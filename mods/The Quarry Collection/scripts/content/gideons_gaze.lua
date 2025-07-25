--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Gideon's gaze"),
    EFFECT = Isaac.GetEntityVariantByName("Gideon's gaze effect"),

    DROP_CHANCE = 25,

    WHITELIST = {
        [203] = true, [42] = true, [202] = true, [235] = true, [236] = true, [804] = true, [201] = true, [302] = true,
        ["42.1"] = "radius",
        ["804.0"] = "dir",
        ["804.1"] = "dir",
        ["804.2"] = "dir",
        ["804.3"] = "dir",
    },

    QUAKE_DIRS = {
        [0] = { x = -40 },
        [1] = { y = -40 },
        [2] = { x = 40 },
        [3] = { y = 40 },
    },

    KEY="GIGA",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CURSE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Gideon's Gaze", DESC = "{{BlackHeart}} +1 black heart#Grimaces are broken when entering a room#Grimaces may drop {{BlackHeart}}" },
	    { LANG = "ru",    NAME = "Взгляд Гидеона", DESC = "{{BlackHeart}} +1 черное сердце#Гримасы ломаются при входе в комнату#С гримасы могут выпасть {{BlackHeart}}" },
        { LANG = "spa",   NAME = "La Mirada de Gideon", DESC = "{{BlackHeart}} +1 corazón negro#Los Lanzarrocas se destruyen al entrar a una habitación#Los Lanzarrocas pueden soltar {{BlackHeart}}" },
	    { LANG = "zh_cn", NAME = "基甸的凝视", DESC = "{{BlackHeart}} +1 黑心#摧毁房间内的石鬼面#摧毁石鬼面时有25%的概率掉落黑心" },
        { LANG = "ko_kr", NAME = "기드온의 감시", DESC = "{{BlackHeart}} 블랙하트 +1#Bomb/Quake를 제외한 모든 Grimace류 몬스터를 즉사시킵니다.#Grimace류 몬스터가 사망 시 25%의 확률로 {{BlackHeart}}블랙하트를 드랍합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When entering a room with grimaces in it a spirit of gideon will appear."},
            {str = "After a while this spirit will growl. This growl will break all grimaces in the room (bomb grimaces are excluded to prevent softlocks)."},
            {str = "Quake grimaces will destroy a path in front of them, And vomit grimaces will destroy all obstacles within a radius around them. This is also to prevent softlocks."},
            {str = "Broken grimaces have a 25% chance to drop black hearts."},
            {str = "The item also grants a black heart upon pickup."},
        }
    }
}

local function addModdedEnemy(enemy, group)
    local key = group and Isaac.GetEntityTypeByName(enemy)..'.'..Isaac.GetEntityVariantByName(enemy) or Isaac.GetEntityTypeByName(enemy)
    item.WHITELIST[key] = group or true
end

local isActive = false
local cachedEnemies = {}
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function processEntity(v, room)
    local group = item.WHITELIST[v.Type..'.'..v.Variant]
    if group == 'dir' then
        -- Quake
        local dir = item.QUAKE_DIRS[v.SubType] or {}
        local vel = Vector(dir.x or 0, dir.y or 0)
        local pos = v.Position
        local i=1
        local lastPos = {}

        while not (lastPos.X == pos.X and lastPos.Y == pos.Y) do
            room:DestroyGrid(room:GetGridIndex(pos), true)
            lastPos = pos
            i = i + 1
            pos = room:GetClampedPosition(v.Position+(vel*i), 10)
        end
    elseif group == 'radius' then
        -- Vomit
        for i = 1, room:GetGridSize() do
            local entity = room:GetGridEntity(i)
            
            if entity and entity:ToRock() and entity.Position:Distance(v.Position) <= 220 then
                entity:Destroy(true)
            end
        end
    elseif group == 'room' then
        -- other
        for i = 1, room:GetGridSize() do
            local entity = room:GetGridEntity(i)
            
            if entity and entity:ToRock() then
                entity:Destroy(true)
            end
        end
    elseif group == 'rem' then
        v:Remove()
    end
end

local function trySpawnGideon()
    cachedEnemies = {}
    local room = QUACOL.GAME:GetRoom()

    for k, entity in pairs(Isaac.GetRoomEntities()) do
        if item.WHITELIST[entity.Type] or item.WHITELIST[entity.Type..'.'..entity.Variant] then
            table.insert(cachedEnemies, entity)
        end
    end

    if #cachedEnemies > 0 then
        if room:IsFirstVisit() then
            local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, item.EFFECT, 0, QUACOL.GAME:GetRoom():GetCenterPos(), Vector(0,0), Isaac.GetPlayer(0)):ToEffect()
            eff:GetSprite().Scale = Vector(2, 2)
            eff.DepthOffset = 9999
            eff:Update()

            QUACOL.SFX:Play(SoundEffect.SOUND_MOTHERSHADOW_CHARGE_UP)

            Isaac.Spawn(EntityType.ENTITY_EFFECT, 151, 0, eff.Position, Vector(0,0), Isaac.GetPlayer(0)):ToEffect()
            Isaac.Spawn(EntityType.ENTITY_EFFECT, 16, 1, eff.Position, Vector(0,0), Isaac.GetPlayer(0)):SetColor(Color(0.1, 0.1, 0.1, 1, 0.2, 0, 0), 0, 99, false, false)
            isActive = true
        else
            for _, v in pairs(cachedEnemies) do
                processEntity(v, room)
                v:Remove()
            end
        end
    end
