local mod = FiendFolio
local sfx = SFXManager()

function mod:tangoAI(npc) -- Tango
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rand = npc:GetDropRNG()

	if not data.init then
		npc.SplatColor = mod.ColorGhostly
		data.beat = 0
		data.stateFrame = 53 -- Should be 22 numbers less than the minimum data stateFrame.
		data.state = "idle"
		data.init = true
	else
		data.stateFrame = data.stateFrame+1
	end

	if npc.State == 17 then
		npc.Velocity = Vector.Zero
		if sprite:IsFinished("Death") then
			npc:Remove()
		elseif not sprite:IsPlaying("Death") then
			sprite:Play("Death")
		end
	elseif data.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if npc.StateFrame % 40 == 0 then
			local target = mod:FindRandomFreePosAir(targetpos, 120)
			data.targetVel = (target - npc.Position):Resized(2.5)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, data.targetVel, 0.1)
		if data.stateFrame >= 75 and data.stateFrame < 95 and rand:RandomInt(20) == 0 and not mod:isScareOrConfuse(npc) and not mod:isCharm(npc) then
			sprite:Play("AttackStart")
			npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
			data.state = "lagtrain"
		elseif data.stateFrame >= 95 and not mod:isScareOrConfuse(npc) and not mod:isCharm(npc) then
			sprite:Play("AttackStart")
			npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
			data.state = "lagtrain"
		end
	elseif data.state == "lagtrain" then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
		if data.beat == 0 then
			if sprite:IsFinished("AttackStart") then
				local warpPos = (targetpos - npc.Position):Normalized()*45
				data.prevNum = math.random(4)
				sprite:Play(mod.tangoPoses[data.prevNum])
				npc.Position = npc.Position+warpPos
				data.beat = 1
			end
		elseif data.beat < 3 then
			if sprite:IsFinished() then
				local warpPos = (targetpos - npc.Position):Normalized()*45
				if data.beat % 2 == 0 then
					local tangoImage = Isaac.Spawn(1000, 1750, 0, npc.Position, Vector.Zero, npc)
					tangoImage:GetSprite():Play(mod.tangoPoses[data.prevNum])
				else
					local tangoImage = Isaac.Spawn(1000, 1750, 1, npc.Position, Vector.Zero, npc)
					tangoImage:GetSprite():Play(mod.tangoPoses[data.prevNum])
				end
				npc.Position = npc.Position+warpPos
				data.prevNum = mod:nextTangoPose(data.prevNum)
				sprite:Play(mod.tangoPoses[data.prevNum])
				data.beat = data.beat+1
			end
		else
			if sprite:IsFinished("AttackEnd") then
				data.state = "idle"
				data.beat = 0
				data.stateFrame = 0
			elseif sprite:IsFinished() then
				local warpPos = (targetpos - npc.Position):Normalized()*45
				sprite:Play("AttackEnd")
				if data.beat % 2 == 0 then
					local tangoImage = Isaac.Spawn(1000, 1750, 0, npc.Position, Vector.Zero, npc)
					tangoImage:GetSprite():Play(mod.tangoPoses[data.prevNum])
				else
					local tangoImage = Isaac.Spawn(1000, 1750, 1, npc.Position, Vector.Zero, npc)
					tangoImage:GetSprite():Play(mod.tangoPoses[data.prevNum])
				end
				npc.Position = npc.Position+warpPos
				npc:PlaySound(SoundEffect.SOUND_CUTE_GRUNT, 1, 0, false, 1)
			end
		end
	end
end

mod.tangoPoses = {"Image01", "Image02", "Image03", "Image04", "Image05"}
function mod:nextTangoPose(prevnum)
	local tnumber = math.random(10)
	if tnumber > 5 and tnumber < 10 then
		tnumber = tnumber-5
	elseif tnumber == 10 then
		tnumber = tnumber-math.random(6,9)
	end
	if tnumber == prevnum then
		if tnumber > 1 then
			tnumber = tnumber-1
		else
			tnumber = tnumber+1
		end
	end
	return tnumber
end

