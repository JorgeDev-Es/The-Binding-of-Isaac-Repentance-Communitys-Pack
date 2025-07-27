local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

function mod:famMonsoon(fam, player, sprite, d)
    if not d.init then
        local targ = mod.FindClosestEnemy(fam.Position, 1250, true)
        if targ then
            fam.Position = targ.Position
        end
        d.state = "fallIntro"
        d.falling = true
        d.init = true
        d.falling = true
        d.fallheight = 600
        d.fallstop = 10
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end

    fam.Velocity = fam.Velocity * 0.8

    if d.falling then
        d.fallheight = d.fallheight - 30
        if d.fallheight < d.fallstop + 1 then
            d.falling = false
            d.fallheight = 0
        end
        fam.SpriteOffset = Vector(0, -d.fallheight)
    end

    if d.state == "fallIntro" then
        mod:spritePlay(sprite, "FallLoop")
        if not d.falling then
            d.state = "Land"
            mod.scheduleForUpdate(function()
                Isaac.Spawn(20, 0, 150, fam.Position+Vector(0,-45), Vector.Zero, nil)
                sfx:Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
            end, 0)
        end
    elseif d.state == "Land" then
        if sprite:IsFinished("FallEnd") then
            d.state = "monstroblast"
        elseif sprite:IsEventTriggered("Land") then
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            fam.CollisionDamage = 100
            mod.scheduleForUpdate(function()
                fam.CollisionDamage = 2
            end, 1)
            sfx:Play(mod.Sounds.LandSoft,1,0,false,0.7)
            sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1.3)
            for i = 22.5, 360, 22.5 do
                local therand = -6 + math.random(10)
                local tear = Isaac.Spawn(2, 0, 0, fam.Position + Vector(0,20):Rotated(i + therand), Vector(0,10):Rotated(i + therand), fam):ToTear()
                tear.Height = -30
                tear.FallingAcceleration = 1.5 + math.random()
                tear.FallingSpeed = -15 - math.random(10)
                tear:Update()
            end
        else
            mod:spritePlay(sprite, "FallEnd")
        end
    elseif d.state == "monstroblast" then
        if sprite:IsFinished("Shoot") then
            d.state = "split"
            mod:spritePlay(sprite, "SplitApart")
            sprite:ReplaceSpritesheet(1, "gfx/nothing.png")
            sprite:LoadGraphics()
        elseif sprite:IsEventTriggered("Shoot") then
            local target = mod.FindClosestEnemy(fam.Position, 1250, true) or player
            if target.Position.X > fam.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
            sfx:Play(mod.Sounds.WateryBarf,1,0,false,1)
            local vec = ((target.Position) - (fam.Position)):Resized(8)
            for i = 1, 7 do
                local tear = Isaac.Spawn(2, 0, 0, fam.Position, vec + (RandomVector() * math.random() * 5.5), fam):ToTear()
                tear.FallingAcceleration = 1 + (math.random() * 0.5)
                tear.FallingSpeed = -10 - math.random(20)
                tear.Scale = mod.MoistroScales[math.random(3)]
            end
            for i = 1, 8 do
                local tear = Isaac.Spawn(2, 0, 0, fam.Position, vec + (RandomVector() * (0.5 + (math.random() * 0.5)) * 6.5),    fam):ToTear()
                tear.FallingAcceleration = 1 + (math.random() * 0.5)
                tear.FallingSpeed = -10 - math.random(20)
                tear.Scale = mod.MoistroWideScales[math.random(3)]
            end
        else
            mod:spritePlay(sprite, "Shoot")
        end
    elseif d.state == "split" then
        if sprite:IsFinished("SplitApart") then
            fam:Remove()
        elseif sprite:IsEventTriggered("Shudder") then
            sfx:Play(mod.Sounds.WateryBarf,1,0,false,0.8)
        elseif sprite:IsEventTriggered("Spawn") then
            sfx:Play(mod.Sounds.SplashLargePlonkless,1,0,false,1.3)
            local target = mod.FindClosestEnemy(fam.Position, 1250, true) or player
            local vec = (target.Position - fam.Position):Resized(12)
            local dribble = mod.spawnent(fam, fam.Position + vec, vec, mod.FF.Dribble.ID, mod.FF.Dribble.Var)
            dribble.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            mod:spritePlay(dribble:GetSprite(), "ChargeLoop")
            dribble.HitPoints = dribble.HitPoints * 0.6
            dribble:AddCharmed(EntityRef(player), -1)
            local ddat = dribble:GetData()
            ddat.state = "charge"
            ddat.charging = 1
            ddat.moist = true
            dribble:Update()
        else
            mod:spritePlay(sprite, "SplitApart")
        end
    end
end