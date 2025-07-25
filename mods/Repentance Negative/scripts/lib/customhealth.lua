local Mod = RepMMod
local game = Game()
local sfx = SFXManager()
local SaveManager = Mod.saveManager

local HeartKey = {
	[Mod.RepmTypes.PICKUP_HEART_FROZEN] = "HEART_ICE",
	[Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF] = "HEART_ICE",
}

local HeartHPAdd = {
	[Mod.RepmTypes.PICKUP_HEART_FROZEN] = 2,
	[Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF] = 1,
}

local HeartPickupSound = {
	[Mod.RepmTypes.PICKUP_HEART_FROZEN] = SoundEffect.SOUND_FREEZE,
	[Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF] = SoundEffect.SOUND_FREEZE,
}

local HeartNumFlies = {
	[Mod.RepmTypes.PICKUP_HEART_FROZEN] = 4,
	[Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF] = 2,
}

--------------------
-- HEART REPLACEMENT
--------------------
--------------------------------------------------------
-- PREVENT MORPHING HEARTS TO THEIR TAINTED COUNTERPARTS
-- WHEN USING SPECIFIC CARDS AND ITEMS
-- OR WHEN IN SPECIFIC ROOMS

local SusCards = {
	Card.CARD_LOVERS,
	Card.CARD_HIEROPHANT,
	Card.CARD_REVERSE_HIEROPHANT,
	Card.CARD_QUEEN_OF_HEARTS,
	Card.CARD_REVERSE_FOOL,
}

local function isSusCard(thisCard)
	for _, card in pairs(SusCards) do
		if card == thisCard then
			return true
		end
	end

	return false
end

local function cancelTaintedMorph()
	local h = Isaac.FindByType(5, 10)

	for _, heart in pairs(h) do
		if heart.FrameCount == 0 then
			heart:GetData().noTaintedMorph = true
		end
	end
end

local function RemoveStoreCreditFromPlayer(player) -- Partially from FF
	local t0 = player:GetTrinket(0)
	local t1 = player:GetTrinket(1)
	
	if t0 & TrinketType.TRINKET_ID_MASK == TrinketType.TRINKET_STORE_CREDIT then
		player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		return
	elseif t1 & TrinketType.TRINKET_ID_MASK == TrinketType.TRINKET_STORE_CREDIT then
		player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		return
	end
	if REPENTOGON then
		player:TryRemoveSmeltedTrinket(TrinketType.TRINKET_STORE_CREDIT)
	else
		local numStoreCredits = player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
			numStoreCredits = numStoreCredits - 1
		end
		
		if numStoreCredits >= 2 then
			player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT + TrinketType.TRINKET_GOLDEN_FLAG)
		else
			player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		end
	end
end

local function TryRemoveStoreCredit(player)
	if Game():GetRoom():GetType() == RoomType.ROOM_SHOP then
		if player:HasTrinket(TrinketType.TRINKET_STORE_CREDIT) then
			RemoveStoreCreditFromPlayer(player)
		else
			for _,player in ipairs(Mod.Filter(Mod.GetPlayers(), function(_, player) return player:HasTrinket(TrinketType.TRINKET_STORE_CREDIT) end)) do
				RemoveStoreCreditFromPlayer(player)
				return
			end
		end
	end
end

--[[
Mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, _, _)
	if isSusCard(card) then
		cancelTaintedMorph()
	end
end)

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, _, _, _)
	cancelTaintedMorph()
end, CollectibleType.COLLECTIBLE_THE_JAR)

Mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, _)
	cancelTaintedMorph()
end, PillEffect.PILLEFFECT_HEMATEMESIS)
]]
------------------------------------------------
-- HANDLE DUPLICATING HEARTS WITH JERA, DIPLOPIA
-- OR CROOKED PENNY, TO MAKE SURE THAT ALL
-- ORIGINAL HEARTS ARE COPIED 1:1

--[[
local function handleHeartsDupe()
	-- iterate through all pickups that have FrameCount of 0 (they've just spawned)
	-- find an older pickup with the same InitSeed
	-- assign its subtype to the newer pickup's subtype
	local h = Isaac.FindByType(5, 10)

	for _, newHeart in pairs(h) do
		if newHeart.FrameCount == 0 then
			for _, oldHeart in pairs(h) do
				if oldHeart.FrameCount > 0 and newHeart.InitSeed == oldHeart.InitSeed then
					newHeart:GetData().noTaintedMorph = true
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, _, _, _)
	handleHeartsDupe()
end, CollectibleType.COLLECTIBLE_DIPLOPIA)

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, _, _, _)
	handleHeartsDupe()
