--Yeah bois, that's right. I'm finally using VSCode!
local mod = RegisterMod("Flat Stone Synergies", 1) --Made by Jaemspio (don't ask why I feel the need to reiterate this every mod I make)

local game = Game()
local nullVector = Vector(0, 0)
local sfx = SFXManager()

local function hasInfiBrim(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) or
	player.MaxFireDelay <= 1
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, rocket)
	if rocket.SubType == 69 then return end
	if not rocket.SpawnerEntity then return end
	local player = rocket.SpawnerEntity:ToPlayer()
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then return end
	if rocket:IsDead() and not rocket:Exists() then
		Isaac.Spawn(1000, 14, 0, rocket.Position, nullVector, player)
		local new = Isaac.Spawn(1000, 8, 69, rocket.Position, nullVector, player):ToEffect()
		new.State = 1
		new.FallingSpeed = 6
		new.SpriteRotation = 180
		new.DamageSource = rocket.DamageSource
		new:GetData().FlatStoneHeight = 20
		new.SpriteOffset = Vector(0, -20)
		local spr = new:GetSprite()
		spr:Load("gfx/1000.031_dr. fetus rocket.anm2", true)
		spr:Play("Idle", true)
	end
end, 31)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType ~= 69 then return end
	if not effect.SpawnerEntity then return end
	local player = effect.SpawnerEntity:ToPlayer()
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then return end
	local data = effect:GetData()
	if effect.State == 1 then
		data.FlatStoneHeight = data.FlatStoneHeight + effect.FallingSpeed
		effect.FallingSpeed = effect.FallingSpeed - 0.5
		effect.SpriteOffset = Vector(0, -data.FlatStoneHeight)
		if effect.FallingSpeed <= 0 then
			effect.SpriteRotation = 0
			effect.SpriteOffset = Vector(0, -data.FlatStoneHeight + 20)
			effect.State = 2
		end
	elseif effect.State == 2 then
		data.FlatStoneHeight = data.FlatStoneHeight - effect.FallingSpeed
		effect.FallingSpeed = effect.FallingSpeed + 0.5
		effect.SpriteOffset = Vector(0, -data.FlatStoneHeight + 20)
		if data.FlatStoneHeight <= 0 then
			effect:Remove()
			local rocket = Isaac.Spawn(1000, 31, 69, effect.Position, nullVector, player):ToEffect()
			rocket.DamageSource = effect.DamageSource
			rocket.Visible = false
			rocket:SetTimeout(1)
			rocket:Update()
		end
	end
