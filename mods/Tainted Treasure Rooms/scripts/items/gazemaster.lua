local mod = TaintedTreasure
local game = Game()

function mod:GazemasterFloorLogic()
	local level = game:GetLevel()
	local currentroomidx = level:GetCurrentRoomIndex()
	local currentroomcenterpos = game:GetRoom():GetCenterPos()
	local currentroomvisitcount = level:GetRoomByIdx(currentroomidx).VisitedCount
	
	if level:GetCurses() & LevelCurse.CURSE_OF_MAZE > 0 then
		level:RemoveCurses(LevelCurse.CURSE_OF_MAZE)
		hascurseofmaze = true
	end
	
	for i = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(i-1)
		if roomdesc then
			if roomdesc.Data.Type == RoomType.ROOM_SECRET then
				Isaac.ExecuteCommand("goto s.secret."..mod:RandomInt(13000, 13040))
				local data = level:GetRoomByIdx(-3,0).Data
				
				level:GetRoomByIdx(roomdesc.GridIndex).Data = data
			elseif roomdesc.Data.Type == RoomType.ROOM_SUPERSECRET then
				Isaac.ExecuteCommand("goto s.supersecret."..mod:RandomInt(13000, 13033))
				local data = level:GetRoomByIdx(-3,0).Data
				
				level:GetRoomByIdx(roomdesc.GridIndex).Data = data
			end
		end
	end
	
	mod:scheduleForUpdate(function()
		for i = game:GetNumPlayers(), 1, -1 do
			Isaac.GetPlayer(i-1).Position = Isaac.GetFreeNearPosition(currentroomcenterpos, 1)
		end
		
		if hascurseofmaze then
			level:AddCurse(LevelCurse.CURSE_OF_MAZE)
		end
	end, 0, ModCallbacks.MC_POST_UPDATE)
	
	mod:scheduleForUpdate(function()
		for i = game:GetNumPlayers(), 1, -1 do
			Isaac.GetPlayer(i-1).Position = Isaac.GetFreeNearPosition(currentroomcenterpos, 1)
		end
	end, 0, ModCallbacks.MC_POST_RENDER)
	
	level:GetRoomByIdx(currentroomidx).VisitedCount = currentroomvisitcount-1
	game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
end