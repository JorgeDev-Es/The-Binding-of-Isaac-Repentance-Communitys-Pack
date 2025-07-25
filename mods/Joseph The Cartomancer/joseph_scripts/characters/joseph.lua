local JosephChar = {}

local utility = JosephMod.utility
local enums = JosephMod.enums

TSIL.SaveManager.AddPersistentPlayerVariable(
      JosephMod,
      "playerRNG",
      nil,
      TSIL.Enums.VariablePersistenceMode.RESET_RUN,
      false
)

TSIL.SaveManager.AddPersistentPlayerVariable(
      JosephMod,
      "EnchantedCards",
      {0, 0, 0, 0, 0},
      TSIL.Enums.VariablePersistenceMode.RESET_RUN,
      false
)
-- TSIL.SaveManager.AddPersistentVariable(
--       JosephMod,
--       "GlowingHourglassTest",
--       0,
--       TSIL.Enums.VariablePersistenceMode.RESET_RUN,
--       false
--     )



-- function JosephChar:Increment()
--     TSIL.SaveManager.SetPersistentVariable(JosephMod, "GlowingHourglassTest", TSIL.SaveManager.GetPersistentVariable(JosephMod, "GlowingHourglassTest") + 1)
-- end
-- JosephMod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, JosephChar.Increment)


-- EnchantedCard slots:
-- 1 - Joseph Base
-- 2 - Joseph Birthright
-- 3 - Card Sleeve
-- 4 - Card Sleeve Schoolbag
-- 5 - Card Sleeve Pocket

local CardChargeBar = {}
local StartedUsingCard = {}
local FramesHeld = {}
local EarlyCancel = {}
local CardUsed = {}
local ManualUse = {}

local ENCHANTMENT_GLINT_FREQ = 100 --ticks to complete full glint cycle
local BIRTHRIGHT_CARD_DISPLAY_OFFSET = 22
local NUMBER_TAROT_CARDS = 22
local RECOMMENDED_SHIFT_IDX = 35
local DISENCHANT_ENTITY_ID = Isaac.GetEntityVariantByName("Disenchant Effect")
local josephType = enums.PlayerType.PLAYER_JOSEPH
local chargebarPos = Vector(-30, -52)
local REVERSE_TAROT_CHANCE = 0.12


local cardDisplayPosPerPlayer = {
    --Vector(394, 147),
    --Vector(45, 46)
    Vector(45, 46), --player 1 top left
    Vector(332, 50), --player 2 top right
    Vector(30, 250), --player 3 bottom left
    Vector(326, 250), --player 4 bottom right but slightly less
}

local playerAnchor = {
    "topleft",
    "topright",
    "bottomleft",
    "bottomright",
}

local f = Font() -- init font object
f:Load("font/terminus.fnt")


--Give random card on player init
function JosephChar:onPlayerInit(player)
    if player:GetPlayerType() ~= josephType then return end

    local rng = RNG()
    rng:SetSeed(player.InitSeed, RECOMMENDED_SHIFT_IDX)

    local randomCard = rng:RandomInt(NUMBER_TAROT_CARDS) + 1
    player:AddCard(randomCard)

    TSIL.SaveManager.SetPersistentPlayerVariable(JosephMod, "playerRNG", player, rng)
    Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_STARTER_DECK)
    
end
JosephMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, JosephChar.onPlayerInit)



--Make sure Joseph always has starter deck
JosephMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    if player:HasCurseMistEffect() then return end
    if player:GetPlayerType() == josephType then
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_STARTER_DECK) then
           player:AddInnateCollectible(CollectibleType.COLLECTIBLE_STARTER_DECK)
           local config = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_STARTER_DECK)
           player:RemoveCostume(config)
        end
    end
    
end)


--Modify starting stats
function JosephChar:HandleStartingStats(player, flag)
    if player:GetPlayerType() ~= josephType then return end

    if flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * 0.85
    end

    if flag == CacheFlag.CACHE_FIREDELAY then
        utility:addTearMultiplier(player, 1.1)
    end

    if flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed - 0.1
    end
end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, JosephChar.HandleStartingStats)


function JosephChar:pickupBirthright(CollectibleType, Charge, FirstTime, Slot, VarData, player)
    if not player:GetPlayerType() == josephType or not FirstTime then return end

    if not utility:IsEnchantmentSlotEmpty(player, enums.CardSlot.JOSEPH_INNATE) then
        local oldCard = utility:GetEnchantedCardInPlayerSlot(player, enums.CardSlot.JOSEPH_INNATE)
        JosephChar:DisenchantCard(player, enums.CardSlot.JOSEPH_INNATE)
        JosephChar:EnchantCard(player, oldCard, enums.CardSlot.JOSEPH_BIRTHRIGHT)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, JosephChar.pickupBirthright, 619)



