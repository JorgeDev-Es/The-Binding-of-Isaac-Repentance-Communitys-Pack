local mod = FiendFolio
local game = Game()


--LOTS OF STOLEN CODE FROM GREEN LOKI, THANKS JULIA

local function spawnDirections(spawner, start, goal, step)
    for i = start, goal, step do
        local vel = Vector.FromAngle(i) * 12
        local proj = Isaac.Spawn(9, 0, 0, spawner.Position, vel, spawner):ToProjectile()
        proj:AddProjectileFlags(ProjectileFlags.SMART | ProjectileFlags.DECELERATE)
        proj.Color = mod.ColorPsy
        proj:GetData().customSpawn = true
    end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 1 and npc.SubType == mod.FF.AlienLokiChampion.Sub then
        local data = npc:GetData()
        local sprite = npc:GetSprite()

        if not data.initialized then
            --sprite:ReplaceSpritesheet(0, "gfx/bosses/champions/boss_loki_green.png")
            --sprite:LoadGraphics()
            data.initialized = true
        end

        if sprite:IsPlaying("TeleportUp") and sprite:IsEventTriggered("Jump") then
            npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
           --[[Isaac.Spawn(1000, 2, 0, npc.Position, Vector(0,0), npc)
            spawnDirections(npc, 18, 306, 72)]] --5 projectiles
        end
        
        if sprite:IsPlaying("Attack03") and sprite:IsEventTriggered("Shoot") then
            spawnDirections(npc, 18, 306, 72) --5 projectiles
        end

        if sprite:IsPlaying("Attack01") and sprite:IsEventTriggered("Shoot") then
            local frame = sprite:GetFrame()

            if frame == 25 or frame == 75 then --diagonals
                spawnDirections(npc, 45, 315, 90)
            else --cardinals
                spawnDirections(npc, 0, 360, 90)
            end
        end
		
		if not npc.FlipX and not sprite:IsPlaying("TeleportUp") then
			local otherhalf
			for i, entity in pairs(Isaac.FindInRadius(npc.Position, 200, EntityPartition.ENEMY)) do
				if entity.Type == 69 and entity.Variant == 1 and entity.SubType == mod.FF.AlienLokiiChampion.Sub and entity.FlipX then
					otherhalf = entity
				end
			end
			
			if otherhalf and not otherhalf:GetSprite():IsPlaying("TeleportUp") then
				local laserend = otherhalf.Position + Vector(0, -17)
				data.LokiiLaser = data.LokiiLaser or EntityLaser.ShootAngle(10, npc.Position, (laserend - npc.Position):GetAngleDegrees(), 5, Vector(0,-17), npc)
				local laser = data.LokiiLaser
				laser.Angle = (laserend - npc.Position):GetAngleDegrees()
				laser.MaxDistance = laserend:Distance(npc.Position) + 3
				laser.DepthOffset = -500
				laser.CollisionDamage = 0
				laser.Mass = 0
				laser:SetTimeout(2)
			end
		end
		
		if data.LokiiLaser and not data.LokiiLaser:Exists() then
			data.LokiiLaser = nil
		end
    end
end, 69)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    if proj.SpawnerEntity then
        if proj.FrameCount > 0 and proj.SpawnerEntity.Type == 69 and proj.SpawnerEntity.Variant == 1 and proj.SpawnerEntity.SubType == mod.FF.AlienLokiiChampion.Sub and not proj:GetData().customSpawn then --if spawned by green lokii and not custom, remove
            proj:Remove()
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, var, sub, pos, vel, spawner, seed) 
    if spawner then
        if spawner.Type == 69 and spawner.Variant == 1 and spawner.SubType == mod.FF.AlienLokiiChampion.Sub then

            if type == 25 and var == 1 then --replace boom fly with Volt
                return {195, 30, 0, seed}
            end
        end
    end
end)