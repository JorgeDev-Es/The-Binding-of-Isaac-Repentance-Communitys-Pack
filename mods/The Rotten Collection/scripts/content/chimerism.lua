--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local data = require("scripts.datamanager")

local item = {
    ID = Isaac.GetItemIdByName("Chimerism"),

    -- Max stats per room limiters
    BOSS_LIMIT = 4,
    MINI_LIMIT = 4,
    ENEMY_LIMIT = 15,

    -- Granted stats
    LUCK = 1,
    DAMAGE = 0.5,
    SPEED = 0.05,
    SHOTSPEED = 0.05,

    -- Do not run stat logic for enemies with armour (can't seem to find a way to find their "armour" value via the API so disabling is the only option)
    DEF_BLACKLIST = {
        [300] = true -- ENTITY_MUSHROOM
    },

    -- Enemies/Bosses that count as mini-bosses
    MINI_WHITELIST = {
        ['46.0'] = true,  -- Sloth
        ['46.1'] = true,  -- Super Sloth
        ['47.0'] = true,  -- Lust
        ['47.1'] = true,  -- Super Lust
        ['48.0'] = true,  -- Wrath
        ['48.1'] = true,  -- Super Wrath
        ['49.0'] = true,  -- Gluttony
        ['49.1'] = true,  -- Super Gluttony
        ['50.0'] = true,  -- Greed
        ['50.1'] = true,  -- Super Greed
        ['51.0'] = true,  -- Envy
        ['51.1'] = true,  -- Super Envy
        ['52.0'] = true,  -- Pride
        ['52.1'] = true,  -- Super Pride
        ['271.0'] = true, -- Uriel
        ['271.1'] = true, -- Fallen Uriel
        ['272.0'] = true,  -- Gabriel
        ['272.1'] = true,  -- Fallen Gabriel
    },

    KEY = "CH",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BOSS,
        ItemPoolType.POOL_ROTTEN_BEGGAR,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Chimerism", DESC = "{{ArrowUp}} Room stat up-when killing enemies#{{ArrowUp}} Floor stat-up when killing mini-bosses#{{ArrowUp}} Permanent stat-up when killing bosses" },
        { LANG = "ru",    NAME = "Химеризм",  DESC = "{{ArrowUp}} При убийстве обычного врага даёт удвоенный показатель до конца комнаты#{{ArrowUp}} При убийстве мини-боссов даёт показатель до конца этажа#{{ArrowUp}} При убийстве боссов даёт удвоенный показатель навсегда" },
        { LANG = "spa",   NAME = "Quimerismo",  DESC = "{{ArrowUp}} Aumento de estadísticas al matar enemigos durante la habitación#{{ArrowUp}} Aumento de estadísticas durante todo el piso al matar minijefes#{{ArrowUp}} Aumento de estadísticas permanente al matar jefes" },
        { LANG = "zh_cn", NAME = "奇美拉现象", DESC = "{{ArrowUp}} 每杀死一个怪物在当前房间内提升一次属性#{{ArrowUp}}  每杀死一个迷你首领在当前层中双倍提升一次属性#{{ArrowUp}} 每杀死一个首领永久双倍提升一次属性#每次提升的属性如下：#+1 运气#+0.5 攻击#+0.05 移速#+0.05 弹速" },
        { LANG = "ko_kr", NAME = "키메라즘", DESC = "{{ArrowUp}} 적 처치 시 그 방에서 랜덤 능력치 하나가 증가합니다.(최대 15회)#{{ArrowUp}} 각기 다른 미니 보스 처치 시 그 스테이지에서 랜덤 능력치 2개가 증가합니다.(최대 4회)#{{ArrowUp}} 각기 다른 보스 처치 시 영구적으로 랜덤 능력치 2개가 증가합니다.(최대 4회)#!!! 증가되는 능력치:#{{Blank}} ({{Damage}} +0.5, {{Luck}} +1, {{Speed}} +0.05, {{Shotspeed}} +0.05)" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When killing an enemy a random stat-up is granted for the current room. This stat-up dissapears when leaving the room"},
            {str = "When killing a mini-boss a random stat-up (x2) is granted for the current floor. This stat-up dissapears when going to a new floor"},
            {str = "When killing a boss a random stat up (x2) is granted permanently"},
            {str = "The amount of a stat granted is multiplied by the amount of the item held. I.E: Holding the item 3 times will grant +3 luck instead of +1"},
            {str = "The possible stats granted are the following: 1 luck, 0.5 damage, 0.05 speed, 0.05 shotspeed"},
            {str = "Killing the same mini-boss/boss or killing more than 3 mini-bosses/bosses while still in the same room does not grant another stat up"},
            {str = "Killing more than 15 enemies while still in the same room does not grant another stat up"}
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'A chimera in real life is an organism with more than one genotype'},
            {str = 'Chimerism was named after the greek mythological creature named the "Chimera". This creature was made up of multiple animals'},
        },
    }
}

