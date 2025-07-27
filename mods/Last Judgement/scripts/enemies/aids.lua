local mod = LastJudgement
local game = Game()

local bal = {
    WanderDist = 50,
	WanderSpeed = 1.1,
	WanderSlip = 0.1,
	IdleCreepFreq = 5,
	IdleCreepSize = 1.3,
	IdleCreepTime = 35,

    --Blood Syringes
    WallTime = {30, 50, 20, -30},
	WallAim = 3, --Multiplies the target velocity to aim ahead
    WallSyrSpeed = 13,
    WallBloodSpeed = {4, 8},
	WallBloodAccel = 0.95,
	WallBloodFall = {-12,2},
	WallBloodFAccel = 1.2,
	WallAng = 19, --V shot angle
	WallInit = 5, --Starting offset for blood
	WallVel = {30, 12},
	WallAccel = -1.2,
	WallFreq = 3,
	WallShunt = 12, --position variance
	WallVar = 7, --Angle variance when shot from wall
	WallBloodSpec = 10, --How long till it clears spectral flag
	WallBloodScale = {40, 65},
	WallBloodChance = 4, --chance not to fire, less busy
	BloodFrames = 10, --1 lower than the total frames
	WallDelay = 8, --how long before the shot fires from the wall
	WallShotSpeed = 6.5, --these the real bullets, not the close ranged
	WallShotAng = 15,
	WallShotFreq = 5, --every x shots
	WallShotScale = 1.4,
	WallWaves = 2, --Number of waves each needle fires
	WallWaveTimer = 30,

    --Puddlemode
    CreepTime = {20, 45, 20, 0},
	CreepInit = 1.4,
	CreepMax = 2.8,
	CreepLerp = 0.07,
	CreepSpeed = 4.5,
	CreepFreq = 3,
	CreepTimer = 15,
	CreepTransition = 20,
	CreepChaseTime = 60,
	CreepSlip = 0.15,
	CreepSyrRad = 80,
	CreepSyrFreq = 6,
	CreepSyrAway = 55, --Avoids spawning needles this close together

    --Syringe Bullets
    BigTime = {35, 60, 20, 0},
	BigNeedleSpeed = 12,
	BigProjCount = 6,
	BigProjSpeed = 7,
	BigSplitTime = 11,
	BigSplitAngle = {35,66,55},
	BigSplitCount = 2,
	BigSplitScale = 0.66,
}

local paramsNeedle = ProjectileParams()
paramsNeedle.Variant = mod.ENT.AidsNeedleProjectile.Var
paramsNeedle.BulletFlags = paramsNeedle.BulletFlags | ProjectileFlags.NO_WALL_COLLIDE
paramsNeedle.FallingSpeedModifier = 0
paramsNeedle.FallingAccelModifier = 0

local paramsSulfur = ProjectileParams()
paramsSulfur.Variant = mod.ENT.SulfuricNeedle.Var
paramsSulfur.HeightModifier = -10
paramsSulfur.FallingSpeedModifier = 0
paramsSulfur.FallingAccelModifier = -0.05

local params = ProjectileParams()
params.Color = mod.Colors.MortisBloodProj
params.FallingSpeedModifier = 0
params.FallingAccelModifier = -0.05
params.Scale = 2

local function makeCopiedTable(original)
	local tab = {}
	for key,entry in pairs(original) do
		if type(entry) == "table" then
			tab[key] = makeCopiedTable(entry)
		else
			tab[key] = entry
		end
	end
	return tab
end

