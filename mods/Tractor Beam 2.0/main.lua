-- "Tractor Beam 2.0"
-- By Connor, aka Ghostbroster

local mod = RegisterMod("Tractor Beam 2.0", 1)

local game = Game()
local sfxManager = SFXManager()

local kZeroVector = Vector(0,0)
local kNormalVector = Vector(1,1)

local kNullColor = Color(1,1,1,1)
local kInvisible = Color(0,0,0,0)

-- These are the only TearFlags that the Tractor Beam laser is allowed to have.
local kTractorBeamAcceptableTearFlags =
		TearFlags.TEAR_SPECTRAL
		| TearFlags.TEAR_PIERCING
		| TearFlags.TEAR_HOMING
		-- Items
		| TearFlags.TEAR_BOOMERANG
		| TearFlags.TEAR_BOUNCE
		| TearFlags.TEAR_OCCULT
		| TearFlags.TEAR_ORBIT
		| TearFlags.TEAR_ORBIT_ADVANCED
		| TearFlags.TEAR_CONTINUUM
		-- Worms
		| TearFlags.TEAR_WIGGLE
		| TearFlags.TEAR_SPIRAL
		| TearFlags.TEAR_SQUARE
		| TearFlags.TEAR_BIG_SPIRAL
		| TearFlags.TEAR_TURN_HORIZONTAL

local kTearPathAffectingTearflags =
		TearFlags.TEAR_WIGGLE
		| TearFlags.TEAR_ORBIT
		| TearFlags.TEAR_ORBIT_ADVANCED
		| TearFlags.TEAR_SPIRAL
		| TearFlags.TEAR_SQUARE
		| TearFlags.TEAR_BIG_SPIRAL
		| TearFlags.TEAR_TURN_HORIZONTAL
		| TearFlags.TEAR_BOOMERANG

--------------------------------------------------
---- GENERAL UTILITIES
--------------------------------------------------

--Stolen from PROAPI
local function Lerp(first,second,percent)
	return (first + (second - first)*percent)
end

-- Returns a normalized vector in the given Direction.
local kUp = Vector(0, -1)
local kDown = Vector(0, 1)
local kLeft = Vector(-1, 0)
local kRight = Vector(1, 0)
local function DirectionToVector(direction)
	if direction == Direction.UP then
		return kUp
	elseif direction == Direction.DOWN then
		return kDown
	elseif direction == Direction.LEFT then
		return kLeft
	elseif direction == Direction.RIGHT then
		return kRight
	else
		return kZeroVector
	end
end

-- Returns the closest cardinal direction to a given vector.
local function VectorToDirection(vector)
	if vector:Length() == 0 then
		return Direction.NO_DIRECTION
	end
	
	local angle = vector:GetAngleDegrees()
	
	if angle > 135 or angle < -135 then
		return Direction.LEFT
	elseif angle <= -45 and angle >= -135 then
		return Direction.UP
	elseif angle > -45 and angle < 45 then
		return Direction.RIGHT
	elseif angle >= 45 and angle <= 135 then
		return Direction.DOWN
	end
	
	return Direction.NO_DIRECTION
end

-- Returns a table nested within another table.
-- `GetSubTable(tab, a, b, c)` returns (or creates) the table at `tab[a][b][c]`
local function GetSubTable(tab, ...)
	local args = {...}
	for i, val in ipairs(args) do
		if not tab[val] then
			tab[val] = {}
		end
		tab = tab[val]
	end
	return tab
end

-- Returns a player from either the Parent or the SpawnerEntity, if either.
local function FindPlayerParent(entity)
	local parent = entity.Parent
	if parent then
		parent = parent:ToPlayer()
	end
	
	local spawner = entity.SpawnerEntity
	if spawner then
		spawner = spawner:ToPlayer()
	end
	
	return parent or spawner
end

-- Finds the player parent for a laser, moving up through parent lasers if necessary.
local function FindLaserPlayerParent(laser)
	local data = laser:GetData()
	if data.newTractorBeamOverrideParent then
		return data.newTractorBeamOverrideParent
	end
	if data.newTractorBeamLaserParent then
		return data.newTractorBeamLaserParent
	end
	
	-- For avoiding infinite loops.
	local seenEntities = {}
	
	local spawner = laser.SpawnerEntity
	while spawner and not seenEntities[GetPtrHash(spawner)] and not spawner:ToPlayer() and spawner.SpawnerEntity do
		seenEntities[GetPtrHash(spawner)] = true
		spawner = spawner.SpawnerEntity
	end
	
	if spawner and spawner:ToPlayer() then
		data.newTractorBeamLaserParent = spawner:ToPlayer()
		return spawner:ToPlayer()
	end
	
	seenEntities = {}
	
	local parent = laser.Parent
	while parent and not seenEntities[GetPtrHash(parent)] and not parent:ToPlayer() and parent.Parent do
		seenEntities[GetPtrHash(parent)] = true
		parent = parent.Parent
	end
	
	if parent and parent:ToPlayer() then
		data.newTractorBeamLaserParent = parent:ToPlayer()
		return parent:ToPlayer()
	end
end

--------------------------------------------------
---- LASER PATH HELPERS
---- Anyone snooping feel free to use these!
--------------------------------------------------

local CachedLaserPaths = {}
local CachedLaserLengths = {}

