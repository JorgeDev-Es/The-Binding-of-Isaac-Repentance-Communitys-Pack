local json = require("json")

local mod = RegisterMod("Stackable Items Mod v2", 1)

-- Mod Config Menu Support
local MOD_NAME = "Stackable Items Mod v2"
local VERSION = "2.2.0"

local settings = {
    cursed_eye = true,
    car_battery = true,
    loki_horns = true,
    isaacs_tomb = true,
    heartbreak = true,
    giant_cell = true,
    xray_vision = true,
    guppys_tail = true,
    cracked_orb = true,
    card_reading = true,
    infestation = true,
    infestation_two = true,
    schoolbag = true,
    stairway = true,
    eye_sores = true,
    jumper_cables = true,
    empty_heart = true,
    nine_volt = true,
    lusty_blood = true,
    bloody_lust = true,
    bloody_gust = true,
    scapular = true,
    gnawed_leaf = true,
    linger_bean = true,
    godhead = true,
    number_two = true,
    tiny_planet = true,
    serpents_kiss = true,
    mysterious_liquid = true,
    hungry_soul = true,
    anemic = true,
    pupula_duplex = true,
    spoon_bender = true,
    toxic_shock = true,
    spelunker_hat = true,
    phd = true,
    virgo = true,
    lucky_foot = true,
    lump_of_coal = true,
    chocolate_milk = true,
    flat_stone = true,
    moms_purse = true,
    ball_of_tar = true,
    aquarius = true,
    bobs_curse = true,
    monstrance = true,
    bffs = true,
    vengeul_spirit = true,
    purgatory = true,
    hive_mind = true,
    bone_spurs = true,
    pound_of_flesh = true,
    dead_bird = true,
    fanny_pack = true,
    mr_mega = true,
    money_equals_power = true,
    eye_drops = true,
    birds_eye = true,
    ghost_pepper = true,
    whore_of_babylon = true,
    brittle_bones = true,
    trisagion = true,
}

local translation = {
    cursed_eye = "Cursed Eye",
    car_battery = "Car Battery",
    loki_horns = "Loki Horns",
    isaacs_tomb = "Isaacs Tomb",
    heartbreak = "Heartbreak",
    giant_cell = "Giant Cell",
    xray_vision = "Xray Vision",
    guppys_tail = "Guppys Tail",
    cracked_orb = "Cracked Orb",
    card_reading = "Card Reading",
    infestation = "Infestation",
    infestation_two = "Infestation Two",
    schoolbag = "Schoolbag", -- 🚫 Fix: Active item does not disappear when moving item to pocket slot
    stairway = "Stairway",
    eye_sores = "Eye Sores",
    jumper_cables = "Jumper Cables",
    empty_heart = "Empty Heart",
    nine_volt = "Nine Volt",
    lusty_blood = "Lusty Blood", -- 🚫
    bloody_lust = "Bloody Lust", -- 🚫
    bloody_gust = "Bloody Gust", -- 🚫
    scapular = "Scapular",
    gnawed_leaf = "Gnawed Leaf",
    linger_bean = "Linger Bean",
    godhead = "Godhead",
    number_two = "No. 2", -- 🚫
    tiny_planet = "Tiny Planet",
    serpents_kiss = "Serpent's Kiss",
    ----------
    mysterious_liquid = "Mysterious Liquid",
    hungry_soul = "Hungry Soul",
    anemic = "Anemic",
    pupula_duplex = "Pupula Duplex",
    spoon_bender = "Spoon Bender",
    toxic_shock = "Toxic Shock",
    spelunker_hat = "Spelunker Hat",
    phd = "PHD",
    virgo = "Virgo",
    lucky_foot = "Lucky Foot",
    lump_of_coal = "Lump of Coal",
    chocolate_milk = "Chocolate Milk",
    flat_stone = "Flat Stone",
    moms_purse = "Mom's Purse",
    ball_of_tar = "Ball of Tar",
    aquarius = "Aquarius",
    bobs_curse = "Bob's Curse",
    monstrance = "Monstrance",
    bffs = "BFFS!",
    vengeul_spirit = "Vengeful Spirit",
    purgatory = "Purgatory",
    hive_mind = "Hive Mind",
    bone_spurs = "Bone Spurs",
    pound_of_flesh = "Pound Of Flesh",
    dead_bird = "Dead Bird",
    fanny_pack = "Fanny Pack",
    mr_mega = "Mr Mega",
    money_equals_power = "Money = Power",
    eye_drops = "Eye Drops",
    birds_eye = "Bird's Eye",
    ghost_pepper = "Ghost Pepper",
    whore_of_babylon = "Whore of Babylon",
    brittle_bones = "Brittle Bones",
    trisagion = "Trisagion",
}

function mod:setupMyModConfigMenuSettings()
    if ModConfigMenu == nil then
        return
    end

    local function save()
        local jsonString = json.encode(settings)
        mod:SaveData(jsonString)
    end

    local function load()
        if not mod:HasData() then
            return
        end
        local jsonString = mod:LoadData()
        settings = json.decode(jsonString)
    end

    ModConfigMenu.AddSpace(MOD_NAME, "Info")
    ModConfigMenu.AddText(MOD_NAME, "Info", function() return MOD_NAME end)
    ModConfigMenu.AddSpace(MOD_NAME, "Info")
    ModConfigMenu.AddText(MOD_NAME, "Info", function() return "Version " .. VERSION end)

    for item, name in pairs(translation) do
        ModConfigMenu.AddSetting(
        "Stackable Items Mod v2",
        "Items",
        {
            Type = ModConfigMenu.OptionType.BOOLEAN,
            CurrentSetting = function()
                return item
            end,
            Display = function()
                return name .. " Stacking: " .. (item and "on" or "off")
            end,
            OnChange = function(b)
                item = b
                save()
            end,
            Info = {
                "Enables/disables stacking for " .. name
            }
        }
    )
    end
    load()
end


-- Items
local CursedEyeItem = CollectibleType.COLLECTIBLE_CURSED_EYE
local CarBatteryItem = CollectibleType.COLLECTIBLE_CAR_BATTERY
local LokiHornsItem = CollectibleType.COLLECTIBLE_LOKIS_HORNS
local IsaacTombItem = CollectibleType.COLLECTIBLE_ISAACS_TOMB
local HeartbreakItem = CollectibleType.COLLECTIBLE_HEARTBREAK
local GiantCellItem = CollectibleType.COLLECTIBLE_GIANT_CELL
local XRayVisionItem = CollectibleType.COLLECTIBLE_XRAY_VISION
local GuppyTailItem = CollectibleType.COLLECTIBLE_GUPPYS_TAIL
local CrackedOrbItem = CollectibleType.COLLECTIBLE_CRACKED_ORB
local CardReadingItem = CollectibleType.COLLECTIBLE_CARD_READING
local InfestationItem = CollectibleType.COLLECTIBLE_INFESTATION
local InfestationTwoItem = CollectibleType.COLLECTIBLE_INFESTATION_2
local SchoolbagItem = CollectibleType.COLLECTIBLE_SCHOOLBAG
local StairwayItem = CollectibleType.COLLECTIBLE_STAIRWAY
local EyeSoresItem = CollectibleType.COLLECTIBLE_EYE_SORE
local JumperCablesItem = CollectibleType.COLLECTIBLE_JUMPER_CABLES
local EmptyHeartItem = CollectibleType.COLLECTIBLE_EMPTY_HEART
local NineVoltItem = CollectibleType.COLLECTIBLE_9_VOLT
local LustyBloodItem = CollectibleType.COLLECTIBLE_LUSTY_BLOOD
local BloodyLustItem = CollectibleType.COLLECTIBLE_BLOODY_LUST
local BloodyGustItem = CollectibleType.COLLECTIBLE_BLOODY_GUST
local ScapularItem = CollectibleType.COLLECTIBLE_SCAPULAR
local GnawedLeafItem = CollectibleType.COLLECTIBLE_GNAWED_LEAF
local LingerBeanItem = CollectibleType.COLLECTIBLE_LINGER_BEAN
local GodHeadItem = CollectibleType.COLLECTIBLE_GODHEAD
local NumberTwoItem = CollectibleType.COLLECTIBLE_NUMBER_TWO
local TinyPlanetItem = CollectibleType.COLLECTIBLE_TINY_PLANET
local SerpentsKissItem = CollectibleType.COLLECTIBLE_SERPENTS_KISS
local MysteriousLiquidItem = CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID
local HungrySoulItem = CollectibleType.COLLECTIBLE_HUNGRY_SOUL
local AnemicItem = CollectibleType.COLLECTIBLE_ANEMIC
local PupulaDuplexItem = CollectibleType.COLLECTIBLE_PUPULA_DUPLEX
local SpoonBenderItem = CollectibleType.COLLECTIBLE_SPOON_BENDER
local ToxicShockItem = CollectibleType.COLLECTIBLE_TOXIC_SHOCK
local SpelunkerHatItem = CollectibleType.COLLECTIBLE_SPELUNKER_HAT
local PHDItem = CollectibleType.COLLECTIBLE_PHD
local VirgoItem = CollectibleType.COLLECTIBLE_VIRGO
local LuckyFootItem = CollectibleType.COLLECTIBLE_LUCKY_FOOT
local LumpOfCoalItem = CollectibleType.COLLECTIBLE_LUMP_OF_COAL
local ChocolateMilkItem = CollectibleType.COLLECTIBLE_CHOCOLATE_MILK
local FlatStoneItem = CollectibleType.COLLECTIBLE_FLAT_STONE
local MomsPurseItem = CollectibleType.COLLECTIBLE_MOMS_PURSE
local BallOfTarItem = CollectibleType.COLLECTIBLE_BALL_OF_TAR
local AquariusItem = CollectibleType.COLLECTIBLE_AQUARIUS
local BobsCurseItem = CollectibleType.COLLECTIBLE_BOBS_CURSE
local MonstranceItem = CollectibleType.COLLECTIBLE_MONSTRANCE
local BFFSItem = CollectibleType.COLLECTIBLE_BFFS
local VengefulSpiritItem = CollectibleType.COLLECTIBLE_VENGEFUL_SPIRIT
local PurgatoryItem = CollectibleType.COLLECTIBLE_PURGATORY
local HiveMindItem = CollectibleType.COLLECTIBLE_HIVE_MIND
local BoneSpursItem = CollectibleType.COLLECTIBLE_BONE_SPURS
local PoundOfFleshItem = CollectibleType.COLLECTIBLE_POUND_OF_FLESH
local DeadBirdItem = CollectibleType.COLLECTIBLE_DEAD_BIRD
local FannyPackItem = CollectibleType.COLLECTIBLE_FANNY_PACK
local MrMegaItem = CollectibleType.COLLECTIBLE_MR_MEGA
local MoneyEqualsPowerItem = CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER
local EyeDropsItem = CollectibleType.COLLECTIBLE_EYE_DROPS
local BirdsEyeItem = CollectibleType.COLLECTIBLE_BIRDS_EYE
local GhostPepperItem = CollectibleType.COLLECTIBLE_GHOST_PEPPER
local WhoreOfBabylonItem = CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON
local BrittleBonesItem = CollectibleType.COLLECTIBLE_BRITTLE_BONES
local TrisagionItem = CollectibleType.COLLECTIBLE_TRISAGION
---
local BrimstoneItem = CollectibleType.COLLECTIBLE_BRIMSTONE
local TechnologyItem = CollectibleType.COLLECTIBLE_TECHNOLOGY
local MomsBottleOfPillsItem = CollectibleType.COLLECTIBLE_MOMS_BOTTLE_OF_PILLS

