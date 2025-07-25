local mod = RegisterMod("Monstro's Lung Synergies", 1) --Made by Jaemspio

local game = Game()
local sfx = SFXManager()
local nullVector = Vector.Zero

local deletingLasers = false
local spawningLaser = false
local spawningTears = false
local spawningBall = false
local oldStatus = false

local function isSpiritSword(sword)
    return sword:ToKnife() ~= nil and (sword.Variant == 10 or sword.Variant == 11)
end

-- local function becomeFetus(tear, player)
--     local flags = TearFlags.TEAR_FETUS
--     if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then flags = flags | TearFlags.TEAR_FETUS_BRIMSTONE end
--     if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then flags = flags | TearFlags.TEAR_FETUS_SWORD end
--     if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then flags = flags | TearFlags.TEAR_FETUS_BOMBER end
--     if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then flags = flags | TearFlags.TEAR_FETUS_BONE end
--     if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then flags = flags | TearFlags.TEAR_FETUS_KNIFE end
--     if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then flags = flags | TearFlags.TEAR_FETUS_TECH end
--     if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then flags = flags | TearFlags.TEAR_FETUS_TECHX end
--     tear:ChangeVariant(TearVariant.FETUS)
--     tear:AddTearFlags(flags)
-- end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
    if cache == CacheFlag.CACHE_FIREDELAY then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
            if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
                player.MaxFireDelay = player.MaxFireDelay * 2.3
            end
            if player:HasWeaponType(WeaponType.WEAPON_FETUS) then
                player.MaxFireDelay = player.MaxFireDelay * 1.85
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
    if not tear.SpawnerEntity then return end
    local player = tear.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then return end
    local data = tear:GetData()
    if data.MonstroBrimstoneLaser then
        if tear:IsDead() then
            spawningLaser = true
            local laser = player:FireBrimstone(tear.Velocity, tear, 1 + math.random(-4, 2) / 10)
            laser.DisableFollowParent = true
            laser.Position = tear.Position
        end
    end
    if data.IsBowlingBall then
        data.TearRotation = data.TearRotation or 0
        data.TearRotation = data.TearRotation + (tear.Velocity.X < 0 and -10 or 10)
        tear.SpriteRotation = data.TearRotation
        if tear.FrameCount > player.TearRange then
            tear.FallingAcceleration = 1
        end
    end
    if data.IsAntiGravTear then
        tear.Velocity = tear.Velocity * 0.92
        if tear.FrameCount <= 1 then
            tear.FallingAcceleration = -0.1
            tear.FallingSpeed = 0
        elseif tear.FrameCount > player.TearRange / 2.5 then
            tear.FallingAcceleration = 1
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear)
    if not tear.SpawnerEntity then return end
    local player = tear.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then return end
    local data = tear:GetData()
    if not data.MonstroBrimstoneLaser then return end
    spawningLaser = true
    local laser = player:FireBrimstone(tear.Velocity, tear, 1 + math.random(-4, 2) / 10)
    laser.DisableFollowParent = true
    laser.Position = tear.Position
end)

local spawnedShockwave = false

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
    if spawningTears then return end
    if not tear.SpawnerEntity then return end
    local player = tear.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then return end
    local data = player:GetData()
    if player:HasWeaponType(WeaponType.WEAPON_FETUS) then
        spawningTears = true
        for i = 1, math.random(3, 6) do
            local t = player:FireTear(tear.Position, tear.Velocity:Rotated(math.random(-20, 20)) * math.random(9, 12) / 10, false, true, true)
            t:ChangeVariant(TearVariant.FETUS)
            t.TearFlags = tear.TearFlags
        end
        spawningTears = false
        tear:Remove()
    end
    if not player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then return end
    if data.MonstroFireFrame and data.MonstroFireFrame <= 1 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) and not player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then --Couldn't be fucked making soy milk work properly
            tear:Remove()
            sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
            if data.ChocolateMilkBarageTimer <= 0 then
                data.FireChocolateBarrage = true
            end
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_ONION) then
            if not spawningBall then
                tear:Remove()
                data.FireBowlingBall = true
                spawnedShockwave = true
            end
        else
            if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
                tear:GetData().IsAntiGravTear = true
                tear.FallingAcceleration = -0.1
                tear.FallingSpeed = 0
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
                if math.random(2) == 1 and not spawningTears then
                    spawningTears = true
                    local t = player:FireTear(tear.Position, tear.Velocity * math.random(8, 11) / 10, true, true, true)
                    t.FallingAcceleration = math.random(23, 32) / 10
                    t.FallingSpeed = -math.random(8, 15)
                    t.Scale = t.Scale * math.random(7, 13) / 10
                    spawningTears = false
                end
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) and not player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
        and not spawnedShockwave then
            local angle = player:GetLastDirection():GetAngleDegrees()
            Isaac.Spawn(1000, 72, 0, player.Position, nullVector, player):ToEffect().Rotation = angle
            spawnedShockwave = true
        end
    end
