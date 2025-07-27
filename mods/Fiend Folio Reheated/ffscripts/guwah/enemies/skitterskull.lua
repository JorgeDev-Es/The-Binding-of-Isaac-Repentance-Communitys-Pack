local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local function MakePoof(npc, size)
    local poofy = Isaac.Spawn(1000, 16, 2, npc.Position, Vector.Zero, npc):ToEffect()
    poofy.Color = mod.ColorGreyscale
    poofy.SpriteScale = Vector(size,size)
    if mod:RandomInt(1,2) == 1 then
        poofy:GetSprite().FlipX = true
    end
    poofy:Update()
    npc:PlaySound(SoundEffect.SOUND_BLACK_POOF, size - 0.2, 0, false, 1)
end

function mod:SkitterSkullAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    
    if not data.Init then
        if npc.SubType > 0 then
            npc.Visible = false
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
            data.State = "Wait"
            data.AggroRadius = 40
        else
            MakePoof(npc, 0.6)
            data.State = "Appear"
        end
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.Init = true
    end

    if data.State == "Wait" then
        npc.Velocity = Vector.Zero
        if data.AggroRadius < 80 then
            data.AggroRadius = data.AggroRadius + 0.1
        end
        if (npc.SubType == 1 and targetpos:Distance(npc.Position) < data.AggroRadius) or mod.CanIComeOutYet() then
            npc.Visible = true
            data.State = "Dirtmaking"
            npc.StateFrame = 20
        end
    
    elseif data.State == "Dirtmaking" then
        npc.Velocity = Vector.Zero
        mod:spritePlay(sprite, "Dirt")
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            MakePoof(npc, 0.6)
            data.State = "Appear"
        end

        if npc.FrameCount % 4 == 0 then
            sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.2, 0, false, mod:RandomInt(12,14,rng)/10)
            local effect = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position, Vector(0,-3.5):Rotated(mod:RandomInt(-45,45,rng)), npc)
            effect.Color = Color(0.8,0.8,0.8,0.6)
            effect:GetData().longonly = true
        end

    elseif data.State == "Appear" then
        npc.Velocity = Vector.Zero
        if sprite:IsFinished("Appear") then
            npc.StateFrame = mod:RandomInt(120,180,rng)
            data.MeleeCooldown = 0
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Appear") then
            MakePoof(npc, 1)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
        else
            mod:spritePlay(sprite, "Appear")
        end

    elseif data.State == "Chase" then
        mod:ChasePlayer(npc, 5)

        if npc.Velocity:Length() <= 0.1 then
            mod:spritePlay(sprite, "Idle")
        else
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                mod:spritePlay(sprite, "WalkHori")
                mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
            else
                sprite.FlipX = false
                if npc.Velocity.Y < 0 then
                    mod:spritePlay(sprite, "WalkUp")
                else
                    mod:spritePlay(sprite, "WalkDown")
                end
            end
        end

        npc.StateFrame = npc.StateFrame - 1
        data.MeleeCooldown = data.MeleeCooldown - 1
        if data.MeleeCooldown <= 0 and npc.Position:Distance(targetpos) <= 80 or (npc.Position:Distance(targetpos) <= 160 and not npc.Pathfinder:HasPathToPos(targetpos)) then
            local vec = mod:SnapVector(targetpos - npc.Position, 90):Resized(60)
            if (npc.Position + vec):Distance(targetpos) <= 40 then
                data.AttackSuffix, sprite.FlipX = mod:GetMoveString(vec, true)
                data.SnapVec = mod:SnapVector(targetpos - npc.Position, 90):Resized(60)
                data.State = "Snap"
            end
        elseif npc.StateFrame <= 0 and room:CheckLine(npc.Position, targetpos, 3, 0, false, false) and npc.Position:Distance(targetpos) < 400 then
            mod:FlipSprite(sprite, npc.Position, targetpos)
            data.State = "Shoot"
        end

    elseif data.State == "Snap" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsFinished("Snap"..data.AttackSuffix) then
            data.MeleeCooldown = 15
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Shoot") then
            for i = 1, game:GetNumPlayers() do
                local player = game:GetPlayer(i)
                if mod:KnightTargetCheck(npc, targetpos, data.AttackSuffix, sprite.FlipX, 30, 80, true) then
                    player:TakeDamage(2, 0, EntityRef(npc), 0)
                end
            end

            mod:DestroyNearbyGrid(npc, 40, false, npc.Position + data.SnapVec)
        
            mod:PlaySound(mod.Sounds.ClipSnap, npc, 0.8, 3)
            mod:PlaySound(SoundEffect.SOUND_BONE_BREAK, npc, 0.8, 0.5)
        else
            mod:spritePlay(sprite, "Snap"..data.AttackSuffix)
        end

    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsFinished("TailShoot") then
            npc.StateFrame = mod:RandomInt(120,180,rng)
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Shoot") then
            local vec = (targetpos - npc.Position):Resized(10)
            local projectile = Isaac.Spawn(9,0,0,npc.Position,vec,npc):ToProjectile()
            projectile.Scale = 2
            projectile.FallingSpeed = 10
            projectile.FallingAccel = 2
            projectile.Height = -90
            projectile.Color = mod.ColorVenomGreen
            projectile:GetData().projType = "skipVenom"
            projectile:Update()

            local effect = Isaac.Spawn(1000, 2, 2, npc.Position, Vector.Zero, npc)
            effect.SpriteOffset = Vector(0,-50)
            effect.Color = mod.ColorVenomGreen
            effect.DepthOffset = npc.Position.Y * 1.25

            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
            mod:FlipSprite(sprite, npc.Position, targetpos)
        else
            mod:spritePlay(sprite, "TailShoot")
        end
    end
end

function mod:SkippingVenomProjectile(projectile, data)
    if projectile.Height >= -10 then
        local sprite = projectile:GetSprite()
        local creep = Isaac.Spawn(1000, 23, 0, projectile.Position, Vector.Zero, projectile):ToEffect()
        creep.Color = mod.ColorVenomGreen
        creep:SetTimeout(200)
        creep:Update()
        local effect = Isaac.Spawn(mod.FF.LargeWaterRipple.ID, mod.FF.LargeWaterRipple.Var, mod.FF.LargeWaterRipple.Sub, projectile.Position, Vector.Zero, projectile)
        effect.Color = mod.ColorIpecacProper
        mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, nil, 1.5, 0.5)
        local new = Isaac.Spawn(9, 0, 0, projectile.Position, projectile.Velocity, projectile.SpawnerEntity):ToProjectile()
        new.Color = projectile.Color
        new.Scale = projectile.Scale
        new.FallingSpeed = -15
        new.FallingAccel = 2
        new.Height = projectile.Height
        new:GetSprite():SetFrame(sprite:GetFrame()) 
        new:GetSprite():Play(sprite:GetAnimation())
        new:GetData().projType = data.projType
        new.ProjectileFlags = projectile.ProjectileFlags
        projectile:Remove()
    end
end