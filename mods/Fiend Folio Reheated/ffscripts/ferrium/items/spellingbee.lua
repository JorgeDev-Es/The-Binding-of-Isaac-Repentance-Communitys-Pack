local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local rewardStrings = {"SPEED", "TEARS", "DAMAGE", "RANGE", "SHOTSPEED", "LUCK", "COIN", "KEY", "BOMB"}

local statPos = {
    ["COIN"] = Vector(30, 33),
    ["BOMB"] = Vector(30, 45),
    ["KEY"] = Vector(30, 57),
    ["SPEED"] = Vector(33, 73),
    ["TEARS"] = Vector(33, 85),
    ["DAMAGE"] = Vector(33, 97),
    ["RANGE"] = Vector(33, 109),
    ["SHOTSPEED"] = Vector(33, 121),
    ["LUCK"] = Vector(33, 133),
    ["HARD"] = Vector(0,16)
}
local statPosJacobs = {
    ["COIN"] = Vector(30, 33),
    ["BOMB"] = Vector(30, 45),
    ["KEY"] = Vector(30, 57),
    ["SPEED"] = Vector(33, 88),
    ["TEARS"] = Vector(33, 101),
    ["DAMAGE"] = Vector(33, 115),
    ["RANGE"] = Vector(33, 128),
    ["SHOTSPEED"] = Vector(33, 143),
    ["LUCK"] = Vector(33, 156),
    ["HARD"] = Vector(0,16)
}

--and this is adapted from connor's render active thank you again

local function coopOrJacobStats()
	local count = 0
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player and player:Exists() and GetPtrHash(player:GetMainTwin()) == GetPtrHash(player)
				and (not player.Parent or player.Parent.Type ~= EntityType.ENTITY_PLAYER) then
			count = count+1
		end
	end
	return count > 1
end

local function analyzeSeedLetters(seed)
    local tab = {}
    for i=1,#seed do
        if i ~= 5 then
            local char = seed:sub(i, i)
            if i > 5 then
                i = i-1
            end
            if not tab[i] then
                tab[i] = {}
            end

            for num,string in ipairs(rewardStrings) do
                local _, count = rewardStrings[num]:gsub(char, "")
                tab[i][string] = count
                if count > 0 and not tab[i].stats then
                    tab[i].stats = true
                end
                if tonumber(char) then
                    tab[i].isNumber = true
                end
            end
            tab[i].char = char
            tab[i].Red = 1
            tab[i].Green = 1
            tab[i].Blue = 1
            tab[i].Alpha = 0
        end
    end

    return tab
end

local function jarvisAnalyze(tab, pos)
    local analyzedData = {}
    for _,string in ipairs(rewardStrings) do
        if tab[string] and tab[string] > 0 then
            local hard = (game.Difficulty > 0 and statPos["HARD"]) or Vector.Zero
            local topLeft = Vector(Options.HUDOffset * 20, Options.HUDOffset * 12)
            local targetDest = Vector.Zero
            if string == "COIN" or string == "KEY" or string == "BOMB" then
                hard = Vector.Zero
            end
            if coopOrJacobStats() then
                targetDest = topLeft+statPosJacobs[string]+hard
            else
                targetDest = topLeft+statPos[string]+hard
            end
            local vec = (targetDest-pos)
            table.insert(analyzedData, {string = string, pos = pos, dest = targetDest, dist = vec:Length(), speed = 0, dir = vec:Normalized()})
        end
    end
    return analyzedData
end

