local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

function mod:ForkBenderProjectileSpawn(projectile, data)
    local mult = mod:GetTotalCollectibleNum(TaintedCollectibles.FORK_BENDER)
    if mult > 0 then
        if (projectile.SpawnerType == EntityType.ENTITY_FIREPLACE and projectile.SpawnerVariant == 3) or mod:RandomInt(1, 5, projectile:GetDropRNG()) <= mult then
            data.ForkBenderTimer = 10
        end
    end
end

function mod:ForkBenderProjectileUpdate(projectile, data)
    data.ForkBenderTimer =  data.ForkBenderTimer - 1
    if data.ForkBenderTimer <= 0 or projectile.Position:Distance(game:GetNearestPlayer(projectile.Position).Position) < 20 then
        local velocity = projectile.Velocity
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, Vector(projectile.Position.X, projectile.Position.Y+projectile.Height), Vector.Zero, projectile)
        effect.Color = mod.ColorPsy
        
        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, projectile.Position, velocity*(-0.5), projectile.SpawnerEntity):ToTear()
        tear:AddTearFlags(TearFlags.TEAR_HOMING)
        tear.Color = mod.ColorHoming
        if projectile:HasProjectileFlags(ProjectileFlags.EXPLODE) then
            tear:AddTearFlags(TearFlags.TEAR_EXPLOSIVE)
            tear.CollisionDamage = 40
        end
        tear.Height = projectile.Height
        tear.Scale = projectile.Scale
        
        projectile:Remove()
        SFXManager():Play(SoundEffect.SOUND_BEEP, 0.2, 2, false, 1)
        data.ForkBenderTimer = nil
    end
end