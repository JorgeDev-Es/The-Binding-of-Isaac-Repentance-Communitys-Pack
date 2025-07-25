local mod = MattPack
-- local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.KitchenKnife, 
    "Must be charged by picking up Black Hearts#{{HalfBlackHeart}} When the knife is not fully charged, temporary Black Hearts spawn more often#When used, Isaac will stab a knife into the ground, shooting a massive fountain of light into the sky#While active, this fountain will damage and repel enemies, repel projectiles, and break rocks#Halfway through its lifespan, the fountain's damage will double"
)
end

mod.DarkKnifeCostumePaths = { -- {string : (folder name), bool : (include skincolor)}
    [PlayerType.PLAYER_BLACKJUDAS] = {"costumes_shadow", false},
    [PlayerType.PLAYER_JUDAS_B] = {"costumes_shadow", false}, -- temp
    [PlayerType.PLAYER_THEFORGOTTEN] = {"costumes_forgotten", false},
    [PlayerType.PLAYER_KEEPER] = {"costumes_keeper", false},
    [PlayerType.PLAYER_KEEPER_B] = {"costumes_keeper", false}, -- temp
}

function MattPack.isFountainOpen()
    for _,player in ipairs(PlayerManager.GetPlayers()) do
        if player:GetData().darkKnifeActive then
            return true
        end
    end
    return false
end

function MattPack.areAllKnivesFullCharged()
    for _,player in ipairs(PlayerManager.GetPlayers()) do
        local maxCharge = 12
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
            maxCharge = 24
        end
        if MattPack.getMinItemCharge(player, MattPack.Items.KitchenKnife) < maxCharge then
            return false
        end
    end
    return true
end

local skinColorVariants = {
    [0] = "white",
    [1] = "black", 
    [2] = "blue",
    [3] = "red",
    [4] = "green",
    [5] = "grey"
}

local halfBlackHeartSubtype = 4102

function mod:useDarkKnife(type, _, player)
    local data = player:GetData()
    if data.darkKnifeActive then
        data.cancelDarkKnife = true
    else
        data.darkKnifeActive = true
    end
    return {Discharge = false, Remove = false, ShowAnim = false}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useDarkKnife, MattPack.Items.KitchenKnife)

local game = mod.constants.game

local r = 255
local g = 0
local b = 0

