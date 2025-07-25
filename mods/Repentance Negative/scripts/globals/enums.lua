local Mod = RepMMod

Mod.RepmAchivements = {}
Mod.RepmChallenges = {}

Mod.RepmTypes = {}

-- Achievements
-- -- Sim
Mod.RepmAchivements.SIM_LAMB = { ID = Isaac.GetAchievementIdByName("RubyChest"), Name = "Lamb"}
Mod.RepmAchivements.SIM_DELIRIUM = { ID = Isaac.GetAchievementIdByName("SimDelirium"), Name = "Delirium" }

-- -- Frosty
Mod.RepmAchivements.FROSTY = { ID = Isaac.GetAchievementIdByName("Frosty"), Name = "Frosty" }
Mod.RepmAchivements.DEATH_CARD = { ID = Isaac.GetAchievementIdByName("FrostySatan"), Name = "Death Card" }
Mod.RepmAchivements.FROZEN_HEARTS = { ID = Isaac.GetAchievementIdByName("FrozenHearts"), Name = "Frozen Hearts" }
Mod.RepmAchivements.IMPROVED_CARDS = { ID = Isaac.GetAchievementIdByName("improved_cards"), Name = "Improved Cards" }
Mod.RepmAchivements.NUMB_HEART = { ID = Isaac.GetAchievementIdByName("NumbHeart"), Name = "Numb Heart" }
Mod.RepmAchivements.ROT = { ID = Isaac.GetAchievementIdByName("RotAch"), Name = "Rot" }

Mod.RepmAchivements.FROSTY_B = { ID = Isaac.GetAchievementIdByName("Frosty_B"), Name = "Tainted Frosty" }
Mod.RepmAchivements.FROSTY_B = { ID = Isaac.GetAchievementIdByName("Frosty_B"), Name = "Tainted Frosty" }

-- Challenges
Mod.RepmChallenges.CHALLENGE_LOCUST_KING = Isaac.GetChallengeIdByName("Locust King")
Mod.RepmChallenges.CHALLENGE_TRAFFIC_LIGHT = Isaac.GetChallengeIdByName("Traffic Light")

-- Characters
Mod.RepmTypes.CHARACTER_SIM = Isaac.GetPlayerTypeByName("Sim", false)
Mod.RepmTypes.CHARACTER_SIM_B = Isaac.GetPlayerTypeByName("Sim", true)

Mod.RepmTypes.CHARACTER_FROSTY = Isaac.GetPlayerTypeByName("Frosty", false)
Mod.RepmTypes.CHARACTER_FROSTY_B = Isaac.GetPlayerTypeByName("Tainted Frosty", true)
Mod.RepmTypes.CHARACTER_FROSTY_C = Isaac.GetPlayerTypeByName("Tainted Ghost Frosty", true)

Mod.RepmTypes.CHARACTER_MINUSAAC = Isaac.GetPlayerTypeByName("Minusaac", false)

-- Pickups
Mod.RepmTypes.PICKUP_HEART_FROZEN = Isaac.GetEntitySubTypeByName("Frozen Heart (REP MIN)")
Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF = Isaac.GetEntitySubTypeByName("Frozen Heart (half) (REP MIN)")