local function GetRandomOrderedTable(list2, rng, existing)
	local list = makeCopiedTable(list2)
	local result = existing or {}
	local failSafe = 0
	while #list > 0 and failSafe < 100 do
		local rand = rng:RandomInt(#list)+1
		table.insert(result, list[rand])
		table.remove(list, rand)
		failSafe = failSafe+1
	end
	return result
end

local function RemoveEntryThroughResult(list2, result)
	local list = makeCopiedTable(list2)
	if type(result) == "table" then
		for _,res in ipairs(result) do
			for key,entry in pairs(list) do
				if entry == res then
					table.remove(list, key)
				end
			end
		end
	else
		for key,entry in pairs(list) do
			if entry == result then
				table.remove(list, key)
			end
		end
	end
	return list
end

--No longer necessary!! Simple attack loop!
--[[local attacks = {"Wall", "Creep", "Big"}
local function GetAidsAttack(d, rng)
    if d.LastAidsAttack then
        local list = RemoveEntryThroughResult(attacks, d.LastAidsAttack)
        local first = list[rng:RandomInt(#list)+1]
        local attacks2 = RemoveEntryThroughResult(attacks, first)
        local ret = GetRandomOrderedTable(attacks2, rng, {first})
        d.LastAidsAttack = ret[3]
        return ret
    else
        local ret = GetRandomOrderedTable(attacks, rng)
        d.LastAidsAttack = ret[3]
        return ret
    end
end]]

local function GetAidsNeedleInfo(wallPos, d)
	local room = game:GetRoom()
	local tl = room:GetTopLeftPos()
    local br = room:GetBottomRightPos()
    if wallPos.X <= tl.X then
        d.SyrWall = "Left"
        d.SyrDir = "Right"
		d.SyrBounds = {tl.Y, br.Y}
    elseif wallPos.X >= br.X then
        d.SyrWall = "Right"
        d.SyrDir = "Left"
		d.SyrBounds = {tl.Y, br.Y}
    elseif wallPos.Y <= tl.Y then
        d.SyrWall = "Top"
        d.SyrDir = "Down"
		d.SyrBounds = {tl.X, br.X}
    elseif wallPos.Y >= br.Y then
        d.SyrWall = "Bottom"
        d.SyrDir = "Up"
		d.SyrBounds = {tl.X, br.X}
    else
        --Horizontal is prioritized for this
        local midPoint = (room:GetBottomRightPos()+room:GetTopLeftPos())/2
        local roomShape = room:GetRoomShape()
        if math.abs(wallPos.Y-midPoint.Y) <= 20 then
            if roomShape == RoomShape.ROOMSHAPE_LTL then
                d.SyrWall = "MidLeft"
                d.SyrDir = "Down"
				d.SyrBounds = {tl.X, midPoint.X}
            elseif roomShape == RoomShape.ROOMSHAPE_LTR then
                d.SyrWall = "MidRight"
                d.SyrDir = "Down"
				d.SyrBounds = {midPoint.X, br.X}
            elseif roomShape == RoomShape.ROOMSHAPE_LBL then
                d.SyrWall = "MidLeft"
                d.SyrDir = "Up"
				d.SyrBounds = {tl.X, midPoint.X}
            elseif roomShape == RoomShape.ROOMSHAPE_LBR then
                d.SyrWall = "MidRight"
                d.SyrDir = "Up"
				d.SyrBounds = {midPoint.X, br.X}
            end
        else
            if roomShape == RoomShape.ROOMSHAPE_LTL then
                d.SyrWall = "MidUp"
                d.SyrDir = "Right"
				d.SyrBounds = {tl.Y, midPoint.Y}
            elseif roomShape == RoomShape.ROOMSHAPE_LTR then
                d.SyrWall = "MidUp"
                d.SyrDir = "Left"
				d.SyrBounds = {tl.Y, midPoint.Y}
            elseif roomShape == RoomShape.ROOMSHAPE_LBL then
                d.SyrWall = "MidDown"
                d.SyrDir = "Right"
				d.SyrBounds = {midPoint.Y, br.Y}
            elseif roomShape == RoomShape.ROOMSHAPE_LBR then
                d.SyrWall = "MidDown"
                d.SyrDir = "Left"
				d.SyrBounds = {midPoint.Y, br.Y}
            end
        end
    end
end

local function ShuntPos(int, rng)
	return Vector(mod:RandomInt(-int, int, rng), mod:RandomInt(-int, int, rng))
end

local function ProjPointGood(pos, vec)
	local room = game:GetRoom()
	local gridEnt = room:GetGridEntityFromPos(pos)
	if gridEnt and (gridEnt:GetType() == GridEntityType.GRID_WALL or gridEnt:GetType() == GridEntityType.GRID_DOOR) then
		local checkPos = gridEnt.Position+vec:Resized(40)
		local checkGrid = room:GetGridEntityFromPos(checkPos)
		if not checkGrid or checkGrid:GetType() ~= GridEntityType.GRID_WALL then
			return true
		end
	end
end

local vals = {{0.5, 0.3}, {1, 0.6}, {1.3, 0.9}, {2.1}}
local function GetCreepScaleAids(scale)
	local check = 1
	while check < 4 and scale >= vals[check][1] do
		check = check+1
	end
	local baseScale = vals[check][1]
	local extraScale = 1
	if check < 4 then
		local diff = scale/vals[check+1][1]
		extraScale = extraScale+diff*vals[check][2]*diff
	else
		extraScale = scale/vals[4][1]
	end
	return baseScale, extraScale
end

local function AidsFindCreepExit(npc, target)
	local dist = 9999
	local room = game:GetRoom()
	local chosen
	local backup = room:FindFreeTilePosition(npc.Position, 0)
	for i = 0, room:GetGridSize() - 1 do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridCollision(i) == GridCollisionClass.GRIDCOLL_NONE and npc.Position:Distance(gridpos) < dist then
			backup = gridpos
			if npc.Pathfinder:HasPathToPos(target.Position) then
				chosen = gridpos
				dist = npc.Position:Distance(gridpos)
			end
		end
	end
	return chosen or backup
end

local function FindNeedleCreepSpots(npc, pos, rng)
	local loops = (pos and 1) or 2
	local results = {}
	local syrs = Isaac.FindByType(mod.ENT.AidsCreepNeedle.ID, mod.ENT.AidsCreepNeedle.Var, 0, false, false)
	local room = game:GetRoom()
	for i = 0, room:GetGridSize() - 1 do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridCollision(i) == GridCollisionClass.COLLISION_NONE and npc.Position:Distance(gridpos) < bal.CreepSyrRad then
			local valid = true
			if pos and pos:Distance(gridpos) < bal.CreepSyrAway then
				valid = false
			end
			if valid then
				for _,syr in ipairs(syrs) do
					if syr.Position:Distance(gridpos) < bal.CreepSyrAway then
						valid = false
						break
					end
				end
			end
			if valid then
				table.insert(results, gridpos)
			end
		end
	end

	local returns = {}
	if #results > 0 then
		for i=1,loops do
			if i == 1 then
				returns[1] = results[rng:RandomInt(#results)+1]+ShuntPos(20, rng)
			else
				if #results > 1 then
					for key,entry in pairs(results) do
						if entry:Distance(returns[1]) < bal.CreepSyrAway then
							table.remove(results, key)
						end
					end
					returns[1] = results[rng:RandomInt(#results)+1]+ShuntPos(20, rng)
				end
			end
		end
	end
	return returns
end

function mod:AidsProjectileUpdate(proj, d)
	if d.projType == "AidsSplitProj" then
		if proj.FrameCount > bal.BigSplitTime then
			if d.Split <= bal.BigSplitCount then
				--local num = (d.Split == bal.BigSplitCount and 1) or 2
				local num = 2
				for i=-1,1,num do
					local vec = (proj.Position-d.OriginalPos):Rotated(i*bal.BigSplitAngle[d.Split]):Resized(bal.BigProjSpeed)
					local v = Isaac.Spawn(9, 0, 0, proj.Position, vec, proj):ToProjectile()
					v.ProjectileFlags = v.ProjectileFlags
					v.FallingSpeed = 0
					v.FallingAccel = -0.065
					v.Color = mod.Colors.MortisBloodProj
					v.Scale = proj.Scale*bal.BigSplitScale
					local pd = v:GetData()
					pd.projType = "AidsSplitProj"
					pd.Split = d.Split+1
					pd.OriginalPos = d.OriginalPos
				end
				proj:Die()
			end
		end

		proj.FallingSpeed = 0
		proj.FallingAccel = -0.065
	end
end

local ClearSpectralProj = function(a, b)
	if a.FrameCount > bal.WallBloodSpec then
		a:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
		b.customProjectileBehaviorLJ = nil
		b.projType = nil
	end
end

--mod:FindRandomValidPathPositionAir(npc, avoidPlayer, minRange, maxRange)
function mod:AIDSAI(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()
    local target = npc:GetPlayerTarget()
	local rng = npc:GetDropRNG()
	local room = game:GetRoom()
	local targetpos = mod:confusePos(npc, target.Position)

	if not d.init then
		d.NextAidsAttack = (rng:RandomInt(2) == 0 and "Big") or "Wall"
		npc.SplatColor = mod.Colors.AidsPuddle
		d.State = "Idle"
		d.MoveFrames = 0
		d.init = true
	else
		d.MoveFrames = d.MoveFrames+1
		npc.StateFrame = npc.StateFrame+1
	end

	if d.State ~= "Creep" and npc.StateFrame % bal.IdleCreepFreq == 0 then
		for i=-1,1,2 do
			local var = (mod:isFriend(npc) and EffectVariant.PLAYER_CREEP_RED) or EffectVariant.CREEP_RED
			local creep = Isaac.Spawn(1000, var, 0, npc.Position+Vector(20*i, -10), Vector.Zero, npc):ToEffect()
			creep.SpriteScale = Vector(bal.IdleCreepSize, bal.IdleCreepSize)
			creep:SetTimeout(bal.IdleCreepTime)
			creep.Color = mod.Colors.AidsPuddle
			creep:Update()
		end
	end

	if d.State == "Idle" then
		if not d.TargetPos or npc.Position:Distance(d.TargetPos) < 5 or d.MoveFrames > 60 or npc:CollidesWithGrid() or not npc.Pathfinder:HasPathToPos(d.TargetPos) then
			d.TargetPos = mod:FindRandomValidPathPosition(npc, nil, bal.WanderDist) + Vector(mod:RandomInt(-10,10,rng), mod:RandomInt(-10,10,rng))
			d.MoveFrames = 0
		end

		if mod:isScare(npc) then
			local targetvel = (target.Position - npc.Position):Resized(-bal.WanderSpeed*1.2)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.2)
		elseif d.TargetPos then
			if room:CheckLine(npc.Position, d.TargetPos, 0, 1, false, false) then
				local targetvel = (d.TargetPos - npc.Position):Resized(bal.WanderSpeed)
				npc.Velocity = mod:Lerp(npc.Velocity, targetvel, bal.WanderSlip)
			else
				npc.Pathfinder:FindGridPath(d.TargetPos, bal.WanderSpeed/6.5, 900, true)
			end
		else
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, bal.WanderSlip)
		end

		local attack = d.NextAidsAttack
		--DEBUG
		--attack = "Big"
		local time = bal[attack .. "Time"]
		local set
		if npc.StateFrame > time[1] and rng:RandomInt(time[3]) == 0 then
			set = true
		elseif npc.StateFrame > time[2] then
			set = true
		end
		if set then
			d.State = attack
			if attack == "Wall" then
				local dir = (target.Position-npc.Position)
				if math.abs(dir.X) > math.abs(dir.Y)*1.2 then
					--npc.FlipX = (npc.Position.X > target.Position.X)
					d.Direction = "Hori"
				else
					if npc.Position.Y < target.Position.Y then
						d.Direction = "Down"
					else
						d.Direction = "Up"
					end
				end
				d.FireDir = ((target.Position+target.Velocity*bal.WallAim)-npc.Position)
			elseif attack == "Creep" then
				d.SubState = "Init"
				npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
				npc:PlaySound(SoundEffect.SOUND_GASCAN_POUR, 0.4, 0, false, 1.4)
				d.CreepSize = bal.CreepInit
				d.CreepStatus = "Grow"
			elseif attack == "Big" then
				d.BigAttack = nil
			end
			npc.StateFrame = 0
		end
		
		mod:SpritePlay(sprite, "Idle01")
	elseif d.State == "Wall" then
		if sprite:IsFinished("Swing" .. d.Direction) then
			d.State = "Idle"
			npc.StateFrame = bal.WallTime[4]
			d.NextAidsAttack = "Creep"
			d.NextNextAidsAttack = "Big"
		elseif sprite:IsEventTriggered("Special") then
			npc.FlipX = d.FireDir.X < 0
		elseif sprite:IsEventTriggered("Explode") then
			npc.FlipX = false
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1)
			for i=-1,1,2 do
				local proj = npc:FireProjectilesEx(npc.Position, d.FireDir:Resized(bal.WallSyrSpeed):Rotated(i*bal.WallAng), 0, paramsNeedle)[1]
			end
			for i=1,3 do
				local par = Isaac.Spawn(1000, EffectVariant.BLOOD_PARTICLE, 0, npc.Position, d.FireDir:Resized(mod:RandomInt(20,60,rng)/10):Rotated(mod:RandomInt(-60,60,rng)), npc)
				par.Color = npc.SplatColor
				par.SplatColor = npc.SplatColor
				par:Update()
			end
		else
			mod:SpritePlay(sprite, "Swing" .. d.Direction)
		end

		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	elseif d.State == "Creep" then
		if d.SubState == "Init" then
			if sprite:IsFinished("Melt") then
				npc.StateFrame = 0
				d.SubState = "Chase"
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			elseif sprite:IsEventTriggered("Shoot") then
				d.BeginMove = true
			else
				mod:SpritePlay(sprite, "Melt")
			end

			if d.BeginMove then
				if mod:isScare(npc) then
					npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-targetpos):Resized(bal.WanderSpeed), bal.CreepSlip)
				elseif room:CheckLine(npc.Position, targetpos, 2, 0, false, false) then
					npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(bal.WanderSpeed), bal.CreepSlip)
				else
					npc.Pathfinder:FindGridPath(targetpos, bal.WanderSpeed/6.5, 0, true)
				end
			else
				npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
			end
		elseif d.SubState == "Chase" then
			if mod:isScare(npc) then
				npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-targetpos):Resized(bal.CreepSpeed), bal.CreepSlip)
			elseif room:CheckLine(npc.Position, targetpos, 2, 0, false, false) then
				npc.Velocity = mod:Lerp(npc.Velocity, (targetpos-npc.Position):Resized(bal.CreepSpeed), bal.CreepSlip)
			else
				npc.Pathfinder:FindGridPath(targetpos, bal.CreepSpeed/6.5, 0, true)
			end

			if npc.StateFrame > bal.CreepChaseTime then
				d.SubState = "TryToEnd"
				d.TargetPos = nil
			end

			mod:SpritePlay(sprite, "Idle02")
		elseif d.SubState == "TryToEnd" then
			if not d.TargetPos or room:GetGridCollisionAtPos(d.TargetPos) > GridCollisionClass.COLLISION_NONE then
				d.TargetPos = AidsFindCreepExit(npc, target)
			elseif room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_NONE then
				d.SubState = "End"
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				d.CreepStatus = "Shrink"
			else
				if room:CheckLine(npc.Position, d.TargetPos, 2, 0, false, false) then
					npc.Velocity = mod:Lerp(npc.Velocity, (d.TargetPos-npc.Position):Resized(bal.CreepSpeed), bal.CreepSlip)
				else
					npc.Pathfinder:FindGridPath(d.TargetPos, bal.CreepSpeed/6.5, 0, true)
				end
			end

			mod:SpritePlay(sprite, "Idle02")
		elseif d.SubState == "End" then
			if sprite:IsFinished("Reform") then
				npc.StateFrame = bal.CreepTime[4]
				d.SubState = nil
				d.State = "Idle"
				d.NextAidsAttack = d.NextNextAidsAttack
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
				npc:PlaySound(SoundEffect.SOUND_GASCAN_POUR, 0.4, 0, false, 1.4)
			else
				mod:SpritePlay(sprite, "Reform")
			end
			npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
		end

		if d.CreepStatus then
			if d.CreepStatus == "Grow" then
				d.CreepSize = mod:Lerp(d.CreepSize, bal.CreepMax, bal.CreepLerp)
				if npc.StateFrame > bal.CreepTransition then
					d.CreepSize = bal.CreepMax
					d.CreepStatus = "Chase"
				end
			elseif d.CreepStatus == "Shrink" then
				d.CreepSize = mod:Lerp(d.CreepSize, bal.CreepInit, bal.CreepLerp)
			else
				if npc.StateFrame % bal.CreepSyrFreq == 0 then
					local results
					if target.Position:Distance(npc.Position) < bal.CreepSyrRad then
						results = FindNeedleCreepSpots(npc, target.Position, rng)
						table.insert(results, target.Position)
						if not (target:ToPlayer() and mod:isFriend(npc)) then
							target:TakeDamage(1, 0, EntityRef(npc), 0)
						end
					else
						results = FindNeedleCreepSpots(npc, nil, rng)
					end

					for _,pos in pairs(results) do
						local needle = Isaac.Spawn(mod.ENT.AidsCreepNeedle.ID, mod.ENT.AidsCreepNeedle.Var, 0, pos, Vector.Zero, npc):ToEffect()
						needle:Update()
					end
					if npc.StateFrame % bal.CreepSyrFreq == 0 then
						if rng:RandomInt(5) > 0 then
							npc:PlaySound(SoundEffect.SOUND_GOOATTACH0, mod:RandomInt(10,20,rng)/100, 0, false, mod:RandomInt(100,120,rng)/100)
						end
					end
				end
			end

			if npc.StateFrame % bal.CreepFreq == 0 then
				local var = (mod:isFriend(npc) and EffectVariant.PLAYER_CREEP_RED) or EffectVariant.CREEP_RED
				local creep = Isaac.Spawn(1000, var, 0, npc.Position, Vector.Zero, npc):ToEffect()
				local spriteScale, scale = GetCreepScaleAids(d.CreepSize)
				creep.SpriteScale = Vector(spriteScale, spriteScale)
				creep.Scale = scale
				creep:SetTimeout(bal.CreepTimer)
				creep.Color = mod.Colors.AidsPuddle
				creep:Update()
			end
		end
	elseif d.State == "Big" then
		if sprite:IsFinished("Shoot") then
			d.State = "Idle"
			npc.StateFrame = bal.BigTime[4]
			d.NextAidsAttack = "Creep"
			d.NextNextAidsAttack = "Wall"
		elseif sprite:IsEventTriggered("Shoot") then
			if not d.BigAttack then
				d.BigAttack = true

				local poof = Isaac.Spawn(1000, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc):ToEffect()
				poof.Color = mod.Colors.MortisBlood
				poof.DepthOffset = 20
				poof.SpriteOffset = Vector(0,-10)
				poof:Update()

				for i=1,bal.BigProjCount do
					local vec = (targetpos-npc.Position):Rotated(i*360/bal.BigProjCount):Resized(bal.BigProjSpeed)
					local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
					local pd = proj:GetData()
					pd.projType = "AidsSplitProj"
					pd.OriginalPos = npc.Position
					pd.Split = 1
				end
			end
			local poof = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position+ShuntPos(10,rng), Vector.Zero, npc):ToEffect()
			poof.SpriteOffset = Vector(0, -25)
			poof.DepthOffset = 35
			poof.Color = mod.Colors.MortisBlood
			poof:Update()
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1)
			for i=1,2 do
				local par = Isaac.Spawn(1000, EffectVariant.BLOOD_PARTICLE, 0, npc.Position, Vector(mod:RandomInt(10,55,rng)/10, 0):Rotated(rng:RandomInt(360)), npc)
				par.Color = npc.SplatColor
				par.SplatColor = npc.SplatColor
				par:Update()
			end
			npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(bal.BigNeedleSpeed), 0, paramsSulfur)
		else
			mod:SpritePlay(sprite, "Shoot")
		end
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
	end
