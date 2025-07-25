--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local sfx = SFXManager()
local familiar = { 
    ID = Isaac.GetItemIdByName("Cube of rot"),
    VARIANT = Isaac.GetEntityVariantByName("Cube of rot"),

    REPLACE_CHANCE = 15,

    KEY = "CURO",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_ROTTEN_BEGGAR,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Cube of Rot", DESC = "Orbits around the player#Randomly teleports#Poisons on contact#Blocks projectiles" },
        { LANG = "ru",    NAME = "Кубик гнили", DESC = "Летает вокруг игрока#Случайно телепортируется#Отравляет врагов при контакте#Блокирует выстрелы" },
        { LANG = "spa",   NAME = "Cubo podrido",  DESC = "Familiar del tipo orbital#Se teletransporta de forma aleatoria a un rango cercano al jugador#Envenena a los enemigos#Bloquea proyectiles" },
        { LANG = "zh_cn", NAME = "腐烂肉块", DESC = "获得一个腐肉块环绕物#阻挡子弹，对怪物造成接触伤害并施加中毒#不时在自己的运动轨道上瞬移#20%的概率代替{{Collectible73}}肉块生成#持有该道具时会影响获得的{{Collectible73}}肉块" },
        { LANG = "ko_kr", NAME = "썩은 큐브", DESC = "캐릭터 주위를 돌며 적의 탄환을 막아줍니다.#주기적으로 캐릭터 주위의 랜덤 위치로 텔레포트합니다.#{{Poison}} 접촉 시 적을 중독시킵니다." },
    },
    SM_DESCRIPTION = {
        '{{Collectible712}} Grants 2 cube of meat wisps#{{ArrowUp}} Poison duration up#Blocked tears are friendly',
        '{{Collectible73}} Grants 1 cube of meat#{{ArrowUp}} Poison duration up#Blocked tears turn poisonous'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants a follower that orbits the player"},
            {str = "Occasionally teleports"},
            {str = "Orbit position, speed and distance will change when teleporting"},
            {str = "Poisons and damages enemies on contact"}
        },
        { -- Spawning
            {str = "Spawing", fsize = 2, clr = 3, halign = 0},
            {str = 'Even though this item is not within the boss pool. When "cube of meat" or "ball of bandages" spawn there is a 1/5 chance that it will be replaced by this item'}
        },
        { -- Synergies
            {str = "Synergies", fsize = 2, clr = 3, halign = 0},
            {str = 'Level 1 and Level 2 "Cube of meat" will occasionally teleport to a different orbit position'},
            {str = 'Level 2 "Cube of meat" will shoot poison shots'},
            {str = 'Level 3 and Level 4 "Cube of meat" will occasionally teleport towards a random enemy'},
            {str = 'All levels of "Cube of meat" will poison enemies on contact'},
            {str = 'All levels of "Cube of meat" will gain a different sprite'}
        },
        { -- Credits
            {str = "Credits", fsize = 2, clr = 3, halign = 0},
            {str = 'Credit to the "Custom Mr Dollies mod" which was used as an example for some of the code used for this item'},
            {str = 'Custom Mr Dollies mod: steamcommunity.com/sharedfiles/ filedetails/?id=2489635144'}
        }
    }
}

local currentCubeState = {
    OrbitSpeed = 0.02,
    OrbitDistance = Vector(70, 70),
    ProcessState = 0
}

local sewState = 0

