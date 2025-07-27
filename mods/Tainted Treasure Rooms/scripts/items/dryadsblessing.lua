local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

function mod:DryadsBlessingOnFireTear(player, tear)
    if mod:BasicRoll(player.Luck, 9, 1, player:GetCollectibleRNG(TaintedCollectibles.DRYADS_BLESSING)) then
        tear:GetData().TaintedGermination = true
        tear.Color = mod.ColorGerminated
    end
end

function mod:InitGerminatedStatus(npc, data, didstatus, player)
    if didstatus and not npc:GetData().HasGerminatedAura then
        local size = npc.Size
        local num = math.floor(npc.Size / 2)
        if num % 2 == 1 then
            num = num + 1
        end
        local skin01 = true
        local refLeaf

        for i = 360/num, 360, 360/num do
            local leaf = Isaac.Spawn(1000, TaintedEffects.CRYSTAL_LEAF, 0, npc.Position, Vector.Zero, npc)
            if skin01 then
                leaf:GetSprite():Play("Leaf01")
                skin01 = false
            else
                leaf:GetSprite():Play("Leaf02")
                skin01 = true
            end
            local data = leaf:GetData()
            data.Angle = i
            data.TargetRadius = npc.Size * 10
            data.CurrentRadius = 0
            data.RadiusRate = data.TargetRadius / 20
            data.OrbitPos = npc.Position
            leaf.Parent = npc
            if not refLeaf then
                refLeaf = leaf
            end
            --leaf:Update()
        end

        local aura = Isaac.Spawn(1000, TaintedEffects.GERMINATED_AURA, 0, npc.Position, Vector.Zero, npc):ToEffect()
        aura:FollowParent(npc)
        aura.DepthOffset = -1000
        aura.Child = refLeaf
        aura:Update()

        npc:GetData().GerminatedRefLeaf = refLeaf
        npc:GetData().HasGerminatedAura = true
    elseif npc:GetData().HasGerminatedAura then
        for _, leaf in pairs(Isaac.FindByType(1000, TaintedEffects.CRYSTAL_LEAF)) do
            if leaf.Parent and leaf.Parent.InitSeed == npc.InitSeed then
                local ldata = leaf:GetData()
                ldata.TargetRadius = ldata.TargetRadius + (ldata.RadiusRate * 10)
            end
        end
    end
end

function mod:GerminatedEnemyUpdate(npc, data)
    if data.GerminatedRefLeaf then
        for _, player in pairs(Isaac.FindInRadius(npc.Position, (data.GerminatedRefLeaf:GetData().CurrentRadius or 0), EntityPartition.PLAYER)) do
            local pdata = player:GetData()
            pdata.GerminatedStacks = pdata.GerminatedStacks + 1
        end
    end
end

function mod:ResetGerminatedBoosts(player, data)
    data.GerminatedStacks = data.GerminatedStacks or 0
    if data.GerminatedStacks > 0 then
        data.GerminatedStacks = 0
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end

function mod:EvaluateGerminatedBoosts(player, data)
    if data.GerminatedStacks > 0 then
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()
    local data = effect:GetData()
    if effect.Parent and effect.Parent:GetData().TaintedStatus == "Germinated" then
        data.OrbitPos = effect.Parent.Position
        if data.CurrentRadius < data.TargetRadius then
            data.CurrentRadius = data.CurrentRadius + data.RadiusRate
        end
    else
        if data.CurrentRadius > 0 then
            data.CurrentRadius = data.CurrentRadius - (data.RadiusRate * 2)
            if effect.Parent then
                data.OrbitPos = effect.Parent.Position
            end
        else
            if effect.Parent then
                effect.Parent:GetData().HasGerminatedAura = false
            end
            effect:Remove()
        end
    end
    data.Angle = data.Angle + 3
    effect.TargetPosition = data.OrbitPos + Vector(data.CurrentRadius, 0):Rotated(data.Angle)
    effect.Velocity = effect.TargetPosition - effect.Position
    sprite.Rotation = data.Angle + 180
end, TaintedEffects.CRYSTAL_LEAF)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()
    if effect.Child then
        local radius = (effect.Child:GetData().CurrentRadius or 0) / 140
        sprite.Scale = Vector(radius, radius)
    else
        effect:Remove()
    end
end, TaintedEffects.GERMINATED_AURA)