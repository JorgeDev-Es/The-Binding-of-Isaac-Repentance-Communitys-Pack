local json = require("json")  -- Make sure to point to the correct path if the json library is external

local function tryIsaacRevengeEffect()
    if not persistent.isaac_revenge then return end
    local game = Game()
    local room = game:GetRoom()
    local level = game:GetLevel()

    -- Only trigger on first visit to the room
    if not room:IsFirstVisit() then return end

    -- Check for at least one item pedestal in the room
    local pedestalCount = 0
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            pedestalCount = pedestalCount + 1
        end
    end

    if pedestalCount == 0 then return end
    -- 25% chance to activate Soul of Isaac effect 20 times
    local chance = 0.25
    if math.random() < chance then
        local player = game:GetPlayer(0) -- Only targets first player; expand for co-op if needed
        local SOUL_ISAAC_CARD = Card.CARD_SOUL_ISAAC
        local USE_FLAGS = 259 -- Replace with named constant if available in your mod

        for _ = 1, 20 do
            player:UseCard(SOUL_ISAAC_CARD, USE_FLAGS)
        end
        -- Play error buzz sound
        SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 1.0, 0, false, 1.0)
    end
end





return {
    tryIsaacRevengeEffect = tryIsaacRevengeEffect,



}