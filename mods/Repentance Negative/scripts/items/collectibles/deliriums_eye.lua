local Mod = RepMMod

local DelColor = Color(1, 1, 1, 1, 0, 0, 0, 3 , 3, 3, 1)

local function TearColor_DelEye(_, player, cache)
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_DILIRIUM_EYE) then
		player.TearColor = DelColor
	end
end
Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, TearColor_DelEye, CacheFlag.CACHE_TEARCOLOR)

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local player, familiarTear = Mod:GetPlayerFromTear(tear)
	if not player then
		return
	end
	local data = Mod:GetData(player)
	data.DiliriumEyeLastActivateFrame = data.DiliriumEyeLastActivateFrame or 0
	if
		player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_DILIRIUM_EYE)
		and not familiarTear
		and (Game():GetFrameCount() > data.DiliriumEyeLastActivateFrame + 1)
	then
		local DelEyeVariant = math.random(1, 5)
		data.DiliriumEyeLastActivateFrame = Game():GetFrameCount()
		if DelEyeVariant == 1 then
			if player:GetFireDirection() == 0 then
				local ShootDirection =
					Vector(-math.cos(0) * player.ShotSpeed * 10, -math.sin(0) * player.ShotSpeed * 10)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1)
				tear:Remove()
			elseif player:GetFireDirection() == 1 then
				local ShootDirection = Vector(math.sin(0) * player.ShotSpeed * 10, -math.cos(0) * player.ShotSpeed * 10)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1)
				tear:Remove()
			elseif player:GetFireDirection() == 2 then
				local ShootDirection = Vector(math.cos(0) * player.ShotSpeed * 10, -math.sin(0) * player.ShotSpeed * 10)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1)
				tear:Remove()
			elseif player:GetFireDirection() == 3 then
				local ShootDirection = Vector(math.sin(0) * player.ShotSpeed * 10, math.cos(0) * player.ShotSpeed * 10)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1)
				tear:Remove()
			end
		elseif DelEyeVariant == 2 then
			if player:GetFireDirection() == 0 then
				local ShootDirection = Vector(
					-math.cos(math.rad(7.5)) * player.ShotSpeed * 10,
					-math.sin(math.rad(7.5)) * player.ShotSpeed * 10
				)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 2)
				local ShootDirection = Vector(
					-math.cos(math.rad(-7.5)) * player.ShotSpeed * 10,
					-math.sin(math.rad(-7.5)) * player.ShotSpeed * 10
				)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 2)
				tear:Remove()
			elseif player:GetFireDirection() == 1 then
				local ShootDirection = Vector(
					math.sin(math.rad(7.5)) * player.ShotSpeed * 10,
					-math.cos(math.rad(7.5)) * player.ShotSpeed * 10
				)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 2)
				local ShootDirection = Vector(
					math.sin(math.rad(-7.5)) * player.ShotSpeed * 10,
					-math.cos(math.rad(-7.5)) * player.ShotSpeed * 10
				)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 2)
				tear:Remove()
			elseif player:GetFireDirection() == 2 then
				local ShootDirection = Vector(
					math.cos(math.rad(7.5)) * player.ShotSpeed * 10,
					-math.sin(math.rad(7.5)) * player.ShotSpeed * 10
				)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 2)
				local ShootDirection = Vector(
					math.cos(math.rad(-7.5)) * player.ShotSpeed * 10,
					-math.sin(math.rad(-7.5)) * player.ShotSpeed * 10
				)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 2)
				tear:Remove()
			elseif player:GetFireDirection() == 3 then
				local ShootDirection = Vector(
					math.sin(math.rad(7.5)) * player.ShotSpeed * 10,
					math.cos(math.rad(7.5)) * player.ShotSpeed * 10
				)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 2)
				local ShootDirection = Vector(
					math.sin(math.rad(-7.5)) * player.ShotSpeed * 10,
					math.cos(math.rad(-7.5)) * player.ShotSpeed * 10
				)
				player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 2)
				tear:Remove()
			end
		elseif DelEyeVariant == 3 then
			if player:GetFireDirection() == 0 then
				for i = -1, 1 do
					if i ~= 0 then
						local ShootDirection = Vector(
							-math.cos(math.rad(15 * i)) * player.ShotSpeed * 10,
							-math.sin(math.rad(15 * i)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 3)
					else
						local ShootDirection =
							Vector(-math.cos(0) * player.ShotSpeed * 10, -math.sin(0) * player.ShotSpeed * 10)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 3)
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 1 then
				for i = -1, 1 do
					if i ~= 0 then
						local ShootDirection = Vector(
							math.sin(math.rad(15 * i)) * player.ShotSpeed * 10,
							-math.cos(math.rad(15 * i)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 3)
					else
						local ShootDirection =
							Vector(math.sin(0) * player.ShotSpeed * 10, -math.cos(0) * player.ShotSpeed * 10)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 3)
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 2 then
				for i = -1, 1 do
					if i ~= 0 then
						local ShootDirection = Vector(
							math.cos(math.rad(15 * i)) * player.ShotSpeed * 10,
							-math.sin(math.rad(15 * i)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 3)
					else
						local ShootDirection =
							Vector(math.cos(0) * player.ShotSpeed * 10, -math.sin(0) * player.ShotSpeed * 10)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 3)
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 3 then
				for i = -1, 1 do
					if i ~= 0 then
						local ShootDirection = Vector(
							math.sin(math.rad(15 * i)) * player.ShotSpeed * 10,
							math.cos(math.rad(15 * i)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 3)
					else
						local ShootDirection =
							Vector(math.sin(0) * player.ShotSpeed * 10, math.cos(0) * player.ShotSpeed * 10)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 3)
						tear:Remove()
					end
				end
			end
		elseif DelEyeVariant == 4 then
			if player:GetFireDirection() == 0 then
				for i = -2, 2 do
					if i < 0 then
						local ShootDirection = Vector(
							-math.cos(math.rad(15 * i + 7.5)) * player.ShotSpeed * 10,
							-math.sin(math.rad(15 * i + 7.5)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 4)
					elseif i > 0 then
						local ShootDirection = Vector(
							-math.cos(math.rad(15 * i - 7.5)) * player.ShotSpeed * 10,
							-math.sin(math.rad(15 * i - 7.5)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 4)
					else
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 1 then
				for i = -2, 2 do
					if i < 0 then
						local ShootDirection = Vector(
							math.sin(math.rad(15 * i + 7.5)) * player.ShotSpeed * 10,
							-math.cos(math.rad(15 * i + 7.5)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 4)
					elseif i > 0 then
						local ShootDirection = Vector(
							math.sin(math.rad(15 * i - 7.5)) * player.ShotSpeed * 10,
							-math.cos(math.rad(15 * i - 7.5)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 4)
					else
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 2 then
				for i = -2, 2 do
					if i < 0 then
						local ShootDirection = Vector(
							math.cos(math.rad(15 * i + 7.5)) * player.ShotSpeed * 10,
							-math.sin(math.rad(15 * i + 7.5)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 4)
					elseif i > 0 then
						local ShootDirection = Vector(
							math.cos(math.rad(15 * i - 7.5)) * player.ShotSpeed * 10,
							-math.sin(math.rad(15 * i - 7.5)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 4)
					else
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 3 then
				for i = -2, 2 do
					if i < 0 then
						local ShootDirection = Vector(
							math.sin(math.rad(15 * i + 7.5)) * player.ShotSpeed * 10,
							math.cos(math.rad(15 * i + 7.5)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 4)
					elseif i > 0 then
						local ShootDirection = Vector(
							math.sin(math.rad(15 * i - 7.5)) * player.ShotSpeed * 10,
							math.cos(math.rad(15 * i - 7.5)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 4)
					else
						tear:Remove()
					end
				end
			end
		elseif DelEyeVariant == 5 then
			if player:GetFireDirection() == 0 then
				for i = -2, 2 do
					if i ~= 0 then
						local ShootDirection = Vector(
							-math.cos(math.rad(15 * i)) * player.ShotSpeed * 10,
							-math.sin(math.rad(15 * i)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 5)
					else
						local ShootDirection =
							Vector(-math.cos(0) * player.ShotSpeed * 10, -math.sin(0) * player.ShotSpeed * 10)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 5)
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 1 then
				for i = -2, 2 do
					if i ~= 0 then
						local ShootDirection = Vector(
							math.sin(math.rad(15 * i)) * player.ShotSpeed * 10,
							-math.cos(math.rad(15 * i)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 5)
					else
						local ShootDirection =
							Vector(math.sin(0) * player.ShotSpeed * 10, -math.cos(0) * player.ShotSpeed * 10)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 5)
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 2 then
				for i = -2, 2 do
					if i ~= 0 then
						local ShootDirection = Vector(
							math.cos(math.rad(15 * i)) * player.ShotSpeed * 10,
							-math.sin(math.rad(15 * i)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 5)
					else
						local ShootDirection =
							Vector(math.cos(0) * player.ShotSpeed * 10, -math.sin(0) * player.ShotSpeed * 10)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 5)
						tear:Remove()
					end
				end
			elseif player:GetFireDirection() == 3 then
				for i = -2, 2 do
					if i ~= 0 then
						local ShootDirection = Vector(
							math.sin(math.rad(15 * i)) * player.ShotSpeed * 10,
							math.cos(math.rad(15 * i)) * player.ShotSpeed * 10
						)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 5)
					else
						local ShootDirection =
							Vector(math.sin(0) * player.ShotSpeed * 10, math.cos(0) * player.ShotSpeed * 10)
						player:FireTear(player.Position, ShootDirection, true, true, false, player, 1.1 / 5)
						tear:Remove()
					end
				end
			end
		end
	end
end)