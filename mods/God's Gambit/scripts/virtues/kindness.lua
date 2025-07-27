local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

local bal = {
    moveSpeed = {3.5,3},
    intervalTime = 40,
    rotateRate = 0.5,
    numRays = {4,6},
}

local function ToggleBeams(npc, data)
    local isSuper = (npc.Variant == mod.ENT.SuperKindness.Var)
    local numRays = isSuper and bal.numRays[2] or bal.numRays[1]

    for i = 1, numRays do
        local angle = (360/numRays * i) + data.RayAngle
        if data.RayBeams[i] and data.RayBeams[i]:Exists() then
            data.RayBeams[i].Timeout = 1
        end
        if data.HasTracers then
            local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.LIGHT_BEAM, 0, npc.Position, Vector.Zero, npc):ToLaser()
            laser.Parent = npc
            laser.PositionOffset = Vector(0, -13)
            laser.Angle = angle
            laser:SetScale(0.5)
            if not mod:isFriend(npc) then
                laser.CollisionDamage = 0
            end
            laser.Mass = 0
            laser.DepthOffset = -120
            laser.Color = Color(1,1,1,0.75)
            laser:Update()
            data.RayBeams[i] = laser
        else
            local tracer = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, npc.Position, Vector(0.001,0), npc):ToEffect()
            tracer.TargetPosition = Vector(1,0):Rotated(angle)
            tracer.Timeout = bal.intervalTime + 15
            tracer.LifeSpan = bal.intervalTime + 10
            tracer:FollowParent(npc)
            tracer.DepthOffset = -120
            tracer.Color = Color(1,0.9,0.7,0.85)
            tracer:Update()
            data.RayBeams[i] = tracer
        end
    end

    if data.HasTracers then
        sfx:Stop(SoundEffect.SOUND_ANGEL_BEAM)
        sfx:Play(SoundEffect.SOUND_LIGHTBOLT)
    end

    data.HasTracers = not data.HasTracers
end

function mod:KindnessAI(npc, sprite, data)
    local isSuper = (npc.Variant == mod.ENT.SuperKindness.Var)
    local numRays = isSuper and bal.numRays[2] or bal.numRays[1]

    if not data.Init then
        data.State = "Idle"
        data.RayAngle = 0
        data.RaySprite = Sprite()
        data.RaySprite:Load(sprite:GetFilename(), true)
        data.RaySprite:Play("Ray", true)
        npc.I1 = 1
        npc.StateFrame = bal.intervalTime
        npc.SplatColor = mod.Colors.ColorKindnessYellow
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.RayBeams = {}
        ToggleBeams(npc, data)
        data.Init = true
    end

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle"..npc.I1)

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "Change"
        end

    elseif data.State == "Change" then
        if sprite:IsFinished("Change"..npc.I1) then
            npc.StateFrame = bal.intervalTime
            data.State = "Idle"
            npc.I1 = (npc.I1 == 2 and 1 or 2)
        elseif sprite:IsEventTriggered("Shoot") then
            ToggleBeams(npc, data)
            mod:PlaySound(data.HasTracers and SoundEffect.SOUND_THUMBS_DOWN or SoundEffect.SOUND_THUMBSUP, npc, isSuper and 0.8 or 1, 0.85)
        else
            mod:SpritePlay(sprite, "Change"..npc.I1)
        end
    end

    mod:MoveDiagonally(npc, isSuper and bal.moveSpeed[2] or bal.moveSpeed[1], 0.3, Vector(-1,1))
    mod:FlipSprite(sprite, npc.Position, npc.Position - npc.Velocity)
    data.RayAngle = data.RayAngle + bal.rotateRate

    for i, beam in pairs(data.RayBeams) do
        if beam:Exists() then
            local angle = (360/numRays * i) + data.RayAngle
            if data.HasTracers then
                beam.TargetPosition = Vector(1,0):Rotated(angle)
            else
                beam.Angle = angle
            end       
        end
    end

    if npc:IsDead() then
        for i, beam in pairs(data.RayBeams) do
            if beam:Exists() then
                beam.Timeout = 1
            end
        end
    end
end

function mod:KindnessRender(npc, sprite, data)
    if data.Init and npc.FrameCount > 3 and mod:IsNormalRender() then
        local isSuper = (npc.Variant == mod.ENT.SuperKindness.Var)
        local numRays = isSuper and bal.numRays[2] or bal.numRays[1]
        local basePos = Isaac.WorldToScreen(npc.Position + npc:GetNullOffset("OrbitPoint"))
        for i = 360/numRays, 360, 360/numRays do
            local angle = i + data.RayAngle
            data.RaySprite.Rotation = angle
            data.RaySprite:Render(basePos + (Vector(isSuper and 25 or 18,0):Rotated(angle) * sprite.Scale))
        end
    end
end