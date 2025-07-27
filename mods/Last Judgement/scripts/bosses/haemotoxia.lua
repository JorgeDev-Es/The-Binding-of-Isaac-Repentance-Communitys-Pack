local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

--Base bomb countdown is 45
local bal = {
    PhaseThreshold = {0.53, 0.4},
    PhaseReduction = 0.5,
    WaterInc = 0.05,

    --Charge
    ChargeTime = {38,60,20,10}, --all attacks follow this formula for stateframe. min, max, chance to happen before max, stateframe it sets it to after attack ends
    ChargeSafety = 5, --thog no hit wall early
    ChargeSpeed = {3, 25, 0.9}, --Initial speed, max, velocity
    ChargeSway = 14, --How far its charge can be angled
    ChargeDirLeeway = 1.15, --Makes it a bit easier to charge vertically
    ChargeDirSwayStart = 60, --How far the player must be from a cardinal to angle
    ChargeKnockback = 5, --Knock a bit away from the wall so the second charge doesn't ruin itself
    ChargeCreep = {110, 180, 90, 110}, --Spritescale variation, Scale variation
    ChargeActive = {0.85, 0.3}, --unused
    ChargeFreq = 12,
    ChargeRand = 3,
    ChargeSplitSpeed = 16,
    ChargeFreq2 = 4,
    Charge2FallSpeed = {35,68},
    Charge2FallAccel = 0.9,
    Charge2Scale = {6,11},
    Charge2Angle = 27,
    Charge2Speed = {80,150},
    ChargeImpactShots = 4, --Fired in a semicircle, unused
    ChargeImpactSpeed = 11,
    ChargeBrimCreep = 4,
    ChargeSplitProjInterval = 6,
    ChargeSplitProjSpeed = 8,

    --Hop
    HopTime = {45, 65, 20, -5},
    HopTimes = 4,
    HopBigFreq = 5, --How often the big bullets fire, this includes frame 0
    HopSmallFreq = 2, --How often the small side bullets fire (alternates)
    HopMax = 14, --Max frames of firing (this is dependent on animation)
    HopBigTimer = 185,
    HopRotate = 48, --Increment of big bullets
    HopRotate2 = 9, --Random rotation of big
    HopSpeed = {45,155}, --Speed of big bullets
    --Side bullets not used, way too busy
    HopScale = {60, 90}, --Scale of side bullets
    HopAngle = 30, --Angle of the side bullets
    HopRotate3 = 6, --Random rotation side
    HopSmallSpeed = 10,
    --ring projs
    HopRingAmount = 6,
    HopRingRotate = 5, --How much DISTANCE it will rotate. This is arc length, not angles
    HopRingSpeed = {13, 4, 0.9},
    HopRingNum = 1,
    HopRingDelay = 5,

    --Brimstone
    BrimTime = {30, 40, 30, 5},
    BrimRotate = {1, 19},
    BrimRotateVel = 0.4,
    BrimRotateAccel = 0.25,
    BrimProj = 10,
    BrimRadius = 92, --This is radius, double it for full width/length
    BrimPlayerCheck = 45,
    BrimHeight = -600,
    BrimHurtRad = 12,
    BrimVolleyFreq = 2,
    BrimVolleyRot = 35, --divided by 10
    BrimVolleyScale = {50, 90},
    BrimFallSpeed = {-25, -15},
    BrimFallAccel = 1.2,
    BrimBombTimer = 53,

    --Bomb
    BombHeight = -66,
    BombHeight2 = -20,
    BombAccel = 1,
    BombUpVel = -8,
    BombAngle = 55, --After starting attack, cannot attack outside this range horizontally (doubled)
    BombSpeed = 0.055, --It's the thing that scales with distance
    BombOffset = Vector(-60,0),
    BombOffset2 = Vector(10, 0),
    BombCreepSize = 3.3,
    BombCountdown = 38,
    BombTimeout = 45, --First bomb lingers a bit instead of immediately disappearing as the enemy attacks
    BombCollHeight = -30,
    BombRadius = 85, --For the Hop bullets, 75 is default.

    --mid downtime relocation for phase 2
    MoveDistMin = 120,
    MoveDistMax = 360,
    MoveCreepTimeout = 55,
    MoveRand = 2,
    MoveNeed = 180,

    --Plus
    PlusTime = {30, 45, 25, 0},
    PlusShots = 2,
    PlusShotStagger = 5,
    PlusShotSpeed = 0.05,
    PlusAvoid = {120,80}, --Tries to avoid putting two shots within this range of eachother
    PlusCountdown = {0, 12, 20}, --Countdown, Warn, Fullspeed
    PlusCreepSmall = 16, --Creep position incremenent
    PlusCreepFast = 20,
    PlusCreepLoops = 2,
    PlusBrimNum = 2, --actually 3
    PlusBrimAim = 20, --Multiply target vel by this
    PlusBrimAimMax = 100,
    PlusTracerDur = 15,
    PlusBrimDur = 10,
    PlusTimeout = 20,
    PlusOffset = Vector(18, -16),
    PlusMaxJumps = 4,

    CreepShotChance = 5, --only happen at 0
    CreepShotVel = {20, 45},
    CreepShotAng = 25,
    CreepSplatVel = {5, 22},
    CreepFall = {-6,-2},
    CreepAccel = 1.2,
    CreepScale = {75, 100},
    CreepFreq = 3,
    CreepPlayerAvoid = 150,

    --Ring
    RingTime = {40, 55, 25, -5},
    RingUnderTime = -1,
    RingJumpFrames = 16,
    RingCreepTimeout = 50,
    RingRingNumber = 8,
    RingProjSpeed = 9.5,
    RingProjAccel = 0.965,
    RingProjMin = 4,
	RingSplitTime = 24,
	RingSplitAngle = {45,33},
	RingSplitCount = 2,
	RingSplitScale = 0.75,
    RingSplitWarn = 0.45,
    RingTimeout = 20,

    --Clot
    ClotTime = {35, 50, 22, 0},
    ClotTimeout = 30,
    ClotTracerDur = 9,
    ClotCreepAng = 31,
    ClotEffOffset = Vector(0, -20),
    ClotShootSpeed = 7,
    ClotCreepLoop = 2,
    ClotCreepInc = 20,
    ClotRebound = -0.33,
    ClotSuckSpeed = {2.5, 5.5},
    ClotSuckAccel = 0.1,
    ClotAbsorbDist = 35,
    ClotProjFreq1 = 9,
    ClotProjAngle1 = 115,
    ClotProjSpeed1 = {50, 75},
    ClotProjScale1 = {60, 100},
    ClotProjFreq2 = 23,
    ClotProjNum2 = 9,
    ClotProjSpeed2 = 4.6,
    ClotProjScale2 = {0.6, 1},

    --Ferro creep spikes
    FerroFrames = {2, 4}, --How long it takes to change frames
    FerroPlayer = {20, 100},
    FerroSpacing = 16, --Distance between spikes
    FerroSafety = 8, --Safety net for spikes to not be placed around borders
    FerroActive = {0.85, 0.6, 0.2}, --Ratio of "active" spikes and what visuals they should have
    FerroShift = 4, --Random movement shifting
    FerroRad = 6, --Distance spikes can shift about
    FerroHurt = 15, --Distance that spikes will hit players in
    FerroSpikeDelay = 3, --Slight delay so that it doesn't look weird sprouting spikes so quick
    FerroCooldown = 20,
    FerroSpikeFreq = 10,
}

local HaemoCreepProjColor = Color(0.55, 0.5, 0.5, 1, 0, 0, 0, 3.5, 0.75, 0.55, 1)

local ChargePopParams = ProjectileParams()
ChargePopParams.FallingSpeedModifier = -0.05
ChargePopParams.FallingAccelModifier = -0.05
ChargePopParams.Scale = 1.85
ChargePopParams.HeightModifier = -20
ChargePopParams.Color = HaemoCreepProjColor

ChargeImpactParams = ProjectileParams()

local HopBigParams = ProjectileParams()
HopBigParams.FallingSpeedModifier = -0.05
HopBigParams.FallingAccelModifier = -0.05
HopBigParams.Scale = 2.25
HopBigParams.BulletFlags = HopBigParams.BulletFlags | ProjectileFlags.BOUNCE

local HopSmallParams = ProjectileParams()
HopSmallParams.FallingSpeedModifier = -0.05
HopSmallParams.FallingAccelModifier = -0.05

local PlusShotParams = ProjectileParams()
PlusShotParams.FallingAccelModifier = 1.5
PlusShotParams.FallingSpeedModifier = -20
PlusShotParams.Scale = 2
PlusShotParams.Color = HaemoCreepProjColor

local RingShotParams = ProjectileParams()
RingShotParams.FallingSpeedModifier = -0.05
RingShotParams.FallingAccelModifier = -0.05
RingShotParams.Scale = 2.3

local CreepShotParams = ProjectileParams()
CreepShotParams.FallingAccelModifier = bal.CreepAccel
CreepShotParams.HeightModifier = -5

local function ShuntPos(int, rng)
	return Vector(mod:RandomInt(-int, int, rng), mod:RandomInt(-int, int, rng))
end

--We're using this again from Aids/Deluge
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

local attacks1 = {"Charge", "Hop", "Brim"}
local attacks2 = {"Plus", "Ring", "Clot"}
local function GetHaemoAttack(d, rng, attacks)
    if d.LastHaemoAttack then
        local list = RemoveEntryThroughResult(attacks, d.LastHaemoAttack)
        local first = list[rng:RandomInt(#list)+1]
        local attacksNew = RemoveEntryThroughResult(attacks, first)
        local ret = GetRandomOrderedTable(attacksNew, rng, {first})
        d.LastHaemoAttack = ret[3]
        return ret
    else
        local ret = GetRandomOrderedTable(attacks, rng)
        d.LastHaemoAttack = ret[3]
        return ret
    end
end

local playedSplitSound
local FloatingChargeProj = function(proj, tab)
    local d = proj:GetData()
	if proj.Parent and proj.Parent:Exists() then
        local rng = proj:GetDropRNG()
        if not d.HaemoFrames then
            d.HaemoFrames = rng:RandomInt(20)
        end

        local stayUp = -0.08
        if proj.Parent:GetData().State and proj.Parent:GetData().State == "Poking" then
            stayUp = 0.2
        end

        proj.FallingSpeed = stayUp+math.sin((proj.FrameCount+d.HaemoFrames)/9)/2
        proj.FallingAccel = 0

        local max = 100
        if proj.FrameCount % 2 == 0 then
            local num = math.max(0.55, (max-proj.FrameCount)/max)
            if num == 0.55 then
                local vel = Vector(0, 1):Rotated(rng:RandomInt(360))
                local circle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, proj.Position, vel, proj):ToEffect()
                circle.SpriteOffset = Vector(0, proj.Height*0.65)
                circle.SpriteScale = proj.SpriteScale*0.75
                circle:SetTimeout(45)
                circle.DepthOffset = proj.DepthOffset-45
            else
                for i=1,4 do
                    local vel = Vector(num*6, 0):Rotated(90*i)
                    local circle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, proj.Position, vel, proj):ToEffect()
                    circle.SpriteOffset = Vector(0, proj.Height*0.65)
                    local sca = 0.3+num/1.3
                    circle.SpriteScale = Vector(sca, sca)
                    circle:SetTimeout(45)
                    circle.DepthOffset = proj.DepthOffset-45
                end
            end
        end

        if proj.Position:Distance(proj.Parent.Position) < 5 then
            proj.Velocity = proj.Parent.Position-proj.Position
        else
            local vel = (proj.Parent.Position-proj.Position):Resized(3)
            proj.Velocity = mod:Lerp(proj.Velocity, vel, 0.2)
        end
    elseif proj.FrameCount > 1 then
        proj.FallingSpeed = -3
        proj.FallingAccel = 1.1
        d.customProjectileBehaviorLJ.customFunc = nil
    end
end

local FloatingChargeDeath = function(proj, tab)
    for i=1,4 do
        local split = Isaac.Spawn(9, 0, 0, proj.Position, Vector(bal.ChargeSplitSpeed, 0):Rotated(90*i), proj):ToProjectile()
        split.FallingSpeed = -0.5
        split.Height = math.floor(proj.Height*0.66)
        split.ProjectileFlags = proj.ProjectileFlags
    end

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, proj.Position, Vector.Zero, proj):ToEffect()
    poof.SpriteOffset = Vector(0, math.floor(proj.Height*0.66))
    poof.Color = Color(0.5, 0.2, 0.2, 0.9, 0.3, 0, 0, 1, 0, 0, 1)
    poof.SpriteScale = Vector(1.6, 1.6)
end

local Spinning = function(proj, tab)
    if proj.FrameCount < 200 then
        proj.FallingSpeed = 0
        proj.FallingAccel = 0
    end

    local targetpos = tab.Origin+tab.OriginVel:Resized(tab.Dist):Rotated(tab.Ang)
    proj.Velocity = (targetpos-proj.Position)
    local ang = 0
    if tab.Dist > 0 then
        ang = 360*bal.HopRingRotate/(2*math.pi*tab.Dist)
    end
    tab.Dist = tab.Dist+tab.Speed
    tab.Ang = tab.Ang+ang*tab.Direction
    tab.Speed = math.max(bal.HopRingSpeed[2], tab.Speed*bal.HopRingSpeed[3])
end

local HopLarge = function(proj, tab)
    local d = proj:GetData()
    if d.HaemotoxiaDetonate then
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
        --local rangle = proj:GetDropRNG():RandomInt(360)
        for k=1,bal.HopRingNum do
            mod:ScheduleForUpdate(function()
                for j=-1,1,2 do
                    for i=1,bal.HopRingAmount do
                        local vec = Vector(0, -bal.HopRingSpeed[1]):Rotated(i*(360/bal.HopRingAmount))
                        local ring = Isaac.Spawn(9, 0, 0, proj.Position, vec, proj):ToProjectile()
                        local pd = ring:GetData()
                        pd.customProjectileBehaviorLJ = {customFunc = Spinning, Direction = j, Origin = proj.Position, OriginVel = vec, Ang = 0, Speed = bal.HopRingSpeed[1], Dist = 0}
                        pd.projType = "customProjectileBehavior"
                        ring.ProjectileFlags = proj.ProjectileFlags
                        ring:ClearProjectileFlags(ProjectileFlags.BOUNCE)
                    end
                end
            end, k*bal.HopRingDelay)
        end
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, proj.Position, Vector.Zero, proj):ToEffect()
        poof.Color = mod.Colors.HaemotoxiaCreep
        poof.SpriteOffset = Vector(0, proj.Height*0.65)
        poof.SpriteScale = Vector(0.8, 1)
        proj:Die()
    elseif proj.FrameCount < bal.HopBigTimer and not d.JustFallDown then
        local rng = proj:GetDropRNG()
        proj.FallingAccel = 0
        proj.FallingSpeed = -0.065

        proj.Velocity = mod:Lerp(proj.Velocity, Vector.Zero, 0.05)

        if proj.FrameCount % 10 == 0 then
            --[[local vel = Vector(0, mod:RandomInt(5, 15, rng)/10):Rotated(rng:RandomInt(360))
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, proj.Position, vel, proj):ToEffect()
            poof.Color = Color(0.5, 0.2, 0.2, 0.35, 0.3, 0, 0, 1, 0, 0, 1)
            poof.SpriteScale = Vector(1.5, 1.5)
            poof.SpriteOffset = Vector(0, proj.Height*0.65)
            poof.DepthOffset = proj.DepthOffset-15]]

            local vel = Vector(mod:RandomInt(6, 25, rng)/10, 0):Rotated(rng:RandomInt(360))
            local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, proj.Position+ShuntPos(5, rng), vel, proj):ToEffect()
            drop.PositionOffset = Vector(0, proj.Height)
            drop.Color = mod.Colors.HaemotoxiaCreep
            drop.FallingSpeed = mod:RandomInt(-7, 15, rng)/10
            drop.DepthOffset = -10
        end
        if proj.FrameCount % 4 == 0 then
            local circle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, proj.Position, Vector(0, 2):Rotated(mod:RandomInt(-5,5,rng)), proj):ToEffect()
            circle.SpriteOffset = Vector(0, proj.Height*0.65)
            circle.SpriteScale = Vector(0.6, 0.6)
            circle.Color = mod.Colors.HaemotoxiaCreep
            circle:SetTimeout(25)
            circle.DepthOffset = -15
            circle:Update()
        end
    else
        proj.FallingSpeed = -3
        proj.FallingAccel = 1.1
        d.customProjectileBehaviorLJ = nil
    end
