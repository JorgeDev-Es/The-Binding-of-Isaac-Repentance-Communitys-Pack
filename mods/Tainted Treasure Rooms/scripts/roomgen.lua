local mod = TaintedTreasure
local rng = mod.RNG
local game = Game()

function mod:IsDeadEnd(roomidx, shape)
	local level = game:GetLevel()
	shape = shape or RoomShape.ROOMSHAPE_1x1
	local deadend = false
	local adjindex = mod.adjindexes[shape]
	local adjrooms = 0
	for i, entry in pairs(adjindex) do
		local oob = false
		for j, idx in pairs(mod.borderrooms[i]) do
			if idx == roomidx then
				oob = true
			end
		end
		if level:GetRoomByIdx(roomidx+entry).GridIndex ~= -1 and not oob then
			adjrooms = adjrooms+1
		end
	end
	if adjrooms == 1 then
		deadend = true
	end
	return deadend
end

function mod:GetDeadEnds(roomdesc)
	local level = game:GetLevel()
	local roomidx = roomdesc.SafeGridIndex
	local shape = roomdesc.Data.Shape
	local adjindex = mod.adjindexes[shape]
	local deadends = {}
	for i, entry in pairs(adjindex) do
		if level:GetRoomByIdx(roomidx).Data then
			local oob = false
			for j, idx in pairs(mod.borderrooms[i]) do
				for k, shapeidx in pairs(mod.shapeindexes[shape]) do
					if idx == roomidx+shapeidx then
						oob = true
					end
				end
			end
			if roomdesc.Data.Doors & (1 << i) > 0 and mod:IsDeadEnd(roomidx+adjindex[i]) and level:GetRoomByIdx(roomidx+adjindex[i]).GridIndex == -1 and not oob then
				table.insert(deadends, {Slot = i, GridIndex = roomidx+adjindex[i]})
			end
		end
	end
	
	if #deadends >= 1 then
		return deadends
	else
		return nil
	end
end

function mod:GetOppositeDoorSlot(slot)
	return mod.oppslots[slot]
end

function mod:UpdateRoomDisplayFlags(initroomdesc)
	local level = game:GetLevel()
	local roomdesc = level:GetRoomByIdx(initroomdesc.GridIndex) --Only roomdescriptors from level:GetRoomByIdx() are mutable
	local roomdata = roomdesc.Data
	if level:GetRoomByIdx(roomdesc.GridIndex).DisplayFlags then
		if level:GetRoomByIdx(roomdesc.GridIndex) ~= level:GetCurrentRoomDesc().GridIndex then
			if roomdata then 
				if level:GetStateFlag(LevelStateFlag.STATE_FULL_MAP_EFFECT) then
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_ICON
				elseif roomdata.Type ~= RoomType.ROOM_DEFAULT and roomdata.Type ~= RoomType.ROOM_SECRET and roomdata.Type ~= RoomType.ROOM_SUPERSECRET and roomdata.Type ~= RoomType.ROOM_ULTRASECRET and level:GetStateFlag(LevelStateFlag.STATE_COMPASS_EFFECT) then
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_ICON
				elseif roomdata and level:GetStateFlag(LevelStateFlag.STATE_BLUE_MAP_EFFECT) and (roomdata.Type == RoomType.ROOM_SECRET or roomdata.Type == RoomType.ROOM_SUPERSECRET) then
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_ICON
				elseif level:GetStateFlag(LevelStateFlag.STATE_MAP_EFFECT) then
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_BOX
				else
					roomdesc.DisplayFlags = RoomDescriptor.DISPLAY_NONE
				end
			end
		end
	end
end

function mod:UpdateLevelDisplayFlags()
	local level = game:GetLevel()
	for i = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(i-1)
		if roomdesc then
			mod:UpdateRoomDisplayFlags(roomdesc)
		end
	end
end

