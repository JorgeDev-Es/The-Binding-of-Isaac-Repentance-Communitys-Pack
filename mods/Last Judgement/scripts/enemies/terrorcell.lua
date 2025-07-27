local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    idleSpeed = 2,
    virusRangeBias = 1.25,
    attackRange = 100,
    minAttackRange = 350,
    chargeCooldown = {20,35},
    chargeSpeed = 20,
    minChargeDuration = 10,
    maxChargeDuration = 30,
    chargeDamage = 25,
    projSpeed = 9,
    projAngleVar = 60,
    projHomingStrength = 2,
    projSpeed2 = 9,
    phageSpawnInterval = 120,
    phageSpawnCap = 4,
}

local params = ProjectileParams()
params.Variant = mod.ENT.AntibodyProjectile.Var
params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE

mod.VirusEnemies = {
    [mod.ENT.Phage.ID.." "..mod.ENT.Phage.Var] = {OneShot = true, Value = 1},
    [mod.ENT.Pheege.ID.." "..mod.ENT.Pheege.Var] = {OneShot = true, Value = 2},
    [mod.ENT.Phooge.ID.." "..mod.ENT.Phooge.Var] = {OneShot = true, Value = 4},
    [mod.ENT.StrainBaby.ID.." "..mod.ENT.StrainBaby.Var] = {OneShot = true, Value = 4},
}

local function RegisterTerrorCellData(_, npc)
    local virusData = mod.VirusEnemies[npc.Type.." "..npc.Variant]
    if virusData then
        virusData.LastDamageFrame = game:GetFrameCount()
        npc:GetData().TerrorCellData = virusData
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, RegisterTerrorCellData)
mod:AddCallback(ModCallbacks.MC_POST_NPC_MORPH, RegisterTerrorCellData)

local function GetVirusEnemies()
    if not (mod.CurrentVirusEnemies and #mod.CurrentVirusEnemies > 0) then
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            if ent:Exists() and ent:GetData().TerrorCellData then
                table.insert(mod.CurrentVirusEnemies, ent)
            end
        end
    end
    return mod.CurrentVirusEnemies
end

local function GetTerrorCellTarget(npc)
    local target = npc:GetPlayerTarget()
    local dist = target.Position:Distance(npc.Position)
    for _, ent in pairs(GetVirusEnemies()) do
        if game:GetRoom():IsPositionInRoom(ent.Position, 0) then
            local newDist = ent.Position:Distance(npc.Position)
            if newDist < dist * bal.virusRangeBias then
                target = ent
                dist = newDist
            end
        end
    end
    return target
end

local function GetTerrorCellTargetPos(npc)
    return mod:confusePos(npc, GetTerrorCellTarget(npc).Position)
end

local function DoCharge(npc)
    local data = npc:GetData()
    npc.Velocity = mod:Lerp(npc.Velocity, npc.V1, 0.3)
    mod:FlipSprite(npc:GetSprite(), npc.Position, npc.Position + npc.V1)

    for _, enemy in pairs(Isaac.FindInRadius(npc.Position, npc.Size + 10, EntityPartition.ENEMY)) do
        local virusData = enemy:GetData().TerrorCellData 
        if virusData then
            if virusData.OneShot then
                data.Antibodies = data.Antibodies + virusData.Value
                enemy:Kill()
            elseif game:GetFrameCount() - virusData.LastDamageFrame > 10 then
                virusData.LastDamageFrame = game:GetFrameCount()
                mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, nil, 1.2, 0.75)
                if enemy.HitPoints <= bal.chargeDamage then
                    data.Antibodies = data.Antibodies + virusData.Value
                    enemy:Kill()
                else
                    enemy:TakeDamage(bal.chargeDamage, 0, EntityRef(npc), 10)
                    local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, enemy.Position, Vector.Zero, enemy)
                    splat.SpriteOffset = Vector(0,-10)
                    splat.Color = enemy.SplatColor
                    splat:Update()
                end
            end
        end
    end
end

