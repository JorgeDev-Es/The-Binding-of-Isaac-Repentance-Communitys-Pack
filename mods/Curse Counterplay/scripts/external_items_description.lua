local mod = RegisterMod("Curse Counterplay", 1)
local game = Game()

function mod:descriptionsEnabled() return true end
function mod:d100descEnabled() return SaveDataDictionary.d100 end
function mod:dataminerdescEnabled() return SaveDataDictionary.dataminer end

local mySprite = Sprite()
mySprite:Load("candle_eid_icon.anm2", true)
EID:addIcon("CurseCandleSmall", "Candle", 0, 9, 9, -1, 0, mySprite)
local mySprite2 = Sprite()
mySprite2:Load("dicepurple_eid_icon.anm2", true)
EID:addIcon("CurseDice", "Dice", 0, 8, 8, 0, 0, mySprite2)

local shopMapItems = {
    CollectibleType.COLLECTIBLE_COMPASS,
    CollectibleType.COLLECTIBLE_BLUE_MAP,
    CollectibleType.COLLECTIBLE_TREASURE_MAP,
    CollectibleType.COLLECTIBLE_XRAY_VISION,
    CollectibleType.COLLECTIBLE_SPELUNKER_HAT,
}

--removals

EID:addCondition(CollectibleType.COLLECTIBLE_DOGMA, mod.descriptionsEnabled, "{{CurseCandleSmall}} Immune to curses")
EID:addCondition(CollectibleType.COLLECTIBLE_EVIL_CHARM, mod.descriptionsEnabled, "{{CurseCandleSmall}} +50% Chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_SOUL, mod.descriptionsEnabled, "{{CurseCandleSmall}} +33% Chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_SAUSAGE, mod.descriptionsEnabled, "{{CurseCandleSmall}} +5% Chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_MAGIC_8_BALL, mod.descriptionsEnabled, "{{CurseCandleSmall}} +10% Chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_HALO, mod.descriptionsEnabled, "{{CurseCandleSmall}} +10% Chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_DUALITY, mod.descriptionsEnabled, "{{CurseCandleSmall}} +10% Chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_ROSARY, mod.descriptionsEnabled, "{{CurseCandleSmall}} +15% Chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_BIBLE, mod.descriptionsEnabled, "{{CurseCandleSmall}} Passive +25% chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_VADE_RETRO, mod.descriptionsEnabled, "{{CurseCandleSmall}} Passive +33% chance to clear curses on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_CRACKED_ORB, mod.descriptionsEnabled, "{{CurseCandleSmall}} 10% Chance to clear curses on hit")
EID:addCondition(CollectibleType.COLLECTIBLE_ALABASTER_BOX, mod.descriptionsEnabled, "{{CurseCandleSmall}} Clears curses on use")
EID:addCondition(CollectibleType.COLLECTIBLE_PRAYER_CARD, mod.descriptionsEnabled, "{{CurseCandleSmall}} 33% Chance to clears curses on use")
EID:addCondition(CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS, mod.descriptionsEnabled, "{{CurseCandleSmall}} Also clears curses when actives X-Ray Vision")
EID:addCondition(CollectibleType.COLLECTIBLE_LOST_SOUL, mod.descriptionsEnabled, "{{CurseCandleSmall}} Clears curses on the next floor if it survives")

EID:addCondition(CollectibleType.COLLECTIBLE_ROCK_BOTTOM, mod.descriptionsEnabled, "{{CurseCandleSmall}} If the floor has no curse, one cannot be added by item effects")

EID:addSynergyCondition(CollectibleType.COLLECTIBLE_BIBLE,CollectibleType.COLLECTIBLE_ROSARY,"Additional +15% chance to clear curses on floor enter")

EID:addCondition(shopMapItems, mod.descriptionsEnabled, "{{CurseCandleSmall}} +25% Chance to clear Curse of the Lost and Maze on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_MIND, mod.descriptionsEnabled, "{{CurseLostSmall}} Curse of the Lost immunity")

EID:addCondition(CollectibleType.COLLECTIBLE_MIND, mod.descriptionsEnabled, "{{CurseMazeSmall}} Curse of the Maze immunity")

EID:addCondition(CollectibleType.COLLECTIBLE_20_20, mod.descriptionsEnabled, "{{CurseBlindSmall}} Curse of the Blind immunity")
EID:addCondition(CollectibleType.COLLECTIBLE_XRAY_VISION, mod.descriptionsEnabled, "{{CurseBlindSmall}} +50% Chance to clear Curse of the Blind on floor enter")

EID:addCondition(CollectibleType.COLLECTIBLE_BODY, mod.descriptionsEnabled, "{{CurseUnknownSmall}} Curse of the Unknown immunity")

EID:addCondition(CollectibleType.COLLECTIBLE_NIGHT_LIGHT, mod.descriptionsEnabled, "{{CurseDarknessSmall}} Curse of Darkness immunity")
EID:addCondition(CollectibleType.COLLECTIBLE_CENSER, mod.descriptionsEnabled, "{{CurseDarknessSmall}} Curse of Darkness immunity")
EID:addCondition(CollectibleType.COLLECTIBLE_SPELUNKER_HAT, mod.descriptionsEnabled, "{{CurseDarknessSmall}} +50% Chance to clear Curse of Darkness on floor enter")
EID:addCondition(CollectibleType.COLLECTIBLE_CRACK_THE_SKY, mod.descriptionsEnabled, "{{CurseDarknessSmall}} Clears Curse of Darkness on use")
EID:addCondition(CollectibleType.COLLECTIBLE_CRYSTAL_BALL, mod.descriptionsEnabled, "{{CurseLostSmall}} Clears Curse of the Lost on use")

--overwrites

EID:addCondition(CollectibleType.COLLECTIBLE_PENTAGRAM, mod.descriptionsEnabled, "{{CurseDarknessSmall}} +5% Chance for the floor curse to be Curse of Darkness")
EID:addCondition(CollectibleType.COLLECTIBLE_ABADDON, mod.descriptionsEnabled, "{{CurseDarknessSmall}} +15% Chance for the floor curse to be Curse of Darkness")
EID:addCondition(CollectibleType.COLLECTIBLE_DUALITY, mod.descriptionsEnabled, "{{CurseDarknessSmall}} +10% Chance for the floor curse to be Curse of Darkness")
EID:addCondition(CollectibleType.COLLECTIBLE_SATANIC_BIBLE, mod.descriptionsEnabled, "{{CurseDarknessSmall}} Passive +25% chance for the floor curse to be Curse of Darkness")
EID:addCondition(CollectibleType.COLLECTIBLE_SANGUINE_BOND, mod.descriptionsEnabled, "{{CurseDarknessSmall}} 10% Chance to replace floor curse with Curse of Darkness when used")
EID:addCondition(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, mod.descriptionsEnabled, "{{CurseDarknessSmall}} Replaces floor curse with Curse of Darkness on use")

EID:addCondition(CollectibleType.COLLECTIBLE_CURSED_EYE, mod.descriptionsEnabled, "{{CurseUnknownSmall}} +15% Chance for the floor curse to be Curse of the Unknown")

EID:addCondition(CollectibleType.COLLECTIBLE_D100, mod.d100descEnabled, "{{CurseDice}} Rerolls floor curse if it has one")
EID:addCondition(CollectibleType.COLLECTIBLE_DATAMINER, mod.dataminerdescEnabled, "{{CurseDice}} Rerolls floor curse if it has one")


local function BibleTractCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_BIBLE_TRACT or descObj.ObjSubType == TrinketType.TRINKET_BIBLE_TRACT + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function BibleTractCurseCallback(descObj)
    if mod:anyoneHasItem(CollectibleType.COLLECTIBLE_ROSARY) then
        EID:appendToDescription(descObj, "#{{CurseCandleSmall}} +33% Chance to clear curses on floor enter#{{Collectible"..CollectibleType.COLLECTIBLE_ROSARY.."}} Additional +15% chance to clear curses on floor enter")
    else
        EID:appendToDescription(descObj, "#{{CurseCandleSmall}} +33% Chance to clear curses on floor enter")
    end
    
    return descObj
end

EID:addDescriptionModifier("Bible Tract Curse Cancel", BibleTractCurseCondition, BibleTractCurseCallback)


local function BrokenGlassesCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_BROKEN_GLASSES or descObj.ObjSubType == TrinketType.TRINKET_BROKEN_GLASSES + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function BrokenGlassesCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseBlindSmall}} +50% Chance to clear Curse of the Blind on floor enter")
    return descObj
