local CuppaJoe = {}

local enums = JosephMod.enums
local coffeya = enums.Trinkets.CUPPA_JOE


TSIL.SaveManager.AddPersistentVariable(
    JosephMod,
    "CuppaJoeSpawned",
    0,
    TSIL.Enums.VariablePersistenceMode.RESET_RUN,
    false
)

TSIL.SaveManager.AddPersistentPlayerVariable(
    JosephMod,
    "CuppaJoeItem",
    nil,
    TSIL.Enums.VariablePersistenceMode.RESET_RUN,
    false
)



---@param player EntityPlayer
function CuppaJoe:AddInnateCupItem(player, item)
    TSIL.SaveManager.SetPersistentPlayerVariable(JosephMod, "CuppaJoeItem", player, item)
    player:AddInnateCollectible(item, 1)
end

function CuppaJoe:RemoveInnateCupItem(player)
    local oldItem = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "CuppaJoeItem", player)
    if oldItem then
        player:AddInnateCollectible(oldItem, -1)
        TSIL.SaveManager.SetPersistentPlayerVariable(JosephMod, "CuppaJoeItem", player, nil)
    end
end


---@param player EntityPlayer
function CuppaJoe:PickupCup(player, trinketType, firstTime)
    local lastItem = CuppaJoe:GetLastPassive(player)
    if lastItem then
        CuppaJoe:RemoveInnateCupItem(player)
        CuppaJoe:AddInnateCupItem(player, lastItem)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, CuppaJoe.PickupCup, coffeya)


---@param player EntityPlayer
function CuppaJoe:DropCup(player, trinketType)
    if player:HasTrinket(coffeya) then return end

    CuppaJoe:RemoveInnateCupItem(player)
end
JosephMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, CuppaJoe.DropCup, coffeya)


---@param player EntityPlayer
function CuppaJoe:PickupItem(_, _, _, _, _, player)
    if not player:HasTrinket(coffeya) then return end
    local lastItem = CuppaJoe:GetLastPassive(player)
    if lastItem then
        CuppaJoe:RemoveInnateCupItem(player)
        CuppaJoe:AddInnateCupItem(player, lastItem)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CuppaJoe.PickupItem)


---@param player EntityPlayer
function CuppaJoe:RemovedItem(player, item)
    if not player:HasTrinket(coffeya) then return end

    local oldItem = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "CuppaJoeItem", player)
    if oldItem == item then
        CuppaJoe:RemoveInnateCupItem(player)
        Isaac.CreateTimer(function()
            local lastItem = CuppaJoe:GetLastPassive(player)
            if lastItem then
                CuppaJoe:AddInnateCupItem(player, lastItem)
            end
        end, 1, 1, true)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, CuppaJoe.RemovedItem)


JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_GAME_STARTED_REORDERED, function (isContinued)
    if not isContinued then return end

    JosephMod.Schedule(1, function ()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if player:HasTrinket(coffeya) then
                local lastItem = CuppaJoe:GetLastPassive(player)
                if lastItem then
                    CuppaJoe:AddInnateCupItem(player, lastItem)
                end
            end
        end
    end,{})
end)


function CuppaJoe:FindFirstPlayerWithEmptyTrinketSlot()
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if player:GetTrinket(0) == 0 then return player end    
        if player:GetMaxTrinkets() > 1 and player:GetTrinket(1) == 0 then return player end
    end
    return nil
end


local cofeeyaSpawned = false
function CuppaJoe:GetTrinket(trinketType)
    if trinketType ~= coffeya then return end
    cofeeyaSpawned = true
end
JosephMod:AddCallback(ModCallbacks.MC_GET_TRINKET, CuppaJoe.GetTrinket)


function CuppaJoe:PickupInit(pickup)
    if pickup.SubType ~= coffeya then return end
    if not cofeeyaSpawned then return end
    cofeeyaSpawned = false

    pickup:Remove()
    local cupSpawned = TSIL.SaveManager.GetPersistentVariable(JosephMod, "CuppaJoeSpawned")
    cupSpawned = cupSpawned + 1
    TSIL.SaveManager.SetPersistentVariable(JosephMod, "CuppaJoeSpawned", cupSpawned)
end
JosephMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, CuppaJoe.PickupInit, PickupVariant.PICKUP_TRINKET)


function CuppaJoe:NewRoom()
    local cupSpawned = TSIL.SaveManager.GetPersistentVariable(JosephMod, "CuppaJoeSpawned")
    if cupSpawned <= 0 then return end

    cupSpawned = cupSpawned - 1
    TSIL.SaveManager.SetPersistentVariable(JosephMod, "CuppaJoeSpawned", cupSpawned)

    local player = CuppaJoe:FindFirstPlayerWithEmptyTrinketSlot()
    if player then
        player:AddTrinket(coffeya)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, CuppaJoe.NewRoom)


---@param player EntityPlayer
function CuppaJoe:GetLastPassive(player)
    local history = player:GetHistory():GetCollectiblesHistory()
    local config
    Isaac.GetPlayer():GetHistory():GetCollectiblesHistory()[1]:GetItemID()
    for i = #history, 1, -1 do
        if not history[i]:IsTrinket() then
            local id = history[i]:GetItemID()

            config = config or Isaac.GetItemConfig()

            if config:GetCollectible(id).Type ~= ItemType.ITEM_ACTIVE then
                return id
            end
        end
    end
    return nil
end

JosephMod.CuppaJoe = CuppaJoe