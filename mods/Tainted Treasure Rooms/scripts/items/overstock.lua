local mod = TaintedTreasure
local game = Game()

function mod:OverstockFloorLogic()
	local level = game:GetLevel()
	local currentroomidx = level:GetCurrentRoomIndex()
	local currentroomcenterpos = game:GetRoom():GetCenterPos()
	local currentroomvisitcount = level:GetRoomByIdx(currentroomidx).VisitedCount
	local keeperb = false
	
	for i = game:GetNumPlayers(), 1, -1 do
		if Isaac.GetPlayer(i-1):GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
			keeperb = true
		end
	end
	
	if not keeperb then
		if level:GetCurses() & LevelCurse.CURSE_OF_MAZE > 0 then
			level:RemoveCurses(LevelCurse.CURSE_OF_MAZE)
			hascurseofmaze = true
		end
		
		for i = level:GetRooms().Size, 0, -1 do
			local roomdesc = level:GetRooms():Get(i-1)
			if roomdesc and roomdesc.Data.Type == RoomType.ROOM_SHOP then
				Isaac.ExecuteCommand("goto s.shop."..mod:RandomInt(7, 12))
				local data = level:GetRoomByIdx(-3,0).Data
				
				level:GetRoomByIdx(roomdesc.GridIndex).Data = data
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
		
		if level:GetStage() == LevelStage.STAGE4_1 or level:GetStage() == LevelStage.STAGE4_2 then
			mod:GenerateSpecialRoom("shop", 7, 12, true)
		end
	else
		mod:GenerateSpecialRoom("shop", 7, 12, true)
	end
end