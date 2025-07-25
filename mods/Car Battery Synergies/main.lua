local modName = "Car Battery Synergies"
local mod = RegisterMod(modName, 1)
mod.savedataVersion = 1

--Static variables
mod.razorDamageBonus = 0.6

--Dynamic variables
mod.r = RNG()
mod.r:SetSeed(Random(), 1)

mod.usedPoop = false
mod.usedDadsKey = false
mod.usedIsaacsTears = false
mod.usedGuppysPaw = false
mod.usedKamikaze = false
mod.usedConverter = false
mod.usedTheBible = false
mod.usedBookOfTheDead = false
mod.usedDoctorsRemote = false
mod.usedEdensSoul = false
mod.usedMysteryGift = false
mod.usedIVBag = false
mod.usedRazorBlade = false
mod.usedGoldenRazor = false	
mod.usedRedCandle = false
mod.usedTheCandle = false
mod.usedRemoteDetonator = false
mod.usedPortableSlot = false
mod.usedAltar = false
mod.usedSharpKey = false
mod.usedTelepathy = false
mod.usedMomsBra = false
mod.usedLemonMishap = false
mod.usedFreeLemonade = false
mod.usedAlabasterBox = false	
mod.usedPandorasBox = false

mod.spawnHolyTrinket = false
mod.initHolyTrinket = 0
mod.razorDamageCount = 0
mod.goldenRazorDamageSum = 0
mod.initMomsBra = 0
mod.babies = {}

mod.Settings = {
	["SaveDataVersion"] = mod.savedataVersion,
	
	["AlabasterBox"] = true, 
	["BookOfTheDead"] = true,
	["Converter"] = true, 
	["DadsKey"] = true, 
	["DoctorsRemote"] = true, 
	["EdensSoul"] = true, 
	["FreeLemonade"] = true, 
	["GoldenRazor"] = true, 
	["GuppysPaw"] = true, 
	["IsaacsTears"] = true, 
	["IVBag"] = true, 
	["Kamikaze"] = true, 
	["LemonMishap"] = true, 
	["MomsBra"] = true,
	["MysteryGift"] = true, 
	["PandorasBox"] = true, 
	["PortableSlot"] = true, 
	["RazorBlade"] = true, 
	["RedCandle"] = true, 
	["RemoteDetonator"] = true, 
	["SacrificialAltar"] = true, 
	["SharpKey"] = true, 
	["TelepathyForDummies"] = true, 
	["TheBible"] = true,
	["TheCandle"] = true,
	["ThePoop"] = true
}

-- Mod Config Menu
if ModConfigMenu then
	ModConfigMenu.UpdateCategory(modName, {
	Info = {
		"View settings for Car Battery Synergies.",
	}})
	
	-- Alabaster Box
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["AlabasterBox"]
		end,
		Default = mod.Settings["AlabasterBox"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["AlabasterBox"] then
				onOff = "Enabled"
			end
			
			return "Alabaster Box: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["AlabasterBox"] = currentBool
		end,
		Info = function()
			local TotalText = "It also spawns a random holy trinket."
			
			return TotalText
		end
	})
	
	-- Book Of the Dead
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["BookOfTheDead"]
		end,
		Default = mod.Settings["BookOfTheDead"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["BookOfTheDead"] then
				onOff = "Enabled"
			end
			
			return "Book of the Dead: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["BookOfTheDead"] = currentBool
		end,
		Info = function()
			local TotalText = "If there is a Bony, Black Bony, Bone Fly, or Revenant in the room, it permanently charm the one that is closest to you."
			
			return TotalText
		end
	})
	
	-- Converter
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["Converter"]
		end,
		Default = mod.Settings["Converter"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["Converter"] then
				onOff = "Enabled"
			end
			
			return "Converter: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["Converter"] = currentBool
		end,
		Info = function()
			local TotalText = "On use, turns your Blue Flies into Red Locusts."
			
			return TotalText
		end
	})
	
	-- Dad's Key
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["DadsKey"]
		end,
		Default = mod.Settings["DadsKey"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["DadsKey"] then
				onOff = "Enabled"
			end
			
			return "Dad's Key: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["DadsKey"] = currentBool
		end,
		Info = function()
			local TotalText = "Replaces all keys on the ground with Charged Keys."
			
			return TotalText
		end
	})
	
	-- Doctor's Remote
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["DoctorsRemote"]
		end,
		Default = mod.Settings["DoctorsRemote"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["DoctorsRemote"] then
				onOff = "Enabled"
			end
			
			return "Doctor's Remote: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["DoctorsRemote"] = currentBool
		end,
		Info = function()
			local TotalText = "You also shot a homing rocket in a random direction."
			
			return TotalText
		end
	})
	
	-- Eden's Soul
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["EdensSoul"]
		end,
		Default = mod.Settings["EdensSoul"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["EdensSoul"] then
				onOff = "Enabled"
			end
			
			return "Eden's Soul: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["EdensSoul"] = currentBool
		end,
		Info = function()
			local TotalText = "It also spawns 2 random trinkets."
			
			return TotalText
		end
	})
	
	-- Free Lemonade
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["FreeLemonade"]
		end,
		Default = mod.Settings["FreeLemonade"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["FreeLemonade"] then
				onOff = "Enabled"
			end
			
			return "Free Lemonade: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["FreeLemonade"] = currentBool
		end,
		Info = function()
			local TotalText = "The familiar that is the most far away from you spawns a pool of Lemonade."
			
			return TotalText
		end
	})
	
	-- Golden Razor
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["GoldenRazor"]
		end,
		Default = mod.Settings["GoldenRazor"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["GoldenRazor"] then
				onOff = "Enabled"
			end
			
			return "Golden Razor: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["GoldenRazor"] = currentBool
		end,
		Info = function()
			local TotalText = "On use, kills Keepers, Hangers, Gold Dips, Greed, Super Greed, and permanently increases your damage for each kill."
			
			return TotalText
		end
	})
	
	-- Guppy's Paw
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["GuppysPaw"]
		end,
		Default = mod.Settings["GuppysPaw"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["GuppysPaw"] then
				onOff = "Enabled"
			end
			
			return "Guppy's Paw: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["GuppysPaw"] = currentBool
		end,
		Info = function()
			local TotalText = "Replaces 1 Red Heart on the ground with a Soul Heart."
			
			return TotalText
		end
	})
	
	-- Isaac's Tears
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["IsaacsTears"]
		end,
		Default = mod.Settings["IsaacsTears"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["IsaacsTears"] then
				onOff = "Enabled"
			end
			
			return "Isaac's Tears: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["IsaacsTears"] = currentBool
		end,
		Info = function()
			local TotalText = "You shoot 16 tears instead of 8."
			
			return TotalText
		end
	})
	
	-- IV Bag
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["IVBag"]
		end,
		Default = mod.Settings["IVBag"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["IVBag"] then
				onOff = "Enabled"
			end
			
			return "IV Bag: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["IVBag"] = currentBool
		end,
		Info = function()
			local TotalText = "Kills one of your Blue Flies, Blue Spiders, or Dips, and spawns a coin in its place."
			
			return TotalText
		end
	})
	
	-- Kamikaze!
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["Kamikaze"]
		end,
		Default = mod.Settings["Kamikaze"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["Kamikaze"] then
				onOff = "Enabled"
			end
			
			return "Kamikaze!: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["Kamikaze"] = currentBool
		end,
		Info = function()
			local TotalText = "Your familiars also explode."
			
			return TotalText
		end
	})
	
	-- Lemon Mishap
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["LemonMishap"]
		end,
		Default = mod.Settings["LemonMishap"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["LemonMishap"] then
				onOff = "Enabled"
			end
			
			return "Lemon Mishap: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["LemonMishap"] = currentBool
		end,
		Info = function()
			local TotalText = "The familiar that is the most far away from you creates a tiny pool of yellow creep."
			
			return TotalText
		end
	})
	
	-- Mom's Bra
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["MomsBra"]
		end,
		Default = mod.Settings["MomsBra"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["MomsBra"] then
				onOff = "Enabled"
			end
			
			return "Mom's Bra: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["MomsBra"] = currentBool
		end,
		Info = function()
			local TotalText = "If you kill an enemy while it is petrified, it spawns a Rock Dip."
			
			return TotalText
		end
	})
	
	-- Mystery Gift
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["MysteryGift"]
		end,
		Default = mod.Settings["MysteryGift"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["MysteryGift"] then
				onOff = "Enabled"
			end
			
			return "Mystery Gift: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["MysteryGift"] = currentBool
		end,
		Info = function()
			local TotalText = "It also spawns a random trinket."
			
			return TotalText
		end
	})
	
	-- Pandora's Box
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["PandorasBox"]
		end,
		Default = mod.Settings["PandorasBox"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["PandorasBox"] then
				onOff = "Enabled"
			end
			
			return "Pandora's Box: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["PandorasBox"] = currentBool
		end,
		Info = function()
			local TotalText = "Give more rewards."
			
			return TotalText
		end
	})
	
	-- Portable Slot
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["PortableSlot"]
		end,
		Default = mod.Settings["PortableSlot"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["PortableSlot"] then
				onOff = "Enabled"
			end
			
			return "Portable Slot: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["PortableSlot"] = currentBool
		end,
		Info = function()
			local TotalText = "Exchanges coins on the ground with different rewards depends on the coin type."
			
			return TotalText
		end
	})
	
	-- Razor Blade
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["RazorBlade"]
		end,
		Default = mod.Settings["RazorBlade"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["RazorBlade"] then
				onOff = "Enabled"
			end
			
			return "Razor Blade: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["RazorBlade"] = currentBool
		end,
		Info = function()
			local TotalText = "Kills one of your Blue Flies, Blue Spiders, or Dips, and increases your damage by +0.6 for the current room."
			
			return TotalText
		end
	})
	
	-- Red Candle
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["RedCandle"]
		end,
		Default = mod.Settings["RedCandle"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["RedCandle"] then
				onOff = "Enabled"
			end
			
			return "Red Candle: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["RedCandle"] = currentBool
		end,
		Info = function()
			local TotalText = "On use, you also shot a flame in a random direction."
			
			return TotalText
		end
	})
	
	-- Remote Detonator
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["RemoteDetonator"]
		end,
		Default = mod.Settings["RemoteDetonator"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["RemoteDetonator"] then
				onOff = "Enabled"
			end
			
			return "Remote Detonator: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["RemoteDetonator"] = currentBool
		end,
		Info = function()
			local TotalText = "On use, it also cause all the enemies that explode on death to explode and die."
			
			return TotalText
		end
	})
	
	-- Sacrificial Altar
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["SacrificialAltar"]
		end,
		Default = mod.Settings["SacrificialAltar"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["SacrificialAltar"] then
				onOff = "Enabled"
			end
			
			return "Sacrificial Altar: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["SacrificialAltar"] = currentBool
		end,
		Info = function()
			local TotalText = "Allows you to sacrifice 4 familiars."
			
			return TotalText
		end
	})
	
	-- Sharp Key
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["SharpKey"]
		end,
		Default = mod.Settings["SharpKey"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["SharpKey"] then
				onOff = "Enabled"
			end
			
			return "Sharp Key: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["SharpKey"] = currentBool
		end,
		Info = function()
			local TotalText = "Your familiars also shot a key in the direction that you shot."
			
			return TotalText
		end
	})
	
	-- Telepathy for Dummies
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["TelepathyForDummies"]
		end,
		Default = mod.Settings["TelepathyForDummies"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["TelepathyForDummies"] then
				onOff = "Enabled"
			end
			
			return "Telepathy for Dummies: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["TelepathyForDummies"] = currentBool
		end,
		Info = function()
			local TotalText = "Your shooting familiars now have homing shots."
			
			return TotalText
		end
	})
	
	-- The Bible
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["TheBible"]
		end,
		Default = mod.Settings["TheBible"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["TheBible"] then
				onOff = "Enabled"
			end
			
			return "The Bible: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["TheBible"] = currentBool
		end,
		Info = function()
			local TotalText = "Spawns Seraphim familiar for the current room."
			
			return TotalText
		end
	})
	
	-- The Candle
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["TheCandle"]
		end,
		Default = mod.Settings["TheCandle"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["TheCandle"] then
				onOff = "Enabled"
			end
			
			return "The Candle: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["TheCandle"] = currentBool
		end,
		Info = function()
			local TotalText = "On use, you also shot a blue flame in a random direction."
			
			return TotalText
		end
	})
	
	-- The Poop
	ModConfigMenu.AddSetting(modName, "Settings", { 
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return mod.Settings["ThePoop"]
		end,
		Default = mod.Settings["ThePoop"],
		
		Display = function()
			local onOff = "Disabled"
			if mod.Settings["ThePoop"] then
				onOff = "Enabled"
			end
			
			return "The Poop: " .. onOff
		end,
		OnChange = function(currentBool)
			mod.Settings["ThePoop"] = currentBool
		end,
		Info = function()
			local TotalText = "Spawns 2 poops instead of 1."
			
			return TotalText
		end
	})
