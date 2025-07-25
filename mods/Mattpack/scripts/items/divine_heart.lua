local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.DivineHeart, "↑ {{Damage}} x1.5 Damage multiplier#↓ {{Tears}} x0.66 Fire rate multiplier#↓ {{Shotspeed}} x0.5 Shot speed multiplier#Piercing + spectral tears#Tears will leave a faint trail along the path they've traveled#Upon the death of the tear, a beam of light will spawn along the trail, dealing up to 3.75x the player's damage per second")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_SACRED_HEART, 'by sacrificing an {{EternalHeart}} {{ColorYellow}}Eternal Heart{{CR}} using {{ButtonRT}}', true, nil, 1)
end

mod.TearLaserSamples = {}
mod.TearLaserSamplesPure = {}

mod.divineHeartFunctionalResolution = 3 -- Lower = more lasers / Default = 3

local sacredHeartColor = Color(1,1,1,2.5,
0,0,0, -- Offset
.48,3.5,3.5, 1) -- Colorize

local sacredHeartLaserColor = Color(1,1,1,2.5,
0,0,0,
2.75,3.5,3.5,1)

mod.ItemCacheData[MattPack.Items.DivineHeart] = { -- {Add, Multiply} / for BitSets {Add, Remove}
    [CacheFlag.CACHE_DAMAGE] = {nil, 1.5},
    [CacheFlag.CACHE_FIREDELAY] = {nil, 1.5}, -- 2/3 fire rate
    [CacheFlag.CACHE_SHOTSPEED] = {nil, .5},
}
function mod:sh2Cache(player, flag)
    if player:HasCollectible(MattPack.Items.DivineHeart) then
        local flagData = mod.ItemCacheData[MattPack.Items.DivineHeart][flag]
        if flagData then
                local add = flagData[1] or 0
            local multi = flagData[2] or 1
            local stat = mod.flagToStat[flag]
            if stat then
                if not (flag == CacheFlag.CACHE_SHOTSPEED and player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)) then -- i LOVE hardcoding
                    player[stat] = (player[stat] + add) * (multi)
                end
            end
        else
            if flag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING
                local modifiers = player:GetWeaponModifiers()
                if modifiers & WeaponModifier.LUDOVICO_TECHNIQUE == 0 then
                    player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
                end
            elseif flag == CacheFlag.CACHE_TEARCOLOR then
                player.TearColor = sacredHeartLaserColor
            elseif flag == CacheFlag.CACHE_FLYING then
                player.CanFly = true
            elseif flag == CacheFlag.CACHE_WEAPON then
                local modifiers = player:GetWeaponModifiers()
                if modifiers & WeaponModifier.LUDOVICO_TECHNIQUE == 0 then
                    if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) or player:HasWeaponType(WeaponType.WEAPON_LASER) then
                        Isaac.CreateTimer(function()
                            local newWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_TEARS, player)
                            newWeapon:SetModifiers(modifiers &~ WeaponModifier.BRIMSTONE)
                            player:SetWeapon(newWeapon, 1)
                        end, 0, 0)
                    end
                elseif not player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
                    Isaac.CreateTimer(function() -- OGH
                        local weaponType = WeaponType.WEAPON_LUDOVICO_TECHNIQUE
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
                            weaponType = WeaponType.WEAPON_LASER
                            modifiers = modifiers | WeaponModifier.LUDOVICO_TECHNIQUE
                        end
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
                            weaponType = WeaponType.WEAPON_BRIMSTONE
                            modifiers = modifiers | WeaponModifier.LUDOVICO_TECHNIQUE
                        end
                        local newWeapon = Isaac.CreateWeapon(weaponType, player)
                        newWeapon:SetModifiers(modifiers)
                        player:SetWeapon(newWeapon, 1)
                    end, 0, 0)
                end
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, mod.sh2Cache)

mod.bloodTearVariants = {
    [1] = true,
    [10] = true,
    [12] = true,
    [15] = true,
    [17] = true,
    [35] = true,
    [37] = true,
}

