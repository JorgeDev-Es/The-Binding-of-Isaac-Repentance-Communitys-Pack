local mod = RegisterMod("Greed Mode Improved Rep", 1)
local game = Game()
local json = require("json")

local settings = {
  ["Ultra Greed/Greedier HP Nerf"] = false, --Reduces the HP of Ultra Greed and Ultra Greedier from 3500 and 2500 to 2500 and 2000, respectively.
  ["Greed Gaper HP Nerf"] = false, --Reduces the HP of Greed Gapers from 9 to 6.
  ["No Machines"] = false, --Replaces Greed Donation Machines found in shops and secret rooms with regular slot machines.
}

local function saveProgress()
  mod:SaveData(json.encode(settings))
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
  if mod:HasData() then
	settings = json.decode(mod:LoadData())
  end
end)

mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function(_, t, v)
  local level = game:GetLevel()
  if settings["No Machines"] and level:GetStage() ~= 7 and game:IsGreedMode() then
	if t == 6 and v == 11 then
	  return {6, 1, 0}
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
  if npc.Type == 299 and settings["Greed Gaper HP Nerf"] then
	npc.HitPoints = 6
	npc.MaxHitPoints = 6
  end
  if settings["Ultra Greed/Greedier HP Nerf"] and npc.Type == 406 then
	if npc.Variant == 0 then
	  npc.HitPoints = 2500
	  npc.MaxHitPoints = 2500
	elseif npc.Variant == 1 then
	  npc.HitPoints = 2000
	  npc.MaxHitPoints = 2000
	end
  end
end)

local function modConfigInit()
  if ModConfigMenu then
	local modName = "GM Improved"
	ModConfigMenu.UpdateCategory(modName, {
	  Info = {"Greed Mode Improved settings.",}
	})
	--Title
	ModConfigMenu.AddText(modName, "Settings", function() return "Greed Mode Improved" end)
	ModConfigMenu.AddSpace(modName, "Settings")
	-- Settings
	ModConfigMenu.AddSetting(modName, "Settings", 
	{
	  Type = ModConfigMenu.OptionType.BOOLEAN,
	  CurrentSetting = function()
		return settings["Ultra Greed/Greedier HP Nerf"]
	  end,
	  Display = function()
		local onOff = "Off"
		if settings["Ultra Greed/Greedier HP Nerf"] then
		  onOff = "On"
		end
		return "Ultra Greed/Greedier HP Nerf: " .. onOff
	  end,
	  OnChange = function(currentBool)
		settings["Ultra Greed/Greedier HP Nerf"] = currentBool
	  end,
	  Info = {"Reduces the HP of Ultra Greed and Ultra Greedier from 3500 and 2500 to 2500 and 2000, respectively."}
	})
	
	ModConfigMenu.AddSetting(modName, "Settings", 
	{
	  Type = ModConfigMenu.OptionType.BOOLEAN,
	  CurrentSetting = function()
		return settings["Greed Gaper HP Nerf"]
	  end,
	  Display = function()
		local onOff = "Off"
		if settings["Greed Gaper HP Nerf"] then
		  onOff = "On"
		end
		return "Greed Gaper HP Nerf: " .. onOff
	  end,
	  OnChange = function(currentBool)
		settings["Greed Gaper HP Nerf"] = currentBool
	  end,
	  Info = {"Reduces the HP of Greed Gapers from 9 to 6."}
	})
	
	ModConfigMenu.AddSetting(modName, "Settings", 
	{
	  Type = ModConfigMenu.OptionType.BOOLEAN,
	  CurrentSetting = function()
		return settings["No Machines"]
	  end,
	  Display = function()
		local onOff = "Off"
		if settings["No Machines"] then
		  onOff = "On"
		end
		return "No Greed Machines in Shop/Secret Rooms: " .. onOff
	  end,
	  OnChange = function(currentBool)
		settings["No Machines"] = currentBool
	  end,
	  Info = {"Replaces Greed Donation Machines found in shops and secret rooms with regular slot machines."}
	})
  end
end

local firstLoad = true
local function onUpdate()
  if firstLoad then
	modConfigInit()
	firstLoad = false
  end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
  saveProgress()
end)