end

local Wiggle = function(proj, tab)
    local thingy = (tab.Dir or 1)*3*math.sin(math.rad(proj.FrameCount*10))
    proj.Velocity = proj.Velocity:Rotated(thingy)
    proj.FallingSpeed = -0.05
    proj.FallingAccel = 0
end

local PlusShot = function(proj, tab)
    if proj.FrameCount % 2 == 0 then
        local rng = proj:GetDropRNG()
        local vel = Vector(0, 1):Rotated(rng:RandomInt(360))
        local circle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, proj.Position, vel, proj):ToEffect()
        circle.SpriteOffset = Vector(0, proj.Height*0.65)
        circle.SpriteScale = proj.SpriteScale*0.7
        circle:SetTimeout(45)
        circle.DepthOffset = proj.DepthOffset-45
    end
end

local PlusShotBreaks = {}
local PlusShotDeath = function(proj, tab)
    if not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
        local rng = proj:GetDropRNG()
        for i=1,4 do
            local vel = Vector(bal.CreepSplatVel[1], bal.CreepSplatVel[2], rng)/10
            local p = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, proj.Position, vel, proj):ToProjectile()
            p.ProjectileFlags = proj.ProjectileFlags
            p.Scale = mod:RandomInt(bal.CreepScale[1], bal.CreepScale[2], rng)/100
            p.FallingAccel = bal.CreepAccel
            p.FallingSpeed = mod:RandomInt(bal.CreepFall[1], bal.CreepFall[2], rng)
            p:Update()
        end
        table.insert(PlusShotBreaks, {Pos = proj.Position, Timer = 0, Count = 1, CreepDist = 0, RNG = rng, Vel = 0, FrameCount = 0, Proj = proj})
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function()
    PlusShotBreaks = {}
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local room = game:GetRoom()
    for key,entry in pairs(PlusShotBreaks) do
        if entry.Timer < bal.PlusCountdown[entry.Count] then
            if entry.Count == 1 then
                entry.Timer = entry.Timer+entry.Vel
                entry.Vel = entry.Vel+0.15
                if entry.FrameCount % 2 == 0 then
                    local max = bal.PlusCountdown[entry.Count]
                    local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, entry.Pos, Vector.Zero, entry.Proj):ToEffect()
                    eff.DepthOffset = 50
                    eff.SpriteRotation = entry.RNG:RandomInt(360)
                    eff.SpriteOffset = ShuntPos(10, entry.RNG)
                    eff.Color = Color(1, math.max(0, math.max(0, (200-entry.Timer*5)/255)), math.max(0, (150-entry.Timer*5)/255), 0.9, (40+(entry.Timer*5))/255, 0, 0)
                    local scale = (max-entry.Timer)/max
                    eff.SpriteScale = Vector(scale, scale)
                    eff:Update()
                end
                if entry.FrameCount % 3 == 0 then
                    sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 0.5, 0, false, mod:RandomInt(110,125,entry.RNG)/100)
                end
            elseif entry.Count == 2 then
                entry.Timer = entry.Timer+1
                if entry.FrameCount % 2 == 0 then
                    for i=1,4 do
                        local targPos = entry.Pos+Vector(entry.CreepDist, 0):Rotated(i*90)
                        if room:IsPositionInRoom(targPos, 0) then
                            local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, targPos, Vector.Zero, entry.Proj):ToEffect()
                            creep:Update()
                            local pos = targPos+ShuntPos(10, entry.RNG)
                            local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, pos, Vector.Zero, entry.Proj):ToEffect()
                            splash.SpriteScale = Vector(1, 0.75)
                            splash:Update()

                            if entry.RNG:RandomInt(bal.CreepShotChance) == 0 then
                                local speed = mod:RandomInt(bal.CreepShotVel[1], bal.CreepShotVel[2], entry.RNG)/10
                                local vel = Vector(speed, 0):Rotated(i*90+mod:RandomInt(-bal.CreepShotAng, bal.CreepShotAng, entry.RNG))
                                local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pos, vel, entry.Proj):ToProjectile()
                                proj.Scale = mod:RandomInt(bal.CreepScale[1], bal.CreepScale[2], entry.RNG)/100
                                proj.FallingAccel = bal.CreepAccel
                                proj.FallingSpeed = mod:RandomInt(bal.CreepFall[1], bal.CreepFall[2], entry.RNG)
                                proj:Update()
                            end
                        end
                    end
                    entry.CreepDist = entry.CreepDist+bal.PlusCreepSmall
                end
            elseif entry.Count == 3 then
                local yay
                for j=1,bal.PlusCreepLoops do
                    entry.CreepDist = entry.CreepDist+bal.PlusCreepFast
                    for i=1,4 do
                        if not entry.InvalidDirs[i] then
                            local targPos = entry.Pos+Vector(entry.CreepDist, 0):Rotated(i*90)
                            if room:IsPositionInRoom(targPos, 0) then
                                yay = true
                                local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, targPos, Vector.Zero, entry.Proj):ToEffect()
                                creep:Update()
                                local pos = targPos+ShuntPos(10, entry.RNG)
                                local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, pos, Vector.Zero, entry.Proj):ToEffect()
                                splash.SpriteScale = Vector(1, 0.75)
                                splash:Update()

                                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, pos, Vector.Zero, entry.Proj):ToEffect()
                                splat.Color = mod.Colors.HaemotoxiaCreep

                                if entry.RNG:RandomInt(bal.CreepShotChance) == 0 then
                                    local speed = mod:RandomInt(bal.CreepShotVel[1], bal.CreepShotVel[2], entry.RNG)/10
                                    local vel = Vector(speed, 0):Rotated(i*90+mod:RandomInt(-bal.CreepShotAng, bal.CreepShotAng, entry.RNG))
                                    local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, pos, vel, entry.Proj):ToProjectile()
                                    proj.Scale = mod:RandomInt(bal.CreepScale[1], bal.CreepScale[2], entry.RNG)/100
                                    proj.FallingAccel = bal.CreepAccel
                                    proj.FallingSpeed = mod:RandomInt(bal.CreepFall[1], bal.CreepFall[2], entry.RNG)
                                    proj:Update()
                                end
                            else
                                entry.InvalidDirs[i] = true
                            end
                        end
                    end
                    if not yay then
                        PlusShotBreaks[key] = nil
                    end
                end
            end
        else
            if entry.Count < #bal.PlusCountdown then
                entry.Count = entry.Count+1
                entry.Timer = 0
                if entry.Count == 2 then
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, entry.Pos, Vector.Zero, entry.Proj):ToEffect()
                    poof.Color = HaemoCreepProjColor
                    entry.InvalidDirs = {}
                    sfx:Play(SoundEffect.SOUND_POISON_HURT, 0.65, 0, false, 1.2)
                    sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.45, 0, false, 0.95)
                end
            else
                PlusShotBreaks[key] = nil
            end
        end
        entry.FrameCount = entry.FrameCount+1
    end
end)

