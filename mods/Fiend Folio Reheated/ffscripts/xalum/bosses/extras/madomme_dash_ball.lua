local mod = FiendFolio
local sfx = SFXManager()

local DASHBALL_SPEED = 6
local DASHBALL_SPAWN_NUM = 12
local DASHBALL_SPAWN_FREQUENCY = 36

return {
	Init = function(npc)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		npc.SpriteOffset = Vector(0, -24)
	end,

	AI = function(npc)
		npc.Velocity = mod.XalumLerp(npc.Velocity, Vector.Zero, 0.2)
		npc:GetSprite():SetFrame("Idle", npc.FrameCount % 12)

		if not npc.SpawnerEntity then
			npc:Remove()
			return
		end

		if npc.FrameCount > 0 then
			local didShoot

			if npc.FrameCount % DASHBALL_SPAWN_FREQUENCY == 0 then
				for i = 1, DASHBALL_SPAWN_NUM do
					local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(DASHBALL_SPEED, 0):Rotated(i * 360 / DASHBALL_SPAWN_NUM), npc.SpawnerEntity):ToProjectile()
					projectile.FallingSpeed = 0
					projectile.FallingAccel = -0.1
				end

				didShoot = true
			elseif npc.FrameCount % DASHBALL_SPAWN_FREQUENCY == DASHBALL_SPAWN_FREQUENCY / 2 then
				for i = 1, DASHBALL_SPAWN_NUM do
					local projectile = Isaac.Spawn(9, 0, 0, npc.Position, Vector(DASHBALL_SPEED, 0):Rotated(i * 360 / DASHBALL_SPAWN_NUM + 180 / DASHBALL_SPAWN_NUM), npc.SpawnerEntity):ToProjectile()
					projectile.FallingSpeed = 0
					projectile.FallingAccel = -0.1
				end

				didShoot = true
			end

			if didShoot then
				sfx:Play(SoundEffect.SOUND_BLOODSHOOT)

				local poof = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc):ToEffect()
				poof.SpriteScale = Vector.One * 1.5
				poof.SpriteOffset = Vector(0, -20)
			end
		end
	end,
}
