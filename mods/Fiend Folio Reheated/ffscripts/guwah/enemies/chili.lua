local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:ChiliAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.Init then
        npc.SplatColor = mod.ColorChili
        npc.StateFrame = mod:RandomInt(30,60,rng)
        sprite:SetOverlayRenderPriority(true)
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
        npc.Velocity = npc.Velocity * 0.9

        if not data.WalkPos then
            data.WalkPos = mod:FindRandomValidPathPosition(npc, 2, 60)
        elseif sprite:IsEventTriggered("Move") then
            if mod:isScare(npc) or (targetpos:Distance(npc.Position) <= 100 and room:CheckLine(npc.Position,targetpos,0,1,false,false)) then
                npc.Velocity = (npc.Position - targetpos):Resized(3)
                data.WalkPos = nil 
            else
                npc.Pathfinder:FindGridPath(data.WalkPos, 0.8, 900, false)
            end
            mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        elseif data.WalkPos and npc.Position:Distance(data.WalkPos) <= 20 then
            data.WalkPos = nil
        end

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 
        and room:CheckLine(npc.Position,targetpos,0,1,false,false) 
        and targetpos:Distance(npc.Position) <= 300
        and mod.GetEntityCount(mod.FF.Litling.ID, mod.FF.Litling.Var) < mod.GetEntityCount(mod.FF.Chili.ID, mod.FF.Chili.Var) * 2 then
            data.State = "Attack"
            mod:FlipSprite(sprite, npc.Position, targetpos)
        end
    elseif data.State == "Attack" then
        npc.Velocity = npc.Velocity * 0.9
        if sprite:IsFinished("Attack") then
            npc.StateFrame = mod:RandomInt(60,90,rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS,npc,0.7)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_WORM_SPIT, npc, 0.8)
            mod:PlaySound(SoundEffect.SOUND_BEAST_LAVABALL_RISE, npc, 0.8)
            local vec = (targetpos - npc.Position):Resized(10)
            local litling = Isaac.Spawn(mod.FF.Litling.ID, mod.FF.Litling.Var, 0, npc.Position + (vec*2), vec, npc)
            litling:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            litling:GetData().State = "Move"
            litling:GetData().FuseTimer = mod:RandomInt(60,120,rng)
            litling:GetSprite():Play("Move",true)
            litling:GetSprite():SetFrame(7)
            mod:FlipSprite(litling:GetSprite(), litling.Position, litling.Position + vec)
            mod:FlipSprite(sprite, npc.Position, targetpos)
        else
            mod:spritePlay(sprite, "Attack")
        end
    end

    mod:spriteOverlayPlay(sprite, "Flame")
    if npc.FrameCount % 5 == 1 then
        local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
        splat.Color = mod.ColorChili
        splat:Update()
    end
end

function mod:LitlingAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.Init then
        npc.SplatColor = mod.ColorCharred
        data.FuseTimer = data.FuseTimer or mod:RandomInt(150,210,rng)
        npc.StateFrame = data.FuseTimer
        sprite:SetOverlayRenderPriority(true)

        local sprite = Sprite()
        sprite:Load("gfx/enemies/chili/monster_litling.anm2")
        sprite:Play("Flame", true)
        data.FireSprite = sprite

        data.State = data.State or "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        npc.Velocity = mod:Lerp(npc.Velocity, RandomVector() * 3, 0.05)
        mod:spritePlay(sprite, "Idle")

        if rng:RandomFloat() <= 0.2 + (0.8 * (1 - (npc.StateFrame / data.FuseTimer))) then
            data.State = "Move"
        end
    elseif data.State == "Move" then
        npc.Velocity = npc.Velocity * 0.85
    
        if sprite:IsFinished("Move") then
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Move") then
            if targetpos:Distance(npc.Position) <= 250 and room:CheckLine(npc.Position,targetpos,0,1,false,false) then
                if mod:isScare(npc) then
                    npc.Velocity = (npc.Position - targetpos):Resized(11):Rotated(mod:RandomInt(-30,30,rng))
                else
                    npc.Velocity = (targetpos - npc.Position):Resized(11):Rotated(mod:RandomInt(-30,30,rng))
                end
            else
                local chili = mod:GetNearestThing(npc.Position, mod.FF.Chili.ID, mod.FF.Chili.Var)
                if chili and chili.Position:Distance(npc.Position) < 100 then
                    for i = 1, 5 do --Try to avoid the Chili
                        local vec = (npc.Position - chili.Position):Resized(100):Rotated(mod:RandomInt(-30,30,rng))
                        local _, movepos = room:CheckLine(npc.Position,npc.Position + vec,0,1,false,false)
                        if npc.Position:Distance(movepos) > 80 then
                            npc.Velocity = vec:Resized(10)
                        elseif i == 5 then
                            npc.Velocity = (mod:FindRandomValidPathPosition(npc) - npc.Position):Resized(10):Rotated(mod:RandomInt(-30,30,rng))
                        end
                    end
                else
                    npc.Velocity = (mod:FindRandomValidPathPosition(npc) - npc.Position):Resized(10):Rotated(mod:RandomInt(-30,30,rng))
                end
            end
            mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        else
            mod:spritePlay(sprite, "Move")
        end
    end

    if not sprite:IsPlaying("Appear") then
        data.FireSprite:Update()
    end
    npc.StateFrame = npc.StateFrame - 1

    if npc.FrameCount % 3 == 1 then
        local splat = Isaac.Spawn(1000,7,0,npc.Position,Vector.Zero,npc)
        splat.Color = mod.ColorCharred
        splat.SpriteScale = Vector(0.4,0.4)
        splat:Update()
    end

    if npc:IsDead() then
        game:BombExplosionEffects(npc.Position, 1, 0, Color.Default, npc, 0.5, false, true)
        local flame = Isaac.Spawn(33,10,0,npc.Position,Vector.Zero,npc)
        flame.HitPoints = flame.HitPoints * 0.66
        flame:Update()
    elseif npc.StateFrame <= 0 then
        game:BombExplosionEffects(npc.Position, 1, 0, Color.Default, npc, 0.5, false, true)
        Isaac.Spawn(33,10,0,npc.Position,Vector.Zero,npc)
        npc:Kill()
    end
end

mod.IsLitlingSecondRender = false

function mod:LitlingRender(npc, sprite, data, isPaused, isReflected, offset)
    if data.Init and not (mod.IsLitlingSecondRender or (npc:HasEntityFlags(EntityFlag.FLAG_APPEAR) and (npc.FrameCount < 5 or sprite:IsPlaying("Appear")))) then
        mod.IsLitlingSecondRender = true
        local scale = math.max(0, 0.5 + ((npc.StateFrame / data.FuseTimer)/2))
        data.FireSprite.Scale = Vector(sprite.Scale.X * scale, sprite.Scale.Y * scale)
        data.FireSprite.Color = sprite.Color
        data.FireSprite:Render(Isaac.WorldToScreen(npc.Position))

        npc:Render(offset)
    end
    mod.IsLitlingSecondRender = false
end

function mod:DieOnPlayerCollision(npc, collider)
    if collider:ToPlayer() then
        npc:Kill()
    end
end