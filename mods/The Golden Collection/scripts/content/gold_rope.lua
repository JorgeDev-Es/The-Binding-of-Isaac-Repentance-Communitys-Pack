--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Gold rope"),

    LUCK = 2,

    EFFECT = Isaac.GetEntityVariantByName("Greed door effect"),
    DOORS = {
        [1] = { DoorSlot.LEFT0, DoorSlot.UP0, DoorSlot.RIGHT0, DoorSlot.DOWN0 }, -- Square
        [2] = { DoorSlot.LEFT0, DoorSlot.RIGHT0 }, -- Short horizontal
        [3] = { DoorSlot.UP0, DoorSlot.DOWN0 }, -- Short vertical
        [4] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.UP0, DoorSlot.DOWN0 }, -- Double vertical
        [5] = { DoorSlot.UP0, DoorSlot.DOWN0 }, -- Long vertical
        [6] = { DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- Double horizontal
        [7] = { DoorSlot.LEFT0, DoorSlot.RIGHT0 }, -- Long horizontal
        [8] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- Square large
        [9] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- LTL
        [10] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- LTR
        [11] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- LBL
        [12] = { DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1, DoorSlot.UP0, DoorSlot.UP1 }, -- LBR
        [13] = false -- Special
    },

    KEY="GORO",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_CRANE_GAME,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SECRET,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Gold Rope", DESC = "{{ArrowUp}} +2 Luck up#Spawn brimstone beams upon taking damage#Beams have your tear effects#Damage scales on held coins" },
        { LANG = "ru",    NAME = "Золотая веревка", DESC = "{{ArrowUp}} +2 удачи#Создает серные лучи при получении урона#Лучи имеют ваши эффекты слёз#Урон зависит от ваших монет" },
        { LANG = "spa",   NAME = "Cuerda dorada", DESC = "{{ArrowUp}} +2 de suerte#Generas rayos de Azufre al recibir daño#Los rayos poseen tus efectos de lágrima#El daño escala con tus monedas" },
        { LANG = "zh_cn", NAME = "大金链", DESC = "{{ArrowUp}} +2 运气#角色受伤时在房间内生成贪婪大门#贪婪大门会发射金硫磺火#金硫磺火拥有角色的眼泪效果#贪婪大门生成的数量及金硫磺火的伤害取决于角色的硬币数量" },
        { LANG = "ko_kr", NAME = "황금 동앗줄", DESC = "{{ArrowUp}} {{Luck}}운 +2#피격시 방 문에서 황금 혈사포가 나갑니다.#혈사포는 캐릭터의 눈물 효과의 영향을 받습니다.#혈사포의 갯수와 공격력은 캐릭터가 소지한 동전의 개수에 비례합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = 'When the player takes damage a "greed door" will spawn'},
            {str = "These doors will shoot a brimstone laser"},
            {str = "The lasers fired will have the same tear effects as the player"},
            {str = "If the player has over 40 coins then 2 beams will spawn. And if they have over 80 then 3 will spawn"},
            {str = "The damage these lasers do is the players damage times the amount of coins carried divided by three plus one. So damage x (1+(coins/50)). This means that the maximum damage a laser can do is 2.98x the players damage."},
        }
    }
}

local cachedDoors = {}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function summonDoor(slot, player, coins)
    if not coins then coins = player:GetNumCoins() end
    local doorPosition = GOLCG.GAME:GetRoom():GetDoorSlotPosition(slot)
    local rotation = 0

    if slot == DoorSlot.LEFT0 or slot == DoorSlot.LEFT1 then 
        rotation = 270
        doorPosition = doorPosition - Vector(-23, 0)
    elseif slot == DoorSlot.RIGHT0 or slot == DoorSlot.RIGHT1 then 
        rotation = 90
        doorPosition = doorPosition - Vector(23, 0)
    elseif slot == DoorSlot.DOWN0 or slot == DoorSlot.DOWN1 then 
        rotation = 180
        doorPosition = doorPosition - Vector(0, 23)
    else
        doorPosition = doorPosition - Vector(0, -23)
    end

    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, item.EFFECT, 0, doorPosition, Vector(0,0), player):ToEffect()

    local sprite = effect:GetSprite()

    sprite.Rotation = rotation
    sprite:Play("Open", true)
    effect:GetData().TGCPlayerDamage = player.Damage*(1+(coins/50))

    effect:Update()

    GOLCG.GAME:SpawnParticles(doorPosition, EffectVariant.GOLD_PARTICLE, 8, 6)
    GOLCG.GAME:SpawnParticles(doorPosition, EffectVariant.ROCK_PARTICLE, 5, 6)

    GOLCG.GAME:ShakeScreen(15)

    GOLCG.SFX:Play(SoundEffect.SOUND_EXPLOSION_DEBRIS, 2, 0)
    GOLCG.SFX:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 0, false, 0.75)

    cachedDoors[effect.InitSeed] = player