end

-- Luck Items
mod.luckItems = {
	CollectibleType.COLLECTIBLE_MOMS_BOX,
	CollectibleType.COLLECTIBLE_LATCH_KEY,
	CollectibleType.COLLECTIBLE_LUCKY_FOOT,
	CollectibleType.COLLECTIBLE_MAGIC_SCAB,
	CollectibleType.COLLECTIBLE_MOMS_PEARLS,
	CollectibleType.COLLECTIBLE_DADS_LOST_COIN,
	CollectibleType.COLLECTIBLE_YO_LISTEN,
	CollectibleType.COLLECTIBLE_EVIL_CHARM,
	CollectibleType.COLLECTIBLE_YO_LISTEN,
	CollectibleType.COLLECTIBLE_GLASS_EYE
}

-- Bomb Trinkets
mod.bombTrinkets = {
	TrinketType.TRINKET_BURNT_PENNY,
	TrinketType.TRINKET_MATCH_STICK,
	TrinketType.TRINKET_BLASTING_CAP,
	TrinketType.TRINKET_BOBS_BLADDER,
	TrinketType.TRINKET_SAFETY_SCISSORS,
	TrinketType.TRINKET_BROKEN_PADLOCK,
	TrinketType.TRINKET_RING_CAP,
	TrinketType.TRINKET_SHORT_FUSE,
	TrinketType.TRINKET_BROWN_CAP,
	TrinketType.TRINKET_SWALLOWED_M80
}

-- Holy Trinkets
mod.holyTrinkets = {
	TrinketType.TRINKET_BIBLE_TRACT,
	TrinketType.TRINKET_MAGGYS_FAITH,
	TrinketType.TRINKET_ROSARY_BEAD,
	TrinketType.TRINKET_FILIGREE_FEATHERS,
	TrinketType.TRINKET_WOODEN_CROSS,
	TrinketType.TRINKET_BETHS_ESSENCE,
	TrinketType.TRINKET_BETHS_FAITH,
	TrinketType.TRINKET_HOLY_CROWN
}

--Increase stats
function mod:cacheUpdate(player,cacheFlag)
	if mod.razorDamageCount > 0 then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + (mod.razorDamageBonus * mod.razorDamageCount)
		end
	else
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage
		end
	end
	
	if mod.goldenRazorDamageSum == nil then
		mod.goldenRazorDamageSum = 0
	end	
	
	if mod.goldenRazorDamageSum > 0 then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + mod.goldenRazorDamageSum
		end
	else
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage
		end
	end
end
mod:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, mod.cacheUpdate )

-- Spawn Pickup
function mod.SpawnPickup(variant, subtype, pos, player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, variant, subtype, pos, Vector(0,0), player)
end

-- Spawn Pickup Near
function mod.SpawnPickupNear(variant, subtype, pos, distance, player, count)
	for i = 1, count do
		Isaac.Spawn(EntityType.ENTITY_PICKUP, variant, subtype, Isaac.GetFreeNearPosition(pos, distance), Vector(0,0), player)
	end
end

-- Spawn an item
function mod.SpawnItem(pos, player, item, distance)
	mod.SpawnPickupNear(PickupVariant.PICKUP_COLLECTIBLE, item, pos, distance, player, 1)
end

--Spawn a charmed enemy
function mod.SpawnCharmed(entType, variant, subtype, pos , player, count, duration)
	for i = 1, count do
		local entity = Isaac.Spawn(entType, variant, subtype, pos, Vector(0, 0), player) 		
		local entityNPC = entity:ToNPC()
		local entRef = EntityRef(entityNPC)
		entityNPC:AddCharmed(entRef, duration)
	end
end

-- Shoot Tear
function mod.ShootTear(player, pos, angleInc, fireDirection, count, speed, damage, multi, scale, clear, flag, variant, color)
	local tearVelocity = Vector(player.ShotSpeed*10, 0)
	if fireDirection ~= "n" then
		if fireDirection == Direction.DOWN then
			tearVelocity = Vector(0, player.ShotSpeed*10)
		elseif fireDirection == Direction.UP then
			tearVelocity = Vector(0, player.ShotSpeed*(-10))
		elseif fireDirection == Direction.LEFT then
			tearVelocity = Vector(player.ShotSpeed*(-10), 0)
		elseif fireDirection == Direction.RIGHT then
			tearVelocity = Vector(player.ShotSpeed*10, 0)
		else
			tearVelocity = fireDirection
		end  
	end
	local angle = 360
	angle = math.floor(angle / count)
	local direction = mod.r:RandomInt(angle)
	if angleInc ~= "n" then
		direction = angleInc
	end
	local tear = nil
	for i = 1, count do
		tear = player:FireTear(pos, tearVelocity:Rotated(i*angle + direction), true, true, false):ToTear()
		tear.CollisionDamage = damage * multi
		if scale ~= 0 then
			tear.Scale = scale
		end
		if clear then
			tear:ClearTearFlags(player.TearFlags)
		end
		if flag ~= "n" then
			tear.TearFlags = tear.TearFlags | flag
		end
		if variant ~= "n" then
			if tear.Variant ~= variant then
				tear:ChangeVariant(variant)
			end
		end
		if color ~= "n" then
			tear:SetColor( color, -1, 1, false, true )
		end	
		if speed ~= "n" then
			tear.Velocity = Vector(tear.Velocity.X * speed, tear.Velocity.Y * speed)
		end
	end
	return tear
end

-- Sacrifice Fly
function mod.SacrificeFly(player, entities, subtype, item)
	for i = 1, #entities do
		local entity = entities[i]	
					
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.BLUE_FLY and entity.SubType == subtype then
			entity:Kill()
			if item == "IV Bag" then
				mod.SpawnPickup(PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, entity.Position, player)
			elseif item == "Razor Blade" then
				mod.razorDamageCount = mod.razorDamageCount + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
			break
		end
	end
