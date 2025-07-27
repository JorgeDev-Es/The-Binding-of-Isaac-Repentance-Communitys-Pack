local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

------------------------------------------------------------
---- Item Choice

-- Chance for the Broken Record to replace an item.
local BROKEN_RECORD_REPLACEMENT_CHANCE = 0.3

-- If any player has Broken Record, returns a random stackable item from any of those players.
local function PickBrokenRecordItem()
	local players = {}
	local rng
	
	local mult = 0
	
	for p=0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(p)
		if player and player:Exists() and player:HasTrinket(mod.ITEM.TRINKET.BROKEN_RECORD) then
			if not rng then
				rng = player:GetTrinketRNG(mod.ITEM.TRINKET.BROKEN_RECORD)
			end
			mult = math.max(mult, player:GetTrinketMultiplier(mod.ITEM.TRINKET.BROKEN_RECORD))
			table.insert(players, player)
		end
	end
	
	local chance = BROKEN_RECORD_REPLACEMENT_CHANCE * mult
	
	if #players == 0 or not rng or chance == 0 or rng:RandomFloat() > chance then
		return
	end
	
	local candidates = {}
	
	for id, _ in pairs(mod:GetStackableItemsTable()) do
		for _, player in ipairs(players) do
			if player:HasCollectible(id, true) then
				table.insert(candidates, id)
				break
			end
		end
	end
	
	return candidates[rng:RandomInt(#candidates)+1]
end

------------------------------------------------------------
---- Visual Effects

local function GetItemGfx(id)
	local item = Isaac.GetItemConfig():GetCollectible(id)
	if not item then return end
	local gfx = item.GfxFileName
	if gfx ~= "" then
		return gfx
	end
end

-- Resets an item pedestal's sprite to match its current SubType, respecting Curse of the Blind.
local function ReloadItemSprite(pickup)
	if game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND ~= 0 then
		pickup:GetSprite():ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
		pickup:GetSprite():LoadGraphics()
		return
	end
	local gfx = GetItemGfx(pickup.SubType)
	if gfx then
		pickup:GetSprite():ReplaceSpritesheet(1, gfx)
		pickup:GetSprite():LoadGraphics()
	end
end

-- Ongoing visual effects for items being replaced.
local brokenRecordEffects = {}
-- Effects that haven't triggered yet (waiting for pickup update).
local queuedBrokenRecordEffects = {}

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	brokenRecordEffects = {}
end)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	queuedBrokenRecordEffects = {}
end)

-- Render the visual effect.
local function DoRender(data)
	if data.LastUpdate >= Isaac.GetFrameCount() then return end
	
	local sprite = data.Sprite
	local renderPos = Isaac.WorldToScreen(data.Pos)
	local frame = math.floor(data.Frame)
	
	if frame >= 12 then
		brokenRecordEffects[data.Seed] = nil
		return
	end
	
	local height = 32 / frame
	
	local y = 0
	if sprite:GetAnimation() == "Idle" and data.IsMorphed then
		y = -8
	end
	
	for i=0, frame-1 do
		local start = i * height
		local x = (2 + ((data.Seed % 256) + i + start) % 3) * (frame-1) * 0.5
		if i % 2 == 0 then
			x = x * -1
		end
		sprite:Render(renderPos + Vector(x, y), Vector(0, start), Vector(0, 32 - (start + height)))
	end
	
	if not game:IsPaused() then
		data.Frame = (data.Frame or 1) + 0.3334
	end
	
	data.LastUpdate = Isaac.GetFrameCount()
end

-- Triggers the rendering of the visual effect after the pedestal's render.
function mod:brokenRecordRender(pickup)
	local data = brokenRecordEffects[pickup.InitSeed]
	if not data then return end
	
	data.FoundEntity = true
	
	local anim = pickup.Price == 0 and "Idle" or "ShopIdle"
	if anim ~= data.Sprite:GetAnimation() then
		data.Sprite:Play(anim, true)
	end
	data.Pos = pickup.Position
	
	DoRender(data)
	
	if not game:IsPaused() and not data.PlayedSound then
		sfx:Play(mod.Sounds.BrokenDisc)
		pickup:SetColor(Color(1,1,1,1,0.85,0.85,0.85), 12, 1, true, true)
		data.PlayedSound = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, mod.brokenRecordRender, PickupVariant.PICKUP_COLLECTIBLE)

-- If a visual effect wasn't updated on its corresponding pickup's MC_POST_PICKUP_RENDER, see about updating it here.
function mod:brokenRecordRenderSprites()
	local currentFrame = Isaac.GetFrameCount()
	for k, data in pairs(brokenRecordEffects) do
		if data.LastUpdate < Isaac.GetFrameCount() then
			if data.Force or data.FoundEntity then
				-- We did find the entity at some point, so just continue on without it.
				DoRender(data)
			else
				-- See if we can find the corresponding pickup.
				local pickup
				for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
					if ent.InitSeed == k then
						pickup = ent:ToPickup()
						break
					end
				end
				if pickup then
					-- We found it. It's not updating for some reason, but that's fine.
					-- Start the animation anyway.
					mod:brokenRecordRender(pickup)
					data.FoundEntity = true
				end
				-- If we didn't find the pickup, it might be hidden temporarily (some room layouts do this).
				-- Just wait until it shows up.
			end
		end
	end
end