function mod:GenerateSpecialRoom(roomtype, minvariant, maxvariant, onnewlevel) --Roomtype must be provided as a string for goto use, enter nil to generate an ordinary room
	onnewlevel = onnewlevel or false
	local level = game:GetLevel()
	local hascurseofmaze = false
	local floordeadends = {}
	local roomvariants = {}
	local currentroomidx = level:GetCurrentRoomIndex()
	local currentroomvisitcount = level:GetRoomByIdx(currentroomidx).VisitedCount
	
	if onnewlevel then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			player:GetData().ResetPosition = player.Position
		end
	end
	
	if level:GetCurses() & LevelCurse.CURSE_OF_MAZE > 0 then
		level:RemoveCurses(LevelCurse.CURSE_OF_MAZE)
		hascurseofmaze = true
		mod.applyingcurseofmaze = true
	end
	
	for i = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(i-1)
		if roomdesc and roomdesc.Data.Type == RoomType.ROOM_DEFAULT and roomdesc.Data.Subtype ~= 34 then
		local deadends = mod:GetDeadEnds(roomdesc)
			if deadends and not (onnewlevel and roomdesc.GridIndex == currentroomidx) then
				for j, deadend in pairs(deadends) do
					table.insert(floordeadends, {Slot = deadend.Slot, GridIndex = deadend.GridIndex, roomidx = roomdesc.GridIndex, visitcount = roomdesc.VisitedCount})
				end
			end
		end
	end
	
	if not floordeadends[1] then
		return false
	end
	
	for i = minvariant, maxvariant do
		table.insert(roomvariants, i)
	end
	
	mod:Shuffle(roomvariants)
	mod:Shuffle(floordeadends)
	
	for i, roomvariant in pairs(roomvariants) do
		if roomtype then
			Isaac.ExecuteCommand("goto s."..roomtype.."."..roomvariant)
		else
			Isaac.ExecuteCommand("goto d."..roomvariant)
		end
		local data = level:GetRoomByIdx(-3,0).Data
		
		if data.Shape == RoomShape.ROOMSHAPE_1x1 then
			for i, entry in pairs(floordeadends) do
				local deadendslot = entry.Slot
				local deadendidx = entry.GridIndex
				local roomidx = entry.roomidx
				local visitcount = entry.visitcount
				local roomdesc = level:GetRoomByIdx(roomidx)
				if roomdesc.Data and level:GetRoomByIdx(roomdesc.GridIndex).GridIndex ~= -1 and mod:GetOppositeDoorSlot(deadendslot) and data.Doors & (1 << mod:GetOppositeDoorSlot(deadendslot)) > 0 then
						if level:MakeRedRoomDoor(roomidx, deadendslot) then
							local newroomdesc = level:GetRoomByIdx(deadendidx, 0)
							newroomdesc.Data = data
							newroomdesc.Flags = 0
							mod:scheduleForUpdate(function()
								SFXManager():Stop(SoundEffect.SOUND_UNLOCK00)
								game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
								if level:GetRoomByIdx(currentroomidx).VisitedCount ~= currentroomvisitcount then
									level:GetRoomByIdx(currentroomidx).VisitedCount = currentroomvisitcount-1
								end
								mod:UpdateRoomDisplayFlags(newroomdesc)
								level:UpdateVisibility()
								if onnewlevel then
									for i = 0, game:GetNumPlayers() - 1 do
										local player = Isaac.GetPlayer(i)
										player.Position = player:GetData().ResetPosition
									end
								end
							end, 0, ModCallbacks.MC_POST_RENDER)
							mod:scheduleForUpdate(function()
								if hascurseofmaze then
									level:AddCurse(LevelCurse.CURSE_OF_MAZE)
									mod.applyingcurseofmaze = false
								end
								if onnewlevel then
									for i = 0, game:GetNumPlayers() - 1 do --You have to do it twice or it doesn't look right, not sure why
										local player = Isaac.GetPlayer(i)
										player.Position = player:GetData().ResetPosition
									end
								end
								level:UpdateVisibility()
							end, 0, ModCallbacks.MC_POST_UPDATE)
						table.insert(mod.minimaprooms, newroomdesc.GridIndex)
						return newroomdesc
					end
				end
			end
		end
	end
	
	game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
	mod:scheduleForUpdate(function()
		if onnewlevel then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				player.Position = player:GetData().ResetPosition
			end
		end
	end, 0)
	return false