end

-- Sacrifice Spider
function mod.SacrificeSpider(player, entities, item)
	for i = 1, #entities do
		local entity = entities[i]	
					
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.BLUE_SPIDER then
			entity:Kill()
			if item == "IV Bag" then
				mod.SpawnPickup(PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, entity.Position, player)
			elseif item == "Razor Blade" then
				mod.razorDamageCount = mod.razorDamageCount + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
			break
		end
	end
end

-- Sacrifice Dip
function mod.SacrificeDip(player, entities, subtype, item)
	for i = 1, #entities do
		local entity = entities[i]	
					
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.DIP and entity.SubType == subtype then
			entity:Kill()
			if item == "IV Bag" then
				local coinSubType = CoinSubType.COIN_PENNY
				if subtype == 3 then
					coinSubType = CoinSubType.COIN_DIME
				elseif subtype == 4 then
					coinSubType = CoinSubType.COIN_LUCKYPENNY
				end
				mod.SpawnPickup(PickupVariant.PICKUP_COIN, coinSubType, entity.Position, player)
			elseif item == "Razor Blade" then
				mod.razorDamageCount = mod.razorDamageCount + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
			break
		end
	end
end

-- Sacrifice Friend
function mod.SacrificeFriend(player, roomEntities, item)
	local sacrificeFly = false
	local sacrificeSpider = false
	local sacrificeDip = false
	local flySubTypes = {}
	local dipSubTypes = {}
	
	for i = 1, #roomEntities do
		local entity = roomEntities[i]	
					
		if entity.Type == EntityType.ENTITY_FAMILIAR then
			if entity.Variant == FamiliarVariant.BLUE_FLY then
				flySubTypes[#flySubTypes + 1] = entity.SubType
				sacrificeFly = true
			elseif entity.Variant == FamiliarVariant.BLUE_SPIDER then
				sacrificeSpider = true
			elseif entity.Variant == FamiliarVariant.DIP then
				dipSubTypes[#dipSubTypes + 1] = entity.SubType
				sacrificeDip = true
			end
		end
	end	
	
	if sacrificeFly and sacrificeSpider and sacrificeDip then
		local randomNum = mod.r:RandomInt(3)
		if randomNum == 0 then
			sacrificeSpider = false
			sacrificeDip = false
		elseif randomNum == 1 then
			sacrificeFly = false
			sacrificeDip = false
		else
			sacrificeFly = false
			sacrificeSpider = false
		end
	elseif sacrificeFly and sacrificeSpider then
		local randomNum = mod.r:RandomInt(2)
		if randomNum == 0 then
			sacrificeSpider = false
		else
			sacrificeFly = false
		end		
	elseif sacrificeFly and sacrificeDip then
		local randomNum = mod.r:RandomInt(2)
		if randomNum == 0 then
			sacrificeDip = false
		else
			sacrificeFly = false
		end
	elseif sacrificeSpider and sacrificeDip then
		local randomNum = mod.r:RandomInt(2)
		if randomNum == 0 then
			sacrificeDip = false
		else
			sacrificeSpider = false
		end
	end
	
	if sacrificeFly and #flySubTypes > 0 then
		local randonSubType = mod.r:RandomInt(#flySubTypes) + 1
		mod.SacrificeFly( player, roomEntities, flySubTypes[randonSubType], item )
	elseif sacrificeSpider then
		mod.SacrificeSpider( player, roomEntities, item )
	elseif sacrificeDip and #dipSubTypes > 0 then
		local randonSubType = mod.r:RandomInt(#dipSubTypes) + 1
		mod.SacrificeDip( player, roomEntities, dipSubTypes[randonSubType], item )
	end
end

-- Golden Razor Synergy
function mod.GoldenRazorSynergy(player, entities)
	local killedGold = false

	for i = 1, #entities do
		local entity = entities[i]	
					
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.DIP and entity.SubType == 3 then
			entity:Kill()
			mod.goldenRazorDamageSum = mod.goldenRazorDamageSum + 0.3
			killedGold = true
			
		elseif entity.Type == EntityType.ENTITY_KEEPER or entity.Type == EntityType.ENTITY_HANGER then
			entity:Kill()
			mod.goldenRazorDamageSum = mod.goldenRazorDamageSum + 0.1
			killedGold = true
			
		elseif entity.Type == EntityType.ENTITY_GREED then
			entity:Kill()
			local bonusDamage = 0.5
			if entity.Variant == 1 then
				bonusDamage = 1
			end
			mod.goldenRazorDamageSum = mod.goldenRazorDamageSum + bonusDamage
			killedGold = true
		end
	end
	
	if killedGold then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

--Spawn Baby
function mod.SpawnBaby(player)
	mod.babies[#mod.babies + 1] = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SERAPHIM, 0, player.Position, Vector(0,0), player)
end

--Check how close we are to a dead enemy
function mod.CheckDeadDistance(player, roomEntities)
	local distance = 0 --Distance between player and the enemy
	local smallestDistance = 100000 --Smallest distance
	local playerPos = player.Position --Player position
	local closestEnemy = nil
	local enemyType = nil
	local enemyVariant = nil
	local enemySubType = nil
	
	for i = 1, #roomEntities do
		local entity = roomEntities[i]						
		if (entity.Type == EntityType.ENTITY_BONY and entity.Variant == 0)
		or entity.Type == EntityType.ENTITY_BLACK_BONY
		or (entity.Type == EntityType.ENTITY_BOOMFLY and entity.Variant == 4) 
		or entity.Type == EntityType.ENTITY_REVENANT then
			distance = playerPos:Distance(entity.Position) --Distance between player and the enemy
			if distance < smallestDistance then
				smallestDistance = distance --Update smallest distance
				closestEnemy = entity
				enemyType = entity.Type
				enemyVariant = entity.Variant
				enemySubType = entity.SubType
			end
		end
	end	
	
	if closestEnemy ~= nil then
		mod.SpawnCharmed(enemyType, enemyVariant, enemySubType, closestEnemy.Position, player, 1, -1)
		closestEnemy:Remove()
	end
end

--Check how close we are to a familiar
function mod.CheckFamiliarDistance(player, entities, isFreeLemonade)
	local distance = 0 --Distance between player and the familiar
	local smallestDistance = -100000 --Smallest distance
	local playerPos = player.Position --Player position
	local farestFamiliar = nil
	
	for i = 1, #entities do
		local entity = entities[i]						
		if entity.Type == EntityType.ENTITY_FAMILIAR then
			distance = playerPos:Distance(entity.Position) --Distance between player and the familiar
			if distance > smallestDistance then
				smallestDistance = distance --Update smallest distance
				farestFamiliar = entity
			end
		end
	end	
	
	if farestFamiliar ~= nil then
		local effect = EffectVariant.PLAYER_CREEP_LEMON_MISHAP
		if isFreeLemonade then
			effect = EffectVariant.PLAYER_CREEP_LEMON_PARTY
		end
		Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, farestFamiliar.Position, Vector(0,0), player)
	end
end

-- Shoot Fire
function mod.ShootFire(effect, player, pos, isBlue)
	local tearVelocity = Vector(player.ShotSpeed*10, 0)
	local angle = 360
	local direction = mod.r:RandomInt(angle)
	local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, pos, tearVelocity:Rotated(angle + direction), player):ToEffect()
	if isBlue then
		flame:SetDamageSource(EntityType.ENTITY_PLAYER)
		flame.LifeSpan = 60
		flame.Timeout = 60
		flame.State = 1
		flame.CollisionDamage = 23
	end
end

-- Remote Detonator Synergy
function mod.RemoteDetonatorSynergy(entities)
	for i = 1, #entities do
		local entity = entities[i]						
		if (entity.Type == EntityType.ENTITY_MULLIGAN and entity.Variant == 2) 
		or (entity.Type == EntityType.ENTITY_BOOMFLY and (entity.Variant == 0 or entity.Variant == 2 or entity.Variant == 5 or entity.Variant == 6)) 
		or entity.Type == EntityType.ENTITY_POISON_MIND 
		or (entity.Type == EntityType.ENTITY_LEECH and (entity.Variant == 1 or entity.Variant == 2)) 
		or entity.Type == EntityType.ENTITY_TICKING_SPIDER 
		or entity.Type == EntityType.ENTITY_BLACK_MAW 
		or entity.Type == EntityType.ENTITY_BLACK_BONY 
		or entity.Type == EntityType.ENTITY_POOFER 
		or entity.Type == EntityType.ENTITY_POOT_MINE then
			entity:Kill() 
		elseif entity.Type == EntityType.ENTITY_FLY_BOMB 
		or entity.Type == EntityType.ENTITY_MIGRAINE then
			Isaac.Explode(entity.Position, nil, 40)
		end
	end	
end

----------------------------------- Sacrificial Altar Synergy --------------------------------------

-- Sacrifice Familiar
function mod.SacrificeFamiliar(familiar, player, kill)
	local sacrifice = false
	local item = nil
	local trinket = nil
	local variant = familiar.Variant
	local pos = familiar.Position
	local repetitions = 1
	local spawnBlackHearts = false
	
	if variant == FamiliarVariant.BROTHER_BOBBY then
		item = CollectibleType.COLLECTIBLE_BROTHER_BOBBY
		
	elseif variant == FamiliarVariant.DEMON_BABY then
		item = CollectibleType.COLLECTIBLE_DEMON_BABY
		
	elseif variant == FamiliarVariant.LITTLE_CHUBBY then
		item = CollectibleType.COLLECTIBLE_LITTLE_CHUBBY
		
	elseif variant == FamiliarVariant.LITTLE_GISH then
		item = CollectibleType.COLLECTIBLE_LITTLE_GISH
		
	elseif variant == FamiliarVariant.LITTLE_STEVEN then
		item = CollectibleType.COLLECTIBLE_LITTLE_STEVEN
		
	elseif variant == FamiliarVariant.ROBO_BABY then
		item = CollectibleType.COLLECTIBLE_ROBO_BABY
		
	elseif variant == FamiliarVariant.SISTER_MAGGY then
		item = CollectibleType.COLLECTIBLE_SISTER_MAGGY
		
	elseif variant == FamiliarVariant.ABEL then
		item = CollectibleType.COLLECTIBLE_ABEL
		
	elseif variant == FamiliarVariant.GHOST_BABY then
		item = CollectibleType.COLLECTIBLE_GHOST_BABY
		
	elseif variant == FamiliarVariant.HARLEQUIN_BABY then
		item = CollectibleType.COLLECTIBLE_HARLEQUIN_BABY
		
	elseif variant == FamiliarVariant.RAINBOW_BABY then
		item = CollectibleType.COLLECTIBLE_RAINBOW_BABY
		
	elseif variant == FamiliarVariant.ISAACS_HEAD then
		trinket = TrinketType.TRINKET_ISAACS_HEAD
		
	elseif variant == FamiliarVariant.BLUE_BABY_SOUL then
		trinket = TrinketType.TRINKET_SOUL
		
	elseif variant == FamiliarVariant.DEAD_BIRD then
		item = CollectibleType.COLLECTIBLE_DEAD_BIRD
		
	elseif variant == FamiliarVariant.EVES_BIRD_FOOT then
		trinket = TrinketType.TRINKET_EVES_BIRD_FOOT
		
	elseif variant == FamiliarVariant.PEEPER then
		item = CollectibleType.COLLECTIBLE_PEEPER
		
	elseif variant == FamiliarVariant.LITTLE_CHAD then
		item = CollectibleType.COLLECTIBLE_LITTLE_CHAD
		
	elseif variant == FamiliarVariant.BUM_FRIEND then
		item = CollectibleType.COLLECTIBLE_BUM_FRIEND
		
	elseif variant == FamiliarVariant.FOREVER_ALONE then
		item = CollectibleType.COLLECTIBLE_FOREVER_ALONE
		
	elseif variant == FamiliarVariant.DISTANT_ADMIRATION then
		item = CollectibleType.COLLECTIBLE_DISTANT_ADMIRATION
		
	elseif variant == FamiliarVariant.GUARDIAN_ANGEL then
		item = CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL
		spawnBlackHearts = true
		
	elseif variant == FamiliarVariant.FLY_ORBITAL then
		sacrifice = true
		
	elseif variant == FamiliarVariant.CUBE_OF_MEAT_1 then
		item = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT
		
	elseif variant == FamiliarVariant.CUBE_OF_MEAT_2 then
		item = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT
		repetitions = 2
		
	elseif variant == FamiliarVariant.CUBE_OF_MEAT_3 then
		item = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT
		repetitions = 3
		
	elseif variant == FamiliarVariant.CUBE_OF_MEAT_4 then
		item = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT
		repetitions = 4
		
	elseif variant == FamiliarVariant.ISAACS_BODY then
		sacrifice = true
		
	elseif variant == FamiliarVariant.SMART_FLY then
		item = CollectibleType.COLLECTIBLE_SMART_FLY
		
	elseif variant == FamiliarVariant.DRY_BABY then
		item = CollectibleType.COLLECTIBLE_DRY_BABY
		
	elseif variant == FamiliarVariant.JUICY_SACK then
		item = CollectibleType.COLLECTIBLE_JUICY_SACK
		
	elseif variant == FamiliarVariant.ROBO_BABY_2 then
		item = CollectibleType.COLLECTIBLE_ROBO_BABY_2
		
	elseif variant == FamiliarVariant.ROTTEN_BABY then
		item = CollectibleType.COLLECTIBLE_ROTTEN_BABY
		
	elseif variant == FamiliarVariant.HEADLESS_BABY then
		item = CollectibleType.COLLECTIBLE_HEADLESS_BABY
		
	elseif variant == FamiliarVariant.LEECH then
		item = CollectibleType.COLLECTIBLE_LEECH
		
	elseif variant == FamiliarVariant.BBF then
		item = CollectibleType.COLLECTIBLE_BBF
		
	elseif variant == FamiliarVariant.BOBS_BRAIN then
		item = CollectibleType.COLLECTIBLE_BOBS_BRAIN
		
	elseif variant == FamiliarVariant.BEST_BUD then
		item = CollectibleType.COLLECTIBLE_BEST_BUD
		
	elseif variant == FamiliarVariant.LIL_BRIMSTONE then
		item = CollectibleType.COLLECTIBLE_LIL_BRIMSTONE
		
	elseif variant == FamiliarVariant.LIL_HAUNT then
		item = CollectibleType.COLLECTIBLE_LIL_HAUNT
		
	elseif variant == FamiliarVariant.DARK_BUM then
		item = CollectibleType.COLLECTIBLE_DARK_BUM
		
	elseif variant == FamiliarVariant.BIG_FAN then
		item = CollectibleType.COLLECTIBLE_BIG_FAN
		
	elseif variant == FamiliarVariant.SISSY_LONGLEGS then
		item = CollectibleType.COLLECTIBLE_SISSY_LONGLEGS
		
	elseif variant == FamiliarVariant.PUNCHING_BAG then
		item = CollectibleType.COLLECTIBLE_PUNCHING_BAG
		
	elseif variant == FamiliarVariant.BALL_OF_BANDAGES_1 then
		item = CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES
		
	elseif variant == FamiliarVariant.BALL_OF_BANDAGES_2 then
		item = CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES
		repetitions = 2
		
	elseif variant == FamiliarVariant.BALL_OF_BANDAGES_3 then
		item = CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES
		repetitions = 3
		
	elseif variant == FamiliarVariant.BALL_OF_BANDAGES_4 then
		item = CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES
		repetitions = 4
		
	elseif variant == FamiliarVariant.MONGO_BABY then
		item = CollectibleType.COLLECTIBLE_MONGO_BABY
		
	elseif variant == FamiliarVariant.CAINS_OTHER_EYE then
		item = CollectibleType.COLLECTIBLE_CAINS_OTHER_EYE
		
	elseif variant == FamiliarVariant.BLUEBABYS_ONLY_FRIEND then
		item = CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND
		
	elseif variant == FamiliarVariant.GEMINI then
		item = CollectibleType.COLLECTIBLE_GEMINI
		
	elseif variant == FamiliarVariant.INCUBUS then
		item = CollectibleType.COLLECTIBLE_INCUBUS
		
	elseif variant == FamiliarVariant.FATES_REWARD then
		item = CollectibleType.COLLECTIBLE_FATES_REWARD
		
	elseif variant == FamiliarVariant.SWORN_PROTECTOR then
		item = CollectibleType.COLLECTIBLE_SWORN_PROTECTOR
		spawnBlackHearts = true
		
	elseif variant == FamiliarVariant.FRIEND_ZONE then
		item = CollectibleType.COLLECTIBLE_FRIEND_ZONE
		
	elseif variant == FamiliarVariant.LOST_FLY then
		item = CollectibleType.COLLECTIBLE_LOST_FLY
		
	elseif variant == FamiliarVariant.CHARGED_BABY then
		item = CollectibleType.COLLECTIBLE_CHARGED_BABY
		
	elseif variant == FamiliarVariant.LIL_GURDY then
		item = CollectibleType.COLLECTIBLE_LIL_GURDY
		
	elseif variant == FamiliarVariant.BUMBO then
		item = CollectibleType.COLLECTIBLE_BUMBO

	elseif variant == FamiliarVariant.KEY_BUM then
		item = CollectibleType.COLLECTIBLE_KEY_BUM
				
	elseif variant == FamiliarVariant.SERAPHIM then
		item = CollectibleType.COLLECTIBLE_SERAPHIM
		spawnBlackHearts = true

	elseif variant == FamiliarVariant.SPIDER_MOD then
		item = CollectibleType.COLLECTIBLE_SPIDER_MOD
				
	elseif variant == FamiliarVariant.FARTING_BABY then
		item = CollectibleType.COLLECTIBLE_FARTING_BABY

	elseif variant == FamiliarVariant.SUCCUBUS then
		item = CollectibleType.COLLECTIBLE_SUCCUBUS
				
	elseif variant == FamiliarVariant.LIL_LOKI then
		item = CollectibleType.COLLECTIBLE_LIL_LOKI

	elseif variant == FamiliarVariant.OBSESSED_FAN then
		item = CollectibleType.COLLECTIBLE_OBSESSED_FAN
				
	elseif variant == FamiliarVariant.PAPA_FLY then
		item = CollectibleType.COLLECTIBLE_PAPA_FLY

	elseif variant == FamiliarVariant.MULTIDIMENSIONAL_BABY then
		item = CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY
				
	elseif variant == FamiliarVariant.SUPER_BUM then
		sacrifice = true

	elseif variant == FamiliarVariant.BIG_CHUBBY then
		item = CollectibleType.COLLECTIBLE_BIG_CHUBBY
				
	elseif variant == FamiliarVariant.HUSHY then
		item = CollectibleType.COLLECTIBLE_HUSHY

	elseif variant == FamiliarVariant.LIL_MONSTRO then
		item = CollectibleType.COLLECTIBLE_LIL_MONSTRO
				
	elseif variant == FamiliarVariant.KING_BABY then
		item = CollectibleType.COLLECTIBLE_KING_BABY

	elseif variant == FamiliarVariant.YO_LISTEN then
		item = CollectibleType.COLLECTIBLE_YO_LISTEN
				
	elseif variant == FamiliarVariant.ACID_BABY then
		item = CollectibleType.COLLECTIBLE_ACID_BABY

	elseif variant == FamiliarVariant.SPIDER_BABY then
		sacrifice = true
				
	elseif variant == FamiliarVariant.BLOODSHOT_EYE then
		item = CollectibleType.COLLECTIBLE_BLOODSHOT_EYE

	elseif variant == FamiliarVariant.ANGRY_FLY then
		item = CollectibleType.COLLECTIBLE_ANGRY_FLY
				
	elseif variant == FamiliarVariant.BUDDY_IN_A_BOX then
		item = CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX

	elseif variant == FamiliarVariant.LIL_HARBINGERS then
		item = CollectibleType.COLLECTIBLE_7_SEALS
				
	elseif variant == FamiliarVariant.LIL_SPEWER then
		item = CollectibleType.COLLECTIBLE_LIL_SPEWER

	elseif variant == FamiliarVariant.INTRUDER then
		item = CollectibleType.COLLECTIBLE_INTRUDER
				
	elseif variant == FamiliarVariant.PSY_FLY then
		item = CollectibleType.COLLECTIBLE_PSY_FLY

	elseif variant == FamiliarVariant.PEEPER_2 then
		sacrifice = true
				
	elseif variant == FamiliarVariant.BOILED_BABY then
		item = CollectibleType.COLLECTIBLE_BOILED_BABY

	elseif variant == FamiliarVariant.FREEZER_BABY then
		item = CollectibleType.COLLECTIBLE_FREEZER_BABY
				
	elseif variant == FamiliarVariant.BIRD_CAGE then
		item = CollectibleType.COLLECTIBLE_BIRD_CAGE

	elseif variant == FamiliarVariant.LOST_SOUL then
		item = CollectibleType.COLLECTIBLE_LOST_SOUL
				
	elseif variant == FamiliarVariant.LIL_DUMPY then
		item = CollectibleType.COLLECTIBLE_LIL_DUMPY

	elseif variant == FamiliarVariant.TINYTOMA then
		item = CollectibleType.COLLECTIBLE_TINYTOMA
				
	elseif variant == FamiliarVariant.BOT_FLY then
		item = CollectibleType.COLLECTIBLE_BOT_FLY

	elseif variant == FamiliarVariant.STITCHES then
		sacrifice = true
		
	elseif variant == FamiliarVariant.BABY_PLUM then
		sacrifice = true
		
	elseif variant == FamiliarVariant.BFRUITY_PLUM then
		item = CollectibleType.COLLECTIBLE_FRUITY_PLUM
		
	elseif variant == FamiliarVariant.LIL_ABADDON then
		item = CollectibleType.COLLECTIBLE_LIL_ABADDON
		
	elseif variant == FamiliarVariant.ABYSS_LOCUST then
		sacrifice = true
		
	elseif variant == FamiliarVariant.LIL_PORTAL then
		item = CollectibleType.COLLECTIBLE_LIL_PORTAL
		
	elseif variant == FamiliarVariant.WORM_FRIEND then
		item = CollectibleType.COLLECTIBLE_WORM_FRIEND
		
	elseif variant == FamiliarVariant.TWISTED_BABY then
		item = CollectibleType.COLLECTIBLE_TWISTED_PAIR
		
	elseif variant == FamiliarVariant.STAR_OF_BETHLEHEM then
		item = CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM
		
	elseif variant == FamiliarVariant.CUBE_BABY then
		item = CollectibleType.COLLECTIBLE_CUBE_BABY
		
	elseif variant == FamiliarVariant.BLOOD_PUPPY then
		item = CollectibleType.COLLECTIBLE_BLOOD_PUPPY
		
	elseif variant == FamiliarVariant.VANISHING_TWIN then
		item = CollectibleType.COLLECTIBLE_VANISHING_TWIN
	end
	
	if kill then
		familiar:Kill()
		local itemReward = Game():GetItemPool():GetCollectible( ItemPoolType.POOL_DEVIL, false, Game():GetSeeds():GetNextSeed(), CollectibleType.COLLECTIBLE_NULL )
		mod.SpawnPickupNear(PickupVariant.PICKUP_COLLECTIBLE, itemReward, pos, 1, player, 1)
		if spawnBlackHearts then
			mod.SpawnPickupNear(PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pos, 1, player, 2)
		end
		
		if item ~= nil then
			for i = 1, repetitions do
				player:RemoveCollectible ( item, false, ActiveSlot.SLOT_PRIMARY, true )
			end
		elseif trinket ~= nil then
			player:TryRemoveTrinket ( trinket )
		end
	end
	
	if item ~= nil or trinket ~= nil then
		sacrifice = true
	end
	
	return sacrifice
end

-- Sacrificial Altar Synergy
function mod.AltarSynergy(player, entities)
	local familiars = {}

	for i = 1, #entities do
		local entity = entities[i]						
		if entity.Type == EntityType.ENTITY_FAMILIAR 
		and mod.SacrificeFamiliar(entity, player, false) then
			familiars[#familiars + 1] = entity
		end
	end	

	if #familiars > 0 then
		local repetitions = #familiars
		if repetitions > 2 then
			repetitions = 2
		end
	
		for i = 1, repetitions do
			local randonFamiliar = mod.r:RandomInt(#familiars) + 1
			local familiar = familiars[randonFamiliar]
			mod.SacrificeFamiliar(familiar, player, true)
			table.remove(familiars, randonFamiliar)
		end
	end
end

------------------------------------ Portable Slot Synergy ---------------------------------------

-- Penny Reward
function mod.PennyReward(player, pos)
	local randomNum = mod.r:RandomInt(100)
	if randomNum < 1 then
		Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.FLY_ORBITAL, 0, pos, Vector(0,0), player)
	elseif randomNum < 3 then
		mod.SpawnPickup(PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pos, player)
	elseif randomNum < 6 then
		mod.SpawnPickup(PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pos, player)
	elseif randomNum < 9 then
		mod.SpawnPickup(PickupVariant.PICKUP_PILL, 0, pos, player)
	elseif randomNum < 13 then
		mod.SpawnPickup(PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pos, player)
	elseif randomNum < 19 then
		mod.SpawnPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, pos, player)
	elseif randomNum < 26 then
		mod.SpawnPickup(PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, player)
	else
		Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, pos, Vector(0,0), player)
	end
end

-- Nickel Reward
function mod.NickelReward(player, pos)
	local randomNum = mod.r:RandomInt(3)
	if randomNum == 0 then
		mod.SpawnPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, player)
	elseif randomNum == 1 then
		mod.SpawnPickup(PickupVariant.PICKUP_TAROTCARD, 0, pos, player)
	else
		mod.SpawnPickup(PickupVariant.PICKUP_GRAB_BAG, 0, pos, player)
	end
end

-- Dime Reward
function mod.DimeReward(player, pos)
	local randomNum = mod.r:RandomInt(100)
	if randomNum < 4 then
		mod.SpawnPickup(PickupVariant.PICKUP_MEGACHEST, ChestSubType.CHEST_CLOSED, pos, player)
	elseif randomNum < 12 then
		mod.SpawnPickup(PickupVariant.PICKUP_OLDCHEST, ChestSubType.CHEST_CLOSED, pos, player)
	elseif randomNum < 28 then
		mod.SpawnPickup(PickupVariant.PICKUP_ETERNALCHEST, ChestSubType.CHEST_CLOSED, pos, player)
	elseif randomNum < 64 then
		mod.SpawnPickup(PickupVariant.PICKUP_LOCKEDCHEST, ChestSubType.CHEST_CLOSED, pos, player)
	else
		mod.SpawnPickup(PickupVariant.PICKUP_BOMBCHEST, ChestSubType.CHEST_CLOSED, pos, player)
	end
end

-- Double Pack Reward
function mod.DoublePackReward(player, pos)
	local randomNum = mod.r:RandomInt(3)
	if randomNum == 0 then
		mod.SpawnPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, pos, player)
	elseif randomNum == 1 then
		mod.SpawnPickup(PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK, pos, player)
	else
		mod.SpawnPickup(PickupVariant.PICKUP_KEY, KeySubType.KEY_DOUBLEPACK, pos, player)
	end
