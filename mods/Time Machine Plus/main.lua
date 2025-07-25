--TIME MACHINE PLUS--
TMplus = RegisterMod("timemachinePLUS", 1)
TMplus.version = 1.7

TMplus.game = Game()
local json = require("json")

TMplus.globalSlotIndex = {}
TMplus.cachedMods = {}

TMplus.options = {
	["minSpeed"] = 0, --Minimum speed
	["maxSpeed"] = 5, --Maximum speed
	["accSpeed"] = .05, --Acceleration
	["decSpeed"] = 1, --Deceleration
	["decWait"] = 15, --Deceleration wait time
	["slotStickiness"] = 50, --Stickiness
	["requireInput"] = true, --Require movement
	["neutralizeSpawns"] = true, --Prevent contact damage from enemies spawned by slots
}

TMplus.ModConfigInitialized = false --If you don't keep track of this it'll make another copy of all the procedurally generated config buttons every time you start a run

--CUSTOM COMMANDS--
print("Time Machine PLUS: for a list of commands, type TM+_Help")
function TMplus:commands(cmd, arg)
	if cmd == "TM+_ClearSave" then
		print("Clearing data and settings for this save file.")
		TMplus:RemoveData()
		TMplus.globalSlotIndex = {}
		TMplus.cachedMods = {}
		TMplus.options = {
			["minSpeed"] = 0, --Minimum speed
			["maxSpeed"] = 5, --Maximum speed
			["accSpeed"] = .05, --Acceleration
			["decSpeed"] = 1, --Deceleration
			["decWait"] = 15, --Deceleration wait time
			["slotStickiness"] = 50, --Stickiness
			["requireInput"] = true, --Require movement
			["neutralizeSpawns"] = true, --Prevent contact damage from enemies spawned by slots
		}
		if ModConfigMenu ~= nil then
			ModConfigMenu.RemoveCategory("Time Machine PLUS")
			TMplus:ModConfigMenuInit()
		end
		TMplus.ModConfigInitialized = false
		Isaac.RunCallback("TM+_REQUEST_COMPATIBILITY_DATA")
		TMplus.ModConfigInitialized = true
	elseif cmd == "TM+_FindByVariant" then
		local result = TMplus.globalSlotIndex[tonumber(arg)]
		if result then
			print("MACHINE FOUND")
			print("Name:", result[1])
			print("Variant:", arg)
			print("Mod of Origin:", result[3])
			print("Current Setting:", result[2])
		else
			print("No valid data on this Variant.")
		end
	elseif cmd == "TM+_FindByName" then
		for i in pairs(TMplus.globalSlotIndex) do
			local result = TMplus.globalSlotIndex[i]
			if result[1] == arg then
				print("MACHINE FOUND")
				print("Name:", result[1])
				print("Variant:", i)
				print("Mod of Origin:", result[3])
				print("Current Setting:", result[2])
				return
			end
		end
		print("No valid data linked to this Name.")
	elseif cmd == "TM+_Toggle" then
		local result = TMplus.globalSlotIndex[tonumber(arg)]
		if result then
			if result[2] then
				print("Disabling", result[1])
				TMplus.globalSlotIndex[tonumber(arg)][2] = false
			else
				print("Enabling", result[1])
				TMplus.globalSlotIndex[tonumber(arg)][2] = true
			end
		end
	elseif cmd == "TM+_Help" then
		print("TM+_ClearSave: Removes all stored data and settings for the current save file.")
		print("TM+_FindByVariant [VARIANT]: Retrieves stored information on a given machine based on its Variant.")
		print("TM+_FindByName [NAME]: Retrieves stored information on a given machine based on its Name.")
		print("TM+_Toggle [VARIANT}: Enables a machine if it's disabled, and vice versa.")
	end
end
TMplus:AddCallback(ModCallbacks.MC_EXECUTE_CMD, TMplus.commands)

--COMPATIBILITY LOADING--