end

EID:addDescriptionModifier("Broken Glasses Blind Cancel", BrokenGlassesCurseCondition, BrokenGlassesCurseCallback)


local function CainsEyeCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_CAINS_EYE or descObj.ObjSubType == TrinketType.TRINKET_CAINS_EYE + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function CainsEyeCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseCandleSmall}} +25% Chance to remove Curse of the Lost and Blind on floor enter#{{Luck}} 100% chance at 3 luck")
    return descObj
end

EID:addDescriptionModifier("Cains Eye Curse Cancel", CainsEyeCurseCondition, CainsEyeCurseCallback)


local function RosaryBeadCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_ROSARY_BEAD or descObj.ObjSubType == TrinketType.TRINKET_ROSARY_BEAD + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function RosaryBeadCurseCallback(descObj)
    if mod:anyoneHasItem(CollectibleType.COLLECTIBLE_ROSARY) then
        EID:appendToDescription(descObj, "#{{CurseCandleSmall}} +15% Chance to clear curses on floor enter#{{Collectible"..CollectibleType.COLLECTIBLE_ROSARY.."}} Additional +15% chance to clear curses on floor enter")
    else
        EID:appendToDescription(descObj, "#{{CurseCandleSmall}} +15% Chance to clear curses on floor enter")
    end
    return descObj
