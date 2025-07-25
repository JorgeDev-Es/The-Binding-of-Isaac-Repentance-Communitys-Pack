--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Flakes of gold"),

    DROPS = {
        [1] = { ["VARIANT"] = PickupVariant.PICKUP_COIN, ["SUBTYPE"] = CoinSubType.COIN_GOLDEN },
        [2] = { ["VARIANT"] = PickupVariant.PICKUP_KEY, ["SUBTYPE"] = KeySubType.KEY_GOLDEN },
        [3] = { ["VARIANT"] = PickupVariant.PICKUP_PILL, ["SUBTYPE"] = PillColor.PILL_GOLD },
        [4] = { ["VARIANT"] = PickupVariant.PICKUP_LIL_BATTERY, ["SUBTYPE"] = BatterySubType.BATTERY_GOLDEN },
        [5] = { ["VARIANT"] = PickupVariant.PICKUP_BOMB, ["SUBTYPE"] = BombSubType.BOMB_GOLDEN },
        [6] = { ["VARIANT"] = PickupVariant.PICKUP_BOMB, ["SUBTYPE"] = BombSubType.BOMB_GOLDENTROLL }
    },

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BOSS,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Flakes of Gold", DESC = "{{GoldenHeart}} Fills 50% of health with golden hearts#Drops a random gold pickup#Turns held trinkets gold" },
        { LANG = "ru",    NAME = "Хлопья золота", DESC = "{{GoldenHeart}} Заполняет 50% здоровья золотыми сердцами#Даёт случайный золотой пикап#Делает ваш брелок золотым " },
        { LANG = "spa",   NAME = "Copitos dorados", DESC = "{{GoldenHeart}} Tus corazones se vuelven dorados#Suelta un recolectable dorado aleatoria#El trinket que tienes se vuelve dorado" },
        { LANG = "zh_cn", NAME = "食用金箔", DESC = "{{GoldenHeart}} 给予最大数量的金心#掉落一个随机的金基础掉落#将持有的饰品变成对应的金饰品#提高金饰品及金基础掉落的生成概率" },
        { LANG = "ko_kr", NAME = "금 시리얼", DESC = "{{GoldenHeart}} 모든 하트를 골든하트로 채웁니다.#랜덤 황금 픽업을 드랍합니다.#현재 소지 중인 장신구를 황금 장신구로 업그레이드 합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Fills half of the players health with golden hearts."},
            {str = "Turns all held trinkets golden (gulped trinkets are not affected)."},
            {str = "Drops a random golden pickup or golden trinket."},
            {str = "The chance of a golden trinket being dropped is 40%, All other drops have an equal chance of dropping (1/6)."},
        },
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnCollect(player, _, touched) -- Apply stats on pickup if they haven't been granted
    if not touched then
        player:AddGoldenHearts(math.ceil((player:GetMaxHearts()+player:GetSoulHearts())/4))

        local colRNG = player:GetCollectibleRNG(item.ID)

        if colRNG:RandomInt(10)+1 > 6 then
            -- local selection  = colRNG:RandomInt(TrinketType.NUM_TRINKETS)+1
            local trinket = GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, GOLCG.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0,0), player):ToPickup()
            trinket:Morph(trinket.Type, trinket.Variant, (trinket.SubType > 32768 and trinket.SubType or trinket.SubType+32768))
        else
            local selection = item.DROPS[colRNG:RandomInt(#item.DROPS)+1]
            GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, selection.VARIANT, selection.SUBTYPE, GOLCG.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0,0), player)
        end

        local trinketA = player:GetTrinket(0)
        local trinketB = player:GetTrinket(1)
        
        if trinketA and trinketA > 0 and trinketA < 32768 then
            player:TryRemoveTrinket(trinketA)
            player:AddTrinket(trinketA+32768, false)
        end

        if trinketB and trinketB > 0 and trinketB < 32768 then
            player:TryRemoveTrinket(trinketB)
            player:AddTrinket(trinketB+32768, false)
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCollect, item.ID)

return item