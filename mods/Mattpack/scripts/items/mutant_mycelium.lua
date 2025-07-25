local mod = MattPack

if EID then
    EID:addCollectible(MattPack.Items.MutantMycelium, "↑ {{Tears}} x1.25 Fire rate multiplier#↓ {{Damage}} x0.85 Damage multiplier# Every fourth shot fired will be a quad shot")
end

local dontSetSpread = {
    [6] = true,
    [7] = true,
    [8] = true,
    [13] = true,
}

function mod:mmSetParams(player)
    if player and player:HasCollectible(MattPack.Items.MutantMycelium) then
        local multiplier = player:GetCollectibleNum(MattPack.Items.MutantMycelium)
        local weapon = player:GetWeapon(1)
        local weaponType = weapon:GetWeaponType()
        local params = player:GetMultiShotParams(weaponType)
        if weapon:GetNumFired() % 4 == 0 then
            params:SetNumLanesPerEye(params:GetNumLanesPerEye() + (3 * multiplier))
            params:SetNumTears(params:GetNumTears() + (3 * multiplier))
            if not dontSetSpread[weaponType] then
                params:SetSpreadAngle(weaponType, (params:GetSpreadAngle(weaponType or 0)) + 15)
                return params
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, CallbackPriority.EARLY - 101, mod.mmSetParams)


function mod:mmEvalCache(player, flag)
    if player:HasCollectible(MattPack.Items.MutantMycelium) then
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * .85
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay / 1.25
        elseif flag == CacheFlag.CACHE_SIZE then
            player.SpriteScale = player.SpriteScale - (Vector.One * .1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.mmEvalCache, CacheFlag.CACHE_DAMAGE)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.mmEvalCache, CacheFlag.CACHE_FIREDELAY)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.mmEvalCache, CacheFlag.CACHE_SIZE)