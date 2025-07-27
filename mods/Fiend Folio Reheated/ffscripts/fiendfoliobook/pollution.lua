local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

function mod:famPollution(fam, player, sprite, d)
    local rng = fam:GetDropRNG()
    local room = game:GetRoom()

    if not d.init then
        if rng:RandomInt(2) == 0 then
            d.moveVec = Vector(-1, 0)
            d.horiPos = room:GetBottomRightPos().X+120
            sprite.FlipX = true
        else
            d.moveVec = Vector(1, 0)
            d.horiPos = room:GetTopLeftPos().X-120
            sprite.FlipX = false
        end

        d.charging = 1
		sfx:Play(mod.Sounds.PollutionCharge, 2, 0, false, 1)
        d.substate = "charging"
        d.chargeState = 1

        fam.Position = Vector(d.horiPos, room:GetCenterPos().Y)
        fam.CollisionDamage = 10
        local tab = {
            [1] = {stateName = "SpitBlot", FadeVal1 = 3, FadeVal2 = 3, Idle1 = 4, Idle2 = 7, AttackOff = 250},
            [2] = {stateName = "KickFlip", FadeVal1 = 2, FadeVal2 = 2, Idle1 = 3, Idle2 = 6, AttackOff = 200},
            [3] = {stateName = "BigSwing", FadeVal1 = 4, FadeVal2 = 2, Idle1 = 5, Idle2 = 6, AttackOff = 200},
        }
        d.tricks = {}
        for i=1,3 do
            local num = rng:RandomInt(#tab)+1
            table.insert(d.tricks, tab[num])
            table.remove(tab, num)
        end
        d.trickNum = 1
        d.init = true
    end

    local inPotentialFlameState = d.substate ~= "andale andale" and d.substate ~= "BigSwing" and d.substate ~= "EndTrick"
	local inNonFlameAnim = sprite:IsPlaying("FadeIn01") or sprite:IsFinished("FadeIn01") or sprite:IsPlaying("FadeOut01") or sprite:IsPlaying("Idle02") or sprite:IsFinished("TrickStart")
    if fam.FrameCount % 4 == 0 and room:IsPositionInRoom(fam.Position, 0) and inPotentialFlameState and not inNonFlameAnim then
		local fire = Isaac.Spawn(1000,51, 20, fam.Position - fam.Velocity:Resized(35), fam.Velocity:Resized(-1.5) + RandomVector() * .3, fam):ToEffect()
		fire:GetData().timer = 55
		fire:GetData().busterRecreation = true
		fire.Parent = fam
        fire.CollisionDamage = (fam.Player and fam.Player:Exists() and fam.Player.Damage+5) or 10
		fire:Update()
	end



    if d.substate == "charging" then
        mod:pollutionSmoke(fam)

		d.playLoop = true
		mod:spritePlay(sprite, "Idle0" .. d.tricks[d.trickNum]["Idle" .. d.chargeState])
		local offval = d.tricks[d.trickNum].AttackOff
		if d.chargeState == 1 then
			if (fam.Position.X > room:GetCenterPos().X - offval and not sprite.FlipX) or
				(fam.Position.X < room:GetCenterPos().X + offval and sprite.FlipX) then
				d.substate = d.tricks[d.trickNum].stateName
				sfx:Stop(mod.Sounds.LoopingBike)
				sfx:Play(mod.Sounds.SkidUltraShort, 1, 0, false, math.random(60,80)/100)
				d.playLoop = false
			end
		else
			if fam.Position.X > room:GetGridWidth()*40-200 and not sprite.FlipX then
				d.substate = "jumpOut"
			elseif sprite.FlipX and fam.Position.X < 200 then
				d.substate = "jumpOut"
			end
		end
    elseif d.substate == "jumpOut" then
        local spriteToPlay = "FadeOut0" .. d.tricks[d.trickNum].FadeVal2
        if sprite:IsFinished(spriteToPlay) then
            local yPos = room:GetCenterPos().Y
            if sprite.FlipX then
                fam.Position = Vector(room:GetGridWidth()*40+100, yPos)
            else
                fam.Position = Vector(-100, yPos)
            end
            d.substate = "jumpIn"
            d.chargeState = 1
            d.trickNum = d.trickNum + 1
            if d.trickNum == 4 then
                fam:Remove()
            end
        elseif sprite:IsEventTriggered("Jump") then
            d.speed = 8
            sfx:Play(mod.Sounds.SkateboardJump, 1, 0, false, 0.9)
        else
            mod:spritePlay(sprite, spriteToPlay)
            if d.speed ~= 8 then
                mod:pollutionSmoke(fam)
            end
        end
    elseif d.substate == "jumpIn" then
        mod:pollutionSmoke(fam)
        local spriteToPlay = "FadeIn0" ..d.tricks[d.trickNum].FadeVal1
        if sprite:IsFinished(spriteToPlay) then
            d.substate = "charging"
            d.chargeState = 1
        elseif sprite:IsEventTriggered("Land") then
            d.speed = 12
            sfx:Play(SoundEffect.SOUND_BIRD_FLAP, 2, 0, false, 0.9)
        else
            mod:spritePlay(sprite, spriteToPlay)
        end
    elseif d.substate == "SpitBlot" then
        d.speed = 5
        if sprite:IsFinished("ShootBlot") then
            d.substate = "charging"
            d.speed = 12
            d.chargeState = 2
        elseif sprite:IsEventTriggered("Shoot") then
            sfx:Play(mod.Sounds.PollutionVom, 1.5, 0, false, 1)
            for i = 60, 360, 60 do
                local blotVec = Vector(4, 0):Rotated(i - 20 + math.random(40))
                local blot = Isaac.Spawn(mod.FF.Blot.ID, mod.FF.Blot.Var, 0, fam.Position + d.moveVec:Resized(-10), blotVec, fam):ToNPC();
                local blotdata = blot:GetData();
                blotdata.downvelocity = -25
                blotdata.downaccel = 2.5
                blot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                blot.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                blot:GetSprite().Offset = Vector(0, -30)
                blotdata.state = "air"
                blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                blot:AddCharmed(EntityRef(fam.Player or fam), -1)
                blot.HitPoints = 40
                blot:Update()
            end
        else
            mod:spritePlay(sprite, "ShootBlot")
        end
    elseif d.substate == "KickFlip" then
        d.speed = 6
        if sprite:IsFinished("KickFlip") then
            d.substate = "charging"
            d.speed = 12
            d.chargeState = 2
        elseif sprite:IsEventTriggered("Jump") then
            sfx:Play(mod.Sounds.SkateboardJump, 1, 0, false, 1)
        elseif sprite:IsEventTriggered("Shoot") then
            d.beeterMode = true
            d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
            d.attackang = (d.target.Position - fam.Position):Resized(7)
            d.strobe = Vector(d.moveVec.X * 60, 0)
            d.strobeUpd = Vector(d.moveVec.X * -12, 0)
        elseif sprite:IsEventTriggered("Land") then
            d.beeterMode = false
            sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SPINNING)
            sfx:Play(mod.Sounds.SkateboardLand, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "KickFlip")
        end
    elseif d.substate == "BigSwing" then
        d.speed = 4
        if sprite:IsFinished("Swing") then
            d.substate = "charging"
            d.speed = 12
            d.chargeState = 2
        elseif sprite:IsEventTriggered("Land") then
            sfx:Play(SoundEffect.SOUND_BIRD_FLAP, 2, 0, false, 0.9)
            sprite.FlipX = d.currentFlipVal
        elseif sprite:IsEventTriggered("Jump") then
            sfx:Play(mod.Sounds.BingBingWahoo, 0.1, 0, false, 0.7)
            sfx:Play(mod.Sounds.SkateboardJump, 1, 0, false, 1)
            d.currentFlipVal = sprite.FlipX
            d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
            if d.target.Position.X > fam.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        elseif sprite:GetFrame() == 25 then
            sfx:Play(SoundEffect.SOUND_FIRE_RUSH, 1, 0, false, 1)
        elseif sprite:IsEventTriggered("Shoot") then
            d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
            local targvec = d.target.Position - fam.Position
            local vec
            local calc = 1
            local angie = 87.5 -- old: 80
            local angieIncrease = 35 -- old: 32
            if math.abs(targvec.X) > math.abs(targvec.Y) * 1.6 then
                calc = 2
                angie = 69 -- old: 60
                angieIncrease = 23 -- old: 20
                if d.target.Position.X < fam.Position.X then
                    vec = Vector(-13,0)
                else
                    vec = Vector(13,0)
                end
            else
                if d.target.Position.Y < fam.Position.Y then
                    vec = Vector(0,-9)
                else
                    vec = Vector(0,9)
                end
            end
            for i = -angie, angie, angieIncrease do
                local multcalc
                if calc == 1 then
                    multcalc = (1 + math.abs(i)/100)
                else
                    multcalc = (1.6 - math.abs(i)/100)
                end
                local fire = Isaac.Spawn(1000,51, 20, fam.Position, (vec * multcalc):Rotated(i) * 0.95, fam):ToEffect()
                fire:GetData().timer = 120
                fire:GetData().gridcoll = 0
                fire:GetData().busterRecreation = true
                fire.Parent = fam
                fire.CollisionDamage = (fam.Player and fam.Player:Exists() and fam.Player.Damage*2+10) or 25
                fire:Update()
            end
        else
            mod:spritePlay(sprite, "Swing")
        end
    end

    if d.charging == 1 then
        d.speed = d.speed or 16
        fam.Velocity = mod:Lerp(fam.Velocity, d.moveVec:Resized(d.speed), 0.3)
    elseif d.charging == 2 then
        fam.Velocity = fam.Velocity * 0.9
    else
        fam.Velocity = fam.Velocity * 0.1
    end

    if d.SFXSlowCharge then
        if not sfx:IsPlaying(mod.Sounds.SlowMotor) then
            sfx:Play(mod.Sounds.SlowMotor, 1, 0, true, 0.8)
        end
    end
    if d.beeterMode then
        if not sfx:IsPlaying(SoundEffect.SOUND_ULTRA_GREED_SPINNING) then
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPINNING, 0.4, 0, true, 1.8)
        end
        if fam.FrameCount % 3 == 0 then
            for i = 1, 3 do
                --npc:FireProjectiles(npc.Position + d.strobe, d.attackang:Rotated(120*i), 0, params)
                local tear = fam:FireProjectile(d.attackang:Rotated(120*i))
                tear:ChangeVariant(1)
                tear.FallingAcceleration = -0.09
                tear.Position = fam.Position + d.strobe
                tear.Velocity = d.attackang:Rotated(120*i)
                tear.Scale = 1.1
                tear.CollisionDamage = (fam.Player and fam.Player:Exists() and fam.Player.Damage+5) or 10
                tear:Update()
            end
            local rotvec = 20
            if sprite.FlipX then rotvec = rotvec * -1 end
            d.attackang = d.attackang:Rotated(rotvec)
            d.strobe = d.strobe + d.strobeUpd
        end
    end
end