--[[##########################################################################
############################# CUBE OF ROT LOGIC ##############################
##########################################################################]]--
function familiar:OnInit(cubeOfRot) -- Initialize familiar
    cubeOfRot:GetSprite():Play("Float")
    cubeOfRot:AddToOrbit(95)
	cubeOfRot.OrbitDistance = Vector(70, 70)
	cubeOfRot.OrbitSpeed = 0.02
end

function familiar:OnUpdate(cubeOfRot) -- Handle familiar animations, updating and teleportation
    local player = cubeOfRot.Player
    local sprite = cubeOfRot:GetSprite()
    local room = Game():GetRoom()

    if Game():GetFrameCount() % 120 == 0 and room:GetAliveEnemiesCount() ~= 0 then
        currentCubeState.ProcessState = 1
        sfx:Play(SoundEffect.SOUND_PLOP, 0.7, 10, false, 1)
        sprite:Play("Dissapear", false)
    end

    if sprite:IsEventTriggered("Appear") then
        sprite:Play("Float", false) 
    end

    if sprite:IsEventTriggered("Dissapear") then
        if currentCubeState.ProcessState == 1 then
            local randomDistance = math.random(40, 80)
            currentCubeState = {
                OrbitSpeed = math.random(1, 4)/100,
                OrbitDistance = Vector(randomDistance, randomDistance),
                -- OrbitAngleOffset = (math.random(-360, 360)/100),
                ProcessState = 2
            }
        end
        sprite:Play("Appear", false)
    end

    cubeOfRot.OrbitDistance = currentCubeState.OrbitDistance
    cubeOfRot.OrbitSpeed = currentCubeState.OrbitSpeed
    cubeOfRot.Velocity = cubeOfRot:GetOrbitPosition(player.Position + player.Velocity) - cubeOfRot.Position
end

function familiar:OnCollision(cubeOfRot, entity, _) -- Poison enemies on contact
    if entity.Type == EntityType.ENTITY_PROJECTILE then 
        if Sewn_API then
            local sewLevel = Sewn_API:GetLevel(cubeOfRot:GetData())    
            if sewLevel > 0 then
                entity = entity:ToProjectile()
                local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, entity.Position, entity.Velocity, cubeOfRot):ToTear()
                tear.Scale = entity.Scale or 1
                tear.Color = Color(0, 0.3, 0, 1, 0, 0.1, 0)
                tear.Height = entity.Height
                tear.CollisionDamage = cubeOfRot.Player.Damage or 5

                if sewLevel == 2 then
                    tear.TearFlags = TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP | 4
                else
                    tear.TearFlags = 0
                end

                tear:Update()
            end
        end

        entity:Remove()
    elseif entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
        local length = 20

        if Sewn_API then
            local sewLevel = Sewn_API:GetLevel(cubeOfRot:GetData())    
    
            if sewLevel == 2 then
                length = 40
            elseif sewLevel == 1 then
                length = 30
            end
        end

        entity:AddPoison(EntityRef(cubeOfRot), length, 1)
    end

end

function familiar:OnCacheUpdate(player, flag) -- Reset familiar(s) on change
    if flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(familiar.VARIANT, player:GetCollectibleNum(familiar.ID)+player:GetEffects():GetCollectibleEffectNum(familiar.ID), player:GetCollectibleRNG(familiar.ID))
    end
end

--[[##########################################################################
######################### COLLECTIBLE SPAWNING LOGIC #########################
##########################################################################]]--
function familiar:OnPickupSpawn(collectible) -- Potentially replace cube of meat/ball of bandages spawns with cube of rot
    if TCC_API:HasGlo(familiar.KEY) == 0 and (collectible.SubType == 73 or collectible.SubType == 207) and collectible:GetDropRNG():RandomInt(100)+1 <= familiar.REPLACE_CHANCE then
        local numPlayers = Game():GetNumPlayers()
        local isBlacklisted = false

        for i=1,numPlayers do
            local player = Game():GetPlayer(tostring((i-1)))

            if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) 
            or player:HasCollectible(CollectibleType.COLLECTIBLE_GLITCHED_CROWN) 
            or player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
                isBlacklisted = true
            end
        end

        if not isBlacklisted then
            collectible.SubType = familiar.ID
            local sprite = collectible:GetSprite()
            sprite:ReplaceSpritesheet ( 1, "gfx/items/collectibles/cube_of_rot.png")
            sprite:LoadGraphics()
            sprite:Update()
            sprite:Render(collectible.Position, Vector(0,0), Vector(0,0))
        end
    end
end

--[[##########################################################################
############################# MEATBOY SYNERGIES ##############################
##########################################################################]]--
local function HandleMeatboyReskin(meatboy, isReset) -- Apply or remove special synergy skin for meatboy follower
    local player = meatboy.Player
    local sprite = meatboy:GetSprite()

    if meatboy.Variant == 44 then
        if isReset then sprite:Reload() else sprite:ReplaceSpritesheet(0, "gfx/familiar/rotcol_familiar_other_01_cubeofmeatlevel1.png") end --Give special sprite
    elseif meatboy.Variant == 45 then
        sprite:Load("gfx/" .. (isReset and "003.045_cube of meat l2.anm2" or "animations/rotcol_cube_of_meat_l2.anm2"))
        sprite:Play("IdleDown", true) -- For some reason this form doesn't automatically play it's animations :P
    elseif meatboy.Variant == 46 then
        sprite:Load("gfx/" .. (isReset and "003.046_cube of meat l3.anm2" or "animations/rotcol_cube_of_meat_l3.anm2"))
    elseif meatboy.Variant == 47 then
        sprite:Load("gfx/" .. (isReset and "003.047_cube of meat l4.anm2" or "animations/rotcol_cube_of_meat_l4.anm2"))
    end

    sprite:LoadGraphics()   
end

local function ReskinAll(isReset)
    for key, value in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, 44)) do HandleMeatboyReskin(value, isReset) end
    for key, value in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, 45)) do HandleMeatboyReskin(value, isReset) end
    for key, value in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, 46)) do HandleMeatboyReskin(value, isReset) end
    for key, value in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, 47)) do HandleMeatboyReskin(value, isReset) end
