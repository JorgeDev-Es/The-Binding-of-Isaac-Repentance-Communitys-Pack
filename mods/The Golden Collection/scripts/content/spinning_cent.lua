--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Spinning cent"),
    NPC = Isaac.GetEntityVariantByName("Spinning cent"),

    CHANCE=16,
    STATES = {
        [1] = "Heart",
        [2] = "Bomb",
        [3] = "Key",
        [4] = "Coin"
    },

    KEY="SPCE",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Spinning Cent", DESC = "Follows and damages enemies#May spawn pickups in combat" },
        { LANG = "ru",    NAME = "Вращающийся цент", DESC = "Следует и наносит урон врагам#Может создавать подбираемые предметы в бою" },
        { LANG = "spa",   NAME = "Centavo giratorio", DESC = "Familiar que persigue y daña a los enemigos#Puede generar recolectables en batalla" },
        { LANG = "zh_cn", NAME = "旋转硬币", DESC = "获得一个旋转硬币跟班#在战斗中出现，追逐怪物造成接触伤害#攻击怪物时概率生成当前图标显示的基础掉落#生成的基础掉落会在一段时间后消失" },
        { LANG = "ko_kr", NAME = "팽이 동전", DESC = "적을 따라다니며 접촉 시 피해를 줍니다.#적에게 접촉 시 16%의 확률로 동전에 그려진 픽업을 드랍합니다.#드랍한 픽업은 1.5초 이후 사라집니다." },
    },
    SM_DESCRIPTION = {
        '{{ArrowUp}} Pickup spawn chance up#{{ArrowUp}} Damage up',
        '{{ArrowDown}} Pickup timeout down#{{ArrowUp}} Damage up'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Follows and damages enemies. Does not change target until the enemy is dead."},
            {str = "While in contact with an enemy it may spawn a pickup based on the icon (heart, bomb, key or coin) it is currently displaying."},
            {str = "Pickups spawned will have a timeout."},
            {str = "It may switch icons periodically."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function getDetail(familiar)
    local animName = familiar:GetSprite():GetAnimation()

    if string.find(animName, "Heart") then
        return { ["anim"] = "Heart", ["pickup"] = PickupVariant.PICKUP_HEART }
    elseif string.find(animName, "Bomb") then
        return { ["anim"] = "Bomb", ["pickup"] = PickupVariant.PICKUP_BOMB }
    elseif string.find(animName, "Key") then
        return { ["anim"] = "Key", ["pickup"] = PickupVariant.PICKUP_KEY }
    else -- Coin
        return { ["anim"] = "Heart", ["pickup"] = PickupVariant.PICKUP_COIN }
    end
end

function item:OnInit(familiar)
    local sprite = familiar:GetSprite()
    sprite:Play("Idle")
    if Sewn_API then 
        Sewn_API:HideCrown(familiar, true)
        familiar.CollisionDamage = 1+Sewn_API:GetLevel(familiar:GetData())
    end
end

function item:OnUpdate(spinningCent)
    local sprite = spinningCent:GetSprite()
    local room = GOLCG.GAME:GetRoom()

    if room:GetAliveEnemiesCount() == 0 then
        if not sprite:IsPlaying('Crumble') and not sprite:IsFinished('Crumble') 
        and not sprite:IsPlaying('Idle') and not sprite:IsFinished('Idle') then
            sprite:Play('Crumble', false)
            spinningCent.Velocity = Vector(0,0)
            spinningCent:FollowPosition(spinningCent.Position)
            if Sewn_API then Sewn_API:HideCrown(spinningCent, true) end
        end
    else
        if sprite:IsPlaying('Crumble') or sprite:IsFinished('Crumble') or sprite:IsPlaying('Idle') or sprite:IsFinished('Idle') then
            spinningCent.Position = room:FindFreePickupSpawnPosition(room:GetRandomPosition(0))
            sprite:Play("Appear" .. item.STATES[math.random(4)], false)
            if Sewn_API then Sewn_API:HideCrown(spinningCent, false) end
        end

        if sprite:IsEventTriggered("Appear") then
            sprite:Play("Spinning" .. getDetail(spinningCent).anim, false)
        end

        if GOLCG.GAME:GetFrameCount() % 100 == 0 then
            sprite:Play("Spinning" .. item.STATES[math.random(4)], false)
        end

        spinningCent:PickEnemyTarget(800, 13, (1 | 2 | 8))

        if spinningCent.Target then
            spinningCent:FollowPosition(spinningCent.Target.Position)
        end

        spinningCent.Velocity = spinningCent.Velocity:Clamped(-3,-3,3,3)
        spinningCent.Position = room:GetClampedPosition(spinningCent.Position, 0)
    end
end

function item:OnCollision(familiar, entity, _)
    if entity:IsVulnerableEnemy()
    and entity:CanShutDoors()
    and GOLCG.GAME:GetFrameCount() % ((Sewn_API and Sewn_API:GetLevel(familiar:GetData()) > 0) and 15 or 25) == 0 and math.random(100) <= item.CHANCE then
        local pickup = GOLCG.SeedSpawn(
            EntityType.ENTITY_PICKUP,
            getDetail(familiar).pickup,
            0,
            entity.Position, 
            RandomVector() * ((math.random() * 2) + 1),
            nil
        ):ToPickup()
        pickup.Timeout = (Sewn_API and Sewn_API:IsUltra(familiar:GetData())) and 55 or 45
        pickup:Update()
    end
end

function item:OnCacheUpdate(player, flag)
    player:CheckFamiliar(item.NPC, player:GetCollectibleNum(item.ID)+player:GetEffects():GetCollectibleEffectNum(item.ID), player:GetCollectibleRNG(item.ID))
end

function item:OnSMChange(familiar)
    familiar.CollisionDamage = 1+Sewn_API:GetLevel(familiar:GetData())
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
GOLCG:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          item.OnInit,      item.NPC)
GOLCG:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        item.OnUpdate,    item.NPC)
GOLCG:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, item.OnCollision, item.NPC)

function item:Enable() 
    GOLCG:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCacheUpdate, CacheFlag.CACHE_FAMILIARS)
    GOLCG.checkAllFam(item.NPC, item.ID)
end

function item:Disable()
    GOLCG:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCacheUpdate, CacheFlag.CACHE_FAMILIARS)
    GOLCG.checkAllFam(item.NPC, item.ID)
end

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(item.NPC, item.ID)
    Sewn_API:AddFamiliarDescription(item.NPC, item.SM_DESCRIPTION[1], item.SM_DESCRIPTION[2], { 0.5, 0.2, 0 })
    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, item.OnSMChange, item.NPC)
    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_LOSE_UPGRADE, item.OnSMChange, item.NPC)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item
