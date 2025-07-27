local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local kZeroVector = Vector.Zero

local kDiscDuration = 30 * 60 -- 1 minute

local kMinItemsPerDisc = 3
local kMaxItemsPerDisc = 5

local kMaxItemPickAttempts = 50

local kItemIconsBaseArc = 70
local kItemIconsStartDuration = 100
local kItemIconsDisappearDuration = 60

local wispCache = {}
local itemIcons = {}

-- Most items that would do nothing as wisps don't have the summonable tag anyway.
-- Everything I've listed here DOES have the summonable tag, though.
local DiscBlacklist = {
	[CollectibleType.COLLECTIBLE_MOMS_PURSE] = true,
	[CollectibleType.COLLECTIBLE_PAGEANT_BOY] = true,
	[CollectibleType.COLLECTIBLE_MISSING_NO] = true,
	[CollectibleType.COLLECTIBLE_BUMBO] = true,
	[CollectibleType.COLLECTIBLE_DADS_LOST_COIN] = true,
	[CollectibleType.COLLECTIBLE_SCHOOLBAG] = true,
}

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	if TaintedCollectibles then
		DiscBlacklist[TaintedCollectibles.CRYSTAL_SKULL] = true
	end
end)

mod.ItemDiscs = {
	mod.ITEM.CARD.TREASURE_DISC,
	mod.ITEM.CARD.SHOP_DISC,
	mod.ITEM.CARD.BOSS_DISC,
	mod.ITEM.CARD.SECRET_DISC,
	mod.ITEM.CARD.DEVIL_DISC,
	mod.ITEM.CARD.ANGEL_DISC,
	mod.ITEM.CARD.PLANETARIUM_DISC,
	mod.ITEM.CARD.CHAOS_DISC,
	mod.ITEM.CARD.BROKEN_DISC,
	mod.ITEM.CARD.TAINTED_TREASURE_DISC,
}

local BasicDiscs = {
	mod.ITEM.CARD.TREASURE_DISC,
	mod.ITEM.CARD.SHOP_DISC,
	mod.ITEM.CARD.BOSS_DISC,
	mod.ITEM.CARD.SECRET_DISC,
	mod.ITEM.CARD.DEVIL_DISC,
	mod.ITEM.CARD.ANGEL_DISC,
	mod.ITEM.CARD.PLANETARIUM_DISC,
}

