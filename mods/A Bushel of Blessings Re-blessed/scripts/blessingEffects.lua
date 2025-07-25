local json = require("json")  -- Make sure to point to the correct path if the json library is external

-- Constants for easier tweaking and readability(Isaac)
local BASE_CHANCE_FULL = 0.25
local BASE_CHANCE_MINI = 0.15
local EXTRA_PEDESTAL_CHANCE = 0.10
local LUCK_BONUS_PER_POINT = 0.02
local SOUL_ISAAC_CARD = Card.CARD_SOUL_ISAAC
local SOUL_PICKUP_SOUND = SoundEffect.SOUND_SOUL_PICKUP




-- Handles the Isaac's Blessing effect in new rooms
local function tryIsaacsBlessingEffect()
    local room = Game():GetRoom()
    if not room:IsFirstVisit() then return end

    local pedestalCount = 0
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            pedestalCount = pedestalCount + 1
        end
    end

    if pedestalCount == 0 then return end
    if not (persistent.isaac_blessing or persistent.isaac_blessing_mini) then return end

    local player = Isaac.GetPlayer()
    local luck = math.max(0, player.Luck)

    local baseChance = persistent.isaac_blessing and BASE_CHANCE_FULL or BASE_CHANCE_MINI
    local extraPedestals = math.max(0, pedestalCount - 1)
    local totalChance = baseChance + (EXTRA_PEDESTAL_CHANCE * extraPedestals) + (LUCK_BONUS_PER_POINT * luck)

    if math.random() < totalChance then
        player:UseCard(SOUL_ISAAC_CARD, 259)
        SFXManager():Play(SOUL_PICKUP_SOUND, 1.0, 0, false, 1.0)
    end
end

-- Cain's Blessing effect constants
local BASE_DOOR_UNLOCK_CHANCE = 0.25      -- 25%
local BASE_SOUL_OF_CAIN_CHANCE = 0.05     -- 5%
local DOOR_UNLOCK_LUCK_SCALE = 0.02       -- +2% per Luck
local SOUL_OF_CAIN_LUCK_SCALE = 0.01      -- +1% per Luck
local SOUL_CAIN_CARD = Card.CARD_SOUL_CAIN

local function tryUnlockDoor(door, chance)
    if math.random() < chance then
        door:SetLocked(false)
        door:Open()
    end
end


-- Applies Cain's Blessing effect when entering a new room
local function tryCainBlessingEffect()
    if not (persistent.cain_blessing or persistent.cain_blessing_secondary) then return end

    local game = Game()
    local level = game:GetLevel()
    local room = game:GetRoom()
    local roomDesc = level:GetCurrentRoomDesc()

    if not room:IsFirstVisit() then return end

    -- local print = function(...) end -- disable all prints if needed

    local player = Isaac.GetPlayer(0)
    local luck = player.Luck
    local doorUnlockChance = BASE_DOOR_UNLOCK_CHANCE + (luck * DOOR_UNLOCK_LUCK_SCALE)
    local soulOfCainChance = BASE_SOUL_OF_CAIN_CHANCE + (luck * SOUL_OF_CAIN_LUCK_SCALE)

    -- === DOOR UNLOCK ATTEMPT ===
    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(slot)
        if door then
            tryUnlockDoor(door, doorUnlockChance)
        end
    end
    

    -- === (Soul of Cain) ATTEMPT ===
        if math.random() < soulOfCainChance then
            -- print("Attempting Soul of Cain red room generation (silent)...")
            player:UseCard(SOUL_CAIN_CARD, 259)
            SFXManager():Play(SOUL_PICKUP_SOUND, 1.0, 0, false, 1.0)
        else
            -- print("Soul of Cain effect did not trigger this time.")
        end

end

-- Utility: Add max red heart containers
local function addRedHearts(player, count)
    for _ = 1, count do
        player:AddMaxHearts(2, false) -- 2 = 1 full red heart container
        player:AddHearts(2)
    end
end

local function tryMaggyBlessingEffect(amount)
    for _, player in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
        player = player:ToPlayer()
        addRedHearts(player, amount)
    end
end