end

function mod:GenerateExtraRoom()
	local level = game:GetLevel()
	local floordeadends = {}
	local currentroomidx = level:GetCurrentRoomIndex()
	for j = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(j-1)
		if roomdesc then
			local deadends = mod:GetDeadEnds(roomdesc)
			if deadends and roomdesc.GridIndex ~= currentroomidx then
				for k, deadend in pairs(deadends) do
					table.insert(floordeadends, {Slot = deadend.Slot, GridIndex = deadend.GridIndex, roomidx = roomdesc.GridIndex, visitcount = roomdesc.VisitedCount})
				end
			end
		end
	end
	
	mod:Shuffle(floordeadends)
	
	for i, deadend in pairs(floordeadends) do
		local deadendslot = deadend.Slot
		local deadendidx = deadend.GridIndex
		local roomidx = deadend.roomidx
		local roomdesc = level:GetRoomByIdx(roomidx)
		if roomdesc.Data and roomdesc.Data.Type == RoomType.ROOM_DEFAULT and level:GetRoomByIdx(roomdesc.GridIndex).GridIndex ~= -1 then
			if level:MakeRedRoomDoor(roomidx, deadendslot) then
				local newroomdesc = level:GetRoomByIdx(deadendidx, 0)
				newroomdesc.Flags = 0
				mod:UpdateRoomDisplayFlags(newroomdesc)
				level:UpdateVisibility()
				table.insert(mod.minimaprooms, newroomdesc.GridIndex)
				return deadendidx
			end
		end
	end
end

function mod:InitializeRoomData(roomtype, minvariant, maxvariant, dataset)
	local level = game:GetLevel()
	local currentroomidx = level:GetCurrentRoomIndex()
	local currentroomvisitcount = level:GetRoomByIdx(currentroomidx).VisitedCount
	local hascurseofmaze = false
	
	if level:GetCurses() & LevelCurse.CURSE_OF_MAZE > 0 then
		level:RemoveCurses(LevelCurse.CURSE_OF_MAZE)
		hascurseofmaze = true
		mod.applyingcurseofmaze = true
	end
	
	for i = minvariant, maxvariant, 1 do
		if roomtype then
			Isaac.ExecuteCommand("goto s."..roomtype.."."..i)
			table.insert(dataset, level:GetRoomByIdx(-3,0).Data)
		else
			Isaac.ExecuteCommand("goto d."..i)
			table.insert(dataset, level:GetRoomByIdx(-3,0).Data)
		end
	end
	game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
	
	if level:GetRoomByIdx(currentroomidx).VisitedCount ~= currentroomvisitcount then
		level:GetRoomByIdx(currentroomidx).VisitedCount = currentroomvisitcount - 1
	end
	
	if hascurseofmaze then
		mod:scheduleForUpdate(function()
			level:AddCurse(LevelCurse.CURSE_OF_MAZE)
			mod.applyingcurseofmaze = false
		end, 0, ModCallbacks.MC_POST_UPDATE)
	end
end