end, CollectibleType.COLLECTIBLE_CROOKED_PENNY)

Mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, _, _)
	handleHeartsDupe()
end, Card.RUNE_JERA)
]]
-------
-- CORE

local function taintedMorph(heartPickup, taintedSubtype)
	heartPickup:Morph(5, 10, taintedSubtype, true, true, true)
end

--[[Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if
		not pickup:GetData().noTaintedMorph
		and pickup.Price == 0
		and game:GetRoom():GetType() ~= RoomType.ROOM_SUPERSECRET
		and (pickup:GetSprite():IsPlaying("Appear") or pickup:GetSprite():IsPlaying("AppearFast"))
		-- BE WARNED THAT FRAMECOUNT == 1 IS NOT SPRITE:GETFRAME() == 1, SPRITE FRAME IS ACTUALLY 1 HIGHER THAN THE NORMAL FRAME
		-- and I don't even know whom to blame for that
		and pickup.FrameCount == 1
	then
		local isTaintFrost = false
		Mod:AnyPlayerDo(function(player)
			if player:GetPlayerType() == Mod.RepmTypes.CHARACTER_FROSTY_B then
				isTaintFrost = true
			end
		end)
		rng:SetSeed(pickup.InitSeed + Random(), 1)
		local roll = rng:RandomFloat() * 1000
		local subtype = pickup.SubType
		local baseChance
		if subtype == HeartSubType.HEART_SOUL and Isaac.GetPersistentGameData():Unlocked(Mod.RepmAchivements.FROZEN_HEARTS.ID) then
			baseChance = 200
			if roll < baseChance then
				taintedMorph(pickup, Mod.RepmTypes.PICKUP_HEART_FROZEN)
			end
		elseif
			(
				subtype == HeartSubType.HEART_SOUL
				or subtype == HeartSubType.HEART_FULL
				or subtype == HeartSubType.HEART_DOUBLEPACK
				or subtype == HeartSubType.HEART_SCARED
				or subtype == HeartSubType.HEART_HALF
			)
			and Isaac.GetPersistentGameData():Unlocked(Mod.RepmAchivements.FROZEN_HEARTS.ID)
			and isTaintFrost
		then
			baseChance = 200
			if roll < baseChance or subtype == HeartSubType.HEART_SOUL then
				taintedMorph(pickup, Mod.RepmTypes.PICKUP_HEART_FROZEN)
			end
		end
	end
end, PickupVariant.PICKUP_HEART)]]

--------------------
-- REGISTERING HEARTS
---------------------

CustomHealthAPI.Library.RegisterSoulHealth("HEART_ICE", {
	AnimationFilename = "gfx/ui/CustomHealthAPI/ui_icehearts.anm2",
	AnimationName = { "IceHeartHalf", "IceHeartFull" },

	SortOrder = 200,
	AddPriority = 225,
	HealFlashRO = 50 / 255,
	HealFlashGO = 70 / 255,
	HealFlashBO = 90 / 255,
	MaxHP = 2,
	PrioritizeHealing = true,
	PickupEntities = {
		{ ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = Mod.RepmTypes.PICKUP_HEART_FROZEN },
		{ ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF },
	},
	SumptoriumSubType = 210,
	SumptoriumSplatColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
	SumptoriumTrailColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
	SumptoriumCollectSoundSettings = {
		ID = SoundEffect.SOUND_ROTTEN_HEART,
		Volume = 1.0,
		FrameDelay = 0,
		Loop = false,
		Pitch = 1.0,
		Pan = 0,
	},
})
local dupesOff = false
CustomHealthAPI.Library.AddCallback(
	"RepentanceMinus",
	CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED,
	0,
	function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
		if key == "HEART_ICE" then
			local pdata = Mod:RunSave(player)
			pdata.isIceheartCrept = true
			for i = 0, 360, 45 do
				local angle = Vector.FromAngle(i) * 8
				local tear = player:FireTear(player.Position, angle, false, true, false, player, 1)
				--tear:ClearTearFlags()
				tear.TearFlags = BitSet128(0, 0)
				tear:AddTearFlags(TearFlags.TEAR_ICE)
				tear:ChangeVariant(41)
			end
		end
	end
)