end, 50)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    deletingLasers = false
    spawnedShockwave = false
    if not player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then return end
    local data = player:GetData()
    local sprite = player:GetSprite()
    data.MonstroFireFrame = data.MonstroFireFrame or 0
    data.MonstroFireFrame = player:GetFireDirection() ~= -1 and 0 or data.MonstroFireFrame + 1
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        local time = math.ceil(player.MaxFireDelay * 2.5 + 1)
        data.ChocolateMilkBarageTimer = data.ChocolateMilkBarageTimer or 0
        data.ChocolateMilkChargeTimer = data.ChocolateMilkChargeTimer or 0
        if player:GetFireDirection() ~= -1 then
            data.ChocolateMilkChargeTimer = math.min(time, data.ChocolateMilkChargeTimer + 1)
        elseif not data.FireChocolateBarrage then
            data.ChocolateMilkChargeTimer = 0
        end
        if data.ChocolateMilkBarageTimer > 0 then
            player:SetShootingCooldown(5)
            if data.ChocolateMilkBarageTimer % 2 == 0 then
                local vel = player:GetLastDirection():Rotated(math.random(-10, 10)) * math.random(11, 14)
                local tear = player:FireTear(player.Position, vel, true, true, true, player, math.random(8, 13) / 10)
                local r = math.floor(player.TearRange / 30)
                tear.FallingAcceleration = math.random(5, 9) / 10
                tear.FallingSpeed = -math.random(r - 2, r + 4)
                tear.KnockbackMultiplier = 0.2
                if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
                    tear:GetData().IsAntiGravTear = true
                    tear.FallingAcceleration = -0.1
                    tear.FallingSpeed = 0
                end
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) and data.ChocolateMilkBarageTimer % 10 == 0 then
                local angle = player:GetLastDirection():GetAngleDegrees()
                Isaac.Spawn(1000, 72, 0, player.Position, nullVector, player):ToEffect().Rotation = angle
            end
            data.ChocolateMilkBarageTimer = data.ChocolateMilkBarageTimer - 1
        end
        if data.FireChocolateBarrage then
            data.FireChocolateBarrage = false
            local t = math.floor((data.ChocolateMilkChargeTimer / time) * 36)
            if t >= 2 then
                data.ChocolateMilkBarageTimer = t
            end
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_ONION) then
        if data.FireBowlingBall then
            data.FireBowlingBall = false
            spawningBall = true
            local dir = player:GetLastDirection()
            local tear = player:FireTear(player.Position, dir * 6 + player:GetTearMovementInheritance(dir), false, true, false, player, 3)
            tear:AddTearFlags(TearFlags.TEAR_BOUNCE)
            tear:ClearTearFlags(TearFlags.TEAR_SPECTRAL)
            tear:ChangeVariant(1)
            tear.FallingAcceleration = -0.1
            tear.FallingSpeed = 0
            tear.Height = -8
            tear.Scale = tear.Scale * 2
            tear:GetData().IsBowlingBall = true
            spawningBall = false
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
        local time = math.ceil(player.MaxFireDelay)
        data.MonstroChargeTimer = data.MonstroChargeTimer or 0
        if player:GetFireDirection() ~= -1 then
            data.MonstroChargeTimer = math.min(time, data.MonstroChargeTimer + 1)
        else
            data.MonstroChargeTimer = 0
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player, amount, flags, source)
    player = player:ToPlayer()
    if not player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then return end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_ONION) then return end
    local data = player:GetData()
	if not data.MonstroChargeTimer then return end
    local time = math.ceil(player.MaxFireDelay)
    local charge = data.MonstroChargeTimer / time
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) and charge > 0 and charge < 1 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, false, false, true, false)
    end