local function needsLoad(modDisplayName, modVersion, TMPSlotIndex) --Called when a mod's compatibility data is loaded
	local versionNumber = tonumber(modVersion) --There's probably a reason why everyone stores their version number as a string instead of a number, but I've never figured it out
	for i in pairs(TMplus.cachedMods) do
		if TMplus.cachedMods[i][1] == modDisplayName then --If mod data is already stored
			if versionNumber > TMplus.cachedMods[i][2] then --If loaded data is newer than stored data, delete from global index all data from the previous version, then update stored version number for mod
				for j in pairs(TMplus.globalSlotIndex) do
					if TMplus.globalSlotIndex[j][3] == modDisplayName then
						TMplus.globalSlotIndex[j] = nil
					end
				end
				TMplus.cachedMods[i][2] = versionNumber
				return true --Load new data if old has been deleted
			end
			return false --Don't load if versions are equivalent; this allows preservation of user-defined toggles for machines
		end
	end
	local modCache = {modDisplayName, versionNumber} --If no data exists at all, give it a spot in the cache and load the new data
	table.insert(TMplus.cachedMods, modCache)
	return true
end

function TMplus:AddCompatibility(modDisplayName, modVersion, TMPSlotIndex) --This is what goes in all of the other mods' compatibility files (vanilla machines are loaded with the same process)
	if needsLoad(modDisplayName, modVersion, TMPSlotIndex) then
		for i in pairs(TMPSlotIndex) do
			TMPSlotIndex[i][3] = modDisplayName --Adds mod name to each modded item without needing to type it out 20 times
			TMplus.globalSlotIndex[i] = TMPSlotIndex[i] --Places modded machine data in global index
		end
	end
	if ModConfigMenu ~= nil and not TMplus.ModConfigInitialized then --Procedurally generates ModConfigMenu buttons for every machine
		TMplus:addConfigMenuItems(modDisplayName, TMPSlotIndex)
	end
end

--PERSISTENT DATA MANIPULATION--

function TMplus:saveConfigData() --Saves persistent data
	for i in pairs(TMplus.globalSlotIndex) do
		TMplus.globalSlotIndex[i][4] = i --Encoding and Decoding a Lua table compresses it to remove all nonexistent indexes (meaning a machine's place in the list no longer corresponds to its Variant), so we have to keep track of its pre-compressed position and then restore it on the other end
	end
	local save = { --https://www.youtube.com/watch?v=d1GoEUYesmg&t=47s
		["options"] = TMplus.options, 
		["cachedMods"] = TMplus.cachedMods, 
		["globalSlotIndex"] = TMplus.globalSlotIndex, 
	}
	TMplus:SaveData(json.encode(save))
end
TMplus:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, TMplus.saveConfigData) --Saves data whenever a run is exited

function TMplus:loadConfigData() --Loads persistent data
	if TMplus:HasData() then
		local unpackedSave = json.decode(TMplus:LoadData())
		local temp = unpackedSave["globalSlotIndex"] --Aforementioned decompression jank
		for i in pairs(temp) do
			TMplus.globalSlotIndex[temp[i][4]] = temp[i]
		end
		for i in pairs(TMplus.globalSlotIndex) do
			TMplus.globalSlotIndex[i][4] = nil
		end
		TMplus.cachedMods = unpackedSave["cachedMods"] --These two are chill
		TMplus.options = unpackedSave["options"]
	end
	Isaac.RunCallback("TM+_REQUEST_COMPATIBILITY_DATA") --Once saved data is loaded, bring in the fresh stuff
	TMplus.ModConfigInitialized = true
end
TMplus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, TMplus.loadConfigData) --Loads data whenever a run is started

--DATA MANIPULATION--

