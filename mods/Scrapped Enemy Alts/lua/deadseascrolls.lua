local mod = ScrapEnemyAlts

local DSSModName = "Dead Sea Scrolls (Scrapped Enemy Alts)"

local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod.storeSaveData()
end

function MenuProvider.GetPaletteSetting()
    return mod.getSaveData().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    mod.getSaveData().MenuPalette = var
end

function MenuProvider.GetGamepadToggleSetting()
    return mod.getSaveData().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    mod.getSaveData().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return mod.getSaveData().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    mod.getSaveData().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return mod.getSaveData().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    mod.getSaveData().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return mod.getSaveData().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    mod.getSaveData().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return mod.getSaveData().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    mod.getSaveData().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return mod.getSaveData().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    mod.getSaveData().MenusPoppedUp = var
end

local dssmenucore = include("lua.dssmenucore")

local dssmod = dssmenucore.init(DSSModName, MenuProvider)

local seadir = {
    main = {
        title = 'scrapped enemy alts',
        buttons = {
            { str = 'resume game', action = 'resume' },
            { str = 'settings',    dest = 'settings' },
        },
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = 'settings',
        buttons = {
            {
                str = 'monster sprites',
                choices = { 'vanilla', 'gapery gapers', 'flash pooters', 'vees resprites', 'last judgement' },
                setting = 1,
                variable = 'mod.spriteOption',
                load = function()
                    return mod.spriteOption or 1
                end,
                store = function(var)
                    mod.spriteOption = var
                end,
                tooltip = { strset = { 'some options', 'will not work', 'on all', 'monsters' } }
            },
            {
                str = 'lump colors',
                choices = { 'yes', 'no' },
                setting = 2,
                variable = 'mod.lumpOption',
                load = function()
                    return mod.lumpOption or 2
                end,
                store = function(var)
                    mod.lumpOption = var
                end,
                tooltip = { strset = { 'should the', 'color of lumps', 'match the', 'floor?' } }
            },
        }
    }
}

local seakey = {
    Item = seadir.main,
    Main = 'main',
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("Scrapped Enemy Alts", {
    Run = dssmod.runMenu,
    Open = dssmod.openMenu,
    Close = dssmod.closeMenu,
    UseSubMenu = false,
    Directory = seadir,
    DirectoryKey = seakey
})