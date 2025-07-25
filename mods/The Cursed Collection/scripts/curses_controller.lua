-- CURCOL.CURSES = {
--     Isaac.GetCurseIdByName("Curse of Decay"),
--     Isaac.GetCurseIdByName("Curse of Famine"),
--     Isaac.GetCurseIdByName("Curse of Blight"),
--     Isaac.GetCurseIdByName("Curse of Conquest"),
--     Isaac.GetCurseIdByName("Curse of Isolation"),
--     Isaac.GetCurseIdByName("Curse of Rebirth"),
--     Isaac.GetCurseIdByName("Curse of Creation")
-- }
local json = require("json")

CURCOL.CURSES_CONFIG = {
    DECAY_CHANCE = 20,
    CONQUEST_CHANCE = 50,
    ISOLATION_CHANCE = 30,
    ISOLATION_COL_CHANCE = 60,
    ISOLATION_ENT_CHANCE = 80,
    REBIRTH_CHANCE = 35,
    CREATION_CHANCE = 65,

    NOTIF_EFF = Isaac.GetEntityVariantByName("CURCOL Notify effect"),
    BLIGHT_EFF = Isaac.GetEntityVariantByName("CURCOL blight effect"),
    CREATION_EFF = Isaac.GetEntityVariantByName("CURCOL creation effect"),

    CREATION_SFX = Isaac.GetSoundIdByName("CURCOL_CREATION"),

    BLIGHT_IG = Isaac.GetItemIdByName("Veil of darkness")
}

local curseIcons = Sprite()
curseIcons:Load("gfx/ui/CURCOL_curse_icons.anm2", true)

local famineList = {
    [PickupVariant.PICKUP_HEART] = {
        [HeartSubType.HEART_FULL] = { SubType = HeartSubType.HEART_HALF },
        [HeartSubType.HEART_SOUL] = { SubType = HeartSubType.HEART_HALF_SOUL },
        [HeartSubType.HEART_DOUBLEPACK] = { SubType = HeartSubType.HEART_HALF },
        [HeartSubType.HEART_BLENDED] = { SubType = HeartSubType.HEART_HALF_SOUL }
    },
    [PickupVariant.PICKUP_COIN] = {
        [CoinSubType.COIN_DOUBLEPACK] = { SubType = CoinSubType.COIN_PENNY },
        [CoinSubType.COIN_NICKEL] = { SubType = { CoinSubType.COIN_STICKYNICKEL, CoinSubType.COIN_PENNY } },
        [CoinSubType.COIN_DIME] = { SubType = CoinSubType.COIN_NICKEL }
    },
    [PickupVariant.PICKUP_BOMB] = {
        [BombSubType.BOMB_DOUBLEPACK] = { SubType = BombSubType.BOMB_NORMAL },
        [BombSubType.BOMB_NORMAL] = { Chance = 25, SubType = BombSubType.BOMB_TROLL }
    },
    [PickupVariant.PICKUP_POOP] = {
        [PoopPickupSubType.POOP_BIG] = { SubType = PoopPickupSubType.POOP_SMALL }
    },
    [PickupVariant.PICKUP_LIL_BATTERY] = {
        [BatterySubType.BATTERY_NORMAL] = { SubType = BatterySubType.BATTERY_MICRO },
        [BatterySubType.BATTERY_MEGA] = { SubType = BatterySubType.BATTERY_NORMAL }
    },
    [PickupVariant.PICKUP_CHEST] = {
        [1] = { Chance = 50, Variant = { PickupVariant.PICKUP_MIMICCHEST, PickupVariant.PICKUP_HAUNTEDCHEST } }
    }
}

-- if RepentancePlusMod then
--     famineList[PickupVariant.PICKUP_HEART][86] = { SubType = HeartSubType.HEART_HALF }
--     famineList[PickupVariant.PICKUP_HEART][89] = { SubType = HeartSubType.HEART_HALF }
--     famineList[PickupVariant.PICKUP_HEART][90] = { SubType = HeartSubType.HEART_HALF }
--     famineList[PickupVariant.PICKUP_HEART][91] = { SubType = HeartSubType.HEART_BLACK }
--     famineList[PickupVariant.PICKUP_HEART][97] = { SubType = HeartSubType.HEART_ETERNAL }
--     famineList[PickupVariant.PICKUP_HEART][98] = { SubType = HeartSubType.HEART_HALF_SOUL }
--     famineList[PickupVariant.PICKUP_HEART][100] = { SubType = HeartSubType.HEART_HALF }
-- end