local itemsDescriptions = {
    ["cursed_eye"] = {CursedEyeItem, "{{ColorRainbow}}Fires an additional wave of tears{{ColorRainbow}}"},
    ["car_battery"] = {CarBatteryItem, "{{ColorRainbow}}Will trigger its effect an extra time{{ColorRainbow}}"},
    ["loki_horns"] = {LokiHornsItem, "{{ColorRainbow}}25% + 5% {{Luck}} chance of firing 4 additional diagonal tears{{ColorRainbow}}"},
    ["isaacs_tomb"] = {IsaacTombItem, "{{ColorRainbow}}Spawns an extra {{DirtyChest}} Old Chest{{ColorRainbow}}"},
    ["heartbreak"] = {HeartbreakItem, "{{ColorRainbow}}Gives extra damage for each broken heart{{ColorRainbow}}"},
    ["giant_cell"] = {GiantCellItem, "{{ColorRainbow}}Spawns an extra Minisaac{{ColorRainbow}}"},
    ["xray_vision"] = {XRayVisionItem, "{{ColorRainbow}}Opens Boss Rush and Hush entrance{{ColorRainbow}}"},
    ["guppys_tail"] = {GuppyTailItem, "{{ColorRainbow}}33% chance to spawn an extra chest {{Luck}} 100% chance at 10 luck{{ColorRainbow}}"},
    ["cracked_orb"] = {CrackedOrbItem, "{{ColorRainbow}}Uses Soul of Cain effect on hit(Opens all red rooms available){{ColorRainbow}}"},
    ["card_reading"] = {CardReadingItem, "{{ColorRainbow}}Spawns all three portals{{ColorRainbow}}"},
    ["infestation"] = {InfestationItem, "{{ColorRainbow}}Spawns additional blue flies{{ColorRainbow}}"},
    ["infestation_two"] = {InfestationTwoItem, "{{ColorRainbow}}Spawns an additional blue spider{{ColorRainbow}}"},
    ["schoolbag"] = {SchoolbagItem, "{{ColorRainbow}}Moves current active item to pocket slot{{ColorRainbow}}"},
    ["stairway"] = {StairwayItem, "{{ColorRainbow}}Ladder does not disappear after leaving the room{{ColorRainbow}}"},
    ["eye_sores"] = {EyeSoresItem, "{{ColorRainbow}}Fires an additional tear in a random direction{{ColorRainbow}}"},
    ["jumper_cables"] = {JumperCablesItem, "{{ColorRainbow}}Adds an additional charge every 7 kills{{ColorRainbow}}"},
    ["empty_heart"] = {EmptyHeartItem, "{{ColorRainbow}}Adds an additional empty heart when triggered{{ColorRainbow}}"},
    ["nine_volt"] = {NineVoltItem, "{{ColorRainbow}}Grants an additional bar of charge when item is activated{{ColorRainbow}}"},
    ["lusty_blood"] = {LustyBloodItem, "{{ColorRainbow}}Damage bonus can be obtained 5 more times{{ColorRainbow}}"},
    ["bloody_lust"] = {BloodyLustItem, "{{ColorRainbow}}Damage bonus increased for each hit{{ColorRainbow}}"},
    ["bloody_gust"] = {BloodyGustItem, "{{ColorRainbow}}Tear bonus increased for each hit{{ColorRainbow}}"},
    ["scapular"] = {ScapularItem, "{{ColorRainbow}}Also triggers with extra {{HalfHeart}} half a heart of health{{ColorRainbow}}"},
    ["gnawed_leaf"] = {GnawedLeafItem, "{{ColorRainbow}}Doubles player's contact damage whem triggered{{ColorRainbow}}"},
    ["linger_bean"] = {LingerBeanItem, "{{ColorRainbow}}Causes Isaac to fart randomly while shooting{{ColorRainbow}}"},
    ["godhead"] = {GodHeadItem, "{{ColorRainbow}}Increases aure size{{ColorRainbow}}"},
    ["number_two"] = {NumberTwoItem, "{{ColorRainbow}}Converts butt bombs spawned to giga bombs and increases bomb damage{{ColorRainbow}}"},
    ["tiny_planet"] = {TinyPlanetItem, "{{ColorRainbow}}Spawns an additional tear when firing{{ColorRainbow}}"},
    ["serpents_kiss"] = {SerpentsKissItem, "{{ColorRainbow}}{{ArrowUp}} +15% chance of firing poison tears and 100% chance for black heart drop on kill{{ColorRainbow}}"},
    ["mysterious_liquid"] = {MysteriousLiquidItem, "{{ColorRainbow}}Increases creep size and damage{{ColorRainbow}}"},
    ["hungry_soul"] = {HungrySoulItem, "{{ColorRainbow}}{{ArrowUp}} +5% chance for ghosts to spawn on regular enemies and +1.5% chance when damaging a boss{{ColorRainbow}}"},
    ["anemic"] = {AnemicItem, "{{ColorRainbow}}Increases creep size and damage{{ColorRainbow}}"},
    ["pupula_duplex"] = {PupulaDuplexItem, "{{ColorRainbow}}{{ArrowUp}} +25% Tear size{{ColorRainbow}}"},
    ["spoon_bender"] = {SpoonBenderItem, "{{ColorRainbow}}{{ArrowUp}} +1 Tear range and spectral tears{{ColorRainbow}}"},
    ["toxic_shock"] = {ToxicShockItem, "{{ColorRainbow}}Increases poison damage and now {{BossRoom}} bosses are poisoned on cooldown(roughly every 5 sec){{ColorRainbow}}"},
    ["spelunker_hat"] = {SpelunkerHatItem, "{{ColorRainbow}}Shows {{UltraSecretRoom}} ultra secret room and spawns a cracked key on pickup and at the start of every floor{{ColorRainbow}}"},
    ["phd"] = {PHDItem, "{{ColorRainbow}}Transforms all {{Pill}} pills into horse pills{{ColorRainbow}}"},
    ["virgo"] = {VirgoItem, "{{ColorRainbow}}Transforms all {{Pill}} pills into horse pills{{ColorRainbow}}"},
    ["lucky_foot"] = {LuckyFootItem, "{{ColorRainbow}}Transforms all {{Pill}} pills into horse pills{{ColorRainbow}}"},
    ["lump_of_coal"] = {LumpOfCoalItem, "{{ColorRainbow}}{{ArrowUp}} +1 Tear range{{ColorRainbow}}"},
    ["chocolate_milk"] = {ChocolateMilkItem, "{{ColorRainbow}}{{ArrowUp}} +25% Tear damage{{ColorRainbow}}"},
    ["flat_stone"] = {FlatStoneItem, "{{ColorRainbow}}Spawns 2 tears on bounce that deal 40% of base damage{{ColorRainbow}}"},
    ["moms_purse"] = {MomsPurseItem, "{{ColorRainbow}}Gulps trinkets and spawns +1 random trinket{{ColorRainbow}}"},
    ["ball_of_tar"] = {BallOfTarItem, "{{ColorRainbow}}Increases creep size, adds +15% chance of firing slow tears and gives +30% chance of firing freezing tears instead{{ColorRainbow}}"},
    ["aquarius"] = {AquariusItem, "{{ColorRainbow}}Increases creep size and damage{{ColorRainbow}}"},
    ["bobs_curse"] = {BobsCurseItem, "{{ColorRainbow}}{{ArrowUp}} +15% chance of firing poison tears{{ColorRainbow}}"},
    ["monstrance"] = {MonstranceItem, "{{ColorRainbow}}Increases aura size and {{Slow}} slows enemies inside{{ColorRainbow}}"},
    ["bffs"] = {BFFSItem, "{{ColorRainbow}}Increases familiar size and damage by 25%{{ColorRainbow}}"},
    ["vengeul_spirit"] = {VengefulSpiritItem, "{{ColorRainbow}}Increases maximum number of wisps to 26 and spawns an additional wisp when taking damage{{ColorRainbow}}"},
    ["purgatory"] = {PurgatoryItem, "{{ColorRainbow}}Spawns an additional purgatory crack{{ColorRainbow}}"},
    ["hive_mind"] = {HiveMindItem, "{{ColorRainbow}}Further increases spider/flies damage and size by 25% {{ColorRainbow}}"},
    ["bone_spurs"] = {BoneSpursItem, "{{ColorRainbow}}Spawns an extra bone familiar when killing an enemy{{ColorRainbow}}"},
    ["pound_of_flesh"] = {PoundOfFleshItem, "{{ColorRainbow}}Reduces devil deals cost by 50% (minimun 1$ cost){{ColorRainbow}}"},
    ["dead_bird"] = {DeadBirdItem, "{{ColorRainbow}}Spawns an extra bird when taking damage{{ColorRainbow}}"},
    ["fanny_pack"] = {FannyPackItem, "{{ColorRainbow}}Each copy has a 50% chance of dropping a random pickup{{ColorRainbow}}"},
    ["mr_mega"] = {MrMegaItem, "{{ColorRainbow}}Increases bomb damage by 25%{{ColorRainbow}}"},
    ["money_equals_power"] = {MoneyEqualsPowerItem, "{{ColorRainbow}}Coins give 100% extra damage{{ColorRainbow}}"},
    ["eye_drops"] = {EyeDropsItem, "{{ColorRainbow}}Further reduces tear delay by 0.5{{ColorRainbow}}"},
    ["birds_eye"] = {BirdsEyeItem, "{{ColorRainbow}}Increases fire size by 50% and damage by 25%{{ColorRainbow}}"},
    ["ghost_pepper"] = {GhostPepperItem, "{{ColorRainbow}}Increases fire size by 50% and damage by 25%{{ColorRainbow}}"},
    ["whore_of_babylon"] = {WhoreOfBabylonItem, "{{ColorRainbow}}Stats stack now when item is active{{ColorRainbow}}"},
    ["brittle_bones"] = {BrittleBonesItem, "{{ColorRainbow}}Further reduces tear delay when losing a bone heart{{ColorRainbow}}"},
    ["trisagion"] = {TrisagionItem, "{{ColorRainbow}}Adds +10% chance of firing holy shot tears{{ColorRainbow}}"},
}


