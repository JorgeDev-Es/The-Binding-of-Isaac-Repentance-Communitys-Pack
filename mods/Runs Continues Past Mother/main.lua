MotherContinue = RegisterMod("Runs Continue Past Mother", 1)

REP_PLUS = FontRenderSettings ~= nil -- because Rep+ doesn't have a global like Rep does :)

-- KNOWN BUGS: The curtain drops when the timer runs out, even if the door's still there (and doesn't despawn)
-- KNOWN BUGS: It also doesn't lift if you e.g. pick up a strange key or use mama mega after killing mother.
-- KNOWN BUGS: Walking out of the blue woom uses a random door and takes you to a random place in the boss room.

local BlueWombDoorData = {
    BlueWombDoorTile = 7
}

-- Set to true to ignore the 35 minutes limit.
MotherContinue.IgnoreTimer = false
-- Internal boolean indicating if this is the first time the player has entered 
-- Mother's room.
--MotherContinue.FirstTimeEnterMotherRoom = true
-- Represents the additional timer in seconds before the door no longer opens, compared to the Womb II door.
MotherContinue.SpawnTimer = 5 * 60

-- FOR USE WITH STAGEAPI
BLUEWOMB = {
	NormalStage = true,
	Stage = LevelStage.STAGE4_3,
	StageType = StageType.STAGETYPE_ORIGINAL
}
SHEOL = {
	NormalStage = true,
	Stage = LevelStage.STAGE5,
	StageType = StageType.STAGETYPE_ORIGINAL
}
VOID = {
	NormalStage = true,
	Stage = LevelStage.STAGE7,
	StageType = StageType.STAGETYPE_ORIGINAL
}

-- Check if the current level is Corpse / Mortis XL / II
local function IsOkayCorpseFloor()
    local level = Game():GetLevel()
    local stage, stageType = level:GetStage(), level:GetStageType()
    if StageAPI then
        local currentstage = StageAPI.GetCurrentStage()
        if currentstage and currentstage.LevelgenStage then
            stage, stageType = currentstage.LevelgenStage.Stage, currentstage.LevelgenStage.StageType
        end
    end

    -- Either Corpse II, Mortis II, or Corpse / Mortis XL
    return (stage == LevelStage.STAGE4_2 or -- (Second floor, fourth chapter OR
       (level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 and stage == LevelStage.STAGE4_1)) and -- First Floor, fourth chapter, XL) AND
       (stageType == StageType.STAGETYPE_REPENTANCE or -- Antibirth OR
       stageType == StageType.STAGETYPE_REPENTANCE_B) -- Repentance
end

-- Check if the current room is Mother's room.
local function IsMotherBossRoom()
    local room = Game():GetRoom()
	return room:GetType() == RoomType.ROOM_BOSS and Game():GetLevel():GetCurrentRoomIndex() == GridRooms.ROOM_SECRET_EXIT_IDX and IsOkayCorpseFloor()
end

function MotherContinue:whenMotherDies()
	if not IsMotherBossRoom() then return end
	if Game():GetRoom():GetGridEntity(66) and Game():GetRoom():GetGridEntity(66):GetType() == GridEntityType.GRID_TRAPDOOR then return end
	MotherContinue.UnfortunateDelay = 10
	MotherContinue.CurtainLift = 0
end

-- Return the blue womb door grid entity
local function GetBlueWombDoorTile()
    local currentRoom = Game():GetRoom()
    return currentRoom:GetGridEntity(BlueWombDoorData.BlueWombDoorTile)
end

-- Returns a random vector, for use in pretty pretty dust spawning
local function GetRandomDustVector()
	local x = (Random() / 2^32) * 60 - 30 -- there's got to be a better way
	local y = (Random() / 2^32) * 40 - 20 -- but it's random (-20, 20)
	return Vector(x,y)
end

-- Spawns a dust effect similar to the vanilla blue womb door.
local function SpawnBlueWombDoorDust()
	if not MotherContinue.BlueWombHasSpawnedDust then
		for i=1,4 do
			local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, Game():GetRoom():GetGridPosition(7) + GetRandomDustVector(), Vector.Zero, nil)
			dust:ToEffect().Timeout = 20 -- I honestly have no idea what these two do
			dust:ToEffect().LifeSpan = 20 -- but if you put them together it works somehow
			dust:GetSprite().Scale = Vector(1,1)
		end
		MotherContinue.BlueWombHasSpawnedDust = true
	end
end

-- Spawn the blue womb door at its selected position
local function SpawnBlueWombDoor()
    local door = GetBlueWombDoorTile()
    
    if not door then
        Isaac.ConsoleOutput("[ERROR] Unable to get tile to spawn Blue Womb door\n")
        return
    end
    
    door:GetSprite():Load("gfx/grid/door_29_doortobluewomb.anm2", false)
	local color = Color.Default
	color:SetColorize(0,5,5,0.5)
	door:GetSprite().Color = color
	door:GetSprite():LoadGraphics()
    door:GetSprite():SetFrame("Opened", 0)
	door:GetSprite().Offset = Vector(0, 12)
    door.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
