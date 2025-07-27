local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local mrMawBal = {
    moveSpeed = 4,
    attackCooldown = {60,90},
    attackRange = 150,
    headSpeed = 24,
    triSpread = 30,
}

local mawBal = {
    moveSpeed = 2,
    attackCooldown = {20,30},
    attackRange = 350,
    projSpeed = 10,
    headSpeed = 24,
}

local params = ProjectileParams()

local numNecks = 7
local neckDipFactors = {
    [1] = 0,
    [2] = 0.33,
    [3] = 0.75,
    [4] = 1,
    [5] = 0.75,
    [6] = 0.33,
    [7] = 0,
}

local function TryShootHead(npc, vec, soundPitch)
    soundPitch = soundPitch or 1
    local data = npc:GetData()
    if data.NumHeads > 0 then
        local head = Isaac.Spawn(mod.ENT.TaintedMaw.ID, mod.ENT.TaintedMaw.Var, 0, npc.Position, vec, npc)
        head:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        head:GetData().State = "Launched"
        head.Parent = npc
        head.HitPoints = head.MaxHitPoints * data.HeadHealth[data.NumHeads]
        head:Update()

        data.NumHeads = data.NumHeads - 1
        mod:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT, npc, soundPitch)

        for i = 1, numNecks do
            local neck = Isaac.Spawn(mod.ENT.TaintedMawNeck.ID, mod.ENT.TaintedMawNeck.Var, 0, npc.Position, vec, npc)
            neck:GetData().NeckIndex = i
            neck.Parent = npc
            neck.Child = head
        end

        return head
    end
end

function mod:TaintedMrMawAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)
    local bal = mrMawBal

    if not data.Init then
        npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
        data.State = "Idle"
        data.HeadHealth = {}
        data.NumHeads = 3
        for i = 1, data.NumHeads do
            data.HeadHealth[i] = 1
        end
        data.Init = true
    end

    mod:QuickSetEntityGridPath(npc)
    mod:SetDeform(sprite)

    if data.State == "Idle" then
        mod:ChasePlayer(npc, bal.moveSpeed, 0.3)
        mod:AnimWalkFrame(npc, sprite, "WalkHori"..data.NumHeads, "WalkVert"..data.NumHeads, true)

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 and data.NumHeads >= 0 and targetpos:Distance(npc.Position) <= bal.attackRange then
            if data.DidNormalShoot and data.NumHeads >= 3 then
                data.DidNormalShoot = false
                data.State = "TriShoot"
            else
                data.NumRounds = data.NumHeads
                data.DidNormalShoot = true
                data.State = "Shoot"
            end
        end

    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.5
        sprite:SetFrame("WalkVert"..data.NumHeads, 0)

        if sprite:IsOverlayFinished("Shoot") then
            data.NumRounds = data.NumRounds - 1
            if data.NumRounds <= 0 or data.NumHeads <= 0 then
                data.State = "Retrieval"
            else
                sprite:PlayOverlay("Shoot", true)
            end
        elseif sprite:IsOverlayEventTriggered("Shoot") then
            TryShootHead(npc, (targetpos - npc.Position):Resized(bal.headSpeed))
        else
            mod:SpriteOverlayPlay(sprite, "Shoot")
        end

    elseif data.State == "TriShoot" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("TriShoot") then
            data.State = "Retrieval"
        elseif sprite:IsEventTriggered("Shoot") then
            for i = -bal.triSpread, bal.triSpread, bal.triSpread do
                TryShootHead(npc, (targetpos - npc.Position):Resized(bal.headSpeed):Rotated(i), 0.8)
            end
        else
            mod:SpritePlay(sprite, "TriShoot")
        end

    elseif data.State == "Retrieval" then
        npc.Velocity = npc.Velocity * 0.5
        sprite:SetFrame("WalkVert"..data.NumHeads, 0)

        local shouldResume = true
        for _, maw in pairs(Isaac.FindByType(mod.ENT.TaintedMaw.ID, mod.ENT.TaintedMaw.Var)) do
            if maw.Parent and maw.Parent.InitSeed == npc.InitSeed then
                shouldResume = false
            end
        end
        if shouldResume then
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
            data.State = "Idle"
        end
    end

    if npc.FrameCount % 60 == 30 and data.NumHeads > 0 then
        mod:PlaySound(SoundEffect.SOUND_ZOMBIE_WALKER_KID, npc, 0.8)
    end

    if npc:IsDead() then
        for i = 1, data.NumHeads do
            local head = Isaac.Spawn(mod.ENT.TaintedMaw.ID, mod.ENT.TaintedMaw.Var, 0, npc.Position, RandomVector() * (bal.headSpeed/2), npc)
            head:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            head.HitPoints = head.MaxHitPoints * data.HeadHealth[data.NumHeads]
            head:Update()
        end
    end
