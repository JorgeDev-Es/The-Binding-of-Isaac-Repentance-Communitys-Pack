local mod = FiendFolio
local game = Game()

mod.DirectionToVector = {
	[Direction.DOWN]	= Vector(0, 1),
	[Direction.UP]		= Vector(0, -1),
	[Direction.LEFT]	= Vector(-1, 0),
	[Direction.RIGHT]	= Vector(1, 0),
}

function mod.GetGoodShootingJoystick(player)
	local returnValue = player:GetShootingJoystick()

    if player.ControllerIndex == 0 and Options.MouseControl and Input.IsMouseBtnPressed(0) then -- ControllerIndex 0 == Keyboard & Mouse
        returnValue = (Input.GetMousePosition(true) - player.Position)
    end

    return returnValue:Normalized()
end

function mod.IsPlayerMarkedFiring(player)
	return (
		player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and
		mod.GetPlayerMarkedTarget(player)
	)
end

function mod.IsPlayerTryingToShoot(player)
	return (
		mod.GetGoodShootingJoystick(player):Length() > 0 or
		player:AreOpposingShootDirectionsPressed() or
		mod.IsPlayerMarkedFiring(player)
	)
end

function mod.GetPlayerFireVector(player)
	return mod.DirectionToVector[player:GetFireDirection()]
end

function mod.GetFamiliarShootingDirection(familiar) -- Return Values: (Vector) Fire Direction, (Bool) Override Movement Inheritance 
	local player = familiar.Player
	local kingBabyTarget = mod.GetMyKingBabyTarget(familiar)

	if kingBabyTarget then
		return (kingBabyTarget.Position - familiar.Position):Normalized(), true
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
		return (mod.GetPlayerMarkedTarget(familiar.Player).Position - familiar.Position):Normalized(), true
	else
		return mod.GetPlayerFireVector(player) or mod.GetGoodShootingJoystick(player), false
	end
end

function mod.GetPlayerMarkedTarget(player, force)
	-- player:GetActiveWeaponEntity doesn't work for Marked :'(
	local data = player:GetData()
	if data.retributionMarkedTargetStorage and data.retributionMarkedTargetStorage:Exists() and not force then
		return data.retributionMarkedTargetStorage
	end

	local targets = Isaac.FindByType(1000, EffectVariant.TARGET)
	for _, target in pairs(targets) do
		if target.SpawnerEntity and target:ToEffect().State == 0 and GetPtrHash(target.SpawnerEntity) == GetPtrHash(player) then
			if player:GetAimDirection():GetAngleDegrees() == (target.Position - player.Position):GetAngleDegrees() then
				data.retributionMarkedTargetStorage = target
				return target
			end
		end
	end
end

function mod.GetMyKingBabyTarget(familiar) -- Modified version of a function by Erfly. Thanks Erfly!!
	local entity = familiar.Parent
	while entity do
		if entity.Type == 3 and entity.Variant == FamiliarVariant.KING_BABY then
			return entity.Target
		end

		entity = entity.Parent
	end
end