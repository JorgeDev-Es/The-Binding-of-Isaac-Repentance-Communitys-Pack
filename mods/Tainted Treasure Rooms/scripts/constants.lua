local mod = TaintedTreasure

mod.maxvariant = 12050 --Starting with a floor of 12000 and mod.maxvariant as the cap, this defines the range of Dice Room layouts that the mod considers to be Tainted Treasure Rooms

TaintedCollectibles = {
	ATLAS = Isaac.GetItemIdByName("Atlas"),
	BAD_ONION = Isaac.GetItemIdByName("The Bad Onion"),
	FORK_BENDER = Isaac.GetItemIdByName("Fork Bender"),
	RAW_SOYLENT = Isaac.GetItemIdByName("Raw Soylent"),
	YEARNING_PAGE = Isaac.GetItemIdByName("Yearning Page"),
	BUZZING_MAGNETS = Isaac.GetItemIdByName("Buzzing Magnets"),
	CLANDESTINE_CARD = Isaac.GetItemIdByName("Clandestine Card"),
	GLAD_BOMBS = Isaac.GetItemIdByName("Glad Bombs"),
	CRICKETS_CRANIUM = Isaac.GetItemIdByName("Cricket's Cranium"),
	DIONYSIUS = Isaac.GetItemIdByName("Dionysius"),
	CONSECRATION = Isaac.GetItemIdByName("Consecration"),
	CRYSTAL_SKULL = Isaac.GetItemIdByName("Crystal Skull"),
	NO_OPTIONS = Isaac.GetItemIdByName("No Options"),
	STEAMY_SURPRISE = Isaac.GetItemIdByName("Steamy Surprise"),
	FINALE = Isaac.GetItemIdByName("Finale"),
	SKELETON_LOCK = Isaac.GetItemIdByName("Skeleton Lock"),
	SALT_OF_MAGNESIUM = Isaac.GetItemIdByName("Salt of Magnesium"),
	WHORE_OF_GALILEE = Isaac.GetItemIdByName("Whore of Galilee"),
	ETERNAL_CANDLE = Isaac.GetItemIdByName("Eternal Candle"),
	OVERSTOCK = Isaac.GetItemIdByName("Overstock"),
	SPIDER_FREAK = Isaac.GetItemIdByName("Spider Freak"),
	BUGULON_SUPER_FAN = Isaac.GetItemIdByName("Bugulon Super Fan"),
	ARROWHEAD = Isaac.GetItemIdByName("Arrowhead"),
	THE_BOTTLE = Isaac.GetItemIdByName("The Bottle"),
	WHITE_BELT = Isaac.GetItemIdByName("White Belt"),
	D_PAD = Isaac.GetItemIdByName("D-Pad"),
	WAR_MAIDEN = Isaac.GetItemIdByName("The War Maiden"),
	BASILISK = Isaac.GetItemIdByName("The Basilisk"),
	POISONED_DART = Isaac.GetItemIdByName("The Poisoned Dart"),
	POLYCORIA = Isaac.GetItemIdByName("Polycoria"),
	COLORED_CONTACTS = Isaac.GetItemIdByName("Colored Contacts"),
	REAPER = Isaac.GetItemIdByName("The Reaper"),
	DRYADS_BLESSING = Isaac.GetItemIdByName("Dryad's Blessing"),
	ATG_IN_A_JAR = Isaac.GetItemIdByName("ATG in a Jar"),
	BROODMIND = Isaac.GetItemIdByName("Broodmind"),
	TECH_ORGANELLE = Isaac.GetItemIdByName("Tech Organelle"),
	GAZEMASTER = Isaac.GetItemIdByName("Gazemaster"),
	SEARED_CLUB = Isaac.GetItemIdByName("Seared Club"),
	LEVIATHAN = Isaac.GetItemIdByName("The Leviathan"),
	RAVENOUS = Isaac.GetItemIdByName("The Ravenous"),
	SORROWFUL_SHALLOT = Isaac.GetItemIdByName("The Sorrowful Shallot"),
	OVERCHARGED_BATTERY = Isaac.GetItemIdByName("Overcharged Battery"),
	LIL_SLUGGER = Isaac.GetItemIdByName("Lil Slugger"),
	BLUE_CANARY = Isaac.GetItemIdByName("Blue Canary"),
	WORMWOOD = Isaac.GetItemIdByName("Wormwood"),
	MAELSTROM = Isaac.GetItemIdByName("The Maelstrom"),
	EVANGELISM = Isaac.GetItemIdByName("Evangelism"),
	LIL_ABYSS = Isaac.GetItemIdByName("Lil Abyss"),
	SWORD = Isaac.GetItemIdByName("The Sword"),
	CONTRACT_OF_SERVITUDE = Isaac.GetItemIdByName("Contract of Servitude"),
	FRACTAL_SYNDROME = Isaac.GetItemIdByName("Fractal Syndrome"),
}