function mod:tangoafterimageAI(npc) -- Tango's Afterimage
	local sprite = npc:GetSprite()
	local data = npc:GetData()

	if npc.FrameCount > 50 then
		if npc.SubType == 0 then
			for i=0,3 do
				local projectile = Isaac.Spawn(9, 4, 0, npc.Position, Vector(0,8):Rotated(90*i), npc):ToProjectile()
				--projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
			end
		else
			for i=0,3 do
				local projectile = Isaac.Spawn(9, 4, 0, npc.Position, Vector(0,8):Rotated(45+(90*i)), npc):ToProjectile()
				--projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
			end
		end
		local poof = Isaac.Spawn(1000, 12, 0, npc.Position, Vector.Zero, npc)
		poof.Color = FiendFolio.ColorGhostly
		SFXManager():Play(SoundEffect.SOUND_CANDLE_LIGHT,1.2,0,false,1)
		npc:Remove()
	end
end

function mod:chorusAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local rng = npc:GetDropRNG()

	if not data.init then
		npc.SplatColor = mod.ColorGhostly
		data.beat = 0
		data.state = "Idle"
		data.init = true
	else
		npc.StateFrame = npc.StateFrame+1
	end

	if data.state == "Idle" then
		mod:spritePlay(sprite, "Idle")

		if npc.StateFrame % 40 == 0 then
			local fakeTarget = mod:FindRandomFreePosAir(targetpos, 120)
			data.targetVel = (fakeTarget - npc.Position):Resized(2.5)
		end
		npc.Velocity = mod:Lerp(npc.Velocity, (data.targetVel or Vector.Zero), 0.1)

		if npc.StateFrame > 30 then
			data.state = "BlackStars"
			data.beat = 1
			local warpPos = (targetpos - npc.Position):Resized(40)
			sprite:Play("train", true)
			npc.Position = npc.Position+warpPos
			data.choir = {}
		end
	elseif data.state == "BlackStars" then
		if sprite:IsFinished("train") then
			if data.beat < 4 then
				local warpPos = (targetpos - npc.Position):Resized(40)
				sprite:Play("train", true)
				npc.Position = npc.Position+warpPos
				data.beat = data.beat+1

				local bridge = Isaac.Spawn(mod.FF.ChorusAfterimage.ID, mod.FF.ChorusAfterimage.Var, mod.FF.ChorusAfterimage.Sub, npc.Position, Vector.Zero, npc)
				bridge.Parent = npc
				if data.beat % 2 == 0 then
					bridge:GetData().x = true
				else
					bridge:GetData().x = false
				end
				table.insert(data.choir, bridge)
			else
				sprite:Play("train", true)
				npc.Position = mod:FindRandomFreePos(npc, 170, false, true, true)
				data.beat = 0

				local bridge = Isaac.Spawn(mod.FF.ChorusAfterimage.ID, mod.FF.ChorusAfterimage.Var, mod.FF.ChorusAfterimage.Sub, npc.Position, Vector.Zero, npc)
				bridge.Parent = npc
				if data.beat % 2 == 0 then
					bridge:GetData().x = true
				else
					bridge:GetData().x = false
				end

				if not data.whisper then
					sfx:Play(mod.Sounds.ChorusWhisper, 1, 0, false, 0.5)
					data.whisper = true
				else
					data.whisper = nil
					for num,singer in pairs(data.choir) do
						singer:GetData().singing = num*9
						singer:GetData().target = target
					end
					data.choir = {}
				end
				
			end
		else
			mod:spritePlay(sprite, "train")
		end

		npc.Velocity = Vector.Zero
	end
end

function mod:chorusAfterimageEffect(e)
	local data = e:GetData()

	if e.FrameCount > 108 then
		if data.x then
			for i=0,3 do
				local projectile = Isaac.Spawn(9, 4, 0, e.Position, Vector(0,8):Rotated(45+90*i), e):ToProjectile()
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
			end
		else
			for i=0,3 do
				local projectile = Isaac.Spawn(9, 4, 0, e.Position, Vector(0,8):Rotated(90*i), e):ToProjectile()
				projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
			end
		end
		local poof = Isaac.Spawn(1000, 12, 0, e.Position, Vector.Zero, e)
		poof.Color = FiendFolio.ColorGhostly
		--SFXManager():Play(SoundEffect.SOUND_CANDLE_LIGHT,1.2,0,false,1)
		e:Remove()
	end

	if data.singing then
		data.singing = data.singing-1
		if data.singing < 0 then
			local target = data.target
			if not target or not target:Exists() then
				target = Isaac.GetPlayer(0)
			end
			local projectile = Isaac.Spawn(9, 4, 0, e.Position, (target.Position-e.Position):Resized(14), e):ToProjectile()
			projectile.ProjectileFlags = projectile.ProjectileFlags | ProjectileFlags.GHOST
			projectile.FallingSpeed = 0
			projectile.FallingAccel = 0
			data.singing = nil
		end
	end
end