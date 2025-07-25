local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx
local SaveManager = mod.SaveManager


if EID then
    EID:addCollectible(MattPack.Items.BoulderBottom, "All temporary effects, such as ones granted by actives, trinkets, and consumables, will never end#This only excludes invincibility and revival effects#Item effects will never be removed#Does not get removed upon self-rerolling")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_ROCK_BOTTOM, 'using {{Card' .. Card.RUNE_HAGALAZ .. "}} {{ColorYellow}}Hagalaz{{CR}}", true)
end

function mod:updateItems2()
    mod.lastData = {}
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_END, CallbackPriority.LATE, mod.updateItems2)
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.LATE, mod.updateItems2)

mod.lastData = {}
mod.bbEffectBlacklist = {}
mod.bbExtraLivesBlacklist = {}

function mod.setBBBlacklist()
    if MattPack.Config.bbBlacklist then
        mod.bbEffectBlacklist = { -- Exists, isNull
            [CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN] = {true},
            [CollectibleType.COLLECTIBLE_MARS] = {true},
            [CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS] = {true},
            [CollectibleType.COLLECTIBLE_UNICORN_STUMP] = {true},
            [CollectibleType.COLLECTIBLE_GAMEKID] = {true},
            [CollectibleType.COLLECTIBLE_TAURUS] = {true},
            [CollectibleType.COLLECTIBLE_DARK_ARTS] = {true},
            [CollectibleType.COLLECTIBLE_HOLY_MANTLE] = {true},
            [CollectibleType.COLLECTIBLE_MEGA_MUSH] = {true},
            [CollectibleType.COLLECTIBLE_HOW_TO_JUMP] = {true},
            [CollectibleType.COLLECTIBLE_SUMPTORIUM] = {true},
            [CollectibleType.COLLECTIBLE_SCAPULAR] = {true},
            [CollectibleType.COLLECTIBLE_CAMO_UNDIES] = {true},
            [NullItemID.ID_REVERSE_CHARIOT] = {true, true},
            [NullItemID.ID_REVERSE_CHARIOT_ALT] = {true, true},
            [NullItemID.ID_REVERSE_STARS] = {true, true},
            [NullItemID.ID_JACOBS_CURSE] = {true, true},
            [NullItemID.ID_HOLY_CARD] = {true, true},
            [NullItemID.ID_TOOTH_AND_NAIL] = {true, true},
        }
    else
        mod.bbEffectBlacklist = { -- Only include softlocks
            [CollectibleType.COLLECTIBLE_HOW_TO_JUMP] = {true},
            [NullItemID.ID_REVERSE_STARS] = {true, true},
            [NullItemID.ID_JACOBS_CURSE] = {true, true},
        }
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, mod.setBBBlacklist)

local toSaveTo = {'playerTearFlags', 'effectsList'}


function mod.saveBBData()
    local runSave = SaveManager.GetRunSave()
    if not runSave then
        runSave = {}
    end
    for _,name in ipairs(toSaveTo) do
        if not runSave[name] then
            runSave[name] = {}
        end
    end
    for _,player in ipairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(MattPack.Items.BoulderBottom) then
            local hash = tostring(GetPtrHash(player))
            runSave.playerTearFlags[hash] = player.TearFlags
            local effectsList = {}
            local tempEffects = player:GetEffects():GetEffectsList()
            effectsList = runSave.effectsList[hash] or {}
            for i = 0, tempEffects.Size - 1 do
                local effect = tempEffects:Get(i)
                if effect then
                    local isNull = effect.Item:IsNull()
                    local itemID = effect.Item.ID
                    local entry = mod.bbEffectBlacklist[itemID]
                    if isNull then
                        if entry and entry[2] then
                            break
                        end
                    else
                        if entry and not entry[2] then
                            break
                        end
                    end
                    for _,effect2 in ipairs(effectsList) do
                        if effect2[1] == isNull and effect2[2] == itemID then
                            goto skip
                        end
                    end
                    table.insert(effectsList, {isNull, itemID})
                    ::skip::
                end
            end
            runSave.effectsList[hash] = effectsList
        end
    end
end

function mod.loadBBData(player)
    local runSave = SaveManager.GetRunSave()
    if not runSave then
        runSave = {}
    end
    for _,name in ipairs(toSaveTo) do
        if not runSave[name] then
            runSave[name] = {}
        end
    end
    local data = player:GetData()
    local hash = tostring(GetPtrHash(player))
    local fallbackList = {[hash] = {}}
    player.TearFlags = runSave.playerTearFlags[hash] or player.TearFlags
    data.effectsToAdd = (runSave.effectsList or fallbackList)[hash] 
