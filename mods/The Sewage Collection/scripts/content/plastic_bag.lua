--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Plastic bag"),

    MAX_CREEP = 80,
    BOMB_CHANCE = 8,

    KEY = "PLBA",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_BEGGAR,
        ItemPoolType.POOL_GREED_BOSS,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Plastic Bag", DESC = "Enemies killed will spawn friendly poop creep#May also spawn butt bombs" },
        { LANG = "ru",    NAME = "Полиэтиленовый пакет", DESC = "Убитые враги будут порождать дружественные лужи какашек#Они также могут создавать прикладные бомбы" },
        { LANG = "spa",   NAME = "Bolsa Plástica", DESC = "Los enemigos asesinados generarán creep de popó#También podrán generar bombas traseras" },
        { LANG = "zh_cn", NAME = "塑料袋", DESC = "怪物被杀死后会在地上留下一滩棕色水渍，有8%的概率同时生成一颗屁股炸弹#角色站在水渍上会获得攻击和射速加成" },
        { LANG = "ko_kr", NAME = "비닐백", DESC = "적 처치 시 적에게 공격력 x1.5의 피해를 주는 갈색 장판을 생성됩니다.#적 처치 시 8%의 확률로 똥 폭탄이 설치됩니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Enemies killed will spawn a puddle of friendly poop creep."},
            {str = "They also have a 7% chance to spawn a butt bomb with this creep."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnDeath(NPC)        
    if NPC:IsActiveEnemy(true) and TCC_API:HasGlo(item.KEY) > 0 then
        local player = SEWCOL.GAME:GetPlayer(0)

        if Isaac.CountEntities(nil, 1000, EffectVariant.CREEP_LIQUID_POOP) < item.MAX_CREEP then
            for i=1, math.random(3)+2 do
                SEWCOL.SeedSpawn(
                    1000, 
                    EffectVariant.CREEP_LIQUID_POOP, 
                    0, 
                    i==1 and NPC.Position or NPC.Position+Vector(math.random(20)+20*(math.random(2)>1 and 1 or -1), math.random(20)+20*(math.random(2)>1 and 1 or -1)), 
                    Vector(0,0), 
                    player
                ):Update()
            end
        end

        if player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= item.BOMB_CHANCE then
            local bomb = SEWCOL.SeedSpawn(EntityType.ENTITY_BOMBDROP, 9, 0, NPC.Position, (NPC.Position-player.Position):Normalized()*10, player):ToBomb()
            bomb:AddTearFlags(TearFlags.TEAR_BUTT_BOMB)
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()  SEWCOL:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, item.OnDeath)    end
function item:Disable() SEWCOL:RemoveCallback(ModCallbacks.MC_POST_NPC_DEATH, item.OnDeath) end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)


return item