function TMplus:addConfigMenuItems(modDisplayName, TMPSlotIndex) --Procedurally generates ModConfigMenu buttons for every machine
	for i in pairs(TMPSlotIndex) do
		if TMplus.globalSlotIndex[i] ~= nil then
			ModConfigMenu.AddSetting("Time Machine PLUS", tostring(modDisplayName), --This already is a string but ModConfigMenu says otherwise
			{
				Type = ModConfigMenu.OptionType.BOOLEAN, 
				CurrentSetting = function()
					return TMplus.globalSlotIndex[i][2]
					end, 
				Display = function()
					return TMplus.globalSlotIndex[i][1] .. ": " .. (TMplus.globalSlotIndex[i][2] and "Enabled" or "Disabled")
					end, 
				OnChange = function(n)
					TMplus.globalSlotIndex[i][2] = n
					end, 
				Info = {"Enable/Disable this machine.", 
				}
			})
		end
	end
end

function TMplus:ModConfigMenuInit() --All the fixed ModConfigMenu buttons for general settings
	if ModConfigMenu == nil then
		return
	end
	ModConfigMenu.AddSetting("Time Machine PLUS", "General", 
	  {
		Type = ModConfigMenu.OptionType.SCROLL,
		CurrentSetting = function()
		  return TMplus.options["minSpeed"]
		end,
		Display = function()
		  return "Minimum Speed: $scroll" .. TMplus.options["minSpeed"]
		end,
		OnChange = function(n)
		  TMplus.options["minSpeed"] = n
		end,
		Info = { "The speed each player resets to. Recommend not changing.", 
		}
	  })
	ModConfigMenu.AddSetting("Time Machine PLUS", "General",
	{
		Type = ModConfigMenu.OptionType.SCROLL,
		CurrentSetting = function()
			return TMplus.options["maxSpeed"]
			end, 
		Display = function()
			return "Maximum Speed: $scroll" .. TMplus.options["maxSpeed"]
			end, 
		OnChange = function(n)
			TMplus.options["maxSpeed"] = n
			end,
		Info = {"The highest speed a player can reach.", 
		}
	})	
	ModConfigMenu.AddSetting("Time Machine PLUS", "General",
	{
		Type = ModConfigMenu.OptionType.SCROLL,
		CurrentSetting = function()
			return math.floor(TMplus.options["accSpeed"] * 100)
			end, 
		Display = function()
			return "Acceleration: $scroll" .. math.floor(TMplus.options["accSpeed"] * 100)
			end, 
		OnChange = function(n)
			TMplus.options["accSpeed"] = n / 100
			end,
		Info = {"The rate at which a player's speed increases.", 
		}
	})
	ModConfigMenu.AddSetting("Time Machine PLUS", "General",
	{
		Type = ModConfigMenu.OptionType.SCROLL,
		CurrentSetting = function()
			return math.floor(TMplus.options["decSpeed"] * 5)
			end, 
		Display = function()
			return "Deceleration: $scroll" .. math.floor(TMplus.options["decSpeed"] * 5)
			end, 
		OnChange = function(n)
			TMplus.options["decSpeed"] = n / 5
			end,
		Info = {"The rate at which a player's speed decreases.", 
		}
	})		
	ModConfigMenu.AddSetting("Time Machine PLUS", "General",
	{
		Type = ModConfigMenu.OptionType.SCROLL,
		CurrentSetting = function()
			return math.floor(TMplus.options["decWait"] / 3)
			end, 
		Display = function()
			return "Reset Delay: $scroll" .. math.floor(TMplus.options["decWait"] / 3)
			end, 
		OnChange = function(n)
			TMplus.options["decWait"] = n * 3
			end,
		Info = {"The time after breaking contact before speed begins to reset.", 
		}
	})	
	ModConfigMenu.AddSetting("Time Machine PLUS", "General",
	{
		Type = ModConfigMenu.OptionType.SCROLL,
		CurrentSetting = function()
			return math.floor(TMplus.options["slotStickiness"] / 10)
			end, 
		Display = function()
			return "Slot Stickiness: $scroll" .. math.floor(TMplus.options["slotStickiness"] / 10)
			end, 
		OnChange = function(n)
			TMplus.options["slotStickiness"] = n * 10
			end,
		Info = {"The force with which your movement is restricted when using a machine.", 
		}
	})
	ModConfigMenu.AddSetting("Time Machine PLUS", "General", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN, 
		CurrentSetting = function()
			return TMplus.options["requireInput"]
			end, 
		Display = function()
			return "Require Constant Input: " .. (TMplus.options["requireInput"] and "yes" or "no")
			end, 
		OnChange = function(n)
			TMplus.options["requireInput"] = n
			end, 
		Info = {"Whether a player must constantly input movement for the mod's effect to work.", 
		}
	})
	ModConfigMenu.AddSetting("Time Machine PLUS", "General", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN, 
		CurrentSetting = function()
			return TMplus.options["neutralizeSpawns"]
			end, 
		Display = function()
			return "Neutralize Spawned Enemies: " .. (TMplus.options["neutralizeSpawns"] and "yes" or "no")
			end, 
		OnChange = function(n)
			TMplus.options["neutralizeSpawns"] = n
			end, 
		Info = {"If enabled, enemies spawned by machines will not deal contact damage for a short time.", 
		}
	})
	ModConfigMenu.AddText("Time Machine PLUS", "General", "Configure individual machines")
	ModConfigMenu.AddText("Time Machine PLUS", "General", "by mod in their respective tabs!")