end

function familiar:OnMeatCollision(meatboy, entity, _) -- Allow meatboy to apply poision to collided enemies
    if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then entity:AddPoison(EntityRef(meatboy), 30, 1) end
end

function familiar:OnMeatOrbitUpdate(meatboy) -- Allow meatboy orbital to teleport (every 120 frames) and handle adding/removing skins
    local room = Game():GetRoom()

    if room:GetAliveEnemiesCount() ~= 0 and Game():GetFrameCount() % 120 == 0 then
        meatboy:SetColor(Color(1, 1, 1, 1, 255, 255, 255), 5, 1, false, false)
        meatboy.OrbitAngleOffset = math.random(-360, 360)/100
    end

    if meatboy.Variant == 45 then
        local entities = Isaac.FindByType(EntityType.ENTITY_TEAR)
        for i = 1, #entities do
            if entities[i].Type == 2 and entities[i].SpawnerType == 3 and entities[i].SpawnerVariant == 45 then
                entities[i]:ToTear().TearFlags = entities[i]:ToTear().TearFlags | TearFlags.TEAR_POISON
            end
        end
    end
end

function familiar:OnMeatWalkUpdate(meatboy) -- Allow meatboy to teleport (every 120 frames) and handle adding/removing skins
    if Game():GetRoom():GetAliveEnemiesCount() ~= 0 and Game():GetFrameCount() % 120 == 0 then
        local enemies = Isaac.GetRoomEntities()

        for i = 1, #enemies do
            if enemies[i]:IsVulnerableEnemy() and enemies[i]:CanShutDoors() then 
                local enemy = enemies[i]

                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, meatboy.Position, Vector(0,0), nil)
                poof:SetColor(Color(0.91, 0.83, 0.74, 1, 0, 0, 0), 0, 1, false, false)
                meatboy:SetColor(Color(1, 1, 1, 1, 255, 255, 255), 5, 1, false, false)
                meatboy.Position = enemy.Position
                return nil
            end
        end
    end
end

function familiar:OnMeatInit(meatboy) HandleMeatboyReskin(meatboy) end -- Reskin meatboy on spawn

