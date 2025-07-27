local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local PROJ_RING_AMOUNT 	= 8
local PROJ_RING_ANGLE	= 360 / PROJ_RING_AMOUNT
local PROJ_RING_VECTOR 	= Vector(0, 40)
local BLOOD_SKULL_ANGLE = 160
local SPIT_PROJ_SPREAD = 25
local DASH_SPEED = 24
local BRIMSTONE_THROW_SPEED = -15
local BRIMSTONE_THROW_ACCEL = 0.25

local MadommeState = {
	INTRO = 0,
	IDLE = 1,
	PROJECTILE_RING = 2,
	SPIT = 3,
	DASH = 4,
	DASH_SKID = 5,
	STATIONARY = 6,
	INVISIBLE = 7,
}

local markerValueToSpawn = {
	[0] = mod.FF.Gimp.Var,
	[1] = mod.FF.Castle.Var,
	[2] = mod.FF.Gloria.Var,
	[3] = mod.FF.MadommeHorse.Var,
}

local function GetDashDataFromAngle(npc, angle)
	local data = npc:GetData()
	local sprite = npc:GetSprite()

	if math.abs(angle) < 45 then
		sprite.FlipX = false
		data.dashVelocity = Vector(DASH_SPEED, 0)
		return "Horizontal"
	elseif math.abs(angle) > 135 then
		sprite.FlipX = true
		data.dashVelocity = Vector(-DASH_SPEED, 0)
		return "Horizontal"
	elseif angle > 0 then
		data.dashVelocity = Vector(0, DASH_SPEED)
		return "Down"
	else
		data.dashVelocity = Vector(0, -DASH_SPEED)
		return "Up"
	end
end

local function GetInitialDashDirection(npc)
	local angle = (npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()
	return GetDashDataFromAngle(npc, angle)
end

local function GetGlintDashDirection(npc)
	local target = npc:GetPlayerTarget()
	local rng = npc:GetData().rng
	local positions = {}

	for angle = 90, 360, 90 do
		local wallPos = EntityLaser.CalculateEndPoint(target.Position, Vector(1, 0):Rotated(angle), Vector.Zero, npc, 0)
		table.insert(positions, {Position = wallPos + Vector(20, 0):Rotated(angle), Angle = Vector(-1, 0):Rotated(angle):GetAngleDegrees()})
	end

	local data = positions[rng:RandomInt(3) + 1]
	return data.Position, GetDashDataFromAngle(npc, data.Angle)
end

local function shockChamps()
	for _, champ in pairs(Isaac.FindByType(mod.FF.Champ.ID, mod.FF.Champ.Var)) do
		champ:GetSprite():Play("Shock")
	end
end

local function isWaveEntityDead(entity)
	return (
		entity:IsDead() or
		entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or
		not entity:Exists() or
		mod:isStatusCorpse(entity)
	)
end

local function shouldTrySpawnBonusGimps(npc)
	local activeGimps = 0
	local data = npc:GetData()

	for i = #data.waveSpawns, 1, -1 do
		local entity = data.waveSpawns[i]

		if entity.Type == mod.FF.Gimp.ID and entity.Variant == mod.FF.Gimp.Var and not isWaveEntityDead(entity) then
			activeGimps = activeGimps + 1
		end
	end

	return activeGimps == 0
end

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, function(_, entity, amount, flags)
	for _, madomme in pairs(Isaac.FindByType(mod.FF.Madomme.ID, mod.FF.Madomme.Var)) do
		if madomme:GetData().state == MadommeState.INVISIBLE and not madomme:GetSprite():IsPlaying("Transition") then
			madomme:GetSprite():Play("Invisible Chuckle")
			sfx:Play(mod.Sounds.MadommeInvisChuckle, 1.5)
		end
	end
end, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	effect.Visible = false
	effect.Color = Color(1, 0, 0, 1)

	local sprite = effect:GetSprite()
	sprite:Play("Blink")
	sprite:ReplaceSpritesheet(0, "gfx/bosses/madomme/madomme_facecrosshair.png")
	sprite:LoadGraphics()
end, 1965)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local data = effect:GetData()

	if data.activateFrame and data.activateFrame <= effect.FrameCount then
		local mask = effect.SubType & ~ 3
		mask = mask >> 2

		Isaac.Spawn(1000, 16, 3, effect.Position, Vector.Zero, nil)
		Isaac.Spawn(1000, 16, 4, effect.Position, Vector.Zero, nil)

		local myVariant = markerValueToSpawn[mask]
		local monster = Isaac.Spawn(mod.FF.Madomme.ID, myVariant, 0, effect.Position, Vector.Zero, data.madomme)

		if data.madomme and data.madomme:Exists() then
			local madommeData = data.madomme:GetData()
			madommeData.waveStarted = true
			madommeData.bonusGimpDelay = data.madomme.FrameCount + 120
			table.insert(madommeData.waveSpawns, monster)
		end

		data.activateFrame = nil
		effect.Visible = false
		effect:BloodExplode()

		sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
	end