TaintedTrinkets = {
	PURPLE_STAR = Isaac.GetTrinketIdByName("Purple Star"),
}

mod.startingtaintedsets = {
	{CollectibleType.COLLECTIBLE_SAD_ONION, TaintedCollectibles.BAD_ONION},
	{CollectibleType.COLLECTIBLE_TREASURE_MAP, TaintedCollectibles.ATLAS},
	{CollectibleType.COLLECTIBLE_SPOON_BENDER, TaintedCollectibles.FORK_BENDER},
	{CollectibleType.COLLECTIBLE_SOY_MILK, TaintedCollectibles.RAW_SOYLENT},
	{CollectibleType.COLLECTIBLE_MISSING_PAGE_2, TaintedCollectibles.YEARNING_PAGE},
	{CollectibleType.COLLECTIBLE_LODESTONE, TaintedCollectibles.BUZZING_MAGNETS},
	{CollectibleType.COLLECTIBLE_MEMBER_CARD, TaintedCollectibles.CLANDESTINE_CARD},
	{CollectibleType.COLLECTIBLE_SAD_BOMBS, TaintedCollectibles.GLAD_BOMBS},
	{CollectibleType.COLLECTIBLE_CRICKETS_HEAD, TaintedCollectibles.CRICKETS_CRANIUM},
	{CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE, TaintedCollectibles.DIONYSIUS},
	{CollectibleType.COLLECTIBLE_HOLY_LIGHT, TaintedCollectibles.CONSECRATION},
	{CollectibleType.COLLECTIBLE_ANKH, TaintedCollectibles.CRYSTAL_SKULL},
	{CollectibleType.COLLECTIBLE_THERES_OPTIONS, TaintedCollectibles.NO_OPTIONS},
	{CollectibleType.COLLECTIBLE_STEAM_SALE, TaintedCollectibles.STEAMY_SURPRISE},
	{CollectibleType.COLLECTIBLE_SKELETON_KEY, TaintedCollectibles.SKELETON_LOCK},
	{CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, TaintedCollectibles.SALT_OF_MAGNESIUM},
	{CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, TaintedCollectibles.WHORE_OF_GALILEE},
	{CollectibleType.COLLECTIBLE_BLACK_CANDLE, TaintedCollectibles.ETERNAL_CANDLE},
	{CollectibleType.COLLECTIBLE_RESTOCK, TaintedCollectibles.OVERSTOCK},
	{CollectibleType.COLLECTIBLE_MUTANT_SPIDER, TaintedCollectibles.SPIDER_FREAK},
	{CollectibleType.COLLECTIBLE_SMB_SUPER_FAN, TaintedCollectibles.BUGULON_SUPER_FAN},
	{CollectibleType.COLLECTIBLE_CUPIDS_ARROW, TaintedCollectibles.ARROWHEAD},
	{CollectibleType.COLLECTIBLE_MOMS_KNIFE, TaintedCollectibles.THE_BOTTLE},
	{CollectibleType.COLLECTIBLE_CHAMPION_BELT, TaintedCollectibles.WHITE_BELT},
	{CollectibleType.COLLECTIBLE_ANALOG_STICK, TaintedCollectibles.D_PAD},
	{CollectibleType.COLLECTIBLE_LEO, TaintedCollectibles.WAR_MAIDEN},
	{CollectibleType.COLLECTIBLE_GEMINI, TaintedCollectibles.BASILISK},
	{CollectibleType.COLLECTIBLE_SCORPIO, TaintedCollectibles.POISONED_DART},
	{CollectibleType.COLLECTIBLE_POLYPHEMUS, TaintedCollectibles.POLYCORIA},
	{CollectibleType.COLLECTIBLE_LOST_CONTACT, TaintedCollectibles.COLORED_CONTACTS},
	{CollectibleType.COLLECTIBLE_GHOST_PEPPER, TaintedCollectibles.REAPER},
	{CollectibleType.COLLECTIBLE_SERPENTS_KISS, TaintedCollectibles.DRYADS_BLESSING},
	{CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR, TaintedCollectibles.ATG_IN_A_JAR},
	{CollectibleType.COLLECTIBLE_HIVE_MIND, TaintedCollectibles.BROODMIND},
	{CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO, TaintedCollectibles.TECH_ORGANELLE},
	{CollectibleType.COLLECTIBLE_XRAY_VISION, TaintedCollectibles.GAZEMASTER},
	{CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER, TaintedCollectibles.SEARED_CLUB},
	{CollectibleType.COLLECTIBLE_LIBRA, TaintedCollectibles.RAVENOUS},
	{TaintedCollectibles.BAD_ONION, TaintedCollectibles.SORROWFUL_SHALLOT},
	{CollectibleType.COLLECTIBLE_BATTERY, TaintedCollectibles.OVERCHARGED_BATTERY},
	{CollectibleType.COLLECTIBLE_DR_FETUS, TaintedCollectibles.LIL_SLUGGER},
	{CollectibleType.COLLECTIBLE_NIGHT_LIGHT, TaintedCollectibles.BLUE_CANARY},
	{CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM, TaintedCollectibles.WORMWOOD},
	{CollectibleType.COLLECTIBLE_VIRGO, TaintedCollectibles.MAELSTROM},
	{CollectibleType.COLLECTIBLE_GODHEAD, TaintedCollectibles.EVANGELISM},
	{CollectibleType.COLLECTIBLE_LIL_PORTAL, TaintedCollectibles.LIL_ABYSS},
	{CollectibleType.COLLECTIBLE_PISCES, TaintedCollectibles.SWORD},
	--{CollectibleType.COLLECTIBLE_INNER_EYE, TaintedCollectibles.FRACTAL_SYNDROME},
}