end

local dirToAng = {["Left"] = 0, ["Up"] = 90, ["Right"] = 180, ["Down"] = 270}
--Copied a bit from Sulfuric Acid Needle
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, proj)
    proj:GetSprite():Play("Projectile", true)
    proj.SpriteRotation = proj.Velocity:GetAngleDegrees()
end, mod.ENT.AidsNeedleProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    local scale = 1 + ((proj.Scale - 1) * 0.5)
    proj.SpriteScale = Vector(scale, scale)

	local d = proj:GetData()
	if not d.WallStuck then
	    proj.SpriteRotation = proj.Velocity:GetAngleDegrees()
		local room = game:GetRoom()
		local gridEnt = room:GetGridEntityFromPos(proj.Position)
		if gridEnt and (gridEnt:GetType() == GridEntityType.GRID_WALL or gridEnt:GetType() == GridEntityType.GRID_DOOR) then
			d.WallStuck = true
			mod:PlaySound(SoundEffect.SOUND_GOOATTACH0, nil, 1, 0.8)
			GetAidsNeedleInfo(gridEnt.Position, d)
			d.Orient = ((d.SyrDir == "Right" or d.SyrDir == "Left") and "Hori") or "Vert"
			if d.Orient == "Hori" then
				d.StuckPos = Vector(gridEnt.Position.X, proj.Position.Y)
			else
				d.StuckPos = Vector(proj.Position.X, gridEnt.Position.Y)
			end
			proj.Velocity = (d.StuckPos-proj.Position)
			proj.SpriteRotation = dirToAng[d.SyrDir]
			proj.Visible = false
			d.SyrVis = Isaac.Spawn(mod.ENT.AidsHelper.ID, mod.ENT.AidsHelper.Var, 0, proj.Position-proj.Velocity:Resized(40), Vector.Zero, proj):ToNPC()
			d.SyrVis.Parent = proj
			d.SyrVis:Update()
			d.SyrVis:Update()
			d.SyrVis:GetSprite():Play("HitWall", true)
			--sprite:Play("HitWall", true)
			d.State = "Init"
		end
	else
		if not d.SyrVis or not d.SyrVis:Exists() then
			d.SyrVis = Isaac.Spawn(mod.ENT.AidsHelper.ID, mod.ENT.AidsHelper.Var, 0, proj.Position+Vector(-40, 0):Rotated(dirToAng[d.SyrDir]), Vector.Zero, proj):ToNPC()
			d.SyrVis.Parent = proj
			d.SyrVis:Update()
			d.SyrVis:Update()
		end
		local sprite2 = d.SyrVis:GetSprite()
		if d.SyrDir == "Down" then
			proj.SpriteOffset = Vector(0, 16)
		elseif d.SyrDir == "Right" then
			proj.SpriteOffset = Vector(12, 0)
		elseif d.SyrDir == "Left" then
			proj.SpriteOffset = Vector(-12, 0)
		end
		if d.State == "Init" then
			if sprite2:IsFinished("HitWall") then
				d.State = "Injecting"
				if d.Orient == "Hori" then
					d.BloodPositions = {proj.Position.Y-bal.WallInit, proj.Position.Y+bal.WallInit}
					local num = (proj.Position.Y-d.SyrBounds[1] > d.SyrBounds[2]-proj.Position.Y and 1) or 2
					d.BloodTracker = {num, (num == 1 and proj.Position.Y-d.SyrBounds[1]) or d.SyrBounds[2]-proj.Position.Y}
				else
					d.BloodPositions = {proj.Position.X-bal.WallInit, proj.Position.X+bal.WallInit}
					local num = (proj.Position.X-d.SyrBounds[1] > d.SyrBounds[2]-proj.Position.X and 1) or 2
					d.BloodTracker = {num, (num == 1 and proj.Position.X-d.SyrBounds[1]) or d.SyrBounds[2]-proj.Position.X}
				end
				d.BloodWaves = {}
				local num = math.floor(0.75*bal.WallShotFreq)
				for i=1,bal.WallWaves do
					d.BloodWaves[i] = {}
					local tab = d.BloodWaves[i]
					tab.BloodSpeed = bal.WallVel[1]
					tab.BloodTracker = makeCopiedTable(d.BloodTracker)
					tab.BloodPositions = makeCopiedTable(d.BloodPositions)
					tab.FinishedDirs = {}
					tab.BloodCounts = {num, num}
					tab.Timer = (bal.WallWaveTimer*(i-1)) + 5
				end

				local rng = proj:GetDropRNG()
				local dir = Vector(-1, 0):Rotated(dirToAng[d.SyrDir])
				mod:PlaySound(SoundEffect.SOUND_POISON_HURT, nil, mod:RandomInt(120,150,rng)/100, 0.3)
				mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL, nil, mod:RandomInt(100,120,rng)/100, 0.75)
				local poof = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 2, proj.Position+dir:Resized(30), Vector.Zero, proj):ToEffect()
				poof.Color = mod.Colors.MortisBlood
				poof.DepthOffset = 60
				poof:Update()
				for i=1,3 do
					local vec = dir:Resized(mod:RandomInt(20,40,rng)/10):Rotated(mod:RandomInt(-25,25,rng))
					local splat = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 1, proj.Position+dir:Resized(10), vec, proj):ToEffect()
					splat.Color = mod.Colors.MortisBlood
				end

				sprite2:SetFrame("Blood", 1)
				sprite2:PlayOverlay("InWall")
			else
				mod:SpritePlay(sprite2, "HitWall")
			end
		elseif d.State == "Injecting" then
			if proj.FrameCount % bal.WallFreq == 0 then
				local totalDist = 0
				local rng = proj:GetDropRNG()
				local dir = Vector(-1, 0):Rotated(dirToAng[d.SyrDir])
				local stillGoing
				for key,tab in pairs(d.BloodWaves) do
					if tab.Timer and tab.Timer > 0 then
						tab.Timer = tab.Timer-1
						stillGoing = true

						if tab.Timer == 0 then
							mod:PlaySound(SoundEffect.SOUND_POISON_HURT, nil, mod:RandomInt(120,150,rng)/100, 0.3)
							mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL, nil, mod:RandomInt(100,120,rng)/100, 0.75)
							local poof = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 2, proj.Position+dir:Resized(30), Vector.Zero, proj):ToEffect()
							poof.Color = mod.Colors.MortisBlood
							poof.DepthOffset = 60
							poof:Update()
							for i=1,3 do
								local vec = dir:Resized(mod:RandomInt(20,40,rng)/10):Rotated(mod:RandomInt(-25,25,rng))
								local splat = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 1, proj.Position+dir:Resized(10), vec, proj):ToEffect()
								splat.Color = mod.Colors.MortisBlood
							end
						end
					else
						tab.BloodSpeed = math.max(bal.WallVel[2], tab.BloodSpeed+bal.WallAccel)
						for i=1,2 do
							if not tab.FinishedDirs[i] then
								stillGoing = true
								local initPos = tab.BloodPositions[i]+(tab.BloodSpeed*(-1+(-1+i)*2))
								local axisVal = (d.Orient == "Hori" and Vector(proj.Position.X, initPos)) or Vector(initPos, proj.Position.Y)
								local pos = axisVal+ShuntPos(bal.WallShunt, rng)
								local bigOne

								if tab.BloodTracker[1] == i then
									local dist
									if i == 1 then
										dist = math.max(0, initPos-d.SyrBounds[1])
									else
										dist = math.max(0, d.SyrBounds[2]-initPos)
									end
									totalDist = totalDist+((tab.BloodTracker[2]-dist)/tab.BloodTracker[2])/bal.WallWaves
									bigOne = true
								end

								if ProjPointGood(pos, dir) then
									local splat = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 1, pos, Vector.Zero, proj):ToEffect()
									splat.Color = mod.Colors.MortisBlood
									mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, nil, mod:RandomInt(110,140,rng)/100, 0.2)
									mod:ScheduleForUpdate(function()
										if rng:RandomInt(bal.WallBloodChance) > 0 then
											local newDir = dir:Resized(mod:RandomInt(bal.WallBloodSpeed[1], bal.WallBloodSpeed[2], rng)):Rotated(mod:RandomInt(-bal.WallVar, bal.WallVar, rng))
											local p = Isaac.Spawn(9, 0, 0, pos, newDir, proj):ToProjectile()
											p.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.ACCELERATE
											p.Acceleration = bal.WallBloodAccel
											p.FallingSpeed = mod:RandomInt(bal.WallBloodFall[1], bal.WallBloodFall[2], rng)
											p.FallingAccel = bal.WallBloodFAccel
											p.Scale = mod:RandomInt(bal.WallBloodScale[1], bal.WallBloodScale[2], rng)/100
											p.Color = mod.Colors.MortisBloodProj
											local pd = p:GetData()
											pd.projType = "customProjectileBehavior"
											pd.customProjectileBehaviorLJ = {customFunc = ClearSpectralProj}
										end
										tab.BloodCounts[i] = tab.BloodCounts[i]+1
										if tab.BloodCounts[i] % bal.WallShotFreq == 0 then
											local poof = Isaac.Spawn(1000, EffectVariant.BULLET_POOF, 0, pos, Vector.Zero, proj):ToEffect()
											poof.Color = Color(0, 0, 0, 0.25, 0.6, 0.3, 0.5)
											local newerDir = dir:Resized(bal.WallShotSpeed):Rotated(mod:RandomInt(-bal.WallShotAng, bal.WallShotAng, rng))
											local p2 = Isaac.Spawn(9, 0, 0, pos, newerDir, proj):ToProjectile()
											p2.ProjectileFlags = proj.ProjectileFlags
											p2.FallingSpeed = -0.5
											p2.FallingAccel = -0.05
											p2.Scale = bal.WallShotScale
											p2.Color = mod.Colors.MortisBloodProj
											local pd2 = p2:GetData()
											pd2.projType = "customProjectileBehavior"
											pd2.customProjectileBehaviorLJ = {customFunc = ClearSpectralProj}
										end
									end, bal.WallDelay)
									tab.BloodPositions[i] = initPos
								else
									if bigOne then
										tab.DoneHere = true
										totalDist = totalDist-1/bal.WallWaves
									end
									tab.FinishedDirs[i] = true
								end
							end
							if tab.DoneHere and i == 2 then
								totalDist = totalDist+1/bal.WallWaves
							end
						end
					end
					
				end
				local ratio = math.floor(bal.BloodFrames*totalDist)+1
				sprite2:SetFrame("Blood", ratio)
				sprite2:PlayOverlay("InWall")
				if not stillGoing then
					d.State = "Break"
				end
			end
		elseif d.State == "Break" then
			proj:Remove()
		end
		proj.Height = -12
		proj.Velocity = (d.StuckPos-proj.Position)
	end
	proj.FallingSpeed = 0
	proj.FallingAccel = -0.065