local languageCode = "en_us"

if EID and REPENTOGON then
    for itemSetting, description in pairs(itemsDescriptions) do
        if settings[itemSetting] then
            for i, condition in pairs(EID.DescriptionConditions["5.100." .. tostring(description[1])] or {}) do
                if condition.modifierText == "No Effect (Copies)" then
                    table.remove(EID.DescriptionConditions["5.100." .. tostring(description[1])], i)
                    break
                end
            end
            EID.descriptions[languageCode].ConditionalDescs["5.100." .. tostring(description[1]) .. " (Copies)"] = description[2]
            EID:AddSelfConditional({description[1]}, "Copies")
        end
    end
end

-- Important Variables
local chests = {PickupVariant.PICKUP_CHEST, PickupVariant.PICKUP_LOCKEDCHEST, PickupVariant.PICKUP_REDCHEST, PickupVariant.PICKUP_BOMBCHEST, PickupVariant.PICKUP_ETERNALCHEST, PickupVariant.PICKUP_SPIKEDCHEST, PickupVariant.PICKUP_MIMICCHEST, PickupVariant.PICKUP_OLDCHEST, PickupVariant.PICKUP_WOODENCHEST, PickupVariant.PICKUP_MEGACHEST, PickupVariant.PICKUP_HAUNTEDCHEST}
local spawning_tear = false
local spawning_laser = false
local using_item = false
local current_scapular_charge = {0, 0, 0, 0, 0, 0, 0, 0}
local scapular_activate = {false, false, false, false, false, false, false, false}
local spawn_dead_bird = {true, true, true, true, true, true, true, true}
local jumper_cables_kills = 0
local current_room_kills = 0
local lusty_blood_extra_damage = 0
local current_floor_hits_taken = 0
local bloody_lust_extra_damage = 0
local bloody_gust_extra_tears = 0
local gnawed_leaf_ticks = 0
local gnawed_leaf_active = false
local dropped_red_key = false
local trackedTears = {}
local trackedLasers = {}
local trackedFamiliars = {}
local hiveMindFamiliars = {
    [FamiliarVariant.DADDY_LONGLEGS] = true,
    [FamiliarVariant.SISSY_LONGLEGS] = true,
    [FamiliarVariant.SPIDER_MOD] = true,
    [FamiliarVariant.BLUE_FLY] = true,
    [FamiliarVariant.BLUE_SPIDER] = true,
    [FamiliarVariant.FOREVER_ALONE] = true,
    [FamiliarVariant.DISTANT_ADMIRATION] = true,
    [FamiliarVariant.BIG_FAN] = true,
    [FamiliarVariant.BBF] = true,
}

local trackedFamiliarsHiveMind = {}
local devil_price_updated = false

local pickupTypes = {
        { PickupVariant.PICKUP_COIN, { CoinSubType.COIN_PENNY, CoinSubType.COIN_NICKEL, CoinSubType.COIN_DIME, CoinSubType.COIN_LUCKYPENNY } },
        { PickupVariant.PICKUP_KEY, { KeySubType.KEY_NORMAL, KeySubType.KEY_GOLDEN } },
        { PickupVariant.PICKUP_BOMB, { BombSubType.BOMB_NORMAL, BombSubType.BOMB_GOLDEN, BombSubType.BOMB_GIGA } },
        { PickupVariant.PICKUP_HEART, { HeartSubType.HEART_FULL, HeartSubType.HEART_HALF, HeartSubType.HEART_SOUL, HeartSubType.HEART_BLACK, HeartSubType.HEART_GOLDEN, HeartSubType.HEART_BONE } },
}

local trackedFires = {}
local boneHearts = 0

--- Checks if the player already has an active item in their pocket slot
---@param player EntityPlayer
---@return boolean
function mod:canHoldPocketActive(player)
    if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == 0 then
        return true
    else
        return false
    end
end

--- Functions for counting enemies killed in the current room
---@param entity Entity
function mod:onKillEnemy(entity)
    if entity:IsEnemy() then
        current_room_kills = current_room_kills + 1
    end
end

--- Resets current room kills
function mod:onNewRoom()
    current_room_kills = 0
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(LustyBloodItem) then
        lusty_blood_extra_damage = 0
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(ScapularItem) then
            current_scapular_charge[i] = math.min(player:GetCollectibleNum(ScapularItem) - 1, 1)
        end
    end
end

-- Checks how much health the player has excluding bone hearts for use with Scapular
---@param index integer
---@return integer
function mod:getPlayerTotalHealth(index)
    local player = Isaac.GetPlayer(index)
    return player:GetHearts() + player:GetSoulHearts() + player:GetEternalHearts() + player:GetRottenHearts()
end

--- Credit to PixelPlz for the code to open the Boss Rush & Hush rooms
--- Checks if room is Mom boss room or Mom's Heart boss room
---@param type string
---@param room Room
---@return boolean
function mod:IsMommyRoom(type, room)
	if room:GetType() == RoomType.ROOM_BOSS and Game():GetLevel():GetAbsoluteStage() ~= LevelStage.STAGE7 then
		local bossID = room:GetBossID()

		if (type == "Mom" 	 and bossID == 6)
		or (type == "Heart"  and (bossID == 8 or bossID == 25))
		or (type == "Mother" and bossID == 88) then
			return true
		end
	end
	return false
end

--- Tries to spawn Boss Rush or Hush door if in correct boss room
function mod:TrySpawnXRayVisionExits()
    local room = Game():GetRoom()
    -- Boss Rush door from Mom
    if mod:IsMommyRoom("Mom", room) == true then
        room:TrySpawnBossRushDoor(true)


    -- Blue Womb door from Mom's Heart / It Lives
    elseif mod:IsMommyRoom("Heart", room) then
        room:TrySpawnBlueWombDoor(false, true)
    end
end

--- X-Ray Vision stacking trying to spawn Hush/Boss Rush exits upon clearing a room
function mod:onClearXRV()
    if not settings.xray_vision then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(XRayVisionItem) then
            local copyCount = player:GetCollectibleNum(XRayVisionItem) - 1
            if copyCount > 0 then
                mod:TrySpawnXRayVisionExits()
            end
        end
    end
end

--- X-Ray Vision stacking trying to spawn Hush/Boss Rush exits upon entering a cleared room
function mod:onNewRoomXRV()
    if not settings.xray_vision then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(XRayVisionItem) then
            local copyCount = player:GetCollectibleNum(XRayVisionItem) - 1
            if copyCount > 0 then
                local room  = Game():GetRoom()
                if room:IsClear() then
                    mod:TrySpawnXRayVisionExits()
                end
            end
        end
    end
end