-- Returns a table representing the path of a laser. Also returns the length of the path.
-- Table entries are tables with two values:
--  - `Position` (The vector position of this point along the laser's path.)
--  - `Distance` (The current distance along the path of the laser, from the start.)
-- Caches data so that multiple calls in the same frame won't redo the work.
-- Note that the laser's PositionOffset may have to be added for the positions to look accurate.
local function GetLaserPath(laser)
	local currentFrame = game:GetFrameCount()
	local data = laser:GetData()
	local hash = GetPtrHash(laser)
	
	if CachedLaserPaths[hash] and CachedLaserLengths[hash] then
		return CachedLaserPaths[hash], CachedLaserLengths[hash]
	end
	
	local path = {}
	local pathLength = 0
	
	-- Insert the root/anchor position of the laser first, except for circle lasers.
	if not laser:IsCircleLaser() then
		table.insert(path, {
			Position = laser.Position,
			Distance = 0,
		})
	end
	
	local samplePoints = laser:GetSamples()
	
	-- Iterate over each sample point of the laser.
	for i=0, #samplePoints-1 do
		local pos = Vector(samplePoints:Get(i).X, samplePoints:Get(i).Y)
		
		local previous = path[#path]
		
		local isDuplicate = previous and pos.X == previous.Position.X and pos.Y == previous.Position.Y
		
		if not isDuplicate then
			if previous then
				pathLength = pathLength + pos:Distance(previous.Position)
			end
			table.insert(path, {
				Position = pos,
				Distance = pathLength,
			})
		end
	end
	
	CachedLaserPaths[hash] = path
	CachedLaserLengths[hash] = pathLength
	
	return path, pathLength
end

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
	-- Have to wipe the cache for a laser every time it updates, because the shape may have changed.
	local hash = GetPtrHash(laser)
	CachedLaserPaths[hash] = nil
	CachedLaserLengths[hash] = nil
end)

-- Returns the total length of a laser's path, from tip to end.
local function GetLaserLength(laser)
	local path, pathLength = GetLaserPath(laser)
	return pathLength
end

-- Binary search implementation for finding a point at a certain distance along a path.
-- Don't call this function - use GetPosAtDistanceAlongLaserPath below.
local function BinarySearch(tab, l, r, targetDist)
	if l == r then
		return tab[l].Position
	end
	
	if l > r then
		local errStr = "GetPosAtDistanceAlongLaserPath Error: Binary search failed."
		print(errStr)
		Isaac.DebugString(errStr)
		return
	end
	
	local mid = math.floor((l + r) / 2)
	
	if not tab[mid] then
		local errStr = "GetPosAtDistanceAlongLaserPath Error: Laser path table is likely malformed."
		print(errStr)
		Isaac.DebugString(errStr)
		return
	end
	
	if tab[mid].Distance <= targetDist then
		if not tab[mid+1] then
			local errStr = "GetPosAtDistanceAlongLaserPath Error (maybe): Reached the end of the table unexpectedly. Table possibly malformed -  normally this doesn't trigger."
			print(errStr)
			Isaac.DebugString(errStr)
			return tab[mid].Position
		elseif tab[mid+1].Distance >= targetDist then
			local n = (targetDist - tab[mid].Distance) / (tab[mid+1].Distance - tab[mid].Distance)
			return Lerp(tab[mid].Position, tab[mid+1].Position, n)
		end
		-- Go right
		return BinarySearch(tab, mid+1, r, targetDist)
	end
	
	-- Go left
	return BinarySearch(tab, l, mid, targetDist)
end

-- Returns a Vector position at a specified distance along a laser's path.
-- Note that the laser's PositionOffset may have to be added for the position to look accurate.
local function GetPosAtDistanceAlongLaserPath(laser, targetDist)
	local path = GetLaserPath(laser)
	return BinarySearch(path, 1, #path, targetDist)
end

--------------------------------------------------
---- Laser path visualizer (debug)
--------------------------------------------------

--[[local target = Sprite()
target:Load("gfx/1000.030_dr. fetus target.anm2", true)
target:Play("Idle", true)
target.Scale = Vector(0.3, 0.3)

mod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, function(_, laser)
	local path = GetLaserPath(laser)
	
	for _, node in ipairs(path) do
		local pos = node.Position + laser.PositionOffset
		local renderPos = Isaac.WorldToScreen(pos)
		target:Render(renderPos, kZeroVector, kZeroVector)
	end
end)]]

--------------------------------------------------
---- TEAR GROUPING FOR MULTISHOT
--------------------------------------------------

local groupableNewTears = {}

local function TrackNewTearForGrouping(tear)
	local dist = math.max(tear:GetData().newTractorBeamTearCurrentDist, 0)
	local tab = GetSubTable(groupableNewTears, dist, tear:GetData().newTractorBeam.InitSeed)
	tab[tear.InitSeed] = tear
end

-- For multishot, arrange the tears into funny little shapes.
function mod:GroupTears()
	local tearSize
	
	for startDist, lasers in pairs(groupableNewTears) do
		for _, tears in pairs(lasers) do
			local numTears = 0
			for _, tear in pairs(tears) do
				numTears = numTears + 1
			end
			if numTears > 1 then
				local row = 1
				local rowSize = 1
				
				local a = 1
				local b = 1
				
				local i = 1
				
				for _, tear in pairs(tears) do
					if not tearSize then
						tearSize = tear.Size * 1.5
					end
					
					local w = tearSize * (rowSize-1)
					local x = 0
					if b > a then
						x = w * (i - a) / (b - a) - w * 0.5
					end
					local y = tearSize * (row-1)
					tear:GetData().newTractorBeamTearMultishotOffset = Vector(x, 0)
					tear:GetData().newTractorBeamTearCurrentDist = startDist - y
					
					if i == b then
						row = row + 1
						a = i + 1
						b = math.min(a + (row-1), numTears)
						rowSize = math.min(row, numTears - (a-1))
					end
					
					i = i + 1
				end
			end
		end
	end
	
	groupableNewTears = {}
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.GroupTears)

--------------------------------------------------
---- TRACTOR BEAM TEAR HANDLING
--------------------------------------------------

local function FixTearRotation(tear, dir)
	if tear.SpriteRotation ~= 0 then
		tear.SpriteRotation = (dir or tear.Velocity):GetAngleDegrees()
	end
end

local function InitTearForTractorBeam(laser, tear, tearSpeed, startDist)
	local tData = tear:GetData()
	
	if startDist and startDist > 0 then
		tear.Position = GetPosAtDistanceAlongLaserPath(laser, startDist)
	end
	
	tData.newTractorBeam = laser
	tData.newTractorBeamTearSpeed = tearSpeed
	tData.newTractorBeamTearCurrentDist = startDist or 0
	tData.newTractorBeamTear = true
	tData.newTractorBeamTearOriginalHeight = tear.Height
	tData.newTractorBeamTearOriginalFallingAcceleration = tear.FallingAcceleration
	tData.newTractorBeamTearOriginalFallingSpeed = tear.FallingSpeed
	tear:ClearTearFlags(kTearPathAffectingTearflags)
	
	if tear:HasTearFlags(TearFlags.TEAR_BOUNCE) then
		tData.newTractorBeamTearWasBounce = true
		tData.newTractorBeamTearOriginalGridCol = tear.GridCollisionClass
		tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	end
	
	if tear.Variant == TearVariant.BALLOON_BRIMSTONE and tear:HasTearFlags(TearFlags.TEAR_BURSTSPLIT) then
		tear:ClearTearFlags(TearFlags.TEAR_QUADSPLIT)
		tear:ClearTearFlags(TearFlags.TEAR_SPLIT)
	end
	
	if tear:ToBomb() then
		local entCol = EntityCollisionClass.ENTCOLL_ENEMIES
		if tear:HasTearFlags(TearFlags.TEAR_PIERCING) then
			entCol = EntityCollisionClass.ENTCOLL_NONE
		end
		tear.EntityCollisionClass = entCol
		tData.newTractorBeamBombEntCol = entCol
		
		local gridCol = EntityGridCollisionClass.GRIDCOLL_NOPITS
		if tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) or tData.newTractorBeamTearWasBounce then
			gridCol = EntityGridCollisionClass.GRIDCOLL_NONE
		end
		tear.GridCollisionClass = gridCol
		tData.newTractorBeamBombGridCol = gridCol
	end
	
	if tear.Visible then
		tear.Visible = false
		tData.newTractorBeamInvisibleFrames = 2
	end
	
	TrackNewTearForGrouping(tear)
