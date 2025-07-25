local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.BloatedBody, "Tears will split in 4 on hit#Split tears deal half the damage of their spawner tears, and have half of their range#Split tears will split into 4 more, further reducing damage and range, and continue splitting until their range runs out")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_CRICKETS_BODY, 'using {{Card' ..Card.RUNE_JERA .. "}}" .. "{{ColorYellow}} Jera {{CR}}", true)
end

function mod:MBtearInit(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    local playerData = player and player:GetData()
    if player and (player:HasCollectible(MattPack.Items.BloatedBody) or playerData.nextIsSuperSplitting) then
        playerData.nextIsSuperSplitting = nil
        local data = tear:GetData()
        if not data.skipBloatedBody then
            data.origSpeed = tear.Velocity:Length()
            data.isSuperSplitting = true
            data.MBPlayer = player
            if tear.Type == 2 then -- if tear
                tear.Scale = tear.Scale + .15
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.MBtearInit)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, mod.MBtearInit)

mod.setScale = nil
local rangeMulti = 1/3
function mod:MBtearDeath(tear, col)
    local data = tear:GetData()
    if data.isSuperSplitting then
        if data.procDelay then
            data.procDelay = data.procDelay - 1
            if data.procDelay <= 0 or ((not col) and tear:IsDead()) then
                data.procDelay = nil
            end
        end
        if not data.procDelay and not (col and tear:IsDead()) then
            local player = data.MBPlayer
            if player then
                data.procDelay = player.MaxFireDelay / 4
                local playerData = player:GetData()
                local bonusMulti = playerData.nextSuperSplitRangeMulti or 1
                playerData.nextSuperSplitRangeMulti = nil
                if not data.lastRange then
                    data.lastRange = player.TearRange * bonusMulti
                end
                if not data.lastHeight then
                    data.lastHeight = player.TearHeight
                end
                if (data.lastRange > 40) then
                    local rotationVector = Vector(1,1):Rotated(math.random(-10, 10))
                    data.lastRange = (data.lastRange or player.TearRange) * rangeMulti
                    local origRange = player.TearRange
                    data.lastHeight = (data.lastHeight or player.TearHeight) * rangeMulti
                    local origHeight = player.TearHeight
                    playerData.setRange = data.lastRange
                    playerData.setHeight = data.lastHeight
                    player:AddCacheFlags(CacheFlag.CACHE_RANGE, true)
                    for i = 1, 4 do
                        local tear2 = player:FireTear(tear.Position, rotationVector:Resized(data.origSpeed or tear.Velocity:Length()):Rotated(90 * i), false, true, false, nil, 1)
                        local tear2Data = tear2:GetData()
                        tear2.TearFlags = tear.TearFlags
                        tear2:ChangeVariant(tear.Variant)
                        tear2.SubType = tear.SubType
                        tear2.Color = tear.Color
                        tear2.CollisionDamage = tear.CollisionDamage / 2
                        local scaleMulti = 2/3
                        if tear.Variant == 8 then
                            scaleMulti = 1/3
                        end
                        tear2.Scale = tear.Scale * scaleMulti
                        tear2.KnockbackMultiplier = tear.KnockbackMultiplier * scaleMulti
                        tear2Data.lastRange = data.lastRange
                        tear2Data.isSuperSplitting = true
                        tear2Data.MBPlayer = tear:GetData().MBPlayer
                    end
                    playerData.setRange = origRange
                    playerData.setHeight = origHeight
                    player:AddCacheFlags(CacheFlag.CACHE_RANGE, true)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, mod.MBtearDeath)
mod:AddCallback(ModCallbacks.MC_TEAR_GRID_COLLISION, mod.MBtearDeath)
mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, mod.MBtearDeath)

