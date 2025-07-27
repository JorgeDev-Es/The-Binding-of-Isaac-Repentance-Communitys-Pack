local mod = FiendFolio

local PROJ_SPEED = 6
local SPAWN_NUM = 16

return {
	Init = function(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.SpriteOffset = Vector(0, -10)

		local data = npc:GetData()
		data.velocityCache = npc.Velocity
		data.bounces = 0
		data.cooldown = 0
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		npc.Velocity = npc.Velocity:Resized(data.velocityCache:Length())

		data.cooldown = data.cooldown - 1

		if npc.Velocity.Y > 0 then
			sprite:Play("Roll down")
		else
			sprite:Play("Roll up")
		end

		sprite.FlipX = npc.Velocity.X < 0

		if npc:CollidesWithGrid() and data.cooldown <= 0 then
			for i = 1, SPAWN_NUM do
				local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(PROJ_SPEED, 0):Rotated(i * 360 / SPAWN_NUM), npc.SpawnerEntity):ToProjectile()
				projectile.FallingSpeed = 0
				projectile.FallingAccel = -0.1
			end

			data.bounces = data.bounces + 1
			data.cooldown = 3

			local poof = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
			poof.SpriteScale = Vector.One * 2
			poof.SpriteOffset = npc.SpriteOffset

			if data.bounces >= 3 then
				npc:Remove()
			end

			npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
			npc:PlaySound(mod.Sounds.RipcordPop, 4, 0, false, 0.2 + math.random() / 5)
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1)
		end
	end,
}