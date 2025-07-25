local mod = MattPack
-- local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.TechOmega, "Instead of tears, Isaac fires a wide, continuous, low-damage laser beam#Enemies hit by the the player's lasers will have their \"tech charge\" increased#Once an enemy's tech charge is full, 4 limited-range, half-damage lasers will burst out of them in an X shape")

    -- Synergies
    mod.addSynergyDescription(MattPack.Items.TechOmega, 
    CollectibleType.COLLECTIBLE_TECH_X, 
    "Tech rings are shot as normal, but deal half damage and increase enemies' tech charge")

    mod.addSynergyDescription(MattPack.Items.TechOmega, 
    CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE, 
    "Isaac controls a large, low damage laser ring that increases enemies' tech charge on hit")

    mod.addSynergyDescription(MattPack.Items.TechOmega, 
    CollectibleType.COLLECTIBLE_BRIMSTONE, 
    "Burst lasers are replaced with long-lasting Brimstone lasers")

    mod.addSynergyDescription(MattPack.Items.TechOmega, 
    CollectibleType.COLLECTIBLE_MOMS_KNIFE, 
    "Upon bursting into lasers, enemies will also shoot out slow-moving knives that deal x2.5 Isaac's damage")

    -- Multishots
    for i,list in ipairs({mod.multishotPlayersList, mod.multishotsList}) do
        for id,amt in pairs(list) do
            local plurality = "lasers"
            if amt <= 2 then
                plurality = 'laser'
            end
            local string = "Enemies will burst into " .. (amt - 1) .. " more " .. plurality
            if i == 1 then
                mod.addSynergyDescription(MattPack.Items.TechOmega, id, string, nil, true)
            else
                mod.addSynergyDescription(MattPack.Items.TechOmega, id, string, nil, nil, true)
            end
        end
    end
end

mod.areLasersFired = false
function mod:clearLasersFired()
    mod.areLasersFired = false
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.clearLasersFired)

local blockCollectibles = {
    CollectibleType.COLLECTIBLE_CRICKETS_BODY,
    -- CollectibleType.COLLECTIBLE_MOMS_KNIFE
}


local bannedTearFlags = {
        TearFlags.TEAR_SLOW,
        TearFlags.TEAR_POISON,
        TearFlags.TEAR_FREEZE,
        TearFlags.TEAR_MULLIGAN,
        TearFlags.TEAR_EXPLOSIVE,
        TearFlags.TEAR_CHARM,
        TearFlags.TEAR_CONFUSION,
        TearFlags.TEAR_QUADSPLIT,
        TearFlags.TEAR_FEAR,
        TearFlags.TEAR_BURN,
        TearFlags.TEAR_KNOCKBACK,
        TearFlags.TEAR_GISH,
        TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,
        TearFlags.TEAR_LIGHT_FROM_HEAVEN,
        TearFlags.TEAR_COIN_DROP,
        TearFlags.TEAR_GODS_FLESH,
        TearFlags.TEAR_GREED_COIN,
        TearFlags.TEAR_PERMANENT_CONFUSION,
        TearFlags.TEAR_BOOGER,
        TearFlags.TEAR_EGG,
        TearFlags.TEAR_MIDAS,
        TearFlags.TEAR_NEEDLE,
        -- TearFlags.TEAR_JACOBS,
        TearFlags.TEAR_HORN,
        TearFlags.TEAR_POP,
        TearFlags.TEAR_ABSORB,
        TearFlags.TEAR_PUNCH,
        TearFlags.TEAR_ICE,
        TearFlags.TEAR_MAGNETIZE,
        TearFlags.TEAR_BAIT,
        TearFlags.TEAR_ECOLI,
        TearFlags.TEAR_RIFT,
        TearFlags.TEAR_SPORE,
        TearFlags.TEAR_TELEPORT
}
local banFlagBitmask = TearFlags.TEAR_SLOW
for _,i in ipairs(bannedTearFlags) do
    banFlagBitmask = banFlagBitmask | i
