local mod = FiendFolio
local game = Game()

local targets = {
	Vector(40, -80),
	Vector(80, -40),
	Vector(80, 40),
	Vector(40, 80),
	Vector(-40, 80),
	Vector(-80, 40),
	Vector(-80, -40),
	Vector(-40, -80),
}

local GimpState = {
	IDLE	= 1,
	LAUNCH	= 2,
}

function getTargetSteps(npc)
	local room = game:GetRoom()
	local data = npc:GetData()
	local fromPosition = room:GetGridPosition(room:GetGridIndex(npc.Position))
	local distance = 9e9
	local player = npc:GetPlayerTarget()
	local target
	local step

	for i = 1, 8 do
		local check = targets[i]
		local targetPos = fromPosition + check

		if room:GetGridCollisionAtPos(targetPos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(targetPos, 0) then
			for _, test in pairs({Vector(check.X, 0), Vector(0, check.Y)}) do
				local stepCheck = test + fromPosition

				if room:GetGridCollisionAtPos(stepCheck) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(targetPos, 0) then
					if targetPos:Distance(player.Position) < distance then
						target = targetPos
						step = stepCheck
						distance = targetPos:Distance(player.Position)
					end

					break
				end
			end
		end
	end

	data.target = target
	data.step = step
end

function getLeapTarget(npc)
	local data = npc:GetData()
	local room = game:GetRoom()
	local player = npc:GetPlayerTarget()
	local fromPosition = room:GetGridPosition(room:GetGridIndex(player.Position))
	local distance = 9e9
	local target

	for i = 1, 8 do
		local check = targets[i]
		local targetPos = fromPosition + check

		if room:GetGridCollisionAtPos(targetPos) == GridCollisionClass.COLLISION_NONE and room:IsPositionInRoom(targetPos, 0) then
			if targetPos:Distance(npc.Position) < distance then
				target = targetPos
				distance = targetPos:Distance(npc.Position)
			end
		end
	end

	data.leapTarget = target
end

return {
	Init = function(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

		local data = npc:GetData()
		data.delay = 60
		data.leaps = 0
		data.target = Vector.Zero
		data.step = Vector.Zero
		data.leapTarget = Vector.Zero
		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 35)
	end,

	AI = function(npc)
		local sprite = npc:GetSprite()
		local data = npc:GetData()
		local rng = data.rng

		if sprite:IsFinished("Appear") then
			sprite:Play("Idle")
		elseif sprite:IsFinished("Attack") then
			sprite:Play("Idle")
			data.delay = npc.FrameCount + 30
		elseif sprite:IsFinished("Walk") then
			data.leaps = data.leaps + 1
			sprite:Play("Walk", true)

			if data.leaps % 2 == 0 then
				if rng:RandomFloat() < 1/3 then
					sprite:Play("Attack")
					npc:PlaySound(SoundEffect.SOUND_MOTHER_ISAAC_RISE, 1, 0, false, 1)
				else
					getTargetSteps(npc)
				end
			end
		end

		if sprite:IsPlaying("Idle") then
			if npc.FrameCount > data.delay then
				sprite:Play("Walk")
				getTargetSteps(npc)
			end
		end

		if sprite:IsPlaying("Attack") and not sprite:WasEventTriggered("Jump") then
			npc.Velocity = npc.Velocity * 0.6
		end

		if sprite:IsEventTriggered("Jump") then
			local jumpLength
			local targetPos

			if sprite:IsPlaying("Attack") then
				getLeapTarget(npc)
				npc:PlaySound(SoundEffect.SOUND_SKIN_PULL, 1, 0, false, 1)
				npc:PlaySound(SoundEffect.SOUND_GHOST_SHOOT, 1, 0, false, 1.1 + math.random() / 10)

				jumpLength = 16
				targetPos = data.leapTarget
			else
				jumpLength = 12
				targetPos = data.leaps % 2 == 0 and data.step or data.target
			end

			npc.Velocity = (targetPos - npc.Position) / jumpLength
			if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) or sprite:IsPlaying("Attack") then
				sprite.FlipX = npc.Velocity.X > 0
			end
		end

		if sprite:IsEventTriggered("Land") then
			npc:PlaySound(SoundEffect.SOUND_MOTHER_ISAAC_HIT, 0.3, 0, false, 1.1 + math.random() / 10)
		end

		if sprite:WasEventTriggered("Land") then
			npc.Velocity = npc.Velocity * 0.6
		end

		if sprite:IsEventTriggered("Sound2") then
			npc:PlaySound(SoundEffect.SOUND_WHIP_HIT, 1, 0, false, 1)
		end
	end,

	Collision = function(npc, collider)
		if not npc:GetSprite():IsPlaying("Idle") and collider.Type == mod.FF.Gimp.ID and collider.Variant == mod.FF.Gimp.Var then
			local data = collider:GetData()
			
			data.state = GimpState.LAUNCH
			data.launchSpeed = -10
			data.launchAccel = 0.5

			collider.SpriteOffset = Vector(0, -5)
			collider.EntityCollisionClass = 0
			collider.Velocity = (collider.Position - npc.Position):Resized(npc.Velocity:Length())
			collider:GetSprite():Play("Launched" .. math.random(2))
		end
	end,
}