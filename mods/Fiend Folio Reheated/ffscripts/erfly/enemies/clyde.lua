local mod = FiendFolio

--All these different AI functions were created by the Clyde discord AI.

function mod:flyerAI(entity)
    local sprite = entity:GetSprite()
    local data = entity:GetData()
    local player = Isaac.GetPlayer(0)

    if not data.init then
        data.init = true
        entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end

    -- Movement behavior
    local velocity = entity.Velocity
    local speed = 2.0
    if math.random(100) < 10 then
        velocity = Vector((math.random() * 2.0) - 1.0, (math.random() * 2.0) - 1.0):Normalized() * speed
    end
    entity.Velocity = mod:Lerp(entity.Velocity, velocity, 0.2)

    -- Shooting behavior
    if entity.FrameCount % 120 == 0 then
        local shootDir = (player.Position - entity.Position):Normalized()
        entity:FireProjectiles(entity.Position, shootDir, 0, ProjectileParams())
        entity:PlaySound(SoundEffect.SOUND_MEATHEAD_SHOOT)
    end

    -- Death behavior
    if entity:IsDead() then
        Isaac.Spawn(math.random(50), math.random(8), 0, entity.Position, Vector(0,0), nil)
    end
end

function mod:laserShooterAI(entity)
    local data = entity:GetData()

    if not data.init then
        data.init = true
        data.laserTimer = 0
    end

    local player = Isaac.GetPlayer(0)
    local angle = (player.Position - entity.Position):GetAngleDegrees() - 90
    entity.Velocity = Vector.FromAngle(angle):Resized(1)

    data.laserTimer = data.laserTimer + 1
    if data.laserTimer > 30 then
        data.laserTimer = 0
        local laser = EntityLaser.ShootAngle(1, entity.Position, angle, 20, Vector(0,-40), entity)
        laser:SetTimeout(30)
        laser:SetMaxDistance(500)
        laser.Color = Color(1, 0, 0, 1, 0, 0, 0)
    end
end

function mod:tearShooterAI(entity)
    local data = entity:GetData()

    if not data.init then
        data.init = true
        data.chaseTarget = Isaac.GetPlayer(0)
        data.shootTimer = 0
    end

    local player = Isaac.GetPlayer(0)
    local playerPos = player.Position

    if entity.Position:Distance(playerPos) > 100 then
        entity.Velocity = (playerPos - entity.Position):Normalized() * 3
    else
        entity.Velocity = Vector(0,0)
    end

    data.shootTimer = (data.shootTimer + 1) % 90
    if data.shootTimer == 0 then
        local tearParams = ProjectileParams()
        tearParams.Variant = ProjectileVariant.PROJECTILE_TEAR
        tearParams.FallingSpeedModifier = -0.25
        tearParams.FallingAccelModifier = 0.05
        tearParams.Scale = 1.0
        tearParams.Color = Color(1, 1, 1, 1, 0, 0, 0)

        local tearSpeed = 15
        local numTears = 12
        local tearSpread = 30

        local startPos = entity.Position
        local targetPos = player.Position

        local angles = {}
        for i = 0, numTears - 1 do
            local angle = (targetPos - startPos):GetAngleDegrees()
            angles[i] = angle + i * tearSpread
        end

        for i = 0, numTears - 1 do
            local tearVector = Vector.FromAngle(angles[i])
            entity:FireProjectiles(startPos, tearVector * tearSpeed, 0, tearParams)
        end
    end
end


function mod:clydeAI(entity)
    mod:tearShooterAI(entity)
end