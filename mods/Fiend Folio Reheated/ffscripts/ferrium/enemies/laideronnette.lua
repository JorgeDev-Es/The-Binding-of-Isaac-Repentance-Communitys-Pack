local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local dirToAngle = {
    ["Up"] = 0,
    ["Right"] = 90,
    ["Down"] = 180,
    ["Left"] = 270,
}

function mod:laideronnetteAI(npc)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local data = npc:GetData()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, target.Position)

    if not data.init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        --npc.Visible = false
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        local wallPos = mod:GetClosestWallPos(npc.Position)
        local ang = dirToAngle[mod:GetMoveString(npc.Position - wallPos)]
        npc.SpriteRotation = ang
        npc.Position = wallPos

        data.state = "Appear"
        sprite:Play("Clench")

        data.laidCooldown = 0

        data.init  = true
    else
        if data.laidCooldown > 0 then
            data.laidCooldown=data.laidCooldown-1
        end
        npc.StateFrame = npc.StateFrame+1
    end

    if data.state == "Idle" then
        npc.Velocity = Vector.Zero
        mod:spritePlay(sprite, "Idle")

        if npc.StateFrame > 40 and rng:RandomInt(30) == 0 then
            data.state = "Unclench"
        elseif npc.StateFrame > 90 then
            data.state = "Unclench"
        end
    elseif data.state == "Hurt" then
        if sprite:IsFinished("Hurt") then
            data.state = "Idle"
        else
            mod:spritePlay(sprite, "Hurt")
        end

        npc.Velocity = Vector.Zero
    elseif data.state == "Clench" then
        if sprite:IsFinished("Clench") then
            data.state = "Idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "Clench")
        end

        npc.Velocity = Vector.Zero
    elseif data.state == "Unclench" then
        if sprite:IsFinished("Unclench") then
            data.state = "Hide"
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "Unclench")
        end

        npc.Velocity = Vector.Zero
    elseif data.state == "Hide" then
        if sprite:IsFinished("Sink") then
            data.state = "Appear"

            local wallPos = mod:GetClosestWallPos(target.Position)
            local ang = dirToAngle[mod:GetMoveString(target.Position - wallPos)]
            npc.SpriteRotation = ang
            npc.Position = wallPos
            if data.Hitbox then
                data.Hitbox:Remove()
                data.Hitbox = nil
            end
        elseif sprite:IsEventTriggered("Transition") then
            data.hiding = 2
        else
            mod:spritePlay(sprite, "Sink")
        end

        if data.hiding then
            data.Hitbox:GetData().PositionOffset = Vector(0,40):Rotated(npc.SpriteRotation+180)*data.hiding

            if data.hiding > 0 then
                data.hiding = data.hiding-1
            else
                data.hiding = nil
                data.Hitbox:Remove()
                data.Hitbox = nil
            end
        end

        npc.Velocity = Vector.Zero
    elseif data.state == "Rise" then
        if sprite:IsFinished("Rise") then
            data.state = "Clench"
        elseif sprite:IsEventTriggered("Transition") then
            data.lengthen = 0
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "Rise")
        end

        if data.lengthen then
            if not data.Hitbox then
                data.Hitbox = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 0, npc.Position, npc.Velocity, npc)
                local hData = data.Hitbox:GetData()
                --hData.Rotation = npc.SpriteRotation
                if npc.SpriteRotation == 0 or npc.SpriteRotation == 180 then
                    hData.Height = 80
                else
                    hData.Width = 80
                end
                hData.Relay = true
                hData.FixToSpawner = true
                data.Hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                data.Hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                data.Hitbox.CollisionDamage = 1
            end

            data.Hitbox:GetData().PositionOffset = Vector(0,40):Rotated(npc.SpriteRotation+180)*data.lengthen

            if data.lengthen < 2 then
                data.lengthen = data.lengthen+1
            else
                data.lengthen = nil
            end
        end

        npc.Velocity = Vector.Zero
    elseif data.state == "Appear" then
        if sprite:IsFinished("Appear") then
            data.state = "Rise"
        else
            mod:spritePlay(sprite, "Appear")
        end

        npc.Velocity = Vector.Zero
    end

    if npc:IsDead() then
        npc:PlaySound(mod.Sounds.LaideronnetteDeath, 1, 0, false, 1)

        local params = ProjectileParams()
        params.FallingAccelModifier = -0.05
        params.FallingSpeedModifier = 0
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        mod:SetGatheredProjectiles()
        for i=1,12 do
            params.Scale = mod:getRoll(2,9,rng)/10
            npc:FireProjectiles(npc.Position+Vector(0,50):Rotated(npc.SpriteRotation+180), Vector(0,mod:getRoll(24,40,rng)/2):Rotated(npc.SpriteRotation+180+mod:getRoll(-5,5,rng)), 0, params)
        end
        for _,proj in pairs(mod:GetGatheredProjectiles()) do
            local pData = proj:GetData()
            pData.projType = "laideronnette"
            pData.fallDir = Vector(0,0.3):Rotated(npc.SpriteRotation)
            pData.dontRemoveHeight = true
        end
    end
