local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local function AttachEvangelismHalo(parent, scale, player)
    scale = scale or 1
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.EVANGELISM_HALO, 0, parent.Position, Vector.Zero, parent):ToEffect()
    effect.SpriteScale = Vector(scale, scale)
    effect:FollowParent(parent)
    effect.DepthOffset = -500
    effect:GetData().TaintedPlayerRef = player
	parent:GetData().TaintedEvangelismHalo = effect
    effect:Update()
    return effect
end

local function IncrementEvangelism(enemy, data, player)
    if data.EvangelismStrength then
        data.EvangelismStrength = data.EvangelismStrength + 0.04
        data.EvangelismTimer = 90

        if data.EvangelismStrength >= 1 then
            local spawner = player
            if not (player and player:Exists()) then
                spawner = Isaac.GetPlayer()
            end
        
            local beam = Isaac.Spawn(1000, EffectVariant.CRACK_THE_SKY, 1, enemy.Position, Vector.Zero, spawner)
            beam.Parent = spawner
            beam.CollisionDamage = spawner.Damage * 5
            beam:Update()

            sfx:Play(SoundEffect.SOUND_DOGMA_LIGHT_RAY_FIRE, 0.3)
            data.EvangelismStrength = 0
        end
    end
end

function mod:GetEnemiesInRadius(position, radius, ignoreNoTarget)
    local goodenemies = {}
    local enemies = Isaac.FindInRadius(position, radius * 2, EntityPartition.ENEMY)
    for _, enemy in pairs(enemies) do
        if enemy:IsEnemy() and enemy.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_PLAYEROBJECTS 
        and enemy.Position:Distance(position) < radius + enemy.Size 
        and not (ignoreNoTarget and enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
            table.insert(goodenemies, enemy:ToNPC())
        end
    end
    return goodenemies
end

mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
    if npc.Variant == TaintedNPCs.DOGMA_RENDERER.Var then
        local data = npc:GetData()
        if not data.Init then
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | 
            EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_HIDE_HP_BAR)
            data.ParentOffset = Vector.Zero
            data.Init = true
        end
        if npc.Parent and npc.Parent:Exists() then
            npc.Velocity = npc.Parent.Position + data.ParentOffset - npc.Position
            if data.EnforceSubtype then
                if npc.Parent.SubType ~= data.EnforceSubtype then
                    npc.Parent:GetData().StaticInit = false
                    npc:Remove()
                end
            end
        else
            npc:Remove()
        end
        return true
    end
end, TaintedNPCs.DOGMA_RENDERER.ID)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()
    local data = effect:GetData()
    if effect.Parent and effect.Parent:Exists() then
        mod:spritePlay(sprite, "Idle")
        if effect.Parent:ToTear() then
            local tear = effect.Parent:ToTear()
            effect.SpriteScale = Vector(tear.Scale / 1.5, tear.Scale / 1.5)  
        end

        for _, enemy in pairs(mod:GetEnemiesInRadius(effect.Position, effect.SpriteScale.X * 80, true)) do
            IncrementEvangelism(enemy, enemy:GetData(), data.TaintedPlayerRef)
        end
    else
        effect.Velocity = Vector.Zero
        if sprite:IsFinished("Disappear") then
            effect:Remove()
        else
            mod:spritePlay(sprite, "Disappear")
        end
    end
end, TaintedEffects.EVANGELISM_HALO)

function mod:EvangelismEnemyUpdate(npc, data)
    data.EvangelismStrength = data.EvangelismStrength or 0
    data.EvangelismTimer = data.EvangelismTimer or 90

    if data.EvangelismStrength > 0 then
        data.EvangelismTimer = data.EvangelismTimer - 1 
        if data.EvangelismTimer <= 0 then
            data.EvangelismStrength = data.EvangelismStrength - 0.05
        end
    
        local color = Color(1,1,1,1,data.EvangelismStrength,data.EvangelismStrength,data.EvangelismStrength)
        npc:SetColor(color, 2, 2, false, true)
    end
end

function mod:EvangelismOnFireTear(player, tear)
    AttachEvangelismHalo(tear, tear.Scale / 1.5, player)
end

function mod:EvangelismOnFireBomb(player, bomb)
    AttachEvangelismHalo(bomb, bomb.RadiusMultiplier, player)
end

function mod:EvangelismKnifeUpdate(knife, data, player)
    if player:HasCollectible(TaintedCollectibles.EVANGELISM) then
        if not (data.EvangelismAura and data.EvangelismAura:Exists()) then
            data.EvangelismAura = AttachEvangelismHalo(knife, knife.Scale, player)
        end
    elseif data.EvangelismAura then
        data.EvangelismAura.Parent = nil
        data.EvangelismAura = nil
    end
end

function mod:EvangelismOnHitIncrementing(player, enemy)
    IncrementEvangelism(enemy, enemy:GetData(), player)
end