end

-- Teleport the player to the Blue Womb Room if close enough to the door.
local function TryGoToBlueWombRoom(player)
    if not IsMotherBossRoom() then return end

    local door = GetBlueWombDoorTile()
    
    if not door then
        Isaac.ConsoleOutput("[ERROR] Unable to get tile to spawn Blue Womb door\n")
        return
    end
    
    --local vect = player.Position - door.Position
    --local dist = vect.X ^ 2 + vect.Y ^ 2
    
    --if dist < (10 ^ 2) then
	if player.Position.Y < 125 then
		Game():GetLevel().LeaveDoor = DoorSlot.UP0
        Game():StartRoomTransition(GridRooms.ROOM_BLUE_WOOM_IDX, Direction.UP)
    end
end

-- Check if the current room is the blue womb room.
local function IsBlueWombRoom()
    local roomIdx = Game():GetLevel():GetCurrentRoomIndex()
    return roomIdx == GridRooms.ROOM_BLUE_WOOM_IDX
end

-- Spawns the trapdoor in the blue womb room.
function MotherContinue:onEnterBlueWombRoom()
    if not IsOkayCorpseFloor() or not IsBlueWombRoom() then
        return
    end
	local room = Game():GetRoom()
    
	for doorslot=0,3 do
		local door = room:GetDoor(doorslot)
		if door then
			door.TargetRoomIndex = GridRooms.ROOM_SECRET_EXIT_IDX -- mother boss room
			if StageAPI and StageAPI.InOverriddenStage() then
				for layer=0,5 do
					door:GetSprite():ReplaceSpritesheet(layer,'gfx/grid/door_29_doortobluewomb_blue.png')
				end
				local color = Color.Default
				color:SetColorize(0,5,5,0.5)
				door:GetSprite().Color = color
				door:GetSprite():LoadGraphics()
			end
		end
	end
	
    -- Hardcoded 67 because it is the middle of the room
	local entity = room:GetGridEntity(67)
	if not StageAPI or not StageAPI.InOverriddenStage() then
		if entity and entity:GetType() == GridEntityType.GRID_TRAPDOOR then return
		else room:SpawnGridEntity(67, GridEntityType.GRID_TRAPDOOR, 0, 1, 0) end
	else
		-- Have to do a StageAPI special
		-- Spawn it every time you enter, because it requires it.
		if entity then room:RemoveGridEntity(67,0,false) end -- don't want an overlap
		local squish = StageAPI.SpawnCustomTrapdoor(room:GetGridPosition(67), BLUEWOMB, "gfx/grid/Door_11_Wombhole.anm2")
		squish:GetSprite():ReplaceSpritesheet(0,'gfx/grid/door_11_wombhole_blue.png')
		squish:GetSprite():LoadGraphics()
    end
end

-- Check the conditions for the spawning of the door to the blue womb. This includes 
-- the timer (can be ignored) and the Strange Key.
local function CheckBlueWombDoorSpawnConditions()
    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        if player:HasTrinket(TrinketType.TRINKET_STRANGE_KEY) then
            return true
        end
    end
    
    -- Because time can be changed... FUCK YOU NICALIS.
    if (Game().TimeCounter <= Game().BlueWombParTime + 30 * MotherContinue.SpawnTimer) or MotherContinue.IgnoreTimer then
        return true
    end
    
    return false
end

