local mod = TaintedTreasure
local game = Game()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	familiar.CollisionDamage = math.max(3.5, player.Damage)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
		if player:GetFireDirection() ~= -1 then
			familiar.Velocity = mod:Lerp(familiar.Velocity, player:GetAimDirection():Resized(10), 0.3)
		else
			familiar.Velocity = familiar.Velocity/1.3
		end
		if Options.MouseControl and Input.IsMouseBtnPressed(0) then
			local pos = Input.GetMousePosition(true)
			familiar.Velocity = mod:Lerp(familiar.Velocity, (pos - familiar.Position), 0.15)
		end
	else
		for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET)) do
			if entity.SpawnerEntity.InitSeed == player.InitSeed then
				familiar.Velocity = mod:Lerp(familiar.Velocity, (entity.Position - familiar.Position), 0.15)
			end
		end
	end
	if familiar.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_WALLS then
		familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
end, TaintedFamiliars.BLUEBABYS_BEST_FRIEND)
