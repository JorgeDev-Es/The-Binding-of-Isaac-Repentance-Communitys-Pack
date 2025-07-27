local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

local bal = {
    idleTime = {10,20},
    hopSpeed = 8,
    hopsBeforeSummon = {5,6},
    summonCap = 3,
    breakThresh = 0.2,
    keyBaseDamage = 9,
    keyPlayerDamageScaling = 2,
    keySpeed = 13,
    keySpawnDelay = 60,
}

function mod:ChastityAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local isSuper = (npc.Variant == mod.ENT.SuperChastity.Var)

    if not data.Init then
        local rag = Isaac.Spawn(mod.ENT.ChastityRag.ID, mod.ENT.ChastityRag.Var, 0, npc.Position, Vector.Zero, npc):ToEffect()
        rag.TargetPosition = npc.Position + Vector(5,0)
        rag.Parent = npc
        if isSuper then
            rag:GetSprite():Load("gfx/bosses/virtues/chastity/miniboss_superchastity.anm2", true)
        end
        rag:Update()
        data.Rag = rag
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
        npc.I1 = mod:RandomInt(bal.hopsBeforeSummon, rng) - 2
        npc.I2 = bal.keySpawnDelay
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")
        npc.Velocity = npc.Velocity * 0.7
        
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if npc.I1 <= 0 then
                if mod:GetEntityCount(EntityType.ENTITY_BABY, isSuper and 3 or 1, isSuper and 0 or 1) >= bal.summonCap then
                    npc.I1 = 4
                else
                    data.State = "Summon"
                end
            else
                data.State = "Hop"
            end
        end

    elseif data.State == "Hop" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Hop") then
            npc.I1 = npc.I1 - 1
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Move") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
            npc.Velocity = RandomVector() * bal.hopSpeed
            data.Rag:GetSprite():Play("RagStretch", true)
        elseif sprite:IsEventTriggered("Stop") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_LAND, npc)
            npc.Velocity = npc.Velocity * 0.7
            if isSuper then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc):Update()
            end
        else
            mod:SpritePlay(sprite, "Hop")
        end

    elseif data.State == "Summon" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Summon") then
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            npc.I1 = mod:RandomInt(bal.hopsBeforeSummon, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            for i = -40, 40, 80 do
                Isaac.Spawn(EntityType.ENTITY_BABY, isSuper and 3 or 1, isSuper and 0 or 1, npc.Position + Vector(i,0), Vector.Zero, npc):Update()
            end
            mod:PlaySound(SoundEffect.SOUND_SUMMONSOUND, npc)
        else
            mod:SpritePlay(sprite, "Summon")
        end

    elseif data.State == "Break" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Break") then
            for i = 1, 3 do
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc):Update()
            end
            local rags = Isaac.Spawn(mod.ENT.ChastityRagPile.ID, mod.ENT.ChastityRagPile.Var, 0, npc.Position, Vector.Zero, npc)
            if isSuper then
                rags:GetSprite():Load("gfx/bosses/virtues/chastity/miniboss_superchastity.anm2", true)
            end
            rags:Update()
            data.Rag:Remove()
            npc:BloodExplode()
            npc:Morph(EntityType.ENTITY_LUST, isSuper and 1 or 0, 0, npc:GetChampionColorIdx())
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        elseif sprite:IsEventTriggered("Shoot") then
            npc:BloodExplode()
            sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        else
            mod:SpritePlay(sprite, "Break")
        end
    end

    if mod:GetEntityCount(mod.ENT.ChastityKey.ID, mod.ENT.ChastityKey.Var) <= 0 and not (npc:IsDead() or data.State == "Break") then
        npc.I2 = npc.I2 - 1
        if npc.I2 <= 0 then
            local spawnSpot = mod:FindSafeSpawnSpot(npc.Position, nil, nil, true, 100, 100, true)
            Isaac.Spawn(mod.ENT.ChastityKey.ID, mod.ENT.ChastityKey.Var, 0, spawnSpot, Vector.Zero, npc)
            npc.I2 = bal.keySpawnDelay
        end
    end
end

function mod:ChastityHurt(npc, sprite, data, amount, flags, source)
    if source.Type == EntityType.ENTITY_TEAR and (source.Variant == TearVariant.KEY or source.Variant == TearVariant.KEY_BLOOD or (source.Entity and source.Entity:GetData().ChastityKey))
    and data.State ~= "Break" then
        if npc.HitPoints - amount <= npc.MaxHitPoints * bal.breakThresh then
            for i = 1, 5 do
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CHAIN_GIB, 0, npc.Position, RandomVector() * mod:RandomInt(4,10), npc)
            end
            npc:BloodExplode()
            sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK, 1.25)
            npc.HitPoints = npc.MaxHitPoints * bal.breakThresh
            data.State = "Break"
            return false
        end
    else
        return false
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect.FrameCount <= 0 then
        effect.DepthOffset = -120
        effect:GetSprite():SetFrame("RagIdle", 0)
    end

    if mod:IsReallyDead(effect.Parent) then
        effect:Remove()
    else
        effect.Velocity = (effect.Parent.Position + effect.Parent:GetNullOffset("RagPos")) - effect.Position
        if effect.TargetPosition:Distance(effect.Parent.Position) > 10 then
            effect.TargetPosition = effect.TargetPosition + (effect.Parent.Position - effect.TargetPosition)/10
        end
        effect.SpriteRotation = (effect.TargetPosition - effect.Parent.Position):GetAngleDegrees()
    end