end

EID:addDescriptionModifier("Rosary Bead Curse Cancel", RosaryBeadCurseCondition, RosaryBeadCurseCallback)



local function BethsEssenceCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_BETHS_ESSENCE or descObj.ObjSubType == TrinketType.TRINKET_BETHS_ESSENCE + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function BethsEssenceCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseCandleSmall}} Clears floor curse when entering an Angel Room")
    return descObj
end

EID:addDescriptionModifier("Beths Essence Curse Cancel", BethsEssenceCurseCondition, BethsEssenceCurseCallback)


local function NumberMagnetCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_NUMBER_MAGNET or descObj.ObjSubType == TrinketType.TRINKET_NUMBER_MAGNET + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function NumberMagnetCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseDarknessSmall}} Changes floor curse to Curse of Darkness when entering a Devil Room")
    return descObj
end

EID:addDescriptionModifier("Number Magnet Curse Overwrite", NumberMagnetCurseCondition, NumberMagnetCurseCallback)


local function DaemonCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_DAEMONS_TAIL or descObj.ObjSubType == TrinketType.TRINKET_DAEMONS_TAIL + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function DaemonCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseDarknessSmall}} +20% Chance for the floor curse to be Curse of Darkness")
    return descObj
end

EID:addDescriptionModifier("Daemon Curse Overwrite", DaemonCurseCondition, DaemonCurseCallback)


local function MissingPosterCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_MISSING_POSTER or descObj.ObjSubType == TrinketType.TRINKET_MISSING_POSTER + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function MissingPosterCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseLostSmall}} +25% Chance for the floor curse to be Curse of the Lost")
    return descObj
end

EID:addDescriptionModifier("Missing Poster Curse Overwrite", MissingPosterCurseCondition, MissingPosterCurseCallback)


local function WickedCrownCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_WICKED_CROWN or descObj.ObjSubType == TrinketType.TRINKET_WICKED_CROWN + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function WickedCrownCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseDarknessSmall}} Sheol is guaranteed to have Curse of Darkness")
    return descObj
end

EID:addDescriptionModifier("Wicked Crown Curse Overwrite", WickedCrownCurseCondition, WickedCrownCurseCallback)


local function HolyCrownCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_HOLY_CROWN or descObj.ObjSubType == TrinketType.TRINKET_HOLY_CROWN + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function HolyCrownCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseCandleSmall}} Cathedral is guaranteed to have no curses")
    return descObj
end

EID:addDescriptionModifier("Holy Crown Curse Overwrite", HolyCrownCurseCondition, HolyCrownCurseCallback)


local function CursedPennyCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
        return false
    end
    if descObj.ObjSubType == TrinketType.TRINKET_CURSED_PENNY or descObj.ObjSubType == TrinketType.TRINKET_CURSED_PENNY + TrinketType.TRINKET_GOLDEN_FLAG then
        return true
    end
end

local function CursedPennyCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseDice}} Chance to reroll curse when picking up a coin")
    return descObj
end

EID:addDescriptionModifier("Cursed Penny Curse Reroll", CursedPennyCurseCondition, CursedPennyCurseCallback)


local function TheSunCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.CARD_SUN and mod:anyoneHasItem(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then return true end
end

local function TheSunCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{Collectible"..CollectibleType.COLLECTIBLE_TAROT_CLOTH.."}} {{CurseCandleSmall}} Removes all curses") return descObj
end

EID:addDescriptionModifier("The Sun Curse Cancel", TheSunCurseCondition, TheSunCurseCallback)


