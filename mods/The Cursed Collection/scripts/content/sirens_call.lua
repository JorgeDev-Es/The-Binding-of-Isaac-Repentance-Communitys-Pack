local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Siren's call"),

    MAX_FAM = 35,
    -- ITEM_TYPES = { 
    --     8,10,11,57,67,73,88,94,95,96,98,99,100,112,113,128,131,144,155,
    --     163,167,170,172,174,178,187,188,206,207,264,265,266,267,268,269,
    --     270,271,272,273,274,275,276,277,278,279,280,281,318,319,320,321,
    --     322,360,361,362,363,364,365,372,384,385,387,388,389,390,403,404,
    --     405,417,426,430,431,435,436,467,468,469,470,471,472,473,491,492,
    --     500,508,509,511,518,519,525,526,528,537,539,542,543,544,548,565,
    --     567,569,575,581,607,608,610,612,615,626,627,629,645,649,651,652,
    --     656,667,679,681,682,697,698,

    --     -- 81 -- Dead cat
    -- },
    FAM_TYPES = {
        1,2,3,4,5,6,7,8,9,10,11,13,14,16,17,22,25,30,31,32,35,42,
        48,50,51,52,53,54,55,56,58,59,60,61,62,63,65,66,67,68,74,75,
        76,77,79,80,81,83,84,85,87,89,92,94,95,96,97,98,99,100,
        101,103,104,105,106,107,108,110,112,116,117,118,119,120,
        123,125,126,127,130,204,207,208,209,210,212,218,224,225,
        230,233,235,239,241,44,45,46,47,69,70,71,72
    },
    COLOR = Color(1, 1, 1, 0.7, 0.6, 0, 0),

    POSITIONS = {
        Vector(-40,-40),
        Vector(40,40),
        Vector(-40,40),
        Vector(40,-40)
    },

    TYPE = 100,
    KEY="SICA",
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_ULTRA_SECRET,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Siren's Call", DESC = "{{Card92}} +1 familiar#Spawn a familiar when taking damage#Lasts for the current room" },
        { LANG = "ru",    NAME = "Зов сирены", DESC = "{{Card92}} +1 спутник#Создайте спутника при получении урона#Длится для текущей комнаты" },
        { LANG = "spa",   NAME = "El llamado de Siren", DESC = "{{Card92}} +1 familiar#Se generará un familiar al recibir daño#Durará por toda la sala" },
        { LANG = "zh_cn", NAME = "塞壬的呼唤", DESC = "{{Card92}} 获得一只随机跟班#角色受伤时临时获得一只随机跟班，离开房间后消失#在陵墓Ⅱ层/炼狱Ⅱ层的首领房内受伤固定获得完整菜刀跟班#在暗室层/玩具箱层的初始房间受伤固定获得完整钥匙跟班" },
        { LANG = "ko_kr", NAME = "사이렌의 부름", DESC = "{{Card92}} 획득 시 패밀리어 하나를 추가로 획득합니다.#피격 시 그 방에서 패밀리어 하나를 소환합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When picked up this item will grant one random item form the baby shop pool."},
            {str = "If the player takes damage then a random temporary familiar will be spawned. These familiars will dissapear when exiting the room. "},
            {str = "The familiar granted from taking damage is guarenteed to be a full knife on mausoleum / gehenna II while in the boss room."},
            {str = "The familiar granted from taking damage is guarenteed to be a full key on dark room / chest while in the starting room."},
        },
        { -- Interacions
            {str = "Interacions", fsize = 2, clr = 3, halign = 0},
            {str = "Box of friends: is able to duplicate temporary familiars."}
        }
    }
}

local hasTriggered = false
local cachedFamiliars = {}
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function insertFam(seed, variant)
    if cachedFamiliars[seed][variant] then
        cachedFamiliars[seed][variant] = cachedFamiliars[seed][variant]+1
    else
        cachedFamiliars[seed][variant] = 1
    end
end

