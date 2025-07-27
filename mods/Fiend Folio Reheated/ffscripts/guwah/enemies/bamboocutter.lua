local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local function IsLaughing(sprite)
    return (sprite:IsPlaying("HeadLaughDown") or sprite:IsPlaying("HeadLaughUp") or sprite:IsPlaying("HeadLaughRight") or sprite:IsPlaying("HeadLaughLeft"))
end

local function IsAligned(pos1, pos2, margin)
    return (math.abs(pos1.X - pos2.X) < margin or math.abs(pos1.Y - pos2.Y) < margin)
end

function mod:BambooCutterAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()


    if not data.Init then
        data.AttackCooldown = mod:RandomInt(15,45,rng)
        data.AggroTimer = 0
        data.Init = true
    end

    data.AttackCooldown = data.AttackCooldown - 1
    data.AggroTimer = data.AggroTimer - 1
    if data.AggroTimer > 0 then
        npc:SetColor(Color(1,0.6,0.6), 10, 3, true, true)
    end

    if data.AttackSuffix then
        if sprite:IsFinished("Attack"..data.AttackSuffix) then
            sprite:Play("Walk"..data.AttackSuffix, true)
            data.AttackSuffix = nil
        elseif sprite:IsEventTriggered("Whoosh") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc, 0.8)
        elseif sprite:IsEventTriggered("Snap") then
            mod:PlaySound(mod.Sounds.ClipSnap, npc, 0.8, 3)
            mod:PlaySound(SoundEffect.SOUND_BONE_BREAK, npc, 0.8, 0.5)
        end
        data.InvestigatePos = nil
    
    elseif data.AggroTimer > 0 then
        npc.State = 4

        if sprite.FlipX then
            if sprite:GetOverlayAnimation() == "HeadLaughRight" then
                sprite:PlayOverlay("HeadLaughLeft", true)
            elseif sprite:GetOverlayAnimation() == "HeadRight" then
                sprite:PlayOverlay("HeadLeft", true)
            end
        end

        if npc.Velocity:Length() > 1 then
            local headsuffix = mod:GetMoveString(npc.Velocity)
            local _, attacksuffix = mod:KnightTargetCheck(npc, targetpos, headsuffix, false, npc.Size, 200)
            if attacksuffix and room:CheckLine(npc.Position,targetpos,0,1,false,false) then
                npc.TargetPosition = mod:SnapVector((targetpos - npc.Position), 90):Normalized()
                npc.Velocity = npc.TargetPosition:Resized(10)
                if targetpos:Distance(npc.Position) <= 120 then
                    data.AttackCooldown = mod:RandomInt(15,30,rng)
                    sprite:PlayOverlay("HeadLaugh"..mod:GetMoveString(npc.TargetPosition), true)
                    data.AttackSuffix, sprite.FlipX = mod:GetMoveString(npc.TargetPosition, true)
                    sprite:Play("Attack"..data.AttackSuffix)
                    npc.State = 8
                elseif not IsLaughing(sprite) then
                    mod:spriteOverlayPlay(sprite, "HeadLaugh"..mod:GetMoveString(npc.TargetPosition))
                end
            elseif data.InvestigatePos then
                npc.TargetPosition = mod:SnapVector((data.InvestigatePos - npc.Position), 90):Normalized()
                npc.Velocity = npc.TargetPosition:Resized(10)
                if npc.Position:Distance(data.InvestigatePos) <= 40 or npc:CollidesWithGrid() or not IsAligned(npc.Position, data.InvestigatePos, 60) then
                    data.InvestigatePos = nil
                end
            end
        end

    elseif npc.FrameCount > 10 then
        npc.Velocity = npc.Velocity:Resized(math.min(5,npc.Velocity:Length()))
        npc.State = 4
        
        if npc.Velocity:Length() > 1 then
            local bodysuffix = mod:GetMoveString(npc.Velocity,true)
            mod:spritePlay(sprite, "Walk"..bodysuffix)
            local headsuffix = mod:GetMoveString(npc.Velocity)
            mod:spriteOverlayPlay(sprite, "Head"..headsuffix)

            if data.AttackCooldown <= 0 then
                local _, attacksuffix = mod:KnightTargetCheck(npc, targetpos, headsuffix, false, npc.Size * 2, 100, true)
                if attacksuffix then
                    data.AttackCooldown = mod:RandomInt(30,45,rng)
                    sprite:PlayOverlay("HeadLaugh"..headsuffix, true)
                    npc.TargetPosition = mod:SnapVector((targetpos - npc.Position), 90):Normalized()
                    data.AttackSuffix = mod:GetMoveString(npc.TargetPosition, true)
                    sprite:Play("Attack"..data.AttackSuffix)
                    npc.State = 8
                end
            end
        end
    end
