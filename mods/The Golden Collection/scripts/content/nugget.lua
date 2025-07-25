--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Nugget"),
    EFFECT = Isaac.GetEntityVariantByName("Big fools groundbreak"),
    
    DELAY_MULTIPLIER = 2.5,
    DAMAGE_MULTIPLIER = 1.5,
    FALL_SPEED_MULTIPLIER = 0.75,
    FALL_ACCELERATION = 1.2,

    KNIFE_THRESHOLD = 5,
    LUDO_RATE = 60,

    LASER_BLACKLIST = {
        [3] = true,
        [7] = true,
        [10] = true,
    },

    KEY="NU",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CRANE_GAME,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
        ItemPoolType.POOL_GREED_SECRET,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Nugget", DESC = "{{ArrowUp}} +50% damage#{{ArrowDown}} Tears down#Missing shots creates a shockwave" },
        { LANG = "ru",    NAME = "Самородок", DESC = "{{ArrowUp}} +50% урона#{{ArrowDown}} скорострельность понижена#Упавшие слёзы создают ударную волну" },
        { LANG = "spa",   NAME = "Pepita de oro", DESC = "{{ArrowUp}} +50% de daño#{{ArrowDown}} Baja en lágrimas#Los disparos que no acierten enemigos crearán una onda de choque" },
        { LANG = "zh_cn", NAME = "黄金鸡块", DESC = "{{ArrowUp}} ×1.5 攻击倍率#{{ArrowDown}} 射速下降#眼泪变成抛物线发射#没有命中怪物的眼泪落到地面将形成冲击波#冲击波会对怪物造成3倍角色伤害并摧毁障碍物" },
        { LANG = "ko_kr", NAME = "너겟", DESC = "{{ArrowUp}} {{Damage}}공격력 배율 x1.5#{{ArrowDown}} {{Tears}}눈물 딜레이 x2.5#눈물이 적을 맞추지 못했을 경우 착지한 자리에 캐릭터의 공격력 x3의 지진파가 생깁니다.#!!! 캐릭터는 이 지진파로 인한 피해를 받지 않으나 매우 강한 넉백을 받습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants +50% damage and a tears down."},
            {str = "When the player misses a shockwave simular to an explosion is created."},
            {str = "This explosion will do 3* the players damage and break obstacles."},
            {str = "This shockwave does not damage the player"}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function ExplosionEffect(player, tear, position, ignorePlayer)
    local pos = position or tear.Position
    local scale = math.min(math.max((tear.Scale or 1), 0.5), 1)
    local entities = Isaac.FindInRadius(pos, 100*scale)

    for i=1, #entities do
        local entity = entities[i]

        if entity:IsEnemy() then
            entity:TakeDamage(tear.CollisionDamage*3*scale, DamageFlag.DAMAGE_CRUSH, EntityRef(tear), 5)
        elseif entity.Type == EntityType.ENTITY_SLOT then
            entity:TakeDamage(50, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
        end

        if entity.Type ~= EntityType.ENTITY_EFFECT 
        and entity.Type ~= EntityType.ENTITY_TEAR
        and not (entity.Type == EntityType.ENTITY_PICKUP and entity:ToPickup():IsShopItem()) 
        and not (ignorePlayer == true and entity.Type == EntityType.ENTITY_PLAYER) then
            entity:AddVelocity((entity.Position - pos):Normalized()*((entity.Type == EntityType.ENTITY_PLAYER) and 4 or 8)*scale)
        end

        -- entity:AddVelocity()
    end

    local room = GOLCG.GAME:GetRoom()
    for i = 1, room:GetGridSize() do
        local entity = room:GetGridEntity(i)
        
        if entity then
            local gridDis = room:GetGridPosition(i):Distance(pos)

            if entity.Desc.Type == GridEntityType.GRID_PIT and gridDis < 50*scale then
                entity:ToPit():MakeBridge(nil)
            elseif gridDis < 100 then
                room:DestroyGrid(i, false)
            end
        end
    end
    
    if room:IsPositionInRoom(pos, 0) then
        local pos = room:FindFreeTilePosition(pos, 30)
        if pos then 
            local eff = Isaac.Spawn(1000, item.EFFECT, 0, pos, Vector(0,0), tear):ToEffect()
            eff.Scale = scale
            eff.SpriteScale = Vector(scale, scale)
        end
    end

    local poof = Isaac.Spawn(1000, EffectVariant.POOF02, 1, pos, Vector(0,0), tear):ToEffect()
    poof.Scale = scale
    poof.SpriteScale = Vector(scale, scale)

    GOLCG.SFX:Play(SoundEffect.SOUND_EXPLOSION_DEBRIS, 0.8, 0)
    GOLCG.SFX:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 0.15, 0, false, 0.75)

    GOLCG.GAME:SpawnParticles(pos, EffectVariant.GOLD_PARTICLE, math.random(2), 2)
    GOLCG.GAME:SpawnParticles(pos, EffectVariant.ROCK_PARTICLE, 1, 2)
