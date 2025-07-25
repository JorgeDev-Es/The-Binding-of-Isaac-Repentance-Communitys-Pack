--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Jar of air"),
    
    PICKUP_SFX = Isaac.GetSoundIdByName("TOYCOL_JAR_OF_AIR_PICKUP"),
    TRIGGER_SFX = Isaac.GetSoundIdByName("TOYCOL_JAR_OF_AIR_TRIGGER"),
    BLOCK_SFX = Isaac.GetSoundIdByName("TOYCOL_JAR_OF_AIR_BLOCK"), --Not working?

    LOCUST_AMOUNT = 3,
    TRIGGER_CHANCE = 10,
    MIN_POISON = 41,
    ADDED_POISON = 260,

    KEY = "JAAI",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Jar of Air", DESC = "{{ArrowUp}} +1 Health up#{{RottenHeart}} +1 Rotten heart#{{Collectible706}} +3 Poison locusts#Poison resistance#Some enemies are poisoned when appearing" },
        { LANG = "ru",    NAME = "Банка воздуха", DESC = "{{ArrowUp}} +1 повышение здоровья#{{RottenHeart}} +1 гнилое сердце#{{Collectible706}} +3 ядовитых мух#Сопротивление яду#Некоторые враги отравлены при появлении" },
        { LANG = "spa",   NAME = "Frasco de Aire", DESC = "{{ArrowUp}} +1 corazón#{{RottenHeart}} +1 corazón podrido#{{Collectible706}} +3 langostas venenosas#Resistencia al veneno#Algunos enemigos serán envenenados al aparecer" },
        { LANG = "zh_cn", NAME = "空气罐", DESC = "{{ArrowUp}} +1 体力上升#{{RottenHeart}} +1 腐心#{{Collectible706}} +3 剧毒深渊蝗虫#角色获得剧毒免疫#怪物生成时概率中毒#(出自 泰拉瑞亚)" },
        { LANG = "ko_kr", NAME = "병 속의 공기", DESC = "{{ArrowUp}} {{EmptyHeart}}최대 체력 +1#{{RottenHeart}} 썩은하트 +1#{{Collectible706}} 독성 심연의 파리 +3#캐릭터가 독구름에 면역이 됩니다.#적 출현 시 10%의 확률로 중독됩니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants a health up and one rotten heart upon pickup."},
            {str = "If the player can't carry health 5 normal poison flies will be spawned instead."},
            {str = "Also adds 3 abyss poison locusts to the player when picked up."},
            {str = "Grants poison cloud and poison damage resistance."},
            {str = "Spawns farts and poisons random enemies when they spawn in."},
            {str = "The poisoning lasts a random amount of time."},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "Terraria".'},
            {str = 'The item is referencing the "Fart in a Jar" accessory that can be found in the game.'},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--

function item:OnSpawn(NPC)
    if NPC:IsActiveEnemy(false) and NPC:IsVulnerableEnemy() and NPC.CanShutDoors then
        local RNG = RNG()
        RNG:SetSeed(NPC.InitSeed, 1)

        if RNG:RandomInt(100)+1 <= (item.TRIGGER_CHANCE*TCC_API:HasGlo(item.KEY)) then
            TOYCG.GAME:Fart(NPC.Position, 85)
            NPC:AddPoison(EntityRef(Isaac.GetPlayer(0)), RNG:RandomInt(item.ADDED_POISON)+item.MIN_POISON, 1)
            if not TOYCG.SFX:IsPlaying(item.TRIGGER_SFX) then
                TOYCG.SFX:Play(item.TRIGGER_SFX, 1) 
                TOYCG.SFX:Stop(SoundEffect.SOUND_FART)
            end
        end
    end
end

function item:OnDamage(entity, _, flags, source, _)
    if TCC_API:Has(item.KEY, entity:ToPlayer()) > 0 and ((flags & DamageFlag.DAMAGE_POISON_BURN) ~= 0 or (source.Type == 1000 and source.Variant == 141)) then
        TOYCG.SFX:Play(item.BLOCK_SFX, 1)
        return false
    end
end

function item:OnCollect(player, _, touched)
    if not touched then
        player:AddMaxHearts(2)
        player:AddRottenHearts(2)
        
        for i=1, item.LOCUST_AMOUNT do
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, 305, player.Position, Vector(0,0), player)
        end
    end
end

function item:OnGrab() TOYCG.SharedOnGrab(item.PICKUP_SFX) end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--

function item:Enable()
    TOYCG:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
    TOYCG:AddCallback(ModCallbacks.MC_POST_NPC_INIT,   item.OnSpawn                           )
end

function item:Disable()
    TOYCG:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT,   item.OnSpawn                           )
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab,    item.ID, false)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect, item.ID, false)

return item