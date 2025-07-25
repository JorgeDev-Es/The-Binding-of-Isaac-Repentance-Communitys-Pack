--[[##########################################################################
######################## MOD CONTENT IMPORT AND SETUP ########################
##########################################################################]]--
SEWCOL = RegisterMod("The Sewage Collection", 1)
local json = require("json")

SEWCOL.SFX = SFXManager()
SEWCOL.GAME = Game()
SEWCOL.CONF = Isaac.GetItemConfig()
SEWCOL.SAVEDATA = {}

function SEWCOL:InitSaveData()
    if SEWCOL:HasData() then
        local loadStatus, LoadValue = pcall(json.decode, SEWCOL:LoadData())
        if loadStatus then
            SEWCOL.SAVEDATA = LoadValue
            goto skipDefault
        end
    end

    SEWCOL.SAVEDATA = {
        CAN_SPAWN_REFLECTIONS = true,
        CAN_UP_REFLECTIONS = true,
        CANT_REFLECT_SHOP = false,
        DO_REFLECTION_SHINE = true,
        BROKEN_MIRROR = false,
        LEECH_LIMIT = 25,
        REF_CACHE = {}
    }

    SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
    ::skipDefault::
end

SEWCOL:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SEWCOL.InitSaveData)
SEWCOL:InitSaveData()

if ModConfigMenu then
	local ModName = "Sewage Collection"

	ModConfigMenu.UpdateCategory(ModName, { Info = {"Settings for enabling and disabling reflection mechanics."} })

	ModConfigMenu.AddSetting(ModName, "Reflections", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return SEWCOL.SAVEDATA.CAN_SPAWN_REFLECTIONS end,
        OnChange = function(currentBool) 
            SEWCOL.SAVEDATA.CAN_SPAWN_REFLECTIONS = currentBool
            SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
        end,
        Info = {"Should reflections spawn naturally?"},
        Display = function()
            local onOff = "False"
            if SEWCOL.SAVEDATA.CAN_SPAWN_REFLECTIONS then onOff = "True" end
            return "Can spawn naturally: " .. onOff
        end
    })
end

-- Define content and path
local path = 'scripts.content.'
local content = { 'the_pail', 'haunted_rose', 'willo', 'plastic_bag', 'slippy_tooth', 'whirling_leech', 'driftwood', 'the_mirror', 'glass_card' }

require('scripts.sewcol_callbacks') -- Import custom/shared callbacks
require('scripts.content.entities.reflections')
require('scripts.content.entities.friendly_leeches')

function SEWCOL.GetShooter(ent)
    if ent and ent.SpawnerType == EntityType.ENTITY_PLAYER then
        if ent.SpawnerEntity ~= nil then
            return ent.SpawnerEntity:ToPlayer()
        elseif ent.Parent ~= nil then
            return ent.Parent:ToPlayer()
        end
    end

    return nil
end

function SEWCOL.SeedSpawn(entType, variant, subtype, pos, vel, spawner, seed)
    local seed = seed or Random()

    if seed == 0 then seed = 1 end

    local ent = Game():Spawn(entType, variant or 0, pos, vel, spawner or nil, subtype or 0, seed or 1)

    return ent
end

function SEWCOL.checkAllFam(var, id, amount)
    local numPlayers = SEWCOL.GAME:GetNumPlayers()
    for i=1,numPlayers do
        local player = SEWCOL.GAME:GetPlayer(tostring((i-1)))
        player:CheckFamiliar(var, (player:GetCollectibleNum(id)+player:GetEffects():GetCollectibleEffectNum(id))*(amount or 1), player:GetCollectibleRNG(id))
    end
end

-- Import content
local contentImports = {}
for _, title in pairs(content) do table.insert(contentImports, require(path .. title)) end
--[[ ### DEV CODE ### --
local function loadItems()
    if SEWCOL.GAME:GetFrameCount() == 0 then
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

SEWCOL:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, loadItems);
-- ### END DEV CODE ### ]]--
local ModIcon = Sprite()
ModIcon:Load("gfx/ui/SEWCOL_mod_icon.anm2", true)

contentImports = TCC_API:InitContent(contentImports, "Sewage Collection", "SewcolMod", ModIcon)

-- V [DOWNPOUR] Willo - Angry fly but it shoots and there's more of them. (Min-min)
-- V [DROSS] The pail - Spawns a gaint poop and clears the room (Clog?)
-- V [DOWNPOUR] Haunted rose - Enemies may spawn ghosts (ghost bomb) upon death (Rainmaker / Haunted theme)
-- V [BOTH] Driftwood - Wormwoods tail will spike up from the ground and hit enemies. it will make a hole of the ground did not have a gap. After the tail goes down the gap gets filled (Wormwood)
-- V [BOTH] Whirling leech - Leeches and maggots are weakened, Spawn charmed leeches and maggots upon taking damage (Lil blub)
-- V [DROSS] Slippy tooth - Tears leave slippery creep and friendly brown creep and higher knockback. Enemies hit by these tears will also permanently leave a trail of this creep below them (Turdlet)
-- V [DROSS] Plastic Bag - Killing enemies has a chance of making them spawn friendly brown creep and a butt bomb. (Colostomia)