function mod:TerrorCellAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = GetTerrorCellTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.WhiteBlood
        npc.StateFrame = mod:RandomInt(bal.chargeCooldown, rng)
        data.Antibodies = 0
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position):Resized(bal.idleSpeed), 0.1)

        local shootTarget = mod:GetPlayerTargetPos(npc)
        npc.StateFrame = npc.StateFrame - 1
        if data.Antibodies > 0 --[[and game:GetRoom():CheckLine(npc.Position, shootTarget, 3)]] then
            mod:FlipSprite(sprite, npc.Position, shootTarget)
            data.State = "Spawn"
        elseif (targetpos:Distance(npc.Position) <= bal.minAttackRange and npc.StateFrame <= 0) or targetpos:Distance(npc.Position) <= bal.attackRange and not mod:isScare(npc) then
            mod:FlipSprite(sprite, npc.Position, targetpos)
            data.State = "ChargeStart"
        end

    elseif data.State == "ChargeStart" then
        npc.Velocity = npc.Velocity * 0.75
        mod:FlipSprite(sprite, npc.Position, targetpos)

        if sprite:IsFinished("ChargeDown") then
            npc.StateFrame = 0
            npc.V1 = (targetpos - npc.Position):Resized(bal.chargeSpeed)
            mod:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_0, npc)
            data.Suffix = (npc.V1.Y < 0) and "Up" or "Down"
            data.State = "Charging"
        else
            mod:SpritePlay(sprite, "ChargeDown")
        end

    elseif data.State == "Charging" then
        mod:SpritePlay(sprite, "ChargeLoop"..data.Suffix)
        DoCharge(npc)

        npc.StateFrame = npc.StateFrame + 1
        if npc.StateFrame > bal.maxChargeDuration or (npc:CollidesWithGrid() and npc.StateFrame > bal.minChargeDuration) then
            data.State = "ChargeStop"
        end

    elseif data.State == "ChargeStop" then
        npc.Velocity = npc.Velocity * 0.33

        if sprite:IsFinished("ChargeEnd"..data.Suffix) then
            npc.StateFrame = mod:RandomInt(bal.chargeCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_SCYTHE_BREAK, npc, 1.5, 0.75)
            mod:PlaySound(SoundEffect.SOUND_STONE_IMPACT, npc, 2, 0.5)
        else
            mod:SpritePlay(sprite, "ChargeEnd"..data.Suffix)
        end

    elseif data.State == "Spawn" then
        npc.Velocity = npc.Velocity * 0.75

        if sprite:IsFinished("Spawn") then
            npc.StateFrame = mod:RandomInt(bal.chargeCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            data.Shooting = true
            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_5, npc, 0.9)
        elseif sprite:IsEventTriggered("Stop") then
            data.Shooting = false
        else
            mod:SpritePlay(sprite, "Spawn")
        end

        if data.Shooting then
            if sprite:GetFrame() % 2 == 0 and data.Antibodies > 0 then
                local shootTarget = mod:GetPlayerTargetPos(npc)
                local proj = npc:FireProjectilesEx(npc.Position, (shootTarget - npc.Position):Resized(bal.projSpeed):Rotated(mod:RandomInt(-bal.projAngleVar, bal.projAngleVar, rng)), 0, params)[1]
                proj:Update()
                data.Antibodies = data.Antibodies - 1
                mod:FlipSprite(sprite, npc.Position, shootTarget)
                mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.2, 0.75)

                for i = 1, 2 do
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, npc.Position, (shootTarget - npc.Position):Resized(bal.projSpeed):Rotated(mod:RandomInt(-bal.projAngleVar, bal.projAngleVar, rng)), npc)
                    effect.SpriteOffset = Vector(0,-15)
                    effect.Color = mod.Colors.WhiteBlood
                    effect:Update()
                end
            end
        end
    end
end

local function CountTerrorCellFood()
    local count = 0
    for _, ent in pairs(GetVirusEnemies()) do
        count = count + (ent:GetData().TerrorCellData and ent:GetData().TerrorCellData.Value or 1)
    end
    return count
end