function mod:sh2Init(tear)
    local spawner = tear.SpawnerEntity
    local player = (spawner and spawner:ToPlayer()) or (spawner and spawner:ToFamiliar() and spawner:ToFamiliar().Player)
    if player:HasCollectible(MattPack.Items.DivineHeart) and tear.SubType ~= 1415 then
        tear:GetData().divineHeartTear = true
        tear.Color = sacredHeartLaserColor
        if tear.Type == 2 then
            tear.Color = sacredHeartColor
            tear.Scale = tear.Scale + .15
            tear:GetTearEffectSprite().Color = sacredHeartLaserColor
            local godheadSprite = tear:GetTearHaloSprite()
            godheadSprite.Color = Color(0,1,1,godheadSprite.Color.A,.75,1,1,.75,1,1,1)
            if tear.Variant == 1 or tear.Variant == 10 or tear.Variant == 35 then
                tear:ChangeVariant(0)
            end
        elseif tear.Type == 7 then
            tear:SetScale(tear:GetScale() + .5)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.sh2Init)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, mod.sh2Init)

local lightSprite = Sprite()
lightSprite:Load("gfx/007.005_lightbeam.anm2")
lightSprite:Play("LargeRedLaser")

function mod.addSampleToEntBeam(ent, posOverride, offsetOverride)
    local tearHash = GetPtrHash(ent)
    if not mod.TearLaserSamples[tearHash] then
        mod.TearLaserSamples[tearHash] = Beam(lightSprite, 1, false, true)
        mod.TearLaserSamplesPure[tearHash] = {}
    end
    local pos = posOverride or ent.Position
    if not posOverride and MattPack.Config.divineHeartResolution > 2 then
        pos = pos + (ent.Velocity * (MattPack.Config.divineHeartResolution / 2))
    end
    local offset = offsetOverride or (ent.PositionOffset * Vector.One)
    mod.TearLaserSamples[tearHash]:Add(Isaac.WorldToScreen(pos + offset), 32, .5)
    table.insert(mod.TearLaserSamplesPure[tearHash], {pos, offset})

end

function mod:sh2Update(tear)
    if tear.Type == 4 and not tear.IsFetus then
        return
    end
    local player = tear.SpawnerEntity and (tear.SpawnerEntity:ToPlayer())
    if tear.Type == 1000 then
        local markedTarget = player and player:GetMarkedTarget()
        if markedTarget and GetPtrHash(tear) == GetPtrHash(markedTarget) then
            return
        end
    end
    if (player and player:HasCollectible(MattPack.Items.DivineHeart)) or tear:GetData().divineHeartTear then
        -- Ludovico
        if tear.Type == 2 and tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
            if not player then
                player = tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player
            end
            tear.Color = sacredHeartColor
            local shootingVector = (player or Isaac.GetPlayer()):GetShootingJoystick ()
            if shootingVector.X == 0 and shootingVector.Y == 0 then
                local tearHash = GetPtrHash(tear)
                if mod.TearLaserSamples[tearHash] and not Game():IsPaused() then
                    mod:sh2Death(tear)
                end
                return
            end
        end

        if tear.Type == 2 then
            -- Kill if off screen
            local nextFramePos = tear.Position + tear.Velocity + tear.PositionOffset
            local isContinuum = tear:HasTearFlags(TearFlags.TEAR_CONTINUUM)
            local margin = -100
            if isContinuum then
                margin = -100
            end
    
            local clampedPos = game:GetRoom():GetClampedPosition(nextFramePos, margin)
            if clampedPos:Distance(nextFramePos) > 0 then
                if tear:HasTearFlags(TearFlags.TEAR_CONTINUUM) then
                    mod:sh2Death(tear)
                else
                    tear:Die()
                end
                return
            end
        end

        -- Add samples
        local res = mod.Config.divineHeartResolution or 2
        if tear.FrameCount % res == 0 then
            mod.addSampleToEntBeam(tear)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.sh2Update)
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.sh2Update)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.sh2Update, 30)

