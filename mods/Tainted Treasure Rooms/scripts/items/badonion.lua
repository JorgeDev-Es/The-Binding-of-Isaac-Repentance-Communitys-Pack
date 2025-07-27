local mod = TaintedTreasure
local game = Game()

function mod:BadOnionPlayerLogic(player, data)
    if data.BadOnionDamage and data.BadOnionDamage > 0 then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
        if not data.BadOnionPuffed then
            player:AddNullCostume(TaintedCostumes.BadOnionSteam)
            data.BadOnionPuffed = true
        end
    elseif data.BadOnionPuffed then
        player:TryRemoveNullCostume(TaintedCostumes.BadOnionSteam)
        data.BadOnionPuffed = false
    end
end

function mod:BadOnionOnKill(player, data)
    data.BadOnionDamageToAdd = player:GetCollectibleNum(TaintedCollectibles.BAD_ONION)
    data.BadOnionDamage = data.BadOnionDamage or 0
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
end

function mod:BadOnionDamageAdding(player, data)
    if data.BadOnionDamageToAdd and data.BadOnionDamageToAdd > 0 then
        data.BadOnionDamage = data.BadOnionDamage + data.BadOnionDamageToAdd
        data.BadOnionDamageToAdd = 0
    end
    if data.BadOnionDamage and data.BadOnionDamage > 0 and player.FrameCount % 3 == 0 then
        data.BadOnionDamage = data.BadOnionDamage - math.max(data.BadOnionDamage/120, 0.025)
		--print(data.BadOnionDamage/120)
        data.BadOnionDamage = math.max(data.BadOnionDamage, 0)
    end
    if data.BadOnionDamageToAdd and data.BadOnionDamage > 0 then
        player.Damage = player.Damage + data.BadOnionDamage
    end
end