if EID then
	EID:addCollectible(TaintedCollectibles.ATLAS, "Generates up to 4 additional rooms each floor#Rooms can be normal or of any special room type")
	EID:addCollectible(TaintedCollectibles.BAD_ONION, "↑ {{Damage}} +1 damage up each time an enemy dies, rapidly fades over time")
	EID:addCollectible(TaintedCollectibles.FORK_BENDER, "Each time an enemy fires a projectile, it has a 1/5 chance to reverse direction and become a homing tear")
	EID:addCollectible(TaintedCollectibles.RAW_SOYLENT, "{{Collectible330}} Each time you fire a tear, you fire 7 additional Soy Milk tears in a circle around you")
	EID:addCollectible(TaintedCollectibles.YEARNING_PAGE, "{{BlackHeart}} +1 Black Heart#↑ {{Damage}} +1.5 damage up#{{Collectible35}} Future items have a chance to be replaced with The Necronomicon")
	EID:addCollectible(TaintedCollectibles.BUZZING_MAGNETS, "{{Magnetize}} Tears have a chance to inflict enemies with repulsion#Enemies inflicted with repulsion are forcefully pushed away from players and take damage when quickly shoved into other enemies and walls")
	EID:addCollectible(TaintedCollectibles.CLANDESTINE_CARD, "{{Shop}} Adds a trapdoor to each shop that leads to the Black Market")
	EID:addCollectible(TaintedCollectibles.GLAD_BOMBS, "{{Bomb}} +5 bombs#Bombs take longer to explode#Bombs shoot a barrage of tears at nearby enemies before they explode")
	EID:addCollectible(TaintedCollectibles.CRICKETS_CRANIUM, "↑ {{Damage}} +0.5 Damage up#↑ {{Damage}} 2X Damage Multiplier#{{Damage}} Prevents your damage from going higher for the rest of the run after being picked up")
	EID:addCollectible(TaintedCollectibles.DIONYSIUS, "{{Collectible577}} Damocles may appear over the head of an enemy in an uncleared room#When an enemy with Damocles over its head takes damage, Damocles falls and instantly kills them. If it's a boss, they take 80 damage instead")
	EID:addCollectible(TaintedCollectibles.CONSECRATION, "Gain a chance to shoot orange tears which create waves of fire in a cross pattern on impact that deal 3 times your damage")
	EID:addCollectible(TaintedCollectibles.CRYSTAL_SKULL, "{{Player16}} Respawn as The Forgotten in the previous room on death#{{EmptyBoneHeart}} You respawn with one empty Bone Heart and half of a Soul Heart")
	EID:addCollectible(TaintedCollectibles.NO_OPTIONS, "↑ {{Damage}} Instead of receiving items after defeating bosses, you gain a permanent +0.8 flat damage boost")
	EID:addCollectible(TaintedCollectibles.STEAMY_SURPRISE, "{{Shop}} Shops contain fewer goods#{{Trinket13}} You recieve a free Store Credit in each shop")
	EID:addCollectible(TaintedCollectibles.FINALE, "Teleport directly to Home#{{Heart}} Full heatlh#{{Card78}} Spawns an item and a Cracked Key in Isaac's room, alongside 20 other random pickups")
	EID:addCollectible(TaintedCollectibles.SKELETON_LOCK, "{{Key}} You can only hold up to 5 keys#↑ Each time you open a lock, you recieve a random stat boost")
	EID:addCollectible(TaintedCollectibles.SALT_OF_MAGNESIUM, "Tears have a chance to make enemies fly backwards while pooping for no additional damage#Poop can drop pickups")
	EID:addCollectible(TaintedCollectibles.WHORE_OF_GALILEE, "↑ Gain increased {{TearsSmall}} tears, {{RangeSmall}} range, and {{LuckSmall}} luck while all {{Heart}} red heart containers are filled#Does not work with no red heart containers")
	EID:addCollectible(TaintedCollectibles.ETERNAL_CANDLE, "↑ All curses will provide additional unique benefits to the player#You are guaranteed to have a curse every floor")
	EID:addCollectible(TaintedCollectibles.OVERSTOCK, "{{Shop}} All shops are Tainted Keeper shops#{{Shop}} Shops spawn in Womb#{{Player33}} If Tainted Keeper is in the game, attempts to spawn an extra shop each floor instead")
	EID:addCollectible(TaintedCollectibles.SPIDER_FREAK, "Shoot six tears at once!")
	EID:addCollectible(TaintedCollectibles.BUGULON_SUPER_FAN, "↑ {{Speed}} +0.3 Speed up#↑ {{Luck}} +1 Luck up#Props spawn in uncleared rooms and can be thrown at enemies to deal damage")
	EID:addCollectible(TaintedCollectibles.ARROWHEAD, "↑ {{ShotSpeed}} +0.3 Shot Speed up#↑ {{Range}} +3 Range up#Tears are spectral, and are fired a small distance away from Isaac and travel backwards#If they pass through Isaac, they gain 50% increased damage and become piercing")
	EID:addCollectible(TaintedCollectibles.THE_BOTTLE, "Gain a bottle that behaves like Mom's Knife, but deals less damage#If the bottle is fully charged, it breaks when it hits an enemy, dealing high damage and spawning damaging glass shards#The bottle comes back after 5 seconds with increased damage#Bottle resets its condition in new rooms")
	EID:addCollectible(TaintedCollectibles.WHITE_BELT, "Reduces the spawn rate of champion enemies#When entering a new room or taking damage, gain an aura that strongly repels enemies and projectiles for 4 seconds")
	EID:addCollectible(TaintedCollectibles.D_PAD, "While in combat, a quick time prompt will periodically appear next to the player#Pressing the correct input will grant a temporary {{Damage}} damage boost#Being too slow or pressing the wrong input grants nothing")
	EID:addCollectible(TaintedCollectibles.WAR_MAIDEN, "You can smash through walls to loop to the opposite side of the room")
	EID:addCollectible(TaintedCollectibles.BASILISK, "Gain a powerful fetal demon familiar that agressively charges at enemies, slightly dragging the player along with it#The cord has a chance to break when the player takes damage, allowing it to move freely")
	EID:addCollectible(TaintedCollectibles.POISONED_DART, "Move close to an enemy to inflict them with a crippling effect that causes them to take double damage")
	EID:addCollectible(TaintedCollectibles.POLYCORIA, "Tears are fired in large clusters which split when hitting an object")
	EID:addCollectible(TaintedCollectibles.COLORED_CONTACTS, "Tears gain a 50% damage increase and turn a random color when they pass through enemy projectiles")
	EID:addCollectible(TaintedCollectibles.REAPER, "{{Chargeable}} After firing for ~3 seconds and releasing, shoots a barrage of white fires forward#White fires have a chance to create explosive ghosts on killing enemies")
	EID:addCollectible(TaintedCollectibles.DRYADS_BLESSING, "Tears have a chance to inflict enemies with germinated#Germinated enemies gain an aura around themselves which increases the stats of any players who stand in it")
	EID:addCollectible(TaintedCollectibles.ATG_IN_A_JAR, "{{Bomb}} +5 bombs#If shooting, placed bombs turn into movable crosshairs that launch the bombs as delayed missiles")
	EID:addCollectible(TaintedCollectibles.BROODMIND, "Friendly flies and spiders no longer attack autonomously and can deal damage multiple times#Flies launch themselves in the direction you're firing#Spiders will swarm towards nearby enemies you're aiming at and huddle close to you otherwise#Each time a friendly fly or spider spawns, two may spawn instead")
	EID:addCollectible(TaintedCollectibles.TECH_ORGANELLE, "Tears and bombs will be connected to you with a beam of electricity#Electricity deals 33% of your damage")
	EID:addCollectible(TaintedCollectibles.GAZEMASTER, "Improves the layouts and rewards of Secret Rooms and Super Secret Rooms")
	EID:addCollectible(TaintedCollectibles.SEARED_CLUB, "All enemies explode on death#Explosions inherit bomb effects#Explosion size and damage scales with enemy max health#You should stand far away from bosses before they die")
	EID:addCollectible(TaintedCollectibles.LEVIATHAN, "↓ Lowers all stats when first picking up#When entering uncleared rooms, there is a chance to spawn poops or yellow creep#↑ After this happens enough times, the all stats down is replaced by a greater all stats up.")
	EID:addCollectible(TaintedCollectibles.RAVENOUS, "Grants 12 of the pickup you have the most of, and 1 of the rest of them#Siphons 10% from each of your stats into your stat which is the highest, boosting that stat even further")
	EID:addCollectible(TaintedCollectibles.SORROWFUL_SHALLOT, "Passively fire tears around yourself which scales with your {{Damage}} Damage and {{Tears}} Tears stats#Killing enemies temporarily increases the rate at which these tears are spawned")
	EID:addCollectible(TaintedCollectibles.OVERCHARGED_BATTERY, "Gain an additional chargebar adjacent to your active item's chargebar that fills when clearing rooms while the active item is fully charged#When you use your active item while the bar is full, it unleashes waves of lasers around you that deal 3 times your damage and break obstacles")
	EID:addCollectible(TaintedCollectibles.LIL_SLUGGER, "You fire piercing sawblade tears that deal repeated damage as they pass through enemies#Sawblades will revolve around obstacles and walls that they hit")
	EID:addCollectible(TaintedCollectibles.BLUE_CANARY, "Spawns a cone in front of you that inflicts enemies with Enlightenment#Every few seconds, each Enlightened enemy in the room will take damage that scales with player damage and the number of Enlightened enemies in the room")
	EID:addCollectible(TaintedCollectibles.WORMWOOD, "Familiar that emits a small aura and slowly travels towards the {{BossRoom}} Boss room#↓ Aura inflicts a tears and damage down#If you beat it to the boss room, you gain a permanent +0.5 tears up that breaks the cap#If it beats you to the boss room, its aura expands to cover the entire room")
	EID:addCollectible(TaintedCollectibles.MAELSTROM, "Taking damage adds a charge of the 'Blade Maelstrom' ability, you can hold up to 3 charges#Double tapping shoot will consume a charge and fire a vortex of sawblades, some of which pull enemies into them")
	EID:addCollectible(TaintedCollectibles.EVANGELISM, "↑ {{Damage}} +0.5 Damage#↓ {{Shot Speed}} -0.3 Shot speed#↓ {{Tears}} Tears down#Tears are surrounded by a static aura that causes enemies within it to glow white, once they glow enough they are struck by a light beam")
	EID:addCollectible(TaintedCollectibles.LIL_ABYSS, "Grants an abyss familiar that bounces around the room diagonally, dealing contact damage#Pulls player and enemy projectiles into itself, after absorbing enough it fires a large barrage of tears at enemies#Can consume trinkets, for every two trinkets consumed it pays out with an Abyss Locust")
	EID:addCollectible(TaintedCollectibles.SWORD, "Grants a swordfish familiar that can skewer enemies then launched them away#Launched enemies damage other enemies they touch and take damage when colliding with a grid")
	EID:addCollectible(TaintedCollectibles.CONTRACT_OF_SERVITUDE, "Grants a unique familiar for each character")

	EID:addTrinket(TaintedTrinkets.PURPLE_STAR, "Increases the chance for Tainted Treasure Rooms to spawn#Tainted Treasure Rooms can spawn in Chapter 4")
