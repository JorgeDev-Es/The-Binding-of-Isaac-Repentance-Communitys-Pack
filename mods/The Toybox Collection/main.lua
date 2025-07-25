--[[##########################################################################
######################## MOD CONTENT IMPORT AND SETUP ########################
##########################################################################]]--
local json = require("json")

TOYCG = RegisterMod("The Toybox Collection", 1)

TOYCG.SAVEDATA = {}
TOYCG.SFX = SFXManager()
TOYCG.GAME = Game()

--TODO: API custom sounds are currently broken. Keep an eye out for this possibly being fixed!

TOYCG:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() TOYCG:SaveData(json.encode(TOYCG.SAVEDATA)) end)
TOYCG:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
    if TOYCG:HasData() then
        if isContinued then
            local loadStatus, LoadValue = pcall(json.decode, TOYCG:LoadData())

            if loadStatus then
                TOYCG.SAVEDATA = LoadValue
                return
            end
        end
    end

    TOYCG.SAVEDATA = {}
    TOYCG:SaveData(json.encode(TOYCG.SAVEDATA))
end)


-- Define content and path
local path = 'scripts.content.'
local content = { 'ancestral_assistance', 'old_relic', 'blank', 'concussion', 'wow_factor', 'jar_of_air', 'witch_wand', 'sigil_of_knowledge', 'blood_of_the_abyss' }

require('scripts.toycol_callbacks') -- Import custom/shared callbacks

function TOYCG.SharedOnGrab(sound, volume, delay, stopMusic)
    TOYCG.SFX:Stop(SoundEffect.SOUND_CHOIR_UNLOCK)

    if stopMusic then
        MusicManager():Crossfade(sound)
    else
        TOYCG.SFX:Play(sound, volume or 1, delay or 0) 
    end
end

function TOYCG.GetShooter(ent)
    if ent and ent.SpawnerType == EntityType.ENTITY_PLAYER then
        if ent.SpawnerEntity ~= nil then
            return ent.SpawnerEntity:ToPlayer()
        elseif ent.Parent ~= nil then
            return ent.Parent:ToPlayer()
        end
    end

    return nil
end

-- Import content
local contentImports = {}
for _, title in pairs(content) do table.insert(contentImports, require(path .. title)) end

local ModIcon = Sprite()
ModIcon:Load("gfx/ui/TOYCOL_mod_icon.anm2", true)

contentImports = TCC_API:InitContent(contentImports, "Toybox Collection", "ToycolMod", ModIcon)