local DISC_INFO = {
	[mod.ITEM.CARD.TREASURE_DISC] = {
		Pool = ItemPoolType.POOL_TREASURE,
		GreedPool = ItemPoolType.POOL_GREED_TREASURE,
		Fallbacks = {
			CollectibleType.COLLECTIBLE_SAD_ONION,
			CollectibleType.COLLECTIBLE_HALO_OF_FLIES,
			CollectibleType.COLLECTIBLE_BREAKFAST,
		},
		Sfx = mod.Sounds.TreasureDisc,
	},
	[mod.ITEM.CARD.SHOP_DISC] = {
		Pool = ItemPoolType.POOL_SHOP,
		GreedPool = ItemPoolType.POOL_GREED_SHOP,
		Fallbacks = { CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX },
		Sfx = mod.Sounds.ShopDisc,
	},
	[mod.ITEM.CARD.BOSS_DISC] = {
		Pool = ItemPoolType.POOL_BOSS,
		GreedPool = ItemPoolType.POOL_GREED_BOSS,
		Fallbacks = {
			CollectibleType.COLLECTIBLE_BREAKFAST,
			CollectibleType.COLLECTIBLE_LUNCH,
			CollectibleType.COLLECTIBLE_DINNER,
		},
		Sfx = mod.Sounds.BossDisc,
	},
	[mod.ITEM.CARD.SECRET_DISC] = {
		Pool = ItemPoolType.POOL_SECRET,
		GreedPool = ItemPoolType.POOL_GREED_SECRET,
		Fallbacks = {
			CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN,
			CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE,
			CollectibleType.COLLECTIBLE_TRANSCENDENCE,
		},
		Sfx = mod.Sounds.SecretDisc,
	},
	[mod.ITEM.CARD.DEVIL_DISC] = {
		Pool = ItemPoolType.POOL_DEVIL,
		GreedPool = ItemPoolType.POOL_GREED_DEVIL,
		Fallbacks = {
			CollectibleType.COLLECTIBLE_PENTAGRAM,
			CollectibleType.COLLECTIBLE_MARK,
			CollectibleType.COLLECTIBLE_PACT,
		},
		Sfx = mod.Sounds.DevilDisc,
	},
	[mod.ITEM.CARD.ANGEL_DISC] = {
		Pool = ItemPoolType.POOL_ANGEL,
		GreedPool = ItemPoolType.POOL_GREED_ANGEL,
		Fallbacks = {
			CollectibleType.COLLECTIBLE_HALO,
			CollectibleType.COLLECTIBLE_CELTIC_CROSS,
			CollectibleType.COLLECTIBLE_WAFER,
		},
		Sfx = mod.Sounds.AngelDisc,
	},
	[mod.ITEM.CARD.PLANETARIUM_DISC] = {
		Pool = ItemPoolType.POOL_PLANETARIUM,
		GreedPool = ItemPoolType.POOL_PLANETARIUM,
		Fallbacks = {
			CollectibleType.COLLECTIBLE_MAGIC_8_BALL,
			CollectibleType.COLLECTIBLE_ZODIAC,
			CollectibleType.COLLECTIBLE_MONAS_HIEROGLYPHICA,
		},
		Sfx = mod.Sounds.PlanetariumDisc,
	},
	[mod.ITEM.CARD.CHAOS_DISC] = {
		Pool = ItemPoolType.POOL_NULL,
		GreedPool = ItemPoolType.POOL_NULL,
		Fallbacks = {
			CollectibleType.COLLECTIBLE_CHAOS,
			CollectibleType.COLLECTIBLE_FRUIT_CAKE,
			CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE,
		},
	},
	[mod.ITEM.CARD.BROKEN_DISC] = {
		Pool = ItemPoolType.POOL_NULL,
		GreedPool = ItemPoolType.POOL_NULL,
		Fallbacks = { CollectibleType.COLLECTIBLE_GB_BUG },
		Sfx = mod.Sounds.BrokenDisc,
	},
	[mod.ITEM.CARD.TAINTED_TREASURE_DISC] = {
		Pool = ItemPoolType.POOL_TREASURE,
		GreedPool = ItemPoolType.POOL_GREED_TREASURE,
		Fallbacks = { CollectibleType.COLLECTIBLE_SAD_ONION },
		Sfx = mod.Sounds.TaintedTreasureDisc,
	},
}

