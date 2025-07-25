--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Witch wand"),

    PICKUP_SFX = Isaac.GetSoundIdByName("TOYCOL_WAND_PICKUP"),
    BOSS_SFX = Isaac.GetSoundIdByName("TOYCOL_WAND_BOSS"),
    TRIGGER_SFX = Isaac.GetSoundIdByName("TOYCOL_WAND_SPAWN"),

    SPAWN_CHANCE = 23,
    ENEMIES = {
        { Type=883 }, -- Baby Begotten
        { Type=891 }, -- Goat
        { Type=891, Variant=1 }, -- Black Goat
        -- { Type=885 }, Cultist (Too OP so it's disabled)
        { Type=885, Variant=1 }, -- Blood Cultist
        { Type=841 }, -- Revenant
        { Type=841, Variant=1 }, -- Quad Revenant
        { Type=890 }, -- Maze Roamer
        { Type=886 }, -- Vis Fatty
        { Type=886, Variant=1 }, -- Fetal Demon
        { Type=834 }, -- Whipper
        { Type=834, Variant=1 }, -- Snapper
        { Type=834, Variant=2 }, -- Flagellant
        { Type=24, Variant=3 }, -- Cursed Goblin (XQC)
        { Type=41, Variant=2 }, -- Loose Knight
        { Type=41, Variant=3 }, -- Brainless Knight
        { Type=41, Variant=4 }, -- Black Knight
        { Type=840 }, -- Pon
        { Type=92 }, -- Mask + Heart
        { Type=92, Variant=1 }, -- Mask 2 + 1/2 Heart
        { Type=892 }, -- Poofer
        { Type=836 }, -- Vis Versa
        { Type=863 }, -- Morning Star
        { Type=248 }, -- Psychic Horf
        { Type=26, Variant=2 }, -- Psychic Maw
        { Type=246, Variant=1 }, -- Rag Man Ragling
        { Type=260, Variant=10 }, -- Lil' Haunt
        { Type=833 }, -- Candler
        { Type=816, Variant=1 }, -- Kineti
        { Type=805 }, -- Bishop
        { Type=227 }, -- Bony
    },
    BOSSES = {
        [EntityType.ENTITY_VISAGE] = true,
        [EntityType.ENTITY_HORNY_BOYS] = true,
        [EntityType.ENTITY_RAGLICH] = true, --unused
        [EntityType.ENTITY_SIREN] = true,
        [EntityType.ENTITY_HERETIC] = true,
    },

    KEY = "WIWA",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CURSE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_CURSE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Witch Wand", DESC = "{{BlackHeart}} +1 Black heart#Can spawn a friendly enemy upon damage#Weaken gehenna and mausoleum bosses#Fear resistance" },
        { LANG = "ru",    NAME = "Ведьмин жезд", DESC = "{{BlackHeart}} +1 черное сердце#Может вызвать дружественного врага при получении урона#Ослабляет боссов геенны и мавзолея#Сопротивление страху" },
        { LANG = "spa",   NAME = "Varita de bruja", DESC = "{{BlackHeart}} +1 Corazón negro#Puede generar un enemigo al recibir daño#Debilita a los jefes de Mausoleo y Gehena#Resistencia al miedo" },
        { LANG = "zh_cn", NAME = "魔杖", DESC = "{{BlackHeart}} +1 黑心#角色受伤时有23%的概率生成友方的陵墓层/炼狱层怪物#削弱陵墓层/炼狱层的首领#角色获得恐惧免疫#(出自 Noita)" },
        { LANG = "ko_kr", NAME = "마녀의 완드", DESC = "{{BlackHeart}} 블랙하트 +1#피격 시 23%의 확률로 Mausoleum/Gehenna 스테이지의 랜덤 아군 몬스터 하나를 소환합니다.#Mausoleum/Gehenna 스테이지의 보스의 체력을 50% 감소시킵니다.#캐릭터가 공포에 면역이 됩니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants one black heart."},
            {str = "Has a 23% chance to spawn a gehenna or mausoleum themed enemy upon taking damage."},
            {str = "Weakens the following bosses to 50% health: The Visage, Horny Boys, Siren and The Heretic."},
            {str = "Grants the player fear immunity"},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "Noita".'},
            {str = 'The item is one of the wands granted to the player upon starting a run.'},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnPlayerUpdate(player)
    if TCC_API:Has(item.KEY, player) > 0 then player:ClearEntityFlags(EntityFlag.FLAG_FEAR) end -- fear immunity
end

function item:OnDamage(entity, _, _, _, _)
    local player = entity:ToPlayer()

    if TCC_API:Has(item.KEY, player) > 0 then
        local RNG = player:GetCollectibleRNG(item.ID)
     
        if RNG:RandomInt(100)+1 <= (item.SPAWN_CHANCE*TCC_API:Has(item.KEY, player)) then
            local selection = item.ENEMIES[RNG:RandomInt(#item.ENEMIES)+1]
            local fren = TOYCG.GAME:Spawn(selection.Type, selection.Variant or 0, player.Position, Vector(0,0), player, 0, RNG:GetSeed())
            fren:AddCharmed(EntityRef(player), -1)
            TOYCG.SFX:Play(item.TRIGGER_SFX, 1)
        end
    end
end

function item:OnSpawn(NPC)
    if item.BOSSES[NPC.Type] and TCC_API:HasGlo(item.KEY) > 0 then
        NPC:AddHealth(-(NPC.MaxHitPoints/2))
        TOYCG.SFX:Play(item.BOSS_SFX, 1)
    end
end

function item:OnGrab() TOYCG.SharedOnGrab(item.PICKUP_SFX) end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    TOYCG:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, item.OnPlayerUpdate                    )
    TOYCG:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,    item.OnDamage, EntityType.ENTITY_PLAYER)
    TOYCG:AddCallback(ModCallbacks.MC_POST_NPC_INIT,      item.OnSpawn                           )
end

function item:Disable()
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, item.OnPlayerUpdate                    )
    TOYCG:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,    item.OnDamage, EntityType.ENTITY_PLAYER)
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT,      item.OnSpawn                           )
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab, item.ID, false)

return item