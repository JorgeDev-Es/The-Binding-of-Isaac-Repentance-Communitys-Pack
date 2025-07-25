local json = require("json")

GOLCG:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))
end)
GOLCG:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
    if GOLCG:HasData() then
        local loadStatus, LoadValue = pcall(json.decode, GOLCG:LoadData())
        if loadStatus then
            if isContinued then
                GOLCG.SAVEDATA = LoadValue
            else
                GOLCG.SAVEDATA = { 
                    CAN_SPAWN_FICHES = LoadValue.CAN_SPAWN_FICHES,
                    HOURGLASS = { IsActive = false, Rooms = {} },
                    BLACK_CARD = { ["Debt"] = 0, ["IgnoreUpdates"] = 0, ['PickupFilter'] = nil }
                }
                GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))
            end

            goto skipDefault
        end
    end

    GOLCG.SAVEDATA = {
        CAN_SPAWN_FICHES = true,
        HOURGLASS = { IsActive = false, Rooms = {} },
        BLACK_CARD = { ["Debt"] = 0, ["IgnoreUpdates"] = 0, ['PickupFilter'] = nil }
    }
    GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))

    ::skipDefault::
end)