end, 1)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife) --Charge Attack Detection/Sprite Stuff
    if not isSpiritSword(knife) or not knife.SpawnerEntity then return end
    local player = knife.SpawnerEntity:ToPlayer()
    if not player then return end
    local data = player:GetData()
    local sprite = knife:GetSprite()
    if sprite:GetAnimation():find("Charged") then data.MonstroChargedSpiritSword = true end
    if sprite:IsEventTriggered("SwingEnd") then data.MonstroChargedSpiritSword = false end
end, 0)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife) --Main Code
    if not isSpiritSword(knife) or not knife.SpawnerEntity then return end
    local player = knife.SpawnerEntity:ToPlayer()
    if not player then return end
    local data = player:GetData()
    if data.MonstroChargedSpiritSword == nil then
        data.MonstroChargedSpiritSword = false
    end
    if oldStatus ~= data.MonstroChargedSpiritSword then
        oldStatus = data.MonstroChargedSpiritSword
        if oldStatus == false then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
                local hasBrim = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)
                local tear
                for _, t in ipairs(Isaac.FindByType(2, 47)) do
                    if t.FrameCount <= 1 then
                        tear = t
                        break
                    end
                end
                if not tear then return end
                for i = 1, hasBrim and math.random(3, 6) or math.random(7, 12) do
                    local t = player:FireTear(tear.Position, tear.Velocity:Rotated(math.random(-10, 10)) * math.random(9, 12) / 10, false, true, true)
                    t.FallingAcceleration = math.random(13, 20) / 10
                    t.FallingSpeed = -math.random(6, 13)
                    t:ChangeVariant(TearVariant.SWORD_BEAM)
                    t:GetData().MonstroBrimstoneLaser = hasBrim
                end
                if player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
                    local angle = player:GetLastDirection():GetAngleDegrees()
                    Isaac.Spawn(1000, 72, 0, tear.Position, nullVector, player):ToEffect().Rotation = angle
                end
                tear:Remove()
            end
        end
    end
end, 4)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function(_, knife)
    if knife.Variant ~= 0 or not knife.SpawnerEntity then return end
    local player = knife.SpawnerEntity:ToPlayer()
    if not player then return end
    if player:HasWeaponType(WeaponType.WEAPON_KNIFE) and player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    and player:GetActiveWeaponEntity():ToKnife():GetKnifeDistance() <= 0.1 then
        knife.Visible = false
        knife:Remove()
    end
end, 1)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
    if knife.Variant ~= 0 or not knife.SpawnerEntity then return end
    local player = knife.SpawnerEntity:ToPlayer()
    if not player then return end
    local data = knife:GetData()
    if knife:IsFlying() and knife:GetKnifeDistance() > knife.MaxDistance - 0.1 and not data.MonstroIsKnifeAtPeak then
        data.MonstroIsKnifeAtPeak = true
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
            for i = 1, math.floor((knife.Charge * 10) ^ 3) // 42 do --Random formula I just pulled out of my ass, go!
                local t = player:FireTear(knife.Position, Vector.FromAngle(knife.Rotation + math.random(-15, 15)) * math.random(8, 11), false, true, true)
                t.FallingAcceleration = math.random(11, 26) / 10
                t.FallingSpeed = -math.random(5, 19)
                t.Scale = t.Scale * math.random(7, 13) / 10
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
                local angle = Vector.FromAngle(knife.Rotation):GetAngleDegrees()
                Isaac.Spawn(1000, 72, 0, knife.Position, nullVector, player):ToEffect().Rotation = angle
            end
        end
    end
    if not knife:IsFlying() then
        data.MonstroIsKnifeAtPeak = false
    end
