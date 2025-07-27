local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local LocalState = {
	IDLE	= 1,
	CHARGE	= 2,
	IMPACT	= 3,
}

local GimpState = {
	IDLE	= 1,
	LAUNCH	= 2,
}

local IDLE_WALK_SPEED 	= 1.5
local CHARGE_SPEED		= 20

local function alignedCardinallyWithTarget(npc)
	local target = npc:GetPlayerTarget().Position
	local angle = (target - npc.Position):GetAngleDegrees()
	local moddedAngle = angle % 90

	return (
		(moddedAngle < 10 or moddedAngle > 80) and
		game:GetRoom():CheckLine(npc.Position, target, 0) and
		not npc:CollidesWithGrid()
	)
end

local function vectorDirectionFromChargeString(dir)
	if dir == "Down" then
		return Vector(0, 1)
	elseif dir == "Up" then
		return Vector(0, -1)
	elseif dir == "Right" then
		return Vector(1, 0)
	elseif dir == "Left" then
		return Vector(-1, 0)
	end
end

return {
	Init = function(npc)
		npc.SpriteOffset = Vector(0, -12)

		local data = npc:GetData()
		data.state = LocalState.IDLE
		data.delay = 20
		data.chargeDirection = "Down"

		data.params = ProjectileParams()
		data.params.Variant = ProjectileVariant.PROJECTILE_ROCK
		data.params.FallingAccelModifier = 1
		data.params.FallingSpeedModifier = -5

		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
			data.state = LocalState.IDLE
		end

		if not data.targetCache or npc.FrameCount % 120 == 0 or npc.Position:Distance(data.targetCache) < 80 then
			data.targetCache = npc:GetPlayerTarget().Position
		end

		if data.state == LocalState.IDLE then
			mod.XalumGridPathfind(npc, data.targetCache, 2, 0.4, 10)

			if npc.Velocity:Length() > 0.3 and npc.FrameCount > 1 then
				if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
					if npc.Velocity.X > 0 then
						sprite:Play("WalkRight")
					else
						sprite:Play("WalkLeft")
					end
				else
					if npc.Velocity.Y > 0 then
						sprite:Play("WalkDown")
					else
						sprite:Play("WalkUp")
					end
				end
			else
				sprite:Play("Idle")
			end

			if npc.FrameCount >= data.delay and alignedCardinallyWithTarget(npc) then
				data.chargeDirection = mod.GetStringDirectionFromVector(npc:GetPlayerTarget().Position - npc.Position)
				data.state = LocalState.CHARGE
				sprite:Play("ChargeStart" .. data.chargeDirection)
				npc:PlaySound(SoundEffect.SOUND_MOTHER_ANGER_SHAKE, 1, 0, false, 1)
				npc:PlaySound(SoundEffect.SOUND_MOUTH_FULL, 1, 0, false, 0.9)
			end
		elseif data.state == LocalState.CHARGE then
			if sprite:IsFinished("ChargeStart" .. data.chargeDirection) then
				sprite:Play("ChargeLoop" .. data.chargeDirection)
			end

			if sprite:IsEventTriggered("Shoot") then
				npc.Velocity = vectorDirectionFromChargeString(data.chargeDirection):Resized(CHARGE_SPEED)
			elseif sprite:IsPlaying("ChargeLoop") or sprite:WasEventTriggered("Shoot") then
				local targetVelocity = vectorDirectionFromChargeString(data.chargeDirection):Resized(CHARGE_SPEED)
				npc.Velocity = mod.XalumLerp(npc.Velocity, targetVelocity, 0.2)
			elseif sprite:IsPlaying("ChargeStart" .. data.chargeDirection) then
				npc.Velocity = npc.Velocity * 0.9
			end

			if npc:CollidesWithGrid() then
				data.state = LocalState.IMPACT
				sprite:Play("ChargeImpact" .. data.chargeDirection)
				game:ShakeScreen(10)
				sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 0.8)
				npc:FireBossProjectiles(10, npc.Position - vectorDirectionFromChargeString(data.chargeDirection):Resized(160), 0, data.params)
			end
		elseif data.state == LocalState.IMPACT then
			npc.Velocity = npc.Velocity * 0.8

			if sprite:IsFinished() then
				sprite:Play("Idle")
				data.state = LocalState.IDLE
				data.delay = npc.FrameCount + 60
			end
		end

		if sprite:IsEventTriggered("Sound") then
			if data.state == LocalState.CHARGE then
				npc:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_0, 1, 0, false, 0.8)
			else
				npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.24, 0, false, math.random(130,150) / 100)
			end
		end
	end,

	Collision = function(npc, collider)
		if npc:GetData().state == LocalState.CHARGE and collider.Type == mod.FF.Gimp.ID and collider.Variant == mod.FF.Gimp.Var then
			local data = collider:GetData()
			
			data.state = GimpState.LAUNCH
			data.launchSpeed = -10
			data.launchAccel = 0.5

			collider.SpriteOffset = Vector(0, -5)
			collider.EntityCollisionClass = 0
			collider.Velocity = (collider.Position - npc.Position):Resized(npc.Velocity:Length())
			collider:GetSprite():Play("Launched" .. math.random(2))
		end
	end,
}