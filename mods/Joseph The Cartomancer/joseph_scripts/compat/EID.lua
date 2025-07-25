if not EID then return end

local enums = JosephMod.enums
local josephType = enums.PlayerType.PLAYER_JOSEPH
JosephMod.Descriptions = include("joseph_scripts.compat.EID_descriptions")
local Descriptions = JosephMod.Descriptions

local CARD_SLEEVE = Isaac.GetItemIdByName("Card Sleeve")


local icons = Sprite()
icons:Load("gfx/ui/EID_icon.anm2", true)

EID:addIcon("Player"..josephType, "Joseph", 0, 16, 16, 5, 6, icons)
EID:addIcon("EnchantIcon", "Enchant", 0, 16, 16, 5, 6, icons)
EID:addIcon("Card" ..enums.Cards.THE_AEON, "TheAeon", 0, 16, 16, 5, 6, icons)

EID:setModIndicatorName("Joseph ")
EID:setModIndicatorIcon("Player"..josephType)



EID:addColor("ColorPurpleGlow", nil, function(color)
    local maxAnimTime = 60
    local frameCount = Game():GetFrameCount()
    local targetColor = { r = 124 / 255, g = 28 / 255, b = 135 / 255, a = 1 }
    local whiteColor = { r = 1, g = 1, b = 1, a = 1 }
    local oscillation = (math.sin((frameCount / maxAnimTime) * math.pi * 2) + 1) / 2

    local r = whiteColor.r * (1 - oscillation) + targetColor.r * oscillation
    local g = whiteColor.g * (1 - oscillation) + targetColor.g * oscillation
    local b = whiteColor.b * (1 - oscillation) + targetColor.b * oscillation
    local a = whiteColor.a * (1 - oscillation) + targetColor.a * oscillation
  
    color = EID:copyKColor(color) or EID:getTextColor()

    color = KColor(r, g, b, a)

    return color
end
)

local function chanceToDisplay(card)
    local chance = enums.CardDisenchantChances[card]
    if card == Card.CARD_REVERSE_STARS then chance = 1 end
    if chance == 0 then return "ZERO"
    elseif chance <= 0.25 then return "LOW"
    elseif chance <= 0.5 then return "MED"
    elseif chance < 1 then return "HIGH"
    else return "HUNDRED" end
end

-- Enchants

local function shouldDisplayEnchantDescription(descObj)
    if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 300 and Descriptions.Enchants[descObj.ObjSubType] then
        if (descObj.Entity ~= nil) then
            if (PlayerManager.AnyoneIsPlayerType(josephType) or PlayerManager.AnyoneHasCollectible(CARD_SLEEVE)) and
            not PlayerManager.AnyoneHasCollectible(enums.Collectibles.SCRAWL) then return true end
        elseif EID.holdTabPlayer then
            if EID.holdTabPlayer:ToPlayer():GetPlayerType() == josephType or EID.holdTabPlayer:ToPlayer():HasCollectible(CARD_SLEEVE) then return true end
        end
    end
end
local function getDescription(descObj)
    local lang = EID:getLanguage()

    local translatedHeader = Descriptions.Enchants["ENCHANT_HEADER"][lang] and Descriptions.Enchants["ENCHANT_HEADER"][lang].description 
    or Descriptions.Enchants["ENCHANT_HEADER"]["en_us"] and Descriptions.Enchants["ENCHANT_HEADER"]["en_us"].description or "When Enchanted:"
    local translatedDescription = Descriptions.Enchants[descObj.ObjSubType][lang] and Descriptions.Enchants[descObj.ObjSubType][lang].description
    or Descriptions.Enchants[descObj.ObjSubType]["en_us"] and Descriptions.Enchants[descObj.ObjSubType]["en_us"].description or "Enchant description unavailable"
    local translatedDisenchantChance = Descriptions.Enchants[chanceToDisplay(descObj.ObjSubType)][lang] and Descriptions.Enchants[chanceToDisplay(descObj.ObjSubType)][lang].description
    or Descriptions.Enchants[chanceToDisplay(descObj.ObjSubType)]["en_us"] and Descriptions.Enchants[chanceToDisplay(descObj.ObjSubType)]["en_us"].description or ""

    EID:appendToDescription(descObj, "#" .. translatedHeader .. "#" .. translatedDescription .. "#" .. translatedDisenchantChance)
    return descObj
