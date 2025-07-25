local mod = MattPack

mod.multishotsList = {
    [CollectibleType.COLLECTIBLE_20_20] = 2,
    [CollectibleType.COLLECTIBLE_INNER_EYE] = 3,
    [CollectibleType.COLLECTIBLE_MUTANT_SPIDER] = 4,
    [CollectibleType.COLLECTIBLE_THE_WIZ] = 2
}
mod.multishotPlayersList = {
    [PlayerType.PLAYER_KEEPER] = 3,
    [PlayerType.PLAYER_KEEPER_B] = 4
}

local game = Game()
local sfx = SFXManager()

mod.constants = {
    game = game,
    sfx = sfx,
    pool = game:GetItemPool(),
    hud = game:GetHUD()
}


-- General
function Lerp(vec1, vec2, percent) -- force of habit forgive me
    return vec1 * (1 - percent) + vec2 * percent
end

function MattPack.isNormalRender(skipUpdate)
    -- thank u guwah
    local isPaused = game:IsPaused() and not skipUpdate
    local isReflected = (game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
    return (isPaused or isReflected) == false
end

mod.pickupSounds = {
    [MattPack.Items.MultiMush] = function()
        sfx:Play(SoundEffect.SOUND_1UP, 2.5, nil, nil, 2/3)
        sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF_2, .5, nil, nil, .75)
        sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF, 1, nil, nil, .75)
    end,
    [MattPack.Items.BoulderBottom] = function()
        sfx:Play(MattPack.Sounds.BoulderBottomPickup, 2.25)
    end,
    [MattPack.Items.BenightedHeart] = function()
        sfx:Play(MattPack.Sounds.ChoirDark, 2.5)
        sfx:Play(SoundEffect.SOUND_BLACK_POOF, 2.5)
    end
}

function mod.switchItem(pedestal, newId, preFunc, postFunc, updateFunc)
    pedestal:GetData().q5Fade = 0
    pedestal:GetData().q5TargetId = newId
    pedestal:ToPickup():RemoveCollectibleCycle ()
    if preFunc then
        preFunc()
    else
        sfx:Play(128, 2, nil, nil, .3)
    end
    pedestal:GetData().q5TargetFunc = postFunc
    pedestal:GetData().q5RenderFunc = updateFunc
end


function MattPack.addItemCharge(player, itemType, amt) -- If nothing was added, return false
    local amtAdded = 0
    for i = 0, 3 do
        if player:GetActiveItem(i) == itemType then
            amtAdded = player:AddActiveCharge(amt, i, true, player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY), true)
        end
    end
    return amtAdded
end

function MattPack.getMinItemCharge(player, CollectibleType)
    local min = nil
    for i = 0, 3 do
        if player:GetActiveItem(i) == CollectibleType then
            if not min then
                min = player:GetActiveCharge(i) + (player:GetBatteryCharge(i) or 0)
            else
                min = math.min(player:GetActiveCharge(i) + (player:GetBatteryCharge(i) or 0), min)
            end
        end
    end
    return min
end

function mod:setItemPools()
    local poolSetting = MattPack.Config.itemPoolConfig or 2
    local pool = mod.constants.pool
    for _,id in pairs(MattPack.Items) do
        pool:ResetCollectible(id)
    end
    if Epiphany and not (Epiphany.SaveManager and Epiphany.SaveManager.IsLoaded()) then
        table.insert(mod.RunPostDataLoad, function()
            if poolSetting == 2 then
                for _,id in ipairs(MattPack.Q5s) do
                    pool:RemoveCollectible(id)
                end
            elseif poolSetting == 3 then
                for _,id in pairs(MattPack.Items) do
                    pool:RemoveCollectible(id)
                end
            end
        end)
    else
        if poolSetting == 2 then
            for _,id in ipairs(MattPack.Q5s) do
                pool:RemoveCollectible(id)
            end
        elseif poolSetting == 3 then
            for _,id in pairs(MattPack.Items) do
                pool:RemoveCollectible(id)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.setItemPools)

-- Rainbow code (not mine)

mod.rainbowColor = Color(0,0,0,1)

