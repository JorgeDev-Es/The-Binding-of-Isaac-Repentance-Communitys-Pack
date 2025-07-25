local HDCmod = RegisterMod("Hanging Dream Catcher", 1)
local game = Game()

local function SpawnHanger(Pos)
	Isaac.Spawn(1000, 245, 0, Pos, Vector(0,0), nil)
end

local function checkCatcher()
	for PlrCount = 0, game:GetNumPlayers() do -- Check all players collections and find the Dream Catcher.
		local plr = Isaac.GetPlayer(PlrCount)
		if plr:HasCollectible(566) then
			return true
		end
	end
end

local function onClear() -- On clearing a room, check if the room is a boss room and spawn a hanger if it is.
	if checkCatcher() then
		local CurRoom = game:GetRoom()
		local CurLevel = game:GetLevel()
		local CurStage = CurLevel:GetStage()
		if CurStage == 8 or CurStage >= 10 then -- Do not spawn hanger IF: you beat anything further than cathedral/sheol
			return
		end
		local RoomType = CurRoom:GetType()
		if RoomType == 5 and CurRoom:IsCurrentRoomLastBoss() then 
				SpawnHanger(CurRoom:GetCenterPos())
				HangerSpawned = true
			end
		end
	end

local function onTrapSpawn() -- When using Ehwaz or We Need To Go Deeper!
	if checkCatcher() then
		local CurRoom = game:GetRoom()
		for PlrCount = 0, game:GetNumPlayers() do
			local plr = Isaac.GetPlayer(PlrCount)
			local GridEnt = CurRoom:GetGridEntityFromPos(plr.Position) -- Check the entity underneath the player's feet at the time of using Shovel or Ehwaz
			if GridEnt ~= nil then
				if checkCatcher() and GridEnt:GetType() == 17 then -- Spawn the hanger if the entity under you is a trapdoor and if a player has the Dream Catcher
					SpawnHanger(GridEnt.Position)
				end
			end
		end
	end
end

local function onBarren() -- Spawn a hanger in Isaac's Dirty Bedroom
	-- 19 = dirty room enum	
	if checkCatcher() then
		local CurRoom = game:GetRoom()
		if CurRoom:GetType() == 19 then
			SpawnHanger(CurRoom:GetCenterPos())
		end
	end
end

local function greedTrapdoor() -- Spawn a hanger in the exit room of Greed Mode
	-- 23 = Greed-mode exit room enum
	if checkCatcher() and game:IsGreedMode() then
		local CurRoom = game:GetRoom()
		if CurRoom:GetType() == 23 then
			SpawnHanger(CurRoom:GetCenterPos())
		end
	end
end

local function altPathTrapdoor() -- Spawn a Hanger in the rooms leading to alt-floors.
	if checkCatcher() then
		local CurStage = game:GetLevel():GetStage()
		local CurRoom = game:GetRoom()
		if CurStage ~= 8 or CurStage <= 10 then
			if CurRoom:GetType() == 27 then
					SpawnHanger(CurRoom:GetCenterPos())
			end
		end
	end
end	

local function onIAMERROR() -- Spawn a Hanger in I AM ERROR Rooms.
	-- 3 = I AM ERROR room enum value
	if checkCatcher() then
		local CurRoom = game:GetRoom()
			if CurRoom:GetType() == 3 then
				SpawnHanger(CurRoom:GetCenterPos())
		end
	end
end	

local function postClear() -- Spawn a hanger on eligible cleared rooms
	if checkCatcher() then
		local CurLevel = game:GetLevel()
		local CurStage = CurLevel:GetStage()
		local CurRoom = CurLevel:GetCurrentRoom()
		if CurRoom:IsClear() then
			if CurStage ~= 8 or CurStage >= 10 then
				if CurRoom:GetType() == 5 and CurRoom:IsCurrentRoomLastBoss() then
					SpawnHanger(CurRoom:GetCenterPos())
					return
				end
			end
		end
	end
end

local function Debug()
	-- Debugging commands
	-- game:GetHUD():ShowItemText(tostring(HangerSpawned), "Hanger Spawned")
end

HDCmod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onClear)
HDCmod:AddCallback(ModCallbacks.MC_USE_ITEM, onTrapSpawn)
HDCmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onBarren)
HDCmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onIAMERROR)
HDCmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, greedTrapdoor)
HDCmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, altPathTrapdoor)
HDCmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postClear)
--HDCmod:AddCallback(ModCallbacks.MC_POST_RENDER, Debug)