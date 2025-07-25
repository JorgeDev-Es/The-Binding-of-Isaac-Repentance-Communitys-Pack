local Mod = RepMMod
local SaveManager = Mod.saveManager

Mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, _, player, flags)
	Mod:RunSave(player).GroovyImmune = true
	if player:HasFullHearts() then
		Isaac.Spawn(5, 10, 1, player.Position, Vector.FromAngle(math.random(360)) * 3, nil)
		Isaac.Spawn(5, 10, 1, player.Position, Vector.FromAngle(math.random(360)) * 3, nil)
		Isaac.Spawn(5, 10, 1, player.Position, Vector.FromAngle(math.random(360)) * 3, nil)
	end
	Isaac.CreateTimer(function()
		Mod:RunSave(player).GroovyImmune = false
	end, 600, 1, true)
	player:AddHearts(3)
	player:AnimateHappy()
end, Mod.RepmTypes.PILL_EFFECT_GROOVY)

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player, amount, DamageFlag)
	if player and player:ToPlayer() then
        if Mod:RunSave(player:ToPlayer()).GroovyImmune == true then
            return false
        end
    end
end, EntityType.ENTITY_PLAYER)

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	Mod:AnyPlayerDo(function(player)
		Mod:RunSave(player).GroovyImmune = false
	end)
end)