end, mod.ENT.ChastityRag.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    effect:GetSprite():SetFrame("DeathRags", 0)
    effect:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
end, mod.ENT.ChastityRagPile.Var)

--The key to victory
local function ThrowChastityKey(player, vel)
    local key = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.GRIDENT, 0, player.Position, vel, player):ToTear()
    key.CollisionDamage = bal.keyBaseDamage + (math.max(player.Damage, 3.5) * bal.keyPlayerDamageScaling)
    key:GetSprite():Load("gfx/002.043_key tear.anm2", true)
    key:GetSprite():Play("Idle", true)
    key:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/virtues/chastity/fallenkey_tears.png", true)
    key:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_ACID)
    key:GetData().ChastityKey = true
    key:Update()
    player:PlayExtraAnimation("HideItem")
    player:GetData().HoldingChastityKey = false
    return key
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup, collider)
    local sprite = pickup:GetSprite()

    if sprite:IsEventTriggered("Sound1") then
        mod:PlaySound(SoundEffect.SOUND_KEY_DROP0, nil, mod:RandomInt(60,70) * 0.01, 0.65)
    elseif sprite:IsEventTriggered("Sound2") then
        mod:PlaySound(SoundEffect.SOUND_KEY_DROP0, nil, mod:RandomInt(80,90) * 0.01, 0.5)
    end
end, mod.ENT.ChastityKey.Var)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, function(_, pickup, collider)
    if collider:ToPlayer() then
        local player = collider:ToPlayer()
        if player:IsExtraAnimationFinished() then
            local sprite = pickup:GetSprite()
            sprite:SetFrame("Held", 0)
            player:AnimatePickup(pickup:GetSprite(), true, "LiftItem")
            player:GetData().HoldingChastityKey = true
            pickup:Remove()
            mod:PlaySound(SoundEffect.SOUND_KEYPICKUP_GAUNTLET, nil, 0.8, 0.5)
        end
    end
end, mod.ENT.ChastityKey.Var)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if player:GetData().HoldingChastityKey then
        local aim = player:GetAimDirection()
        if aim:Length() > 0.1 then
            ThrowChastityKey(player, aim:Resized(bal.keySpeed) + player:GetTearMovementInheritance(aim))
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player)
    if player:GetData().HoldingChastityKey then
        ThrowChastityKey(player:ToPlayer(), RandomVector() * 4)
    end
end, EntityType.ENTITY_PLAYER)

function mod:ChastityKeyCleanup()
    for _, player in pairs(mod:GetAllPlayers()) do
        if player:GetData().HoldingChastityKey then
            player:PlayExtraAnimation("HideItem")
            player:GetData().HoldingChastityKey = false
        end
    end
    for _, key in pairs(Isaac.FindByType(mod.ENT.ChastityKey.ID, mod.ENT.ChastityKey.Var)) do
        key.Visible = false
        key:Remove()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
    if tear:GetData().ChastityKey then
        tear.SpriteRotation = tear.Velocity:GetAngleDegrees()
    end
end, TearVariant.GRIDENT)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, tear)
    if tear:GetData().ChastityKey then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 20, tear.Position, Vector.Zero, tear)
        poof.PositionOffset = tear.PositionOffset
        poof.SpriteRotation = tear.SpriteRotation
        poof.Color = tear.Color
        poof:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/virtues/chastity/fallenkey_poof.png", true)
        poof:Update()
        poof.SpriteRotation = tear.SpriteRotation
        for i = 1, 3 do
            local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.NAIL_PARTICLE, 0, tear.Position, RandomVector() * mod:RandomInt(3,7), tear)
            gib.Color = tear.Color
            gib:Update()
        end
        mod:PlaySound(SoundEffect.SOUND_POT_BREAK, nil, 3, 0.3)
        for _, grid in pairs(mod:GetGridsInRadius(tear.Position, 40)) do
            if grid:GetType() == GridEntityType.GRID_LOCK and grid.State == 0 then
                local gsprite = grid:GetSprite()
                local didbreak
                if gsprite:GetAnimation() == "Idle" then
                    gsprite:Play("Breaking", true)
                    didbreak = true
                elseif gsprite:GetAnimation() == "IdleCoin" then
                    gsprite:Play("BreakingCoin", true)
                    didbreak = true
                end
                if didbreak then
                    grid.State = 1
                    gsprite:ReplaceSpritesheet(1, "blank.png")
                    gsprite:SetFrame(10)
                    gsprite:LoadGraphics()
                    sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK)
                end
            end
        end
    end
end, EntityType.ENTITY_TEAR)

mod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.LATE, function(_, tear, collider)
    if tear:GetData().ChastityKey and collider:ToNPC() and not mod:isFriend(collider) then
        if collider.Type == mod.ENT.Chastity.ID and (collider.Variant == mod.ENT.Chastity.Var or collider.Variant == mod.ENT.SuperChastity.Var) then
            collider:TakeDamage(tear.CollisionDamage, 0, EntityRef(tear), 0)
            tear:Die()
        end
    end
end, TearVariant.GRIDENT)

--Patch Wrinkly Babies to not get stuck on Locks/Pillars
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 3 then
        if npc.State == 7 and npc:CollidesWithGrid() then
            npc.State = 8
            npc:GetSprite():Play("Attack", true)
        end
    end
end, EntityType.ENTITY_BABY)