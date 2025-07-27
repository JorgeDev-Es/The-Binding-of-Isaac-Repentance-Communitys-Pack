local mod = TaintedTreasure
local game = Game()

--Shamelessly stolen from Fiend Folio
--Good god why does this even require any effort at all stupid ass API

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear) -- Regular tears
	local player = mod:GetPlayerFromTear(tear)
	if player then
		mod:RunCustomCallback("FIRE_TEAR", {tear, player, false, tear:HasTearFlags(BitSet128(0, 1 << (127 - 64)))})
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear) -- Ludovico Technique tears
	if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
		local player = nil
		if not tear.SpawnerEntity then
			return
		elseif tear.SpawnerEntity:ToPlayer() then
			player = tear.SpawnerEntity:ToPlayer()
		elseif tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player then
			local familiar = tear.SpawnerEntity:ToFamiliar()
			if mod:DoesFamiliarShootPlayerTears(familiar) then
				player = familiar.Player
			else
				return
			end
		else
			return
		end

		if math.floor(tear.FrameCount / player.MaxFireDelay) ~= math.floor((tear.FrameCount - 1) / player.MaxFireDelay) then
			mod:postLudoTearReset(tear)
			mod:RunCustomCallback("FIRE_TEAR", {tear, player, false, true})
		end
	end
end)

local fatesRewardTearsToBePostFired = {} -- Fate's Reward tears (they suck or something idk lol)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	for _, tear in pairs(fatesRewardTearsToBePostFired) do
		local player = nil
		if not tear.SpawnerEntity then
			return
		elseif tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player then
			local familiar = tear.SpawnerEntity:ToFamiliar()

			if familiar.Variant == FamiliarVariant.FATES_REWARD then
				player = familiar.Player
			else
				return
			end
		else
			return
		end

		mod:RunCustomCallback("FIRE_TEAR", {tear, player, true, tear:HasTearFlags(BitSet128(0, 1 << (127 - 64)))})
	end

	fatesRewardTearsToBePostFired = {}
end, FamiliarVariant.FATES_REWARD)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	if tear.SpawnerEntity then
	    if tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and
		   tear.SpawnerEntity.Variant == FamiliarVariant.FATES_REWARD and
		   tear.SpawnerEntity:ToFamiliar().Player
		then
			fatesRewardTearsToBePostFired[tear.Index .. " " .. tear.InitSeed] = tear
		elseif tear.SpawnerEntity.Type == EntityType.ENTITY_PLAYER and tear.Variant == TearVariant.SWORD_BEAM then
			local player = mod:GetPlayerFromTear(tear)
			mod:RunCustomCallback("FIRE_TEAR", {tear, player, false, tear:HasTearFlags(BitSet128(0, 1 << (127 - 64)))})
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, tear)
	if fatesRewardTearsToBePostFired[tear.Index .. " " .. tear.InitSeed] then
		fatesRewardTearsToBePostFired[tear.Index .. " " .. tear.InitSeed] = nil
	end
end, EntityType.ENTITY_TEAR)

function mod:postLudoTearReset(tear)
	local data = tear:GetData()

    --I guess like reset everything here?
    data.TaintedRepulsion = nil
    data.TaintedFireWave = nil
	data.TaintedPoopBlast = nil
	data.TaintedColoredContact = nil
	data.TaintedGermination = nil
	if data.TaintedEvangelismHalo then
		data.TaintedEvangelismHalo:Remove()
	end
end

function mod:GetPlayerFromTear(tear)
	local player
	if not tear.SpawnerEntity then
		return
	elseif tear.SpawnerEntity:ToPlayer() then
		player = tear.SpawnerEntity:ToPlayer()
	elseif tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player then
		local familiar = tear.SpawnerEntity:ToFamiliar()
		if mod:DoesFamiliarShootPlayerTears(familiar) then
			player = familiar.Player
		else
			return
		end
	else
		return
	end
	return player
end