local conquestWhitelist = { -- Most enemies that can be champions because i can't read the entities2.xml config via the api i think :(
    [10] = true, [11] = true, [12] = true, [14] = true, [15] = true, [16] = true, [21] = true, [22] = true, [23] = true, [24] = true, [25] = true, [26] = true, [27] = true, [29] = true, [30] = true, [31] = true, [32] = true, [34] = true, [38] = true,
    [39] = true, [40] = true, [41] = true, [51] = true, [53] = true, [54] = true, [55] = true, [56] = true, [57] = true, [58] = true, [59] = true, [60] = true, [61] = true, [86] = true, [87] = true, [88] = true, [91] = true, [204] = true, [205] = true,
    [206] = true, [207] = true, [208] = true, [209] = true, [210] = true, [213] = true, [214] = true, [220] = true, [224] = true, [225] = true, [226] = true, [227] = true, [229] = true, [230] = true, [234] = true, [237] = true,
    [238] = true, [240] = true, [241] = true, [242] = true, [243] = true, [244] = true, [246] = true, [247] = true, [248] = true, [249] = true, [250] = true, [252] = true, [253] = true, [254] = true, [255] = true, [257] = true,
    [258] = true, [259] = true, [260] = true, [276] = true, [277] = true, [278] = true, [279] = true, [280] = true, [282] = true, [283] = true, [284] = true, [288] = true, [289] = true, [290] = true, [298] = true, --[297] = true
    [299] = true, [300] = true, [301] = true, [303] = true, [304] = true, [305] = true, [307] = true, [308] = true, [309] = true, [310] = true, [803] = true, [806] = true, [807] = true, [811] = true, [812] = true, [813] = true,
    [816] = true, [817] = true, [819] = true, [820] = true, [821] = true, [822] = true, [823] = true, [824] = true, [825] = true, [826] = true, [828] = true, [829] = true, [830] = true, [831] = true, [832] = true, [833] = true,
    [834] = true, [836] = true, [839] = true, [840] = true, [841] = true, [843] = true, [844] = true, [850] = true, [851] = true, [854] = true, [856] = true, [857] = true, [858] = true, [859] = true, [860] = true, [861] = true,
    [862] = true, [863] = true, [869] = true, [872] = true, [873] = true, [874] = true, [875] = true, [876] = true, [878] = true, [879] = true, [880] = true, [881] = true, [882] = true, [883] = true, [886] = true, [889] = true,
    [890] = true, [891] = true
}

local isolationBlacklist = {
    [851] = true, [876] = true, [808] = true, [856] = true, [300] = true, [30] = true,  [298] = true,
    [309] = true, [861] = true, [35] = true,  [216] = true, [311] = true, [834] = true, [56] = true,
    [307] = true, [58] = true,  [60] = true,  [835] = true, [886] = true, [213] = true, [287] = true,
    [838] = true, [221] = true, [841] = true, [805] = true, [244] = true, [240] = true, [241] = true,
    [242] = true, [304] = true, [255] = true, [276] = true, [289] = true, [825] = true, [829] = true,
    [306] = true,
}

local creationWhitelist = {
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCK_ALT] = true,
    [GridEntityType.GRID_ROCK_SS] = true,
    [GridEntityType.GRID_ROCK_SPIKED] = true,
    [GridEntityType.GRID_ROCK_ALT2] = true,
    [GridEntityType.GRID_ROCK_GOLD] = true,
}

local creationSpecialRocks = {
    GridEntityType.GRID_ROCKT,
    GridEntityType.GRID_ROCK_GOLD
}

local creationDoorSets = {
    [1] = { DoorSlot.LEFT0, DoorSlot.UP0, DoorSlot.RIGHT0, DoorSlot.DOWN0 }, -- Square
    [2] = { DoorSlot.LEFT0, DoorSlot.RIGHT0 }, -- Short horizontal
    [3] = { DoorSlot.UP0, DoorSlot.DOWN0 }, -- Short vertical
    [4] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.UP0, DoorSlot.DOWN0 }, -- Double vertical
    [5] = { DoorSlot.UP0, DoorSlot.DOWN0 }, -- Long vertical
    [6] = { DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- Double horizontal
    [7] = { DoorSlot.LEFT0, DoorSlot.RIGHT0 }, -- Long horizontal
    [8] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- Square large
    [9] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- LTL
    [10] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- LTR
    [11] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- LBL
    [12] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- LBR
}

local decayWhitelist = {
    [PickupVariant.PICKUP_PILL] = true,
    [PickupVariant.PICKUP_TAROTCARD] = true,
    [PickupVariant.PICKUP_TRINKET] = true,

    [PickupVariant.PICKUP_HEART] = true,
    [PickupVariant.PICKUP_COIN] = true,
    [PickupVariant.PICKUP_KEY] = true,
    [PickupVariant.PICKUP_BOMB] = true,
    [PickupVariant.PICKUP_POOP] = true,
    [PickupVariant.PICKUP_GRAB_BAG] = true,
    [PickupVariant.PICKUP_LIL_BATTERY] = true,

    [PickupVariant.PICKUP_CHEST] = true,
    [PickupVariant.PICKUP_BOMBCHEST] = true,
    [PickupVariant.PICKUP_SPIKEDCHEST] = true,
    [PickupVariant.PICKUP_ETERNALCHEST] = true,
    [PickupVariant.PICKUP_MIMICCHEST] = true,  
    [PickupVariant.PICKUP_OLDCHEST] = true,
    [PickupVariant.PICKUP_WOODENCHEST] = true,
    [PickupVariant.PICKUP_MEGACHEST] = true,
    [PickupVariant.PICKUP_HAUNTEDCHEST] = true,
    [PickupVariant.PICKUP_LOCKEDCHEST] = true,
    [PickupVariant.PICKUP_REDCHEST] = true
}

local failedCurseFrame = -1