local function FindPlusSpots(npc)
    local rng = npc:GetDropRNG()
    local results = {}
    local valids = {}
    local fullValids = {}
	local room = game:GetRoom()
	for i = 0, room:GetGridSize() - 1 do
		local gridpos = room:GetGridPosition(i)
        if room:GetGridCollision(i) == GridCollisionClass.COLLISION_NONE then
            table.insert(valids, gridpos)
            table.insert(fullValids, gridpos)
        end
    end
    for i=1,bal.PlusShots do
        if #fullValids == 0 then
            break
        end
        if i == 1 then
            table.insert(results, valids[rng:RandomInt(#valids)+1])
        else
            local check = results[#results]
            local superValid = {}
            for _,spot in ipairs(valids) do
                if math.abs(spot.X - check.X) > bal.PlusAvoid[1] and  math.abs(spot.Y - check.Y) > bal.PlusAvoid[2] then
                    table.insert(superValid, spot)
                end
            end
            valids = superValid

            if #valids > 0 then
                table.insert(results, valids[rng:RandomInt(#valids)+1]+ShuntPos(10, rng))
            else --ehhh, this shouldn't be triggering normally but backup
                table.insert(results, fullValids[rng:RandomInt(#fullValids)+1]+ShuntPos(10, rng))
            end
        end
    end

    if #results > 0 then
        return results
    else
        return {npc.Position}
    end
end

--Just copying over from AIDS cause nesting the custom projectile behavior thing is annoying
function mod:HaemotoxiaProjectileUpdate(proj, d)
	if d.projType == "HaemotoxiaSplitProj" then
        if not d.MaxSplitCount then
            if proj.FrameCount > bal.RingSplitTime then
                --local num = (d.Split == bal.RingSplitCount and 1) or 2
                local num = 1
                for i=-1,1,num do
                    local vec = (proj.Position-d.OriginalPos):Rotated(i*bal.RingSplitAngle[d.Split]):Resized(bal.RingProjSpeed)
                    local v = Isaac.Spawn(9, 0, 0, proj.Position, vec, proj):ToProjectile()
                    v.ProjectileFlags = v.ProjectileFlags
                    v.FallingSpeed = 0
                    v.FallingAccel = -0.065
                    v.Scale = proj.Scale*bal.RingSplitScale
                    local new = d.Split+1
                    local pd = v:GetData()
                    pd.projType = "HaemotoxiaSplitProj"
                    pd.Split = d.Split+1
                    pd.OriginalPos = d.OriginalPos
                    if new > bal.RingSplitCount then
                        pd.MaxSplitCount = true
                    end
                end
                if not playedSplitSound then
                    playedSplitSound = true
                    sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
                    mod:ScheduleForUpdate(function()
                        playedSplitSound = nil
                    end, 3)
                end
                proj:Die()
            elseif (bal.RingSplitTime-proj.FrameCount)/bal.RingSplitTime <= bal.RingSplitWarn then
                proj.Color = Color.Lerp(proj.Color, Color(0.2, 0.2, 0.2, 1, 0.45, 0, 0, 2, 0.6, 0.6, 1), 0.1)
            end
        end
        
        if proj.Velocity:Length() > bal.RingProjMin then
            proj.Velocity = proj.Velocity*bal.RingProjAccel
        end

		proj.FallingSpeed = 0
		proj.FallingAccel = -0.065
	end
end

local function FindNewLandSpot(npc, rng)
    local room = game:GetRoom()
    local center = room:GetCenterPos()
    local dist = npc.Position:Distance(center)
    local results = {}
    local players = {}
    for i = 1, game:GetNumPlayers() do
        local p = Isaac.GetPlayer(i-1)
        table.insert(players, p)
    end
	for i = 0, room:GetGridSize() - 1 do
		local gridpos = room:GetGridPosition(i)
        if room:GetGridCollision(i) == GridCollisionClass.COLLISION_NONE and gridpos:Distance(center) < dist and
        (npc.Position:Distance(gridpos) > bal.MoveDistMin and npc.Position:Distance(gridpos) < bal.MoveDistMax)  and
        npc.Position:Distance(center) > npc.Position:Distance(gridpos) then
            local noway
            for _,player in ipairs(players) do
                if player.Position:Distance(gridpos) < bal.CreepPlayerAvoid then
                    noway = true
                    break
                end
            end
            if not noway then
                table.insert(results, gridpos)
            end
        end
    end
    if #results > 0 then
        return results[rng:RandomInt(#results)+1]
    end
end

function mod:HaemotoxiaAI(npc, sprite, d)
    local target = npc:GetPlayerTarget()
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not d.init then
        d.State = "Idle"
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks1)
        npc.SplatColor = mod.Colors.HaemotoxiaCreep
        d.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if not d.Phase2ed then
        local frac = npc.HitPoints/npc.MaxHitPoints
        if frac < bal.PhaseThreshold[2] or 1 == 0 then
            d.Phase2 = true
            d.DamageMitigation = true
        elseif frac < bal.PhaseThreshold[1] then
            d.Phase2 = true
            d.DamageNegation = true
        end
    else
        mod:NegateKnockoutDrops(npc)
    end

    if d.State == "Idle" then
        if d.ShotFirstBomb then
            local nextAttack = d.HaemotoxiaAttackQueue[1]
            --nextAttack = "Brim"

            local tab = bal[nextAttack .. "Time"]
            local active
            if npc.StateFrame > tab[2] then
                active = true
            elseif npc.StateFrame > tab[1] and rng:RandomInt(tab[3]) == 0 then
                active = true
            end

            if d.Phase2 then
                d.State = "PhaseChange"
                for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                    if not creep:GetData().RemoveFerro and not creep:GetData().SpecialTimeout and not creep:GetData().HaemoMainPuddle then
                        creep:GetData().RemoveFerro = true
                        creep:ToEffect():SetTimeout(1)
                    end
                end
                for _,proj in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, 0, 0, false, false)) do
                    if proj:GetData().HaemotoxiaBombShot then
                        proj:GetData().JustFallDown = true
                    end
                end
            elseif active then
                d.State = nextAttack
                if nextAttack == "Charge" then
                    d.ChargeState = "Begin"
                    d.ChargeNum = 0
                    local dir
                    local swayDir = 0
                    if math.abs(target.Position.X - npc.Position.X) >= math.abs(target.Position.Y - npc.Position.Y)*bal.ChargeDirLeeway then
                        dir = (target.Position.X > npc.Position.X and Vector(1, 0)) or Vector(-1, 0)
                        if math.abs(target.Position.Y-npc.Position.Y) > bal.ChargeDirSwayStart then
                            swayDir = ((target.Position.Y > npc.Position.Y and 1) or -1)*dir.X
                        end
                        d.ChargeAnim = "Hori"
                        npc.FlipX = target.Position.X < npc.Position.X
                    else
                        dir = (target.Position.Y > npc.Position.Y and Vector(0, 1)) or Vector(0, -1)
                        if math.abs(target.Position.X-npc.Position.X) > bal.ChargeDirSwayStart then
                            swayDir = ((target.Position.X > npc.Position.X and -1) or 1)*dir.Y
                        end
                        d.ChargeAnim = (target.Position.Y > npc.Position.Y and "Down") or "Up"
                    end
                    local sway = bal.ChargeSway
                    local diff = mod:GetAbsoluteAngleDifference(dir, (target.Position-npc.Position))
                    if diff < sway then
                        sway = diff
                    end
                    d.ChargeDir = dir:Rotated(sway*swayDir)
                elseif nextAttack == "Hop" then
                    d.HopNum = 0
                    d.ChosenPos = nil
                elseif nextAttack == "Brim" then
                    local playerTarget = target
                    if game:GetNumPlayers() > 1 and not mod:isCharm(npc) then
                        local dist = 9999
                        for i = 1, game:GetNumPlayers() do
                            local p = Isaac.GetPlayer(i-1)
                            if p:Distance(room:GetCenterPos()) < dist then
                                playerTarget = p
                                dist = p:Distance(room:GetCenterPos())
                            end
                        end
                    end
                    d.ChosenTarget = playerTarget
                    d.HaemoWarningLaser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 2, playerTarget.Position, Vector.Zero, npc):ToLaser()
                    d.HaemoWarningLaser.Radius = bal.BrimRadius
                    d.HaemoWarningLaser.Color = Color(1, 1, 1, 0.3, 0, 0, 0, 1, 1, 1, 1)
                    d.HaemoWarningLaser:AddTearFlags(TearFlags.TEAR_CONTINUUM)
                    d.HaemoWarningLaser:GetData().HaemoSpecialerLaser = Color(1, 1, 1, 0.05, 0, 0, 0, 1, 1, 1, 1)
                    d.HaemoWarningLaser:GetData().HaemoSpecialLaser = true
                    d.HaemoWarningLaser.Parent = playerTarget
                    d.HaemoWarningLaser:Update()
                    d.HaemoWarningLaser:Update()
                    sfx:Stop(SoundEffect.SOUND_LASERRING_STRONG) --:DDDDDDDDD
                    sfx:Stop(SoundEffect.SOUND_BLOOD_LASER)
                end

                for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                    if not creep:GetData().RemoveFerro and (not creep:GetData().SpecialTimeout or creep:GetData().StillRemovePlease) and not creep:GetData().HaemoMainPuddle then
                        creep:GetData().RemoveFerro = true
                        creep:ToEffect():SetTimeout(1)
                    end
                end
                for _,proj in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, 0, 0, false, false)) do
                    if proj:GetData().HaemotoxiaBombShot then
                        proj:GetData().JustFallDown = true
                    end
                end
                for _,bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB, 0, 0, false, false)) do
                    if bomb:GetData().HaemotoxiaBloodBomb then
                        bomb:GetData().SpecialTimeout = 20
                    end
                end
            end
        else
            d.State = "ShootBomb"
        end

        if not d.Phase2 then
            mod:SpritePlay(sprite, "Idle")
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif d.State == "Charge" then
        if d.ChargeState == "Begin" then
            if sprite:IsFinished("ChargeStart" .. d.ChargeAnim) then
                d.ChargeState = "Charging"
            elseif sprite:IsEventTriggered("Land") then
                npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, mod:RandomInt(190,210,rng)/100)
                npc:PlaySound(SoundEffect.SOUND_GASCAN_POUR, 0.4, 0, false, mod:RandomInt(110,125,rng)/100)

                local null = sprite:GetNullFrame("EffectGuide"):GetPos()
                d.HaemoLaser = EntityLaser.ShootAngle(LaserVariant.THICK_RED, npc.Position, d.ChargeDir:GetAngleDegrees()+180, 999, Vector.Zero, npc)
                if npc.FlipX == true then
                    null = Vector(-null.X, null.Y)
                end
                d.HaemoLaser.ParentOffset = null*1.5
                d.HaemoLaser:Update()
                d.Charging = 0

                local vec = (d.HaemoLaser.EndPoint-npc.Position)
                for i=bal.ChargeBrimCreep, vec:Length(), bal.ChargeBrimCreep do
                    local pos = npc.Position+vec:Resized(i*bal.ChargeBrimCreep)
                    if room:IsPositionInRoom(pos, 0) then
                        local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, pos, Vector.Zero, npc):ToEffect()
                        if rng:RandomInt(6) > 0 then
                            creep:GetData().CustomFerroActive = bal.ChargeActive
                        end
                        creep:Update()
                        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, pos, Vector.Zero, npc):ToEffect()
                        splat.Color = mod.Colors.HaemotoxiaCreep
                    else
                        break
                    end
                end

                d.ChargeSpeed = bal.ChargeSpeed[1]
                npc.StateFrame = 0
                d.PrevMass = npc.Mass
                npc.Mass = 999
            else
                mod:SpritePlay(sprite, "ChargeStart" .. d.ChargeAnim)
            end
        elseif d.ChargeState == "Charging" then
            mod:SpritePlay(sprite, "Charge" .. d.ChargeAnim .. "Loop")
        elseif d.ChargeState == "Stop" then
            if sprite:IsFinished("ChargeEnd" .. d.ChargeAnim) then
                --[[d.State = "ShootBomb"
                d.ShootBombEndFunc = function()
                    if d.ChargeNum == 1 then
                        local dir
                        local swayDir = 0
                        d.State = "Charge"
                        if d.ChargeAnim == "Hori" then
                            d.ChargeAnim = (target.Position.Y > npc.Position.Y and "Down") or "Up"
                            dir = (target.Position.Y > npc.Position.Y and Vector(0, 1)) or Vector(0, -1)
                            if math.abs(target.Position.X-npc.Position.X) > bal.ChargeDirSwayStart then
                                swayDir = ((target.Position.X > npc.Position.X and -1) or 1)*dir.Y
                            end
                        else
                            npc.FlipX = (target.Position.X < npc.Position.X and true) or false
                            d.ChargeAnim = "Hori"
                            dir = (target.Position.X > npc.Position.X and Vector(1, 0)) or Vector(-1, 0)
                            if math.abs(target.Position.Y-npc.Position.Y) > bal.ChargeDirSwayStart then
                                swayDir = ((target.Position.Y > npc.Position.Y and 1) or -1)*dir.X
                            end
                        end
        
                        local sway = bal.ChargeSway
                        local diff = mod:GetAbsoluteAngleDifference(dir, (target.Position-npc.Position))
                        if diff < sway then
                            sway = diff
                        end
                        d.ChargeDir = dir:Rotated(sway*swayDir)
                        d.ChargeState = "Begin"
                    elseif d.ChargeNum == 2 then
                        d.State = "ChargeJump"
                    end
                end]]
                if d.Phase2 and d.ChargeNum == 1 then
                    d.State = "ChargeJump"
                elseif d.ChargeNum == 1 then
                    local dir
                    local swayDir = 0
                    d.State = "Charge"
                    if d.ChargeAnim == "Hori" then
                        d.ChargeAnim = (target.Position.Y > npc.Position.Y and "Down") or "Up"
                        dir = (target.Position.Y > npc.Position.Y and Vector(0, 1)) or Vector(0, -1)
                        if math.abs(target.Position.X-npc.Position.X) > bal.ChargeDirSwayStart then
                            swayDir = ((target.Position.X > npc.Position.X and -1) or 1)*dir.Y
                        end
                    else
                        npc.FlipX = (target.Position.X < npc.Position.X and true) or false
                        d.ChargeAnim = "Hori"
                        dir = (target.Position.X > npc.Position.X and Vector(1, 0)) or Vector(-1, 0)
                        if math.abs(target.Position.Y-npc.Position.Y) > bal.ChargeDirSwayStart then
                            swayDir = ((target.Position.Y > npc.Position.Y and 1) or -1)*dir.X
                        end
                    end
    
                    local sway = bal.ChargeSway
                    local diff = mod:GetAbsoluteAngleDifference(dir, (target.Position-npc.Position))
                    if diff < sway then
                        sway = diff
                    end
                    d.ChargeDir = dir:Rotated(sway*swayDir)
                    d.ChargeState = "Begin"
                elseif d.ChargeNum == 2 then
                    d.State = "ChargeJump"
                end
            else
                mod:SpritePlay(sprite, "ChargeEnd" .. d.ChargeAnim)
            end
        end

        if not d.Charging then
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
        else
            local null = sprite:GetNullFrame("EffectGuide"):GetPos()
            if npc.FlipX == true then
                null = Vector(-null.X, null.Y)
            end
            if d.HaemoLaser then
                d.HaemoLaser.ParentOffset = null*1.5
            end
            d.Charging = d.Charging+1
            d.ChargeSpeed = math.min(bal.ChargeSpeed[2], d.ChargeSpeed+bal.ChargeSpeed[3])
            npc.Velocity = mod:Lerp(npc.Velocity, d.ChargeDir:Resized(d.ChargeSpeed), 0.4)

            local evilProj
            if d.Charging % bal.ChargeFreq == 0 then
                evilProj = npc:FireProjectilesEx(npc.Position, Vector.Zero, 0, ChargePopParams)[1]
                evilProj.DepthOffset = 120
                local pd = evilProj:GetData()
                pd.projType = "customProjectileBehavior"
				pd.customProjectileBehaviorLJ = {customFunc = FloatingChargeProj, death = FloatingChargeDeath}
            else
                if rng:RandomInt(bal.ChargeRand) == 0 then
                    if d.Charging % bal.ChargeFreq ~= (bal.ChargeFreq-1) then
                        d.Charging = d.Charging+1
                    end
                end
                local scaledGain = d.ChargeSpeed/bal.ChargeSpeed[2]
                if scaledGain < 0.2 then
                    d.Charging = d.Charging-1
                elseif scaledGain > 0.65 and d.Charging % bal.ChargeFreq < (bal.ChargeFreq-2) then
                    d.Charging = d.Charging+1
                elseif scaledGain > 0.4 and d.Charging % bal.ChargeFreq < (bal.ChargeFreq-1) then
                    d.Charging = d.Charging+1
                end
            end

            local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, npc.Position, Vector.Zero, npc):ToEffect()
            local scale1 = mod:RandomInt(bal.ChargeCreep[1], bal.ChargeCreep[2], rng)/100
            creep.SpriteScale = Vector(scale1, scale1)
            creep:Update()
            local scale2 = mod:RandomInt(bal.ChargeCreep[3], bal.ChargeCreep[4], rng)/100
            creep.SpriteScale = Vector(scale2, scale2)
            if evilProj ~= nil then
                creep:GetData().SpecialBehavior = "Charge"
                evilProj.Parent = creep
                creep.Child = evilProj
            else
                if rng:RandomInt(6) > 0 then
                    creep:GetData().CustomFerroActive = bal.ChargeActive
                end
            end
            creep:Update()

            if npc.FrameCount % 2 == 0 then
                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc):ToEffect()
                splat.Color = mod.Colors.HaemotoxiaCreep
                splat.SpriteScale = Vector(1.5, 1.5)
                splat:Update()
            end

            if npc.StateFrame % bal.ChargeFreq2 == 0 then
                npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES, 0.6, 0, false, mod:RandomInt(90,110,rng)/100)
                local params = ProjectileParams()
                params.FallingSpeedModifier = -mod:RandomInt(bal.Charge2FallSpeed[1], bal.Charge2FallSpeed[2], rng)/10
                params.FallingAccelModifier = bal.Charge2FallAccel
                params.Scale = mod:RandomInt(bal.Charge2Scale[1], bal.Charge2Scale[1], rng)/10
                local vel = d.ChargeDir:Resized(mod:RandomInt(bal.Charge2Speed[1], bal.Charge2Speed[2], rng)/10):Rotated(180+mod:RandomInt(-bal.Charge2Angle, bal.Charge2Angle, rng))
                npc:FireProjectiles(npc.Position+null*1.5, vel, 0, params)
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position+null*1.5, vel, npc):ToEffect()
            end

            if npc.StateFrame % bal.ChargeSplitProjInterval == 0 then
                for i = -90, 90, 180 do
                    npc:FireProjectiles(npc.Position, mod:SnapVector(d.ChargeDir, 90):Rotated(i):Resized(bal.ChargeSplitProjSpeed), 0, ChargeImpactParams)
                end
            end

            for i=1,6 do
                local vel = Vector(0, 1):Resized(mod:RandomInt(12,55,rng)/10):Rotated(rng:RandomInt(360))
                local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc):ToEffect()
                drop.FallingSpeed = mod:RandomInt(-55,-25,rng)/10
                drop.m_Height = -15
                drop.Color = Color(0.8, 0, 0, 1, 0.3, 0, 0, 0.2, 0, 0, 1)
            end

            if npc.StateFrame > bal.ChargeSafety and npc:CollidesWithGrid() then
                d.ChargeState = "Stop"
                npc.Velocity = d.ChargeDir:Rotated(180):Resized(bal.ChargeKnockback)
                npc.Mass = d.PrevMass
                npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, mod:RandomInt(90,110,rng)/100)
                d.Charging = nil
                d.ChargeNum = d.ChargeNum+1
                if d.HaemoLaser then
                    d.HaemoLaser:SetTimeout(1)
                end

                --[[local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc):ToEffect()
                poof.Color = mod.Colors.HaemotoxiaCreep
                poof:Update()]]

                local vec = Vector(0, -bal.ChargeImpactSpeed)
                if d.ChargeAnim == "Up" then
                    vec = Vector(bal.ChargeImpactSpeed, 0)
                elseif d.ChargeAnim == "Down" then
                    vec = Vector(-bal.ChargeImpactSpeed, 0)
                elseif d.ChargeAnim == "Hori" and not npc.FlipX then
                    vec = Vector(0, bal.ChargeImpactSpeed)
                end

                --[[local ang = 180/(bal.ChargeImpactShots-1)
                for i=1,bal.ChargeImpactShots+1 do
                    npc:FireProjectiles(npc.Position, vec:Rotated(ang*(i-1)), 0, ChargeImpactParams)
                end]]
            end
        end
    elseif d.State == "ChargeJump" then
        if sprite:IsFinished("Jump") then
            npc.StateFrame = bal.ChargeTime[4]
            d.State = "Idle"
            table.remove(d.HaemotoxiaAttackQueue, 1)
            if #d.HaemotoxiaAttackQueue == 0 then
                d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks1)
            end
            d.ChargeNum = nil
        elseif sprite:IsEventTriggered("Jump") then
            npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 0.75, 0, false, mod:RandomInt(60,75,rng)/100)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        elseif sprite:IsEventTriggered("Shoot") then
            for _,spike in ipairs(Isaac.FindByType(mod.ENT.FerroCreepSpikes.ID, mod.ENT.FerroCreepSpikes.Var, mod.ENT.FerroCreepSpikes.Sub, false, false)) do
                if spike:GetData().SpecialBehavior and spike:GetData().SpecialBehavior == "Charge" then
                    spike:GetData().State = "Poking"
                end
            end
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
            game:ShakeScreen(4)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            d.AppearAnimationed = true
            local creeped
            for _,creep in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, -1, false, false)) do
                if creep.Position:Distance(npc.Position) < npc.Size then
                    creeped = true
                    break
                end
            end
            if creeped then
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, npc.Position, Vector.Zero, npc):ToEffect()
                poof.Color = mod.Colors.HaemotoxiaCreep
                for i=1,6 do
                    local vel = Vector(0, 1):Resized(mod:RandomInt(12,55,rng)/10):Rotated(rng:RandomInt(360))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc):ToEffect()
                    drop.FallingSpeed = mod:RandomInt(-55,-25,rng)/10
                    drop.m_Height = -15
                    drop.Color = Color(0.8, 0, 0, 1, 0.3, 0, 0, 0.2, 0, 0, 1)
                end
            else
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, npc.Position, Vector.Zero, npc):ToEffect()
            end
            game:MakeShockwave(npc.Position, 0.01, 0.05, 10)
        else
            mod:SpritePlay(sprite, "Jump")
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif d.State == "Hop" then
        if not d.ChosenPos then
            local pos = target.Position
            if not room:IsPositionInRoom(pos, 0) or room:GetGridCollisionAtPos(pos) > GridCollisionClass.COLLISION_NONE then
                pos = room:FindFreeTilePosition(pos, 999)
            end
            d.ChosenPos = pos
        end
        if sprite:IsFinished("JumpAttack") then
            d.State = "ShootBomb"
            d.ShootBombEndFunc = function()
                if d.Phase2 then
                    d.State = "Idle"
                elseif d.HopNum < bal.HopTimes then
                    d.State = "Hop"
                    d.ChosenPos = nil
                else
                    d.State = "Idle"
                    npc.StateFrame = bal.HopTime[4]
                    table.remove(d.HaemotoxiaAttackQueue, 1)
                    if #d.HaemotoxiaAttackQueue == 0 then
                        d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks1)
                    end
                end
            end
            d.HopNum = d.HopNum+1
        elseif sprite:IsEventTriggered("Jump") then
            npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 0.75, 0, false, mod:RandomInt(60,75,rng)/100)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            d.Jumping = true
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.8, 0, false, 1)
            game:ShakeScreen(3)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            local creeped
            for _,creep in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, -1, false, false)) do
                if creep.Position:Distance(npc.Position) < npc.Size then
                    creeped = true
                    break
                end
            end
            if creeped then
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, npc.Position, Vector.Zero, npc):ToEffect()
                poof.Color = mod.Colors.HaemotoxiaCreep
                for i=1,6 do
                    local vel = Vector(0, 1):Resized(mod:RandomInt(12,55,rng)/10):Rotated(rng:RandomInt(360))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc):ToEffect()
                    drop.FallingSpeed = mod:RandomInt(-55,-25,rng)/10
                    drop.m_Height = -15
                    drop.Color = Color(0.8, 0, 0, 1, 0.3, 0, 0, 0.2, 0, 0, 1)
                end
            else
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, npc.Position, Vector.Zero, npc):ToEffect()
            end
            game:MakeShockwave(npc.Position, 0.005, 0.05, 8)
            d.Jumping = nil
            npc.FlipX = target.Position.X > npc.Position.X
        elseif sprite:IsEventTriggered("Shoot") then
            npc.FlipX = target.Position.X > npc.Position.X
            local degrees = mod:GetAngleDegreesButGood(target.Position-npc.Position)
			local moveDegrees = mod:GetAngleDegreesButGood((target.Position+target.Velocity*5)-npc.Position)
			local rotDir = -1
			if degrees-moveDegrees < 0 then
				rotDir = 1
			end
            d.ChosenDirection = (target.Position-npc.Position)
            d.FireRotation = rotDir
            d.HopShooting = 0
            d.HopShot = 0
            d.HopAlt = rotDir
        else
            mod:SpritePlay(sprite, "JumpAttack")
        end

        if d.HopShooting then
            local flip = (npc.FlipX and 1) or -1
            local offset = Vector(40*flip, 6)
            local trueOffset = Vector(75*flip, 10)
            if not room:IsPositionInRoom(npc.Position+offset, 0) then
                offset = Vector.Zero
            end
            if d.HopShooting % bal.HopBigFreq == 0 then
                local ang = d.ChosenDirection:Rotated(-d.FireRotation*bal.HopRotate+d.FireRotation*bal.HopRotate*d.HopShot+mod:RandomInt(-bal.HopRotate2, bal.HopRotate2, rng))
                local proj = npc:FireProjectilesEx(npc.Position+offset, ang:Resized(mod:RandomInt(bal.HopSpeed[1], bal.HopSpeed[2], rng)/10), 0, HopBigParams)[1]
                local pd = proj:GetData()
                pd.projType = "customProjectileBehavior"
                pd.customProjectileBehaviorLJ = {customFunc = HopLarge}
                pd.HaemotoxiaBombShot = true
                d.HopShot = d.HopShot+1

                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, npc.Position+trueOffset, ang:Resized(4.5), npc):ToEffect()
                poof.Color = Color(0.5, 0.2, 0.2, 1, 0.35, 0, 0, 1, 0, 0, 1)
                poof.SpriteScale = Vector(1.45, 1.45)
                npc:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false, mod:RandomInt(85,100,rng)/100)
            end
            d.HopShooting = d.HopShooting+1
            --[[if d.HopShooting % bal.HopSmallFreq == 0 then
                local scale = mod:RandomInt(bal.HopScale[1], bal.HopScale[2], rng)/100
                local ang = d.ChosenDirection:Rotated(bal.HopAngle*d.HopAlt+mod:RandomInt(-bal.HopRotate3, bal.HopRotate3, rng)):Resized(bal.HopSmallSpeed)
                local proj = npc:FireProjectilesEx(npc.Position, ang, 0, HopSmallParams)[1]
                local pd = proj:GetData()
                pd.projType = "customProjectileBehavior"
                pd.customProjectileBehaviorLJ = {customFunc = Wiggle}
                d.HopAlt = -1*d.HopAlt
            end]]
            if d.HopShooting > bal.HopMax then
                d.HopShooting = nil
            end
        end

        if not d.Jumping then
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
        else
            local targVel = (d.ChosenPos-npc.Position)*0.1
            npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
        end
    elseif d.State == "Brim" then
        if sprite:IsFinished("Brimstone") then
            d.ShootBombEndFunc = function()
                npc.StateFrame = bal.BrimTime[4]
                d.State = "Idle"
                table.remove(d.HaemotoxiaAttackQueue, 1)
                if #d.HaemotoxiaAttackQueue == 0 then
                    d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks1)
                end
                for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                    if not creep:GetData().RemoveFerro and not creep:GetData().SpecialTimeout and not creep:GetData().HaemoMainPuddle then
                        creep:ToEffect():SetTimeout(35)
                        creep:GetData().SpecialTimeout = true
                        creep:GetData().StillRemovePlease = true
                    end
                end
            end
            d.SpecialBombTimer = bal.BrimBombTimer
            d.State = "ShootBomb"
            d.TargetThisInstead = d.OriginalTargetPos
            d.OriginalTargetPos = nil
            d.RotatedSpeed = nil
            d.RotatedVel = nil
            d.RotateCount = nil
        elseif sprite:IsEventTriggered("Sound") then
            sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 0.9)
        elseif sprite:IsEventTriggered("Shoot") then
            if d.HaemoWarningLaser and d.HaemoWarningLaser:Exists() then
                d.HaemoWarningLaser:GetData().DIEDIEDIEDIE = true
            end

            local null = sprite:GetNullFrame("EffectGuide"):GetPos()
            --[[d.SkyLaser = EntityLaser.ShootAngle(LaserVariant.THICK_RED, npc.Position, 270, 50, Vector.Zero, npc)
            d.SkyLaser:AddTearFlags(TearFlags.TEAR_CONTINUUM)
            d.SkyLaser.Color = Color(1, 1, 1, 1, 0, 0, 0, 0, 0, 0)
            d.SkyLaser.ParentOffset = null*1.5
            d.SkyLaser:GetData().HaemoSpecialLaser = true
            d.SkyLaser:Update()
            d.SkyLaser:Update()]]
            d.SkyLaser = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUSH_LASER_UP, 0, npc.Position, Vector.Zero, npc):ToEffect()
            d.SkyLaser:GetSprite():Load("gfx/bosses/LastJudgement/haemo_laser.anm2", true)
            d.SkyLaser:FollowParent(npc)
            d.SkyLaser.SpriteOffset = Vector(0, 50)+null*1.5
            d.SkyLaser:Update()

            if not d.ChosenTarget or not d.ChosenTarget:Exists() then
                d.ChosenTarget = target
            end
            local rangle = d.ChosenTarget.Velocity:GetAngleDegrees()-30 --kinda sucks for coop, but what can you do (there's a lot that can be done but idk it's weird)
            local giveUp = 0
            local pos = d.ChosenTarget.Position+Vector(bal.BrimRadius, 0):Rotated(rangle)
            local pleaseCheck = true
            while pleaseCheck do
                local found
                for i = 1, game:GetNumPlayers() do
                    local p = Isaac.GetPlayer(i-1)
                    if p.Position:Distance(pos) < bal.BrimPlayerCheck then
                        found = true
                        rangle = rng:RandomInt(360)
                        break
                    end
                end
                giveUp = giveUp+1
                if not found or giveUp > 20 then
                    pleaseCheck = nil
                end
            end
            d.OriginalTargetPos = d.ChosenTarget.Position
            d.OriginalLandPos = pos

            d.LandLaser = EntityLaser.ShootAngle(LaserVariant.THICK_RED, pos+Vector(0, bal.BrimHeight), 90, 50, Vector.Zero, npc)
            d.LandLaser:GetData().HaemoSpecialLaser = true
            --d.LandLaser:AddTearFlags(TearFlags.TEAR_CONTINUUM)
            --d.LandLaser.Color = Color(1, 1, 1, 1, 0, 0, 0, 0, 0, 0)
            d.LandLaser.MaxDistance = -bal.BrimHeight
            d.LandLaser.EndPoint = pos
            d.LandLaser.DisableFollowParent = true
            --d.LandLaser:Update()
            --d.LandLaser:Update()

            d.Lasering = true
            d.ChosenTarget = nil
        elseif sprite:IsEventTriggered("Land") then
            if d.LandLaser then
                d.LandLaser:SetTimeout(2)
                d.LandLaser.Velocity = Vector.Zero
                d.LandLaser = nil
            end
            if d.SkyLaser then
                d.SkyLaser:SetTimeout(2)
                d.SkyLaser = nil
            end
            d.Lasering = nil
        else
            mod:spritePlay(sprite, "Brimstone")
        end

        if d.Lasering then
            if d.LandLaser then
                d.LandLaser:SetTimeout(20)
                local pos = d.LandLaser.Position
                for i=1,game:GetNumPlayers() do
                    local p = Isaac.GetPlayer(i-1)
                    if p.Position:Distance(pos) < bal.BrimHurtRad then
                        p:TakeDamage(1, 0, EntityRef(d.LandLaser), 0)
                    end
                end

                d.RotatedSpeed = d.RotatedSpeed or bal.BrimRotate[1]
                d.RotatedVel = (d.RotatedVel or bal.BrimRotateVel)+bal.BrimRotateAccel
                d.RotatedSpeed = math.min(d.RotatedSpeed+d.RotatedVel, bal.BrimRotate[2])
                local original = d.RotateCount or 0
                d.RotateCount = (d.RotateCount or 0)+d.RotatedSpeed
                local targetPos = d.OriginalTargetPos+(d.OriginalLandPos-d.OriginalTargetPos):Rotated(d.RotateCount)
                d.LandLaser.Velocity = (targetPos-d.LandLaser.Position)+Vector(0, bal.BrimHeight)

                if d.RotatedSpeed > 360 then
                    d.RotatedSpeed = nil
                    d.RotatedVel = nil
                    d.RotateCount = nil
                    d.LandLaser.Velocity = Vector.Zero
                    d.LandLaser:SetTimeout(2)
                    d.LandLaser = nil
                end

                if d.RotatedSpeed > 10 then
                    local circlePos = d.OriginalTargetPos+(d.OriginalLandPos-d.OriginalTargetPos):Rotated(original+d.RotatedSpeed/2)
                    local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, circlePos, Vector.Zero, d.LandLaser)
                    creep:Update()
                    local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, circlePos, Vector.Zero, npc):ToEffect()
                    splat.Color = mod.Colors.HaemotoxiaCreep
                end

                
                local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, pos+Vector(0, -bal.BrimHeight), Vector.Zero, d.LandLaser)
                creep:Update()
                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, pos+Vector(0, -bal.BrimHeight), Vector.Zero, npc):ToEffect()
                splat.Color = mod.Colors.HaemotoxiaCreep
            end

            local null = sprite:GetNullFrame("EffectGuide"):GetPos()
            if d.SkyLaser then
                d.SkyLaser.SpriteOffset = Vector(0, 50)+null*1.5
                d.SkyLaser:SetTimeout(20)
            end

            if npc.StateFrame % bal.BrimVolleyFreq == 0 and 2 == 0 then
                local params = ProjectileParams()
                params.FallingSpeedModifier = mod:RandomInt(bal.BrimFallSpeed[1], bal.BrimFallSpeed[2], rng)
                params.FallingAccelModifier = bal.BrimFallAccel
                params.Scale = mod:RandomInt(bal.BrimVolleyScale[1], bal.BrimVolleyScale[2], rng)/100
                params.HeightModifier = null.Y
                local vel = (target.Position-npc.Position):Rotated(mod:RandomInt(-bal.BrimVolleyRot, bal.BrimVolleyRot, rng)/10)*0.03
                npc:FireProjectiles(npc.Position, vel, 0, params)

                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.64, 0, false, mod:RandomInt(95,115,rng)/100)
                local vel2 = Vector(mod:RandomInt(5, 35, rng)/10, 0):Rotated(rng:RandomInt(360))
                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, vel2, npc):ToEffect()
                splat.SpriteOffset = null+Vector(0, 20)
            end

            if npc.StateFrame % 4 == 0 then
                for i=1,2 do
                    local vel = Vector(mod:RandomInt(35, 75, rng)/10, 0):Rotated(rng:RandomInt(360))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position, vel, npc):ToEffect()
                    drop.PositionOffset = Vector(0, -150)
                    drop.Color = mod.Colors.HaemotoxiaCreep
                    drop.FallingSpeed = mod:RandomInt(-5,125,rng)/10
                end
            end
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif d.State == "ShootBomb" then
        local playerTarget = d.TargetThisInstead or target.Position

        if sprite:IsFinished("Attack") then
            d.TargetThisInstead = nil
            d.SpecialBombTimer = nil
            if d.ShootBombEndFunc then
                d.ShootBombEndFunc()
            else
                npc.StateFrame = 0
                d.ShotFirstBomb = true
                d.State = "Idle"
            end
        elseif sprite:IsEventTriggered("Target") then
            npc.FlipX = playerTarget.X > npc.Position.X
            local mult = (npc.FlipX and -1) or 1
            local offset = Vector(mult*bal.BombOffset.X, bal.BombOffset.Y)
            d.LastChosenBombDir = (playerTarget-(npc.Position+offset))
        elseif sprite:IsEventTriggered("Shoot") then
            local mult = (npc.FlipX and -1) or 1
            local offset = Vector(mult*bal.BombOffset.X, bal.BombOffset.Y)
            local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, 0, 0, npc.Position+offset, d.LastChosenBombDir*bal.BombSpeed or Vector.Zero, npc):ToBomb()
            bomb:GetSprite():Load("gfx/items/pick ups/bombs/blood2.anm2", true)
            bomb:SetHeight(bal.BombUpVel)
            bomb:SetFallingSpeed(bal.BombAccel)
            bomb.PositionOffset = Vector(0, bal.BombHeight)
            bomb:GetData().IgnoreHighCollHaemo = true
            bomb:GetData().HaemotoxiaBloodBomb = npc
            if d.SpecialBombTimer then
                bomb:SetExplosionCountdown(d.SpecialBombTimer)
            else
                bomb:SetExplosionCountdown(bal.BombCountdown)
            end
            if not d.ShotFirstBomb then
                bomb:GetData().SpecialTimeout = bal.BombTimeout
            end
            bomb:Update()

            local poof1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, npc.Position, Vector.Zero, npc):ToEffect()
            poof1.Color = mod.Colors.HaemotoxiaCreep
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, npc.Position, Vector.Zero, npc):ToEffect()
            poof.SpriteScale = Vector(0.7, 0.7)
            poof.FlipX = npc.FlipX
            poof.Color = mod.Colors.HaemotoxiaCreep
            if npc.FlipX then
                poof.SpriteOffset = Vector(-180, -85)
            else
                poof.SpriteOffset = Vector(-75, -95)
            end
            poof:Update()

            for i=1,3 do
                local vel = d.LastChosenBombDir:Resized(mod:RandomInt(5,45,rng)/10):Rotated(mod:RandomInt(-65,65,rng))
                local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position+offset, vel, npc):ToEffect()
                drop.FallingSpeed = mod:RandomInt(-5,125,rng)/10
                drop.m_Height = -150
                drop.Color = Color(0.8, 0, 0, 1, 0.3, 0, 0, 0.2, 0, 0, 1)
            end
            for i=1,4 do
                local vel = d.LastChosenBombDir:Resized(mod:RandomInt(5,60,rng)/10):Rotated(mod:RandomInt(-65,65,rng))
                local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position+offset, vel, npc):ToEffect()
                drop.PositionOffset = Vector(0, -150)
                drop.Color = mod.Colors.HaemotoxiaCreep
                drop.FallingSpeed = mod:RandomInt(-5,125,rng)/10
            end

            npc:PlaySound(SoundEffect.SOUND_HEARTOUT, 1, 0, false, 1)
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_SCAMPER, 1, 0, false, 0.8)
        else
            mod:SpritePlay(sprite, "Attack")
        end

        local dir = playerTarget-npc.Position
        local properVec = (npc.FlipX and Vector(1, 0)) or Vector(-1, 0)
        if mod:GetAngleDifference(properVec, dir) < bal.BombAngle then
            local mult = (npc.FlipX and -1) or 1
            local offset = Vector(mult*bal.BombOffset.X, bal.BombOffset.Y)
            d.LastChosenBombDir = (playerTarget-(npc.Position+offset))
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif d.State == "PhaseChange" then
        if sprite:IsFinished("Pop") then
            d.State = "Emerge"
            d.TimeOut = 30
            d.Phase2ed = true
            d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks2)

            for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                if not creep:GetData().RemoveFerro and not creep:GetData().SpecialTimeout and not creep:GetData().HaemoMainPuddle then
                    creep:GetData().RemoveFerro = true
                    creep:ToEffect():SetTimeout(1)
                end
            end
            for _,proj in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, 0, 0, false, false)) do
                if proj:GetData().HaemotoxiaBombShot then
                    proj:GetData().JustFallDown = true
                end
            end
        elseif sprite:IsEventTriggered("Sound") then
            --Glass Cracking
            npc:PlaySound(SoundEffect.SOUND_BONE_BREAK, 0.75, 0, false, mod:RandomInt(120,130,rng)/100)
        elseif sprite:IsEventTriggered("Shoot") then
        elseif sprite:IsEventTriggered("Pop") then
            npc:PlaySound(SoundEffect.SOUND_GLASS_BREAK, 1, 0, false, 1)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

            d.HaemoCreeping = true

            for i=1,10 do
                local vel = Vector(mod:RandomInt(15, 55, rng)/10, 0):Rotated(rng:RandomInt(360))
                local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position, vel, npc):ToEffect()
                drop.PositionOffset = Vector(0, mod:RandomInt(-60,-25,rng))
                drop.Color = mod.Colors.HaemotoxiaCreep
                drop.FallingSpeed = mod:RandomInt(-60, 5, rng)/10
            end
        elseif sprite:IsEventTriggered("Land") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, npc.Position, Vector.Zero, npc):ToEffect()
            poof.Color = mod.Colors.HaemotoxiaCreep
            for i=1,6 do
                local vel = Vector(0, 1):Resized(mod:RandomInt(25,75,rng)/10):Rotated(rng:RandomInt(360))
                local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position, vel, npc):ToEffect()
                drop.FallingSpeed = mod:RandomInt(-65,-25,rng)/10
                drop.m_Height = -18
                drop.Color = Color(0.8, 0, 0, 1, 0.3, 0, 0, 0.2, 0, 0, 1)
            end
            for i=1,6 do
                local vel = Vector(mod:RandomInt(15, 60, rng)/10, 0):Rotated(rng:RandomInt(360))
                local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position, vel, npc):ToEffect()
                drop.PositionOffset = Vector(0, mod:RandomInt(-55,-25,rng))
                drop.Color = mod.Colors.HaemotoxiaCreep
                drop.FallingSpeed = mod:RandomInt(-45, 5, rng)/10
            end
            npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
            npc:PlaySound(SoundEffect.SOUND_HEARTIN, 0.8, 0, false, 0.9)
            npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
        elseif sprite:IsEventTriggered("Jump") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        else
            mod:SpritePlay(sprite, "Pop")
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif d.State == "Idle2" then
        local nextAttack = d.HaemotoxiaAttackQueue[1]
        --nextAttack = "Clot"

        local tab = bal[nextAttack .. "Time"]
        local active
        if npc.StateFrame > tab[2] then
            active = true
        elseif npc.StateFrame > tab[1] and rng:RandomInt(tab[3]) == 0 then
            active = true
        end

        if active then
            d.Phase2HaemoAttack = nextAttack
            d.State = nextAttack
            if nextAttack == "Plus" then
                d.AttackState = "Creep"
                d.AttackSpots = FindPlusSpots(npc)

                d.AttackTargets = {}
                for _,spot in ipairs(d.AttackSpots) do
                    local targ = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, spot, Vector.Zero, npc):ToEffect()
                    targ.Parent = npc
                    targ:GetData().HaemotoxiaTarget = true
                    targ:Update()
                    table.insert(d.AttackTargets, targ)
                    for i=1,4 do
                        local pos = targ.Position+Vector(10,0):Rotated(i*90)
                        local tracer = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, pos, Vector(0.001,0), npc):ToEffect()
                        tracer.Timeout = 30
                        tracer.LifeSpan = 30
                        tracer.TargetPosition = Vector(1,0):Rotated(i*90)
                        tracer.PositionOffset = Vector(0, 8)
                        tracer.Color = Color(1,0,0,0.7,0,0,0, 2, 0, 0, 0.5)
                        tracer:Update()
                    end
                end
            elseif nextAttack == "Ring" then
                d.AttackState = "Bomb"
                d.OldCreep = nil
                d.JumpCount = 0
                --[[d.SkipFirstJump = true
                d.TargetPos = npc.Position]]
                npc.FlipX = target.Position.X < npc.Position.X
                local mult = (npc.FlipX and -1) or 1
                local offset = Vector(mult*bal.BombOffset2.X, bal.BombOffset2.Y)
                d.LastChosenBombDir = (target.Position-(npc.Position+offset))
            elseif nextAttack == "Clot" then
                d.Creeping = nil
                d.AttackState = "Creep"
            end

            for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                if not creep:GetData().RemoveFerro and not creep:GetData().SpecialTimeout and not creep:GetData().HaemoMainPuddle then
                    creep:GetData().RemoveFerro = true
                    creep:ToEffect():SetTimeout(1)
                end
            end
        end


        mod:SpritePlay(sprite, "Idle2")

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif d.State == "Emerge" then
        if d.TimeOut then
            if d.TimeOut > 0 then
                d.TimeOut = d.TimeOut-1
            else
                npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
                d.TimeOut = nil
            end
        else
            if sprite:IsFinished("Surface") then
                if d.SurfaceFunc then
                    d.SurfaceFunc()
                else
                    d.State = "Idle2"
                    if d.Phase2HaemoAttack then
                        npc.StateFrame = bal[d.Phase2HaemoAttack .. "Time"][4]
                    else
                        npc.StateFrame = 0
                    end
                end
            elseif sprite:IsEventTriggered("Land") then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            else
                mod:SpritePlay(sprite, "Surface")
            end
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif d.State == "Plus" then
        if d.AttackState == "Creep" then
            if sprite:IsFinished("Haemolacria") then
                d.AttackState = "Brim"
                d.BrimCount = 0
                npc.FlipX = target.Position.X < npc.Position.X
            elseif sprite:IsEventTriggered("Sound") then
                npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT, 1, 0, false, mod:RandomInt(90,95,rng)/100)
                npc:PlaySound(SoundEffect.SOUND_GOOATTACH0, 0.6, 0, false, mod:RandomInt(90,110,rng)/100)
            elseif sprite:IsEventTriggered("Shoot") then
                npc:PlaySound(SoundEffect.SOUND_BOSS_GURGLE_ROAR, 1, 0, false, mod:RandomInt(105,115,rng)/100)
                for key,targ in ipairs(d.AttackTargets) do
                    mod:ScheduleForUpdate(function()
                        local proj = npc:FireProjectilesEx(npc.Position, (targ.Position-npc.Position)*bal.PlusShotSpeed, 0, PlusShotParams)[1]
                        targ.Parent = proj
                        local pd = proj:GetData()
                        pd.projType = "customProjectileBehavior"
                        pd.customProjectileBehaviorLJ = {customFunc = PlusShot, death = PlusShotDeath}
                        pd.GetClearedWhenHaemoDies = true
                    end, bal.PlusShotStagger*(key-1))
                end
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc):ToEffect()
                poof.Color = mod.Colors.HaemotoxiaCreep
                poof.SpriteOffset = Vector(0, -20)
                poof.DepthOffset = 40
            else
                mod:SpritePlay(sprite, "Haemolacria")
            end
        elseif d.AttackState == "Brim" then
            if d.BrimCount < bal.PlusBrimNum then
                if sprite:IsFinished("BrimstoneCont") then
                    sprite:Play("Idle", true)
                    sprite:Play("BrimstoneCont", true)
                    d.BrimCount = d.BrimCount + 1
                elseif sprite:IsEventTriggered("Target") then
                    npc.FlipX = target.Position.X < npc.Position.X
                    local extra = target.Velocity*bal.PlusBrimAim
                    if extra:Length() > bal.PlusBrimAimMax then
                        extra = extra:Resized(bal.PlusBrimAimMax)
                    end
                    local targPos = target.Position+extra
                    local flip = (npc.FlipX and -1) or 1
                    local pos = npc.Position+Vector(bal.PlusOffset.X*flip, 0)
                    local weheee = pos+(targPos-pos):Resized(700)
                    mod:MakeCustomTracer(pos+Vector(0,bal.PlusOffset.Y), weheee, npc, {
                        Color = Color(1,0,0),
                        Width = 1,
                        Duration = bal.PlusTracerDur,
                        LineCheckMode = LineCheckMode.PROJECTILE,
                        FollowParent = true,
                    })
                    d.TargPos = targPos
                elseif sprite:IsEventTriggered("Shoot") then
                    local flip = (npc.FlipX and -1) or 1
                    local pos = npc.Position+Vector(bal.PlusOffset.X*flip, 0)
                    local ang = (d.TargPos-npc.Position):GetAngleDegrees()
                    local laser = EntityLaser.ShootAngle(LaserVariant.THICK_RED, pos, ang, bal.PlusBrimDur, Vector(0, bal.PlusOffset.Y), npc)
                    laser.DepthOffset = 50
                else
                    mod:SpritePlay(sprite, "BrimstoneCont")
                end
            else
                if sprite:IsFinished("BrimstoneGoUnder") then
                    local backup = true
                    if rng:RandomInt(bal.MoveRand) == 0 and npc.Position:Distance(room:GetCenterPos()) > bal.MoveNeed then
                        backup = false
                        d.State = "Move"
                        d.AttackState = "JumpOut"
                        d.TargetPos = FindNewLandSpot(npc, rng)
                        if d.TargetPos == nil then
                            backup = true
                        else
                            local dir = d.TargetPos-npc.Position
                            if math.abs(dir.X) > math.abs(dir.Y) and dir:Length() > 50 then
                                d.AttackDir = "Hori"
                                npc.FlipX = dir.X < 0
                            else
                                d.AttackDir = "Vert"
                            end
                        end
                    end
                    if backup then
                        d.State = "Emerge"
                    end
                    d.TimeOut = bal.PlusTimeout

                    table.remove(d.HaemotoxiaAttackQueue, 1)
                    if #d.HaemotoxiaAttackQueue == 0 then
                        d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks2)
                    end
                    for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                        if not creep:GetData().RemoveFerro and not creep:GetData().SpecialTimeout and not creep:GetData().HaemoMainPuddle then
                            creep:GetData().RemoveFerro = true
                            creep:ToEffect():SetTimeout(1)
                        end
                    end
                elseif sprite:IsEventTriggered("Target") then
                    npc.FlipX = target.Position.X < npc.Position.X
                    local flip = (npc.FlipX and -1) or 1
                    local pos = npc.Position+Vector(bal.PlusOffset.X*flip, 0)
                    local targPos = (target.Position+target.Velocity*bal.PlusBrimAim)
                    local weheee = pos+(targPos-pos):Resized(700)
                    mod:MakeCustomTracer(pos+Vector(0,bal.PlusOffset.Y), weheee, npc, {
                        Color = Color(1,0,0),
                        Width = 1,
                        Duration = bal.PlusTracerDur,
                        LineCheckMode = LineCheckMode.PROJECTILE,
                        FollowParent = true,
                    })
                    d.TargPos = targPos
                elseif sprite:IsEventTriggered("Shoot") then
                    local flip = (npc.FlipX and -1) or 1
                    local pos = npc.Position+Vector(bal.PlusOffset.X*flip, 0)
                    local ang = (d.TargPos-npc.Position):GetAngleDegrees()
                    local laser = EntityLaser.ShootAngle(LaserVariant.THICK_RED, pos, ang, bal.PlusBrimDur, Vector(0, bal.PlusOffset.Y), npc)
                    laser.DepthOffset = 50
                elseif sprite:IsEventTriggered("Jump") then
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                    npc:PlaySound(SoundEffect.SOUND_HEARTIN, 0.8, 0, false, 0.9)
                    npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
                else
                    mod:SpritePlay(sprite, "BrimstoneGoUnder")
                end
            end
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif d.State == "Ring" then
        if d.AttackState == "Jump" then
            if sprite:IsFinished("Dive" .. d.AttackDir) then
                if d.JumpCount >= bal.PlusMaxJumps then
                    --Oh wait, I don't have to clear the creep away, it's already set away
                    d.TimeOut = bal.RingTimeout
                    table.remove(d.HaemotoxiaAttackQueue, 1)
                    if #d.HaemotoxiaAttackQueue == 0 then
                        d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks2)
                    end
                else
                    d.SurfaceFunc = function()
                        d.State = "Ring"
                        d.AttackState = "Bomb"
                        npc.FlipX = target.Position.X < npc.Position.X
                        local mult = (npc.FlipX and -1) or 1
                        local offset = Vector(mult*bal.BombOffset2.X, bal.BombOffset2.Y)
                        d.LastChosenBombDir = (target.Position-(npc.Position+offset))
                        d.SurfaceFunc = nil
                    end
                end
                d.State = "Emerge"
                d.TimeOut = 0
            elseif sprite:IsEventTriggered("Jump") then
                d.Jumping = true
                d.JumpSpeed = (d.TargetPos-npc.Position):Length()/bal.RingJumpFrames
                if not d.SkipFirstJump then
                    d.HaemoCreeping = nil
                    for key,creep in pairs(d.MyCreep) do
                        if creep:Exists() then
                            creep:GetData().NoRandomSpikes = nil
                            creep:GetData().HaemoMainPuddle = nil
                        else
                            d.MyCreep[key] = nil
                        end
                    end
                    if d.OldCreep ~= nil then
                        if d.OlderCreep ~= nil then
                            for _,creep in pairs(d.OlderCreep) do
                                creep:GetData().SpecialTimeout = bal.RingCreepTimeout
                            end
                        end
                        d.OlderCreep = d.OldCreep
                    end
                    d.OldCreep = makeCopiedTable(d.MyCreep)
                    d.MyCreep = nil
                end

                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT, 1, 0, false, 1)

                for i=1,4 do
                    local dir = (d.TargetPos-npc.Position)
                    if dir:Length() < 20 then
                        dir = Vector(0,1):Rotated(rng:RandomInt(360))
                    end
                    local vel = dir:Resized(mod:RandomInt(25, 80, rng)/10):Rotated(mod:RandomInt(-90, 90, rng))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position, vel, npc):ToEffect()
                    drop.PositionOffset = Vector(0, mod:RandomInt(-80,-35,rng))
                    drop.Color = mod.Colors.HaemotoxiaCreep
                    drop.FallingSpeed = mod:RandomInt(-80, -10, rng)/10
                end
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, npc.Position, Vector.Zero, npc):ToEffect()
                poof.Color = mod.Colors.HaemotoxiaCreep
                poof.FlipX = (d.TargetPos-npc.Position).X > 0
                poof:Update()
            elseif sprite:IsEventTriggered("Land") then
                for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                    if not creep:GetData().RemoveFerro and creep:GetData().HaemotoxiaBombCreep then
                        creep:GetData().RemoveFerro = true
                        creep:ToEffect():SetTimeout(1)
                    end
                end
                if not d.SkipFirstJump then
                    d.HaemoCreeping = true
                else
                    d.SkipFirstJump = nil
                end
                playedSplitSound = nil
                for i=1,bal.RingRingNumber do
					local vec = (target.Position-npc.Position):Rotated(i*360/bal.RingRingNumber):Resized(bal.RingProjSpeed)
					local proj = npc:FireProjectilesEx(npc.Position, vec, 0, RingShotParams)[1]
					local pd = proj:GetData()
					pd.projType = "HaemotoxiaSplitProj"
					pd.OriginalPos = npc.Position
					pd.Split = 1
				end
                d.Jumping = nil

                npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 1, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_HEARTIN, 0.8, 0, false, 0.9)
                npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
                
                for i=1,6 do
                    local vel = Vector(mod:RandomInt(55, 150, rng)/10, 0):Rotated(rng:RandomInt(360))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position, vel, npc):ToEffect()
                    drop.PositionOffset = Vector(0, mod:RandomInt(-60,-30,rng))
                    drop.Color = mod.Colors.HaemotoxiaCreep
                    drop.FallingSpeed = mod:RandomInt(-65, -5, rng)/10
                end
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc):ToEffect()
                poof.SpriteOffset = Vector(0, -10)
                poof.SpriteScale = Vector(0.6, 0.6)
                poof.Color = mod.Colors.HaemotoxiaCreep
                poof:Update()
                for i=-1,1,2 do
                    local pos = npc.Position+Vector(30*i, 0)+ShuntPos(5, rng)
                    local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, pos, Vector.Zero, npc):ToEffect()
                    poof2.Color = mod.Colors.HaemotoxiaCreep
                    poof2.DepthOffset = 50
                    poof2:Update()
                end
                local pos = npc.Position+Vector(0, 10)+ShuntPos(5, rng)
                local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, pos, Vector.Zero, npc):ToEffect()
                poof2.Color = mod.Colors.HaemotoxiaCreep
                poof2.DepthOffset = 50
                poof2:Update()
            else
                mod:SpritePlay(sprite, "Dive" .. d.AttackDir)
            end
        elseif d.AttackState == "Bomb" then
            if sprite:IsFinished("BloodBomb") then
                d.AttackState = "BombIdle"
                npc.StateFrame = 0
                d.TargetPos = npc.Position
            elseif sprite:IsEventTriggered("Shoot") then
                local mult = (npc.FlipX and -1) or 1
                local offset = Vector(mult*bal.BombOffset2.X, bal.BombOffset2.Y)
                local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, 0, 0, npc.Position+offset, d.LastChosenBombDir*bal.BombSpeed or Vector.Zero, npc):ToBomb()
                bomb:GetSprite():Load("gfx/items/pick ups/bombs/blood2.anm2", true)
                bomb:SetHeight(bal.BombUpVel)
                bomb:SetFallingSpeed(bal.BombAccel)
                bomb.PositionOffset = Vector(0, bal.BombHeight2)
                bomb:GetData().IgnoreHighCollHaemo = true
                bomb:GetData().HaemotoxiaBloodBomb = npc
                bomb:SetExplosionCountdown(bal.BombCountdown)
                bomb:Update()
                d.MyHaemotoxiaBomb = bomb
    
                local poof1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, npc.Position, Vector.Zero, npc):ToEffect()
                poof1.Color = mod.Colors.HaemotoxiaCreep
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, npc.Position, Vector.Zero, npc):ToEffect()
                poof.FlipX = not npc.FlipX
                poof.Color = mod.Colors.HaemotoxiaCreep
                if npc.FlipX then
                    poof.SpriteOffset = Vector(-30, -35)
                else
                    poof.SpriteOffset = Vector(-30, -35)
                end
                poof:Update()
    
                for i=1,3 do
                    local vel = d.LastChosenBombDir:Resized(mod:RandomInt(5,45,rng)/10):Rotated(mod:RandomInt(-65,65,rng))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, npc.Position+offset, vel, npc):ToEffect()
                    drop.FallingSpeed = mod:RandomInt(-20,60,rng)/10
                    drop.m_Height = -50
                    drop.Color = Color(0.8, 0, 0, 1, 0.3, 0, 0, 0.2, 0, 0, 1)
                end
                for i=1,4 do
                    local vel = d.LastChosenBombDir:Resized(mod:RandomInt(45,95,rng)/10):Rotated(mod:RandomInt(-65,65,rng))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position+offset, vel, npc):ToEffect()
                    drop.PositionOffset = Vector(0, -65)
                    drop.Color = mod.Colors.HaemotoxiaCreep
                    drop.FallingSpeed = mod:RandomInt(-55,10,rng)/10
                end
    
                npc:PlaySound(SoundEffect.SOUND_HEARTOUT, 1, 0, false, 1)
            elseif sprite:IsEventTriggered("Jump") then
                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_HEARTIN, 0.8, 0, false, 0.9)
                npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            else
                mod:SpritePlay(sprite, "BloodBomb")
            end
    
            local dir = target.Position-npc.Position
            local properVec = (npc.FlipX and Vector(-1, 0)) or Vector(1, 0)
            if mod:GetAngleDifference(properVec, dir) < bal.BombAngle then
                local mult = (npc.FlipX and -1) or 1
                local offset = Vector(mult*bal.BombOffset2.X, bal.BombOffset2.Y)
                d.LastChosenBombDir = (target.Position-(npc.Position+offset))
            end
        elseif d.AttackState == "Submerge" then
            if sprite:IsFinished("GoUnder") then
                d.AttackState = "UnderIdle"
                npc.StateFrame = 0
            elseif sprite:IsEventTriggered("Jump") then
                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_HEARTIN, 0.8, 0, false, 0.9)
                npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            else
                mod:SpritePlay(sprite, "GoUnder")
            end
        elseif d.AttackState == "UnderIdle" then
            if npc.StateFrame > bal.RingUnderTime then
                local dir = d.TargetPos-npc.Position
                if math.abs(dir.X) > math.abs(dir.Y) and dir:Length() > 50 then
                    d.AttackDir = "Hori"
                    npc.FlipX = dir.X < 0
                else
                    d.AttackDir = "Vert"
                end
                d.AttackState = "Jump"
                d.JumpCount = d.JumpCount+1
            end
        elseif d.AttackState == "BombIdle" then
            if d.MyHaemotoxiaBomb and d.MyHaemotoxiaBomb:Exists() then
                d.TargetPos = d.MyHaemotoxiaBomb.Position
            else
                d.AttackState = "UnderIdle"
            end
            
            --mod:SpritePlay(sprite, "Idle2")
        end

        if d.Jumping then
            --Roughly 18 frames midair
            if npc.Position:Distance(d.TargetPos) < 30 then
                npc.Velocity = d.TargetPos-npc.Position
            else
                npc.Velocity = mod:Lerp(npc.Velocity, (d.TargetPos-npc.Position):Resized(d.JumpSpeed), 0.4)
            end
        else
            npc.Velocity = Vector.Zero
        end
    elseif d.State == "Clot" then
        if d.AttackState == "Creep" then
            if sprite:IsFinished("CreepAttack") then
                d.AttackState = "EnterBallIdle"
            elseif sprite:IsEventTriggered("Sound") then
                npc:PlaySound(SoundEffect.SOUND_LOW_INHALE, 1, 0, false, mod:RandomInt(115,125,rng)/100)
            --[[elseif sprite:IsEventTriggered("Target") then
                npc.FlipX = (target.Position.X < npc.Position.X)
                for i=-1,1,2 do
                    local targetPos = npc.Position+(target.Position-npc.Position):Rotated(i*bal.ClotCreepAng):Resized(700)
                    mod:MakeCustomTracer(npc.Position, targetPos, npc, {
                        Color = Color(0.7,0,0),
                        Width = 1,
                        Duration = bal.ClotTracerDur,
                        LineCheckMode = LineCheckMode.ENTITY,
                        FollowParent = true,
                    })
                end
                d.TargetVec = (target.Position-npc.Position)]]
            elseif sprite:IsEventTriggered("Shoot") then
                d.TargetVec = (target.Position-npc.Position)
                d.Creeping = {[-1] = 0, [1] = 0}

                npc:PlaySound(SoundEffect.SOUND_SINK_DRAIN_GURGLE, 1, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_MEGA_BLAST_END, 1, 0, false, 1.3)
                npc:PlaySound(SoundEffect.SOUND_HEARTOUT, 0.6, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_HEARTIN, 1.5, 0, false, 0.7)

                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, npc.Position, Vector.Zero, npc):ToEffect()
                poof.FlipX = not npc.FlipX
                poof.Color = mod.Colors.HaemotoxiaCreep
                if npc.FlipX then
                    poof.SpriteOffset = Vector(-30, -35)
                else
                    poof.SpriteOffset = Vector(-30, -35)
                end
                poof:Update()

                --[[CreepShotParams.HeightModifier = -15
                for i=-1,1,2 do
                    local vec = d.TargetVec:Rotated(i*bal.ClotCreepAng)
                    for j=1,rng:RandomInt(2)+3 do
                        mod:ScheduleForUpdate(function()
                            local speed = mod:RandomInt(bal.CreepShotVel[1], bal.CreepShotVel[2], rng)/4
                            local vel = vec:Rotated(mod:RandomInt(-bal.CreepShotAng, bal.CreepShotAng, rng)):Resized(speed)
                            CreepShotParams.Scale = mod:RandomInt(bal.CreepScale[1], bal.CreepScale[2], rng)/100
                            CreepShotParams.FallingSpeedModifier = mod:RandomInt(bal.CreepFall[1], bal.CreepFall[2], rng)
                            npc:FireProjectiles(npc.Position, vel, 0, CreepShotParams)
                        end, j*bal.CreepFreq)
                    end
                end
                CreepShotParams.HeightModifier = -5]]

                local yoof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, npc.Position+d.TargetVec:Resized(50), Vector.Zero, npc):ToEffect()
                yoof.SpriteScale = Vector(1.2, 1.2)
            elseif sprite:IsEventTriggered("Pop") then
                if not mod:isFriend(npc) then
                    npc.FlipX = (target.Position.X < npc.Position.X)
                    npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_5, 1, 0, false, mod:RandomInt(90, 95, rng)/100)
                    npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, mod:RandomInt(90 ,95, rng)/100)
                    npc:PlaySound(SoundEffect.SOUND_ANGRY_GURGLE, 0.4, 0, false, 1)
                    local vel = (target.Position-npc.Position):Resized(bal.ClotShootSpeed)
                    local clot = Isaac.Spawn(mod.ENT.HaemoClot.ID, mod.ENT.HaemoClot.Var, mod.ENT.HaemoClot.Sub, npc.Position, vel, npc):ToEffect()
                    clot.Parent = npc
                    clot:GetData().ClotVel = vel
                    clot:Update()
                    d.HaemoClot = clot

                    local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc):ToEffect()
                    cloud.Color = mod.Colors.HaemotoxiaCreep
                    cloud.SpriteScale = Vector(0.6, 0.8)
                    cloud.SpriteOffset = Vector(0, -20)
                    cloud:Update()
                end
            else
                mod:SpritePlay(sprite, "CreepAttack")
            end
        elseif d.AttackState == "EnterBallIdle" then
            if sprite:IsFinished("CreepToIdle") then
                d.AttackState = "BallIdle"
            elseif sprite:IsEventTriggered("Sound") then
                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.5, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
            else
                mod:SpritePlay(sprite, "CreepToIdle")
            end
        elseif d.AttackState == "BallIdle" then
            if not d.HaemoClot or not d.HaemoClot:Exists() then
                d.State = "Idle2"
                d.TimeOut = bal.ClotTimeout
                table.remove(d.HaemotoxiaAttackQueue, 1)
                if #d.HaemotoxiaAttackQueue == 0 then
                    d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks2)
                end
            end

            mod:SpritePlay(sprite, "Idle2")
        elseif d.AttackState == "IdleToSuck" then
            if sprite:IsFinished("IdleToSuck") then
                d.AttackState = "Sucking"
                d.SuckVel = bal.ClotSuckSpeed[1]
                if d.HaemoClot and d.HaemoClot:Exists() then
                    d.HaemoClot:GetData().Sucked = true
                else
                    d.AttackState = "End"
                end
            elseif sprite:IsEventTriggered("Sound") then
                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.5, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 0, false, 1)
            else
                mod:SpritePlay(sprite, "IdleToSuck")
            end
        elseif d.AttackState == "Sucking" then
            if d.HaemoClot and d.HaemoClot:Exists() then
                npc.FlipX = (d.HaemoClot.Position-npc.Position).X < 0

                d.HaemoClot.Velocity = mod:Lerp(d.HaemoClot.Velocity, (npc.Position-d.HaemoClot.Position):Resized(d.SuckVel), 0.1)
                d.SuckVel = math.min(bal.ClotSuckSpeed[2], d.SuckVel+bal.ClotSuckAccel)

                if d.HaemoClot.Position:Distance(npc.Position) < bal.ClotAbsorbDist then
                    for i=1,5 do
                        local splof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, d.HaemoClot.Position, Vector.Zero, npc):ToEffect()
                        splof.Color = mod.Colors.HaemotoxiaCreep
                        splof.PositionOffset = d.HaemoClot.PositionOffset
                        splof.SpriteOffset = ShuntPos(10, rng)
                        local scal = mod:RandomInt(55, 100, rng)/100
                        splof.SpriteScale = Vector(scal, scal)
                        splof:Update()
                    end
                    for i=1,4 do
                        local vel = Vector(mod:RandomInt(15, 75, rng)/10, 0):Rotated(rng:RandomInt(360))
                        local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, d.HaemoClot.Position, vel, npc):ToEffect()
                        gib:Update()
                        gib.Color = HaemoCreepProjColor
                        gib:Update()
                    end
                    for i=1,4 do
                        local vel = Vector(mod:RandomInt(45,95,rng)/10, 0):Rotated(rng:RandomInt(360))
                        local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, d.HaemoClot.Position, vel, npc):ToEffect()
                        drop.PositionOffset = Vector(0, -45)
                        drop.Color = mod.Colors.HaemotoxiaCreep
                        drop.FallingSpeed = mod:RandomInt(-55,10,rng)/10
                    end
                    npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                    npc:PlaySound(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1, 0, false, 0.93)

                    d.HaemoClot:Remove()
                    d.HaemoClot = nil
                    d.AttackState = "End"
                end
            else
                d.AttackState = "End"
            end

            mod:spritePlay(sprite, "SuckLoop")
        elseif d.AttackState == "End" then
            if sprite:IsFinished("SuckEnd") then
                local backup = true
                if rng:RandomInt(bal.MoveRand) == 0 and npc.Position:Distance(room:GetCenterPos()) > bal.MoveNeed then
                    backup = false
                    d.State = "Move"
                    d.AttackState = "JumpOut"
                    d.TargetPos = FindNewLandSpot(npc, rng)
                    if d.TargetPos == nil then
                        backup = true
                    else
                        local dir = d.TargetPos-npc.Position
                        if math.abs(dir.X) > math.abs(dir.Y) and dir:Length() > 50 then
                            d.AttackDir = "Hori"
                            npc.FlipX = dir.X < 0
                        else
                            d.AttackDir = "Vert"
                        end
                    end
                end
                if backup then
                    d.State = "Emerge"
                end
                d.TimeOut = bal.ClotTimeout

                table.remove(d.HaemotoxiaAttackQueue, 1)
                if #d.HaemotoxiaAttackQueue == 0 then
                    d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks2)
                end
                for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                    if not creep:GetData().RemoveFerro and not creep:GetData().SpecialTimeout and not creep:GetData().HaemoMainPuddle then
                        creep:GetData().RemoveFerro = true
                        creep:ToEffect():SetTimeout(1)
                    end
                end
            elseif sprite:IsEventTriggered("Jump") then
                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_HEARTIN, 0.8, 0, false, 0.9)
                npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            else
                mod:spritePlay(sprite, "SuckEnd")
            end
        end

        if d.Creeping then
            local yay
            for j=1,bal.ClotCreepLoop do
                for key,dist in pairs(d.Creeping) do
                    local vec = d.TargetVec:Rotated(key*bal.ClotCreepAng):Resized(dist)
                    d.Creeping[key] = dist+bal.ClotCreepInc
                    local targPos = npc.Position+vec
                    if room:IsPositionInRoom(targPos, 0) then
                        yay = true
                        local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, targPos, Vector.Zero, npc):ToEffect()
                        creep:Update()
                        local pos = targPos+ShuntPos(10, rng)
                        local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, pos, Vector.Zero, npc):ToEffect()
                        splash.SpriteScale = Vector(1,0.75)
                        splash:Update()
                        --[[local sca = mod:RandomInt(35, 80, rng)/100
                        splash.SpriteScale = Vector(sca, sca)]]

                        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, pos, Vector.Zero, npc):ToEffect()
                        splat.Color = mod.Colors.HaemotoxiaCreep

                        if rng:RandomInt(bal.CreepShotChance) == 0 then
                            local speed = mod:RandomInt(bal.CreepShotVel[1], bal.CreepShotVel[2], rng)/10
                            local vel = vec:Rotated(mod:RandomInt(-bal.CreepShotAng, bal.CreepShotAng, rng)):Resized(speed)
                            CreepShotParams.Scale = mod:RandomInt(bal.CreepScale[1], bal.CreepScale[2], rng)/100
                            CreepShotParams.FallingSpeedModifier = mod:RandomInt(bal.CreepFall[1], bal.CreepFall[2], rng)
                            npc:FireProjectiles(pos, vel, 0, CreepShotParams)
                        end
                    else
                        d.Creeping[key] = nil
                    end
                end
            end
            if not yay then
                d.Creeping = nil
            end
        end
    elseif d.State == "Move" then
        if d.AttackState == "JumpOut" then
            if sprite:IsFinished("Dive" .. d.AttackDir) then
                d.TimeOut = 0
                table.remove(d.HaemotoxiaAttackQueue, 1)
                if #d.HaemotoxiaAttackQueue == 0 then
                    d.HaemotoxiaAttackQueue = GetHaemoAttack(d, rng, attacks2)
                end
                d.State = "Emerge"
                d.TimeOut = 0
            elseif sprite:IsEventTriggered("Jump") then
                d.Jumping = true
                d.JumpSpeed = (d.TargetPos-npc.Position):Length()/bal.RingJumpFrames
                d.HaemoCreeping = nil
                for key,creep in pairs(d.MyCreep) do
                    if creep:Exists() then
                        creep:GetData().NoRandomSpikes = nil
                        creep:GetData().HaemoMainPuddle = nil
                        creep:GetData().SpecialTimeout = bal.MoveCreepTimeout
                    else
                        d.MyCreep[key] = nil
                    end
                end
                d.MyCreep = nil

                npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT, 1, 0, false, 1)

                for i=1,4 do
                    local dir = (d.TargetPos-npc.Position)
                    if dir:Length() < 20 then
                        dir = Vector(0,1):Rotated(rng:RandomInt(360))
                    end
                    local vel = dir:Resized(mod:RandomInt(25, 80, rng)/10):Rotated(mod:RandomInt(-90, 90, rng))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position, vel, npc):ToEffect()
                    drop.PositionOffset = Vector(0, mod:RandomInt(-80,-35,rng))
                    drop.Color = mod.Colors.HaemotoxiaCreep
                    drop.FallingSpeed = mod:RandomInt(-80, -10, rng)/10
                end
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, npc.Position, Vector.Zero, npc):ToEffect()
                poof.Color = mod.Colors.HaemotoxiaCreep
                poof.FlipX = (d.TargetPos-npc.Position).X > 0
                poof:Update()
            elseif sprite:IsEventTriggered("Land") then
                d.Jumping = nil
                d.HaemoCreeping = true

                npc:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, 1, 0, false, 1)
                npc:PlaySound(SoundEffect.SOUND_HEARTIN, 0.8, 0, false, 0.9)
                npc:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, 1, 0, false, 1)
                
                for i=1,6 do
                    local vel = Vector(mod:RandomInt(55, 150, rng)/10, 0):Rotated(rng:RandomInt(360))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, npc.Position, vel, npc):ToEffect()
                    drop.PositionOffset = Vector(0, mod:RandomInt(-60,-30,rng))
                    drop.Color = mod.Colors.HaemotoxiaCreep
                    drop.FallingSpeed = mod:RandomInt(-65, -5, rng)/10
                end
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc):ToEffect()
                poof.SpriteOffset = Vector(0, -10)
                poof.SpriteScale = Vector(0.6, 0.6)
                poof.Color = mod.Colors.HaemotoxiaCreep
                poof:Update()
                for i=-1,1,2 do
                    local pos = npc.Position+Vector(30*i, 0)+ShuntPos(5, rng)
                    local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, pos, Vector.Zero, npc):ToEffect()
                    poof2.Color = mod.Colors.HaemotoxiaCreep
                    poof2.DepthOffset = 50
                    poof2:Update()
                end
                local pos = npc.Position+Vector(0, 10)+ShuntPos(5, rng)
                local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, pos, Vector.Zero, npc):ToEffect()
                poof2.Color = mod.Colors.HaemotoxiaCreep
                poof2.DepthOffset = 50
                poof2:Update()
            else
                mod:SpritePlay(sprite, "Dive" .. d.AttackDir)
            end
        elseif d.AttackState == "Ending" then
            
        end

        if d.Jumping then
            --Roughly 18 frames midair
            if npc.Position:Distance(d.TargetPos) < 30 then
                npc.Velocity = d.TargetPos-npc.Position
            else
                npc.Velocity = mod:Lerp(npc.Velocity, (d.TargetPos-npc.Position):Resized(d.JumpSpeed), 0.4)
            end
        else
            npc.Velocity = Vector.Zero
        end
    end

    if d.HaemoCreeping then
        if not d.MyCreep then
            d.MyCreep = {}
            for i=-1,1,2 do
                local pos = npc.Position+Vector(30*i, 0)+ShuntPos(5, rng)
                local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, pos, Vector.Zero, npc):ToEffect()
                creep.SpriteScale = Vector(bal.BombCreepSize, bal.BombCreepSize)
                creep:GetData().NoRandomSpikes = true
                creep:GetData().HaemoMainPuddle = true
                creep:Update()
                table.insert(d.MyCreep, creep)
            end
            local pos = npc.Position+Vector(0, 10)+ShuntPos(5, rng)
            local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, pos, Vector.Zero, npc):ToEffect()
            creep.SpriteScale = Vector(bal.BombCreepSize, bal.BombCreepSize)
            creep:GetData().NoRandomSpikes = true
            creep:GetData().HaemoMainPuddle = true
            creep:Update()
            table.insert(d.MyCreep, creep)
        end
    end
