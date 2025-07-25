local mod = RegisterMod("Jacob's Ladder Fix", 1)

local zeroVector = Vector(0, 0)

local baseLaserColor = Color(0, 0, 0, 1, 167, 223, 251)
local laserColor = Color(0, 0, 0, 1, 146, 140, 162)

local function fireJacobLadderLaser(pos, player)
    local laser = EntityLaser.ShootAngle(2, pos, math.random(1, 360), 4, zeroVector, player)
    laser:SetHomingType(1)
    laser.TearFlags = laser.TearFlags | TearFlags.TEAR_HOMING
    laser:GetData().IsJacobsLadder = true
    laser.DisableFollowParent = true
    laser.Color = laserColor
    laser.OneHit = true
    laser.CollisionDamage = player.Damage / 2
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
    if flag == CacheFlag.CACHE_TEARCOLOR and player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
        player.LaserColor = baseLaserColor
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
    if not laser:GetData().IsJacobsLadder and (laser.Parent and laser.Parent:ToPlayer()) then
        local player = laser.Parent:ToPlayer()
        player:AddCacheFlags(CacheFlag.CACHE_TEARCOLOR)
        player:EvaluateItems()
        if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_JACOBS_LADDER) or player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
            if math.random(1, 4) == 1 then
                local endPoint = laser:GetEndPoint()
                fireJacobLadderLaser(endPoint, player)
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
    if bomb.IsFetus then
        local player
        if bomb.Parent and bomb.Parent:ToPlayer() then
            player = bomb.Parent:ToPlayer()
        elseif bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() then
            player = bomb.SpawnerEntity:ToPlayer()
        end

        if player and (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_JACOBS_LADDER) or player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER)) then
            if math.random(1, 8) == 1 then
                fireJacobLadderLaser(bomb.Position, player)
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    local weap = player:GetActiveWeaponEntity()
    if weap and weap:Exists() and weap.Type == EntityType.ENTITY_EFFECT and weap.Variant == EffectVariant.TARGET and player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) and (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_JACOBS_LADDER) or player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER)) then
        if math.random(1, 8) == 1 then
            fireJacobLadderLaser(weap.Position, player)
        end
    end
end)
