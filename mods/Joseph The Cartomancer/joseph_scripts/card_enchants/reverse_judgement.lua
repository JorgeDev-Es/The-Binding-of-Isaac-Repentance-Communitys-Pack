local ReverseJudgement = {}

local utility = JosephMod.utility
local enums = JosephMod.enums


---@param player EntityPlayer
---@param card Card
---@param firstTime boolean
function ReverseJudgement:initReverseJudgement(player, card, firstTime)
    if firstTime ~= true then return end
    local itemPool = Game():GetItemPool()
    local roomType = Game():GetRoom():GetType()

    local roomCollectibles = TSIL.EntitySpecific.GetPickups(PickupVariant.PICKUP_COLLECTIBLE)

    if #roomCollectibles == 0 then
        return
    end

    for i, item in pairs(roomCollectibles) do
        local data = utility:GetData(item, "spawned")
        data.FirstSpawn = true
        local collectible = utility:GetCollectible(player:GetCardRNG(Card.CARD_REVERSE_JUDGEMENT))
        item:AddCollectibleCycle(collectible)
    end
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseJudgement.initReverseJudgement, Card.CARD_REVERSE_JUDGEMENT)
JosephMod:AddCallback(enums.Callbacks.JOSEPH_GAME_START_ENCHANT_REFRESH, ReverseJudgement.initReverseJudgement, Card.CARD_REVERSE_JUDGEMENT)



function ReverseJudgement:removeReverseJudgement(player, card, slot)
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseJudgement.removeReverseJudgement, Card.CARD_REVERSE_JUDGEMENT)


---@param item EntityPickup
function ReverseJudgement:ItemSpawn(item)
    if not utility:AnyPlayerHasEnchantment(Card.CARD_REVERSE_JUDGEMENT) then return end
    local data = utility:GetData(item, "spawned")
    if data.FirstSpawn == true then return end
    if item.Touched then return end
    if not(Game():GetRoom():IsFirstVisit() or Game():GetRoom():GetFrameCount() > -1) then return end

    
    data.FirstSpawn = true
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        for j = 0, utility:GetEnchantmentCount(player, Card.CARD_REVERSE_JUDGEMENT) - 1, 1 do
            local collectible = utility:GetCollectible(player:GetCardRNG(Card.CARD_REVERSE_JUDGEMENT))
            item:AddCollectibleCycle(collectible)
        end
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, ReverseJudgement.ItemSpawn, PickupVariant.PICKUP_COLLECTIBLE)


