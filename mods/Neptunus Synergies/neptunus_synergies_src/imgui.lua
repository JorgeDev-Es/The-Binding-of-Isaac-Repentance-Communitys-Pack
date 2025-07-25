local mod = RoarysNeptunusSynergies

local modconfigs_tabid
local tabIDvars = {
	"ModsSettingMenu",
	"ModsSettings",
	"ModsConfigMenu",
	"ModsConfigs",
	"ModSettingMenu",
	"ModSettings",
	"ModConfigMenu",
	"ModConfigs"
}
for i,v in pairs(tabIDvars) do
	if ImGui.ElementExists(v) then
		modconfigs_tabid = v
		break
	end
end
if modconfigs_tabid == nil then
	modconfigs_tabid = "ModsSettingMenu"
	ImGui.CreateMenu("ModsSettingMenu", "\u{f085} Mod Configs")
end

ImGui.AddElement(modconfigs_tabid, "NepSynWindowButton", ImGuiElement.MenuItem, "Neptunus Synergies")
ImGui.CreateWindow("NepSynSettingsWindow", "Neptunus Synergies Settings")
ImGui.LinkWindowToElement("NepSynSettingsWindow", "NepSynWindowButton")

ImGui.AddCheckbox("NepSynSettingsWindow", "NepSynChangeSprites", "Change sprites", function (isOn)
	mod.config.changeSprites = isOn
	mod.SaveConfig()
end, mod.config.changeSprites)
ImGui.SetHelpmarker("NepSynChangeSprites", "Whether to use special sprites for lasers and sword;\nwhether to change blood tear variants to their respective blue variants.")

ImGui.AddCheckbox("NepSynSettingsWindow", "NepSynOverwriteSprites", "Overwrite unique sprites", function (isOn)
	mod.config.overwriteUniqueSprites = isOn
	mod.SaveConfig()
end, mod.config.overwriteUniqueSprites)
ImGui.SetHelpmarker("NepSynOverwriteSprites", "Overwrites sprites from 'Unique <x>' mods.\nCurrently interacts only with 'Unique Swords' mods.")

ImGui.AddCheckbox("NepSynSettingsWindow", "NepSynWaterBombs", "Water bombs", function (isOn)
	mod.config.waterBombs = isOn
	mod.SaveConfig()
end, mod.config.waterBombs)
ImGui.SetHelpmarker("NepSynWaterBombs", "Affects Dr. Fetus and Epic Fetus synergies:\n•changes explosion sprites into water explosions;\n•spawns creep, that damages enemies.")


function mod.UpdateImGUIData()
	ImGui.UpdateData("NepSynChangeSprites", ImGuiData.Value, mod.config.changeSprites)
	ImGui.UpdateData("NepSynOverwriteSprites", ImGuiData.Value, mod.config.overwriteUniqueSprites)
	ImGui.UpdateData("NepSynWaterBombs", ImGuiData.Value, mod.config.waterBombs)
end