local spritesToScale = {0, 1, 4, 6, 7}
function mod:darkKnifeAnimRender(player, offset)
    if player:HasCollectible(MattPack.Items.KitchenKnife) then
        local data = player:GetData()
        
        local currentModifier = game:GetCurrentColorModifier()
        if data.darkKnifeActive then
            if player:IsDead() then
                data.darkKnifeActive = nil
                data.frameFountainCreated = nil
                data.darkKnifeAnim:Stop()
                data.darkKnifeAnim.Color = Color(1,1,1,1)
                if data.darkKnifeLight then
                    data.darkKnifeLight:Remove()
                    data.darkKnifeLight = nil
                end
                MusicManager():VolumeSlide(1, .01)
                data.chargeRemoved = nil
                sfx:Stop(MattPack.Sounds.FountainCreate)
                sfx:Play(MattPack.Sounds.FountainCancel)
                data.cancelDarkKnife = nil
            else
                local darkKnifeAnim = data.darkKnifeAnim
                
                if not darkKnifeAnim then
                    darkKnifeAnim = Sprite()
                    darkKnifeAnim:Load("gfx/characters/costume_darkknife.anm2")
                    data.darkKnifeAnim = darkKnifeAnim
                    darkKnifeAnim:SetRenderFlags(0)
                end
                
                for _,i in ipairs(spritesToScale) do
                    darkKnifeAnim:GetLayer(i):SetSize(player.SpriteScale)
                end
                
                local setRainbow = player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE)
                local hasMultiMush = player:HasCollectible(MattPack.Items.MultiMush)
                if mod.isNormalRender() then
                    if setRainbow then
                        mod.updateRainbow()
                    end
                    
                    if hasMultiMush then
                        darkKnifeAnim:SetRenderFlags(darkKnifeAnim:GetRenderFlags() | AnimRenderFlags.GOLDEN)
                    end
                end

                local isFountainOpen = darkKnifeAnim:WasEventTriggered("FountainOpen") and not darkKnifeAnim:WasEventTriggered("FountainClose")
                local isFlipped = darkKnifeAnim:WasEventTriggered("FlipHalfway")
                local isUpdateFrame = game:GetFrameCount() % 2 == 0
                local light = data.darkKnifeLight
                
                if not (light and light:Exists()) then
                    light = Isaac.Spawn(1000, 121, 0, player.Position, Vector.Zero, nil)
                    light.SpriteScale = Vector.Zero
                    data.darkKnifeLight = light
                else
                    local lightLayer = darkKnifeAnim:GetNullFrame("*light")
                    if lightLayer then
                        light.Position = player.Position + Isaac.ScreenToWorldDistance(lightLayer:GetPos())
                        light.SpriteScale = Isaac.ScreenToWorldDistance(lightLayer:GetScale())
                        if setRainbow then
                            light.Color = Color(1,1,1,3)
                        end
                    end
                end
                
                if darkKnifeAnim:GetFrame() > 23 then
                    darkKnifeAnim:GetLayer("layer"):SetColor(Color(1,1,1,1))
                end

                if not darkKnifeAnim:IsPlaying() then
                    darkKnifeAnim:Play("KnifeAnim", true)
                    darkKnifeAnim:GetLayer("isaacunder"):SetColor(player.Color)
                    darkKnifeAnim:GetLayer("layer"):SetColor(player.Color)
                    local costumeData = mod.DarkKnifeCostumePaths[player:GetPlayerType()]
                    local costumeFolder = (costumeData and costumeData[1]) or "costumes"
                    local skinColor = ""
                    local costumeColor = skinColorVariants[player:GetBodyColor()]
                    if (costumeData and costumeData[2] and costumeColor) or ((not costumeData) and costumeColor) then -- yeah yeah
                        skinColor = "_" .. costumeColor
                    end
                    if costumeData or skinColor then
                        local filepath = "gfx/characters/" .. costumeFolder .. "/costume_darkknife" .. skinColor .. ".png"
                        for i = 0, 6 do
                            darkKnifeAnim:ReplaceSpritesheet(i, filepath, true)
                        end
                    end
                end
        
                if darkKnifeAnim:IsEventTriggered("FountainOpen") then
                    sfx:Play(MattPack.Sounds.FountainCreate, 2.5)
                    MusicManager():VolumeSlide(.1, .5)
                    data.frameFountainCreated = player.FrameCount
                end
                
                if MattPack.isNormalRender() then
                    if isUpdateFrame then
                        player.FireDelay = player.MaxFireDelay
                        
                        darkKnifeAnim:Update()
                        
                        if isFountainOpen then
                            for _,ent in ipairs(Isaac.GetRoomEntities()) do
                                local npc = ent:ToNPC()
                                if npc then
                                    if (not npc:IsVulnerableEnemy()) and not npc:IsBoss() then
                                        if npc.Position:Distance(player.Position) < 5 * (player.FrameCount - (data.frameFountainCreated or player.FrameCount)) * (math.random(90, 110) / 100) then -- ough that's messy
                                            npc:Die()
                                        end
                                    end
                                    local stageMulti = game:GetLevel():GetStage()
                                    local damageToDeal = .5 * ((stageMulti + 1) / 2)
                                    if npc:IsBoss() then
                                        damageToDeal = damageToDeal * 1.5
                                    end
                                    if isFlipped then
                                        damageToDeal = damageToDeal * 2
                                    end
                                    npc:TakeDamage(damageToDeal, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
                                    
                                    local massMultiplier = ((10 / npc.Mass) + 2) / 3
                                    local distanceMultiplier = 60 / npc.Position:Distance(player.Position)
                                    local randomMultiplier = math.random(25, 100) / 100
                                    local flipMultiplier = (isFlipped and 2) or 1
                                    npc.Velocity = npc.Velocity + (npc.Position - player.Position):Resized(1 * massMultiplier * distanceMultiplier * randomMultiplier * flipMultiplier)
                                end
                                
                                local proj = ent:ToProjectile()
                                if proj then
                                    local massMultiplier = 8 / proj.Mass
                                    local distanceMultiplier = 60 / proj.Position:Distance(player.Position)
                                    local randomMultiplier = math.random(25, 100) / 100
                                    local flipMultiplier = (isFlipped and 2) or 1
                                    proj.Velocity = proj.Velocity + (proj.Position - player.Position):Resized(.5 * massMultiplier * distanceMultiplier * randomMultiplier * flipMultiplier)
                                end

                                local pickup = ent:ToPickup()
                                if pickup then
                                    if pickup.SubType == 6 or pickup.SubType == halfBlackHeartSubtype then
                                        local distanceMultiplier = 60 / pickup.Position:Distance(player.Position)
                                        pickup.Velocity = pickup.Velocity + (player.Position - pickup.Position):Resized(.15 * distanceMultiplier )    
                                    end
                                end
                            end
                        end
                    end
                end
                
                if isFountainOpen then
                    game:Darken(0, 1)
                    if setRainbow then
                        game:SetColorModifier(ColorModifier((mod.rainbowColor.R or 1), (mod.rainbowColor.G or 1), (mod.rainbowColor.B or 1), 1, 0, 1), true, .25)
                    elseif hasMultiMush then
                        game:SetColorModifier(ColorModifier(3, 2.75, 2, 1, 0, 4), true, .25)
                    else
                        game:SetColorModifier(ColorModifier(2.5, 2.5, 2.5, 1, 0, 2), true, .25)
                    end
        
                    player.Friction = 0
                    player.Mass = 999
                    darkKnifeAnim.Color = Color(1 / currentModifier.R, 1 / currentModifier.G, 1 / currentModifier.B)
        
                    if isFountainOpen and darkKnifeAnim:GetFrame() < 172 and (data.cancelDarkKnife or MattPack.getMinItemCharge(player, MattPack.Items.KitchenKnife) <= 0) then
                        sfx:Stop(MattPack.Sounds.FountainCreate)
                        sfx:Play(MattPack.Sounds.FountainCancel)
                        darkKnifeAnim:SetFrame(172)
                        data.cancelDarkKnife = nil
                    end
                else
                    game:GetRoom():UpdateColorModifier(true, true, .15)
                    data.cancelDarkKnife = nil
                end
                
                if isFountainOpen and darkKnifeAnim:WasEventTriggered("FlipStart") then
                    darkKnifeAnim.PlaybackSpeed = .5
                else
                    darkKnifeAnim.PlaybackSpeed = 1
                end
                
                darkKnifeAnim:Render(Isaac.WorldToRenderPosition(player.Position) + offset)
                
                darkKnifeAnim:LoadGraphics()
                
                if darkKnifeAnim:IsFinished() then
                    data.darkKnifeActive = nil
                    data.frameFountainCreated = nil
                    darkKnifeAnim:Stop()
                    player:PlayExtraAnimation("LeapDown")
                    player:GetSprite():SetFrame(28)
                    darkKnifeAnim.Color = Color(1,1,1,1)
                    light:Remove()
                    MusicManager():VolumeSlide(1, .01)
                    if not data.chargeRemoved or data.chargeRemoved == 0 then
                        MattPack.addItemCharge(player, MattPack.Items.KitchenKnife, -1)
                        data.chargeRemoved = nil
                    end
                else
                    return false
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, mod.darkKnifeAnimRender)

