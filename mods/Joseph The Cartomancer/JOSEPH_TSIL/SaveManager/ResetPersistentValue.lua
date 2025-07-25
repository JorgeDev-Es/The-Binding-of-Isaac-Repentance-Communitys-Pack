
function TSIL.SaveManager.ResetPersistentVariable(mod, variableName)
	local PersistentData = TSIL.__VERSION_PERSISTENT_DATA.PersistentData

	local modPersistentData = PersistentData[mod.Name]

	if modPersistentData == nil then
		return
	end

	local modVariables = modPersistentData.variables

	local foundVariable = modVariables[variableName]

	if foundVariable == nil then
		return
	end

	foundVariable.value = TSIL.Utils.DeepCopy.DeepCopy(foundVariable.default, TSIL.Enums.SerializationType.NONE)
end