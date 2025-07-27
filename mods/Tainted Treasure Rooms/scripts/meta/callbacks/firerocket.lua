local mod = TaintedTreasure
local game = Game()

--From Fiend Folio

function mod:rollEpicFetusEffects(player, target) -- Epic Fetus
	local data = target:GetData()
	if not data.TTRocketQueuedEffects then
        mod:RunCustomCallback("FIRE_ROCKET", {target, player})
		data.TTRocketQueuedEffects = true
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, target)
	local player = nil
	if target.SpawnerEntity and target.SpawnerEntity:ToPlayer() then
		player = target.SpawnerEntity:ToPlayer()
	elseif target.SpawnerEntity and target.SpawnerEntity:ToFamiliar() and target.SpawnerEntity:ToFamiliar().Player then
		local familiar = target.SpawnerEntity:ToFamiliar()
		if mod:DoesFamiliarShootPlayerTears(familiar) then
			player = familiar.Player
		else
			return
		end
	else
		return
	end
	mod:rollEpicFetusEffects(player, target)
end, EffectVariant.TARGET)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, rocket)
	local player = nil
	if rocket.SpawnerEntity and rocket.SpawnerEntity:ToPlayer() then
		player = rocket.SpawnerEntity:ToPlayer()
	elseif rocket.SpawnerEntity and rocket.SpawnerEntity:ToFamiliar() and rocket.SpawnerEntity:ToFamiliar().Player then
		local familiar = rocket.SpawnerEntity:ToFamiliar()
		if mod:DoesFamiliarShootPlayerTears(familiar) then
			player = familiar.Player
		else
			return
		end
	else
		return
	end

	local rocketdata = rocket:GetData()
	if rocket.FrameCount <= 1 then
		if rocket.Parent and rocket.Parent.Type == EntityType.ENTITY_EFFECT and rocket.Parent.Variant == EffectVariant.TARGET and not rocket.Parent:GetData().TTPassedOnRocketEffects then
            mod:TTCopyEntStatus(rocket.Parent, rocket)
			rocket.Parent:GetData().TTPassedOnRocketEffects = true
            rocketdata.TTRocketQueuedEffects = true
		else
			mod:rollEpicFetusEffects(player, rocket)
		end
	end
end, EffectVariant.ROCKET)