end, 8)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	if effect.SpawnerEntity and effect.SpawnerEntity.SubType == 40326 then
		effect:Remove()
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	if not tear.SpawnerEntity or not tear:HasTearFlags(TearFlags.TEAR_HYDROBOUNCE) then return end
	local player = tear.SpawnerEntity:ToPlayer()
	if not player then return end
	local data = tear:GetData()
	if tear:HasTearFlags(TearFlags.TEAR_ORBIT_ADVANCED) then --This took forever to get working
		if data.FlagedForDeletion then
			tear:Remove()
			return
		end
		if not data.FlatStoneBounces then --Tear needs to be initialized
			data.FlatStoneBounces = 0
			if math.floor(tear.FallingSpeed) == 0 then
				data.IsSaturusTear = true
			end
		end
		if data.IsSaturusTear then
			local nextHeight = tear.Height + tear.FallingSpeed + tear.FallingAcceleration --Not 100% accurate, but close enough
			tear.FallingAcceleration = 1
			if nextHeight >= -5 and data.FlatStoneBounces < 15 then --It will fall on the next frame
				tear.FallingSpeed = -12
				data.FlatStoneBounces = data.FlatStoneBounces + 1
				local t = Isaac.Spawn(2, tear.Variant, 0, tear.Position, tear.Velocity, player):ToTear()
				t.Visible = false
				t.Height = 99999
				t.Color = tear.Color
				t.TearFlags = tear.TearFlags
				t.FallingSpeed = tear.FallingSpeed
				t.FallingAcceleration = tear.FallingAcceleration
				for i = 1, 5 do
					t:Update()
				end
				t:GetData().FlagedForDeletion = true
			end
			if tear:IsDead() then
				tear:ClearTearFlags(TearFlags.TEAR_HYDROBOUNCE)
			end
		end
	end
	if tear:HasTearFlags(TearFlags.TEAR_BOOMERANG) then
		local max = math.floor(player.TearRange / 8)
		if tear.FrameCount <= max then
			tear.Height = math.min(-10, tear.Height)
		end
	end
	if tear:HasTearFlags(TearFlags.TEAR_RIFT) then
		data.IsRiftTear = true
	end
	if tear:IsDead() then
		if data.IsRiftTear then --The "Rift" flag gets removed after the first bounce
			if data.HadFirstBounce then
				if math.random(4) == 1 then
					local rift = Isaac.Spawn(1000, 180, 0, tear.Position, nullVector, player):ToEffect()
					rift.SpriteScale = Vector(tear.Scale, tear.Scale)
					rift:SetTimeout(90)
				end
			end
			data.HadFirstBounce = true
		end
		if tear:HasTearFlags(TearFlags.TEAR_BURN) then
			if math.random(10) == 1 then
				Isaac.Spawn(1000, 52, 0, tear.Position, nullVector, player)
			end
		end
		if tear:HasTearFlags(TearFlags.TEAR_LIGHT_FROM_HEAVEN) then
			if math.random(4) == 1 then
				Isaac.Spawn(1000, 19, 0, tear.Position, nullVector, player)
			end
		end
		if tear:HasTearFlags(TearFlags.TEAR_EGG) then
			if math.random(20) == 1 then
				Isaac.Spawn(3, 43 + 30 * math.random(0, 1), 0, tear.Position, nullVector, player):ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
	if not bomb.SpawnerEntity then return end
	local player = bomb.SpawnerEntity:ToPlayer()
	if not player then return end
	if not bomb.IsFetus then return end
	if bomb:HasTearFlags(TearFlags.TEAR_HYDROBOUNCE) then
		if bomb.PositionOffset.Y >= 0 and bomb.Position:Distance(player.Position) > 100 * bomb.RadiusMultiplier and math.random(5) == 1 then
			local b = Isaac.Spawn(4, 0, 0, bomb.Position, nullVector, player):ToBomb()
			b.Visible = false
			b:SetExplosionCountdown(0)
			b.ExplosionDamage = bomb.ExplosionDamage
			b.RadiusMultiplier = bomb.RadiusMultiplier
			b.Flags = bomb.Flags
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, function(_, laser)
	if not laser.SpawnerEntity then return end
	local player = laser.SpawnerEntity:ToPlayer()
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then return end
	if not player:HasWeaponType(WeaponType.WEAPON_LASER) or player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then return end
	laser:SetMaxDistance(130)