function mod:sh2UpdateKnife(ent)
    if MattPack.isNormalRender() then
        local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
        if (player and player:HasCollectible(MattPack.Items.DivineHeart)) or ent:GetData().divineHeartTear then
            if ent:IsFlying() then
                local res = mod.Config.divineHeartResolution or 2
                if ent.FrameCount % res == 0 then
                    mod.addSampleToEntBeam(ent)
                end
            else
                if ent.SubType == 0 then
                    local sprite = ent:GetSprite()
                    local anim = sprite:GetAnimation()

    
                    local data = ent:GetData()
                    local isSwinging = ent:GetIsSwinging()
                    if isSwinging or (data.lastPercentDone and data.lastPercentDone < 1) then
                        local isSpin = anim:sub(1, 4) == "Spin"
        

                        local attackVector = Vector.FromAngle(ent.Rotation)
        
                        local animData = sprite:GetCurrentAnimationData()
                        local length = animData:GetLength()
                        if ent.Variant == 1 or ent.Variant == 2 or ent.Variant == 3 then
                            length = 9
                        end
                        local lastPercent = data.lastPercent or 0
                        local percentDone = (sprite:GetFrame() - 1) / (length - 2)
                        if not isSwinging and (data.lastPercentDone and data.lastPercentChange) then
                            percentDone = data.lastPercentDone + (data.lastPercentChange or 0)
                            if percentDone >= 1 then
                                data.lastPercentDone = nil
                            end
                        else
                            data.lastPercentDone = percentDone
                        end
                        data.lastPercent = percentDone

                        if data.lastPercent > 1 and percentDone >= 1 then -- for ones witht custom length ogh
                            goto kill
                        end

                        local spinStartOffset = -45
                        local spinAngleTarget = 90
                        local range = player.TearRange / 4
                        if isSpin then
                            spinStartOffset = 0
                            spinAngleTarget = 360 * 3
                            range = (range) * (.5 + (percentDone))
                        end
                        data.lastPercentChange = percentDone - lastPercent
                        
                        local samplePos = ent.Position + attackVector:Resized(range):Rotated(spinStartOffset + (spinAngleTarget * percentDone))
                        if (not (data.lastSamplePos and (data.lastSamplePos + player.Velocity):Distance(samplePos) <= 1)) then
                            mod.addSampleToEntBeam(ent, samplePos)
                            local extraSamples = 1
                            if isSpin then
                                extraSamples = 2
                            end
                            if isSwinging then
                                for i = 1, extraSamples do
                                    local frameFraction = sprite:GetFrame() + (1 / (extraSamples + 1)) * i
                                    local percentDone2 = (frameFraction - 1) / (length - 2)
                                    local samplePos2 = ent.Position + attackVector:Resized(range):Rotated(spinStartOffset + (spinAngleTarget * percentDone2))
                                    mod.addSampleToEntBeam(ent, samplePos2)
                                end
                            end
                            data.lastSamplePos = samplePos
                        end
                        return
                    end
                    ::kill::
                    mod:sh2Death(ent)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, mod.sh2UpdateKnife)

function mod:sh2UpdateLaser(tear)
    if tear:IsCircleLaser() then
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if (player and player:HasCollectible(MattPack.Items.DivineHeart)) or tear:GetData().divineHeartTear then
            local homingMulti = 1
            local isLudo = tear.SubType == 1
            if isLudo then
                homingMulti = 0
                tear.Color = sacredHeartLaserColor
                local shootingVector = player:GetShootingJoystick ()
                if shootingVector.X == 0 and shootingVector.Y == 0 then
                    local tearHash = GetPtrHash(tear)
                    if mod.TearLaserSamples[tearHash] and not Game():IsPaused() then
                        mod:sh2Death(tear)
                    end
                    return
                end
            end
            local homingTargets = Isaac.GetRoomEntities()
            
            local closestThisFrame = {tear.Position, 0}
            local spaceDistance = tear.Radius + tear.Size
            
            local framesForLoop = tear.Radius / 2.5

            framesForLoop = math.max(framesForLoop, 1)
            local startPos = tear.Position + tear.Velocity:Resized(tear.Radius):Rotated(((tear.FrameCount % framesForLoop) / framesForLoop) * 360)
            if not isLudo then
                for _,ent in ipairs(homingTargets) do
                    local npc = ent:ToNPC()
                    if npc and npc:IsVulnerableEnemy() and (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false) then
                        local targetPos = npc.Position + (tear.Position - npc.Position):Resized(spaceDistance)
                        local lineToNPC = targetPos - tear.Position
                        local startDist = 250 * (tear.Size / 5)
                        local ratio = math.max(0, (1 - lineToNPC:Length() / startDist)) * homingMulti
                        
                        if (not closestThisFrame) or (closestThisFrame[2] < (1 - lineToNPC:Length() / spaceDistance)) then
                            closestThisFrame = {ent.Position, (1 - lineToNPC:Length() / spaceDistance)}
                        end
                        
                        tear.Velocity = Lerp(tear.Velocity, lineToNPC:Resized(tear.Velocity:Length()), ratio / 10):Resized(tear.Velocity:Length())
                    end
                end
            end
            local res = mod.Config.divineHeartResolution or 2
            if tear.FrameCount % res == 0 then
                mod.addSampleToEntBeam(tear, Lerp(startPos, closestThisFrame[1], closestThisFrame[2]))
            end    
        end    
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_UPDATE, mod.sh2UpdateLaser)