local function whenSpawningCreep_IceHeart(_, player)
	local pdata = Mod:RunSave(player)
	if pdata.isIceheartCrept and game:GetFrameCount() % 3 == 0 then
		local creep = Isaac.Spawn(1000, 54, 0, player.Position, Vector.Zero, player):ToEffect()
		creep.Scale = 0.65
		--creep:SetTimeout(15)
		creep:Update()
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, whenSpawningCreep_IceHeart)

local function disableCreepRoom()
	Mod:AnyPlayerDo(function(player)
		local pdata = Mod:RunSave(player)
		pdata.isIceheartCrept = nil
	end)
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, disableCreepRoom)

--------------------------------------------------------------------

-------------
-- SUMPTORIUM
-------------
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, Tear)
	if Tear.SpawnerEntity and Tear.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
		local familiars = Isaac.FindInRadius(Tear.Position - Tear.Velocity, 0.0001, EntityPartition.FAMILIAR)

		for _, familiar in ipairs(familiars) do
			if familiar.Variant == FamiliarVariant.BLOOD_BABY then
				--if familiar.SubType == Mod.CustomFamiliars.ClotSubtype.DAUNTLESS then
				--     Tear:GetData().isDauntlessClot = true
				--end
			end
		end
	elseif Tear.SpawnerEntity and Tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR then
		local familiar = Tear.SpawnerEntity:ToFamiliar()
		if familiar.Variant == FamiliarVariant.BLOOD_BABY then
			--if familiar.SubType == Mod.CustomFamiliars.ClotSubtype.DAUNTLESS then
			--    Tear:GetData().isDauntlessClot = true
			--end
		end
	end
end)

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, Tear)
	if Tear.FrameCount ~= 1 then
		return
	end
end)

--------------------
-- PICKING HEARTS UP
-- HEARTS UPDATE
--------------------
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if pickup.SubType < 84 or pickup.SubType > 100 then
		return
	end

	local sprite = pickup:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", false)
	end
	if sprite:IsPlaying("Collect") and sprite:GetFrame() > 5 then
		pickup:Remove()
	end
end, PickupVariant.PICKUP_HEART)

---@param pickup EntityPickup
---@param collider EntityPlayer
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	--print(pickup.SubType)
	if pickup.SubType ~= Mod.RepmTypes.PICKUP_HEART_FROZEN and pickup.SubType ~= Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF then
		return
	end
	if collider.Type ~= EntityType.ENTITY_PLAYER then
		return
	end
	local player = collider:ToPlayer()
	local sprite = pickup:GetSprite()

	if pickup:IsShopItem() and (pickup.Price > player:GetNumCoins() or not player:IsExtraAnimationFinished()) then
		return true
	elseif sprite:IsPlaying("Collect") then
		return true
	elseif pickup.Wait > 0 then
		return not sprite:IsPlaying("Idle")
	elseif sprite:WasEventTriggered("DropSound") or sprite:IsPlaying("Idle") then
		if pickup.Price == PickupPrice.PRICE_SPIKES then
			local tookDamage = player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
			if not tookDamage then
				return pickup:IsShopItem()
			end
		end

		-- SOUL HEALTH
		if CustomHealthAPI.Library.CanPickKey(player, HeartKey[pickup.SubType]) then
			CustomHealthAPI.Library.AddHealth(player, HeartKey[pickup.SubType], HeartHPAdd[pickup.SubType], true)
			sfx:Play(HeartPickupSound[pickup.SubType], 1, 0, false, 1.0)
			if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_HOLY_LIGHTER) then
				player:SetActiveCharge(
					math.min(12, player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + 2),
					ActiveSlot.SLOT_POCKET
				)
				sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
			end
		else
			return pickup:IsShopItem()
		end

		if pickup.OptionsPickupIndex ~= 0 then
			for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
				if
					entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex
					and (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
				then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
					entity:Remove()
				end
			end
		end

		if pickup:IsShopItem() then
			local pickupSprite = pickup:GetSprite()
			local holdSprite = Sprite()

			holdSprite:Load(pickupSprite:GetFilename(), true)
			holdSprite:Play(pickupSprite:GetAnimation(), true)
			holdSprite:SetFrame(pickupSprite:GetFrame())
			player:AnimatePickup(holdSprite)

			if pickup.Price > 0 then
				player:AddCoins(-1 * pickup.Price)
			end

			CustomHealthAPI.Library.TriggerRestock(pickup)
			TryRemoveStoreCredit(player)
			pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pickup:Remove()
		else
			sprite:Play("Collect", true)
			pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pickup:Die()
		end

		game:GetLevel():SetHeartPicked()
		game:ClearStagesWithoutHeartsPicked()
		game:SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)

		return true
	else
		return false
	end
