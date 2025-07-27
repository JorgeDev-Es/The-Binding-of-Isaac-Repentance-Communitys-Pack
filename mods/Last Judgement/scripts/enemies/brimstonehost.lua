local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
	shootCooldown = 25, -- this is what value the state timer checks before shooting
	shootCooldownResetTo = 22, -- after it shoots, this is what the state timer is set to (which is reduced by shooting at it)
	
	shortenShootCooldownOnHitBy = 10,
	shortenShootAnimationOnHitBy = 10,
	
	tracerLifespan = 20,
	tracerColor = Color(1,0.2,0,0.3,0,0,0),
	laserYOffset = -10,
	laserScale = 0.45,
	
	laserEndFrame = 115,
	firstOpenedFrame = 49, -- within this range, shooting the brimstone host shortens its shoot animation by shortenShootAnimationOnHitBy
	lastOpenedFrame = 105,
}

function mod:BrimstoneHostAI(npc)
  local d = npc:GetData()
  local sprite = npc:GetSprite()
  local target = npc:GetPlayerTarget()
  local room = game:GetRoom()
  
  if not d.init then
	d.state = "down"
	d.init = true
  end
  
  if npc.StateFrame < bal.shootCooldown then
	npc.StateFrame = npc.StateFrame + 1
  end
  
  -- down state
  if d.state == "down" then
	sprite:Play("Idle")
	d.shielded = true
	
	if room:CheckLine(npc.Position,target.Position,3,1,false,false) and npc.StateFrame >= bal.shootCooldown then
	  d.state = "shoot"
	end
  
  -- brimstone shooting state
  elseif d.state == "shoot" then
	if sprite:IsEventTriggered("Open") then
		d.shielded = false
	end
	
	if sprite:IsEventTriggered("GetTarget") then
		d.angle = (target.Position - npc.Position):GetAngleDegrees()
		
		local tracer = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, npc.Position + Vector(-10, 0):Rotated(d.angle), Vector(0.001,0), npc):ToEffect()
		tracer.Timeout = bal.tracerLifespan
		tracer.TargetPosition = Vector(1,0):Rotated(d.angle)
		tracer.LifeSpan = bal.tracerLifespan
		tracer:FollowParent(npc)
		tracer.SpriteScale = Vector(2,2)
		tracer.Color = bal.tracerColor
		tracer:Update()
	end
	
	if sprite:IsEventTriggered("Shoot") then
		local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, npc.Position - Vector(0, 10), Vector(2, 0):Rotated(d.angle), npc):ToEffect()
		poof.DepthOffset = 10000
		poof.SpriteScale = Vector(0.5, 0.5)
		poof:Update()
		
		local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector(7, 0):Rotated(d.angle), npc):ToEffect()
		
		-- spawn gibs
		for i = 0, 3 do
			local gibs = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, npc.Position + Vector(20, 0):Rotated(d.angle), Vector(i * 2, 0):Rotated(d.angle), npc)
			gibs.SpriteScale = Vector(1 - (i * 0.1), 1 - (i * 0.1))
			gibs:Update()
		end
		
		local brim = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, npc.Position, Vector(0, 0), npc):ToLaser()
		brim.PositionOffset = Vector(0, bal.laserYOffset)
		brim.SpawnerEntity = npc
		brim.Parent = npc
		brim.Angle = d.angle
		brim.DepthOffset = 10000
		brim.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		brim.CollisionDamage = 0.5
		brim.Mass = 0.5
		brim:SetTimeout(10000)
		brim:AddTearFlags(TearFlags.TEAR_OCCULT)
		brim:Update()
		brim:SetScale(bal.laserScale)
		brim:ClearTearFlags(TearFlags.TEAR_OCCULT)
		d.brim = brim
	end
	
	-- I forgot why I do a separate getframe check here instead of just using the event
	if sprite:IsEventTriggered("ShootEnd") or sprite:GetFrame() > bal.laserEndFrame and d.brim.Timeout > 1 then
		d.brim:SetTimeout(1)
	end
	
	if sprite:IsEventTriggered("Close") then
		d.shielded = true
	end
	
	-- done shooting
	-- note that the cooldown doesn't get fully reset, it's very active since it has a longer telegraph anyway
	-- this way it doesn't break flow (which is a problem I have with normal hosts)
	if sprite:IsFinished("Shoot") then
		npc.StateFrame = bal.shootCooldownResetTo
		d.state = "down"
		d.brim = nil
	elseif not sprite:IsPlaying("Shoot") then
		sprite:Play("Shoot")
	end
  end
  
  npc.Velocity = Vector(0, 0)
end

function mod:BrimstoneHostHurt(npc, sprite, data, amount, damageFlags, source)
	local d = npc:GetData()
	if d.shielded then
		-- the cooldown does get lowered a bit if you're shooting at it though
		-- to make it a little more interesting to deal with one solo
		npc:ToNPC().StateFrame = math.max(0, npc:ToNPC().StateFrame - bal.shortenShootCooldownOnHitBy)
		return false
	else
		local sprite = npc:GetSprite()
		local frame = sprite:GetFrame()
		
		-- just a weird way of making it stay open for less time if you're actively engaging with it
		if sprite:IsPlaying("Shoot") and frame > bal.firstOpenedFrame and frame < bal.lastOpenedFrame then
			sprite:SetFrame(sprite:GetFrame() + bal.shortenShootAnimationOnHitBy)
		end
	end
end