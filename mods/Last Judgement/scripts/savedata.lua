local mod = LastJudgement
local game = Game()
local json = require("json")

function mod:GetSaveData()
    if not mod.saveData then
        if Isaac.HasModData(LastJudgement) then
            mod.saveData = json.decode(mod:LoadData())
        else
            mod.saveData = {}
        end
    end

    return mod.saveData
end

function mod:StoreSaveData()
    local saveData = mod:GetSaveData()
    mod:SaveData(json.encode(mod:GetSaveData()))
end

function mod:GetPersistentPlayerData(player) --From Retribution, by Xalum
    local savedata = mod:GetSaveData()
	if not savedata.RunData.PersistentPlayerData then
        savedata.RunData.PersistentPlayerData = {}
    end

    local seedReference = CollectibleType.COLLECTIBLE_SAD_ONION
    local playerType = player:GetPlayerType()

    if playerType == PlayerType.PLAYER_LAZARUS2_B then
        seedReference = CollectibleType.COLLECTIBLE_INNER_EYE
    elseif playerType ~= PlayerType.PLAYER_ESAU then
        player = player:GetMainTwin()
    end

    local tableIndex = player:GetCollectibleRNG(seedReference):GetSeed()
    tableIndex = tostring(tableIndex)

    savedata.PersistentPlayerData[tableIndex] = savedata.PersistentPlayerData[tableIndex] or {}
    return savedata.PersistentPlayerData[tableIndex]
end

function mod:ResetSaveData(trueReset)
    if trueReset then
        mod.saveData = {}
    end
    mod.saveData.RunData = {}
    mod.saveData.RunData.FloorData = {}
    mod.saveData.RunData.PersistentPlayerData = {}
end

function mod:ResetFloorData()
    local saveData = mod:GetSaveData()
    if saveData.RunData then
        saveData.RunData.FloorData = {}
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
	if isContinued then
        local saveData = mod:GetSaveData()
    else
        mod:ResetSaveData()
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    mod:ResetFloorData()
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
	if shouldSave then
		mod:StoreSaveData()
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function(_, unloadedMod)
    if unloadedMod.Name == "Last Judgement" then
        mod:StoreSaveData()
    end
end)