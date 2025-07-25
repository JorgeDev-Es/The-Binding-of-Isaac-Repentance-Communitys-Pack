--
-- Generic and very straightforward data storage system used in the MenuProvider functions below
-- Use your own mod's functions for this if it has them! If not, however, feel free to copy this and
-- change the mod name.
--
local mod = MattPack
local SaveManager = mod.SaveManager

mod.menusavedata = mod.menusavedata or {}
SaveManager.AddCallback(mod.SaveManager.Utility.CustomCallback.POST_DATA_LOAD, function(_)
    mod.menusavedata = (SaveManager.GetDeadSeaScrollsSave() and SaveManager.GetDeadSeaScrollsSave().savedata) or {}
end)


function mod.GetSaveData()
    local dssSave = SaveManager.GetDeadSeaScrollsSave()
    if dssSave then
        mod.menusavedata = dssSave.savedata or {}
        return mod.menusavedata
    end
end

function mod.StoreSaveData()
    local dssSave = SaveManager.GetDeadSeaScrollsSave()
    dssSave.savedata = mod.menusavedata
end

--
-- End of generic data storage manager
--

--
-- MenuProvider
--

-- Change this variable to match your mod. The standard is "Dead Sea Scrolls (Mod Name)"
local DSSModName = "Lazy MattPack"

-- Every MenuProvider function below must have its own implementation in your mod, in order to
-- handle menu save data.
local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod.StoreSaveData()
end

function MenuProvider.GetPaletteSetting()
    return mod.GetSaveData().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    mod.GetSaveData().MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    if not REPENTANCE then
        return mod.GetSaveData().HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
        mod.GetSaveData().HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    return mod.GetSaveData().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    mod.GetSaveData().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return mod.GetSaveData().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    mod.GetSaveData().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return mod.GetSaveData().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    mod.GetSaveData().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return mod.GetSaveData().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    mod.GetSaveData().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return mod.GetSaveData().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    mod.GetSaveData().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return mod.GetSaveData().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    mod.GetSaveData().MenusPoppedUp = var
end

local dssmenucore = include("scripts.dssmenucore")

-- This function returns a table that some useful functions and defaults are stored on.
local dssmod = dssmenucore.init(DSSModName, MenuProvider)


-- Adding a Menu

-- Creating a menu like any other DSS menu is a simple process. You need a "Directory", which
-- defines all of the pages ("items") that can be accessed on your menu, and a "DirectoryKey", which
-- defines the state of the menu.
local exampledirectory = {
    main = {
        title = 'lazy mattpack',
        buttons = {
            { str = 'resume game', action = 'resume' },

            { str = 'settings',    dest = 'settings' },

            dssmod.changelogsButton,
        },
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = 'settings',
        buttons = {
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            { -- Item Pool Config
                str = 'itempool config',
                choices = { 'all items', 'non-q5', 'none' },
                setting = 2,
                variable = 'ItemPoolOption',
                load = function()
                    return SaveManager.GetSettingsSave().ItemPoolOption or 2
                end,
                store = function(var)
                    SaveManager.GetSettingsSave().ItemPoolOption = var
                    mod.updateSaveData()
                end,
                tooltip = { strset = { 'configure', 'what items', 'appear', 'naturally' } }
            },
            { -- EID Quality 5 Hints
                str = 'eid q5 hints',
                choices = { 'enabled', 'disabled' },
                setting = 1,
                variable = 'EIDQ5Hints',
                load = function()
                    return SaveManager.GetSettingsSave().EIDQ5Hints or 1
                end,
                store = function(var)
                    SaveManager.GetSettingsSave().EIDQ5Hints = var
                    mod.EIDHintsEnabled = (var == 1)
                    mod.updateSaveData()
                end,
                tooltip = { strset = { 'show hints', 'for what', 'items can be', 'transformed', 'into', 'quality 5s' } }
            },
            { -- Linger Bean Rework
                str = 'linger bean rework',
                choices = { 'enabled', 'disabled' },
                setting = 1,
                variable = 'LingerBeanReworkToggle',
                load = function()
                    return SaveManager.GetSettingsSave().LingerBeanReworkToggle or 1
                end,
                store = function(var)
                    SaveManager.GetSettingsSave().LingerBeanReworkToggle = var
                    mod.updateSaveData()
                end,
                tooltip = { strset = { 'toggle the', 'linger bean', 'rework' } }
            },

            {str="", nosel = true, fsize = 1},
            {str="balor", nosel = true, fsize = 2, color = Color(1,0,0,1)},
            { -- Balor Screenshake
            str = 'screenshake',
            choices = { 'off', 'reduced', 'intense'},
            setting = 2,
            variable = 'BalorScreenshake',
            load = function()
                return SaveManager.GetSettingsSave().BalorScreenshake or 2
            end,
            store = function(var)
                SaveManager.GetSettingsSave().BalorScreenshake = var
                mod.updateSaveData()
            end,
            tooltip = { strset = { 'configure', 'the strength', 'of the', 'screenshake', 'caused by', 'shooting with', 'balor' } }
            },
            
            {str="", nosel = true, fsize = 1},
            {str="divine heart", nosel = true, fsize = 2},
            { -- Sacred Heart 2 Resolution
            str = 'light beam quality',
            choices = { 'very low', 'low', 'medium', 'high'},
            setting = 3,
            variable = 'DivineHeartResolution',
            load = function()
                return SaveManager.GetSettingsSave().DivineHeartResolution or 3
            end,
            store = function(var)
                SaveManager.GetSettingsSave().DivineHeartResolution = var
                mod.updateSaveData()
            end,
            tooltip = { strset = { 'configure', 'the visual', 'quality of', 'the lasers', 'spawned by', 'divine heart' } }
            },
            
            {str="", nosel = true, fsize = 1},
            {str="boulder bottom", nosel = true, fsize = 2},
            { -- Boulder Bottom Blacklist
                str = 'bb blacklist',
                choices = { 'enabled', 'disabled' },
                setting = 1,
                variable = 'BoulderBottomBlacklist',
                load = function()
                    return SaveManager.GetSettingsSave().BoulderBottomBlacklist or 1
                end,
                store = function(var)
                    SaveManager.GetSettingsSave().BoulderBottomBlacklist = var
                    mod.updateSaveData()
                end,
                tooltip = { strset = { 'prevents', 'invincibility', 'effects from', 'being', 'permanent', "---", 'prone to', 'softlocks', 'when disabled!'}}
            },
        }
    },
    rgonpopup = {
		title = "lazy mattpack",
		fsize = 1,
		buttons = {
            {str = "repentogon required", nosel = true, fsize = 2},
            {str = "", nosel = true},
			{str = "sorry! the lazy mattpack", nosel = true},
			{str = "cannot run without repentogon", nosel = true},
			{str = "", nosel = true},
			{str = "this unfortunately means that it", nosel = true},
			{str = "is currently incompatible with", nosel = true},
			{str = "repentance+", nosel = true},
            {str = "", nosel = true},
			{str = "repentogon can be installed", nosel = true},
			{str = "at repentogon.com", nosel = true},
            {str = "", nosel = true},
			{
				str = "i understand",
				action = "resume",
				fsize = 3,
				glowcolor = 3,
			},
		},
	},

}

local exampledirectorykey = {
    Item = exampledirectory.main,
    Main = 'main',
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("Lazy MattPack", {
    Run = dssmod.runMenu,
    Open = dssmod.openMenu,
    Close = dssmod.closeMenu,
    UseSubMenu = false,
    Directory = exampledirectory,
    DirectoryKey = exampledirectorykey
})