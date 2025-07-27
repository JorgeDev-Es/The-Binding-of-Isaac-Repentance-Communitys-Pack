local mod = TaintedTreasure
local game = Game()

--From Fiend Folio also <3

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, creep) -- Aquarius
	if creep.SpawnerEntity and creep.SpawnerType == EntityType.ENTITY_PLAYER then
		local player = creep.SpawnerEntity:ToPlayer()
        mod:RunCustomCallback("FIRE_CREEP", {creep, player})
	end
end, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, creep)
	local data = creep:GetData()
	if creep.FrameCount == 0 and data.ForceColor then
		creep.Color = data.ForceColor
	end
	if data.TaintedFireWaveCooldown then
		data.TaintedFireWaveCooldown = data.TaintedFireWaveCooldown - 1
	end
end, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)