local function GetRandomBasicDisc(rng)
	return BasicDiscs[(rng:Next() % #BasicDiscs) + 1]
end

local function GetRandomBasicDiscInfo(rng)
	return DISC_INFO[GetRandomBasicDisc(rng)]
end

-- Savedata for which discs are currently active.
local function GetDiscData(player)
	local data = player:GetData().ffsavedata
	if not data.DiscData then
		data.DiscData = {}
	end
	return data.DiscData
end

-- Savedata which stores the InitSeeds of item wisps spawned from discs are expected to still exist.
-- Helps take advantage of the fact that item wisps maintain their InitSeed after quit+continue.
local function GetDiscWispRefs()
	local data = FiendFolio.savedata.run
	if not data.DiscWisps then
		data.DiscWisps = {}
	end
	return data.DiscWisps
end

local function InitializeDiscItemWisp(wisp)
	wisp:AddEntityFlags(EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_REWARD)
	wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	wisp.Visible = false
	wisp:RemoveFromOrbit()
	wisp:GetData().isFfDiscWisp = true
	wispCache[wisp.InitSeed] = wisp
end

local cachedTaintedCollectibles
local isTaintedItem = {}

local function PickTaintedTreasuresItem(rng)
	if not TaintedCollectibles then
		return CollectibleType.COLLECTIBLE_SAD_ONION
	end
	
	if not cachedTaintedCollectibles then
		cachedTaintedCollectibles = {}
		
		for _, id in pairs(TaintedCollectibles) do
			table.insert(cachedTaintedCollectibles, id)
			isTaintedItem[id] = true
		end
	end
	
	return cachedTaintedCollectibles[(rng:Next() % #cachedTaintedCollectibles) + 1]
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, card)
	if card.SubType == mod.ITEM.CARD.TAINTED_TREASURE_DISC and not TaintedCollectibles then
		card:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, GetRandomBasicDisc(card:GetDropRNG()), true, true, true)
	end
end, PickupVariant.PICKUP_TAROTCARD)

local function isValidDiscItem(player, itemConfigEntry, isBrokenDisc)
	return itemConfigEntry and itemConfigEntry.ID > 0
			and not DiscBlacklist[itemConfigEntry.ID]
			and itemConfigEntry.Type ~= ItemType.ITEM_ACTIVE
			and (itemConfigEntry.Tags & ItemConfig.TAG_SUMMONABLE ~= 0 or isTaintedItem[itemConfigEntry.ID])
			and (not player:HasCollectible(itemConfigEntry.ID, true) or mod:IsItemStackable(itemConfigEntry.ID, true))
			and not (isBrokenDisc and not mod:IsItemStackable(itemConfigEntry.ID, true))
end

local function pickItemFromPool(player, pool, rng, disc)
	local isBrokenDisc = (disc == mod.ITEM.CARD.BROKEN_DISC)
	
	local itemPool = game:GetItemPool()
	local itemConfig = Isaac.GetItemConfig()
	
	local itemID
	local itemConfigEntry
	
	local attempts = 0
	
	while not isValidDiscItem(player, itemConfigEntry, isBrokenDisc) and attempts < kMaxItemPickAttempts do
		local poolType = pool
		
		if TaintedCollectibles and disc == mod.ITEM.CARD.TAINTED_TREASURE_DISC then
			itemID = PickTaintedTreasuresItem(rng)
		else
			if poolType == ItemPoolType.POOL_NULL then
				-- Pick a random pool for Chaos/Broken Disc
				local tab = GetRandomBasicDiscInfo(rng)
				if game:IsGreedMode() then
					poolType = tab.GreedPool
				else
					poolType = tab.Pool
				end
			end
			
			if (poolType == ItemPoolType.POOL_SHOP or poolType == ItemPoolType.POOL_GREED_SHOP) and player:HasTrinket(TrinketType.TRINKET_ADOPTION_PAPERS) then
				poolType = ItemPoolType.POOL_BABY_SHOP
			end
			
			itemID = itemPool:GetCollectible(poolType, false, rng:Next())
		end
		
		itemConfigEntry = itemConfig:GetCollectible(itemID)
		
		attempts = attempts + 1
	end
	
	if isValidDiscItem(player, itemConfigEntry, isBrokenDisc) then
		return itemConfigEntry
	end
end

-- Starts a visual of an item appearing/disappearing.
local function ShowItemIcon(player, itemGfx, angle, isRemoval)
	local sprite = Sprite()
	sprite:Load("gfx/005.100_collectible.anm2", false)
	sprite:Play("ShopIdle")
	sprite:ReplaceSpritesheet(1, itemGfx)
	sprite:LoadGraphics()
	
	local pos = player.Position
	if not isRemoval then
		pos = pos - Vector(0, 35)
	end
	local vel = Vector.FromAngle(angle + 180) * 5
	
	table.insert(itemIcons, {
		Sprite = sprite,
		Pos = pos,
		Vel = vel,
		Player = player,
		FrameCount = 0,
		IsRemoval = isRemoval,
	})
end

local discLines = {
    [mod.ITEM.CARD.TREASURE_DISC] = {Sound = mod.Sounds.VAObjectDiscTreasure, Delay = 40},
    [mod.ITEM.CARD.SHOP_DISC] = {Sound = mod.Sounds.VAObjectDiscShop, Delay = 75},
    [mod.ITEM.CARD.BOSS_DISC] = {Sound = mod.Sounds.VAObjectDiscBoss, Delay = 50},
    [mod.ITEM.CARD.SECRET_DISC] = {Sound = mod.Sounds.VAObjectDiscSecret},
    [mod.ITEM.CARD.DEVIL_DISC] = {Sound = mod.Sounds.VAObjectDiscDevil, Delay = 50},
    [mod.ITEM.CARD.ANGEL_DISC] = {Sound = mod.Sounds.VAObjectDiscAngel, Delay = 60},
    [mod.ITEM.CARD.PLANETARIUM_DISC] = {Sound = mod.Sounds.VAObjectDiscPlanetarium, Delay = 50},
    [mod.ITEM.CARD.CHAOS_DISC] = {Sound = mod.Sounds.VAObjectDiscChaos, Delay = 60},
    [mod.ITEM.CARD.BROKEN_DISC] = {Sound = mod.Sounds.VAObjectDiscBroken, Delay = 60},
    [mod.ITEM.CARD.TAINTED_TREASURE_DISC] = {Sound = mod.Sounds.VAObjectDiscTainted, Delay = 40},
}

function mod:itemDisc(disc, player, useFlags)
	local discInfo = DISC_INFO[disc]

	FiendFolio:trySayAnnouncerLine(discLines[disc].Sound, useFlags, discLines[disc].Delay or 30)
	
	if not discInfo then
		print("[FF] Disc Error: No disc data found for CardID: " .. disc)
	end
	
	local rng = player:GetCardRNG(disc)
	
	local pool
	if game:IsGreedMode() then
		pool = discInfo.GreedPool
	else
		pool = discInfo.Pool
	end
	
	if not pool or pool < ItemPoolType.POOL_NULL or pool >= ItemPoolType.NUM_ITEMPOOLS then
		print("[FF] Disc Error: ItemPool is: " .. (pool or "NULL"))
	end
	
	local itemConfig = Isaac.GetItemConfig()
	local wispRefs = GetDiscWispRefs()
	
	local numItems = kMinItemsPerDisc + rng:RandomInt(kMaxItemsPerDisc - kMinItemsPerDisc + 1)
	local duration = kDiscDuration
	
	local pickedItems = {}
	local usedFallbacks = 0
	
	for i=1, numItems do
		local itemConfigEntry = pickItemFromPool(player, pool, rng, disc)
		
		if not itemConfigEntry then
			usedFallbacks = usedFallbacks + 1
			
			-- Use a fallback item for this disc.
			local fallbackItem = discInfo.Fallbacks[usedFallbacks] or discInfo.Fallbacks[1]
			
			if not fallbackItem then break end
			
			itemConfigEntry = itemConfig:GetCollectible(fallbackItem)
		end
		
		if itemConfigEntry then
			table.insert(pickedItems, itemConfigEntry)
			
			-- For the Broken Disc, just use all this same item.
			if disc == mod.ITEM.CARD.BROKEN_DISC then
				while #pickedItems < numItems do
					table.insert(pickedItems, itemConfigEntry)
				end
				break
			end
		end
		
		if usedFallbacks >= 3 then
			break
		end
	end
	
	local newWisps = {}
	
	for i, itemConfigEntry in pairs(pickedItems) do
		-- Display the item that was obtained.
		local angle = 90
		if #pickedItems > 1 then
			local arc = kItemIconsBaseArc
			if #pickedItems > 3 then
				arc = mod:Lerp(kItemIconsBaseArc, 360 - (360 / #pickedItems), (#pickedItems - 3) / (kMaxItemsPerDisc * 2 - 3))
			end
			angle = angle - arc * 0.5 + arc * ((i-1) / (#pickedItems-1))
		end
		ShowItemIcon(player, itemConfigEntry.GfxFileName, angle)
		
		-- Add the hidden item wisp.
		local wisp = player:AddItemWisp(itemConfigEntry.ID, player.Position)
		InitializeDiscItemWisp(wisp)
		wispRefs[""..wisp.InitSeed] = true
		mod:discItemWispUpdate(wisp)
		newWisps[""..wisp.InitSeed] = itemConfigEntry.ID
	end
	
	table.insert(GetDiscData(player), {
		Duration = duration,
		Wisps = newWisps,
	})
	
	sfx:Play(SoundEffect.SOUND_THUMBSUP)
	
	-- Play the unique disc sound(s).
	if disc == mod.ITEM.CARD.BROKEN_DISC then
		local delay = 30
		local extraSfx = GetRandomBasicDiscInfo(rng).Sfx
		for i=0, 3 do
			mod.scheduleForUpdate(function()
				sfx:Stop(extraSfx)
				sfx:Play(discInfo.Sfx, 1, 0, false, 1)
				if i < 3 then
					sfx:Play(extraSfx, 1.5, 0, false, 0.4)
				end
			end, delay*i, ModCallbacks.MC_POST_RENDER)
		end
	elseif disc == mod.ITEM.CARD.CHAOS_DISC then
		local pitch = 1.5
		local delay = 30
		local sound1 = GetRandomBasicDiscInfo(rng).Sfx
		local sound2
		while not sound2 or sound2 == sound1 do
			sound2 = GetRandomBasicDiscInfo(rng).Sfx
		end
		local sound3 = GetRandomBasicDiscInfo(rng).Sfx
		sfx:Play(sound1, 1, 0, false, pitch)
		mod.scheduleForUpdate(function()
			sfx:Stop(sound1)
			sfx:Play(sound2, 1, 0, false, pitch)
		end, delay, ModCallbacks.MC_POST_RENDER)
		mod.scheduleForUpdate(function()
			sfx:Stop(sound2)
			sfx:Play(sound3, 1, 0, false, pitch)
		end, delay*2, ModCallbacks.MC_POST_RENDER)
	else
		local discSfx = discInfo.Sfx
		if discSfx then
			sfx:Play(discSfx)
		end
	end
end
for _, disc in pairs(mod.ItemDiscs) do
	mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.itemDisc, disc)
end

local kWhite = Color(1,1,1,0.5,1,1,1)
local kNormal = Color(1,1,1,0.8)
local kInvisible = Color(1,1,1,0)

-- Renders the visuals of items appearing/disappearing.
function mod:discPostRender()
	for k, tab in pairs(itemIcons) do
		if not game:IsPaused() then
			if tab.IsRemoval then
				tab.Vel = mod:Lerp(tab.Vel, kZeroVector, 0.075)
				tab.Sprite.Color = Color.Lerp(kNormal, kInvisible, tab.FrameCount / kItemIconsDisappearDuration)
			elseif tab.FrameCount < kItemIconsStartDuration then
				tab.Vel = mod:Lerp(tab.Vel, kZeroVector, 0.075)
				tab.Sprite.Color = Color.Lerp(kWhite, kNormal, math.min(tab.FrameCount / kItemIconsStartDuration*5, 1)),kNormal
			else
				tab.Vel = mod:Lerp(tab.Vel, ((tab.Player.Position + tab.Player.Velocity) - tab.Pos):Resized(15), 0.1)
				local t = tab.Player.Position:Distance(tab.Pos) / 100
				t = math.min(math.max(t, 0), 1)
				local targetColor = Color.Lerp(kWhite, kNormal, t)
				tab.Sprite.Color = Color.Lerp(tab.Sprite.Color, targetColor, 0.2)
			end
			tab.Pos = tab.Pos + tab.Vel
			tab.FrameCount = tab.FrameCount + 1
		end
		
		tab.Sprite:Render(Isaac.WorldToScreen(tab.Pos), kZeroVector, kZeroVector)
		
		if tab.FrameCount >= 120*2 or (tab.IsRemoval and tab.FrameCount >= kItemIconsDisappearDuration)
				or (tab.FrameCount >= kItemIconsStartDuration and tab.Player.Position:Distance(tab.Pos) < 10) then
			itemIcons[k] = nil
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function() itemIcons = {} end)

-- MC_POST_PEFFECT_UPDATE
function mod:discPlayerUpdate(player)
	local itemConfig = Isaac.GetItemConfig()
	
	local wispRefs = GetDiscWispRefs()
	local activeDiscs = GetDiscData(player)
	
	for key, data in pairs(activeDiscs) do
		if data.Duration and data.Duration > 0 then
			data.Duration = data.Duration - 1
		end
		if not data.Duration or data.Duration == 0 then
			local itemsRemoved = false
			
			for wispKey, itemID in pairs(data.Wisps) do
				wispRefs[wispKey] = nil
				if player:HasCollectible(itemID) then
					ShowItemIcon(player, itemConfig:GetCollectible(itemID).GfxFileName, RandomVector():GetAngleDegrees(), true)
					itemsRemoved = true
				end
			end
			
			activeDiscs[key] = nil
			
			if itemsRemoved then
				sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
				game:GetHUD():ShowItemText("Your free trial has expired")
			end
		end
	end
end

---------- Item wisp handling ----------

function mod:discItemWispInit(wisp)
	if not wisp:GetData().isFfDiscWisp and GetDiscWispRefs()[""..wisp.InitSeed] then
		-- This wisp isn't marked as a disc wisp, but there's supposed to be a disc wisp with this InitSeed.
		-- Most likely, we've quit and continued a run. Re-initialize this as a disc wisp and hide it.
		if wispCache[wisp.InitSeed] and wispCache[wisp.InitSeed]:Exists() and wispCache[wisp.InitSeed]:GetData().isFfDiscWisp then
			-- Nevermind, found the existing wisp. (Likely Bazarus Moment.)
			wisp:Remove()
			return
		end
		InitializeDiscItemWisp(wisp)
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.discItemWispInit, FamiliarVariant.ITEM_WISP)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continuing)
	for _, wisp in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)) do
		mod:discItemWispInit(wisp:ToFamiliar())
	end