function mod:darkKnifeSparkle(player)
    if player:HasCollectible(MattPack.Items.KitchenKnife) then
        local data = player:GetData()
        if data.darkKnifeActive then
            if data.frameFountainCreated then
                local timeSinceFountain = player.FrameCount - data.frameFountainCreated + 2
                if timeSinceFountain > 0 and timeSinceFountain % 18 == 0 and ((data.lastDrainFrame or 0) ~= player.FrameCount) then
                    MattPack.addItemCharge(player, MattPack.Items.KitchenKnife, -1)
                    data.chargeRemoved = (data.chargeRemoved or 0) + 1
                    data.lastDrainFrame = player.FrameCount
                end
                if timeSinceFountain % math.random(18, 20) == 0 and ((data.lastBreakFrame or 0) ~= player.FrameCount) then
                    local room = game:GetRoom()
                    for i = 0, 418 do
                        local grid = room:GetGridEntity(i)
                        if grid then
                            local amplitude = (timeSinceFountain / 9)
                            if grid.Position:Distance(player.Position) < 20 * amplitude * (math.random(90, 110) / 100) then
                                grid:Destroy()
                            end
                        end
                    end
                end
                if timeSinceFountain % 5 == 0 then
                    -- Particles shooting from point of impact
                    local bling = Isaac.Spawn(1000, 103, 4100, player.Position + (Vector(14, 6) * player.SpriteScale), Vector.Zero, nil)
                    bling:GetSprite():ReplaceSpritesheet(0, "gfx/ultragreedbling_darkknifeparticle.png", true)
                    bling:GetSprite():Play("Bling5")
                    bling.SpriteRotation = 90
                    bling:GetSprite().PlaybackSpeed = .25
                    bling.Color = Color(0,0,0,.05,1,1,1)
                    bling.Velocity = Vector(0, 2.5)
                    bling.DepthOffset = -20
                end
            end
        end
        local knifeAnimFrame = (data.darkKnifeAnim and data.darkKnifeAnim:GetFrame())
        if knifeAnimFrame and knifeAnimFrame <= 21 then
            local data = player:GetData()
            if data.darkKnifeActive and knifeAnimFrame ~= data.lastDarkKnifeFrame then
                local maxDistanceX = 165
                local maxDistanceY = 23
                local movePercent = knifeAnimFrame / 21 - .5
                local bling = Isaac.Spawn(1000, 103, 0, player.Position + (Vector(1.5, 0) + Vector(maxDistanceX * movePercent, -50 + math.random(-maxDistanceY, maxDistanceY)) * player.SpriteScale), Vector.Zero, nil)        
                bling.Color = Color(0,0,0,1,1,1,1)
    
                sfx:Play(MattPack.Sounds.FountainMarker, 2.25, 0)
                data.lastDarkKnifeFrame = knifeAnimFrame
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.darkKnifeSparkle)


