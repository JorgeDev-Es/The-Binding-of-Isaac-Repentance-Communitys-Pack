local enums = {}


enums.PlayerType = {
    PLAYER_JOSEPH = Isaac.GetPlayerTypeByName("Joseph​", false)
}

enums.Collectibles = {
    LIL_SLOT_MACHINE = Isaac.GetItemIdByName("Lil Slot Machine"),
    LIL_FORTUNE_TELLER = Isaac.GetItemIdByName("Lil Fortune Teller"),
    LIL_BLOOD_BANK = Isaac.GetItemIdByName("Lil Blood Bank"),
    MAGIC_SKIN_SINGLE_USE = Isaac.GetItemIdByName("Magic Skin "),
    CARD_SLEEVE = Isaac.GetItemIdByName("Card Sleeve"),
    CALENDAR = Isaac.GetItemIdByName("Calendar"),
    SCRAWL = Isaac.GetItemIdByName("Scrawl"),
    POKER_MAT = Isaac.GetItemIdByName("Poker Mat"),
    SHREDDER = Isaac.GetItemIdByName("Shredder"),
    SOUL_OF_ENVY = Isaac.GetItemIdByName("Soul of Envy"),
    ACE_OF_HEARTS = Isaac.GetItemIdByName("Ace of Hearts"),
}

enums.Trinkets = {
    CUPPA_JOE = Isaac.GetTrinketIdByName("Cup of Joe"),
    EAR_OF_GRAIN = Isaac.GetTrinketIdByName("Ear of Grain"),
}

enums.Cards = {
    THE_AEON = Isaac.GetCardIdByName("TheAeon"),
}

enums.Familiars = {
    LIL_SLOT_MACHINE_FAMILIAR = Isaac.GetEntityVariantByName("Lil Slot Machine Familiar"),
    LIL_FORTUNE_TELLER_FAMILIAR = Isaac.GetEntityVariantByName("Lil Fortune Teller Familiar"),
    LIL_BLOOD_BANK_FAMILIAR = Isaac.GetEntityVariantByName("Lil Blood Bank Familiar"),

}

enums.Effects = {
    DISENCHANT_EFFECT = Isaac.GetEntityVariantByName("Disenchant Effect"),
    FALLEN_GOLD_DAMOCLES = Isaac.GetEntityVariantByName("Fallen Golden Damocles"),
    REVERSE_EMPEROR_PORTAL = Isaac.GetEntityVariantByName("Reverse Emperor Portal")
}

enums.Enemies = {
}




enums.Sounds = {

}

enums.Costumes = {

}


enums.Slots = {

}


enums.Achievements = {
    JOSEPH = Isaac.GetAchievementIdByName("Joseph"),
    JOSEPH_B = Isaac.GetAchievementIdByName("Tainted Joseph"),
    CARD_SLEEVE = Isaac.GetAchievementIdByName("Card Sleeve"),  -- Delirium
    CALENDAR = Isaac.GetAchievementIdByName("Calendar"),        -- Hush
    SCRAWL = Isaac.GetAchievementIdByName("Scrawl"),            -- The Beast
    POKER_MAT = Isaac.GetAchievementIdByName("Poker Mat"),      -- Satan
    SHREDDER = Isaac.GetAchievementIdByName("Shredder"),        -- Lamb
    SOUL_OF_ENVY = Isaac.GetAchievementIdByName("Soul of Envy"),-- Isaac
    CUPPA_JOE = Isaac.GetAchievementIdByName("Cup of Joe"),     -- Bossrush
    EAR_OF_GRAIN = Isaac.GetAchievementIdByName("Ear of Grain"),-- Mother
    ACE_OF_HEARTS = Isaac.GetAchievementIdByName("Ace of Hearts"),-- ???
    LIL_SLOTS = Isaac.GetAchievementIdByName("Lil Slotmachine"),-- Greed
    LIL_BLOOD = Isaac.GetAchievementIdByName("Lil Bloodmachine"),-- Ultra greed
    THE_AEON = Isaac.GetAchievementIdByName("The Aeon")         -- Unlocked with Joseph
}


---@enum JosephCallbacks
enums.Callbacks = {

    --Called whenever the player enchants a card for the first time
    --Params:
    --
    -- * player - EntityPlayer
    -- * card - Card
    -- * firstTime - boolean | nil
    --
    --Optional args:
    --
    -- * card - Card
    JOSEPH_POST_ENCHANT_ADD = "JOSEPH_POST_ENCHANT_ADD",


    --Called when the player loses an enchant
    --Params:
    --
    -- * player - EntityPlayer
    -- * card - Card
    -- * slot - enums.CardSlot
    --
    --Optional args:
    --
    -- * card - Card
    JOSEPH_POST_ENCHANT_REMOVE = "JOSEPH_POST_ENCHANT_REMOVE",


    --Called when continuing a run, used for readding innate collectibles
    --Params:
    --
    -- * player - EntityPlayer
    -- * card - Card
    -- * firstTime - boolean
    --
    --Optional args:
    --
    -- * card - Card
    JOSEPH_GAME_START_ENCHANT_REFRESH = "JOSEPH_GAME_START_ENCHANT_REFRESH"
}