local function handleMaggyBlessingOnRunStart()
    local amount = persistent.maggy_blessing
    if amount > 0 then
        tryMaggyBlessingEffect(amount)
        persistent.maggy_blessing = amount - 1
    end
end




-- Helper: Check if the player is Lost or Tainted Lost
local function isLostVariant(player)
    local variant = player:GetPlayerType()
    return variant == PlayerType.PLAYER_THELOST or variant == PlayerType.PLAYER_THELOST_B
end

-- Helper: Reduces the player's health to 1 heart of the most appropriate type
local function reduceToOneHeart(player)
    local hasBone = player:GetBoneHearts() > 0
    local hasSoul = player:GetSoulHearts() > 0
    local hasRed = player:GetMaxHearts() > 0

    -- Clear all health types
    player:AddMaxHearts(-player:GetMaxHearts(), false)
    player:AddHearts(-player:GetHearts())
    player:AddSoulHearts(-player:GetSoulHearts())
    player:AddBoneHearts(-player:GetBoneHearts())

    -- Give 1 heart of the most fitting type
    if hasBone then
        player:AddBoneHearts(1)
    elseif hasSoul or not hasRed then
        player:AddSoulHearts(2) -- 2 = 1 soul heart
    else
        player:AddMaxHearts(2, false)
        player:AddHearts(2)
    end
end

