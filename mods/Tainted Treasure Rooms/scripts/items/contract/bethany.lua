local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source)
	if entity.Variant == FamiliarVariant.WISP and entity.SubType == TaintedCollectibles.CONTRACT_OF_SERVITUDE then
		if amount >= entity.HitPoints then
			--print(entity.HitPoints, amount)
			return false
		end
	end
end, EntityType.ENTITY_FAMILIAR)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	if familiar.SubType == TaintedCollectibles.CONTRACT_OF_SERVITUDE then
		if familiar.HitPoints == 1 then
			familiar.CollisionDamage = 0
		else
			familiar.CollisionDamage = 7
		end
	end
end, FamiliarVariant.WISP)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, TaintedCollectibles.CONTRACT_OF_SERVITUDE)) do
		if entity.HitPoints == entity.MaxHitPoints then
			local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP)
			local validwisps = {}
			for i, wisp in pairs(wisps) do
				if not (wisp.HitPoints == wisp.MaxHitPoints or GetPtrHash(wisp) == GetPtrHash(entity)) then
					table.insert(validwisps, wisp)
				end
			end
			
			local wisp = mod:GetRandomElem(validwisps)
			if wisp then
				wisp.HitPoints = wisp.MaxHitPoints
				local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, wisp.Position, Vector.Zero, entity):ToEffect()
				poof.Color = Color(1, 1, 1, 1, 1, 1, 1)
				poof.SpriteScale = poof.SpriteScale*0.8
			end
		else
			entity.HitPoints = entity.MaxHitPoints
		end
	end
end)