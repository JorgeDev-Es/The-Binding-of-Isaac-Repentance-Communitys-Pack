local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

local function ClearSuckData(data)
    for _, proj in pairs(data.Projectiles) do
        if proj:Exists() then
            proj:Die()
        end
    end
    data.Projectiles = {}
    data.SuckDistance = nil
    data.Sucking = false
    data.State = "SuckEnd"
end

function mod:VacuoleAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.Init then
        local params = ProjectileParams()
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        params.Scale = 1.5
        params.Color = mod.ColorDecentlyRed
        data.Params = params
    
        npc.StateFrame = mod:RandomInt(30,90,rng)
        data.State = "Wander"
        data.Projectiles = {}
        data.Init = true
    end

    if data.State == "Wander" then
        if data.WalkPos then
            local vel 
            if mod:isScare(npc) or (targetpos:Distance(npc.Position) <= 120 and room:CheckLine(npc.Position,targetpos,0,1,false,false)) then
                vel = (npc.Position - targetpos):Resized(4)
                data.WalkPos = nil
            elseif room:CheckLine(npc.Position,data.WalkPos,0,1,false,false) then
                vel = (data.WalkPos - npc.Position):Resized(3)
            else
                npc.Pathfinder:FindGridPath(data.WalkPos, 0.3, 900, true)
            end

            if vel then
                npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.1)
            end

            if data.WalkPos and npc.Position:Distance(data.WalkPos) <= 20 then
                data.WalkPos = nil
            end
        else
            data.WalkPos = mod:FindRandomValidPathPosition(npc)
        end

        if sprite:IsFinished("Appear") then
            data.CanWalk = true
            sprite:Play("Idle")
        elseif sprite:IsEventTriggered("Step") then
            mod:PlaySound(mod.Sounds.BertranStep, npc, 0.8 + (mod:RandomInt(0,1,rng) * 0.3), 0.15)
        end

        if data.CanWalk then
            if npc.Velocity:Length() <= 0.1 then
                mod:spritePlay(sprite, "Idle")
            else
                if math.abs(npc.Velocity.X) < math.abs(npc.Velocity.Y) then
                    sprite:SetAnimation("WalkVertFull", false)
                else
                    if npc.Velocity.X < 0 then
                        sprite:SetAnimation("WalkLeftFull", false)
                    else
                        sprite:SetAnimation("WalkRightFull", false)
                    end
                end
            end
        end

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "SuckStart"
        end
    elseif data.State == "SuckStart" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("SuckStart") then
            npc.StateFrame = 150
            data.State = "SuckLoop"
        elseif sprite:IsEventTriggered("Warn") then
            if rng:RandomFloat() <= 0.5 then
                data.SuckAngle = 45
            else
                data.SuckAngle = 0
            end
            data.SuckSpeed = 5
            data.SuckDistance = 0
            for i = data.SuckAngle, 360 + data.SuckAngle, 90 do
                local pos = mod.XalumFindWall(npc.Position, Vector(20,0):Rotated(i)).Position
                local dist = pos:Distance(npc.Position)
                if dist > data.SuckDistance then
                    data.SuckDistance = dist
                end
                local tracer = Isaac.Spawn(1000, 181, 0, pos, Vector.Zero, npc):ToEffect()
                tracer.SpriteRotation = i + 270
                tracer.SpriteScale = Vector(0.2,0.2)
                tracer.Color = mod.ColorBetterRedThanDead
                tracer:GetSprite().PlaybackSpeed = 0.75
                tracer:Update()
            end
            mod:PlaySound(SoundEffect.SOUND_WORM_SPIT, npc, 0.75)
        elseif sprite:IsEventTriggered("Suck") then
            data.Sucking = true
        else
            mod:spritePlay(sprite, "SuckStart")
        end
    elseif data.State == "SuckLoop" then
        npc.Velocity = npc.Velocity * 0.5
        mod:spritePlay(sprite, "SuckLoop")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            ClearSuckData(data)
        end
    elseif data.State == "SuckEnd" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("SuckEnd") then
            data.WalkPos = nil
            npc.StateFrame = mod:RandomInt(30,90,rng)
            sprite:Play("Idle")
            data.State = "Wander"
        elseif sprite:IsEventTriggered("SuckEnd") then
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
        else
            mod:spritePlay(sprite, "SuckEnd")
        end
    end

    if data.SuckDistance then
        for i = data.SuckAngle, 360 + data.SuckAngle, 90 do
            local pos = npc.Position + Vector(data.SuckDistance, 0):Rotated(i)

            if data.Projectiles[i] and data.Projectiles[i]:Exists() then
                local proj = data.Projectiles[i]:ToProjectile()
                proj.FallingSpeed = 0
                proj.FallingAccel = -0.1
                proj.Velocity = pos - proj.Position
            else
                if room:IsPositionInRoom(pos,0) then
                    mod:SetGatheredProjectiles()
                    npc:FireProjectiles(pos, Vector.Zero, 0, data.Params)
                    for _, proj in pairs(mod:GetGatheredProjectiles()) do
                        data.Projectiles[i] = proj
                    end
                    Isaac.Spawn(1000,2,2,pos,Vector.Zero,npc)
                else
                    if npc.FrameCount % 8 == 0 then
                        local bloodpos = mod.XalumFindWall(npc.Position, Vector(20,0):Rotated(i)).Position
                        Isaac.Spawn(1000,5,0,bloodpos,(npc.Position-bloodpos):Resized(3):Rotated(mod:RandomInt(-10,10,rng)),npc)
                    end
                end
            end
        end

        if data.Sucking then
            data.SuckDistance = data.SuckDistance - data.SuckSpeed
            if data.SuckSpeed < 10 then
                data.SuckSpeed = data.SuckSpeed + 0.15
            end
            if data.SuckDistance <= 0 then
                ClearSuckData(data)
            end
        end
    end
end

function mod:VacuoleRemove(npc, data)
    for _, proj in pairs(data.Projectiles) do
        if proj:Exists() then
            proj.FallingAccel = 1
            proj.Velocity = proj.Velocity * 0.5
        end
    end
end