-- Helper: Get a random high-quality devil item or Brimstone as fallback
local function getRandomHighQualityDevilItem()
    local pool = Game():GetItemPool()
    local itemConfig = Isaac.GetItemConfig()
    local candidates = {}

    for _ = 1, 50 do
        local id = pool:GetCollectible(ItemPoolType.POOL_DEVIL, false)
        local config = itemConfig:GetCollectible(id)

        if config and config.Quality >= 3 and config.Type == ItemType.ITEM_PASSIVE then
            table.insert(candidates, id)
        end
    end

    if #candidates > 0 then
        local selectedId = candidates[math.random(#candidates)]
        pool:RemoveCollectible(selectedId)
        return selectedId
    else
        -- Brimstone fallback
        return CollectibleType.COLLECTIBLE_BRIMSTONE
    end
end

-- === Judas' Blessing Effect ===

-- === Judas' Blessing Effect ===
local function tryJudasBlessingEffect()
    -- Trigger only once per activation
    if persistent.judasBlessingTriggeredThisFrame then return end
    if not (persistent.judas_blessing or persistent.judas_blessing_secondary) then return end

    persistent.judasBlessingTriggeredThisFrame = true

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)

        -- Skip Lost and Tainted Lost
        if not isLostVariant(player) then
            reduceToOneHeart(player)
        end
            -- Give a strong Devil item or fallback to Brimstone
            local itemId = getRandomHighQualityDevilItem()
            if itemId and itemId > 0 then
                player:AddCollectible(itemId, 0, true)
            end
        
    end

    -- Advance blessing state
    if persistent.judas_blessing_secondary then
        persistent.judas_blessing_secondary = false
    elseif persistent.judas_blessing then 
        persistent.judas_blessing = false
        persistent.judas_blessing_secondary = true
    end

    mod:SaveData(json.encode(persistent))

end




--BlueBaby effect
local function tryBlueBabyChestSpawnEffect(pickup)
    if not (persistent.bluebaby_blessing or persistent.bluebaby_blessing_secondary) then return end

    -- Double-check variant
    local variant = pickup.Variant
    if variant ~= PickupVariant.PICKUP_LOCKEDCHEST then return end

    local config = Isaac.GetItemConfig()
    local itemId = math.random(1, #config:GetCollectibles())

    -- Remove the opened chest and replace with an item
    pickup:Remove()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemId, pickup.Position, Vector(0, 0), nil)
end



--==============================================================
-- Eve’s Blessing ─ 3-item Devil Room choice (no queues, no cycles)
--==============================================================
local function tryEveBlessingEffect()
    -- Abort if neither primary nor secondary blessing is active
    if not (persistent.eve_blessing or persistent.eve_blessing_secondary) then
        return
    end

    ------------------------------------------------------------
    -- Constants
    ------------------------------------------------------------
    local PED_COUNT         = 3                       -- Number of pedestals
    local PED_SPACING       = 80                      -- Horizontal distance between pedestals (pixels)
    local PED_OFFSET_Y      = -80                     -- Y offset from player (pixels)
    local OPTIONS_INDEX_EVE = 326                     -- Unique index for this choice set
    local ITEM_POOL_TYPE    = ItemPoolType.POOL_DEVIL -- Source pool: Devil Room

    ------------------------------------------------------------
    -- Shortcuts and setup
    ------------------------------------------------------------
    local game       = Game()
    local room       = game:GetRoom()
    local itemPool   = game:GetItemPool()
    local player     = Isaac.GetPlayer(0)
    local rng        = player:GetCollectibleRNG(1)
    local playerPos  = player.Position

    local roomWidth  = room:GetGridWidth()  * 40
    local roomHeight = room:GetGridHeight() * 40

    ------------------------------------------------------------
    -- Generate 3 unique Devil Room collectibles
    ------------------------------------------------------------
    local rolledIDs = {}

    while #rolledIDs < PED_COUNT do
        local id = itemPool:GetCollectible(ITEM_POOL_TYPE, true, rng:Next())

        local isDuplicate = false
        for _, existing in ipairs(rolledIDs) do
            if existing == id then
                isDuplicate = true
                break
            end
        end

        if not isDuplicate then
            table.insert(rolledIDs, id)
        end
    end

    ------------------------------------------------------------
    -- Spawn the collectible pedestals
    ------------------------------------------------------------
    for i = 1, PED_COUNT do
        local offsetX = (i - math.ceil(PED_COUNT / 2)) * PED_SPACING
        local pos     = playerPos + Vector(offsetX, PED_OFFSET_Y)

        -- Clamp to within room bounds
        pos.X = math.max(0, math.min(roomWidth, pos.X))
        pos.Y = math.max(0, math.min(roomHeight, pos.Y))

        local pedestal = Isaac.Spawn(
            EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_COLLECTIBLE,
            rolledIDs[i],
            pos,
            Vector.Zero,
            nil
        ):ToPickup()

        pedestal.OptionsPickupIndex = OPTIONS_INDEX_EVE
    end

    ------------------------------------------------------------
    -- Flip the persistent blessing flags
    ------------------------------------------------------------
    if persistent.eve_blessing_secondary then
        persistent.eve_blessing_secondary = false
    elseif persistent.eve_blessing then
        persistent.eve_blessing = false
        persistent.eve_blessing_secondary = true
    end

    -- Save state
    mod:SaveData(json.encode(persistent))
end






local function tryAzazelBlessingEffect(tear)
    if not (persistent.azazel_blessing or persistent.azazel_blessing_secondary) then return end
    local rng = RNG()

    local player = tear.SpawnerEntity:ToPlayer()
    if not player then return end

    -- Use seeded RNG for consistency
    rng:SetSeed(tear.InitSeed, 35)
    local chance = rng:RandomFloat()

    if chance <= 0.10 then
        -- Remove the original tear
        tear:Remove()

        -- Get the velocity and snap to cardinal direction
        local angle = tear.Velocity:GetAngleDegrees()
        local snapAngle = 0

        if angle >= -45 and angle < 45 then
            snapAngle = 0    -- Right
        elseif angle >= 45 and angle < 135 then
            snapAngle = 90   -- Down
        elseif angle >= 135 or angle < -135 then
            snapAngle = 180  -- Left
        else
            snapAngle = 270  -- Up
        end

        -- Fire the brimstone laser
        local laser = EntityLaser.ShootAngle(
            LaserVariant.THICK_RED,            -- Laser type
            player.Position,                   -- Start position
            snapAngle,                         -- Snap to 0/90/180/270 degrees
            10,                                -- Duration (frames)
            Vector(0, -10),                    -- Offset
            player                             -- Parent entity
        )

        -- Inherit tear effects from the player
        laser:AddTearFlags(player.TearFlags)
        laser.CollisionDamage = player.Damage * 2

        -- Optional: make it visually nice
        laser:SetColor(Color(1, 0, 0, 1, 0, 0, 0), -1, 1, false, false)
    end
end


-- Lazarus trinket gulping
local function tryLazarusTrinketGive()
    local itemPool = Game():GetItemPool()
    local numPlayers = Game():GetNumPlayers()

    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)

        -- Get a random trinket and give it to the player
        local trinket = itemPool:GetTrinket()
        player:AddTrinket(trinket)

        -- Gulp the trinket using Smelter active effect (true last param = ignore item charge)
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false)
    end
