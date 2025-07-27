local mod = TaintedTreasure
local game = Game()

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
	local data = laser:GetData()
	if laser.FrameCount == 1 then
		local var = laser.Variant
		if var == 4 or var == 7 or var == 8 or var == 13 then -- Pride, Tractor Beam, Circle of Protection and Beast Lasers
			return
		end

		if laser.SpawnerEntity and laser.SpawnerEntity.Type == EntityType.ENTITY_PLAYER and var == 2 and laser.SubType == 0 then
			local familiars = Isaac.FindInRadius(laser.Position, 0.000001, EntityPartition.FAMILIAR)
			for _,familiar in ipairs(familiars) do
				if familiar.Variant == FamiliarVariant.FINGER then
					return
				end
			end
		end

		local player = nil
		if laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer() then
			player = laser.SpawnerEntity:ToPlayer()
		elseif laser.SpawnerEntity and laser.SpawnerEntity:ToFamiliar() and laser.SpawnerEntity:ToFamiliar().Player then
			local familiar = laser.SpawnerEntity:ToFamiliar()

			if familiar.Variant == FamiliarVariant.INCUBUS or familiar.Variant == FamiliarVariant.SPRINKLER or
			familiar.Variant == FamiliarVariant.TWISTED_BABY or familiar.Variant == FamiliarVariant.BLOOD_BABY or
			familiar.Variant == FamiliarVariant.UMBILICAL_BABY then
				player = familiar.Player
			else
				return
			end
		else
			return
		end

		mod:RunCustomCallback("FIRE_LASER", {laser, player})
	end
	if data.ForceSpriteScale then
		laser.SpriteScale = data.ForceSpriteScale
		data.ForceSpriteScale = nil
		laser.Visible = true
	end
end)