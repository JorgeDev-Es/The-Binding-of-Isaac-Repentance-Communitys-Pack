local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.KnifeBender, "↓ {{Tears}} x0.75 Fire rate multiplier#↓ {{ShotSpeed}} x0.75 Shot speed multiplier#{{Collectible"..CollectibleType.COLLECTIBLE_SPOON_BENDER .."}} Tears will attract enemy projectiles, absorbing them on contact#Upon absorbing a projectile, the tear will inherit a portion of the projectile's damage, as well as any applicable projectile flags and a small boost in range.")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_MOMS_KNIFE, 'using {{Collectible' .. CollectibleType.COLLECTIBLE_SPOON_BENDER .. "}} {{ColorYellow}}Homing Tears{{CR}}", true)
end

function mod:kbTearFire(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(MattPack.Items.KnifeBender) then
            tear:GetData().origScale = tear.Scale
            tear:GetData().isKnifeBender = true
            tear:ClearTearFlags(TearFlags.TEAR_SHIELDED)
            if tear:ToLaser() and tear.Timeout > 0 then
                tear.Timeout = tear.Timeout + 3
            end
            if tear.Type == 8 then
                if tear.Variant == 0 then
                    tear:GetSprite():ReplaceSpritesheet(0, "gfx/moms_knife_bent.png", true)
                elseif tear.Variant == 10 then
                    tear:GetSprite():ReplaceSpritesheet(0, "gfx/spirit_sword_bent.png", true)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.kbTearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, mod.kbTearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, mod.kbTearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, mod.kbTearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, mod.kbTearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, mod.kbTearFire)
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, mod.kbTearFire)
-- mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.kbTearFire)

mod.ProjFlagsToTear = {
    [ProjectileFlags.SMART] = TearFlags.TEAR_HOMING,
    [ProjectileFlags.EXPLODE] = TearFlags.TEAR_EXPLOSIVE,
    [ProjectileFlags.ACID_GREEN] = TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,
    [ProjectileFlags.GOO] = TearFlags.TEAR_GISH,
    [ProjectileFlags.GHOST] = TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_GHOST_BOMB,
    [ProjectileFlags.WIGGLE] = TearFlags.TEAR_WIGGLE,
    [ProjectileFlags.BOOMERANG] = TearFlags.TEAR_BOOMERANG,
    [ProjectileFlags.ACID_RED] = TearFlags.TEAR_BAIT | TearFlags.TEAR_BLOOD_BOMB,
    [ProjectileFlags.GREED] = TearFlags.TEAR_GREED_COIN,
    [ProjectileFlags.RED_CREEP] = TearFlags.TEAR_BAIT | TearFlags.TEAR_BLOOD_BOMB,
    [ProjectileFlags.ORBIT_CW] = TearFlags.TEAR_ORBIT,
    [ProjectileFlags.ORBIT_CCW] = TearFlags.TEAR_ORBIT,
    [ProjectileFlags.NO_WALL_COLLIDE] = TearFlags.TEAR_SPECTRAL,
    [ProjectileFlags.CREEP_BROWN] = TearFlags.TEAR_BUTT_BOMB,
    [ProjectileFlags.BURST] = TearFlags.TEAR_BURSTSPLIT | TearFlags.TEAR_SCATTER_BOMB,
    [ProjectileFlags.TURN_HORIZONTAL] = TearFlags.TEAR_TURN_HORIZONTAL,
    [ProjectileFlags.MEGA_WIGGLE] = TearFlags.TEAR_WIGGLE,
    [ProjectileFlags.BURST3] = TearFlags.TEAR_BURSTSPLIT | TearFlags.TEAR_SCATTER_BOMB,
    [ProjectileFlags.CONTINUUM] = TearFlags.TEAR_CONTINUUM,
    [ProjectileFlags.FIRE_WAVE] = TearFlags.TEAR_BURN,
    [ProjectileFlags.FIRE_WAVE_X] = TearFlags.TEAR_BURN,
    [ProjectileFlags.BURST8] = TearFlags.TEAR_BURSTSPLIT | TearFlags.TEAR_SCATTER_BOMB,
    [ProjectileFlags.FIRE_SPAWN] = TearFlags.TEAR_BURN,
    [ProjectileFlags.ANTI_GRAVITY] = TearFlags.TEAR_WAIT,
    [ProjectileFlags.BOUNCE] = TearFlags.TEAR_BOUNCE,
    [ProjectileFlags.BOUNCE_FLOOR] = TearFlags.TEAR_HYDROBOUNCE,
    [ProjectileFlags.BLUE_FIRE_SPAWN] = TearFlags.TEAR_BURN,
    [ProjectileFlags.LASER_SHOT] = TearFlags.TEAR_JACOBS,
    [ProjectileFlags.GODHEAD] = TearFlags.TEAR_GLOW | TearFlags.TEAR_HOMING,
    [ProjectileFlags.SMART_PERFECT] = TearFlags.TEAR_HOMING,
    [ProjectileFlags.BURSTSPLIT] = TearFlags.TEAR_BURSTSPLIT | TearFlags.TEAR_SCATTER_BOMB,
    [ProjectileFlags.WIGGLE_ROTGUT] = TearFlags.TEAR_WIGGLE,
    [ProjectileFlags.FREEZE] = TearFlags.TEAR_FREEZE,
    [ProjectileFlags.ACCELERATE_TO_POSITION] = TearFlags.TEAR_ACCELERATE,
    [ProjectileFlags.BACKSPLIT] = TearFlags.TEAR_SPLIT | TearFlags.TEAR_SCATTER_BOMB,
    [ProjectileFlags.SIDEWAVE] = TearFlags.TEAR_SPLIT | TearFlags.TEAR_SCATTER_BOMB,
    [ProjectileFlags.ORBIT_PARENT] = TearFlags.TEAR_ORBIT,
}

