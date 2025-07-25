local BumFamiliars = {}

local enums = JosephMod.enums
local BUM_PAYOUT_DISTANCE_SQR = 65*65
local LIL_SLOT_COIN_COST = 3
local LIL_FORTUNE_TELLER_COIN_COST = 4
local LIL_BLOOD_BANK_HEART_COST = 1

---@class EntityToSpawn
---@field type EntityType
---@field variant integer
---@field subtype integer

---@class EntityToPickup
---@field variant PickupVariant
---@field subtype integer

---@class bumPickups
---@field reward integer
---@field value EntityToPickup
---@field spawn nil | EntityToSpawn

---@class bumPayouts
---@field chance number
---@field value EntityToSpawn

---@class bumInfo
---@field collectible CollectibleType
---@field superBum boolean
---@field cost integer
---@field pickups bumPickups[]
---@field payouts bumPayouts[]

---Custom function to define a familiar variant as a "Bum Familiar"
---@param familiarVariant FamiliarVariant
---@param collectibleType CollectibleType
---@param contributesToSuperBum boolean
---@param payoutCost number 
---@param pickups bumPickups[]
---@param payouts bumPayouts[]
local function AddBumFamiliar(familiarVariant, collectibleType, contributesToSuperBum, payoutCost, pickups, payouts)
	BumFamiliars[familiarVariant] = {
		collectible = collectibleType,
		superBum = contributesToSuperBum,
		cost = payoutCost,
		pickups = pickups,
		payouts = payouts
	}
end

---@param familiar EntityFamiliar
local function BumFamiliarInit(_, familiar)
	if BumFamiliars[familiar.Variant] then
		local player = familiar.SpawnerEntity
		local aa = player
		---@diagnostic disable-next-line: need-check-nil
		while aa.Child ~= nil do
			---@diagnostic disable-next-line: need-check-nil
			aa = aa.Child
		end
		---@diagnostic disable-next-line: assign-type-mismatch
		familiar.Parent = aa
		aa.Child = familiar
	end
end
JosephMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, BumFamiliarInit)


---@param familiar EntityFamiliar
local function BumFamiliarUpdate(_, familiar)
	---@type bumInfo
	local bumInfo = BumFamiliars[familiar.Variant]

	if not bumInfo then return end

	local sprite = familiar:GetSprite()

	if sprite:IsFinished("IdleDown") then
		sprite:Play("FloatDown", true)
	end

	local newPos = familiar.Parent.Position - familiar.Position

	local closestEntity
	local bumPickup
	local closestDist = math.huge

	for _, pickup in ipairs(TSIL.EntitySpecific.GetPickups()) do
		local distance = pickup.Position:DistanceSquared(familiar.Position)
		if pickup:Exists() and not pickup:IsDead() and distance < closestDist and not pickup:IsShopItem() then
			local foundBumPickup = TSIL.Utils.Tables.FindFirst(bumInfo.pickups, function (_, foundBumPickup)
				return pickup.Variant == foundBumPickup.value.variant and
				pickup.SubType == foundBumPickup.value.subtype
			end)

			if foundBumPickup then
				closestEntity = pickup
				closestDist = distance
				bumPickup = foundBumPickup
			end
		end
	end

	if sprite:IsPlaying("PreSpawn") or sprite:IsPlaying("Spawn") then
		newPos = Vector.Zero
	elseif sprite:IsFinished("PreSpawn") then
		sprite:Play("Spawn")
		SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN)
		local reward = TSIL.Random.GetRandomElementFromWeightedList(familiar:GetDropRNG(), bumInfo.payouts)
		Isaac.Spawn(
			---@diagnostic disable-next-line: undefined-field
			reward.type,
			---@diagnostic disable-next-line: undefined-field
			reward.variant,
			---@diagnostic disable-next-line: undefined-field
			reward.subtype,
			familiar.Position,
			Vector(math.random(-2, 2), math.random(1,5)),
			familiar
		)
		familiar.Coins = familiar.Coins - bumInfo.cost
		newPos = Vector.Zero
	elseif sprite:IsFinished("Spawn") then
		familiar:GetSprite():Play("FloatDown")
		newPos = Vector.Zero
	elseif closestEntity then
		newPos = closestEntity.Position - familiar.Position
		if (newPos:LengthSquared() < 100 and bumPickup.reward > 0) then
			familiar.Coins = familiar.Coins + bumPickup.reward
			if bumPickup.spawn then
				Isaac.Spawn(
					bumPickup.spawn.type,
					bumPickup.spawn.variant,
					bumPickup.spawn.subtype,
					familiar.Position,
					Vector(math.random(-2, 2), math.random(1,5)),
					familiar
				)
			end
			closestEntity:PlayPickupSound()
			closestEntity.Velocity = Vector(0, 0)
			closestEntity.EntityCollisionClass = 0
			closestEntity:GetSprite():Play("Collect", true)
			closestEntity:Die()
		end
	elseif (familiar.Coins >= bumInfo.cost and familiar.Position:DistanceSquared(familiar.SpawnerEntity.Position) < BUM_PAYOUT_DISTANCE_SQR) then
		familiar:GetSprite():Play("PreSpawn", true)
		SFXManager():Play(SoundEffect.SOUND_COIN_SLOT)
		newPos = Vector.Zero
	elseif (familiar.Parent:ToPlayer() and newPos:DistanceSquared(Vector.Zero) < BUM_PAYOUT_DISTANCE_SQR) or
	(newPos:DistanceSquared(Vector.Zero) < 40*40) then
		newPos = Vector.Zero
	end

	newPos:Resize(4)
	---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
	familiar.Velocity = TSIL.Utils.Math.Lerp(familiar.Velocity, newPos, 0.25)