end

function mod:techOUpdate(player)
    if player:HasCollectible(MattPack.Items.TechOmega) then
        local data = player:GetData()

        for _,item in ipairs(blockCollectibles) do
            player:BlockCollectible(item)
        end
    
        local weapon = player:GetWeapon(1)
        
        if not (player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)) then
            player:EnableWeaponType(WeaponType.WEAPON_LASER, true)
            if weapon then
                if weapon:GetModifiers() & WeaponModifier.MONSTROS_LUNG == 0 or weapon:GetModifiers() & WeaponModifier.C_SECTION ~= 0 then
                    weapon:SetCharge(0)
                end
            end
            player.FireDelay = 2
            local shootingDir = player:GetShootingJoystick()
            local markedTarget = player:GetMarkedTarget ()
            if markedTarget then
                shootingDir = (markedTarget.Position - player.Position):Normalized()
            elseif Options.MouseControl and Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_1) then
                shootingDir = (Input.GetMousePosition(true) - player.Position):Normalized()
            end
            if (shootingDir:Length() > 0) and player:IsDead() == false and (player:CanShoot() or player:GetPlayerType() == PlayerType.PLAYER_LILITH) then
                for _,desc in ipairs(player:GetCostumeSpriteDescs()) do
                    local sprite = desc:GetSprite()
                    if sprite:GetAnimation():sub(0, 4) == "Head" then
                        sprite:SetFrame(2)
                    end
                end
                local laser
                if not data.techOLaser or data.techOLaser:Exists() == false then
                    sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_STRONG, 0, 10)
                    laser = player:FireTechLaser(player.Position, LaserOffset.LASER_MOMS_EYE_OFFSET, player:GetShootingJoystick(), false, false, player, .05)
                    local laserData = laser:GetData()
                    laserData.isTechO = true
                    laserData.isTechOMain = true
                    laserData.skipBloatedBody = true
                    laser.Timeout = 12
                    laser.DisableFollowParent = false
                    data.techOLaser = laser
                    local color = laser.Color
                    color.A = 2/3
                    laser.Color = color
                    laser:GetSprite().PlaybackSpeed = .5
                    laser:SetScale(5)
                    laser.GridCollisionClass = GridCollisionClass.COLLISION_WALL
                    if shootingDir.Y == -1 then
                        laser:GetData().addOffset = Vector(0, 8 * player.SpriteScale.Y)
                    else
                        laser:GetData().addOffset = nil
                    end
                else
                    laser = data.techOLaser:ToLaser()
                    laser.Timeout = 12
                    local angleDiff = math.abs(shootingDir:GetAngleDegrees() - laser.Angle)
                    local lerpIntensity = .15 * math.max(1, 1 + (angleDiff - 90) / 90)
                    laser.Angle = Lerp(Vector.FromAngle(laser.Angle), shootingDir + player:GetTearMovementInheritance(shootingDir) / 50, lerpIntensity):GetAngleDegrees() + math.random(-1, 1) / 5
                    laser.ParentOffset = Lerp(laser.ParentOffset, player:GetLaserOffset(LaserOffset.LASER_MOMS_EYE_OFFSET, shootingDir) + (laser:GetData().addOffset or Vector.Zero), .25) + Vector(0, 6.5 * player.SpriteScale.Y)
                    laser.DepthOffset = Lerp(-10, 3000, shootingDir.Y)
                end
                if laser then
                    laser:ClearTearFlags(TearFlags.TEAR_QUADSPLIT)
                    laser.Mass = 0
                end
            else
                if data.techOLaser then
                    data.techOLaser:Die()
                    data.techOLaser = nil
                end
            end
        end
    elseif sfx:IsPlaying(MattPack.Sounds.TechOmegaLoop) then
        sfx:Stop(MattPack.Sounds.TechOmegaLoop)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.techOUpdate)