end

function mod:laideronnetteHurt(entity, damage, flags, source, countdown)
    local npc = entity:ToNPC()
    local data = npc:GetData()
    data.laidCooldown = data.laidCooldown or 0
    if damage > 0 and data.laidCooldown <= 0 then
        local rng = npc:GetDropRNG()
        if data.state == "Idle" then
            data.state = "Hurt"
        end
        if damage < npc.HitPoints then
            npc:PlaySound(mod.Sounds.LaideronnetteHurt, 1, 0, false, math.random(90,110)/100)
        end

        local params = ProjectileParams()
        params.FallingAccelModifier = -0.05
        params.FallingSpeedModifier = 0
        params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
        mod:SetGatheredProjectiles()
        for i=1,5 do
            params.Scale = mod:getRoll(2,9,rng)/10
            npc:FireProjectiles(npc.Position+Vector(0,50):Rotated(npc.SpriteRotation+180), Vector(0,mod:getRoll(8,16,rng)):Rotated(npc.SpriteRotation+180+mod:getRoll(-40,40,rng)), 0, params)
        end
        params.Scale = 2
        local color = Color(1,1,1,1,0,0,0)
        color:SetColorize(6,1,1,1)
        params.Color = color
        npc:FireProjectiles(npc.Position+Vector(0,50):Rotated(npc.SpriteRotation+180), Vector(0,mod:getRoll(8,16,rng)):Rotated(npc.SpriteRotation+180+mod:getRoll(-40,40,rng)), 0, params)
        for _,proj in pairs(mod:GetGatheredProjectiles()) do
            local pData = proj:GetData()
            pData.projType = "laideronnette"
            pData.fallDir = Vector(0,0.3):Rotated(npc.SpriteRotation)
            if proj.Scale == 2 then
                pData.burst = true
            end
        end

        data.laidCooldown = 12
    end
end

function mod.laideronnetteProj(v, d)
    if d.projType == "laideronnette" then
        local room = game:GetRoom()

        v.FallingSpeed = 0
        v.FallingAccel = 0

        v.Velocity = v.Velocity+d.fallDir

        if not room:IsPositionInRoom(v.Position, -100) and d.falling == true and not d.dontRemoveHeight then
            v:Remove()
        elseif d.dontRemoveHeight and v.FrameCount > 200 then
            v:Remove()
        end

        if d.canCollide then
            local wallDetect = room:GetGridCollisionAtPos(v.Position)
            if wallDetect == GridCollisionClass.COLLISION_WALL and v.FrameCount > 15 then
                v:Die()
            end
        else
            if math.abs(d.fallDir.X) > math.abs(d.fallDir.Y) then
                if d.fallDir.X > 0 then
                    if v.Velocity.X > 0 then
                        d.falling = true
                        if room:IsPositionInRoom(v.Position, 0) then
                            d.canCollide = true
                        end
                    end
                else
                    if v.Velocity.X < 0 then
                        d.falling = true
                        if room:IsPositionInRoom(v.Position, 0) then
                            d.canCollide = true
                        end
                    end
                end
            else
                if d.fallDir.Y > 0 then
                    if v.Velocity.Y > 0 then
                        d.falling = true
                        if room:IsPositionInRoom(v.Position, 0) then
                            d.canCollide = true
                        end
                    end
                else
                    if v.Velocity.Y < 0 then
                        d.falling = true
                        if room:IsPositionInRoom(v.Position, 0) then
                            d.canCollide = true
                        end
                    end
                end
            end
        end
    end
end

function mod.laideronneteProjRemove(v, d)
    if d.projType == "laideronnette" and d.burst then
        sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
        for i=1,8 do
            local proj = Isaac.Spawn(9, 0, 0, v.Position, Vector(0,10):Rotated(i*45), v):ToProjectile()
            proj.ProjectileFlags = v.ProjectileFlags
            local pData = proj:GetData()
            pData.projType = "laideronnette"
            pData.fallDir = d.fallDir
            pData.canCollide = true
        end
    end
end

--[[function mod:laideronneteHelperAI(npc)
    local data = npc:GetData()
    local laid = data.laideronnette

    if not data.init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.Visible = false
        npc:GetSprite().Color = Color(1,1,1,0,0,0,0)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        data.state = "Snap"

        data.init = true
    end

    npc.Visible = false

    if not mod:superExists(laid) then
        npc:Remove()
    else
        if data.state == "Snap" then
            local wallPos = mod:GetClosestWallPos(npc.Position)
            local ang = dirToAngle[mod:GetMoveString(npc.Position - wallPos)]
            laid.SpriteRotation = ang
            npc.Position = wallPos
            laid.Position = npc.Position
            data.state = "Idle"
        end
    end
end]]