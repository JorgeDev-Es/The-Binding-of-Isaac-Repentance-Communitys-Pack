local mod = TaintedTreasure
local game = Game()

mod.RavenousBool = false

--Basically, apply a sort of scalar to all stats based on default Isaac stats (barring Luck because 0 works poorly)and see how they compare against it. 
--Scalars used for applying the multipliers
--I could re-implement Libra with this if I wanted lol

mod.RavenousStatScales = {
    ["Damage"] = {3.5, function(player) return player.Damage end, function(player,val) player.Damage = val end},
    ["Speed"] = {1, function(player) return player.MoveSpeed end, function(player,val) player.MoveSpeed = val end},
    ["ShotSpeed"] = {1, function(player) return player.ShotSpeed end, function(player,val) player.ShotSpeed = val end},
    ["Tears"] = {2.73, function(player) return 30 / (player.MaxFireDelay + 1) end, function(player,val) player.MaxFireDelay = math.max((30 / val) - 1, -0.99) end},
    ["Range"] = {260, function(player) return player.TearRange end, function(player,val) player.TearRange = val end},
    ["Luck"] = {1, function(player) return player.Luck end, function(player,val) player.Luck = val end},
}

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if mod and not mod.AddedExtraCallbacks then
		mod:AddPostCacheCallback()
		mod.AddedExtraCallbacks = true
	end

    local players = mod:GetAllPlayers()
    for _, player in pairs(players) do
        local savedata = mod.GetPersistentPlayerData(player)
        if savedata.RavenousEval then
            mod:RavenousStatEvaluation(player)
            savedata.RavenousEval = false
        end
    end
end)

mod:AddCustomCallback("GAIN_COLLECTIBLE", function(_, player, collectibleType)
    local coins = player:GetNumCoins()
    local bombs = player:GetNumBombs()
    local keys = player:GetNumKeys()
    local max = math.max(coins,bombs,keys)

    if max == coins then
        player:AddCoins(12)
        player:AddBombs(1)
        player:AddKeys(1)
    elseif max == bombs then
        player:AddCoins(1)
        player:AddBombs(12)
        player:AddKeys(1)
    elseif max == keys then
        player:AddCoins(1)
        player:AddBombs(1)
        player:AddKeys(12)
    end
end, TaintedCollectibles.RAVENOUS)

function mod:RavenousStatEvaluation(player)
    local bigstat = mod:CalculateHighestStat(player)
    if bigstat then 
        local buff = 1
        for statname, stats in pairs(mod.RavenousStatScales) do
            if statname ~= bigstat then
                local stat = stats[2](player)
                stat = stat / stats[1]
                local lilstat = stat * 0.9
                buff = buff + (stat - lilstat)
                lilstat = lilstat * stats[1]
                stats[3](player, lilstat)
            end
        end

        local stats = mod.RavenousStatScales[bigstat]
        local stat = stats[2](player)
        stat = stat / stats[1]
        stat = stat * buff
        stat = stat * stats[1]
        stats[3](player, stat)
    end
end

function mod:CalculateHighestStat(player)
    local record = -99999
    local tied = false
    local bigstat
    for statname, stats in pairs(mod.RavenousStatScales) do
        local stat = stats[2](player)
        stat = stat / stats[1]
        if stat > record then
            bigstat = statname
            record = stat
            tied = false
        elseif stat == record then
            tied = true
        end
    end

    if bigstat and not tied then --If two stats are tied, do nothing
        return bigstat
    end
end