end

function mod:HaemotoxiaRender(npc, sprite, d)
    if mod:IsNormalRender() then
        if not d.AppearAnimationed and d.State and d.State == "ShootBomb" then --Appear animation
            if sprite:IsEventTriggered("Land") then
                npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
                game:ShakeScreen(4)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                d.AppearAnimationed = true
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, npc.Position, Vector.Zero, npc):ToEffect()
                mod:ScheduleForUpdate(function() --OKAY. Leaving this in without the scheduler causes the game to crash
                    game:MakeShockwave(npc.Position, 0.01, 0.05, 10)
                end, 1)
            end
        elseif sprite:IsPlaying("Death") then
            local room = game:GetRoom()
            if not d.Watered then
                room:SetWaterColor(KColor(0.3, 0.05, 0, 0.95))
                room:GetFXParams().WaterEffectColor = Color(1, 0.1, 0.1)
                d.WaterAmount = 0
                d.WaterFrames = 0
                d.HaemotoxiaBleedDeath = 0
                d.HaemotoxiaFreqInc = 0
                d.HaemotoxiaShrinkFrame = 0
                d.Watered = true

                for _,creep in ipairs(Isaac.FindByType(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, false, false)) do
                    if not creep:GetData().RemoveFerro then
                        creep:GetData().RemoveFerro = true
                        creep:ToEffect():SetTimeout(1)
                    end
                end
                PlusShotBreaks = {}
                for _,proj in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, 0, 0, false, false)) do
                    if proj:GetData().GetClearedWhenHaemoDies then
                        proj:GetData().projType = nil
                    end
                end
            end

            if npc.FrameCount % 3 == 0 and npc.FrameCount > d.WaterFrames then
                d.WaterFrames = npc.FrameCount
                d.WaterAmount = math.min(1, d.WaterAmount+bal.WaterInc)
                room:SetWaterAmount(d.WaterAmount)
                room:SetWaterColor(KColor(0.3, 0.03, 0, 0.95))
            end


            if sprite:IsEventTriggered("Target") then
                d.ShrinkingDeath = true
                d.DeathVec = Vector(30, 15)
                d.DeathFreq = 4
            end
            if not d.ShrinkingDeath then
                if npc.FrameCount % 3 == 0 and npc.FrameCount > d.HaemotoxiaBleedDeath then
                    d.HaemotoxiaBleedDeath = npc.FrameCount
                    local rng = npc:GetDropRNG()
                    local height = sprite:GetNullFrame("EffectGuide")
                    local poof = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc):ToEffect()
                    poof.Color = npc.SplatColor
                    poof.SplatColor = npc.SplatColor
                    poof.SpriteOffset = Vector(mod:RandomInt(-50,50,rng), mod:RandomInt(-20,height.Y,rng))
                    poof.DepthOffset = 5
                    poof:Update()

                    npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.2, 0, false, mod:RandomInt(90,110,rng)/100)
                end
            else
                if npc.FrameCount % d.DeathFreq == 0 and npc.FrameCount > d.HaemotoxiaBleedDeath then
                    d.HaemotoxiaBleedDeath = npc.FrameCount
                    local rng = npc:GetDropRNG()
                    local poof = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc):ToEffect()
                    poof.Color = npc.SplatColor
                    poof.SplatColor = npc.SplatColor
                    poof.SpriteOffset = Vector(mod:RandomInt(-d.DeathVec.X,d.DeathVec.X,rng), mod:RandomInt(-d.DeathVec.Y,d.DeathVec.Y,rng))
                    poof.DepthOffset = 5
                    poof:Update()

                    npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.2, 0, false, mod:RandomInt(90,110,rng)/100)
                end

                if npc.FrameCount % 4 == 0 and npc.FrameCount > d.HaemotoxiaShrinkFrame then
                    d.HaemotoxiaShrinkFrame = npc.FrameCount
                    local x = d.DeathVec.X-1
                    local y = d.DeathVec.Y
                    if x % 2 == 0 then
                        y = y-1
                    end
                    d.DeathVec = Vector(math.max(1, x), math.max(1, y))
                end

                if npc.FrameCount % 10 == 0 and npc.FrameCount > d.HaemotoxiaFreqInc then
                    d.HaemotoxiaFreqInc = npc.FrameCount
                    d.DeathFreq = d.DeathFreq+1
                end
            end
        end
    end