--- Adjusts stats appropriately for items that change stats or tear effects
---@param player EntityPlayer
---@param cacheFlags CacheFlag
function mod:evaluateCache(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        if player:HasCollectible(HeartbreakItem) and settings.heartbreak then
            local copyCount = player:GetCollectibleNum(HeartbreakItem) - 1
            local damageToAdd = 0.25 * player:GetBrokenHearts() * copyCount
            player.Damage = player.Damage + damageToAdd
        end
        if player:HasCollectible(LustyBloodItem) and settings.lusty_blood then
            player.Damage = player.Damage + lusty_blood_extra_damage
        end
        if player:HasCollectible(BloodyLustItem) and settings.bloody_lust then
            player.Damage = player.Damage + bloody_lust_extra_damage
        end
        if player:HasCollectible(MoneyEqualsPowerItem) and settings.money_equals_power then
            local copyCount = player:GetCollectibleNum(MoneyEqualsPowerItem) - 1
            if copyCount > 0 then
                local coins = player:GetNumCoins()
                player.Damage = player.Damage + 0.04 * coins * copyCount
            end
        end
    end
    if cacheFlags & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY then
        if player:HasCollectible(BloodyGustItem) and settings.bloody_gust then
            player.MaxFireDelay = player.MaxFireDelay - (bloody_gust_extra_tears)
        end
        if player:HasCollectible(EyeDropsItem) and settings.eye_drops then
            local copyCount = player:GetCollectibleNum(EyeDropsItem) - 1
            if copyCount > 0 then
                player.MaxFireDelay = player.MaxFireDelay - 0.5 * copyCount
            end
        end
    end
    if cacheFlags & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG then
        if player:HasCollectible(SpoonBenderItem) and settings.spoon_bender then
            local copyCount = player:GetCollectibleNum(SpoonBenderItem) - 1
            if copyCount > 0 then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL -- Add spectral tears
                player.TearHeight = player.TearHeight - 3.5 -- Add small range up
                player.TearRange = player.TearRange + 40 -- Add small range up
            end
        end
    end
    if cacheFlags & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG then
        if player:HasCollectible(LumpOfCoalItem) and settings.lump_of_coal then
            local copyCount = player:GetCollectibleNum(LumpOfCoalItem) - 1
            if copyCount > 0 then
                player.TearHeight = player.TearHeight - 3.5 -- Add small range up
                player.TearRange = player.TearRange + 40 -- Add small range up
            end
        end
    end
    if cacheFlags & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then
        if player:HasCollectible(TrisagionItem) and settings.trisagion then
            local copyCount = player:GetCollectibleNum(TrisagionItem) - 1
            if copyCount > 0 then
                player.ShotSpeed = player.ShotSpeed - 0.05 -- Add small shot speed down
            end
        end
    end
end

--- Adjusts stats appropriately for items that change stats or tear effects
---@param player EntityPlayer
---@param cacheFlag CacheFlag
function mod:evaluateCacheWhoreOfBabylon(player, cacheFlag)
    if player:HasCollectible(WhoreOfBabylonItem) then
        local copies = player:GetCollectibleNum(WhoreOfBabylonItem) - 1
        local isEve = player:GetPlayerType() == PlayerType.PLAYER_EVE
        local isActive = false

        if isEve then
            isActive = player:GetHearts() <= 2
        else
            isActive = player:GetHearts() <= 1
        end

        if isActive then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + 1.5 * copies
            end
            if cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + 0.3 * copies
            end
        end
    end
end

--- Cursed Eye Stacking with Tears fires extra tears
--- @param tear EntityTear
function mod:onFireTearsCE(tear)
    if not settings.cursed_eye then
        return
    end
    if spawning_tear then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(CursedEyeItem) then
            local copyCount = player:GetCollectibleNum(CursedEyeItem) - 1
            if copyCount > 0 then
                spawning_tear = true
                for i=1, copyCount, 1 do
                    player:FireTear(player.Position, tear.Velocity, true, false, true)
                end
                spawning_tear = false
            end
        end
    end
end

--- Cursed Eye Stacking with Tech Lasers fires extra lasers
--- @param laser EntityLaser
function mod:onFireLaserCE(laser)
    if not settings.cursed_eye then
        return
    end
    if spawning_laser then
        return
    end
    local player = laser.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(CursedEyeItem) then
            if player:HasWeaponType(WeaponType.WEAPON_LASER) then
                local copyCount = player:GetCollectibleNum(CursedEyeItem) - 1
                if copyCount > 0 then
                    spawning_laser = true
                    for i=1, copyCount, 1 do
                        player:FireTechLaser(player.Position, LaserOffset.LASER_TECH1_OFFSET, laser.EndPoint:Rotated(-45), false)
                    end
                    spawning_laser = false
                end
            end
        end
    end
end

--- Loki's Horns Stacking with Tears, firing 4 tears diagonally
--- @param tear EntityTear
function mod:onFireTearsLH(tear)
    if not settings.loki_horns then
        return
    end
    if spawning_tear then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(LokiHornsItem) then
            local vel = tear.Velocity
            local copyCount = player:GetCollectibleNum(LokiHornsItem) - 1
            if copyCount > 0 then
                if math.random() < 0.25 + (0.05 * player.Luck) then
                    spawning_tear = true
                    player:FireTear(player.Position, vel:Rotated(45), false, true, false)
                    player:FireTear(player.Position, vel:Rotated(-45), false, true, false)
                    player:FireTear(player.Position, vel:Rotated(135), false, true, false)
                    player:FireTear(player.Position, vel:Rotated(-135), false, true, false)
                    spawning_tear = false
                end
            end
        end
    end
end

--- Isaac's Tomb Stacking
--- Spawns an additional Old Chest per stack of Isaac's Tomb at the start of each floor
function mod:onNewFloorIT()
    if not settings.isaacs_tomb then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(IsaacTombItem) then
            local copyCount = player:GetCollectibleNum(IsaacTombItem) - 1
            if copyCount > 0 then
                for i=1, copyCount, 1 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, 0, Vector(320,240), Vector(0,0), nil)
                end
            end
        end
    end
end

--- Card Reading Stacking adds the third portal type when entering a floor
function mod:onNewFloorCR()
    if not settings.card_reading then
        return
    end
    local copyCount = 0
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(CardReadingItem) then
            copyCount = copyCount + player:GetCollectibleNum(CardReadingItem) - 1
        end
    end
        if copyCount > 0 then
            local room = Game():GetRoom()
            local entities = room:GetEntities()
            local treasure_portal = false
            local boss_portal = false
            local secret_portal = false
            for i=0, entities.Size-1 do
                local cur_entity = entities:Get(i)
                if cur_entity.Type == EntityType.ENTITY_EFFECT and cur_entity.Variant == EffectVariant.PORTAL_TELEPORT then
                    if cur_entity.SubType == 0 then
                        treasure_portal = true
                    elseif cur_entity.SubType == 1 then
                        boss_portal = true
                    elseif cur_entity.SubType == 2 then
                        secret_portal = true
                    end
                end
            end
            if treasure_portal and boss_portal then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PORTAL_TELEPORT, 2, Vector(320,200), Vector(0, 0), nil)
            elseif treasure_portal and secret_portal then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PORTAL_TELEPORT, 1, Vector(320,200), Vector(0, 0), nil)
            elseif boss_portal and secret_portal then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PORTAL_TELEPORT, 0, Vector(320,200), Vector(0, 0), nil)
            end
        end
end

--- Car Battery Stacking
--- Uses the active item one additional time per stack of car battery
--- @param item CollectibleType
--- @param player_entity EntityPlayer
--- @param flags any
function mod:onUseItemCB(item, _, player_entity, flags)
    if not settings.car_battery then
        return
    end
    if player_entity:HasCollectible(CarBatteryItem) then
        --Check for the USE_CARBATTERY UseFlag to prevent additional uses of the item
        if (flags & (1 << 5)) == (1 << 5) then
            return
        end
        --Make sure effect isn't repeated into infinity
        if using_item then
            return
        end
        --Get number of copies of Car Battery and uses active item effect appropriate number of times
        local copyCount = player_entity:GetCollectibleNum(CarBatteryItem) - 1
        if copyCount > 0 then
            using_item = true
            for i=1, copyCount, 1 do
                player_entity:UseActiveItem(item, UseFlag.USE_CARBATTERY)
            end
            using_item = false
        end
    end
end

--- Adds an additional Minisaac when damaged per stack of Giant Cell
--- @param entity Entity
function mod:onDamageGC(entity)
    if not settings.giant_cell then
        return
    end
    local player = entity:ToPlayer()
    if player then
        if player:HasCollectible(GiantCellItem) then
            local copyCount = player:GetCollectibleNum(GiantCellItem) - 1
            if copyCount > 0 then
                for i=1, copyCount, 1 do
                    player:AddMinisaac(player.Position, true)
                end
            end
        end
    end
end

--- Uses Soul of Cain effect on taking damage if player has more than one Cracked Orb
function mod:onDamageCO()
    if not settings.cracked_orb then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local copyCount = player:GetCollectibleNum(CrackedOrbItem) - 1
        if copyCount > 0 then
            player:UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM)
        end
    end
end

--- Infestation 1 Stacking
--- Spawns an additional 2-6 blue flies after taking damage
--- @param entity Entity
function mod:onDamageInfestation(entity)
    if not settings.infestation then
        return
    end
    local player = entity:ToPlayer()
    if player then
        if player:HasCollectible(InfestationItem) then
            local copyCount = player:GetCollectibleNum(InfestationItem) - 1
            if copyCount > 0 then
                for i=1, copyCount, 1 do
                    local flies = math.random(2, 6)
                    player:AddBlueFlies(flies, player.Position, player)
                end
            end
        end
    end
end

--- Adds an additional 33% (increased with luck) on room clear to spawn a chest of ANY random type
--- @param rng RNG
--- @param position Vector
function mod:onClearGT(rng, position)
    if not settings.guppys_tail then
        return
    end
    local room = Game():GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        return
    end
    local copyCount = 0
    local maxLuck = 0
    local leftHandTrinket = false
    local gildedKeyTrinket = false
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        maxLuck = math.min(math.max(0, player.Luck), 10)
        if player:GetTrinket(0) == TrinketType.TRINKET_LEFT_HAND or player:GetTrinket(1) == TrinketType.TRINKET_LEFT_HAND then
            leftHandTrinket = true
        end
        if player:HasCollectible(GuppyTailItem) then
            copyCount = copyCount + player:GetCollectibleNum(GuppyTailItem) - 1
        end
    end
    if copyCount > 0 then
        for i=1, copyCount, 1 do
            if (rng:RandomFloat() * maxLuck * 0.1) + rng:RandomFloat() > 0.66 then
                local spawnpos = room:FindFreePickupSpawnPosition(position)
                if leftHandTrinket then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, 0, spawnpos, Vector(0,0), nil)
                elseif gildedKeyTrinket then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, spawnpos, Vector(0,0), nil)
                else
                    local chestType = rng:RandomInt(10)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, chests[chestType], 0, spawnpos, Vector(0,0), nil)
                end
            end
        end
    end
end

--- Spawn an additional blue spider per stack of Infestation 2 upon killing an enemy
--- @param entity Entity
function mod:onKillInfestationTwo(entity)
    if not settings.infestation_two then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if entity:IsEnemy() then
            if player:HasCollectible(InfestationTwoItem) then
                local copyCount = player:GetCollectibleNum(InfestationTwoItem) - 1
                if copyCount > 0 then
                    for i=1, copyCount, 1 do
                        local spider_target = Vector(entity.Position.X + math.random(-10, 10), entity.Position.Y+80)
                        player:ThrowBlueSpider(entity.Position, spider_target)
                    end
                end
            end
        end
    end
end

--- If the player does not already have a pocket active item, the player's current active item will be moved to the pocket active slot
--- @param item CollectibleType
--- @param player_entity EntityPlayer
--- @param flags any
--- @param active_slot integer
function mod:onUseItemSchoolbag(item, _, player_entity, flags, active_slot)
    if not settings.schoolbag then
        return
    end
    if not mod:canHoldPocketActive(player_entity) then
        return
    end
    local current_active_item = item
    if player_entity:HasCollectible(SchoolbagItem) then
        local copyCount = player_entity:GetCollectibleNum(SchoolbagItem) - 1
        if copyCount > 0 then
            if active_slot == ActiveSlot.SLOT_PRIMARY and (flags & (1 << 2)) == (1 << 2) then
                player_entity:SetPocketActiveItem(current_active_item, ActiveSlot.SLOT_POCKET, false)
            end
        end
    end
end

--- Stairway ladder will now persist after leaving the initial room
function mod:onNewRoomStairway()
    if not settings.stairway then
        return
    end
    local copyCount = 0
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(StairwayItem) then
            copyCount =  copyCount + player:GetCollectibleNum(StairwayItem) - 1
        end
    end
    if copyCount > 0 then
        if Game():GetLevel():GetCurrentRoomIndex() == Game():GetLevel():GetStartingRoomIndex() then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TALL_LADDER, 1, Vector(440, 160), Vector(0,0), nil)
        end
    end
end

