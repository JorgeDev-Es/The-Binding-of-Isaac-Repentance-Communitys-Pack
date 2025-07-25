--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local trinket = {
    ID = Isaac.GetTrinketIdByName("The mirror"),

    CHANCE = 10,
    COL_CHANCE = 25,
    COIN_CHANCE = 2,

    KEY="THMI",
    TYPE = 350,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "The Mirror", DESC = "Chance to {{SEWCOL_ColorReflect}}reflect{{ColorReset}} items increased" },
        { LANG = "ru",    NAME = "Зеркало", DESC = "Шанс на{{SEWCOL_ColorReflect}}отражение{{ColorReset}} предметов увеличены" },
        { LANG = "spa",   NAME = "El Espejo", DESC = "Posibilidad de objetos {{SEWCOL_ColorReflect}}reflejados{{ColorReset}} incrementada" },
        { LANG = "zh_cn", NAME = "镜子", DESC = "增加{{SEWCOL_ColorReflect}}镜像{{ColorReset}}物品出现的概率" },
        { LANG = "ko_kr", NAME = "거울", DESC = "{{SEWCOL_ColorReflect}}거울 형태{{ColorReset}}의 픽업 확률 증가#거울 형태의 픽업은 습득 시 2배로 복사되나 피해를 받습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Increases the chance to reflect pickups by 10%."},
            {str = "Increases the chance to reflect collectibles by 35%."},
            {str = "These chances are increased by ~5% and ~12.5% respecively for every trinket multiplier."},
            {str = "Default: 10% and 25%, Gold/Mom's Box: 15% and 33%, Both: 20% and 50%."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function trinket:OnSpawn(pickup)
    if SEWCOL.REFLECTION.WHITELIST[pickup.Variant] and not pickup:GetData().SEWCOL_MIRRORED then
        local RNG = RNG()
        RNG:SetSeed(pickup:GetDropRNG():GetSeed(), 1)
        
        if RNG:RandomInt(100)+1 <= math.ceil(((pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == CoinSubType.COIN_PENNY) and trinket.COIN_CHANCE or pickup.Variant == 100 and trinket.COL_CHANCE or trinket.CHANCE)*(TCC_API:HasGlo(trinket.KEY)/2+0.5)) then
            SEWCOL.Reflect(pickup)
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function trinket:Enable()
    TCC_API:AddTCCCallback("TCC_ON_SPAWN", trinket.OnSpawn)
end

function trinket:Disable()
    TCC_API:RemoveTCCCallback("TCC_ON_SPAWN", trinket.OnSpawn)
end

TCC_API:AddTCCInvManager(trinket.ID, trinket.TYPE, trinket.KEY, trinket.Enable, trinket.Disable)

return trinket

