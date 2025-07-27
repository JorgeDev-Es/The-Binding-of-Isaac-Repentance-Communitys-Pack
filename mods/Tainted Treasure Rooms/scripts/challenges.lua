local mod = TaintedTreasure
local rng = RNG()
local game = Game()

function mod:ArtOfWarFloorLogic()
	local level = game:GetLevel()
	local currentroomidx = level:GetCurrentRoomIndex()
	local currentroomvisitcount = level:GetRoomByIdx(currentroomidx).VisitedCount
	for i, player in pairs(mod:GetAllPlayers()) do
		if not player:HasCollectible(TaintedCollectibles.WAR_MAIDEN) then
			player:AddCollectible(TaintedCollectibles.WAR_MAIDEN)
		end
	end
	
	if level:GetStageType() ~= StageType.STAGETYPE_ORIGINAL then
		Isaac.ExecuteCommand("stage "..level:GetStage())
	else
		for i = level:GetRooms().Size, 0, -1 do
			local roomdesc = level:GetRooms():Get(i-1)
			if roomdesc and roomdesc.GridIndex and roomdesc.GridIndex ~= currentroomidx then
				mod:ArtOfWarReplaceRoomData(roomdesc)
			end
		end
		level:GetRoomByIdx(currentroomidx).VisitedCount = currentroomvisitcount-1
		game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
	end
end

function mod:ArtOfWarReplaceRoomData(roomdesc)
	local level = game:GetLevel()
	local roomvariants = {}
	for i = 13000, 13079 do
		table.insert(roomvariants, i)
	end
	mod:Shuffle(roomvariants)
	if roomdesc.Data and roomdesc.Data.Type == RoomType.ROOM_DEFAULT then
		for i, roomvariant in pairs(roomvariants) do
			Isaac.ExecuteCommand("goto d."..roomvariant)
			local data = level:GetRoomByIdx(-3,0).Data
			local valid = true
			for i, idx in pairs(mod.adjindexes[roomdesc.Data.Shape]) do
				if level:GetRoomByIdx(roomdesc.GridIndex+idx).GridIndex ~= -1 then
					if not (data.Doors & (1 << i) > 0) then
						valid = false
					end
				end
			end
			if roomdesc.Data.Shape ~= data.Shape then
				valid = false
			end
			if valid then
				level:GetRoomByIdx(roomdesc.GridIndex).Data = data
				return true
			end
		end
	elseif roomdesc.Data and roomdesc.Data.Type == RoomType.ROOM_BOSS then
		Isaac.ExecuteCommand("goto s.boss.1300"..(level:GetStage()-1))
		local data = level:GetRoomByIdx(-3,0).Data
		if roomdesc.Data.Shape == data.Shape then
			level:GetRoomByIdx(roomdesc.GridIndex).Data = data
		end
	end
end