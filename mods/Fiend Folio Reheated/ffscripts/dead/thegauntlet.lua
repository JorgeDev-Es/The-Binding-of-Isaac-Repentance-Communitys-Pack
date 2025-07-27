local mod = FiendFolio
local game = Game()
local map = include("resources.luarooms.ff_bossrush_challenge")
local mapList = StageAPI.RoomsList("FFTheGauntlet", map)
local doOnFirstUpdate
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
    doOnFirstUpdate = nil
    if not continued and game.Challenge == FiendFolio.challenges.theGauntlet then
        doOnFirstUpdate = true
        local player = Isaac.GetPlayer()
        player:AddBombs(-1)
        player:AddCoins(3)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if doOnFirstUpdate then
        local map = StageAPI.CreateMapFromRoomsList(mapList, nil, {NoChampions = true})
        StageAPI.InitCustomLevel(map, true)
        doOnFirstUpdate = nil
    end

    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local room = game:GetRoom()
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid and (grid.Desc.Type == GridEntityType.GRID_TRAPDOOR or grid.Desc.Type == GridEntityType.GRID_STAIRS) then -- i hate you crawlspaces!!
                room:RemoveGridEntity(i, 0, false)
            end
        end

        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom and currentRoom.Layout.Name == "Cacophobia Gateway" then
            game:Darken(1, 30)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        for _, item in ipairs(items) do
            if item.FrameCount <= 1 then
                game:GetHUD():ShowItemText("Whoops", "Looks like you dropped something!")
                item:Remove()
            end
        end
    end
end, CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING)

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, inputHook, action)
    if game.Challenge == FiendFolio.challenges.theGauntlet and entity and entity.Type == EntityType.ENTITY_PLAYER then
        if action == ButtonAction.ACTION_PILLCARD then
            local player = entity:ToPlayer()
            if player:GetCard(0) == Card.CARD_ACE_OF_HEARTS then
                local room = game:GetRoom()
                if not room:IsClear() then
                    if inputHook == InputHook.GET_ACTION_VALUE then
                        return 0
                    else
                        return false
                    end
                end
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            local sadOnions = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_SAD_ONION)
            local setOnionItem
            if currentRoom.Layout.Name == "Secreter Shop" then
                setOnionItem = FiendFolio.ITEM.COLLECTIBLE.WHITE_PEPPER
            elseif currentRoom.Layout.Name == "How'd You Get Here?" then
                setOnionItem = FiendFolio.ITEM.COLLECTIBLE.FIEND_FOLIO
            end

            if setOnionItem then
                for _, onion in ipairs(sadOnions) do
                    local price = onion:ToPickup().Price
                    onion:ToPickup():Morph(onion.Type, onion.Variant, setOnionItem, true, true, true)
                    onion:ToPickup().AutoUpdatePrice = false
                    onion:ToPickup().Price = price
                end
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        return PillEffect.PILLEFFECT_POWER
    end
end)

-- No heart drops from bosses in this one!!
mod:AddPriorityCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, CallbackPriority.EARLY, function(_, id, var, sub, pos, vel, spawner, seed)
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        if id == EntityType.ENTITY_PICKUP then
            local room = game:GetRoom()
            local bossRoom = room:GetType() == RoomType.ROOM_BOSS
            local delete
            if bossRoom
            and spawner
            and spawner.Type >= 10
            and (var == PickupVariant.PICKUP_HEART
            or (var >= FiendFolio.PICKUP.VARIANT.IMMORAL_HEART and var <= FiendFolio.PICKUP.VARIANT.IMMORAL_HEART)
            or (var >= FiendFolio.PICKUP.VARIANT.MORBID_HEART and var <= FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART))
            then
                delete = true
            end

            if var == PickupVariant.PICKUP_TRINKET
            and sub ~= TrinketType.TRINKET_PERFECTION then
                delete = true
            end

            if (not bossRoom or not room:IsClear()) and game:GetRoom():GetFrameCount() > 0 and (not spawner or spawner.Type ~= EntityType.ENTITY_PLAYER) then
                if var == PickupVariant.PICKUP_BOMB then
                    if #Isaac.FindByType(FiendFolio.FF.Buck.ID, FiendFolio.FF.Buck.Var) == 0 then
                        delete = true
                    end
                elseif var ~= PickupVariant.PICKUP_COLLECTIBLE then
                    delete = true
                else
                    local isBadgeOrReward = sub == FiendFolio.ITEM.COLLECTIBLE.YOUR_ETERNAL_REWARD
                    for _, collect in ipairs(FiendFolio.RewardBadges) do
                        if sub == collect then
                            isBadgeOrReward = true
                            break
                        end
                    end

                    if not isBadgeOrReward then
                        delete = true
                    end
                end
            end

            if var == 370 then --NEVER delete the trophy
                delete = false
            end

            if delete then
                return {
                    1000,
                    StageAPI.E.DeleteMeEffect.V,
                    0,
                    seed
                }
            elseif (var == PickupVariant.PICKUP_HEART and sub == HeartSubType.HEART_GOLDEN) then -- no golden ace of hearts
                return {
                    id,
                    var,
                    HeartSubType.HEART_SOUL
                }
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        return 0
    end