end)

function mod:discItemWispUpdate(wisp)
	local data = wisp:GetData()
	
	if not data.isFfDiscWisp then return end
	
	wisp.Position = Vector(-100, -50)
	wisp.Velocity = kZeroVector
	
	if not GetDiscWispRefs()[""..wisp.InitSeed] then
		-- This disc wisp should no longer exist.
		if wisp.Player and wisp.SubType == CollectibleType.COLLECTIBLE_MARS then
			wisp.Player:TryRemoveNullCostume(NullItemID.ID_MARS)
		end
		wisp:Remove()
		wisp:Kill()
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.discItemWispUpdate, FamiliarVariant.ITEM_WISP)

-- Disables collisions for disc wisps.
function mod:discItemWispCollision(wisp)
	if wisp:GetData().isFfDiscWisp then
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.discItemWispCollision, FamiliarVariant.ITEM_WISP)

-- Prevents disc wisps from taking damage.
function mod:discItemWispDamage(entity, damage, damageFlags, damageSourceRef, damageCountdown)
	if entity and entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.ITEM_WISP and entity:GetData().isFfDiscWisp then
		return false
	end
	
	if damageSourceRef.Type == EntityType.ENTITY_FAMILIAR and damageSourceRef.Variant == FamiliarVariant.ITEM_WISP
			and damageSourceRef.Entity and damageSourceRef.Entity:GetData().isFfDiscWisp then
		return false
	end
