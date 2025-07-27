local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    moveSpeed = 3,
    moveCooldown = {15,30},
    dashSpeed = 5,
    dashSizeScaling = 1,
    targetRange = 120,
    rangeSizeScaling = 40,
    projSpeed = 8,
    dashesBeforeCombine = {1,2},
}

local params = ProjectileParams()
params.Color = mod.Colors.VirusBlue

function mod:PhageAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)
    local size = npc.Variant - mod.ENT.Phage.Var + 1

    if not data.Init then
        if npc.SubType > 1 then
            for i = 1, npc.SubType - 1 do
                Isaac.Spawn(npc.Type, npc.Variant, 0, npc.Position + (RandomVector() * mod:RandomInt(5,15,rng)), Vector.Zero, npc.SpawnerEntity)
            end
            npc.SubType = 0
        end
        npc.StateFrame = mod:RandomInt(bal.moveCooldown, rng)
        npc.SplatColor = mod.Colors.VirusBlue
        data.ColorTint = data.ColorTint or (mod:RandomInt(-12,12,rng) * 0.05)
        data.DashesBeforeCombine = mod:RandomInt(bal.dashesBeforeCombine, rng)
        local color = Color(1,1,1)
        color:SetColorize(1,1,1,data.ColorTint)
        npc.Color = color
        if npc.State == 16 and npc.I1 == 2 then
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            npc.V1 = npc.Velocity
            data.State = "Bullet"
        else
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            data.State = data.State or "Appear"
        end
        data.Init = true
    end

    mod:SetDeform(sprite)

    if data.State == "Appear" then
        npc.Velocity = npc.Velocity * 0.8

        if sprite:IsFinished("Appear") then
            data.State = "Idle"
            mod:SpritePlay(sprite, "Idle")
        else
            mod:SpritePlay(sprite, "Appear")
        end

    elseif data.State == "Idle" then
        local room = game:GetRoom()

        mod:SpritePlay(sprite, "Idle")
        if room:IsPositionInRoom(npc.Position, 0) then
            npc.Velocity = mod:Lerp(npc.Velocity, RandomVector() * bal.moveSpeed, 0.1)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.NumDashes = size
                data.State = "Dash"
            end
        else
            npc.Velocity = mod:Lerp(npc.Velocity, (room:GetCenterPos() - npc.Position):Resized(bal.moveSpeed), 0.1)
        end

    elseif data.State == "Dash" then
        mod:SpritePlay(sprite, "Idle")

        if sprite:IsOverlayFinished("Dash") then
            data.NumDashes = data.NumDashes - 1
            data.DashesBeforeCombine = data.DashesBeforeCombine - 1
            if data.NumDashes <= 0 then
                sprite:RemoveOverlay()
                npc.StateFrame = mod:RandomInt(bal.moveCooldown, rng)
                data.State = "Idle"
            else
                sprite:PlayOverlay("Dash", true)
            end
        else
            mod:SpriteOverlayPlay(sprite, "Dash")
        end

        if sprite:IsOverlayEventTriggered("Shoot") then
            local other = mod:GetNearestThing(npc.Position, npc.Type, npc.Variant, -1, nil, npc)
            local speed = bal.dashSpeed + ((size - 1) * bal.dashSizeScaling)
            local range = bal.targetRange + ((size - 1) * bal.rangeSizeScaling)
            if data.DashesBeforeCombine <= 0 and size < 3 and other and other.Position:Distance(npc.Position) <= range then
                npc.Velocity = (other.Position - npc.Position):Resized(speed)
            elseif (targetpos:Distance(npc.Position) <= range and rng:RandomFloat() <= 0.33 * size) or game:GetRoom():GetGridCollisionAtPos(npc.Position) >= GridCollisionClass.COLLISION_SOLID then
                npc.Velocity = (targetpos - npc.Position):Resized(speed)
            else
                npc.Velocity = RandomVector() * speed
            end
        else
            npc.Velocity = npc.Velocity * 0.95
        end

    elseif data.State == "Bullet" then
        mod:SpritePlay(sprite, "Bullet")
        npc.Velocity = npc.V1

        if npc.FrameCount % 10 == 5 then
            npc:SetColor(Color(1,1,1,1,0.3,0,0.1), 7, 100, true, false)
        end

        if npc:CollidesWithGrid() then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            mod:PlaySound(SoundEffect.SOUND_SPLATTER, npc, 1, 0.75)
            data.State = "Idle"
        end
    end

    if npc:IsDead() then
        if size > 1 then
            npc:FireProjectiles(npc.Position, Vector(bal.projSpeed, (size - 1) * 3), ProjectileMode.CIRCLE_CUSTOM, params)
            --[[for i = 1, 2 do
                local vec = RandomVector() * bal.dashSpeed
                local new = Isaac.Spawn(npc.Type, npc.Variant - 1, 0, npc.Position + vec, vec, npc)
                new.HitPoints = npc.MaxHitPoints / 2
                new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                new:GetData().ColorTint = data.ColorTint
                new:GetData().State = "Idle"
            end]]
        end
    end
end

function mod:PhageColl(npc, sprite, data, collider)
    if data.Init 
    and collider:GetData().Init
    and collider.Type == npc.Type 
    and collider.Variant == npc.Variant
    and data.DashesBeforeCombine <= 0
    and data.State == "Dash" then
        local combined = Isaac.Spawn(npc.Type, npc.Variant + 1, 0, (npc.Position + collider.Position)/2, Vector.Zero, npc.SpawnerEntity)
        combined:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        --[[combined.MaxHitPoints = npc.HitPoints + collider.HitPoints
        combined.HitPoints = combined.MaxHitPoints]]
        combined:GetData().ColorTint = (data.ColorTint + collider:GetData().ColorTint)/2
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, combined.Position, Vector.Zero, combined)
        poof.Color = Color(0.25,0.5,1)
        mod:PlaySound(SoundEffect.SOUND_SUMMON_POOF, combined)
        mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, combined, 1, 0.5)
        npc:Remove()
        collider:Remove()
    end
end

function mod:PhageDevolve(npc)
    local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, npc.Position, npc.Velocity, npc)
    gib.Color = mod.Colors.VirusBlue
    gib.SplatColor = mod.Colors.VirusBlue
    return mod:D10Cleanup(npc)
end

function mod:ShootPhage(pos, vel, spawner)
    local phage = Isaac.Spawn(mod.ENT.Phage.ID, mod.ENT.Phage.Var, 0, pos, vel, spawner):ToNPC()
    phage.State = 16
    phage.I1 = 2
    phage:Update()
    return phage
end

function mod:CountPhages()
    return (mod:GetEntityCount(mod.ENT.Phage.ID, mod.ENT.Phage.Var) + (mod:GetEntityCount(mod.ENT.Pheege.ID, mod.ENT.Pheege.Var) * 2) + (mod:GetEntityCount(mod.ENT.Phooge.ID, mod.ENT.Phooge.Var) * 4))
end