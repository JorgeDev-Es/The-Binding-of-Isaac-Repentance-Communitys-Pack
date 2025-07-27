local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    targetRange = 160,
    maxTentacles = 30,
    maxTentacleCurve = 25,
}

local function GetTentacleEnd(npc)
    local parentEnt = npc
    local iterLimit = 0
    while iterLimit <= bal.maxTentacles and (parentEnt.Child and not mod:IsReallyDead(parentEnt.Child)) do
        parentEnt = parentEnt.Child
        iterLimit = iterLimit + 1
    end
    return parentEnt:ToNPC(), iterLimit, (iterLimit == 0)
end

function mod:PathoAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
        if game:GetRoom():IsClear() then
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
        Isaac.Spawn(mod.ENT.PathoGround.ID, mod.ENT.PathoGround.Var, 0, npc.Position, Vector.Zero, npc)
        if npc.SubType == 0 then
            npc.SubType = mod:RandomInt(1,2,rng)
            if rng:RandomFloat() <= 0.5 then
                npc.SubType = npc.SubType + 2
            end
        end
        data.AnimSuffix = (npc.SubType % 2) + 1
        sprite.FlipX = npc.SubType > 2
        npc.SplatColor = mod.Colors.BlueGuts
        data.State = "Idle"
        data.Init = true
    end

    npc.Velocity = Vector.Zero
    mod:NegateKnockoutDrops(npc)
    mod:QuickSetEntityGridPath(npc)

    if targetpos:Distance(npc.Position) <= bal.targetRange and npc.FrameCount > 30 then
        mod:SpritePlay(sprite, "Active"..data.AnimSuffix)

        local tentacleEnd, tentacleNum, isStarting = GetTentacleEnd(npc)
        if tentacleNum <= bal.maxTentacles then
            if isStarting or tentacleEnd:GetData().State == "Idle" then
                local targVec = targetpos - tentacleEnd.Position
                if isStarting then
                    tentacleEnd.V1 = targVec
                else
                    targVec = mod:AngleLimitVector(tentacleEnd.V1, targVec, bal.maxTentacleCurve)
                end
                local tentacle = Isaac.Spawn(mod.ENT.PathoTentacle.ID, mod.ENT.PathoTentacle.Var, tentacleNum, tentacleEnd.Position + tentacleEnd.V1:Resized(isStarting and 1 or 30), Vector.Zero, npc):ToNPC()
                tentacle.V1 = targVec
                tentacle.Parent = tentacleEnd
                tentacleEnd.Child = tentacle
                tentacle:Update()
                mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 2.5, 0.2)
            end
        end
    else
        mod:SpritePlay(sprite, "Idle"..data.AnimSuffix)

        local tentacleEnd, tentacleNum, isStarting = GetTentacleEnd(npc)
        if tentacleNum > 0 then
            if tentacleEnd:GetData().State == "Idle" then
                tentacleEnd:GetData().State = "Shrink"
                mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 3, 0.2)
            end
        end
    end
end

function mod:PathoTentacleAI(npc, sprite, data)
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.SplatColor = mod.Colors.BlueGuts
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc.SpriteRotation = npc.V1:GetAngleDegrees()
        npc.SpriteOffset = Vector(0,-2)
        data.State = "Grow"
        sprite:Play("Grow", true)
        data.Init = true
    end

    npc.Velocity = Vector.Zero
    mod:NegateKnockoutDrops(npc)

    if mod:IsReallyDead(npc.Parent) then
        npc:Kill()
    else
        if data.State == "Grow" then
            if sprite:IsFinished("Grow") then
                sprite:Play("Idle", true)
                sprite:SetFrame((npc.SubType * 6) % sprite:GetAnimationData("Idle"):GetLength()) --Don't question the math when it works
                data.State = "Idle"
            else
                mod:SpritePlay(sprite, "Grow")
            end

        elseif data.State == "Shrink" then
            if sprite:IsFinished("Shrink") then
                npc:Remove()
            else
                mod:SpritePlay(sprite, "Shrink")
            end
        end
    end

    for _, ent in pairs(Isaac.FindInCapsule(npc:GetNullCapsule("Hitbox")), EntityPartition.PLAYER | EntityPartition.ENEMY) do
        if ent:ToPlayer() and not mod:isFriend(npc) then
            ent:TakeDamage(npc.CollisionDamage, 0, EntityRef(npc), 0)
        elseif ent.FrameCount % 3 == 0 and ent:ToNPC() and mod:isFriend(npc) ~= mod:isFriend(ent) then
            ent:TakeDamage(3, 0, EntityRef(npc), 0) 
        end
    end

    sprite:GetLayer(1):SetVisible(mod:IsReallyDead(npc.Child))
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    effect:GetSprite():SetFrame("Ground", 0)
    effect:GetSprite().FlipX = mod:RandomBool()
end, mod.ENT.PathoGround.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    effect:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
end, mod.ENT.PathoGround.Var)