end

-- Releases a tear from the tractor beam.
local function ReleaseTear(tear, freeze)
	local tData = tear:GetData()
	tData.newTractorBeamTear = false
	
	if tear:ToTear() then
		FixTearRotation(tear)
		
		if tData.newTractorBeamTearHeight then
			tear.Height = tData.newTractorBeamTearHeight
		end
		tear.FallingAcceleration = 0.3
		tear.FallingSpeed = -1
		
		tear.Velocity = tData.newTractorBeamTearReleaseVelocity or tear.Velocity
		tData.newTractorBeamReleaseSpeed = tear.Velocity:Length() * 0.3
	elseif tear:ToBomb() then
		tear.Velocity = tData.newTractorBeamTearReleaseVelocity or tear.Velocity
		tData.newTractorBeamBombFallingSpeed = 0
	end
	
	if freeze then
		tear.Velocity = kZeroVector
	end
	
	if tData.newTractorBeamInvisibleFrames and tData.newTractorBeamInvisibleFrames > 0 then
		tear.Visible = true
	end
	
	if tData.newTractorBeamTearOriginalGridCol and tData.newTractorBeamTearSpectralFrames and tData.newTractorBeamTearSpectralFrames > 0 then
		tear.GridCollisionClass = tData.newTractorBeamTearOriginalGridCol
	end
	
	if tear:ToTear() and tData.newTractorBeamTearWasBounce then
		tear:AddTearFlags(TearFlags.TEAR_BOUNCE)
		tear.GridCollisionClass = tData.newTractorBeamTearOriginalGridCol
		tear.FallingAcceleration = tData.newTractorBeamTearOriginalFallingAcceleration
		tear.FallingSpeed = tData.newTractorBeamTearOriginalFallingSpeed
		tData.newTractorBeamReleaseSpeed = nil
		tear.Position = game:GetRoom():GetClampedPosition(tear.Position, 0)
	end
	
	if tData.newTractorBeamTearAddedSpectral then
		if not game:GetRoom():IsPositionInRoom(tear.Position, 0) then
			tear:Die()
			return
		else
			if tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) then
				tear:ClearTearFlags(TearFlags.TEAR_SPECTRAL)
			end
			tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		end
	end
	
	if not game:GetRoom():IsPositionInRoom(tear.Position, 0) and not tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) and tear.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NONE then
		tear:Die()
	end
end