--[[##########################################################################
############################### MOD CONFIG MENU ##############################
##########################################################################]]--
-- if ModConfigMenu then
--     local ModName = "Cursed Collection"
--     ModConfigMenu.UpdateCategory(ModName, { Info = {"Settings for enabling and disabling the natural appearance of curses."} })
-- end

local function InitCurse(name, key, frame, enable, disable)
    local id = Isaac.GetCurseIdByName("Curse of " .. name)

    if id > 0 then
        local value = true

        if ModConfigMenu then
            value = CURCOL.SAVEDATA[key]  
            ModConfigMenu.AddSetting("Cursed Collection", "Curses", {
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function() return CURCOL.SAVEDATA[key] end,
                OnChange = function(currentBool) 
                    CURCOL.SAVEDATA[key] = currentBool
                    CURCOL:SaveData(json.encode(CURCOL.SAVEDATA))
                    TCC_API:ToggleCurse(id, CURCOL.SAVEDATA[key])
                end,
                Info = {"Enable the natural occurence of curse of " .. name .. "?"},
                Display = function()
                    local onOff = "False"
                    if CURCOL.SAVEDATA[key] then onOff = "True" end
                    return "Enable Curse of " .. name .. ": " .. onOff
                end
            })
        end

        TCC_API:AddTCCCurse(id, enable, disable, value, curseIcons, frame)
    else
        local frameDiff = frame - failedCurseFrame

        if frameDiff > 10 or failedCurseFrame == -1 then
            failedCurseFrame = frame
            print('THE COLLECTION: One or more curses failed to load! Try restarting your game to fix this.')
        end
    
        Isaac.DebugString('THE COLLECTION: Curse of ' .. name .. ' failed to load! GetCurseIdByName returned ' .. tostring(id) .. ' under the name "Curse of ' .. name .. '"')
    end
end

--[[##########################################################################
############################# CURSES OF FAMINE ###############################
##########################################################################]]--
local function devourItem(pickup, newType, newVariant, newSubType, RNG)
    pickup:Remove()

    if type(newVariant) == 'table' then newVariant =  newVariant[RNG:RandomInt(#newVariant)+1] end
    if type(newSubType) == 'table' then newSubType =  newSubType[RNG:RandomInt(#newSubType)+1] end

    pickup:Morph(newType, newVariant, newSubType, true, true, false)
    pickup:SetColor(Color(0.8,0.8,0.8,1,0.30,0,0.45), 60, 100, true, true)

    local eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.NOTIF_EFF, 0, pickup.Position-Vector(0, 65), pickup.Velocity, pickup):ToEffect()
    eff.DepthOffset = pickup.Position.Y + 10
    eff:FollowParent(pickup)
    eff:GetSprite():Play('Famine')

    if not CURCOL.SFX:IsPlaying(SoundEffect.SOUND_POISON_HURT) then CURCOL.SFX:Play(SoundEffect.SOUND_POISON_HURT, 1, 0, false, 0.8) end
end

local function OnLootFamine(_, pickup)
    if pickup.Variant == 350 then
        if pickup.SubType >= 32768 then
            devourItem(pickup, pickup.Type, pickup.Variant, pickup.SubType-32768)
        end
    elseif pickup.Variant ~= 100 then
        local selection = famineList[pickup.Variant]

        if selection and selection[pickup.SubType] ~= nil then
            local subselection = selection[pickup.SubType]

            local RNG = RNG()
            RNG:SetSeed(pickup:GetDropRNG():GetSeed(), 1)

            if not subselection.Chance or RNG:RandomInt(100)+1 <= subselection.Chance then
                devourItem(pickup, subselection.Type or pickup.Type, subselection.Variant or pickup.Variant, subselection.SubType or pickup.SubType, RNG)
            end
        end
    end
end

InitCurse("Famine", "ENABLE_FAMINE", 3, 
    function() TCC_API:AddTCCCallback("TCC_ON_SPAWN", OnLootFamine)    end,
    function() TCC_API:RemoveTCCCallback("TCC_ON_SPAWN", OnLootFamine) end
)

--[[##########################################################################
############################## CURSES OF DECAY ###############################
##########################################################################]]--
local function OnLootDecay(_, pickup)
    if decayWhitelist[pickup.Variant] then
        local RNG = RNG()
        RNG:SetSeed(pickup:GetDropRNG():GetSeed(), 1)

        if RNG:RandomInt(100)+1 <= CURCOL.CURSES_CONFIG.DECAY_CHANCE then
            pickup.Timeout = math.random(55)+60
            -- pickup:GetSprite().Scale = Vector(1.1, 1.1)
            pickup:SetColor(Color(0.8,0.8,0.8,1,0.10,0,0.25), -1, 101, false, true)
            local eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.NOTIF_EFF, 0, pickup.Position-Vector(0, 65), pickup.Velocity, pickup):ToEffect()
            eff:FollowParent(pickup)
            eff.DepthOffset = pickup.Position.Y + 10

            if not CURCOL.SFX:IsPlaying(SoundEffect.SOUND_JELLY_BOUNCE) then CURCOL.SFX:Play(SoundEffect.SOUND_JELLY_BOUNCE, 1, 5) end
        end
    end
end

InitCurse("Decay", "ENABLE_DECAY", 0,
    function() TCC_API:AddTCCCallback("TCC_ON_SPAWN", OnLootDecay)    end,
    function() TCC_API:RemoveTCCCallback("TCC_ON_SPAWN", OnLootDecay) end
)

--[[##########################################################################
############################### CURSE OF BLIGHT ##############################
##########################################################################]]--
function CURCOL:Blight(pickup)
    if pickup.SubType > 0 and not pickup:GetData().CURCOL_BLIGHTED then
        local sprite = pickup:GetSprite()
        local curAnim = "idle"
        local overlay = sprite:GetOverlayFrame()
        for _, anim in pairs({"Idle","Empty","ShopIdle","Alternates"}) do
            if sprite:IsPlaying(anim) then curAnim = anim; break end
        end
        
        sprite:Load("gfx/animations/CURCOL_blight.anm2")

        local flag = LevelCurse.CURSE_OF_BLIND
        if (CURCOL.GAME:GetLevel():GetCurses() % (flag + flag)) >= flag then
            sprite:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
        else
            sprite:ReplaceSpritesheet(1,CURCOL.CONF:GetCollectible(pickup.SubType).GfxFileName)
        end
        
        sprite:LoadGraphics()
        sprite:Play(curAnim,true)

        if pickup:ToPickup():IsShopItem() then
            sprite:SetOverlayFrame("ShopIdle",overlay)
        else
            sprite:SetOverlayFrame("Alternates",overlay)
        end

        CURCOL.GAME:Darken(1, 20)

        local eff = Isaac.Spawn(1000, 16, -1, pickup.Position, Vector(0,0), pickup)
        eff:SetColor(Color(0,0,0,1,0,0,0), -1, 101, false, true)

        pickup:GetData().CURCOL_BLIGHTED = true
    end
end

local function OnColInit(_, pickup) CURCOL:Blight(pickup) end

if EID then
    function EID:hasCurseBlind()
        local curses = Game():GetLevel():GetCurses()
        local flag = 2^(Isaac.GetCurseIdByName("Curse of Blight")-1)

        return curses & LevelCurse.CURSE_OF_BLIND > 0 or curses % (flag + flag) >= flag
    end
end

local function HandleAnimCollectible(_, animation)
    local isMirrored = false

    if animation.SpawnerEntity and animation.SpawnerEntity:GetData().SEWCOL_MIRRORED then
        isMirrored = true
    end

    animation:SetColor(Color(0,0,0,(isMirrored and 0.5 or 1),0,0,0), -1, 100, false, true)
end

function CURCOL:OnBlightSlotInit()
    for _, slot in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT, 16, -1, false, true)) do
        slot:SetColor(Color(0,0,0,1,0,0,0), -1, 100, false, true)
    end
end

function CURCOL:OnBlightSlotRender(slot)
    slot:SetColor(Color(0,0,0,1,0,0,0), -1, 100, false, true)
    if slot.FrameCount % 10 == 0 then
        if slot.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND then CURCOL.GAME:Darken(1, 20) end

        local eff
        local selection = math.random(10)

        if selection > 4 then
            local offset = math.random(8)*(math.random(2) > 1 and -1 or 1)
            eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.BLIGHT_EFF, 0, slot.Position+Vector(offset, 0), Vector(0,0), slot):GetSprite()
            eff.PlaybackSpeed = math.random(30, 100)/100
            local scale = math.random(100, 160)/100
            eff.Scale = Vector(scale, scale)
        else
            local offset = math.random(10)*(math.random(2) > 1 and -1 or 1)
            eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.BLIGHT_EFF, 0, slot.Position+Vector(offset, 0), Vector(0,0), slot):GetSprite()
            eff.FlipX = (math.random(2) > 1 and true or false)
            local scale = math.random(70, 110)/100
            eff.Scale = Vector(scale, scale)
        end

        eff:Play('Overlay' .. selection)
    end
end

function CURCOL:OnBlightRender(pickup, ignore)
	if pickup.FrameCount % 10 == 0 and (pickup.SubType ~= CURCOL.CURSES_CONFIG.BLIGHT_IG or ignore) then
        if pickup.Variant ~= 100 or pickup.SubType ~= 0 then CURCOL.GAME:Darken(1, 20) end

        local eff
        local selection = math.random(10)
        local isShop = pickup:IsShopItem()

        if selection > 4 then
            local offset = math.random(8)*(math.random(2) > 1 and -1 or 1)
            eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.BLIGHT_EFF, 0, pickup.Position+Vector(offset, isShop and -5 or 0), Vector(0,0), pickup):GetSprite()
            eff.PlaybackSpeed = math.random(30, 100)/100
            local scale = math.random(100, 160)/100
            eff.Scale = Vector(scale, scale)
        else
            local offset = isShop and 0 or math.random(10)*(math.random(2) > 1 and -1 or 1)
            eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.BLIGHT_EFF, 0, pickup.Position+Vector(offset, isShop and -8 or 0), Vector(0,0), pickup):GetSprite()
            eff.FlipX = (math.random(2) > 1 and true or false)
            local scale = math.random(70, 110)/100
            eff.Scale = Vector(scale, scale)
        end

        eff:Play('Overlay' .. selection)
    end
end

InitCurse("Blight", "ENABLE_BLIGHT", 4, 
    function() 
        CURCOL:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, OnColInit, 100)
        CURCOL:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, CURCOL.OnBlightRender, 100)
        CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, CURCOL.OnBlightSlotInit)
        TCC_API:AddTCCCallback("TCC_SLOT_UPDATE", CURCOL.OnBlightSlotRender, 16)

        if AnimatedItemsAPI then
            CURCOL:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, HandleAnimCollectible, Isaac.GetEntityVariantByName("Pedestal Animation"))
        end

        for key, pickup in pairs(Isaac.FindByType(5, 100)) do CURCOL:Blight(pickup) end

        for _, slot in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT, 16, -1, false, true)) do
            slot:SetColor(Color(0,0,0,1,0,0,0), -1, 100, false, true)
        end
    end,
    function() 
        CURCOL:RemoveCallback(ModCallbacks.MC_POST_PICKUP_INIT, OnColInit, 100)
        CURCOL:RemoveCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, CURCOL.OnBlightRender, 100)
        CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, CURCOL.OnBlightSlotInit)
        TCC_API:RemoveTCCCallback("TCC_SLOT_UPDATE", CURCOL.OnBlightSlotRender, 16)

        if AnimatedItemsAPI then
            CURCOL:RemoveCallback(ModCallbacks.MC_POST_EFFECT_INIT, HandleAnimCollectible, Isaac.GetEntityVariantByName("Pedestal Animation"))
        end
    end
)

