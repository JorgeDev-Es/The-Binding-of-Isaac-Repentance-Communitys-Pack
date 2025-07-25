local Mod = RepMMod

local DSSModName = "Repentance-"

local DSSCoreVersion = 6

local MenuProvider = {}

local SaveManager = Mod.saveManager

function MenuProvider.SaveSaveData()
	Mod:SaveGameData()
end

function MenuProvider.GetPaletteSetting()
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	return dssSave and dssSave.MenuPalette or nil
end

function MenuProvider.SavePaletteSetting(var)
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	dssSave.MenuPalette = var
end

function MenuProvider.GetGamepadToggleSetting()
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	return dssSave and dssSave.GamepadToggle or nil
end

function MenuProvider.SaveGamepadToggleSetting(var)
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	dssSave.GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	return dssSave and dssSave.MenuKeybind or nil
end

function MenuProvider.SaveMenuKeybindSetting(var)
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	dssSave.MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	return dssSave and dssSave.MenuHint or nil
end

function MenuProvider.SaveMenuHintSetting(var)
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	dssSave.MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	return dssSave and dssSave.MenuBuzzer or nil
end

function MenuProvider.SaveMenuBuzzerSetting(var)
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	dssSave.MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	return dssSave and dssSave.MenusNotified or nil
end

function MenuProvider.SaveMenusNotified(var)
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	dssSave.MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	return dssSave and dssSave.MenusPoppedUp or nil
end

function MenuProvider.SaveMenusPoppedUp(var)
	local dssSave = SaveManager.GetDeadSeaScrollsSave()
	dssSave.MenusPoppedUp = var
end

