local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Lots of code from Lightning Flies
function mod:VoltAI(npc, sprite, npcdata)
	npcdata.flies = {}
	npcdata.LasersToSpawn = npcdata.LasersToSpawn or 0
	
	local charged_duration = 60
	local fly_duration = 60
	local move_speed = 2
	local target = npc:GetPlayerTarget()
	local targetpos = mod:confusePos(npc, target.Position)
	
	mod:FlipSprite(sprite, npc.Position, target.Position)

	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		npc:Morph(13, 0, 0, -1)
	end

	if npcdata.state == "init" then
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc.StateFrame = 0
		npc.SplatColor = Color(0,0,0,1,0.7,0.8,1)
		npcdata.state = "fly"
	elseif npcdata.state == "fly" then
		if not sprite:IsPlaying("Fly") then
			sprite:Play("Fly",0)
			npc.StateFrame = 0
		end

		npc.StateFrame = npc.StateFrame + 1
		if npc.StateFrame >= fly_duration and not mod:isScareOrConfuse(npc) then
			npcdata.state = "charged"
			npc.StateFrame = 0
		end
	elseif npcdata.state == "charged" then
		if not sprite:IsPlaying("FlyCharged") then
			sprite:Play("FlyCharged",0)
			npc.StateFrame = 0
		end
		move_speed = 3;

		--Sort out later

		npc.StateFrame = npc.StateFrame + 1
		if npc.StateFrame >= charged_duration or mod:isScareOrConfuse(npc) then
			npcdata.state = "fly"
			sfx:Stop(mod.Sounds.LightningFlyBuzzLoop)
			npc.StateFrame = 0
		end
	else npcdata.state = "init" end

	if npcdata.state == "charged" and not sfx:IsPlaying(mod.Sounds.LightningFlyBuzzLoop) and not npc:HasMortalDamage() then
		sfx:Play(mod.Sounds.LightningFlyBuzzLoop, 0.5, 0, true, 1)
	end
	
	if npcdata.LasersToSpawn > 0 and npc.FrameCount % 2 == 0 then
		npcdata.LasersToSpawn = npcdata.LasersToSpawn - 1
		
		local laser = EntityLaser.ShootAngle(10, npc.Position, mod:RandomInt(1, 360), 5, Vector(0,-20), npc)
		laser.DepthOffset = npc.DepthOffset - 1
		laser.MaxDistance = 90
		laser.Mass = 0
		laser.CollisionDamage = 0
	end

	if npc:IsDead() then
		local burst = Isaac.Spawn(1000, 3, 0, npc.Position, nilvector, npc):ToEffect()
		burst.SpriteOffset = Vector(0,-14)
		
		for i = mod:RandomInt(0, 72), 360, 72 do
			local laser = Isaac.Spawn(1000, 1737, 0, npc.Position, Vector.FromAngle(i):Resized(7), npc):ToEffect()
			laser:GetData().delay = 20
			laser:GetData().timeout = 8
			laser:GetData().DoesntPush = true
			laser:Update()
			laser:GetData().offSetSpawn = Vector(0,-25)
			laser.Parent = npc
			laser:Update()
			laser.Color = Color(0,0,0,1,0.7,0.8,1)
		end
	end

	--[[if npc:HasMortalDamage() then
		sfx:Stop(mod.Sounds.LightningFlyBuzzLoop)
	end]]

	npcdata.targetvelocity = mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(move_speed))
	npc.Velocity = mod:Lerp(npcdata.targetvelocity, npc.Velocity, 0.8)
end

function mod:VoltHurt(npc, amount)
	local npcdata = npc:GetData()
	if npcdata.state == "charged" then
		if npc:ToNPC().StateFrame > 10 and amount > 0 then
			npcdata.LasersToSpawn = math.min(npcdata.LasersToSpawn + mod:RandomInt(1, 4), 5)
		end
		return false
	end
end