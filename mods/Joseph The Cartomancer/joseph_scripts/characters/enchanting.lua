local mod = JosephMod

---Duration for pressed action to count as a tap basically
local WINDOW = 20
---How long you have to hold to enchant
local MAX_CHARGE = 30 * 3
local SPRITE_OFFSET = Vector(-30, -52)

---@type table<integer, StupidJosephData>
local stupidData = {}

---@param player EntityPlayer
local function GetData(player)
    local idx = TSIL.Players.GetPlayerIndex(player)
    stupidData[idx] = stupidData[idx] or
    ---@class StupidJosephData
    ---@field Timer integer
    ---@field Holding boolean
    ---@field Override boolean
    ---@field Ugugugug ChargeBar
    ---@field Charge integer
    ---@field Activated boolean
    {
        Timer = 0,
        Holding = false,
        Override = false,
        Ugugugug = JosephMod.Chargebar(),
        Activated = false,
    }
    ---@type StupidJosephData
    return stupidData[idx]
end

---@param player EntityPlayer
local function CanHold(player)
    local card = player:GetCard(0)
    if card == Card.CARD_NULL then return false end

    return true
end

---@param player EntityPlayer
local function CanCharge(player)
    local card = player:GetCard(0)
    if card == Card.CARD_NULL then return false end

    local config = Isaac.GetItemConfig():GetCard(card)
    if not config or not mod.enums.CardAnims[card] then return false end

    return true
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function ()
    stupidData = {}
end)

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    local data = GetData(player)
    local canHold = CanHold(player)
    local q = Input.IsActionPressed(ButtonAction.ACTION_PILLCARD, player.ControllerIndex)
    local holding = q and canHold and not data.Activated

    if not q then
        data.Activated = false
    end

    data.Charge = data.Timer >= WINDOW and CanCharge(player) and (data.Charge or 0) + 1 or 0

    if canHold then
        data.Override = false

        if (not holding and data.Holding) or data.Charge >= MAX_CHARGE then
            if data.Timer <= WINDOW then
                data.Override = true
            end

            if data.Charge >= MAX_CHARGE then
                local card = player:GetCard(0)

                mod.josephCharacter:EnchantCard(
                    player,
                    card,
                    player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
                    and mod.utility:IsEnchantmentSlotEmpty(player, mod.enums.CardSlot.JOSEPH_BIRTHRIGHT)
                    and mod.enums.CardSlot.JOSEPH_BIRTHRIGHT
                    or mod.enums.CardSlot.JOSEPH_INNATE,
                    true
                )

                data.Activated = true
                holding = false
            end
        end
    else
        data.Override = nil
    end

    data.Timer = holding and data.Timer + 1 or 0
    data.Holding = holding
    data.Ugugugug:TryLoad("gfx/ui/card_chargebar.anm2")
    data.Ugugugug:SetCharge(data.Charge, MAX_CHARGE)
end)

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function (_, player)
    if player:GetPlayerType() ~= mod.enums.PlayerType.PLAYER_JOSEPH then return end
    local data = GetData(player)
    data.Ugugugug:Render(Isaac.WorldToScreen(player.Position + SPRITE_OFFSET))
end)

---@param entity Entity?
---@param id ButtonAction
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function (_, entity, _, id)
    if id ~= ButtonAction.ACTION_PILLCARD then return end

    local player = entity and entity:ToPlayer()
    if not player or player:GetPlayerType() ~= mod.enums.PlayerType.PLAYER_JOSEPH then return end

    return GetData(player).Override
end, InputHook.IS_ACTION_TRIGGERED)
-- kerkle