--- For every tear fired while stacking Eye Sore, an additional random tear will be fired in a random direction
--- @param tear EntityTear
function mod:onFireTearsEyeSores(tear)
    if not settings.eye_sores then
        return
    end
    if spawning_tear then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(EyeSoresItem) then
            local copyCount = player:GetCollectibleNum(EyeSoresItem) - 1
            if copyCount > 0 then
                spawning_tear = true
                for i=1, copyCount, 1 do
                    player:FireTear(player.Position, tear.Velocity:Rotated(math.random(-179, 180)), true, false, true)
                end
                spawning_tear = false
            end
        end
    end
end

--- Stacking Jumper Cables adds an additional charge to the primary active item and pocket active every 7 kills
--- @param entity Entity
function mod:onKillJumperCables(entity)
    if not settings.jumper_cables then
        return
    end
    local player = Isaac.GetPlayer(0)
    if entity:IsEnemy() then
        if player:HasCollectible(JumperCablesItem) then
            local copyCount = player:GetCollectibleNum(JumperCablesItem) - 1
            if copyCount > 0 then
                if jumper_cables_kills == 7 then
                    jumper_cables_kills = 0
                    player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + 1, ActiveSlot.SLOT_PRIMARY)
                    player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + 1, ActiveSlot.SLOT_POCKET)
                else
                    jumper_cables_kills = jumper_cables_kills + 1
                end
            end
        end
    end
end

--- Stacking Empty Heart adds an additional empty heart container per stack when effect is triggered
function mod:onNewFloorEmptyHeart()
    if not settings.empty_heart then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(EmptyHeartItem) then
            local copyCount = player:GetCollectibleNum(EmptyHeartItem) - 1
            if copyCount > 0 then
                -- If player has two hearts less than their max red hearts, then trigger effect
                if player:GetHearts() <= 2 then
                    for i=1, copyCount, 1 do
                        player:AddMaxHearts(2, true)
                    end
                end
            end
        end
    end
end

--- 9 Volt Stacking adds additional charges back to the item upon use
--- @param player_entity EntityPlayer
--- @param flags any
function mod:onUseItemNineVolt(_, _, player_entity, flags)
    if not settings.nine_volt then
        return
    end
    if player_entity:HasCollectible(NineVoltItem) then
        if (flags & (1 << 5)) == (1 << 5) then
            return
        end
        local copyCount = player_entity:GetCollectibleNum(NineVoltItem) - 1
        if copyCount > 0 then
            player_entity:SetActiveCharge(player_entity:GetActiveCharge() + copyCount)
        end
    end
end

--- Lusty Blood Stacking adds additional damage upon killing the appropriate number of enemies
--- @param entity Entity
function mod:onKillEnemyLustyBlood(entity)
    if not settings.lusty_blood then
        return
    end
    if entity:IsEnemy() then
        local player = Isaac.GetPlayer(0)
        if player:HasCollectible(LustyBloodItem) then
            local copyCount = player:GetCollectibleNum(LustyBloodItem)
            if copyCount > 1 then
                local max_kill_bonus = copyCount * 10
                if current_room_kills <= 10 then
                    lusty_blood_extra_damage = 0
                elseif current_room_kills > 10 and current_room_kills <= max_kill_bonus then
                    lusty_blood_extra_damage = (current_room_kills - 10) * 0.5
                end
            end
        end
    end
end

--- Increments the number of hits taken on the current floor by 1 when hit
function mod:onDamage()
    current_floor_hits_taken = current_floor_hits_taken + 1
end

--- Resets value of hits taken on current floor, extra damage from bloody lust, and extra tears from bloody gust
function mod:onNewFloor()
    dropped_red_key = false
    devil_price_updated = false
    local player = Isaac.GetPlayer(0)
    current_floor_hits_taken = 0
    if player:HasCollectible(BloodyLustItem) then
        bloody_lust_extra_damage = 0
    end
    if player:HasCollectible(BloodyGustItem) then
        bloody_gust_extra_tears = 0
    end

end

--- Bloody Lust Stacking adds appropriate amount of damage when taking hits
function mod:onDamageBloodyLust()
    if not settings.bloody_lust then
        return
    end
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(BloodyLustItem) then
        local copyCount = player:GetCollectibleNum(BloodyLustItem) - 1
        if copyCount > 0 then
            local max_hit_bonus = copyCount * 4
            if current_floor_hits_taken <= 6 then
                bloody_lust_extra_damage = 0
            elseif current_floor_hits_taken > 6 and (current_floor_hits_taken - 6) <= max_hit_bonus then
                bloody_lust_extra_damage = 1.5 * (current_floor_hits_taken - 6)
            end
        end
    end
end

--- Bloody Gust Stacking adds appropriate amount of tears when taking hits
function mod:onDamageBloodyGust()
    if not settings.bloody_gust then
        return
    end
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(BloodyGustItem) then
        local copyCount = player:GetCollectibleNum(BloodyGustItem) - 1
        if copyCount > 0 then
            local max_hit_bonus = copyCount * 2
            if current_floor_hits_taken <= 6 then
                bloody_gust_extra_tears = 0
            elseif current_floor_hits_taken > 6 and (current_floor_hits_taken - 6) <= max_hit_bonus then
                bloody_gust_extra_tears = 0
                for i=1, current_floor_hits_taken, 1 do
                    bloody_gust_extra_tears = (bloody_gust_extra_tears + (0.1 * (i-1)) + 0.25)
                end
                bloody_gust_extra_tears = bloody_gust_extra_tears - 3
            end
        end
    end
end

--- Scapular Stacking
--- @param amount integer
function mod:onDamageScapular(_, amount)
    if not settings.scapular then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(ScapularItem) then
            local copyCount = player:GetCollectibleNum(ScapularItem)
            if copyCount > 1 then
                if current_scapular_charge[i] > 0 and mod:getPlayerTotalHealth(i)-amount <= copyCount and mod:getPlayerTotalHealth(i)-amount > 0 then
                    current_scapular_charge[i] = current_scapular_charge[i] - 1
                    scapular_activate[i] = true
                end
            end
        end
    end
end

--- Adds soul hearts to the player after taking damage. This is necessary as the MC_ENTITY_TAKE_DMG callback occurs before the actual damage is taken.
function mod:onUpdateScapular()
    if not settings.scapular then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player then
            if scapular_activate[i] then
                player:AddSoulHearts(2)
                scapular_activate[i] = false
            end
        end
    end
end

--- Checks if the player has been standing still without shooting for 1 second before activating the gnawed leaf effect
function mod:postUpdateGnawedLeaf()
    if not settings.gnawed_leaf then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(GnawedLeafItem) then
            if player:GetMovementVector().X == 0 and player:GetMovementVector().Y == 0 and player:GetShootingInput().X == 0 and player:GetShootingInput().Y == 0 then
                gnawed_leaf_ticks = gnawed_leaf_ticks + 1
                if gnawed_leaf_ticks >= 30 then
                    gnawed_leaf_active = true
                end
            else
                gnawed_leaf_ticks = 0
                gnawed_leaf_active = false
            end
        end
    end
end

--- Gnawed Leaf Stacking. Deals double the player's current damage multiplied by number of stacks after the first whenever an enemy collides with the player
--- @param player_entity EntityPlayer
--- @param collider_entity Entity
function mod:onPlayerCollisionGnawedLeaf(player_entity, collider_entity)
    if not settings.gnawed_leaf then
        return
    end
    if not collider_entity:IsEnemy() then
        return
    end
    if player_entity:HasCollectible(GnawedLeafItem) then
        local copyCount = player_entity:GetCollectibleNum(GnawedLeafItem) - 1
        if copyCount > 0 then
            if gnawed_leaf_active then
                local damage = copyCount * player_entity.Damage * 2
                collider_entity:TakeDamage(damage, 0, EntityRef(player_entity), 0)
            end
        end
    end
end

--- Linger bean stacking
--- @param tear EntityTear
function mod:onFireTearsLingerBean(tear)
    if not settings.linger_bean then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(LingerBeanItem) then
            local copyCount = player:GetCollectibleNum(LingerBeanItem) - 1
            if copyCount > 0 then
                for i=1, copyCount, 1 do
                    local chance = math.random()
                    if chance > 0.85 then
                        local radius = 100 * copyCount
                        if chance > 0.95 then
                            Game():ButterBeanFart(player.Position, radius, player, true, true)
                        else
                            Game().Fart(Game(), player.Position, radius, player, copyCount, 0)
                        end
                    end
                end
            end
        end
    end
end

--- Stole this code from Fiend Folio which stole the code from Retribution. Get fricked.
--- @param tear any
--- @param multiplier number
local function increaseTearScale(tear, multiplier)
    tear.Scale = tear.Scale * multiplier
end

--- Generate a bigger aura when stacking GodHeadItem
--- @param tear EntityTear
function mod:onTearUpdateGodHead(tear)
    if not settings.godhead then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(GodHeadItem) then
            local copyCount = player:GetCollectibleNum(GodHeadItem) - 1
            if copyCount > 0 then
                if tear.FrameCount < 1 then
                    if tear.Parent.Type == 1 or (tear.Parent.Type == 3 and (tear.Parent.Variant == 80 or tear.Parent.Variant == 235 or tear.Parent.Variant == 240)) then
                        increaseTearScale(tear, 1 + (copyCount * 0.25))
                    end
                elseif tear.FrameCount == 1 and tear.Parent then
                    if tear.Parent.Type == 3 and tear.Parent.Variant == 81 then
                        increaseTearScale(tear, 1 + (copyCount * 0.25))
                    end
                end
            end
        end
    end
end

--- Number Two Stacking - If you know how to fix the visual issues, please leave a comment on the mod page or message me on twitter
--- @param bomb EntityBomb
function mod:onBombNumber2(bomb)
    if not settings.number_two then
        return
    end
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(NumberTwoItem) then
        local copyCount = player:GetCollectibleNum(NumberTwoItem) - 1
        if copyCount == 1 then
            if bomb.Variant == BombVariant.BOMB_BUTT then
                bomb.Variant = BombVariant.BOMB_MR_MEGA
            end
        end
        if copyCount >= 2 then
            if bomb.Variant == BombVariant.BOMB_BUTT then
                bomb:AddTearFlags(TearFlags.TEAR_GIGA_BOMB)
                bomb.Variant = BombVariant.BOMB_GIGA
            end
        end
        if copyCount > 0 then
            bomb.ExplosionDamage = bomb.ExplosionDamage * (copyCount + 1)
        end
    end