end, 1965)

StageAPI.AddCallback("FiendFolio", "POST_ROOM_LOAD", 1, function(currentRoom)
	if game:GetRoom():GetType() == RoomType.ROOM_BOSS and Isaac.CountEntities(nil, mod.FF.Madomme.ID, mod.FF.Madomme.Var) > 0 then
		currentRoom.Data.RoomGfx = mod.MadommeBackdrop
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	effect.SpriteScale = effect.SpriteScale * 0.5
end, Isaac.GetEntityVariantByName("Fizsh"))

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, projectile)
	local data = projectile:GetData()
	if data.madommeTrail then
		data.madommeTrail.Velocity = projectile.Position + projectile.PositionOffset - data.madommeTrail.Position
	end
end)

return {
	Init = function(npc)
		local data = npc:GetData()

		data.attacksPool = {1, 2, 3}
		data.attacksToAdd = {4, 5}
		data.addedAttacks = 0
		data.lastAttack = 0
		data.forceAttack = 0
		data.counter = 0
		data.state = MadommeState.INTRO
		data.cooldown = 60
		data.stateFrame = 0
		data.crossedLeg = "R"

		data.orbitingProjectiles = {}
		data.orbitingAngle = 0

		data.dashVelocity = Vector.Zero
		data.dashPosition = Vector.Zero
		data.dashDirection = "Horizontal"
		data.endDashing = false

		data.waveSpawns = {}
		data.bonusGimpDelay = 0
		data.bonusGimpsSpawned = 0
		data.waveStarted = false

		mod.XalumInitNpcRNG(npc)

		local sprite = npc:GetSprite()
		sprite:Play("Idle")

		npc.EntityCollisionClass = 0
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		local rng = data.rng

		data.cooldown = data.cooldown - 1
		data.stateFrame = data.stateFrame + 1
		data.orbitingAngle = data.orbitingAngle + 8

		if sprite:IsFinished("Appear") then
			sprite:Play("Intro")
		elseif sprite:IsFinished("Intro") or sprite:IsFinished("LegUncross R") or sprite:IsFinished("LegUncross L") or sprite:IsFinished("Spit End") or sprite:IsFinished("Throw") or sprite:IsFinished("End Dash from Glint") or sprite:IsFinished("Brimstone Orb") or sprite:IsFinished("Un Transition") then
			sprite:Play("Idle")
			data.state = MadommeState.IDLE
			data.stateFrame = 0
			data.cooldown = data.cooldownOverride or 60
			data.cooldownOverride = nil
		elseif sprite:IsFinished("LegCross Start") or sprite:IsFinished("LegCross L Cross") then
			sprite:Play("LegCross R Loop")
			data.crossedLeg = "R"
		elseif sprite:IsFinished("LegCross R Cross") then
			sprite:Play("LegCross L Loop")
			data.crossedLeg = "L"
		elseif sprite:IsFinished("Spit Ready") then
			sprite:Play("Spit Loop")
		elseif sprite:IsFinished("Spit") then
			if data.counter < 3 or (data.counter < 4 and rng:RandomFloat() < 0.5) then
				sprite:Play("Spit", true)
			else
				sprite:Play("Spit End")
				sfx:Play(mod.Sounds.MadommeSpitEnd)
			end
		elseif sprite:IsFinished("Dash startup") then
			local dashAnim = GetInitialDashDirection(npc)
			sprite:Play("Dash " .. dashAnim)
			sfx:Play(mod.Sounds.MadommeDashStart)
			data.state = MadommeState.DASH
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

			data.dashingBall = Isaac.Spawn(mod.FF.MadommeDashBall.ID, mod.FF.MadommeDashBall.Var, 0, npc.Position, Vector.Zero, npc)
			data.dashingBall:BloodExplode()
			Isaac.Spawn(1000, 16, 4, npc.Position, Vector.Zero, npc)
		elseif sprite:IsFinished("Eye glint") or sprite:IsFinished("Eye glint vertical") then
			if data.endDashing then
				sprite:Play("End Dash from Glint")
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			else
				sprite:Play("Dash " .. data.dashDirection .. " (from glint)")
			end

			sfx:Play(mod.Sounds.MadommeDashStart)
			npc.SpriteOffset = Vector.Zero
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			data.state = MadommeState.DASH
			data.shadow.Visible = true
		elseif sprite:IsFinished("Transition") or sprite:IsFinished("Invisible Chuckle") or sprite:IsFinished("Invisible Grimmace") then
			sprite:Play("Invisible Idle")
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)

			if data.transition then
				for _, marker in pairs(Isaac.FindByType(1000, 1965)) do
					if marker.SubType & 3 == data.transition then
						local data = marker:GetData()
						data.activateFrame = marker.FrameCount + 30
						data.madomme = npc

						marker.Visible = true
					end
				end

				data.transition = nil
				data.bonusGimpTargetFrame = nil
				data.bonusGimpsSpawned = 0
			end
		end

		if data.state == MadommeState.INTRO then
			npc.Velocity = mod.XalumLerp(npc.Velocity, Vector.Zero, 0.5)
		elseif data.state == MadommeState.IDLE then
			mod.XalumRandomPathfind(npc, 2)

			local tooClose = false
			for _, champ in pairs(Isaac.FindByType(mod.FF.Champ.ID, mod.FF.Champ.Var)) do
				if champ.Position:Distance(npc.Position) < 80 then
					tooClose = true
					break
				end
			end

			if tooClose then
				local speed = npc.Velocity:Length()
				local drift = (npc:GetPlayerTarget().Position - npc.Position):Normalized() * 0.5

				npc.Velocity = (npc.Velocity + drift):Resized(speed)
			end

			if sprite:IsPlaying("Idle") and data.transition and Isaac.CountEntities(nil, mod.FF.MadommeWaveMarker.ID, mod.FF.MadommeWaveMarker.Var) > 0 then
				sprite:Play("Transition")
				sprite.FlipX = false
				sfx:Play(mod.Sounds.MadommeTransition)
				data.state = MadommeState.INVISIBLE
				data.waveSpawns = {}
				data.waveStarted = false

				shockChamps()

				return
			end

			if sprite:IsPlaying("Idle") and data.stateFrame > 0 and data.cooldown <= 0 and npc.FrameCount % 15 == 0 then
				local attack
				local canUse = {
					true,
					data.lastAttack ~= 5,
					true,
					true,
					true,
				}

				repeat
					local roll = rng:RandomInt(#data.attacksPool) + 1
					attack = data.attacksPool[roll]
				until attack ~= data.lastAttack and canUse[attack]

				if data.forceAttack > 0 then
					attack = data.forceAttack
					data.forceAttack = 0
				end

				-- attack = 3

				if attack == 1 then
					sprite:Play("Throw")
					sfx:Play(mod.Sounds.MadommeThrowStart)
					data.cooldownOverride = 15
				elseif attack == 2 then
					sprite:Play("LegCross Start")
					sfx:Play(mod.Sounds.MadommeLegCrossL)
					data.state = MadommeState.PROJECTILE_RING
					data.stateFrame = 0
					data.counter = 0
				elseif attack == 3 then
					sprite:Play("Spit Ready")
					sprite.FlipX = npc:GetPlayerTarget().Position.X > npc.Position.X
					data.state = MadommeState.SPIT
					data.stateFrame = 0
					data.counter = 0
				elseif attack == 4 then
					sprite:Play("Dash startup")
					sfx:Play(mod.Sounds.MadommeThrowStart)
					data.counter = 0
					data.endDashing = false
				elseif attack == 5 then
					sprite:Play("Brimstone Orb")
					sfx:Play(mod.Sounds.MadommeBrimstoneOrb)
					data.state = MadommeState.SPIT
					data.cooldownOverride = 0
				end

				data.lastAttack = attack
			end
		elseif data.state == MadommeState.PROJECTILE_RING then
			local targetPosition = npc:GetPlayerTarget().Position
			local targetVelocity = (targetPosition - npc.Position):Resized(2)
			npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.2)

			if data.stateFrame > 0 and data.stateFrame % 45 == 0 then
				if data.counter < 3 then
					data.counter = data.counter + 1
					sprite:Play("LegCross " .. data.crossedLeg .. " Cross")
					sfx:Play(mod.Sounds["MadommeLegCross" .. data.crossedLeg])
				else
					sprite:Play("LegUncross " .. data.crossedLeg)

					for _, projectile in pairs(data.orbitingProjectiles) do
						projectile:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
						projectile.Velocity = projectile.Velocity:Resized(9)
					end
					data.orbitingProjectiles = {}
				end
			end
		elseif data.state == MadommeState.SPIT then
			npc.Velocity = mod.XalumLerp(npc.Velocity, Vector.Zero, 0.4)

			if sprite:IsPlaying("Spit Loop") and data.stateFrame >= 20 then
				sprite:Play("Spit")
			end
		elseif data.state == MadommeState.DASH then
			npc.Velocity = mod.XalumLerp(npc.Velocity, data.dashVelocity, 0.5)

			if not mod.IsPositionOnScreen(npc.Position) then
				data.state = MadommeState.STATIONARY
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

				if data.counter < 4 then
					npc.Position, data.dashDirection = GetGlintDashDirection(npc)
				else
					data.endDashing = true
					data.dashDirection = "Horizontal"

					if rng:RandomFloat() < 0.5 then
						npc.Position = EntityLaser.CalculateEndPoint(npc:GetPlayerTarget().Position, Vector(-1, 0), Vector.Zero, npc, 0) - Vector(20, 0)
						data.dashVelocity = Vector(DASH_SPEED, 0)
						sprite.FlipX = false
					else
						npc.Position = EntityLaser.CalculateEndPoint(npc:GetPlayerTarget().Position, Vector(1, 0), Vector.Zero, npc, 0) + Vector(20, 0)
						data.dashVelocity = Vector(-DASH_SPEED, 0)
						sprite.FlipX = true
					end
				end

				if data.dashDirection == "Horizontal" then
					npc.SpriteOffset = Vector(0, 16)
				else
					npc.SpriteOffset = Vector(0, 48)
				end

				sprite:Play("Eye glint")
				data.counter = data.counter + 1
				data.shadow.Visible = false
				sfx:Play(mod.Sounds.EpicTwinkle, 2, 0, false, math.random(12, 14) / 10)
			end
		elseif data.state == MadommeState.DASH_SKID then
			npc.Velocity = mod.XalumLerp(npc.Velocity, Vector.Zero, 0.2)
		elseif data.state == MadommeState.STATIONARY then
			npc.Velocity = Vector.Zero
		elseif data.state == MadommeState.INVISIBLE then
			mod.XalumRandomPathfind(npc, 2)

			local player = npc:GetPlayerTarget()
			local animation = sprite:GetAnimation()

			if animation ~= "Transition" and animation ~= "Invisible Chuckle" and animation ~= "Invisible Grimmace" then
				if math.abs(player.Position.X - npc.Position.X) > 140 then
					if player.Position.X < npc.Position.X then
						sprite:Play("Invisible LookLeft")
					else
						sprite:Play("Invisible LookRight")
					end
				else
					sprite:Play("Invisible Idle")
				end
			end

			for i = #data.waveSpawns, 1, -1 do
				local entity = data.waveSpawns[i]

				if isWaveEntityDead(entity) then
					sprite:Play("Invisible Grimmace")
					sfx:Play(mod.Sounds.MadommeInvisGrimmace, 1.5)
					table.remove(data.waveSpawns, i)
				end
			end

			if data.waveStarted then
				data.bonusGimpTargetFrame = data.bonusGimpTargetFrame or npc.FrameCount + 120

				if #data.waveSpawns == 0 then
					sprite:Play("Un Transition")
					sfx:Play(mod.Sounds.MadommeUntransition)
					data.state = MadommeState.IDLE
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
					npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
					shockChamps()
				elseif shouldTrySpawnBonusGimps(npc) then
					if data.bonusGimpTargetFrame < npc.FrameCount then
						data.bonusGimpDelay = npc.FrameCount + 120
						data.bonusGimpsSpawned = data.bonusGimpsSpawned + 1
						data.bonusGimpTargetFrame = data.bonusGimpDelay + 30 * data.bonusGimpsSpawned

						local gimpMarkers = {}
						for _, marker in pairs(Isaac.FindByType(1000, 1965)) do
							if marker.SubType & ~ 3 == 0 then
								table.insert(gimpMarkers, marker)
							end
						end

						local marker = gimpMarkers[rng:RandomInt(#gimpMarkers) + 1]
						local data = marker:GetData()
						data.activateFrame = marker.FrameCount + 30
						data.madomme = npc

						marker.Visible = true
					end
				else
					data.bonusGimpTargetFrame = math.max(data.bonusGimpDelay, npc.FrameCount) + 30 * data.bonusGimpsSpawned
				end
			end
		end

		if npc.HitPoints / npc.MaxHitPoints <= 2/3 and data.addedAttacks < 1 then
			data.addedAttacks = data.addedAttacks + 1
			local roll = rng:RandomInt(#data.attacksToAdd) + 1
			local attack = data.attacksToAdd[roll]
			data.forceAttack = attack
			table.insert(data.attacksPool, attack)
			table.remove(data.attacksToAdd, roll)
			data.transition = 0
		end

		if npc.HitPoints / npc.MaxHitPoints <= 1/3 and data.addedAttacks < 2 then
			data.addedAttacks = data.addedAttacks + 1
			data.forceAttack = data.attacksToAdd[1]
			table.insert(data.attacksPool, data.attacksToAdd[1])
			data.transition = 1
		end

		if #data.orbitingProjectiles > 0 then
			for i, projectile in pairs(data.orbitingProjectiles) do
				if projectile:Exists() then
					local targetPosition = npc.Position + PROJ_RING_VECTOR:Rotated(data.orbitingAngle + i * PROJ_RING_ANGLE)
					local targetVelocity = targetPosition - projectile.Position
					projectile.Velocity = mod.XalumLerp(projectile.Velocity, targetVelocity, 0.2)
				end
			end
		end

		if sprite:IsPlaying("Throw") then
			if not sprite:WasEventTriggered("throw ball") then
				sprite.FlipX = npc:GetPlayerTarget().Position.X > npc.Position.X
			end
		end

		if sprite:IsEventTriggered("Summon Ring") then
			for i = 1, PROJ_RING_AMOUNT do
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(9, 0):Rotated(data.orbitingAngle + i * PROJ_RING_ANGLE), npc):ToProjectile()
				projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
				projectile.FallingSpeed = 0
				projectile.FallingAccel = -0.1

				table.insert(data.orbitingProjectiles, projectile)
			end

			Isaac.Spawn(1000, 16, 3, npc.Position, Vector.Zero, npc)
			sfx:Play(SoundEffect.SOUND_BLOODSHOOT)
		end

		if sprite:IsEventTriggered("Summon Skull") then
			local targetDirection = (npc:GetPlayerTarget().Position - npc.Position):Resized(24)
			local firingAngle = BLOOD_SKULL_ANGLE - (data.counter % 2 + 1) * BLOOD_SKULL_ANGLE
			local skull = Isaac.Spawn(mod.FF.MadommeSkull.ID, mod.FF.MadommeSkull.Var, 0, npc.Position, targetDirection:Rotated(firingAngle), npc)
			skull.SpriteOffset = Vector(0, -24)
			skull:GetData().sinMul = data.counter % 2 == 1 and 1 or -1

			Isaac.Spawn(1000, 16, 3, npc.Position + npc.Velocity, Vector.Zero, npc)
			sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.4)
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
		end

		if sprite:IsEventTriggered("throw ball") then
			local targetVelocity = Vector.FromAngle(sprite.FlipX and 60 or 120):Resized(16)
			Isaac.Spawn(mod.FF.MadommeBallgag.ID, mod.FF.MadommeBallgag.Var, 0, npc.Position + targetVelocity:Resized(32), targetVelocity, npc)
			data.cooldown = 45
		end

		if sprite:IsEventTriggered("lines") then
			local room = game:GetRoom()
			local targetPosition = npc:GetPlayerTarget().Position
			sprite.FlipX = targetPosition.X > npc.Position.X
			data.spitDirections = {}
			data.tracers = {}

			local max = 3 + (data.counter % 2)
			for i = 0, max do
				local direction = (targetPosition - npc.Position):Rotated(-SPIT_PROJ_SPREAD * max / 2 + SPIT_PROJ_SPREAD * i):Rotated(10 - rng:RandomFloat() * 20)
				if max == 4 and i == 2 then direction = (targetPosition - npc.Position) end

				local position = EntityLaser.CalculateEndPoint(npc.Position, direction, Vector.Zero, npc, 0)
				table.insert(data.spitDirections, position)

				local indicatorBeam = Isaac.Spawn(1000, 175, 0, position, Vector.Zero, npc):ToEffect()
				indicatorBeam.Parent = npc
				indicatorBeam.Target = indicatorBeam
				indicatorBeam.Color = Color(1, 0, 0, 1)
				indicatorBeam.DepthOffset = -1000
				indicatorBeam.Timeout = 15
				table.insert(data.tracers, indicatorBeam)
			end

			sfx:Play(mod.Sounds.MadommeSpitReady, 0.8)
		end

		if sprite:IsEventTriggered("spit") then
			data.counter = data.counter + 1

			sfx:Play(mod.Sounds.MadommeSpit)

			for _, targetPosition in pairs(data.spitDirections) do
				local projectile = Isaac.Spawn(9, mod.FF.FrogProjectileBlood.Var, 0, npc.Position, (targetPosition - npc.Position):Resized(32), npc):ToProjectile()
				projectile:AddProjectileFlags(ProjectileFlags.ANY_HEIGHT_ENTITY_HIT)
				projectile.Height = -64
				projectile.FallingSpeed = 4
				projectile.SizeMulti = Vector(3.5, 1)
				projectile.PositionOffset = projectile.Velocity:Resized(8)
				projectile.SpriteRotation = projectile.Velocity:GetAngleDegrees()
				projectile.Mass = 2

				local trail = Isaac.Spawn(1000, 166, 0, projectile.Position, Vector(0, projectile.Height), projectile):ToEffect()
				trail.Parent = projectile
				trail.MinRadius = 0.15
				trail.Color = Color(0.5, 0, 0, 1, 0, 0, 0)
				trail.SpriteScale = Vector.One * 2
				trail:Update()
				projectile:GetData().madommeTrail = trail
			end

			for i = #data.tracers, 1, -1 do
				data.tracers[i].Visible = false
				table.remove(data.tracers, i)
			end
		end

		if sprite:IsEventTriggered("Skid") then
			data.state = MadommeState.DASH_SKID
			game:ShakeScreen(10)
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
			sfx:Play(mod.Sounds.MadommeDashEnd)
		end

		if sprite:IsEventTriggered("Stop") then
			data.state = MadommeState.IDLE

			if data.dashingBall then
				local poof = Isaac.Spawn(1000, 2, 5, data.dashingBall.Position, Vector.Zero, npc):ToEffect()
				poof.SpriteScale = Vector.One * 2
				poof.SpriteOffset = data.dashingBall.SpriteOffset

				data.dashingBall:Remove()
			end
		end

		if sprite:IsEventTriggered("Charge") then
			sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER, 1, 0, false, 0.8)
			sfx:Play(SoundEffect.SOUND_HAND_LASERS, 0.5, 0, false, 0.6)
		end

		if sprite:IsEventTriggered("Toss") then
			local targetPosition = npc:GetPlayerTarget().Position
			local ball = Isaac.Spawn(mod.FF.MadommeBrimstoneBall.ID, mod.FF.MadommeBrimstoneBall.Var, 0, npc.Position, Vector.Zero, npc)
			local ballData = ball:GetData()

			ball.SpriteOffset = Vector(0, -72)
			ballData.fallingSpeed = BRIMSTONE_THROW_SPEED
			ballData.fallingAccel = BRIMSTONE_THROW_ACCEL

			sfx:Stop(SoundEffect.SOUND_HAND_LASERS)
			sfx:Play(SoundEffect.SOUND_FAMINE_BURST, 2, 0, false, 0.8)
		end

		-- Sounds
		local animation = sprite:GetAnimation()
		local frame = sprite:GetFrame()

		if animation == "Intro" then
			if frame == 15 then
				sfx:Play(SoundEffect.SOUND_PING_PONG)
			elseif frame == 22 or frame == 25 then
				sfx:Play(SoundEffect.SOUND_SPLATTER, 0.85, 0, false, 0.6 + math.random() / 5)
			elseif frame == 27 then
				sfx:Play(SoundEffect.SOUND_HEARTOUT, 0.6, 0, false, 0.5)
				data.shadow = Isaac.Spawn(1000, mod.FF.DetatchedShadow.Var, mod.FF.DetatchedShadow.Sub, npc.Position, Vector.Zero, npc)
			elseif frame >= 41 and npc.EntityCollisionClass == 0 then
				npc.EntityCollisionClass = 4
			elseif frame == 60 then
				sfx:Play(mod.Sounds.MadommeAppear)
			end
		end

		if sprite:IsEventTriggered("yell") then
			sfx:Play(mod.Sounds.MadommeThrowEnd)
		end

		if npc:HasMortalDamage() then
			sfx:Play(mod.Sounds.MadommeDeath)
		end

		if data.shadow then
			data.shadow.Position = npc.Position
			data.shadow.Velocity = npc.Velocity
		end

		if frame >= 10 then
			if animation == "Transition" then
				data.shadow.Visible = false
			elseif animation == "Un Transition" then
				data.shadow.Visible = true
			end
		end
	end,

	Damage = function(npc, amount, flags, source, cooldown)
		if source.Type == 1000 and source.Variant == 71 then -- Player Brimstone Swirl
			local realSource = mod.XalumFindRealEntity(source)
			if realSource then
				source = {Type = realSource.SpawnerType, Variant = realSource.SpawnerVariant}
			end
		end

		if source.Type == mod.FF.Madomme.ID and source.Variant == mod.FF.Madomme.Var then
			return false
		end
	end,

	Death = function(npc)
		for _, champ in pairs(Isaac.FindByType(mod.FF.Champ.ID, mod.FF.Champ.Var)) do
			champ:GetSprite():Play("CryStart")
		end

		if npc:GetData().shadow then
			npc:GetData().shadow:Remove()
		end
	end,
}