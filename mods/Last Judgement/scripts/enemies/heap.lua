local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    initCooldown = {60,120},
    clusterCooldown = {210,270},
    clusterSpeed = 7.5,
    clusterAmount = {8,11},
    phageSpeed = 6,
    spawnCap = 6,
    deathPhages = {2,3},
    deathPhageSpeed = {4,9},
    gooCooldown = {20,25},
    gooProjSpeed = 4,
    gooSwapCooldown = {90,120},
    gooHideTime = {10,20},
    deathSpeed = 8,
    deathNum = 9,
}

local params1 = ProjectileParams()
params1.Color = mod.Colors.MortisBloodProj

local params2 = ProjectileParams()
params2.Color = mod.Colors.VirusBlue
params2.BulletFlags = ProjectileFlags.WIGGLE
params2.Scale = 0.5
params2.FallingAccelModifier = -0.15

local params3 = ProjectileParams()
params3.Color = mod.Colors.VirusBlue
params3.Scale = 1.5

function mod:HeapAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SpriteOffset = Vector(0,5)
        npc.SizeMulti = Vector(1.33,1)
        npc.SplatColor = mod.Colors.MortisBlood
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        data.TookDamage = 0
        data.State = "Appear"
        data.Init = true
    end

    npc.Velocity = Vector.Zero
    mod:QuickSetEntityGridPath(npc)

    if data.State == "Appear" then
        if sprite:IsFinished("Appear") and npc.FrameCount > 0 then
            if npc.SubType == 1 then
                data.GooLeftSide = (Isaac.GetPlayer().Position.X < npc.Position.X)
            elseif npc.SubType == 2 then
                data.GooLeftSide = true
            elseif npc.SubType == 3 then
                data.GooLeftSide = false
            else
                data.GooLeftSide = (rng:RandomFloat() <= 0.5)
            end
        
            data.GooSprite = Sprite()
            data.GooSprite:Load("gfx/enemies/heap/monster_goo.anm2", true)
            data.GooState = "Emerge"
            npc.StateFrame = mod:RandomInt(bal.initCooldown, rng)
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "Appear")
        end

    elseif data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if mod:CountPhages() < mod:GetEntityCount(mod.ENT.Heap.ID, mod.ENT.Heap.Var) * bal.spawnCap then
                data.State = "Attack"
            else
                npc.StateFrame = 20
            end
        end

    elseif data.State == "Attack" then
        if sprite:IsFinished("Attack") then
            data.GooCooldown = mod:RandomInt(bal.gooCooldown, rng)
            npc.StateFrame = mod:RandomInt(bal.clusterCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            local angle = rng:RandomFloat() <= 0.5 and 45 or 0
            for i = angle, angle + 270, 90 do
                local vec = Vector.FromAngle(i):Resized(bal.phageSpeed)
                mod:ShootPhage(npc.Position + vec:Resized(20), vec, npc)
            end
            --mod:ShootClusterProjectiles(npc, (targetpos - npc.Position):Resized(bal.clusterSpeed), mod:RandomInt(bal.clusterAmount,rng), params1, 13, 0.6, -8, 2.5)
            mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_GURGLE, npc, 0.33, 1)
            mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc, 0.8, 1)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc)
            effect.SpriteScale = Vector(0.5,0.5)
            effect.Color = mod:CloneColor(mod.Colors.VirusBlue, 0.6)
            effect.SpriteOffset = Vector(0,-20)
            effect:Update()
        else
            mod:SpritePlay(sprite, "Attack")
        end
    end

    if data.GooSprite then
        local onSameSide
        if data.GooLeftSide then
            onSameSide = (targetpos.X <= npc.Position.X)
        else
            onSameSide = (targetpos.X >= npc.Position.X)
        end
        data.GooSprite:Update()

        if data.GooState == "Emerge" then
            if data.GooSprite:IsFinished("Emerge") then
                data.GooCooldown = mod:RandomInt(bal.gooCooldown, rng)
                data.GooSwapTimer = mod:RandomInt(bal.gooSwapCooldown, rng)
                data.GooState = "Idle"
            elseif data.GooSprite:IsEventTriggered("Sound") then
                mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 1.3, 0.5)
            else
                mod:SpritePlay(data.GooSprite, "Emerge")
            end

        elseif data.GooState == "Idle" then
            mod:SpritePlay(data.GooSprite, "Idle")

            if data.State ~= "Attack" then
                if onSameSide then
                    data.GooCooldown = data.GooCooldown - 1
                    if data.GooCooldown <= 0 then
                        local gooOffset = data.GooLeftSide and Vector(-40,0) or Vector(40,0)
                        local gooPos = npc.Position + gooOffset
                        if game:GetRoom():CheckLine(targetpos, gooPos, 3) then
                            local vec = (targetpos - gooPos):Resized(bal.gooProjSpeed)
                            local proj = npc:FireProjectilesEx(gooPos, vec, 0, params2)[1]
                            proj.DepthOffset = 40
                            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, npc.Position, Vector.Zero, npc)
                            effect.Color = mod:CloneColor(mod.Colors.VirusBlue, 0.6)
                            effect.PositionOffset = gooOffset + Vector(0,-30)
                            effect.DepthOffset = 40
                            effect:Update()
                            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.3, 0.5)
                            data.GooState = "Shoot"
                        else
                            data.GooCooldown = mod:RandomInt(bal.gooCooldown, rng)
                        end
                    end
                else
                    data.GooSwapTimer = data.GooSwapTimer - 1
                    if data.TookDamage > 0 then
                        data.GooSwapTimer = data.TookDamage
                        data.TookDamage = 0
                    end
                    if data.GooSwapTimer <= 0 then
                        data.GooSwapTimer = mod:RandomInt(bal.gooHideTime,rng)
                        data.GooState = "Submerge"
                    end
                end
            end
          
        elseif data.GooState == "Shoot" then
            if data.GooSprite:IsFinished("Shoot") then
                data.GooCooldown = mod:RandomInt(bal.gooCooldown, rng)
                data.GooState = "Idle"
            else
                mod:SpritePlay(data.GooSprite, "Shoot")
            end

        elseif data.GooState == "Submerge" then
            if data.GooSprite:IsFinished("Submerge") then
                data.GooSwapTimer = data.GooSwapTimer - 1
                if data.GooSwapTimer <= 0 then
                    data.GooLeftSide = not data.GooLeftSide
                    data.GooState = "Emerge"
                end
            elseif data.GooSprite:IsEventTriggered("Sound") then
                mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1.3, 0.5)
            else
                mod:SpritePlay(data.GooSprite, "Submerge")
            end
        end
    end

    if npc:IsDead() then
        for i = 1, 10 do
            local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, npc.Position, RandomVector() * mod:RandomInt(2,6,rng), npc)
            gib.Color = mod.Colors.VirusBlue
            gib.SplatColor = mod.Colors.VirusBlue
            gib:Update()
        end
        for i = 1, mod:RandomInt(bal.deathPhages,rng) do
            local vec = RandomVector() * mod:RandomInt(bal.deathPhageSpeed, rng)
            local phage = Isaac.Spawn(mod.ENT.Phage.ID, mod.ENT.Phage.Var, 0, npc.Position + vec, vec, npc)
            phage:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            phage:GetData().State = "Idle"
        end
        local pheege = Isaac.Spawn(mod.ENT.Pheege.ID, mod.ENT.Pheege.Var, 0, npc.Position, RandomVector() * 2, npc)
        pheege:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:FireProjectiles(npc.Position, Vector(bal.deathSpeed, bal.deathNum), ProjectileMode.CIRCLE_CUSTOM, params3)
    end

    data.TookDamage = 0
end

function mod:HeapRender(npc, sprite, data)
    if data.GooSprite then
        if npc.Visible then
            if mod:IsNormalRender() and sprite:GetCurrentAnimationData() then
                local animScale = sprite:GetCurrentAnimationData():GetLayer(0):GetFrame(sprite:GetFrame()):GetScale()
                data.GooSprite.Scale = Vector(sprite.Scale.X * animScale.X, sprite.Scale.Y * animScale.Y)
                data.GooSprite.Color = sprite.Color
                data.GooSprite.FlipX = data.GooLeftSide
            end
            if not mod:IsRenderingReflection() then
                local renderPos = Isaac.WorldToScreen(npc.Position + Vector(0,7) + (data.GooLeftSide and npc:GetNullOffset("Goo Left") or npc:GetNullOffset("Goo Right")))
                data.GooSprite:Render(renderPos)
            end
        end
    end
end

function mod:HeapHurt(npc, sprite, data, amount, damageFlags, source)
    if data.TookDamage then
        data.TookDamage = math.max(data.TookDamage, amount)
    end
end