-- CacheFlag and related stat keys table
local cacheFlags = {
    [CacheFlag.CACHE_LUCK] = 'Luck',
    [CacheFlag.CACHE_DAMAGE] = 'Damage',
    [CacheFlag.CACHE_SPEED] = 'MoveSpeed',
    [CacheFlag.CACHE_SHOTSPEED] = 'ShotSpeed'
}

-- I can't be arsed to save rewardList in the mod data so if people really wanted to they could circumvent this and get more stats
-- Disables the ability for the player to get more of same entity type (boss, miniboss, enemy) related statups from the same room.
local rewardList = {
    ['boss'] = {},
    ['mini'] = {},
    ['normal'] = 0
}

local enemyCache = {}

-- Local in-file state that tracks the currenly gained stats
local chiState = nil

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function getTableLength(table)
    local i = 1
    for _ in pairs(table) do i = i + 1 end
    return i
end

local function ApplyStat(type, multiplier, unt) -- Generate and apply a random stat based on params
    local currentStat = math.random(1, 4)
    local stat
    local value

    -- Select a random stat
    if currentStat == 1 then
        stat = 'Luck'
        value = item.LUCK * multiplier
    elseif currentStat == 2 then
        stat = 'Damage'
        value = item.DAMAGE * multiplier
    elseif currentStat == 3 then
        stat = 'MoveSpeed'
        value = item.SPEED * multiplier
    else
        stat = 'ShotSpeed'
        value = item.SHOTSPEED * multiplier
    end

    -- Apply stat to players
    local numPlayers = Game():GetNumPlayers()
    local hasRockBottom = false

    for i=1,numPlayers do
        local player = Game():GetPlayer((i-1))
        if TCC_API:Has(item.KEY, player) > 0 then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM) then
                hasRockBottom = true
            end
        end
    end

    -- Update or set stat in state
    if not chiState[type] then
        chiState[type] = {}
    end

    if chiState[type][stat] then
        chiState[type][stat] = chiState[type][stat] + value
    else
        chiState[type][stat] = value
    end

    if hasRockBottom then
        if not chiState.totalStats then
            chiState.totalStats = {}
        end

        if chiState.totalStats[stat] then
            chiState.totalStats[stat] = chiState.totalStats[stat] + value
        else
            chiState.totalStats[stat] = value
        end
    end

    SFXManager():Play(type == 'roomStats' and SoundEffect.SOUND_VAMP_GULP or SoundEffect.SOUND_VAMP_DOUBLE, type == 'roomStats' and 0.35 or 1, 0, false, type == 'roomStats' and 1.1 or 0.8)

    -- If not a room stat (floor or permanent) then save it in the mod data
    if type ~= 'roomStats' then data.SetData(item.KEY, chiState) end

    for i=1,numPlayers do
        local player = Game():GetPlayer((i-1))
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end
end