--[[##########################################################################
############################## CURSE OF CONQUEST #############################
##########################################################################]]--
local function OnNPCSpawn(_, NPC)
    if (conquestWhitelist[NPC.Type] or conquestWhitelist[NPC.Type..'.'..NPC.Variant]) and not NPC:IsChampion() and NPC:GetDropRNG():RandomInt(100)+1 <= CURCOL.CURSES_CONFIG.CONQUEST_CHANCE then
        -- if type(conquestWhitelist[NPC.Type]) == 'table' and not conquestWhitelist[NPC.Type][NPC.Variant] then return end

        NPC:MakeChampion(NPC.InitSeed, -1, true)
        local eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.NOTIF_EFF, 0, NPC.Position-Vector(0, 65), Vector(0,0), NPC):ToEffect()
        eff:FollowParent(NPC)
        eff.DepthOffset = NPC.Position.Y + 10
        eff:GetSprite():Play('Conquest')

        if not CURCOL.SFX:IsPlaying(SoundEffect.SOUND_KNIFE_PULL) then CURCOL.SFX:Play(SoundEffect.SOUND_KNIFE_PULL, 1, 0, false, 0.8) end
    end
end

InitCurse("Conquest", "ENABLE_CONQ", 2, 
    function() CURCOL:AddCallback(ModCallbacks.MC_POST_NPC_INIT, OnNPCSpawn)    end, 
    function() CURCOL:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, OnNPCSpawn) end
)

