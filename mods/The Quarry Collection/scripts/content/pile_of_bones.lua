--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Pile of bones"),

    SPURS = 16,
    ORBITALS = 3,

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Pile of Bones", DESC = "{{EmptyBoneHeart}} +1 Bone heart on pickup#Summons bone spurs#May grant bone orbitals" },
	    { LANG = "ru",    NAME = "Куча костей", DESC = "{{EmptyBoneHeart}} +1 костяное сердце#Вызывает костяные шпоры#Может дать костные орбитали" },
        { LANG = "spa",   NAME = "Pila de huesos", DESC = "{{EmptyBoneHeart}} +1 corazón de hueso#Puede generar {{Collectible683}} Espuelas de hueso#Puede otorcar orbitales de huesos" },
	    { LANG = "zh_cn", NAME = "骨堆",     DESC = "{{EmptyBoneHeart}} +1 骨心#使用后生成骨头环绕物并在房间内生成一些骨刺" },
        { LANG = "ko_kr", NAME = "뼈 더미", DESC = "{{EmptyBoneHeart}} 뼈하트 +1#뼛조각과 뼈 배리어를 소환합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When used will spawn 16 bone spurs at the players position that move into a random direction."},
            {str = "May also grant up to 3 bone orbitals."},
            {str = "Also grants 1 bone heart upon pickup."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function randomVel(amp)
    local x = math.random()*(math.random() > 0.5 and -1 or 1)
    local y = math.random()*(math.random() > 0.5 and -1 or 1)

    return Vector(x,y)*amp
end

function item:OnUse(_, RNG, player)
    QUACOL.SFX:Play(SoundEffect.SOUND_DEATH_BURST_BONE, 1, 2, false, 1.2)
    -- local room = QUACOL.GAME:GetRoom()

    for i=1, item.SPURS do
        -- local rotation = 180+(math.random(120)-60)
        QUACOL.SeedSpawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, player.Position, randomVel(10), player)
    end

    for i=1, RNG:RandomInt(item.ORBITALS+1) do
        QUACOL.SeedSpawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_ORBITAL, 0, player.Position, Vector(0,0), player)
    end
end

function item:OnCollect(player, _, touched)
    if not touched then
        player:AddBoneHearts(1)
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
QUACOL:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCollect, item.ID)

return item