local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 999, function(_, player, flag)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.TOP_ROCK) then
        local data = player:GetData().ffsavedata
        data.topRockStats = data.topRockStats or {
            Damage = 9999999,
            FireDelay = -9999999,
            ShotSpeed = 9999999,
            Range = 9999999,
            Speed = 9999999,
            Luck = 9999999,
        }
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = math.min(data.topRockStats.Damage, player.Damage + 0.5)
            data.topRockStats.Damage = player.Damage
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = math.max(data.topRockStats.FireDelay, player.MaxFireDelay - 0.5)
            data.topRockStats.FireDelay = player.MaxFireDelay
        elseif flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = math.min(data.topRockStats.ShotSpeed, player.ShotSpeed + 0.5)
            data.topRockStats.ShotSpeed = player.ShotSpeed
        elseif flag == CacheFlag.CACHE_RANGE then
            player.TearRange = math.min(data.topRockStats.Range, player.TearRange + 50)
            data.topRockStats.Range = player.TearRange
        elseif flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = math.min(data.topRockStats.Speed, player.MoveSpeed + 0.2)
            data.topRockStats.Speed = player.MoveSpeed
        elseif flag == CacheFlag.CACHE_LUCK then
            player.Luck = math.min(data.topRockStats.Luck, player.Luck + 2)
            data.topRockStats.Luck = player.Luck
        end
	end
end)