end

function item:OnTearUpdate(tear)
    local player = GOLCG.GetShooter(tear)
    if player and TCC_API:Has(item.KEY, player) > 0 then
        if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
            if tear.FrameCount % item.LUDO_RATE == 0 and tear.FrameCount ~= 0 and GOLCG.GAME:GetRoom():GetAliveEnemiesCount() > 0 then
                ExplosionEffect(player, tear)   
            end
        else
            if ((tear:CollidesWithGrid() and tear.Height > -60) or tear.Height >= -5) 
            and (not tear:GetData() or not tear:GetData()['GOLCOL_NUGGET_EFFECT']) then
                tear:GetData()['GOLCOL_NUGGET_EFFECT'] = true
                ExplosionEffect(player, tear)
            elseif (not tear:GetData() or not tear:GetData()['GOLCOL_NUGGET_VELOCITY']) then
                tear:GetData()['GOLCOL_NUGGET_VELOCITY'] = true
                tear.FallingSpeed = -17.8125 --player.TearHeight*item.FALL_SPEED_MULTIPLIER
                tear.FallingAcceleration = item.FALL_ACCELERATION
            end
        end
    end
end

function item:OnLaserUpdate(laser)
    local player = GOLCG.GetShooter(laser)
    if player and TCC_API:Has(item.KEY, player) > 0 and not item.LASER_BLACKLIST[laser.Variant] and laser.Visible then
        local hasLudo = (laser:IsCircleLaser() and laser.SubType == 1)
        if ((hasLudo and laser.FrameCount % item.LUDO_RATE == 0) or (not hasLudo and laser.FrameCount == 1)) and GOLCG.GAME:GetRoom():GetAliveEnemiesCount() > 0 then
            ExplosionEffect(player, laser, laser.Position, not hasLudo)
        end
    end
end

function item:OnTearCollision(tear, collider, low)
    local player = GOLCG.GetShooter(tear)

    if player and TCC_API:Has(item.KEY, player) > 0
    and collider.Type == EntityType.ENTITY_FIREPLACE
    and (not tear:GetData() or not tear:GetData()['GOLCOL_NUGGET_EFFECT']) then
        tear:GetData()['GOLCOL_NUGGET_EFFECT'] = true
        ExplosionEffect(player, tear)
        tear:Die()
    end
end

function item:OnKnifeUpdate(knife)
	local player = GOLCG.GetShooter(knife)
	if not player or TCC_API:Has(item.KEY, player) == 0 then return end
    
    local distance = knife:GetKnifeDistance()
    if not knife:GetData()['GOLCOL_NUGGET_EFFECT'] and distance >= knife.MaxDistance then
        knife:GetData()['GOLCOL_NUGGET_EFFECT'] = true
        ExplosionEffect(knife.SpawnerEntity:ToPlayer(), knife)
    elseif distance == 0 then
        knife:GetData()['GOLCOL_NUGGET_EFFECT'] = nil
    end
end

function item:OnCache(player, cacheFlag)
    if TCC_API:Has(item.KEY, player) > 0 then
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            if player:HasWeaponType(WeaponType.WEAPON_TEARS) then
                player.MaxFireDelay = math.floor(player.MaxFireDelay*item.DELAY_MULTIPLIER)
            end
        elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = math.floor(player.Damage*item.DAMAGE_MULTIPLIER)
        end
    end
end

function item:OnEff(effect)
    if effect.FrameCount > 21 then
        effect:Remove()
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    GOLCG:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, item.OnTearCollision)
    GOLCG:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE,   item.OnTearUpdate   )
    GOLCG:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE,  item.OnLaserUpdate  )
    GOLCG:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE,  item.OnKnifeUpdate  )
    GOLCG:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,     item.OnCache        )
    GOLCG.checkFlags(item.KEY, CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE)
end

function item:Disable() 
    GOLCG:RemoveCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, item.OnTearCollision)
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_TEAR_UPDATE,   item.OnTearUpdate   )
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_LASER_UPDATE,  item.OnLaserUpdate  )
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_KNIFE_UPDATE,  item.OnKnifeUpdate  )
    GOLCG:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,     item.OnCache        )
end

GOLCG:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, item.OnEff, item.EFFECT)
TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item