local function TheWorldCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.CARD_WORLD and mod:anyoneHasItem(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then return true end
end

local function TheWorldCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{Collectible"..CollectibleType.COLLECTIBLE_TAROT_CLOTH.."}} {{CurseCandleSmall}} Removes Curse of the Lost and Maze") return descObj
end

EID:addDescriptionModifier("The World Curse Cancel", TheWorldCurseCondition, TheWorldCurseCallback)


local function HolyCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.CARD_HOLY and mod:anyoneHasItem(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then return true end
end

local function HolyCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{Collectible"..CollectibleType.COLLECTIBLE_TAROT_CLOTH.."}} {{CurseCandleSmall}} 50% Chance to remove all curses") return descObj
end

EID:addDescriptionModifier("Holy Card Curse Cancel", HolyCurseCondition, HolyCurseCallback)


local function JokerCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.CARD_JOKER and mod:anyoneHasItem(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then return true end
end

local function JokerCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{Collectible"..CollectibleType.COLLECTIBLE_TAROT_CLOTH.."}} {{CurseCandleSmall}} If Angel Room, Removes floor curse#{{Blank}} {{CurseDarknessSmall}} If Devil Room, replaces floor curse with Curse of Darkness") return descObj
end

EID:addDescriptionModifier("Joker Card Curse Cancel", JokerCurseCondition, JokerCurseCallback)


local function RDevilCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.CARD_HOLY then return true end
end

local function RDevilCurseCallback(descObj)
    if mod:anyoneHasItem(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
        EID:appendToDescription(descObj, "#{{Collectible"..CollectibleType.COLLECTIBLE_TAROT_CLOTH.."}} {{CurseCandleSmall}} Removes all curses")
    else
        EID:appendToDescription(descObj, "#{{CurseCandleSmall}} 50% Chance to remove all curses")
    end
    return descObj
end

EID:addDescriptionModifier("Reverse Devil Curse Cancel", RDevilCurseCondition, RDevilCurseCallback)


local function AnsuzCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.RUNE_ANSUZ then return true end
end

local function AnsuzCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseCandleSmall}} Removes Curse of the Lost and Unknown") return descObj
end

EID:addDescriptionModifier("Ansuz Curse Cancel", AnsuzCurseCondition, AnsuzCurseCallback)


local function PerthroCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.RUNE_PERTHRO and SaveDataDictionary.perthro == true then return true end
end

local function PerthroCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseDice}} Rerolls floor curse if it has one") return descObj
end

EID:addDescriptionModifier("Perthro Curse Cancel", PerthroCurseCondition, PerthroCurseCallback)


local function MaggyCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.CARD_SOUL_MAGDALENE then return true end
end

local function MaggyCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseUnknownSmall}} Removes Curse of the Unknown") return descObj
end

EID:addDescriptionModifier("Soul of Maggy Curse Cancel", MaggyCurseCondition, MaggyCurseCallback)


local function LostCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_TAROTCARD then return false end
    if descObj.ObjSubType == Card.CARD_SOUL_LOST then return true end
end

local function LostCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseLostSmall}} Replaces floor curse with Curse of the Lost") return descObj
end

EID:addDescriptionModifier("Soul of Lost Curse Cancel", LostCurseCondition, LostCurseCallback)


local function SeeForeverCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_PILL then return false end
    if game:GetItemPool():GetPillEffect(descObj.ObjSubType) == PillEffect.PILLEFFECT_SEE_FOREVER then return true end
end

local function SeeForeverCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseLostSmall}} Removes Curse of the Lost") return descObj
end

EID:addDescriptionModifier("See Forever Curse Cancel", SeeForeverCurseCondition, SeeForeverCurseCallback)



local function SeeForeverHorseCurseCondition(descObj)
    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= PickupVariant.PICKUP_PILL then return false end
    if game:GetItemPool():GetPillEffect(descObj.ObjSubType) == PillEffect.PILLEFFECT_SEE_FOREVER and ((descObj.ObjSubType & PillColor.PILL_GIANT_FLAG) ~= 0) then return true end
end

local function SeeForeverHorseCurseCallback(descObj)
    EID:appendToDescription(descObj, "#{{CurseCandleSmall}} Removes Curse of the Unknown and Blind") return descObj
end

EID:addDescriptionModifier("See Forever Horse Curse Cancel", SeeForeverHorseCurseCondition, SeeForeverHorseCurseCallback)



function mod:anyoneHasItem(item_id)
    for _,entity in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
        local playerEntity = entity:ToPlayer()
        if playerEntity ~= nil then
            if playerEntity:HasCollectible(item_id) then
                return true
            end
        end
    end
    return false
end