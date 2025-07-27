local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
   idleTime = {20,40},
   maxProjSpeed = 10,
   splitProjSpeed = 10,
   hiddenTime = {10,20},
}

local params = ProjectileParams()
params.Variant = mod.ENT.PillProjectile.Var
params.FallingSpeedModifier = -25
params.FallingAccelModifier = 1.5

local function GetNewPit(npc)
    local room = game:GetRoom()
    local noGoodIndexes = {}
    local goodIndexes = {}
    for _, popper in pairs(Isaac.FindByType(mod.ENT.Popper.ID, mod.ENT.Popper.Var)) do
        noGoodIndexes[room:GetGridIndex(popper.TargetPosition)] = true
    end
    for i = 0, room:GetGridSize() - 1 do
        local grid = room:GetGridEntity(i)
        if grid and grid:GetType() == GridEntityType.GRID_PIT and room:GetGridCollision(i) == GridCollisionClass.COLLISION_PIT and not noGoodIndexes[i] then
            table.insert(goodIndexes, i)
        end
    end
    local index = mod:GetRandomElem(goodIndexes, npc:GetDropRNG())
    if index then
        return room:GetGridPosition(index)
    end
    return npc.Position
end

local function DoSplash(npc)
    local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, npc.Position, Vector.Zero, npc)
    splash.SpriteScale = Vector(0.8,0.8)
    splash:Update()
    mod:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, npc, 1.5, 0.5)
end

local function CheckForWater(npc, instantSplash)
    if mod:HasWaterPits() then
        npc:SetColor(game:GetRoom():GetFXParams().WaterEffectColor, 15, 999, true, true)
        if instantSplash then
            mod:ScheduleForUpdate(function() DoSplash(npc) end, 3)
        else
            npc:GetData().DoSplash = true
        end
    end
end

function mod:PopperAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.MortisBlood
        npc.TargetPosition = npc.Position
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        CheckForWater(npc, true)
        data.State = "Appear"
        data.Init = true
    end

    npc.Position = npc.TargetPosition
    npc.Velocity = Vector.Zero

    if data.State == "Appear" then
        if sprite:IsFinished("Appear") then
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            mod:SpritePlay(sprite, "Idle")
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Coll") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
            if data.DoSplash then
                DoSplash(npc, true)
                data.DoSplash = false
            end
        else
            mod:SpritePlay(sprite, "Appear")
        end

    elseif data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "Shoot"
        end

    elseif data.State == "Shoot" then
        if sprite:IsFinished("Shoot") then
            npc.StateFrame = mod:RandomInt(bal.hiddenTime, rng)
            data.State = "Leave"
        elseif sprite:IsEventTriggered("Shoot") then
            local vec = (targetpos - npc.Position)/26
            vec = vec:Resized(math.min(bal.maxProjSpeed, vec:Length()))
            local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
            proj.Height = -40
            proj:Update()
            mod:PlaySound(SoundEffect.SOUND_PESTILENCE_MAGGOT_POPOUT, npc, 1.25, 0.5)
            mod:PlaySound(SoundEffect.SOUND_THE_STAIN_BURST, npc, mod:RandomInt(90,110,rng) * 0.01, 2.5)
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position, Vector.Zero, npc)
            effect.Color = mod:CloneColor(mod.Colors.WhiteBlood, 0.25)
            effect.DepthOffset = 40
            effect.PositionOffset = npc:GetNullOffset("EffectPos")
            effect:Update()
        else
            mod:SpritePlay(sprite, "Shoot")
        end

    elseif data.State == "Leave" then
        if sprite:IsFinished("Leave") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                npc.TargetPosition = GetNewPit(npc)
                npc.Position = npc.TargetPosition
                npc.Visible = true
                CheckForWater(npc)
                data.State = "Appear"
            else
                npc.Visible = false
            end
        elseif sprite:IsEventTriggered("Coll") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
        else
            mod:SpritePlay(sprite, "Leave")
        end
    end
end

local numColors = 8

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, proj)
    local sprite = proj:GetSprite()
    local data = proj:GetData()
    if proj.SubType ~= 1 then
        local color1, color2 = mod:RandomInt(1,numColors), mod:RandomInt(1,numColors)
        sprite:ReplaceSpritesheet(0, "gfx/enemies/popper/popper_pill_"..color1..".png", true)
        for i = 1, 2 do
            sprite:ReplaceSpritesheet(i, "gfx/enemies/popper/popper_pill_"..color2..".png", true)
        end
        data.PillColors = {color1,color2}
        local frame = mod:RandomInt(0, sprite:GetAnimationData("MoveFrame"):GetLength())
        frame = frame - (frame % 2)
        sprite:SetFrame("MoveFrame", mod:RandomInt(0, frame))
        sprite:PlayOverlay("FlashOverlay", true)
        data.ReverseAnim = (mod:RandomInt(1,2) <= 1)
        data.AnimInterval = 1
        data.SpinFrame = data.AnimInterval
    end
