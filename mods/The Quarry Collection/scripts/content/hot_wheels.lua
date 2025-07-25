--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local familiar = {
    ID = Isaac.GetItemIdByName("Hot wheels"),
    NPC = Isaac.GetEntityVariantByName("Hot wheels"),
    FLARE = Isaac.GetEntityVariantByName("QUACOL Fire jet"),

    ANIMATIONS = {
        [0] = 1,
        [22] = 8,
        [45] = 7,
        [68] = 6,
        [90] = 5,
        [112] = 4,
        [135] = 3,
        [157] = 2,
        [180] = 1,
        [202] = 8,
        [225] = 7,
        [247] = 6,
        [270] = 5,
        [292] = 4,
        [315] = 3,
        [337] = 2,
        [360] = 1,
    },
    GRID_WHITELIST = {
        [GridEntityType.GRID_ROCK] = true,
        -- [GridEntityType.GRID_ROCKB] = true,
        [GridEntityType.GRID_ROCKT] = true,
        [GridEntityType.GRID_ROCK_BOMB] = true,
        [GridEntityType.GRID_ROCK_ALT] = true,
        [GridEntityType.GRID_ROCK_SS] = true,
    },

    KEY="HOWH",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Hot Wheels", DESC = "Familiar that drives around when walked into#Lights enemies on fire#Breaks rocks" },
		{ LANG = "ru",    NAME = "Хот Вилс", DESC = "Спутник, который ездит, когда его толкают#Поджигает врагов огнём#Разбивает камни" },
        { LANG = "spa",   NAME = "Carrito en llamas", DESC = "Familiar que se desplaza al caminar junto a él#Puede prender a los enemigos en fuego#Puede romper rocas" },
	    { LANG = "zh_cn", NAME = "风火轮", DESC = "生成一辆能推动的矿车#可以点燃接触到的怪物、摧毁撞到的岩石#撞到怪物或墙时会喷射石头眼泪" },
        { LANG = "ko_kr", NAME = "불바퀴", DESC = "캐릭터가 접촉할 시 직선으로 미끄러지며 이동합니다.#{{Burning}} 적과 접촉 시 적에게 불을 붙이며 적의 탄환을 막습니다.#장애물을 파괴할 수 있습니다.#벽과 접촉 시 돌 눈물을 발사합니다." },
    },
    SM_DESCRIPTION = {
        '{{ArrowUp}} Push speed up#Spawns more tears#Some tears may split',
        '{{ArrowUp}} Creates damaging fires when colliding#All tears are on fire'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "A minecart familiar that can be pushed around."},
            {str = "Will light enemies on fire when colliding with them."},
            {str = "Will break rocks when colliding with them."},
            {str = "Will create a splash of rock tears when colliding with enemies or walls."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function InitTear(fam, sewLevel)
    local rotation = 180+(math.random(120)-60)
    local shot = QUACOL.SeedSpawn(EntityType.ENTITY_TEAR, TearVariant.ROCK, 0, fam.Position, fam.Velocity:Rotated(rotation)/2, fam):ToTear()
    shot.CollisionDamage = 2.8
    shot.FallingSpeed = -(math.random(15)+10)
    shot.FallingAcceleration = 1.2

    local flags = TearFlags.TEAR_ROCK
    if sewLevel > 0 and math.random() > 0.65 then flags = flags | TearFlags.TEAR_QUADSPLIT end
    if sewLevel == 2 then flags = flags | TearFlags.TEAR_BURN end

    shot:AddTearFlags(flags)
end

local function closestDegreeFinder(deg)  
    local index = 0
    local closestDistance = nil
    local cachedDistance = nil
  
    for key, value in pairs(familiar.ANIMATIONS) do
      local distance = math.abs(key - deg)
  
      if distance > 180 then
        distance = math.abs(distance - 360)
      end

      if not closestDistance or distance < closestDistance then
        closestDistance = distance
        index = key
      elseif distance > closestDistance then

      end
    end

    return familiar.ANIMATIONS[index]
end

local function collide(hotWheels, coolDown)
    if hotWheels.Velocity:Distance(Vector(0,0)) > 5 then
        QUACOL.GAME:SpawnParticles(hotWheels.Position, EffectVariant.ROCK_PARTICLE, 3, 2)
        QUACOL.GAME:ShakeScreen(4)
        QUACOL.SFX:Play(487)
        
        local sewLevel = Sewn_API and Sewn_API:GetLevel(hotWheels:GetData()) or 0
        
        local amount = sewLevel == 0 and 3 or 5

        if sewLevel == 2 then
            QUACOL.SeedSpawn(1000, familiar.FLARE, 0, hotWheels.Position, Vector(0,0), hotWheels.Player)
        end

        for i=1, math.random(2)+amount do
            InitTear(hotWheels, sewLevel)
        end
    end

    hotWheels.Velocity = hotWheels.Velocity:Rotated(170 + math.random(20))/((math.random(20) + 190)/100)
    hotWheels.Position = hotWheels.Position + (hotWheels.Velocity:Normalized()*2) -- move it away from the wall a little

    if coolDown then hotWheels:GetData().QUACOL_COOLDOWN = coolDown end
end

function familiar:OnUpdate(hotWheels)
    local data = hotWheels:GetData()

    if not data.QUACOL_COOLDOWN then
        local room = QUACOL.GAME:GetRoom()
        local col = room:GetGridCollisionAtPos(hotWheels.Position)
        if col == GridCollisionClass.COLLISION_SOLID then
            local grid = room:GetGridEntityFromPos(hotWheels.Position)
            if grid then
                if familiar.GRID_WHITELIST[grid:GetType()] then
                    grid:Destroy()
                else
                    collide(hotWheels, 15)
                end
            end
        elseif col == GridCollisionClass.COLLISION_OBJECT then
            room:DamageGrid(room:GetGridIndex(hotWheels.Position), 5)
        elseif col > 0 then
            collide(hotWheels, 15)
        end
    else
        if data.QUACOL_COOLDOWN == 1 then 
            data.QUACOL_COOLDOWN = nil
            local room = QUACOL.GAME:GetRoom()
            local col = room:GetGridCollisionAtPos(hotWheels.Position)

            if col == GridCollisionClass.COLLISION_PIT then
                hotWheels.Position = Isaac.GetFreeNearPosition(hotWheels.Position, 0)
            end
        else
            data.QUACOL_COOLDOWN = data.QUACOL_COOLDOWN - 1
        end
    end

    hotWheels.Position = QUACOL.GAME:GetRoom():GetClampedPosition(hotWheels.Position, 0)

    local sprite = hotWheels:GetSprite()
    sprite.PlaybackSpeed = hotWheels.Velocity:Clamped(-1,-1,1,1):Distance(Vector(0,0))/3
    if sprite.PlaybackSpeed > 0 then
        hotWheels:GetSprite():Play("Move"..closestDegreeFinder(hotWheels.Velocity:GetAngleDegrees()))
    end
    
    sprite:Update()
end

function familiar:OnCollision(hotWheels, entity, _)
    if not hotWheels:GetData().QUACOL_COOLDOWN then
        if entity:IsVulnerableEnemy() and entity:CanShutDoors() then
            if hotWheels.Velocity:Distance(Vector(0,0)) < 5 then
                local vel = (hotWheels.Position - entity.Position):Normalized()
                hotWheels.Velocity = vel*3
            else
                entity.Velocity = (entity.Velocity+(hotWheels.Velocity*1.5)):Clamped(-30,-30,30,30)
                collide(hotWheels)
            end

            if not entity:HasEntityFlags(EntityFlag.FLAG_BURN) then entity:AddBurn(EntityRef(hotWheels), 43, 1) end
        elseif entity.Type == EntityType.ENTITY_PLAYER then
            if hotWheels.Velocity:Distance(Vector(0,0)) <= 20 then
                if entity.Velocity:Distance(Vector(0,0)) > 3 then
                    local color = Color(1,1,1,1)
                    color:SetColorize(1, 1, 1, 1)
                    
                    QUACOL.GAME:SpawnParticles((hotWheels.Position+entity.Position)/2, EffectVariant.NAIL_PARTICLE, 1, 2, color)
                end
                
                local dirVel = entity.Velocity:Normalized()
                local direction = dirVel:GetAngleDegrees()

                if  Sewn_API and Sewn_API:GetLevel(hotWheels:GetData()) > 0 then 
                    hotWheels.Velocity = (hotWheels.Velocity+(dirVel*15)):Clamped(-30,-30,30,30)
                else
                    hotWheels.Velocity = (hotWheels.Velocity+(dirVel*11)):Clamped(-30,-30,30,30)
                end
            end
        -- elseif entity.Type == EntityType.ENTITY_FIREPLACE and QUACOL.GAME:GetFrameCount() % 16 == 0 then
        --     local type = entity.Variant > 1 and EffectVariant.BLUE_FLAME or EffectVariant.RED_CANDLE_FLAME
        --     local rotation = math.random(360)
        --     Isaac.Spawn(1000, type, 0, hotWheels.Position+Vector(20, 20):Rotated(rotation), Vector(7,7):Rotated(rotation), hotWheels)
        elseif entity.Type == EntityType.ENTITY_PROJECTILE then
            entity:Die()
        end
    end
end

function familiar:OnCacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(familiar.NPC, player:GetCollectibleNum(familiar.ID)+player:GetEffects():GetCollectibleEffectNum(familiar.ID), player:GetCollectibleRNG(familiar.ID))
    end
end

function familiar:OnEnter()
    local room = QUACOL.GAME:GetRoom()

    for key, fam in ipairs(Isaac.FindByType(3, familiar.NPC)) do
        fam.Position = room:FindFreePickupSpawnPosition(room:GetCenterPos()+(Vector(1,1):Rotated(math.random(360))*(math.random(60))), 0, true)
        fam.Velocity = Vector(0,0)
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
QUACOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnUpdate,    familiar.NPC)
QUACOL:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnCollision, familiar.NPC)

function familiar:Enable() 
    QUACOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    QUACOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, familiar.OnEnter)
    QUACOL.checkAllFam(familiar.NPC, familiar.ID)
end

function familiar:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, familiar.OnEnter)
    QUACOL.checkAllFam(familiar.NPC, familiar.ID)
end

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(familiar.NPC, familiar.ID)
    Sewn_API:AddFamiliarDescription(familiar.NPC, familiar.SM_DESCRIPTION[1], familiar.SM_DESCRIPTION[2], { 0.5, 0.2, 0 })
end

TCC_API:AddTCCInvManager(familiar.ID, familiar.TYPE, familiar.KEY, familiar.Enable, familiar.Disable)

return familiar