mod.ProjVarToTearFlag = {
    [ProjectileVariant.PROJECTILE_BONE] = TearFlags.TEAR_BONE,
    [ProjectileVariant.PROJECTILE_FIRE] = TearFlags.TEAR_BURN,
    [ProjectileVariant.PROJECTILE_COIN] = TearFlags.TEAR_GREED_COIN,
    [ProjectileVariant.PROJECTILE_ROCK] = TearFlags.TEAR_ROCK,
    [ProjectileVariant.PROJECTILE_LAVA] = TearFlags.TEAR_BURN,
    [ProjectileVariant.PROJECTILE_PEEP] = TearFlags.TEAR_POP,
}

local homingRadius = 80

local function absorbEffect(tear, proj, pos, color)
    local scale = proj.Scale or 1
    game:MakeShockwave(pos, 0.005 * (scale + 1) / 2, 0.025, math.ceil(3 * (scale)))
    for i = 0, math.random(5, math.max(5, math.ceil(15 * (scale or 1)))) do
        local particle = Isaac.Spawn(1000, 66, 0, pos, (Lerp(tear.Velocity, RandomVector():Resized(math.random(2, 15)), math.random(0, 50) / 100)), nil)
        particle.Color = color
    end
    proj:Remove()
    sfx:Play(SoundEffect.SOUND_SPLATTER, .5 * scale, 0, false, 1.25)
    sfx:Play(SoundEffect.SOUND_BISHOP_HIT, .75 * scale, 0, false, 1.5)
end

function mod:kbTearUpdate(tear)
    local data = tear:GetData()
    local player = (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()) or Isaac.GetPlayer()
    if data.isKnifeBender or (tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) and player:HasCollectible(MattPack.Items.KnifeBender)) then
        if not data.kbOrigScale then
            data.kbOrigScale = tear.Scale
        end
        for _,proj in ipairs(Isaac.FindByType(9)) do
            if proj:Exists() then
                proj = proj:ToProjectile()
                local dist = proj.Position:Distance(tear.Position)
                if dist <= homingRadius then
                    local color = proj.Color
                    if not proj:GetData().origColor then
                        proj:GetData().origColor = color
                    end
                    local distancePercentInverse = dist / homingRadius
                    local distancePercent = 1 - ((distancePercentInverse + 1) / 2)
                    color:SetColorize(1.4, .15, 1.38, distancePercent * 2.5)
                    color:SetOffset(Lerp(color.RO, .4, distancePercent), Lerp(color.GO, .15, distancePercent), Lerp(color.BO, .38, distancePercent))
                    proj:SetColor(color, 2, 999, true, true)
                    proj.Velocity = Lerp(proj.Velocity, (tear.Position - proj.Position):Resized(20), distancePercent)
                    proj.FallingSpeed = Lerp(proj.FallingSpeed, (tear.Height - proj.Height) / 2, (distancePercent + .5) / 1.5)
                    local dist = tear.Size * 1.5
                    if proj.Position:Distance(tear.Position) <= dist and math.abs(proj.Height - tear.Height) <= 5 then
                        for projFlag,tearFlag in pairs(mod.ProjFlagsToTear) do
                            if proj:HasProjectileFlags(projFlag) then
                                tear:AddTearFlags(tearFlag)
                            end
                        end
                        if mod.ProjVarToTearFlag[proj.Variant] then
                            tear:AddTearFlags(mod.ProjVarToTearFlag[proj.Variant])
                        end
                        tear.CollisionDamage = tear.CollisionDamage + ((player.Damage) * (proj.Scale + 1) / 2)
                        tear.Scale = tear.Scale + (proj.Scale / 15)
                        tear.Color = Color.Lerp(tear.Color, proj:GetData().origColor or proj.Color, .15)
                        tear:SetColor(color, 7, 999, true, true)
                        tear.Height = tear.Height - .15

                        absorbEffect(tear, proj, tear.Position + Vector(0, tear.Height), color)
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.kbTearUpdate)

