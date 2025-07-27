local mod = TaintedTreasure
local game = Game()

--From Fiend Folio, this looked like it was fun to write

local bombsToBePostFired = {}
function mod:testForPostFireBomb(ent)
	for _, bomb in pairs(bombsToBePostFired) do
		local player = nil
		if not bomb.SpawnerEntity then
			return
		elseif bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() then
			player = bomb.SpawnerEntity:ToPlayer()
		elseif bomb.SpawnerEntity:ToFamiliar() and bomb.SpawnerEntity:ToFamiliar().Player then
			local familiar = bomb.SpawnerEntity:ToFamiliar()
			if mod:DoesFamiliarShootPlayerTears(familiar) then
				player = familiar.Player
			else
				return
			end
		else
			return
		end
		mod:RunCustomCallback("FIRE_BOMB", {bomb, player})
	end

	bombsToBePostFired = {}
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.testForPostFireBomb)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.INCUBUS)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.SPRINKLER)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.TWISTED_BABY)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.BLOOD_BABY)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.testForPostFireBomb, FamiliarVariant.UMBILICAL_BABY)

function mod:postScatterBomb(bomb, obomb)
	--Copy over effects
    mod:TTCopyEntStatus(obomb, bomb)
end

function mod:testForPostScatterBomb(obomb)
	for _, bomb in pairs(bombsToBePostFired) do
		mod:postScatterBomb(bomb, obomb)
	end

	bombsToBePostFired = {}
end

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
	if bomb:IsDead() and (bomb.Flags & TearFlags.TEAR_SCATTER_BOMB == TearFlags.TEAR_SCATTER_BOMB or
	                      bomb.Flags & TearFlags.TEAR_SPLIT == TearFlags.TEAR_SPLIT or
	                      bomb.Flags & TearFlags.TEAR_PERSISTENT == TearFlags.TEAR_PERSISTENT or
	                      bomb.Flags & TearFlags.TEAR_QUADSPLIT == TearFlags.TEAR_QUADSPLIT)
	then
		mod:testForPostScatterBomb(bomb)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
	if bomb.Variant == BombVariant.BOMB_THROWABLE then
		return
	elseif not bomb.SpawnerEntity then
		return
	elseif bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() then
		bombsToBePostFired[bomb.InitSeed] = bomb
	elseif bomb.SpawnerEntity:ToFamiliar() and bomb.SpawnerEntity:ToFamiliar().Player then
		local familiar = bomb.SpawnerEntity:ToFamiliar()
		if mod:DoesFamiliarShootPlayerTears(familiar) then
			bombsToBePostFired[bomb.InitSeed] = bomb
		else
			return
		end
	else
		return
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bomb)
	if bombsToBePostFired[bomb.InitSeed] then
		bombsToBePostFired[bomb.InitSeed] = nil
	end
end, EntityType.ENTITY_BOMBDROP)