-- Function responsible for moving tears along the path of the Tractor Beam.
function mod:TearUpdate(tear)
	local tData = tear:GetData()
	
	if tData.newTractorBeamReleaseSpeed then
		tear.Velocity = Lerp(tear.Velocity, tear.Velocity:Resized(tData.newTractorBeamReleaseSpeed), 0.2)
	end
	
	local player = FindPlayerParent(tear)
	
	if not player then
		if tData.newTractorBeamTear then
			ReleaseTear(tear)
		end
		return
	end
	
	-- Take control of any tears that are allowed to be controlled by the Tractor Beam.
	-- Ludo tears are not supported.
	if tear:HasTearFlags(TearFlags.TEAR_TRACTOR_BEAM) and not tData.newTractorBeamTear
			and not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) and player:GetData().newTractorBeam
			and not (tear:ToBomb() and not player:HasWeaponType(WeaponType.WEAPON_BOMBS)) then
		InitTearForTractorBeam(player:GetData().newTractorBeam, tear, player.ShotSpeed * 10)
	end
	
	-- Even if we don't put this tear on the tractor beam for whatever reason, always remove the vanilla Tractor Beam's TearFlags.
	if tear:HasTearFlags(TearFlags.TEAR_TRACTOR_BEAM) then
		tear:ClearTearFlags(TearFlags.TEAR_TRACTOR_BEAM)
	end
	
	-- From this point onwards, code is for tears on the tractor beam only.
	if not tData.newTractorBeamTear then return end
	
	-- No
	if tear:HasTearFlags(TearFlags.TEAR_BOUNCE) then
		tear:ClearTearFlags(TearFlags.TEAR_BOUNCE)
	end
	
	-- Temporary invisibility, to hide some wonky looking initial frames.
	if tData.newTractorBeamInvisibleFrames and tData.newTractorBeamInvisibleFrames > 0 then
		tData.newTractorBeamInvisibleFrames = tData.newTractorBeamInvisibleFrames - 1
		if tData.newTractorBeamInvisibleFrames == 0 then
			tear.Visible = true
		end
	end
	
	-- Temporary "spectral", to avoid colliding with grids when not desired.
	if tData.newTractorBeamTearOriginalGridCol and tData.newTractorBeamTearSpectralFrames and tData.newTractorBeamTearSpectralFrames > 0 then
		tData.newTractorBeamTearSpectralFrames = tData.newTractorBeamTearSpectralFrames - 1
		if tData.newTractorBeamTearSpectralFrames == 0 then
			tear.GridCollisionClass = tData.newTractorBeamTearOriginalGridCol
		end
	end
	
	-- If a tear sticks to something (sticky bomb / spore / booger tears), stop trying to move it.
	-- Also, if fetus bombs collide with a grid, release them.
	if tear.StickTarget or (tear:ToBomb() and tear:CollidesWithGrid() and not tData.newTractorBeamTearWasBounce) then
		ReleaseTear(tear)
		return
	end
	
	-- Get the EntityLaser for the Tractor Beam, or whatever laser we're riding on.
	local laser = tData.newTractorBeam
	local laserIsMainTractorBeam = laser:GetData().isNewTractorBeam
	local laserIsChildTractorBeam = laser:GetData().isNewTractorBeamChild
	
	tData.newTractorBeamTearEpicFetus = laser:GetData().newTractorBeamEpicFetusTarget
	
	if not laser or not laser:Exists() then
		if tData.newTractorBeamTearEpicFetus then
			tear:Remove()
		else
			ReleaseTear(tear)
		end
		return
	end
	
	local heightOffset = math.min(math.floor(laser.PositionOffset.Y), -5)
	local posOffset = Vector(laser.PositionOffset.X, 0)
	
	if tData.newTractorBeamTearEpicFetus then
		posOffset = Vector(laser.PositionOffset.X, laser.PositionOffset.Y)
		heightOffset = -5
	end
	
	tData.newTractorBeamTearHeight = heightOffset
	
	if tear:ToTear() then
		-- Lock tears to travel along the Tractor Beam at a low height.
		-- This also means that they won't drop prematurely.
		tear.Height = heightOffset
		tear.FallingAcceleration = -heightOffset
		tear.FallingSpeed = -1
	elseif tear:ToBomb() then
		-- Make bombs float too!
		tear.SpriteOffset = Vector(0, laser.PositionOffset.Y * 0.5 + tear.Size * 0.1)
		tear.EntityCollisionClass = tData.newTractorBeamBombEntCol
		tear.GridCollisionClass = tData.newTractorBeamBombGridCol
	end
	
	-- Don't let tears be outside the room if they shouldn't be.
	if not game:GetRoom():IsPositionInRoom(tear.Position, -10)
			and not (tear.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_NONE or tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) or tear:HasTearFlags(TearFlags.TEAR_CONTINUUM)) then
		ReleaseTear(tear)
		return
	end
	
	-- Fetch the laser's path.
	local path, pathLength = GetLaserPath(laser)
	local startPos = path[1].Position + posOffset
	local endPos = path[#path].Position + posOffset
	
	local tearSpeed = tData.newTractorBeamTearSpeed
	
	-- The current distance that the tear has already traveled along the path.
	local currentDist = tData.newTractorBeamTearCurrentDist or 0
	
	-- Eye of the Occult allows tears to stop in place when you aren't firing.
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
		tearSpeed = tearSpeed * player:GetAimDirection():Length()
	end
	
	-- Tractor beam tears stay still and bunch together until you release them.
	if laserIsMainTractorBeam and currentDist <= 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) and player:GetFireDirection() ~= Direction.NO_DIRECTION then
		TrackNewTearForGrouping(tear)
		tearSpeed = 0
	end
	
	-- Handles tears that back to the start of the beam when they reach the end.
	-- For circle lasers (tech x).
	if tData.newTractorBeamLoopingTear then
		local n = tData.newTractorBeamLoopingTear
		currentDist = n * pathLength
		tData.newTractorBeamLoopingTear = (n + (tearSpeed / pathLength)) % 1.0
	end
	
	-- How far along the path we should be next update.
	local targetDist = math.min(currentDist + tearSpeed, pathLength)
	-- The Vector position we should move towards now.
	local newTargetPos = GetPosAtDistanceAlongLaserPath(laser, targetDist) + posOffset
	-- The newTargetPos we would have had last update on the current laser.
	-- Since the shape or angle of the laser can change constantly, this is often not what our actual
	-- targetPos was last update. Still, this is useful.
	local theoreticalPrevTargetPos = GetPosAtDistanceAlongLaserPath(laser, currentDist) + posOffset
	
	-- If the tear has reached the end of the path, kill it (except with Continuum / Rubber Cement).
	if not tData.newTractorBeamLoopingTear and (currentDist >= pathLength-1 --[[or theoreticalPrevTargetPos:Distance(endPos) < 5]]) then
		-- Epic fetus stuff.
		if laser:GetData().newTractorBeamEpicFetusTarget then
			if not laser:GetData().newTractorBeamEpicFetusTarget:Exists() then
				tear:Remove()
			else
				ReleaseTear(tear)
				tear.Height = -10
				tear.FallingAcceleration = 0.5
				tear.FallingSpeed = 1
				tear.Position = Vector(tear.Position.X, laser.Position.Y)
				tear.Velocity = kZeroVector
			end
			return
		end
		
		local moveToChildBeam = laser:GetData().childNewTractorBeam
				and laser:GetData().childNewTractorBeam:Exists()
				and GetLaserLength(laser:GetData().childNewTractorBeam) >= 35
		if moveToChildBeam then
			-- There's a child laser - continuum or rubber cement. Move onto the new laser.
			if tData.newTractorBeam.Position:Distance(laser:GetData().childNewTractorBeam.Position) > 200 then
				-- Probably continuum
				tData.newTractorBeamTearTargetPos = laser:GetData().childNewTractorBeam.Position
				tear.Position = tData.newTractorBeam.Position
			end
			tData.newTractorBeam = laser:GetData().childNewTractorBeam
			tData.newTractorBeamTearCurrentDist = 0
			
			-- Hurt grid entities when we bounce off them with rubber cement.
			local grid = game:GetRoom():GetGridEntityFromPos(tear.Position)
			if not grid then
				grid = game:GetRoom():GetGridEntityFromPos(tear.Position - Vector(0, 25))
			end
			if grid then
				grid:Hurt(1)
			end
			
			-- Safety net so that we don't collide with walls.
			if tear.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NONE then
				tData.newTractorBeamTearOriginalGridCol = tear.GridCollisionClass
				tData.newTractorBeamTearSpectralFrames = 10
				tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			end
			tear:Update()
		else
			-- Normal case where the tear just reached the end of the beam. Release it.
			ReleaseTear(tear)
		end
		return
	end
	
	-- handle the position offsets for multishot bundles of tears.
	if tData.newTractorBeamTearMultishotOffset and tData.newTractorBeamTearMultishotOffset:Length() > 0 then
		local angle = (newTargetPos - theoreticalPrevTargetPos):GetAngleDegrees() + 90
		if tearSpeed == 0 or newTargetPos:Distance(theoreticalPrevTargetPos) == 0 then
			angle = laser.Angle + 90
		end
		offset = tData.newTractorBeamTearMultishotOffset:Rotated(angle)
		
		newTargetPos = newTargetPos + offset
		theoreticalPrevTargetPos = theoreticalPrevTargetPos + offset
	end
	
	if newTargetPos then
		-- By next update we should be at this distance.
		tData.newTractorBeamTearCurrentDist = targetDist
		
		-- "Velocity" moving along the path of the laser with no other factors.
		tData.newTractorBeamTearLockedVelocity = newTargetPos - theoreticalPrevTargetPos
		
		if tear:ToTear() then
			-- Keep the tear rotated in right direction.
			FixTearRotation(tear, tData.newTractorBeamTearLockedVelocity)
		end
		
		-- Factor in the players' velocity when determining where we should be on the next frame.
		if laser:GetData().newTractorBeamEpicFetusTarget then
			newTargetPos = newTargetPos + laser:GetData().newTractorBeamEpicFetusTarget.Velocity
			tData.newTractorBeamTearReleaseVelocity = tData.newTractorBeamTearLockedVelocity + laser.Velocity
		elseif laser:IsCircleLaser() or laser.OneHit then
			newTargetPos = newTargetPos + laser.Velocity
			tData.newTractorBeamTearReleaseVelocity = tData.newTractorBeamTearLockedVelocity + laser.Velocity
		else
			newTargetPos = newTargetPos + player.Velocity * 2
			tData.newTractorBeamTearReleaseVelocity = tData.newTractorBeamTearLockedVelocity + player:GetTearMovementInheritance(tData.newTractorBeamTearLockedVelocity)
		end
		tData.newTractorBeamTearReleaseVelocity = tData.newTractorBeamTearReleaseVelocity:Resized(tearSpeed)
		
		local justTurned = player:GetData().newTractorBeamJustTurned or 0
		if justTurned > 0 then
			-- Set the tear's position to the previous pos for the CURRENT laser path.
			-- Avoids weird lerping after turning suddenly.
			tear.Position = theoreticalPrevTargetPos
		else
			-- Set the tear's position to the previous targetPos.
			tear.Position = tData.newTractorBeamTearTargetPos or startPos
		end
		
		-- Move towards the new target position.
		tear.Velocity = newTargetPos - tear.Position
		tData.newTractorBeamTearTargetPos = newTargetPos
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.TearUpdate)

