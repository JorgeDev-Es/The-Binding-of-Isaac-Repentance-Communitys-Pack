local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

mod.Tear = {
	CLAY_JAR = Isaac.GetEntityVariantByName("Clay Jar Tear"),
	MIRROR_SHARD = Isaac.GetEntityVariantByName("Mirror Shard Tear"),
}

mod.Familiar = {
	ASHERAH_POLE = Isaac.GetEntityVariantByName("Asherah Pole"),
	HAPPY_FLY = Isaac.GetEntityVariantByName("Happy Fly"),
	BELL_GHOST = Isaac.GetEntityVariantByName("Bell Ghost"),
	COMETA = Isaac.GetEntityVariantByName("Cometa"),
	PEBBLE = Isaac.GetEntityVariantByName("Pebble"),
}

mod.Collectible = {
	TOY_SOLDIER = Isaac.GetItemIdByName("Toy Soldier"),
	EPHEMERAL_TORCH = Isaac.GetItemIdByName("Ephemeral Torch"),
	CLAY_JAR = Isaac.GetItemIdByName("Clay Jar"),
	BAALS_ALTAR = Isaac.GetItemIdByName("Baal's Altar"),
	ASHERAH_POLE = Isaac.GetItemIdByName("Asherah Pole"),
	COVENANT = Isaac.GetItemIdByName("Covenant"),
	BATTLE_BANNER = Isaac.GetItemIdByName("Battle Banner"),
	DEMISE_OF_THE_FAITHFUL = Isaac.GetItemIdByName("Demise of the Faithful"),
	APPETIZER = Isaac.GetItemIdByName("Appetizer"),
	HAPPY_FLY = Isaac.GetItemIdByName("Happy Fly"),
	GROCERY_BAG = Isaac.GetItemIdByName("Grocery Bag"),
	TOY_SHOVEL = Isaac.GetItemIdByName("Toy Shovel"),
	DEL_KEY = Isaac.GetItemIdByName("Del Key"),
	CRACKED_MIRROR = Isaac.GetItemIdByName("Cracked Mirror"),
	BOX_CUTTER = Isaac.GetItemIdByName("Box Cutter"),
	PLASTIC_BRICK = Isaac.GetItemIdByName("Plastic Brick"),
	DIRGE_BELL = Isaac.GetItemIdByName("Dirge Bell"),
	DEAD_ORANGE = Isaac.GetItemIdByName("Dead Orange"),
	SNARED_FOX = Isaac.GetItemIdByName("Snared Fox"),
	SPICY_BEAN = Isaac.GetItemIdByName("Spicy Bean"),
	DADS_DUMBBELL = Isaac.GetItemIdByName("Dad's Dumbbell"),
	COMETA = Isaac.GetItemIdByName("Cometa"),
	PEBBLE = Isaac.GetItemIdByName("Pebble"),
}

mod.Trinket = {
	TRUMPET = Isaac.GetTrinketIdByName("Trumpet"),
	WHITE_FLAG = Isaac.GetTrinketIdByName("White Flag"),
	THRESHED_WHEAT = Isaac.GetTrinketIdByName("Threshed Wheat"),
	LUCKY_BUG = Isaac.GetTrinketIdByName("Lucky Bug"),
	MOMS_TELEPHONE = Isaac.GetTrinketIdByName("Mom's Telephone"),
	CAUTION_SIGN = Isaac.GetTrinketIdByName("Caution Sign"),
	RUNE_STONE = Isaac.GetTrinketIdByName("Rune Stone"),
	GRENADE_PIN = Isaac.GetTrinketIdByName("Grenade Pin"),
	MOXIES_YARN = Isaac.GetTrinketIdByName("Moxie's Yarn"),
	DEVILS_TONGUE = Isaac.GetTrinketIdByName("Devil's Tongue"),
	SPARE_BATTERY = Isaac.GetTrinketIdByName("Spare Battery"),
}

mod.Pickup = {
	MIRROR_SHARD = Isaac.GetEntityVariantByName("Mirror Shard"),
	PLASTIC_BRICK = Isaac.GetEntityVariantByName("Plastic Brick"),
}

mod.Effect = {
	CLAY_JAR = Isaac.GetEntityVariantByName("Clay Jar Shards"),
	SUNLIGHT = Isaac.GetEntityVariantByName("Sunlight"),
	WHEAT = Isaac.GetEntityVariantByName("Wheat"),
}

mod.Sound = {
	SERVANT_BELL = Isaac.GetSoundIdByName("Servant Bell"),
	GLASS_BREAK = Isaac.GetSoundIdByName("Glass Break"),
	GLITCH = Isaac.GetSoundIdByName("Glitch"),
	MOM_PHONE = Isaac.GetSoundIdByName("Mom Phone"),
	TRUMPET_DOOT = Isaac.GetSoundIdByName("Trumpet Doot"),
	WOOD_CREAK = Isaac.GetSoundIdByName("Wood Creak"),
	COVENANT_CHOIR = Isaac.GetSoundIdByName("Covenant Choir"),
	METAL_HIT = Isaac.GetSoundIdByName("Metal Hit"),
	METAL_DEFLECT = Isaac.GetSoundIdByName("Metal Deflect"),
}

mod.ItemPool = {
	GROCERY_SHOP = Isaac.GetPoolIdByName("groceryShop"),
}

mod.Price = {
	TOY_SOLDIER = -460,
}