end)

local badgesNeeded = {
    Ch2 = {FiendFolio.ITEM.COLLECTIBLE.SPATULA_BADGE, FiendFolio.ITEM.COLLECTIBLE.COMMISSIONED_BADGE, FiendFolio.ITEM.COLLECTIBLE.MYSTERY_BADGE},
    Ch3 = {FiendFolio.ITEM.COLLECTIBLE.BABY_BADGE, FiendFolio.ITEM.COLLECTIBLE.DRIPPING_BADGE},
    Ch4 = {FiendFolio.ITEM.COLLECTIBLE.HAUNTED_BADGE}
}

local function hasAllItems(player, list)
    for _, id in ipairs(list) do
        if not player:HasCollectible(id) then
            return false
        end
    end

    return true
end

local badgeDoorStates = {
    Default = "Hidden",
    Hidden = {
        Anim = "Hidden",
        Triggers = {
            EnteredThrough = {
                State = "Opened",
                Anim = "Opened"
            },
            DadsKey = {
                State = "Opened",
                ForcedOpen = true,
                Check = function(door, data, sprite, doorData, doorGridData)
                    local leadsToMap = doorGridData.LevelMapID
                    local leadsTo = doorGridData.LeadsTo
                    local levelMap = StageAPI.LevelMaps[leadsToMap]
                    local leadsToRoom = levelMap:GetRoom(leadsTo)

                    if leadsToRoom then
                        local player = Isaac.GetPlayer()
                        if leadsToRoom.Layout.Name == "How'd You Get Here?" then
                            return hasAllItems(player, badgesNeeded.Ch2)
                        elseif leadsToRoom.Layout.Name == "Take This, You'll Need It" then
                            return hasAllItems(player, badgesNeeded.Ch3)
                        elseif leadsToRoom.Layout.Name == "The Collector's Gambit" then
                            return hasAllItems(player, badgesNeeded.Ch4)
                        end
                    end

                    return true
                end
            }
        }
    },
    Closed = StageAPI.SecretDoorClosedState,
    Opened = StageAPI.SecretDoorOpenedState
}

local badgeDoor = StageAPI.CustomStateDoor("FFGauntletBadgeDoor", "gfx/grid/door_08_holeinwall.anm2", badgeDoorStates, nil, nil, StageAPI.SecretDoorOffsetsByDirection)

StageAPI.AddCallback("FiendFolio", "PRE_LEVELMAP_SPAWN_DOOR", 1, function(slot, doorData, levelRoom, targetLevelRoom, roomData, levelMap)
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        if targetLevelRoom.RoomType == RoomType.ROOM_SECRET then
            StageAPI.SpawnCustomDoor(slot, doorData.ExitRoom, levelMap, "FFGauntletBadgeDoor", nil, doorData.ExitSlot, "Secret")
            return true
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, p, collider, low)
    if game.Challenge == FiendFolio.challenges.theGauntlet and not p:IsShopItem() then
        return false
    end
end, PickupVariant.PICKUP_BOMB)

--[[
FiendFolio.savedata.gauntletPlaceboCoins = 0

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, p)
    if p.Type == 5 and p.Variant == 20 and game.Challenge == FiendFolio.challenges.theGauntlet then
        --print(p.Price)
        if not (Game():GetRoom():GetType() == 5 and Game():GetRoom():IsClear()) then
            p:GetData().gauntletPlaceboCoin = true
        end
    end
end)

