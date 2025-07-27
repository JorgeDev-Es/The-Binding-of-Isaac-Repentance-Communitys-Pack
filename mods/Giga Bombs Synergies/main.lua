GigaBombsSynergiesMod = RegisterMod("GigaBombsSynergiesMod", 1)

local myFolder = "loi_GigaBombsSynergies"
local LOCAL_TSIL = require(myFolder .. ".TSIL")
LOCAL_TSIL.Init(myFolder)

include("giga_bomb_synergies_scripts.Constants")
include("giga_bomb_synergies_scripts.Helpers")

---@class GigaBombSynergy
---@field sprite string
---@field anm2File? string
---@field isActive fun(bomb: EntityBomb): boolean
---@field onExplode? fun(bomb: EntityBomb)
---@field onUpdate? fun(bomb: EntityBomb)

---@type GigaBombSynergy[]
local GigaBombSynergies = {}


---@param sprite string
---@param isActive fun(bomb: EntityBomb): boolean
---@param onExplode? fun(bomb: EntityBomb)
---@param onUpdate? fun(bomb: EntityBomb)
---@param anm2File? string
function GigaBombsSynergiesMod.AddGigaBombSynergy(sprite, isActive, onExplode, onUpdate, anm2File)
    GigaBombSynergies[#GigaBombSynergies+1] = {
        sprite = sprite,
        isActive = isActive,
        onExplode = onExplode,
        onUpdate = onUpdate,
        anm2File = anm2File
    }
end


---@param bomb EntityBomb
function GigaBombsSynergiesMod:OnGigaBombInit(bomb)
    local activeBombSynergies = TSIL.Utils.Tables.Filter(GigaBombSynergies, function (_, bombSynergy)
        return bombSynergy.isActive(bomb)
    end)

    if #activeBombSynergies == 0 then return end

    local nancyBombSynergy = TSIL.Utils.Tables.FindFirst(activeBombSynergies, function (_, bombSynergy)
        return bombSynergy.sprite == "GigaNancyBomb"
    end)

    local activeBombSynergy = activeBombSynergies[1]
    if nancyBombSynergy then
        activeBombSynergy = nancyBombSynergy
    end
    local anm2 = activeBombSynergy.anm2File
    local spriteSheet = activeBombSynergy.sprite

    local sprite = bomb:GetSprite()

    if anm2 then
        local animation = sprite:GetAnimation()
        local frame = sprite:GetFrame()
        sprite:Load("gfx/" .. anm2 .. ".anm2", true)
        sprite:Play(animation, true)
        sprite:SetFrame(frame)
    else
        sprite:ReplaceSpritesheet(0, "/gfx/bombs/" .. spriteSheet .. ".png")
        sprite:LoadGraphics()
    end
end
GigaBombsSynergiesMod:AddCallback(
    TSIL.Enums.CustomCallback.POST_BOMB_INIT_LATE,
    GigaBombsSynergiesMod.OnGigaBombInit,
    BombVariant.BOMB_GIGA
)


---@param bomb EntityBomb
function GigaBombsSynergiesMod:OnGigaBombUpdate(bomb)
    local activeBombSynergies = TSIL.Utils.Tables.Filter(GigaBombSynergies, function (_, bombSynergy)
        return bombSynergy.isActive(bomb) and bombSynergy.onUpdate ~= nil
    end)

    TSIL.Utils.Tables.ForEach(activeBombSynergies, function (_, bombSynergy)
        bombSynergy.onUpdate(bomb)
    end)
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_BOMB_UPDATE,
    GigaBombsSynergiesMod.OnGigaBombUpdate,
    BombVariant.BOMB_GIGA
)


---@param bomb EntityBomb
function GigaBombsSynergiesMod:OnGigaBombExplode(bomb)
    local activeBombSynergies = TSIL.Utils.Tables.Filter(GigaBombSynergies, function (_, bombSynergy)
        return bombSynergy.isActive(bomb) and bombSynergy.onExplode ~= nil
    end)

    TSIL.Utils.Tables.ForEach(activeBombSynergies, function (_, bombSynergy)
        bombSynergy.onExplode(bomb)
    end)
end
GigaBombsSynergiesMod:AddCallback(
    TSIL.Enums.CustomCallback.POST_BOMB_EXPLODED,
    GigaBombsSynergiesMod.OnGigaBombExplode,
    BombVariant.BOMB_GIGA
)


--BOMB SYNERGIES
include("giga_bomb_synergies_scripts.BloodBombs")
include("giga_bomb_synergies_scripts.BobbyBombs")
include("giga_bomb_synergies_scripts.BobsCurseBombs")
include("giga_bomb_synergies_scripts.BomberBoyBombs")
include("giga_bomb_synergies_scripts.BrimstoneBombs")
include("giga_bomb_synergies_scripts.ButtBombs")
include("giga_bomb_synergies_scripts.GhostBombs")
include("giga_bomb_synergies_scripts.GlitterBombs")
include("giga_bomb_synergies_scripts.HotBombs")
include("giga_bomb_synergies_scripts.NancyBombs")
include("giga_bomb_synergies_scripts.SackBombs")
include("giga_bomb_synergies_scripts.SadBombs")
include("giga_bomb_synergies_scripts.ScatterBombs")