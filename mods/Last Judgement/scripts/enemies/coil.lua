local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    laserDelay = 15,
}

mod.CoilBlacklist = {
    [mod.ENT.Coil.ID.." "..mod.ENT.Coil.Var] = true,
}

local function IsValidCoilTarget(enemy)
    return ((enemy:IsEnemy() or enemy:ToProjectile() or enemy:ToEffect()) 
    and enemy.Visible 
    and not (mod:IsReallyDead(enemy)
    or mod:isFriend(enemy)
    or mod.CoilBlacklist[enemy.Type.." "..enemy.Variant]))
end

local function GetCoilTargets(npc)
    local enemies = {}
    for _, enemy in pairs(Isaac.FindInRadius(npc.Position, 2000, EntityPartition.ENEMY)) do
        if IsValidCoilTarget(enemy) then
            table.insert(enemies, enemy)
        end
    end
    for _, brain in pairs(Isaac.FindByType(mod.ENT.BrainProjectile.ID, mod.ENT.BrainProjectile.Var)) do
        table.insert(enemies, brain)
    end
    for _, wound in pairs(Isaac.FindByType(mod.ENT.GashWound.ID, mod.ENT.GashWound.Var)) do
        table.insert(enemies, wound)
    end
    return enemies
end

local function RegisterCoilTarget(npc, enemy)
    local data = npc:GetData()
    local tracer = mod:MakeCustomTracer(npc.Position, enemy.Position, npc, {
        Width = 0.5,
        Color = data.LaserColor,
        Duration = bal.laserDelay,
        FadeDuration = 3,
        LineCheckMode = LineCheckMode.PROJECTILE,
    })
    data.LaserTargets[enemy.InitSeed] = {
        Enemy = enemy,
        Tracer = tracer,
        Laser = nil,
        Delay = bal.laserDelay,
    }
    return data.LaserTargets[enemy.InitSeed]
end

function mod:CoilAI(npc, sprite, data)
    local room = game:GetRoom()
    local isMortis = mod.STAGE.Mortis:IsStage()

    if not data.Init then
        if mod.STAGE.Mortis:IsStage() then
            npc.SplatColor = mod.Colors.MortisBlood
            data.LaserColor = mod.Colors.ElectricBlue
        else
            npc.SplatColor = mod.Colors.CorpseBlood
            data.LaserColor = mod.Colors.ElectricGreen
        end
        npc:AddEntityFlags(EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        data.LaserTargets = {}
        data.State = "Appear"
        data.Init = true
    end

    npc.Velocity = Vector.Zero
    mod:NegateKnockoutDrops(npc)
    mod:QuickSetEntityGridPath(npc)

    local numLasers = 0
    if npc.FrameCount > 0 then
        for _, enemy in pairs(GetCoilTargets(npc)) do
            if not data.LaserTargets[enemy.InitSeed] then
                RegisterCoilTarget(npc, enemy)
            end
        end

        for index, dat in pairs(data.LaserTargets) do
            if IsValidCoilTarget(dat.Enemy) then
                dat.Delay = dat.Delay - 1
                if dat.Delay > 0 then
                    dat.Tracer.TargetPosition = dat.Enemy.Position
                elseif dat.Delay <= 0 then
                    if dat.Laser and dat.Laser:Exists() then
                        dat.Laser.Angle = (dat.Enemy.Position - npc.Position):GetAngleDegrees()
                        local endPoint = mod:GetLaserEndPoint(npc.Position, dat.Laser.Angle, dat.Enemy.Position)
                        dat.Laser:SetMaxDistance((npc.Position - endPoint):Length())
                    else
                        local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THIN_RED, 0, npc.Position, Vector.Zero, npc):ToLaser()
                        laser.Parent = npc
                        laser.PositionOffset = Vector(0,-10)
                        laser.Angle = (dat.Enemy.Position - npc.Position):GetAngleDegrees()
                        laser.Color = data.LaserColor
                        local endPoint = mod:GetLaserEndPoint(npc.Position, laser.Angle, dat.Enemy.Position)
                        laser:SetMaxDistance((npc.Position - endPoint):Length())
                        laser.DepthOffset = -120
                        if not mod:isFriend(npc) then
                            laser.CollisionDamage = 0
                        end
                        laser.Mass = 0
                        laser:Update()
                        dat.Laser = laser
                    end
                end
                numLasers = numLasers + 1
            else
                if dat.Tracer and dat.Tracer:Exists() then
                    dat.Tracer.Timeout = math.min(dat.Tracer.Timeout, 0)
                end
                if dat.Laser and dat.Laser:Exists() then
                    dat.Laser.Timeout = 1
                end
                data.LaserTargets[index] = nil
            end
        end
    end

    if data.State == "Appear" then
        if sprite:IsFinished("Appear") then
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "Appear")
        end

    elseif data.State == "Idle" then
        mod:SpritePlay(sprite, numLasers > 0 and "IdleAlt" or "IdleAlt2")
    end