function mod:TerrorCellPhageSpawning()
    if mod:GetEntityCount(mod.ENT.TerrorCell.ID, mod.ENT.TerrorCell.Var) > 0 and game:GetFrameCount() % bal.phageSpawnInterval == 0 then
        if CountTerrorCellFood() < bal.phageSpawnCap then
            local room = game:GetRoom()
            local phage = Isaac.Spawn(mod.ENT.Phage.ID, mod.ENT.Phage.Var, 0, room:GetCenterPos() + RandomVector():Resized(room:GetBottomRightPos().X - room:GetCenterPos().X + 150), Vector.Zero, nil)
            phage:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            phage.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            phage:GetData().State = "Idle"
            mod:FadeIn(phage, 30)
            phage:Update()
        end
    end
    mod.CurrentVirusEnemies = {}
end

local function GetAntibodyTarget(proj, dist)
    dist = dist or 9999
    local target = Isaac.GetPlayer()
    if not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
        for _, player in pairs(mod:GetAllPlayers()) do
            local newDist = player.Position:Distance(proj.Position)
            if newDist < dist then
                target = player
                dist = newDist
            end
        end
    end
    if proj:HasProjectileFlags(ProjectileFlags.HIT_ENEMIES) then
        for _, enemy in pairs(Isaac.FindInRadius(proj.Position, dist, EntityPartition.ENEMY)) do
            if enemy:IsEnemy() and enemy.EntityCollisionClass > EntityCollisionClass.ENTCOLL_NONE and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
                local newDist = enemy.Position:Distance(proj.Position)
                if newDist < dist then
                    target = enemy
                    dist = newDist
                end
            end
        end
    end
    return target
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, proj)
    proj:GetSprite():Play((mod:RandomInt(2) <= 1) and "MoveReverse" or "Move", true)
end, mod.ENT.AntibodyProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    local scale = 1 + ((proj.Scale - 1) * 0.5)
    proj.SpriteScale = Vector(scale, scale)
    proj.FallingAccel = 0
    proj.FallingSpeed = 0
    proj.Height = -24

    local data = proj:GetData()
    local sprite = proj:GetSprite()
    if data.Stuck then
        proj.Velocity = proj.Velocity * 0.33
        if sprite:IsEventTriggered("Shoot") then
            local target = GetAntibodyTarget(proj)
            local p = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, proj.Position, (target.Position - proj.Position):Resized(bal.projSpeed2), proj.SpawnerEntity):ToProjectile()
            p.ProjectileFlags = proj.ProjectileFlags
            p.CollisionDamage = proj.CollisionDamage
            p.Scale = proj.Scale * 0.66
            p.Color = mod.Colors.WhiteBlood
            proj:Die()
            sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.75)
        end
    else
        if game:GetRoom():GetGridCollisionAtPos(proj.Position) >= GridCollisionClass.COLLISION_SOLID then
            local frame = math.floor(sprite:GetCurrentAnimationData():GetLayer(0):GetFrame(sprite:GetFrame()):GetCrop().X / 32) + 1
            sprite:Play("Stuck"..frame, true)
            mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, nil, 1.2, 0.33)
            data.Stuck = true
        else
            local target = GetAntibodyTarget(proj, 400)
            if target then
                local angleDiff = mod:BoundValue(mod:GetAngleDifference(proj.Velocity, (target.Position - proj.Position)), -bal.projHomingStrength, bal.projHomingStrength)
                proj.Velocity = proj.Velocity:Rotated(-angleDiff):Resized(bal.projSpeed)
            end
        end
    end
end, mod.ENT.AntibodyProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
    if proj.Variant == mod.ENT.AntibodyProjectile.Var then
        proj = proj:ToProjectile()
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, proj.Position, Vector.Zero, proj)
        poof.SpriteScale = proj.SpriteScale
        poof.PositionOffset = proj.PositionOffset
        poof.Color = mod.Colors.WhiteBlood
        poof:Update()
        sfx:Play(SoundEffect.SOUND_TEARIMPACTS)
    end
end, mod.ENT.AntibodyProjectile.ID)