-- Collectibles
Mod.RepmTypes.COLLECTIBLE_TSUNDERE_FLY = Isaac.GetItemIdByName("Frozen Flies")
Mod.RepmTypes.COLLECTIBLE_FRIENDLY_ROCKS = Isaac.GetItemIdByName("Friendly Rocks")
Mod.RepmTypes.COLLECTIBLE_LIKE = Isaac.GetItemIdByName("Like")
Mod.RepmTypes.COLLECTIBLE_FROZEN_FOOD = Isaac.GetItemIdByName("Frozen Food")
Mod.RepmTypes.COLLECTIBLE_NUMB_HEART = Isaac.GetItemIdByName("Numb Heart")
Mod.RepmTypes.COLLECTIBLE_BOOK_OF_TALES = Isaac.GetItemIdByName("Book of Tales")
--Mod.RepmTypes.COLLECTIBLE_PRO_BACKSTABBER = Isaac.GetItemIdByName("Pro Backstabber")
Mod.RepmTypes.COLLECTIBLE_ADVANCED_KAMIKAZE = Isaac.GetItemIdByName("Advanced Kamikaze")
Mod.RepmTypes.COLLECTIBLE_AXE_ACTIVE = Isaac.GetItemIdByName("Sim's Axe")
Mod.RepmTypes.COLLECTIBLE_CURIOUS_HEART = Isaac.GetItemIdByName("Curious Heart")
Mod.RepmTypes.COLLECTIBLE_STRAWBERRY_MILK = Isaac.GetItemIdByName("Strawberry Milk")
Mod.RepmTypes.COLLECTIBLE_HOLY_SHELL = Isaac.GetItemIdByName("Holy shell")
Mod.RepmTypes.COLLECTIBLE_LEAKY_BUCKET = Isaac.GetItemIdByName("Leaky Bucket")
Mod.RepmTypes.COLLECTIBLE_DELIRIOUS_TECH = Isaac.GetItemIdByName("Delirious Tech")
--Mod.RepmTypes.COLLECTIBLE_VACUUM = Isaac.GetItemIdByName("Vacuum")
Mod.RepmTypes.COLLECTIBLE_BEEG_MINUS = Isaac.GetItemIdByName("Minus")
Mod.RepmTypes.COLLECTIBLE_PIXELATED_CUBE = Isaac.GetItemIdByName("Pixelated Cube")
Mod.RepmTypes.COLLECTIBLE_110V = Isaac.GetItemIdByName("110V")
Mod.RepmTypes.COLLECTIBLE_DILIRIUM_EYE = Isaac.GetItemIdByName("Deliriums Eye")
Mod.RepmTypes.COLLECTIBLE_HOLY_OTMICHKA = Isaac.GetItemIdByName("Holy Master Key")
Mod.RepmTypes.COLLECTIBLE_FLOWER_TEA = Isaac.GetItemIdByName("Flower Tea")
Mod.RepmTypes.COLLECTIBLE_DEAL_OF_THE_DEATH = Isaac.GetItemIdByName("Faustian Bargain")
Mod.RepmTypes.COLLECTIBLE_SANDWICH = Isaac.GetItemIdByName("Sandwich")
Mod.RepmTypes.COLLECTIBLE_BOOK_OF_NECROMANCER = Isaac.GetItemIdByName("Necronomicon Vol. 3")
Mod.RepmTypes.COLLECTIBLE_VHS = Isaac.GetItemIdByName("VHS Cassette")
Mod.RepmTypes.COLLECTIBLE_ROT = Isaac.GetItemIdByName("Rot")
Mod.RepmTypes.COLLECTIBLE_BLOODY_NEGATIVE = Isaac.GetItemIdByName("Bloody Negative")
Mod.RepmTypes.COLLECTIBLE_SIREN_HORNS = Isaac.GetItemIdByName("Siren Horns")
Mod.RepmTypes.COLLECTIBLE_HOW_TO_DIG = Isaac.GetItemIdByName("How To Dig")
Mod.RepmTypes.COLLECTIBLE_BATTERED_LIGHTER = Isaac.GetItemIdByName("Battered Lighter")
Mod.RepmTypes.COLLECTIBLE_HOLY_LIGHTER = Isaac.GetItemIdByName("Holy Lighter")
Mod.RepmTypes.COLLECTIBLE_SAW_SHIELD = Isaac.GetItemIdByName("Saw Shield")
Mod.RepmTypes.COLLECTIBLE_STRONG_SPIRIT = Isaac.GetItemIdByName("Strong Spirit")
Mod.RepmTypes.COLLECTIBLE_PORTAL_D6 = Isaac.GetItemIdByName("Portal D6")