-- Update function for Dr Fetus bombs.
-- Mostly just calls the same code that the tears use.
function mod:BombUpdate(bomb)
	local data = bomb:GetData()
	if data.newTractorBeamBombFallingSpeed then
		data.newTractorBeamBombFallingSpeed = data.newTractorBeamBombFallingSpeed + 0.25
		bomb.SpriteOffset = Vector(bomb.SpriteOffset.X, math.min(bomb.SpriteOffset.Y + data.newTractorBeamBombFallingSpeed, 0))
		bomb.Velocity = Lerp(bomb.Velocity, kZeroVector, 0.025)
	end
	
	mod:TearUpdate(bomb)
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.BombUpdate)

-- Fix some compatibility issues with bomb mods by messing with TearFlags as early as possible.
-- (Doesn't work on Init.)
local newBombs = {}
mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
	table.insert(newBombs, bomb)
end)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	for _, bomb in pairs(newBombs) do
		mod:BombUpdate(bomb)
	end
	newBombs = {}
end)

function mod:PreTearCollision(tear, collider)
	local tData = tear:GetData()
	if tData.newTractorBeamTear then
		local laser = tData.newTractorBeam
		-- Don't let epic fetus tears collide with anything while they're "falling".
		if laser and laser:GetData().newTractorBeamEpicFetusTarget then
			return true
		end
		-- Release tears from the tractor beam on enemy collision for bouncy tears (rubber cement).
		if collider and not collider:ToPlayer() and (tear:ToBomb() or tData.newTractorBeamTearWasBounce) then
			ReleaseTear(tear)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.PreTearCollision)
mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, mod.PreTearCollision)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider)
	if collider:ToTear() or collider:ToBomb() then
		return mod:PreTearCollision(collider, npc)
	end
end)

function mod:HandleFetusTears(tear)
	if tear.Variant == 50 then
		local player = FindPlayerParent(tear)
		if player and player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
			tear:AddTearFlags(TearFlags.TEAR_TRACTOR_BEAM)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.HandleFetusTears)

--------------------------------------------------
---- HANDLING THE TRACTOR BEAM ITSELF
--------------------------------------------------

-- Returns true if the player should actually have a tractor beam.
local function ShouldHaveTractorBeam(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM)
			and not player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE)
			and not player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE)
			and not player:HasWeaponType(WeaponType.WEAPON_ROCKETS)
			and not player:HasWeaponType(WeaponType.WEAPON_TECH_X)
			and not player:HasWeaponType(WeaponType.WEAPON_LASER)
			and not player:HasWeaponType(WeaponType.WEAPON_KNIFE)
			and not player:HasWeaponType(WeaponType.WEAPON_BONE)
			and not player:HasWeaponType(WeaponType.WEAPON_NOTCHED_AXE)
			and not player:HasWeaponType(WeaponType.WEAPON_URN_OF_SOULS)
			and not player:HasWeaponType(WeaponType.WEAPON_UMBILICAL_WHIP)
end

-- Detects when the player turns abruptly.
function mod:DetectTurn(player)
	local pData = player:GetData()
	
	if pData.newTractorBeamJustTurned and pData.newTractorBeamJustTurned > 0 then
		pData.newTractorBeamJustTurned = pData.newTractorBeamJustTurned - 1
	end
	
	if not ShouldHaveTractorBeam(player) or player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
		return
	end
	
	local currentDir = pData.newTractorBeamDir or Direction.NO_DIRECTION
	local newDir = Direction.NO_DIRECTION
	
	if player:GetFireDirection() ~= Direction.NO_DIRECTION then
		newDir = player:GetFireDirection()
	elseif player:GetHeadDirection() ~= Direction.NO_DIRECTION then
		newDir = player:GetHeadDirection()
	end
	
	if newDir ~= currentDir then
		pData.newTractorBeamJustTurned = 4
	end
	
	pData.newTractorBeamDir = newDir
end

local function SetTractorBeamTearFlags(player, beam)
	beam.TearFlags = player:GetTearHitParams(WeaponType.WEAPON_LASER).TearFlags & kTractorBeamAcceptableTearFlags
	if not beam:HasTearFlags(TearFlags.TEAR_BOUNCE) then
		beam:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	end
	player:GetData().newTractorBeamSetTearFlags = true
end

