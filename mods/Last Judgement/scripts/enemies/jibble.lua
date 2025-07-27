local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    size = 55,
    attachRange = 40,
    idleTime = {30,45},
    jumpSpeed = 17,
    maxJumpSideSpeed = 8,
    sideSpeedVariance = {80,120}, --*0.01
    fallSpeed = 17,
    fallAccel = 0.05,
    projSpeed = 8,
}

local params = ProjectileParams()
params.Color = mod.Colors.VirusBlue
params.Scale = 1.25

local anglesToCheck = {0,180,90,270}

local function TryAttachToWall(npc, sprite, data, isInit)
    local room = game:GetRoom()
    if not room:IsPositionInRoom(npc.Position, -30) then
        npc:Kill()
    else
        for _, i in pairs(anglesToCheck) do
            local attachPos = room:GetLaserTarget(npc.Position, npc.V1:Rotated(i))
            if attachPos:Distance(npc.Position) <= bal.attachRange and not (npc.StateFrame > 0 and i == 0) then
                npc.V1 = npc.V1:Rotated(i)
                npc.Position = attachPos - npc.V1:Resized(25)
                data.AnimSuffix = mod:GetMoveString(npc.V1)
                sprite:Play("Land"..data.AnimSuffix, true)
                data.State = "Land"
                if not isInit then
                    --[[for j = 60, 360, 60 do
                        npc:FireProjectiles(attachPos - npc.V1:Resized(5), npc.V1:Rotated(j + 30):Resized(bal.projSpeed), 0, params)
                    end]]
                    npc:FireProjectiles(attachPos - npc.V1:Resized(5), Vector(bal.projSpeed,0), ProjectileMode.CIRCLE_EIGHT, params)
                    mod:PlaySound(SoundEffect.SOUND_GOOATTACH0, npc, 0.6)
                    mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS_OLD, npc, 0.6, 1.2)
                end
                if data.AnimSuffix == "Left" or data.AnimSuffix == "Right" then
                    data.GoingSideways = true
                else
                    data.GoingSideways = false
                end
                return true
            end
        end
    end
    return false
end

local function RegisterGib(npc, frame, radius)
    local rng = npc:GetDropRNG()
    local offset = RandomVector() * mod:RandomInt(10,bal.size-radius-10,rng)
    local dat = {
        Frame = frame,
        BaseOffset = offset,
        CurrentOffset = offset,
        FlipX = (rng:RandomFloat() <= 0.5),
        Radius = radius,
    }
    table.insert(npc:GetData().Gibs, dat)
end

function mod:JibbleAI(npc, sprite, data)
    local targetpos = mod:GetPlayerTargetPos(npc)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc.SplatColor = mod.Colors.VirusBlue
        npc.V1 = Vector(0,1)
        if not TryAttachToWall(npc, sprite, data, true) then
            data.State = "Move"
        end
        sprite:ReplaceSpritesheet(1, "blank.png", true)
        data.Gibs = {}
        for i = 1, mod:RandomInt(2,3) do
            RegisterGib(npc, mod:RandomInt(0,3,rng), 10)
        end
        RegisterGib(npc, rng:RandomFloat() <= 0.1 and 8 or mod:RandomInt(4,7,rng), 20)
        RegisterGib(npc, rng:RandomFloat() <= 0.1 and 10 or 9, 30)

        data.Init = true
    end

    mod:NegateKnockoutDrops(npc)

    if data.State == "Land" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Land"..data.AnimSuffix) then
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "Land"..data.AnimSuffix)
        end

    elseif data.State == "Idle" then
        npc.Velocity = Vector.Zero
        mod:SpritePlay(sprite, "Idle"..data.AnimSuffix)

        local attachPoint = room:GetLaserTarget(npc.Position, npc.V1)
        npc.StateFrame = npc.StateFrame - 1
        if attachPoint:Distance(npc.Position) > 35 then
            data.State = "Move"
        elseif npc.StateFrame <= 0 then
            data.State = "Jump"
        end

    elseif data.State == "Jump" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Jump"..data.AnimSuffix) then
            if data.GoingSideways then
                local sideSpeed = mod:BoundValue((targetpos.Y - npc.Position.Y)/20, -bal.maxJumpSideSpeed, bal.maxJumpSideSpeed) * (mod:RandomInt(bal.sideSpeedVariance,rng) * 0.01)
                npc.Velocity = Vector(-npc.V1:Resized(bal.jumpSpeed).X, sideSpeed)
            else
                local sideSpeed = mod:BoundValue((targetpos.X - npc.Position.X)/20, -bal.maxJumpSideSpeed, bal.maxJumpSideSpeed) * (mod:RandomInt(bal.sideSpeedVariance,rng) * 0.01)
                npc.Velocity = Vector(sideSpeed, -npc.V1:Resized(bal.jumpSpeed).Y)
            end
            npc.StateFrame = 20
            data.State = "Move"
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 0.6, 1.2)
        else
            mod:SpritePlay(sprite, "Jump"..data.AnimSuffix)
        end

    elseif data.State == "Move" then
        if data.GoingSideways then
            npc.Velocity = mod:Lerp(npc.Velocity, Vector(npc.V1:Resized(bal.fallSpeed).X, npc.Velocity.Y), bal.fallAccel)
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector(npc.Velocity.X, npc.V1:Resized(bal.fallSpeed).Y), bal.fallAccel)
        end
        mod:SpritePlay(sprite, "Move")
        npc.StateFrame = npc.StateFrame - 1
        TryAttachToWall(npc, sprite, data)
    end

    if npc:IsDead() then
        for i = 3, 4 do
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, i, npc.Position, Vector.Zero, npc)
            effect.Color = mod.Colors.VirusBlue
            effect:Update()
        end
    end
end

local gibSprite = Sprite()
gibSprite:Load("gfx/enemies/jibble/monster_jibble.anm2", true)

function mod:JibbleRender(npc, sprite, data)
    if data.Init and npc.FrameCount > 3 then
        if mod:IsNormalRender() then
            local animScale = sprite:GetCurrentAnimationData():GetLayer(0):GetFrame(sprite:GetFrame()):GetScale()
            local offsetMult = Vector.One + ((animScale - Vector.One) * 1.5)
            for _, gib in pairs(data.Gibs) do
                gib.CurrentOffset = gib.BaseOffset * offsetMult
            end
        end

        if not mod:IsRenderingReflection() then
            local basePos = npc.Position + npc.PositionOffset + npc:GetNullOffset("Center")
            gibSprite.Scale = sprite.Scale
            gibSprite.Color = sprite.Color
            for _, gib in pairs(data.Gibs) do
                gibSprite:SetFrame("Gibs", gib.Frame)
                gibSprite.FlipX = gib.FlipX
                gibSprite:Render(Isaac.WorldToScreen(basePos + gib.CurrentOffset) + npc.SpriteOffset)
            end
            gibSprite.FlipX = false
            gibSprite:SetFrame(sprite:GetAnimation(), sprite:GetFrame())
            gibSprite:RenderLayer(1, Isaac.WorldToScreen(npc.Position + npc.PositionOffset) + npc.SpriteOffset)
        end
    end
end