mod.sh2BeamBeams = {}
function mod:sh2Death(tear)
    local tearHash = GetPtrHash(tear)
    if mod.TearLaserSamples[tearHash] and not Game():IsPaused() then
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() or Isaac.GetPlayer()
        
        if tear.Type == 4 then
            local toPlayer = player.Position - tear.Position
            for i = 20, math.ceil(toPlayer:Length()), 20 do
                mod.addSampleToEntBeam(tear, tear.Position + toPlayer:Resized(i))
            end
        end
        
        local firstLaser
        local lastPos
        local samples = mod.TearLaserSamplesPure[tearHash]
        local laserResolutionDivision = mod.divineHeartFunctionalResolution

        local setDmg = tear.CollisionDamage / 4
        if setDmg == 0 then
            setDmg = player.Damage / 3
        end
        local beam = mod.TearLaserSamples[tearHash]
        local brimCount = player and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE)
        local timeout = 15
        local scale = 1
        if brimCount > 0 then
            timeout = timeout * 3
            if brimCount == 1 then
                scale = 1.25
            else
                scale = 1.5
            end
        end
        for i,data in ipairs(samples) do
            local pos = data[1]
            local isLast = i == #samples
            if i % laserResolutionDivision == 0 or isLast then
                if lastPos then
                    local laser = Isaac.Spawn(7, 5, 1415, lastPos, Vector.Zero, player):ToLaser()
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
                        if math.random(1, 4) == 1 then
                            local closestEnemy = nil
                            local range = 40
                            for _,ent in ipairs(Isaac.FindInRadius(lastPos, range, EntityPartition.ENEMY)) do
                                if not closestEnemy or (closestEnemy.Position:Distance(lastPos) > ent.Position:Distance(lastPos)) then
                                    closestEnemy = ent
                                end
                            end
                            local toEnemy = (closestEnemy and (closestEnemy.Position - lastPos)) or RandomVector():Resized(range * (math.random(5, 10) / 10))
                            local laser2 = EntityLaser.ShootAngle(2, lastPos, (toEnemy):GetAngleDegrees(), 10, data[2], player)
                            laser2.DisableFollowParent = true
                            laser2.CollisionDamage = setDmg / 2
                            laser2.MaxDistance = toEnemy:Length()
                        end
                    end
                    if not firstLaser then
                        firstLaser = laser
                    end
                    laser.Angle = (pos - lastPos):GetAngleDegrees()
                    local multi = 1 / laserResolutionDivision -- i don't actually know if this is correct but it's probably fine
                    if not isLast then
                        multi = laserResolutionDivision
                    end
                    local dist = pos:Distance(lastPos) * multi
                    laser.MaxDistance = dist
                    laser.Timeout = timeout
                    laser:SetScale(scale)
                    laser.OneHit = false
                    laser.CollisionDamage = setDmg
                    laser.Color = Color(0,0,0,.1,1,1,1)
                    local laserSprite = laser:GetSprite()
                    laserSprite:ReplaceSpritesheet(0, "", true) -- yeah
                end
            end
            lastPos = pos
        end
        if firstLaser then
            local brimSwirlSprite = Sprite()
            brimSwirlSprite:Load("gfx/1000.071_brimstoneswirl.anm2")
            brimSwirlSprite:Play("IdleQuick")
            brimSwirlSprite:SetFrame(15)
            brimSwirlSprite.Scale = Vector.One * .2 * (scale * 1.66)
            brimSwirlSprite.PlaybackSpeed = .35 * (15 / timeout)
            brimSwirlSprite.Rotation = math.random(0, 360)
            
            if brimCount > 0 then
                beam:GetSprite():Load("gfx/007.001_thick red laser.anm2", true)
                beam:GetSprite():Play("LargeRedLaser")
            end
            mod.sh2BeamBeams[firstLaser] = {beam, brimSwirlSprite, mod.TearLaserSamplesPure[tearHash]}
            mod.TearLaserSamples[tearHash] = nil
            
            sfx:Play(SoundEffect.SOUND_LIGHTBOLT, .9, nil, nil, math.random(95, 105) / 100)
            sfx:Play(SoundEffect.SOUND_ANGEL_BEAM, .4, nil, nil, math.random(125, 130) / 100)
            if brimCount > 0 then
                if brimCount == 1 then
                    sfx:Play(SoundEffect.SOUND_BLOOD_LASER, .75, nil, nil, math.random(100, 115) / 100)
                else
                    sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER, 1, nil, nil, math.random(100, 115) / 100)
                end
            end

        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.sh2Death)