function JosephChar:removeBirthright(player, _)
    if not player or player:GetPlayerType() ~= josephType then return end

    if not utility:IsEnchantmentSlotEmpty(player, enums.CardSlot.JOSEPH_BIRTHRIGHT) then
        local oldCard = utility:GetEnchantedCardInPlayerSlot(player, enums.CardSlot.JOSEPH_BIRTHRIGHT)
        JosephChar:DisenchantCard(player, enums.CardSlot.JOSEPH_BIRTHRIGHT, true)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, JosephChar.removeBirthright, 619)



---@param player EntityPlayer
---@param card Card
---@param slot CardSlot 
---@param removeCard boolean | nil
function JosephChar:EnchantCard(player, card, slot, removeCard)
    local firstTime = true
    if removeCard and removeCard == true then
        player:RemovePocketItem(0)
    end
    player:AnimateCard(card)
    SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER, 1)

    if not utility:IsEnchantmentSlotEmpty(player, slot) then
        JosephChar:DisenchantCard(player, slot, false)
    end
    utility:SetEnchantedCardInPlayerSlot(player, slot, card)

    if slot == enums.CardSlot.JOSEPH_BIRTHRIGHT then firstTime = false end

    JosephMod.BaseCardEffects:InitCardEffect(player, card, firstTime)
    Isaac.RunCallbackWithParam(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, card, player, card, firstTime)
end


---@param player EntityPlayer
---@param slot CardSlot 
---@param playEffect boolean | nil play the on hit disenchant perfection effect
function JosephChar:DisenchantCard(player, slot, playEffect)
    local enchantedCard = utility:GetEnchantedCardInPlayerSlot(player, slot)
    utility:SetEnchantedCardInPlayerSlot(player, slot, 0)
    if enchantedCard and enchantedCard ~= 0 then
        JosephMod.BaseCardEffects:RemoveCardEffect(player, enchantedCard)
        Isaac.RunCallbackWithParam(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, enchantedCard, player, enchantedCard, slot)
    end

    if playEffect and playEffect == true and enchantedCard and enchantedCard ~= 0 then
        SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN)
        JosephChar:PlayDisenchantAnimation(player, enchantedCard)
    end
end


function JosephChar:showEnchantment(player, i)

    if player == nil then return end
    if player:GetPlayerType() ~= josephType then return end
    local enchantedCards =  utility:GetEnchantedCardsPerPlayer(player)


    local enchantedCard = enchantedCards[enums.CardSlot.JOSEPH_INNATE]
    if enchantedCard and enchantedCard ~= 0 then
        local enchantmentDisplay = Sprite()
        local displayPos = Vector(JosephMod.utility:HUDOffset(cardDisplayPosPerPlayer[i+1].X, cardDisplayPosPerPlayer[i+1].Y, playerAnchor[i+1]))
        enchantmentDisplay.Color = Color(1, 1, 1, 0.8)

        if i == 0 then
            enchantmentDisplay:Load("gfx/ui/enchanted_card_displays.anm2",true)
            enchantmentDisplay:SetFrame("CardFronts", enchantedCard)
            if Isaac.ScreenToWorld(displayPos).X > -22 and Isaac.ScreenToWorld(displayPos).Y > 70 then
                local playerPostAdjust = Game():GetNearestPlayer(displayPos).Position + Vector(0, -20)
                local distance = Isaac.WorldToScreen(playerPostAdjust):Distance(displayPos)
                local transparency = distance/80
                enchantmentDisplay.Color.A = math.min(0.8, transparency)
            end
        else
            enchantmentDisplay:Load("gfx/ui/ui_cardspills.anm2",true)
            if enchantedCard < 78 then --Check to make sure its not trying to render a frame that doesnt exist
                enchantmentDisplay:SetFrame("CardFronts", enchantedCard)
            end
        end

        enchantmentDisplay:LoadGraphics()
        --print("X distance: " .. player.Position.X - Isaac.ScreenToWorld(displayPos).X .. " | Y distance: " ..  player.Position.Y - Isaac.ScreenToWorld(displayPos).Y)
        enchantmentDisplay:Render(displayPos)
    end

    local birthrightCard = enchantedCards[enums.CardSlot.JOSEPH_BIRTHRIGHT]
    if birthrightCard and birthrightCard ~= 0 then
        local birthrightDisplay = Sprite()
        local displayPos = Vector(JosephMod.utility:HUDOffset(cardDisplayPosPerPlayer[i+1].X + BIRTHRIGHT_CARD_DISPLAY_OFFSET, cardDisplayPosPerPlayer[i+1].Y, playerAnchor[i+1]))
        birthrightDisplay.Color = Color.Lerp(Color(1, 1, 1, 0.8), Color(0.8, 0.8, 2, 0.8, 0.2, 0, 0.3), 0.5*(1 + math.sin(2*3.14 * (1/ENCHANTMENT_GLINT_FREQ) * Game():GetFrameCount()))) --Color goes from normal to purple tinted every ENCHANTMENT_GLINT_FREQ ticks

        if i == 0 then
            birthrightDisplay:Load("gfx/ui/enchanted_card_displays.anm2",true)
            birthrightDisplay:SetFrame("CardFronts", birthrightCard)
            if Isaac.ScreenToWorld(displayPos).X > -22 and Isaac.ScreenToWorld(displayPos).Y > 70 then --If in the room bounds
            
                local playerPostAdjust = Game():GetNearestPlayer(displayPos).Position + Vector(0, -20)
                local distance = Isaac.WorldToScreen(playerPostAdjust):Distance(displayPos)
                local transparency = distance/80
                birthrightDisplay.Color.A = math.min(0.8, transparency)
            end
        else
            birthrightDisplay:Load("gfx/ui/ui_cardspills.anm2",true)
            if birthrightCard < 78 then --Check to make sure its not trying to render a frame that doesnt exist
                birthrightDisplay:SetFrame("CardFronts", birthrightCard)
            end
        end

        birthrightDisplay:LoadGraphics()
        birthrightDisplay:Render(displayPos)
    end
