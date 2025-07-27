local mod = FiendFolio
local game = Game()

function mod:FushigiOnFireTear(player, tear)
	if player:HasTrinket(mod.ITEM.TRINKET.FUSHIGI) and mod:BasicRoll(player.Luck, 9, 0.4 + player:GetTrinketMultiplier(mod.ITEM.TRINKET.FUSHIGI)*0.1) and not player:GetData().FiringFushigiTear then
		tear:ChangeVariant(TearVariant.METALLIC)
		tear:AddTearFlags(TearFlags.TEAR_OCCULT)
		tear.CollisionDamage = tear.CollisionDamage * 2
		if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			tear.Scale = tear.Scale * 1.25
			tear.Height = tear.Height * 2
		end
	end
end

function mod:FushigiOnFireBomb(player, bomb)
	if player:HasTrinket(mod.ITEM.TRINKET.FUSHIGI) and mod:BasicRoll(player.Luck, 9, 0.4 + player:GetTrinketMultiplier(mod.ITEM.TRINKET.FUSHIGI)*0.1) then
		bomb:SetExplosionCountdown(60)
		bomb:AddTearFlags(TearFlags.TEAR_OCCULT)
		bomb.ExplosionDamage = bomb.ExplosionDamage * 2
	end
end

function mod:RollForFushigiTear(player, velmultiplier)
	if player:HasTrinket(mod.ITEM.TRINKET.FUSHIGI) and mod:BasicRoll(player.Luck, 9, 0.4 + player:GetTrinketMultiplier(mod.ITEM.TRINKET.FUSHIGI)*0.1) then
		local aimdirection = player:GetAimDirection()
		player:GetData().FiringFushigiTear = true
		local tear = player:FireTear(player.Position, aimdirection:Resized(velmultiplier), false, true, false, player, 2)
		tear:ChangeVariant(TearVariant.METALLIC)
		tear:AddTearFlags(TearFlags.TEAR_OCCULT)
		tear.Height = tear.Height * 2
		player:GetData().FiringFushigiTear = false
	end
end