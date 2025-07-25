
local GLOWING_HOUR_GLASS_BACKUP_KEYS = {
    [TSIL.Enums.VariablePersistenceMode.REMOVE_LEVEL] = true,
    [TSIL.Enums.VariablePersistenceMode.REMOVE_ROOM] = true,
    [TSIL.Enums.VariablePersistenceMode.RESET_LEVEL] = true,
    [TSIL.Enums.VariablePersistenceMode.RESET_ROOM] = true,
    [TSIL.Enums.VariablePersistenceMode.RESET_RUN] = true,
    [TSIL.Enums.VariablePersistenceMode.REMOVE_RUN] = true
}


function TSIL.SaveManager.MakeGlowingHourGlassBackup(slot)
    local glowingHourglassSlot = TSIL.__VERSION_PERSISTENT_DATA.GlowingHourglassPersistentDataBackup[slot]

    if not glowingHourglassSlot then
        glowingHourglassSlot = {}
        TSIL.__VERSION_PERSISTENT_DATA.GlowingHourglassPersistentDataBackup[slot] = glowingHourglassSlot
    end

    TSIL.Utils.Tables.IterateTableInOrder(TSIL.__VERSION_PERSISTENT_DATA.PersistentData, function(modName, modPersistentData)

        local saveDataGlowingHourGlass = glowingHourglassSlot[modName]
        if saveDataGlowingHourGlass == nil then
            saveDataGlowingHourGlass = {}
            glowingHourglassSlot[modName] = saveDataGlowingHourGlass
        end

        TSIL.Utils.Tables.IterateTableInOrder(modPersistentData.variables, function (variableName, variable)
            local conditionalFunc = variable.conditionalSave

            if conditionalFunc ~= nil then
                local shouldSave = conditionalFunc()
                if not shouldSave then
                    return
                end
            end

            if not GLOWING_HOUR_GLASS_BACKUP_KEYS[variable.persistenceMode] then
                return
            end

            if variable.ignoreGlowingHourglass then
                return
            end

            saveDataGlowingHourGlass[variableName] = TSIL.Utils.DeepCopy.DeepCopy(variable.value, TSIL.Enums.SerializationType.NONE)
        end)
    end)
end


function TSIL.SaveManager.RestoreGlowingHourGlassBackup(slot)
    local glowingHourglassSlot = TSIL.__VERSION_PERSISTENT_DATA.GlowingHourglassPersistentDataBackup[slot]

    if not glowingHourglassSlot then
        return
    end

    TSIL.Utils.Tables.IterateTableInOrder(TSIL.__VERSION_PERSISTENT_DATA.PersistentData, function(modName, modPersistentData)
        local saveDataGlowingHourGlass = glowingHourglassSlot[modName]
        if saveDataGlowingHourGlass == nil then
            return
        end

        TSIL.Utils.Tables.IterateTableInOrder(modPersistentData.variables, function (variableName, variable)
            local conditionalFunc = variable.conditionalSave

            if conditionalFunc ~= nil then
                local shouldSave = conditionalFunc()
                if not shouldSave then
                    return
                end
            end

            if not GLOWING_HOUR_GLASS_BACKUP_KEYS[variable.persistenceMode] then
                return
            end

            if variable.ignoreGlowingHourglass then
                return
            end

            local newValue = saveDataGlowingHourGlass[variableName]

            if newValue == nil then
                return
            end

            variable.value = TSIL.Utils.DeepCopy.DeepCopy(newValue, TSIL.Enums.SerializationType.NONE)
        end)
    end)
end

