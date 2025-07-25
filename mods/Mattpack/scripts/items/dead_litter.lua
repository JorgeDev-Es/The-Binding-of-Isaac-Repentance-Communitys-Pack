local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx
local hud = mod.constants.hud

if EID then
    EID:addCollectible(MattPack.Items.DeadLitter, 
    "↑ x1.66 Damage multiplier#" .. 
    "10% chance for each shot to be accompanied by one of three cat-themed effect#" .. 
    "{{Luck}} 50% chance at 10 luck#" ..
    "{{Collectible" .. CollectibleType.COLLECTIBLE_GUPPYS_HEAD .. "}} Fires 3 temporary, half-damage Abyss locusts#" ..
    "{{Collectible" .. CollectibleType.COLLECTIBLE_TAMMYS_HEAD .. "}} Fires 9 additional tears in a circle around Isaac#" ..
    "{{Collectible" .. CollectibleType.COLLECTIBLE_CRICKETS_HEAD .. "}} Tears are given the#{{Blank}} {{Collectible" .. MattPack.Items.BloatedBody .. "}} Bloated Body effect, splitting into 4 until they run out of range")

    mod.appendToDescription(CollectibleType.COLLECTIBLE_MOVING_BOX, "Store up three#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_GUPPYS_PAW .. "}} {{ColorYellow}}cat parts{{CR}} to transform them", false, true)
end

function mod:dlCache(player, flag)
    if player and player:HasCollectible(MattPack.Items.DeadLitter) then
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * (1 + 2/3)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.dlCache)

local maxLuck = 10
local minChance = 12 -- 1/8 -- 8.33%
local maxChance = 2 -- 1/2 -- 50%

function mod:deadLitterLocust(ent)
    if ent.SubType == 1515 then
        if ent.State ~= -1 then
            if ent.FrameCount > 30 then
                ent:Die()
                local splat = Isaac.Spawn(1000, 3, 0, ent.Position + ent.PositionOffset, Vector.Zero, nil)
                splat.Color = Color(.5,.75,1,.5)
                sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, .5, nil, nil, 1)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, mod.deadLitterLocust, 231)

function mod:deadLitterLocustDmg(_, _, _, source)
    local src = source and source.Entity
    if src and src.Type == 3 and src.Variant == 231 and src.SubType == 1515 then
        local player = src.SpawnerEntity and src.SpawnerEntity:ToPlayer()
        if player then
            local multi = 1
            if player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) or player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                multi = 1.25
            end
            return {Damage = player.Damage / 2 * multi} -- idk why they choose from pre-cache player damage but whatever
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.deadLitterLocustDmg)

mod.WeaponChanceMultis = { -- i expected to need this more but it turnued out fine grins
    [WeaponType.WEAPON_LUDOVICO_TECHNIQUE] = 10,
    [WeaponType.WEAPON_ROCKETS] = 10,
    
}

function mod:dlSetParams(player)
    -- is it a bad idea to move this here? it's proobably fine
    local data = player:GetData()
    if player and player:HasCollectible(MattPack.Items.DeadLitter) then
        mod.effectProcced = nil
        local weaponType = player:GetWeapon(1):GetWeaponType()
        for i = 1, player:GetCollectibleNum(MattPack.Items.DeadLitter) do -- Run once for each copy of Dead Litter to allow for effect stacking
            local chance = (Lerp(minChance, maxChance, math.min(1, math.max(0, (player.Luck / maxLuck))))) * (mod.WeaponChanceMultis[weaponType] or 1)
            local rand = math.random(1, math.ceil(chance * 30))
            if rand <= 10 then -- Cricket
                data.nextIsSuperSplitting = true
            elseif rand <= 20 then -- Guppy
                for i = 0, 2 do
                    local locust = Isaac.Spawn(3, 231, 1515, player.Position, RandomVector():Rotated(120 * i):Resized(10), player):ToFamiliar()
                    locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    locust.Color = Color(0,1,1,1,0,.85,1)
                end
                sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 1, nil, nil, .75)                
                sfx:Play(SoundEffect.SOUND_ANGEL_WING, .75, nil, nil, 2)
            elseif rand <= 30 then -- Tammy
                data.dlSetTears = (data.dlSetTears or 0) + 9
            end

            if rand <= 30 then
                mod.effectProcced = true
            end
        end
        local params = player:GetMultiShotParams(weaponType)
        local data = player:GetData()
        if data.dlSetTears then
            local tearsToAdd = data.dlSetTears
            data.dlSetTears = nil
            if not data.dlLastParams then
                data.dlLastParams = {params:GetNumTears(), params:GetNumEyesActive(), params:GetMultiEyeAngle()}
            end
            local setTears = (params:GetNumTears() or 1) + (tearsToAdd)
            params:SetNumTears(setTears)
            params:SetNumEyesActive(setTears + 1)
            params:SetMultiEyeAngle(360 / 2)
            sfx:Play(SoundEffect.SOUND_HEARTOUT, .5, nil, nil, 1)
            return params
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, CallbackPriority.EARLY - 101, mod.dlSetParams) -- this entire item won't work if this callback is cancelled, which community remix somehow does :sob:

