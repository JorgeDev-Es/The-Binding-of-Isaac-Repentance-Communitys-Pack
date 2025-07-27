local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:cubertAI(npc)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local data = npc:GetData()
    local targetpos = mod:confusePos(npc, target.Position)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.init then
        npc.SplatColor = Color(0, 0.2, 0.8, 1, 0, 0.078, 0.275)
        data.state = "Idle"
        data.dir = "Left"
        data.moveFrame = 0
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
        data.moveFrame = data.moveFrame+1
    end

    if data.state == "Idle" then
        if npc.Velocity.X > 0 then
            data.dir = "Right"
        else
            data.dir = "Left"
        end

        if npc.StateFrame > 70 and rng:RandomInt(20) == 0 then
            data.state = "SlideHop"
            data.slideDir = nil
        elseif npc.StateFrame > 125 then
            data.state = "SlideHop"
            data.slideDir = nil
        else
            if data.moveFrame > 20 and rng:RandomInt(10) == 0 then
                data.state = "Hop"
                data.hopTarget = nil
            elseif data.moveFrame > 40 then
                data.state = "Hop"
                data.hopTarget = nil
            end
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)

        mod:spritePlay(sprite, "Idle" .. data.dir)
    elseif data.state == "Slide" then
        if npc:CollidesWithGrid() then
            data.state = "Slam"
            data.landed = nil
            data.superSlide = nil
            npc:PlaySound(SoundEffect.SOUND_FREEZE_SHATTER, 1, 0, false, 1)

            mod:SetGatheredProjectiles()
            local params = ProjectileParams()
            params.FallingAccelModifier = -0.1
            params.BulletFlags = params.BulletFlags | ProjectileFlags.ACCELERATE | ProjectileFlags.NO_WALL_COLLIDE
            params.Variant = 8
            params.Scale = 0.5
            local vel = 2
            for i=90,360,90 do
                for j=-vel,vel-1, vel/2 do
                    local size = math.sqrt(j^2+vel^2)
                    npc:FireProjectiles(npc.Position, Vector(j,vel):Rotated(i):Resized(size), 0, params)
                end
            end
            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                local s = proj:GetSprite()
                if REVEL then
                    s:Load("gfx/effects/revel1/projectile_icicle.anm2", true)
                    s:Play("Idle", true)
                else
                    s:Load("gfx/002.041_ice tear.anm2", true)
                    s:Play("RegularTear6", true)
                end
                proj:GetData().customProjectileBehavior = {customFunc = function()
                    if proj.Acceleration < 1.1 then
                        proj.Acceleration = proj.Acceleration+0.005
                    end
                    if proj.FrameCount > 30 then
                        proj:ClearProjectileFlags(ProjectileFlags.ACCELERATE)
                    end
                    s.Rotation = proj.Velocity:GetAngleDegrees()

                    if room:GetGridCollisionAtPos(proj.Position) > 1 then
                        proj:Remove()
                    end
                end, death = function()
                    sfx:Play(SoundEffect.SOUND_FREEZE_SHATTER, 0.25, 0, false, math.random(130,160)/100)
                    for i=1,2 do
                        if REVEL then
                            REVEL.SpawnIceRockGib(proj.Position, RandomVector():Resized(math.random(1, 5)), proj)
                        else
                            local tooth = Isaac.Spawn(1000, 35, 0, proj.Position, RandomVector()*2, proj):ToEffect()
                            tooth.Color = Color(1, 1, 1, 1, 0.4, 0.4, 0.6)
                        end
                    end
                end}
                proj:GetData().projType = "customProjectileBehavior"
            end
        end

        if npc.StateFrame > 100 then
            data.state = "Idle"
            npc.StateFrame = 0
            data.moveFrame = 0
            data.landed = nil
            data.superSlide = nil
        end

        mod:spritePlay(sprite, "Slidle" .. data.dir)
    elseif data.state == "Slam" then
        if sprite:IsFinished("Slam" .. data.dir) then
            data.state = "Idle"
            data.moveFrame = 0
            npc.StateFrame = 0
        else
            mod:spritePlay(sprite, "Slam" .. data.dir)
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "Hop" then
        if not data.hopTarget then
            data.hopTarget = mod:FindRandomFreePos(npc, 80, true, nil, nil, 20)
            --Isaac.Spawn(9, 0, 0, data.hopTarget, Vector.Zero, nil)
            local goDir = (data.hopTarget-npc.Position)
            if goDir.X > 0 then
                data.dir = "Right"
            else
                data.dir = "Left"
            end
            data.jumped = nil
            data.slideVel = goDir*0.1
        end

        if sprite:IsFinished("Hop" .. data.dir) then
            data.state = "Idle"
            data.moveFrame = 0
            data.jumped = nil
        elseif sprite:IsEventTriggered("Jump") then
            data.jumping = true
            data.jumped = true
            npc:PlaySound(SoundEffect.SOUND_SHELLGAME,0.3,2,false,1.3)
        elseif sprite:IsEventTriggered("Land") then
            data.jumping = false
            npc:PlaySound(SoundEffect.SOUND_BONE_BOUNCE, 1, 0, false, math.random(110,150)/100)
        else
            mod:spritePlay(sprite, "Hop" .. data.dir)
        end

        if data.jumping then
            local targVel = (data.hopTarget-npc.Position)*0.25
            npc.Velocity = mod:Lerp(npc.Velocity, targVel, 0.3)
        elseif data.jumped then
            if npc.FrameCount % 5 == 0 and npc.Velocity:Length() > 1.3 then
                local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position, -npc.Velocity:Resized(1)+RandomVector()*math.random(1,2)/2, npc)
                smoke.Color = Color(1,1,1,0.2,0,0,0.3)
                smoke:GetData().longonly = true
                smoke:Update()
            end

            npc.Velocity = mod:Lerp(npc.Velocity, data.slideVel, 0.15)
            data.slideVel = data.slideVel*0.85
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
        end
    elseif data.state == "SlideHop" then
        if not data.slideDir then
            local slide = (targetpos - npc.Position)
            if math.abs(slide.X) > math.abs(slide.Y) then
                if slide.X > 0 then
                    data.dir = "Right"
                    data.slideDir = Vector(12, 0)
                else
                    data.dir = "Left"
                    data.slideDir = Vector(-12, 0)
                end
            else
                if slide.Y > 0 then
                    data.slideDir = Vector(0, 12)
                else
                    data.slideDir = Vector(0, -12)
                end
            end
            data.landed = nil
            data.superSlide = nil
        end

        if sprite:IsFinished("HopSlide" .. data.dir) then
            data.state = "Slide"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Jump") then
            npc:PlaySound(SoundEffect.SOUND_SHELLGAME,0.3,2,false,1.3)
            data.superSlide = true
        elseif sprite:IsEventTriggered("Land") then
            data.landed = true
            npc:PlaySound(SoundEffect.SOUND_BONE_BOUNCE, 1, 0, false, math.random(110,150)/100)
        else
            mod:spritePlay(sprite, "HopSlide" .. data.dir)
        end
    end

    if data.superSlide then
        if data.slideDir then
            if data.landed then
                if npc.FrameCount % 5 == 0 and npc.Velocity:Length() > 1.3 then
                    local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position, -npc.Velocity:Resized(1)+RandomVector()*math.random(1,2)/2, npc)
                    smoke.Color = Color(1,1,1,0.2,0,0,0.3)
                    smoke:GetData().longonly = true
                    smoke:Update()
                end
                if npc.FrameCount % 2 == 0 then
                    if REVEL then
                        local creep = REVEL.SpawnIceCreep(npc.Position, npc)
                    else
                        local creep = Isaac.Spawn(1000, 94, 160, npc.Position, Vector.Zero, npc)
                        creep:Update()
                        creep.Color = Color(0, 0, 0, 1, 0.53, 0.65, 0.79)
                    end
                end
            end
            npc.Velocity = mod:Lerp(npc.Velocity, data.slideDir, 0.3)
        else
            data.superSlide = nil
        end
    end

    if npc:IsDead() then
        sfx:Play(SoundEffect.SOUND_FREEZE_SHATTER, 1, 0, false, math.random(90,110)/100)
        for i=1,6 do
            if REVEL then
                REVEL.SpawnIceRockGib(npc.Position, RandomVector():Resized(math.random(1, 5)), npc)
            else
                local tooth = Isaac.Spawn(1000, 35, 0, npc.Position, RandomVector()*2, npc):ToEffect()
                tooth.Color = Color(1, 1, 1, 1, 0.4, 0.4, 0.6)
            end
        end
    end
end