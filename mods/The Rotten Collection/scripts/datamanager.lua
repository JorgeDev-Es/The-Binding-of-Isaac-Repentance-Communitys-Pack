local json = require("json")

local fetchedData = nil

if ROTCG:HasData() then
    local loadStatus, LoadValue = pcall(json.decode, ROTCG:LoadData())
    if loadStatus then
        fetchedData = LoadValue
    else
        fetchedData = {}
    end
end

local function Load(_, isContinued)
    -- Reset save if new run
    if ROTCG:HasData() then
        if isContinued then
            local loadStatus, LoadValue = pcall(json.decode, ROTCG:LoadData())

            if loadStatus then
                fetchedData = LoadValue
            else
                fetchedData = {}
            end
        else
            local oldData = json.decode(ROTCG:LoadData()) or {}

            fetchedData = { ['settings'] = oldData.settings }
            ROTCG:SaveData(json.encode({ ['settings'] = oldData.settings }))
        end
    end
end

local function SetData(key, content)
    if fetchedData == nil then fetchedData = {} end
    fetchedData[key] = content
    ROTCG:SaveData(json.encode(fetchedData))
end

local function GetData(key)
    if not fetchedData then Load(nil, true) end
    return (fetchedData and fetchedData[key]) and fetchedData[key] or {}
end

local function SaveData()
    ROTCG:SaveData(json.encode(fetchedData))
end

ROTCG:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveData)
ROTCG:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Load)

return {
    GetData = GetData,
    SetData = SetData,
    SaveData = SaveData,
}