function item:CacheSource(entity, _, _, source)
    if not entity:IsVulnerableEnemy() or entity:GetData().ROTCOL_CHIMERA_MARKED then return end
    local wasPlayer

    if source.Entity then
        if source.Entity.Type == EntityType.ENTITY_PLAYER
        or (source.Entity.SpawnerType == EntityType.ENTITY_PLAYER and source.Entity.SpawnerEntity)
        or source.Entity.Player
        or (source.Entity.Parent and source.Entity.Parent.Type == EntityType.ENTITY_PLAYER) then -- Damage source parent was a player
            wasPlayer = true
        end
    end

    if wasPlayer then
        entity:GetData().ROTCOL_CHIMERA_MARKED = true
        enemyCache[#enemyCache+1] = entity
    end
end

function item:Consume() -- Grants stats when kills are made
    local newEnemyCache = {}
    for i=1, #enemyCache do
        local entity = enemyCache[i]
        local spr = entity:GetSprite()
        local anim = spr:GetAnimation()
        if entity:IsDead() or anim:find('Death') or anim:find('Die') or spr:IsEventTriggered('Death') then
            entity:GetData().ROTCOL_CHIMERA_MARKED = true
            if item.MINI_WHITELIST[entity.Type..'.'..entity.Variant] then -- If type is in table of mini-bosses then enemy was a mini-boss
                if not rewardList['mini'][entity.Type] ~= 2 and getTableLength(rewardList['mini']) < item.MINI_LIMIT then
                    ApplyStat("floorStats", (1+TCC_API:HasGlo(item.KEY)), entity)
                    rewardList['mini'][entity.Type] = 2
                end
            elseif entity:IsBoss() or entity:GetBossID() > 0 then  -- If boss id exists then enemy was a boss
                if not rewardList['boss'][entity.Type] ~= 2 and getTableLength(rewardList['boss']) < item.BOSS_LIMIT then
                    ApplyStat("permanentStats", (1+TCC_API:HasGlo(item.KEY)), entity)
                    rewardList['boss'][entity.Type] = 2
                end
            elseif not item.DEF_BLACKLIST[entity.Type] then -- Normal enemy
                if rewardList['normal'] < item.ENEMY_LIMIT then
                    ApplyStat("roomStats", TCC_API:HasGlo(item.KEY), entity)
                    rewardList['normal'] = (rewardList['normal']+1)
                end
            end
        else
            newEnemyCache[#newEnemyCache+1] = entity
        end
    end

    enemyCache = newEnemyCache
end

function item:OnNewRoom() -- Reset stats by room type upon entering a room
    enemyCache = {}
    if chiState ~= nil and Game():GetFrameCount() ~= 0 then
        rewardList = {
            ['boss'] = {},
            ['mini'] = {},
            ['normal'] = 0
        }

        chiState['roomStats'] = {}

        local numPlayers = Game():GetNumPlayers()

        for i=1,numPlayers do
            local player = Game():GetPlayer(tostring((i-1)))
            if TCC_API:Has(item.KEY, player) and chiState and chiState['roomStats'] then
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end
    end
end

function item:OnNewFloor() -- Remove floor stats from state and save when switching floors and re-apply permanent stats because they aren't cached and get cleared
    if chiState ~= nil and Game():GetFrameCount() ~= 0 then
        local numPlayers = Game():GetNumPlayers()
        chiState['floorStats'] = {}
        for i=1,numPlayers do
            local player = Game():GetPlayer(tostring((i-1)))
            if TCC_API:Has(item.KEY, player) then -- This presents the edgecase that if the item is removed the stats granted that floor will be semi-permanent but i can't be arsed to fix it
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end
    end
end

function item:OnCache(player, flag) -- Reload/Apply room and floor based stats
    if chiState ~= nil then
        local currentStat = cacheFlags[flag]

        if currentStat then
            if chiState then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM) then
                    if chiState.totalStats and chiState.totalStats[currentStat] then 
                        if currentStat == "MoveSpeed" and player[currentStat] + chiState.totalStats[currentStat] >= 2 then
                            player[currentStat] = 2
                        else
                            player[currentStat] = player[currentStat] + chiState.totalStats[currentStat] 
                        end
                    end
                else
                    for key, value in pairs(chiState) do
                        if value[currentStat] and key ~= "totalStats" then
                            if currentStat == "MoveSpeed" and player[currentStat] + value[currentStat] >= 2 then
                                player[currentStat] = 2
                            else
                                player[currentStat] = player[currentStat] + value[currentStat]
                            end
                        end
                    end
                end
            end
        end
    end
end

function item:OnLoad() -- Setup mod state and apply stats from save
    chiState = data.GetData(item.KEY)

    local numPlayers = Game():GetNumPlayers()

    for i=1,numPlayers do
        local playerIndex = tostring((i-1))
        local player = Game():GetPlayer(playerIndex)
        if TCC_API:Has(item.KEY, player) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
        end
    end
end

--##############################################################################--
--############################# MOD COMPATIBILITY ##############################--
--##############################################################################--
function item:PostLoad()
    if FiendFolio then
        item.MINI_WHITELIST[FiendFolio.FF.Hermit.ID..'.'..FiendFolio.FF.Hermit.Var] = true
        item.MINI_WHITELIST[FiendFolio.FF.Gravedigger.ID..'.'..FiendFolio.FF.Gravedigger.Var] = true
        item.MINI_WHITELIST[FiendFolio.FF.Psion.ID..'.'..FiendFolio.FF.Psion.Var] = true
    end

    if REVEL then
        item.MINI_WHITELIST[REVEL.ENT.DUNGO.id..'.'..REVEL.ENT.DUNGO.variant] = true
        item.MINI_WHITELIST[REVEL.ENT.RAGTIME.id..'.'..REVEL.ENT.RAGTIME.variant] = true
        item.MINI_WHITELIST[REVEL.ENT.CHUCK.id..'.'..REVEL.ENT.CHUCK.variant] = true
    end

    if CiiruleanItems then
        item.MINI_WHITELIST[CiiruleanItems.SAMAEL.ID..'.'..CiiruleanItems.SAMAEL.VARIANT] = true
    end

    ROTCG:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)
end

ROTCG:AddCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    ROTCG:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,    item.OnCache    )
    ROTCG:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,   item.CacheSource)
    ROTCG:AddCallback(ModCallbacks.MC_POST_UPDATE,       item.Consume    )
    ROTCG:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, item.OnLoad     )
    ROTCG:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,     item.OnNewRoom  )
    ROTCG:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,    item.OnNewFloor )

    chiState = data.GetData(item.KEY)

    ROTCG.checkFlags(item.KEY, CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
end

function item:Disable()
    ROTCG:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,    item.OnCache    )
    ROTCG:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,   item.CacheSource)
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_UPDATE,       item.Consume    )
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, item.OnLoad     )
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,     item.OnNewRoom  )
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL,    item.OnNewFloor )

    chiState = nil
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item