end

-- Lucky Penny Reward
function mod.LuckyPennyReward(player, pos)
	local randomItem = mod.r:RandomInt(#mod.luckItems) + 1
	mod.SpawnItem(pos, player, mod.luckItems[randomItem], 1)
end

-- Sticky Nickel Reward
function mod.StickyNickelReward(player, pos)
	local randomNum = mod.r:RandomInt(100)
	if randomNum < 15 then
		mod.SpawnItem(pos, player, CollectibleType.COLLECTIBLE_STICKY_BOMBS, 1)
	else
		local randomTrinket = mod.r:RandomInt(#mod.bombTrinkets) + 1
		mod.SpawnPickup(PickupVariant.PICKUP_TRINKET, mod.bombTrinkets[randomTrinket], pos, player)
	end
end

-- Golden Penny Reward
function mod.GoldenReward(player, pos)
	local randomNum = mod.r:RandomInt(3)
	if randomNum == 0 then
		mod.SpawnPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN, pos, player)
	elseif randomNum == 1 then
		mod.SpawnPickup(PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN, pos, player)
	else
		mod.SpawnPickup(PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN, pos, player)
	end
end

-- Portable Slot Synergy
function mod.PortableSlotSynergy(player, entities)
	for i = 1, #entities do
		local entity = entities[i]	
		local pos = entity.Position
					
		if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COIN then
			entity:Remove()
			if entity.SubType == CoinSubType.COIN_PENNY then
				mod.PennyReward(player, pos)
			elseif entity.SubType == CoinSubType.COIN_NICKEL then
				mod.NickelReward(player, pos)
			elseif entity.SubType == CoinSubType.COIN_DIME then
				mod.DimeReward(player, pos)
			elseif entity.SubType == CoinSubType.COIN_DOUBLEPACK then
				mod.DoublePackReward(player, pos)
			elseif entity.SubType == CoinSubType.COIN_LUCKYPENNY then
				mod.LuckyPennyReward(player, pos)
			elseif entity.SubType == CoinSubType.COIN_STICKYNICKEL then
				mod.StickyNickelReward(player, pos)
			elseif entity.SubType == CoinSubType.COIN_GOLDEN then
				mod.GoldenReward(player, pos)
			end
		end
	end
end

------------------------------------------ Pandora's Box Synergy ---------------------------------------

function mod.PandorasBoxSynergy(player, pos)
	local level = Game():GetLevel()
	local stage = level:GetStage()
	local stageType = level:GetStageType()
	
	if stage == 1 then -- The Basement I
		mod.SpawnPickupNear(PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, 50, player, 1)
	
	elseif stage == 2 then -- The Basement II
		mod.SpawnPickupNear(PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pos, 50, player, 2)
		mod.SpawnPickupNear(PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pos, 50, player, 2)
	
	elseif stage == 3 then -- The Caves I
		mod.SpawnPickupNear(PickupVariant.PICKUP_TRINKET, 0, pos, 50, player, 1)
	
	elseif stage == 4 then -- The Caves II
		mod.SpawnPickupNear(PickupVariant.PICKUP_TRINKET, 0, pos, 50, player, 1)
	
	elseif stage == 5 then -- The Depths I
		mod.SpawnPickupNear(PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, 50, player, 1)
	
	elseif stage == 6 then -- The Depths II
		mod.SpawnPickupNear(PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, 50, player, 20)
	
	elseif stage == 7 then -- Womb I
		mod.SpawnPickupNear(PickupVariant.PICKUP_TRINKET, 0, pos, 50, player, 2)
	
	elseif stage == 8 then -- Womb II
		mod.SpawnItem(pos, player, CollectibleType.COLLECTIBLE_BIBLE, 50)
	
	elseif stage == 10 then
		if stageType == 0 then -- Sheol
			mod.SpawnPickupNear(PickupVariant.PICKUP_REDCHEST, ChestSubType.CHEST_CLOSED, pos, 50, player, 1)
			mod.SpawnPickupNear(PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pos, 50, player, 1)
		else -- Catheral
			mod.SpawnPickupNear(PickupVariant.PICKUP_ETERNALCHEST, ChestSubType.CHEST_CLOSED, pos, 50, player, 1)
			mod.SpawnPickupNear(PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, pos, 50, player, 1)
		end
		
	elseif stage == 11 and stageType == 1 then -- Chest
		mod.SpawnPickupNear(PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, 50, player, 1)
	end
end

-------------------------------------------------- Main ------------------------------------------------

--On update function
function mod:onUpdate()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
		local playerPos = player.Position
		local roomEntities = Isaac.GetRoomEntities()
	
		-- The Poop
		if mod.usedPoop then
			mod.usedPoop = false
			Isaac.GridSpawn(GridEntityType.GRID_POOP, 0, Isaac.GetFreeNearPosition(player.Position, 1), true)
		end
		
		-- Dad's Key
		if mod.usedDadsKey then
			mod.usedDadsKey = false
				
			for i = 1, #roomEntities do
				local entity = roomEntities[i]						
				if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_KEY and entity.SubType ~= KeySubType.KEY_CHARGED then
					entity:Remove()
					mod.SpawnPickup(PickupVariant.PICKUP_KEY, KeySubType.KEY_CHARGED, entity.Position, player)
				end
			end	
		end
		
		-- Isaac's Tears
		if mod.usedIsaacsTears then
			mod.usedIsaacsTears = false
			local angleInc = 22
				
			for i = 1, 8 do
				mod.ShootTear(player, playerPos, angleInc, "n", 1, "n", player.Damage, 1, 0, false, "n", "n", "n")
				angleInc = angleInc + 45
			end	
		end
			
		-- Guppy's Paw
		if mod.usedGuppysPaw then
			mod.usedGuppysPaw = false
			local converted = false
				
			for i = 1, #roomEntities do
				local entity = roomEntities[i]						
				if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_HEART and entity.SubType == HeartSubType.HEART_FULL then
					entity:Remove()
					mod.SpawnPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, entity.Position, player)
					converted = true
					return
				end
			end	
			
			if not converted then
				for i = 1, #roomEntities do
					local entity = roomEntities[i]						
					if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_HEART and entity.SubType == HeartSubType.HEART_HALF then
						entity:Remove()
						mod.SpawnPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, entity.Position, player)
						break
					end
				end	
			end
		end
		
		-- Kamikaze!
		if mod.usedKamikaze then
			mod.usedKamikaze = false
			
			for i = 1, #roomEntities do
				local entity = roomEntities[i]						
				if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant ~= FamiliarVariant.BLUE_FLY and entity.Variant ~= FamiliarVariant.BLUE_SPIDER then
					Isaac.Explode(entity.Position, nil, 40) 
				end
			end	
		end
		
		-- Converter
		if mod.usedConverter then
			mod.usedConverter = false
			
			for i = 1, #roomEntities do
				local entity = roomEntities[i]						
				if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.BLUE_FLY and entity.SubType == 0 then
					entity:Remove()
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 1, entity.Position, Vector(0,0), player)
				end
			end	
		end
				
		-- The Bible
		if mod.usedTheBible then
			mod.usedTheBible = false
			mod.SpawnBaby(player)
		end
		
		-- Book of the Dead
		if mod.usedBookOfTheDead then
			mod.usedBookOfTheDead = false
			mod.CheckDeadDistance(player, roomEntities)
		end
		
		-- Doctor's Remote
		if mod.usedDoctorsRemote then
			mod.usedDoctorsRemote = false

			local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_ROCKET, 0, playerPos, Vector(0,0), player):ToBomb()
			bomb:AddTearFlags( 4 )
		end
		
		-- Eden's Soul
		if mod.usedEdensSoul then
			mod.usedEdensSoul = false
			mod.SpawnPickupNear(PickupVariant.PICKUP_TRINKET, 0, playerPos, 50, player, 2)
		end
		
		-- Mystery Gift
		if mod.usedMysteryGift then
			mod.usedMysteryGift = false
			mod.SpawnPickupNear(PickupVariant.PICKUP_TRINKET, 0, playerPos, 50, player, 1)
		end
		
		-- IV Bag
		if mod.usedIVBag then
			mod.usedIVBag = false			
			mod.SacrificeFriend(player, roomEntities, "IV Bag")
		end
		
		-- Razor Blade
		if mod.usedRazorBlade then
			mod.usedRazorBlade = false			
			mod.SacrificeFriend(player, roomEntities, "Razor Blade")
		end
		
		-- Golden Razor
		if mod.usedGoldenRazor then
			mod.usedGoldenRazor = false			
			mod.GoldenRazorSynergy(player, roomEntities)
		end

		-- Red Candle
		if mod.usedRedCandle then	
			local fireDirection = player:GetFireDirection()		
			if fireDirection ~= -1 then	
				mod.ShootFire( EffectVariant.HOT_BOMB_FIRE, player, playerPos, false)
				mod.usedRedCandle = false
			end
		end
		
		-- The Candle
		if mod.usedTheCandle then	
			local fireDirection = player:GetFireDirection()		
			if fireDirection ~= -1 then	
				mod.ShootFire( EffectVariant.BLUE_FLAME, player, playerPos, true)
				mod.usedTheCandle = false
			end
		end
		
		-- Remote Detonator
		if mod.usedRemoteDetonator then
			mod.usedRemoteDetonator = false			
			mod.RemoteDetonatorSynergy(roomEntities)
		end
		
		-- Portable Slot
		if mod.usedPortableSlot then
			mod.usedPortableSlot = false			
			mod.PortableSlotSynergy(player, roomEntities)
		end
		
		-- Sacrificial Altar
		if mod.usedAltar then
			mod.usedAltar = false			
			mod.AltarSynergy(player, roomEntities)
		end
		
		-- Sharp Key
		if mod.usedSharpKey then			
			local fireDirection = player:GetFireDirection()		
			if fireDirection ~= -1 then	
				for i = 1, #roomEntities do
					local entity = roomEntities[i]						
					if entity.Type == EntityType.ENTITY_FAMILIAR then
						 local tear = mod.ShootTear(player, entity.Position, 0, fireDirection, 1, 1.5, player.Damage, 5, 0, true, "n", TearVariant.KEY_BLOOD, "n"):ToTear()
						 tear.CollisionDamage = tear.CollisionDamage + 30
					end
				end	

				mod.usedSharpKey = false
			end
		end
		
		-- Telepathy for Dummies
		if mod.usedTelepathy then			
			for i = 1, #roomEntities do
				local entity = roomEntities[i]
				if entity.Type == 2 then
					if entity.SpawnerType == 3 and entity.SpawnerVariant ~= FamiliarVariant.SERAPHIM and entity.SpawnerVariant ~= FamiliarVariant.LITTLE_STEVEN then
						entity:ToTear().TearFlags = entity:ToTear().TearFlags | TearFlags.TEAR_HOMING
						entity:SetColor( Color( 1, 0, 1, 1, 0, 0, 0 ), -1, 1, false, true )
					end
				end
			end
		end
		
		-- Lemon Mishap
		if mod.usedLemonMishap then
			mod.usedLemonMishap = false
			mod.CheckFamiliarDistance(player, roomEntities, false)
		end
		
		-- Free Lemonade
		if mod.usedFreeLemonade then
			mod.usedFreeLemonade = false
			mod.CheckFamiliarDistance(player, roomEntities, true)
		end
		
		-- Alabaster Box
		if mod.usedAlabasterBox then
			mod.usedAlabasterBox = false			
			mod.spawnHolyTrinket = true
			mod.initHolyTrinket = Game():GetFrameCount()
		end
		
		if mod.spawnHolyTrinket then
			local f = Game():GetFrameCount() - mod.initHolyTrinket
			if f == 30 then
				local randomTrinket = mod.r:RandomInt(#mod.holyTrinkets) + 1
				mod.SpawnPickupNear(PickupVariant.PICKUP_TRINKET, mod.holyTrinkets[randomTrinket], playerPos, 50, player, 1)
				mod.spawnHolyTrinket = false
			end
		end
		
		-- Pandora's Box
		if mod.usedPandorasBox then
			mod.usedPandorasBox = false			
			mod.PandorasBoxSynergy(player, playerPos)
		end
	end
end
mod:AddCallback( ModCallbacks.MC_POST_UPDATE, mod.onUpdate )

-------------------------------------------- On Item Use -------------------------------------------------

-- The Poop
function mod:OnThePoopUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["ThePoop"] then
		mod.usedPoop = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnThePoopUse, CollectibleType.COLLECTIBLE_POOP)

