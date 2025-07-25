local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.CLSpoonBender, "{{Collectible"..CollectibleType.COLLECTIBLE_SPOON_BENDER .."}} Strong homing tears#Homing tears will have infinite range for as long as they are attracted to an enemy#When being attracted by two enemies at once, a tear will split into two x0.66 damage tears that will home in on both enemies separately")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_SPOON_BENDER, 'using {{Card' .. Card.CARD_HUGE_GROWTH .. "}} {{ColorYellow}}Huge Growth{{CR}}", true)

    -- Synergies
    mod.addSynergyDescription(MattPack.Items.CLSpoonBender, 
    CollectibleType.COLLECTIBLE_TECH_X, 
    "Tech rings will home in on and orbit enemies")
end

local homingColor = Color(.4, .15, .38, 1.5)
homingColor:SetOffset(.275, 0, .45)

function mod:clsbTearInit(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if (player and player:HasCollectible(MattPack.Items.CLSpoonBender)) then
        tear:GetData().CLSpoonBenderTear = true
        tear:ClearTearFlags(TearFlags.TEAR_HOMING)
        tear:ClearTearFlags(TearFlags.TEAR_TURN_HORIZONTAL)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mod.clsbTearInit)

function mod:clsbLaserInit(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if (player and player:HasCollectible(MattPack.Items.CLSpoonBender)) then
        if tear:IsCircleLaser() then
            tear:GetData().CLSpoonBenderTear = true
        end
        tear:SetHomingType(2)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.clsbLaserInit)

function mod:clsbHoming(tear) 
    if tear:Exists() and tear:IsDead() == false and tear.FrameCount > 0 then
        local player = tear.SpawnerEntity and (tear.SpawnerEntity:ToPlayer())
        local tearData = tear:GetData()
        if tearData.CLSpoonBenderTear or ((player and player:HasCollectible(MattPack.Items.CLSpoonBender))) then
            if not player then
                player = (tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player)
            end
            if tearData.homingTargets and tear.FrameCount > 8 then
                tearData.homingTargets = nil
            end
            local homingTargets = (tearData.homingTargets or Isaac.GetRoomEntities())
            local forces = {}
            local room = game:GetRoom()
            for _,ent in ipairs(homingTargets) do
                local npc = ent:ToNPC()
                if npc and npc:IsVulnerableEnemy() and (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false) and (tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) or room:CheckLine(ent.Position, tear.Position, 3)) then
                    local lineToNPC = npc.Position - tear.Position
                    local startDist = 150
                    local ratio = math.max(0, (1 - lineToNPC:Length() / startDist))
                    ratio = ratio / (math.max((tearData.gigaSpoonSplits or 0) / 1.5, 1)) -- Smaller tears home less strongly
                    
                    if ratio < .95 then
                        local origVel = tear.Velocity
                        tear.Velocity = Lerp(tear.Velocity, lineToNPC:Resized(tear.Velocity:Length()), ratio):Resized(tear.Velocity:Length() * (1 + (.1 * ratio)))
                        table.insert(forces, {npc, tear.Velocity - origVel})
                        if ratio > 0 then
                            tear.FallingSpeed = -.1
                        end
                    end
                end
            end
            if player and ((tearData.gigaSpoonSplits or 0) < 3) and #forces > 1 then
                local maxForce = {}
                for _,forceTable1 in ipairs(forces) do
                    local force1 = forceTable1[2]
                    for _,forceTable2 in ipairs(forces) do
                        local force2 = forceTable2[2]
                        if (not maxForce[2]) or maxForce[2] < force1:Distance(force2) then
                            maxForce = {{force1, force2}, force1:Distance(force2), {forceTable1[1], forceTable2[1]}}
                        end
                    end
                end
                if #maxForce > 0 then
                    if maxForce[2] > 5 and tear.FrameCount > 2 then
                        sfx:Play(SoundEffect.SOUND_SPLATTER, 1)
                        sfx:Play(SoundEffect.SOUND_SPLATTER, .5, 0, false, 1.25)
                        sfx:Play(SoundEffect.SOUND_BISHOP_HIT, .75, 0, false, 1.5)
                        for i, force in ipairs(maxForce[1]) do
                            local tear2 = Isaac.Spawn(tear.Type, tear.Variant, tear.SubType, tear.Position, force:Resized(math.max(5, tear.Velocity:Length() * (2/3))), tear):ToTear()
                            local tear2Data = tear2:GetData()
                            for ind,val in pairs(tearData) do
                                tear2Data[ind] = val
                            end
                            tear2.Color = tear.Color
                            tear2.TearFlags = tear.TearFlags
                            if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
                                tear2:ClearTearFlags(TearFlags.TEAR_LUDOVICO)
                                tear2:AddTearFlags(TearFlags.TEAR_OCCULT)
                            end
                            tear2.Position = tear.Position
                            tear2.SpawnerEntity = tear.SpawnerEntity
                            tear2Data.homingTargets = {maxForce[3][i]}
                            tear2.CollisionDamage = tear.CollisionDamage * (2/3)
                            tear2.Scale = tear.Scale * (2/3)
                            tear2.KnockbackMultiplier = tear.KnockbackMultiplier * (2/3)
                            tear2.FallingSpeed = -.85
                            tear2.Height = tear.Height
                            tear2Data.gigaSpoonSplits = (tearData.gigaSpoonSplits or 0) + 1
                            for i = 0, math.random(3,6) do
                                local particle = Isaac.Spawn(1000, 66, 0, tear.Position + tear.PositionOffset, (Lerp(tear.Velocity, tear2.Velocity, ((math.random(0, 100) / 100) + 1) / 2):Resized(math.random(2, 15))), nil)
                                particle.Color = tear.Color
                            end
                        end
                        tear:Remove()          
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.clsbHoming)