function mod:undoTechOBlock(player)
    for _,item in ipairs(blockCollectibles) do
        player:UnblockCollectible(item)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, mod.undoTechOBlock, MattPack.Items.TechOmega)

function mod:nonTechOLasers(ent)
    local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(MattPack.Items.TechOmega) then
        if (not ent:GetData().isTechO) and (not ent:GetData().isTech5090) and ent:GetDamageMultiplier() >= .1 then
            if ent.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO then
                ent.CollisionDamage = ent.CollisionDamage * .15 -- i wonder why damage multiplier doesn't work
                if ent.Variant == 2 then
                    ent:SetScale(3)
                end
            else
                ent:SetDamageMultiplier(.5)
            end
            if not ent:GetData().techOInitDone then
                ent.Velocity = ent.Velocity / 2
                if ent.Timeout > 0 then
                    ent.Timeout = math.ceil(ent.Timeout * 2.5)
                end
                ent:GetData().techOInitDone = true
            end
            local color = ent.Color
            color.A = math.min(color.A, 2/3)
            ent.Color = color
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_UPDATE, mod.nonTechOLasers)

function mod:techOSFX(player)
    if player:HasCollectible(MattPack.Items.TechOmega) then
        local targetPitch = 2.25
        local data = player:GetData()
        local isPlaying = sfx:IsPlaying(MattPack.Sounds.TechOmegaLoop)

        if not data.techOLaser or data.techOLaser:Exists() == false then
            if isPlaying then
                data.omegaPitch = (data.omegaPitch or targetPitch) - .05
                if data.omegaPitch <= 0 then
                    data.omegaPitch = nil
                    sfx:Stop(MattPack.Sounds.TechOmegaLoop)
                else
                    sfx:AdjustPitch(MattPack.Sounds.TechOmegaLoop, data.omegaPitch)
                    sfx:AdjustVolume(MattPack.Sounds.TechOmegaLoop, data.omegaPitch / targetPitch * .75)
                end
            end
        else
            if not isPlaying then
                sfx:Play(MattPack.Sounds.TechOmegaLoop, .075, nil, true)
            end
            if data.omegaPitch or 0 <= targetPitch then
                data.omegaPitch = math.min(targetPitch, (data.omegaPitch or 0) + .15)
                sfx:AdjustPitch(MattPack.Sounds.TechOmegaLoop, data.omegaPitch)
                sfx:AdjustVolume(MattPack.Sounds.TechOmegaLoop, data.omegaPitch / targetPitch * .75)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.techOSFX)

mod.maxOmegaCharge = 15
mod.sublaserDmgMulti = .5