local function addEnts(names)
    for i=1, #names do
        local name = names[i]
        conquestWhitelist[Isaac.GetEntityTypeByName(name)..'.'..Isaac.GetEntityVariantByName(name)] = true
    end
end

local function PostLoad()
    if FiendFolio then
        -- Fuck Fiend Folio this shit is way too large :(
        addEnts({
            "Mern", "Spooter", "Super Spooter", "Mega Spooter", "Litter Bug", "Toxic Litter Bug", "Charmed Litter Bug", "Soft Serve", "Sundae", "Scoop", "Chorister", "Fathead",
            "Drink Worm", "Drunk Worm", "Wobbles", "Sludge Host", "Corposlave", "Curdle", "Curdle (Naked)", "Calzone", "Panini", "Marge", "Honey Eye", "Smogger", "Spinny", "Pitcher",
            "Mutant Horf", "Phoenix", "Phoenix (Corpse)", "Phoenix (Revived)", "Pyroclasm", "Skipper", "Slammer", "Wimpy", "Smasher", "S'Eptic", "Stompy", "Doomer", "Marzlammer", "Flinty",
            "Sniffle", "Dry Wheeze", "Snagger", "Poople", "Dung", "Morsel", "Falafel", "Cancerlet", "Slick", "Stump", "Frog", "Motor Neuron", "Dweller", "Dweller (Inner Eye)", "Dweller (Spoon Bender)",
            "Dweller (Number One)", "Dweller (Brother Bobby)", "Dweller (Technology)", "Dweller (Polyphemus)", "Dweller (Lost Contact)", "Dweller (Cricket's Body)", "Dweller (Cursed Eye)", "Dweller (Soy Milk)",
            "Dweller (Euthanasia)", "Dweller (Random)", "Dweller Brother", "Resident", "Resident Body", "Harley", "Warty", "Gunk", "Punk", "Gleek", "Ribeye", "Cortex", "Balor", "Septic Balor", "Eyesore",
            "Beeter", "Crosseyes", "Tado Kid", "Haunted", "Fishface", "Shiny Fishface", "Bubble Blowing Double Baby", "Spitum", "Mr. Flare", "Mr. Crisply", "Incisor", "Starving", "Milk Tooth", "Foreseer",
            "Psleech", "Fumegeist", "Sourpatch", "Sourpatch Body", "Limepatch", "Limepatch Body", "Zingling", "Zingy", "Globulon", "Primemind", "Charlie", "Sooty", "Peepling", "Gis", "Poobottle", "Drainfly",
            "Homer", "Gishle", "Hover", "Sagging Sucker", "Red Horf", "Shitty Horf", "Wire", "Piper", "Fossilized Boom Fly", "Stingler", "Bunch", "Grape", "Bumbler", "Eroded Host", "Honeydrip", "Pester",
            "Ramblin' Evil Mushroom", "Smidgen", "Red Smidgen", "Eroded Smidgen", "Tittle", "Dr. Shambles", "Neonate", "Flanks", "Carrier", "Lipoma", "Nanny Long Legs", "Residuum", "Technician", "Clergy",
            "Stolas", "Bull", "Geyser", "Mag Gaper", "Aper", "Mobile Mushroom", "Slobber", "Bleeder", "Pale Bleeder", "Valvo", "Guflush", "Cancer Boy", "Benign", "Dewdrop", "Bellow", "Floodface (Random)",
            "Floodface (Chasing)", "Connipshit", "Psystalk", "Crucible", "Crucible (Ignited)", "Fount", "Drillbit", "Minimoon", "Bladder", "Heartbeat", "Ignis", "Globlet", "Crotchety", "Gabber", "Wheezer",
            "Gritty", "Psyclopia", "Peepisser", "Brood", "Alderman", "Unshornz", "Dread Maw", "Quaker", "Shaker", "Brisket", "Shellmet", "Nematode", "Hoster", "Hangman", "Slimer", "Fracture", "Mite", "Holy Wobbles",
            "Fireswirl", "Whale Guts", "Whale Cord", "Clam", "Lunksack", "Coloscope", "Putrefatty", "Musk", "Spanky", "Spiroll", "Acolyte", "Anode", "Crudemate", "Spider (Nicalis)", "Carrot", "Berry", "Moaner",
            "Unpawtunate", "Unpawtunate Skull", "Ragurge", "Wick", "Cracker", "Clickety Clash", "Strobila", "Lonely Knight", "Lonely Knight Brain", "Lonely Knight Shell", "Chops", "Super Shottie", "Super Shottie Hook",
            "Magleech", "Myiasis", "Myiasis Projectile", "Trashbagger", "Stomy", "Cappin", "Blasted", "Coconut", "Fishy", "Necrotic", "Catfish", "Squid", "Bub", "Shirk", "Shirk Spot", "Glorf", "Rotdrink", "Rotskull",
            "Kukodemon", "Maze Runner", "Maze Runner (Red)", "Shock Collar", "Cathy", "Arcane Creep", "Puffer", "Dolphin", "Madhat", "Ztewie", "Marlin", "Dollop", "Toothache", "Chunky", "Grilled Chunky", "Butt Fly",
            "Briar", "Grazer", "Blare", "Potluck", "Casualty", "Dim", "Dim's Soul", "Craig", "Nailhead", "Vacuole", "Contestant", "Dumptruck", "Gutso", "Duke's Demon"
        })
    end

    if REVEL then
        addEnts({
            "Block Gaper", "Cardinal Block Gaper", "Yellow Block Gaper", "Yellow Cardinal Block Gaper", "Geicer", "Hice", "Cloudy", "Brainfreeze",
            "Snowbob", "Snowbob Head", "Snowbob Head (Tears)", "Fatsnow", "Iced Hive", "Stalactrite", "Arrowhead", "Rag Gaper", "Rag Gaper (Head)",
            "Rag Gusher", "Antlion", "Aerotoma", "Rag Trite", "Rag Fatty", "Chicken", "Bomb Sack", "Bomb Sack No Spawns", "Avalanche", "Shy Fly",
            "Coal Heater", "Harfang", "Jackal", "Gilded Jackal", "Stabstack", "Stabstack Piece", "Stabstack Rolling Piece", "Ragma", "Pine", "Pinecone", "Dune"
        })
    end

    if CiiruleanItems then
        addEnts({
            "Circe Swine", "Spirit", " Curdle ", "Mega Clot", "Kaboom Fly", "Bloated Fly", "Spew Fly", "Drowned Maggot", "Drowned Spitty", "Full Sucker", "Dowsing Bloodlaser",
            "Full Spit", "Sip", "Stumbling Boil", "Stumbling Gut", "Stumbling Sack", "Walking Blue Boil", "Stumbling Blue Boil", "Mega Pooter", "Samael Angel",
        })
    end

    if Deliverance then
        addEnts({
            "Raga", "Cracker", "Jester", "Joker", "Nutcracker", "Beamo", "Peabody", "Peabody X", "Peamonger", "Rosenberg", "Shroomeo", "Tinhorn", "Fat Host", "Red Fat Host", "Cadaver", "Wicked Cadaver",
            "Sluggish Cadaver", "Cadaver (random)", "Eddie", "Seraphim", "Fistulauncher", "Mother Of Many", "Pale Mother Of Many", "Creampile", "Grilly", "Bloodmind", "Peaglobby"
        })
    end

    CURCOL:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, PostLoad)
