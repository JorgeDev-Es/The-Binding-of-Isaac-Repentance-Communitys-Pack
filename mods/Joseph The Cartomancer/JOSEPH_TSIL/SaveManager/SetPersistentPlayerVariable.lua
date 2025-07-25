function TSIL.SaveManager.SetPersistentPlayerVariable(mod, variableName, player, newValue)
	local persistentData = TSIL.__VERSION_PERSISTENT_DATA.PersistentData
    local persistentPlayerData = TSIL.__VERSION_PERSISTENT_DATA.PersistentPlayerData

	local modPersistentData = persistentData[mod.Name]
    local modPersistentPlayerData = persistentPlayerData[mod.Name]

	if modPersistentData == nil or modPersistentPlayerData == nil then
		return
	end

	local modVariables = modPersistentData.variables

	local foundVariable = modVariables[variableName]
    local playerVariableData = modPersistentPlayerData[variableName]

	if foundVariable == nil or playerVariableData == nil then
		return
	end

    local playerIndex = TSIL.Players.GetPlayerIndex(player, playerVariableData.differentiateSoulAndForgotten)
	foundVariable.value[playerIndex] = newValue
end