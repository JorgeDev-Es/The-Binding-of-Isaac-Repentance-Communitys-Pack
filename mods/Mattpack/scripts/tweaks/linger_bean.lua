local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

local lingerBean = CollectibleType.COLLECTIBLE_LINGER_BEAN
function mod:updateLingerBean()
    local lbConfig = Isaac.GetItemConfig():GetCollectible(lingerBean)
    if mod.Config.lbReworkEnabled ~= false then
        mod.lbReworkEnabled = true
        lbConfig.Quality = 3
        lbConfig.Description = "Thunderous Farts"
    else
        mod.lbReworkEnabled = false
        local lbData = XMLData.GetEntryById(XMLNode.ITEM, lingerBean)
        if lbData then
            lbConfig.Quality = lbData.quality or 0
            lbConfig.Description = lbData.description or "Crying makes me toot"
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, mod.updateLingerBean)

if EID then
    EID:addDescriptionModifier("LingerBeanRework", 
    function(objectDescription)
        if MattPack.Config.lbReworkEnabled then
            if objectDescription.ObjType == 5 
            and objectDescription.ObjVariant == 100 
            and objectDescription.ObjSubType == lingerBean then
                return true
            end
        end
    end, 
    function(descObject)
        descObject.Description = "Double tapping a fire key will shoot a poop cloud opposite the direction of your firing#A cloud can be spawned every 10 seconds#Clouds will grow through 4 stages, gaining an additional effect each stage#On the final stage, enemies beneath the cloud will occasionally be struck by lightning"
        return descObject
    end)
end