end

--- Sapwns additional tear when stacking Tiny Planet
--- @param tear EntityTear
function mod:onFireTearsTinyPlanet(tear)
    if not settings.tiny_planet then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(TinyPlanetItem) then
            local copyCount = player:GetCollectibleNum(TinyPlanetItem) - 1
            if copyCount > 0 then
                if spawning_tear then
                    return
                end
                for i=1, copyCount, 1 do
                    spawning_tear = true
                    player:FireTear(tear.Position, tear.Velocity, false, true, false, player, 0.5)
                    spawning_tear = false
                end
            end
        end
    end
end

--- SerpentsKissItem stacking - Increases chance of poison tears and assures black heart drop on kill
--- @param tear EntityTear
function mod:onFireTearsSerpentsKiss(tear)
    if not settings.serpents_kiss then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(SerpentsKissItem) then
            local copyCount = player:GetCollectibleNum(SerpentsKissItem) - 1
            if copyCount > 0 then
                if not tear:HasTearFlags(TearFlags.TEAR_POISON) then
                    if math.random() < 0.15 * copyCount then
                        tear:AddTearFlags(TearFlags.TEAR_POISON)
                    end
                end
                if tear:HasTearFlags(TearFlags.TEAR_POISON) then
                    tear:AddTearFlags(TearFlags.TEAR_BLACK_HP_DROP)
                end
            end
        end
    end
end

--- Stacking Mysterious Liquids by making the creep bigger and lasting longer
--- @param entity Entity
function mod:onDamageDealtMysteriousLiquid(entity)
    if not settings.mysterious_liquid then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(MysteriousLiquidItem) then
            local copyCount = player:GetCollectibleNum(MysteriousLiquidItem) - 1
            if copyCount > 0 and entity.Type == EntityType.ENTITY_TEAR then
                for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, -1, false, false)) do
                    effect.SpriteScale = Vector(copyCount + 1, copyCount + 1)
                    effect.CollisionDamage = 1 + copyCount*2
                end
            end
        end
    end
end

--- Stacking Hungry Soul by increasing the probability of ghosts spawning: +5% for each extra copy starting at 35% with one extra copy
--- @param entity Entity
function mod:onKillEnemyHungrySoul(entity)
    if not settings.hungry_soul then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(HungrySoulItem) then
            local copyCount = player:GetCollectibleNum(HungrySoulItem) - 1
            if copyCount > 0 then
                if math.random() < 0.30 + 0.05 * copyCount then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 0, entity.Position, Vector(0,0), player)
                end
            end
        end
    end
end

--- Also updating Hungry souls so that a boss has a very low chance of spawning a ghost: 1.5% for each extra copy starting at base 1.5%
--- @param entity Entity
function mod:onDamageBossHungrySoul(entity)
    if not settings.hungry_soul then
        return
    end
    if not entity:IsBoss() then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(HungrySoulItem) then
            local copyCount = player:GetCollectibleNum(HungrySoulItem) - 1
            if copyCount > 0 then
                if math.random() < 0.015 * (copyCount + 1) then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 0, entity.Position, Vector(0,0), player)
                end
            end
        end
    end
end

--- Stacking anemic will now create a creep which increases in size and damage for each extra copy
function mod:onUpdateAnemic()
    if not settings.anemic then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(AnemicItem) then
            local copyCount = player:GetCollectibleNum(AnemicItem) - 1
            if copyCount > 0 then
                for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, -1, false, false)) do
                    effect.SpriteScale = Vector(copyCount*0.33 + 1, copyCount*0.33 + 1)
                    effect.CollisionDamage = 1 + copyCount*2
                end
            end
        end
    end
end

--- Stacking Pupula Duplex will now increase the size of the tear by 25% for each extra copy
--- @param tear EntityTear
function mod:onFireTearsPupulaDuplex(tear)
    if not settings.pupula_duplex then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(PupulaDuplexItem) then
            local copyCount = player:GetCollectibleNum(PupulaDuplexItem) - 1
            if copyCount > 0 then
                local scaleFactor = copyCount*0.25 + 1
                tear.Scale = tear.Scale * scaleFactor
            end
        end
    end
end

--- Stacking Toxic Shock will now posion the enemies for a longer duration and with a bigger damage output
function mod:onNewRoomToxicShock()
    if not settings.toxic_shock then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(ToxicShockItem) then
            local copyCount = player:GetCollectibleNum(ToxicShockItem) - 1
            if copyCount > 0 then
                for _, entity in pairs(Isaac.GetRoomEntities()) do
                    if entity:IsVulnerableEnemy() and not entity:IsBoss() then
                        entity:AddPoison(EntityRef(player), 2 + copyCount, player.Damage + (copyCount*2))
                    end
                end
            end
        end
    end
end

--- Stacking Toxic Shock will now posion the bosses indefinite
function mod:onUpdateToxicShockBoss()
    if not settings.toxic_shock then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local room = Game():GetRoom()
        if room:GetType() == RoomType.ROOM_BOSS then
            if player:HasCollectible(ToxicShockItem) then
                local copyCount = player:GetCollectibleNum(ToxicShockItem) - 1
                if copyCount > 0 then
                    for _, entity in pairs(Isaac.GetRoomEntities()) do
                        if entity:IsBoss() and not entity:IsDead() then
                            entity:SetBossStatusEffectCooldown(0)
                            entity:AddPoison(EntityRef(player), 4, math.min((player.Damage + (copyCount*2)) / 4, 2))
                        end
                    end
                end
            end
        end
    end
end

--- Stacking Spelunker Hat will now give the same effect as having The Mind item + showing also the ultra secret room
function mod:onUpdateSpelunkerHat()
    if not settings.spelunker_hat then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(SpelunkerHatItem) then
            local copyCount = player:GetCollectibleNum(SpelunkerHatItem) - 1
            if copyCount > 0 then
                local level = Game():GetLevel()
                level:ApplyMapEffect()
                level:ApplyCompassEffect(true)
                level:ApplyBlueMapEffect()
                for i = 0, 169 do
                    local room = level:GetRoomByIdx(i)
                    if room.Data and room.Data.Type == RoomType.ROOM_ULTRASECRET then
                        if room.DisplayFlags & 1 << 2 == 0 then
                            room.DisplayFlags = room.DisplayFlags | 1 << 2 -- Show Icon
                            level:UpdateVisibility()
                            level:RemoveCurses(1)
                        end
                        if dropped_red_key == false then
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 78, player.Position, Vector(0, 0), nil)
                            dropped_red_key = true
                        end
                        return
                    end
                end
            end
        end
    end
end

--- Stacking Spelunker Hat will also give a cracked key each floor and on pickup
function mod:onNewFloorSpelunkerHat()
    if not settings.spelunker_hat then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(SpelunkerHatItem) then
            local copyCount = player:GetCollectibleNum(SpelunkerHatItem) - 1
            if copyCount > 0 then
                local level = Game():GetLevel()
                level:RemoveCurses(1)
                dropped_red_key = false
            end
        end
    end
end

--- Stacking PHD, Virgo or Lucky Foot will convert all pills into its horse pill version (even those holded by the player)
function mod:onUpdateHorsePills()
    if not settings.phd then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local copyCountPHD = player:GetCollectibleNum(PHDItem) - 1
        local copyCountVirgo = player:GetCollectibleNum(VirgoItem) - 1
        local copyCountLuckyFoot = player:GetCollectibleNum(LuckyFootItem) - 1
        if copyCountPHD > 0 or copyCountVirgo > 0 or copyCountLuckyFoot > 0  then
            local pillColor = player:GetPill(0)
            if pillColor ~= PillColor.PILL_NULL then
                player.SetPill(player, 0, pillColor | PillColor.PILL_GIANT_FLAG)
            end
            local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, -1)
            for ent = 1, #entities do
                local entity = entities[ent]
                if entity:Exists() and entity:IsDead() == false and entity.SubType > 0 and entity.SubType < 15 then
                    entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, (entity.SubType + 2048), true)
                end
            end
        end
    end
end

--- Obtaining a pill via Mom's Bottle of pills will now play the horse pill animation
--- @param player EntityPlayer
function mod:OnPlayerGetsPill(_, _, player)
    if not settings.phd then
        return
    end
    local copyCountPHD = player:GetCollectibleNum(PHDItem) - 1
    local copyCountVirgo = player:GetCollectibleNum(VirgoItem) - 1
    local copyCountLuckyFoot = player:GetCollectibleNum(LuckyFootItem) - 1
    if copyCountPHD > 0 or copyCountVirgo > 0 or copyCountLuckyFoot > 0  then
        local pillColor = math.random(15) | PillColor.PILL_GIANT_FLAG
        player:AnimatePill(pillColor)
        player:AddPill(pillColor)
        return true
    end
end

--- Stacking Chocolate Milk will give the player a 25% extra damage for each extra copy when firing a tear at all charge level
--- @param tear EntityTear
function mod:onTearInitChocoMilk(tear)
    if not settings.chocolate_milk then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        local copyCountChocolateMilk = player:GetCollectibleNum(ChocolateMilkItem) - 1
        if copyCountChocolateMilk > 0 then
            tear.CollisionDamage = tear.CollisionDamage * (1 + 0.25*copyCountChocolateMilk)
        end
    end
end

--- Stacking Chocolate Milk will give the player damage upgrade when combining multiple copies with Brimstone or Technology
--- @param player EntityPlayer
--- @param cacheFlag CacheFlag
function mod:onEvaluateCacheChocoMilk(player, cacheFlag)
    if not settings.chocolate_milk then
        return
    end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        local copyCountChocolateMilk = player:GetCollectibleNum(ChocolateMilkItem) - 1
        local hasLaser = player:HasCollectible(BrimstoneItem) or
                         player:HasCollectible(TechnologyItem)

        if copyCountChocolateMilk > 0 and hasLaser then
            player.Damage = player.Damage * (1 + 0.25*copyCountChocolateMilk)
        end
    end
end

 -- Stacking Flat Stone now generates two extra small tears on bounce
