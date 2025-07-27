local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local t = {"A", "B", "C"}

return {
	Init = function(npc)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = 0
	end,

	Render = function(npc)
		if not game:IsPaused() then
			if npc.SpriteOffset.Y < 0 then
				local data = npc:GetData()
				npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + data.fallingSpeed)
				data.fallingSpeed = data.fallingSpeed + data.fallingAccel
			else
				npc.SpriteOffset = Vector.Zero
			end
		end
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + data.fallingSpeed)
		data.fallingSpeed = data.fallingSpeed + data.fallingAccel

		if data.fallingSpeed > 0  and not data.doneTeleport then
			data.doneTeleport = true

			local room = game:GetRoom()
			npc.Position = room:FindFreePickupSpawnPosition(Isaac.GetRandomPosition())

			local target = Isaac.Spawn(1000, 30, 0, npc.Position, Vector.Zero, npc):ToEffect()
			local sprite = target:GetSprite()
			sprite:ReplaceSpritesheet(0, "gfx/bosses/madomme/madomme_suncrosshair" .. t[math.random(3)] .. ".png")
			sprite:LoadGraphics()
			sprite:Play("Blink")

			target.Timeout = 20
			data.target = target
		end

		if sprite:IsFinished("Appear") or sprite:IsFinished("Idle") then
			sprite:Play("Idle")
		elseif sprite:IsFinished("Disappear") then
			npc.Visible = false
		end

		--[[if data.target then
			data.target:GetSprite():SetFrame(npc.FrameCount % 2)
		end]]

		if npc.SpriteOffset.Y > 0 and sprite:IsPlaying("Idle") then
			npc.Velocity = Vector.Zero
			npc.SpriteOffset = Vector.Zero

			local targetAngle = (npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()
			local laser = EntityLaser.ShootAngle(1, npc.Position, targetAngle, 15, Vector.Zero, npc.SpawnerEntity or npc)
			laser:AddTearFlags(TearFlags.TEAR_WAIT)

			local poof = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
			poof.SpriteScale = Vector.One * 2

			local tracer = Isaac.Spawn(1000, 198, 0, npc.Position, Vector.Zero, npc):ToEffect()
	        tracer.TargetPosition = Vector.FromAngle(targetAngle)
	        tracer.LifeSpan = 33
	        tracer.Timeout = 38
	        tracer.SpriteScale = Vector(3, 0.0001)
	        tracer.PositionOffset = Vector(0, 5)
	        tracer.Color = Color(0.5, 0.2, 0, 0.8, 0, 0, 0)
	        tracer:Update()

			data.laserParts = {Laser = laser, Tracer = tracer}
			data.landed = true
			data.target:Remove()
			data.target = nil

			sprite:Play("Disappear")
			sfx:Play(SoundEffect.SOUND_FAMINE_BURST, 1.5, 0, false, 0.8)
		end

		if data.laserParts then
			if data.laserParts.Laser:Exists() and data.laserParts.Tracer:Exists() then
				local angle = data.laserParts.Laser.AngleDegrees
				local targetAngle = (npc:GetPlayerTarget().Position - npc.Position):GetAngleDegrees()
				local rotateBy = mod.RotateTowardsTarget(angle, targetAngle, 0.05)
				data.laserParts.Laser.AngleDegrees = data.laserParts.Laser.AngleDegrees + rotateBy
				data.laserParts.Laser.SpriteRotation = data.laserParts.Laser.AngleDegrees - 90

				if data.laserParts.Tracer:Exists() then
					data.laserParts.Tracer.TargetPosition = Vector.FromAngle(data.laserParts.Laser.AngleDegrees)
				end
			else
				npc:Remove()
			end
		end
	end,
}