local DSSInitializerFunction = include("scripts.lib.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local pdg = Isaac.GetPersistentGameData()

local function InitMusicSettings()
	local music, _ = Mod.GetModdedMusicTable()
	local MM = {}
	local musicData = Mod.GetModdedMusicData()
	for musicId, name in pairs(music) do
		if not musicData.Music[name] then
			musicData.Music[name] = 1
		end
		MM[#MM + 1] = {
			strset = Mod.SplitString(name:sub(21):lower(), 18),
			choices = { Mod.GetDSSStr("enabled"), Mod.GetDSSStr("disabled") },
			variable = name,
			setting = 1,
			load = function()
				return musicData.Music[name] or 1
			end,
			store = function(var)
				musicData.Music[name] = var
				Mod.ChangeFloorMusicTo(musicId, Isaac.GetMusicIdByName(name), var == 1)
			end,
			tooltip = {
				strset = Mod.SplitString('enable/disable "' .. name:sub(21):lower() .. '" music from this mod', 15),
			},
		}
		MM[#MM + 1] = { str = "", nosel = true, fsize = 2 }
	end
	return MM
end

local function InitJingleSettings()
	local music, jingle = Mod.GetModdedMusicTable()
	local MM = {}
	local musicData = Mod.GetModdedMusicData()
	for jingleId, name in pairs(jingle) do
		if not musicData.Jingle[name] then
			musicData.Jingle[name] = 1
		end
		MM[#MM + 1] = {
			strset = Mod.SplitString(name:sub(21):lower(), 18),
			choices = { Mod.GetDSSStr("enabled"), Mod.GetDSSStr("disabled") },
			variable = name,
			setting = 1,
			load = function()
				return musicData.Jingle[name] or 1
			end,
			store = function(var)
				musicData.Jingle[name] = var
			end,
			tooltip = {
				strset = Mod.SplitString('enable/disable "' .. name:sub(21):lower() .. '" jingle from this mod', 15),
			},
		}
		MM[#MM + 1] = { str = "", nosel = true, fsize = 2 }
	end
	return MM
end

local function InitUnlockButtons()
	local buttons = {}
	for _, ach in pairs(Mod.RepmAchivements) do
		buttons[#buttons + 1] = {
			strset = Mod.SplitString(ach.Name:lower(), 18),
			choices = { Mod.GetDSSStr("locked"), Mod.GetDSSStr("unlocked") },
			variable = "RepMAchievement" .. ach.Name,
			setting = 1,
			load = function()
				local val = pdg:Unlocked(ach.ID) and 2 or 1
				return val
			end,
			store = function(var)
				if var == 2 then
					pdg:Unlocked(ach.ID)
				else
					Isaac.ExecuteCommand("lockachievement " .. ach.ID)
				end
			end,
			tooltip = {
				strset = Mod.SplitString("unlock/lock " .. ach.Name:lower(), 15),
			},
		}
		buttons[#buttons + 1] = { str = "", nosel = true, fsize = 2 }
	end
	return buttons
end

local function InitMenu()
	local menu = {
		main = {
			title = Mod.GetDSSStr("Title"),
			format = {
				Panels = {
					{
						Panel = dssmod.panels.main,
						Offset = Vector(-42, 10),
						Color = 1,
					},
					{
						Panel = dssmod.panels.tooltip,
						Offset = Vector(130, -2),
						Color = 1,
					},
				},
			},
			tooltip = Mod.GetDSSStr("startTooltip"),
		},
		unlocks = {
			title = Mod.GetDSSStr("unlock_manager"),
			buttons = {
				{
					str = Mod.GetDSSStr("unlocks"),
					dest = "unlocks_sub",
					tooltip = { strset = { Mod.GetDSSStr("unlocks") } },
				},
				{ str = "", nosel = true, fsize = 3 },
				{
					strset = Mod.SplitString(Mod.GetDSSStr("unlock"), 21),
					func = function(button, page, item)
						for _, ach in pairs(Mod.RepmAchivements) do
							Isaac.GetPersistentGameData():TryUnlock(ach.ID, true)
						end
						dssmod.closeMenu(item, false)
					end,
				},
				{ str = "", nosel = true, fsize = 3 },
				{
					strset = Mod.SplitString(Mod.GetDSSStr("lock"), 21),
					func = function(button, page, item)
						for _, ach in pairs(Mod.RepmAchivements) do
							Isaac.ExecuteCommand("lockachievement " .. ach.ID)
						end
						dssmod.closeMenu(item, false)
					end,
				},
			},
		},
		unlocks_sub = {
			title = Mod.GetDSSStr("unlocks"),
			buttons = InitUnlockButtons(),
		},
		music_manager = {
			title = Mod.GetDSSStr("music_manager"),
			buttons = {
				{ str = Mod.GetDSSStr("music_settings"), dest = "music_settings" },
				{ str = "", nosel = true, fsize = 2 },
				{ str = Mod.GetDSSStr("jingle_settings"), dest = "jingle_settings" },
				{ str = "", nosel = true, fsize = 2 },
				{
					strset = Mod.SplitString(Mod.GetDSSStr("enable_all_music"), 21),
					func = function(button, page, item)
						local music, jingle = Mod.GetModdedMusicTable()
						local musicData = Mod.GetModdedMusicData()
						for musicId, name in pairs(music) do
							musicData.Music[name] = 1
							Mod.ChangeFloorMusicTo(musicId, Isaac.GetMusicIdByName(name), true)
						end
						for jingleId, name in pairs(jingle) do
							musicData.Jingle[name] = 1
						end
						dssmod.closeMenu(item, false)
					end,
				},
				{ str = "", nosel = true, fsize = 2 },
				{
					strset = Mod.SplitString(Mod.GetDSSStr("disable_all_music"), 21),
					func = function(button, page, item)
						local music, jingle = Mod.GetModdedMusicTable()
						local musicData = Mod.GetModdedMusicData()
						for musicId, name in pairs(music) do
							musicData.Music[name] = 2
							Mod.ChangeFloorMusicTo(musicId, Isaac.GetMusicIdByName(name), false)
						end
						for jingleId, name in pairs(jingle) do
							musicData.Jingle[name] = 2
						end
						dssmod.closeMenu(item, false)
					end,
				},
			},
			tooltip = { strset = { "manage music", "and jingles" } },
		},
		music_settings = {
			title = Mod.GetDSSStr("music_settings"),
			buttons = InitMusicSettings(),
		},
		jingle_settings = {
			title = Mod.GetDSSStr("jingle_settings"),
			buttons = InitJingleSettings(),
		},
		warpzone = {
			title = Mod.GetDSSStr("settings"),
			buttons = {
				dssmod.gamepadToggleButton,
				dssmod.menuKeybindButton,
			},
		},
	}

	local buttons = {
		
			{ str = Mod.GetDSSStr("resume_game"), action = "resume" },
			{ str = "", nosel = true, fsize = 3 },
			{ str = Mod.GetDSSStr("music_manager"), dest = "music_manager" },
			{ str = "", nosel = true, fsize = 3 },
			{ str = Mod.GetDSSStr("unlocks"), dest = "unlocks" },
			{ str = "", nosel = true, fsize = 3 },
			{
				str = Mod.GetDSSStr("happy_start"),
				choices = { Mod.GetDSSStr("tu_var1"), Mod.GetDSSStr("tu_var2") },
				variable = "StartThumbsUp",
				setting = 1,
				load = function()
					return Mod:GetDefaultFileSave("StartThumbsUp") or 1
				end,
				store = function(var)
					Mod:AddDefaultFileSave("StartThumbsUp", var)
				end,
			},
			{ str = "", nosel = true, fsize = 3 },
		
	}
	if SoundtrackSongList then
		table.remove(buttons, 3)
		table.remove(buttons, 3)
		menu["music_manager"] = nil
		menu["music_settings"] = nil
		menu["jingle_settings"] = nil
	end

	menu.main.buttons = buttons

	return menu
end

Mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()

	Mod.DSSdirectory = InitMenu()

	local RepMdirectorykey = {
		Item = Mod.DSSdirectory.main,
		Main = "main",
		Idle = false,
		MaskAlpha = 1,
		Settings = {},
		SettingsChanged = false,
		Path = {},
	}

	DeadSeaScrollsMenu.AddMenu("rep-", {
		Run = dssmod.runMenu,
		Open = dssmod.openMenu,
		Close = dssmod.closeMenu,
		Directory = Mod.DSSdirectory,
		DirectoryKey = RepMdirectorykey,
		UseSubMenu = true,
	})
end)