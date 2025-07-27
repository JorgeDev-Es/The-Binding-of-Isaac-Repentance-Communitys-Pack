local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    numProjs = 12,
    projGap = 6,
    moveSpeed = 2,
    chargeCooldown = {45,60},
    chargeAngleVar = 15,
    maxChargeOverreach = 160,
}

local params = ProjectileParams()
params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE

local function StrainBabyProj(proj, tab)
    if not tab.Init then
        local tint = mod:RandomInt(50,100) * 0.01
        local color = Color(0.5,0.75,1,1)
        color:SetColorize(1.15,1.5,3 * tint,1.25)
        proj.Color = color
        if tab.bigBoi then
            proj.Scale = 1.75
        else
            proj.Scale = mod:RandomInt(20,28) * 0.05
        end
        proj.FallingAccel = 0
        proj.FallingSpeed = 0
        tab.Init = true
    end

    if mod:IsReallyDead(proj.Parent) then
        proj.Velocity = proj.Velocity * 0.75
        proj.FallingAccel = 3
    else
        proj.Height = -10
        if proj.Parent.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_ALL then
            local vec = proj.Parent.Position - proj.Position
            proj.TargetPosition = proj.Parent.Position - vec:Resized(bal.projGap)
            proj.Velocity = mod:Lerp(proj.Velocity, (proj.TargetPosition - proj.Position)/5, 0.3)
        end
    end
end

local function StrainBabyProjDeath(proj, tab)
    if not (mod:IsReallyDead(proj.Child) or mod:IsReallyDead(proj.Parent)) then
        proj.Child.Parent = proj.Parent
        proj.Parent.Child = proj.Child
    end
end

local function GetStrainBabyPos(npc)
    local target = npc:GetPlayerTarget()
    local targetpos = target.Position + target.Velocity * 15
    local room = game:GetRoom()
    local chargepos = target.Position
    local vec = (targetpos - npc.Position):Rotated(mod:RandomInt(-bal.chargeAngleVar, bal.chargeAngleVar, npc:GetDropRNG()))
    for i = 0, bal.maxChargeOverreach, 20 do
        local newPos = npc.Position + vec + vec:Resized(i)
        if room:IsPositionInRoom(newPos, 0) then
            chargepos = newPos
        else
            return chargepos
        end
    end
    vec = (target.Position - npc.Position):Rotated(mod:RandomInt(-bal.chargeAngleVar, bal.chargeAngleVar, npc:GetDropRNG()))
    for i = 0, bal.maxChargeOverreach, 20 do
        local newPos = npc.Position + vec + vec:Resized(i)
        if room:IsPositionInRoom(newPos, 0) then
            chargepos = newPos
        else
            return chargepos
        end
    end
    return chargepos
end

local function DoCharge(npc)
    local sprite = npc:GetSprite()
    local suffix = mod:GetMoveString(npc.Velocity, true)
    sprite:SetAnimation("Dash"..suffix, false)
    if suffix == "Hori" then
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
    else
        sprite.FlipX = false
    end
    npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(12), 0.3)
end

function mod:StrainBabyAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.VirusBlue
        npc.StateFrame = mod:RandomInt(bal.chargeCooldown, rng)
        data.State = "Idle"
        data.Init = true

        local parent = npc
        data.NumProjs = 0
        for i = 1, bal.numProjs do
            mod:ScheduleForUpdate(function()
                if not mod:IsReallyDead(npc) then
                    local proj = npc:FireProjectilesEx(npc.Position, Vector.Zero, 0, params)[1]
                    proj:GetData().projType = "customProjectileBehavior"
                    proj:GetData().customProjectileBehaviorLJ = {customFunc = StrainBabyProj, bigBoi = (i == 1), death = StrainBabyProjDeath}
                    parent.Child = proj
                    proj.Parent = parent
                    parent = proj
                    proj:Update()
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, npc.Position, Vector.Zero, npc)
                    effect.Color = proj.Color
                    effect.SpriteOffset = Vector(0,-3)
                    effect:Update()
                    mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1, 0.3)
                    data.NumProjs = data.NumProjs + 1
                end
            end, i * 5)
        end
    end

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(bal.moveSpeed)), 0.1)

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 and data.NumProjs >= bal.numProjs and not mod:isScare(npc) then
            npc.StateFrame = mod:RandomInt(bal.chargeCooldown, rng)
            data.State = "ChargeStart"
        end

    elseif data.State == "ChargeStart" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("DashStart") then
            data.State = "Charging"
            npc.TargetPosition = GetStrainBabyPos(npc)
            sprite:Play("DashDown", true)
            DoCharge(npc)
            mod:PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR, npc, 1.2)
        else
            mod:SpritePlay(sprite, "DashStart")
        end

    elseif data.State == "Charging" then
        if npc.Position:Distance(npc.TargetPosition) <= 20 or npc:CollidesWithGrid() then
            sprite.FlipX = false
            data.State = "ChargeStop"
        else
            DoCharge(npc)
        end

    elseif data.State == "ChargeStop" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("DashEnd") then
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "DashEnd")
        end
    end
end