local function hsvToRgb(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    local r, g, b
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    return (r + m) * 4, (g + m) * 4, (b + m) * 4
end

local lastStep = 1
function mod.updateRainbow(steps)
    lastStep = (lastStep + (steps or 1)) % 360
    local r, g, b = hsvToRgb(lastStep, 1, 1)
    mod.rainbowColor = Color(r, g, b)
end

local appendLists = {}
function mod.appendToDescription(itemID, string, q5format, logo, index)
    if EID then
        EID:addDescriptionModifier("Q5" .. itemID .. (index or ""), 
        function(objectDescription)
            if (not q5format) or MattPack.Config.EIDHintsEnabled then
                if objectDescription.ObjType == 5 
                and objectDescription.ObjVariant == 100 
                and objectDescription.ObjSubType == itemID then
                    return true
                end
            end
        end, 
        function(descObject)
            if q5format then
                EID:appendToDescription(descObject, "#{{MPLazyWorm}} Can be transformed " .. string)
            elseif logo then
                EID:appendToDescription(descObject, "#{{MPLazyWorm}} " .. string)
            else
                EID:appendToDescription(descObject, string)
            end
            return descObject
        end)
    end
end

function mod.addSynergyDescription(id1, id2, string, noIcon, isPlayer, oneSided)
    if EID then
        for i = 1, ((not isPlayer and not oneSided) and 2) or 1 do
            local itemID = id1
            local synItem = id2
            if i == 2 then
                itemID = id2
                synItem = id1
            end
            local modifierID
            if isPlayer then
                modifierID = "MP_Player_Synergy_" .. itemID .. "+" .. synItem
            else
                modifierID = "MP_Synergy_" .. itemID .. "+" .. synItem
            end
            EID:addDescriptionModifier(modifierID, 
            function(objectDescription)
                if objectDescription.ObjType == 5 
                and objectDescription.ObjVariant == 100 then
                    if (not isPlayer) and objectDescription.ObjSubType == synItem then
                        if PlayerManager.AnyoneHasCollectible(itemID) then               
                            return true
                        end
                    elseif isPlayer and objectDescription.ObjSubType == itemID then
                        if PlayerManager.AnyoneIsPlayerType(synItem) then                    
                            return true
                        end
                    end
                end
            end, 
            function(descObject)
                local stringStart = "#"
                if not noIcon then
                    if isPlayer then
                        stringStart = "#{{Player" .. synItem .. "}} "
                    else
                        stringStart = "#{{Collectible" .. itemID .. "}} "
                    end
                end
                EID:appendToDescription(descObject, stringStart .. string)
                return descObject
            end)
        end
    end
end

function mod.fireKnifeProjectile(player, position, velocity, fallingSpeed, fallingAccel, damage, spawner)
    if player then
        local parentTear = Isaac.Spawn(2, 13, 0, position or player.Position, velocity or Vector.Zero, nil):ToTear()
        parentTear.FallingSpeed = fallingSpeed or 0
        parentTear.FallingAcceleration = fallingAccel or -.05
        parentTear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        parentTear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        parentTear.CollisionDamage = 0
        parentTear.Visible = false
        local knife = player:FireKnife(parentTear, velocity:GetAngleDegrees()):ToKnife()
        knife.CollisionDamage = damage or (player.Damage * 2.5)
        knife.SpawnerEntity = spawner or player
        return knife
    end
end

mod.flagToStat = {
    [CacheFlag.CACHE_DAMAGE] = "Damage",
    [CacheFlag.CACHE_FIREDELAY] = "MaxFireDelay",
    [CacheFlag.CACHE_SHOTSPEED] = "ShotSpeed",
    [CacheFlag.CACHE_RANGE] = "TearRange",
    [CacheFlag.CACHE_SPEED] = "MoveSpeed",
}

function mod.downpourReflection(vector, countMirror) -- thanks liz
    local room = game:GetRoom()
    local isReflected = (room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
    if isReflected then
        vector = Vector(vector.X, -vector.Y)
    end
    if countMirror and room:IsMirrorWorld() then
        vector = Vector(vector.X, vector.Y)
    end
    return vector
end