-- Dad's Key
function mod:OnDadsKeyUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["DadsKey"] then
		mod.usedDadsKey = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnDadsKeyUse, CollectibleType.COLLECTIBLE_DADS_KEY)

-- Isaac's Tears
function mod:OnIsaacsTearsUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["IsaacsTears"] then
		mod.usedIsaacsTears = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnIsaacsTearsUse, CollectibleType.COLLECTIBLE_ISAACS_TEARS)

-- Guppy's Paw
function mod:OnGuppysPawUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["GuppysPaw"] then
		mod.usedGuppysPaw = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnGuppysPawUse, CollectibleType.COLLECTIBLE_GUPPYS_PAW)

-- Kamikaze!
function mod:OnKamikazeUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if mod.Settings["Kamikaze"] then
		mod.usedKamikaze = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnKamikazeUse, CollectibleType.COLLECTIBLE_KAMIKAZE)

-- Converter
function mod:OnConverterUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["Converter"] then
		mod.usedConverter = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnConverterUse, CollectibleType.COLLECTIBLE_CONVERTER)

-- The Bible
function mod:OnTheBibleUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["TheBible"] then
		mod.usedTheBible = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnTheBibleUse, CollectibleType.COLLECTIBLE_BIBLE)

-- Book of the Dead
function mod:OnBookOfTheDeadUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["BookOfTheDead"] then
		mod.usedBookOfTheDead = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnBookOfTheDeadUse, CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD)

