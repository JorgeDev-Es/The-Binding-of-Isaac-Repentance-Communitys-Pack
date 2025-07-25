local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

if AccurateBlurbs then
	local collectibleDesc = {
		[mod.Collectible.TOY_SOLDIER] = "Nullify damage once per floor",
		[mod.Collectible.EPHEMERAL_TORCH] = "Fading luck up + touch fireplaces for luck up",
		[mod.Collectible.CLAY_JAR] = "Throw a shattering jar",
		[mod.Collectible.BAALS_ALTAR] = "Store an item pedestal",
		[mod.Collectible.ASHERAH_POLE] = "Stationary smite-marking buddy",
		[mod.Collectible.COVENANT] = "Choose the mark for (DMG up + eternal heart)",
		[mod.Collectible.BATTLE_BANNER] = "DMG multiplier unless backtracking",
		[mod.Collectible.DEMISE_OF_THE_FAITHFUL] = "DMG multiplier + bone heart + Boss pickups",
		[mod.Collectible.APPETIZER] = "HP up + heal + higher max HP",
		[mod.Collectible.HAPPY_FLY] = "Invincibility-touch fly buddy",
		[mod.Collectible.GROCERY_BAG] = "Hold more pickups + better Shops",
		[mod.Collectible.TOY_SHOVEL] = "Maybe dig a valuable",
		[mod.Collectible.DEL_KEY] = "Damage the room until enemies are deleted",
		[mod.Collectible.CRACKED_MIRROR] = "Enemies may drop a mirror shard on kill",
		[mod.Collectible.BOX_CUTTER] = "Convert 1 HP into some pickups",
		[mod.Collectible.PLASTIC_BRICK] = "May spawn plastic bricks on room entry",
		[mod.Collectible.DIRGE_BELL] = "Gain a fragile ghostly buddy on room clear",
		[mod.Collectible.DEAD_ORANGE] = "HP up + tears up + rotten heart Boss-pickup",
		[mod.Collectible.SNARED_FOX] = "Wiggly tears every few shots + rotten heart",
		[mod.Collectible.SPICY_BEAN] = "Burning fart on command",
		[mod.Collectible.DADS_DUMBBELL] = "Speed down + use for (DMG up + size up)",
		[mod.Collectible.COMETA] = "Luck up + all-orbiting blocking comet",
		[mod.Collectible.PEBBLE] = "Tinted rocks drop orbiting pebbles",
	}
	local trinketDesc = {
		[mod.Trinket.TRUMPET] = "Fear weakens + may fear the room on entry",
		[mod.Trinket.WHITE_FLAG] = "Nullify damage + drops after nullifying",
		[mod.Trinket.THRESHED_WHEAT] = "Firing swipes wheat in front",
		[mod.Trinket.LUCKY_BUG] = "May gain luck up or remove luck on room clear",
		[mod.Trinket.MOMS_TELEPHONE] = "Contact Mom some time after room entry",
		[mod.Trinket.CAUTION_SIGN] = "Last enemy killed per room explodes",
		[mod.Trinket.RUNE_STONE] = "Tinted rocks drop a rune",
		[mod.Trinket.GRENADE_PIN] = "Bombs synchronize blast-timings",
		[mod.Trinket.MOXIES_YARN] = "Basic fly enemies turn blue",
		[mod.Trinket.DEVILS_TONGUE] = "Burn on contact",
		[mod.Trinket.SPARE_BATTERY] = "Divided batteries + rewards may be a battery",
	}
	mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
		for idx, desc in pairs(collectibleDesc) do
			Isaac.GetItemConfig():GetCollectible(idx).Description = desc
		end
		for idx, desc in pairs(trinketDesc) do
			Isaac.GetItemConfig():GetTrinket(idx).Description = desc
		end
	end)
end