function mod:sh2LightUpdate(ent)
    local parent = ent.Parent
    if parent and parent.Type == 7 and parent.SubType == 1415 then
        local data = ent:GetData()
        if not data.origSpriteScale then
            data.origSpriteScale = ent.SpriteScale
        end
        local scaleX = math.min(1, parent.SpriteScale.X)
        if data.fadeBothAxes then
            ent.SpriteScale = scaleX * data.origSpriteScale
        else
            ent.SpriteScale = Vector(scaleX, 1) * data.origSpriteScale
        end
        if parent.SpriteScale.X < .25 then
            ent:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.sh2LightUpdate, 121)

function mod:sh2LaserRender()
    if MattPack.isNormalRender(true) then
        local toClear = {}
        for laser,data in pairs(mod.sh2BeamBeams) do
            local beam = data[1]
            local swirlSprite = data[2]
            local purePos = data[3]
            if laser and laser:Exists() then
                local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
                local brimCount = player and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE)
                local points = beam:GetPoints()
                local color = Color(.2,.4,.66,.75,1,1.5,1.5)
                swirlSprite.Color = color
                if brimCount > 0 then
                    color = sacredHeartLaserColor
                    swirlSprite.Color = sacredHeartLaserColor
                end
                beam:GetSprite().Offset = Vector(250,250)
                local minWidth = 32
                local maxWidth = 34
                if brimCount > 0 then
                    if brimCount == 1 then
                        minWidth = 42
                        maxWidth = 57
                    else
                        minWidth = 39
                        maxWidth = 65
                    end
                end
                for i,point in ipairs(points) do
                    local width = laser.SpriteScale.X * (math.random(minWidth, maxWidth) / 100)
                    point:SetColor(color)
                    point:SetWidth(width)
                    local curPurePos = purePos and purePos[i]
                    if curPurePos then
                        local pos = (Isaac.WorldToScreen(curPurePos[1] + curPurePos[2]))
                        if game:GetRoom():IsMirrorWorld() then
                            pos = Vector(-pos.X, pos.Y) + Vector(Isaac.GetScreenWidth(), 0)
                        end
                        point:SetPosition(pos)
                    end
                    local pos = point:GetPosition()
                    if i == 1 or i == #points then
                        swirlSprite:Render(pos)
                        if MattPack.isNormalRender() then
                            swirlSprite:Update()
                        end
                    end
                end
                beam:SetPoints(points)
                beam:Render(false)
            else
                table.insert(toClear, laser)
            end
        end
        for _,index in ipairs(toClear) do
            mod.sh2BeamBeams[index] = nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.sh2LaserRender)

