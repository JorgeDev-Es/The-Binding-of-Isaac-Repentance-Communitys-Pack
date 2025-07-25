local Mod = RepMMod

LASER_DURATION = 15

local offset = Vector(20, -27)

local HolyShellChargeBar = include("scripts.lib.chargebar")("gfx/chargebar_axe.anm2", true)

local function renderCharge(_, player)
	local data = player:GetData()
	if data.HolyshellFrame then
		HolyShellChargeBar:SetCharge((data.HolyshellFrame / player.MaxFireDelay / 3), 1)
		HolyShellChargeBar:Render(Isaac.WorldToScreen(player.Position) + offset + Vector(5, -10))
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderCharge)

local function onUpdate(_, player)
	local data = Mod:GetData(player)
	if data.HolyshellFrame == nil then
		data.HolyshellFrame = 0
	end
	if data.HolyshellCool == nil then
		data.HolyshellCool = 0
	end

	--заряд
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_HOLY_SHELL) then
		--player.FireDelay = player.MaxFireDelay -- стопает стрельбу
		if player:GetFireDirection() > -1 and data.HolyshellCool == 0 then
			-- заряд
			data.HolyshellFrame = math.min(player.MaxFireDelay * 3, data.HolyshellFrame + 1)
			local BOff = (data.HolyshellFrame / player.MaxFireDelay / 6)
			player:SetColor(Color(1, 1, 1, 1, BOff, BOff, BOff), 1, 0, false, false)
		elseif Game():GetRoom():GetFrameCount() > 1 then
			--стрельба
			if data.HolyshellFrame == player.MaxFireDelay * 3 then
				BaseAngle = 0
				--BaseAngle = 45
				for Angle = BaseAngle, BaseAngle + 270, 90 do
					local HolyLaser = EntityLaser.ShootAngle(
						LaserVariant.LIGHT_BEAM,
						player.Position,
						Angle,
						LASER_DURATION,
						Vector(0, 0),
						player
					)
					HolyLaser.TearFlags = player.TearFlags
					HolyLaser.CollisionDamage = player.Damage * 0.5
					Mod:GetData(HolyLaser).HolyShellLaser = true
				end
				data.HolyshellCool = LASER_DURATION * 2
			else
			end
			data.HolyshellFrame = 0
		end
		data.HolyshellCool = math.max(0, data.HolyshellCool - 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, onUpdate)

local function postDamageHolyLaser(_, entity, collider, low)
	if collider and collider:IsVulnerableEnemy() then
		if Mod:GetData(entity).HolyShellLaser then

		end
	end
end

--Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, onUpdate)