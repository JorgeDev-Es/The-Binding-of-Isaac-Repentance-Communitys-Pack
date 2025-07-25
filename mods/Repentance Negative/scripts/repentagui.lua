local Mod = RepMMod
local SaveManager = Mod.saveManager

local ig = ImGui
local root = "RepMMod"

local function IsNumber(t)
	return t and type(t) == "number"
end

local function IsFunction(t)
	return t and type(t) == "function"
end

local function IsBoolean(t)
	return t and type(t) == "boolean"
end

local function IsString(t)
	return t and type(t) == "string"
end

local function IsTable(t)
	return t and type(t) == "table"
end

---@param elemType ImGuiElement | integer
---@return boolean
local function IsMenu(elemType)
	return elemType == ImGuiElement.Menu or elemType == ImGuiElement.MenuItem
end

---@param elemType ImGuiElement | integer
---@return boolean
local function IsWindow(elemType)
	return elemType == ImGuiElement.Window
end

---@param ... string
---@return string
local function MakeElementName(...)
	local finalName = nil
	for _, str in ipairs({ ... }) do
		if IsString(finalName) then
			finalName = finalName .. "_" .. str
		else
			finalName = str
		end
	end
	return finalName or ""
end

local function RemoveElement(id, type)
	if IsString(id) then
		local resetFunc = {
			[ImGuiElement.Menu] = ig.RemoveMenu,
			[ImGuiElement.MenuItem] = ig.RemoveMenu,
			[ImGuiElement.Window] = ig.RemoveWindow,
			Default = ig.RemoveElement,
		}
		local func = (IsNumber(type) and resetFunc[type]) and resetFunc[type] or resetFunc.Default
		if ig.ElementExists(id) then
			func(id)
		end
	end
end

---@param parentId string
---@param id string
---@param elems function | string | table
local function AddElements(parentId, id, elems)
	local parentElement = MakeElementName(parentId, id)
	local tabBarID = MakeElementName(parentElement, "TabBar")
	RemoveElement(tabBarID)
	for name, elem in pairs(elems) do
		if IsFunction(elem) then
			elem(parentElement, name)
		elseif IsString(elem) then
			ig.AddText(parentElement, elem, true, MakeElementName(parentElement, name))
		elseif IsTable(elem) then
			if not ig.ElementExists(tabBarID) then
				ig.AddTabBar(parentElement, tabBarID)
			end
			local tabID = MakeElementName(tabBarID, name)
			ig.AddTab(tabBarID, tabID, name)
			AddElements(tabBarID, name, elem)
		end
	end
end

local function InitAchievementMenu()
	return {function(parentID, id)
		ig.AddButton(parentID, MakeElementName(parentID, id, "unlock"), Mod.GetDSSStr("unlock", false), function()
			for _, ach in pairs(Mod.RepmAchivements) do
				Isaac.GetPersistentGameData():TryUnlock(ach.ID, true)
			end
		end, true)
		ig.AddButton(parentID, MakeElementName(parentID, id, "lock"), Mod.GetDSSStr("lock", false), function()
			for _, ach in pairs(Mod.RepmAchivements) do
				Isaac.ExecuteCommand("lockachievement " .. ach.ID)
			end
		end, true)
		for name, ach in pairs(Mod.RepmAchivements) do
			ig.AddCheckbox(parentID, MakeElementName(parentID, id, ach.Name), ach.Name, function(newVal)
				if newVal then
					Isaac.GetPersistentGameData():TryUnlock(ach.ID, false)
				else
					Isaac.ExecuteCommand("lockachievement " .. ach.ID)
				end
			end, false)
			ig.AddCallback(MakeElementName(parentID, id, ach.Name), ImGuiCallback.Render, function()
				ig.UpdateData(
					MakeElementName(parentID, id, ach.Name),
					ImGuiData.Value,
					Isaac.GetPersistentGameData():Unlocked(ach.ID)
				)
			end)
		end
	end}
end

local debugValues = {
	["Traffic Light"] = function()
		if SaveManager.IsLoaded() then
			return Mod:RunSave().RedLightSign
		else
			return "null"
		end
	end,
	["Traffic Light Cooldown"] = function()
		if SaveManager.IsLoaded() then
			return Mod:RunSave().saveTimer
		else
			return "null"
		end
	end,
}

local function InitDebugArgs()
	local tab = {}
	table.insert(tab, function(parentID, id)
		for name, val in pairs(debugValues) do
			ig.AddText(parentID, name .. ": " .. tostring(val()), false, MakeElementName(parentID, name))
			ig.AddCallback(MakeElementName(parentID, name), ImGuiCallback.Render, function()
				ig.UpdateData(MakeElementName(parentID, name), ImGuiData.Label, name .. ": " .. tostring(val()))
			end)
		end
	end)

	return tab
end