-- Doctor's Remote
function mod:OnDoctorsRemoteUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["DoctorsRemote"] then
		mod.usedDoctorsRemote = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnDoctorsRemoteUse, CollectibleType.COLLECTIBLE_DOCTORS_REMOTE)

-- Eden's Soul
function mod:OnEdensSoulUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if mod.Settings["EdensSoul"] then
		mod.usedEdensSoul = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnEdensSoulUse, CollectibleType.COLLECTIBLE_EDENS_SOUL)

-- Mystery Gift
function mod:OnMysteryGiftUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["MysteryGift"] then
		mod.usedMysteryGift = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnMysteryGiftUse, CollectibleType.COLLECTIBLE_MYSTERY_GIFT)

-- IV Bag
function mod:OnIVBagUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["IVBag"] then
		mod.usedIVBag = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnIVBagUse, CollectibleType.COLLECTIBLE_IV_BAG)

-- Razor Blade
function mod:OnRazorBladeUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["RazorBlade"] then
		mod.usedRazorBlade = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnRazorBladeUse, CollectibleType.COLLECTIBLE_RAZOR_BLADE)

-- Golden Razor
function mod:OnGoldenRazorUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["GoldenRazor"] then
		mod.usedGoldenRazor = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnGoldenRazorUse, CollectibleType.COLLECTIBLE_GOLDEN_RAZOR)