function mod:clsbBombInit(tear)
    if tear:Exists() and tear:IsDead() == false and tear.FrameCount > 0 then
        local player = tear.SpawnerEntity and (tear.SpawnerEntity:ToPlayer())
        local tearData = tear:GetData()
        if tearData.CLSpoonBenderTear or ((player and player:HasCollectible(MattPack.Items.CLSpoonBender))) then
            tear:ClearTearFlags(TearFlags.TEAR_HOMING)
            tear:ClearTearFlags(TearFlags.TEAR_TURN_HORIZONTAL)
            if not player then
                player = (tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player)
            end
            if tearData.homingTargets and tear.FrameCount > 8 then
                tearData.homingTargets = nil
            end
            local homingTargets = (tearData.homingTargets or Isaac.GetRoomEntities())
            local forces = {}
            local room = game:GetRoom()
            for _,ent in ipairs(homingTargets) do
                local npc = ent:ToNPC()
                if npc and npc:IsVulnerableEnemy() and (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false) and (tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) or room:CheckLine(ent.Position, tear.Position, 3)) then
                    local lineToNPC = npc.Position - tear.Position
                    local startDist = 150
                    local ratio = math.max(0, (1 - lineToNPC:Length() / startDist))
    
                    if ratio < .95 then
                        local origVel = tear.Velocity
                        tear.Velocity = Lerp(tear.Velocity, lineToNPC:Resized(tear.Velocity:Length()), ratio):Resized(tear.Velocity:Length() * (1 + (.1 * ratio)))
                        table.insert(forces, {npc, tear.Velocity - origVel})
                    end
                end
            end
            if player and ((tearData.gigaSpoonSplits or 0) <= 3) and #forces > 1 then
                
                local maxForce = {}
                for _,forceTable1 in ipairs(forces) do
                    local force1 = forceTable1[2]
                    for _,forceTable2 in ipairs(forces) do
                        local force2 = forceTable2[2]
                        if (not maxForce[2]) or maxForce[2] < force1:Distance(force2) then
                            maxForce = {{force1, force2}, force1:Distance(force2), {forceTable1[1], forceTable2[1]}}
                        end
                    end
                end
                if #maxForce > 0 then
                    if maxForce[2] > 7.5 and tear.FrameCount > 2 then
                        sfx:Play(SoundEffect.SOUND_SPLATTER, 1)
                        sfx:Play(SoundEffect.SOUND_SPLATTER, .5, 0, false, 1.25)
                        sfx:Play(SoundEffect.SOUND_BISHOP_HIT, .75, 0, false, 1.5)
                        for i, force in ipairs(maxForce[1]) do
                            local tear2 = Isaac.Spawn(tear.Type, tear.Variant, tear.SubType, tear.Position, force:Resized(math.max(5, tear.Velocity:Length() * (2/3))), tear):ToBomb()
                            local tear2Data = tear2:GetData()
                            for ind,val in pairs(tearData) do
                                tear2Data[ind] = val
                            end
                            tear2.Color = tear.Color
                            tear2.Flags = tear.Flags
                            tear2.Position = tear.Position
                            tear2.SpawnerEntity = tear.SpawnerEntity
                            tear2Data.homingTargets = {maxForce[3][i]}
                            tear2Data.CLSpoonBenderTear = true
                            tear2.ExplosionDamage = tear.ExplosionDamage * (2/3)
                            tear2.RadiusMultiplier = tear.RadiusMultiplier * (2/3)
                            tear2:SetScale(tear:GetScale() * (2/3))
                            tear2Data.gigaSpoonSplits = (tearData.gigaSpoonSplits or 0) + 1
                            for i = 0, math.random(3,6) do
                                local particle = Isaac.Spawn(1000, 66, 0, tear.Position + tear.PositionOffset, (Lerp(tear.Velocity, tear2.Velocity, ((math.random(0, 100) / 100) + 1) / 2):Resized(math.random(2, 15))), nil)
                                particle.Color = tear.Color
                            end
                        end
                        tear:Remove()          
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.clsbBombInit)