end, mod.ENT.PillProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    local scale = 1 + ((proj.Scale - 1) * 0.5)
    proj.SpriteScale = Vector(scale, scale)
end, mod.ENT.PillProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_RENDER, function(_, proj)
    if mod:IsNormalRender() then
        local sprite = proj:GetSprite()
        local data = proj:GetData()
        mod:SetColorFlash(sprite)
        if sprite:GetAnimation() == "MoveFrame" and data.SpinFrame then
            data.SpinFrame = data.SpinFrame - 1
            if data.SpinFrame <= 0 then
                local frame
                if data.ReverseAnim then
                    frame = sprite:GetFrame() - 2
                    if frame < 0 then
                        frame = sprite:GetAnimationData("MoveFrame"):GetLength() - 1
                    end
                else
                    frame = sprite:GetFrame() + 2
                    if frame > sprite:GetAnimationData("MoveFrame"):GetLength() then
                        frame = 0
                    end
                end
                sprite:SetFrame("MoveFrame", frame)
                data.AnimInterval = data.AnimInterval * 1.2
                if data.AnimInterval >= 7 then
                    data.SpinFrame = nil
                else
                    data.SpinFrame = math.floor(data.AnimInterval)
                end
            end
        end
    end
end, mod.ENT.PillProjectile.Var)

local PillColors = {
    [1] = Color(138/255,161/255,214/255),
    [2] = Color(128/255,195/255,196/255),
    [3] = Color(242/255,159/255,214/255),
    [4] = Color(242/255,201/255,242/255),
    [5] = Color(227/255,146/255,239/255),
    [6] = Color(169/255,215/255,241/255),
    [7] = Color.Default,
    [8] = Color(234/255,226/255,204/255),
}

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
    if proj.Variant == mod.ENT.PillProjectile.Var then
        proj = proj:ToProjectile()
        if proj.SubType ~= 1 then
            local sprite = proj:GetSprite()
            local animData = sprite:GetAnimationData("MoveFrame")
            if animData then
                for i = 0, 1 do
                    local frame = math.floor(animData:GetLayer(i):GetFrame(sprite:GetFrame()):GetCrop().X / 32)
                    local angle = (frame * 45) - 90
                    local p = Isaac.Spawn(mod.ENT.PillProjectile.ID, mod.ENT.PillProjectile.Var, 1, proj.Position, Vector(bal.splitProjSpeed,0):Rotated(angle), proj):ToProjectile()
                    local anim = (mod:RandomInt(2) <= 1) and "MoveSplitReverse" or "MoveSplit"
                    p:GetSprite():Play(anim, true)
                    p:GetSprite():SetFrame((anim == "MoveSplit") and (frame * 2) or (sprite:GetCurrentAnimationData():GetLength() - (frame * 2)) - 1)
                    p:GetSprite():ReplaceSpritesheet(0, proj:GetSprite():GetLayer(i):GetSpritesheetPath(), true)
                    p.ProjectileFlags = proj.ProjectileFlags
                    p.CollisionDamage = proj.CollisionDamage
                    p.Scale = proj.Scale
                    local color = proj:GetData().PillColors[i + 1]
                    p:GetData().PillColor = color
                    p:Update()
                    local impact = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, proj.Position, p.Velocity * 0.5, proj)
                    impact.Color = PillColors[color]
                    impact.PositionOffset = proj.PositionOffset
                    impact.SpriteScale = Vector(0.75,0.75)
                    impact:Update()
                    mod:PlaySound(SoundEffect.SOUND_PESTILENCE_MAGGOT_POPOUT, nil, 2.5, 0.3)
                end
            end
        else
            local impact = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, proj.Position, Vector.Zero, proj)
            impact.Color = PillColors[proj:GetData().PillColor or 0]
            impact.PositionOffset = proj.PositionOffset
            impact.SpriteScale = Vector(0.75,0.75)
            impact:Update()
            mod:PlaySound(SoundEffect.SOUND_POT_BREAK, nil, 4, 0.15)
        end

        for i = 1, 2 do
            local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, proj.Position, RandomVector() * mod:RandomInt(2,4), proj)
            smoke.PositionOffset = proj.PositionOffset
            smoke.Color = Color(1,1,1,0.7,0.8,0.8,0.8)
            smoke.SpriteScale = Vector(0.65,0.65)
            smoke:Update()
        end
    end
end, mod.ENT.PillProjectile.ID)