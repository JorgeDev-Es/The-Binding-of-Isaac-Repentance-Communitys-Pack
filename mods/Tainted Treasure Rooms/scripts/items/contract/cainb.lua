local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local sprite = familiar:GetSprite()
	local data = familiar:GetData()
	local savedata = mod.GetPersistentPlayerData(player)
	
	savedata.ConsumedTrueSightCount = savedata.ConsumedTrueSightCount or 0
	
	if not data.Launched then
		familiar:FollowParent()
	else
		familiar.Velocity = data.Launched:Resized(8)
		for i, entity in pairs(Isaac.FindInRadius(familiar.Position, 13, EntityPartition.PICKUP)) do
			if entity.Variant ~= PickupVariant.PICKUP_COLLECTIBLE and entity:ToPickup() and familiar:Exists() then
				local pickup = Isaac.Spawn(entity.Type, entity.Variant, entity.SubType, Isaac.GetFreeNearPosition(entity.Position, 5), Vector.Zero, familiar)
				savedata.ConsumedTrueSightCount = savedata.ConsumedTrueSightCount + 1
				player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
				player:EvaluateItems()
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
			end
		end
	end
	
	if player:GetData().TaintedFamiliarDoubleTapped == true then
		data.Launched = player:GetLastDirection()
	end
	
	if familiar:CollidesWithGrid() then
		data.Launched = nil
	end
end, TaintedFamiliars.TRUE_SIGHT)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	familiar:AddToFollowers()
end, TaintedFamiliars.TRUE_SIGHT)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	for i, player in pairs(mod:GetAllPlayers()) do
		local savedata = mod.GetPersistentPlayerData(player)
		if savedata.ConsumedTrueSightCount and savedata.ConsumedTrueSightCount > 0 then
			if mod:RandomInt(1, 3) == 1 then
				savedata.ConsumedTrueSightCount = savedata.ConsumedTrueSightCount - 1
				player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
				player:EvaluateItems()
			end
		end
	end
end)