-- Trinkets
Mod.RepmTypes.TRINKET_POCKET_TECHNOLOGY = Isaac.GetTrinketIdByName("Pocket Technology")
Mod.RepmTypes.TRINKET_MICRO_AMPLIFIER = Isaac.GetTrinketIdByName("Micro Amplifier")
Mod.RepmTypes.TRINKET_FROZEN_POLAROID = Isaac.GetTrinketIdByName("Frozen Polaroid")
Mod.RepmTypes.TRINKET_BURNT_CLOVER = Isaac.GetTrinketIdByName("Burnt Clover")
Mod.RepmTypes.TRINKET_MORE_OPTIONS = Isaac.GetTrinketIdByName("MORE OPTIONS")
Mod.RepmTypes.TRINKET_HAMMER = Isaac.GetTrinketIdByName("Hammer")
Mod.RepmTypes.TRINKET_ICE_PENNY = Isaac.GetTrinketIdByName("Ice Penny")

-- Null items
Mod.RepmTypes.NULL_SIRENS_SINGING = Isaac.GetNullItemIdByName("Siren's Singing")
Mod.RepmTypes.NULL_MINUS_SHARD = Isaac.GetNullItemIdByName("Minus Shard")
Mod.RepmTypes.NULL_MINUS_SHARD_POSITIVE_BONUS = Isaac.GetNullItemIdByName("Minus Shard Bonus Positive")
Mod.RepmTypes.NULL_MINUS_SHARD_NEGATIVE_BONUS = Isaac.GetNullItemIdByName("Minus Shard Bonus Negative")
Mod.RepmTypes.NULL_IMPR_REV_STRENTH = Isaac.GetNullItemIdByName("Impoved Rev. Strenght")
Mod.RepmTypes.NULL_HOW_TO_DIG = Isaac.GetNullItemIdByName("How to Dig")

-- Pickups
Mod.RepmTypes.EEE_CHEST = Isaac.GetEntityVariantByName("EEE Chest")
Mod.RepmTypes.PICKUP_AXE = Isaac.GetEntityVariantByName("Sim Axe Pickup")

-- Cards
Mod.RepmTypes.CARD_MINUS_SHARD = Isaac.GetCardIdByName("MinusShard")
Mod.RepmTypes.CARD_HAMMER_CARD = Isaac.GetCardIdByName("HammerCard")

-- Pills
Mod.RepmTypes.PILL_EFFECT_GROOVY = Isaac.GetPillEffectByName("Groovy")

-- Familiars
Mod.RepmTypes.FAMILIAR_SAW_SHIELD = Isaac.GetEntityVariantByName("Saw Shield")

-- Slots
Mod.RepmTypes.SLOT_FOUNTAIN = Isaac.GetEntityVariantByName("Fountain of Confession")

-- Effects
Mod.RepmTypes.EFFECT_FROSTY_RIFT = Isaac.GetEntityVariantByName("Frosty Rift")
Mod.RepmTypes.EFFECT_SAW_SHIELD_FIRE = Isaac.GetEntityVariantByName("Saw Shield Fire Effect")
Mod.RepmTypes.EFFECT_SIMS_AXE = Isaac.GetEntityVariantByName("Sim Axe Active")

-- SFX
Mod.RepmTypes.SFX_WIND = Isaac.GetSoundIdByName("blizz_sound")
Mod.RepmTypes.SFX_LIGHTNING = Isaac.GetSoundIdByName("Thunder")
Mod.RepmTypes.SFX_LIGHTER = Isaac.GetSoundIdByName("lighter_sound")
Mod.RepmTypes.SFX_PICKUP_SAW_SHIELD = Isaac.GetSoundIdByName("sh_pickup")
Mod.RepmTypes.SFX_SAW_SHIELD_BOUNCE = Isaac.GetSoundIdByName("sh_bounce")
Mod.RepmTypes.SFX_SAW_SHIELD_CRASH = Isaac.GetSoundIdByName("sh_wall_crash")
Mod.RepmTypes.SFX_SAW_SHIELD_DAMAGE = Isaac.GetSoundIdByName("sh_shredding")
Mod.RepmTypes.SFX_FOUNTAIN = Isaac.GetSoundIdByName("fountain")

-- Other
Mod.sawShieldReturnCooldown = 300
Mod.sawShieldBounces = 5

Mod.directionToVector = {
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1),
	[Direction.NO_DIRECTION] = Vector(0, 1),
}