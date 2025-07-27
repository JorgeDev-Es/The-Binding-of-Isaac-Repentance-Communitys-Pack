local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--PollutionPart2, PollutionPhase2, Pollution Part 2, Pollution Phase 2, Pollution2AI, etc.
function mod:pollutionHorsepowerAI(npc, sprite, d)
	local room = game:GetRoom()
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()

	if not d.init then
		d.state = d.state or "idle"
		d.init = true
		npc.SplatColor = mod.ColorDankBlackReal
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if mod.allPlayersDead() then
		npc:PlaySound(mod.Sounds.PollutionWins2, 2, 0, false, 1)
	end

	if d.state == "launched" then
		if not d.substate then
			d.fallspeed = -14
			npc.SpriteOffset = Vector(0, -20)
			d.substate = "falloff"
			mod:spritePlay(sprite, "InAir01")
		elseif d.substate == "falloff" then
			if d.fallspeed > 0 then
				if sprite:IsFinished("Apex01") then
					mod:spritePlay(sprite, "Fall01")
				end
			elseif d.fallspeed > -10 then
				mod:spritePlay(sprite, "Apex01")
			else
				mod:spritePlay(sprite, "InAir01")
			end

			local targvec = room:GetCenterPos() - npc.Position
			npc.Velocity = mod:Lerp(npc.Velocity, targvec * 0.1, 0.3)

			d.fallspeed = d.fallspeed + 1
			npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + d.fallspeed)

			if npc.SpriteOffset.Y > -5 then
				d.substate = "land"
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				npc.SpriteOffset = Vector(0, 0)
				mod:spritePlay(sprite, "Land")
				npc.Velocity = nilvector
				npc:BloodExplode()

				sfx:Play(SoundEffect.SOUND_BONE_SNAP, 0.6, 0, false, 0.7)

				local headExplode = Isaac.Spawn(1000,7009,0,npc.Position + Vector(0, 10),nilvector,npc):ToEffect()
				local hES = headExplode:GetSprite()
				hES:ReplaceSpritesheet(2, "gfx/bosses/pollution/effect_meltypoof_butpollution.png")
				hES:LoadGraphics()
				headExplode:Update()

				for i = -30, 30, 30 do
					local blotVec = Vector(0, 4):Rotated(i - 20 + math.random(40))
					local blot = Isaac.Spawn(mod.FF.Blot.ID, mod.FF.Blot.Var, 0, npc.Position, blotVec, npc):ToNPC();
					local blotdata = blot:GetData();
					blotdata.downvelocity = -15
					blotdata.downaccel = 2.5
					blot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					blot.GridCollisionClass = GridCollisionClass.COLLISION_NONE
					blot:GetSprite().Offset = Vector(0, -10)
					blotdata.state = "air"
					blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					blot:Update()
				end
			end
		elseif d.substate == "land" then
			npc.Velocity = npc.Velocity * 0.3
			npc.SpriteOffset = Vector(0, 0)
			if sprite:IsFinished("Land") then
				d.fallspeed = -14
				npc.SpriteOffset = Vector(0, -20)
				d.substate = "jumpback"
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
			else
				mod:spritePlay(sprite, "Land")
			end
		elseif d.substate == "jumpback" then
			if d.fallspeed > 0 then
				if sprite:IsFinished("Apex02") then
					mod:spritePlay(sprite, "Fall02")
				end
			elseif d.fallspeed > -10 then
				mod:spritePlay(sprite, "Apex02")
			else
				mod:spritePlay(sprite, "InAir02")
			end
			d.fallspeed = d.fallspeed + 1
			npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + d.fallspeed)

			if npc.Parent then
				d.aimedPos = npc.Parent.Position
			else
				d.aimedPos = d.backupPosition
			end

			local targvec = d.aimedPos - npc.Position
			npc.Velocity = mod:Lerp(npc.Velocity, targvec * 0.1, 0.3)

			if npc.SpriteOffset.Y > -5 then
				d.substate = "appear"
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				npc.SpriteOffset = Vector(0, 0)
				mod:spritePlay(sprite, "Appear")
				npc.Velocity = nilvector
				if npc.Parent then
					if npc.Parent:GetSprite().FlipX then
						sprite.FlipX = true
					end
					npc.Parent:Remove()

					npc:PlaySound(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 0.7)
					npc:PlaySound(SoundEffect.SOUND_SLOTSPAWN,1.3,0,false, 0.5)
					npc:PlaySound(mod.Sounds.CarIgnition, 1, 0, false, 0.8)

					--Horse
					local vec = (target.Position - npc.Position) * 0.04
					local horse = Isaac.Spawn(mod.FF.ThrownHorse.ID, mod.FF.ThrownHorse.Var, 0, npc.Position, vec, npc):ToNPC();
					local horsed = horse:GetData()
					horse.SpriteOffset = Vector(0,-30)
					horsed.vec = vec
					horsed.fallspeed = -7
					horse:Update()
				end
			end
		elseif d.substate == "appear" then
			if sprite:IsFinished("Appear") then
				d.state = "idle"
			else
				mod:spritePlay(sprite, "Appear")
			end
		end
	elseif d.state == "idle" then
		--npc.Velocity = mod:Lerp(

		--[[if not sfx:IsPlaying(mod.Sounds.SteamTrain) then
			sfx:Play(mod.Sounds.SteamTrain, 0.7, 0, true, 0.9)
		end]]

		mod:CatheryPathFinding(npc, target.Position, {
			Speed = 11,
			Accel = 0.05,
			GiveUp = true
		})

		if npc.FrameCount % 6 == 2 then
			--sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 1, 0, false, 0.7)
			for i = -30, 30, 30 do
				local fire = Isaac.Spawn(1000,7005, 20, npc.Position + Vector(0,-50), npc.Velocity:Resized(-5):Rotated(i) + Vector(0, 3), npc):ToEffect()
				fire:GetData().timer = 50
				--fire:GetData().gridcoll = 0
				fire.Parent = npc
				fire:Update()
			end
		end

		if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
			mod:spritePlay(sprite, "WalkHori")
			mod:spriteOverlayPlay(sprite, "HeadHori")
			if npc.Velocity.X < 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		else
			if npc.Velocity.Y > 0 then
				mod:spritePlay(sprite, "WalkDown")
				mod:spriteOverlayPlay(sprite, "HeadDown")
			else
				mod:spritePlay(sprite, "HeadUp")
				mod:spriteOverlayPlay(sprite, "WalkUp")
			end
		end
		if npc.StateFrame > 150 then
			d.state = "charge"
			mod:spritePlay(sprite, "ChargeStart")
			sprite:RemoveOverlay()
			if target.Position.X > npc.Position.X then
				d.chargeVec = mod:Lerp(Vector(1, 0), (target.Position - npc.Position):Normalized(), 0.5):Normalized()
				sprite.FlipX = false
			else
				sprite.FlipX = true
				d.chargeVec = mod:Lerp(Vector(-1, 0), (target.Position - npc.Position):Normalized(), 0.5):Normalized()
			end
			d.substate = nil
		end
	elseif d.state == "charge" then
		d.substate = d.substate or "initTheBinch"
		if d.substate == "initTheBinch" then
			if sprite:IsFinished("ChargeStart") then
				d.substate = "loopyLoop"
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.HorseGoWhee, 1, 0, false, math.random(80,85)/100)
			elseif sprite:IsEventTriggered("Charge") then
				d.chargin = true
				npc.StateFrame = 0
			else
				mod:spritePlay(sprite, "ChargeStart")
			end
		elseif d.substate == "loopyLoop" then
			mod:spritePlay(sprite, "ChargeLoop")
		elseif d.substate == "impact" then
			if sprite:IsFinished("Impact") then
				d.state = "framebreath"
				d.timesFired = 0
				d.substate = nil
				npc.StateFrame = -1
			else
				mod:spritePlay(sprite, "Impact")
			end
		end

		if d.chargin then
			npc.Velocity = d.chargeVec:Resized(17)
			for k,v in ipairs(mod.GetGridEntities()) do
				if v.Position:Distance(npc.Position + d.chargeVec:Resized(30)) < 30 then
					v:Destroy()
				end
			end
			if npc.FrameCount % 3 == 2 then
				--sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 1, 0, false, 0.7)
				for i = -60, 60, 60 do
					local fire = Isaac.Spawn(1000,7005, 20, npc.Position + Vector(0,-50), npc.Velocity:Resized(-5):Rotated(i) + Vector(0, 3), npc):ToEffect()
					fire:GetData().timer = 50
					--fire:GetData().gridcoll = 0
					fire.Parent = npc
					fire:Update()
				end
			end
			if npc.StateFrame > 5 and npc:CollidesWithGrid() then
				d.chargin = false
				npc.Velocity = nilvector
				d.substate = "impact"
				mod:spritePlay(sprite, "Impact")
				game:ShakeScreen(15)
				npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1)
			end
		else
			npc.Velocity = npc.Velocity * 0.9
		end
	elseif d.state == "framebreath" then
		npc.Velocity = npc.Velocity * 0.7
		d.substate = d.substate or "start"
		local targvec = target.Position - npc.Position
		if d.substate == "start" then
			if math.abs(targvec.X) > math.abs(targvec.Y) then
				sprite:SetFrame("WalkHori", 0)
				sprite:SetOverlayFrame("HeadHoriShootStart", npc.StateFrame)
				if targvec.X < 0 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			else
				if targvec.Y > 0 then
					sprite:SetFrame("WalkDown", 0)
					sprite:SetOverlayFrame("HeadDownShootStart", npc.StateFrame)
				else
					sprite:SetFrame("HeadUpShootStart", npc.StateFrame)
					sprite:SetOverlayFrame("WalkUp", 0)
				end
			end

			if npc.StateFrame > 13 then
				d.substate = "flameWar"
				npc:PlaySound(mod.Sounds.FriedLoop,1,0,true,1)
			elseif npc.StateFrame == 5 then
				d.rotval = 0
				d.firing = true
				npc:PlaySound(mod.Sounds.FriedStart,1,0,false,0.7)
				d.targetedVec = targvec
			end
		elseif d.substate == "flameWar" then
			local targvec = d.targetedVec
			if math.abs(targvec.X) > math.abs(targvec.Y) then
				sprite:SetFrame("WalkHori", 0)
				mod:spriteOverlayPlay(sprite, "HeadHoriShoot")
				if targvec.X < 0 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			else
				if targvec.Y > 0 then
					sprite:SetFrame("WalkDown", 0)
					mod:spriteOverlayPlay(sprite, "HeadDownShoot")
				else
					mod:spritePlay(sprite, "HeadUpShoot")
					sprite:SetOverlayFrame("WalkUp", 0)
				end
			end
		end
		if d.firing then
			d.rotval = d.rotval or 0
			d.rotval = d.rotval + 1
			if d.rotval > 60 then
				d.timesFired = d.timesFired + 1
				if d.timesFired > 2 then
					d.state = "idle"
				else
					d.substate = nil
				end
				d.firing = false
				npc.StateFrame = -1
				sfx:Stop(mod.Sounds.FriedLoop)
				npc:PlaySound(mod.Sounds.FriedEnd,1,0,false,0.7)
			end
			if npc.FrameCount % 2 == 1 then
				local emberParticle = Isaac.Spawn(1000,66, 0, npc.Position, d.targetedVec:Resized(math.random(4,7)):Rotated(-35 + math.random(70)), npc):ToEffect()
				emberParticle.SpriteOffset = Vector(0, -20)
				emberParticle:Update()

				local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, d.targetedVec:Resized(math.random(4,7)):Rotated(-35 + math.random(70)), npc)
				smoke.SpriteRotation = math.random(360)
				smoke.Color = Color(1,1,1,0.3,75 / 255,70 / 255,50 / 255)
				--smoke.SpriteScale = Vector(2,2)
				smoke.SpriteOffset = Vector(0, -20)
				smoke.RenderZOffset = 300
				smoke:Update()
			end
			if d.rotval % 4 == 0 then
				for i = -50, 50, 50 do
					local vec = (d.targetedVec):Resized(10):Rotated(i + math.sin((d.rotval) / 6.5) * 15) -- used to be (val / 6) * 15, lower first value = faster rotation, lower second value = less extreme rotation
					local fire = Isaac.Spawn(1000,7005, 0, npc.Position + Vector(0,-30), vec, npc):ToEffect()
					fire:SetColor(Color(1,1,1,1,-100 / 255,70 / 255,455 / 255),10,1,true,false)
					fire:GetData().flamethrower = true
					fire:GetData().timer = 50
					--fire:GetData().gridcoll = 1
					fire.Parent = npc
					fire:Update()
				end
			end
		end
	end

	if npc:HasMortalDamage() then
		sfx:StopLoopingSounds()
	end
