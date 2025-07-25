local Chariot = {}

local utility = JosephMod.utility
local enums = JosephMod.enums

local RECOMMENDED_SHIFT_IDX = 35
local chargeBarOffset = Vector(18,7)
local chariotActived = {false, false, false, false}
local slipFrames = 0
local maxSlipFrames = 5



---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function Chariot:initChariot(player, card)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, Chariot.initChariot, Card.CARD_CHARIOT)

---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function Chariot:removeChariot(player, card, slot)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, Chariot.removeChariot, Card.CARD_CHARIOT)


function Chariot:ChariotNewRoom()
    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        local playerIndex = TSIL.Players.GetPlayerIndex(player)

        chariotActived[playerIndex] = false
        local data = utility:GetData(player, "ChariotCharge")
        data.Charge = 0
    end
end
JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, Chariot.ChariotNewRoom)


function Chariot:PlayerUpdate(player)
    local room = Game():GetRoom()
    if not room:IsFirstVisit() then return end
    if not utility:HasEnchantment(player, Card.CARD_CHARIOT) then return end

    local playerIndex = TSIL.Players.GetPlayerIndex(player)

    local data = utility:GetData(player, "ChariotCharge")

    data.Chargebar = data.Chargebar or JosephMod.Chargebar()
    data.Charge = data.Charge or 0

    if chariotActived[playerIndex] == true then
        if player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN) >= 1 then
            data.Charge = 100
        else
            data.Charge = 0
        end
    else
        if player:GetMovementDirection() ~= -1 then
            if player.Velocity:Length() >= player.MoveSpeed*2 then
                slipFrames = math.max(0, slipFrames-1)
                data.Charge = math.min(100, data.Charge + 0.5)
            elseif slipFrames < maxSlipFrames then
                slipFrames = math.min(maxSlipFrames, slipFrames+1)
                data.Charge = math.min(100, data.Charge + 0.5)
            else
                data.Charge = math.max(0, data.Charge - 3)
            end

        else
            data.Charge = math.max(0, data.Charge - 3)
            slipFrames = maxSlipFrames
        end
    end

    data.Chargebar:SetCharge(data.Charge, 100)


    if data.Charge == 100 and chariotActived[playerIndex] ~= true then
        player:UseCard(Card.CARD_CHARIOT, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        chariotActived[playerIndex] = true
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Chariot.PlayerUpdate)


function Chariot:Render()
    local room = Game():GetRoom()
    if not room:IsFirstVisit() then return end

    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        Chariot:PlayerRender(player)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_RENDER, Chariot.Render)


function Chariot:PlayerRender(player)
    -- Isaac.RenderText(player.Velocity:Length(), 60, 60, 1, 1, 1, 1)
    -- Isaac.RenderText(player.MoveSpeed*0.75, 60, 80, 1, 1, 1, 1)
    if not utility:HasEnchantment(player, Card.CARD_CHARIOT) then return end
    
    local data = utility:GetData(player, "ChariotCharge")

    data.Chargebar = data.Chargebar or JosephMod.Chargebar()

    data.Chargebar:TryLoad("gfx/ui/chariot_chargebar.anm2")
    data.Chargebar:Render(Isaac.WorldToScreen(player.Position) + chargeBarOffset)
end
