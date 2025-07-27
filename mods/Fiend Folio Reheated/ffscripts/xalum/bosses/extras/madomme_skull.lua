local mod = FiendFolio
local sfx = SFXManager()

local LIFESPAN = 105
local REVERSE_DURATION = 5
local PERSONAL_SPACE = 60
local MAX_SPEED = 9
local SPEED_LERP = 0.2
local ANGLE_LERP = 0.125


return {
	Init = function(npc)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

		local data = npc:GetData()
		data.sinMul = 1

		npc:GetSprite():Play("Idle")
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		local target = npc:GetPlayerTarget()
		local targetAngle = (target.Position - npc.Position):GetAngleDegrees()
		if npc.FrameCount >= LIFESPAN - REVERSE_DURATION then
			targetAngle = targetAngle + 180
		end

		local rotateBy = mod.RotateTowardsTarget(npc.Velocity:GetAngleDegrees(), targetAngle, ANGLE_LERP)
		local angleMod = math.sin(npc.FrameCount / 15) * 10 * data.sinMul
		npc.Velocity = npc.Velocity:Rotated(rotateBy + angleMod)

		if npc.Position:Distance(target.Position) <= PERSONAL_SPACE then
			npc.Velocity = npc.Velocity + (npc.Position - target.Position):Resized(3)
		end

		for _, skull in pairs(Isaac.FindByType(npc.Type, npc.Variant)) do
			if npc.InitSeed ~= skull.InitSeed and npc.Position:Distance(skull.Position) < PERSONAL_SPACE * 2/3 then
				npc.Velocity = npc.Velocity + (npc.Position - skull.Position):Resized(2)
			end
		end

		local currentMaxSpeed = MAX_SPEED * npc.FrameCount / LIFESPAN
		npc.Velocity = mod.XalumLerp(npc.Velocity, npc.Velocity:Resized(MAX_SPEED), SPEED_LERP)

		local height = npc.SpriteOffset.Y
		height = mod.XalumLerp(height, 0, 0.1)
		npc.SpriteOffset = Vector(0, height)

		if npc.FrameCount % 2 == 0 then
			local trail = Isaac.Spawn(1000, 111, 0, npc.Position, RandomVector(), npc):ToEffect()
			trail.SpriteOffset = npc.SpriteOffset + Vector(0, -14)
			trail.DepthOffset = -1000
		end

		if npc.FrameCount >= LIFESPAN and not sprite:IsPlaying("Explode") then
			sprite:Play("Explode")
			sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS)
		end

		if sprite:IsEventTriggered("Explosion") then
			local splash = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
			splash.SpriteOffset = Vector(0, -12)
			npc:Remove()

			local projectile = Isaac.Spawn(9, 0, 0, npc.Position, (target.Position - npc.Position):Resized(11), npc):ToProjectile()
			projectile.Scale = projectile.Scale * 2
			projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)

			local sprite = projectile:GetSprite()
			sprite:Load("gfx/bosses/madomme/eyeskull.anm2")
			sprite:Play("Eye")

			sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 0.8)
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
		end
	end,
}