function mod:kbLaserUpdate(laser)
    local data = laser:GetData()
    if data.isKnifeBender then
        local player = (laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()) or Isaac.GetPlayer()
        for _,proj in ipairs(Isaac.FindByType(9)) do
            proj = proj:ToProjectile()
            
            local samplePoints = laser:GetNonOptimizedSamples()
            local targetPos = laser.Position
            local dist = proj.Position:Distance(laser.Position)
            for i=0, #samplePoints-1 do
                local newpos = samplePoints:Get(i)
                local newDist = newpos:Distance(proj.Position)
                if newDist < dist then
                    dist = newDist
                    targetPos = newpos
                end
            end
            if dist <= homingRadius then
                local color = proj.Color
                if not proj:GetData().origColor then
                    proj:GetData().origColor = color
                end
                local distancePercentInverse = dist / homingRadius
                local distancePercent = 1 - ((distancePercentInverse + 1) / 2)
                color:SetColorize(1.4, .15, 1.38, distancePercent * 2.5)
                color:SetOffset(Lerp(color.RO, .4, distancePercent), Lerp(color.GO, .15, distancePercent), Lerp(color.BO, .38, distancePercent))
                proj.Color = color
                proj.Velocity = Lerp(proj.Velocity, (targetPos - proj.Position):Resized(20), distancePercent)
                proj.FallingSpeed = Lerp(proj.FallingSpeed, (laser.PositionOffset.Y - proj.Height) / 2, distancePercent)
                if proj.Position:Distance(targetPos) <= 10 and math.abs(proj.Height - laser.PositionOffset.Y) <= 5  then
                    for projFlag,tearFlag in pairs(mod.ProjFlagsToTear) do
                        if proj:HasProjectileFlags(projFlag) then
                            laser:AddTearFlags(tearFlag)
                        end
                    end
                    laser.CollisionDamage = laser.CollisionDamage + ((player.Damage) * (proj.Scale + 1) / 2)
                    laser:SetScale(laser:GetScale() + (proj.Scale / 10))
                    laser.Color = Color.Lerp(laser.Color, proj:GetData().origColor or proj.Color, .15)
                    laser:SetColor(color, 7, 999, true, true)
                    laser.OneHit = false
                    if laser.Timeout > 0 then
                        laser:SetTimeout(laser.Timeout + 1)
                    end

                    absorbEffect(laser, proj, targetPos + Vector(0, laser.PositionOffset.Y), color)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.kbLaserUpdate)

function mod:kbKnifeUpdate(ent)
    if ent:GetData().isKnifeBender then
        local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
        if player then
            for _,proj in ipairs(Isaac.FindByType(9)) do
                if proj:Exists() then
                    proj = proj:ToProjectile()
                    local dist = proj.Position:Distance(ent.Position)
                    if dist <= homingRadius then
                        local color = proj.Color
                        if not proj:GetData().origColor then
                            proj:GetData().origColor = color
                        end
                        local distancePercentInverse = dist / homingRadius
                        local distancePercent = 1 - ((distancePercentInverse + 1) / 2)
                        color:SetColorize(1.4, .15, 1.38, distancePercent * 2.5)
                        color:SetOffset(Lerp(color.RO, .4, distancePercent), Lerp(color.GO, .15, distancePercent), Lerp(color.BO, .38, distancePercent))
                        proj:SetColor(color, 2, 999, true, true)
                        local height = -15
                        if ent:GetKnifeDistance() >= 25 then
                            proj.Velocity = Lerp(proj.Velocity, (ent.Position - proj.Position):Resized(20), distancePercent)
                            proj.FallingSpeed = Lerp(proj.FallingSpeed, (height - proj.Height) / 2, (distancePercent + .5) / 1.5)
                        end
                        local dist = ent.Size * 1.5
                        local maxHeightDiff = 5
                        if ent.Variant >= 10 then
                            maxHeightDiff = 40
                        end
                        if proj.Position:Distance(ent.Position) <= dist and math.abs(proj.Height - height) <= maxHeightDiff then
                            for projFlag,tearFlag in pairs(mod.ProjFlagsToTear) do
                                if proj:HasProjectileFlags(projFlag) then
                                    ent:AddTearFlags(tearFlag)
                                end
                            end
                            ent.CollisionDamage = ent.CollisionDamage + ((player.Damage) * (proj.Scale + 1) / 2)
                            ent.Scale = ent.Scale + (proj.Scale / 15)
                            ent.Color = Color.Lerp(ent.Color, proj:GetData().origColor or proj.Color, .15)
                            ent:SetColor(color, 15, 999, true, true)    
                            absorbEffect(ent, proj, ent.Position, color)
                        end
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, mod.kbKnifeUpdate)

