function TSIL.SaveManager.AddPersistentPlayerVariable(mod, variableName, defaultValue, persistenceMode, differentiateSoulAndForgotten, ignoreGlowingHourglass, conditionalSave)
    TSIL.SaveManager.AddPersistentVariable(
        mod,
        variableName,
        {},
        persistenceMode,
        ignoreGlowingHourglass,
        conditionalSave
    )

    local playerVariables = TSIL.__VERSION_PERSISTENT_DATA.PersistentPlayerData[mod.Name]
    if not playerVariables then
        playerVariables = {}
        TSIL.__VERSION_PERSISTENT_DATA.PersistentPlayerData[mod.Name] = playerVariables
    end

    playerVariables[variableName] = {
        default = TSIL.Utils.DeepCopy.DeepCopy(defaultValue, TSIL.Enums.SerializationType.NONE),
        differentiateSoulAndForgotten = differentiateSoulAndForgotten
    }
end