end

function item:OnDamage(player, _, flags, source)
    if TCC_API:Has(item.KEY, player:ToPlayer()) > 0 and source.Type ~= 6 and (flags & DamageFlag.DAMAGE_CURSED_DOOR) == 0 then
        local player = player:ToPlayer()
        local coins = player:GetNumCoins()
        local rng = player:GetCollectibleRNG(item.ID)
        local room = GOLCG.GAME:GetRoom()
        local availableDoors = {table.unpack(item.DOORS[room:GetRoomShape()])}

        for i=1, (coins > 80 and 3 or coins > 40 and 2 or 1) do
            if next(availableDoors) then
                player = player:ToPlayer()
                local selection = math.random(#availableDoors)
                local slot = availableDoors[selection]
                summonDoor(slot, player, coins)
                table.remove(availableDoors, selection)
                rng:Next()
            end
        end
    end
end

function item:OnUpdate(effect)
    local sprite = effect:GetSprite()

    if sprite:IsEventTriggered("IsOpen") then
        sprite:Play("Opened", true)
        local position = effect.Position
        local rotation = effect:GetSprite().Rotation

        if rotation == 90 then
            position = position + Vector(23, 0)
        elseif rotation == 180 then
            position = position + Vector(0, 23)
        elseif rotation == 270 then
            position = position + Vector(-23, 0)
        else
            position = position + Vector(0, -23)
        end
        
        local player = cachedDoors[effect.InitSeed]
        local laser = EntityLaser.ShootAngle(3, position, (rotation+90), 50, Vector(0,0), player or GOLCG.GAME:GetPlayer(1) --[[Game():GetPlayer(1)]]):ToLaser() -- Apparently effect.Parent isn't a player ఠ_ఠ
        if player then 
            laser:AddTearFlags(player.TearFlags)
            -- laser:SetColor(player.TearColor, 0, 100, false, true)
            -- Color(1, 1, 0, 0.3, 255, 230, 0)
        end
        laser:SetColor(Color(1, 0.85, 0.4, 1, 0, 0, 0), 0, 80, false, true)
        laser.DepthOffset = effect.Position.Y+1000
        laser.DisableFollowParent = true
        laser.CollisionDamage = (effect:GetData().TGCPlayerDamage or 10)
        laser:Update()

        GOLCG.GAME:SpawnParticles(position, EffectVariant.GOLD_PARTICLE, 4, 6)

        cachedDoors[effect.InitSeed] = nil
    end
    
    if sprite:IsEventTriggered("IsDone") then
        sprite:Play("Die", true)
        GOLCG.GAME:SpawnParticles(effect.Position, EffectVariant.ROCK_PARTICLE, 3, 6)
        GOLCG.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 2, 0)
        GOLCG.GAME:ShakeScreen(5)
    end

    if sprite:IsEventTriggered("IsDead") then
        effect:Remove()
    end
end

function item:OnCache(player)
    if TCC_API:Has(item.KEY, player) then
        player.Luck = player.Luck+(item.LUCK*TCC_API:Has(item.KEY, player))
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()  
    GOLCG:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,    item.OnDamage, EntityType.ENTITY_PLAYER)
    GOLCG:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,     item.OnCache,  CacheFlag.CACHE_LUCK)
    GOLCG.checkFlags(item.KEY, CacheFlag.CACHE_LUCK)
end

function item:Disable() 
    GOLCG:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
    GOLCG:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,  item.OnCache,  CacheFlag.CACHE_LUCK)
end

GOLCG:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, item.OnUpdate, item.EFFECT)

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)


return item