end

function mod:HaemotoxiaHurt(npc, damage, flags, source)
    local d = npc:GetData()
    if source and source.Entity and source.Entity.Type == EntityType.ENTITY_BOMB and source.Entity:GetData().HaemotoxiaBloodBomb then
        return false
    elseif d.Phase2 and not d.Phase2ed then
        if d.DamageNegation and flags ~= flags | DamageFlag.DAMAGE_CLONES then
            npc:TakeDamage(math.min(1, damage*bal.PhaseReduction), flags | DamageFlag.DAMAGE_CLONES, source, 0)
            return false
        elseif d.DamageMitigation and flags ~= flags | DamageFlag.DAMAGE_CLONES then
            npc:TakeDamage(damage*bal.PhaseReduction, flags | DamageFlag.DAMAGE_CLONES, source, 0)
            return false
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == mod.ENT.FerroCreep.Sub then
        local d = effect:GetData()
        if not d.HaemoSetCreepColor then
            effect.Color = mod.Colors.HaemotoxiaCreep
            d.HaemoSetCreepColor = true
        end
        if d.DONTDOANYTHINGELSEHAEMO then
            return
        end
        if effect.FrameCount > bal.FerroSpikeDelay then
            if not d.init and effect.State == 1 then
                local room = game:GetRoom()
                local rng = effect:GetDropRNG()
                --it's a bit late that i realize i could just do angle stuff that's built in instead of this hexagon geometry stuff
                --at least this is less expensive
                local checkCreep = {}
                for _,creep in ipairs(Isaac.FindByType(effect.Type, effect.Variant, effect.SubType, false, false)) do
                    if not (creep.InitSeed == effect.InitSeed or creep:ToEffect().State > 1) and creep.Position:Distance(effect.Position) < creep.Size+effect.Size then
                        table.insert(checkCreep, creep)
                    end
                end
                d.SpikePositions = {}
                local radius = effect.Size-bal.FerroSafety
                local step = 3/2*bal.FerroSpacing
                local num = math.floor(radius/step)
                for i=-num,num do
                    local x = step*i
                    local offset = 0
                    if i % 2 == 1 then
                        offset = math.sqrt(3)/2*bal.FerroSpacing
                    end

                    local chord = math.sqrt(radius^2-x^2)
                    chord = chord*0.9 --There were some odd spikes that pressed out too far vertically
                    local pos
                    local val = 0
                    local firstTime = true
                    for j=-1,1,2 do
                        while math.abs(val) < chord do
                            if math.abs(val) < chord and not (firstTime and offset == 0) then
                                pos = effect.Position+Vector(x, (val+offset)*j)+ShuntPos(bal.FerroShift, rng)
                                if room:IsPositionInRoom(pos, 1) and room:GetGridCollisionAtPos(pos) == GridCollisionClass.COLLISION_NONE then
                                    local blacklist
                                    if #checkCreep > 0 then
                                        for _,creep in ipairs(checkCreep) do
                                            if creep:GetData().SpikePositions and not (d.HaemoMainPuddle and not creep:GetData().HaemoMainPuddle) then
                                                for _,entry in ipairs(creep:GetData().SpikePositions) do
                                                    if pos:Distance(entry.Pos) < bal.FerroSpacing then
                                                        blacklist = true
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if not blacklist or (offset == 0 and d.SpecialBehavior == "Charge") then
                                        table.insert(d.SpikePositions, {Pos = pos, Special = d.SpecialBehavior})
                                        d.SpecialBehavior = nil
                                    end
                                end
                            end
                            firstTime = nil
                            val = val+math.sqrt(3)*bal.FerroSpacing
                        end
                        val = 0
                    end
                end

                for _,entry in ipairs(d.SpikePositions) do
                    local dist = entry.Pos:Distance(effect.Position)
                    local active = d.CustomFerroActive or bal.FerroActive
                    if entry.Special or (1 == 0 and dist < effect.Size*active[1]) then
                        local spike = Isaac.Spawn(mod.ENT.FerroCreepSpikes.ID, mod.ENT.FerroCreepSpikes.Var, 0, entry.Pos, Vector.Zero, effect):ToEffect()
                        spike.Parent = effect
                        spike:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        
                        local frame = 1
                        if not entry.Special and 1 == 0 then
                            if active[4] and dist < effect.Size*active[4] then
                                frame = 4
                            elseif active[3] and dist < effect.Size*active[3] then
                                frame = 3
                            elseif active[2] and dist < effect.Size*active[2] then
                                frame = 2
                            end
                        elseif entry.Special == "Charge" then
                            frame = 3
                            spike:GetData().SpecialBehavior = "Charge"
                            if effect.Child and effect.Child:Exists() then
                                effect.Child.Parent = spike
                                spike.Child = effect.Child
                                effect.Child = nil
                            end
                        end
                        spike:GetData().TargetFrame = frame
                        entry.Spike = spike
                    end
                end

                d.init = true
            end

            if not d.RemoveFerro and effect.State == 1 then
                if not d.SpecialTimeout then
                    effect:SetTimeout(20)
                end

                local measure = bal.FerroPlayer[2]-bal.FerroPlayer[1]
                local unit = measure/4
                for i = 1, game:GetNumPlayers() do
                    local p = Isaac.GetPlayer(i-1)
                    local dist = p.Position:Distance(effect.Position)
                    if d.SpikePositions and dist < effect.Size+bal.FerroPlayer[2] then
                        for _,entry in ipairs(d.SpikePositions) do
                            if (not entry.Spike or not entry.Spike:Exists()) and entry.Pos:Distance(p.Position) < bal.FerroPlayer[2] then
                                local DONT
                                for _,boss in ipairs(Isaac.FindByType(mod.ENT.Haemotoxia.ID, mod.ENT.Haemotoxia.Var, 0, false, false)) do
                                    if entry.Pos:Distance(boss.Position) < boss.Size then
                                        if math.abs(entry.Pos.Y-boss.Position.Y) < boss.Size*boss.SizeMulti.Y then
                                            DONT = true
                                            break
                                        end
                                    end
                                end
                                local res = 5-math.ceil((entry.Pos:Distance(p.Position)-bal.FerroPlayer[1])/unit)
                                if not DONT and res > 2 then
                                    local spike = Isaac.Spawn(mod.ENT.FerroCreepSpikes.ID, mod.ENT.FerroCreepSpikes.Var, 0, entry.Pos, Vector.Zero, effect):ToEffect()
                                    spike.Parent = effect
                                    spike:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                    spike:GetData().TargetFrame = 0
                                    entry.Spike = spike
                                end
                            end
                        end
                    end
                end

                if not d.FerroFrameOff then
                    d.FerroFrameOff = effect:GetDropRNG():RandomInt(10)
                end
                if not d.NoRandomSpikes and  #d.SpikePositions > 1 and (effect.FrameCount+d.FerroFrameOff) % bal.FerroSpikeFreq == 0 then
                    local rng = effect:GetDropRNG()
                    local goodSpikes = {}
                    for key,entry in ipairs(d.SpikePositions) do
                        if (not entry.Spike or not entry.Spike:Exists()) and (not entry.Cooldown or effect.FrameCount-entry.Cooldown > bal.FerroCooldown) then
                            table.insert(goodSpikes, key)
                        end
                    end
                    if #d.SpikePositions > 5 then
                        local prevSpike
                        for i=1,1 do
                            if prevSpike then
                                local gooderSpikes = {}
                                for _,key in pairs(goodSpikes) do
                                    if d.SpikePositions[key].Pos:Distance(prevSpike.Position) < bal.FerroSpacing*2 then
                                    else
                                        table.insert(gooderSpikes, key)
                                    end
                                end
                                if #gooderSpikes < #goodSpikes then
                                    goodSpikes = gooderSpikes
                                end
                            end
                            local key = goodSpikes[rng:RandomInt(#goodSpikes)+1]
                            if key ~= nil then
                                local entry = d.SpikePositions[key]
                                local spike = Isaac.Spawn(mod.ENT.FerroCreepSpikes.ID, mod.ENT.FerroCreepSpikes.Var, 0, entry.Pos, Vector.Zero, effect):ToEffect()
                                spike.Parent = effect
                                spike:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                spike:GetData().TargetFrame = 0
                                spike:GetData().FerroIdle = true
                                entry.Spike = spike
                                entry.Cooldown = effect.FrameCount
                                prevSpike = spike
                            end
                        end
                    end
                end
            end
        end
	end
end, mod.ENT.FerroCreep.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()
    local d = effect:GetData()
    local rng = effect:GetDropRNG()

    if not d.init then
        d.TargetFrame = d.TargetFrame or 1
        d.CurrentFrame = 1
        d.StateFrame = 0
        d.FerroFrame = mod:RandomInt(bal.FerroFrames[1], bal.FerroFrames[2], rng)
        effect.FlipX = (rng:RandomInt(2) == 0 and true) or false
        sprite:Stop()
        sprite:SetFrame("Idle", d.CurrentFrame)
        sprite:Stop()
        d.OriginalSpikePos = effect.Position
        effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        d.init = true
    else
        d.StateFrame = d.StateFrame+1
    end

    local yay = true
    if not effect.Parent or not effect.Parent:Exists() or (effect.Parent:ToEffect() and effect.Parent:ToEffect().State > 1) then
        d.TargetFrame = 0
        d.TempFrame = nil
        if d.MyCreep and effect.Parent then
            d.MyCreep:SetTimeout(effect.Parent:ToEffect().Timeout)
            d.MyCreep.State = effect.Parent:ToEffect().State
        end
        yay = false
    end

    if d.State and d.State == "Poking" then
        if sprite:IsFinished("PokeUp") then
            d.State = nil
            d.CurrentFrame = 3
            sprite:Stop()
            sprite:SetFrame("Idle", d.CurrentFrame)
            sprite:Stop()
            playedSplitSound = nil
        elseif sprite:IsEventTriggered("Spike") then
            if effect.Child and effect.Child:Exists() then
                effect.Child:Die()
                if not playedSplitSound then
                    sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
                end
            end
            if not playedSplitSound then
                playedSplitSound = true
                sfx:Play(SoundEffect.SOUND_TOOTH_AND_NAIL, 1, 0, false, 1.5)
            end
        else
            mod:spritePlay(sprite, "PokeUp")
        end

        effect.Velocity = Vector.Zero
    elseif d.FerroIdle then
        if sprite:IsFinished("Cycle") then
            effect:Remove()
        else
            mod:spritePlay(sprite, "Cycle")
        end

        effect.Velocity = Vector.Zero
	elseif d.StateFrame % d.FerroFrame == 0 then
        if yay and not (d.SpecialBehavior and d.SpecialBehavior == "Charge") then
            local measure = bal.FerroPlayer[2]-bal.FerroPlayer[1]
            local unit = measure/4
            local found
            local highest = 0
            for i = 1, game:GetNumPlayers() do
                local p = Isaac.GetPlayer(i-1)
                local dist = p.Position:Distance(effect.Position)
                if dist < bal.FerroPlayer[2] then
                    found = true
                    local res = 5-math.ceil((dist-bal.FerroPlayer[1])/unit)
                    if res > 2 and res > d.TargetFrame and res > highest then
                        highest = res
                    end

                    if dist < bal.FerroHurt then
                        p:TakeDamage(1, 0, EntityRef(effect), 0)
                    end
                end
            end
            if found then
                if d.TempFrame and highest > d.TempFrame then
                    d.TempFrame = highest
                elseif not d.TempFrame then
                    d.TempFrame = highest
                end
            else
                d.TempFrame = nil
            end
        end

        local val = d.TargetFrame
        if d.TempFrame and d.TempFrame > d.TargetFrame then
            val = d.TempFrame
        end

        if d.CurrentFrame > val then
            d.CurrentFrame = d.CurrentFrame-1
        elseif d.CurrentFrame < val then
            d.CurrentFrame = d.CurrentFrame+1
            if d.CurrentFrame == 3 then
                if rng:RandomInt(3) == 0 then
                    sfx:Play(SoundEffect.SOUND_TOOTH_AND_NAIL_TICK, 0.3, 0, false, mod:RandomInt(85, 125, rng)/100)
                end
                local num = rng:RandomInt(3)+1
                for i=1,num do
                    local vel = Vector(mod:RandomInt(10,45,rng)/10, 0):Rotated(rng:RandomInt(360))
                    local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WATER_SPLASH, 1, effect.Position, vel, effect):ToEffect()
                    drop.FallingSpeed = -mod:RandomInt(45,90,rng)/10
                    drop.m_Height = -5
                    drop.Color = Color(0.8, 0, 0, 1, 0.3, 0, 0, 0.2, 0, 0, 1)
                end
            end
        end

        if d.CurrentFrame > 0 then
            sprite:SetFrame("Idle", d.CurrentFrame-1)
        else
            if d.MyCreep then
                local vel = Vector.Zero
                if effect.Parent and effect.Parent:Exists() then
                    vel = (effect.Parent.Position-effect.Position):Resized(0.33*effect.Parent.SpriteScale.X)
                end
                d.MyCreep.Velocity = vel
                d.MyCreep:SetTimeout(1)
                d.MyCreep:GetData().HaemoDone = true
            end
            effect:Remove()
        end
    end

    if effect.Parent and effect.Parent:Exists() then
        --[[if d.CurrentFrame < 3 then
            effect.Velocity = mod:Lerp(effect.Velocity, (effect.Parent.Position-effect.Position):Resized(mod:RandomInt(1,10,rng)/9), 0.4)
        else
            if effect.Position:Distance(d.OriginalSpikePos) < 3 then
                effect.Velocity = d.OriginalSpikePos-effect.Position
            else
                effect.Velocity = mod:Lerp(effect.Velocity, (d.OriginalSpikePos-effect.Position):Resized(3), 0.4)
            end
        end

        effect.Velocity = effect.Velocity+Vector(0,mod:RandomInt(1,3,rng)/13):Rotated(rng:RandomInt(360))

        local dist = d.OriginalSpikePos-effect.Position
        if dist:Length() > bal.FerroRad then
            local distToClose = dist - dist:Resized(bal.FerroRad)
            effect.Velocity = effect.Velocity + distToClose*0.5
        end]]
        effect.Velocity = Vector.Zero

        if not d.MyCreep then
            d.MyCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, effect.Position, Vector.Zero, effect):ToEffect()
            d.MyCreep.Color = effect.Parent.Color
            d.MyCreep:Update()
            d.MyCreep:GetSprite():SetFrame(effect.Parent:GetSprite():GetFrame())
            d.MyCreep:Update()
            d.MyCreep.SpriteScale = Vector(0.2, 0.2)
        elseif d.MyCreep and not d.MyCreep:GetData().HaemoDone then
            d.MyCreep.Velocity = (effect.Position-d.MyCreep.Position)
            d.MyCreep:SetTimeout(20)
            if d.MyCreep.SpriteScale.X < 1 then
                local num = math.min(1, d.MyCreep.SpriteScale.X+0.1)
                d.MyCreep.SpriteScale = Vector(num, num)
            end
        end
    else
        effect.Velocity = mod:Lerp(effect.Velocity, Vector.Zero, 0.2)
    end