function mod:kbBombUpdate(ent)
    if ent:GetData().isKnifeBender then
        local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
        if player then
            for _,proj in ipairs(Isaac.FindByType(9)) do
                if proj:Exists() then
                    proj = proj:ToProjectile()
                    local dist = proj.Position:Distance(ent.Position)
                    if dist <= homingRadius then
                        local color = proj.Color
                        if not proj:GetData().origColor then
                            proj:GetData().origColor = color
                        end
                        local distancePercentInverse = dist / homingRadius
                        local distancePercent = 1 - ((distancePercentInverse + 1) / 2)
                        color:SetColorize(1.4, .15, 1.38, distancePercent * 2.5)
                        color:SetOffset(Lerp(color.RO, .4, distancePercent), Lerp(color.GO, .15, distancePercent), Lerp(color.BO, .38, distancePercent))
                        proj:SetColor(color, 2, 999, true, true)
                        local height = -15
                        if ent.FrameCount > 5 then
                            proj.Velocity = Lerp(proj.Velocity, (ent.Position - proj.Position):Resized(20), distancePercent)
                            proj.FallingSpeed = Lerp(proj.FallingSpeed, (height - proj.Height) / 2, (distancePercent + .5) / 1.5)
                        end
                        local dist = ent.Size * 1.5
                        if proj.Position:Distance(ent.Position) <= dist and math.abs(proj.Height - height) <= 5 then
                            for projFlag,tearFlag in pairs(mod.ProjFlagsToTear) do
                                if proj:HasProjectileFlags(projFlag) then
                                    ent:AddTearFlags(tearFlag)
                                end
                            end
                            ent:SetScale(ent:GetScale() + (proj.Scale / 5))
                            ent:SetLoadCostumes(true)
                            if not ent:GetData().origMulti then
                                ent:GetData().origMulti = ent.RadiusMultiplier
                            end
                            ent:GetData().tearsHit = (ent:GetData().tearsHit or 0) + 1
                            local increaseBy = 1.5 * ((proj.Scale + 1) / 2)
                            ent.ExplosionDamage = ent.ExplosionDamage + ((player.Damage * 5) * (proj.Scale + 1) / 2)
                            local multi = 1
                            if ent.ExplosionDamage >= 175 then
                                multi = .75
                            end
                            ent.RadiusMultiplier = ((40 + ((increaseBy / ent:GetData().origMulti) * ent:GetData().tearsHit)) / 40) * ent:GetData().origMulti * multi
                            ent.Color = Color.Lerp(ent.Color, proj:GetData().origColor or proj.Color, .15)
                            ent:SetColor(color, 15, 999, true, true)
                            absorbEffect(ent, proj, ent.Position, color)
                        end
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.kbBombUpdate)

function mod:kbEvalCache(player, flag)
    if player:HasCollectible(MattPack.Items.KnifeBender) then
        if flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay / .75
        elseif flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed * .75
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.kbEvalCache, CacheFlag.CACHE_FIREDELAY)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.kbEvalCache, CacheFlag.CACHE_SHOTSPEED)