end

function mod:TaintedMawAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)
    local bal = mawBal

    if not data.Init then
        npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
        data.State = data.State or "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(bal.moveSpeed)), 0.1)

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 and npc.Position:Distance(targetpos) <= bal.attackRange and game:GetRoom():CheckLine(npc.Position, targetpos, 3) then
            data.State = "Shoot"
        end

    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.95

        if sprite:IsFinished("Shoot") then
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            for i = 3, 1, -1 do
                params.Scale = (i + 1) * 0.5
                local proj = npc:FireProjectilesEx(npc.Position, (targetpos - npc.Position):Resized((bal.projSpeed/3) * i), 0, params)[1]
                proj.FallingAccel = 0
            end
            mod:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc, 0.9)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position + npc:GetNullOffset("EffectPos"), Vector.Zero, npc):ToEffect()
            effect:FollowParent(npc)
            effect.Color = Color(1,1,1,0.75)
            effect.DepthOffset = 40
            effect:Update()
        else
            mod:SpritePlay(sprite, "Shoot")
        end

    elseif data.State == "Launched" then
        mod:SpritePlay(sprite, "Head")
        if mod:IsReallyDead(npc.Parent) then
            npc.Parent = nil
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "Head")
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Parent.Position - npc.Position):Resized(bal.headSpeed), 0.04)
            if npc.FrameCount > 5 and npc.Position:Distance(npc.Parent.Position) <= npc.Parent.Size + npc.Size then
                local pdata = npc.Parent:GetData()
                local psprite = npc.Parent:GetSprite()
                pdata.NumHeads = pdata.NumHeads + 1
                pdata.HeadHealth[pdata.NumHeads] = mod:GetHealthPercent(npc)
                if pdata.State == "Retrieval" then
                    psprite:PlayOverlay("Return", true)
                    psprite:SetFrame("WalkVert"..pdata.NumHeads, 0)
                elseif pdata.State == "Shoot" then
                    psprite:SetFrame("WalkVert"..pdata.NumHeads, 0)
                end
                for _, neck in pairs(Isaac.FindByType(mod.ENT.TaintedMawNeck.ID, mod.ENT.TaintedMawNeck.Var)) do
                    if neck.Child and neck.Child.InitSeed == npc.InitSeed then
                        neck:Remove()
                    end
                end
                mod:PlaySound(SoundEffect.SOUND_SCAMPER, npc)
                npc:Remove()
            end
        end
    end
end

function mod:TaintedMawColl(npc, sprite, data, collider)
    if data.State == "Launched" and collider:ToNPC() then
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local data = effect:GetData()

    if not data.Init then
        effect:GetSprite():Play("Neck", true)
        data.Init = true
    end

    if mod:IsReallyDead(effect.Child) or mod:IsReallyDead(effect.Parent) then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, effect.Position, Vector.Zero, effect)
        poof.PositionOffset = effect.PositionOffset
        poof:Update()
        effect:Remove()
    else
        local span = effect.Child.Position - effect.Parent.Position
        local pos = effect.Parent.Position + ((span / numNecks) * (data.NeckIndex - 0.5))
        effect.Velocity = pos - effect.Position
        local dipMult = math.max(0, math.min(1 - (span:Length()/200), 1))
        effect.PositionOffset = Vector(0,-14 + ((20 * neckDipFactors[data.NeckIndex]) * dipMult))
    end
end, mod.ENT.TaintedMawNeck.Var)