function mod.burstLasers(target, player, laser, isDead)
    local startingAngle = math.random(-75, 75) / 10
    local multi = 1
    local staticCharge = target:GetData().staticCharge or 0
    if isDead then
        multi = math.min(1, staticCharge / mod.maxOmegaCharge)
    else
        if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
            local timeToFall = 10
            local marker = Isaac.Spawn(1000, 30, 0, target.Position, Vector.Zero, player):ToEffect()
            marker.Timeout = timeToFall
            local rocket = Isaac.Spawn(1000, 31, 0, target.Position, Vector.Zero, player):ToEffect()
            rocket.Timeout = timeToFall
            rocket:Update()
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY, nil, true) then
        multi = multi * 1.5
    end
    local lasersAmt = 4
    local multishotParams = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)
    lasersAmt = lasersAmt + (multishotParams:GetNumTears() - 1) + (player:GetCollectibleNum(MattPack.Items.TechOmega) - 1)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE) and math.random(1,3) == 1 then
        lasersAmt = lasersAmt + 1
    end
    if player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_BOOK_WORM) >= 3 and math.random(1,4) == 1 then
        lasersAmt = lasersAmt + 1
    end
    for i = 0, lasersAmt - 1 do
        local timeout = 10
        local laser2
        local scale = 2

        local angleDiff = 360 / lasersAmt
        
        local angle = Vector(1, 1):Rotated(angleDiff * i + startingAngle)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) then
            angle = angle + Vector.FromAngle(math.random(-5, 5))
        end

        if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
            laser2 = player:FireBrimstone(Vector(1, 1):Rotated(90 * i + startingAngle), player, mod.sublaserDmgMulti * multi)
            timeout = 25
            scale = .75
        else
            laser2 = player:FireTechLaser(target.Position, LaserOffset.LASER_TRACTOR_BEAM_OFFSET, angle, false, false, player, mod.sublaserDmgMulti * multi)
        end
        local data = laser2:GetData()
        laser2.DisableFollowParent = true
        data.isTechO = true
        laser2.Position = target.Position
        laser2.ParentOffset = Vector.Zero
        laser2:SetScale(scale * ((multi + 1) / 2))
        laser2.OneHit = false
        laser2.Timeout = timeout
        data.spawnerPointer = target
        data.spawnerHash = GetPtrHash(target)
        if (laser and laser:HasTearFlags(TearFlags.TEAR_CONTINUUM)) or player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
            laser2.MaxDistance = -1
        else
            laser2.MaxDistance = player.TearRange / 3.25 + 12.5
        end
        laser2:ClearTearFlags(TearFlags.TEAR_JACOBS)
        laser2:Update()
        laser2:ForceCollide(target)
        
        local endpoint = laser2.Position + angle:Resized(laser2.MaxDistance + 15)
        if not isDead then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
                local bomb = player:FireBomb(target.Position, angle:Rotated(math.random(-75, 75) / 10):Resized(1.55), player)
                bomb:AddTearFlags(TearFlags.TEAR_PIERCING)
                bomb:SetScale(.5)
                bomb:SetHeight(-7.5)
                bomb.ExplosionDamage = bomb.ExplosionDamage / 2
                bomb.RadiusMultiplier = bomb.RadiusMultiplier / 1.15
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE, nil, true) then
                local knife = mod.fireKnifeProjectile(player, target.Position, angle:Resized(15), 0, -.05, player.Damage * 2.5, target)
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
                Isaac.Spawn(1000, 2, 4, endpoint, Vector.Zero, nil)
                for i = 1, math.random(6, 11) do
                    local tear = player:FireTear(endpoint, RandomVector():Resized(math.random(3, 6)), true, true, false, player, math.random(50, 83) / 300)
                    tear:ClearTearFlags(TearFlags.TEAR_BURSTSPLIT)
                    tear.Scale = tear.Scale - .5
                end
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION, nil, true) then
                local tear = player:FireTear(target.Position + angle:Resized(target.Size / 2), angle:Resized(math.random(3, 6)), true, true, false, player, mod.sublaserDmgMulti)
                tear:AddTearFlags(TearFlags.TEAR_FETUS)
                if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
                    tear:AddTearFlags(TearFlags.TEAR_FETUS_KNIFE)
                end
                if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
                    tear:AddTearFlags(TearFlags.TEAR_FETUS_SWORD)
                end
                tear:ChangeVariant(50)
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY, nil, true) then
                for i = 0, 3 do
                    local rotAmt = 30
                    local laser3 = player:FireTechLaser(endpoint, LaserOffset.LASER_TRACTOR_BEAM_OFFSET, angle:Rotated(i * 67.5 - 90), false, false, player, mod.sublaserDmgMulti * 2/3)
                    laser3.TearFlags = TearFlags.TEAR_NORMAL
                    laser3.MaxDistance = laser2.MaxDistance / 2
                    laser3.Position = endpoint
                    laser3.PositionOffset = laser2.PositionOffset
                    laser3:GetData().dontCharge = true
                end
            end
        end
        mod.areLasersFired = true
    end
    target:GetData().staticCharge = 0
end

mod.TechOChargeMultipliers = {
    [CollectibleType.COLLECTIBLE_EPIC_FETUS] = .55
}