end

mod.ContractEffects = { --Index = player type, first entry = item description, second entry = EID description
	[PlayerType.PLAYER_BLUEBABY] = {"Not so lonely", "#{{Player4}} Grants a more powerful version of {{Collectible320}} ???'s Only Friend that poops and scales with player damage"},
	[PlayerType.PLAYER_JUDAS] = {"Belial boy", "#{{Player3}} Grants a familiar that gains a massive damage boost for the room each time your active item is used"},
	[PlayerType.PLAYER_AZAZEL_B] = {"Belphegor", "#{{Player28}} Grants a familiar that follows behind you and faces away from where you're shooting and sneezes when Azazel does, sometimes targeting enemies on its own"},
	[PlayerType.PLAYER_BETHANY] = {"Her favorite", "#{{Player18}} Grants an immortal wisp that fires lost contact wisps and can regenerate other wisps"},
	[PlayerType.PLAYER_BLUEBABY_B] = {"Bygone", "#{{Player25}} Grants a Polty familiar you can throw poop to#Will find an enemy and throw its held poop at it"},
	[PlayerType.PLAYER_LILITH] = {"Asmodeus", "#{{Player13}} Grants a familiar that orbits around {{Collectible360}} Incubus, firing player tears and dealing contact damage"},
	[PlayerType.PLAYER_MAGDALENE] = {"I love you too", "#{{Player1}} Grants a familiar that bounces diagonally throughout the room, standing in its aura grants a high chance to prevent damage"},
	[PlayerType.PLAYER_SAMSON] = {"Stims", "#{{Player6}} Grants a familiar that has a 50% chance to deal fake damage to you each time you enter a new room"},
	[PlayerType.PLAYER_THEFORGOTTEN] = {"Hey soul sister", "#{{Player16}} Grants a familiar that stays close to your side and fires projectiles while you're the Forgotten, and swings a bone club by the Forgotten's body while you're the Soul"},
	[PlayerType.PLAYER_THESOUL] = {"Hey soul sister", "#{{Player16}} Grants a familiar that stays close to your side and fires projectiles while you're the Forgotten, and swings a bone club by the Forgotten's body while you're the Soul"},
	[PlayerType.PLAYER_CAIN_B] = {"Double tap duplication", "#{{Player23} {{Throwable}} Throwable (double-tap shoot)#Duplicates the first projectile it touches#Has a chance to respawn each time you clear a room"},
}