end, mod.ENT.FerroCreepSpikes.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	if explosion.SpawnerEntity and 
	   explosion.SpawnerEntity:GetData().HaemotoxiaBloodBomb and
	   not explosion.SpawnerEntity:GetData().HaemotoxiaBloodBombExploded
	then
		local bomb = explosion.SpawnerEntity
        bomb:GetData().HaemotoxiaBloodBombExploded = true

		local creep = Isaac.Spawn(mod.ENT.FerroCreep.ID, mod.ENT.FerroCreep.Var, mod.ENT.FerroCreep.Sub, explosion.Position, Vector.Zero, bomb):ToEffect()
        creep.SpriteScale = Vector(bal.BombCreepSize, bal.BombCreepSize)
        if bomb:GetData().SpecialTimeout then
            creep:GetData().SpecialTimeout = true
            creep:SetTimeout(bomb:GetData().SpecialTimeout)
        end
        creep:GetData().HaemotoxiaBombCreep = true
        creep:Update()

        for _,proj in ipairs(Isaac.FindInRadius(explosion.Position, bal.BombRadius, EntityPartition.BULLET)) do
            if proj:GetData().HaemotoxiaBombShot then
                proj:GetData().HaemotoxiaDetonate = true
            end
        end

        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, explosion.Position, Vector.Zero, bomb):ToEffect()
        poof.Color = mod.Colors.HaemotoxiaCreep
        local rng = bomb:GetDropRNG()
        for i=1,3 do
            local vel = Vector(0,mod:RandomInt(6,8,rng)):Rotated(rng:RandomInt(360))
            local pof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, bomb.Position, vel, bomb):ToEffect()
            pof.Color = mod.Colors.HaemotoxiaCreep
        end
        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, bomb.Position, Vector.Zero, bomb):ToEffect()
        splat.SpriteScale = Vector(3, 3)
        splat.Color = mod.Colors.HaemotoxiaCreep
	end