end

-- lost blessing
local function tryLostBlessingEffect()
    local game = Game()
    local room = game:GetRoom()

    if not room:IsFirstVisit() then return end

    if not (persistent and (persistent.lost_blessing or persistent.lost_blessing_secondary)) then return end

    local numPlayers = game:GetNumPlayers()

    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)
        if player then
            -- math.random returns integer, so math.random() < 0.15 doesn't work directly.
            -- Use math.random(1, 100) <= 15 to simulate 15% chance.
            if math.random(1, 100) <= 15 then
                player:UseCard(Card.CARD_HOLY, 0)
                SFXManager():Play(SoundEffect.SOUND_HOLY_CARD, 1.0, 0, false, 1.0)
            end
        end
    end
end




local function tryKeepersBlessingEffect()
    if not (persistent.keepers_blessing or persistent.keepers_blessing_secondary) then return end

    local rng = RNG()
    rng:SetSeed(Random(), 35)
    local player = Isaac.GetPlayer()
    local room = Game():GetRoom()
    local level = Game():GetLevel()



    if not room:IsFirstVisit() then return end

    -- 33% chance per room to spawn coins
    if rng:RandomFloat() <= 0.33 then
        local numCoins = rng:RandomInt(3) + 1 -- 1 to 3 coins
        for i = 1, numCoins do
            local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pos, Vector.Zero, nil)
        end
    end
end




local function tryLilithBlessingEffect()
    local babyItems = {}
    local rng = RNG()
    rng:SetSeed(Random(), 35)  -- Seed once at mod startup or in 
    local player = Isaac.GetPlayer()

    -- Gather all TAG_BABY collectibles the player doesn't already have
    for itemID = 1, CollectibleType.NUM_COLLECTIBLES - 1 do
        local config = Isaac.GetItemConfig():GetCollectible(itemID)
        if config 
            and config:HasTags(ItemConfig.TAG_BABY) 
            and not player:HasCollectible(itemID, true) then  -- includes all item forms
            table.insert(babyItems, itemID)
        end
    end

    -- Pick one at random and give it
    if #babyItems > 0 then
        local randomIndex = rng:RandomInt(#babyItems) + 1
        player:AddCollectible(babyItems[randomIndex])
    end
end

local function tryApollyonBlessingEffect()
    if not (persistent.apollyon_blessing or persistent.apollyon_blessing_secondary) then return end
    local abyssLocustID = FamiliarVariant.ABYSS_LOCUST
    local player = Isaac.GetPlayer()
    local itemID = 477 --Void

    -- Check if the pocket slot is valid and empty
    if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == CollectibleType.COLLECTIBLE_NULL then
        player:AddCollectible(itemID, 0, false, ActiveSlot.SLOT_POCKET)
    else
        -- Pocket is occupied or doesn't exist, use main active slot instead
        player:AddCollectible(itemID, 0, false, ActiveSlot.SLOT_PRIMARY)
    end
    -- Number of familiars to spawn
    local numLocusts = 2
    local player = Isaac.GetPlayer(0)
    
    for i = 1, numLocusts do
        local offset = Vector(i * 40, 0)
        local abyssLocust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, 0, player.Position + offset, Vector(0, 0), nil)
        abyssLocust:GetData().isPermanent = true
    end

    if persistent.apollyon_blessing_secondary then
        persistent.apollyon_blessing_secondary = false
    elseif persistent.apollyon_blessing then
        persistent.apollyon_blessing = false
        persistent.apollyon_blessing_secondary = true
    end

    -- Save state
    mod:SaveData(json.encode(persistent))
end