mod.TaintedBeggarBlacklist = {
	[CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE] = true,
	[TaintedCollectibles.BAD_ONION] = true,
}

mod.PurpleSparkleBlacklist = {
	[TaintedCollectibles.BAD_ONION] = true,
	[CollectibleType.COLLECTIBLE_POLAROID] = true,
	[CollectibleType.COLLECTIBLE_NEGATIVE] = true,
}

mod.PurpleSparkleWhitelist = {
	[CollectibleType.COLLECTIBLE_DAMOCLES] = true,
}

TaintedTears = {
	SAWBLADE = Isaac.GetEntityVariantByName("Sawblade Tear"),
}

TaintedFamiliars = {
	BASILISK = Isaac.GetEntityVariantByName("Basilisk Baby"),
	LIL_ABYSS = Isaac.GetEntityVariantByName("Lil Abyss"),
	BLUEBABYS_BEST_FRIEND = Isaac.GetEntityVariantByName("???'s Best Friend"),
	SWORDFISH = Isaac.GetEntityVariantByName("Swordfish"),
	BELIAL_BOY = Isaac.GetEntityVariantByName("Belial Boy"),
	BELPHEGOR = Isaac.GetEntityVariantByName("Belphegor"),
	BYGONE = Isaac.GetEntityVariantByName("Bygone"),
	ASMODEUS = Isaac.GetEntityVariantByName("Asmodeus"),
	GLUTTON_BABY = Isaac.GetEntityVariantByName("Glutton Baby"),
	STIMS = Isaac.GetEntityVariantByName("Stims"),
	SOUL_SISTER = Isaac.GetEntityVariantByName("Soul Sister"),
	BONE_SISTER = Isaac.GetEntityVariantByName("Bone Sister"),
	TRUE_SIGHT = Isaac.GetEntityVariantByName("True Sight"),
}