-- Red Candle
function mod:OnRedCandleUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if mod.Settings["RedCandle"] then
		if mod.usedRedCandle then
			mod.usedRedCandle = false
			return
		end
		mod.usedRedCandle = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnRedCandleUse, CollectibleType.COLLECTIBLE_RED_CANDLE)

-- The Candle
function mod:OnTheCandleUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if mod.Settings["TheCandle"] then
		if mod.usedTheCandle then
			mod.usedTheCandle = false
			return
		end
		mod.usedTheCandle = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnTheCandleUse, CollectibleType.COLLECTIBLE_CANDLE)

-- Remote Detonator
function mod:OnRemoteDetonatorUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["RemoteDetonator"] then
		mod.usedRemoteDetonator = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnRemoteDetonatorUse, CollectibleType.COLLECTIBLE_REMOTE_DETONATOR)

-- Portable Slot
function mod:OnPortableSlotUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["PortableSlot"] then
		mod.usedPortableSlot = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnPortableSlotUse, CollectibleType.COLLECTIBLE_PORTABLE_SLOT)

-- Sacrificial Altar
function mod:OnSacrificialAltarUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if mod.Settings["SacrificialAltar"] then
		mod.usedAltar = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnSacrificialAltarUse, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

-- Sharp Key
function mod:OnSharpKeyUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if mod.Settings["SharpKey"] then
		if mod.usedSharpKey then
			mod.usedSharpKey = false
			return
		end
		mod.usedSharpKey = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnSharpKeyUse, CollectibleType.COLLECTIBLE_SHARP_KEY)

-- Telepathy for Dummies
function mod:OnTelepathyUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if mod.Settings["TelepathyForDummies"] then
		mod.usedTelepathy = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnTelepathyUse, CollectibleType.COLLECTIBLE_TELEPATHY_BOOK)

-- Mom's Bra
function mod:OnMomsBraUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["MomsBra"] then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
			mod.usedMomsBra = true
			mod.initMomsBra = Game():GetFrameCount()
		end
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnMomsBraUse, CollectibleType.COLLECTIBLE_MOMS_BRA)

-- Lemon Mishap
function mod:OnLemonMishapUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["LemonMishap"] then
		mod.usedLemonMishap = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnLemonMishapUse, CollectibleType.COLLECTIBLE_LEMON_MISHAP)

-- Free Lemonade
function mod:OnFreeLemonadeUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["FreeLemonade"] then
		mod.usedFreeLemonade = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnFreeLemonadeUse, CollectibleType.COLLECTIBLE_FREE_LEMONADE)

-- Alabaster Box
function mod:OnAlabasterBoxUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["AlabasterBox"] then
		mod.usedAlabasterBox = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnAlabasterBoxUse, CollectibleType.COLLECTIBLE_ALABASTER_BOX)

-- Pandora's Box
function mod:OnPandorasBoxUse(collectibleID, rngObj, player, useFlags, activeSlot, varData)	
	if mod.Settings["PandorasBox"] then
		mod.usedPandorasBox = true
	end
end
mod:AddCallback( ModCallbacks.MC_USE_ITEM, mod.OnPandorasBoxUse, CollectibleType.COLLECTIBLE_BLUE_BOX)

------------------------------------------- On Death --------------------------------------------------

function mod.onDeath(_, ent)
	if mod.usedMomsBra then
		local player = Isaac.GetPlayer(0)
		local pos = ent.Position
		if ent:IsActiveEnemy(true) and ent:HasEntityFlags(EntityFlag.FLAG_FREEZE)then
			local f = Game():GetFrameCount() - mod.initMomsBra
			if f < 150 then
				Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DIP, 12, pos, Vector(0, 0), player)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onDeath)

----------------------------------------- On a New Room ------------------------------------------------

function mod:OnNewRoom()
	local player = Isaac.GetPlayer(0)
	
	mod.razorDamageCount = 0
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
	
	mod.usedRedCandle = false
	mod.usedTheCandle = false
	mod.usedSharpKey = false
	mod.usedTelepathy = false
	mod.usedMomsBra = false
	
	-- Remove Babies
	for i = #mod.babies, 1, -1 do
		if mod.babies[i] then
			mod.babies[i]:Remove()
		end
		table.remove(mod.babies, i)
	end	