end

function JosephChar:OnHUDRender()
    if RoomTransition.IsRenderingBossIntro() then return end

    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        JosephChar:showEnchantment(player, i)
    end
  end
JosephMod:AddPriorityCallback(ModCallbacks.MC_HUD_RENDER, CallbackPriority.IMPORTANT, JosephChar.OnHUDRender)


function JosephChar:OnHit(entity, amount, flags, source, countDown)

    local player = entity:ToPlayer()
    if player:GetPlayerType() ~= josephType then return end
    local fakeDamageFlags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE
    if flags & fakeDamageFlags > 0 then return end

    local enchantedCard = utility:GetEnchantedCardInPlayerSlot(player, enums.CardSlot.JOSEPH_INNATE)
    if utility:IsEnchantmentSlotEmpty(player, enums.CardSlot.JOSEPH_INNATE) then return end

    local rng = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "playerRNG", player)
    if not rng or rng == 0 then rng = JosephChar:CreateRNG(player) end

    local randomFloat = rng:RandomFloat()
    if randomFloat < (enums.CardDisenchantChances[enchantedCard] or 0.33) then
        JosephChar:DisenchantCard(player, enums.CardSlot.JOSEPH_INNATE, true)
    end
    TSIL.SaveManager.SetPersistentPlayerVariable(JosephMod, "playerRNG", player, rng)

end
JosephMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, JosephChar.OnHit, EntityType.ENTITY_PLAYER)



function JosephChar:PlayDisenchantAnimation(player, card)

    local entity = Isaac.Spawn(1000, enums.Effects.DISENCHANT_EFFECT, 0, player.Position, 4*RandomVector(), player)

    local sprite = entity:GetSprite()

    sprite:ReplaceSpritesheet(0, "gfx/effects/" .. enums.CardAnims[card] .. ".png")
    sprite:LoadGraphics()
end


function JosephChar:DisenchantAnimationInit(entity)
    entity:GetSprite():Play("Appear", true)
end
JosephMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, JosephChar.DisenchantAnimationInit, DISENCHANT_ENTITY_ID)


function JosephChar:DisenchantAnimationUpdate(entity)
    local sprite = entity:GetSprite()
    if sprite:IsFinished("Appear") then
        Isaac.Spawn(1000, 15, 0, entity.Position, Vector(0, 0), entity)
        entity:Remove()
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, JosephChar.DisenchantAnimationUpdate, DISENCHANT_ENTITY_ID)


function JosephChar:CreateRNG(player)
    local rng = RNG()
    rng:SetSeed(player.InitSeed, RECOMMENDED_SHIFT_IDX)
    TSIL.SaveManager.SetPersistentPlayerVariable(JosephMod, "playerRNG", player, rng)
    TSIL.Utils.Functions.RunInFramesTemporary(function ()
        return TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "playerRNG", player)
    end, 1)
end

---Make Joseph's Deck of cards only give tarot cards

---@param player EntityPlayer
function JosephChar:UseDeckOfCards(CollectibleType, RNG, player, UseFlags, ActiveSlot)
    if player:GetPlayerType() ~= josephType then return end

    local randomCard
    local attempts = 50
    while attempts > 0 do
        local getCard = Game():GetItemPool():GetCard(RNG:Next(), false, false, false)
        if enums.CardAnims[getCard] then
            randomCard = getCard
            break
        end
        attempts = attempts - 1
    end
    if not randomCard then randomCard = Card.CARD_FOOL end

    player:AnimateCard(randomCard, "UseItem")
    player:AddCard(randomCard)

    return true
end
JosephMod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.LATE, JosephChar.UseDeckOfCards, CollectibleType.COLLECTIBLE_DECK_OF_CARDS)

local isJoseph = false
function JosephChar:ChangeCharacter(player, flag)
    if flag == CacheFlag.CACHE_COLOR then
        if player:GetPlayerType() == josephType then isJoseph = true end
        if isJoseph == true and player:GetPlayerType() ~= josephType then
            isJoseph = false
            JosephChar:DisenchantCard(player, enums.CardSlot.JOSEPH_INNATE, true)
            JosephChar:DisenchantCard(player, enums.CardSlot.JOSEPH_BIRTHRIGHT, true)
        end
    end
end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, JosephChar.ChangeCharacter)

return JosephChar