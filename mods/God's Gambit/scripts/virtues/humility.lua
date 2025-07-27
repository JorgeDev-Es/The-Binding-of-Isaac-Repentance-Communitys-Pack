local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

local bal = {
    moveSpeed = 4,
    attackCooldown = {45,135},
    superAttackCooldown = {60,180},
    maxPons = 2,
    spawnRate = 150,
    chaseScribbleShootDelay = 90,
    chaseScribbleSpeed = 6,
    chaseScribbleSlowdown = 0.025,
    spacedScribbleShootDelay = 60,
    spacedScribbleGap = 100,
} 

local function FireHumilityLaser(parent, angle)
    local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.PRIDE, 0, parent.Position, Vector.Zero, parent):ToLaser()
    laser.Parent = parent
    laser.Angle = angle
    if not mod:isFriend(parent) then
        laser.CollisionDamage = 0
    end
    laser.Mass = 0
    laser.Timeout = 15
    laser:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/virtues/humility/effect_humilitylaser.png", true)
    laser:Update()
    for i = 1, 16 do
        mod:ScheduleForUpdate(function()
            mod:PlaySound(i % 2 == 0 and SoundEffect.SOUND_CHARACTER_SELECT_LEFT or SoundEffect.SOUND_CHARACTER_SELECT_RIGHT, nil, 1, 0.6 - ((i - 16) * 0.0375))
        end, i)
    end
    return laser
end

function mod:HumilityAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local isSuper = (npc.Variant == mod.ENT.SuperHumility.Var)

    if not data.Init then
        if isSuper then
            npc.Visible = false
            npc.SplatColor = Color(1,1,1,0)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc.StateFrame = mod:RandomInt(bal.superAttackCooldown, rng)
            data.SpawnChaser = (rng:RandomFloat() <= 0.5)
        else
            npc.SplatColor = mod.Colors.PitchBlack
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
            data.State = "Idle"
        end
        
        npc.I1 = bal.spawnRate
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.Init = true
    end

    if isSuper then
        npc.Position = Vector.Zero
        npc.Velocity = Vector.Zero

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if data.SpawnChaser then
                local scribble = Isaac.Spawn(mod.ENT.HumilityScribble.ID, mod.ENT.HumilityScribble.Var, 1, mod:GetPlayerTargetPos(npc), Vector.Zero, npc)
                scribble.Parent = npc
                scribble:Update()
            else
                local bottomRight = game:GetRoom():GetBottomRightPos()
                local pos = Vector(mod:RandomInt(0,60,rng), rng:RandomFloat() <= 0.5 and 100 or (bottomRight.Y + 20))
                while pos.X < bottomRight.X + 20 do
                    local spawnPos = Vector(pos.X,pos.Y)
                    mod:ScheduleForUpdate(function()
                        local scribble = Isaac.Spawn(mod.ENT.HumilityScribble.ID, mod.ENT.HumilityScribble.Var, 0, spawnPos, Vector.Zero, npc)
                        scribble.Parent = npc
                        scribble:Update()
                    end, mod:RandomInt(0,15))
                    pos = pos + Vector(bal.spacedScribbleGap,0)
                end
            end
            npc.StateFrame = mod:RandomInt(bal.superAttackCooldown, rng)
            data.SpawnChaser = not data.SpawnChaser
        end
    
    else
        if data.State == "Idle" then
            mod:WanderGridAligned(npc, data, bal.moveSpeed, 0.3)
            mod:AnimWalkFrame(npc, sprite, "WalkHori", "WalkVert", true)
    
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.State = "Attack"
            end
    
        elseif data.State == "Attack" then
            npc.Velocity = npc.Velocity * 0.75
    
            if sprite:IsFinished("Attack") then
                npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Shoot") then
                for i = 90, 360, 90 do
                    FireHumilityLaser(npc, i)
                end
                mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_HISS, npc, 0.5, 0.25)
            else
                mod:SpritePlay(sprite, "Attack")
            end
        end
    end

    npc.I1 = npc.I1 - 1
    if npc.FrameCount > 60 
    and (mod:GetEntityCount(EntityType.ENTITY_PON, -1, -1, nil, true) + mod:GetEntityCount(mod.ENT.HumilityPonspawn.ID, mod.ENT.HumilityPonspawn.Var) <= 0 
    or (npc.I1 <= 0 and mod:GetEntityCount(EntityType.ENTITY_PON) < bal.maxPons)) 
    and not (npc:IsDead() or npc:HasMortalDamage()) then
        local spawnpos = mod:FindSafeSpawnSpot(npc.Position, 9999, nil, true, 160, 80)
        Isaac.Spawn(mod.ENT.HumilityPonspawn.ID, mod.ENT.HumilityPonspawn.Var, 0, spawnpos, Vector.Zero, npc)
        mod:PlaySound(SoundEffect.SOUND_PAPER_OUT, npc, 2, 0.75)
        mod:ScheduleForUpdate(function() mod:PlaySound(SoundEffect.SOUND_PAPER_IN, npc, 2, 0.75) end, 8)
        npc.I1 = bal.spawnRate
    end