local function gauntletUpdatePrices()
    local pickups = Isaac.FindByType(5, -1, -1, false, false)
    for _, p in ipairs(pickups) do
        p = p:ToPickup()
        if p.Price and p.Price > 0 then
            p.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            for i=1, FiendFolio.savedata.gauntletPlaceboCoins do
                mod.scheduleForUpdate(function()
                    if p:Exists() then
                        p.Price = p.Price+1
                        p.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    end
                end, 30+(i*3))
            end
            mod.scheduleForUpdate(function()
                if p:Exists() then p.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY end
            end, 30+(FiendFolio.savedata.gauntletPlaceboCoins+1)*3)
        end
    end
    for i=1, FiendFolio.savedata.gauntletPlaceboCoins do
        mod.scheduleForUpdate(function()
            pickups = Isaac.FindByType(5, -1, -1, false, false)
            for _, p in ipairs(pickups) do
                p = p:ToPickup()
                if p.Price and p.Price > 0 then
                    FiendFolio.savedata.gauntletPlaceboCoins = FiendFolio.savedata.gauntletPlaceboCoins-1
                    SFXManager():Play(mod.Sounds.CursedPennyPositive, 1, 0, false, 1)
                    break
                end
            end
        end, 30+(i*3))
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local c = 0
        local coins = Isaac.FindByType(5, 20, -1, false, false)
        for _, coin in ipairs(coins) do
            c = c+1
            if c>7 then
                coin:GetData().gauntletPlaceboCoin = true
            end
        end
        --print("p: " .. FiendFolio.savedata.gauntletPlaceboCoins)
        if FiendFolio.savedata.gauntletPlaceboCoins > 0 then
            gauntletUpdatePrices()
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, p, collider, low)
    if game.Challenge == FiendFolio.challenges.theGauntlet and p:GetData().gauntletPlaceboCoin then
        FiendFolio.savedata.gauntletPlaceboCoins = FiendFolio.savedata.gauntletPlaceboCoins + p:GetCoinValue()
    end
end, 20)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider, low)
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        if pickup.Price and pickup.Price > 0 and collider.Type == 1 and collider:ToPlayer():GetNumCoins() >= pickup.Price then
            mod.scheduleForUpdate(function()

                if pickup:Exists() then return end
                
                local rPrice
                if pickup.Variant == 100 then
                    rPrice = pickup.Price - 15
                elseif pickup.Variant == 10 and pickup.SubType == 1 then
                    rPrice = pickup.Price - 3
                else
                    rPrice = pickup.Price - 5
                end

                local pickups = Isaac.FindByType(5, -1, -1, false, false)
                for _, p in ipairs(pickups) do
                    p = p:ToPickup()
                    if p.Price and p.Price > 0 then
                        p.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        for i=1, rPrice do
                            mod.scheduleForUpdate(function()
                                if p:Exists() then
                                    p.Price = p.Price-1
                                    p.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                                end
                            end, 5+i)
                        end
                        mod.scheduleForUpdate(function()
                            if p:Exists() then p.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY end
                        end, 5+(rPrice+1))
                    end
                end
            end, 1)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local pickups = Isaac.FindByType(5, -1, -1, false, false)
        for _, p in ipairs(pickups) do
            p = p:ToPickup()
            if p.Price then
                p:GetData().couponPrevPrice = p.Price
            end
        end
    end
end, 521)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    if game.Challenge == FiendFolio.challenges.theGauntlet then
        local pickups = Isaac.FindByType(5, -1, -1, false, false)
        for _, p in ipairs(pickups) do
            p = p:ToPickup()
            if p.Price ~= p:GetData().couponPrevPrice then
                local rPrice
                if p.Variant == 100 then
                    rPrice = 15
                elseif p.Variant == 10 and p.SubType == 1 then
                    rPrice = 3
                else
                    rPrice = 5
                end
                FiendFolio.savedata.gauntletPlaceboCoins = FiendFolio.savedata.gauntletPlaceboCoins + rPrice
                gauntletUpdatePrices()
            end
        end
    end
end, 521)]]