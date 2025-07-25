--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Whirling leech"),
    LEECH = Isaac.GetEntityVariantByName("SEWCOL friendly leech"),

    MAX_SPAWN_LEECHES = 2,

    ENEMY_FILTER = {
        [55] = 3,
        [854] = 6,
        [21] = 2,
        ['23.0'] = 2,
        ['23.1'] = 2,
        ['23.2'] = 2,
        [810] = 1,
        [853] = 1,
        [855] = 5,
        ['881.0'] = 2,

        ['19.0'] = 1,
        ['62.0'] = 1,
        ['62.1'] = 1,
        ['62.3'] = 1,
        ['28.0'] = 2,
        ['28.1'] = 2,
        ['19.1'] = 1,
    },

    KEY = "BLSU",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_BOSS,
        ItemPoolType.POOL_GREED_BOSS,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Whirling Leech", DESC = "{{EmptyHeart}} +1 heart container#Worm-like enemies are weakened#Worm-like enemies spawn friendly leeches#Taking damage spawns friendly leeches" },
        { LANG = "ru",    NAME = "Вращающаяся пиявка", DESC = "{{EmptyHeart}} +1 красное сердце#Червеподобные враги ослаблены или очарованы#Червеподобные враги порождают дружественных пиявок#Получение урона порождает дружественных пиявок" },
        { LANG = "spa",   NAME = "Sanguijuela remolinante", DESC = "{{EmptyHeart}} +1 contenedore de corazón#Enemigos gusanos serán encantados o debilitados#Generará leeches amigables al recibir daño" },
        { LANG = "zh_cn", NAME = "回旋水蛭", DESC = "{{EmptyHeart}} +1 心之容器#蠕虫类怪物会被削弱或魅惑#角色受到伤害时会生成一些友方小水蛭" },
        { LANG = "ko_kr", NAME = "소용돌이 리치", DESC = "{{EmptyHeart}} 빈 최대 체력 +1#벌레류 몬스터가 매혹되거나 약화됩니다.#피격 시 아군 Leech를 소환합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants an empty heart container upon pickup."},
            {str = "Leeches, worms and maggots are weakened to 5 or less health upon spawning."},
            {str = "Upon death these enemies spawn a couple of friendly leeches."},
            {str = "When the player takes damage between 3 and 5 random friendly leeches may be spawned within the room."},
        }
    }
}

local function addModdedEnemy(enemy, leeches) item.ENEMY_FILTER[Isaac.GetEntityTypeByName(enemy)..'.'..Isaac.GetEntityVariantByName(enemy)] = leeches or 1 end

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function isInFilter(NPC)
    return item.ENEMY_FILTER[NPC.Type] or item.ENEMY_FILTER[NPC.Type..'.'..NPC.Variant]
end

function item:OnDamage(entity, _, flags, _, _)
    local player = entity:ToPlayer()
    if TCC_API:Has(item.KEY, player) > 0 then
        local amount = player:GetCollectibleRNG(item.ID):RandomInt(item.MAX_SPAWN_LEECHES+1)+3
        local room = SEWCOL.GAME:GetRoom()

        for i=1, amount do
            local pos = room:FindFreePickupSpawnPosition(Isaac.GetRandomPosition(), 0, true)
            SEWCOL.SeedSpawn(3, item.LEECH, 0, pos, Vector(0,0), player)
        end
    end
end

function item:OnSpawn(NPC)
    if TCC_API:HasGlo(item.KEY) > 0 and isInFilter(NPC) and not NPC:IsBoss() and not NPC:HasEntityFlags(EntityFlag.FLAG_CHARM) and not NPC:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) then
        local player = SEWCOL.GAME:GetPlayer(0)
        NPC:AddHealth(-(NPC.MaxHitPoints-(player:GetCollectibleRNG(item.ID):RandomInt(5)+1)))
        NPC:SetColor(Color(1, 1, 1, 1, 0.6, 0, 0), 10, 99, true, false)
    end
end

function item:OnDeath(NPC)        
    if isInFilter(NPC) then
        local numPlayers = SEWCOL.GAME:GetNumPlayers()

        for i=1,numPlayers do
            local player = SEWCOL.GAME:GetPlayer(tostring((i-1)))

            for i=1, TCC_API:Has(item.KEY, player)*isInFilter(NPC) do
                SEWCOL.SeedSpawn(3, item.LEECH, 0, Vector(5, 5):Rotated(math.random(360)) + NPC.Position, Vector(0,0), player)
            end
        end
    end
end

--##############################################################################--
--############################# MOD COMPATIBILITY ##############################--
--##############################################################################--
function item:PostLoad()
    if IpecacMod then
        addModdedEnemy('Leecher')
        addModdedEnemy('Scolexian', 2)
        addModdedEnemy('Meat Boy Tapeworm', 1)
        addModdedEnemy('Tammy Tapeworm', 1)
        addModdedEnemy('Isaac Tapeworm', 1)
        addModdedEnemy('Steven Tapeworm', 1)
    end

    if deliveranceContent then
        addModdedEnemy('Rosenberg', 2)
        addModdedEnemy('Eddie')
    end

    if FiendFolio then
        addModdedEnemy("Drink Worm")
        addModdedEnemy("Creepy Maggot")
        addModdedEnemy("Nubert")
        addModdedEnemy("Tapeworm")
        addModdedEnemy("Weaver", 2)
        addModdedEnemy("Archer", 2)
        addModdedEnemy("Carrier", 2)
        addModdedEnemy("Weaver Sr.", 2)
        addModdedEnemy("Thread", 2)
        addModdedEnemy("Retch", 2)
        addModdedEnemy("Dread Weaver", 2)
        addModdedEnemy("Drunk Worm", 3)
        addModdedEnemy("Gorger", 3)
        addModdedEnemy("Psleech", 3)
        addModdedEnemy("Bunker Worm", 4)
        addModdedEnemy("Gary", 4)

        addModdedEnemy("Kingpin")
        addModdedEnemy("Luncheon", 5)
    end

    if REVEL then
        addModdedEnemy("Ice Worm", 2)
        addModdedEnemy("Tile Monger", 2)
        addModdedEnemy("Sand Worm", 2)
        addModdedEnemy("Sandy", 6)
        addModdedEnemy("Sandy (No Shadow)", 6)
    end

    if CiiruleanItems then
        addModdedEnemy("Drowned Conjoined Spitty")
        addModdedEnemy("Drowned Grub", 2)
        addModdedEnemy("Drowned Maggot")
        addModdedEnemy("Drowned Spitty")
    end

    SEWCOL:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)
end

SEWCOL:AddCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    SEWCOL:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,    item.OnDamage, EntityType.ENTITY_PLAYER)
    SEWCOL:AddCallback(ModCallbacks.MC_POST_NPC_INIT,      item.OnSpawn                           )
    SEWCOL:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, item.OnDeath) 
end

function item:Disable()
    SEWCOL:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
    SEWCOL:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT,   item.OnSpawn                           )
    SEWCOL:RemoveCallback(ModCallbacks.MC_POST_NPC_DEATH, item.OnDeath) 
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item