--we can do this the easy way....
function mod:GenerateRoomFromLuarooms(dataset, onnewlevel)
	onnewlevel = onnewlevel or false
	local level = game:GetLevel()
	local floordeadends = {}
	local currentroomidx = level:GetCurrentRoomIndex()
	
	for i = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(i-1)
		if roomdesc and roomdesc.Data.Type == RoomType.ROOM_DEFAULT and roomdesc.Data.Subtype ~= 34 and roomdesc.Data.Subtype ~= 10 then --Subtype checks protect against generation off of Mirror or Mineshaft entrance rooms
		local deadends = mod:GetDeadEnds(roomdesc)
			if deadends and not (onnewlevel and roomdesc.GridIndex == currentroomidx) then
				for j, deadend in pairs(deadends) do
					table.insert(floordeadends, {Slot = deadend.Slot, GridIndex = deadend.GridIndex, roomidx = roomdesc.GridIndex, visitcount = roomdesc.VisitedCount})
				end
			end
		end
	end
	
	if not floordeadends[1] then
		return false
	end
	
	--for i, data in pairs(dataset) do
		--table.insert(setcopy, data)
	--end
	
	mod:Shuffle(floordeadends)
	
	for i, entry in pairs(floordeadends) do
		local deadendslot = entry.Slot
		local deadendidx = entry.GridIndex
		local roomidx = entry.roomidx
		local visitcount = entry.visitcount
		local roomdesc = level:GetRoomByIdx(roomidx)
		if roomdesc.Data and level:GetRoomByIdx(roomdesc.GridIndex).GridIndex ~= -1 and mod:GetOppositeDoorSlot(deadendslot) then
			if level:MakeRedRoomDoor(roomidx, deadendslot) then
				local newroomdesc = level:GetRoomByIdx(deadendidx, 0)
				newroomdesc.Data = data
				local data = StageAPI.GetGotoDataForTypeShape(RoomType.ROOM_DICE, RoomShape.ROOMSHAPE_1x1)

				newroomdesc.Data = data
				local luaroom = StageAPI.LevelRoom{
					RoomType = RoomType.ROOM_DEFAULT,
					RequireRoomType = false,
					RoomsList = dataset,
					RoomDescriptor = newroomdesc
				}
				StageAPI.SetLevelRoom(luaroom, newroomdesc.ListIndex)
				newroomdesc.Flags = 0
				mod:UpdateRoomDisplayFlags(newroomdesc)
				level:UpdateVisibility()
				table.insert(mod.minimaprooms, newroomdesc.GridIndex)
				return newroomdesc
			end
		end
	end
end

--or the hard way.
function mod:GenerateRoomFromDataset(dataset, onnewlevel)
	onnewlevel = onnewlevel or false
	local level = game:GetLevel()
	local floordeadends = {}
	local setcopy = dataset
	local currentroomidx = level:GetCurrentRoomIndex()
	
	for i = level:GetRooms().Size, 0, -1 do
		local roomdesc = level:GetRooms():Get(i-1)
		if roomdesc and roomdesc.Data.Type == RoomType.ROOM_DEFAULT and roomdesc.Data.Subtype ~= 34 and roomdesc.Data.Subtype ~= 10 then --Subtype checks protect against generation off of Mirror or Mineshaft entrance rooms
		local deadends = mod:GetDeadEnds(roomdesc)
			if deadends and not (onnewlevel and roomdesc.GridIndex == currentroomidx) then
				for j, deadend in pairs(deadends) do
					table.insert(floordeadends, {Slot = deadend.Slot, GridIndex = deadend.GridIndex, roomidx = roomdesc.GridIndex, visitcount = roomdesc.VisitedCount})
				end
			end
		end
	end
	
	if not floordeadends[1] then
		return false
	end
	
	--for i, data in pairs(dataset) do
		--table.insert(setcopy, data)
	--end
	
	mod:Shuffle(floordeadends)
	mod:Shuffle(setcopy)
	
	for i, data in pairs(setcopy) do
		if data.Shape == RoomShape.ROOMSHAPE_1x1 then
			for i, entry in pairs(floordeadends) do
				local deadendslot = entry.Slot
				local deadendidx = entry.GridIndex
				local roomidx = entry.roomidx
				local visitcount = entry.visitcount
				local roomdesc = level:GetRoomByIdx(roomidx)
				if roomdesc.Data and level:GetRoomByIdx(roomdesc.GridIndex).GridIndex ~= -1 and mod:GetOppositeDoorSlot(deadendslot) and data.Doors & (1 << mod:GetOppositeDoorSlot(deadendslot)) > 0 then
					if level:MakeRedRoomDoor(roomidx, deadendslot) then
						local newroomdesc = level:GetRoomByIdx(deadendidx, 0)
						newroomdesc.Data = data
						newroomdesc.Flags = 0
						mod:UpdateRoomDisplayFlags(newroomdesc)
						level:UpdateVisibility()
						table.insert(mod.minimaprooms, newroomdesc.GridIndex)
						return newroomdesc
					end
				end
			end
		end
	end
end