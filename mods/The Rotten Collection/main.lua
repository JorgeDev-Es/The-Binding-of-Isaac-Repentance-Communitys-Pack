ROTCG = RegisterMod("The Rotten Collection", 1)

-- Define content and path
local path = 'scripts.content.'
local content = {'cube_of_rot', 'foul_guts', 'chimerism', 'necrosis', 'knout', 'mothers_spine', 'rotten_gut', 'sick_maggot'}

require('scripts.rotcol_callbacks') -- Import custom/shared callbacks
require('scripts.datamanager') -- Import data manager

function ROTCG.checkAllFam(var, id, amount)
    local numPlayers = Game():GetNumPlayers()
    for i=1,numPlayers do
        local player = Game():GetPlayer(tostring((i-1)))
        player:CheckFamiliar(var, (player:GetCollectibleNum(id)+player:GetEffects():GetCollectibleEffectNum(id))*(amount or 1), player:GetCollectibleRNG(id))
    end
end

function ROTCG.checkFlags(key, flags)
    local numPlayers =  Game():GetNumPlayers()
    for i=1,numPlayers do
        local player =  Game():GetPlayer(tostring((i-1)))
        if TCC_API:Has(key, player) then
            player:AddCacheFlags(flags)
            player:EvaluateItems()
        end
    end
end

-- Import content
local contentImports = {}
for _, title in pairs(content) do table.insert(contentImports, require(path .. title)) end

local ModIcon = Sprite()
ModIcon:Load("gfx/ui/ROTCOL_mod_icon.anm2", true)

contentImports = TCC_API:InitContent(contentImports, "Rotten Collection", "RotcolMod", ModIcon)