end

function mod:MakeCustomTracer(startPos, endPos, parent, params)
    params = params or {}
    local tracer = Isaac.Spawn(mod.ENT.CustomTracer.ID, mod.ENT.CustomTracer.Var, 0, startPos, Vector.Zero, parent):ToEffect()
    local data, sprite = tracer:GetData(), tracer:GetSprite()
    tracer.Parent = parent
    tracer.TargetPosition = endPos
    tracer.Timeout = params.Duration or 10
    tracer.Color = params.Color or Color.Default
    tracer.DepthOffset = params.DepthOffset or 0
    for i = 0, 2 do
        local layer = sprite:GetLayer(i)
        layer:SetColor(Color(1,1,1,params.Alpha or 0.5))
        layer:SetSize(Vector(1, params.Width or 1))
    end
    data.TracerLineCheck = params.LineCheckMode
    data.TracerIsDebug = params.IsDebug
    data.TracerFadeDuration = params.FadeDuration or 5
    mod:FadeIn(tracer, data.TracerFadeDuration)
    if parent and params.FollowParent then
        tracer:FollowParent(parent)
    end
    tracer:Update()
    return tracer
end

function mod:MakeCustomTracerDebug(startPos, endPos, parent, params) --For testing with console
    params = params or {}
    params.IsDebug = true
    if type(startPos) == "number" then
        startPos = game:GetRoom():GetGridPosition(startPos)
    end
    if type(endPos) == "number" then
        endPos = game:GetRoom():GetGridPosition(endPos)
    end
    return mod:MakeCustomTracer(startPos, endPos, parent, params)
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local data, sprite = effect:GetData(), effect:GetSprite()
    if not data.TracerIsDebug then
        if mod:IsReallyDead(effect.Parent) and effect.Timeout > 0 then
            effect.Timeout = 0
        end
        if effect.Timeout == 0 then
            mod:FadeOut(effect, data.TracerFadeDuration or 5)
            mod:ScheduleForUpdate(function() effect:Remove() end, data.TracerFadeDuration or 5)
        end
    end
end, mod.ENT.CustomTracer.Var)

local spanOffset = Vector(24.5,0)
mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, function(_, effect)
    local data, sprite = effect:GetData(), effect:GetSprite()
    local span = effect.TargetPosition - effect.Position
    sprite.Rotation = span:GetAngleDegrees()
    if data.TracerLineCheck then
        local _, endPoint = game:GetRoom():CheckLine(effect.Position, effect.Position + span, data.TracerLineCheck)
        effect.TargetPosition = endPoint
        span = effect.TargetPosition - effect.Position
    end
    local length = (Isaac.WorldToScreenDistance(span):Length()/16) - 1
    local layer = sprite:GetLayer(0)
    layer:SetSize(Vector(length, layer:GetSize().Y))
    sprite:RenderLayer(0, Isaac.WorldToScreen(effect.Position + spanOffset:Rotated(sprite.Rotation)))
    sprite:RenderLayer(1, Isaac.WorldToScreen(effect.Position))
    sprite:RenderLayer(2, Isaac.WorldToScreen(effect.TargetPosition))
    return false
end, mod.ENT.CustomTracer.Var)