function mod:darkKnifeGrowingEffect(ent)
    if ent.SubType == 4100 then
        local percentDone = ent.FrameCount / (4 / ent:GetSprite().PlaybackSpeed)
        ent.SpriteScale = Vector(4.5 * percentDone, 60 * (percentDone))
        local color = ent.Color
        color.A = .05 * (1 - percentDone)
        ent.Color = color
        ent.SpriteOffset = Vector(-9.5 + (percentDone * 33), 0)
        if ent:GetSprite():IsFinished() then
            ent:Die()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, mod.darkKnifeGrowingEffect, 103)

function mod:darkKnifeLighting(ent)
    local player = ent:ToPlayer()
    if player and player:HasCollectible(MattPack.Items.KitchenKnife) then
        local data = player:GetData()
        local knifeAnimFrame = (data.darkKnifeAnim and data.darkKnifeAnim:GetFrame())
        if knifeAnimFrame and knifeAnimFrame >= 24 and knifeAnimFrame <= 177 then
            return false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_RENDER_ENTITY_LIGHTING, mod.darkKnifeLighting)

local heartSeeds = {}
function mod:darkKnifeHeartConversion(ent)
    if PlayerManager.AnyoneHasCollectible(MattPack.Items.KitchenKnife) and not MattPack.areAllKnivesFullCharged() then
        local subtype = ent.SubType
        if not heartSeeds[ent.InitSeed] then
            heartSeeds[ent.InitSeed] = true
            local timeoutTime = 240
            if math.random(1, 3) == 1 then
                if subtype == 1 or subtype == 9 or subtype == 10 then
                    ent:Morph(5, 10, 6, true) -- Red heart to black heart
                    ent.Timeout = timeoutTime
                elseif subtype == 2 then
                    ent:Morph(5, 10, halfBlackHeartSubtype, true) -- Half red heart to half black heart
                    ent.Timeout = timeoutTime
                elseif subtype == 5 then
                    ent:Morph(5, 10, 6, true) -- Double red heart to two black hearts
                    ent.Timeout = timeoutTime
                    ent.Velocity = RandomVector()
                    ent.Position = ent.Position + ent.Velocity
                    local heart2 = Isaac.Spawn(5, 10, 6, ent.Position - ent.Velocity, -ent.Velocity, nil):ToPickup()
                    heart2.Timeout = timeoutTime
                end
            elseif math.random(1, 4) > 1 then
                if subtype == 3 then
                    ent:Morph(5, 10, 6) -- Soul heart to black heart
                    ent.Timeout = timeoutTime
                elseif subtype == 8 then
                    ent:Morph(5, 10, halfBlackHeartSubtype) -- Half soul heart to half black heart
                    ent.Timeout = timeoutTime
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.darkKnifeHeartConversion, 10)