end, 0)

local brimLasers = {
    [1] = true,
    [6] = true,
    [9] = true,
    [11] = true,
    [14] = true,
    [15] = true,
}

mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, function(_, laser)
    if spawningLaser then
        spawningLaser = false
        return
    end
    if not brimLasers[laser.Variant] then return end
    if not laser.SpawnerEntity then return end
    local player = laser.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then return end
    if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
        if not deletingLasers then
            local dir = player:GetLastDirection()
            local vel = dir * math.random(6, 9) + player:GetTearMovementInheritance(dir)
            for i = 1, math.random(3, 7) do
                local tear = player:FireTear(player.Position, vel:Rotated(math.random(-25, 25)) * player.ShotSpeed, false, true, true)
                tear.FallingAcceleration = math.random(6, 17) / 10
                tear.FallingSpeed = -math.random(8, 34)
                tear:ChangeVariant(TearVariant.BALLOON_BRIMSTONE)
                tear:ClearTearFlags(TearFlags.TEAR_ABSORB | TearFlags.TEAR_POP | TearFlags.TEAR_QUADSPLIT)
                tear:GetData().MonstroBrimstoneLaser = true
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
                local angle = player:GetLastDirection():GetAngleDegrees()
                Isaac.Spawn(1000, 72, 0, player.Position, nullVector, player):ToEffect().Rotation = angle
            end
        end
        deletingLasers = true
        laser.Visible = false
        laser:Remove()
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if deletingLasers then
        effect.Visible = false
        effect:Remove()
    end
end, 70)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source)
    if deletingLasers and source.Type == 7 and source.SpawnerType == 1 then
        return false
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
    if not bomb.SpawnerEntity then return end
    local player = bomb.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SAD_BOMBS) then return end
    if bomb:IsDead() then
        local enemy
        local closest = 9999999
        for _, e in ipairs(Isaac.GetRoomEntities()) do
            if e:ToNPC() and e:IsActiveEnemy() then
                local d = bomb.Position:Distance(e.Position)
                if d < closest then
                    closest = d
                    enemy = e
                end
            end
        end
        if not enemy then return end
        for _, t in ipairs(Isaac.FindByType(2)) do
            if t.FrameCount <= 1 then
                t:Remove()
            end
        end
        for i = 1, math.random(11, 16) do
            local vel = (enemy.Position - bomb.Position)
            local t = player:FireTear(bomb.Position, Vector.FromAngle(vel:GetAngleDegrees() + math.random(-15, 15)) * math.random(12, 17), false, true, true)
            t.FallingAcceleration = math.random(11, 26) / 10
            t.FallingSpeed = -math.random(5, 19)
            t.Scale = t.Scale * math.random(7, 13) / 10
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, item, rng, player)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then return end
    local enemy
    local closest = 9999999
    for _, e in ipairs(Isaac.GetRoomEntities()) do
        if e:ToNPC() and e:IsActiveEnemy() then
            local d = player.Position:Distance(e.Position)
            if d < closest then
                closest = d
                enemy = e
            end
        end
    end
    if not enemy then return end
    for i = 1, math.random(11, 16) do
        local vel = (enemy.Position - player.Position)
        local t = player:FireTear(player.Position, Vector.FromAngle(vel:GetAngleDegrees() + math.random(-15, 15)) * math.random(12, 17), false, true, true)
        t.FallingAcceleration = math.random(11, 26) / 10
        t.FallingSpeed = -math.random(5, 19)
        t.Scale = t.Scale * math.random(7, 13) / 10
    end
    player:AnimateCollectible(CollectibleType.COLLECTIBLE_TAMMYS_HEAD, "UseItem")
    return true
end, CollectibleType.COLLECTIBLE_TAMMYS_HEAD)