end

function item:OnUpdate()
    if QUACOL.GAME:GetFrameCount() % 120 == 0 and not isActive and TCC_API:HasGlo(item.KEY) then
        trySpawnGideon()
    end
end

function item:OnDeath()
    if TCC_API:HasGlo(item.KEY) and QUACOL.GAME:GetRoom():GetType() == RoomType.ROOM_BOSS then
        for k, v in pairs(Isaac.FindByType(EntityType.ENTITY_GIDEON)) do
            QUACOL.SeedSpawn(2, 9, 0, v.Position, Vector(0,0), Isaac.GetPlayer(0))

            local sprite = v:GetSprite()
            sprite:ReplaceSpritesheet(0, "gfx/bosses/alt_gideon.png")
            sprite:LoadGraphics()
            sprite:Update()
            sprite:Render(v.Position, Vector(0,0), Vector(0,0))
        end
    end
end

function item:OnEffectUpdate(effect)
    if effect:GetSprite():IsEventTriggered("IsFinished") then
        if #cachedEnemies <= 0 then
            for k, entity in pairs(Isaac.GetRoomEntities()) do
                if item.WHITELIST[entity.Type] or item.WHITELIST[entity.Type..'.'..entity.Variant] then
                    table.insert(cachedEnemies, entity)
                end
            end
        end

        local room = QUACOL.GAME:GetRoom()

        for _, v in pairs(cachedEnemies) do
            if v:GetDropRNG():RandomInt(100)+1 <= item.DROP_CHANCE and room:IsFirstVisit() then
                Isaac.Spawn(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, v.Position, Vector(0,0), v)
            end

            v:Die()

            processEntity(v, room)
        end

        cachedEnemies = {}
        effect:GetSprite():Play("Die")
        QUACOL.SFX:Play(SoundEffect.SOUND_GHOST_ROAR)
        QUACOL.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        QUACOL.GAME:ShakeScreen(12)
    elseif effect:GetSprite():IsEventTriggered("IsDead") then
        effect:Remove()
        isActive = false
    end
end

--##############################################################################--
--############################# MOD COMPATIBILITY ##############################--
--##############################################################################--
function item:PostLoad()
    if IpecacMod then
        addModdedEnemy("Dr. Grimace", "radius")
        addModdedEnemy("Epic Grimace", "room")
        addModdedEnemy("Lovely Grimace", true)
        -- addModdedEnemy("Planetary Grimace 1")
        -- addModdedEnemy("Planetary Grimace 2")
        -- addModdedEnemy("Gravity Grimace")
        -- addModdedEnemy("Super Gravity Grimace")
        -- addModdedEnemy("Crosseyed Stone Shooter")
    end

    if deliveranceContent then
        addModdedEnemy("Stonelet", true)
        addModdedEnemy("Triple Stonelet", true)
    end

    if FiendFolio then
        addModdedEnemy("Immural", true)
        addModdedEnemy("Stoney Slammer", true)
        addModdedEnemy("Crazy Stoney Slammer", true)
        addModdedEnemy("Tombit", true)
        addModdedEnemy("Tap", true)
        addModdedEnemy("Glass Eye", true)
        addModdedEnemy("Frowny", true)
        addModdedEnemy("Super Grimace", true)
        -- addModdedEnemy("Wetstone")
        -- addModdedEnemy("Furnace")
        -- addModdedEnemy("Cauldron")
        -- addModdedEnemy("Sensory Grimace")
    end

    if REVEL then
        addModdedEnemy("Brimstone Trap", "rem")
        addModdedEnemy("Stone Creep", true)
        -- addModdedEnemy("Big Blowy")
        -- addModdedEnemy("Frost Shooter")
        -- addModdedEnemy("Igloo")
    end

    -- CutMonsterPack: ID 302, therefore automatically whitelisted
    -- if CiiruleanItems then end

    QUACOL:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)
end

QUACOL:AddCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
QUACOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, item.OnEffectUpdate, item.EFFECT)

function item:Enable()
    QUACOL:AddCallback(ModCallbacks.MC_POST_UPDATE, item.OnUpdate)
    QUACOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, trySpawnGideon)
    QUACOL:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, item.OnDeath)
end

function item:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_UPDATE, item.OnUpdate)
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, trySpawnGideon)
    QUACOL:RemoveCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, item.OnDeath)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item