end, EffectVariant.BOMB_EXPLOSION)

--This doesn't stop tears from colliding, but it at least stops player pushing
mod:AddPriorityCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, CallbackPriority.EARLY, function(_, bomb)
    if bomb:GetData().IgnoreHighCollHaemo then
        if bomb.PositionOffset.Y < bal.BombCollHeight then
            return true
        end
    end
end, 0)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
    local d = laser:GetData()
    if d.HaemoSpecialLaser then
        laser.Color = d.HaemoSpecialerLaser or Color(1, 1, 1, 1, 0, 0, 0, 0, 0, 0)

        if d.HaemoSpecialerLaser then
            if laser.Parent and laser.Parent:Exists() then
                laser.Velocity = (laser.Parent.Position-laser.Position)
                local alph
                if laser.FrameCount % 8 == 0 then
                    if not d.HaemoRed then
                        d.HaemoRed = 3
                    else
                        d.HaemoRed = nil
                    end
                end
                local red = mod:Lerp(d.HaemoSpecialerLaser:GetColorize().R, d.HaemoRed or 1, 0.1)
                if d.DIEDIEDIEDIE then
                    alph = mod:Lerp(d.HaemoSpecialerLaser.A, 0, 0.4)
                    if alph < 0.05 then
                        laser:Remove()
                    end
                else
                    alph = mod:Lerp(d.HaemoSpecialerLaser.A, 0.5, 0.25)
                end
                d.HaemoSpecialerLaser = Color(1, 0.8, 0.65, alph, 0, 0, 0, red, 0.6, 0.5, 1)
            else
                laser:Remove()
            end
        end
    end