--- @param tear EntityTear
function mod:onTearCollideFlatStone(tear)
    if not settings.flat_stone then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        local copyCountFlatStone = player:GetCollectibleNum(FlatStoneItem) - 1
        if copyCountFlatStone > 0 then
            if tear.Height == -5 then
                if tear.HasTearFlags(tear, TearFlags.TEAR_EFFECT_COUNT) == false then
                   tear:Remove()
                   local leftTear = player:FireTear(tear.Position, tear.Velocity:Rotated(5), false, true, false, nil, 0.4)
                   leftTear:AddTearFlags(TearFlags.TEAR_EFFECT_COUNT)
                   leftTear.SpriteScale = Vector(0.75, 0.75)
                   local midTear = player:FireTear(tear.Position, tear.Velocity:Rotated(0), false, true, false, nil, 1)
                   midTear:AddTearFlags(TearFlags.TEAR_EFFECT_COUNT)
                   local rightTear = player:FireTear(tear.Position, tear.Velocity:Rotated(-5), true, false, true, nil, 0.4)
                   rightTear:AddTearFlags(TearFlags.TEAR_EFFECT_COUNT)
                   rightTear.SpriteScale = Vector(0.75, 0.75)
               end
            end
        end
    end
end

--- Stacking MomsPurseItem will gulp current trinkets and spawn one more on pickup
--- @param type CollectibleType
function mod:onMomsPursePickup(type)
    if not settings.moms_purse then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local copyCountMomsPurse = player:GetCollectibleNum(MomsPurseItem)
        if copyCountMomsPurse > 0 and type == CollectibleType.COLLECTIBLE_MOMS_PURSE then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM)
            player:PlayDelayedSFX(SoundEffect.SOUND_VAMP_GULP, 2, 2, 2)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, player.Position, Vector.Zero, nil)
        end
    end
end

--- Stacking BallOfTarItem will increase creep size
function mod:onUpdateBallOfTar()
    if not settings.ball_of_tar then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(BallOfTarItem) then
            local copyCount = player:GetCollectibleNum(BallOfTarItem) - 1
            if copyCount > 0 then
                for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, -1, false, false)) do
                    effect.SpriteScale = Vector(copyCount*0.33 + 1, copyCount*0.33 + 1)
                end
            end
        end
    end
end

--- BallOfTarItem stacking - Increases chance of slowing tears and to replace slow with freeze effect
--- @param tear EntityTear
function mod:onFireTearsBallOfTar(tear)
    if not settings.ball_of_tar then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(BallOfTarItem) then
            local copyCount = player:GetCollectibleNum(BallOfTarItem) - 1
            if copyCount > 0 then
                if not tear:HasTearFlags(TearFlags.TEAR_SLOW) then
                    if math.random() < 0.15 * copyCount then
                        tear:AddTearFlags(TearFlags.TEAR_SLOW)
                    end
                end
                if tear:HasTearFlags(TearFlags.TEAR_SLOW) then
                    if math.random() < 0.30 * copyCount then
                        tear:AddTearFlags(TearFlags.TEAR_FREEZE)
                        tear:ChangeVariant(TearVariant.ICE)
                    end
                end
            end
        end
    end
end

--- Stacking AquariusItem will increase creep size
function mod:onUpdateAquarius()
    if not settings.aquarius then
        return
    end
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(AquariusItem) then
            local copyCount = player:GetCollectibleNum(AquariusItem) - 1
            if copyCount > 0 then
                for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, -1, false, false)) do
                    effect.SpriteScale = Vector(copyCount*0.33 + 1, copyCount*0.33 + 1)
                    effect.CollisionDamage = 1 + copyCount*2
                end
            end
        end
    end
end

--- BobsCurseItem stacking - Increases chance of poison tears
--- @param tear EntityTear
function mod:onFireTearsBobsCurse(tear)
    if not settings.bobs_curse then
        return
    end
    if not tear.SpawnerEntity then
        return
    end
    local player = tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(BobsCurseItem) then
            local copyCount = player:GetCollectibleNum(BobsCurseItem) - 1
            if copyCount > 0 then
                if not tear:HasTearFlags(TearFlags.TEAR_POISON) then
                    if math.random() < 0.15 * copyCount then
                        tear:AddTearFlags(TearFlags.TEAR_POISON)
                        local poisonColor = Color(0, 1, 0, 1, 0, 0, 0)
                        tear.Color = poisonColor
                    end
                end
            end
        end
    end
end

--- MonstranceItem stacking - Increases aura size and applies slow to enemies inside
--- @param player EntityPlayer
function mod:onPlayerUpdateMonstrance(player)
    if not settings.monstrance then
        return
    end

    if player:HasCollectible(MonstranceItem) then
        local copyCount = player:GetCollectibleNum(MonstranceItem) - 1
        if copyCount > 0 then
            for _, entity in pairs(Isaac.GetRoomEntities()) do
                if entity.Type == 1000 and entity.Variant == EffectVariant.HALO then
                    local scaleMultiplier = 1 + (0.2 * copyCount)
                    entity.SpriteScale = Vector(scaleMultiplier, scaleMultiplier)

                    local baseRadius = 100
                    local expandedRadius = baseRadius * scaleMultiplier

                    local currentFrame = Game():GetFrameCount()

                    local enemies = Isaac.FindInRadius(entity.Position, expandedRadius, EntityPartition.ENEMY)
                    for _, enemy in ipairs(enemies) do
                        if enemy:IsVulnerableEnemy() then
                            enemy:AddSlowing(EntityRef(player), 30, 0.6, Color(0.5, 0.5, 1, 1, 0, 0, 0))
                            local distance = entity.Position:Distance(enemy.Position)
                            if distance > baseRadius then
                                if (currentFrame + enemy.Index) % 4 == 0 then
                                    enemy:TakeDamage(0.4, 0, EntityRef(player), 0)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

--- BFFSItem stacking - Increases familiar size and damage
--- @param familiar EntityFamiliar
function mod:onFamiliarUpdateBFFS(familiar)
    if not settings.bffs then
        return
    end
    local player = familiar.Player
    if not player then return end
    if player:HasCollectible(BFFSItem) then
        local copyCount = player:GetCollectibleNum(BFFSItem) - 1
        if copyCount > 0 then
            familiar.SpriteScale = Vector(1 + 0.2*copyCount, 1 + 0.2*copyCount)
            if familiar.CollisionDamage > 0 then
                if not trackedFamiliars[familiar.InitSeed] then
                    trackedFamiliars[familiar.InitSeed] = familiar.CollisionDamage
                end
                familiar.CollisionDamage = trackedFamiliars[familiar.InitSeed] * (1 + 0.25 * copyCount)
            end
        end
    end
end

--- BFFSItem stacking - Increases familiar size and damage
--- @param tear EntityTear
function mod:onFamiliarTearInit(tear)
    if not settings.bffs then
        return
    end
    local spawner = tear.SpawnerEntity
    if spawner and spawner:ToFamiliar() then
        local familiar = spawner:ToFamiliar()
        if familiar then
            local player = familiar.Player
            if player and player:HasCollectible(BFFSItem) then
                trackedTears[tear.InitSeed] = {
                    player = player,
                    copies = player:GetCollectibleNum(BFFSItem) - 1
                }
            end
        end
    end
end

--- BFFSItem stacking - Increases familiar size and damage
--- @param tear EntityTear
function mod:onFamiliarTearUpdate(tear)
    if not settings.bffs then
        return
    end
    local data = trackedTears[tear.InitSeed]
    if data then
        local copyCount = data.copies
        if copyCount > 0 then
            tear.CollisionDamage = tear.CollisionDamage * (1 + 0.25 * copyCount)
            tear.Scale = tear.Scale * (1 + 0.1 * copyCount)
            tear.Position = tear.Position + Vector(0, -6*copyCount)
        end
        trackedTears[tear.InitSeed] = nil
    end
end

--- BFFSItem stacking - Increases familiar size and damage
--- @param laser EntityLaser
function mod:onFamiliarLaserInit(laser)
    if not settings.bffs then
        return
    end
    local spawner = laser.SpawnerEntity
    if spawner and spawner:ToFamiliar() then
        local familiar = spawner:ToFamiliar()
        if familiar then
            local player = familiar.Player
            if player and player:HasCollectible(BFFSItem) then
                local copyCount = player:GetCollectibleNum(BFFSItem) - 1
                trackedLasers[laser.InitSeed] = {
                    player = player,
                    copies = copyCount
                }
                laser.Position = laser.Position + Vector(0, -6*copyCount)
            end
        end
    end
end

--- BFFSItem stacking - Increases familiar size and damage
--- @param laser EntityLaser
function mod:onFamiliarLaserUpdate(laser)
    if not settings.bffs then
        return
    end
    local data = trackedLasers[laser.InitSeed]
    if data then
        local copyCount = data.copies
        if copyCount > 0 then
            laser.CollisionDamage = laser.CollisionDamage * (1 + 0.25 * copyCount)
            laser.SpriteScale = laser.SpriteScale * (1 + 0.2 * copyCount)
        end
        trackedLasers[laser.InitSeed] = nil
    end
end

--- VengefulSpiritItem Stacking - Adds extra wisp on hit and increases max number to 26
--- @param entity Entity
function mod:onDamageVengefulSpirit(entity)
    if not settings.vengeul_spirit then
        return
    end
    local player = entity:ToPlayer()
    if player then
        if player:HasCollectible(VengefulSpiritItem) then
            local copyCount = player:GetCollectibleNum(VengefulSpiritItem) - 1
            if copyCount > 0 then
                for i=1, copyCount, 1 do
                    player:AddWisp(VengefulSpiritItem, player.Position, true)
                end
            end
        end
    end
end

--- PurgatoryItem Stacking - Adds extra purgatory crack on the floor
function mod:onUpdatePurgatory()
    for i = 0, Game():GetNumPlayers() - 1 do
        if not settings.purgatory then
            return
        end
        local player = Isaac.GetPlayer(i)
        local copyCount = player:GetCollectibleNum(PurgatoryItem) - 1

        if copyCount <= 0 then return end

        local room = Game():GetRoom()
        local purgatoryEffects = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY)

        if not room:IsClear() and #purgatoryEffects <= 1 then
            for i = 0, copyCount do
                local validPosition = nil
                local attempts = 0
                repeat
                    local randomPos = room:GetRandomPosition(10)
                    if mod:isValidPurgatoryPosition(randomPos) then
                        validPosition = randomPos
                    end
                    attempts = attempts + 1
                until validPosition or attempts > 20
                if validPosition then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 0, validPosition, Vector.Zero, player)
                end
            end
        end
    end
end