function mod:darkKnifeHeartConversionClear()
    heartSeeds = {}
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.darkKnifeHeartConversionClear)

function mod:darkKnifeHeartCharge(pickup, collider)
    local player = collider:ToPlayer()
    if player then
        local isHalfBlackHeart = (pickup.Variant == 10 and pickup.SubType == halfBlackHeartSubtype) or (pickup.Variant == 1022)
        if (pickup.Variant == 10 and pickup.SubType == 6) or isHalfBlackHeart then
            local heartValue = 2
            if isHalfBlackHeart then
                heartValue = 1
            end
            if player:HasCollectible(MattPack.Items.KitchenKnife) then
                local amtAdded = MattPack.addItemCharge(player, MattPack.Items.KitchenKnife, heartValue)
                if amtAdded > 0 then
                    for i = 1, math.random(3, 6) do
                        local smoke = Isaac.Spawn(1000, 88, 0, pickup.Position + Vector(0, -10), Vector(0, -math.random(3, 9)):Rotated(math.random(0, 180) - 90), nil)
                        smoke:ToEffect().LifeSpan = 90
                    end
                    for i = 1, math.random(1,6), 1 do                    
                        local ember = Isaac.Spawn(1000, 66, 0, pickup.Position + Vector(0, -10), RandomVector():Resized(math.random(2,8)), nil)
                        ember.Color = Color(0,0,0,.5) 
                    end
                    local poof = Isaac.Spawn(1000, 15, 1, pickup.Position + Vector(0, -10), Vector.Zero, nil)
                    poof.Color = Color(.5,.5,.5,.5,0,0,0,1,1,1)
                    poof.DepthOffset = 10
                    sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, nil, nil, math.random(85, 115) / 100)
                    sfx:Play(SoundEffect.SOUND_MENU_FLIP_DARK, 1, nil, nil, 1.66)
                    sfx:Play(SoundEffect.SOUND_BEEP, 1, nil, nil, 1)
                    
                    local bloodSplat = Isaac.Spawn(1000, 7, 0, pickup.Position + Vector(0, -8), Vector.Zero, pickup)
                    bloodSplat.Color = Color(0,0,0,1)
                    
                    pickup:Remove()
                    return {Collide = false, SkipCollisionEffects = true}
                end
            end
            if pickup.SubType == halfBlackHeartSubtype and pickup.Wait == 0 and player:CanPickBlackHearts() then -- Health bar flashes as you walk into this but it's whatever
                player:AddBlackHearts(1)
                pickup:GetSprite():Play("Collect")
                pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                pickup:Die()
                sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 0)
                pickup.Wait = 20
                return {Collide = false}
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.IMPORTANT, mod.darkKnifeHeartCharge)

function mod:darkKnifeHeartCharge2(player, amt)
    local amtToReturn = amt
    if player and player:HasCollectible(MattPack.Items.KitchenKnife) then
        amtToReturn = amtToReturn - (MattPack.addItemCharge(player, MattPack.Items.KitchenKnife, amt) or 0)
    end
    return amtToReturn
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, CallbackPriority.IMPORTANT, mod.darkKnifeHeartCharge2, AddHealthType.BLACK)

function mod:darkKnifeMinUsableCharge()
    return 1
end
mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, mod.darkKnifeMinUsableCharge, MattPack.Items.KitchenKnife)


function mod:darkKnifeSpawnBlackHearts(npc)
    if PlayerManager.AnyoneHasCollectible(MattPack.Items.KitchenKnife) then
        if math.random(1, 5) == 1 then
            if not MattPack.isFountainOpen() and not MattPack.areAllKnivesFullCharged() then
                local heart = Isaac.Spawn(5, 10, halfBlackHeartSubtype, npc.Position, Vector.Zero, nil):ToPickup()
                heart.Timeout = 120
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.darkKnifeSpawnBlackHearts)