function mod:sh2TearTrailRender(tear)
    if MattPack.isNormalRender(true) then
        local hash = GetPtrHash(tear)
        local beam = hash and mod.TearLaserSamples[hash]
        if beam then
            local points = beam:GetPoints()
            if #points > 1 then
                local purePos = mod.TearLaserSamplesPure[hash]
                for i,point in ipairs(points) do
                    local curPurePos = purePos and purePos[i]
                    if curPurePos then
                        point:SetPosition(Isaac.WorldToScreen(curPurePos[1] + curPurePos[2]))
                    end
                    local color = Color(0,0,0,1,1,1,1)
                    color.A = math.random(10, 30) / 100
                    point:SetColor(color)
                    local width = math.random(18, 22) / 100
                    if i <= 2 then
                        width = width * (i - 1) / 2
                    end
                    point:SetWidth(width)
                end
                beam:SetPoints(points)
                beam:Render(false)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, mod.sh2TearTrailRender)
mod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, mod.sh2TearTrailRender)
mod:AddCallback(ModCallbacks.MC_PRE_BOMB_RENDER, mod.sh2TearTrailRender)
mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_RENDER, mod.sh2TearTrailRender)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.sh2TearTrailRender, 30)

function mod:sh2Rmv(tear)
    local tearHash = GetPtrHash(tear)
    if mod.TearLaserSamples[tearHash] then
        mod.TearLaserSamples[tearHash] = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.sh2Rmv, 2)

function mod:clearLists()
    mod.TearLaserSamples = {}
    mod.sh2BeamBeams = {}
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.clearLists)

local eyeOffsets = {
    [Direction.LEFT] = Vector(-15, -1),
    [Direction.RIGHT] = Vector(15, -1)
}

for i = 1, 2 do
    local eyeShineSprite1 = Sprite()
    eyeShineSprite1:Load("gfx/eyelights.anm2")
    eyeShineSprite1:Play("Shine1", true)
    eyeShineSprite1.Rotation = math.random(1, 360)
    local eyeShineSprite2 = Sprite()
    eyeShineSprite2:Load("gfx/eyelights.anm2")
    eyeShineSprite2:Play("Shine2", true)
    eyeShineSprite2.Rotation = math.random(1, 360)
    local eyeShineSprite3 = Sprite()
    eyeShineSprite3:Load("gfx/eyelights.anm2")
    eyeShineSprite3:Play("Shine3", true)
    eyeShineSprite3.Rotation = math.random(1, 360)
    local eyeShineSprite4 = Sprite()
    eyeShineSprite4:Load("gfx/eyelights.anm2")
    eyeShineSprite4:Play("Shine4", true)
    eyeShineSprite4.Rotation = math.random(1, 360)

    eyeShineSprite1.Color = Color(1,1,1,.75)
    eyeShineSprite2.Color = Color(1,1,1,.9)
    eyeShineSprite3.Color = Color(1,1,1,.85)
    eyeShineSprite4.Color = Color(1,1,1,.8)

    local offset1 = math.random(15, 30) / 100
    local offset2 = math.random(15, 30) / 100
    local offset3 = math.random(15, 30) / 100
    local offset4 = math.random(15, 30) / 100

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(mod)
        offset1 = math.random(15, 30) / 100
        offset2 = math.random(15, 30) / 100
        offset3 = math.random(15, 30) / 100
        offset4 = math.random(15, 30) / 100
    end)

    local multi = (i == 1 and - 1) or 1
    local multi2 = ((math.random(1, 2) == 1 and -1) or 1) * 2
    function mod:renderEyes(player, offset)
        if player:HasCollectible(MattPack.Items.DivineHeart) and player:IsExtraAnimationFinished() and MattPack.isNormalRender(true) then
            local headDir = player:GetHeadDirection()
            local pos = offset + Isaac.WorldToRenderPosition(player.Position + (eyeOffsets[headDir] or Vector.Zero))
            local eyePos = pos + Isaac.WorldToScreenDistance(Vector(multi * -10.5, -27)) + player:GetFlyingOffset()
            local sprite = player:GetSprite()
            if headDir == Direction.DOWN or (i == 1 and headDir == Direction.LEFT) or (i == 2 and headDir == Direction.RIGHT) then
                if sprite:GetOverlayFrame() ~= 2 then
                    eyeShineSprite1:Render(eyePos)
                    eyeShineSprite1.Rotation = eyeShineSprite1.Rotation + offset1 * multi * multi2
                    
                    eyeShineSprite2:Render(eyePos)
                    eyeShineSprite2.Rotation = eyeShineSprite2.Rotation - offset2 * multi * multi2
                    
                    eyeShineSprite3:Render(eyePos)
                    eyeShineSprite3.Rotation = eyeShineSprite3.Rotation + offset3 * multi * multi2
                    
                    eyeShineSprite4:Render(eyePos)
                    eyeShineSprite4.Rotation = eyeShineSprite4.Rotation - offset4 * multi * multi2
                end
            end
        end
    end
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.renderEyes)
end

