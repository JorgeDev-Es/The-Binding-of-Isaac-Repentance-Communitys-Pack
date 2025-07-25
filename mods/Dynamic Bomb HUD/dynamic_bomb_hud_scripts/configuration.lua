--Mod configuration menu!!! yayyy!!!

if ModConfigMenu then
    local MOD_NAME = "Dynamic Bomb HUD"
    local VERSION = "1.4"

    --General info (Name, Version and Credits)
  
    ModConfigMenu.AddSpace(MOD_NAME, "Info")
    ModConfigMenu.AddText(MOD_NAME, "Info", function() return MOD_NAME end)
    ModConfigMenu.AddSpace(MOD_NAME, "Info")
    ModConfigMenu.AddText(MOD_NAME, "Info", function() return "Version " .. VERSION end)
    ModConfigMenu.AddSpace(MOD_NAME, "Info")
    ModConfigMenu.AddText(MOD_NAME, "Info", function() return "Credits:" end)
    ModConfigMenu.AddText(MOD_NAME, "Info", function() return "Art by Nerfexus" end)
    ModConfigMenu.AddText(MOD_NAME, "Info", function() return "Code and mod idea by Tiburones202" end)

    ModConfigMenu.AddSpace(MOD_NAME, "Options")
    ModConfigMenu.AddText(MOD_NAME, "Options", function() return "Cycle options:" end)

    ModConfigMenu.AddSetting(MOD_NAME, "Options", 
        {
            Type = ModConfigMenu.OptionType.BOOLEAN,
            Attribute = "Cycle between bombs",
            Default = false,

            CurrentSetting = function()
                return CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "Cycle", false)
            end,

            Display = function()
                local OnOff = CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "Cycle", false) and "On" or "Off"
                return "Cycle between bombs: " .. OnOff
            end,

            -- a function that is called whenever the setting is changed (can be used to save your settings for example)
            OnChange = function(value) 
                CustomBombHUDIcons.saveManager.GetSettingsSave().Cycle = value
            end,

            Info = { "Cycle between all the owned bomb modifiers when having multiple" },
        }
    )

    ModConfigMenu.AddSetting(MOD_NAME, "Options", 
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            Attribute = "Frames per cycle",
            Default = 30,
            Minimum = 5,
            Maximum = 240,

            CurrentSetting = function()
                return CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "FramesPerCycle", 30)
            end,

            Display = function()
                local framesThingy = CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "FramesPerCycle", 30)
                return "Frames per cycle: " .. tostring(framesThingy)
            end,

            -- a function that is called whenever the setting is changed (can be used to save your settings for example)
            OnChange = function(value) 
                CustomBombHUDIcons.saveManager.GetSettingsSave().FramesPerCycle = value
            end,

            Info = { "Amount of frames the game should wait before changing the bomb sprite when having multiple modifiers" },
        }
    )

    ModConfigMenu.AddSpace(MOD_NAME, "Options")
    ModConfigMenu.AddText(MOD_NAME, "Options", function() return "Other options:" end)

    ModConfigMenu.AddSetting(MOD_NAME, "Options", 
        {
            Type = ModConfigMenu.OptionType.BOOLEAN,
            Attribute = "Tainted Lazarus birthright",
            Default = false,

            CurrentSetting = function()
                return CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "CountTLazHologram", false)
            end,

            Display = function()
                local OnOff = CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "CountTLazHologram", false) and "On" or "Off"
                return "Tainted Lazarus birthright: " .. tostring(OnOff)
            end,

            -- a function that is called whenever the setting is changed (can be used to save your settings for example)
            OnChange = function(value) 
                CustomBombHUDIcons.saveManager.GetSettingsSave().CountTLazHologram = value
            end,

            Info = { "Count Tainted Lazarus' birthright hologram to render bombs" },
        }
    )
end

--get config thing!!! In case it's null, yk?
--CustomBombHUDIcons:GetOption(options, Cycle, false)
function CustomBombHUDIcons:GetOption(options, option, defaultValue)
    if not options[option] then
        options[option] = defaultValue
    end

    return options[option]
end