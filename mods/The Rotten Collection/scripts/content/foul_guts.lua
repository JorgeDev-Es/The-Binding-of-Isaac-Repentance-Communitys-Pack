--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = { 
    ID = Isaac.GetItemIdByName("Foul Guts"),

    MIN = 2,
    EXT = 2,

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BOSS,
        ItemPoolType.POOL_ROTTEN_BEGGAR,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Foul Guts",     DESC = "{{EmptyHeart}} +1 Heart container#{{EmptyBoneHeart}} +2 Bone hearts#{{RottenHeart}} Fills all containers with rotten hearts#{{BlendedHeart}} Drops random hearts when no red hearts can be held" },
        { LANG = "ru",    NAME = "Грязные кишки", DESC = "{{EmptyHeart}} +1 красное сердце#{{EmptyBoneHeart}} +2 костяных сердца#{{RottenHeart}} Заменяет все контейнеры гнилыми сердцами#{{BlendedHeart}} Выбрасывает рандомные сердца если персонаж не может иметь красные сердца" },
        { LANG = "spa",   NAME = "Tripas sucias", DESC = "{{EmptyHeart}} +1 contenedor de corazón vacío#{{EmptyBoneHeart}} +2 corazones de hueso#{{RottenHeart}} Rellena todos los contenedores de corazones con corazones podridos#{{BlendedHeart}} Suelta corazones aleatorios cuando no se pueden tener corazones rojos" },
        { LANG = "zh_cn", NAME = "恶心的内脏",     DESC = "{{EmptyHeart}} +1 心之容器#{{EmptyBoneHeart}} +2 骨心#{{RottenHeart}} 用腐心填满所有心之容器#{{BlendedHeart}} 如果角色无法拥有红心则掉落随机心" },
        { LANG = "ko_kr", NAME = "더러운 내장",    DESC = "{{EmptyHeart}} 빈 최대 체력 +1#{{EmptyBoneHeart}} 뼈하트 +2#{{RottenHeart}} 모든 체력을 썩은하트로 채웁니다.#{{BlendedHeart}} 빨간 하트를 가질 수 없는 경우 이하의 픽업을 2~5개 드랍합니다:#{{Blank}} {{SoulHeart}} {{HalfSoulHeart}} {{BlackHeart}} {{BlendedHeart}} {{BoneHeart}} {{RottenHeart}}" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "+1 Heart container"},
            {str = "+2 Bone Hearts"},
            {str = "Replaces all red hearts and fills all empty containers with rotten hearts"},
            {str = "When the player can't hold any red/rotten hearts then between 2 and 5 of the following hearts will be dropped: Soul, Half soul, Black, Blended, Bone and Rotten"}
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'The texture of this item was based on the "Guts" enemy variant named "Cyst"'}
        },
    }
}

local spawnableHearts = {
    [1] = HeartSubType.HEART_SOUL,
    [2] = HeartSubType.HEART_BLACK,
    [3] = HeartSubType.HEART_HALF_SOUL,
    [4] = HeartSubType.HEART_BLENDED,
    [5] = HeartSubType.HEART_BONE,
    [6] = HeartSubType.HEART_ROTTEN
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnCollect(player, _, touched) -- Apply stats on pickup if they haven't been granted
    if not touched then
        player:AddMaxHearts(2)
        player:AddBoneHearts(2)
        local max = player:GetEffectiveMaxHearts()

        if max > 0 then
            player:AddRottenHearts(max)
        else
            local room = Game():GetRoom()
            for i = 1, player:GetCollectibleRNG(item.ID):RandomInt(item.EXT)+item.MIN+1 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, spawnableHearts[math.random(1, 6)], room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0,0), player)
            end
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCollect, item.ID, false)

return item