end, PickupVariant.PICKUP_HEART)

---@param pickup EntityPickup
local function FrozenHeartSpawnOld(_, pickup)
	if Isaac.GetPersistentGameData():Unlocked(Mod.RepmAchivements.FROZEN_HEARTS.ID) and not pickup:GetData().noTaintedMorph then
		local subtype = {
			[HeartSubType.HEART_HALF_SOUL] = Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF,
			[HeartSubType.HEART_SOUL] = Mod.RepmTypes.PICKUP_HEART_FROZEN,
		}
		if PlayerManager.AnyoneIsPlayerType(Mod.RepmTypes.CHARACTER_FROSTY_B) or PlayerManager.AnyoneIsPlayerType(Mod.RepmTypes.CHARACTER_FROSTY_C) then
			subtype[HeartSubType.HEART_FULL] = Mod.RepmTypes.PICKUP_HEART_FROZEN
			subtype[HeartSubType.HEART_DOUBLEPACK] = Mod.RepmTypes.PICKUP_HEART_FROZEN
			subtype[HeartSubType.HEART_SCARED] = Mod.RepmTypes.PICKUP_HEART_FROZEN
			subtype[HeartSubType.HEART_HALF] = Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF
		end
		if subtype[pickup.SubType] and pickup:GetDropRNG():RandomFloat() <= 0.20 then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, subtype[pickup.SubType], true, true)
		end
	end
end
--Mod:AddCallback("REPM_PICKUP_INIT_FIRST", FrozenHeartSpawn, PickupVariant.PICKUP_HEART)


---@param ptype EntityType | integer
---@param variant number | PickupVariant
---@param subtype number | HeartSubType
---@param position Vector
---@param velocity Vector
---@param spawner Entity
---@param seed integer
---@return table
local function FrozenHeartSpawn(_, ptype, variant, subtype, position, velocity, spawner, seed)
	if Isaac.GetPersistentGameData():Unlocked(Mod.RepmAchivements.FROZEN_HEARTS.ID)
	and ptype == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_HEART
	and (type(spawner) == "nil") then
		local newsubtype = {
			[HeartSubType.HEART_HALF_SOUL] = Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF,
			[HeartSubType.HEART_SOUL] = Mod.RepmTypes.PICKUP_HEART_FROZEN,
		}
		if PlayerManager.AnyoneIsPlayerType(Mod.RepmTypes.CHARACTER_FROSTY_B) or PlayerManager.AnyoneIsPlayerType(Mod.RepmTypes.CHARACTER_FROSTY_C) then
			newsubtype[HeartSubType.HEART_FULL] = Mod.RepmTypes.PICKUP_HEART_FROZEN
			newsubtype[HeartSubType.HEART_DOUBLEPACK] = Mod.RepmTypes.PICKUP_HEART_FROZEN
			newsubtype[HeartSubType.HEART_SCARED] = Mod.RepmTypes.PICKUP_HEART_FROZEN
			newsubtype[HeartSubType.HEART_HALF] = Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF
		end
		local pickedSubType = newsubtype[subtype]
		local chance = 0.2
		local rng = RNG(seed)
		if subtype == 0 then
			local chooser = WeightedOutcomePicker()
			chooser:AddOutcomeWeight(Mod.RepmTypes.PICKUP_HEART_FROZEN, 50)
			chooser:AddOutcomeWeight(Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF, 50)
			pickedSubType = chooser:PickOutcome(rng)
			chance = 0.1
		end
		if pickedSubType and rng:RandomFloat() <= chance then
			return {ptype, variant, pickedSubType, seed}
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, FrozenHeartSpawn)