function mod:lingerCloudUpdate(ent)
    if MattPack.Config.lbReworkEnabled then
        local data = ent:GetData()
        local player = (ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()) or Isaac.GetPlayer()
    
        local isBrim = player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE)
        local isTech = player:HasWeaponType(WeaponType.WEAPON_LASER) or player:HasWeaponType(WeaponType.WEAPON_TECH_X)
    
        ent.Friction = 1.3 - (.075 * (data.cloudState or 0))
        if ent.State > 0 and data.cloudState ~= 4 then
            ent.State = 15
        end
        ent:SetShadowSize(.12 * (ent.SpriteScale.X / 12 + (11/12)))
        ent:GetSprite().PlaybackSpeed = .25
        
        local homingRange = 60 + 20 * ((data.cloudState or 0))
        local homingStrength = 1
        
        local colorIntensity = .25 * ((data.cloudState or 0) + 1)
        
        if player.TearFlags & TearFlags.TEAR_HOMING > 0 then
            homingStrength = 1.5
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
            ent.Velocity = ent.Velocity + player:GetShootingJoystick():Resized(.75)
            colorIntensity = colorIntensity + .25
        end
        
        local color = Color(1,1,1,1.25)
        color:SetColorize(player.TearColor.R, player.TearColor.G, player.TearColor.B, colorIntensity)
        
        if ent.FrameCount == 1 then
            sfx:Play(SoundEffect.SOUND_POOPITEM_THROW, .5)
            ent.Color = color
        end
        
        for _,npc in ipairs(Isaac.FindInRadius(ent.Position, homingRange * homingStrength, EntityPartition.ENEMY)) do
            if npc:IsActiveEnemy() then
                local toTarget = (npc.Position - ent.Position)
                if toTarget:Length() > 5 then
                    ent.Velocity = ent.Velocity + toTarget:Resized(math.max(0, 1 - (toTarget:Length()) / homingRange * homingStrength) * .25 * homingStrength)
                end
            end
        end
        
        local timeBetweenStages = 210
        local lastState = data.cloudState or 0
    
    
        local fireDelayMulti = math.min(player.MaxFireDelay / 10, (player.MaxFireDelay / 10 + 1) / 2)
    
        if not data.cloudState or data.cloudState == 0 then
            data.cloudState = 0
            if ent.FrameCount >= timeBetweenStages then
                data.cloudState = 1
                data.targetScale = 1.5
                data.nextStateFrame = timeBetweenStages * 2
            end
        elseif data.cloudState == 1 then
            if ent.FrameCount >= timeBetweenStages * 2 then
                data.cloudState = 2
                data.targetScale = 2
                data.nextStateFrame = timeBetweenStages * 3
            end
        elseif data.cloudState == 2 then
            if ent.FrameCount >= timeBetweenStages * 3 then
                ent.Color = color
                data.doThunder = true
                data.cloudState = 3
                data.targetScale = 3
                data.nextStateFrame = nil
                sfx:Play(SoundEffect.SOUND_DOGMA_JACOBS_ZAP, .5, nil, nil, .5)
            elseif ent.FrameCount == timeBetweenStages * 3 - 10 then
                sfx:Play(SoundEffect.SOUND_THUNDER)
            end
        elseif data.cloudState == 3 then
            if data.doThunder then
                ent:SetColor(color * Color(1, 1, 2.5, 2.5), 30, 99, true, true)
                data.doThunder = nil
            end
            if ent.FrameCount >= timeBetweenStages * 6 then
                ent.State = math.max(ent.State + 1, 450)
                data.cloudState = 4
            end
            if data.lightningCooldown then
                data.lightningCooldown = data.lightningCooldown - 1
                if data.lightningCooldown <= 0 then
                    data.lightningCooldown = nil
                end
            else
                local inRadius = Isaac.FindInRadius(ent.Position, 50)
                table.sort(inRadius, function(ent1, ent2)
                    if ent1.Position:Distance(ent.Position) < ent2.Position:Distance(ent.Position) then
                        return true
                    end
                end)
                for _,npc in ipairs(Isaac.FindInRadius(ent.Position, 50)) do
                    if npc:IsActiveEnemy() then
                        data.doThunder = true
                        local lengthToBottom = 90
                        data.lightningCooldown = 120 * ((fireDelayMulti + 1) / 2)
                        local sourcePos = ent.Position - Vector(0, lengthToBottom) + (RandomVector() * Vector(1, .25)):Resized(math.random(0, 35))
                        local laser = EntityLaser.ShootAngle((isBrim and 9) or 2, sourcePos, (sourcePos - npc.Position):GetAngleDegrees() + 180, 10, Vector.Zero, player)
                        laser:GetData().isLingerBean = true
                        laser.TearFlags = player.TearFlags
                        laser.CollisionDamage = player.Damage * 3
                        laser.OneHit = false
                        laser.DisableFollowParent = true
                        laser.MaxDistance = sourcePos:Distance(npc.Position) - 30
                        if not (isBrim or isTech) then
                            laser.Color = Color(0, 0, 0, 1,player.TearColor.R,player.TearColor.G,player.TearColor.B,5)
                        else
                            laser.Color = Color(1,0,0,1) * player.LaserColor
                        end
                        if isBrim then
                            laser:SetScale(.5)
                            laser.Timeout = math.ceil(laser.Timeout * 1.5)
                        else
                            laser:SetScale(2)
                        end
                        laser.DepthOffset = lengthToBottom + npc.Size * 2
                        laser:ForceCollide(npc)
                        sfx:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP_STRONG)
                        sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_BURST)
                        sfx:Play(SoundEffect.SOUND_THUNDER)
                        if game:GetRoom():GetWaterAmount() > 0 then
                            Isaac.Spawn(1000, 167, 0, npc.Position, Vector.Zero, player):ToEffect()
                            data.lightningCooldown = 90
                        end
                        game:GetRoom():SetLightningIntensity(.5)
                        break
                    end
                end
            end
            if math.random(1, math.max(1, math.floor(12 * fireDelayMulti))) == 1 then
                local tear = player:FireTear(ent.Position + (RandomVector() * Vector(1, .25)):Resized(math.random(0, 35)), Vector.Zero, true, true, false, player, 1)
                tear.FallingSpeed = 15
                tear.FallingAcceleration = 1
                tear:GetData().isLingerBean = true
                if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) or player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
                    tear:ChangeVariant(13)
                    tear:AddTearFlags(TearFlags.TEAR_PIERCING)
                    local lastAnim = tear:GetSprite():GetAnimation()
                    tear:GetSprite():Load("gfx/knife_tears.anm2")
                    tear:GetSprite():Play(lastAnim, true)
                    tear.SpriteOffset = Vector(0, -15)
                    tear.SpriteScale = tear.SpriteScale * .85
                end
                tear.Height = -math.random(75, 115)
                if isBrim or isTech then
                    if tear.Color.R == 1 and tear.Color.G == 1 and tear.Color.B == 1 then
                        tear.Color = Color(1,0,0,1) * tear.Color
                    end            
                end
                if tear:HasTearFlags(TearFlags.TEAR_LASERSHOT) then
                    tear.Velocity = Vector(0, .1)
                    tear:Update()
                    tear:Update()
                    tear.FallingSpeed = 5
                    tear.Height = tear.Height - 15
                end
            end
            data.firstColorSet = nil
        else
            data.nextStateFrame = timeBetweenStages
        end
        if data.cloudState > 0 and data.cloudState < 4 then
            local sizeMulti = (ent.SpriteScale / 3)
            if math.random(1, math.max(1, math.floor((5 - data.cloudState) * fireDelayMulti))) == 1 then
                Isaac.CreateTimer(function()
                    local drop = Isaac.Spawn(1000, 135, 0, ent.Position + (RandomVector() * Vector(1, .25)):Resized(math.random(0, 35)) * (sizeMulti), Vector.Zero, ent):ToEffect()
                    local setFrame = math.random(8, 12)
                    setFrame = setFrame + (4 - data.cloudState)
                    drop:GetSprite():SetFrame(setFrame)
                    drop.SpriteScale = Vector(1, .35)
                    drop:GetData().isLingerBean = true
                    drop:GetData().lingerPlayer = ent.SpawnerEntity
                    drop:GetData().creepScale = ent.SpriteScale
                    if data.cloudState > 1 then
                        if data.cloudState > 2 or math.random(1, 3) == 1 then
                            drop:GetData().inheritFlags = true
                            drop:GetData().brimTech = isBrim or isTech
                            if isBrim or isTech then
                                drop.Color = Color(1,0,0,1) * player.LaserColor
                            else
                                drop.Color = player.TearColor
                            end
                        end
                    end
                end, 1, math.random(1, 3), false)
            end
        end
    
        if data.targetScale then
            ent.SpriteScale = (Lerp(ent.SpriteScale, Vector.One * data.targetScale, .15))
        end
        if data.cloudState ~= lastState then
            sfx:Play(SoundEffect.SOUND_POOPITEM_HOLD, .25, nil, nil, 1 - (.25 * (lastState)))
            sfx:Play(SoundEffect.SOUND_SUMMON_POOF, .85, nil, nil, 1 - (.25 * (lastState)))
            ent.Color = color
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.lingerCloudUpdate, 105)