end, LaserVariant.THICK_RED)

mod:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, function(_, laser)
    if laser:GetData().HaemoSpecialLaser then
        return true
    end
end, LaserVariant.THICK_RED)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
    local d = e:GetData()
    if d.HaemotoxiaTarget then
        local sprite = e:GetSprite()
        --I hate you blink animation I hate you blink animation
        if e.FrameCount % 2 == 0 then
            if not d.PLAYBLINK then
                d.PLAYBLINK = true
            else
                d.PLAYBLINK = nil
            end
        end
        if d.PLAYBLINK then
            sprite:SetFrame("Blink", 1)
        else
            sprite:SetFrame("Blink", 0)
        end
        --mod:SpritePlay(e:GetSprite(), "Blink")

        if not e.Parent or not e.Parent:Exists() then
            e:Remove()
        end
    end
end, EffectVariant.TARGET)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
    local d = e:GetData()
    local sprite = e:GetSprite()
    local rng = e:GetDropRNG()
    if not d.init then
        e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        e.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        e:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        d.ClotSprite = rng:RandomInt(2)+1
        d.State = "Idle"
        d.init = true
    end

    if e.Parent and not mod:isStatusCorpse(e.Parent) and not e.Parent:GetSprite():IsPlaying("Death") then
        if d.State == "Idle" then
            if e:CollidesWithGrid() then
                d.State = "Bounce"
                e.Velocity = bal.ClotRebound*(d.ClotVel or Vector.Zero)
                sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
            else
                e.Velocity = mod:Lerp(e.Velocity, d.ClotVel or Vector.Zero, 0.3)
            end
            if e.FrameCount % bal.ClotProjFreq1 == 0 then
                for i=-1,1,2 do
                    local vel = d.ClotVel:Rotated(bal.ClotProjAngle1*i):Resized(mod:RandomInt(bal.ClotProjSpeed1[1], bal.ClotProjSpeed1[2], rng)/10)
                    local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, e.Position, vel, e):ToProjectile()
                    proj.FallingSpeed = -0.05
                    proj.FallingAccel = -0.05
                    proj.Scale = mod:RandomInt(bal.ClotProjScale1[1], bal.ClotProjScale1[2], rng)/100
                    proj:Update()
                end

                local vel = d.ClotVel:Rotated(180+mod:RandomInt(-20, 20, rng)):Resized(mod:RandomInt(5, 18, rng)/10)
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, e.Position+d.ClotVel:Rotated(180):Resized(5), vel, e):ToEffect()
                poof.SpriteOffset = e.PositionOffset*0.8
                poof.Color = mod.Colors.HaemotoxiaCreep
                poof.DepthOffset = 20
                local sca = mod:RandomInt(70, 100, rng)/100
                poof.SpriteScale = Vector(sca, sca)
                poof:Update()
            end

            mod:SpritePlay(sprite, "Idle")
        elseif d.State == "Bounce" then
            if sprite:IsFinished("Impact") then
                e.Parent:GetData().AttackState = "IdleToSuck"
                d.State = "Idle2"
                d.ClotDir = (e.Parent.Position-e.Position)
                d.ClotAngle = 0
            else
                mod:SpritePlay(sprite, "Impact")
            end

            e.Velocity = mod:Lerp(e.Velocity, Vector.Zero, 0.25)
        elseif d.State == "Idle2" then
            mod:SpritePlay(sprite, "Idle")
            if e.FrameCount % bal.ClotProjFreq2 == 0 then
                for i=1,bal.ClotProjNum2 do
                    local vel = d.ClotDir:Resized(bal.ClotProjSpeed2, 0):Rotated(i*360/bal.ClotProjNum2+d.ClotAngle)
                    local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, e.Position, vel, e):ToProjectile()
                    proj.FallingSpeed = -0.05
                    proj.FallingAccel = -0.05
                    if not d.ClotScale then
                        proj.Scale = bal.ClotProjScale2[1]
                        d.ClotScale = true
                    else
                        proj.Scale = bal.ClotProjScale2[2]
                        d.ClotScale = nil
                    end
                    proj:GetData().projType = "customProjectileBehavior"
                    proj:GetData().customProjectileBehaviorLJ = {customFunc = function() proj.FallingSpeed = -0.05 proj.FallingAccel = -0.05 end}
                end
                d.ClotAngle = d.ClotAngle+180/bal.ClotProjNum2
                sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 0.7, 0, false, mod:RandomInt(120,130,rng)/100)
                sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.5, 0, false, 1)
                
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, e.Position, Vector.Zero, e):ToEffect()
                poof.SpriteOffset = e.PositionOffset*0.8
                poof.Color = mod.Colors.HaemotoxiaCreep
                poof.DepthOffset = 20
                poof:Update()
                local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, e.Position, Vector.Zero, e):ToEffect()
                poof2.SpriteOffset = e.PositionOffset*0.7
                poof2.DepthOffset = 30
                poof2.Color = Color(0, 0, 0, 0.5, 0.3, 0.03, 0.03, 3.5, 0.3, 0.3, 1)
                poof2.SpriteScale = Vector(1.8, 1.8)
                poof2:Update()
            end
        end

        for i = 1, game:GetNumPlayers() do
            local p = Isaac.GetPlayer(i-1)
            local dist = p.Position:Distance(e.Position)
            if dist < e.Size+1 then
                p:TakeDamage(1, 0, EntityRef(e), 0)
            end
        end

        if e.FrameCount % 16 == 0 then
            local vel = Vector(mod:RandomInt(5, 35, rng)/10, 0):Rotated(rng:RandomInt(360))
            local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, e.Position+ShuntPos(15, rng), vel, e):ToEffect()
            gib:Update()
            gib.Color = HaemoCreepProjColor
            gib:Update()
        end

        if e.FrameCount % 3 == 0 then
            local vel = e.Velocity:Rotated(180+mod:RandomInt(-20,20,rng))
            local circle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, e.Position+ShuntPos(12,rng), vel, e):ToEffect()
            circle.SpriteOffset = e.PositionOffset*0.65
            local sca = mod:RandomInt(100,150,rng)/100
            circle.SpriteScale = Vector(sca, sca)
            circle:SetTimeout(70)
            circle.DepthOffset = e.DepthOffset-45
            circle.Color = mod.Colors.HaemotoxiaCreep
            circle:Update()
        end

        e.PositionOffset = mod:Lerp(e.PositionOffset, Vector(0, -30), 0.2)
    else
        for i=1,5 do
            local splof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, e.Position, Vector.Zero, e):ToEffect()
            splof.Color = mod.Colors.HaemotoxiaCreep
            splof.PositionOffset = e.PositionOffset
            splof.SpriteOffset = ShuntPos(10, rng)
            local scal = mod:RandomInt(55, 100, rng)/100
            splof.SpriteScale = Vector(scal, scal)
            splof:Update()
        end
        for i=1,4 do
            local vel = Vector(mod:RandomInt(15, 75, rng)/10, 0):Rotated(rng:RandomInt(360))
            local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, e.Position, vel, e):ToEffect()
            gib:Update()
            gib.Color = HaemoCreepProjColor
            gib:Update()
        end
        for i=1,4 do
            local vel = Vector(mod:RandomInt(45,95,rng)/10, 0):Rotated(rng:RandomInt(360))
            local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 0, e.Position, vel, e):ToEffect()
            drop.PositionOffset = Vector(0, -45)
            drop.Color = mod.Colors.HaemotoxiaCreep
            drop.FallingSpeed = mod:RandomInt(-55,10,rng)/10
        end
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1, 0, false, 1)
        e:Remove()
    end
end, mod.ENT.HaemoClot.Var)