end
JosephMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BumFamiliarUpdate)

---@param player EntityPlayer
local function EvaluateCache(_, player)
	for familiarType, _ in pairs(BumFamiliars) do
		---@type bumInfo
		local bumInfo = BumFamiliars[familiarType]
		TSIL.Familiars.CheckFamiliarFromCollectibles(
			player,
			bumInfo.collectible,
			familiarType
		)
	end
end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache, CacheFlag.CACHE_FAMILIARS)

---@type bumPickups[]
local lilSlotPickups = {
	{reward = 1, value = {
		variant = PickupVariant.PICKUP_COIN,
		subtype = CoinSubType.COIN_PENNY
	}},
	{reward = 5, value = {
		variant = PickupVariant.PICKUP_COIN,
		subtype = CoinSubType.COIN_NICKEL
	}},
	{reward = 10, value = {
		variant = PickupVariant.PICKUP_COIN,
		subtype = CoinSubType.COIN_DIME
	}},
	{reward = 2, value = {
		variant = PickupVariant.PICKUP_COIN,
		subtype = CoinSubType.COIN_DOUBLEPACK
	}},
	{reward = 10, value = {
		variant = PickupVariant.PICKUP_COIN,
		subtype = CoinSubType.COIN_LUCKYPENNY
	}},
	{reward = 1, value = {
		variant = PickupVariant.PICKUP_COIN,
		subtype = CoinSubType.COIN_GOLDEN
	}}
}

local redHeartPickups = {
	{reward = 2, value = {
		variant = PickupVariant.PICKUP_HEART,
		subtype = HeartSubType.HEART_FULL
	}},
	{reward = 4, value = {
		variant = PickupVariant.PICKUP_HEART,
		subtype = HeartSubType.HEART_DOUBLEPACK
	}},
	{reward = 1, value = {
		variant = PickupVariant.PICKUP_HEART,
		subtype = HeartSubType.HEART_HALF
	}},
	{reward = 1, value = {
		variant = PickupVariant.PICKUP_HEART,
		subtype = HeartSubType.HEART_ROTTEN
	}},
	{reward = 1, value = {
		variant = PickupVariant.PICKUP_HEART,
		subtype = HeartSubType.HEART_BLENDED
	}, spawn = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_HEART,
		subtype = HeartSubType.HEART_HALF_SOUL
	}},
}


AddBumFamiliar(enums.Familiars.LIL_SLOT_MACHINE_FAMILIAR, enums.Collectibles.LIL_SLOT_MACHINE, false, LIL_SLOT_COIN_COST, lilSlotPickups, {
	{chance = 10, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_BOMB,
		subtype = 0
	}},
	{chance = 6, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_KEY,
		subtype = 0
	}},
	{chance = 18, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_HEART,
		subtype = 0
	}},
	{chance = 8, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_PILL,
		subtype = 0
	}},
	{chance = 20, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_COIN,
		subtype = 0
	}},
	{chance = 3, value = { --Pretty Fly
		type = 3,
		variant = 33,
		subtype = 0
	}},
})

AddBumFamiliar(enums.Familiars.LIL_FORTUNE_TELLER_FAMILIAR, enums.Collectibles.LIL_FORTUNE_TELLER, false, LIL_FORTUNE_TELLER_COIN_COST, lilSlotPickups, {
	{chance = 11, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_TAROTCARD,
		subtype = Card.CARD_NULL
	}},
	{chance = 7, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_HEART,
		subtype = HeartSubType.HEART_SOUL
	}},
	{chance = 7, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_HEART,
		subtype = HeartSubType.HEART_HALF_SOUL
	}},
	{chance = 14, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_TRINKET,
		subtype = 0
	}},
})

AddBumFamiliar(enums.Familiars.LIL_BLOOD_BANK_FAMILIAR, enums.Collectibles.LIL_BLOOD_BANK, false, LIL_BLOOD_BANK_HEART_COST, redHeartPickups, {
	{chance = 200, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_COIN,
		subtype = 0
	}},
	{chance = 1, value = {
		type = EntityType.ENTITY_PICKUP,
		variant = PickupVariant.PICKUP_TRINKET,
		subtype = TrinketType.TRINKET_CHILDS_HEART
	}},
})