local mod = LastJudgement
local game = Game()

local balance = {
    StickInDist = 30,
    StickInSOffsetD = 30,
    StickInSOffsetU = 5,
    StickInSpawn = 20,
    RecoilSpeed = 14,

    GrowTime = 11, --per each stage, 4 times
    GrowFinal = 35, --time before final pustule pops
    ShotSpeed = 10, --these are for v shot
    ShotSpread = 33,
    ShotSize = 1.2,
    ShotSpeed2 = {75,225}, --these for straight volley
    ShotSpread2 = 8,
    ShotNum = 6,
    ShotAccel = 1.2,
    ShotFall = {60,140},
    ShotSize2 = {45,80},
}

local function CheckChargeCollision(npc)
	local room = game:GetRoom()
    if npc:CollidesWithGrid() then
        local isGrid
        local hitGrid
        for i=-npc.Size,npc.Size,npc.Size do
            local grid = room:GetGridEntityFromPos(npc.Position+npc.V1:Resized(npc.Size+10))
            if grid and ((grid.CollisionClass > GridCollisionClass.COLLISION_SOLID or grid:GetType() == GridEntityType.GRID_DOOR) and grid:GetType() ~= GridEntityType.GRID_PILLAR) then
                isGrid = true
                hitGrid = grid
            end
        end
        return {isGrid, hitGrid}
    end
end

local function VecToDir(vec, npc)
    local dir
    local flip = npc.FlipX
    local offset = Vector.Zero
    if math.abs(vec.X) > math.abs(vec.Y) then
        if vec.X > 0 then
            flip = false
        else
            flip = true
        end
        dir = "Hori"
    else
        if vec.Y > 0 then
            dir = "Down"
            --offset = offset+Vector(0, balance.StickInSOffsetD)
        else
            dir = "Up"
            --offset = offset+Vector(0, balance.StickInSOffsetU)
        end
    end
    return dir, flip, offset
end

function mod:VaxAI(npc)
    local sprite = npc:GetSprite()
    local rng = npc:GetDropRNG()
    local d = npc:GetData()

    if not d.init then
        mod:ScheduleForUpdate(function()
            sprite:GetLayer("dirty"):SetColor(mod.MortisDirtColor)
        end, 0)
        npc.SplatColor = mod.Colors.MortisBlood
        
        d.init = true
    end

    if npc.State == NpcState.STATE_ATTACK or d.ChargingVax then
        if not d.ChargingVax then
            d.ChargingVax = true
            d.VaxDir = npc.V1
        end
        local charge = CheckChargeCollision(npc)
        if charge and charge[1] then
            npc.State = NpcState.STATE_ATTACK2
            d.VaxGrid = charge[2]
            d.VaxStuck = true
            local offset = Vector.Zero
            d.VaxString, d.VaxFlip, offset = VecToDir(d.VaxDir, npc)
            d.VaxPos = charge[2].Position-d.VaxDir:Resized(balance.StickInDist)
            npc:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.6, 0, false, mod:RandomInt(105,115,rng)/100)
            npc:PlaySound(SoundEffect.SOUND_GOOATTACH0, 0.6, 0, false, mod:RandomInt(105,115,rng)/100)
            npc.PositionOffset = offset --thank you for setting spriteoffset every frame
            d.ChargingVax = nil
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            local poof = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 1, npc.Position+d.VaxDir:Resized(balance.StickInSpawn + 8), Vector.Zero, npc):ToEffect()
            poof.SpriteOffset = Vector(0, -10)
            poof.PositionOffset = npc.PositionOffset
            poof.Color = mod.Colors.MortisBlood
            poof.DepthOffset = 40
            poof:Update()
        end
        if npc:CollidesWithGrid() and d.ChargingVax then
            d.ChargingVax = nil
        end
    end

    if npc.State == NpcState.STATE_ATTACK2 then
        if d.VaxStuck then
            npc.Velocity = d.VaxPos-npc.Position
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
            npc.PositionOffset = mod:Lerp(npc.PositionOffset, Vector.Zero, 0.1)
        end

        if sprite:IsFinished("Stick" .. d.VaxString) then
            npc.State = NpcState.STATE_MOVE
            npc.PositionOffset = Vector.Zero
        elseif sprite:IsEventTriggered("Pull") then
            d.VaxStuck = false
            npc.Velocity = d.VaxDir:Resized(-balance.RecoilSpeed)
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)

            for i=1,rng:RandomInt(2)+1 do
                local speed = d.VaxDir:Resized(mod:RandomInt(15,45,rng)/10):Rotated(180+mod:RandomInt(-45,45,rng))
                local gib = Isaac.Spawn(1000, EffectVariant.BLOOD_PARTICLE, 0, npc.Position+d.VaxDir:Resized(balance.StickInSpawn), speed, npc):ToEffect()
                gib:Update()
                mod:ScheduleForUpdate(function()
                    gib:SetColor(mod.Colors.MortisBlood, 999, 10, false, false)
                end, 1)
            end
            local poof = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 744, npc.Position+d.VaxDir:Resized(balance.StickInSpawn), Vector.Zero, npc)
            poof.Color = mod.Colors.MortisBlood
            poof.SpriteScale = Vector(0.6, 0.6)
            poof.SpriteOffset = Vector(0, -10)

            local pos = npc.Position
            if math.abs(d.VaxDir.X) > math.abs(d.VaxDir.Y) then
                pos = Vector(d.VaxGrid.Position.X, npc.Position.Y-15*npc.SpriteScale.Y)
            else
                pos = Vector(npc.Position.X, d.VaxGrid.Position.Y)
            end
            local pustule = Isaac.Spawn(mod.ENT.VaxPustule.ID, mod.ENT.VaxPustule.Var, mod.ENT.VaxPustule.Sub, pos, Vector.Zero, npc):ToNPC()
            pustule:GetSprite().Rotation = d.VaxDir:GetAngleDegrees()-90
            pustule:GetData().dir = d.VaxDir:Resized(-1)
            pustule:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        else
            mod:SpritePlay(sprite, "Stick" .. d.VaxString)
        end
    end