end, mod.ENT.AidsNeedleProjectile.Var)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() --It just crashes when you exit why is it doing that?????
	for _,proj in ipairs(Isaac.FindByType(mod.ENT.AidsNeedleProjectile.ID, mod.ENT.AidsNeedleProjectile.Var, -1, false, false)) do
		proj:GetData().WHYSTOPIT = true
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
    if proj.Variant == mod.ENT.AidsNeedleProjectile.Var and not proj:GetData().WHYSTOPIT then
        proj = proj:ToProjectile()
		local sub = (proj:GetData().WallStuck and 1) or 0
        local poof = Isaac.Spawn(mod.ENT.AidsNeedlePoof.ID, mod.ENT.AidsNeedlePoof.Var, sub, proj.Position, Vector.Zero, proj)
		poof.SpriteOffset = proj.SpriteOffset
        poof.PositionOffset = proj.PositionOffset
        poof.SpriteScale = proj.SpriteScale
        poof.SpriteRotation = proj.SpriteRotation
        poof.Color = proj.Color
		poof:GetData().SyrDir = proj:GetData().SyrDir
        poof:Update()
        mod:PlaySound(SoundEffect.SOUND_GLASS_BREAK, nil, 1.2, 0.75)
    end
end, mod.ENT.AidsNeedleProjectile.ID)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()
	if effect.SubType == 1 then
		local d = effect:GetData()
		if not d.init then
			d.init = true
			effect.Visible = false
			d.SyrVis = Isaac.Spawn(mod.ENT.AidsHelper.ID, mod.ENT.AidsHelper.Var, 0, effect.Position+Vector(-40, 0):Rotated(dirToAng[d.SyrDir]), Vector.Zero, effect):ToNPC()
			d.SyrVis.Parent = effect
			d.SyrVis:Update()
			d.SyrVis:Update()
		end

		if not d.SyrVis or not d.SyrVis:Exists() then
			effect:Remove()
		else
			local sprite2 = d.SyrVis:GetSprite()
			if sprite2:IsFinished("PoofWall") then
				effect:Remove()
			else
				mod:SpritePlay(sprite2, "PoofWall")
			end
		end
	else
		if sprite:IsFinished("Poof") then
			effect:Remove()
		else
			mod:SpritePlay(sprite, "Poof")
		end
	end
	local anim = (effect.SubType == 1 and "PoofWall") or "Poof"
    if sprite:IsFinished(anim) then
        effect:Remove()
    else
        mod:SpritePlay(sprite, anim)
    end