function mod:lingerDroplet(ent)
    if MattPack.Config.lbReworkEnabled then
        if ent:GetData().isLingerBean and ent:Exists() then
            if ent:GetSprite():GetFrame() > 14 then
                local creep
                if ent:GetData().inheritFlags then
                    creep = ((ent:GetData().lingerPlayer and ent:GetData().lingerPlayer:ToPlayer()) or Isaac.GetPlayer()):SpawnAquariusCreep()
                    creep.Position = ent.Position
                    if ent:GetData().brimTech then
                        if creep.Color.R == 1 and creep.Color.G == 1 and creep.Color.B == 1 then
                            creep.Color = Color(1,0,0,1) * creep.Color
                        end
                    end
                else
                    creep = Isaac.Spawn(1000, 54, 0, ent.Position, Vector.Zero, ent:GetData().lingerPlayer or Isaac.GetPlayer()):ToEffect()
                end
                creep.Scale = .5
                creep.SpriteScale = creep.SpriteScale * Vector(1, .75)
                creep:Update()
                creep.Timeout = math.ceil(creep.Timeout / 2)
                ent:GetData().isLingerBean = nil
                creep.CollisionDamage = creep.CollisionDamage / 2
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.lingerDroplet, 135)

mod.LingerCooldown = 600

function mod:doubleTap(player)
    if MattPack.Config.lbReworkEnabled then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_LINGER_BEAN, nil, true) then
            player:BlockCollectible(CollectibleType.COLLECTIBLE_LINGER_BEAN)
            local data = player:GetData()
            if not data.lingerCooldown then
                for i = 4, 7 do
                    if Input.IsActionTriggered(i, player.ControllerIndex) then
                        local prevButton = data.lastButton
                        data.lastButton = i
                        if prevButton == i then
                            Isaac.Spawn(1000, 105, 0, player.Position, player.Velocity:Resized(math.min(10, player.Velocity:Length())) - (player:GetShootingInput() * 7.5), player)
                            data.lastButton = nil
                            data.lingerCooldown = mod.LingerCooldown
                        end
                        data.timeToClear = 30
                    end
                end
                if data.timeToClear then
                    data.timeToClear = data.timeToClear - 1
                    if data.timeToClear <= 0 then
                        data.lastButton = nil
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.doubleTap)


