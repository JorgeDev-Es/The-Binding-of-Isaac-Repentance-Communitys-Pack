local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    chaseSpeed = 4,
    chaseTime = {45,75},
    attackDistance = 100,
    maxAttackDistance = 350,
    minAttackTime = 30,
    projSpeed = 13,
    deathProjSpeed = 9,
    runSpeed = 6,
    runTime = {15,45},
}

local params = ProjectileParams()
params.Color = mod.Colors.OrganBlue
params.Spread = 0.5

local function GetTransform(npc)
    local data = npc:GetData()
    local transforms = {1,2,3,4}
    if data.LastTransform then
        table.remove(transforms, data.LastTransform)
    end
    local transform = mod:GetRandomElem(transforms, npc:GetDropRNG()) or 1
    data.LastTransform = transform
    return transform
end

function mod:StressBallAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.StateFrame = mod:RandomInt(0,15,rng)
        npc.SplatColor = mod.Colors.OrganBlue
        data.State = "Run"
        data.Init = true
    end

    if data.State == "Transform" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Transform "..data.Transform) then
            npc.StateFrame = mod:RandomInt(bal.chaseTime, rng)
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1.5)
            data.Inflated = true
        else
            mod:SpritePlay(sprite, "Transform "..data.Transform)
        end

    elseif data.State == "Chase" then
        mod:ChasePlayer(npc, bal.chaseSpeed, 0.3)
        mod:AnimWalkFrame(npc, sprite, {"WalkRight "..data.Transform.." Flash", "WalkLeft "..data.Transform.." Flash"}, "WalkVert "..data.Transform.." Flash")

        npc.StateFrame = npc.StateFrame - 1
        local dist = npc.Position:Distance(targetpos)
        if (npc.StateFrame <= 0 or dist <= bal.attackDistance) and game:GetRoom():CheckLine(npc.Position, targetpos, 3) and dist <= bal.maxAttackDistance and npc.StateFrame <= bal.minAttackTime then
            data.State = "Attack"
        end

    elseif data.State == "Attack" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Squeeze "..data.Transform) then
            npc.StateFrame = mod:RandomInt(bal.runTime, rng)
            data.State = "Run"
        elseif sprite:IsEventTriggered("Shoot") then
            local startAngle = 180 - (90 * (data.Transform - 1))
            for i = startAngle, startAngle + 240, 120 do
                npc:FireProjectiles(npc.Position, Vector(bal.projSpeed, 0):Rotated(i), ProjectileMode.SPREAD_TWO, params)
            end
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc)
            effect.SpriteScale = Vector(0.7,0.7)
            effect.Color = mod:CloneColor(mod.Colors.OrganBlue, 0.75)
            effect.DepthOffset = -120
            effect.SpriteOffset = Vector(0,-20)
            effect:Update()
            mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc, 1.2)
            mod:PlaySound(SoundEffect.SOUND_HEARTIN, npc, 1.2)
            data.Inflated = false
        else
            mod:SpritePlay(sprite, "Squeeze "..data.Transform)
        end

    elseif data.State == "Run" then
        mod:WanderAbout(npc, data, bal.runSpeed, 0.3, 0, 0, bal.attackDistance)
        mod:AnimWalkFrame(npc, sprite, {"WalkRight", "WalkLeft"}, "WalkVert")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.Transform = GetTransform(npc)
            data.State = "Transform"
        end
    end

    if npc:IsDead() and data.Inflated then
        local startAngle = 180 - (90 * (data.Transform - 1))
        for i = startAngle, startAngle + 240, 120 do
            npc:FireProjectiles(npc.Position, Vector(bal.deathProjSpeed, 0):Rotated(i), ProjectileMode.SPREAD_TWO, params)
        end
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc)
        effect.SpriteScale = Vector(0.7,0.7)
        effect.Color = mod:CloneColor(mod.Colors.OrganBlue, 0.75)
        effect.DepthOffset = -40
        effect:Update()
        mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc, 1.2)
        mod:PlaySound(SoundEffect.SOUND_HEARTIN, npc, 1.2)
    end
end