end, mod.ENT.AidsNeedlePoof.Var)

function mod:AidsHelper(npc)
	local d = npc:GetData()
	if not d.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_NO_KNOCKBACK |
			EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_REWARD)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		npc:UpdateDirtColor(true)
		d.init = true
	end

	if not npc.Parent or not npc.Parent:Exists() then
		npc:Remove()
	else
		local par = npc.Parent
		npc.SpriteOffset = par.SpriteOffset
		npc.PositionOffset = par.PositionOffset
		npc.SpriteRotation = par.SpriteRotation
		npc.Color = par.Color
		npc.Velocity = (par.Position-npc.Position)
	end
end

local rendered = true
local tryRender = false
mod:AddCallback(ModCallbacks.MC_PRE_RENDER, function()
	tryRender = true
	rendered = false
end)

mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_ROCK_RENDER, function()
	if tryRender then
		tryRender = false
		rendered = true
		for _,npc in ipairs(Isaac.FindByType(mod.ENT.Aids.ID, mod.ENT.Aids.Var, 0, false, false)) do
			local d = npc:GetData()
			if d.State == "Creep" and (d.SubState == "Chase" or d.SubState == "TryToEnd") then
				npc:GetSprite():Render(Isaac.WorldToScreen(npc.Position))
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, function(_, npc)
	if npc.Variant == mod.ENT.Aids.Var and rendered then
		local d = npc:GetData()
		if not npc:GetSprite():IsPlaying("Death") and d.State == "Creep" and (d.SubState == "Chase" or d.SubState == "TryToEnd") then
			return false
		end
	end
