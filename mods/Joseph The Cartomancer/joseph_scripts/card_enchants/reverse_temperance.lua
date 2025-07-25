local ReverseTemperance = {}

local utility = JosephMod.utility
local enums = JosephMod.enums

local TAKE_PILL_CHANCE = 0.33
local CARDPILL_USE_DELAY = 15
local VANILLA_PILLCOLOR_COUNT = 13

local positivePillCollectibles = {
    CollectibleType.COLLECTIBLE_PHD,
    CollectibleType.COLLECTIBLE_LUCKY_FOOT,
    CollectibleType.COLLECTIBLE_VIRGO
}


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseTemperance:initReverseTemperance(player, card, slot)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_LITTLE_BAGGY, 1)
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseTemperance.initReverseTemperance, Card.CARD_REVERSE_TEMPERANCE)
JosephMod:AddCallback(enums.Callbacks.JOSEPH_GAME_START_ENCHANT_REFRESH, ReverseTemperance.initReverseTemperance, Card.CARD_REVERSE_TEMPERANCE)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseTemperance:removeReverseTemperance(player, card, slot)
    utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_LITTLE_BAGGY)
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseTemperance.removeReverseTemperance, Card.CARD_REVERSE_TEMPERANCE)


function ReverseTemperance:NewRoom()
    local room = Game():GetRoom()
    if not room:IsFirstVisit() then return end
    if room:IsClear() then return end

    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        if utility:HasEnchantment(player, Card.CARD_REVERSE_TEMPERANCE) then
            local rng = player:GetCardRNG(Card.CARD_REVERSE_TEMPERANCE)
            if rng:RandomFloat() < TAKE_PILL_CHANCE then
                ReverseTemperance:TakeRandomPill(player, rng)
            end
        end
    end
end
JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, ReverseTemperance.NewRoom)



---Activate per Acid Penny activation
---@param player EntityPlayer
---@param rng RNG
function ReverseTemperance:TakeRandomPill(player, rng)
    local itemPool = Game():GetItemPool()
    local pillColor = rng:RandomInt(VANILLA_PILLCOLOR_COUNT) + 1
    local pillEffect = itemPool:GetPillEffect(pillColor, player)
    local realPhd = false
    local falsePhd = player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD)

    itemPool:IdentifyPill(pillColor)

    for _, collectible in ipairs(positivePillCollectibles) do
        if player:HasCollectible(collectible) then
            realPhd = true
        end
    end

    if falsePhd and not realPhd then
        pillEffect = TSIL.Pills.GetFalsePHDPillEffect(pillColor)
        pillColor = ReverseTemperance:PillEffectToPillColor(player, pillEffect)
    elseif realPhd and not falsePhd then
        pillEffect = TSIL.Pills.GetPHDPillEffect(pillColor)
        pillColor = ReverseTemperance:PillEffectToPillColor(player, pillEffect)
    end

    if pillColor == PillColor.PILL_NULL then
        pillColor = PillColor.PILL_BLUE_BLUE
    end

    player:AnimatePill(pillColor, "Pickup")
    SFXManager():Play(SoundEffect.SOUND_SHELLGAME)

    TSIL.Utils.Functions.RunInFrames(function ()
        player:UsePill(pillEffect, pillColor, UseFlag.USE_NOANNOUNCER)
    end, CARDPILL_USE_DELAY, {})
end


---Gets the PillColor of a PillEffect in a given run
---@param player EntityPlayer
---@param pillEffect PillEffect
---@return integer
function ReverseTemperance:PillEffectToPillColor(player, pillEffect)
    local itemPool = Game():GetItemPool()
    for colorId = 1, PillColor.NUM_STANDARD_PILLS do
        local currentPillEffect = itemPool:GetPillEffect(colorId, player)
        if currentPillEffect == pillEffect then
            return colorId
        end
    end
    return PillColor.PILL_NULL
end