local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function SpawnNeckGibs(npc)
    if npc.I1 ~= 1 then
        for i = 20, 400, 20 do
            local effect = Isaac.Spawn(1000, 2, 1, npc.Position, Vector.Zero, npc)
            effect.SpriteOffset = Vector(0, -i)
            effect:Update()
        end
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
        npc.I1 = 1
    end
end

local function CheckIfClaimed(pos, npc)
    return not npc:GetData().FlagpoleClaimed
end

function mod:FlagpoleHeadAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.State = "ReelDown"
        mod:PlaySound(mod.Sounds.StretchEye, npc, 2, 0.8)

        npc.Child = mod:GetNearestThing(npc.Position, mod.FF.FlagpoleBody.ID, mod.FF.FlagpoleBody.Var, -1, CheckIfClaimed)
        if not mod:IsReallyDead(npc.Child) then
            if npc:IsChampion() then
                npc.Child:ToNPC():MakeChampion(69, npc:GetChampionColorIdx(), true)
                npc.Child.HitPoints = npc.Child.MaxHitPoints
            end
            npc.Child:GetData().FlagpoleClaimed = true
            npc.Child.Parent = npc
        end

        data.Init = true
    end

    if data.State == "Idle" then
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(2)), 0.1)

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 250 then
                data.State = "Shoot"
            elseif npc.StateFrame <= -60 then
                data.State = "ReelUp"
                npc.Velocity = Vector.Zero
            end
        end

        mod:spritePlay(sprite, "Idle")

    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.9

        if sprite:IsFinished("Attack") then
            data.AttackCounter = data.AttackCounter + 1
            if data.AttackCounter >= 2 then
                data.State = "ReelUp"
                npc.Velocity = Vector.Zero
            else
                data.State = "Idle"
                npc.StateFrame = mod:RandomInt(40,75,rng)
            end
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc)
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)

            local vec = targetpos - npc.Position
            local params = ProjectileParams()
            params.FallingAccelModifier = 0.8
            for i = 1, mod:RandomInt(5,8,rng) do
                params.FallingSpeedModifier = mod:RandomInt(-8,-5,rng)
                params.Scale = mod:RandomInt(6,12,rng) * 0.1
                npc:FireProjectiles(npc.Position, vec:Resized(mod:RandomInt(4,10,rng)):Rotated(mod:RandomInt(-20,20,rng)), 0, params)			
            end

            npc.Velocity = vec:Resized(-5)

            local effect = Isaac.Spawn(1000, 2, 5, npc.Position, Vector.Zero, npc)
            effect.Color = Color(1,1,1,0.7)
            effect.SpriteOffset = Vector(0,-20)
            effect.DepthOffset = npc.Position.Y * 0.75
            effect:Update()
        else
            mod:spritePlay(sprite, "Attack")
        end

    elseif data.State == "ReelUp" then
        npc.Velocity = npc.Velocity * 0.9

        if sprite:IsFinished("ReelUp") then
            npc.Visible = false
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                for i = 1, 10 do
                    local trypos = targetpos + (RandomVector() * mod:RandomInt(20,80,rng))
                    if room:IsPositionInRoom(trypos, 0) and room:CheckLine(trypos, targetpos, 3, 0, false, false) and trypos:Distance(npc.Position) > 60 then
                        npc.Position = trypos
                        break
                    end
                end
                npc.Visible = true
                data.State = "ReelDown"
                npc:PlaySound(mod.Sounds.StretchEye, 1, 0, false, 2)
            end
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(mod.Sounds.StretchEye, npc, 2, 0.8)
            if not mod:IsReallyDead(npc.Child) then
                npc.Child:GetData().State = "ReelStart"
            end
        elseif sprite:IsEventTriggered("Shoot") then
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc.StateFrame = mod:RandomInt(5,10,rng)
        else
            mod:spritePlay(sprite, "ReelUp")
        end
    
    elseif data.State == "ReelDown" then
        npc.Velocity = npc.Velocity * 0.9

        if sprite:IsFinished("ReelDown") then
            data.State = "Idle"
            data.AttackCounter = 0
            if not data.FirstTime then
                npc.StateFrame = mod:RandomInt(30,60,rng)
                data.FirstTime = true
            elseif not mod:IsReallyDead(npc.Child) then
                npc.Child:GetData().State = "ReelStop"
            end
        elseif sprite:IsEventTriggered("Shoot") then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        else
            mod:spritePlay(sprite, "ReelDown")
        end
    
    elseif data.State == "Drop" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Drop") then
            mod:DestroyNearbyGrid(npc, 30)

            local num = mod:RandomInt(8,12,rng)
            local angle = mod:RandomAngle(rng)
            local params = ProjectileParams()
            params.FallingAccelModifier = 1
            for i = 360/num, 360, 360/num do
                params.FallingSpeedModifier = mod:RandomInt(-12,-5,rng)
                params.Scale = mod:RandomInt(6,12,rng) * 0.1
                npc:FireProjectiles(npc.Position, Vector(mod:RandomInt(6,11,rng),0):Rotated(angle + i + mod:RandomInt(-20,20,rng)), 0, params)			
            end
        
            local creep = Isaac.Spawn(1000, EffectVariant.CREEP_RED, 0, npc.Position, Vector.Zero, npc):ToEffect()
            creep.SpriteScale = Vector(3,3)
            creep:SetTimeout(300)
            creep:Update()
        
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
            npc:Kill()
        else
            mod:spritePlay(sprite, "Drop")
        end
    end

    if npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ALL and mod:IsReallyDead(npc.Child) then
        data.State = "Drop"
        npc.Velocity = Vector.Zero
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        SpawnNeckGibs(npc)
    end
end

function mod:FlagpoleBodyAI(npc, sprite, data)
    if not data.Init then
        data.State = "Idle"
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.Init = true
    end

    mod.QuickSetEntityGridPath(npc)
    npc.Velocity = Vector.Zero

    if data.State == "Idle" then
        mod:spritePlay(sprite, "BodyIdle")

    elseif data.State == "ReelStart" then
        if sprite:IsFinished("BodyReelStart") then
            data.State = "ReelLoop"
        else
            mod:spritePlay(sprite, "BodyReelStart")
        end
    
    elseif data.State == "ReelLoop" then
        mod:spritePlay(sprite, "BodyReelLoop")

    elseif data.State == "ReelStop" then
        if sprite:IsFinished("BodyReelStop") then
            data.State = "Idle"
        else
            mod:spritePlay(sprite, "BodyReelStop")
        end
    
    elseif data.State == "GetUp" then
        if sprite:IsFinished("BodyGetUp") then
            local hp = npc.HitPoints
            npc:Morph(EntityType.ENTITY_GUSHER, 1, 0, -1)
            npc.HitPoints = hp
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            mod:ReplaceEnemySpritesheet(npc, "gfx/enemies/flagpole/flagpole_body", 0)
            data.GuwahFunctions = nil
        else
            mod:spritePlay(sprite, "BodyGetUp")
        end
    end

    if npc.FrameCount > 0 and mod:IsReallyDead(npc.Parent) then
        data.State = "GetUp"
        SpawnNeckGibs(npc)
    end
end

function mod:FlagpoleDeath(npc)
    SpawnNeckGibs(npc)
end