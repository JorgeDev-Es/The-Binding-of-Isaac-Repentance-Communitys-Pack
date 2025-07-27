local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local canaryBal = {
    moveSpeed = 5,
    attackCooldown = 20,
    laserDuration = 8,
}

local foreignerBal = {
    moveSpeed = 5,
    attackCooldown = 30,
    laserDuration = 60,
    rockHeatRate = 10,
    coalSpeed = {5,9},
    coalHeight = {30,50},
}

--Fixes bug where lasers cut off short at the bottom wall of the room (can be seen with vanilla entities also lol)
function mod:FixLaserBug(endPos, angle)
    if not game:GetRoom():IsPositionInRoom(endPos + Vector(10,0):Rotated(angle), 0) then
        return endPos + Vector(20,0):Rotated(angle)
    end
    return endPos
end

function mod:GetLaserEndPoint(pos, angle, targetPos)
    targetPos = targetPos or pos + Vector.FromAngle(angle):Resized(1000)
    local _, endPos = game:GetRoom():CheckLine(pos, targetPos, LineCheckMode.PROJECTILE)
    return mod:FixLaserBug(endPos, angle)
end

function mod:GetLaserEndPointFromLaser(laser, targetPos)
    return mod:GetLaserEndPoint(laser.Position, laser.Angle, targetPos)
end

--when someone says something so bulborbphobic
function mod:CanaryAI(npc, sprite, data)
    local targetpos = mod:GetPlayerTargetPos(npc)
    local isForeigner = (npc.Variant == mod.ENT.Foreigner.Var)
    local bal = isForeigner and foreignerBal or canaryBal

    if not data.Init then
        npc.StateFrame = bal.attackCooldown
        data.State = "Idle"
        data.Init = true
    end

    mod:QuickSetEntityGridPath(npc)

    if data.State == "Idle" then
        mod:WanderGridAligned(npc, data, bal.moveSpeed, 0.3, 8)
        mod:AnimWalkFrame(npc, sprite, {"WalkRight", "WalkLeft"}, {"WalkDown", "WalkUp"})

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 and mod:IsAlignedWithPos(npc.Position, targetpos, 20, not isForeigner and 3 or false, 300, -npc.Velocity) then
            data.State = "Shoot"
            data.ShootVec = mod:SnapVector((targetpos - npc.Position), 90)
            data.Suffix = mod:GetMoveString(data.ShootVec)
            npc.StateFrame = bal.attackCooldown
        end

        if npc.FrameCount % 30 == 15 and npc:GetDropRNG():RandomFloat() <= 0.33 then
            mod:PlaySound(SoundEffect.SOUND_ANGRY_GURGLE, npc)
        end

    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("Attack"..data.Suffix) then
            if isForeigner then
                npc.StateFrame = bal.laserDuration
                mod:SpritePlay(sprite, "Attack"..data.Suffix.."Loop")
                data.State = "ShootLoop"
            else
                data.State = "Idle"
            end
        elseif sprite:IsEventTriggered("Sound") then
            if isForeigner then
                mod:PlaySound(SoundEffect.SOUND_LIGHTBOLT_CHARGE, npc, 2.5, 3)
            else
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_VERYSMALL, 0, npc.Position, Vector.Zero, npc)
                effect.PositionOffset = npc:GetNullOffset("LaserPos")
                if not (data.Suffix == "Up" or data.Suffix == "Right") then
                    effect.DepthOffset = 20
                else
                    effect.DepthOffset = -20
                end
                effect.Color = Color(1,0,0,1,1)
                effect:Update()
                mod:PlaySound(SoundEffect.SOUND_BATTERYCHARGE, npc, 2, 0.75)
            end
        elseif sprite:IsEventTriggered("Shoot") then
            local laser = Isaac.Spawn(EntityType.ENTITY_LASER, isForeigner and LaserVariant.THICK_RED or LaserVariant.THIN_RED, 0, npc.Position, Vector.Zero, npc):ToLaser()
            laser.Parent = npc
            laser.Angle = data.ShootVec:GetAngleDegrees()
            laser.Timeout = bal.laserDuration
            laser.PositionOffset = npc:GetNullOffset("LaserPos")
            laser:SetMaxDistance(laser.Position:Distance(mod:GetLaserEndPointFromLaser(laser)))
            if data.Suffix ~= "Up" and (data.Suffix ~= "Right" or isForeigner) then
                laser.DepthOffset = 20
            else
                laser.DepthOffset = -20
            end
            if isForeigner then
                mod:ScheduleForUpdate(function() sfx:Stop(SoundEffect.SOUND_BLOOD_LASER) end, 0, ModCallbacks.MC_POST_RENDER)
                sfx:Play(mod.Sounds.HotBrimstone, 0.75)
                laser.CollisionDamage = 3
                laser.Size = 10
                laser:GetSprite():Load("gfx/effects/effect_hotbrimstone.anm2", true)
                laser:GetSprite():Play("HotLaser", true)
                laser:GetData().HotBrimstone = true
            else
                if not mod:isFriend(npc) then
                    laser.CollisionDamage = 0
                end
                laser.OneHit = true
            end
            laser:Update()
            laser:Update()
        else
            mod:SpritePlay(sprite, "Attack"..data.Suffix)
        end

    elseif data.State == "ShootLoop" then
        npc.Velocity = npc.Velocity * 0.5
        mod:SpritePlay(sprite, "Attack"..data.Suffix.."Loop")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "ShootEnd"
        end

    elseif data.State == "ShootEnd" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("Attack"..data.Suffix.."End") then
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "Attack"..data.Suffix.."End")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect.FrameCount <= 0 then
        if effect.SpawnerEntity and effect.SpawnerEntity:GetData().HotBrimstone then
            local sprite = effect:GetSprite()
            sprite:Load("gfx/effects/effect_hotbrimstone_impact.anm2")
            sprite:Play("Start", true)
        end
    end
