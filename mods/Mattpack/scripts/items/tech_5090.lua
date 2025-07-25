local mod = MattPack
-- local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.Tech5090, "When moving, Isaac continuously fires out a laser in the direction he is walking#This laser will increase in range, width, and damage the longer Isaac is walking in a straight line, and quickly drains as he turns#The damage of the laser ranges from .5x Isaac's damage up to 5x#The laser will lightly repel enemy projectiles")
end

function mod:tech5090PlayerUpdate(player)
    if player:HasCollectible(MattPack.Items.Tech5090) then
        local data = player:GetData()
        local movementDir = player.Velocity
        local distance = player.Position:Distance(data.lastPos or player.Position)
        data.lastPos = player.Position
        if movementDir:Length() > .1 then
            if data.tech5090Laser and string.sub(data.tech5090Laser:GetSprite():GetAnimation(), -4, -1) == "Fade" then
                data.tech5090Laser:Remove()
                data.tech5090Laser = nil
            end
            if distance > 1 and ((not data.tech5090Laser) or (data.tech5090Laser:Exists() == false)) then
                local laser = player:FireTechLaser(player.Position, LaserOffset.LASER_MOMS_EYE_OFFSET, movementDir, false, false, player, .05)
                laser.Timeout = 2
                laser.DisableFollowParent = false
                laser.MaxDistance = 60
                laser:GetData().isTech5090 = true
                laser.PositionOffset = Vector(0, -10 * player.SpriteScale.X)
                data.tech5090Laser = laser
            end
        end
    elseif sfx:IsPlaying(MattPack.Sounds.Tech5090Loop) then
        sfx:Stop(MattPack.Sounds.Tech5090Loop)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.tech5090PlayerUpdate)

function mod:tech5090Render(ent)
    local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(MattPack.Items.Tech5090) then
        local data = ent:GetData()
        if data.isTech5090 then
            local laserAngle = Vector.FromAngle(ent.Angle)
            local playerAngle = player.Velocity:Normalized()
            if laserAngle:Distance(playerAngle) < 1.75 then
                ent.Angle = Lerp(laserAngle, playerAngle, .25):GetAngleDegrees()
            else
                ent:Die()
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, mod.tech5090Render)

function mod:tech5090Update(laser)
    local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
    local data = laser:GetData()
    if player and data.isTech5090 then
        if laser.Angle < 0 then
            laser.DepthOffset = -10
        else
            laser.DepthOffset = 3000
        end
        if not data.origScale then
            data.origScale = laser:GetScale()
        end
        local distance = (data.lastPos and (data.lastPos):Distance(player.Position))
        data.lastPos = player.Position
        local dmgMulti = laser:GetDamageMultiplier()
        if laser:IsDead() then
            laser:Remove()
        elseif (distance and distance > 1) then
            local laserAngle = Vector.FromAngle(laser.Angle)
            local movementDir = player.Velocity
            local percent = 1 - ((data.lastDir or movementDir):Normalized()):Distance(movementDir:Normalized())
            laser.Timeout = 4
            data.lastDir = movementDir
            laser.ParentOffset = Vector.Zero
            local amtToAdd = Lerp(-dmgMulti, .15, percent)
            dmgMulti = math.max(.5, math.min(5, dmgMulti + (amtToAdd * player.MoveSpeed)))
            if dmgMulti >= .5 then
                laser:SetDamageMultiplier(dmgMulti)
                
                laser.MaxDistance = 60 * ((dmgMulti + 5) / 6)
                laser:SetScale(((data.origScale) or 1) * (dmgMulti + 3 / 4))
                laser.Mass = 8 * (dmgMulti + 1) / 2
                
                local extendedMaxDistance = laser.MaxDistance + 20
                local centerPoint = laser.Position + laserAngle:Resized(extendedMaxDistance / 2)
                for _,ent in ipairs(Isaac.FindInRadius(centerPoint, extendedMaxDistance / 2, EntityPartition.BULLET)) do
                    ent.Velocity = ent.Velocity + laserAngle:Resized(2)
                end
            else
                laser:Die()
            end
            player:GetData().tech5090Percent = laser:GetDamageMultiplier()
                
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_UPDATE, mod.tech5090Update)

function mod:tech5090LaserCol(laser, col)
    if laser:GetData().isTech5090 then
        col:GetData().hitBy = laser
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, mod.tech5090LaserCol)

function mod:tech5090Explosion(ent, amt, flags, source, countdown)
    local src = source and source.Entity
    if ent and ent:GetData().hitBy then
        src = ent:GetData().hitBy
        ent:GetData().hitBy = nil
    end
    if src and src.Type == 7 then
        local player = ent and ent:ToPlayer()
        if src:GetData().isTech5090 then
            local dmg = amt
            local cd = countdown
            if player then
                player.Velocity = player:GetVelocityBeforeUpdate()
                return false
            else
                local spawnerPlayer = src.SpawnerEntity and src.SpawnerEntity:ToPlayer()
                if spawnerPlayer then
                    cd = cd * (spawnerPlayer.MaxFireDelay / 10)
                end
                if flags & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
                    dmg = amt / 10
                end
                return {Damage = dmg, DamageCountdown = cd}
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.tech5090Explosion)

function mod:tech5090Costume(player)
    if player:HasCollectible(MattPack.Items.Tech5090) then
        local data = player:GetData()
        local percent = data.tech5090Percent
        if percent then
            if not sfx:IsPlaying(MattPack.Sounds.Tech5090Loop) then
                sfx:Play(MattPack.Sounds.Tech5090Loop, .5, nil, true)
            else
                local pitch = percent / 2
                sfx:AdjustPitch(MattPack.Sounds.Tech5090Loop, (pitch + 1) / 2)
                sfx:AdjustVolume(MattPack.Sounds.Tech5090Loop, percent / 6)
            end
            local descs = player:GetCostumeSpriteDescs()
            local playerSprite = player:GetSprite()
            for _,costume in pairs(descs) do
                local config = costume:GetItemConfig()
                if config and config.ID == MattPack.Items.Tech5090 then
                    local sprite = costume:GetSprite()
                    local isShooting = playerSprite:GetOverlayFrame() == 2
                    if isShooting then
                        sprite.Offset = Vector(0,1)
                    else
                        sprite.Offset = Vector.Zero
                    end
                    if percent <= 4.5 then
                        sprite.PlaybackSpeed = percent
                    elseif sprite:GetOverlayAnimation() == "HeadDown_Overlay" then
                        sprite.PlaybackSpeed = 1
                        local frameToSet = player.FrameCount % 2
                        if playerSprite:GetOverlayFrame() == 2 then
                            frameToSet = frameToSet + 2
                        end
                        sprite:SetOverlayFrame("HeadDown_FullSpeed", frameToSet)
                    end
                end
            end
        else
            sfx:Stop(MattPack.Sounds.Tech5090Loop)
        end
        if MattPack.isNormalRender() then
            data.tech5090Percent = math.max(0, (percent or .1) - .015)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, mod.tech5090Costume)