function mod:lingerCounter(player)
    if MattPack.Config.lbReworkEnabled then
        local data = player:GetData()
        if data.lingerCooldown then
            data.lingerCooldown = data.lingerCooldown - 1
            if data.lingerCooldown <= 0 then
                data.lingerCooldown = nil
                player:SetColor(Color(.70, .5, .3, 1), 15, 99, true, true)
                sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT, .5, nil, nil, 1.25)
                sfx:Play(SoundEffect.SOUND_FAT_WIGGLE, nil, nil, nil, .85)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.lingerCounter)


function mod:laserMoveCloud(laser)
    if MattPack.Config.lbReworkEnabled then
        for _,ent in ipairs(Isaac.FindByType(1000, 105)) do
            local velToAdd = Vector.FromAngle(laser.Angle):Resized(5)
            if laser:IsCircleLaser() or laser.Variant == 3 then
                if laser.Position:Distance(ent.Position) <= 60 then
                    velToAdd = (laser.Parent or laser).Velocity * .25
                else
                    goto continue
                end
            end
            if not laser:GetData().isLingerBean then
                ent.Velocity = ent.Velocity + (velToAdd / 6)
            end
            ::continue::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.laserMoveCloud)

function mod:trisagFix(ent)
    if MattPack.Config.lbReworkEnabled then
        if ent.Variant == 3 and ent.Parent and ent.Parent:GetData().isLingerBean then
            if ent.FrameCount <= 1 then
                ent.Visible = false
                ent.Angle = 90
            else
                ent.Visible = true
            end
            ent.PositionOffset = ent.Parent.PositionOffset - Vector(0, 20)
            ent:SetScale(.5)
            ent.MaxDistance = 15
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.trisagFix)
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.trisagFix)

function mod:knifeMoveCloud(knife)
    if MattPack.Config.lbReworkEnabled then
        local isSword = knife.Variant > 0
        if knife:GetKnifeVelocity() > 0 or isSword then
            for _,ent in ipairs(Isaac.FindByType(1000, 105)) do
                if ent.Position:Distance(knife.Position) <= 60 then
                    ent.Velocity = ent.Velocity + Vector.FromAngle(knife.Rotation):Resized(1.5)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, mod.knifeMoveCloud)

function mod:bombMoveCloud(bomb)
    if MattPack.Config.lbReworkEnabled then
        for _,ent in ipairs(Isaac.FindByType(1000, 105)) do
            if ent.Position:Distance(bomb.Position) <= (bomb.Size + 40) then
                ent.Velocity = ent.Velocity + bomb.Velocity / 2
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.bombMoveCloud)