end

-- Prevents disc wisps from firing tears with book of virtues.
function mod:discItemWispTears(tear)
	if tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR
			and tear.SpawnerEntity.Variant == FamiliarVariant.ITEM_WISP
			and (tear.SpawnerEntity:GetData().isFfDiscWisp or tear.SpawnerEntity:GetData().preventWispFiring) then
		tear:Remove()
	end
end

---------------------------------------------
-- Spindle
---------------------------------------------

function mod.GetRandomDisc(rng)
	local disc = mod.ItemDiscs[rng:RandomInt(#mod.ItemDiscs)+1]
	if (disc == mod.ITEM.CARD.TAINTED_TREASURE_DISC and not TaintedCollectibles) or (disc == mod.ITEM.CARD.BROKEN_DISC and rng:RandomInt(2) == 0) then
		return GetRandomBasicDisc(rng)
	end
	return disc
end

-- Spawn 3 discs when Spindle is acquired.
mod.AddItemPickupCallback(function(player)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SPINDLE)
	for i=1,3 do
		local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 20) + mod:shuntedPosition(10, rng)
		local disc = mod.GetRandomDisc(rng) or mod.ITEM.CARD.TREASURE_DISC
		mod.scheduleForUpdate(function()
			local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 20) + mod:shuntedPosition(10, rng)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, disc, pos, kZeroVector, nil)
		end, i)
	end
end, nil, CollectibleType.COLLECTIBLE_SPINDLE)

-- Spindle spawns a disc in the boss room.
function mod:spindleNewRoom()
	local room = game:GetRoom()
	
	if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_BOSS then
		for i=0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(i)
			
			if player and player:Exists() and player:HasCollectible(CollectibleType.COLLECTIBLE_SPINDLE) then
				local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SPINDLE)
				for i=1, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SPINDLE) do
					local pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(0), 0, true)
					local disc = mod.GetRandomDisc(rng) or mod.ITEM.CARD.TREASURE_DISC
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, disc, pos, kZeroVector, nil)
				end
			end
		end
	end
end