end

--THE ACTUAL MOD--

TMplus.totalPlayers = 1 --Default player-specific vars. Required because the first POST_UPDATE callback triggers before the first POST_PLAYER_INIT, which is what normally creates player-specific vars

TMplus.playerSpeedMult = {} 
TMplus.playerSpeedMult[0] = 0

TMplus.playerTouchTimer = {}
TMplus.playerTouchTimer[0] = 0

include("TM+_builtincompatibility") --Vanilla and built-in modded compatibility; uses almost exactly the same code as in the template

TMplus:ModConfigMenuInit() --Generates fixed ModConfigMenu settings

local function GetPlayerID(player) --We have REPENTOGON at home
	TMplus.totalPlayers = TMplus.game:GetNumPlayers()
	for i = 0, TMplus.totalPlayers - 1 do
		if player == TMplus.game:GetPlayer(i) then
			return i
		end
	end
	return 0
end

local function updatePlayers() --Assigns player-specific vars (clears everything first so the mod doesn't needlessly track vars for nonexistent Soul Stones, Strawmen etc)
	TMplus.playerSpeedMult = {}
	TMplus.playerTouchTimer = {}
	TMplus.totalPlayers = TMplus.game:GetNumPlayers()
	for i = 0, TMplus.totalPlayers - 1 do --"Player 1" is actually considered Player 0, and so on
		TMplus.playerSpeedMult[i] = 0
		TMplus.playerTouchTimer[i] = 0
	end
end
TMplus:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, updatePlayers) --Triggers updatePlayers whenever a new character is created
TMplus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, updatePlayers) --Triggers updatePlayers upon entering a new room (to check if Soul Stone characters have despawned)

function TMplus:timer() --Tracks how long a player has gone without touching a machine/beggar (the timer var is reset upon a successful collision in step)
	for i = 0, TMplus.totalPlayers - 1 do
		TMplus.playerTouchTimer[i] = math.min(TMplus.playerTouchTimer[i] + 1, TMplus.options["decWait"]) --Fancy version of the classic "if x<=y then x = x+1"
		if TMplus.playerTouchTimer[i] >= TMplus.options["decWait"] then --If player has waited for long enough, begin slowing time back down to normal
			TMplus.playerSpeedMult[i] = math.max(TMplus.options["minSpeed"], TMplus.playerSpeedMult[i] - TMplus.options["decSpeed"])
		end
	end
end
TMplus:AddCallback(ModCallbacks.MC_POST_UPDATE, TMplus.timer) --Triggers timer every game update (30 times / second)