function item:OnDamage(entity, _, flags, _, _)
    local player = entity:ToPlayer()

    if TCC_API:Has(item.KEY, player) then
        if not cachedFamiliars[player.InitSeed] then cachedFamiliars[player.InitSeed] = {} end
        local level = CURCOL.GAME:GetLevel()
        local stage = level:GetStage()
        
        for i=1, player:GetCollectibleNum(item.ID) do
            local variant = item.FAM_TYPES[player:GetCollectibleRNG(item.ID):RandomInt(#item.FAM_TYPES)+1]

            if not cachedFamiliars[player.InitSeed][223] 
            and stage == LevelStage.STAGE3_2 
            and level:IsAltStage()
            and CURCOL.GAME:GetRoom():GetType() == RoomType.ROOM_BOSS then -- Full knife
                variant = 223
            end

            if not cachedFamiliars[player.InitSeed][28] 
            and stage == LevelStage.STAGE6 
            and level:GetStartingRoomIndex() == level:GetCurrentRoomIndex() then -- Full key
                variant = 28
            end

            local fam = CURCOL.SeedSpawn(EntityType.ENTITY_FAMILIAR, variant, 0, player.Position, Vector(0,0), player)
            if Sewn_API then fam:GetData().Sewn_noUpgrade = Sewn_API.Enums.NoUpgrade.MACHINE end
            fam:SetColor(item.COLOR, 0, 99, false, false)
            
            if variant ~= 224 then -- Don't insert baby plum since it's temporary
                insertFam(player.InitSeed, variant)
            end

            if variant == 235 then -- Twisted pair should grant two familiars
                local fam2 = CURCOL.SeedSpawn(EntityType.ENTITY_FAMILIAR, variant, 1, player.Position, Vector(0,0), player)
                if Sewn_API then fam2:GetData().Sewn_noUpgrade = Sewn_API.Enums.NoUpgrade.MACHINE end
                fam2:SetColor(item.COLOR, 0, 99, false, false)
                insertFam(player.InitSeed, variant)
            end

        end

        hasTriggered = true
    end
end

function item:OnRoom()
    if hasTriggered then
        hasTriggered = false
        cachedFamiliars = {}

        local numPlayers = CURCOL.GAME:GetNumPlayers()

        for i=1,numPlayers do
            local player = CURCOL.GAME:GetPlayer(tostring((i-1)))
            
            if player:HasCollectible(item.ID) then
                player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
                player:EvaluateItems()
                -- player:RespawnFamiliars()
            end
        end
    end
end

function item:OnCache(player)
    if cachedFamiliars[player.InitSeed] then
        local num = 0
        for key, v in pairs(cachedFamiliars[player.InitSeed]) do
            for i=1, v do
                local fam = CURCOL.SeedSpawn(EntityType.ENTITY_FAMILIAR, key, 0, player.Position, Vector(0,0), player)
                fam:SetColor(item.COLOR, 0, 99, false, false)
                if Sewn_API then fam:GetData().Sewn_noUpgrade = Sewn_API.Enums.NoUpgrade.MACHINE end
                num = num+1
                if num >= item.MAX_FAM then break end
            end
            if num >= item.MAX_FAM then break end
        end
    end
end

function item:OnUse(_, RNG, player, _, _, _)
    if cachedFamiliars[player.InitSeed] then
        for key, v in pairs(cachedFamiliars[player.InitSeed]) do
            insertFam(player.InitSeed, key)
        end
    end
end

function item:OnCollect(player, collectible, touched, isTrinket)
    if not touched then
        player:UseCard(Card.CARD_SOUL_LILITH, 259)
        CURCOL.SFX:Stop(SoundEffect.SOUND_SOUL_OF_LILITH)
    end
end


--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    CURCOL:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
    CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,   item.OnRoom)
    CURCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,  item.OnCache, CacheFlag.CACHE_FAMILIARS)
    CURCOL:AddCallback(ModCallbacks.MC_USE_ITEM,        item.OnUse,   CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)

    local hasTriggered = false
    local cachedFamiliars = {}
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,   item.OnRoom)
    CURCOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,  item.OnCache, CacheFlag.CACHE_FAMILIARS)
    CURCOL:RemoveCallback(ModCallbacks.MC_USE_ITEM,        item.OnUse,   CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)

    local hasTriggered = false
    local cachedFamiliars = {}
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect, item.ID)

return item