-- Forcibly spawn the door to the blue womb if the player has used Mama Mega 
-- previously. Note that this only applies if the player used Mama Mega BEFORE
-- entering the boss fight.
function MotherContinue:onEnterMotherBossRoom()
    if not IsMotherBossRoom() then return end
	if Isaac.GetChallenge() ~= 0 then return end
	
    if Game():GetLevel():GetStateFlag(LevelStateFlag.STATE_MAMA_MEGA_USED)
       and Game():GetLevel():GetCurrentRoomDesc().Flags & RoomDescriptor.FLAG_MAMA_MEGA == 0 then
		--[[
        -- Mama Mega spawns the door only the first time. Note that the player
        -- may have managed to exit the boss room, then used Mama Mega, so the 
        -- boolean is switched only if the use flag for Mama Mega has been set.
        if not MotherContinue.FirstTimeEnterMotherRoom then
            return
        end
        
        -- Only switch boolean to false if Mama Mega is used. In Womb II, Mama Mega
        -- can be used at any point in time to open the door, same thing here.
        -- HOWEVER, if the door is forcibly opened with Mama Mega, it will remain 
        -- open only while the player is in the boss room.
        MotherContinue.FirstTimeEnterMotherRoom = false
		]]
		
		-- Mama Mega will trigger, so open the door!
        SpawnBlueWombDoor()
		SpawnBlueWombDoorDust()
    end
	
	if Isaac.CountBosses() > 0 then return end
	
	if CheckBlueWombDoorSpawnConditions() then
		SpawnBlueWombDoor()
		SpawnBlueWombDoorDust()
	end
	
	if REP_PLUS then
		-- We need to fix a vanilla issue, that makes the void portal inaccessible.
		local room = Game():GetRoom()
		--for i=151,223,1 do -- this is the 'accurate' way, but looks goofy since Isaac can move almost entirely off-screen
		for i=151,208,1 do -- this is WRONG but looks better
			if i%15~=0 and i%15~=14 and i~=172 then
				-- not a 'real' wall, nor the void portal
				-- so GET YE GONE
				room:RemoveGridEntity(i,0,false)
			end
		end
	end
	
	if not StageAPI or not StageAPI.InOverriddenStage() then return end
	-- So it's a beaten Mother room, in a situation you need to StageAPI the stuff back up.
	StageAPI.SpawnCustomTrapdoor(Game():GetRoom():GetGridPosition(66), SHEOL)
	
	local rng = RNG()
	rng:SetSeed(Game():GetSeeds():GetStartSeed(),35)
	if not REP_PLUS and rng:RandomInt(2) == 0 then
		StageAPI.SpawnCustomTrapdoor(Game():GetRoom():GetGridPosition(123), VOID, "gfx/grid/VoidTrapdoor.anm2")
		-- I'm sorry, doc. I can't get a pulse.
	end
end

-- Returns whether or not you're currently in the blue womb entry room, on Corpse XL.
-- Because apparently Womb XL has an undefined default next floor, unlike Womb II? Dumb.
local function IsXLCorpseBlueWoom()
	local level = Game():GetLevel()
	return IsBlueWombRoom() and
	       (level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 and level:GetStage() == LevelStage.STAGE4_1) and
           (level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B)
end

function MotherContinue:everyUpdateGross()
	-- All challenges that reach Mother end there, so this mod does nothing
	if Isaac.GetChallenge() ~= 0 then return end
	
	-- mother's room type is considered 5 (boss) even though it's special
	-- you'd EXPECT level:IsAltStage() to say if it's corpse, but nooo, it considers Utero and Scarred Womb as alts too. Wanker.
	local room = Game():GetRoom()
	local level = Game():GetLevel()
	if IsMotherBossRoom() then
		local changes = false
		for num = 0, Game():GetNumPlayers()-1 do
			local player = Game():GetPlayer(num)
			if player:GetSprite():IsPlaying("Trapdoor") or player:GetSprite():IsPlaying("LightTravel") then
				Game():GetLevel():SetStage(LevelStage.STAGE4_2, StageType.STAGETYPE_ORIGINAL)
				changes = true
			else
                -- Probably not the best, this could cause the player to teleport 
                -- to the blue womb room, but I'm confident in the very small 
                -- distance I've chosen for the detection radius of the door to 
                -- avoid this problem.
                TryGoToBlueWombRoom(player)
            end
		end
		
		if MotherContinue.UnfortunateDelay ~= nil then
			if MotherContinue.UnfortunateDelay > 0 then
				MotherContinue.UnfortunateDelay = MotherContinue.UnfortunateDelay - 1
			elseif Isaac.CountBosses() > 0 then
				MotherContinue.UnfortunateDelay = nil
			else
				if not StageAPI or not StageAPI.InOverriddenStage() then
					room:SpawnGridEntity(66, GridEntityType.GRID_TRAPDOOR, 0, 0, 0)
				else
					-- Have to do a StageAPI special
					StageAPI.SpawnCustomTrapdoor(room:GetGridPosition(66), SHEOL)
				end
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR, 0, room:GetGridPosition(68), Vector.Zero, nil)
				MotherContinue.UnfortunateDelay = nil
				
				local rng = RNG()
				rng:SetSeed(Game():GetSeeds():GetStartSeed(),35)
				if not REP_PLUS and rng:RandomInt(2) == 0 then
					if not StageAPI or not StageAPI.InOverriddenStage() then
						room:SpawnGridEntity(123, GridEntityType.GRID_TRAPDOOR, 1, 0, 1) -- void portal
					else
						StageAPI.SpawnCustomTrapdoor(room:GetGridPosition(123), VOID, "gfx/grid/VoidTrapdoor.anm2")
						-- Too bad you can't recreate the pulse...
					end
				end
			end
		end
        
        -- For some weird reason not checking Isaac.CountBosses() causes the game 
        -- to spawn the door during the transition between Mother's phases. I guess 
        -- this is because technically we kill Mother before the game respawns 
        -- her, so... Yeah, let's check the amount of bosses to be sure.
        if Isaac.CountBosses() == 0 then
            if CheckBlueWombDoorSpawnConditions() then
                SpawnBlueWombDoor()
				SpawnBlueWombDoorDust()
				
				-- This code is VERY scary if it screws up, but the CountBosses probably makes it safe.
				if MotherContinue.CurtainLift then
					local curtains = Isaac.FindByType(EntityType.ENTITY_MOTHER)
					if #curtains > 0 then
						curtains[1].Position = curtains[1].Position - Vector(0, MotherContinue.CurtainLift)
						MotherContinue.CurtainLift = math.min(MotherContinue.CurtainLift + 5, 200)
					end
				end
            end
        end
	end
	
	if IsXLCorpseBlueWoom() then
		for num = 0, Game():GetNumPlayers()-1 do
			local player = Game():GetPlayer(num)
			if player:GetSprite():IsPlaying("Trapdoor") then
				Game():GetLevel():SetStage(LevelStage.STAGE4_3, StageType.STAGETYPE_ORIGINAL) -- blue womb
			end
		end
	end