local function jarvisSortThisAllOutForMe(player, data, tab, mode) --oh ok, I could've done this cleaner but it's too late or rather I'm too lazy
    data.SpellingBeeStats = data.SpellingBeeStats or {}
    if mode == 0 then --buffs
        for _,string in ipairs(rewardStrings) do
            if tab[string] and tab[string] > 0 then
                if string == "SPEED" then
                    data.SpellingBeeStats.Speed = (data.SpellingBeeStats.Speed and data.SpellingBeeStats.Speed+1) or 1
                elseif string == "TEARS" then
                    data.SpellingBeeStats.Tears = (data.SpellingBeeStats.Tears and data.SpellingBeeStats.Tears+1) or 1
                elseif string == "DAMAGE" then
                    data.SpellingBeeStats.Damage = (data.SpellingBeeStats.Damage and data.SpellingBeeStats.Damage+1) or 1
                elseif string == "RANGE" then
                    data.SpellingBeeStats.Range = (data.SpellingBeeStats.Range and data.SpellingBeeStats.Range+1) or 1
                elseif string == "SHOTSPEED" then
                    data.SpellingBeeStats.Shotspeed = (data.SpellingBeeStats.Shotspeed and data.SpellingBeeStats.Shotspeed+1) or 1
                elseif string == "LUCK" then
                    data.SpellingBeeStats.Luck = (data.SpellingBeeStats.Luck and data.SpellingBeeStats.Luck+1) or 1
                elseif string == "COIN" then
                    player:AddCoins(1)
                elseif string == "KEY" then
                    player:AddKeys(1)
                elseif string == "BOMB" then
                    player:AddBombs(1)
                end
            end
        end
    elseif mode == 1 then --debuffs
        --Randomly chosen but more debilitating debuffs vs small, but widespread

        --[[for _,num in ipairs(tab) do
            local string = rewardStrings[num]
            if string == "SPEED" then
                data.SpellingBeeStats.Speed = (data.SpellingBeeStats.Speed and data.SpellingBeeStats.Speed-0.45) or -0.45
            elseif string == "TEARS" then
                data.SpellingBeeStats.Tears = (data.SpellingBeeStats.Tears and data.SpellingBeeStats.Tears+-0.5) or -0.5
            elseif string == "DAMAGE" then
                data.SpellingBeeStats.Damage = (data.SpellingBeeStats.Damage and data.SpellingBeeStats.Damage-0.35) or -0.35
            elseif string == "RANGE" then
                data.SpellingBeeStats.Range = (data.SpellingBeeStats.Range and data.SpellingBeeStats.Range-0.65) or -0.65
            elseif string == "SHOTSPEED" then
                data.SpellingBeeStats.Shotspeed = (data.SpellingBeeStats.Shotspeed and data.SpellingBeeStats.Shotspeed-0.65) or -0.65
            elseif string == "LUCK" then
                data.SpellingBeeStats.Luck = (data.SpellingBeeStats.Luck and data.SpellingBeeStats.Luck-0.66) or -0.66
            end
        end]]
        data.SpellingBeeStats.Speed = (data.SpellingBeeStats.Speed and data.SpellingBeeStats.Speed-0.25) or -0.25
        data.SpellingBeeStats.Tears = (data.SpellingBeeStats.Tears and data.SpellingBeeStats.Tears+-0.22) or -0.22
        data.SpellingBeeStats.Damage = math.max((data.SpellingBeeStats.Damage and data.SpellingBeeStats.Damage-0.22) or -0.22, -10)
        data.SpellingBeeStats.Range = (data.SpellingBeeStats.Range and data.SpellingBeeStats.Range-0.38) or -0.38
        data.SpellingBeeStats.Shotspeed = (data.SpellingBeeStats.Shotspeed and data.SpellingBeeStats.Shotspeed-0.32) or -0.32
        data.SpellingBeeStats.Luck = (data.SpellingBeeStats.Luck and data.SpellingBeeStats.Luck-0.7) or -0.7
    end
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end

mod.AddItemPickupCallback(function(player, added)
    local data = player:GetData()
    local savedata = data.ffsavedata.RunEffects
    local seeds = game:GetSeeds()
    if not savedata.SpellingBeeSeed then
        local seed = seeds:GetStartSeedString()
        savedata.SpellingBeeSeed = analyzeSeedLetters(seed)
    elseif player:GetCollectibleNum(mod.ITEM.COLLECTIBLE.SPELLING_BEE, false) > 1 and savedata.spellingBeeApplied then
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end, function(player)
    local data = player:GetData()
    local savedata = data.ffsavedata.RunEffects
    if player:GetCollectibleNum(mod.ITEM.COLLECTIBLE.SPELLING_BEE, false) == 0 then
        savedata.SpellingBeeApplied = false
        savedata.SpellingBeeSeed = nil
        savedata.SpellingBeeStats = nil
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end, mod.ITEM.COLLECTIBLE.SPELLING_BEE)