end

function mod:bbSaveData(shouldSave)
    if shouldSave and PlayerManager.AnyoneHasCollectible(MattPack.Items.BoulderBottom) then
        mod.saveBBData()
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.LATE, mod.bbSaveData)

function mod:bbLoadData(player)
    mod.loadBBData(player)
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.LATE, mod.bbLoadData)

function mod:updateItems(player)
    if player:HasCollectible(MattPack.Items.BoulderBottom) and (not game:IsPaused()) and (not game:GetRoom():HasCurseMist()) then
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM) then
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM, 1)
        end
        local data = player:GetData()
        
        data.maxMegaBlastDuration = math.max(data.maxMegaBlastDuration or 0, player:GetMegaBlastDuration())
        if data.maxMegaBlastDuration > 0 then
            player:SetMegaBlastDuration(data.maxMegaBlastDuration)
        end
        data.maxRedStewDuration = math.max(data.maxRedStewDuration or 0, player:GetRedStewBonusDuration())
        if data.maxRedStewDuration > 0 then
            player:GetRedStewBonusDuration(data.maxRedStewDuration)
        end

        player.TearFlags = player.TearFlags | (data.lastTearFlags or 0)
        data.lastTearFlags = player.TearFlags
        local effects = player:GetEffects()
        local tempEffects = effects:GetEffectsList()
        for i = 0, tempEffects.Size - 1 do
            local effect = tempEffects:Get(i)
            if effect then
                local isNull = effect.Item:IsNull()
                local itemID = effect.Item.ID
                local minCooldown = 0
                local entry = mod.bbEffectBlacklist[itemID]
                if isNull then
                    if entry and entry[2] then
                        -- minCooldown = 60
                        goto skip
                    end
                else
                    if entry and not entry[2] then
                        -- minCooldown = 60
                        goto skip
                    end
                end
                if effect.Cooldown <= minCooldown then
                    effect.Cooldown = 300
                end
            end
        end
        ::skip::

        if not data.lastSpriteScale then
            data.lastSpriteScale = Vector.Zero
        end
        player.SpriteScale = Vector(math.max(player.SpriteScale.X, data.lastSpriteScale.X), math.max(player.SpriteScale.Y, data.lastSpriteScale.Y))
        data.lastSpriteScale = player.SpriteScale

        if data.effectsToAdd and #data.effectsToAdd > 0 then -- Effects
            local toClear = {}
            for i,itemData in pairs(data.effectsToAdd) do
                local isNull = itemData[1]
                local type = itemData[2]
                if isNull then
                    if not effects:HasNullEffect(type) then
                        if not (mod.bbEffectBlacklist[type] and mod.bbEffectBlacklist[type][2]) then
                            player:AddNullItemEffect(type, true)
                        end
                        table.insert(toClear, i)
                    end
                else
                    if not (mod.bbEffectBlacklist[type] and not mod.bbEffectBlacklist[type][2]) then
                        if not player:GetEffects():HasCollectibleEffect (type) then
                            player:AddCollectibleEffect(type, true)
                        end
                        table.insert(toClear, i)
                    end
                end
            end
            for _,index in ipairs(toClear) do
                data.effectsToAdd[index] = nil
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, CallbackPriority.LATE, mod.updateItems)

mod.skipRemovalCheck = {}

function mod:bbReAddCollectible(player, type)
    if (player:HasCollectible(MattPack.Items.BoulderBottom) and Isaac.GetItemConfig():GetCollectible(type).Type ~= ItemType.ITEM_ACTIVE) then
        if not mod.skipRemovalCheck[type] then
            local func = function()
                local extraLivesPre = player:GetExtraLives()
                player:AddCollectible(type, nil, false)
                if MattPack.Config.bbBlacklist then
                    if player:GetExtraLives() > extraLivesPre then
                        mod.skipRemovalCheck[type] = true
                        player:RemoveCollectible(type, nil, nil, true)
                    end
                end
            end
            if player:GetPlayerType() == PlayerType.PLAYER_EDEN_B then
                Isaac.CreateTimer(function()
                    func()
                    if not player:HasCollectible(MattPack.Items.BoulderBottom) then
                        player:AddCollectible(MattPack.Items.BoulderBottom)
                    end
                end, 0, 0)
            else
                func()
            end
        else
            mod.skipRemovalCheck[type] = nil
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, CallbackPriority.LATE, mod.bbReAddCollectible)

