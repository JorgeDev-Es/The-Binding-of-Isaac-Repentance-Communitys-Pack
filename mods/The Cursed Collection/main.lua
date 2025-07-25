--[[##########################################################################
######################## MOD CONTENT IMPORT AND SETUP ########################
##########################################################################]]--
CURCOL = RegisterMod("The Cursed Collection", 1)
local json = require("json")

CURCOL.SFX = SFXManager()
CURCOL.GAME = Game()
CURCOL.CONF = Isaac.GetItemConfig()
CURCOL.SAVEDATA = {}

function CURCOL:InitSaveData()
    if CURCOL:HasData() then
        local loadStatus, LoadValue = pcall(json.decode, CURCOL:LoadData())
        if loadStatus then
            CURCOL.SAVEDATA = LoadValue
            goto skipDefault
        end
    end

    CURCOL.SAVEDATA = {
        ENABLE_DECAY = true,
        ENABLE_FAMINE = true,
        ENABLE_BLIGHT = true,
        ENABLE_CONQ = true,
        ENABLE_ISO = true,
        ENABLE_REB = true,
        ENABLE_CREA = true,
        PAPYRUS_NO_MOD = false,
        -- BIND_CACHE = {},
        -- CAN_SPAWN_SOULBIND = true,
    }

    CURCOL:SaveData(json.encode(CURCOL.SAVEDATA))
    ::skipDefault::

end

function CURCOL:InitRun(isContOrLoad)
    local curses = { Famine = "ENABLE_FAMINE", Decay = "ENABLE_DECAY", Blight = "ENABLE_BLIGHT", Conquest = "ENABLE_CONQ", Rebirth = "ENABLE_REB", Creation = "ENABLE_CREA" }
    for key, value in pairs(curses) do
        local id = Isaac.GetCurseIdByName("Curse of " .. key)
        if id > 0 then TCC_API:ToggleCurse(id, CURCOL.SAVEDATA[value]) end
    end

    -- Make amalgamation artificially rarer
    if not isContOrLoad then
        local seed = CURCOL.GAME:GetSeeds():GetStartSeed()

        if seed and seed ~= 0 then
            local rng = RNG()
            rng:SetSeed(seed, 1)

            if rng:RandomInt(3) == 0 then
                CURCOL.GAME:GetItemPool():RemoveTrinket(Isaac.GetTrinketIdByName("Amalgamation"))
            end
        end
    end
end

-- MC_POST_PLAYER_INIT is needed because otherwise savedata on file 2 and 3 will load after curse eval
CURCOL:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, CURCOL.InitSaveData)
CURCOL:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CURCOL.InitRun)

-- Define content and path
local path = 'scripts.content.'
local content = { 
    'mended_knife', 'sirens_call', 'chained_spikey', 'anathema', 'soul_cleaver', 
    'pentacle', 'DO_NOT_TOUCH', 'fettered_heart', 'sewn_bond',
    'cursed_flame', 'lil_heretic', 'secretion', 'revenir', 
    'curse_of_the_tower', 'papyrus_rags', 'cursed_dice', 'veil_of_darkness', 
    'amalgamation'
}

require('scripts.curcol_callbacks') -- Import custom/shared callbacks
require('scripts.curses_controller') -- Import curses

CURCOL.InitRun(true)

function CURCOL.GetShooter(ent)
    if ent and ent.SpawnerType == EntityType.ENTITY_PLAYER then
        if ent.SpawnerEntity ~= nil then
            return ent.SpawnerEntity:ToPlayer()
        elseif ent.Parent ~= nil then
            return ent.Parent:ToPlayer()
        end
    end

    return nil
end

function CURCOL.checkFlags(key, flags)
    local numPlayers = CURCOL.GAME:GetNumPlayers()
    for i=1,numPlayers do
        local player = CURCOL.GAME:GetPlayer(tostring((i-1)))
        if TCC_API:Has(key, player) then
            player:AddCacheFlags(flags)
            player:EvaluateItems()
        end
    end
end

function CURCOL.SeedSpawn(entType, variant, subtype, pos, vel, spawner, seed)
    local seed = seed or Random()

    if seed == 0 then seed = 1 end

    local ent = Game():Spawn(entType, variant, pos, vel, spawner or nil, subtype or 0, seed or 1)

    return ent
end