end

function mod:FrayedNerveAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    
    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        data.State = "Idle"
        data.Init = true
    end

    npc.Velocity = Vector.Zero
    mod.QuickSetEntityGridPath(npc)

    if data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
    elseif data.State == "Aggro" then
        if sprite:IsFinished("Transition") then
            data.State = "Alerted"
        elseif sprite:IsEventTriggered("Alert") then
            data.Alerting = true
            mod:PlaySound(mod.Sounds.FrayedAlert, npc, 0.2, 3)
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 0.7, 0.5)
            mod.scheduleForUpdate(function()
				Isaac.Spawn(20, 0, 150, npc.Position, Vector.Zero, nil)
                sfx:Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
			end, 0)
        else
            mod:spritePlay(sprite, "Transition")
        end
    elseif data.State == "Alerted" then
        mod:spritePlay(sprite, "Idle02")
        if npc.StateFrame <= 0 then
            data.State = "Revert"
            data.Alerting = false
        end
    elseif data.State == "Revert" then
        if sprite:IsFinished("Transition02") then
            data.State = "Idle"
        else
            mod:spritePlay(sprite, "Transition02")
        end
    end

    if targetpos:Distance(npc.Position) <= 100 and room:CheckLine(npc.Position,targetpos,3,0,false,false) and not room:IsClear() then
        npc.StateFrame = 90
    else
        npc.StateFrame = npc.StateFrame - 1
    end

    if npc.StateFrame > 0 then
        if data.State == "Idle" then
            data.State = "Aggro"
        end
        if data.Alerting then
            for _, cutter in pairs(Isaac.FindByType(mod.FF.BambooCutter.ID, mod.FF.BambooCutter.Var)) do
                local targetindex

                if sprite:IsEventTriggered("Alert") then
                    local dist = 9999
                    local index = room:GetGridIndex(npc.Position)
                    local row = math.floor(index/room:GetGridWidth())
                    for i = index - 5, index + 5, 1 do
                        for j = row - 7, row - 1, 1 do
                            local index2 = i + (j * room:GetGridWidth())
                            local pos = room:GetGridPosition(index2)
                            if room:IsPositionInRoom(pos,0) and room:CheckLine(cutter.Position,pos,1,0,false,false) and IsAligned(cutter.Position, pos, 40) then
                                if pos:Distance(npc.Position) < dist then
                                    targetindex = index2
                                    dist = pos:Distance(npc.Position)
                                end
                            end
                        end
                    end
                end

                local headsuffix = mod:GetMoveString(cutter.Velocity)
                if targetindex then
                    cutter:GetData().InvestigatePos = room:GetGridPosition(targetindex)
                    cutter.TargetPosition = mod:SnapVector((cutter:GetData().InvestigatePos - cutter.Position), 90):Normalized()
                    headsuffix = mod:GetMoveString(cutter.TargetPosition)
                end
                if cutter:GetData().AggroTimer and cutter:GetData().AggroTimer <= 0 then
                    cutter:GetSprite():PlayOverlay("HeadLaugh"..headsuffix, true)
                    mod:PlaySound(mod.Sounds.TemperCharge, cutter, 0.7)
                end

                cutter:GetData().AggroTimer = npc.StateFrame
            end
        end
    end
end

function mod:FrayedNerveHurt(npc, amount, damageFlags, source)
    if not game:GetRoom():IsClear() then
        npc.StateFrame = 90
    end
    return false
end