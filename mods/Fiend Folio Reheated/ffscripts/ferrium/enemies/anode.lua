local mod = FiendFolio
local game = Game()

local function anodeFindPartners(npc, data, table2, rng, mode)
    mode = mode or 0

    if mode == 1 then
        for _, anode in ipairs(table2) do
            local aData = anode:GetData()
            local new = true
            for _,check in pairs(data.relationshipStatus) do
                if anode.InitSeed == check.InitSeed then
                    new = false
                end
            end

            if new then
                table.insert(data.relationshipStatus, anode)
                if aData.state == "Idle" then
                    aData.state = "elecStart"
                    aData.laserMode = "enemy"
                    if aData.poly then
                        aData.relationshipStatus = {npc}
                        aData.checkForConnections = true
                    else
                        aData.significantOther = npc
                    end
                else
                    aData.relationshipStatus = aData.relationshipStatus or {}
                    table.insert(aData.relationshipStatus, npc)
                end

                local beam = Isaac.Spawn(mod.FF.AnodeBeam.ID, mod.FF.AnodeBeam.Var, mod.FF.AnodeBeam.Sub, anode.Position, Vector.Zero, npc):ToEffect()
                beam.Parent = npc
                beam.Target = (anode:GetData().laserDummyEffect or anode)
                beam.Color = Color(0.8, 0, 0, 1, 0, 0, 0)
            end
            if data.state ~= "elecStart" then
                data.tracerCheck = true
            end
        end
    elseif #table2 > 0 then
        if data.poly then
            data.relationshipStatus = {}
            for _, anode in ipairs(table2) do
                local aData = anode:GetData()
                table.insert(data.relationshipStatus, anode)
                if aData.state == "Idle" then
                    aData.state = "elecStart"
                    aData.laserMode = "enemy"
                    if aData.poly then
                        aData.relationshipStatus = {npc}
                        aData.checkForConnections = true
                    else
                        aData.significantOther = npc
                    end
                else
                    aData.relationshipStatus = aData.relationshipStatus or {}
                    table.insert(aData.relationshipStatus, npc)
                end

                local beam = Isaac.Spawn(mod.FF.AnodeBeam.ID, mod.FF.AnodeBeam.Var, mod.FF.AnodeBeam.Sub, anode.Position, Vector.Zero, npc):ToEffect()
                beam.Parent = npc
                beam.Target = (anode:GetData().laserDummyEffect or anode)
                beam.Color = Color(0.8, 0, 0, 1, 0, 0, 0)
            end
        else
            data.significantOther = table2[rng:RandomInt(#table2)+1]
            local aData = data.significantOther:GetData()

            if aData.state == "Idle" then
                aData.state = "elecStart"
                aData.laserMode = "enemy"
                if aData.poly then
                    aData.relationshipStatus = {npc}
                    aData.checkForConnections = true
                else
                    aData.significantOther = npc
                end
            else
                aData.relationshipStatus = aData.relationshipStatus or {}
                table.insert(aData.relationshipStatus, npc)
            end
            local beam = Isaac.Spawn(mod.FF.AnodeBeam.ID, mod.FF.AnodeBeam.Var, mod.FF.AnodeBeam.Sub, data.significantOther.Position, Vector.Zero, npc):ToEffect()
            beam.Parent = npc
            beam.Target = (data.significantOther:GetData().laserDummyEffect or data.significantOther)
            beam.Color = Color(0.8, 0, 0, 1, 0, 0, 0)
        end
        data.state = "elecStart"
        data.laserMode = "enemy"
    end
end

function mod:anodeAI(npc)
    local sprite = npc:GetSprite()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local data = npc:GetData()
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()


    if not data.init then
        data.state = "Idle"

        if (npc.SubType >> 3 & 3) == 1 then
            data.iknowwhatyouare = true
        elseif (npc.SubType >> 3 & 3) == 2 then
            data.onlyinterestedinthese = true
        end
        if (npc.SubType >> 5 & 1) == 1 then
            data.thisisyourspot = npc.Position
        end
        if (npc.SubType >> 6 & 1) == 1 then
            data.poly = true
        end
        data.anodeGroup = npc.SubType & 7
        data.targetedAnodeGroup = (npc.SubType >> 7) & 7

        data.movement = rng:RandomInt(5)+5

        data.laserDummyEffect = mod:AddDummyEffect(npc, Vector(0,-30*npc.SpriteScale.Y))

        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    local anodes = {}
    local totalAnodes = {}
    for _,anode in ipairs(Isaac.FindByType(mod.FF.Anode.ID, mod.FF.Anode.Var, -1, false, true)) do
        if room:CheckLine(npc.Position, anode.Position, 3) then
            local aData = anode:GetData()
            if (aData.state == "Idle" or (aData.poly and aData.state ~= "elecEnd")) and not mod:isCharm(anode) and npc.InitSeed ~= anode.InitSeed then
                table.insert(anodes, anode)
            end
        end
        if npc.InitSeed ~= anode.InitSeed then
            table.insert(totalAnodes, anode)
        end
    end

    if data.state == "Idle" then
        if npc.Velocity:Length() > 0.3 then
            if npc.Velocity.X > 0 then
                sprite.FlipX = false
            else
                sprite.FlipX = true
            end

            mod:spritePlay(sprite, "Walk")
        else
            mod:spritePlay(sprite, "Idle")
        end

        local check = false
        if npc.StateFrame > 35 and rng:RandomInt(30) == 0 then
            check = true
        elseif npc.StateFrame > 70 then
            check = true
        end
        if check then
            if mod:isFriend(npc) then
                local playerTab = {}
                for i = 1, game:GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)

                    if room:CheckLine(npc.Position, player.Position, 3) then
                        table.insert(playerTab, player)
                    end
                end

                if #playerTab > 0 then
                    data.significantOther = playerTab[rng:RandomInt(#playerTab)+1] --not actually in love sorry
                    data.state = "elecStart"
                    data.laserMode = "friend"
                end
            elseif not mod:isCharm(npc) and not mod:isScareOrConfuse(npc) then
                if data.iknowwhatyouare then
                    local exclusiveClub = {}
                    for _,anode in ipairs(anodes) do
                        local aData = anode:GetData()
                        local distCheck = true
                        if anode.Position:Distance(npc.Position) < 70 and not data.poly then
                            distCheck = false
                        end
                        if aData.onlyinterestedinthese and npc.SubType & 7 == anode.SubType & 7 and npc.SubType & 7 == aData.targetedAnodeGroup and distCheck then
                            table.insert(exclusiveClub, anode)
                        elseif anode.SubType & 7 == data.anodeGroup and distCheck then
                            table.insert(exclusiveClub, anode)
                        end
                    end

                    anodeFindPartners(npc, data, exclusiveClub, rng)
                elseif data.onlyinterestedinthese then
                    local possiblepartners = {}
                    for _,anode in ipairs(anodes) do
                        local aData = anode:GetData()
                        local distCheck = true
                        if anode.Position:Distance(npc.Position) < 70 and not data.poly then
                            distCheck = false
                        end
                        if aData.iknowwhatyouare and npc.SubType & 7 == anode.SubType & 7 and anode.SubType & 7 == data.targetedAnodeGroup and distCheck then
                            table.insert(possiblepartners, anode)
                        elseif aData.onlyinterestedinthese and (npc.SubType & 7 == aData.targetedAnodeGroup or anode.SubType & 7 == data.targetedAnodeGroup) and distCheck then
                            table.insert(possiblepartners, anode)
                        elseif anode.SubType & 7 == data.targetedAnodeGroup and distCheck and not aData.iknowwhatyouare then
                            table.insert(possiblepartners, anode)
                        end
                    end

                    anodeFindPartners(npc, data, possiblepartners, rng)
                else
                    local willing = {}
                    for _,anode in ipairs(anodes) do
                        local aData = anode:GetData()
                        local distCheck = true
                        if anode.Position:Distance(npc.Position) < 70 and not data.poly then
                            distCheck = false
                        end
                        if aData.iknowwhatyouare and anode.SubType & 7 == npc.SubType & 7 and distCheck then
                            table.insert(willing, anode)
                        elseif aData.onlyinterestedinthese and aData.targetedAnodeGroup == npc.SubType & 7 and distCheck then
                            table.insert(willing, anode)
                        elseif not aData.iknowwhatyouare and distCheck then
                            table.insert(willing, anode)
                        end
                    end

                    anodeFindPartners(npc, data, willing, rng)
                end
            end
        end

        if data.thisisyourspot then
            if npc.Position:Distance(data.thisisyourspot) > 10 then
                if room:CheckLine(npc.Position, data.thisisyourspot, 0, 1, false, false) then
                    local targetvel = (data.thisisyourspot - npc.Position):Resized(5.5)
                    npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
                else
                    npc.Pathfinder:FindGridPath(data.thisisyourspot, 0.7, 900, true)
                end
            else
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
            end
        elseif mod:isScare(npc) then
            local targetvel = (targetpos - npc.Position):Resized(-7)
            npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
        else
            if data.movement > 0 then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
                data.movement = data.movement-1
            elseif not data.goHere then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
                local ALLALONE = true
                for _,anode in ipairs(totalAnodes) do
                    if data.iknowwhatyouare then
                        local aData = anode:GetData()
                        if aData.onlyinterestedinthese and aData.targetedAnodeGroup == npc.SubType & 7 and anode.SubType & 7 == npc.SubType & 7 then
                            ALLALONE = false
                            break
                        elseif anode.SubType & 7 == npc.SubType & 7 then
                            ALLALONE = false
                            break
                        end
                    elseif data.onlyinterestedinthese then
                        local aData = anode:GetData()
                        if aData.iknowwhatyouare and (npc.SubType & 7 == anode.SubType & 7 or anode.SubType & 7 == data.targetedAnodeGroup) then
                            ALLALONE = false
                            break
                        elseif anode.SubType & 7 == data.targetedAnodeGroup and not aData.iknowwhatyouare then
                            ALLALONE = false
                            break
                        end
                    else
                        local aData = anode:GetData()
                        if aData.iknowwhatyouare and anode.SubType & 7 == npc.SubType & 7 then
                            ALLALONE = false
                            break
                        elseif aData.onlyinterestedinthese and aData.targetedAnodeGroup == npc.SubType & 7 then
                            ALLALONE = false
                            break
                        elseif not aData.iknowwhatyouare then
                            ALLALONE = false
                            break
                        end
                    end
                end

                if ALLALONE then
                    data.goHere = mod:FindClosestValidPosition(npc, target, nil, 200, 0)
                else
                    data.goHere = mod:FindRandomValidPathPosition(npc, 3, 60, 120)
                end
                data.movement = math.floor(-(npc.Position:Distance(data.goHere)*2))
            elseif data.movement < 0 then
                --[[local nearCheck = false
                for _,anode in ipairs(anodes) do
                    if anode:Distance(npc.Position) < 50 then
                        nearCheck = true
                    end
                end]]
                data.movement = data.movement+1
                if npc.Position:Distance(data.goHere) < 25 then
                    data.movement = 10+rng:RandomInt(10)
                    data.goHere = nil
                elseif room:CheckLine(npc.Position, data.goHere, 0, 1, false, false) then
                    local targetvel = (data.goHere - npc.Position):Resized(5.5)
                    npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
                else
                    npc.Pathfinder:FindGridPath(data.goHere, 0.7, 900, true)
                end
            else
                data.movement = 10
                data.goHere = nil
            end
        end
    elseif data.state == "elecing" then
        if npc.StateFrame > 80 then
            data.state = "elecEnd"
        end

        mod:spritePlay(sprite, "ElecLoop")

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "elecStart" then
        if sprite:IsFinished("ElecStart") then
            data.state = "elecing"
            npc.StateFrame = 0
            data.tracerCheck = true
        elseif sprite:IsEventTriggered("Zappy") then
            data.zapping = true
            data.tracerCheck = true
        else
            mod:spritePlay(sprite, "ElecStart")
        end
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "elecEnd" then
        if sprite:IsFinished("ElecEnd") then
            data.movement = 10
            data.goHere = nil
            npc.StateFrame = mod:getRoll(-15,0,rng)
            data.state = "Idle"
        elseif sprite:IsEventTriggered("Zappy") then
            data.zapping = nil

            if data.anodeLaser then
                if data.anodeLaser:Exists() then
                    data.anodeLaser:Remove()
                end
                data.anodeLaser = nil
            end
            if data.anodeLasers then
                for _,laser in pairs(data.anodeLasers) do
                    if laser and laser:Exists() then
                        laser:Remove()
                    end
                end
                data.anodeLasers = nil
            end
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_CLAP, 1, 0, false, 1.2)
        else
            mod:spritePlay(sprite, "ElecEnd")
        end
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    end
    
    if data.tracerCheck then
        for _,laser in ipairs(Isaac.FindByType(mod.FF.AnodeBeam.ID, mod.FF.AnodeBeam.Var, mod.FF.AnodeBeam.Sub, false, false)) do
            if laser.Parent.InitSeed == npc.InitSeed then
                laser:Remove()
            end
        end
        data.tracerCheck = nil
    end

    if data.checkForConnections then
        if data.iknowwhatyouare then
            local exclusiveClub = {}
            for _,anode in ipairs(anodes) do
                local aData = anode:GetData()
                if aData.onlyinterestedinthese and npc.SubType & 7 == anode.SubType & 7 and npc.SubType & 7 == aData.targetedAnodeGroup then
                    table.insert(exclusiveClub, anode)
                elseif anode.SubType & 7 == data.anodeGroup then
                    table.insert(exclusiveClub, anode)
                end
            end

            anodeFindPartners(npc, data, exclusiveClub, rng, 1)
        elseif data.onlyinterestedinthese then
            local possiblepartners = {}
            for _,anode in ipairs(anodes) do
                local aData = anode:GetData()
                if aData.iknowwhatyouare and npc.SubType & 7 == anode.SubType & 7 and anode.SubType & 7 == data.targetedAnodeGroup then
                    table.insert(possiblepartners, anode)
                elseif aData.onlyinterestedinthese and (npc.SubType & 7 == aData.targetedAnodeGroup or anode.SubType & 7 == data.targetedAnodeGroup) then
                    table.insert(possiblepartners, anode)
                elseif anode.SubType & 7 == data.targetedAnodeGroup and not aData.iknowwhatyouare and not aData.onlyinterestedinthese then
                    table.insert(possiblepartners, anode)
                end
            end

            anodeFindPartners(npc, data, possiblepartners, rng, 1)
        else
            local willing = {}
            for _,anode in ipairs(anodes) do
                local aData = anode:GetData()
                if aData.iknowwhatyouare and anode.SubType & 7 == npc.SubType & 7 then
                    table.insert(willing, anode)
                elseif aData.onlyinterestedinthese and aData.targetedAnodeGroup == npc.SubType & 7 then
                    table.insert(willing, anode)
                elseif not aData.iknowwhatyouare then
                    table.insert(willing, anode)
                end
            end

            anodeFindPartners(npc, data, willing, rng, 1)
        end
        data.checkForConnections = nil
    end

    if data.zapping then
        local fail = false
        if data.laserMode == "enemy" then
            if data.poly then
                if data.relationshipStatus then
                    local allgone = true
                    for key,anode in pairs(data.relationshipStatus) do
                        if anode and anode:Exists() and not mod:isStatusCorpse(anode) then
                            data.anodeLasers = data.anodeLasers or {}
                            if not data.anodeLasers[anode.InitSeed] and anode:GetData().zapping then
                                data.anodeLasers[anode.InitSeed] = EntityLaser.ShootAngle(2, npc.Position+Vector(0,-15), (anode.Position-npc.Position):GetAngleDegrees(), 4, Vector(0,-15), npc)
                                data.anodeLasers[anode.InitSeed].Mass = 0
                                data.anodeLasers[anode.InitSeed]:GetData().anodeLaser = true
                                data.anodeLasers[anode.InitSeed].EndPoint = anode.Position
                                data.anodeLasers[anode.InitSeed].MaxDistance = anode.Position:Distance(npc.Position)
                                data.anodeLasers[anode.InitSeed].EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
						        data.anodeLasers[anode.InitSeed].CollisionDamage = 0
                                data.anodeLasers[anode.InitSeed]:Update()
                                npc:PlaySound(SoundEffect.SOUND_REDLIGHTNING_ZAP, 1, 0, false, 1)
                            elseif data.anodeLasers[anode.InitSeed] then
                                data.anodeLasers[anode.InitSeed].Angle = (anode.Position-npc.Position):GetAngleDegrees()
                                data.anodeLasers[anode.InitSeed].MaxDistance = anode.Position:Distance(npc.Position)
                                data.anodeLasers[anode.InitSeed]:SetTimeout(4)
                            end

                            if mod:isFriend(anode) or mod:isFriend(npc) or mod:isScareOrConfuse(anode) or anode:GetData().state == "Idle" then
                                if data.anodeLasers[anode.InitSeed] then
                                    data.anodeLasers[anode.InitSeed]:Remove()
                                    data.anodeLasers[anode.InitSeed] = nil
                                end
                                table.remove(data.relationshipStatus, key)
                            else
                                allgone = false
                            end
                        else
                            if data.anodeLasers then
                                if data.anodeLasers[anode.InitSeed] then
                                    data.anodeLasers[anode.InitSeed]:Remove()
                                    data.anodeLasers[anode.InitSeed] = nil
                                end
                            end
                            table.remove(data.relationshipStatus, key)
                        end
                    end

                    if allgone then
                        fail = true
                    end
                else
                    fail = true
                end
            else
                if data.significantOther and data.significantOther:Exists() and not mod:isStatusCorpse(data.significantOther) then
                    if mod:isFriend(data.significantOther) or mod:isFriend(npc) or mod:isScareOrConfuse(data.significantOther) or data.significantOther:GetData().state == "Idle" then
                        fail = true
                    end
                    
                    if not data.anodeLaser and data.significantOther:GetData().zapping then
                        data.anodeLaser = EntityLaser.ShootAngle(2, npc.Position+Vector(0,-15), (data.significantOther.Position-npc.Position):GetAngleDegrees(), 999, Vector(0,-15), npc)
                        data.anodeLaser.Mass = 0
                        data.anodeLaser:GetData().anodeLaser = true
                        data.anodeLaser.MaxDistance = data.significantOther.Position:Distance(npc.Position)
                        data.anodeLaser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
						data.anodeLaser.CollisionDamage = 0
                        data.anodeLaser:Update()
                        npc:PlaySound(SoundEffect.SOUND_REDLIGHTNING_ZAP, 1, 0, false, 1)
                    elseif data.anodeLaser then
                        data.anodeLaser.Angle = (data.significantOther.Position-npc.Position):GetAngleDegrees()
                        data.anodeLaser.MaxDistance = data.significantOther.Position:Distance(npc.Position)
                        data.anodeLaser:SetTimeout(4)

                        --data.anodeLaser.Color = Color(data.anodeLaser.FrameCount/255, data.anodeLaser.FrameCount/255, data.anodeLaser.FrameCount/255, 1, 0, 0, 0)
                    end
                else
                    fail = true
                end
            end
        elseif data.laserMode == "friend" then
            if data.significantOther and data.significantOther:Exists() then
                if not data.anodeLaser then
                    data.anodeLaser = EntityLaser.ShootAngle(2, npc.Position, (data.significantOther.Position-npc.Position):GetAngleDegrees(), 999, Vector(0,-30), npc)
                    data.anodeLaser.Mass = 0
                    data.anodeLaser:GetData().anodeLaser = true
                    data.anodeLaser.MaxDistance = data.significantOther.Position:Distance(npc.Position)
                    data.anodeLaser:Update()
                    npc:PlaySound(SoundEffect.SOUND_REDLIGHTNING_ZAP, 1, 0, false, 1)
                elseif data.anodeLaser then
                    data.anodeLaser.Angle = (data.significantOther.Position-npc.Position):GetAngleDegrees()
                    data.anodeLaser.MaxDistance = data.significantOther.Position:Distance(npc.Position)
                    data.anodeLaser:SetTimeout(4)
                end
            else
                fail = true
            end
        end
        if fail then
            data.significantOther = nil
            data.zapping = nil
            data.relationshipStatus = nil
            data.state = "elecEnd"
            if data.anodeLaser then
                if data.anodeLaser:Exists() then
                    data.anodeLaser:Remove()
                end
                data.anodeLaser = nil
            end
            if data.anodeLasers then
                for _,laser in pairs(data.anodeLasers) do
                    if laser and laser:Exists() then
                        laser:Remove()
                    end
                end
                data.anodeLasers = nil
            end
        end
    end
end