function mod:bbReAddEffect(player, item)
    if player:HasCollectible(MattPack.Items.BoulderBottom) then
        local data = player:GetData()
        local type = item.ID
        if not data.effectsToAdd then
            data.effectsToAdd = {}
        end
        if item:IsNull() then
            table.insert(data.effectsToAdd, {true, type})
        else
            table.insert(data.effectsToAdd, {false, type})
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, CallbackPriority.LATE, mod.bbReAddEffect)

function mod:bbAddModelingClayEffect()
    for _,player in ipairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(MattPack.Items.BoulderBottom) then
            for _,type in ipairs({player:GetModelingClayEffect(), player:GetMetronomeCollectibleID()}) do
                if type and type > 0 then
                    local data = player:GetData()
                    if not data.effectsToAdd then
                        data.effectsToAdd = {}
                    end
                    table.insert(data.effectsToAdd, {false, type})
                end
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_NEW_ROOM, CallbackPriority.LATE, mod.bbAddModelingClayEffect)
mod:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_INIT, CallbackPriority.LATE, mod.bbAddModelingClayEffect)

function mod:bbHeight(player)
    if player:HasCollectible(MattPack.Items.BoulderBottom) then
        player.TearHeight = -65 * player.SpriteScale.Y + (player.TearFallingSpeed)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.bbHeight, CacheFlag.CACHE_RANGE)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.bbHeight, CacheFlag.CACHE_SIZE)

function mod:bbSwallowTrinkets(ent, col)
    local player = col:ToPlayer()
    if player and player:HasCollectible(MattPack.Items.BoulderBottom) then
        ent:GetSprite():Play("Collect")
        ent:Die()
        sfx:Play(SoundEffect.SOUND_VAMP_GULP)
        player:AddSmeltedTrinket(ent.SubType)
        return {Collide = false, SkipCollisionEffects = true}
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, mod.bbSwallowTrinkets, 350)

function mod:bbSwallowHeldTrinkets(type, _, _, _, _, player)
    if type == MattPack.Items.BoulderBottom then
        local toRemove = {}
        for i = 0, 1 do
            local trinket = player:GetTrinket(i)
            if trinket ~= 0 then
                player:AddSmeltedTrinket(trinket)
                table.insert(toRemove, trinket)
            end
        end
        local wasGulped = false
        for _,trinket in ipairs(toRemove) do
            player:TryRemoveTrinket(trinket)
            wasGulped = true
        end
        if wasGulped then
            sfx:Play(SoundEffect.SOUND_VAMP_GULP)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, mod.bbSwallowHeldTrinkets)

local trinketAdded = nil
function mod:bbSwallowHeldTrinketsDelayed(player)
    if player:HasCollectible(MattPack.Items.BoulderBottom) then
        if not trinketAdded then
            Isaac.CreateTimer(function()
                mod.bbSwallowHeldTrinkets(nil, MattPack.Items.BoulderBottom, nil, nil, nil, nil, player) 
            end, 1, 1)
            trinketAdded = true
        else
            Isaac.CreateTimer(function()
                trinketAdded = nil
             end, 2, 1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, mod.bbSwallowHeldTrinketsDelayed)

-- function mod:bbCancelCostumeRemove(_, player)
--     if player:HasCollectible(MattPack.Items.BoulderBottom) then
--         return true
--     end
-- end
-- mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_REMOVE_COSTUME, mod.bbCancelCostumeRemove)


-- Unlock condition
function mod:bbUnlockCond()
    local bb = Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_ROCK_BOTTOM) or {}
    for _,pedestal in ipairs(bb) do
        local targetFunc = function()
            sfx:Play(SoundEffect.SOUND_EXPLOSION_STRONG, 1.5)
            sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1.5)
            for i = 0, math.random(8, 12) do
                local particle = Isaac.Spawn(1000, 4, 0, pedestal.Position - Vector(0, 15) + RandomVector():Resized(math.random(0, 30)), RandomVector():Resized(math.random(0, 15)), pedestal)
                particle:Update()
            end
        end
        mod.switchItem(pedestal, MattPack.Items.BoulderBottom, nil, targetFunc)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.bbUnlockCond, Card.RUNE_HAGALAZ)

function mod:bbCancelGiantbook()
    if #(Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_ROCK_BOTTOM) or {}) > 0 then
        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_ITEM_OVERLAY_SHOW, mod.bbCancelGiantbook, Giantbook.HAGALAZ)