end

CURCOL:AddCallback(ModCallbacks.MC_INPUT_ACTION, PostLoad)

--[[##########################################################################
############################## CURSE OF REBIRTH ##############################
##########################################################################]]--
-- local function OnClear(_, RNG)
--     if CURCOL.GAME:GetRoom():GetType() == RoomType.ROOM_DEFAULT
--     and RNG:RandomInt(100)+1 <= CURCOL.CURSES_CONFIG.REBIRTH_CHANCE then
--         Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_D7, false, true, false, false)
--         CURCOL.SFX:Play(SoundEffect.SOUND_SUMMONSOUND)

--         local room = Game():GetRoom()
--         local doorPos = room:GetClampedPosition(room:GetDoorSlotPosition(CURCOL.GAME:GetLevel().EnterDoor), 15)

--         for i=1,Game():GetNumPlayers() do
--             local player = Game():GetPlayer(tostring((i-1)))

--             player:AnimateTeleport(false)
--             player.Position = doorPos
--             player:AddSlowing(EntityRef(player), 8, 0, Color(1,1,1,1))
--             player.Velocity = Vector(0,0)
--             player:SetColor(Color(0.8,0.8,0.8,1,0.30,0,0.45), 60, 100, true, true)
--             if not CURCOL.SFX:IsPlaying(SoundEffect.SOUND_JELLY_BOUNCE) then CURCOL.SFX:Play(SoundEffect.SOUND_JELLY_BOUNCE, 1, 5) end 
--         end
--     end
-- end

-- InitCurse("Rebirth", "ENABLE_REB", 5, 
--     function() CURCOL:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClear)    end, 
--     function() CURCOL:RemoveCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClear) end
-- )

local function OnNPCDeath(_, NPC)
    if not NPC:IsBoss() and NPC.CanShutDoors and NPC.FrameCount == Game():GetRoom():GetFrameCount() and NPC:GetDropRNG():RandomInt(100)+1 <= CURCOL.CURSES_CONFIG.REBIRTH_CHANCE then
        local newNPC = CURCOL.SeedSpawn(NPC.Type, NPC.Variant, NPC.SubType, NPC.Position, NPC.Velocity, NPC):ToNPC()
        local newData = newNPC:GetData()

        for key, value in pairs(NPC:GetData()) do
            newData[key] = value
        end

        if NPC:IsChampion() then
            local champ = NPC:GetChampionColorIdx()
            newNPC:MakeChampion(NPC.InitSeed, champ, true)
        end

        newNPC:SetColor(Color(0.8,0.8,0.8,1,0.30,0,0.45), 60, 100, true, true)

        local eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.NOTIF_EFF, 0, newNPC.Position-Vector(0, 65), Vector(0,0), newNPC):ToEffect()
        eff:FollowParent(newNPC)
        eff.DepthOffset = newNPC.Position.Y + 10
        eff:GetSprite():Play('Rebirth')

        CURCOL.SFX:Play(SoundEffect.SOUND_SUMMONSOUND)
    end