end

function mod:VaxPustuleAI(npc)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local rng = npc:GetDropRNG()
    local d = npc:GetData()

    if not d.init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_REWARD)
        npc.SplatColor = mod.Colors.VirusBlue
        d.initPos = npc.Position
        d.state = "idle"
        npc.I1 = 0
        if not d.dir then d.dir = Vector.Zero end
        d.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    local offset = sprite:GetNullFrame("stuckpos"):GetPos():Rotated(sprite.Rotation-180)
    npc.Velocity = (d.initPos+offset)-npc.Position

    if d.state == "idle" then
        if npc.I1 < 5 then
            if npc.StateFrame > balance.GrowTime then
                d.state = "grow"
            end
        else
            if npc.StateFrame > balance.GrowFinal then
                d.state = "pop"
            end
        end
        mod:SpritePlay(sprite, "Idle" .. npc.I1)
    elseif d.state == "grow" then
        if sprite:IsFinished("Transition" .. npc.I1) then
            npc.I1 = npc.I1+1

            npc.Size = npc.Size+3
            d.state = "idle"
        else
            mod:SpritePlay(sprite, "Transition" .. npc.I1)
        end
    elseif d.state == "pop" then
        if sprite:IsFinished("Burst") then
            local params = ProjectileParams()
            params.Color = mod.Colors.VirusBlue
            --[[params.Scale = balance.ShotSize
            for i=-1,1,2 do
                npc:FireProjectiles(npc.Position, d.dir:Resized(balance.ShotSpeed):Rotated(i*balance.ShotSpread), ProjectileMode.SINGLE, params)
            end]]
            --[[params.FallingAccelModifier = balance.ShotAccel
            for i=1,balance.ShotNum do
                params.Scale = mod:RandomInt(balance.ShotSize2[1], balance.ShotSize2[2], rng)/100
                params.FallingSpeedModifier = -mod:RandomInt(balance.ShotFall[1], balance.ShotFall[2], rng)/10
                npc:FireProjectiles(npc.Position, d.dir:Resized(mod:RandomInt(balance.ShotSpeed2[1], balance.ShotSpeed2[2], rng)/10):Rotated(mod:RandomInt(-balance.ShotSpread2, balance.ShotSpread2, rng)), ProjectileMode.SINGLE, params)
            end]]

            for i=0,3 do
                npc:FireProjectiles(npc.Position+d.dir:Resized(15), d.dir:Resized(balance.ShotSpeed):Rotated(-90+60*i), ProjectileMode.SINGLE, params)
            end
            --[[local poof = Isaac.Spawn(1000, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc):ToEffect()
            poof.Color = mod.Colors.MortisBlood
            poof.SpriteScale = Vector(0.5, 0.5)]]
            npc:PlaySound(SoundEffect.SOUND_PESTILENCE_HEAD_EXPLODE, 0.6, 0, false, mod:RandomInt(180,210,rng)/100)
            npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 0.9, 0, false, mod:RandomInt(90,110,rng)/100)
            npc:Die()
        else
            mod:SpritePlay(sprite, "Burst")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
    if e.SubType == mod.ENT.Embolism.ID then
        if e:GetSprite():IsFinished() then
            e:Remove()
        end
    end
end, EffectVariant.BLOOD_EXPLOSION)