function mod:techOLaserUpdate(laser, col)
    local player = (laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()) or Isaac.GetPlayer()
    if player:HasCollectible(MattPack.Items.TechOmega) and 
    (col:IsActiveEnemy() and not col:IsInvincible()) and 
    not mod.areLasersFired 
    and laser.Variant ~= 10 then
        local data = laser:GetData()
        local applyTearFlags = nil
        if not data.dontCharge and (not (data.spawnerHash and data.spawnerHash == GetPtrHash(col))) and not (data.spawnerPointer and data.spawnerPointer:HasCommonParentWithEntity(col)) then
            col:GetData().chargeApplyPlayer = player
            local staticCharge = col:GetData().staticCharge or 0
            local defaultChargeAmt = 1

            local additionalMulti = 1
            for item,multi in pairs(mod.TechOChargeMultipliers) do
                if player:HasCollectible(item) and multi < additionalMulti then
                    additionalMulti = multi
                end
            end
            local chargeSpeedMulti = defaultChargeAmt / math.min((player.MaxFireDelay / 10 + .25) / 1.25, ((player.MaxFireDelay / 10 + 2) / 3)) * additionalMulti
            staticCharge = staticCharge + chargeSpeedMulti
            if math.random(0, math.max(10, math.floor(1 - staticCharge / mod.maxOmegaCharge * 100 + 100))) <= 10 then
                for i = 0, math.random(0, 3) do
                    local particle = Isaac.Spawn(1000, 66, 0, col.Position + RandomVector():Resized(math.random(0, math.floor(col.Size / 1.5))) + Vector(0, laser.PositionOffset.Y), col.Velocity + (Vector.FromAngle(laser.Angle + math.random(-45, 45))):Resized(math.random(5, 10)), nil)
                    particle.Color = Color(0,0,0,1,1,0,0)
                end
            end

            if laser:GetData().isTechO then
                if laser.Timeout > 0 and laser.Timeout < 10 and laser.FrameCount % 5 == 0 then
                    laser.Timeout = laser.Timeout + 1
                end
            end

            local maxCharge = mod.maxOmegaCharge

            if (staticCharge >= maxCharge) then
                for i = 0, math.random(5, 15) do
                    local particle = Isaac.Spawn(1000, 66, 0, col.Position + RandomVector():Resized(math.random(0, math.floor(col.Size / 1.5))) + Vector(0, laser.PositionOffset.Y), col.Velocity + RandomVector():Resized(math.random(5, 15)), nil)
                    particle.Color = Color(1,0,0,1)
                end
                mod.burstLasers(col, player, laser, false)
                applyTearFlags = true
            else
                col:GetData().staticCharge = staticCharge
            end
        elseif laser.FrameCount > 0 and laser.Variant == 2 then
            return true
        end
        if laser:GetData().isTechOMain and not applyTearFlags then
            laser:ClearTearFlags(banFlagBitmask)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, mod.techOLaserUpdate)

function mod:techDeathBurst(ent)
    if ent:GetData().staticCharge and ent:GetData().staticCharge >= mod.maxOmegaCharge / 3 then
        mod.burstLasers(ent, ent:GetData().chargeApplyPlayer or Isaac.GetPlayer(), nil, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.techDeathBurst)

function mod:techOChargeEffect(ent)
    local data = ent:GetData()
    if data.staticCharge and data.staticCharge > 0 then
        data.staticCharge = math.max(0, data.staticCharge - .15)
        local targetColor = Color(1,1,1,1)
        targetColor:SetColorize(1,0,0,1)
        targetColor:SetOffset(1,0,0,1)
        ent:SetColor(Color.Lerp(ent.Color, targetColor, (data.staticCharge / mod.maxOmegaCharge) * 1.5), 2, 99, true, false)
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.techOChargeEffect)




function mod:techOImpactInit(ent)
    if ent.SpawnerEntity and ent.SpawnerEntity:GetData().isTechOMain then
        ent.SpriteScale = Vector(3, .5)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.techOImpactInit)