local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

local bal = {
    idleTime = {5,10},
    numHops = {2,3},
    hopSpeed = 10,
    rummageTime = {150,180},
    bombChance = 0.4,
    superSpecialBombChance = 0.3,
    bombSpeed = {8,14},
    bombFallSpeed = {-15,-5},
    coinAmount = {2,5},
    coinAmountSuper = {4,7},
    coinSpeed = {4,9},
    coinFallSpeed = {-30,-15},
    numProjs = {1,2},
    projSpeed = 18,
    superProjSpread = 30,
    projSpeed2 = 12,
}

local params = ProjectileParams()
params.Variant = ProjectileVariant.PROJECTILE_GRID
params.FallingAccelModifier = 1
params.Damage = 1

local params2 = ProjectileParams()
params2.Scale = 3
params2.HeightModifier = -50
params2.FallingSpeedModifier = 8

function mod:CharityAI(npc, sprite, data)
    local targetpos = mod:GetPlayerTargetPos(npc)
    local rng = npc:GetDropRNG()
    local isSuper = (npc.Variant == mod.ENT.SuperCharity.Var)

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        npc.CollisionDamage = 0
        npc.SplatColor = mod.Colors.GreedGuts
        data.State = "Appear"
        sprite:Play("Appear", true)
        data.Init = true
    end

    if data.State == "Appear" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Appear") then
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            npc.I1 = mod:RandomInt(bal.numHops, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            sfx:Play(SoundEffect.SOUND_CHEST_DROP)
        elseif sprite:IsEventTriggered("Shoot") then
            sfx:Play(SoundEffect.SOUND_CHEST_OPEN)
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.CollisionDamage = 2
        else
            mod:SpritePlay(sprite, "Appear")
        end

    elseif data.State == "Idle" then
        npc.Velocity = npc.Velocity * 0.5
        mod:SpritePlay(sprite, "Idle")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "Jump"
        end

    elseif data.State == "Jump" then
        if sprite:WasEventTriggered("Shoot") and not sprite:WasEventTriggered("Sound") then
            npc.Velocity = npc.Velocity * 0.8
        else
            npc.Velocity = npc.Velocity * 0.5
        end

        if sprite:IsFinished("Jump") then
            npc.I1 = npc.I1 - 1
            if npc.I1 <= 0 then
                data.State = "RummageStart"
            else
                npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
                data.State = "Idle"
            end
        elseif sprite:IsEventTriggered("Shoot") then
            npc.Velocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(bal.hopSpeed))
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
        elseif sprite:IsEventTriggered("Sound") then
            sfx:Play(SoundEffect.SOUND_CHEST_DROP)
            npc.Velocity = npc.Velocity * 0.5
        else
            mod:SpritePlay(sprite, "Jump")
        end

    elseif data.State == "RummageStart" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("RummageStart") then
            npc.StateFrame = mod:RandomInt(bal.rummageTime, rng)
            npc.V1 = Vector(-1,0)
            data.State = "RummageLoop"
        else
            mod:SpritePlay(sprite, "RummageStart")
        end

    elseif data.State == "RummageLoop" then
        npc.Velocity = npc.Velocity * 0.5
        mod:SpritePlay(sprite, "RummageLoop")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.ProjData = {}
            for i = 1, bal.numProjs[isSuper and 2 or 1] do
                local isTar = (rng:RandomFloat() <= 0.5)
                data.ProjData[i] = isTar
                if isTar then
                    sprite:GetLayer("ball"..i):SetColor(mod.Colors.Tar)
                else
                    sprite:GetLayer("ball"..i):SetColor(Color.Default)
                end
            end
            sprite:Play("RummageEnd", true)
            data.State = "RummageEnd"
        end

        if sprite:IsEventTriggered("Shoot") then
            if rng:RandomFloat() <= bal.bombChance then
                local bombVariant = BombVariant.BOMB_NORMAL
                local bombFlags = BitSet128()
                if isSuper and rng:RandomFloat() <= bal.superSpecialBombChance then
                    if rng:RandomFloat() <= 0.5 then
                        bombVariant = BombVariant.BOMB_SAD_BLOOD
                        bombFlags = TearFlags.TEAR_SAD_BOMB
                    else
                        bombVariant = BombVariant.BOMB_HOT
                        bombFlags = TearFlags.TEAR_BURN
                    end
                end 
                local vel = npc.V1:Resized(mod:RandomInt(bal.bombSpeed,rng)):Rotated(mod:RandomInRange(90,rng))
                local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, bombVariant, 0, npc.Position + vel:Resized(npc.Size + 3), vel, npc):ToBomb()
                bomb.Flags = bombFlags
                bomb:SetHeight(mod:RandomInt(bal.bombFallSpeed, rng))
                bomb:SetFallingSpeed(1)
                bomb.ExplosionDamage = 5
                bomb:Update()
                mod:PlaySound(SoundEffect.SOUND_SCAMPER, npc, 0.8)
            else
                for i = 1, mod:RandomInt(isSuper and bal.coinAmountSuper or bal.coinAmount, rng) do
                    local vel = npc.V1:Resized(mod:RandomInt(bal.coinSpeed,rng)):Rotated(mod:RandomInRange(90,rng))
                    params.FallingSpeedModifier = mod:RandomInt(bal.coinFallSpeed, rng)
                    local proj = npc:FireProjectilesEx(npc.Position, vel, 0, params)[1]
                    proj:GetSprite():Load("gfx/002.020_coin tear.anm2", true)
                    proj:GetSprite():Play("Rotate"..mod:RandomInt(1,3,rng), true)
                    proj:GetData().projType = "CharityCoin"
                    proj.SpriteRotation = mod:RandomAngle()
                    proj:Update()
                end
                mod:PlaySound(SoundEffect.SOUND_SCAMPER, npc, 1.2)
            end
            npc.V1 = -npc.V1
        end

    elseif data.State == "RummageEnd" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("RummageEnd") then
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            npc.I1 = mod:RandomInt(bal.numHops, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_POWERUP1, npc)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_SHELLGAME, npc)
            for i, isTar in pairs(data.ProjData) do
                local angle = isSuper and (i == 1 and bal.superProjSpread or -bal.superProjSpread) or 0
                if isTar then
                    params2.Color = mod.Colors.Tar
                else
                    params2.Color = Color.Default
                end
                local proj = npc:FireProjectilesEx(npc.Position, (targetpos - npc.Position):Resized(bal.projSpeed):Rotated(angle), 0, params2)[1]
                proj:GetData().projType = "CharityOrb"
                proj:GetData().CharityTarOrb = isTar
                proj:Update()
            end
        else
            mod:SpritePlay(sprite, "RummageEnd")
        end
    end
end

function mod:CharityCoinProjectileDeath(proj, data)
    for i = 1, mod:RandomInt(2,3) do
        local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, 1, proj.Position, RandomVector() * mod:RandomInt(2,6), proj)
        gib.Color = proj.Color
        gib:Update()
    end
    local impact = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, proj.Position, Vector.Zero, proj)
    impact.PositionOffset = proj.PositionOffset
    impact.Color = Color(1,1,1,1,0.9,0.9,0)
    impact:Update()
    mod:PlaySound(SoundEffect.SOUND_POT_BREAK, nil, mod:RandomInt(25,30) * 0.1, 0.25)
end

function mod:CharityOrbProjectile(proj, data)
    proj.Velocity = proj.Velocity * 0.95
end

function mod:CharityOrbProjectileDeath(proj, data)
    sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
    for i = 90, 360, 90 do
        mod:CloneProjectile(proj, Vector(bal.projSpeed2,0):Rotated(i + (data.CharityTarOrb and 45 or 0)))
    end
end