end

mod.DealingHumilityDamage = false
function mod:HumilityHurt(npc, sprite, data, amount, flags, source)
    return mod.DealingHumilityDamage
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, npc)
    for _, virtue in pairs(Isaac.FindByType(mod.ENT.Humility.ID)) do
        if virtue.Variant == mod.ENT.Humility.Var or virtue.Variant == mod.ENT.SuperHumility.Var then
            mod.DealingHumilityDamage = true
            virtue:TakeDamage(npc.MaxHitPoints + game:GetLevel():GetStage(), 0, EntityRef(npc), 0)
            mod.DealingHumilityDamage = false
        end
    end
end, EntityType.ENTITY_PON)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    effect:GetSprite():Play("Spawn", true)
end, mod.ENT.HumilityPonspawn.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect:GetSprite():IsFinished() then
        Isaac.Spawn(EntityType.ENTITY_PON, 0, 0, effect.Position, Vector.Zero, effect.SpawnerEntity)
        sfx:Play(SoundEffect.SOUND_SUMMONSOUND)
        effect.Visible = false
        effect:Remove()
    end
end, mod.ENT.HumilityPonspawn.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite, data = effect:GetSprite(), effect:GetData() 
        
    if not data.Init then
        sprite:Play("Grow", true)
        data.MoveSpeed = bal.chaseScribbleSpeed
        data.State = "Grow"
        data.Init = true
    end

    if mod:IsReallyDead(effect.Parent) and data.State ~= "Shrink" then
        data.State = "Shrink"
    end

    if data.State == "Grow" then
        if effect.SubType == 1 then
            effect.Velocity = mod:Lerp(effect.Velocity, (game:GetNearestPlayer(effect.Position).Position - effect.Position):Resized(data.MoveSpeed), 0.05)
        end

        if sprite:IsFinished("Grow") then
            data.ShootDelay = effect.SubType == 1 and bal.chaseScribbleShootDelay or bal.spacedScribbleShootDelay
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "Grow")
        end

    elseif data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")
        if effect.SubType == 1 then
            data.MoveSpeed = data.MoveSpeed - bal.chaseScribbleSlowdown
            effect.Velocity = mod:Lerp(effect.Velocity, (game:GetNearestPlayer(effect.Position).Position - effect.Position):Resized(data.MoveSpeed), 0.05)
        end

        data.ShootDelay = data.ShootDelay - 1
        if data.ShootDelay <= 0 then
            if effect.SubType == 1 then
                for i = 90, 360, 90 do
                    FireHumilityLaser(effect, i)
                end
                mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_HISS, nil, 0.33, 0.1)
            else
                if effect.Position.Y < game:GetRoom():GetCenterPos().Y then
                    FireHumilityLaser(effect, 90)
                else
                    FireHumilityLaser(effect, 270)
                end
            end
            data.State = "Shrink"
        end

    elseif data.State == "Shrink" then
        effect.Velocity = effect.Velocity * 0.9

        if sprite:IsFinished("Shrink") then
            effect:Remove()
        else
            mod:SpritePlay(sprite, "Shrink")
        end
    end
end, mod.ENT.HumilityScribble.Var)