--uhhh just kinda taking this from the fairy names

local skippedRenderModes = {
	[RenderMode.RENDER_WATER_REFRACT] = true,
	[RenderMode.RENDER_WATER_REFLECT] = true,
}

local function renderSpellingBee(player, offset)
	if skippedRenderModes[game:GetRoom():GetRenderMode()] then return end

	local d = player:GetData()
    if d.ffsavedata then
        local savedata = d.ffsavedata.RunEffects

        if savedata.SpellingBeeSeed and not savedata.SpellingBeeApplied then
            local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.SPELLING_BEE)
            if not d.SpellingBeeData2 then
                d.SpellingBeeData2 = {Frame = 0, State = "Init", CorrectPitch = 1, goodOnes = {}}
            elseif not game:IsPaused() then
                d.SpellingBeeData2.Frame = d.SpellingBeeData2.Frame+1
            end
            local d2 = d.SpellingBeeData2
            if d2.State == "Sorting" then
                local reallyFinished = true
                for num, entry in ipairs(savedata.SpellingBeeSeed) do
                    if not entry.numFinished then
                        reallyFinished = false
                    end
                    local allDone = true
                    if d2.Frame < 20 and not entry.stats then
                        local ShakeVec = Vector.Zero
                        if not entry.stats then
                            entry.Alpha = mod:Lerp(entry.Alpha, 0, 0.12)
                            entry.Green = mod:Lerp(entry.Green, 0, 0.15)
                            entry.Blue = mod:Lerp(entry.Green, 0, 0.15)
                            ShakeVec = mod:shuntedPosition(4, rng)
                            if entry.isNumber then
                                entry.Red = mod:Lerp(entry.Red, 3, 0.15)
                                if not d2.horrible then
                                    player:AnimateSad()
                                    d2.horrible = true
                                end
                                if not entry.numFinished then
                                    jarvisSortThisAllOutForMe(player, savedata, nil, 1)
                                    entry.numFinished = true
                                end
                            else
                                entry.numFinished = true
                                entry.Red = mod:Lerp(entry.Red, 0, 0.15)
                            end
                        end

                        if num < 5 then
                            local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + num*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y - 15) + ShakeVec
                            mod.TempestFont:DrawString(entry.char, pos.X, pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                        else
                            local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + (num-4)*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y) + ShakeVec
                            mod.TempestFont:DrawString(entry.char, pos.X, pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                        end
                    else
                        local adjustedTime = num
                        for order,goodNum in ipairs(d2.goodOnes) do
                            if goodNum == num then
                                adjustedTime = order
                            end
                        end
                        if d2.Frame > 20 + adjustedTime*14 and not entry.finished then
                            if not entry.flying then
                                entry.flying = true
                                local pos
                                if num < 5 then
                                    pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + num*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y - 15)
                                else
                                    pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + (num-4)*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y)
                                end
                                entry.targetData = jarvisAnalyze(entry, pos)
                            end

                            if entry.targetData then
                                for _,td in ipairs(entry.targetData) do
                                    if td.speed < 10 then
                                        td.speed = math.min(10, td.speed+0.005)
                                    end
                                    td.pos = td.pos+td.dir*td.speed*td.dist*0.1

                                    --[[if entry.Red < 10 then
                                        entry.Red = entry.Red+td.speed
                                        entry.Green = entry.Green+td.speed
                                        entry.Blue = entry.Blue+td.speed
                                    end]]

                                    if td.pos:Distance(td.dest) < 2 or td.pos.X < td.dest.X then
                                        entry.finished = true
                                    else
                                        allDone = false
                                    end

                                    mod.TempestFont:DrawString(entry.char, td.pos.X, td.pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                                end
                            end
                        elseif not entry.finished then
                            allDone = false
                            if entry.stats then
                                if num < 5 then
                                    local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + num*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y - 15)
                                    mod.TempestFont:DrawString(entry.char, pos.X, pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                                else
                                    local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + (num-4)*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y)
                                    mod.TempestFont:DrawString(entry.char, pos.X, pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                                end
                            end
                        end

                        if allDone and not entry.numFinished then
                            sfx:Play(SoundEffect.SOUND_THUMBSUP, 0.6, 0, false, d2.CorrectPitch)
                            d2.CorrectPitch = d2.CorrectPitch+0.15
                            jarvisSortThisAllOutForMe(player, savedata, entry, 0)
                            entry.numFinished = true
                        end
                    end
                end
                if reallyFinished then
                    d.SpellingBeeData2 = nil
                    savedata.SpellingBeeApplied = true
                end
            elseif d2.State == "Init" then
                for num, entry in ipairs(savedata.SpellingBeeSeed) do
                    if d2.Frame < 40 then
                        entry.Alpha = mod:Lerp(entry.Alpha, 1, 0.12)
                    else
                        entry.Alpha = 1
                    end

                    if d2.Frame > 40 + num*8 then
                        if entry.stats then
                            entry.Red = mod:Lerp(entry.Red, 0.5, 0.15)
                            entry.Green = mod:Lerp(entry.Green, 2, 0.15)
                        else
                            if entry.isNumber then
                                entry.Red = mod:Lerp(entry.Red, 2, 0.15)
                            else
                                entry.Red = mod:Lerp(entry.Red, 0.5, 0.15)
                            end
                            entry.Green = mod:Lerp(entry.Green, 0.5, 0.15)
                        end
                        entry.Blue = mod:Lerp(entry.Blue, 0.5, 0.15)
                        if not entry.activated then
                            entry.activated = true
                            if entry.stats then
                                sfx:Play(SoundEffect.SOUND_PENNYPICKUP, 0.8, 0, false, d2.CorrectPitch)
                                d2.CorrectPitch = d2.CorrectPitch+0.15
                                if not Options.FoundHUD then
                                    jarvisSortThisAllOutForMe(player, savedata, entry, 0)
                                end
                                table.insert(d2.goodOnes, num)
                            else
                                if entry.isNumber then
                                    sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 0.4, 0, false, mod:getRoll(110,160,rng)/100)
                                    if not Options.FoundHUD then
                                        --local debuff = mod:getSeveralDifferentNumbers(3, 6, rng)
                                        jarvisSortThisAllOutForMe(player, savedata, nil, 1)
                                    end
                                else
                                    sfx:Play(SoundEffect.SOUND_FETUS_LAND, 0.4, 0, false, mod:getRoll(110,160,rng)/100)
                                end
                            end
                            entry.Shake = 7
                        end
                    end
                    local ShakeVec = Vector.Zero
                    if entry.Shake and entry.Shake > 0 then
                        entry.Shake = entry.Shake-1
                        ShakeVec = mod:shuntedPosition(4, rng)
                    end

                    if num < 5 then
                        local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + num*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y - 15) + ShakeVec
                        mod.TempestFont:DrawString(entry.char, pos.X, pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                    else
                        local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + (num-4)*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y) + ShakeVec
                        mod.TempestFont:DrawString(entry.char, pos.X, pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                    end

                    if d2.Frame > 125 then
                        if Options.FoundHUD then
                            d2.State = "Sorting"
                            d2.Frame = 0
                            d2.CorrectPitch = 1
                        else
                            d2.State = "FadeNoHUD"
                            d2.Frame = 0
                        end
                    end
                end
            elseif d2.State == "FadeNoHUD" then
                for num, entry in ipairs(savedata.SpellingBeeSeed) do
                    if num < 5 then
                        local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + num*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y - 15)
                        mod.TempestFont:DrawString(entry.char, pos.X, pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                    else
                        local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(-25 + (num-4)*10 - mod.TempestFont:GetStringWidth(entry.char)*0.5, offset + player.SpriteOffset.Y)
                        mod.TempestFont:DrawString(entry.char, pos.X, pos.Y, KColor(entry.Red, entry.Green, entry.Blue, entry.Alpha), 0, false)
                    end

                    if d2.Frame < 40 then
                        entry.Alpha = mod:Lerp(entry.Alpha, 0, 0.12)
                    else
                        entry.Alpha = 0
                        d2.State = "Finished!"
                        savedata.SpellingBeeApplied = true
                        d.SpellingBeeData2 = nil
                    end
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
	renderSpellingBee(player, -45)
end)