end
mod:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, mod.OnNewRoom )

------------------------------------------- Save & Load --------------------------------------------------

-- Save mod settings on game exit
function mod:onExit(SaveData) 
	if SaveData then
		local modDataString = ""
		modDataString = modDataString .. tostring (mod.goldenRazorDamageSum)
		.. "," .. tostring (mod.Settings["AlabasterBox"]) 		
		.. "," .. tostring (mod.Settings["BookOfTheDead"]) 
		.. "," .. tostring (mod.Settings["Converter"]) 
		.. "," .. tostring (mod.Settings["DadsKey"]) 
		.. "," .. tostring (mod.Settings["DoctorsRemote"])
		.. "," .. tostring (mod.Settings["EdensSoul"])
		.. "," .. tostring (mod.Settings["FreeLemonade"])
		.. "," .. tostring (mod.Settings["GoldenRazor"])
		.. "," .. tostring (mod.Settings["GuppysPaw"])
		.. "," .. tostring (mod.Settings["IsaacsTears"])
		.. "," .. tostring (mod.Settings["IVBag"])
		.. "," .. tostring (mod.Settings["Kamikaze"])
		.. "," .. tostring (mod.Settings["LemonMishap"])
		.. "," .. tostring (mod.Settings["MomsBra"]) 
		.. "," .. tostring (mod.Settings["MysteryGift"]) 
		.. "," .. tostring (mod.Settings["PandorasBox"]) 
		.. "," .. tostring (mod.Settings["PortableSlot"])
		.. "," .. tostring (mod.Settings["RazorBlade"])
		.. "," .. tostring (mod.Settings["RedCandle"])
		.. "," .. tostring (mod.Settings["RemoteDetonator"])
		.. "," .. tostring (mod.Settings["SacrificialAltar"])
		.. "," .. tostring (mod.Settings["SharpKey"])
		.. "," .. tostring (mod.Settings["TelepathyForDummies"])
		.. "," .. tostring (mod.Settings["TheBible"])
		.. "," .. tostring (mod.Settings["TheCandle"])
		.. "," .. tostring (mod.Settings["ThePoop"])
		.. "," .. tostring (mod.Settings["SaveDataVersion"])
		Isaac.SaveModData(mod,modDataString)
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.onExit)

-- Load mod settings when reloading a game
function mod:onReload(SaveData)
	local modDatastring = Isaac.LoadModData(mod)
	
	if modDatastring ~= nil and modDatastring ~= "" then	
		Isaac.DebugString(modDatastring)
		goldenRazorDamageSumStr,AlabasterBoxStr,BookOfTheDeadStr,ConverterStr,DadsKeyStr,DoctorsRemoteStr,EdensSoulStr,FreeLemonadeStr,GoldenRazorStr,
		GuppysPawStr,IsaacsTearsStr,IVBagStr,KamikazeStr,LemonMishapStr,MomsBraStr,MysteryGiftStr,PandorasBoxStr,PortableSlotStr,RazorBladeStr,
		RedCandleStr,RemoteDetonatorStr,SacrificialAltarStr,SharpKeyStr,TelepathyForDummiesStr,TheBibleStr,TheCandleStr,ThePoopStr,SaveDataVersionStr
		= modDatastring:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
		
		mod.Settings["SaveDataVersion"] = tonumber(SaveDataVersionStr)
		local valid = false
		if mod.Settings["SaveDataVersion"] ~= nil then
			if mod.Settings["SaveDataVersion"] == mod.savedataVersion then
				valid = true
			end
		end
		if valid then
			mod.Settings["AlabasterBox"] = AlabasterBoxStr == "true"
			mod.Settings["BookOfTheDead"] = BookOfTheDeadStr == "true"
			mod.Settings["Converter"] = ConverterStr == "true"
			mod.Settings["DadsKey"] = DadsKeyStr == "true"
			mod.Settings["DoctorsRemote"] = DoctorsRemoteStr == "true"
			mod.Settings["EdensSoul"] = EdensSoulStr == "true"
			mod.Settings["FreeLemonade"] = FreeLemonadeStr == "true"
			mod.Settings["GoldenRazor"] = GoldenRazorStr == "true"
			mod.Settings["GuppysPaw"] = GuppysPawStr == "true"
			mod.Settings["IsaacsTears"] = IsaacsTearsStr == "true"
			mod.Settings["IVBag"] = IVBagStr == "true"
			mod.Settings["Kamikaze"] = KamikazeStr == "true"
			mod.Settings["LemonMishap"] = LemonMishapStr == "true"
			mod.Settings["MomsBra"] = MomsBraStr == "true"
			mod.Settings["MysteryGift"] = MysteryGiftStr == "true"
			mod.Settings["PandorasBox"] = PandorasBoxStr == "true"
			mod.Settings["PortableSlot"] = PortableSlotStr == "true"
			mod.Settings["RazorBlade"] = RazorBladeStr == "true"
			mod.Settings["RedCandle"] = RedCandleStr == "true"
			mod.Settings["RemoteDetonator"] = RemoteDetonatorStr == "true"
			mod.Settings["SacrificialAltar"] = SacrificialAltarStr == "true"
			mod.Settings["SharpKey"] = SharpKeyStr == "true"
			mod.Settings["TelepathyForDummies"] = TelepathyForDummiesStr == "true"
			mod.Settings["TheBible"] = TheBibleStr == "true"
			mod.Settings["TheCandle"] = TheCandleStr == "true"
			mod.Settings["ThePoop"] = ThePoopStr == "true"
		else
			Isaac.RemoveModData(mod)
			mod.Settings["SaveDataVersion"] = mod.savedataVersion
			mod.Settings["AlabasterBox"] = true
			mod.Settings["BookOfTheDead"] = true
			mod.Settings["Converter"] = true
			mod.Settings["DadsKey"] = true
			mod.Settings["DoctorsRemote"] = true
			mod.Settings["EdensSoul"] = true
			mod.Settings["FreeLemonade"] = true
			mod.Settings["GoldenRazor"] = true
			mod.Settings["GuppysPaw"] = true
			mod.Settings["IsaacsTears"] = true
			mod.Settings["IVBag"] = true
			mod.Settings["Kamikaze"] = true
			mod.Settings["LemonMishap"] = true
			mod.Settings["MomsBra"] = true
			mod.Settings["MysteryGift"] = true
			mod.Settings["PandorasBox"] = true
			mod.Settings["PortableSlot"] = true
			mod.Settings["RazorBlade"] = true
			mod.Settings["RedCandle"] = true
			mod.Settings["RemoteDetonator"] = true
			mod.Settings["SacrificialAltar"] = true
			mod.Settings["SharpKey"] = true
			mod.Settings["TelepathyForDummies"] = true
			mod.Settings["TheBible"] = true
			mod.Settings["TheCandle"] = true
			mod.Settings["ThePoop"] = true
	
			modDataString = ""
			modDataString = modDataString .. tostring (mod.goldenRazorDamageSum)
			.. "," .. tostring (mod.Settings["AlabasterBox"]) 		
			.. "," .. tostring (mod.Settings["BookOfTheDead"]) 
			.. "," .. tostring (mod.Settings["Converter"]) 
			.. "," .. tostring (mod.Settings["DadsKey"]) 
			.. "," .. tostring (mod.Settings["DoctorsRemote"])
			.. "," .. tostring (mod.Settings["EdensSoul"])
			.. "," .. tostring (mod.Settings["FreeLemonade"])
			.. "," .. tostring (mod.Settings["GoldenRazor"])
			.. "," .. tostring (mod.Settings["GuppysPaw"])
			.. "," .. tostring (mod.Settings["IsaacsTears"])
			.. "," .. tostring (mod.Settings["IVBag"])
			.. "," .. tostring (mod.Settings["Kamikaze"])
			.. "," .. tostring (mod.Settings["LemonMishap"])
			.. "," .. tostring (mod.Settings["MomsBra"]) 
			.. "," .. tostring (mod.Settings["MysteryGift"]) 
			.. "," .. tostring (mod.Settings["PandorasBox"]) 
			.. "," .. tostring (mod.Settings["PortableSlot"])
			.. "," .. tostring (mod.Settings["RazorBlade"])
			.. "," .. tostring (mod.Settings["RedCandle"])
			.. "," .. tostring (mod.Settings["RemoteDetonator"])
			.. "," .. tostring (mod.Settings["SacrificialAltar"])
			.. "," .. tostring (mod.Settings["SharpKey"])
			.. "," .. tostring (mod.Settings["TelepathyForDummies"])
			.. "," .. tostring (mod.Settings["TheBible"])
			.. "," .. tostring (mod.Settings["TheCandle"])
			.. "," .. tostring (mod.Settings["ThePoop"])
			.. "," .. tostring (mod.Settings["SaveDataVersion"])
			Isaac.SaveModData(mod,modDataString)
		end
	end
	
	if not SaveData then
		local player = Isaac.GetPlayer(0)
		mod.goldenRazorDamageSum = 0
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
		
	else
		mod.goldenRazorDamageSum = tonumber(goldenRazorDamageSumStr)
		if mod.goldenRazorDamageSum == nil then
			mod.goldenRazorDamageSum = 0
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onReload)