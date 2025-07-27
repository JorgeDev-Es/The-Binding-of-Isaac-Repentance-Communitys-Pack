local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    shootHPThresh = 0.8,
    gutSpeed = 25,
    projInterval = 50,
    projSpeed = 8,
    swayAmount = 20,
    swayInterval = 60,
    useRework = true,
    projIntervalAlt = 60,
    projSpeedAlt = {4,7},
    projDelay = {0,15},
}

local params = ProjectileParams()
params.Color = mod.Colors.MortisBloodProj
params.HeightModifier = 10
params.FallingAccelModifier = -0.075

local function GetTopsyGutEnd(npc)
    local room = game:GetRoom()
    local vec = Vector(0,40):Rotated(npc.SpriteRotation)
    local samplePos = npc.Position + vec
    local iterLimit = 0
    while iterLimit < 40 do
        local grid = room:GetGridEntityFromPos(samplePos)
        if grid then
            if grid.CollisionClass >= GridCollisionClass.COLLISION_WALL or grid:GetType() == GridEntityType.GRID_ROCKB then
                return samplePos - vec:Resized(20), (grid:GetType() == GridEntityType.GRID_WALL)
            end
        elseif not room:IsPositionInRoom(samplePos, 0) then
            return samplePos - vec:Resized(20), true
        end
        samplePos = samplePos + vec
        iterLimit = iterLimit + 1
    end
end

local function MakeChunk(npc)
    if npc:Exists() and not npc:GetData().Anchored then
        local chunk = Isaac.Spawn(mod.ENT.TopsyChunk.ID, mod.ENT.TopsyChunk.Var, 0, npc.Parent.Position, npc.V1, npc)
        chunk.SpriteRotation = npc.SpriteRotation
        chunk.Parent = npc
        mod:FadeIn(chunk, 3)
        chunk:Update()
    end
end

local function GetChunks(npc)
    local chunks = {}
    for _, chunk in pairs(Isaac.FindByType(mod.ENT.TopsyChunk.ID, mod.ENT.TopsyChunk.Var)) do
        if chunk.Parent and chunk.Parent.InitSeed == npc.InitSeed then
            table.insert(chunks, chunk)
        end
    end
    return chunks
end

function mod:TopsyAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)
    local room = game:GetRoom()

    if not data.Init then
        for i = 90, 360, 90 do
            local index = room:GetGridIndex(npc.Position + Vector.FromAngle(i):Resized(40))
            if index and room:GetGridCollision(index) < GridCollisionClass.COLLISION_WALL and room:IsPositionInRoom(room:GetGridPosition(index), 0) then
                npc.SpriteRotation = (room:GetGridPosition(index) - npc.Position):GetAngleDegrees() - 90
                break
            end
        end
        npc.DepthOffset = -800
        npc.SpriteOffset = Vector(0,10):Rotated(npc.SpriteRotation)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.SplatColor = mod.Colors.MortisBlood
        data.State = "Idle"
        data.Init = true
    end

    npc.Velocity = Vector.Zero

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle01")

        if mod:IsAlignedWithPos(npc.Position, targetpos, 20, nil, 400) or npc.HitPoints <= npc.MaxHitPoints * bal.shootHPThresh then
            data.State = "Shoot"
        end

    elseif data.State == "Shoot" then
        if sprite:IsFinished("Shoot") then
            data.State = "Finished"
        
        elseif sprite:IsEventTriggered("Shoot") then
            local gut = Isaac.Spawn(mod.ENT.TopsyGut.ID, mod.ENT.TopsyGut.Var, 0, npc.Position, Vector.Zero, npc):ToNPC()
            local vec = Vector(0, bal.gutSpeed):Rotated(npc.SpriteRotation)
            gut.TargetPosition, gut:GetData().RenderDirtSprite = GetTopsyGutEnd(npc)
            gut.SpriteRotation = npc.SpriteRotation + 90
            gut.V1 = vec
            gut.Parent = npc
            npc.Child = gut
            gut:Update()
            if not bal.useRework then
                local dist = npc.Position:Distance(gut.TargetPosition)
                for i = 60, dist, 60 do
                    mod:ScheduleForUpdate(function() MakeChunk(gut) end, i / 20)
                end
            end

            mod:PlaySound(SoundEffect.SOUND_WHIP, npc)
        
            npc:BloodExplode()
            for i = 1, 5 do
                local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, npc.Position, Vector(0,mod:RandomInt(4,8,rng)):Rotated(npc.SpriteRotation + mod:RandomInt(-30,30,rng)), npc)
                gib.Color = npc.SplatColor
                gib.SplatColor = npc.SplatColor
            end
        else
            mod:SpritePlay(sprite, "Shoot")
        end

    elseif data.State == "Finished" then
        mod:SpritePlay(sprite, "Idle02")

        if mod:IsReallyDead(npc.Child) then
            npc:Kill()
        end
    end
end