function mod:dlBrimstoneFix(laser, col)
    if not laser.OneHit and col and col:ToNPC() then -- Give brimstone lasers a quarter chance to proc similar effects on hit
        local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
        if player and player:HasCollectible(MattPack.Items.DeadLitter) then
            local data = laser:GetData()
            if not data.isSuperSplitting and not mod.effectProcced then
                local chance = (Lerp(minChance, maxChance, math.min(1, math.max(0, (player.Luck / maxLuck)))))
                local rand = math.random(1, math.ceil(chance * 30))
                if rand <= 5 then
                    laser:AddTearFlags(TearFlags.TEAR_QUADSPLIT)
                elseif rand <= 10 then
                    for i = 0, 2 do
                        local locust = Isaac.Spawn(3, 231, 1515, player.Position, RandomVector():Rotated(120 * i):Resized(10), player):ToFamiliar()
                        locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        locust.Color = Color(0,1,1,1,0,.85,1)
                    end
                    sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 1, nil, nil, .75)                
                    sfx:Play(SoundEffect.SOUND_ANGEL_WING, .75, nil, nil, 2)
                end
            end
            mod.effectProcced = nil
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_LASER_COLLISION, CallbackPriority.EARLY - 101, mod.dlBrimstoneFix)

mod.DeadLitterInitialized = false
mod.DeadLitterCatBits = {} -- [itemID = true],
mod.DeadLitterCatNames = {"Cricket", "Guppy", "Tammy", "Moxie", "Fry"}
mod.DeadLitterCatNameBlacklist = {"Collar", "Hairball", "Yarn"}
mod.animData = {}

function mod:dlTransform(_, _, player)
    local contents = player:GetMovingBoxContents ()
    local catBits = 0
    local catIndices = {}
    for i = 0, #contents - 1 do
        if catBits < 3 then
            local item = contents:Get(i)
            local type = item:GetSubType()
            if type > 0 and mod.DeadLitterCatBits[type] then
                catBits = catBits + 1
                table.insert(catIndices, i)
            end
        else
            break
        end
    end
    if catBits >= 3 then
        for i,index in ipairs(catIndices) do
            local state = contents:Get(index)
            if i == 1 then
                state:SetSubType(MattPack.Items.DeadLitter)
            else
                state:SetType(1000)
                state:SetVariant(5)
                state:SetSubType(0)
            end
        end
        sfx:Play(SoundEffect.SOUND_FAMINE_BURST, 1)
        sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1)
        sfx:Play(SoundEffect.SOUND_DEATH_REVERSE, 1.75)
        sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_2, 1, nil, nil, 1.5)
        Isaac.CreateTimer(function()
            sfx:Play(SoundEffect.SOUND_POWERUP1, .5, nil, nil, .5)
        end, 15)
        game:SetColorModifier(ColorModifier(.75, 0, 0, .25, 0, 1), true, .75)
        Isaac.CreateTimer(function()
            game:GetRoom():UpdateColorModifier(true, true, .1)
        end, 5)
        mod.animData[player:GetPlayerIndex()] = {1, 125}
        game:ShakeScreen(5)
        return {Discharge = false}
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.dlTransform, CollectibleType.COLLECTIBLE_MOVING_BOX)

