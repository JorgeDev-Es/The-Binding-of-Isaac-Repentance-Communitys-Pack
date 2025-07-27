local mod = TaintedTreasure
local game = Game()

function mod:ATGInputLogic(player, data)
    if player:HasCollectible(TaintedCollectibles.ATG_IN_A_JAR) and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex) then
		local bomb = nil
		local isgiga = false
		local damage = 0
		local radiusmult = 0
		mod:scheduleForUpdate(function()
			for i, entity in pairs(Isaac.FindInRadius(player.Position, 30)) do
				if entity.Type == EntityType.ENTITY_BOMB and entity.SpawnerType and entity.SpawnerType == EntityType.ENTITY_PLAYER and entity.FrameCount < 5 and not bomb then
					bomb = entity:ToBomb()
					damage = bomb.ExplosionDamage
					radiusmult = bomb.RadiusMultiplier
					if bomb.Variant == BombVariant.BOMB_GIGA or bomb.Variant == BombVariant.BOMB_ROCKET_GIGA then
						isgiga = true
					end
					if bomb.IsFetus then
						bomb = nil
					end
				end
			end
			if (not data.TaintedATGTarget or not data.TaintedATGTarget:Exists() or player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS)) and bomb and player:GetFireDirection() ~= Direction.NO_DIRECTION then
				local target = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.ATG_TARGET, 0, player.Position, Vector.Zero, player)
				data.TaintedATGTarget = target
				if isgiga then
					target:GetData().TaintedGigaATG = true
				end
				target:GetData().TaintedATGDamage = damage
				target:GetData().TaintedATGRadius = radiusmult
				bomb:Remove()
				target:SetColor(Color(0.2, 0.8, 0.2, 1, 0, 0, 0), -1, 1)
				target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			elseif data.TaintedATGTarget and data.TaintedATGTarget:Exists() then
				local target = data.TaintedATGTarget
				target.Color = Color.Default
				target:GetSprite().PlaybackSpeed = 1
				mod:spritePlay(target:GetSprite(), "Rocket")
				if bomb then
					bomb:Remove()
					player:AddBombs(1)
					if isgiga then
						player:AddGigaBombs(1)
					end
				end
			end
		end, 0)
	end
end