function mod:NewTractorBeamPlayerUpdate(player)
	local pData = player:GetData()
	
	-- Spawns the New Tractor Beam when needed.
	if --[[game:GetRoom():GetFrameCount() > 0 and]] ShouldHaveTractorBeam(player) and (not pData.newTractorBeam or not pData.newTractorBeam:Exists()) then
		local dir
		if player:GetAimDirection():Length() > 0 then
			dir = player:GetAimDirection()
		else
			dir = DirectionToVector(player:GetHeadDirection())
		end
		
		local beam = player:FireTechLaser(player.Position, 0, dir, false, false, player, 0)
		SetTractorBeamTearFlags(player, beam)
		beam.CollisionDamage = 0
		
		-- Funny hack that makes the laser incapable of colliding with anything.
		local dummy = Isaac.Spawn(EntityType.ENTITY_SHOPKEEPER, 0, 0, kZeroVector, kZeroVector, nil)
		beam.Parent = dummy
		dummy:Remove()
		
		-- This stops the beam from automatically inheriting TearFlags from the player.
		beam.SpawnerEntity = nil
		
		beam.Timeout = -1	-- Beam will last indefinitely.
		beam.Mass = 0	-- Prevents the beam from "pushing" entities.
		beam.Position = player.Position
		beam:SetMaxDistance(player.TearRange)
		
		beam:GetData().isNewTractorBeam = true
		beam:GetData().newTractorBeamPlayer = player
		pData.newTractorBeam = beam
		
		beam:GetSprite():Load("gfx/tractor_beam_2_laser.anm2", true)
		beam:GetSprite():LoadGraphics()
		beam:GetSprite():Play("Laser0")
		
		beam:Update()
		
		-- Fix any child lasers that spawned (continuum/rubber cement).
		for _, laser in pairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
			if laser.Parent and GetPtrHash(laser.Parent) == GetPtrHash(beam) then
				laser:ToLaser():SetMaxDistance(1)
				laser:Update()
			end
		end
		
		-- Fix any laser impact/tips.
		for _, eff in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.LASER_IMPACT)) do
			mod:LaserTip(eff)
		end
		
		beam:Update()
		
		-- This code should only get triggered when the player picks up Tractor Beam or
		-- enters a new room, so I'm not really worried about stopping the wrong sound.
		sfxManager:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK)
		sfxManager:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP)
		sfxManager:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP_STRONG)
		sfxManager:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP_BURST)
	elseif pData.newTractorBeam then
		if not ShouldHaveTractorBeam(player) then
			pData.newTractorBeam:Remove()
			pData.newTractorBeam = nil
		else
			-- Lock the beam at the player's position, but keep it from clipping into walls.
			local pos = player.Position
			
			if pData.newTractorBeam:GetData().newTractorBeamVectorDir then
				local dir = pData.newTractorBeam:GetData().newTractorBeamVectorDir
				local truePos = pos + pData.newTractorBeam.PositionOffset
				
				local kLaserTipLength = 32 -- Distance between the laser's position and its first sample point.
				local kExtraPadding = 16
				local kWallWidth = 35  -- Approx. size of a grid entity
				
				-- I'm basically preventing the beam from being close enough to a wall so that it's first sample point doesn't clip past the wall grid entities.
				-- When this happens the beam will clip through the wall, which isnt a huge deal but I didn't like it.
				local i = 0
				while i < 50 and not game:GetRoom():IsPositionInRoom(truePos + dir:Resized((kLaserTipLength + kExtraPadding) - i), -kWallWidth) do
					i = i + 1
				end
				
				pos = pos - dir:Resized(i)
			end
			
			pData.newTractorBeam.Position = pos
		end
	end
	
	mod:DetectTurn(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.NewTractorBeamPlayerUpdate)

local function IsMarkedTarget(player, target)
	target = target:ToEffect()
	return target
		 and target.SpawnerEntity
		 and GetPtrHash(target.SpawnerEntity) == GetPtrHash(player)
		 and target.State == 0
		 and target.Timeout == 0
		 and target.LifeSpan == 0
end

local antiRecursionBit = false

-- Post-Update function for the New Tractor Beam.
local function NewTractorBeamUpdate(beam)
	local data = beam:GetData()
	
	if not data.isNewTractorBeam then return end
	
	local player = data.newTractorBeamPlayer
	local pData = player:GetData()
	
	if not player or not ShouldHaveTractorBeam(player) then
		beam:Remove()
		return
	end
	
	-- Refresh the beam's TearFlags regularly, but not every single frame.
	-- Only certain TearFlags are allowed (see kTractorBeamAcceptableTearFlags).
	if not pData.newTractorBeamSetTearFlags or beam.FrameCount % 60 == 0 then
		SetTractorBeamTearFlags(player, beam)
	end
	
	data.newTractorBeamFrame = (data.newTractorBeamFrame or 0) + 1
	mod:NewTractorBeamRender(beam)
	
	beam.Color = kNullColor
	beam.SpriteScale = kNormalVector
	
	if beam:HasTearFlags(TearFlags.TEAR_CONTINUUM) and beam:HasTearFlags(TearFlags.TEAR_BOUNCE) then
		beam:SetMaxDistance(0)
	else
		beam:SetMaxDistance(player.TearRange)
	end
	
	-- Find the current direction for the Tractor Beam.
	local dir
	local vectorDir
	
	local mark
	
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
		if pData.newTractorBeamMark and pData.newTractorBeamMark:Exists() then
			mark = pData.newTractorBeamMark
		else
			for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0)) do
				if IsMarkedTarget(player, entity) then
					mark = entity
					break
				end
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
				for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.OCCULT_TARGET, 0)) do
					if IsMarkedTarget(player, entity) then
						mark = entity
						break
					end
				end
			end
			pData.newTractorBeamMark = mark
		end
	end
	
	if mark then
		vectorDir = mark.Position - player.Position
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) and player:GetAimDirection():Length() > 0 then
		vectorDir = player:GetAimDirection()
	elseif player:GetFireDirection() ~= Direction.NO_DIRECTION then
		dir = player:GetFireDirection()
	elseif player:GetHeadDirection() ~= Direction.NO_DIRECTION then
		dir = player:GetHeadDirection()
	end
	
	if dir then
		vectorDir = DirectionToVector(dir)
		data.newTractorBeamDir = dir
	else
		data.newTractorBeamDir = nil
	end
	
	-- Update the position, offsets and angle of the beam when appropriate.
	if vectorDir then
		data.newTractorBeamVectorDir = vectorDir
		
		if pData.newTractorBeamPlayerSize ~= player.SpriteScale.X then
			pData.newTractorBeamOffsetCache = nil
			pData.newTractorBeamFallbackOffsetCache = nil
		end
		pData.newTractorBeamPlayerSize = player.SpriteScale.X
		
		local offsetCache = GetSubTable(pData, "newTractorBeamOffsetCache")
		local fallbackOffsetCache = GetSubTable(pData, "newTractorBeamFallbackOffsetCache")
		
		local headDir = VectorToDirection(vectorDir)
		if headDir == Direction.NO_DIRECTION then
			headDir = Direction.DOWN
		end
		local headVectorDir = DirectionToVector(headDir)
		
		if player:GetSprite():GetOverlayAnimation() ~= "" and player:GetSprite():GetOverlayFrame() < 2 then
			offsetCache[headDir] = player:GetLaserOffset(LaserOffset.LASER_TRACTOR_BEAM_OFFSET, headVectorDir)
		else
			fallbackOffsetCache[headDir] = player:GetLaserOffset(LaserOffset.LASER_TRACTOR_BEAM_OFFSET, headVectorDir)
		end
		
		beam.PositionOffset = offsetCache[headDir] or fallbackOffsetCache[headDir]
		if headDir ~= data.prevHeadDir and not antiRecursionBit then
			antiRecursionBit = true
			beam:Update()
			antiRecursionBit = false
		end
		data.prevHeadDir = headDir
		
		beam.ParentOffset = kZeroVector
	
		local targetAngle = vectorDir:GetAngleDegrees()
		-- Quick little calculation to make sure we take the shortest rotation to the targetAngle.
		local shortestRotation = (targetAngle - beam.Angle + 540) % 360 - 180
		data.newTractorBeamTargetAngle = beam.Angle + shortestRotation
	end
	 
	if data.newTractorBeamTargetAngle then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
			-- Lerp towards the target angle.
			beam.Angle = Lerp(beam.Angle, data.newTractorBeamTargetAngle, 0.25)
		else
			-- Snap to the target angle.
			beam.Angle = data.newTractorBeamTargetAngle
		end
	end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	player:GetData().newTractorBeamSetTearFlags = false