function mod:dlSpawn(ent)
    if ent.SubType == MattPack.Items.DeadLitter then
        local isFromBox = false
        for _,player in ipairs(PlayerManager.GetPlayers()) do
            local contents = player:GetMovingBoxContents ()
            for i = 0, #contents - 1 do
                local item = contents:Get(i)
                local type = item:GetSubType()
                if type == MattPack.Items.DeadLitter then
                    isFromBox = true
                end
            end
        end
        if isFromBox then
            Isaac.CreateTimer(function()
                local effect = Isaac.Spawn(1000, 2, 5, ent.Position + Vector(0, -35), Vector.Zero, nil)
                effect:GetSprite().PlaybackSpeed = .75
                effect.SpriteScale = Vector.One * 1.25
                for i = 0, math.random(3, 6) do
                    Isaac.Spawn(1000, 5, 0, ent.Position, RandomVector():Resized(math.random(1, 5)), nil)
                end
                sfx:Play(SoundEffect.SOUND_BABY_BRIM, 1.25, nil, nil, .66) -- my craft
                sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, .75)
                sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF_2, .75, nil, nil, 1.5)
                sfx:Play(SoundEffect.SOUND_JELLY_BOUNCE, 1.25, nil, nil, .66)
            end, 0)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.dlSpawn, 100)

mod.skipNext = nil
function mod:dlTransformHud(player, slot, offset)
    if not mod.skipNext then
        local index = player:GetPlayerIndex()
        local animData = mod.animData[index]
        if animData then -- yeah
            local fadeSpeed = .5
            local scaleSpeed = .5
            animData[1] = animData[1] + fadeSpeed
            animData[2] = animData[2] - scaleSpeed
            local opacity = animData[1] / 6
            local scale = math.max(1, animData[2] / 100)
            if opacity >= 30 then
                mod.animData[index] = nil
                return
            elseif opacity >= 15 then
                animData[1] = animData[1] + (fadeSpeed * 1.5)
                opacity = -opacity + 30
            else
                opacity = opacity
            end
            mod.skipNext = true
            hud:GetPlayerHUD(index):RenderActiveItem(slot, offset / scale, opacity, scale)
            mod.skipNext = nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, mod.dlTransformHud)

function mod:dlCompat()
    if not mod.DeadLitterInitialized then -- Run once per mod init
        local config = Isaac.GetItemConfig()
        mod.DeadLitterInitialized = true
        for i = 1, config:GetCollectibles().Size - 1 do
            local config = config:GetCollectible(i)
            if config then
                for _,name in ipairs(mod.DeadLitterCatNames) do
                    local nameUpper = config.Name:upper()
                    if string.find(nameUpper, name:upper()) then
                        for _,blName in ipairs(mod.DeadLitterCatNameBlacklist) do
                            if string.find(nameUpper, blName:upper()) then
                                goto skip
                            end
                        end
                        mod.DeadLitterCatBits[i] = true
                        ::skip::
                        break
                    end
                end
            end
        end
        if EID then
            EID:addDescriptionModifier("DeadLitterCatBitInfo", 
            function(objectDescription)
                if MattPack.Config.EIDHintsEnabled then
                    if objectDescription.ObjType == 5 
                    and objectDescription.ObjVariant == 100 
                    and mod.DeadLitterCatBits[objectDescription.ObjSubType]
                    and PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOVING_BOX) then
                        return true
                    end
                end
            end, 
            function(descObject)
                EID:appendToDescription(descObject, "#{{MPLazyWorm}} " .. "Can be transformed by packing 3 {{Collectible" .. CollectibleType.COLLECTIBLE_GUPPYS_PAW .. "}} {{ColorYellow}}cat parts{{CR}} into {{Collectible" .. CollectibleType.COLLECTIBLE_MOVING_BOX .. "}} {{ColorYellow}}Moving Box{{CR}}")
                return descObject
            end)
        end
        
        -- CR
        if communityRemix then
            EID:assignTransformation("collectible", MattPack.Items.DeadLitter, "Tammy")
            communityRemix.TransformationItem[MattPack.Items.DeadLitter] = {communityRemix.NullItemID.ID_TAMMY}
        end
    end
    
end
mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, mod.dlCompat)
mod:dlCompat()