end

function mod:horse(npc)
	local d = npc:GetData()
	local r = npc:GetDropRNG()

	if not d.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		d.init = true
	end
	d.vec = d.vec or nilvector
	npc.Velocity = d.vec

	mod:spritePlay(npc:GetSprite(), "Spin")

	if npc.SpriteOffset.Y > -20 then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
	else
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end

	d.fallspeed = d.fallspeed or -5
	d.fallspeed = d.fallspeed + 0.5
	npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + d.fallspeed)

	if npc:CollidesWithGrid() or npc.SpriteOffset.Y > 0 then
		--npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT,1,0,false,0.7)
		Isaac.Explode(npc.Position, npc, 10)
		local sploshEffect = Isaac.Spawn(1000, 1739, 0, npc.Position, nilvector, npc):ToEffect()
		sploshEffect.SpriteOffset = npc.SpriteOffset
		sploshEffect:Update()
		npc:Remove()
	end
end

function mod:meltdown2RenderAI(npc)
	local sprite = npc:GetSprite()
	if sprite:IsPlaying("Death") then
		if sprite:IsEventTriggered("Scream") then
			sfx:Play(mod.Sounds.MDP2_Death, 1, 0, false, 1)
		end
	end
end

function mod:meltdownAI(npc, sprite, d)
	local room = game:GetRoom()
	local target = npc:GetPlayerTarget()

	if not d.init then
		d.state = "idle"
		d.spawnedMorsel = {}
		d.init = true
		d.flinchDenial = true
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if npc.HitPoints < npc.MaxHitPoints * 0.55 and room:IsPositionInRoom(npc.Position, 0) then
		d.state = "CantTakeItAnymore"
	end
	if d.state == "idle" and npc.FrameCount % 3 == 1 and not d.flinchDenial then
		for i = 1, 20 do
			if (not d.spawnedMorsel[i]) and npc.HitPoints < npc.MaxHitPoints * (0.05 * i) then
				d.state = "flinch"
				d.flinchDenial = true
			end
		end
	end

	if d.state == "CantTakeItAnymore" then
		npc.Velocity = nilvector
		if sprite:IsFinished("Transition") then
			npc:Remove()
		else
			mod:spritePlay(sprite, "Transition")
		end

			--All da sounds
		if sprite:IsEventTriggered("Blink") then
			npc:PlaySound(mod.Sounds.Boink,1,0,false,math.random(80,120)/100)
		elseif sprite:IsEventTriggered("Grrrrrrrr") then
			npc:PlaySound(mod.Sounds.MDP1_TransGrr,1,0,false,1)
		elseif sprite:IsEventTriggered("Scream") then
			npc:PlaySound(mod.Sounds.MetalDrop,0.8,0,false,0.7)
			npc:PlaySound(SoundEffect.SOUND_BONE_SNAP,0.8,0,false,0.7)
		elseif sprite:IsEventTriggered("Shoot") then
			sfx:Play(mod.Sounds.WingFlap,1,0,false,math.random(120,130)/100)
		elseif sprite:IsEventTriggered("Grah") then
			sfx:Play(mod.Sounds.MDP1_TransThrow,1,0,false,1)
		elseif sprite:IsEventTriggered("Strangle") then
			npc:PlaySound(mod.Sounds.StretchEye,0.8,0,false,1)
			npc:PlaySound(mod.Sounds.MDP1_TransitionStrangle,1,0,false,1)
		elseif sprite:IsEventTriggered("OhShit") then
			npc:PlaySound(mod.Sounds.GlobSurprise,1,0,false,0.7)
		elseif sprite:IsEventTriggered("RipSound") then
			sfx:Stop(mod.Sounds.StretchEye)
			npc:PlaySound(mod.Sounds.ClothRip,1,0,false,1)
		elseif sprite:GetFrame() == 162 and not d.playedNuke then
			npc:PlaySound(mod.Sounds.Nuke,1,0,false,1)
			d.playedNuke = true
		elseif sprite:IsEventTriggered("Spawn") then
			local nukeFlash = Isaac.Spawn(1000, mod.FF.MeltdownFlash.Var, mod.FF.MeltdownFlash.Sub, npc.Position, nilvector, npc)
            nukeFlash.SpriteOffset = npc.SpriteOffset
            nukeFlash.RenderZOffset = 1000000
			nukeFlash:GetSprite().FlipX = sprite.FlipX
            nukeFlash:Update()
		elseif sprite:GetFrame() == 165 and not d.shookYet then
			--npc:PlaySound(mod.Sounds.Nuke,2,0,false,1)
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.RenderZOffset = 1000000
			game:ShakeScreen(60)
			d.shookYet = true
		elseif sprite:GetFrame() == 117 and not d.deathBeeped then
			npc:PlaySound(mod.Sounds.BusterDethBeep,1,0,false,1.4)
			d.deathBeeped = true
			--Actual Transition bit
		elseif sprite:GetFrame() == 170 and not d.spawnedPhase2 then
			local phase2 = Isaac.Spawn(mod.FF.Meltdown2.ID, mod.FF.Meltdown2.Var, 0, npc.Position, nilvector, npc)
			phase2:GetData().state = "transition"
			phase2:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            phase2.MaxHitPoints = npc.MaxHitPoints
            phase2.HitPoints = npc.HitPoints
			phase2:Update()
			d.spawnedPhase2 = true
            npc:Remove()
		--[[elseif sprite:GetFrame() > 170 and sprite:GetFrame() < 180 then
			if StageAPI then
				StageAPI.ChangeRoomGfx(mod.SmokyBackdrop)
			end]]
		end
	elseif d.state == "flinch" then
		d.flinchChoice = d.flinchChoice or math.random(2)
		if sprite:IsFinished("Flinch0" .. d.flinchChoice) then
			d.state = "idle"
			d.flinchChoice = nil
		elseif sprite:IsEventTriggered("Spawn") then
			npc:PlaySound(mod.Sounds.MDP1_Flinch, 1, 0, false, 1)
			for i = 1, 20 do
				if (not d.spawnedMorsel[i]) and npc.HitPoints < npc.MaxHitPoints * (0.05 * i) then
					local skin = Isaac.Spawn(mod.FF.Falafel.ID, mod.FF.Falafel.Var, 0, npc.Position + Vector(0, 5) + RandomVector():Resized(0.5 + math.random(25)/10), Vector(0, 1):Rotated(-45 + math.random(90)):Resized(0.5 + math.random(25)/10), npc)
					skin.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					skin:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					skin:GetData().fallspeed = -8 - math.random(4)
					skin.SpriteOffset = Vector(0, -10 - math.random(20))
					skin:GetData().fallaccel = 1
					skin:GetData().state = "thrown"
					skin:Update()
					d.spawnedMorsel[i] = true
				end
			end
		else
			mod:spritePlay(sprite, "Flinch0" .. d.flinchChoice)
		end
	elseif d.state == "idle" then
		if not (sprite:IsPlaying("Twitch") or sprite:IsPlaying("Flinch01") or sprite:IsPlaying("Flinch02")) then
			mod:spritePlay(sprite, "Idle")
			if sprite:GetFrame() == 18 and math.random(2) == 1 then
				mod:spritePlay(sprite, "Twitch")
			end
		end

		if npc.StateFrame % 30 == 0 or (not d.targetvel) then
			local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
			d.targetvel = (gridtarget - npc.Position):Resized(5)
		end
		if d.targetvel then
			npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)
			if d.targetvel.X < 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		end

		if npc.StateFrame > 60 and math.random(5) == 1 then
			d.targetvel = nil
			d.flinchDenial = false
			local choice = math.random(3)
			if d.justBonkd then
				choice = math.random(2)
			end
			if choice == 1 and not d.justChargd then
				d.state = "charge"
				d.cstate = nil
				d.justChargd = true
				d.justBombd = false
				d.justBonkd = false
				mod:spritePlay(sprite, "DashStart")
				if room:GetCenterPos().X < npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			elseif choice == 2 and not d.justBombd then
				d.state = "bomberboy"
				d.justBombd = true
				d.justChargd = false
				d.justBonkd = false
				d.cstate = "throw"
				d.flippin = true
			else
				d.state = "bonk"
				d.justBombd = false
				d.justChargd = false
				if target.Position.X < npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
				d.flippin = true
			end
		end
	elseif d.state == "bonk" then
		npc.Velocity = npc.Velocity * 0.7
		if d.flippin then
			if target.Position.X < npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
		end
		if sprite:IsFinished("HitHorse") then
			d.state = "idle"
			d.justBonkd = true
			npc.StateFrame = 40
		elseif sprite:IsEventTriggered("Grrrrrrrr") then
			--npc:PlaySound(mod.Sounds.BuckAppear2, 1, 0, false, 1.2)
		elseif sprite:IsEventTriggered("Scream") then
			npc:PlaySound(mod.Sounds.MDP1_HitHorseScream, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Grah") then
			--npc:PlaySound(mod.Sounds.MDP1_HitHorseStart, 1, 0, false, 1)
		elseif sprite:GetFrame() == 39 then
			npc:PlaySound(mod.Sounds.MDP1_HitHorseStart, 1, 0, false, 1)
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.FunnyBonk,2,0,false,math.random(90,100)/100)
			npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS,1,1,false,1)
			for i = -15, 15, 15 do
				local vec = (target.Position - npc.Position):Resized(13):Rotated(i)
				if i == 0 then
					vec = vec:Resized(17)
				end
				--npc:FireProjectiles(npc.Position + vec:Resized(15), vec, 0, ProjectileParams())
				local proj = Isaac.Spawn(9, 0, 0, npc.Position + vec:Resized(15), vec, npc):ToProjectile()
				proj:GetData().projType = "Radioactive"
				proj:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/radioactive.png")
				proj:GetSprite():LoadGraphics()
				proj:Update()
			end
			d.flippin = false
		else
			mod:spritePlay(sprite, "HitHorse")
		end
	elseif d.state == "bomberboy" then
		npc.Velocity = npc.Velocity * 0.7
		if d.flippin then
			if target.Position.X < npc.Position.X then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
            d.flippin = false
		end
		if d.cstate == "throw" then
			if sprite:IsFinished("TNTThrow") then
				--[[d.state = "idle"
				d.waitinForBarrel = true
				npc.StateFrame = 30]]
				d.cstate = "loogie"
			elseif sprite:IsEventTriggered("Grah") then
				npc:PlaySound(mod.Sounds.MDP1_TNT_1, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Scream") then
				npc:PlaySound(mod.Sounds.MDP1_TNT_2, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.MDP1_TNT_3, 1, 0, false, 1)
                if target.Position.X < npc.Position.X then
                    sprite.FlipX = true
                else
                    sprite.FlipX = false
                end
				local spawnPoint = (target.Position - npc.Position)
				spawnPoint = npc.Position + spawnPoint:Resized(math.max(120, spawnPoint:Length()))
				local pos = room:FindFreeTilePosition(spawnPoint, 10)
				d.rememberThis = pos
				local barrel = Isaac.Spawn(mod.FF.NuclearWaste.ID, mod.FF.NuclearWaste.Var, 0, npc.Position, nilvector, npc)
				barrel.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				barrel.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				local bd = barrel:GetData()
				bd.targpos = pos
				bd.state = "inair"
				bd.fallspeed = -15
				bd.fallaccel = 1
				barrel:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				if sprite.FlipX then
					barrel:GetSprite().FlipX = true
				end
				barrel:Update()
			elseif sprite:GetFrame() == 44 then
				sfx:Play(SoundEffect.SOUND_SHELLGAME,2,0,false,math.random(80,90)/100)
			else
				mod:spritePlay(sprite, "TNTThrow")
			end
		elseif d.cstate == "loogie" then
			if sprite:IsFinished("SpitFireball") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("OhShit") then
				npc:PlaySound(mod.Sounds.MDP1_DashStartGrah, 1, 0, false, 0.7)
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(mod.Sounds.MDP1_DashEnd, 1, 0, false, 0.7)
				d.flippin = false
				local ash = mod.FindClosestUnlitPowder(npc.Position, npc)
				local targetpos = target.Position
				if ash then
					targetpos = ash.Position
				end
				local vel = (targetpos - npc.Position) * 0.03
				local coal = Isaac.Spawn(9, 1, 0, npc.Position, vel, npc):ToProjectile()
				local coald = coal:GetData()
				coald.projType = "coalRadioactive"
				coald.projSpeed = 5
				coal.FallingSpeed = -15
				coal.FallingAccel = 1
				--coal.Color = Color(0.5,1.5,1,1,0,0,0)
				local coals = coal:GetSprite()
				coals:Load("gfx/projectiles/sooty_tear_radioactive.anm2",true)
				coals:Play("spin",true)
				coal:Update()
			else
				mod:spritePlay(sprite, "SpitFireball")
			end
		else
			d.cstate = "throw"
		end
	elseif d.state == "charge" then
		if sprite:IsFinished("DashStart") then
			mod:spritePlay(sprite, "Dash")
		end
		if not d.cstate then
			npc.Velocity = npc.Velocity * 0.7
			if sprite:IsEventTriggered("Grah") then
				npc:PlaySound(mod.Sounds.MDP1_DashStartStart, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Scream") then
				npc:PlaySound(mod.Sounds.MDP1_DashStartScream, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Dash") or sprite:IsFinished("DashStart") or sprite:IsPlaying("Dash") then
				npc:PlaySound(mod.Sounds.MDP1_DashStartGrah, 1, 0, false, 1)
				d.cstate = "GOOO"
				npc.StateFrame = 0
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			end
		end
		if d.cstate == "GOOO" then
			local chargeVec = Vector(math.min(30, (15 + npc.StateFrame * 0.5)), 0)
			if sprite.FlipX then
				chargeVec = chargeVec * -1
			end
			npc.Velocity = mod:Lerp(npc.Velocity, chargeVec, 0.7)

			local changeState
			if npc.Position.X > room:GetGridWidth()*50+200 and not sprite.FlipX then
				changeState = true
			elseif sprite.FlipX and npc.Position.X < -200 then
				changeState = true
			end

			if changeState then
				d.cstate = "watchingFromTheEdge"
				local yPos = target.Position.Y
				local spawnPos
				if sprite.FlipX then
					spawnPos = Vector(room:GetGridWidth()*50+200, yPos)
				else
					spawnPos = Vector(-200, yPos)
				end
				npc.Position = spawnPos + Vector(0, -200)
				d.Saveposition = npc.Position
				npc.Visible = false
				npc.Velocity = nilvector
				local fakehorse = Isaac.Spawn(mod.FF.FakeHorse.ID, mod.FF.FakeHorse.Var, 0, spawnPos, nilvector, npc):ToNPC()
				fakehorse:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				if sprite.FlipX then fakehorse:GetSprite().FlipX = true end
				fakehorse:GetData().vec = chargeVec:Resized(15)
				d.chargeVec = chargeVec:Resized(15)
				fakehorse.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				fakehorse:Update()
				npc.Child = fakehorse
			end

		end
		if d.cstate == "watchingFromTheEdge" then
			d.Saveposition = d.Saveposition or npc.Position
			npc.Position = d.Saveposition
			if (npc.Child and (not npc.Child:Exists())) or (not npc.Child) then
				npc.Child = nil
				local ypos = 100
				local chargey = 5
				if target.Position.Y < room:GetCenterPos().Y then
					ypos = (room:GetGridHeight() * 50) + 30
					chargey = -5
				end
				npc.Position = Vector(npc.Position.X, ypos)
				npc.Velocity = Vector(d.chargeVec.X, chargey):Resized(15)
				npc.TargetPosition = npc.Position + npc.Velocity:Resized(500)
				--Isaac.Spawn(1000,1,0,npc.TargetPosition,nilvector,nil)
				npc.Visible = true
				d.cstate = "reenter"
			end
		end
		if d.cstate == "reenter" then
			npc.TargetPosition = npc.TargetPosition or player.Position
			local targvec = (npc.TargetPosition - npc.Position):Resized(15)
			npc.Velocity = mod:Lerp(npc.Velocity, targvec, 0.1)
			if room:IsPositionInRoom(npc.Position, 0) then
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				mod:spritePlay(sprite, "DashEnd")
				d.cstate = "slowit"
			end
		end
		if d.cstate == "slowit" then
			npc.Velocity = npc.Velocity * 0.9
			if sprite:IsFinished("DashEnd") then
				d.state = "idle"
				npc.StateFrame = 0
				if math.random(3) ~= 1 then
					d.state = "bonk"
					d.flippin = true
				end
			elseif sprite:GetFrame() == 5 then
				npc:PlaySound(mod.Sounds.MDP1_DashEnd, 1, 0, false, 1)
			else
				mod:spritePlay(sprite, "DashEnd")
			end
		end
	end
end

function mod:meltdownFlashEffectAI(e)
    local sprite = e:GetSprite()
    if sprite:IsFinished("Flash") then
        e:Remove()
    elseif sprite:GetFrame() > 6 and sprite:GetFrame() < 16 then
        local room = Game():GetRoom()
        if room:GetBackdropType() == BackdropType.BURNT_BASEMENT then
            if StageAPI then
                StageAPI.ChangeRoomGfx(mod.SmokyBackdrop)
            end
        else
            if sprite:GetFrame() == 7 then --Only do it once
                local smokyBlue = Color(1,1,1,1)
                smokyBlue:SetColorize(43/64, 52/64, 65/64, 1)
                room:SetFloorColor(smokyBlue)
                room:SetWallColor(smokyBlue)
            end
        end
    else
        mod:spritePlay(sprite, "Flash")
    end
	if sprite:GetFrame() == 16 then
		if not e:GetData().spawnedThing then
			local vec = Vector(0,-60)
			if sprite.FlipX then
				vec = vec + Vector(40,0)
			else
				vec = vec + Vector(-40,0)
			end
			local ash = Isaac.Spawn(1000,100,0,e.Position + vec,nilvector,e)

			ash.SpriteScale = ash.SpriteScale * 0.25
			ash.Color = Color(1,1,1,0.75)
			ash:GetSprite().FlipX = not sprite.FlipX
			e:Update()
		end
	end
end

function mod:meltdownForsakenAI(npc, sprite, d)
	local room = game:GetRoom()
	local r = npc:GetDropRNG()
	local target = npc:GetPlayerTarget()
	if not d.init then
		d.init = true
		mod.meltdownForsakenTearStuff = nil
		d.state = d.state or "idle"
		npc.SplatColor = mod.ColorCharred
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

	if d.state == "transition" then
		npc.Velocity = npc.Velocity * 0.7
		if npc.FrameCount < 60 then
			mod:spritePlay(sprite, "TransitionIdle")
		else
			if sprite:IsFinished("Appear") then
				d.state = "idle"
			elseif sprite:IsEventTriggered("Scream") then
				npc:PlaySound(mod.Sounds.MDP2_Appear,1,0,false,1)
				npc:PlaySound(mod.Sounds.FireLight, 2, 0, false, 1)
			else
				mod:spritePlay(sprite, "Appear")
			end
		end
	elseif d.state == "idle" then
		if d.pickedUp then
			mod:spritePlay(sprite, "Idle02")
			if npc.StateFrame > 30 then
				d.state = "dropTheBomb"
			end
		else
			mod:spritePlay(sprite, "Idle01")
		end
		d.goPassives = true
		local nuke = mod.FindClosestEntity(npc.Position, 99999, mod.FF.DavyCrockett.ID, mod.FF.DavyCrockett.Var)
		if nuke and nuke:GetData().state == "sitte" and not d.pickedUp then
			local targvec = (nuke.Position - npc.Position):Resized(8)
			npc.Velocity = mod:Lerp(npc.Velocity, targvec, 0.05)

			if npc.Position:Distance(nuke.Position) < 20 then
				npc.Velocity = nilvector
				npc.Position = nuke.Position + Vector(0, -5)
				d.state = "pickup"
				d.nuke = nuke
			end
		else
			if npc.StateFrame % 30 == 0 or (not d.targetvel) then
				local gridtarget = mod:FindRandomFreePosAir(target.Position, 120)
				d.targetvel = (gridtarget - npc.Position):Resized(8)
			end
			if d.targetvel then
				npc.Velocity = mod:Lerp(npc.Velocity, d.targetvel, 0.05)
			end
		end
	elseif d.state == "pickup" then
		if (d.nuke and d.nuke:Exists()) or d.pickedUp then
			if d.nuke then
				npc.Position = d.nuke.Position + Vector(0, -5)
			end
			if sprite:IsFinished("PickUpBomb") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Strain") then
				npc:PlaySound(mod.Sounds.MDP2_PickupStrain,1,1,false,1)
				mod:spritePlay(d.nuke:GetSprite(), "Shake")
				d.nuke.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			elseif sprite:IsEventTriggered("PickUp") then
				d.pickedUp = true
				d.nuke:Remove()
				npc:PlaySound(mod.Sounds.MDP2_PickupPickup,1,1,false,1)
				sfx:Stop(mod.Sounds.MDP2_PickupScream)
			elseif sprite:IsEventTriggered("OhBoy") then
				npc:PlaySound(mod.Sounds.MDP2_PickupOhboy,1,1,false,1)
			elseif sprite:IsEventTriggered("Scream") then
				sfx:Stop(mod.Sounds.MDP2_PickupOhboy)
				npc:PlaySound(mod.Sounds.MDP2_PickupScream, 1, 0, false, 1)
			else
				mod:spritePlay(sprite, "PickUpBomb")
			end
		else
			d.state = "idle"
			d.nuke = nil
		end
	elseif d.state == "dropTheBomb" then
		if sprite:IsFinished("ThrowBomb") then
			d.state = "idle"
			d.pickedUp = false
		elseif sprite:IsEventTriggered("Shoot") then
			npc:PlaySound(mod.Sounds.MDP2_Throw,1,0,false,1)
			sfx:Play(SoundEffect.SOUND_SHELLGAME,2,0,false,math.random(120,130)/100)
			local pos = room:FindFreeTilePosition(target.Position, 10)
			local barrel = Isaac.Spawn(mod.FF.DavyCrockett.ID, mod.FF.DavyCrockett.Var, 0, npc.Position, nilvector, npc)
			barrel.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			barrel.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			local bd = barrel:GetData()
			bd.targpos = pos
			barrel.SpriteOffset = Vector(0, -20)
			bd.state = "inair"
			bd.fallspeed = -15
			bd.fallaccel = 1
			barrel:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			if sprite.FlipX then
				barrel:GetSprite().FlipX = true
			end
			barrel:Update()
		elseif sprite:IsEventTriggered("OhBoy") then

		elseif sprite:IsEventTriggered("Strain") then
			npc:PlaySound(mod.Sounds.MDP2_ThrowStrain,1,0,false,1)
		else
			mod:spritePlay(sprite, "ThrowBomb")
		end
	end


	if d.goPassives then
		--Radioactive tears
		mod.meltdownForsakenTearStuff = {
			{StartPos = Vector(room:GetCenterPos().X - 100, 50),		ShootVec = Vector(5, 10):Resized(9)},
			{StartPos = Vector(room:GetCenterPos().X + 100, 50),		ShootVec = Vector(-5, 10):Resized(9)},
			{StartPos = Vector(room:GetCenterPos().X - 100, 50),		ShootVec = Vector(-5, 10):Resized(9)},
			{StartPos = Vector(room:GetCenterPos().X + 100, 50),		ShootVec = Vector(5, 10):Resized(9)},
			}
		if npc.FrameCount % 25 == 0 then
			d.prevRandomThing = d.prevRandomThing or 1
			local randomThing = d.prevRandomThing
			while randomThing == d.prevRandomThing do
				randomThing = r:RandomInt(#mod.meltdownForsakenTearStuff) + 1
			end
			d.prevRandomThing = randomThing
			local mfts = mod.meltdownForsakenTearStuff[randomThing]
			local proj = Isaac.Spawn(9, 0, 0, mfts.StartPos, mfts.ShootVec:Resized(5), npc):ToProjectile()
			proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			proj.FallingSpeed = -0.1
			proj.FallingAccel = -0.1
			proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
			proj:GetData().projType = "Radioactive"
			proj:GetSprite():ReplaceSpritesheet(0, "gfx/projectiles/radioactive.png")
			proj:GetSprite():LoadGraphics()
			proj:Update()
		end

		--Fire
		if npc.FrameCount % 25 == 1 then
			d.fireRots = d.fireRots or 0
			d.fireRots = d.fireRots + 1
			local vec = Vector(0,7):Rotated(45 * d.fireRots)
			for i = 72, 360, 72 do
				local fire = Isaac.Spawn(1000,7005, 10, npc.Position + Vector(0,-50), vec:Rotated(i) + npc.Velocity, npc):ToEffect()
				fire:GetData().timer = 35
				--fire:GetData().gridcoll = 0
				--fire.Color = Color(0.5,1.5,1,1,0,0,0)
				fire:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_radioactive.png")
				fire:GetSprite():LoadGraphics()
				fire:GetData().timeTested = true
				fire:GetData().initVel = vec:Rotated(i)
				fire:GetData().parentcounter = 1
				fire:GetData().subt10val1 = 1.5
				fire:GetData().subt10val2 = 1
				fire.Parent = npc
				fire:Update()
			end
		end

		--Spawn Nuke
		mod.nukeDrops = mod.nukeDrops or {}
		if mod.GetEntityCount(mod.FF.DavyCrockett.ID, mod.FF.DavyCrockett.Var) < 1 and (not d.pickedUp) and not (#mod.nukeDrops > 0) then
			local spawnPoint = room:FindFreeTilePosition(npc.Position, 120)
			local nuke = Isaac.Spawn(mod.FF.DavyCrockett.ID, mod.FF.DavyCrockett.Var, 0, spawnPoint, nilvector, npc)
			local nd = nuke:GetData()
			nd.state = "drop"
			nuke:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			nuke.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			nuke:Update()
		end
	end
end

function mod:meltdownBombHorseAI(npc, sprite, d)
	local room = game:GetRoom()
	if d.vec then
		d.vec = d.vec * 1.02
		if d.vec:Length() > 40 then
			d.vec = d.vec:Resized(40)
		end
		npc.Velocity = d.vec
	end
	mod:spritePlay(sprite, "Dash")
	if room:IsPositionInRoom(npc.Position, 0) then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
	end
	if npc:CollidesWithGrid() or npc:IsDead() then
		Isaac.Explode(npc.Position, npc, 25)
		for i = 90, 360, 90 do
			Isaac.Explode(npc.Position + Vector(50, 0):Rotated(i), npc, 25)
		end
		if not npc:IsDead() then
			npc:Kill()
		end
	end
end

function mod:davyCrockettAI(npc, subt)
	local d = npc:GetData()
	local sprite = npc:GetSprite()

	if d.state == "drop" then
		npc.SpriteOffset = Vector(0, -5)
		if sprite:IsFinished("Fall") then
			d.state = "sitte"
		elseif sprite:IsEventTriggered("DropThaBomb") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			npc:PlaySound(SoundEffect.SOUND_SHOVEL_DROP, 1, 0, false, 1)
		else
			mod:spritePlay(sprite, "Fall")
		end
	elseif d.state == "sitte" then
		npc.SpriteOffset = Vector(0, -5)
		npc.Velocity = npc.Velocity * 0.5
		if not sprite:IsPlaying("Shake") then
			mod:spritePlay(sprite, "Idle02")
		end
	elseif d.state == "inair" then
		mod:spritePlay(sprite, "InAir")
		local vec = d.targpos - npc.Position
		npc.Position = npc.Position + vec * 0.02
		npc.Velocity = vec * 0.02
		d.fallspeed = d.fallspeed + d.fallaccel
		npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + d.fallspeed)
		if npc.SpriteOffset.Y > 0 then
			npc:Remove()
		end
	end
	if npc:IsDead() or mod.GetEntityCount(mod.FF.Meltdown2.ID, mod.FF.Meltdown2.Var) < 1 then
		--Isaac.Explode(npc.Position, nil, 25)
		game:BombExplosionEffects(npc.Position, 10, DamageFlag.DAMAGE_TNT, mod.ColorNormal, npc, 1, false, true)
		mod.nukeDrops = mod.nukeDrops or {}
		table.insert(mod.nukeDrops, {spawner = npc, pos = npc.Position, count = 0})
		if not npc:IsDead() then
			npc:Remove()
		end
	end
end

function mod.nukePathLogic()
	if mod.nukeDrops and #mod.nukeDrops > 0 then
		local room = game:GetRoom()
		for _, bomb in pairs(mod.nukeDrops) do
			bomb.count = bomb.count + 1
			--if bomb.count < 6 then
				--[[if bomb.count % 2 == 1 then
					local spawnedAny
					for i = 90, 360, 90 do
						local spawnpos = bomb.pos + Vector(bomb.count * 40, 0):Rotated(i)
						if room:IsPositionInRoom(spawnpos, 0) then
							spawnedAny = true
							game:BombExplosionEffects(spawnpos, 10, DamageFlag.DAMAGE_TNT, mod.ColorNormal, bomb.spawner, 1, false, true)
						end
					end
					if not spawnedAny then
						mod.nukeDrops = {}
					end
				end]]
				if bomb.count % 2 == 1 then
					local spawnedAny
					for i = 90, 360, 90 do
						local spawnpos = bomb.pos + Vector(bomb.count * 20, 0):Rotated(i)
						if room:IsPositionInRoom(spawnpos, 0) then
							spawnedAny = true
							local vec = RandomVector():Resized(math.random(10,20)/10)
							local fire = Isaac.Spawn(1000,7005, 20, spawnpos + vec, vec * 0.1, nil):ToEffect()
							fire:GetData().timer = 10
							fire:GetData().timeTested = true
							--fire:GetData().gridcoll = 0
							--fire.Color = Color(0.5,1.5,1,1,0,0,0)
							fire:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_radioactive.png")
							fire:GetSprite():LoadGraphics()
							fire:Update()
						end
					end
					if bomb.count % 4 ~= 1 then
						for i = 45, 315, 90 do
							local spawnpos = bomb.pos + Vector(bomb.count * 5, 0):Rotated(i)
							if room:IsPositionInRoom(spawnpos, 0) then
								spawnedAny = true
								local vec = RandomVector():Resized(math.random(10,20)/10)
								local fire = Isaac.Spawn(1000,7005, 20, spawnpos + vec, vec * 0.1, nil):ToEffect()
								fire:GetData().timer = 10
								fire:GetData().timeTested = true
								--fire:GetData().gridcoll = 0
								--fire.Color = Color(0.5,1.5,1,1,0,0,0)
								fire:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_radioactive.png")
								fire:GetSprite():LoadGraphics()
								fire:Update()
							end
						end
					end
					if bomb.count % 4 ~= 1 and (not spawnedAny) then
						mod.nukeDrops = {}
					end
				end
			--end
		end
	end
end

function mod:nuclearWasteBarrelAI(npc, subt)
	local d = npc:GetData()
	local sprite = npc:GetSprite()

	if d.state == "inair" then
		mod:spritePlay(sprite, "InAir")
		local vec = d.targpos - npc.Position
		npc.Position = npc.Position + vec * 0.02
		npc.Velocity = vec * 0.02
		d.fallspeed = d.fallspeed + d.fallaccel
		npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + d.fallspeed)
		if npc.FrameCount > 5 and (not d.lastAsh or d.lastAsh and npc.Position:Distance(d.lastAsh) > 25) then
			mod.SpawnGunpowder(npc, npc.Position, 999999, 15, nil, nil, nil, nil, "gfx/effects/effect_005_fire_radioactive.png")
			d.lastAsh = npc.Position
		end
		if npc.SpriteOffset.Y > 0 then
			npc.SpriteOffset = nilvector
			d.state = "landed"
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			mod:spritePlay(sprite, "Land")
		end
	elseif d.state == "landed" then
		npc.Velocity = nilvector
		if not sprite:IsPlaying("Land") then
			if npc.FrameCount > 100 then
				npc.SpriteOffset = (Vector((npc.FrameCount % 2 == 0 and 0.6 or -0.6), 0))
			end
			mod:spritePlay(sprite, "Idle")
		end
		if mod.FindClosestFire(npc.Position,30) or npc:HasMortalDamage() or npc.FrameCount > 150 then
			Isaac.Explode(npc.Position, nil, 25)
			for i = 45, 360, 45 do
				local fire = Isaac.Spawn(1000,7005, 0, npc.Position, Vector(12, 0):Rotated(i), npc):ToEffect()
				fire:GetData().timer = 150
				fire:GetData().Friction = 0.9
				--fire:GetData().gridcoll = 0
				--fire.Color = Color(0.5,1.5,1,1,0,0,0)
				fire:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_radioactive.png")
				fire:GetSprite():LoadGraphics()
				fire.Parent = npc
				fire:Update()
			end
			npc:Remove()
		end
	end
end