---@enum CardSlot
enums.CardSlot = {
    JOSEPH_INNATE = 1,
    JOSEPH_BIRTHRIGHT = 2,
    CARD_SLEEVE_MAIN = 3,
    CARD_SLEEVE_SCHOOLBAG = 4,
    CARD_SLEEVE_POCKET = 5
}
enums.CardAnims = {}

enums.CardAnims[Card.CARD_FOOL] = "00_TheFool"
enums.CardAnims[Card.CARD_MAGICIAN] = "01_TheMagician"
enums.CardAnims[Card.CARD_HIGH_PRIESTESS] = "02_TheHighPriestess"
enums.CardAnims[Card.CARD_EMPRESS] = "03_TheEmpress"
enums.CardAnims[Card.CARD_EMPEROR] = "04_TheEmperor"
enums.CardAnims[Card.CARD_HIEROPHANT] = "05_TheHierophant"
enums.CardAnims[Card.CARD_LOVERS] = "06_TheLovers"
enums.CardAnims[Card.CARD_CHARIOT] = "07_TheChariot"
enums.CardAnims[Card.CARD_JUSTICE] = "08_TheJustice"
enums.CardAnims[Card.CARD_HERMIT] = "09_TheHermit"
enums.CardAnims[Card.CARD_WHEEL_OF_FORTUNE] = "10_WheelOfFortune"
enums.CardAnims[Card.CARD_STRENGTH] = "11_Strength"
enums.CardAnims[Card.CARD_HANGED_MAN] = "12_TheHangedMan"
enums.CardAnims[Card.CARD_DEATH] = "13_Death"
enums.CardAnims[Card.CARD_TEMPERANCE] = "14_Temperance"
enums.CardAnims[Card.CARD_DEVIL] = "15_TheDevil"
enums.CardAnims[Card.CARD_TOWER] = "16_TheTower"
enums.CardAnims[Card.CARD_STARS] = "17_TheStars"
enums.CardAnims[Card.CARD_MOON] = "18_TheMoon"
enums.CardAnims[Card.CARD_SUN] = "19_TheSun"
enums.CardAnims[Card.CARD_JUDGEMENT] = "20_Judgement"
enums.CardAnims[Card.CARD_WORLD] = "21_TheWorld"

enums.CardAnims[Card.CARD_REVERSE_FOOL] = "22_TheFool"
enums.CardAnims[Card.CARD_REVERSE_MAGICIAN] = "23_TheMagician"
enums.CardAnims[Card.CARD_REVERSE_HIGH_PRIESTESS] = "24_TheHighPriestess"
enums.CardAnims[Card.CARD_REVERSE_EMPRESS] = "25_TheEmpress"
enums.CardAnims[Card.CARD_REVERSE_EMPEROR] = "26_TheEmperor"
enums.CardAnims[Card.CARD_REVERSE_HIEROPHANT] = "27_TheHierophant"
enums.CardAnims[Card.CARD_REVERSE_LOVERS] = "28_TheLovers"
enums.CardAnims[Card.CARD_REVERSE_CHARIOT] = "29_TheChariot"
enums.CardAnims[Card.CARD_REVERSE_JUSTICE] = "30_TheJustice"
enums.CardAnims[Card.CARD_REVERSE_HERMIT] = "31_TheHermit"
enums.CardAnims[Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = "32_WheelOfFortune"
enums.CardAnims[Card.CARD_REVERSE_STRENGTH] = "33_Strength"
enums.CardAnims[Card.CARD_REVERSE_HANGED_MAN] = "34_TheHangedMan"
enums.CardAnims[Card.CARD_REVERSE_DEATH] = "35_Death"
enums.CardAnims[Card.CARD_REVERSE_TEMPERANCE] = "36_Temperance"
enums.CardAnims[Card.CARD_REVERSE_DEVIL] = "37_TheDevil"
enums.CardAnims[Card.CARD_REVERSE_TOWER] = "38_TheTower"
enums.CardAnims[Card.CARD_REVERSE_STARS] = "39_TheStars"
enums.CardAnims[Card.CARD_REVERSE_MOON] = "40_TheMoon"
enums.CardAnims[Card.CARD_REVERSE_SUN] = "41_TheSun"
enums.CardAnims[Card.CARD_REVERSE_JUDGEMENT] = "42_Judgement"
enums.CardAnims[Card.CARD_REVERSE_WORLD] = "43_TheWorld"


enums.ReverseCardAchievmentIDs = {}

enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_FOOL] = Achievement.REVERSED_FOOL
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_MAGICIAN] = Achievement.REVERSED_MAGICIAN
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_HIGH_PRIESTESS] = Achievement.REVERSED_HIGH_PRIESTESS
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_EMPRESS] = Achievement.REVERSED_EMPRESS
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_EMPEROR] = Achievement.REVERSED_EMPEROR
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_HIEROPHANT] = Achievement.REVERSED_HIEROPHANT
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_LOVERS] = Achievement.REVERSED_LOVERS
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_CHARIOT] = Achievement.REVERSED_CHARIOT
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_JUSTICE] = Achievement.REVERSED_JUSTICE
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_HERMIT] = Achievement.REVERSED_HERMIT
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = Achievement.REVERSED_WHEEL_OF_FORTUNE
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_STRENGTH] = Achievement.REVERSED_STRENGTH
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_HANGED_MAN] = Achievement.REVERSED_HANGED_MAN
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_DEATH] = Achievement.REVERSED_DEATH
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_TEMPERANCE] = Achievement.REVERSED_TEMPERANCE
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_DEVIL] = Achievement.REVERSED_DEVIL
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_TOWER] = Achievement.REVERSED_TOWER
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_STARS] = Achievement.REVERSED_STARS
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_MOON] = Achievement.REVERSED_SUN_AND_MOON
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_SUN] = Achievement.REVERSED_SUN_AND_MOON
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_JUDGEMENT] = Achievement.REVERSED_JUDGEMENT
enums.ReverseCardAchievmentIDs[Card.CARD_REVERSE_WORLD] = Achievement.REVERSED_WORLD