end, mod.ENT.Aids.ID)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
	if npc.Variant == mod.ENT.Aids.Var and mod:IsNormalRender() then
		local d = npc:GetData()
		local sprite = npc:GetSprite()
		if sprite:IsPlaying("Death") then
			if sprite:IsEventTriggered("Shoot") then
			elseif sprite:IsEventTriggered("Special") then
				npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
				npc:PlaySound(SoundEffect.SOUND_GASCAN_POUR, 0.4, 0, false, 1.4)
				d.AidsBleedDeath = npc.FrameCount
			elseif sprite:IsEventTriggered("Explode") then
				if not d.BloodExploded then
					npc:BloodExplode()
					local splat = Isaac.Spawn(1000, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc):ToEffect()
					splat.Color = mod.Colors.AidsPuddle
					splat.SpriteScale = Vector(3.5, 3.5)
					splat:Update()
					d.BloodExploded = true
				end
			end

			if d.AidsBleedDeath then
				if npc.FrameCount % 3 == 0 and npc.FrameCount > d.AidsBleedDeath then
					d.AidsBleedDeath = npc.FrameCount
					local rng = npc:GetDropRNG()
					local height = sprite:GetNullFrame("Height")
					local poof = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc):ToEffect()
					poof.Color = npc.SplatColor
					poof.SplatColor = npc.SplatColor
					poof.SpriteOffset = Vector(mod:RandomInt(-40,40,rng), mod:RandomInt(-20,height.Y,rng))
					poof.DepthOffset = 5
					poof:Update()
	
					npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.2, 0, false, mod:RandomInt(90,110,rng)/100)
					if npc.FrameCount % 6 == 0 then
						local splat = Isaac.Spawn(1000, EffectVariant.BLOOD_SPLAT, 0, npc.Position+ShuntPos(35,rng), Vector.Zero, npc):ToEffect()
						splat.Color = mod.Colors.AidsPuddle
						splat.SpriteScale = Vector(2, 2)
						splat:Update()
					end
				end
			end
		end
	end
end, mod.ENT.Aids.ID)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
	local d = e:GetData()
	local sprite = e:GetSprite()

	if not d.init then
		for _, grid in pairs(mod:GetGridsInRadius(e.Position, 20)) do
            if grid.CollisionClass >= GridCollisionClass.COLLISION_SOLID then
                grid:Destroy()
            end
        end
		--Not including player damage here cause it's a bit odd probably
		e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		d.init = true
	end

	if sprite:IsFinished("IdleSharp") then
		e:Remove()
	else
		mod:SpritePlay(sprite, "IdleSharp")
	end
end, mod.ENT.AidsCreepNeedle.Var)