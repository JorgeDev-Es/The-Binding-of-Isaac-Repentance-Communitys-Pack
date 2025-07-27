local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

function mod:buoyUpdate(npc)
    local sprite, d = npc:GetSprite(), npc:GetData()
    local target = npc:GetPlayerTarget()
    local r = npc:GetDropRNG()
    if not d.init then
        if npc.SubType == 1 then
            d.state = "idle"
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc.StateFrame = -25
            local effect = Isaac.Spawn(1000, 15, 0, npc.Position, nilvector, npc)
            effect.SpriteScale = effect.SpriteScale * 0.5
        else
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            d.state = "floating"
        end
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.state == "floating" then
        mod:spritePlay(sprite, "Idle")
        if target.Position:Distance(npc.Position) < 80 then
            d.state = "awaken"
        end
    elseif d.state == "awaken" then
        if sprite:IsFinished("Exit") then
            d.state = "idle"
        elseif sprite:IsEventTriggered("Move") then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc:PlaySound(mod.Sounds.SplashLargePlonkless, 0.5, 0, false, math.random(150,160)/100)
            npc.Velocity = RandomVector() * math.random()
            if npc.Velocity.X < 0 then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end

            local numproj = math.random(3,5)
            for i = 360/numproj, 360, 360/numproj do
                local params = ProjectileParams()
                params.Scale = 0.2 + (math.random() * 0.2)
                params.FallingSpeedModifier = math.random(-15,-8)
                params.FallingAccelModifier = 1.5
                params.Variant = 4
                npc:FireProjectiles(npc.Position, Vector(2 + (math.random() * 1.5),0):Rotated(i + math.random(-30,30)), 0, params)
            end
        
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(mod.Sounds.SplashSmall, 0.5, 0, false, math.random(97,103)/100)
            d.landed = true
            npc.Velocity = npc.Velocity * 0.5
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        else
            mod:spritePlay(sprite, "Exit")
        end
    elseif d.state == "idle" then
        npc.SpriteOffset = Vector(0, 0)
        mod:spritePlay(sprite, "Idle2")
        if npc.StateFrame > 0 and (r:RandomInt(25) == 0 or npc.StateFrame > 10) then
            if mod:isScareOrConfuse(npc) or r:RandomInt(2) == 0 then
                d.state = "move"
            else
                d.state = "shoot"
                if r:RandomInt(2) == 0 then
                    d.shootVec = target.Position - npc.Position
                else
                    d.shootVec = RandomVector()
                end
                if d.shootVec.X < 0 then
                    sprite.FlipX = true
                else
                    sprite.FlipX = false
                end
            end
        end
    elseif d.state == "move" then
        if sprite:IsFinished("Move") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Move") then
            npc:PlaySound(mod.Sounds.WormScoot, 0.2, 0, false, math.random(97,103)/100)
            if not mod:isConfuse(npc) and (mod:isScare(npc) or r:RandomInt(2) == 0) then
                npc.Velocity = mod:reverseIfFear(npc, (target.Position - npc.Position):Resized(5))
            else
                npc.Velocity = RandomVector() * 5
            end
            if npc.Velocity.X < 0 then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        else
            mod:spritePlay(sprite, "Move")
        end
    elseif d.state == "shoot" then
        if sprite:IsFinished("Shoot") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Move") then
            npc:PlaySound(SoundEffect.SOUND_LITTLE_SPIT,0.4,2,false,math.random(150,180)/100)
            local params = ProjectileParams()
            params.Scale = 0.2
            params.FallingSpeedModifier = -5
            params.FallingAccelModifier = 1.5
            params.Variant = 4
            npc:FireProjectiles(npc.Position, d.shootVec:Resized(7), 0, params)
        else
            mod:spritePlay(sprite, "Shoot")
        end
    end

    npc.Velocity = npc.Velocity * 0.95
end

function mod:buoyHurt(npc)
    local d = npc:GetData()
    if d.state == "floating" then
        d.state = "awaken"
    end
end