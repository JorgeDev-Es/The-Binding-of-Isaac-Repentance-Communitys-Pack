local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local params = ProjectileParams()
params.Variant = 4
params.HeightModifier = -40
params.FallingAccelModifier = 2
params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE

local function ZephyrRainTear(npc)
    if npc.FrameCount % 3 == 0 then
        local rng = npc:GetDropRNG()
        params.Scale = mod:RandomInt(5,10,rng) * 0.1
        npc:FireProjectiles(npc.Position + (RandomVector() * mod:RandomInt(0,20,rng)), RandomVector() + (npc.Velocity * 0.7), 0, params)
        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, mod:RandomInt(20,30,rng) * 0.05, 0.5)
    end
end

function mod:ZephyrAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.Init then
        if rng:RandomFloat() <= 0.5 then
            data.AnimSuffix = "Uncharged"
        else
            data.AnimSuffix = ""
        end
        npc.StateFrame = mod:RandomInt(30,60,rng)
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:spritePlay(sprite, "Idle"..data.AnimSuffix)

        local dist = npc.Position:Distance(targetpos)

        if dist < 60 or mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(5), 0.1)
        elseif dist > 250 then
            npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position):Resized(5), 0.05)
        else
            data.TargetPosition = data.TargetPosition or (targetpos + (RandomVector() * mod:RandomInt(40,160,rng)))
            npc.Velocity = mod:Lerp(npc.Velocity, (data.TargetPosition - npc.Position):Resized(5), 0.05)
            if rng:RandomFloat() <= 0.05 or not room:IsPositionInRoom(data.TargetPosition, 0) then
                data.TargetPosition = nil
            end
        end

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if data.AnimSuffix == "Uncharged" then
                data.State = "YankUp"
            else
                data.State = "Lightning"
                local lightning = Isaac.Spawn(1000, mod.FF.ZephyrLightning.Var, mod.FF.ZephyrLightning.Sub, targetpos, Vector.Zero, npc)
                lightning.Parent = npc
                lightning:Update()
                data.Lightning = lightning
                mod:FlipSprite(sprite, npc.Position, targetpos)
            end
        end

    elseif data.State == "Lightning" then
        npc.Velocity = npc.Velocity * 0.8

        if sprite:IsFinished("Lightning") then
            data.State = "Idle"
            data.AnimSuffix = "Uncharged"
            npc.StateFrame = mod:RandomInt(45,90,rng)
            sprite.FlipX = false
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_0, npc, 1.5, 1)
        elseif sprite:IsEventTriggered("Shoot") then
            data.Lightning:GetData().State = "Bolt"
            mod:FlipSprite(sprite, npc.Position, data.Lightning.Position)
        else
            mod:spritePlay(sprite, "Lightning") 
        end
        
    elseif data.State == "Death" then
        if sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_SIREN_MINION_SMOKE, npc)
        elseif sprite:IsEventTriggered("Shoot") then
            if room:GetGridCollisionAtPos(npc.Position) == GridCollisionClass.COLLISION_PIT then
                if room:HasWater() then
                    mod:PlaySound(mod.Sounds.SplashLarge, npc, 1, 2)
                    Isaac.Spawn(1000, EffectVariant.BIG_SPLASH, 0, npc.Position, Vector.Zero, npc)
                end
                npc:Remove()
            else
                if room:HasWater() then
                    mod:PlaySound(mod.Sounds.SplashSmall, npc, 1, 2)
                    Isaac.Spawn(1000, mod.FF.LargeWaterRipple.Var, mod.FF.LargeWaterRipple.Sub, npc.Position, Vector.Zero, npc)
                end
                for i = 1, 3 do
                    Isaac.Spawn(1000, 5, 1, npc.Position, RandomVector()*(mod:RandomInt(2,4,rng)), npc)
                end
                mod:PlaySound(SoundEffect.SOUND_BONE_SNAP, npc)
                mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc)
            end
        elseif sprite:IsEventTriggered("Explosion") then
            npc:Kill()
        end

    elseif data.State == "YankUp" then
        npc.Velocity = npc.Velocity * 0.8

        if sprite:IsFinished("YankUp") then
            data.State = "ChargeStart"
            data.AnimSuffix = "Down"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc, 1.2, 0.8)
        elseif sprite:IsEventTriggered("Coll") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
        else
            mod:spritePlay(sprite, "YankUp") 
        end

    elseif data.State == "ChargeStart" then
        if data.ChargeVel then
            npc.Velocity = mod:Lerp(npc.Velocity, data.ChargeVel, 0.3)
            ZephyrRainTear(npc)
        else
            npc.Velocity = npc.Velocity * 0.8
        end

        if sprite:IsFinished("ChargeStart"..data.AnimSuffix) then
            sprite:Play("ChargeLoop"..data.AnimSuffix)
            data.State = "ChargeLoop"
            data.ChargeTime = 0
        elseif sprite:IsEventTriggered("Shoot") then            
            data.ChargeVel = (targetpos - npc.Position):Resized(7)
            npc.Velocity = data.ChargeVel
            data.AnimSuffix = mod:GetMoveString(data.ChargeVel)
            sprite:SetAnimation("ChargeStart"..data.AnimSuffix, false)
        else
            mod:spritePlay(sprite, "ChargeStart"..data.AnimSuffix) 
        end

    elseif data.State == "ChargeLoop" then
        npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position):Resized(5), 0.05):Resized(7)
        ZephyrRainTear(npc)
        data.AnimSuffix = mod:GetMoveString(npc.Velocity)
        sprite:SetAnimation("ChargeLoop"..data.AnimSuffix, false)

        data.ChargeTime = data.ChargeTime + 1
        if data.ChargeTime > 90 or (data.ChargeTime > 15 and not room:IsPositionInRoom(npc.Position, 0)) then
            data.State = "YankDown"
        end

    elseif data.State == "YankDown" then
        if not room:IsPositionInRoom(npc.Position, 0) then
            npc.Velocity = mod:Lerp(npc.Velocity, (room:GetCenterPos() - npc.Position):Resized(7), 0.15)
        else
            npc.Velocity = npc.Velocity * 0.8
        end

        if sprite:IsFinished("YankDown") then
            data.State = "Idle"
            data.AnimSuffix = ""
            data.ChargeVel = nil
            npc.StateFrame = mod:RandomInt(45,90,rng)
        elseif sprite:IsEventTriggered("Coll") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        else
            mod:spritePlay(sprite, "YankDown") 
        end
    end