local function checks(machine) --Performs various checks on "collider" passed by PRE_PLAYER_COLLISION
	if machine.Type ~= 6 then --Must be a Slot
		return false
	end
	if not TMplus.globalSlotIndex[machine.Variant] then --Must have valid data indexed
		return false
	end
	if not TMplus.globalSlotIndex[machine.Variant][2] then --Must be enabled
		return false
	end
	local data = machine:GetData()
	local frame = machine:GetSprite():GetFrame()
	if frame == data.previousFrame then --Must be on a different frame of its animation than the previous check. Essentially, this checks if the machine's current animation is 1 frame long.
		return false						--Since this check is run on collision, the machine won't be playing its Idle animation, so the only possible 1-frame animation is its "blown" or "death" animation.
	end	
	data.previousFrame = frame
	return true
end

local function applyStickiness(player, playernum, oldpos, oldvel) --Helps prevent player from slipping off of machines
	player:MultiplyFriction(1 / (TMplus.options["slotStickiness"] + 1)) --The +1 prevents a divide by 0 error if stickiness is turned off
	player.Position = oldpos --The player's old position and velocity are much more stable than the current values; you'd almost think game objects weren't supposed to update more than once a frame
	if player.Velocity:Length() > 5 then --If player is moving fast enough to clip through a machine
		player.Velocity = -.01 * oldvel:Normalized() --Sets player velocity to an extremely small force in the opposite direction to the original, preventing clipping through machines at high speed
	end
end 

function TMplus:step(player, machine, uhh) --The Big One
	if not TMplus.options["requireInput"] or (TMplus.options["requireInput"] and player.Velocity:Length() > .1) then
		playernum = GetPlayerID(player) --I miss her so much
		if checks(machine) then --If the collider entity passes a series of checks, defined above
			TMplus.playerTouchTimer[playernum] = 0 --Resets timer var for player currently touching machine/beggar
			local oldpos = player.Position --Stores current player position and velocity
			local oldvel = player.Velocity
			for i = 1, math.floor(TMplus.playerSpeedMult[playernum]-0.5+math.random()) do --This is pretty self-explanatory
				machine:Update()
				player:Update()
			end
			applyStickiness(player, playernum, oldpos, oldvel) --Moderates player velocity to prevent clippin' n' slippin'
			TMplus.playerSpeedMult[playernum] = math.min(TMplus.playerSpeedMult[playernum] + TMplus.options["accSpeed"], TMplus.options["maxSpeed"]) --Increases player speed
			Game().TimeCounter = Game().TimeCounter + math.max(0, math.floor(TMplus.playerSpeedMult[playernum] - 1)) --Quit having fun
		end
	end
end
TMplus:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, TMplus.step) --Triggers step whenever a player collides with something (it might be a machine, you never know)

function TMplus:neutralizeSpawns(player, amt, flags, spawnRef, frames) --Prevents contact damage from enemies recently spawned by machines, triggers when damage would be dealt
	if TMplus.playerSpeedMult[GetPlayerID(player)] > TMplus.options["minSpeed"] and TMplus.options["neutralizeSpawns"] then --Only works if enabled and machine is sped up
		local spawn = spawnRef.Entity
		local data = spawn:GetData()
		if data.spawnedBySlot == nil and spawn.FrameCount < 30 then --If the enemy has no data yet, and is less than 1 second old
			for _, near in pairs(Isaac.FindInRadius(spawn.Position, 5, 0xFFFFFFFF)) do --Searches nearby entities for a slot
				if near.Type == 6 then
					data.spawnedBySlot = true --If enemy is near a slot, say it has been spawned by it
				end
			end
		end
		if data.spawnedBySlot then --If enemy was spawned by slot, prevent damage and knock it away
			spawn:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
			return false
		end
	end
end
TMplus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, TMplus.neutralizeSpawns, 1) --Triggers neutralizeSpawns when a player would take damage