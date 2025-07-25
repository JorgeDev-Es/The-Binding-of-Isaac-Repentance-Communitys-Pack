local modName = "Visible Holy Mantles";

--Check if Mod Config is installed
if ModConfigMenu then
	--Add a tab for Visible Lost Health
    ModConfigMenu.UpdateCategory(modName,
	{
    Info = {
        "View settings for " .. modName .. ".",
    }});

	--Add option to choose where to draw the additional shields
    ModConfigMenu.AddSetting(modName, "Settings", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return VHM.Settings["drawShieldsInline"];
        end,
        Display = function()
            local toggle = "Inline";
            if not VHM.Settings["drawShieldsInline"] then
                toggle = "Below";
            end
            return "Icon Positions: " .. toggle;
        end,
        OnChange = function(currentBool)
            VHM.Settings["drawShieldsInline"] = currentBool;
        end,
        Info = function()
            if VHM.Settings["drawShieldsInline"] then
                return "Holy Mantle icons will be drawn in line with the health bar.";
            else
                return "Holy Mantle icons will be drawn below the health bar.";
            end
        end
    });

    --Add option to choose if shields should overlap each other
    ModConfigMenu.AddSetting(modName, "Settings", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return VHM.Settings["drawShieldsOverlapping"];
        end,
        Display = function()
            local toggle = "Overlapping";
            if not VHM.Settings["drawShieldsOverlapping"] then
                toggle = "Separated";
            end
            return "Draw Icons: " .. toggle;
        end,
        OnChange = function(currentBool)
            VHM.Settings["drawShieldsOverlapping"] = currentBool;
        end,
        Info = function()
            if VHM.Settings["drawShieldsOverlapping"] then
                return "Holy Mantle icons will be drawn overlapping each other slightly.";
            else
                return "Holy Mantle icons will be drawn discretely.";
            end
        end
    });

    --Add option to see mantles even during Curse of the Unknown
    ModConfigMenu.AddSetting(modName, "Settings", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return VHM.Settings["overrideCurse"];
        end,
        Display = function()
            local toggle = "ENABLED";
            if VHM.Settings["overrideCurse"] then
                toggle = "disabled";
            end
            return "Curse of the Unknown: " .. toggle;
        end,
        OnChange = function(currentBool)
            VHM.Settings["overrideCurse"] = currentBool;
        end,
        Info = function()
            if VHM.Settings["overrideCurse"] then
                return "Holy Mantle icons will be shown during Curse of the Unknown.";
            else
                return "Holy Mantle icons will not be shown during Curse of the Unknown.";
            end
        end
    });
end
