local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

function mod:famBuster(fam, player, sprite, d)
    local rng = fam:GetDropRNG()
    local room = game:GetRoom()

    if not d.init then
        d.bal = FiendFolio.Buster.Balance
		fam.SpriteOffset = Vector(0, -5)
        d.state = "charge"
		d.chargeattackcount = 0
        d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
        if rng:RandomInt(2) == 0 then
            d.left = true
            d.horiPos = room:GetBottomRightPos().X+120
        else
            d.left = false
            d.horiPos = room:GetTopLeftPos().X-120
        end
        fam.Position = Vector(d.horiPos, d.target.Position.Y)
        --fam.Position = Vector(d.target.Position.X, d.target.Position.Y)
        fam.CollisionDamage = 10
        sfx:Play(mod.Sounds.BusterChargeLoop2, 1, 0, true, 1)
        sfx:Play(mod.Sounds.BusterChargeStart2, 1, 0, false, 1)
        d.orbiters = {}
        
        d.init = true
    end

    if d.state == "charge" then
        local spawn = false
        if d.chargeattackcount < 2 then
            fam.Velocity = Vector((d.bal.ChargeSpeed-5) * (d.left and -1 or 1), 0)
            local inRoomPos = fam.Position - Vector((d.left and -1 or 1) * d.bal.ChargeOutsideThreshold, 0)
            if d.checkOutside then
                if not room:IsPositionInRoom(inRoomPos, 0) then
                    d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
                    fam.Position = Vector(d.horiPos, d.target.Position.Y)
                    d.chargeattackcount = d.chargeattackcount+1
                    d.checkOutside = nil
                    spawn = true
                end
            elseif room:IsPositionInRoom(inRoomPos, 0) then
                d.checkOutside = true
            end

            mod:spritePlay(sprite, d.left and "ChargeLeft" or "ChargeRight")
        else
            if not d.stopping then
                fam.Velocity = Vector((d.bal.ChargeSpeed-5) * (d.left and -1 or 1), 0)
                if (d.left and fam.Position.X < room:GetCenterPos().X) or (not d.left and fam.Position.X > room:GetCenterPos().X) then
                    d.stopping = true
                    sfx:Play(mod.Sounds.FireFizzle, 0.4, 0, false, 1.3)
                    sfx:Stop(mod.Sounds.BusterChargeLoop2)
                end
            else
                if sprite:IsFinished(d.left and "ChargeLeftEnd" or "ChargeRightEnd") then
                    d.state = "waitandsee"
                else
                    mod:spritePlay(sprite, d.left and "ChargeLeftEnd" or "ChargeRightEnd")
                end
                
                fam.Velocity = fam.Velocity * d.bal.ChargeFriction
            end
        end

        if not d.stopping and fam.FrameCount % 1 == 0 then
            local pos = fam.Position - fam.Velocity * 0.2
            if room:IsPositionInRoom(pos, 0)
            and room:GetGridCollisionAtPos(pos) ~= GridCollisionClass.COLLISION_WALL then
                local f = Isaac.Spawn(1000,51, 0, pos + Vector(0, mod:getRoll(-5, 5, rng)), Vector.Zero, fam)
                --local f = Isaac.Spawn(1000,7005, 960, pos + Vector(0, mod:getRoll(-5, 5, rng)), Vector.Zero, fam)
                f:SetColor(Color(1,1,1,1,-100 / 255,70 / 255,455 / 255),10,1,true,false)
                local fData = f:GetData()
                fData.flamethrower = true
                fData.scale = d.bal.FireScale
                fData.timer = 90
                fData.busterRecreation = true
                f.CollisionDamage = (fam.Player and fam.Player:Exists() and fam.Player.Damage+5) or 10
            end
        end

        if fam.FrameCount % 40 == 0 or spawn then
            local topLeft, bottomRight = room:GetTopLeftPos(), room:GetBottomRightPos()
            local pos = Vector(math.random(topLeft.X, bottomRight.X), math.random(topLeft.Y, bottomRight.Y))
            local dir = math.random(1, 4)
            if dir == 1 then
                pos.X = topLeft.X - d.bal.ComRoomOffset
            elseif dir == 2 then
                pos.X = bottomRight.X + d.bal.ComRoomOffset
            elseif dir == 3 then
            pos.Y = topLeft.Y - d.bal.ComRoomOffset
            else
                pos.Y = bottomRight.Y + d.bal.ComRoomOffset
            end

            local com = Isaac.Spawn(FiendFolio.Commission.Id.Type,
                                    FiendFolio.Commission.Id.Variant,
                                    FiendFolio.Commission.Id.SubType,
                                    pos, nilvector, fam)
            com:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            com.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            com:AddCharmed(EntityRef(fam), -1)
            com.Parent = fam
            table.insert(d.orbiters, com)
        end
    elseif d.state == "waitandsee" then
        local hasOrbitsComing = false
        local hasOrbits = false
        for _, orb in ipairs(d.orbiters) do
            local isOrbiting = orb:GetData().OrbitState == 'Orbiting'
			hasOrbits = hasOrbits or isOrbiting
            hasOrbitsComing = hasOrbitsComing or not isOrbiting
        end

        if not (d.target and d.target:Exists()) then
            d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
        end

        if fam.FrameCount % d.bal.PathfindingPeriod == 0 then
            local toTarget = (d.target.Position-fam.Position)
            local vel = Vector(toTarget.X * math.abs(toTarget.X) * 0.7, toTarget.Y * math.abs(toTarget.Y) * 1.4) * (d.bal.Speed / 5000)
            local speed = vel:Length()
            if speed > d.bal.Speed then
                vel = vel * (d.bal.Speed / speed)
            end
    
            fam.Velocity = vel
        end

        mod:spritePlay(sprite, "WalkIdle")

        if not hasOrbitsComing then
            if hasOrbits then
                d.state = "shriek"
            else
                d.state = "spitooey"
                sprite:Play("BurpSkyShoot", true)
                sfx:Play(mod.Sounds.BusterBurpskyCharge, 0.8, 4, false, 1)
            end
        end
    elseif d.state == "shriek" then
        if sprite:IsFinished("HotShriek") then
            d.state = "spitooey"
            sprite:Play("BurpSkyShoot", true)
            sfx:Play(mod.Sounds.BusterBurpskyCharge, 0.8, 4, false, 1)
        elseif sprite:IsEventTriggered("Scream") then
            sfx:Play(mod.Sounds.BusterHotShriekScream, 1, 0, false, 1)
            for _, orbiter in ipairs(d.orbiters) do
                local odata = orbiter:GetData()
                if odata.OrbitState == 'Orbiting' then
                    orbiter.Velocity = (orbiter.Position - fam.Position):Resized(d.bal.HotShriekSpeed)
                    odata.Berserk = true
                    odata.Exploding = true
                    orbiter.Parent = nil
                end
            end
        elseif sprite:IsEventTriggered("ShriekStart") then
            sfx:Play(mod.Sounds.BusterHotShriekStart, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "HotShriek")
        end

        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
    elseif d.state == "spitooey" then
        if sprite:IsEventTriggered("Shoot") then
            local bet = d.target.Position - fam.Position
            local fallSpeed = -0.75 * d.bal.BurpSkyProjTimeToTarget * d.bal.BurpSkyProjFallAccel
            local tear = fam:FireProjectile(Vector.Zero)
            tear:ChangeVariant(1)
            tear.Velocity = bet * (1.02 / d.bal.BurpSkyProjTimeToTarget)
            tear.SpawnerEntity = fam
            tear.Scale = 2
            tear.Height = -d.bal.BurpSkyProjHeight
            tear.FallingSpeed = fallSpeed
            tear.FallingAcceleration = d.bal.BurpSkyProjFallAccel
            tear.Color = mod.ColorCrackleOrange
            tear:GetData().customTearBehavior = {death = function()
                sfx:Play(mod.Sounds.FireFizzle, 0.4, 0, false, 1.3)
                for i = 1, 10 do
                    local fire = Isaac.Spawn(1000,51, 0, tear.Position, Vector(8,0):Rotated((360/10) * i), fam)
                    fire.CollisionDamage = (fam.Player and fam.Player:Exists() and fam.Player.Damage+5) or 10
                    fire:GetData().busterFireball = true
                    fire:GetData().busterRecreation = true
                    fire:Update()
                end
            end}

            sfx:Play(mod.Sounds.BusterBurpskyShoot, 1, 0, false, 1)
        elseif sprite:IsFinished("BurpSkyShoot") then
            if not d.shot then
                d.shot = true
                sprite:Play("HotShriek", true)
                sprite:Play("BurpSkyShoot")
                d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
            else
                sprite:Play("BurpSkyEnd", true)
            end
        elseif sprite:IsFinished("BurpSkyEnd") then
            d.state = "outtahere"
            if room:GetCenterPos().X > fam.Position.X then
                d.left = true
            else
                d.left = false
            end
            sprite:Play(d.left and "ChargeLeftStart" or "ChargeRightStart", true)
            sfx:Play(mod.Sounds.BusterChargeStart, 1, 0, false, 1)
        end

        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
    elseif d.state == "outtahere" then
        if sprite:IsEventTriggered("Dash") then
            d.movement = true
            sfx:Play(mod.Sounds.BusterChargeEnd1, 1, 0, false, 1)
            sfx:Play(mod.Sounds.BusterChargeLoop, 1, 0, false, 1)
        end

        if d.movement then
            fam.Velocity = Vector((d.bal.ChargeSpeed-5) * (d.left and -1 or 1), 0)
            local inRoomPos = fam.Position - Vector((d.left and -1 or 1) * d.bal.ChargeOutsideThreshold, 0)
            if not room:IsPositionInRoom(inRoomPos, 0) then
                fam:Remove()
                sfx:Stop(mod.Sounds.BusterChargeLoop)
            end

            mod:spritePlay(sprite, d.left and "ChargeLeft" or "ChargeRight")

            local pos = fam.Position - fam.Velocity * 0.2
            if room:IsPositionInRoom(pos, 0)
            and room:GetGridCollisionAtPos(pos) ~= GridCollisionClass.COLLISION_WALL then
                local f = Isaac.Spawn(1000,51, 0, pos + Vector(0, mod:getRoll(-5, 5, rng)), Vector.Zero, fam)
                --local f = Isaac.Spawn(1000,7005, 960, pos + Vector(0, mod:getRoll(-5, 5, rng)), Vector.Zero, fam)
                f:SetColor(Color(1,1,1,1,-100 / 255,70 / 255,455 / 255),10,1,true,false)
                local fData = f:GetData()
                fData.flamethrower = true
                fData.scale = d.bal.FireScale
                fData.timer = 90
                fData.busterRecreation = true
                f.CollisionDamage = (fam.Player and fam.Player:Exists() and fam.Player.Damage+5) or 10
            end
        else
            fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
        end
    end

    for i = #d.orbiters, 1, -1 do
        local baby = d.orbiters[i]
		if not (baby:Exists() and baby.Parent and baby.Parent.InitSeed == fam.InitSeed) then
			table.remove(d.orbiters, i)
		end
    end
end