end, CacheFlag.CACHE_TEARFLAG)

function mod:NewTractorBeamRender(beam)
	if (beam:GetData().isNewTractorBeam or beam:GetData().isNewTractorBeamChild) and beam:GetData().newTractorBeamFrame then
		local frame = math.floor(1 * beam:GetData().newTractorBeamFrame) % 9
		beam:GetSprite():SetFrame("Laser0", frame)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, mod.NewTractorBeamRender)

-- Replaces the "LASER_IMPACT" sprite for the Tractor Beam.
function mod:LaserTip(eff)
	if eff.SpawnerEntity and (eff.SpawnerEntity:GetData().isNewTractorBeam or eff.SpawnerEntity:GetData().isNewTractorBeamChild or eff.SpawnerEntity:GetData().newTractorBeamEpicFetusTarget) then
		if eff:GetSprite():GetFilename() ~= "gfx/tractor_beam_2_laser_tip.anm2" then
			eff:GetSprite():Load("gfx/tractor_beam_2_laser_tip.anm2", true)
			eff:GetSprite():LoadGraphics()
			eff:GetSprite():Play("End", true)
		end
		
		eff:GetSprite():SetFrame(eff.SpawnerEntity:GetSprite():GetFrame())
		eff.Color = eff.SpawnerEntity.Color
		eff.SpriteScale = eff.SpawnerEntity.SpriteScale
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.LaserTip, EffectVariant.LASER_IMPACT)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.LaserTip, EffectVariant.LASER_IMPACT)

-- Prevent the Tractor Beam laser from dealing damage to enemies.
function mod:PreTakeDamage(tookDamage, damage, damageFlags, damageSourceRef)
	if damageSourceRef.Type == EntityType.ENTITY_LASER and damageSourceRef.Entity
			and (damageSourceRef.Entity:GetData().isNewTractorBeam or damageSourceRef.Entity:GetData().isNewTractorBeamChild) then
		return false
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.PreTakeDamage)

--------------------------------------------------
---- BRIMSTONE / TECH / ETC SYNERGIES
--------------------------------------------------

-- Spawns a tear intended to travel along a non-tractor beam laser, like brimstone or tech.
local function SpawnNewTractorBeamTearForLaser(player, laser, tearSpeed, startingDist, circleOffset)
	local tear = player:FireTear(laser.Position, kZeroVector, true, true, false, player)
	tear:ClearTearFlags(TearFlags.TEAR_JACOBS | TearFlags.TEAR_LASERSHOT | TearFlags.TEAR_BURSTSPLIT | TearFlags.TEAR_SPLIT | TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_BONE)
	InitTearForTractorBeam(laser, tear, tearSpeed, startingDist)
	
	local tData = tear:GetData()
	
	if not tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) then
		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
		tData.newTractorBeamTearAddedSpectral = true
	end
	
	tData.newTractorBeamOverrideLaser = laser
	tData.newTractorBeamLoopingTear = circleOffset
	tear.Height = math.min(math.floor(laser.PositionOffset.Y), -5)
	
	if laser.Variant == 2 then
		tear.Scale = math.max(0.5, tear.Scale * 0.5)
	end
	tear.CollisionDamage = tear.CollisionDamage * 0.5
	
	if not laser:GetData().newTractorBeamEpicFetusTarget then
		local c = laser.Color
		c:SetTint(1,0,0,1)
		tear.Color = c
	end
	
	if laser.OneHit then
		ReleaseTear(tear, true)
	end
	
	return tear
end

local BrimstoneLaserVariants = {
	[1] = true,
	[6] = true,
	[9] = true,
	[11] = true,
	[14] = true,
	[15] = true,
}

local function AllowLaserSynergy(player, laser)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then return false end
	if laser:GetData().newTractorBeamDisableLaserSynergy then return false end
	if laser:GetData().newTractorBeamEpicFetusTarget then return true end
	
	if BrimstoneLaserVariants[laser.Variant] then
		return player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)
				or player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE)
				or player:HasWeaponType(WeaponType.WEAPON_TECH_X)
	elseif laser.Variant == 2 then
		return player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY)
				or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)
				or player:HasWeaponType(WeaponType.WEAPON_LASER)
				or player:HasWeaponType(WeaponType.WEAPON_TECH_X)
	end
end

local function LaserSynergies(laser)
	local player = FindLaserPlayerParent(laser)
	
	if not player or not AllowLaserSynergy(player, laser) then return false end
	
	local data = laser:GetData()
	
	local tearPadding = 100 -- Distance between tears.
	local tearSpeed = player.ShotSpeed * 10
	
	if not data.newTractorBeamSpawnedInitialLaserTears then
		if laser:IsCircleLaser() then
			-- For circle lasers, just spawn 4 tears evenly spaced along the circle.
			local numTears = 4
			for i=0, numTears-1 do
				SpawnNewTractorBeamTearForLaser(player, laser, tearSpeed, nil, i / numTears)
			end
		else
			local samplePoints = laser:GetSamples()
			local laserLength = GetLaserLength(laser)
			local step = tearPadding
			local currentDist = 0
			
			if laser.OneHit then
				currentDist = step * 0.5
			end
			
			-- Spawn tears along the laser as soon as it appears.
			while currentDist <= laserLength do
				local tear = SpawnNewTractorBeamTearForLaser(player, laser, tearSpeed, currentDist)
				currentDist = currentDist + step
			end
		end
		data.newTractorBeamSpawnedInitialLaserTears = true
	elseif not laser:IsCircleLaser() and not laser.OneHit and not (data.newTractorBeamEpicFetusTarget and data.newTractorBeamEpicFetusTarget.Timeout < 10)
			and (laser.FrameCount - data.newTractorBeamFirstUpdate) % math.ceil(tearPadding / tearSpeed) == 0 then
		-- Spawn additional tears moving along the laser while its active.
		SpawnNewTractorBeamTearForLaser(player, laser, tearSpeed)
	end