end

EID:addDescriptionModifier("CardEnchant", shouldDisplayEnchantDescription, getDescription)


-- Character
for character, translations in pairs(Descriptions.Characters) do
    for language, description in pairs(translations) do
        EID:addCharacterInfo(character, description.description, description.name, language)

    end
end

-- Birthrights
for character, translations in pairs(Descriptions.Birthrights) do
    for language, description in pairs(translations) do
        EID:addBirthright(character, description.description, description.name, language)
    end
end

-- Collectibles
for collectible, translations in pairs(Descriptions.Collectibles) do
    for language, description in pairs(translations) do
        EID:addCollectible(collectible, description.description, description.name, language)

        if description.abyss then
            if not EID.descriptions[language].abyssSynergies then
                EID.descriptions[language].abyssSynergies = {}
            end
            EID.descriptions[language].abyssSynergies[collectible] = description.abyss
        end

        if description.book_of_virtues then
            if not EID.descriptions[language].bookOfVirtuesWisps then
                EID.descriptions[language].bookOfVirtuesWisps = {}
            end
            EID.descriptions[language].bookOfVirtuesWisps[collectible] = description.book_of_virtues
        end

        if description.book_of_belial then
            if not EID.descriptions[language].bookOfBelialBuffs then
                EID.descriptions[language].bookOfBelialBuffs = {}
            end
            EID.descriptions[language].bookOfBelialBuffs[collectible] = description.book_of_belial
        end
    end
end

-- Trinkets
for trinket, translations in pairs(Descriptions.Trinkets) do
    for language, description in pairs(translations) do
        EID:addTrinket(trinket, description.description, description.name, language)

        if description.double then
            EID:addGoldenTrinketTable(trinket, { fullReplace = true })

            if not EID.descriptions[language].goldenTrinketEffects then
                EID.descriptions[language].goldenTrinketEffects = {}
            end

            EID.descriptions[language].goldenTrinketEffects[trinket] = {
                description.description,
                description.double,
                description.triple or description.double
            }
        end
    end
end

-- Pickups
for card, translations in pairs(Descriptions.Cards) do
    for language, description in pairs(translations) do
        EID:addCard(card, description.description, description.name, language)
    end
end

-- -- Entities
-- for entity, translations in pairs(Descriptions.Entities) do
--     local tokens = TSIL.Utils.String.Split(entity, ".")
--     local type = tokens[1]
--     local variant = tokens[2] or 0
--     local subtype = tokens[3] or 0

--     for language, description in pairs(translations) do
--         EID:addEntity(
--             type,
--             variant,
--             subtype,
--             description.name,
--             description.description,
--             language
--         )
--     end
-- end





-- ---Appends an s to `str` if the amount is not 1.
-- ---@param str string
-- ---@param amount integer
-- ---@return string
-- local function MakePlural(str, amount)
--     if amount == 1 then
--         return str
--     else
--         return str .. "s"
--     end
-- end


-- ---Returns the pickup name according to the language.
-- ---@param variant PickupVariant
-- ---@return string
-- local function GetPickupName(variant)
--     local translations = PICKUP_NAME[variant]
--     if not translations then
--         translations = PICKUP_NAME[PickupVariant.PICKUP_NULL]
--     end

--     local eidLanguage = EID:getLanguage()

--     local name = translations[eidLanguage]
--     if not name then
--         name = translations["en_us"]
--     end

--     return name
-- end