function mod:MBBombDeath(bomb)
    if bomb.Type == 4 then
        bomb = bomb:ToBomb()
        local data = bomb:GetData()
        if data.isSuperSplitting then
            local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
            if player then
                local playerData = player:GetData()
                if not data.lastRange then
                    data.lastRange = player.TearRange
                end
                if not data.lastHeight then
                    data.lastHeight = player.TearHeight
                end
                if (data.lastRange > 40) then
                    local rotationVector = Vector(1,1):Rotated(math.random(-10, 10))
                    data.lastRange = (data.lastRange or player.TearRange) * rangeMulti
                    local origRange = player.TearRange
                    data.lastHeight = (data.lastHeight or player.TearHeight) * rangeMulti
                    local origHeight = player.TearHeight
                    playerData.setRange = data.lastRange
                    playerData.setHeight = data.lastHeight
                    player:AddCacheFlags(CacheFlag.CACHE_RANGE, true)
                    for i = 1, 4 do
                        local tear2 = player:FireBomb(bomb.Position, rotationVector:Resized(data.lastRange / 7.5):Rotated(90 * i), nil)
                        tear2.Flags = bomb.Flags
                        tear2.Variant = bomb.Variant
                        tear2.SubType = bomb.SubType
                        tear2.Color = bomb.Color
                        tear2.ExplosionDamage = (bomb.ExplosionDamage) / 2
                        local scaleMulti = 2/3
                        tear2:SetScale(bomb:GetScale() * scaleMulti)
                        tear2:GetData().lastRange = data.lastRange
                    end
                    playerData.setRange = origRange
                    playerData.setHeight = origHeight
                    player:AddCacheFlags(CacheFlag.CACHE_RANGE, true)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.MBBombDeath)

local laserRangeMulti = 2/5
function mod:MBLaserCol(laser, col)
    local doCheck = (col or (laser.Timeout <= 0 and laser.FrameCount > 1)) and laser.SubType ~= 1415
    if laser:IsCircleLaser() and not col then
        doCheck = false
    end
    if doCheck and not game:IsPaused() then
        local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
        local playerData = player and player:GetData()
        local data = laser:GetData()
        if player and (player:HasCollectible(MattPack.Items.BloatedBody) or playerData.nextIsSuperSplitting) and not data.skipBloatedBody then
            playerData.nextIsSuperSplitting = nil
            laser:ClearTearFlags(TearFlags.TEAR_CONTINUUM)
            local shouldBurst = (not data.alreadyBurst) or (col and (not data.burstList[GetPtrHash(col)]))
            if shouldBurst then
                data.alreadyBurst = true
                data.burstList = (data.burstList or {})
                if col then
                    data.burstList[GetPtrHash(col)] = true
                end
                local bonusMulti = playerData.nextSuperSplitRangeMulti or 1
                playerData.nextSuperSplitRangeMulti = nil
                local laserLength = data.lastDistance
                local pos2 = nil
                if not laserLength then
                    if not col then
                        local samplePoints = laser:GetSamples()
                        if #samplePoints > 0 then
                            pos2 = samplePoints:Get(#samplePoints - 1)
                        end
                    else
                        pos2 = col.Position
                    end
                    laserLength = (player.TearRange / 1.5 + 40) * bonusMulti
                end
                if not pos2 then
                    pos2 = laser.Position + Vector.FromAngle(laser.Angle):Resized(laserLength + 13)
                end
                if (laserLength > 40) then
                    local rotationVector = 45 + math.random(-10, 10)
                    local impact = Isaac.Spawn(1000, 50, 5, pos2, Vector.Zero, nil)
                    impact.Color = laser.Color
                    impact.PositionOffset = laser.PositionOffset
                    impact.SpriteRotation = math.random(0, 360)
                    impact.SpriteScale = Vector.One * math.min(1, laserLength / 65 / 2.5)
                    if Isaac.CountEntities(nil, 7) < 124 then                       
                        for i = 1, 4 do
                            local laser2
                            if laser.Variant == 2 then
                                laser2 = player:FireTechLaser(pos2, -1, Vector.FromAngle(rotationVector + 90 * i), nil, false, nil, (laser.CollisionDamage / 2) / player.Damage)
                            else
                                laser2 = player:FireBrimstone(Vector.FromAngle(rotationVector + 90 * i), nil, (laser.CollisionDamage / 2) / player.Damage)
                                laser2.Position = pos2
                            end
                            laser2.TearFlags = laser.TearFlags
                            laser:ClearTearFlags(TearFlags.TEAR_CONTINUUM)
                            laser2.DisableFollowParent = true
                            laser2.Variant = laser.Variant
                            if not laser:IsCircleLaser() then
                                laser2.SubType = laser.SubType
                            end

                            local laser2data = laser2:GetData()
                            laser2data.spawnerPointer = data.spawnerPointer
                            laser2data.spawnerHash = data.spawnerHash

                            laser2.CollisionDamage = laser.CollisionDamage / 2
                            laser2.PositionOffset = laser.PositionOffset
                            local scaleMulti = 2/3
                            laser2:SetMaxDistance(laserLength * laserRangeMulti)
                            laser2data.lastDistance = laserLength * laserRangeMulti
                            laser2:SetScale(laser2:GetScale() * scaleMulti)
                            laser2.Timeout = math.max(1, laser.Timeout + 3)
                            laser2.Color = laser.Color
                            laser2:RecalculateSamplesNextUpdate()
                            laser2:Update()
                        end
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_UPDATE, mod.MBLaserCol)
mod:AddCallback(ModCallbacks.MC_POST_LASER_COLLISION, mod.MBLaserCol)