function CURCOL.checkAllFam(var, id, amount)
    local numPlayers = CURCOL.GAME:GetNumPlayers()
    for i=1,numPlayers do
        local player = CURCOL.GAME:GetPlayer(tostring((i-1)))
        player:CheckFamiliar(var, (player:GetCollectibleNum(id)+player:GetEffects():GetCollectibleEffectNum(id))*(amount or 1), player:GetCollectibleRNG(id))
    end
end

function CURCOL.tryHoldAFuneral()
    local numItems = 0
    local player = Isaac.GetPlayer()
    
    for i=1,CURCOL.GAME:GetNumPlayers() do
        local curPlayer = CURCOL.GAME:GetPlayer(tostring((i-1)))

        local hasItem = curPlayer:GetCollectibleNum(CollectibleType.COLLECTIBLE_BLACK_CANDLE, true)

        if hasItem > 0 then
            player = curPlayer    
        end

        for j=1, hasItem do
            numItems = numItems + 1
            curPlayer:RemoveCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)
        end
    end

    for key, value in pairs(Isaac.FindByType(3, 237, 260, false, false)) do
        value:Kill()
        numItems = numItems + 1
    end

    if numItems > 0 then
        local room = CURCOL.GAME:GetRoom()
        local pos = room:GetClampedPosition(player.Position, 45)

        local freePos = {
            Vector(0,0),
            Vector(0,30),
            Vector(0,-30),
            Vector(30,0),
            Vector(-30,0),
            Vector(30,30),
            Vector(30,-30),
            Vector(-30,0),
            Vector(-30,30),
            Vector(-30,-30),
        }

        for i=1, #freePos do
            local grid = room:GetGridEntityFromPos(pos+freePos[i])
            if grid then grid:Destroy(false) end
        end

        local eff = Isaac.Spawn(1000, Isaac.GetEntityVariantByName("CURCOL black candle grave effect"), 0, room:GetClampedPosition(player.Position, 45), Vector(0,0), player)
        eff.DepthOffset = -100

        MusicManager():Play(8, 0.4)
        CURCOL.SFX:Play(SoundEffect.SOUND_DOOR_HEAVY_OPEN, 1, 8, false, 1.8)
        CURCOL.SFX:Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND)
        CURCOL.SFX:Play(SoundEffect.SOUND_BLACK_POOF)

        local pos = room:GetClampedPosition(Vector(pos.X, pos.Y+60), 0)

        for i=1, 2+numItems do
            local offX = i % 3 == 0 and -30 or i % 2 == 0 and 30 or 0
            local offY = (i % 3 == 0 and 15 or i % 2 == 0 and 15 or 0) - (30*math.floor((i-1)/3))
            
            CURCOL.SeedSpawn(5, 10, 6, Vector(pos.X+offX, pos.Y-offY), Vector(0,0), player)
        end
    end
end

if EID then
    local EIDspr = Sprite()
    EIDspr:Load("gfx/ui/CURCOL_curse_icons.anm2", true)
    EID:addIcon("CURCOL_blight", "EID", 4, 16, 16, -2, 0, EIDspr)
    EID:addIcon("CURCOL_crea",   "EID", 6, 16, 16, -2, 0, EIDspr)
end

local function OnBlightEff(_, effect)
    if effect.FrameCount > 60 then
        effect:Remove()
    end
end

CURCOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnBlightEff, Isaac.GetEntityVariantByName("CURCOL blight effect"))

-- Import content
local contentImports = {}
for _, title in pairs(content) do table.insert(contentImports, require(path .. title)) end
--[[ ### DEV CODE ### --
local function loadItems()
    if CURCOL.GAME:GetFrameCount() == 0 then
        local offset = 0
        local offsetY = 0
        for _, item in ipairs(contentImports) do
            if item.SHOW_DEV or true then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, item.TYPE, item.ID, Vector(320+offset, 300-offsetY), Vector(0, 0), nil)

                if item.TYPE == 350 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, item.TYPE, item.ID+32768, Vector(320+offset, 300-offsetY), Vector(0, 0), nil)
                end

                if offset == -200 then
                    offset = 0
                    offsetY = offsetY+50
                elseif offset == 0 then
                    offset = 50
                elseif offset > 0 then
                    offset = offset - (offset*2)
                else
                    offset = -1*offset+50
                end
            end
        end
    end
end

CURCOL:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, loadItems);
-- ### END DEV CODE ### ]]--
local ModIcon = Sprite()
ModIcon:Load("gfx/ui/CURCOL_mod_icon.anm2", true)

contentImports = TCC_API:InitContent(contentImports, "Cursed Collection", "CurcolMod", ModIcon)

--TODO: Research / catch curse id -1 bug