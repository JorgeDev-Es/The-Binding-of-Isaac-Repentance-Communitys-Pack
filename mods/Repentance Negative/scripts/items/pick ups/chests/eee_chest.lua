local Mod = RepMMod

local function optionsCheck(pickup)
	if pickup.OptionsPickupIndex and pickup.OptionsPickupIndex > 0 then
		for _, entity in pairs(Isaac.FindByType(5, -1, -1)) do
			if
				entity:ToPickup().OptionsPickupIndex
				and entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex
				and GetPtrHash(entity:ToPickup()) ~= GetPtrHash(pickup)
			then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
				entity:Remove()
			end
		end
	end
end

local payouts = {
	[1] = { Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_FULL },
	[2] = { Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_HALF },
	[3] = { Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_SOUL },
	[4] = { Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_TAROTCARD, SubType = 0 },
	[5] = {
		Type = EntityType.ENTITY_PICKUP,
		Variant = PickupVariant.PICKUP_TAROTCARD,
		SubType = Mod.RepmTypes.CARD_MINUS_SHARD,
	},
}

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE, function(_, pickup)
	
end, Mod.RepmTypes.EEE_CHEST)

---@param pickup EntityPickup
local function onPrePickupGetLootList(_, pickup)
	if pickup.Variant == Mod.RepmTypes.EEE_CHEST and pickup.SubType == ChestSubType.CHEST_CLOSED then
		local loot = LootList()
		local rng = RNG(pickup.InitSeed)
		if rng:RandomFloat() <= 0.1 then
			loot:PushEntry(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE,
				Game():GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, pickup.InitSeed)
			)
		else
			local rolls = rng:RandomInt(1, 3)
			if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_LUCKY_TOE) then
				rolls = rolls + 1
			end
			if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOMS_KEY) then
				rolls = rolls + rng:RandomInt(1, 2)
			end

			local overpaid = 0

			for i = 1, rolls do
				local payout = payouts[rng:RandomInt(1, 5)]

				if payout.Variant == PickupVariant.PICKUP_TAROTCARD then
					if payout.SubType == 0 then
						payout.SubType = rng:RandomInt(56, 77)
					end
					overpaid = overpaid + 1
				end
				print(payout.Type.." : "..payout.Variant.." : "..payout.SubType)
				loot:PushEntry(payout.Type, payout.Variant, payout.SubType)

				if i + overpaid >= rolls then
					break
				end
			end
		end
		return loot
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_GET_LOOT_LIST, onPrePickupGetLootList)

---@param pickup EntityPickup
---@param player EntityPlayer
function Mod.openEEEChest(pickup, player)
	optionsCheck(pickup)
	pickup:GetSprite():Play("Open")
	for _, item in pairs(pickup:GetLootList():GetEntries()) do
		print(item:GetType().." : "..item:GetVariant().." : "..item:GetSubType())
		if item:GetType() == EntityType.ENTITY_PICKUP then
			if item:GetVariant() == PickupVariant.PICKUP_COLLECTIBLE then
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pickup:Remove()
				local pedestal =
					Isaac.Spawn(item:GetType(), item:GetVariant(), item:GetSubType(), pickup.Position, Vector.Zero, nil)
				pedestal:GetSprite():ReplaceSpritesheet(5, "gfx/items/slots/EEE_pedestal.png", true)
				pedestal:GetSprite():SetOverlayFrame("Alternates", 5)
				pedestal:Update()
			else
				Isaac.Spawn(
					item:GetType(),
					item:GetVariant(),
					item:GetSubType(),
					pickup.Position,
					EntityPickup.GetRandomPickupVelocity(pickup.Position, item:GetRNG(), 0),
					nil
				)
			end
		end
	end
	pickup.SubType = ChestSubType.CHEST_OPENED
	SFXManager():Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
	pickup:UpdatePickupGhosts()
end

local function chestCollision(_, pickup, collider, _)
	if not collider or not collider:ToPlayer() then
		return
	end
	local player = collider:ToPlayer()
	local sprite = pickup:GetSprite()
	if pickup.SubType == ChestSubType.CHEST_CLOSED then
		if sprite:IsPlaying("Appear") then
			return false
		end
		Mod.openEEEChest(pickup, player)
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, chestCollision, Mod.RepmTypes.EEE_CHEST)

local function chestInit(_, pickup)
	if pickup.SubType == ChestSubType.CHEST_OPENED then
		pickup:Remove()
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, chestInit, Mod.RepmTypes.EEE_CHEST)

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, function(_, pickup, eType, Variant, SubType)
	if
		pickup.Type == EntityType.ENTITY_PICKUP
		and pickup.Variant == Mod.RepmTypes.EEE_CHEST
		and pickup.SubType == ChestSubType.CHEST_OPENED
	then
		return false
	end
end)

---@param pickup EntityPickup
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE_GHOST_PICKUPS, function(_, pickup)
	if pickup.Variant == Mod.RepmTypes.EEE_CHEST and pickup.SubType == ChestSubType.CHEST_CLOSED
	and PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_EYE) then
		return true
	end
end)

---@param pickup EntityPickup
local function chestSpawn(_, pickup)
	if Isaac.GetPersistentGameData():Unlocked(RepMMod.RepmAchivements.SIM_LAMB.ID) then
		if
			Game():GetRoom():GetType() ~= RoomType.ROOM_CHALLENGE
			and Game():GetLevel():GetStage() ~= LevelStage.STAGE6
		then
			local rng = pickup:GetDropRNG()
			if
				pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST and rng:RandomFloat() <= 0.01
				or pickup.Variant == PickupVariant.PICKUP_REDCHEST and rng:RandomFloat() <= 0.25
			then
				pickup:Morph(5, Mod.RepmTypes.EEE_CHEST, 1, true, true, false)
				SFXManager():Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
				pickup:UpdatePickupGhosts()
			end
		end
	end
end
Mod:AddCallback("REPM_PICKUP_INIT_FIRST", chestSpawn)