function mod:kbMorphCond(ent)
    if ent.SubType == 114 then
        local data = ent:GetData()
        local pos = ent.Position + Vector(0, -42.5)
        local tearTargetPos = ent.Position + Vector(0, -10)
        for _,tear in ipairs(Isaac.FindByType(2)) do
            if tear:ToTear():HasTearFlags(TearFlags.TEAR_HOMING) then
                local dist = tear.Position:Distance(tearTargetPos)
                local homingRadius2 = homingRadius * 2
                if dist <= homingRadius2 then
                    local distancePercentInverse = dist / homingRadius2
                    local distancePercent = 1 - ((distancePercentInverse + 1) / 2)
                    tear.Velocity = Lerp(tear.Velocity, (tearTargetPos - tear.Position):Resized(20), distancePercent)
                    if dist <= 20 then
                        
                        local color = Color(1,1,1,1)
                        local percent = 1
                        color:SetColorize(1.4, .15, 1.38, percent * 2.5)
                        color:SetOffset(Lerp(color.RO, .4, percent), Lerp(color.GO, .15, percent), Lerp(color.BO, .38, percent))
                        game:MakeShockwave(pos, 0.005 * 2 / 2, 0.025, 6)
                        for i = 0, math.random(5, math.max(5, 15)) do
                            local particle = Isaac.Spawn(1000, 66, 0, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
                            particle.Color = color
                        end
                        tear:Die()
                        sfx:Play(SoundEffect.SOUND_SPLATTER, 1, 0, false, 1.25)
                        sfx:Play(SoundEffect.SOUND_BISHOP_HIT, 1.5, 0, false, 1.5)
    
                        data.kbCharge = (data.kbCharge or 0) + .2
                    end
                end
            end
        end

        for _,laser in ipairs(Isaac.FindByType(7)) do
            local laser = laser:ToLaser()
            local ptrhash = GetPtrHash(laser)
            if laser and laser:HasTearFlags(TearFlags.TEAR_HOMING) and (not data.kbCooldown) and not (data.lasersToIgnore and data.lasersToIgnore[ptrhash]) then
                local samplePoints = laser:GetNonOptimizedSamples()
                for i=0, #samplePoints-1 do
                    local sampePos = samplePoints:Get(i)
                    if sampePos:Distance(tearTargetPos) < laser.Radius / 2 then
                        local color = Color(1,1,1,1)
                        local percent = 1
                        color:SetColorize(1.4, .15, 1.38, percent * 2.5)
                        color:SetOffset(Lerp(color.RO, .4, percent), Lerp(color.GO, .15, percent), Lerp(color.BO, .38, percent))
                        game:MakeShockwave(pos, 0.005 * 2 / 2, 0.025, 6)
                        for i = 0, math.random(5, math.max(5, 15)) do
                            local particle = Isaac.Spawn(1000, 66, 0, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
                            particle.Color = color
                        end
                        sfx:Play(SoundEffect.SOUND_SPLATTER, 1, 0, false, 1.25)
                        sfx:Play(SoundEffect.SOUND_BISHOP_HIT, 1.5, 0, false, 1.5)
                        
                        data.kbCharge = (data.kbCharge or 0) + .2
                        if laser.OneHit then
                            if not data.lasersToIgnore then
                                data.lasersToIgnore = {}
                            end
                            data.lasersToIgnore[ptrhash] = true
                        else
                            Isaac.CreateTimer(function()
                                data.kbCooldown = nil
                            end, 2, 1)
                            data.kbCooldown = true
                        end
                        break
                    end
                end
            end
        end
        
        local color = Color(1,1,1,1)
        local percent = (data.kbCharge or 0) / 1
        color:SetColorize(1.4, .15, 1.38, percent * 2.5)
        color:SetOffset(Lerp(color.RO, .4, percent), Lerp(color.GO, .15, percent), Lerp(color.BO, .38, percent))
        data.kbCharge = math.max(0, (data.kbCharge or 0) - .01)
        ent:GetSprite():GetLayer(1):SetColor(color)
        if data.kbCharge then
            if data.kbCharge > 1 then
                ent:Morph(5, 100, MattPack.Items.KnifeBender, true)
                mod.constants.pool:RemoveCollectible(MattPack.Items.KnifeBender)
                ent:SetColor(color, 30, 999, true, true)
                EntityEffect.CreateLight(pos, 5, 10, 6, color)
                data.kbCharge = nil
                game:MakeShockwave(pos, 0.005 * 2 / 2, 0.1, 10)
                for i = 0, 25 do
                    local particle = Isaac.Spawn(1000, 66, 0, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
                    particle.Color = color
                end
                sfx:Play(SoundEffect.SOUND_SPLATTER, 1.5, 0, false, 1.25)
                sfx:Play(SoundEffect.SOUND_BISHOP_HIT, 3.5, 0, false, .25)
                sfx:Play(MattPack.Sounds.OrbBreak, 1, 0, false, .75)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.kbMorphCond, 100)


function mod:kbLudoScale(tear)
    local data = tear:GetData()
    if data.kbOrigScale and tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
        tear.Scale = Lerp(tear.Scale, data.kbOrigScale, .15)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, mod.kbLudoScale)