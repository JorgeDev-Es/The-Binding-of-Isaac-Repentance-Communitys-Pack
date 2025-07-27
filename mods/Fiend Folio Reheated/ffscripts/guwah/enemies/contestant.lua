local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local function MinimizeVector(vec, len)
    return vec:Resized(math.min(vec:Length(), len))
end

local function AnimWalkFrame(npc, sprite, horianim, vertanim)
    if npc.Velocity:Length() < 0.1 then
        sprite:SetFrame(vertanim, 0)
    else
        local anim
        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            anim = horianim
        else
            anim = vertanim
        end
        if npc.Velocity.X > 0 then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
        if not sprite:IsPlaying() then
            sprite:Play(anim)
        else
            sprite:SetAnimation(anim, false)
        end
    end
end

function mod:WanderAbout(npc, data, speed, idletime, avoidPlayer)
    idletime = idletime or 1

    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if data.WalkPos then
        local vel 
        if mod:isScare(npc) or (avoidPlayer and targetpos:Distance(npc.Position) <= avoidPlayer and room:CheckLine(npc.Position,targetpos,0,1,false,false)) then
            vel = MinimizeVector(npc.Position - targetpos, speed)
            data.WalkPos = nil
        elseif room:CheckLine(npc.Position,data.WalkPos,0,1,false,false) then
            vel = MinimizeVector(data.WalkPos - npc.Position, speed)
        elseif npc.Pathfinder:HasPathToPos(data.WalkPos, false) then
            npc.Pathfinder:FindGridPath(data.WalkPos, (speed * 0.1) + 0.2, 900, true)
        else
            data.WalkPos = nil
        end

        if vel then
            npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.3)
        end

        if data.WalkPos and npc.Position:Distance(data.WalkPos) <= 20 then
            if rng:RandomFloat() <= idletime then
                data.WalkPos = nil
            end
        else
            return true
        end
    else
        data.WalkPos = mod:FindRandomValidPathPosition(npc)
        return true
    end
end

function mod:ChasePlayer(npc, speed, targetpos)
    local room = game:GetRoom()
    local targetpos = targetpos or mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(speed)), 0.25)
    else
        npc.Pathfinder:FindGridPath(targetpos, (speed * 0.1) + 0.2, 900, true)
    end

    mod.QuickSetEntityGridPath(npc)
end

local function InterceptScrew(npc, data)
    if data.ScrewToCatch and not mod:IsReallyDead(data.ScrewToCatch)then
        local vel = mod:intercept(npc, data.ScrewToCatch, 6):Resized(6)
        npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.3)
        return true
    else
        npc.Velocity = npc.Velocity * 0.7
    end
end

local function MakeCluster(npc, vec)
    if vec then
        local rng = npc:GetDropRNG()
        local params = ProjectileParams()
        params.FallingAccelModifier = 0.6
        for i = 1, mod:RandomInt(5,8,rng) do
            params.FallingSpeedModifier = mod:RandomInt(-8,-5,rng)
            params.Scale = mod:RandomInt(16,30,rng) * 0.05
            npc:FireProjectiles(npc.Position, vec:Resized(mod:RandomInt(5,12,rng)):Rotated(mod:RandomInt(-20,20,rng)), 0, params)			
        end
    end

    Isaac.Spawn(1000, 2, 0, npc.Position, Vector.Zero, npc)
    npc:BloodExplode()
    sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
end

local function CountScrews()
    return (mod.GetEntityCount(mod.FF.Contestant.ID,mod.FF.Contestant.Var,1) + mod.GetEntityCount(mod.FF.ScrewProjectile.ID,mod.FF.ScrewProjectile.Var))
end