function mod:clsbLaserUpdate(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    local tearData = tear:GetData()
    if tearData.CLSpoonBenderTear or (player and player:HasCollectible(MattPack.Items.CLSpoonBender)) then
        local homingTargets = Isaac.GetRoomEntities()
        local room = game:GetRoom()
        
        for _,ent in ipairs(homingTargets) do
            local npc = ent:ToNPC()
            if npc and npc:IsVulnerableEnemy() and (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false) and (tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) or room:CheckLine(ent.Position, tear.Position, 3)) then
                local spaceDistance = tear.Radius + tear.Size
                local targetPos = npc.Position + (tear.Position - npc.Position):Resized(spaceDistance)
                local lineToNPC = targetPos - tear.Position
                local startDist = 250 * (tear.Size / 5)
                local ratio = math.max(0, (1 - lineToNPC:Length() / startDist)) / 4
                
                tear.Velocity = Lerp(tear.Velocity, lineToNPC:Resized(tear.Velocity:Length()), ratio * (tearData.homingStrength or 1)):Resized(tear.Velocity:Length())
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_UPDATE, mod.clsbLaserUpdate)

function mod:clsbTearColor(player)
    if player:HasCollectible(MattPack.Items.CLSpoonBender) then
        player.TearColor = homingColor
        player.LaserColor = homingColor
        player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING | TearFlags.TEAR_TURN_HORIZONTAL
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.clsbTearColor, CacheFlag.CACHE_TEARCOLOR)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.clsbTearColor, CacheFlag.CACHE_TEARFLAG)


function mod:clSpoonBenderUnlock()
    local clsb = Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_SPOON_BENDER) or {}
    for _,pedestal in ipairs(clsb) do
        local data = pedestal:GetData()
        data.q5TargetScale = .75
        data.q5TargetOffset = Vector(0, .1)

        local pos = pedestal.Position + Vector(0, -42.5)
        local targetFunc = function()
            sfx:Play(SoundEffect.SOUND_SPLATTER, 1.5, 0, false, 1.25)
            sfx:Play(SoundEffect.SOUND_BISHOP_HIT, 3.5, 0, false, .25)
            for i = 0, 25 do
                local particle = Isaac.Spawn(1000, 66, 0, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
                particle.Color = homingColor
            end
        end
        mod.switchItem(pedestal, MattPack.Items.CLSpoonBender, function()
            sfx:Play(128, 2, nil, nil, .3)
            sfx:Play(SoundEffect.SOUND_INFLATE, 1, nil, nil, .45) 
        end, targetFunc)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.clSpoonBenderUnlock, Card.CARD_HUGE_GROWTH)