local function tryForgottenBlessingEffect()
    if not (persistent.forgotten_blessing or persistent.forgotten_blessing_secondary) then return end

    local numBones = 5
    local player = Isaac.GetPlayer()
    local room = Game():GetRoom()
    if not room:IsFirstVisit() then return end

    for i = 1, numBones do
        local bone = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, player.Position, Vector.Zero, player):ToFamiliar()

        -- Prevent spawn animation
        bone:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

        -- Randomize orbit direction: 1 for normal, -1 for reverse
        local direction = (math.random(0, 1) == 0) and 1 or -1

        -- Orbit settings
        local orbitDistance = 40
        local orbitLayer = i -- Stagger to avoid stacking

        bone.OrbitDistance = Vector(orbitDistance, orbitDistance)
        bone.OrbitSpeed = 0.05 * direction
        bone:AddToOrbit(orbitLayer)
        bone:FollowParent()

        -- Offset the spawn position around the circle by a random angle
        local angle = math.random() * 360
        local radians = angle * math.pi / 180
        local offset = Vector(math.cos(radians), math.sin(radians)) * orbitDistance
        bone.Position = player.Position + offset

        -- Apply velocity to initiate movement
        bone.Velocity = bone:GetOrbitPosition(player.Position) - bone.Position
    end
end

local RandomWispToSpawn = nil  -- This will store the chosen active item ID

-- @return integer[] A table of all active item IDs
local function GetAllActiveItems()
    local activeItems = {}

    for id = 1, CollectibleType.NUM_COLLECTIBLES - 1 do
        local configItem = Isaac.GetItemConfig():GetCollectible(id)
        if configItem and configItem.Type == ItemType.ITEM_ACTIVE then
            table.insert(activeItems, id)
        end
    end

    return activeItems
end

-- Picks a random active item and stores its ID in RandomWispToSpawn
local function ChooseRandomActiveItem()
    local activeItems = GetAllActiveItems()
    if #activeItems > 0 then
        RandomWispToSpawn = activeItems[math.random(1, #activeItems)]
    else
        RandomWispToSpawn = nil
    end
end

local function tryBethanyBlessingEffect()
    if not (persistent.bethany_blessing or persistent.bethany_blessing_secondary) then return end

    local player = Isaac.GetPlayer()
    local room = Game():GetRoom()
    if not room:IsFirstVisit() then return end

    ChooseRandomActiveItem()
    local rng = RNG()
    rng:SetSeed(Random() + player.InitSeed, 35)  -- Seed for consistent randomness per room
    local roll = rng:RandomFloat()  -- Returns 0.0 to <1.0

    if roll < 0.6 then
        -- 60% chance: spawn a basic wisp (no item)
        player:AddWisp(CollectibleType.COLLECTIBLE_NULL, player.Position)

    elseif roll < 0.9 then
        -- 30% chance: spawn a wisp with RandomWispToSpawn
        if RandomWispToSpawn then
            player:AddWisp(RandomWispToSpawn, player.Position)
        else
            -- Fallback: plain wisp if none assigned
            player:AddWisp(CollectibleType.COLLECTIBLE_NULL, player.Position)
        end

    else
        -- 10% lemegeton wisp
        player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMEGETON, false, true, true, false, -1, 0)    
    end
end










-- Callbacks for Blessings
return {
    tryIsaacsBlessingEffect = tryIsaacsBlessingEffect,
    tryCainBlessingEffect = tryCainBlessingEffect,
    tryMaggyBlessingEffect = tryMaggyBlessingEffect,
    handleMaggyBlessingOnRunStart = handleMaggyBlessingOnRunStart,
    tryJudasBlessingEffect = tryJudasBlessingEffect,
    tryBlueBabyChestSpawnEffect = tryBlueBabyChestSpawnEffect,
    tryEveBlessingEffect = tryEveBlessingEffect,
    tryAzazelBlessingEffect = tryAzazelBlessingEffect,
    tryLazarusTrinketGive = tryLazarusTrinketGive,
    tryLostBlessingEffect = tryLostBlessingEffect,
    tryKeepersBlessingEffect = tryKeepersBlessingEffect,
    tryLilithBlessingEffect = tryLilithBlessingEffect,
    tryApollyonBlessingEffect = tryApollyonBlessingEffect,
    tryForgottenBlessingEffect = tryForgottenBlessingEffect,
    tryBethanyBlessingEffect = tryBethanyBlessingEffect,
}