function mod:ContestantAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if npc.SubType == 0 then --No screw
        AnimWalkFrame(npc,sprite,"WalkHori02","WalkVert02")
        if data.ScrewTargeted then
            if not InterceptScrew(npc, data) then
                data.ScrewTargeted = data.ScrewTargeted - 1
                if data.ScrewTargeted <= 0 then
                    data.ScrewTargeted = nil
                end
            end
        elseif CountScrews() > 0 then
            mod:WanderAbout(npc, data, 3, 0.1, 60)
        else
            mod:ChasePlayer(npc, 3)
        end
    
    elseif npc.SubType == 1 then --Screwed
        if npc.FrameCount <= 1 then
            data.State = "Idle"
            npc.StateFrame = mod:RandomInt(45,90,rng)
        end

        if data.State == "Impact" then
            npc.Velocity = npc.Velocity * 0.7

            if sprite:IsFinished("ScrewImpact") then
                data.State = "Idle"
                npc.StateFrame = mod:RandomInt(45,90,rng)
            else
                mod:spritePlay(sprite, "ScrewImpact")
            end

        elseif data.State == "Idle" then
            AnimWalkFrame(npc,sprite,"WalkHori01","WalkVert01")

            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                local targetboy
                local isTargets 
                local currentangle = 9999 
                local dist = 100
                for _, contestant in pairs(Isaac.FindByType(mod.FF.Contestant.ID,mod.FF.Contestant.Var,-1)) do
                    if contestant.SubType ~= 1 then
                        isTargets = true
                        if not contestant:GetData().ScrewTargeted then
                            local anglediff = mod:GetAngleDifferenceDead(targetpos - npc.Position, contestant.Position - npc.Position)
                            if anglediff < currentangle then
                                currentangle = anglediff
                                targetboy = contestant
                            elseif contestant.Position:Distance(targetpos) < dist then
                                dist = contestant.Position:Distance(targetpos)
                                targetboy = contestant
                            end
                        end
                    elseif contestant:GetData().State == "Shoot" then --If its shooting then it could be a valid target in the future
                        isTargets = true
                    end
                end
                
                if targetboy and currentangle <= 30 then
                    targetboy:GetData().ScrewTargeted = 60
                    data.TargetBoy = targetboy
                    data.State = "Shoot"
                    mod:FlipSprite(sprite, targetboy.Position, npc.Position)
                elseif isTargets then
                    npc.StateFrame = 5
                else
                    data.State = "Shoot"
                    mod:FlipSprite(sprite, targetpos, npc.Position)
                end
            else
                mod:WanderAbout(npc, data, 5.5, 0.2, 30)
            end
        elseif data.State == "Shoot" then
            data.ShootAnim = data.ShootAnim or "ShootDown"
            npc.Velocity = npc.Velocity * 0.7

            if sprite:IsFinished(data.ShootAnim) then
                npc.SubType = 2
            elseif sprite:IsEventTriggered("Target") then
                local target = targetpos
                if data.TargetBoy and not mod:IsReallyDead(data.TargetBoy) then
                    target = data.TargetBoy.Position
                end

                if target.Y < npc.Position.Y then
                    data.ShootAnim = "ShootUp"
                else
                    data.ShootAnim = "ShootDown"
                end
            
                sprite:SetAnimation(data.ShootAnim, false)
                data.ShootAngle = mod:GetAngleDegreesButGood(target - npc.Position)
            elseif sprite:IsEventTriggered("Shoot") then
                local vec = Vector(14,0):Rotated(data.ShootAngle)
                local screw = Isaac.Spawn(mod.FF.ScrewProjectile.ID, mod.FF.ScrewProjectile.Var, 0, npc.Position + vec, vec, npc)
                screw:Update()
                MakeCluster(npc)
                mod:FlipSprite(sprite, npc.Position + vec, npc.Position)
                npc.Velocity = vec * -1
                if data.TargetBoy and not mod:IsReallyDead(data.TargetBoy) then
                   data.TargetBoy:GetData().ScrewToCatch = screw
                end
            else
                mod:spritePlay(sprite, data.ShootAnim)
            end
        end
    elseif npc.SubType == 2 then --After the incident
        AnimWalkFrame(npc,sprite,"WalkHori03","WalkVert03")

        if data.ScrewTargeted then
            if not InterceptScrew(npc, data) then
                data.ScrewTargeted = data.ScrewTargeted - 1
                if data.ScrewTargeted <= 0 then
                    data.ScrewTargeted = nil
                end
            end
        else
            mod:ChasePlayer(npc, 4)
        end
    end
end

function mod:ScrewProjectile(npc, sprite, data)
    if not data.Init then
        npc:SetSize(10, Vector(3,1), 12)
        npc.SpriteOffset = Vector(0,-15)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        data.Init = true
    end

    mod:spritePlay(sprite, "Move")
    sprite.Rotation = npc.Velocity:GetAngleDegrees()
    npc.Velocity = npc.Velocity:Resized(12)

    if npc:CollidesWithGrid() then
        npc:Kill()
    end
end

function mod:ScrewProjectileCollision(npc, collider)
    if collider:ToNPC() then
        if collider.Type == mod.FF.Contestant.ID and collider.Variant == mod.FF.Contestant.Var and collider.SubType ~= 1 then
            collider.SubType = 1
            collider:GetData().State = "Impact"
            collider:GetData().ScrewTargeted = nil
            collider.Velocity = npc.Velocity
            MakeCluster(collider:ToNPC(), npc.Velocity)
            mod:FlipSprite(collider:GetSprite(), collider.Position, npc.Position)
            npc:Remove()
        else
            return true
        end
    end
end

function mod:ScrewProjectileDeath(npc)
    sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
    sfx:Play(SoundEffect.SOUND_POT_BREAK, 1, 0, false, 2)
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, npc.Position + npc.Velocity + Vector(0,-15), Vector.Zero, npc)
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, 27, 0, npc.Position, RandomVector()*3, npc)
        gib:GetSprite():ReplaceSpritesheet(0, "gfx/grid/super_tnt.png")
        gib:GetSprite():LoadGraphics()
        gib:Update()
	end
end