enums.CardDisenchantChances = {}

enums.CardDisenchantChances[Card.CARD_FOOL] = 0.33
enums.CardDisenchantChances[Card.CARD_MAGICIAN] = 0.90
enums.CardDisenchantChances[Card.CARD_HIGH_PRIESTESS] = 0.90
enums.CardDisenchantChances[Card.CARD_EMPRESS] = 0.90
enums.CardDisenchantChances[Card.CARD_EMPEROR] = 0.25
enums.CardDisenchantChances[Card.CARD_HIEROPHANT] = 0.33
enums.CardDisenchantChances[Card.CARD_LOVERS] = 0.33
enums.CardDisenchantChances[Card.CARD_CHARIOT] = 0.25
enums.CardDisenchantChances[Card.CARD_JUSTICE] = 0.33
enums.CardDisenchantChances[Card.CARD_HERMIT] = 0.25
enums.CardDisenchantChances[Card.CARD_WHEEL_OF_FORTUNE] = 0.25
enums.CardDisenchantChances[Card.CARD_STRENGTH] = 0.90
enums.CardDisenchantChances[Card.CARD_HANGED_MAN] = 0.33
enums.CardDisenchantChances[Card.CARD_DEATH] = 0.33
enums.CardDisenchantChances[Card.CARD_TEMPERANCE] = 0.25
enums.CardDisenchantChances[Card.CARD_DEVIL] = 0.90
enums.CardDisenchantChances[Card.CARD_TOWER] = 0.10
enums.CardDisenchantChances[Card.CARD_STARS] = 0.25
enums.CardDisenchantChances[Card.CARD_MOON] = 0.25
enums.CardDisenchantChances[Card.CARD_SUN] = 0.50
enums.CardDisenchantChances[Card.CARD_JUDGEMENT] = 0.25
enums.CardDisenchantChances[Card.CARD_WORLD] = 0.25

enums.CardDisenchantChances[Card.CARD_REVERSE_FOOL] = 0.05
enums.CardDisenchantChances[Card.CARD_REVERSE_MAGICIAN] = 0.75
enums.CardDisenchantChances[Card.CARD_REVERSE_HIGH_PRIESTESS] = 0.25
enums.CardDisenchantChances[Card.CARD_REVERSE_EMPRESS] = 0.75
enums.CardDisenchantChances[Card.CARD_REVERSE_EMPEROR] = 0.25
enums.CardDisenchantChances[Card.CARD_REVERSE_HIEROPHANT] = 0.25
enums.CardDisenchantChances[Card.CARD_REVERSE_LOVERS] = 0.33
enums.CardDisenchantChances[Card.CARD_REVERSE_CHARIOT] = 0.25
enums.CardDisenchantChances[Card.CARD_REVERSE_JUSTICE] = 0.33
enums.CardDisenchantChances[Card.CARD_REVERSE_HERMIT] = 0.25
enums.CardDisenchantChances[Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = 0.33
enums.CardDisenchantChances[Card.CARD_REVERSE_STRENGTH] = 0.33
enums.CardDisenchantChances[Card.CARD_REVERSE_HANGED_MAN] = 0.75
enums.CardDisenchantChances[Card.CARD_REVERSE_DEATH] = 0.75
enums.CardDisenchantChances[Card.CARD_REVERSE_TEMPERANCE] = 0.33
enums.CardDisenchantChances[Card.CARD_REVERSE_DEVIL] = 0.5
enums.CardDisenchantChances[Card.CARD_REVERSE_TOWER] = 0.33
enums.CardDisenchantChances[Card.CARD_REVERSE_STARS] = 0
enums.CardDisenchantChances[Card.CARD_REVERSE_MOON] = 0.33
enums.CardDisenchantChances[Card.CARD_REVERSE_SUN] = 0.75
enums.CardDisenchantChances[Card.CARD_REVERSE_JUDGEMENT] = 0.75
enums.CardDisenchantChances[Card.CARD_REVERSE_WORLD] = 0.33


JosephMod.enums = enums
