local Mod = RepMMod

local PinkColor = Color(1, 1, 1, 1, 0, 0, 0, 5, 0.5, 2, 1)

local function tearFire_StrawMilk(_, t)
	local d = t:GetData()
	local player = t.SpawnerEntity
		and (t.SpawnerEntity:ToPlayer() or t.SpawnerEntity:ToFamiliar() and t.SpawnerEntity.Player)
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_STRAWBERRY_MILK) then
		d.IsStrawMilk = true

		if math.random(1, 8) == 8 then
			t:AddTearFlags(TearFlags.TEAR_FREEZE)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, tearFire_StrawMilk)

local function TearDed_StrawMilk(_, t)
	if t:GetData().IsStrawMilk then
		local p = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, t.Position, Vector.Zero, t)
		local player = t.SpawnerEntity and t.SpawnerEntity:ToPlayer()
			or t.SpawnerEntity:ToFamiliar() and t.SpawnerEntity.Player
		if player then
			p:ToEffect().Scale = math.max(0.5, math.min(3, player.Damage / 15))
			--p:Update()
			--p:Update()
			p.Color = Color(5.0, 1.0, 5.0, 1.0, 2, 0, 2)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, TearDed_StrawMilk, EntityType.ENTITY_TEAR)

local function TearColor_StrawMilk(_, player, cache)
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_STRAWBERRY_MILK) then
		player.TearColor = PinkColor
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, TearColor_StrawMilk, CacheFlag.CACHE_TEARCOLOR)