end

InitCurse("Rebirth", "ENABLE_REB", 5, 
    function() CURCOL:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, OnNPCDeath)    end, 
    function() CURCOL:RemoveCallback(ModCallbacks.MC_POST_NPC_DEATH, OnNPCDeath) end
)

--[[##########################################################################
############################## CURSE OF CREATION #############################
##########################################################################]]--
local function canPlayerReach(endPos, startPos)
    local canReach = true

    local tempNPC = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, startPos, Vector(0,0), nil):ToNPC()

    if not tempNPC.Pathfinder:HasPathToPos(endPos, true) then
        canReach = false
    end

    tempNPC:Remove()

    return canReach
end

local function canPlayerReachAll(pos, endPos)
    for i=1, #pos do
        if not canPlayerReach(pos[i], endPos) then
            return false
        end
    end

    return true
end

local function getRequiredPositions(room, doors)
    local positions = {}
    for i=0, room:GetGridSize() do
        local grid = room:GetGridEntity(i)
        if grid and grid:ToPressurePlate() and grid:GetVariant() == 0 and grid.State ~= PressurePlateState.PLATE_PRESSED then
            positions[#positions+1] = grid.Position
        end
    end

    for j=1, #doors do
        if room:IsDoorSlotAllowed(doors[j]) -- Door is allowed
        and room:GetDoor(doors[j]) then -- Door exists
            positions[#positions+1] = room:GetDoorSlotPosition(doors[j])
        end
    end

    return positions
end

local function OnGridBreak(_, gridEnt)
    if creationWhitelist[gridEnt.Desc.Type] and gridEnt.Desc.State == 2 and not CURCOL.GAME:GetRoom():HasCurseMist() then
        -- local RNG = gridEnt:GetRNG()
        -- RNG:Next()
        -- RNG:SetSeed(gridEnt:GetRNG():GetSeed()..gridEnt:GetGridIndex(), 0)
     
        if math.random(100) <= CURCOL.CURSES_CONFIG.CREATION_CHANCE --TODO: this should be seeded but it seems that gridEnt RNG isnt unique
        and #Isaac.FindByType (5, 340, -1, true) == 0
        and #Isaac.FindByType (5, 370, -1, true) == 0 then
            local sprite = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.CREATION_EFF, 0, gridEnt.Position, Vector(0,0), nil):GetSprite()
            sprite:Play(math.random(2) == 1 and 'Rubble01' or 'Rubble02')
            if not CURCOL.SFX:IsPlaying(CURCOL.CURSES_CONFIG.CREATION_SFX) then CURCOL.SFX:Play(CURCOL.CURSES_CONFIG.CREATION_SFX) end
        end
    end
end

local function animateWarp(player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER)
    player:AnimateTeleport(false)
    player:SetColor(Color(0.8,0.8,0.8,1,0.30,0,0.45), 300, 100, true, true)
    if not CURCOL.SFX:IsPlaying(SoundEffect.SOUND_JELLY_BOUNCE) then CURCOL.SFX:Play(SoundEffect.SOUND_JELLY_BOUNCE, 1, 5) end
end

local function OnGridEffUpdate(_, eff)
    if eff:GetSprite():IsEventTriggered('Finished') then
        local room = CURCOL.GAME:GetRoom()
        local ent = room:GetGridEntityFromPos(eff.Position)
        local gridType = GridEntityType.GRID_ROCK

        if ent then 
            gridType = ent.Desc.Type
            ent:Destroy(true)
        end

        local rand = math.random(100)
        if gridType == GridEntityType.GRID_ROCKT or gridType == GridEntityType.GRID_ROCK_SS or gridType == GridEntityType.GRID_ROCK_GOLD then
            gridType = rand <= 10 and gridType or GridEntityType.GRID_ROCK_SPIKED
        else
            gridType = rand <= 75 and gridType or rand <= 95 and GridEntityType.GRID_ROCK_SPIKED or creationSpecialRocks[math.random(#creationSpecialRocks)]
        end

        local newGridEnt = Isaac.GridSpawn(gridType, 0, eff.Position, true)
        eff:Remove()

        local door = CURCOL.GAME:GetLevel().EnterDoor
        local doorSet = creationDoorSets[room:GetRoomShape()] or {}
        local doorPos

        if door < 0 then
            if doorSet then doorPos = room:GetDoorSlotPosition(doorSet[1]) end
        else
            doorPos = room:GetDoorSlotPosition(door)
        end

        if not doorPos then
            doorPos = room:GetCenterPos()
        end

        local players = Game():GetNumPlayers()
        local positions = getRequiredPositions(room, doorSet)
        local hasCancelled = false
        local hasWarped = {}

        for i=1,players do
            local player = Game():GetPlayer(tostring((i-1)))
            local currentPos = player.Position

            if not canPlayerReachAll(positions, player.Position) then
                local originPos = player.Position + (player.Velocity:Rotated(180):Normalized()*40)
                local warpPos = room:FindFreePickupSpawnPosition(room:GetClampedPosition(originPos, 30), 0, true, false)

                if canPlayerReachAll(positions, warpPos) then
                    hasWarped[#hasWarped+1] = { p = player, pos = warpPos }
                else
                    warpPos = room:FindFreePickupSpawnPosition(room:GetClampedPosition(doorPos, 30), 0, true, false)
                    if canPlayerReachAll(positions, warpPos) then
                        hasWarped[#hasWarped+1] = { p = player, pos = warpPos, anim = true }
                    else
                        room:RemoveGridEntity(newGridEnt:GetGridIndex(), 0, true)
                        newGridEnt:GetSprite().Color = Color(1,1,1,0,0,0,0)
                        player.Position = currentPos
                        hasCancelled = true
                        break
                    end
                end
            end
        end

        if not hasCancelled then
            if next(hasWarped) then
                for i=1, #hasWarped do
                    if hasWarped[i].anim then animateWarp(hasWarped[i].p) end
                    hasWarped[i].p.Position = hasWarped[i].pos
                end
            end

            local color = Color(0.65,0.65,0.65,0.75)
            color:SetColorize(1.5,1,2,1)
            newGridEnt:GetSprite().Color = color
            Isaac.Spawn(1000,121,-1,newGridEnt.Position,Vector(0,0),nil)

            local pickups = Isaac.FindInRadius(eff.Position, 40, EntityPartition.PICKUP)

            if #pickups > 0 then
                for i=1, #pickups do
                    pickups[i]:AddVelocity((pickups[i].Position - room:FindFreePickupSpawnPosition(pickups[i].Position, 0, true, false)):Clamped(-5,-5,5,5))
                end
            end
        end
    end
end

InitCurse("Creation", "ENABLE_CREA", 6,
    function() TCC_API:AddTCCCallback("TCC_GRID_BREAK", OnGridBreak); CURCOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnGridEffUpdate, CURCOL.CURSES_CONFIG.CREATION_EFF) end, 
    function() TCC_API:RemoveTCCCallback("TCC_GRID_BREAK", OnGridBreak); CURCOL:RemoveCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnGridEffUpdate, CURCOL.CURSES_CONFIG.CREATION_EFF) end
)

--[[##########################################################################
############################# CURSE OF ISOLATION #############################
##########################################################################]]--
-- local function OnPickupCollision(_, pickup)
--     if not pickup:GetData().CURCOL_TP
--     and not pickup:IsShopItem()
--     and pickup:GetDropRNG():RandomInt(100)+1 <= (CURCOL.CURSES_CONFIG[pickup.Variant == 100 and 'ISOLATION_COL_CHANCE' or 'ISOLATION_CHANCE']) then
--         local room = QUACOL.GAME:GetRoom()

--         local eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.NOTIF_EFF, 0, pickup.Position-Vector(0, 65), Vector(0,0), pickup)
--         eff.DepthOffset = pickup.Position.Y + 10
--         eff:GetSprite():Play('Isolation')

--         local pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(30), 0, true)
--         CURCOL.GAME:SpawnParticles(pickup.Position, EffectVariant.ROCK_PARTICLE, 3, 1)
--         pickup.TargetPosition = pos
--         pickup.Position = pos
--         pickup:SetColor(Color(1,1,1,0), 2, 101, true, true)
--         CURCOL.SFX:Play(SoundEffect.SOUND_HELL_PORTAL1)

--         return true
--     else
--         pickup:GetData().CURCOL_TP = true
--     end
-- end

-- local function OnEntityDamage(_, entity, damage, _, source)
--     if not entity:IsBoss() and entity.Mass < 50 and not isolationBlacklist[entity.Type]
--     and source and source.Entity and (source.Entity.Type == EntityType.ENTITY_PLAYER or CURCOL.GetShooter(source.Entity)) 
--     and damage < entity.HitPoints and CURCOL.GAME:GetRoom():GetAliveEnemiesCount() == 1
--     and entity:GetDropRNG():RandomInt(100)+1 <= CURCOL.CURSES_CONFIG.ISOLATION_ENT_CHANCE then
--         local player = source.Entity
--         local point = entity.Position
        
--         if source.Entity.Type ~= EntityType.ENTITY_PLAYER then
--             player = CURCOL.GetShooter(source.Entity)
--         end
        
--         local center = player.Position

--         if center:Distance(point) < 105 then return end

--         local angle = math.random(180)+90 -- +90 is mimimum rotation

--         angle = (angle) * (math.pi/180);
--         local rotatedX = math.cos(angle) * (point.X - center.X) - math.sin(angle) * (point.Y-center.Y) + center.X;
--         local rotatedY = math.sin(angle) * (point.X - center.X) + math.cos(angle) * (point.Y - center.Y) + center.Y;

--         local newPos = Vector(rotatedX, rotatedY)+player.Velocity

--         local col = CURCOL.GAME:GetRoom():GetGridCollisionAtPos(newPos)
--         if col == 0 or (entity:IsFlying() and col ~= GridCollisionClass.COLLISION_WALL and col ~= GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER) then
--             entity.Position = newPos
--             entity:SetColor(Color(1,1,1,0), 2, 101, true, true)
--             entity:GetSprite():SetFrame(entity:GetSprite():GetDefaultAnimationName(), 0)
--             CURCOL.SFX:Play(SoundEffect.SOUND_HELL_PORTAL1)

--             local eff = Isaac.Spawn(1000, CURCOL.CURSES_CONFIG.NOTIF_EFF, 0, entity.Position-Vector(0, 65), entity.Velocity, entity):ToEffect()
--             eff:FollowParent(entity)
--             eff.DepthOffset = entity.Position.Y + 10
--             eff:GetSprite():Play('Isolation')
--         end
--     end
-- end

-- InitCurse("Isolation", "ENABLE_ISO", 1, 
--     function() CURCOL:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, OnPickupCollision)    CURCOL:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnEntityDamage)    end, 
--     function() CURCOL:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, OnPickupCollision) CURCOL:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnEntityDamage) end
-- )