end

function MotherContinue:unkillMausHeart()
	if Game():GetLevel():GetStage() == LevelStage.STAGE1_1 then -- new run
		Game():SetStateFlag(GameStateFlag.STATE_MAUSOLEUM_HEART_KILLED, false)
	end
end

-- Force open the door if the player uses Mama Mega inside the boss room. This can 
-- happen several times.
function MotherContinue:onMamaMegaUse(item, rng, player, useFlags, activeSlot, varData)
    if not IsMotherBossRoom() then return end
	if Isaac.GetChallenge() ~= 0 then return end
    
    SpawnBlueWombDoor()
	SpawnBlueWombDoorDust()
    return
end

--[[
-- Resets the boolean indicating if this is the first time the player has entered
-- Mother's room. Called every time the player changes stage (this resets the 
-- flag properly in case of a Victory Lap or if the player uses the D5 room / 
-- Forget Me Now)
function MotherContinue:resetFirstTimeMother()
    MotherContinue.FirstTimeEnterMotherRoom = true
end

-- Save data. This exports the FirstTimeEnterMotherRoom flag.
function MotherContinue:saveData()
    if self.FirstTimeEnterMotherRoom then
        self:SaveData("1")
    else
        self:SaveData("0")
    end
end

-- Load data. This restores the FirstTimeEnterMotherRoom flag.
function MotherContinue:onGameStart(continued)
    if not continued then
        self:RemoveData()
    elseif self:HasData() then
        local data = self:LoadData()
        if data == "1" then
            self.FirstTimeEnterMotherRoom = true
        else
            self.FirstTimeEnterMotherRoom = false
        end
    else -- only triggers in case of crashes
		self.FirstTimeEnterMotherRoom = true
	end
end
]]

-- Resets variables that reset per room.
function MotherContinue:resetCurtainDust()
	MotherContinue.BlueWombHasSpawnedDust = nil
	MotherContinue.CurtainLift = nil
end

-- Identifies if Delirium's about
function MotherContinue:setDeliPresence()
	if #Isaac.FindByType(EntityType.ENTITY_DELIRIUM) > 0 then MotherContinue.DeliHere = true
	else MotherContinue.DeliHere = nil end
end

-- Prevents Delirium from transforming into mother (instantly killing her)
function MotherContinue:blockDeliTransformation(npc)
	if MotherContinue.DeliHere then
		npc:Morph(EntityType.ENTITY_DELIRIUM, 0, 0, -1)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
end

MotherContinue:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, MotherContinue.whenMotherDies, EntityType.ENTITY_MOTHER)
MotherContinue:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, MotherContinue.whenMotherDies)
MotherContinue:AddCallback(ModCallbacks.MC_POST_UPDATE, MotherContinue.everyUpdateGross)
MotherContinue:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, MotherContinue.unkillMausHeart)

MotherContinue:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MotherContinue.onEnterBlueWombRoom)
MotherContinue:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MotherContinue.onEnterMotherBossRoom)
MotherContinue:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MotherContinue.resetCurtainDust)
MotherContinue:AddCallback(ModCallbacks.MC_USE_ITEM, MotherContinue.onMamaMegaUse, CollectibleType.COLLECTIBLE_MAMA_MEGA)
--MotherContinue:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, MotherContinue.resetFirstTimeMother)
--MotherContinue:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, MotherContinue.saveData)
--MotherContinue:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, MotherContinue.onGameStart)
MotherContinue:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MotherContinue.setDeliPresence)
MotherContinue:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MotherContinue.blockDeliTransformation, EntityType.ENTITY_MOTHER)