end

--------------------------------------------------
---- PATCH: Prevent lasers spawned from tears from being eligible for the laser synergy.
--------------------------------------------------

local newLasers = {}

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, tear)
	for _, laser in pairs(newLasers) do
		if tear.Parent then
			local player = tear.Parent:ToPlayer()
			if player and player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) and tear.Position:Distance(laser.Position) == 0 then
				laser:GetData().newTractorBeamDisableLaserSynergy = true
			end
		end
	end
end, EntityType.ENTITY_TEAR)

mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, function(_, laser)
	newLasers[laser.InitSeed] = laser
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	newLasers = {}
end)

--------------------------------------------------
---- GENERAL LASERS UPDATE
--------------------------------------------------

function mod:KeepVanillaTractorBeamInvisible(laser)
	laser.Color = kInvisible
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.KeepVanillaTractorBeamInvisible, 7)

function mod:LaserUpdate(laser)
	local data = laser:GetData()
	
	if not data.newTractorBeamFirstUpdate then
		data.newTractorBeamFirstUpdate = laser.FrameCount
	end
	
	-- Keep the vanilla Tractor Beam invisible.
	if laser.Variant == 7 and laser.Parent and laser.Parent:ToPlayer() then
		mod:KeepVanillaTractorBeamInvisible(laser)
		return
	end
	
	if data.isNewTractorBeam then
		NewTractorBeamUpdate(laser)
		return
	end
	
	-- Trisageeeon
	if laser.Parent and laser.Parent:Exists() and laser.Parent:ToTear()
			and laser.Parent:GetData().newTractorBeamTear
			and laser.Parent:GetData().newTractorBeamTearLockedVelocity then
		laser.Parent.Velocity = laser.Parent:GetData().newTractorBeamTearLockedVelocity
		laser.PositionOffset = Lerp(laser.PositionOffset, laser.Parent.PositionOffset, 0.25)
		return
	end
	
	-- Detect if this laser is a child of the tractor beam, and fix it if so.
	if not data.isNewTractorBeamChild and laser.FrameCount == data.newTractorBeamFirstUpdate
			and laser.Parent and (laser.Parent:GetData().isNewTractorBeam or laser.Parent:GetData().isNewTractorBeamChild) then
		laser.Mass = 0
	
		data.isNewTractorBeamChild = true
		
		laser:GetSprite():Load("gfx/tractor_beam_2_laser.anm2", true)
		laser:GetSprite():LoadGraphics()
		laser:GetSprite():Play("Laser0")
		
		laser.Parent:GetData().childNewTractorBeam = laser
		
		laser:Update()
		return
	end
	
	-- "Child" tractor beams (Rubber Cement, Continuum)
	if data.isNewTractorBeamChild then
		if not laser.Parent or not laser.Parent:Exists() or not laser.Parent:ToLaser() then
			laser:Remove()
			return
		end
		
		laser.PositionOffset = laser.Parent.PositionOffset
		laser.ParentOffset = kZeroVector
		
		laser.TearFlags = laser.Parent:ToLaser().TearFlags
		
		data.newTractorBeamFrame = (data.newTractorBeamFrame or 0) + 1
		mod:NewTractorBeamRender(laser)
		
		if GetLaserLength(laser) < 35 then
			laser.SpriteScale = kZeroVector
		else
			laser.SpriteScale = kNormalVector
		end
		
		local c = laser.Color
		c:SetTint(c.R, c.G, c.B, 0.3)
		laser.Color = c
		
		return
	end
	
	if data.newTractorBeamEpicFetusTarget and not data.newTractorBeamEpicFetusTarget:Exists() then
		laser:Remove()
		return
	end
	
	LaserSynergies(laser)
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.LaserUpdate)

--------------------------------------------------
---- EPIC FETUS SYNERGY
--------------------------------------------------

function mod:TargetUpdate(target)
	if target.SubType > 0 or not target.SpawnerEntity or not target.SpawnerEntity:ToPlayer() then return end
	
	local player = target.SpawnerEntity:ToPlayer()
	
	if not player:HasWeaponType(WeaponType.WEAPON_ROCKETS) or not player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then return end
	
	local data = target:GetData()
	
	if target.Timeout > 0 and (not data.newTractorBeam or not data.newTractorBeam:Exists()) then
		local dir = kDown
		local beam = player:FireTechLaser(player.Position, 0, dir, false, false, player, 0)
		beam.CollisionDamage = 0
		
		-- Funny hack that makes the laser incapable of colliding with anything.
		local dummy = Isaac.Spawn(EntityType.ENTITY_SHOPKEEPER, 0, 0, kZeroVector, kZeroVector, nil)
		beam.Parent = dummy
		dummy:Remove()
		
		beam.SpawnerEntity = nil
		beam.Timeout = -1
		beam.Mass = 0
		
		beam.TearFlags = player:GetTearHitParams(WeaponType.WEAPON_LASER).TearFlags & kTractorBeamAcceptableTearFlags
		beam:AddTearFlags(TearFlags.TEAR_SPECTRAL)
		
		beam:GetSprite():Load("gfx/tractor_beam_2_laser.anm2", true)
		beam:GetSprite():LoadGraphics()
		beam:GetSprite():Play("Laser0")
		
		beam:GetData().newTractorBeamEpicFetusTarget = target
		beam:GetData().newTractorBeamOverrideParent = player
		
		local length = 500
		beam.PositionOffset = Vector(0, -length)
		beam:SetMaxDistance(length - 35)
		
		beam:Update()
		
		data.newTractorBeam = beam
	end
	
	if data.newTractorBeam then
		data.newTractorBeam.Color = kNullColor
		data.newTractorBeam.SpriteScale = kNormalVector
		data.newTractorBeam.Position = target.Position
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.TargetUpdate, EffectVariant.TARGET)

--------------------------------------------------
---- EVIL EYE FIX
--------------------------------------------------

function mod:EvilEyeInit(eye)
	if eye.Velocity:Length() == 0 then
		for i=0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(i)
			if player and player:Exists() and player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
				local dir = player:GetAimDirection()
				if dir:Length() == 0 then
					dir = DirectionToVector(player:GetHeadDirection())
				end
				eye.Velocity = dir:Resized(player.ShotSpeed * 3)
				return
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.EvilEyeInit, EffectVariant.EVIL_EYE)