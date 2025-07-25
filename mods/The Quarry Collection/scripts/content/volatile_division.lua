--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local trinket = {
    ID = Isaac.GetTrinketIdByName("Volatile division"),

    REPLACE_CHANCE = 25,

    KEY="VODI",
    TYPE = 350,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Volatile division", DESC = "Bomb pickups spawn with a throwable bomb#Higher bomb double pack chance" },
	    { LANG = "ru",    NAME = "Неустойчивое подразделение", DESC = "Пикапы бомб появляются с бросаемой бомбой#Более высокий шанс двойной бомбы" },
        { LANG = "spa",   NAME = "División Volátil", DESC = "Las bombas generadas aparecerán junto a una bomba roja lanzable#Mayor posibilidad de conseguir bombas dobles" },
        { LANG = "zh_cn", NAME = "不稳定分裂", DESC = "每当生成一个炸弹掉落物会同时生成一个可投掷炸弹#有25%的概率将炸弹掉落物转变成双炸弹掉落物" },
        { LANG = "ko_kr", NAME = "휘발성 분할", DESC = "폭탄 픽업이 드랍될 때 캐릭터가 집을 수 있는 빨간 폭탄이 추가로 드랍됩니다.#25%의 확률로 폭탄 픽업을 1+1 폭탄 픽업으로 바꿉니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Every bomb pickup spawned will spawn an additional throwable bomb with it."},
            {str = "The amount of throwable bombs is increased +1 for every trinket multiplier."},
            {str = "Has a 25% chance to replace a bomb pickup with a bomb doublepack pickup."},
            {str = "This chance is increased by 100% for every trinket multiplier."},
        }
    }
}

--##############################################################################--
--################################# trinket LOGIC #################################--
--##############################################################################--
function trinket:OnSpawn(pickup)
    if pickup.Type == 5 and pickup.Variant == 40 and (pickup.SubType == 1 or pickup.SubType == 2 or pickup.SubType == 4) then
        for i=1, TCC_API:HasGlo(trinket.KEY) do
            QUACOL.SeedSpawn(5, 41, 0, pickup.Position, Vector(1,1):Rotated(math.random(360)), pickup)
        end

        if pickup.SubType == 1 and pickup:GetDropRNG():RandomInt(100)+1 <= trinket.REPLACE_CHANCE*TCC_API:HasGlo(trinket.KEY) then
            pickup:Morph(pickup.Type, pickup.Variant, BombSubType.BOMB_DOUBLEPACK, true, true)
            for i=1, TCC_API:HasGlo(trinket.KEY) do
                QUACOL.SeedSpawn(5, 41, 0, pickup.Position, Vector(1,1):Rotated(math.random(360)), pickup)
            end
        elseif pickup.SubType == 2 then
            for i=1, TCC_API:HasGlo(trinket.KEY) do
                QUACOL.SeedSpawn(5, 41, 0, pickup.Position, Vector(1,1):Rotated(math.random(360)), pickup)
            end
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