function mod:TopsyGutAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc.SplatColor = mod.Colors.VirusBlue
        npc.DepthOffset = -400
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc.StateFrame = 0
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        data.NumChunks = 0
        data.Init = true
    end

    if mod:IsReallyDead(npc.Parent) then
        npc:Kill()
    else
        local endPos = npc.Parent.Position + npc.V2
        local endDist = npc.Parent.Position:Distance(endPos)
        local yScale = endDist/330
        mod:ScheduleForUpdate(function() sprite.Scale = Vector(1,yScale) end, 0)
        npc.SizeMulti = Vector(yScale * 21,1)
        npc.PositionOffset = -npc.V2/1.8
        sprite.Color = npc.Parent:GetSprite().Color

        if data.Anchored then
            npc.Velocity = npc.Velocity * 0.5
            mod:SpritePlay(sprite, "GutConnected")
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then 
                if bal.useRework then
                    for i = 40, endDist, 40 do
                        mod:ScheduleForUpdate(function()  
                            if not (mod:IsReallyDead(npc) or mod:IsReallyDead(npc.Parent)) then
                                params.Scale = mod:RandomInt(50,150,rng) * 0.01
                                local projPos = npc.Parent.Position + npc.V2:Resized(i + mod:RandomInt(-20,20,rng))
                                local proj = npc.Parent:ToNPC():FireProjectilesEx(projPos, Vector(mod:RandomInt(bal.projSpeedAlt, rng), 0):Rotated(npc.SpriteRotation + (rng:RandomFloat() <= 0.5 and 90 or -90)), 0, params)[1]
                                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, projPos, proj.Velocity * 0.25, npc)
                                splat.Color = mod.Colors.MortisBlood
                                splat.SpriteOffset = Vector.Zero
                                splat.DepthOffset = -40
                                splat:Update()
                                mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc.Parent, mod:RandomInt(50,100,rng) * 0.01, 0.66)
                            end
                        end, mod:RandomInt(bal.projDelay, rng) + (i/16))
                    end
                else
                    for _, chunk in pairs(GetChunks(npc)) do
                        chunk:GetSprite():Play("SegmentShoot", true)
                    end
                end
                npc.StateFrame = (bal.useRework and bal.projIntervalAlt or bal.projInterval)
            end
        else
            mod:SpritePlay(sprite, "Gut")
            npc.V2 = npc.V2 + npc.V1
            npc.Velocity = (npc.Parent.Position + (npc.V2/2)) - npc.Position

            local grid = room:GetGridEntityFromPos(endPos)
            if grid then
                grid:Destroy()
            end

            if endPos:Distance(npc.TargetPosition) <= bal.gutSpeed + 1 then
                for i = 1, 5 do
                    local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, endPos, Vector(0,mod:RandomInt(4,8,rng)):Rotated(npc.SpriteRotation + mod:RandomInt(-30,30,rng) + 90), npc)
                    gib:Update()
                end
                sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
                data.Anchored = true
            end
        end
    end

    if npc:IsDead() then
        local startPos = npc.Position - (npc.V2/2)
        local endPos = npc.Position + (npc.V2/2)
        local dist = startPos:Distance(endPos)
        for i = 30, dist, 30 do
            local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, startPos + npc.V2:Resized(i), Vector.Zero, npc)
            splat.Color = npc.SplatColor
            splat:Update()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()
    local data = effect:GetData()

    if not data.Init then
        effect.SplatColor = mod.Colors.MortisBlood
        if effect.SpriteRotation % 180 == 90 then
            effect.SpriteOffset = Vector(0,-18)
        end
        mod:SpritePlay(sprite, "Segment")
        data.State = "Idle"
        data.Init = true
    end

    if mod:IsReallyDead(effect.Parent) or mod:IsReallyDead(effect.Parent.Parent) then
        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, effect.Position, Vector.Zero, effect)
        splat.Color = effect.SplatColor
        splat.SpriteOffset = effect.SpriteOffset
        splat:Update()
        effect:Remove()
    else
        sprite.Color = effect.Parent:GetSprite().Color

        if sprite:IsEventTriggered("Shoot") then
            for i = 0, 180, 180 do
                effect.Parent:ToNPC():FireProjectiles(effect.Position, Vector(bal.projSpeed,0):Rotated(i + effect.SpriteRotation + 90), 0, params)
                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, effect.Position, Vector.Zero, effect)
                splat.Color = effect.SplatColor
                splat.SpriteOffset = effect.SpriteOffset
                splat.DepthOffset = -40
                splat:Update()
                mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, effect.Parent)
            end
        end

        if effect.Parent:GetData().Anchored then
            if data.SwayOrigin then
                local val = mod:Sway(bal.swayAmount, -bal.swayAmount, bal.swayInterval, 2.2, 2.2, data.SwayFrame)
                effect.TargetPosition = data.SwayOrigin + Vector(0,val):Rotated(effect.SpriteRotation + 90)
                effect.Velocity = effect.TargetPosition - effect.Position
                data.SwayFrame = data.SwayFrame + data.SwayIncrement
            else
                effect.Velocity = effect.Velocity * 0.3
                if effect.Velocity:Length() <= 0.1 then
                    data.SwayFrame = math.floor(bal.swayInterval/3.5)
                    data.SwayIncrement = mod:RandomInt(50,150) * 0.01
                    data.SwayOrigin = effect.Position
                end
            end
        end
    end
end, mod.ENT.TopsyChunk.Var)

local dirtSprite = Sprite()
dirtSprite:Load("gfx/enemies/topsy/topsy_gut.anm2", true)
dirtSprite:Play("Dirt", true)

function mod:TopsyGutRender(npc, sprite, data)
    if not mod:IsReallyDead(npc.Parent) then
        npc.Parent:GetSprite():RenderLayer(0, Isaac.WorldToScreen(npc.Parent.Position))
        if data.Anchored and data.RenderDirtSprite then
            dirtSprite.Rotation = npc.SpriteRotation
            dirtSprite.Color = mod.MortisDirtColor
            dirtSprite:Render(Isaac.WorldToScreen(npc.Position + (npc.V2/2)))
        end
    end
end

function mod:TopsyGutHurt(npc, sprite, data, amount, damageFlags, source)
    if not mod:IsReallyDead(npc.Parent) then
        npc.Parent:TakeDamage(amount, damageFlags, source, 0)
    end
    return false
end