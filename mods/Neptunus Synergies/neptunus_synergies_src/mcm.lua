local mod = RoarysNeptunusSynergies
local modconfigexists, MCM = pcall(require, "scripts.modconfig")


if modconfigexists then
	MCM.AddText("Neptunus Synergies", "Config", function() return "Mod by Roary" end)
	
	MCM.AddSpace("Neptunus Synergies", "Config")
	
	MCM.AddSetting(
		"Neptunus Synergies",
		"Config",
		{
			Type = MCM.OptionType.BOOLEAN,
			CurrentSetting = function()
				return mod.config.changeSprites
			end,
			Display = function()
				return "Change sprites: " .. (mod.config.changeSprites and "ON" or "OFF")
			end,
			OnChange = function(currentBool)
				mod.config.changeSprites = currentBool
				mod.SaveConfig()
			end,
			Info = {
				"Whether to use special sprites for lasers and sword, changes blood tear variants to their respective blue variants."
			}
		}
	)
	
	MCM.AddSetting(
		"Neptunus Synergies",
		"Config",
		{
			Type = MCM.OptionType.BOOLEAN,
			CurrentSetting = function()
				return mod.config.waterBombs
			end,
			Display = function()
				return "Water bombs: " .. (mod.config.waterBombs and "ON" or "OFF")
			end,
			OnChange = function(currentBool)
				mod.config.waterBombs = currentBool
				mod.SaveConfig()
			end,
			Info = {
				"Affects Dr. Fetus bombs and Epic Fetus rockets.$newlineChanges explosion sprites into water explosions, spawns creep."
			}
		}
	)
	
	MCM.AddSetting(
		"Neptunus Synergies",
		"Config",
		{
			Type = MCM.OptionType.BOOLEAN,
			CurrentSetting = function()
				return mod.config.overwriteUniqueSprites
			end,
			Display = function()
				return "Overwrite unique sprites: " .. (mod.config.overwriteUniqueSprites and "ON" or "OFF")
			end,
			OnChange = function(currentBool)
				mod.config.overwriteUniqueSprites = currentBool
				mod.SaveConfig()
			end,
			Info = {
				"Overwrites sprites from 'Unique <x>' mods.$newlineCurrently interacts only with 'Unique Swords' mods."
			}
		}
	)
end