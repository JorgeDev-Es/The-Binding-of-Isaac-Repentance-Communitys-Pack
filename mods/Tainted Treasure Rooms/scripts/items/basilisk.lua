local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local function AttachBasiliskCord(familiar)
    local player = familiar.Player 
    local cord = Isaac.Spawn(TaintedNPCs.BASILISK_CORD.ID, TaintedNPCs.BASILISK_CORD.Var, TaintedNPCs.BASILISK_CORD.Sub, familiar.Position, Vector.Zero, familiar)
    cord:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    cord.Parent = familiar
    cord.Target = player
    cord.TargetPosition = Vector.One
    cord.DepthOffset = -20
    familiar.Child = cord
end

function mod:GetFamiliarTarget(pos, radius, ignoreOptional)
    radius = radius or 9999
    local target 
    local enemies = Isaac.FindInRadius(pos, radius, EntityPartition.ENEMY)
    for _, enemy in pairs(enemies) do
        local distance = enemy.Position:Distance(pos)
        if enemy:IsActiveEnemy() 
        and (ignoreOptional == nil or enemy:CanShutDoors())
        and distance < radius 
        and not (enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)
        or enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            radius = distance
            target = enemy
        end
    end
	return target
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
    familiar:GetSprite():Play("Walk01")
    familiar:GetData().DamageMult = 1.5
    familiar.State = 1
end, TaintedFamiliars.BASILISK)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    local data = familiar:GetData()
    local sprite = familiar:GetSprite()
    local player = familiar.Player
    local rng = familiar.Player:GetCollectibleRNG(TaintedCollectibles.BASILISK)
    
    if not (familiar.Child or data.Unchained) then
        AttachBasiliskCord(familiar)
    end

    local vec = player.Position - familiar.Position
    local target
    if data.Unchained then
        target = mod:GetFamiliarTarget(familiar.Position, 400, true)
    else
        target = mod:GetFamiliarTarget(player.Position, 200, true)
    end
    if target then
        local targetpos = target.Position + Vector(0,1)
        if familiar.FrameCount % 10 == 0 and mod:RandomInt(1,4,rng) == 1 then
            local chargelength = math.min(30, math.max(20, familiar.Position:Distance(targetpos)))
            familiar.Velocity = mod:Lerp(familiar.Velocity, (targetpos - familiar.Position):Resized(chargelength):Rotated(mod:RandomInt(-10,10,rng)), 0.5)
            data.DamageMult = 2.5
            if not data.Unchained then
                player.Velocity = mod:Lerp(player.Velocity, familiar.Velocity, 0.25)
            end
        else
            familiar.Velocity = mod:Lerp(familiar.Velocity, (targetpos - familiar.Position):Resized(8), 0.05)
        end
    
        if player.Position:Distance(familiar.Position) > 150 and not data.Unchained then
            player.Velocity = mod:Lerp(player.Velocity, vec / -40, 0.1)
            familiar.Velocity = mod:Lerp(familiar.Velocity, vec / 30, 0.1)
        end
    
        if sprite:IsPlaying("Walk01") then
            sprite:Play("Rage")
        end
        mod:FlipSprite(sprite, familiar.Position, targetpos)
    else
        familiar.Velocity = mod:Lerp(familiar.Velocity, Vector.Zero, 0.1)

        if player.Position:Distance(familiar.Position) > 100 then
            familiar.Velocity = mod:Lerp(familiar.Velocity, vec / 10, 0.1)
        end

        if sprite:IsPlaying("Walk02") then
            sprite:Play("RageEnd")
        end
        mod:FlipSprite(sprite, familiar.Position, familiar.Position + familiar.Velocity)
    end

    if data.DamageMult > 1.5 then
        data.DamageMult = data.DamageMult - 0.1
    else
        data.DamageMult = 1.5
    end
    familiar.CollisionDamage = math.max(3.5, player.Damage) * data.DamageMult

    if sprite:IsFinished("Rage") then
        sprite:Play("Walk02")
    elseif sprite:IsFinished("RageEnd") then
        sprite:Play("Walk01")
    end
end, TaintedFamiliars.BASILISK)

function mod:BasiliskOnPlayerHit(familiar, player)
    local data = familiar:GetData()
    if not data.Unchained then
        local rng = player:GetCollectibleRNG(TaintedCollectibles.BASILISK)
        local roll = (rng:RandomFloat() <= 0.33 * familiar.State)
        if roll then
            sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
            familiar.Child:Kill()
            data.Unchained = true
        else
            familiar.State = familiar.State + 1
        end
    end
end

function mod:BasiliskNewRoom(familiar)
    familiar:GetData().Unchained = false
    familiar.State = 1
end