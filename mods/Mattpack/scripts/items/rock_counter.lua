local mod = MattPack

if EID then
    EID:addCollectible(MattPack.Items.AltRock, "{{Warning}} Bonus item, may be buggy#All stat changes applied after picking up this item will be reversed")
    EID:addCollectible(MattPack.Items.RockCounter, "{{Warning}} Bonus item, may be buggy#All negative stat changes applied after picking up this item will be reversed#This effect is applied after damage calculations, meaning that the stats up will always be proportional to how far your stats would be below base")
end

mod.lastCache = {}
mod.lastCache2 = {}
function mod:evalCache(player, flag)
    if player:HasCollectible(MattPack.Items.RockCounter) then
        local lastCache = mod.lastCache[player.ControllerIndex]
        if not lastCache then
            mod.lastCache[player.ControllerIndex] = {
                [CacheFlag.CACHE_DAMAGE] = {player.Damage, "Damage"},
                [CacheFlag.CACHE_FIREDELAY] = {30 / (player.MaxFireDelay + 1), "MaxFireDelay"},
                [CacheFlag.CACHE_SHOTSPEED] = {player.ShotSpeed, "ShotSpeed"},
                [CacheFlag.CACHE_RANGE] = {player.TearRange, "TearRange"},
                [CacheFlag.CACHE_SPEED] = {player.MoveSpeed, "MoveSpeed"},
                [CacheFlag.CACHE_LUCK] = {player.Luck, "Luck"},
            }
        end
        local origInfo = mod.lastCache[player.ControllerIndex][flag]
        if origInfo then
            local origStat = origInfo[1]
            local curStat = player[origInfo[2]]
            if flag == CacheFlag.CACHE_FIREDELAY then
                curStat = 30 / (player[origInfo[2]] + 1)
            end
            local statDiff = (curStat - origStat)
            
            if statDiff < 0 or (flag == CacheFlag.CACHE_FIREDELAY) then
                local setStats = origStat - statDiff
                if flag == CacheFlag.CACHE_FIREDELAY then
                    player[origInfo[2]] = math.max(0, math.min(player[origInfo[2]], (30 / setStats - 1)))
                else
                    player[origInfo[2]] = math.max(player[origInfo[2]], setStats)
                end
                mod.lastCache[player.ControllerIndex][origInfo[2]] = player[origInfo[2]]
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, mod.evalCache)

function mod:clearLastCache()
    mod.lastCache = {}
    mod.lastCache2 = {}    
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.clearLastCache)

function mod:evalCache2(player, flag) -- Alt Rock
    if player:HasCollectible(MattPack.Items.AltRock) then
        local lastCache = mod.lastCache2[player.ControllerIndex]
        if not lastCache then
            mod.lastCache2[player.ControllerIndex] = {
                [CacheFlag.CACHE_DAMAGE] = {player.Damage, "Damage"},
                [CacheFlag.CACHE_FIREDELAY] = {player.MaxFireDelay, "MaxFireDelay"},
                [CacheFlag.CACHE_SHOTSPEED] = {player.ShotSpeed, "ShotSpeed"},
                [CacheFlag.CACHE_RANGE] = {player.TearRange, "TearRange"},
                [CacheFlag.CACHE_SPEED] = {player.MoveSpeed, "MoveSpeed"},
                [CacheFlag.CACHE_LUCK] = {player.Luck, "Luck"},
            }
        end
        local origInfo = mod.lastCache2[player.ControllerIndex][flag]
        if origInfo then
            local origStat = origInfo[1]
            local curStat = player[origInfo[2]]
            local statDiff = (curStat - origStat)
            local multi = 1
            -- if statDiff < 0 or (flag == CacheFlag.CACHE_FIREDELAY) then -- shit's wild
            --     multi = 1.5
            -- else
            --     multi = .5
            -- end
            
            local setStats = origStat - (statDiff * multi)
            if flag == CacheFlag.CACHE_FIREDELAY then
                player[origInfo[2]] = math.max(0, setStats)
            else
                player[origInfo[2]] = setStats
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, mod.evalCache2)