local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

if EID then
	EID:addIcon("Shield", "Idle", 0, 16, 16, -2, -2, Sprite("gfx/compat/eid_shield.anm2", true))
	EID:addIcon("MirrorShard", "Idle", 0, 16, 16, -2, -2, Sprite("gfx/compat/eid_pickups.anm2", true))
	EID:addIcon("PlasticBrick", "Idle", 1, 16, 16, -2, -2, Sprite("gfx/compat/eid_pickups.anm2", true))
	
	EID:addCollectible(mod.Collectible.TOY_SOLDIER, "{{Shield}} Grants a shield that prevents explosion damage and one hit per-floor#{{DevilRoom}} The shield can be traded for a Devil Room item#{{Warning}} The trade still affects Angel Room chance")
	EID:addCollectible(mod.Collectible.EPHEMERAL_TORCH, "{{ArrowUp}} {{Luck}} +10 Luck#{{ArrowDown}} {{Luck}} -1 Luck when clearing a room#Damage from a fireplace restores luck#5% chance to replace rocks with fireplaces")
	EID:addAbyssSynergiesCondition(mod.Collectible.EPHEMERAL_TORCH, "Orange locust that burns enemies")
	
	EID:addCollectible(mod.Collectible.CLAY_JAR, "{{Throwable}} Throwable jar that bounces off obstacles and enemies#The jar deals 18 contact damage#{{BleedingOut}} Creates fragments where it lands that deal 4 damage per tick and cause bleeding")
	EID:addCondition(mod.Collectible.CLAY_JAR, "5.350." .. TrinketType.TRINKET_MODELING_CLAY, "Increases Jar's contact damage by 4")
	
	EID:addCollectible(mod.Collectible.BAALS_ALTAR, "Use and collide with an item pedestal to store it#Use again to dispense the item")
	EID:addCollectible(mod.Collectible.ASHERAH_POLE, "Near enemies become targeted#Targeted enemies are periodically struck by 3 beams of light until they die#{{Warning}} The beams can also hurt Isaac")
	EID:addBFFSCondition(mod.Collectible.ASHERAH_POLE, nil, 3)
	EID:addAbyssSynergiesCondition(mod.Collectible.ASHERAH_POLE, "White, glowing, slow locust that has a chance to summon beams of light that deal triple Isaac's damage")
	
	EID:addCollectible(mod.Collectible.COVENANT, "Pedestal items have a quality based chance to be marked#{{ArrowUp}} {{Damage}} Taking the marked item grants +0.5 Damage and an Eternal Heart#{{AngelDevilChance}} +35% Devil/Angel Room chance")
	EID:addCollectible(mod.Collectible.BATTLE_BANNER, "{{BossRoom}} Reveals the location of the Boss Room#{{ArrowUp}} {{Damage}} x1.8 Damage multiplier#{{Warning}} Damage is lost when backtracking more than three times#Entering a new floor restores damage")
	EID:addCollectible(mod.Collectible.DEMISE_OF_THE_FAITHFUL, "{{EmptyBoneHeart}} +1 Bone Heart#{{ArrowUp}} {{Damage}} x1.3 Damage multiplier#{{BossRoom}} Bosses drop additional rewards when defeated")
	EID:addCollectible(mod.Collectible.APPETIZER, "{{ArrowUp}} {{Heart}} +1 Health#{{HealingRed}} Heals 1 heart#The max amount of Heart containers is raised by 1")
	EID:addBingeEaterBuffsCondition(mod.Collectible.APPETIZER, "{{ArrowUp}} {{Range}} +2.5 Range#{{ArrowUp}} {{Luck}} +1 Luck#{{ArrowUp}} {{Damage}} Temporary +3.6 Damage#{{ArrowDown}} {{Speed}} -0.03 Speed")
	EID:AddItemConditional(mod.Collectible.APPETIZER, CollectibleType.COLLECTIBLE_BINGE_EATER, "Binge Eater Healing") -- Binge Eater (Heals 2 hearts)
	
	EID:addCollectible(mod.Collectible.HAPPY_FLY, "Moves randomly around the room#Grants invincibility for 1.2 seconds when touched")
	EID:addBFFSCondition(mod.Collectible.HAPPY_FLY, nil, 1.2)
	
	EID:addCollectible(mod.Collectible.GROCERY_BAG, "Increases the {{Coin}} coin / {{Bomb}} bomb / {{Key}} key cap by 50#{{Shop}} Shops have bigger stock and may offer items from the grocery item pool")
	
	EID:addCollectible(mod.Collectible.TOY_SHOVEL, "10% chance to dig up a random pickup#Chance is increased by 10% when used in a special room#Chance is increased by 40% when used on a decorative floor tile (grass, small rocks, papers, gems, etc.)")
	EID:addCondition(mod.Collectible.TOY_SHOVEL, CollectibleType.COLLECTIBLE_TREASURE_MAP, "Increases chance by 20%")
	EID:addCondition(mod.Collectible.TOY_SHOVEL, CollectibleType.COLLECTIBLE_BLUE_MAP, "Increases chance by 20%")
	
	EID:addCollectible(mod.Collectible.DEL_KEY, "All enemies take point of damage every few frames#{{ERROR}} Corrupts their sprites")
	EID:addCollectible(mod.Collectible.CRACKED_MIRROR, "{{ArrowDown}} {{Luck}} -1 Luck#{{MirrorShard}} Enemies have a chance to drop a Mirror Shard on death that disappears in 7 seconds#{{Luck}} The chance is influenced by the amount of negative luck Isaac has#{{Pill}} Forces a Luck Down pill into the pill rotation")
	EID:addCollectible(mod.Collectible.BOX_CUTTER, "{{EmptyHeart}} Removes 1 heart container#Spawns 6 random pickups#{{Collectible214}} Grants Anemic for the room")
	EID:addCondition(mod.Collectible.BOX_CUTTER, CollectibleType.COLLECTIBLE_BOX, "Spawns 2 more random pickups")
	EID:addCondition(mod.Collectible.BOX_CUTTER, CollectibleType.COLLECTIBLE_MOVING_BOX, "Spawns more random pickups based on how filled the box is")
	EID:addCondition(mod.Collectible.BOX_CUTTER, CollectibleType.COLLECTIBLE_CRACK_JACKS, "Guarantees one Trinket reward")
	EID:addCondition(mod.Collectible.BOX_CUTTER, CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS, "Spawns several Blue-Spiders alongside the usual rewards")
	
	EID:addCollectible(mod.Collectible.PLASTIC_BRICK, "{{PlasticBrick}} Spawns a Plastic Brick pickup#{{PlasticBrick}} Chance to spawn up to 2 Plastic Brick pickups when entering a new room")
	EID:addCollectible(mod.Collectible.DIRGE_BELL, "Clearing a room spawns a familiar that shoots spectral tears which deal 5 damage#Caps at 10 familiars#{{Warning}} Dies in one hit")
	EID:addBFFSCondition(mod.Collectible.DIRGE_BELL, nil, 5)
	
	EID:addCollectible(mod.Collectible.DEAD_ORANGE, "{{ArrowUp}} {{Tears}} +0.5 Fire Rate#{{ArrowUp}} {{EmptyHeart}} +1 Empty Heart#{{ArrowUp}} {{RottenHeart}} +2 Rotten Hearts#{{RottenHeart}} Bosses drop a Rotten Heart when killed")
	EID:addCollectible(mod.Collectible.SNARED_FOX, "{{RottenHeart}} Spawns a Rotten Heart#Spawns 3-6 blue flies#Isaac fires 6 wiggling tears every 6 tears")
	EID:addAbyssSynergiesCondition(mod.Collectible.SNARED_FOX, "Green locust that deals 10% more damage and has a chance to poison enemies")
	
	EID:addCollectible(mod.Collectible.SPICY_BEAN, "{{Burning}} Deals 8 damage to enemies nearby and burns them#The burn deals Isaac's damage 6 times")
	EID:addCollectible(mod.Collectible.DADS_DUMBBELL, "{{ArrowUp}} {{Damage}} Permanent +1 Damage and Size up on use#{{ArrowDown}} {{Speed}} Caps Isaac's speed to 0.5 while held")
	
	EID:addCollectible(mod.Collectible.COMETA, "{{ArrowUp}} {{Luck}} +1 Luck#Spawns a quick comet familiar#Deals 3.5 contact damage per tick and blocks projectiles#{{Luck}} Contact damage is increased by 1.5 per luck")
	EID:addBFFSCondition(mod.Collectible.COMETA, nil, 3.5)
	
	EID:addCollectible(mod.Collectible.PEBBLE, "Tinted rocks drop pebbles alongside their usual rewards#Pebbles orbit Isaac and block projectiles")
	--EID:addBFFSCondition(mod.Collectible.PEBBLE, "")
	
	EID:addTrinket(mod.Trinket.TRUMPET, "{{Fear}} 20% chance to fear random enemies for 3 seconds when entering a room#{{Damage}} Feared enemies take 50% more damage")
	EID:addGoldenTrinketMetadata(mod.Trinket.TRUMPET, nil, 50)
	
	EID:addTrinket(mod.Trinket.WHITE_FLAG, "Ignore the first hit in a room#On hit drop the trinket and teleport to the starting room#{{Warning}} Can't be picked up until the room it was dropped in is cleared")
	EID:addGoldenTrinketTable(mod.Trinket.WHITE_FLAG, {goldenOnly = true, findReplace = true, mult = 2})
	EID.descriptions["en_us"].goldenTrinketEffects[mod.Trinket.WHITE_FLAG] = {"starting", "treasure"}
	
	EID:addTrinket(mod.Trinket.THRESHED_WHEAT, "Isaac performs a wheat melee attack once every second while shooting")
	EID:addGoldenTrinketTable(mod.Trinket.THRESHED_WHEAT, {findReplace = true})
	EID.descriptions["en_us"].goldenTrinketEffects[mod.Trinket.THRESHED_WHEAT] = {"once", "twice", "thrice"}
	
	EID:addTrinket(mod.Trinket.LUCKY_BUG, "{{ArrowUp}} {{Luck}} Clearing a room has a 15% chance to permanently increase luck#{{ArrowDown}} {{Luck}} Has a 3% chance to instead remove all gained luck and drop the trinket#{{Warning}} The trinket disappears in 1.5 seconds once dropped this way")
	EID:addGoldenTrinketMetadata(mod.Trinket.LUCKY_BUG, nil, 15)
	
	EID:addTrinket(mod.Trinket.MOMS_TELEPHONE, "18 seconds upon entering an uncleared room two of Mom's Hands come down and grab an enemy each")
	EID:addGoldenTrinketTable(mod.Trinket.MOMS_TELEPHONE, {t = {18}, mults = {0.5, 0.333}}) -- Should be similar to Mom's Toenail (which is 20 seconds)
	
	EID:addTrinket(mod.Trinket.CAUTION_SIGN, "{{Warning}} Last enemy to die in a room explodes")
	EID:addGoldenTrinketMetadata(mod.Trinket.CAUTION_SIGN, "Explodes in a large cross shaped blast akin to the effect of {{Collectible" .. CollectibleType.COLLECTIBLE_BOMBER_BOY .. "}} Bomber Boy")
	
	EID:addTrinket(mod.Trinket.RUNE_STONE, "{{Rune}} Tinted Rocks drop runes alongside their usual rewards")
	EID:addGoldenTrinketMetadata(mod.Trinket.RUNE_STONE, "Drops additional runes")
	
	EID:addTrinket(mod.Trinket.GRENADE_PIN, "Isaac's bombs explode slower#Placing a bomb whilst another is present will prevent its explosion")
	--EID:addGoldenTrinketMetadata(mod.Trinket.GRENADE_PIN, "")
	
	EID:addTrinket(mod.Trinket.MOXIES_YARN, "Basic fly enemies turn into Blue Flies")
	--EID:addGoldenTrinketMetadata(mod.Trinket.MOXIES_YARN, "")
	
	EID:addTrinket(mod.Trinket.DEVILS_TONGUE, "{{Burning}} Touching enemies burns them")
	EID:addGoldenTrinketMetadata(mod.Trinket.DEVILS_TONGUE, "{{Burning}} Fire immunity (except projectiles)")
	
	EID:addTrinket(mod.Trinket.SPARE_BATTERY, "Batteries are divided into several micro-batteries#5% chance to spawn a random battery on room clear")
	EID:addGoldenTrinketMetadata(mod.Trinket.SPARE_BATTERY, nil, 5)
	
	EID:addEntity(EntityType.ENTITY_PICKUP, mod.Pickup.MIRROR_SHARD, 0, "{{MirrorShard}}Mirror Shard", "{{BleedingOut}} Pick and throw a piercing spectral tear that does 5x Isaac's damage and causes bleeding")
	EID:addEntity(EntityType.ENTITY_PICKUP, mod.Pickup.PLASTIC_BRICK, 0, "{{PlasticBrick}}Plastic Brick", "Triggers on-hit effects without hurting Isaac")
end