local divineHeartChargeBar = Sprite()
divineHeartChargeBar:Load("gfx/chargebar.anm2", true)
divineHeartChargeBar.PlaybackSpeed = 2

local eternalHeartSprite = Sprite()
eternalHeartSprite:Load("gfx/005.014_heart (eternal).anm2", true)
eternalHeartSprite:Play("Idle", true)

function mod:sacrificeEternalHeart(player)
    mod.CancelDrop = false
    local sacredHearts = Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_SACRED_HEART)
    if #sacredHearts > 0 and player:GetEternalHearts() > 0 then
        if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
            mod.CancelDrop = true
            mod.chargePercent = (mod.chargePercent or 0) + .003
            local heldSprite = player:GetHeldSprite()
            if not player:IsHoldingItem() then
                player:AnimatePickup(eternalHeartSprite, false, "LiftItem")
            else
                heldSprite.PlaybackSpeed = (mod.chargePercent * 4)
                local delay = math.ceil(14 / heldSprite.PlaybackSpeed)
                if delay < 8 then
                    sfx:Play(SoundEffect.SOUND_HEARTBEAT_FASTEST, nil, delay)
                elseif delay < 16 then
                    sfx:Play(SoundEffect.SOUND_HEARTBEAT_FASTER, nil, delay)
                else
                    sfx:Play(SoundEffect.SOUND_HEARTBEAT, nil, delay)
                end
            end
            if mod.chargePercent < 1 then
                divineHeartChargeBar:SetFrame("Charging", math.ceil(mod.chargePercent * 100))
            else
                divineHeartChargeBar:Play("Disappear", false)
                divineHeartChargeBar:Update()
                if divineHeartChargeBar:IsFinished() then
                    mod.CancelDrop = nil
                    mod.chargePercent = nil
                    player:AddEternalHearts(-1)
                    player:PlayExtraAnimation("HideItem")
                    for _,item in ipairs(sacredHearts) do
                        local light = Isaac.Spawn(1000, 19, 0, item.Position, Vector.Zero, nil)
                        light.DepthOffset = 500
                        light.Color = Color(1,1,1,2)
                        Isaac.CreateTimer(function()
                            item:ToPickup():Morph(5, 100, MattPack.Items.DivineHeart)
                        end, 4, 0)
                        sfx:Play(SoundEffect.SOUND_ANGEL_BEAM)
                        sfx:Play(SoundEffect.SOUND_HOLY, nil, nil, nil, .75)
                    end
                    heldSprite.Color = Color(0,0,0,0)
                    local blood = Isaac.Spawn(1000, 2, 0, player.Position, Vector.Zero, nil)
                    blood.Color = Color(1,1,1,1,.825,.8,.85,1,1,1,1)
                    blood.SpriteOffset = Vector(0, -40)
                    sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
                end
            end
            divineHeartChargeBar:Render(Isaac.WorldToRenderPosition(player.Position + Vector(0, -80) * player.SpriteScale))
        else
            if mod.chargePercent then
                player:PlayExtraAnimation("HideItem")
            end
            mod.CancelDrop = nil
            mod.chargePercent = nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.sacrificeEternalHeart)

function mod:cancelDrop(_, _, btact)
    if mod.CancelDrop and btact == ButtonAction.ACTION_DROP then
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod.cancelDrop, InputHook.IS_ACTION_PRESSED)