function mod:MBKnifeCol(ent, col)
    local data = ent:GetData()
    if ent:IsFlying() then
        local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
        if player and player:HasCollectible(MattPack.Items.BloatedBody) then
            if not data.MBTriggered then
                data.MBTriggered = true
                for i = 0, 3 do
                    local dir = Vector(1, 0):Rotated(90 * i)
                    local knife = mod.fireKnifeProjectile(player, ent.Position, dir:Resized(25), 0, 0, ent.CollisionDamage / 2, player)
                    knife.SpriteScale = ent.SpriteScale * 2/3
                    knife:GetData().isBBKnife = true
                    knife.Parent:GetData().bbSpawner = col
                    knife.SpawnerEntity = player
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_COLLISION, mod.MBKnifeCol)

function mod:MBKnifeUpdate(knife)
    if not knife:IsFlying() then
        local data = knife:GetData()
        if data.MBTriggered then
            data.MBTriggered = nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, mod.MBKnifeUpdate)


function mod:tearPoofSpawn(ent)
    for _,tear in ipairs(Isaac.FindInRadius(ent.Position, 0, EntityPartition.TEAR)) do
        local tear = tear:ToTear()
        if tear then
            if tear:GetData().isSuperSplitting then
                local setScale = ent.SpriteScale * math.min(1, tear.Scale * 2)
                if setScale:Length() < .3 then
                    ent:Remove()
                else
                    ent.SpriteScale = setScale
                    ent:GetSprite().PlaybackSpeed = math.max(1, 1 / (setScale:Length()))
                end
                break
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.tearPoofSpawn, 13)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.tearPoofSpawn, 79)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.tearPoofSpawn, 80)

function mod:cacheSet(player)
    local data = player:GetData()
    if data.setRange then
        player.TearRange = data.setRange
        data.setRange = nil
    end
    if data.setHeight then
        player.TearHeight = data.setHeight
        data.setHeight = nil
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE + 2, mod.cacheSet)

function mod:mutantBodyUnlockCond()
    local bl = Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_CRICKETS_BODY) or {}
    for _,pedestal in ipairs(bl) do
        local data = pedestal:GetData()
        data.q5TargetScale = .35
        data.q5TargetOffset = Vector(0, .05)
        local pos = pedestal.Position + Vector(2.5, -35)
        local targetFunc = function()
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1.5)
            sfx:Play(SoundEffect.SOUND_JELLY_BOUNCE, 1.5)
            local splat = Isaac.Spawn(1000, 2, 4, pos, Vector.Zero, nil)
            splat.DepthOffset = 80
            for i = 0, math.random(18, 24) do
                local particle = Isaac.Spawn(1000, 5, 5, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
            end
            for i = 0, 15 do
                local variant = 0
                if i <= 4 then
                    variant = 1
                end
                local tear = Isaac.Spawn(2, variant, 0, pedestal.Position, RandomVector():Resized(math.random(3, 4)), nil):ToTear()
                tear.Height = -35
                tear.FallingSpeed = math.random(-1000, 0) / 100
                tear.FallingAcceleration = math.random(40, 50) / 100
                tear.Scale = tear.Scale + (math.random(-50, 15) / 100)
            end
        end
        local updateFunc = function(pedestal, percent)
            if MattPack.isNormalRender() and math.random(1, 7) == 1 then
                if math.random(1, 4) == 1 then
                    sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, nil, nil, math.random(85, 115) / 100)
                else
                    sfx:Play(SoundEffect.SOUND_PLOP, 1, nil, nil, math.random(85, 115) / 100)
                end
                local tearPoof = Isaac.Spawn(1000, 12, 0, pos + RandomVector():Resized(0, 25), Vector.Zero, nil)
                tearPoof.SpriteScale = Vector.One * math.random(5, 10) / 10 * ((data.q5TargetScale * percent) + 1)
                tearPoof.Color = pedestal.Color
            end
        end
        mod.switchItem(pedestal, MattPack.Items.BloatedBody, function()
            sfx:Play(128, 2, nil, nil, .3)
            sfx:Play(SoundEffect.SOUND_INFLATE, 1, nil, nil, .45) 
        end, targetFunc, updateFunc)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.mutantBodyUnlockCond, Card.RUNE_JERA)
