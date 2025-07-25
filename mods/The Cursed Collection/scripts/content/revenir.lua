--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Revenir"),
    COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/CURCOL_revenir_charged.anm2"),

    SPREAD_RATE = 2,
    WAVE_CHANCE = 100,
    FLAMES = 24,
    CHARGE_TIME = 150,

    DIR = {
        [0] = Vector(-1, 0),
        [1] = Vector(0, -1),
        [2] = Vector(1, 0),
        [3] = Vector(0, 1),
    },

    KEY="REVR",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CRANE_GAME,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Revenir", DESC = "While firing, charge up a swirl of fire" },
        { LANG = "ru",    NAME = "Ревенир", DESC = "Во время стрельбы зарядите огненный вихрь" },
        { LANG = "spa",   NAME = "Revenir", DESC = "Al disparar, se recargará un remolino de fuego" },
        { LANG = "zh_cn", NAME = "死灵骷髅头", DESC = "蓄力后旋转发射一连串紫色火焰" },
        { LANG = "ko_kr", NAME = "레브니르", DESC = "공격키를 2.8초 이상 누르면 충전되며 공격키를 떼면 360도 방향으로 화염을 발사합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "After firing for ~2.8 seconds, releasing the fire button will trigger a swirl of fires."},
            {str = "This item shows a chargebar if the player has them enabled in their settings."},
        },
        { -- Interacions
            {str = "Interacions", fsize = 2, clr = 3, halign = 0},
            {str = "Loki's horns makes the player fire 4 swirls of fire."},
        }
    }
}

local activeWaves = {}
local cachedWaves = {}

local color = Color(0.8,1,1,1)
color:SetColorize(1.3, 1, 1.95, 1)

--TODO: Add synergies?
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function calcMax(frames)
    local num = math.ceil(frames/5)
    return num > item.FLAMES and item.FLAMES or num
end

local function addCostume(player)
    player:AddNullCostume(item.COSTUME)
end

local function startWave(player, dir)
    player:TryRemoveNullCostume(item.COSTUME)
    CURCOL.SFX:Play(SoundEffect.SOUND_GHOST_ROAR)
    table.insert(activeWaves, { parent = player, frame = CURCOL.GAME:GetFrameCount()+0, count = 0, dir = dir, isQuad = player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) })
end

local function genSprite()
    local sprite = Sprite()
    sprite:Load("gfx/animations/CURCOL_chargebar_revenir.anm2", false)
    return sprite
end

function item:OnEffUpdate(eff)
    if eff:GetData().CURCOL_REVENIR and eff.Scale < 1 then
        eff.Scale = eff.Scale + 0.055
    end
end

function item:OnUpdate()
    for i=1, #activeWaves do
        local hasChanged = false
        local value = activeWaves[i]
        if CURCOL.GAME:GetFrameCount() >= value.frame+item.SPREAD_RATE then
            value.parent:ShootRedCandle(value.dir:Rotated(15*value.count))

            if value.isQuad then
                value.parent:ShootRedCandle(value.dir:Rotated(15*value.count+90))
                value.parent:ShootRedCandle(value.dir:Rotated(15*value.count+180))
                value.parent:ShootRedCandle(value.dir:Rotated(15*value.count+270))
            end

            local fires = Isaac.FindByType(1000, EffectVariant.RED_CANDLE_FLAME, -1, true)
            
            for key, eff in pairs(fires) do
                if eff.FrameCount < 1 and not eff:GetData().CURCOL_REVENIR then
                    eff = eff:ToEffect()
                    eff:SetColor(color, -1, 99, false, true)
                    eff.Timeout = 20
                    eff.Velocity = eff.Velocity*1.15
                    eff.Scale = 0.15
                    eff.Position = value.parent.Position
                    eff:GetData().CURCOL_REVENIR = true
                    eff:Update()
                end
            end
            
            if activeWaves[i].count < (activeWaves[i].max or item.FLAMES) then
                activeWaves[i].count = value.count + 1
                activeWaves[i].frame = CURCOL.GAME:GetFrameCount()
                table.insert(cachedWaves, activeWaves[i])
            end

            hasChanged = true
        end

        if hasChanged and i == #activeWaves then
            activeWaves = cachedWaves
            cachedWaves = {}
        end
    end
end

function item:OnNewRoom() activeWaves = {} end
--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--

function item:Enable()
    CURCOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, item.OnEffUpdate, EffectVariant.RED_CANDLE_FLAME)
    CURCOL:AddCallback(ModCallbacks.MC_POST_UPDATE,        item.OnUpdate  )
    CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,      item.OnNewRoom )
    TCC_API:AddTCCChargeBar(item.KEY, genSprite, item.CHARGE_TIME, true, item.ID, addCostume, startWave)
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, item.OnEffUpdate, EffectVariant.RED_CANDLE_FLAME)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_UPDATE,        item.OnUpdate  )
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,      item.OnNewRoom )
    TCC_API:RemoveTCCChargeBar(item.KEY)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item