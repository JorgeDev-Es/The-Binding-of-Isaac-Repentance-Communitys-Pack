--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetTrinketIdByName("Amalgamation"),

    CHANCE = 50,

    TYPE = 350,
    KEY="AMAL",
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Amalgamation", DESC = "Is gulped upon pickup#{{Trinket}} Trinkets have a 50% chance to be gulped when picked up" },
        { LANG = "ru",    NAME = "Слияние", DESC = "Проглатывается при получении#{{Trinket}} Брелки имеют 50% шанс быть проглоченными при поднятии" },
        { LANG = "spa",   NAME = "Amalgama", DESC = "Es tragado por defecto#{{Trinket}} Los trinkets tienen un 50% de posibilidad de ser tragados al tomarlos" },
        { LANG = "zh_cn", NAME = "融合", DESC = "拾取时自动吞下该饰品#{{Trinket}} 50%的概率吞下第一次拾取的饰品" },
        { LANG = "ko_kr", NAME = "융합", DESC = "!!! 획득과 동시에 흡수됨#{{Trinket}} 장신구를 집을 때 50%의 확률로 흡수됩니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When picked up this trinket will automatically gulp itself."},
            {str = "While carried the player has a 50% chance to gulp other trinkets when they are picked up for the first time."},
            {str = "Chance is increased by +10% for every trinket multiplier."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnCollectTrink(player, id, touched, isTrinket)
    if isTrinket and id == item.ID then
        local otherTrinket = 0

        local trinket0 = player:GetTrinket(0)
        local trinket1 = player:GetTrinket(1)

        if trinket0 >= 32768 then trinket0 = trinket0-32768 end
        if trinket1 >= 32768 then trinket1 = trinket0-32768 end

        if trinket0 ~= id and trinket0 > 0 then
            otherTrinket = player:GetTrinket(0)
            player:TryRemoveTrinket(trinket0)
        elseif trinket1 ~= id and trinket1 > 0 then
            otherTrinket = player:GetTrinket(1)
            player:TryRemoveTrinket(trinket1)
        end

        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false, -1)
        CURCOL.SFX:Play(SoundEffect.SOUND_VAMP_GULP)
        
        if otherTrinket > 0 then
            player:AddTrinket(otherTrinket, false)
        end
    end
end

function item:OnCollect(player, id, touched, isTrinket)
    if isTrinket and TCC_API:Has(item.KEY, player) > 0 and not touched and player:GetTrinketRNG(item.ID):RandomInt(100)+1 <= (item.CHANCE+((TCC_API:Has(item.KEY, player)-1)*10)) then
        local otherTrinket = 0

        local trinket0 = player:GetTrinket(0)
        local trinket1 = player:GetTrinket(1)

        if trinket0 >= 32768 then trinket0 = trinket0-32768 end
        if trinket1 >= 32768 then trinket1 = trinket0-32768 end

        if trinket0 ~= id and trinket0 > 0 then
            otherTrinket = player:GetTrinket(0)
            player:TryRemoveTrinket(trinket0)
        elseif trinket1 ~= id and trinket1 > 0 then
            otherTrinket = player:GetTrinket(1)
            player:TryRemoveTrinket(trinket1)
        end

        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false, -1)
        CURCOL.SFX:Play(SoundEffect.SOUND_VAMP_GULP)
        
        if otherTrinket > 0 then
            player:AddTrinket(otherTrinket, false)
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable() TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect) end
function item:Disable() TCC_API:RemoveTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect) end

TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollectTrink)

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item