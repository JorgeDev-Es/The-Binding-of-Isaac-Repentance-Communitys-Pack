--[[##########################################################################
######################## MOD CONTENT IMPORT AND SETUP ########################
##########################################################################]]--
QUACOL = RegisterMod("The Quarry Collection", 1)
local json = require("json")

QUACOL.SAVEDATA = {}
QUACOL.SFX = SFXManager()
QUACOL.GAME = Game()
QUACOL.CONF = Isaac.GetItemConfig()

function QUACOL:InitSaveData()
    if QUACOL:HasData() then
        local loadStatus, LoadValue = pcall(json.decode, QUACOL:LoadData())
        if loadStatus then
            QUACOL.SAVEDATA = LoadValue
            goto skipDefault
        end
    end

    QUACOL.SAVEDATA = {
        ROCK_LIMIT = 25
    }

    QUACOL:SaveData(json.encode(QUACOL.SAVEDATA))
    ::skipDefault::
end

QUACOL:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, QUACOL.InitSaveData)
QUACOL:InitSaveData()

-- Define content and path
local path = 'scripts.content.'
local content = { 
    'singed_stones', 'gideons_gaze', 'limestone_carving', 'hot_wheels', 'mini_bombs', 'tuff_cookie', 
    'premature_detonation', 'quake_oats', 'pile_of_bones', 'broken_shell', 'crackling_slag', 'volatile_division'
}

require('scripts.quacol_callbacks') -- Import custom/shared callbacks
require('scripts.fire_jet') -- Import shared effect with logic
require('scripts.rock_spiders')

function QUACOL.GetShooter(ent)
    if ent then
        if ent.SpawnerEntity and ent.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and ent.SpawnerEntity.Variant == FamiliarVariant.INCUBUS then
            if ent.SpawnerEntity:ToFamiliar().Player ~= nil then
                return ent.SpawnerEntity:ToFamiliar().Player:ToPlayer()
            end
        elseif ent.SpawnerType == EntityType.ENTITY_PLAYER then
            if ent.SpawnerEntity ~= nil then
                return ent.SpawnerEntity:ToPlayer()
            elseif ent.Parent ~= nil then
                return ent.Parent:ToPlayer()
            end
        end
    end

    return nil
end

function QUACOL.SeedSpawn(entType, variant, subtype, pos, vel, spawner, seed)
    local seed = seed or Random()

    if seed == 0 then seed = 1 end

    local ent = Game():Spawn(entType, variant or 0, pos, vel, spawner or nil, subtype or 0, seed or 1)

    return ent
end

function QUACOL.checkAllFam(var, id, amount)
    local numPlayers = QUACOL.GAME:GetNumPlayers()
    for i=1,numPlayers do
        local player = QUACOL.GAME:GetPlayer(tostring((i-1)))
        player:CheckFamiliar(var, (player:GetCollectibleNum(id)+player:GetEffects():GetCollectibleEffectNum(id))*(amount or 1), player:GetCollectibleRNG(id))
    end
end

function QUACOL.checkFlags(key, flags)
    local numPlayers = QUACOL.GAME:GetNumPlayers()
    for i=1,numPlayers do
        local player = QUACOL.GAME:GetPlayer(tostring((i-1)))
        if TCC_API:Has(key, player) then
            player:AddCacheFlags(flags)
            player:EvaluateItems()
        end
    end
end

-- Import content
local contentImports = {}
for _, title in pairs(content) do table.insert(contentImports, require(path .. title)) end
--[[ ### DEV CODE ### --
local function loadItems()
    if QUACOL.GAME:GetFrameCount() == 0 then
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

QUACOL:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, loadItems);
-- ### END DEV CODE ### ]]--
local ModIcon = Sprite()
ModIcon:Load("gfx/ui/QUACOL_mod_icon.anm2", true)

contentImports = TCC_API:InitContent(contentImports, "Quarry Collection", "QuacolMod", ModIcon)