function familiar:OnSewUpgrade(cobeOfRot, isPerm)
    if Game():GetFrameCount()-sewState > 10 and isPerm then
        local sewLevel = Sewn_API:GetLevel(cobeOfRot:GetData())
        if sewLevel == 2 then
            cobeOfRot.Player:AddCollectible(73)
        elseif sewLevel == 1 then
            for i=1, 2 do
                Isaac.Spawn(3, 237, 73, cobeOfRot.Position, Vector(0,0), cobeOfRot.Player)
            end
        end
    end
end


function familiar:SetSewState() sewState = Game():GetFrameCount() end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnInit,       familiar.VARIANT)
ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnUpdate,     familiar.VARIANT)
ROTCG:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnCollision,  familiar.VARIANT)

function familiar:Enable()
    ROTCG:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnMeatCollision,    44) -- Level 1 poision contact synergy
    ROTCG:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnMeatCollision,    45) -- Level 2 poision contact synergy
    ROTCG:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnMeatCollision,    46) -- Level 3 poision contact synergy
    ROTCG:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnMeatCollision,    47) -- Level 4 poision contact synergy
    ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnMeatOrbitUpdate,  44) -- Level 1 orbit teleportation synergy 
    ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnMeatOrbitUpdate,  45) -- Level 1 orbit teleportation and poision shooting synergy 
    ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnMeatWalkUpdate,   46) -- Level 3 walking teleportation synergy
    ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnMeatWalkUpdate,   47) -- Level 4 walking teleportation synergy
    ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnMeatInit,         44) -- Replace level 1 textures
    ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnMeatInit,         45) -- Replace level 2 textures
    ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnMeatInit,         46) -- Replace level 3 textures
    ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnMeatInit,         47) -- Replace level 4 textures

    ROTCG:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,         familiar.OnCacheUpdate)

    ReskinAll()

    currentCubeState = {
        OrbitSpeed = 0.02,
        OrbitDistance = Vector(70, 70),
        ProcessState = 0
    }

    ROTCG.checkAllFam(familiar.VARIANT, familiar.ID)
end

function familiar:Disable()
    ROTCG:RemoveCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnMeatCollision,    44) -- Level 1 poision contact synergy
    ROTCG:RemoveCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnMeatCollision,    45) -- Level 2 poision contact synergy
    ROTCG:RemoveCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnMeatCollision,    46) -- Level 3 poision contact synergy
    ROTCG:RemoveCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnMeatCollision,    47) -- Level 4 poision contact synergy
    ROTCG:RemoveCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnMeatOrbitUpdate,  44) -- Level 1 orbit teleportation synergy 
    ROTCG:RemoveCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnMeatOrbitUpdate,  45) -- Level 1 orbit teleportation and poision shooting synergy 
    ROTCG:RemoveCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnMeatWalkUpdate,   46) -- Level 3 walking teleportation synergy
    ROTCG:RemoveCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnMeatWalkUpdate,   47) -- Level 4 walking teleportation synergy
    ROTCG:RemoveCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnMeatInit,         44) -- Replace level 1 textures
    ROTCG:RemoveCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnMeatInit,         45) -- Replace level 2 textures
    ROTCG:RemoveCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnMeatInit,         46) -- Replace level 3 textures
    ROTCG:RemoveCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnMeatInit,         47) -- Replace level 4 textures

    ROTCG:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,         familiar.OnCacheUpdate)

    ReskinAll(true)

    ROTCG.checkAllFam(familiar.VARIANT, familiar.ID)
end

if Sewn_API then
    ROTCG:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, familiar.SetSewState)

    Sewn_API:MakeFamiliarAvailable(familiar.VARIANT, familiar.ID)
    Sewn_API:AddFamiliarDescription(familiar.VARIANT, familiar.SM_DESCRIPTION[1], familiar.SM_DESCRIPTION[2], { 0, 0.5, 0 })

    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, familiar.OnSewUpgrade, familiar.VARIANT)
end

ROTCG:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, familiar.OnPickupSpawn, PickupVariant.PICKUP_COLLECTIBLE) -- Replace collectible spawns with cube of rot by chance
TCC_API:AddTCCInvManager(familiar.ID, familiar.TYPE, familiar.KEY, familiar.Enable, familiar.Disable)

return familiar