TaintedPickups = {
	BUGULON_PROP = Isaac.GetEntityVariantByName("Bugulon Prop (Chair)"),
}

TaintedMachines = {
	TAINTED_BEGGAR = Isaac.GetEntityVariantByName("Tainted Beggar"),
}

TaintedNPCs = {
	BASILISK_CORD = {ID = EntityType.ENTITY_EVIS, Var = 10, Sub = 1500},
	DOGMA_RENDERER = {ID = EntityType.ENTITY_DOGMA, Var = 1500},
}

TaintedEffects = {
	FADE_IN = Isaac.GetEntityVariantByName("Fade In"),
	DIONYSIUS = Isaac.GetEntityVariantByName("Dionysius"),
	ITEM_GHOST = Isaac.GetEntityVariantByName("Item Ghost"),
	BOTTLE_SHARD = Isaac.GetEntityVariantByName("Bottle Shard"),
	SWIPE = Isaac.GetEntityVariantByName("Swipe"),
	DUMMY = Isaac.GetEntityVariantByName("Dummy Effect"),
	SPARKLE = Isaac.GetEntityVariantByName("Tainted Sparkle"),
	CRYSTAL_LEAF = Isaac.GetEntityVariantByName("Crystal Leaf"),
	GERMINATED_AURA = Isaac.GetEntityVariantByName("Germinated Aura"),
	ATG_TARGET = Isaac.GetEntityVariantByName("ATG Target"),
	PLAYER_FIRE_JET = Isaac.GetEntityVariantByName("Player Fire Jet"),
	CANARY_LIGHT = Isaac.GetEntityVariantByName("Canary Light"),
	MAELSTROM_INDIACTOR = Isaac.GetEntityVariantByName("Maelstrom Indicator"),
	EVANGELISM_HALO = Isaac.GetEntityVariantByName("Evangelism Halo"),
}

TaintedCostumes = {
	BadOnionSteam = Isaac.GetCostumeIdByPath("gfx/characters/costume_badonion_steam.anm2"),
	WhoreOfGalilee = Isaac.GetCostumeIdByPath("gfx/characters/costume_whoreofgalilee.anm2"),
	WhoreOfGalileeHair = Isaac.GetCostumeIdByPath("gfx/characters/costume_whoreofgalilee_hair.anm2"),
	LeviathanPurified = Isaac.GetCostumeIdByPath("gfx/characters/costume_leviathan2.anm2"),
	OverchargedBattery = Isaac.GetCostumeIdByPath("gfx/characters/costume_overchargedbattery.anm2"),
}

