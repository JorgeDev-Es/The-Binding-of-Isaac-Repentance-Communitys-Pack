local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local direChestFortunes = include("ffscripts.erfly.misc.fortunes_direchest")
local direChestFortuneRNG = RNG()
direChestFortuneRNG:SetSeed(Isaac.GetTime(), 35)

local function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
end

local function fortuneArray(array)
    game:GetHUD():ShowFortuneText(
        array[1],
        array[2] or nil,
        array[3] or nil,
        array[4] or nil,
        array[5] or nil,
        array[6] or nil,
        array[7] or nil,
        array[8] or nil,
        array[9] or nil,
        array[10] or nil
    )
end

function mod:BuildFortuneTable(rebuildTable, showcount)
    mod.FortuneTable = mod.FortuneTable or {}
    if rebuildTable then
        mod.FortuneTable = {}
    end
    if #mod.FortuneTable <= 1 then
        local fortunetablesetup = split(string.lower(mod.FFFortunes), "\n\n")
        for i = 1, #fortunetablesetup do
            table.insert(mod.FortuneTable, split(fortunetablesetup[i], "\n"))
        end
    end
    if showcount then
        print("Fiend Folio has exactly " .. #mod.FortuneTable .. " fortunes at your disposal")
    end
end

function mod:ShowFortune(forcedtune, noDireChest)
    if forcedtune then
        local fortune = split(forcedtune, "\n")
        fortuneArray(fortune)
    else
        if not mod.ACHIEVEMENT.DIRE_CHEST:IsUnlocked() and not noDireChest and direChestFortuneRNG:RandomFloat() < 1/5 then
            fortuneArray(direChestFortunes[direChestFortuneRNG:RandomInt(#direChestFortunes) + 1])
        else
            if FiendFolio.CustomFortunesEnabled then
                mod:BuildFortuneTable()
                local choice = math.random(#mod.FortuneTable)
                local fortune = mod.FortuneTable[choice]
                fortuneArray(fortune)
            else
                game:ShowFortune()
            end
        end
    end
end

local fortuneExceptions = {
    {"how many", "duplicate fortunes", "are there"},
    {"i just wanted to tell", "you good luck! we're", "all counting on you!"}
}

function FiendFolio:findFortuneDupes()
    mod:BuildFortuneTable()
    Isaac.DebugString("Running fortune dupe check")
    for i = 1, #mod.FortuneTable do
        for k = i, #mod.FortuneTable do
            if i ~= k then
                local dupe = true
                if #mod.FortuneTable[i] == #mod.FortuneTable[k] then
                    for j = 1, #mod.FortuneTable[i] do
                        if mod.FortuneTable[i][j] ~= mod.FortuneTable[k][j] then
                            dupe = false
                            break
                        end
                    end
                    if dupe then
                        local exception
                        for j = 1, #fortuneExceptions do
                            if #fortuneExceptions[j] == #mod.FortuneTable[i] then
                                local isMatched = true
                                for j2 = 1, #mod.FortuneTable[i] do
                                    if mod.FortuneTable[i][j2] ~= fortuneExceptions[j][j2] then
                                        isMatched = false
                                        break
                                    end
                                    if isMatched then
                                        exception = true
                                        break
                                    end
                                end
                            end
                        end
                        if not exception then
                            local coolString = "______________________" .. "\n"
                            for j = 1, #mod.FortuneTable[i] do
                                coolString = coolString .. mod.FortuneTable[i][j] .. "\n"
                            end
                            Isaac.DebugString(coolString)
                        end
                    end
                end
            end
        end
    end
    Isaac.DebugString("Fortune dupe check complete :)")
end

local specialSeeds = {
    "BOOB TOOB",
    "BRWN SNKE",
    "B911 TCZL",
    "CAMO K1DD",
    "CAMO DROP",
    "CHAM P1ON",
    "CLST RPHO",
    "COCK FGHT",
    "COME BACK",
    "CONF ETTI",
    "DONT STOP",
    "DRAW KCAB",
    "DYSL EX1A",
    "FACE DOWN",
    "FART SNDS",
    "FREE 2PAY",
    "IMNO BODY",
    "GGGG GGGG",
    "HART BEAT",
    "ISAA AACE",
    "KEEP AWAY",
    "NICA LISY",
    "PAC1 F1SM",
    "SLOW 4ME2",
    "TARO TARJ",
    "THEG HOST",
    "XXXX XXZX",
    "8AJJ AASE",
    "BLCK CNDL",
    "M0DE SEVN",
}

function mod:ShowRule()
    if Options.Language == "en" then
        if math.random(25) == 1 then
            mod:ShowFortune(specialSeeds[math.random(#specialSeeds)])
        else
            mod.FortuneTableRules = mod.FortuneTableRules or {}
            if #mod.FortuneTableRules <= 1 then
                local fortunelist = mod.FFFortunesRules
                local fortunetablesetup = split(mod.FFFortunesRules, "\n\n")
                for i = 1, #fortunetablesetup do
                    table.insert(mod.FortuneTableRules, split(fortunetablesetup[i], "\n"))
                end
                --print("Fiend Folio has exactly " .. #mod.FortuneTable .. " rules at your disposal")
            end
            local choice = math.random(#mod.FortuneTableRules)
            local fortune = mod.FortuneTableRules[choice]
            fortuneArray(fortune)
        end
    else
        game:ShowRule()
    end
end

--i'm just going to copypaste these functions because i'm lazy (don't blame erfly)
function mod:BuildTortuneTable(rebuildTable)
    mod.TortuneTable = mod.TortuneTable or {}
    if rebuildTable then
        mod.TortuneTable = {}
    end
    if #mod.TortuneTable <= 1 then
        local tortunetablesetup = split(string.lower(mod.FFTortunes), "\n\n")
        for i = 1, #tortunetablesetup do
            table.insert(mod.TortuneTable, split(tortunetablesetup[i], "\n"))
        end
    end
end

function mod:ShowTortune()
    mod:BuildTortuneTable()
    local choice = math.random(#mod.TortuneTable)
    local tortune = mod.TortuneTable[choice]
    fortuneArray(tortune)
end

-- For anyone wanting to test big fortunes
-- paste your epic fortune inside the two brackets below,
-- so it looks like:
-- [======[
-- funny words
-- haha so funny
-- ]======]
-- then comment out the: string = nil
-- so it looks like:     --string = nil
-- then just run fortune in the console and it'll show your epic input

-- this is unnecessary to do now
-- just copy the fortune (with newlines) into the console

function mod:fortuneCommand(params)
    if #params > 0 then
        mod:ShowFortune(params, true)
    else
        --I'm really sorry for the formatting
        local string =
[======[

]======]
        string = nil
        mod:ShowFortune(string, true)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, player)
    local pickupFound
    for _, pickup in pairs(Isaac.FindByType(5, -1, -1)) do
        if pickup and pickup.Type == 5 and pickup.FrameCount <= 0 then
            pickupFound = true
        end
    end
    if not pickupFound then
        mod:ShowFortune()
    end
end, CollectibleType.COLLECTIBLE_FORTUNE_COOKIE)

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
    if sprite:IsPlaying("Prize") then
        if sprite:GetFrame() == 4 then
            local pickupFound
            for _, pickup in pairs(Isaac.FindByType(5, -1, -1)) do
                if pickup and pickup.Type == 5 and pickup.FrameCount <= 0 then
                    pickupFound = true
                end
            end
            if not pickupFound then
                mod:ShowFortune()
            end
        end
    end
end, 3)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, player)
    mod:ShowRule()
end, Card.CARD_RULES)
