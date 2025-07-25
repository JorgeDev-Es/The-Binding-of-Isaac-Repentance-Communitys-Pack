CustomBombHUDIcons = RegisterMod("Dynamic Bomb HUD", 1)

include("dynamic_bomb_hud_scripts/HUDHelper/hud_helper")

include("dynamic_bomb_hud_scripts/stupidUtils")
--used to save options
CustomBombHUDIcons.saveManager = include("dynamic_bomb_hud_scripts.SaveManager.save_manager")
CustomBombHUDIcons.saveManager.Init(CustomBombHUDIcons)

include("dynamic_bomb_hud_scripts/configuration")
include("dynamic_bomb_hud_scripts/DBHUD_API")
include("dynamic_bomb_hud_scripts/DBHUD_main")

include("dynamic_bomb_hud_scripts/FFCompat")