end

function FiendFolio.ZephyrDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
        deathAnim:GetData().State = "Death"
        deathAnim:GetData().Init = true
    end
    FiendFolio.genericCustomDeathAnim(npc, "Death", true, onCustomDeath, false, false, true, true)
end

function mod:ZephyrLightning(effect, sprite, data)
    if not data.Init then
        data.State = "Reticle"
        data.Init = true
    end

    if data.State == "Reticle" then
        mod:spritePlay(sprite, "Reticle")
        if mod:IsReallyDead(effect.Parent) then
            effect:Remove()
        end

    elseif data.State == "Bolt" then
        if not data.StrikeInit then
            mod:PlaySound(SoundEffect.SOUND_REDLIGHTNING_ZAP_BURST)
            mod:PlaySound(SoundEffect.SOUND_THUNDER, nil, 1.5)
            local ring = Isaac.Spawn(7, 2, 2, effect.Position, Vector.Zero, effect.Parent):ToLaser()
            ring.CollisionDamage = 0
            ring.Parent = effect.Parent
            ring.Radius = 5
            ring:AddTearFlags(TearFlags.TEAR_CONTINUUM)
            ring:SetColor(FiendFolio.ColorElectricYellow, 999, 1, false, false)
            ring.Visible = false
            ring:GetData().ZephyrRing = true
            data.StrikeInit = true
        end

        if sprite:IsFinished("Bolt") then
            effect:Remove()
        else
            mod:spritePlay(sprite, "Bolt")
        end

        if sprite:GetFrame() <= 11 then
            mod:DamageInRadius(effect.Position, 18, 2, effect.Parent)
        end
    end
end

function mod:ZephyrRing(laser, data)
    laser.Visible = true
    laser:SetColor(FiendFolio.ColorElectricYellow, 999, 1, false, false)
    if laser.Radius < 60 then
        laser.Radius = laser.Radius + 3
    else
        laser:SetTimeout(1)
    end
end