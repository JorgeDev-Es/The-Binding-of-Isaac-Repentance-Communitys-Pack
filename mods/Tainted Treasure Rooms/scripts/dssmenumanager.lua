local mod = TaintedTreasure
local game = Game()
local json = require("json")


local DSSModName = "Dead Sea Scrolls (Tainted Treasures)"

local DSSCoreVersion = 4

local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod:SaveData(json.encode(mod.savedata))
end

function MenuProvider.GetPaletteSetting()
    return mod:GetSaveData().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    mod:GetSaveData().MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    if not REPENTANCE then
        return mod:GetSaveData().HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
        mod:GetSaveData().HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    return mod:GetSaveData().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    mod:GetSaveData().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return mod:GetSaveData().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    mod:GetSaveData().MenuKeybind = var
end

function MenuProvider.GetMenusNotified()
    return mod:GetSaveData().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    mod:GetSaveData().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return mod:GetSaveData().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    mod:GetSaveData().MenusPoppedUp = var
end

local DSSInitializerFunction = include("scripts.ttmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

mod.savedata.config = mod.savedata.config or {}
if type(mod.savedata.config.TaintedBeggars) ~= "number" then
	mod.savedata.config.TaintedBeggars = 2
end
if type(mod.savedata.config.PurpleSparkle) ~= "number" then
	mod.savedata.config.PurpleSparkle = 2
end

local ttdirectory = {
    main = {
        title = 'tainted treasures',

        buttons = {
            {str = 'resume game', action = 'resume'},
            {str = 'settings', dest = 'settings'},
            dssmod.changelogsButton,
        },
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = 'settings',
        buttons = {
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
			dssmod.startPopupButton,
            {
                str = '',
                fsize = 2,
                nosel = true
            },
            {
                str = 'tainted beggars',

                choices = {'on', 'off'},
                setting = 2,

                variable = 'taintedbeggars',
                
                load = function()
                    return mod:GetSaveData().config.TaintedBeggars or 1
                end,

                store = function(var)
                    mod:GetSaveData().config.TaintedBeggars = var
                end,

                tooltip = {strset = {'tainted', 'beggars', 'can replace', 'normal', 'beggars', 'and drop', 'items with', 'a tainted', 'counterpart'}}
            },
			{
                str = 'purple sparkle',

                choices = {'on', 'off'},
                setting = 2,

                variable = 'purplesparkle',
                
                load = function()
                    return mod:GetSaveData().config.PurpleSparkle or 1
                end,

                store = function(var)
                    mod:GetSaveData().config.PurpleSparkle = var
                end,

                tooltip = {strset = {'items with', 'a tainted', 'counterpart', 'will glitter', 'with purple', 'sparkles on', 'the ground'}}
            },
        }
    }
}

local ttdirectorykey = {
    Item = ttdirectory.main,
    Main = 'main',
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("Tainted Treasures", {Run = dssmod.runMenu, Open = dssmod.openMenu, Close = dssmod.closeMenu, Directory = ttdirectory, DirectoryKey = ttdirectorykey})

DeadSeaScrollsMenu.AddPalettes({
    {
        Name = "tainted",
        {44, 42, 47}, -- Back
        {128, 89, 141}, -- Text
        {170, 141, 179}, -- Highlight Text
    },
	{
        Name = "bad onion",
        {169, 55, 45},
        {172, 111, 158},
		{225, 133, 125},
    },
	{
        Name = "lucky cat",
        {37, 36, 40},
        {159, 36, 66},
        {249, 0, 0},
    },
	{
        Name = "colored contacts",
        {127, 135, 165},
        {197, 147, 160},
        {229, 220, 189},
    },
	{
        Name = "wormwood",
        {37, 128, 17},
        {143, 225, 80},
        {217, 247, 192},
    },
	{
        Name = "bounce house",
        {182, 115, 44},
        {109, 139, 203},
        {193, 57, 59},
    },
})

function mod:IsSettingOn(setting)
	if setting == 1 then
		return true
	else
		return false
	end
end