-- Queue up the visual effect for item replacement.
function mod:playBrokenRecordVisualEffect(pickup, oldItem, isMorphed, force)
	-- Don't bother if curse of the blind is active.
	if game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND ~= 0 then return end
	
	local gfx = GetItemGfx(oldItem)
	local sprite = Sprite()
	sprite:Load("gfx/005.100_collectible.anm2", false)
	sprite:Play("Idle", true)
	sprite:ReplaceSpritesheet(1, gfx)
	sprite:LoadGraphics()
	
	brokenRecordEffects[pickup.InitSeed] = {
		Sprite = sprite,
		Frame = 1,
		Seed = pickup.InitSeed,
		Pos = pickup.Position,
		LastUpdate = 0,
		IsMorphed = isMorphed,
		Force = force,
	}
end

------------------------------------------------------------
---- Detecting items from chests

-- How many additional frames to keep information on pickups for morph-tracking purposes.
-- I needed one additional frame for Mega Chests, apparantly.
local MORPH_DETECTION_BUFFER = 1

-- Table of non-collectible pickups, for use in identifying when a non-collectible pickup morphs
-- into a collectible (IE, when you get an item from a chest).
local nonCollectiblePickups = {}

-- Returns true if this item pedestal morphed from a different pickup within the last frame.
-- For use on MC_POST_PICKUP_INIT.
local function WasMorphed(pickup)
	if pickup.Type ~= EntityType.ENTITY_PICKUP or pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then return end
	local data = nonCollectiblePickups[pickup.Position.X] and nonCollectiblePickups[pickup.Position.X][pickup.Position.Y]
	if data and data.Pointer and data.Pointer.Ref then
		return GetPtrHash(data.Pointer.Ref) == GetPtrHash(pickup)
	end
end

-- Track non-collectible pickups to try to detect if they morph into items.
function mod:brokenRecordTrackNonCollectiblePickups(pickup)
	if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
		if not nonCollectiblePickups[pickup.Position.X] then
			nonCollectiblePickups[pickup.Position.X] = {}
		end
		nonCollectiblePickups[pickup.Position.X][pickup.Position.Y] = {
			Pointer = EntityPtr(pickup),
			Added = game:GetFrameCount(),
		}
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.brokenRecordTrackNonCollectiblePickups)

------------------------------------------------------------
---- Detecting normal item pedestal spawns

local itemSpawnedFromPool = {}
local itemSpawnedWithSeed = {}

-- Detect that an item was chosen from a pool this frame.
function mod:brokenRecordPostGetCollectible(itemType, itemPool, decrease)
	if decrease and itemPool and itemPool ~= -1 then
		itemSpawnedFromPool[itemType] = itemPool
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, mod.brokenRecordPostGetCollectible)

-- Detect that an item pedestal entity spawned this frame.
local function CheckSpawn(id, variant, subtype, seed)
	if id == EntityType.ENTITY_PICKUP and (variant == PickupVariant.PICKUP_COLLECTIBLE or variant == PickupVariant.PICKUP_SHOPITEM) then
		itemSpawnedWithSeed[seed] = true
	end
end

function mod:brokenRecordPreSpawn(id, variant, subType, pos, vel, spawner, seed)
	CheckSpawn(id, variant, subtype, seed)
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.brokenRecordPreSpawn)

function mod:brokenRecordPreRoomSpawn(id, variant, subType, gridIdx, seed)
	CheckSpawn(id, variant, subtype, seed)
end
mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, mod.brokenRecordPreRoomSpawn)

-- On pedestal init, if we've detected that this item was chosen from a pool this frame,
-- AND that the item pedestal itself was first spawned this frame, then this is a new
-- item spawn that should be safe to replace.
function mod:brokenRecordPedestalInit(pickup)
	local itemType = pickup.SubType
	
	local isMorphed = WasMorphed(pickup)
	
	--[[print("MC_POST_PICKUP_INIT: " .. pickup.SubType .. " @ " .. game:GetFrameCount())
	print(itemSpawnedFromPool[itemType] or "NOPOOL")
	print(itemSpawnedWithSeed[pickup.InitSeed] and "SPAWNED" or "NOT_SPAWNED")
	print("MORPHED: " .. (isMorphed and "TRUE" or "FALSE"))]]
	
	if itemSpawnedFromPool[itemType] and (itemSpawnedWithSeed[pickup.InitSeed] or isMorphed) then
		local newItem = PickBrokenRecordItem()
		if newItem then
			-- Trigger the visual effects on the pedestal's first update.
			queuedBrokenRecordEffects[pickup.InitSeed] = {
				OldItem = pickup.SubType,
				IsMorphed = isMorphed,
			}
			pickup.SubType = newItem
		end
		itemSpawnedWithSeed[pickup.InitSeed] = nil
		itemSpawnedFromPool[itemType] = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.brokenRecordPedestalInit, PickupVariant.PICKUP_COLLECTIBLE)

-- When an item was replaced on its init, trigger the visual effects on the first available update.
-- Waiting until update helps circumvent a few visual oddities, such as room transitions.
function mod:brokenRecordPedestalUpdate(pickup)
	if game:IsPaused() then return end
	local data = queuedBrokenRecordEffects[pickup.InitSeed]
	if data then
		ReloadItemSprite(pickup)
		mod:playBrokenRecordVisualEffect(pickup, data.OldItem, data.IsMorphed)
		queuedBrokenRecordEffects[pickup.InitSeed] = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.brokenRecordPedestalUpdate, PickupVariant.PICKUP_COLLECTIBLE)

-- Clear tables at the end of each frame.
function mod:brokenRecordPostUpdate()
	local currentFrame = game:GetFrameCount()
	for x, subTab in pairs(nonCollectiblePickups) do
		for y, data in pairs(subTab) do
			if currentFrame - data.Added >= MORPH_DETECTION_BUFFER then
				subTab[y] = nil
			end
		end
		if next(subTab) == nil then
			nonCollectiblePickups[x] = nil
		end
	end
	itemSpawnedFromPool = {}
	itemSpawnedWithSeed = {}
end