TaintedSounds = {
	POWERUPTAINTED = Isaac.GetSoundIdByName("TaintedTreasure"),
	MAGNET_BUZZ = Isaac.GetSoundIdByName("Magnet Buzz"),
	FART_BLAST = Isaac.GetSoundIdByName("FartBlast"),
	ATONEMENT_THROW = Isaac.GetSoundIdByName("AtonementThrow"),
	ATONEMENT_IMPACT = Isaac.GetSoundIdByName("AtonementImpact"),
	BOTTLE_BREAK = Isaac.GetSoundIdByName("BottleBreak"),
	BOTTLE_BREAK2 = Isaac.GetSoundIdByName("BottleBreak2"),
	DPAD_BEEP = Isaac.GetSoundIdByName("DPadBeep1"),
	DPAD_BEEP2 = Isaac.GetSoundIdByName("DPadBeep2"),
	DPAD_WIN = Isaac.GetSoundIdByName("DPadWin"),
	DPAD_FAIL = Isaac.GetSoundIdByName("DPadFail"),
	SAW_AMBIENT = Isaac.GetSoundIdByName("SawAmbient"),
	SAW_ATTACH = Isaac.GetSoundIdByName("SawAttach"),
	SAW_SHOOT = Isaac.GetSoundIdByName("SawShoot"),
}

TaintedTracks = {
	SACRIFICIAL = Isaac.GetMusicIdByName("Sacrificial"),
}

TaintedChallenges = {
	ART_OF_WAR = Isaac.GetChallengeIdByName("Art of War"),
}

mod.ColorSaltOfMagnesium = Color(1,1,0,1,100 / 255,50 / 255,30 / 255)
	mod.ColorSaltOfMagnesium:SetColorize(1,1,1,1)
mod.ColorConsecration = Color(1, 1, 1, 1, 1, 0.3, 0)
mod.ColorBuzzingMagnet = Color(0.2, 0.2, 0.2, 1, 0, 0, 0)
mod.ColorBuzzingMagnetCreep = Color(0, 0, 0.2, 1, 0.2, 0.2, 0.2)
mod.ColorWeakness = Color(1,1,1)
	mod.ColorWeakness:SetColorize(1.3,1,1.5,0.6)
mod.ColorGreyscale = Color(1,1,1)
	mod.ColorGreyscale:SetColorize(1,1,1,1)
mod.ColorGreyscaleLight = Color(1,1,1,1,0.1,0.1,0.1)
	mod.ColorGreyscaleLight:SetColorize(1,1,1,1)
mod.ColorGerminated = Color(0.3,1,0.3,1,0.2,0.4,0.2)
mod.ColorEnlightened = Color(0.4,0.4,1,1,0.1,0.1,0.3)
mod.ColorGerminatedCreep = Color(0.3,1,0.3,1,0.2,0.8,0.4)
mod.ColorPsy = Color(0.4,0.4,0.4,1,66 / 255,13 / 255,102 / 255)
mod.ColorHoming = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)
mod.ColorSoy = Color(1.5, 2, 2, 1, 0, 0, 0)
mod.ColorPoop = Color(0,0,0,1,55 / 255,35 / 255,30 / 255)
mod.ColorPoop2 = Color(1.5,1.5,1.5,1,-0.4,-0.45,-0.4) --Doesn't work :(
mod.ColorPeepPiss = Color(1,1,1,1,0.235,0.235,0)
	mod.ColorPeepPiss:SetColorize(1,1,0,1)
mod.ColorElectricRed = Color(1,0.5,0.5,1,0.6,0,0)
mod.ColorShadyRed = Color(-1,-1,-1,1,1,0,0)