end, EffectVariant.LASER_IMPACT)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect.FrameCount <= 0 and effect.SubType == 1 then
        for _, laser in pairs(Isaac.FindByType(EntityType.ENTITY_LASER, LaserVariant.THICK_RED)) do
            if laser:GetData().HotBrimstone then --This is a shit method but they dont set SpawnerEntity lollll
                effect.Color = mod.Colors.FireyFade
                break
            end
        end
    end
end, EffectVariant.WATER_SPLASH)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
    local data = laser:GetData()

    if data.HotBrimstone then
        laser.Size = 10
        laser:SetMaxDistance(laser.Position:Distance(mod:GetLaserEndPointFromLaser(laser)))
        if laser.Timeout > 0 then
            local room = game:GetRoom()
            for _, grid in pairs(mod:GetGridsInRadius(laser.Position + Vector.FromAngle(laser.Angle):Resized(laser.MaxDistance + 20), 30)) do
                if grid:ToRock() and grid.State ~= 2 then
                    local index = grid:GetGridIndex()
                    local heatRate = foreignerBal.rockHeatRate
                    if not mod.HotRocks[index] then
                        mod.HotRocks[index] = {
                            Heat = 0,
                            IsFriendly = mod:isFriend(laser.Parent)
                        }
                    end
                    mod.HotRocks[index].Heat = mod.HotRocks[index].Heat + (100/heatRate)
                elseif laser.FrameCount % 2 == 0 then
                    grid:Hurt(1)
                end
            end
        end
    end
end)

local function GetRockColor(heat)
    return Color(1, 1, 1 - (heat/100), 1, heat/120, heat/240, 0)
end

function mod:HotRocksUpdate()
    for index, data in pairs(mod.HotRocks) do
        local grid = game:GetRoom():GetGridEntity(index)
        if grid:ToRock() and grid.CollisionClass >= GridCollisionClass.COLLISION_SOLID then
            if data.Heat > 100 then
                grid:GetSprite().Color = Color.Default
                if grid:Destroy() then
                    for i = 1, 3 do
                        local coal = Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 11, 0, grid.Position, RandomVector() * mod:RandomInt(foreignerBal.coalSpeed), nil):ToNPC()
                        coal.State = 16
                        coal.PositionOffset = Vector(0, -mod:RandomInt(foreignerBal.coalHeight))
                        coal.SplatColor = mod.Colors.FireyFade
                        if data.IsFriendly then
                            coal:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
                        end
                        coal:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        coal:Update()
                    end
                    data.Heat = 0
                else
                    data.Heat = 100
                    grid:GetSprite().Color = GetRockColor(data.Heat)
                end
            elseif data.Heat > 0 then
                grid:GetSprite().Color = GetRockColor(data.Heat)
                data.Heat = data.Heat - 1
            end
        end
    end
end

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, function(_, npc, amount, dmgFlags, source, cooldown)
    if mod:HasDamageFlag(dmgFlags, DamageFlag.DAMAGE_LASER) and source.Type == mod.ENT.Foreigner.ID and source.Variant == mod.ENT.Foreigner.Var and not mod:HasDamageFlag(dmgFlags, DamageFlag.DAMAGE_FIRE) then
        npc:TakeDamage(amount, dmgFlags | DamageFlag.DAMAGE_FIRE, source, cooldown)
        return false
    end
end)