end)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
	if not laser.SpawnerEntity then return end
	local player = laser.SpawnerEntity:ToPlayer()
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then return end
	local data = laser:GetData()
	if player:HasWeaponType(WeaponType.WEAPON_LASER) and not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) and not laser.GridHit then
			if laser.FrameCount == 3 then
				for i = 1, math.random(2, 4) do
					local vel = Vector.FromAngle(laser.Angle + math.random(-10, 10)) * math.random(90, 105) / 10 * player.ShotSpeed
					local tear = player:FireTear(laser:GetEndPoint(), vel)
					tear.Color = Color(1, 0.1, 0.1, 1, 0.8, 0, 0)
					tear:ClearTearFlags(TearFlags.TEAR_POP | TearFlags.TEAR_ABSORB)
				end
			end
		end
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
		if not laser:IsCircleLaser() then return end
		if not player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) and not player:HasWeaponType(WeaponType.WEAPON_LASER) then return end
		if not data.Initialized then
			data.FlatStoneHeight = 20
			data.State = 1
			data.FallingSpeed = 0
			data.Initialized = true
		end
		data.FlatStoneHeight = data.FlatStoneHeight - data.FallingSpeed
		data.FallingSpeed = data.FallingSpeed + 1.1
		if data.State == 1 then
			if data.FlatStoneHeight <= 0 then
				data.State = 2
				if player:HasWeaponType(WeaponType.WEAPON_LASER) then
					data.FallingSpeed = -6
				else
					data.FallingSpeed = -12
				end
				Isaac.Spawn(1000, 14, 0, laser.Position, nullVector, player)
				if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
					for i = 0, 3 do
						local brim = player:FireBrimstone(Vector.FromAngle(i * 90), player, 1)
						brim.DisableFollowParent = true
						brim.Position = laser.Position
					end
				else
					for i = 0, 3 do
						player:FireTechLaser(laser.Position, LaserOffset.LASER_SHOOP_OFFSET, Vector.FromAngle(i * 90))
					end
				end
			end
		elseif data.State == 2 then
			if data.FallingSpeed <= 0 then
				data.State = 1
			end
		end
		laser.Position = laser.Position + Vector(0, data.FallingSpeed)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
	if not laser.SpawnerEntity then return end
	local player = laser.SpawnerEntity:ToPlayer()
	local data = laser:GetData()
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then return end
	if not player:HasWeaponType(WeaponType.WEAPON_TECH_X) then return end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) and laser:IsCircleLaser() then
		if not data.Initialized then
			data.TrueVelocity = player:GetLastDirection() * 8 * player.ShotSpeed + player:GetTearMovementInheritance(player:GetLastDirection()) / 2
			data.FlatStoneHeight = 20
			data.State = 1
			data.FallingSpeed = 0
			data.Initialized = true
		end
		if laser.FrameCount % 2 == 0 then
			for _, e in pairs(Isaac.FindInRadius(laser.Position + laser.SpriteOffset, 40, EntityPartition.ENEMY)) do
				e:TakeDamage(player.Damage, 0, EntityRef(player), 3)
			end
		end
		laser.Velocity = data.TrueVelocity
		data.FlatStoneHeight = data.FlatStoneHeight - data.FallingSpeed
		data.FallingSpeed = data.FallingSpeed + 1.1
		if data.State == 1 then
			if data.FlatStoneHeight <= 0 then
				data.State = 2
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
					data.FallingSpeed = -12
				else
					data.FallingSpeed = -6
				end
				Isaac.Spawn(1000, 14, 0, laser.Position, nullVector, player)
				for i = 0, 3 do
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
						local brim = player:FireBrimstone(Vector.FromAngle(i * 90), player, 1)
						brim.DisableFollowParent = true
						brim.Position = laser.Position
					else
						player:FireTechLaser(laser.Position, LaserOffset.LASER_SHOOP_OFFSET, Vector.FromAngle(i * 90))
					end
				end
			end
		elseif data.State == 2 then
			if data.FallingSpeed <= 0 then
				data.State = 1
			end
		end
		laser.Position = laser.Position + Vector(0, data.FallingSpeed)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, function(_, laser)
	if laser:GetData().IsBallLaser then return end
	if not laser.SpawnerEntity then return end
	local player = laser.SpawnerEntity:ToPlayer()
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then return end
	if not player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) or player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then return end
	if not hasInfiBrim(player) then
		for _, b in pairs(Isaac.FindByType(1000, 113)) do
			if b:GetData().IsFlatStoneBall then
				return
			end
		end
		local vel = Vector.FromAngle(laser.Angle) * 8
		local ball = Isaac.Spawn(1000, 113, 0, laser.Position, vel, player)
		ball:GetData().IsFlatStoneBall = true
		ball.Color = player.LaserColor
		laser.CollisionDamage = 0
		laser.Visible = false
		laser:Remove()
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if not effect:GetData().IsFlatStoneBall then return end
	if not effect.SpawnerEntity then return end
	local room = game:GetRoom()
	local player = effect.SpawnerEntity:ToPlayer()
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then return end
	local data = effect:GetData()
	if not data.Initialized then
		data.TrueVelocity = player:GetLastDirection() * 8 * player.ShotSpeed + player:GetTearMovementInheritance(player:GetLastDirection()) / 2
		data.FlatStoneHeight = 20
		data.LifeSpan = player.TearRange + 40
		effect.State = 1
		effect.FallingSpeed = 0
		effect:SetTimeout(99999)
		data.Initialized = true
	end
	if effect.FrameCount % 2 == 0 then
		for _, e in pairs(Isaac.FindInRadius(effect.Position + effect.SpriteOffset, 40, EntityPartition.ENEMY)) do
			e:TakeDamage(player.Damage, 0, EntityRef(player), 3)
		end
	end
	effect.Velocity = data.TrueVelocity
	data.LifeSpan = data.LifeSpan - effect.Velocity:Length()
	data.FlatStoneHeight = data.FlatStoneHeight - effect.FallingSpeed
	effect.FallingSpeed = effect.FallingSpeed + 0.5
	if player:HasCollectible(CollectibleType.COLLECTIBLE_RUBBER_CEMENT) then
		if not room:IsPositionInRoom(effect.Position + effect.Velocity, 0) then
			if room:IsLShapedRoom() then
				--This method works 100% of the time, 70% of the time
				local pos = effect.Position + effect.Velocity
				if not room:IsPositionInRoom(Vector(effect.Position.X, pos.Y), 0) then --If the x is outside the room
					data.TrueVelocity = Vector(-data.TrueVelocity.X, data.TrueVelocity.Y) --Flip the x
				end
				if not room:IsPositionInRoom(Vector(pos.X, effect.Position.Y), 0) then --If the y is outside the room
					data.TrueVelocity = Vector(data.TrueVelocity.X, -data.TrueVelocity.Y) --Flip the y
				end
			else
				local center = room:GetCenterPos()
				if not room:IsPositionInRoom(Vector(effect.Position.X, center.Y), 0) then --If the x is outside the room
					data.TrueVelocity = Vector(-data.TrueVelocity.X, data.TrueVelocity.Y) --Flip the x
				end
				if not room:IsPositionInRoom(Vector(center.X, effect.Position.Y), 0) then --If the y is outside the room
					data.TrueVelocity = Vector(data.TrueVelocity.X, -data.TrueVelocity.Y) --Flip the y
				end
			end
			effect.Position = room:GetClampedPosition(effect.Position, 0)
		end
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
		effect.Position = room:ScreenWrapPosition(effect.Position, -180)
	end
	if effect.State == 1 then
		if data.FlatStoneHeight <= 0 then
			effect.State = 2
			effect.FallingSpeed = -6
			Isaac.Spawn(1000, 14, 0, effect.Position, nullVector, player)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
				for i = 0, 3 do
					player:FireTechLaser(effect.Position, LaserOffset.LASER_SHOOP_OFFSET, Vector.FromAngle(i * 90))
				end
			end
			local brim = player:FireBrimstone(effect.Velocity, player, 1)
			brim.DisableFollowParent = true
			brim.Position = effect.Position
			brim:GetData().IsBallLaser = true
		end
	elseif effect.State == 2 then
		if effect.FallingSpeed <= 0 then
			effect.State = 1
		end
	end
	effect.SpriteOffset = Vector(0, -data.FlatStoneHeight)
	if (data.LifeSpan <= 0 or player:GetFireDirection() ~= -1) and effect.Timeout > 1 then
		effect:SetTimeout(1)
	end
end, 113)