-- ROOM GEN
mod.adjindexes = {
	[RoomShape.ROOMSHAPE_1x1] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13, 
		[DoorSlot.RIGHT0] = 1, 
		[DoorSlot.DOWN0] = 13
	},
	[RoomShape.ROOMSHAPE_IH] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.RIGHT0] = 1
	},
	[RoomShape.ROOMSHAPE_IV] = {
		[DoorSlot.UP0] = -13, 
		[DoorSlot.DOWN0] = 13
	},
	[RoomShape.ROOMSHAPE_1x2] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13, 
		[DoorSlot.RIGHT0] = 1, 
		[DoorSlot.DOWN0] = 26,
		[DoorSlot.LEFT1] = 12, 
		[DoorSlot.RIGHT1] = 14
	},
	[RoomShape.ROOMSHAPE_IIV] = {
		[DoorSlot.UP0] = -13, 
		[DoorSlot.DOWN0] = 26
	},
	[RoomShape.ROOMSHAPE_2x1] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13, 
		[DoorSlot.RIGHT0] = 2,
		[DoorSlot.DOWN0] = 13,
		[DoorSlot.UP1] = -12,
		[DoorSlot.DOWN1] = 14
	},
	[RoomShape.ROOMSHAPE_IIH] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.RIGHT0] = 3
	},
	[RoomShape.ROOMSHAPE_2x2] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13,
		[DoorSlot.RIGHT0] = 2,
		[DoorSlot.DOWN0] = 26,
		[DoorSlot.LEFT1] = 12,
		[DoorSlot.UP1] = -12, 
		[DoorSlot.RIGHT1] = 15, 
		[DoorSlot.DOWN1] = 27
	},
	[RoomShape.ROOMSHAPE_LTL] = {
		[DoorSlot.LEFT0] = -1,
		[DoorSlot.UP0] = -1,
		[DoorSlot.RIGHT0] = 1, 
		[DoorSlot.DOWN0] = 25,
		[DoorSlot.LEFT1] = 11, 
		[DoorSlot.UP1] = -13, 
		[DoorSlot.RIGHT1] = 14, 
		[DoorSlot.DOWN1] = 26
	},
	[RoomShape.ROOMSHAPE_LTR] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13, 
		[DoorSlot.RIGHT0] = 1,
		[DoorSlot.DOWN0] = 26,
		[DoorSlot.LEFT1] = 12, 
		[DoorSlot.UP1] = 1,
		[DoorSlot.RIGHT1] = 15, 
		[DoorSlot.DOWN1] = 27
	},
	[RoomShape.ROOMSHAPE_LBL] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13,
		[DoorSlot.RIGHT0] = 2,
		[DoorSlot.DOWN0] = 13,
		[DoorSlot.LEFT1] = 13,
		[DoorSlot.UP1] = -12, 
		[DoorSlot.RIGHT1] = 15, 
		[DoorSlot.DOWN1] = 27
	},
	[RoomShape.ROOMSHAPE_LBR] = {
		[DoorSlot.LEFT0] = -1, 
		[DoorSlot.UP0] = -13,
		[DoorSlot.RIGHT0] = 2,
		[DoorSlot.DOWN0] = 26,
		[DoorSlot.LEFT1] = 12,
		[DoorSlot.UP1] = -12,
		[DoorSlot.RIGHT1] = 14,
		[DoorSlot.DOWN1] = 14
	}
}

mod.borderrooms = {
	[DoorSlot.LEFT0] = {0, 13, 26, 39, 52, 65, 78, 91, 104, 117, 130, 143, 156},
	[DoorSlot.UP0] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
	[DoorSlot.RIGHT0] = {12, 25, 38, 51, 64, 77, 90, 103, 116, 129, 142, 155, 168},
	[DoorSlot.DOWN0] = {156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168},
	[DoorSlot.LEFT1] = {0, 13, 26, 39, 52, 65, 78, 91, 104, 117, 130, 143, 156},
	[DoorSlot.UP1] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
	[DoorSlot.RIGHT1] = {12, 25, 38, 51, 64, 77, 90, 103, 116, 129, 142, 155, 168},
	[DoorSlot.DOWN1] = {156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168}
}

mod.oppslots = {
	[DoorSlot.LEFT0] = DoorSlot.RIGHT0, 
	[DoorSlot.UP0] = DoorSlot.DOWN0, 
	[DoorSlot.RIGHT0] = DoorSlot.LEFT0, 
	[DoorSlot.LEFT1] = DoorSlot.RIGHT0, 
	[DoorSlot.DOWN0] = DoorSlot.UP0, 
	[DoorSlot.UP1] = DoorSlot.DOWN0, 
	[DoorSlot.RIGHT1] = DoorSlot.LEFT0, 
	[DoorSlot.DOWN1] = DoorSlot.UP0
}

mod.shapeindexes = {
	[RoomShape.ROOMSHAPE_1x1] = { 0 },
	[RoomShape.ROOMSHAPE_IH] = { 0 },
	[RoomShape.ROOMSHAPE_IV] = { 0 },
	[RoomShape.ROOMSHAPE_1x2] = { 0, 13 },
	[RoomShape.ROOMSHAPE_IIV] = { 0, 13 },
	[RoomShape.ROOMSHAPE_2x1] = { 0, 1 },
	[RoomShape.ROOMSHAPE_IIH] = { 0, 1 },
	[RoomShape.ROOMSHAPE_2x2] = { 0, 1, 13, 14 },
	[RoomShape.ROOMSHAPE_LTL] = { 1, 13, 14 },
	[RoomShape.ROOMSHAPE_LTR] = { 0, 13, 14 },
	[RoomShape.ROOMSHAPE_LBL] = { 0, 1, 14 },
	[RoomShape.ROOMSHAPE_LBR] = { 0, 1, 13 },
}
-- END OF ROOM GEN 