local function InitMusicSettings()
	local musicWindow = {}
	local music, jingle = Mod.GetModdedMusicTable()

	table.insert(musicWindow, function(parentId, id)
		ig.AddButton(parentId, MakeElementName(parentId, "music_enable"), Mod.GetDSSStr("enable_all_music", false), function()
			local musicData = Mod.GetModdedMusicData()
			for musicId, name in pairs(music) do
				musicData.Music[name] = 1
				Mod.ChangeFloorMusicTo(musicId, Isaac.GetMusicIdByName(name), true)
			end
			for jingleId, name in pairs(jingle) do
				musicData.Jingle[name] = 1
			end
			Mod:SaveGameData()
		end, true)
		ig.AddButton(
			parentId,
			MakeElementName(parentId, "music_disable"),
			Mod.GetDSSStr("disable_all_music", false),
			function()
				local musicData = Mod.GetModdedMusicData()
				for musicId, name in pairs(music) do
					musicData.Music[name] = 2
					Mod.ChangeFloorMusicTo(musicId, Isaac.GetMusicIdByName(name), false)
				end
				for jingleId, name in pairs(jingle) do
					musicData.Jingle[name] = 2
				end
				Mod:SaveGameData()
			end,
			true
		)
		ig.AddTabBar(parentId, MakeElementName(parentId, id, "Tab"))
		ig.AddTab(
			MakeElementName(parentId, id, "Tab"),
			MakeElementName(parentId, id, "Tab", "Music"),
			Mod.GetDSSStr("music_settings", false)
		)
		ig.AddTab(
			MakeElementName(parentId, id, "Tab"),
			MakeElementName(parentId, id, "Tab", "Jingle"),
			Mod.GetDSSStr("jingle_settings", false)
		)
		for musicId, name in pairs(music) do
			ig.AddCheckbox(
				MakeElementName(parentId, id, "Tab", "Music"),
				MakeElementName(parentId, id, "Tab", "Music", name),
				name:gsub("Repentance Negative", ""),
				function(checked)
					local musicData = Mod.GetModdedMusicData()
					musicData.Music[name] = checked and 1 or 2
					Mod.ChangeFloorMusicTo(musicId, Isaac.GetMusicIdByName(name), checked)
					Mod:SaveGameData()
				end,
				true
			)
			ig.AddCallback(MakeElementName(parentId, id, "Tab", "Music", name), ImGuiCallback.Render, function()
				local musicData = Mod.GetModdedMusicData()
				ig.UpdateData(
					MakeElementName(parentId, id, "Tab", "Music", name),
					ImGuiData.Value,
					musicData.Music[name] == 1
				)
			end)
		end
		for jingleId, name in pairs(jingle) do
			ig.AddCheckbox(
				MakeElementName(parentId, id, "Tab", "Jingle"),
				MakeElementName(parentId, id, "Tab", "Jingle", name),
				name:gsub("Repentance Negative", ""),
				function(checked)
					local musicData = Mod.GetModdedMusicData()
					musicData.Jingle[name] = checked and 1 or 2
					Mod:SaveGameData()
				end,
				true
			)
			ig.AddCallback(MakeElementName(parentId, id, "Tab", "Jingle", name), ImGuiCallback.Render, function()
				local musicData = Mod.GetModdedMusicData()
				ig.UpdateData(
					MakeElementName(parentId, id, "Tab", "Jingle", name),
					ImGuiData.Value,
					musicData.Jingle[name] == 1
				)
			end)
		end
	end)

	return musicWindow
end

local function InitOtherSettings()
	local otherSettingsWindow = {}

	table.insert(otherSettingsWindow, function(parentId, id)
		ig.AddCheckbox(parentId, MakeElementName(parentId, "happy_start"), Mod.GetDSSStr("happy_start", false), function(checked)
			Mod:AddDefaultFileSave("StartThumbsUp", checked and 1 or 2)
			Mod:SaveGameData()
		end, true)
	end)

	return otherSettingsWindow
end

local menus = {
	["Achievements"] = InitAchievementMenu(),
	["Music Manager"] = InitMusicSettings(),
	["Other Settings"] = InitOtherSettings(),
}

local menuNames = {
	["Achievements"] = Mod.GetDSSStr("unlock_manager", false),
	["Music Manager"] = Mod.GetDSSStr("music_manager", false),
	["Other Settings"] = Mod.GetDSSStr("other_settings", false),
}

local function InitDebugMenu()
	RemoveElement(MakeElementName(root, "Debug"), ImGuiElement.Menu)
	ig.AddElement(root, MakeElementName(root, "Debug"), ImGuiElement.MenuItem, "\u{f085} Debug")
	RemoveElement(MakeElementName(root, "Debug", "Window"), ImGuiElement.Window)
	ig.CreateWindow(MakeElementName(root, "Debug", "Window"), "Debug Window")
	ig.LinkWindowToElement(MakeElementName(root, "Debug", "Window"), MakeElementName(root, "Debug"))
	AddElements(root, MakeElementName("Debug", "Window"), InitDebugArgs())
	ig.SetVisible(MakeElementName(root, "Debug", "Window"), true)
end

local function DeleteDebugMenu()
	RemoveElement(MakeElementName(root, "Debug"))
	RemoveElement(MakeElementName(root, "Debug", "Window"), ImGuiElement.Window)
end

RemoveElement(root, ImGuiElement.Menu)

ig.CreateMenu(root, "Rep-")

for menuName, menu in pairs(menus) do
	RemoveElement(MakeElementName(root, menuName), ImGuiElement.Menu)
	ig.AddElement(root, MakeElementName(root, menuName), ImGuiElement.MenuItem, menuNames[menuName])
	RemoveElement(MakeElementName(root, menuName, "Window"), ImGuiElement.Window)
	ig.CreateWindow(MakeElementName(root, menuName, "Window"), menuName)
	ig.LinkWindowToElement(MakeElementName(root, menuName, "Window"), MakeElementName(root, menuName))
	AddElements(root, MakeElementName(menuName, "Window"), menu)
end

local function CheckSoundtrackMenu()
	if SoundtrackSongList then
		RemoveElement(MakeElementName(root, "Music Manager"))
		RemoveElement(MakeElementName(root, "Music Manager", "Window"), ImGuiElement.Window)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, CheckSoundtrackMenu)

Mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, args)
	if cmd == "RepMModDebug" then
		if args:lower() == "enable" then
			InitDebugMenu()
		elseif args:lower() == "disable" then
			DeleteDebugMenu()
		end
	end
end)