--- PurgatoryItem Stacking - Always spawn the crack on an empty floor tile
--- @param position Vector
--- @return boolean
function mod:isValidPurgatoryPosition(position)
    local room = Game():GetRoom()
    local gridIndex = room:GetGridIndex(position)
    local gridEntity = room:GetGridEntity(gridIndex)

    if gridEntity and (gridEntity.Desc.Type ~= GridEntityType.GRID_NULL and gridEntity.Desc.Type ~= GridEntityType.GRID_DECORATION) then
        return false
    end

    for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY)) do
        if entity.Position:DistanceSquared(position) < 25 then
            return false
        end
    end

    return true
end

--- HiveMindItem stacking - Increases familiar size and damage
--- @param familiar EntityFamiliar
function mod:onFamiliarUpdateHiveMind(familiar)
    if not settings.bffs then
        return
    end
    local player = familiar.Player
    if not player then return end
    if player:HasCollectible(HiveMindItem) and hiveMindFamiliars[familiar.Variant] then
        local copyCount = player:GetCollectibleNum(HiveMindItem) - 1
        if copyCount > 0 then
            familiar.SpriteScale = Vector(1 + 0.2*copyCount, 1 + 0.2*copyCount)
            if familiar.CollisionDamage > 0 then
                if not trackedFamiliarsHiveMind[familiar.InitSeed] then
                    trackedFamiliarsHiveMind[familiar.InitSeed] = familiar.CollisionDamage
                end
                familiar.CollisionDamage = trackedFamiliarsHiveMind[familiar.InitSeed] * (1 + 0.2 * copyCount)
            end
        end
    end
end

-- BoneSpursItem Stacking will spawn a new bone for each extra copy when killing an enemy
---@param entity Entity
function mod:onEnemyKillBoneSpurs(entity)
    if not settings.bone_spurs then
        return
    end
    if not entity:IsEnemy() or entity:IsBoss() then
        return
    end

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if not player:HasCollectible(BoneSpursItem) then return end

        local copyCount = player:GetCollectibleNum(BoneSpursItem) - 1

        if copyCount > 0 then
            for i = 1, copyCount do
                local spawnPosition = entity.Position + Vector(math.random(-20, 20), math.random(-20, 20))
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, spawnPosition, Vector.Zero, player)
            end
        end

    end
end

--- PoundOfFleshItem Stacking - Reduces devil deals costs by 50% per extra copy
function mod:onDevilDealPoundOfFlesh()
    if not settings.pound_of_flesh then
        return
    end
    local room = Game():GetRoom()

    if room:GetType() ~= RoomType.ROOM_DEVIL then
        return
    end
    if devil_price_updated == false then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local pickup = entity:ToPickup()
                if pickup then
                    for i = 0, Game():GetNumPlayers() - 1 do
                        local player = Isaac.GetPlayer(i)
                        if player:HasCollectible(PoundOfFleshItem) then
                            local copyCount = player:GetCollectibleNum(PoundOfFleshItem) - 1
                            if copyCount > 0 then
                                local basePrice = pickup.Price
    
                                local newPrice = math.max(math.floor(basePrice / (2 ^ copyCount)), 1)
    
                                pickup.AutoUpdatePrice = false
                                pickup.Price = newPrice
                            end
                        end
                    end
                end
            end
        end
        devil_price_updated = true
    end
end

--- Stacking PoundOfFleshItem will refresh the cost on ìtem pickup
--- @param type CollectibleType
function mod:onPoundFleshPickup(type)
    if not settings.pound_of_flesh then
        return
    end
    if type == CollectibleType.COLLECTIBLE_POUND_OF_FLESH then
        devil_price_updated = false
    end
end

--- DeadBirdItem Stacking - Spawns extra dead bird familiar when taking damage
--- @param entity Entity
function mod:onDamageDeadBird(entity)
    if not settings.dead_bird then
        return
    end
    local player = entity:ToPlayer()
    if player then
        if player:HasCollectible(DeadBirdItem) then
            local copyCount = player:GetCollectibleNum(DeadBirdItem) - 1
            if copyCount > 0 and spawn_dead_bird[player.Index + 1] == true then
                for i=1, copyCount, 1 do
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEAD_BIRD, 0, player.Position, Vector.Zero, player)
                end
                spawn_dead_bird[player.Index + 1] = false
            end
        end
    end
end

--- DeadBirdItem Stacking - Resets damage taken on new room
function mod:onNewRoomDeadBird()
    if not settings.dead_bird then
        return
    end
    spawn_dead_bird = {true, true, true, true, true, true, true, true}
end

--- FannyPackItem Stacking - Spawns extra pickups when taking damage
--- @param entity Entity
function mod:onDamageFannyPack(entity)
    if not settings.fanny_pack then
        return
    end
    local player = entity:ToPlayer()
    if player then
        if player:HasCollectible(FannyPackItem) then
            local copyCount = player:GetCollectibleNum(FannyPackItem) - 1
            if copyCount > 0 then
                for i = 1, copyCount do
                    if math.random() < 0.5 then
                        local pickup = pickupTypes[math.random(#pickupTypes)]
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup[1], pickup[2][math.random(#pickup[2])], Vector(player.Position.X + math.random(-20, 20), player.Position.Y + math.random(-20, 20)), Vector.Zero, player)
                    end
                end
            end
        end
    end
end

--- MrMegaItem Stacking - Increases bomb damage by 25%
--- @param bomb EntityBomb
function mod:onBombMrMega(bomb)
    local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
    if not player then return end

    local copies = player:GetCollectibleNum(MrMegaItem) - 1
    if copies < 1 then return end

    local extraMultiplier = 1 + (copies * 0.25)
    bomb.ExplosionDamage = bomb.ExplosionDamage * extraMultiplier
end

--- Stacking BirdsEyeItem will increase fire size and damage
--- @param entity Entity
function mod:onPlayerRedFireSpawn(entity)
    if not settings.birds_eye then
        return
    end
    if entity.Variant ~= EffectVariant.RED_CANDLE_FLAME then return end

    local player = entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(BirdsEyeItem) then return end
    local copyCount = player:GetCollectibleNum(BirdsEyeItem) - 1
    if copyCount > 0 and not trackedFires[entity.InitSeed] then
        entity.SpriteScale = Vector(copyCount * 0.5 + 1, copyCount * 0.5 + 1)
        entity.CollisionDamage = entity.CollisionDamage * (1 + 0.25* copyCount)
        trackedFires[entity.InitSeed] = true
    end
end

--- Stacking GhostPepperItem will increase fire size and damage
--- @param entity Entity
function mod:onPlayerBlueFireSpawn(entity)
    if not settings.ghost_pepper then
        return
    end
    if entity.Variant ~= EffectVariant.BLUE_FLAME then return end

    local player = entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(GhostPepperItem) then return end
    local copyCount = player:GetCollectibleNum(GhostPepperItem) - 1
    if copyCount > 0 and not trackedFires[entity.InitSeed] then
        entity.SpriteScale = Vector(copyCount * 0.5 + 1, copyCount * 0.5 + 1)
        entity.CollisionDamage = entity.CollisionDamage * (1 + 0.25* copyCount)
        trackedFires[entity.InitSeed] = true
    end
end

-- Stacking BrittleBonesItem will further reduce tear_delay when losing bone heart
--- @param entity Entity
function mod:onPlayerDamageBrittleBones(entity)
    local player = entity:ToPlayer()
    if player then
        if player:GetBoneHearts() < boneHearts then
            local copies = player:GetCollectibleNum(BrittleBonesItem) - 1
            local extraTears = copies * 1
            player.MaxFireDelay = player.MaxFireDelay - extraTears
        end
    end
end
-- Stacking BrittleBonesItem will further reduce tear_delay when losing bone heart
--- @param entity Entity
function mod:prePlayerDamageBrittleBones(entity)
    local player = entity:ToPlayer()
    if player then
        local copies = player:GetCollectibleNum(BrittleBonesItem) - 1
        if copies > 0 then boneHearts = player:GetBoneHearts() end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, mod.onPlayerDamageBrittleBones, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.prePlayerDamageBrittleBones, EntityType.ENTITY_PLAYER)


mod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, mod.onMomsPursePickup)
mod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, mod.onPoundFleshPickup)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.OnPlayerGetsPill, MomsBottleOfPillsItem)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onUpdateHorsePills)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdateScapular)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdateAnemic)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdateToxicShockBoss)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdateSpelunkerHat)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.postUpdateGnawedLeaf)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdateBallOfTar)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdateAquarius)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdatePurgatory)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onDevilDealPoundOfFlesh)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.onPlayerUpdateMonstrance)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamage, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, mod.onPlayerCollisionGnawedLeaf)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageGC, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageCO, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageInfestation, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageBloodyLust, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageBloodyGust, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageScapular, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageVengefulSpirit, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageDeadBird, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageFannyPack, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamageBossHungrySoul)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.onPlayerRedFireSpawn)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.onPlayerBlueFireSpawn)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.onDamageDealtMysteriousLiquid)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onKillEnemy)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onKillInfestationTwo)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onKillJumperCables)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onKillEnemyLustyBlood)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onKillEnemyHungrySoul)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onEnemyKillBoneSpurs)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onTearInitChocoMilk)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsCE)
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.onFireLaserCE)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsLH)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsEyeSores)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsLingerBean)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsTinyPlanet)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsSerpentsKiss)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsPupulaDuplex)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsBallOfTar)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onFireTearsBobsCurse)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mod.onFamiliarTearInit)
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.onFamiliarLaserInit)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_UPDATE, mod.onTearCollideFlatStone)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.onFamiliarTearUpdate)
mod:AddCallback(ModCallbacks.MC_PRE_LASER_UPDATE, mod.onFamiliarLaserUpdate)
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.onTearUpdateGodHead)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.onUseItemCB)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.onUseItemNineVolt)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.onUseItemSchoolbag)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloorIT)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloorCR)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloorEmptyHeart)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloorSpelunkerHat)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloor)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.evaluateCache)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.onEvaluateCacheChocoMilk)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.evaluateCacheWhoreOfBabylon)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoomXRV)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoomStairway)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoomToxicShock)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoomDeadBird)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.onClearXRV)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.onClearGT)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, mod.onBombNumber2)
mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, mod.onBombMrMega)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onFamiliarUpdateBFFS)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onFamiliarUpdateHiveMind)

mod:setupMyModConfigMenuSettings()