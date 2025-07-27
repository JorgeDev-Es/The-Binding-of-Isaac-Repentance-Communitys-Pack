local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local WORMHOLE_ROCK_ID = mod.ITEM.ROCK.WORMHOLE_ROCK

local PORTAL_TEAR_HEIGHT = -20
local PORTAL_BOMB_OFFSET = Vector(0, -15)

local BURST_COLOR = Color(1,1,1,1)
BURST_COLOR:SetColorize(0.8, 1.5, 1.75, 1.5)

local PROJ_COLOR = Color(1,1,1,1)
PROJ_COLOR:SetColorize(0.75, 1.25, 1.75, 1.0)

local TEARFLAGS_TO_PAUSE = {
	TearFlags.TEAR_SHRINK,
}

local catchRandy

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	catchRandy = nil
end)

function mod:wormholeRockCache(player)
	player:CheckFamiliar(mod.ITEM.FAMILIAR.WORMHOLE_ROCK_PORTAL, player:HasTrinket(WORMHOLE_ROCK_ID) and 1 or 0, player:GetTrinketRNG(WORMHOLE_ROCK_ID), nil, 0)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.wormholeRockCache, CacheFlag.CACHE_FAMILIARS)

local function PortalNearby(pos, dist)
	if dist < 1 then
		return false
	end
	for _, portal in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.ITEM.FAMILIAR.WORMHOLE_ROCK_PORTAL)) do
		if pos:Distance(portal.Position) < dist then
			return true
		end
	end
end

local function GetPortalPos()
	local dist = 80
	local pos
	while not pos or PortalNearby(pos, dist) do
		pos = game:GetRoom():FindFreePickupSpawnPosition(game:GetRoom():GetRandomPosition(25), 25, true, true)
		dist = dist - 2
	end
	return pos
end

local function FindSubPortal(mainPortal)
	local subPortal
	for _, portal in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.ITEM.FAMILIAR.WORMHOLE_ROCK_PORTAL, 1)) do
		if not portal:GetData().OtherPortal or not portal:GetData().OtherPortal:Exists() then
			subPortal = portal
			break
		end
	end
	subPortal = subPortal or Isaac.Spawn(EntityType.ENTITY_FAMILIAR, mod.ITEM.FAMILIAR.WORMHOLE_ROCK_PORTAL, 1, GetPortalPos(), Vector.Zero, mainPortal.Player)
	mainPortal:GetData().OtherPortal = subPortal
	subPortal:GetData().OtherPortal = mainPortal
	return
end

function mod.wormholeRockPortalCollision(hitbox, collider)
	local portal = hitbox.Parent
	local data = portal:GetData()
	local isTear = collider.Type == EntityType.ENTITY_TEAR and not collider:ToTear():HasTearFlags(TearFlags.TEAR_LUDOVICO)
	local isProjectile = collider.Type == EntityType.ENTITY_PROJECTILE
	local isBomb = collider.Type == EntityType.ENTITY_BOMB
	if portal and portal:Exists() and (isTear or isProjectile or isBomb)
			and not data.wormholeRockPortalBurst and portal:GetSprite():IsPlaying("Idle")
			and not collider:GetData().wentThroughWormholeRockPortal then
		collider:GetData().enteredWormholeRockPortalAt = game:GetFrameCount()
		collider:GetData().goingThroughWormholeRockPortal = portal
		collider:GetData().wentThroughWormholeRockPortal = true
		
		data.wormholeRockPortalTears = (data.wormholeRockPortalTears or 0) + 1
		local player = portal.Player or Isaac.GetPlayer()
		local playerTears = 30 / (player.MaxFireDelay + 1)
		
		if data.wormholeRockPosFrames > 30 * 8 and data.wormholeRockPortalTears > playerTears * 3 and player:GetTrinketRNG(WORMHOLE_ROCK_ID):RandomInt(20) == 0 then
			data.wormholeRockPortalTears = 0
			data.wormholeRockPortalBurst = 0
			data.wormholeRockPosFrames = 0
			if data.OtherPortal then
				data.OtherPortal:GetData().wormholeRockPortalTears = 0
				data.OtherPortal:GetData().wormholeRockPortalBurst = 0
				data.OtherPortal:GetData().wormholeRockPosFrames = 0
			end
		end
		
		if collider:ToTear() then
			local tear = collider:ToTear()
			local disabledFlags = 0
			for _, flag in pairs(TEARFLAGS_TO_PAUSE) do
				if tear:HasTearFlags(flag) then
					tear:ClearTearFlags(flag)
					disabledFlags = disabledFlags | flag
				end
			end
			if disabledFlags ~= 0 then
				collider:GetData().wormholeRockPortalDisabledTearFlags = disabledFlags
			end
		end
	end
	return true
end

function mod:wormholeRockPortalOtherCollision(ent, collider)
	if collider.Type == mod.FF.Hitbox.ID and collider.Variant == mod.FF.Hitbox.Var
			and collider.Parent and collider.Parent.Type == EntityType.ENTITY_FAMILIAR
			and collider.Parent.Variant == mod.ITEM.FAMILIAR.WORMHOLE_ROCK_PORTAL then
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.wormholeRockPortalOtherCollision)
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, mod.wormholeRockPortalOtherCollision)

function mod:wormholeRockPortalInit(portal)
	mod.scheduleForUpdate(function()
		portal.Position = GetPortalPos()
	end, 0, nil, true)
	portal:GetSprite():Play("Open", true)
	portal:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	portal.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	portal.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	portal.DepthOffset = -10
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.wormholeRockPortalInit, mod.ITEM.FAMILIAR.WORMHOLE_ROCK_PORTAL) 

function mod:wormholeRockNewRoom()
	for _, portal in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.ITEM.FAMILIAR.WORMHOLE_ROCK_PORTAL)) do
		portal.Position = GetPortalPos()
		portal:GetSprite():Play("Open", true)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, particle)
	if particle:GetData().wormholeRockParticle then
		local targetPos = mod:Lerp(particle.Position, particle.TargetPosition, 0.1)
		particle.Velocity = targetPos - particle.Position
		particle.SpriteScale = mod:Lerp(particle.SpriteScale, Vector.Zero, 0.1)
		local a = mod:Lerp(particle.Color.A, 0, 0.1)
		particle.Color = Color(1,1,1,a,1,1,1)
	end
end, EffectVariant.EMBER_PARTICLE)

local function CupcakeWormExists()
	for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.ITEM.FAMILIAR.RANDY_THE_SNAIL)) do
		if ent:GetData().isCupcakeWorm then
			return true
		end
	end
end

local function MaybeSpawnSomethingFromPortal(portal, rng)
	local player = portal.Player or Isaac.GetPlayer()
	local spawnPos = (rng:RandomInt(2) == 0) and portal.Position or portal:GetData().OtherPortal.Position
	local spawnWorm = not catchRandy and rng:RandomInt(20) == 0 and not CupcakeWormExists()
	local spawnFish = (rng:RandomInt(100) == 0) and not (#Isaac.FindByType(mod.FF.FishNuclearThrone.ID, mod.FF.FishNuclearThrone.Var) > 0)
	local spawnFox = (rng:RandomInt(50) == 0)
	
	if spawnFox then
		Isaac.Spawn(mod.FFID.Connor, (rng:RandomInt(50) == 0) and mod.FF.HoneyFoxWorm.Var or mod.FF.HoneyFox.Var, 0, spawnPos, Vector.Zero, player)
	elseif spawnFish then
		local fish = Isaac.Spawn(mod.FF.FishNuclearThrone.ID, mod.FF.FishNuclearThrone.Var, 0, spawnPos, Vector.Zero, player)
		fish:AddCharmed(EntityRef(player), -1)
	elseif spawnWorm then
		player:GetEffects():AddCollectibleEffect(mod.ITEM.COLLECTIBLE.RANDY_THE_SNAIL)
		catchRandy = spawnPos
	end
end

function mod:wormholeRockPortal(portal)
	local data = portal:GetData()
	local sprite = portal:GetSprite()
	local player = portal.Player or Isaac.GetPlayer()
	local isMainPortal = portal.SubType == 0
	local rng = player:GetTrinketRNG(WORMHOLE_ROCK_ID)
	
	portal.SpriteScale = Vector(1, 1)
	
	if isMainPortal then
		if not data.OtherPortal or not data.OtherPortal:Exists() then
			FindSubPortal(portal)
		end
	elseif not data.OtherPortal or not data.OtherPortal:Exists() then
		portal:Remove()
		return
	end
	
	data.wormholeRockPosFrames = (data.wormholeRockPosFrames or 0) + 1
	
	if not data.wormholeRockPortalBurst then
		if not isMainPortal and data.OtherPortal.Position:Distance(portal.Position) < 20 then
			portal.Position = GetPortalPos()
			sprite:Play("Open", true)
		end
		if portal.FrameCount % 5 == 0 and sprite:IsPlaying("Idle") then
			local center = portal.Position + portal.PositionOffset
			local start = center + Vector(12, 0):Rotated(Random() % 360)
			--local vel = (center - start):Resized(1)
			local vel = Vector.Zero
			local particle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, start, vel, portal):ToEffect()
			particle.Color = Color(1,1,1,1,1,1,1)
			particle.Timeout = 60
			particle.DepthOffset = portal.DepthOffset + 100
			particle:GetData().wormholeRockParticle = true
			particle.TargetPosition = center
		end
	else
		local t = data.wormholeRockPortalBurst / 30
		portal.SpriteOffset = Vector(t * 6 * math.sin(portal.FrameCount * math.pi / 1.5), 0)
		if t >= 1 then
			data.wormholeRockPortalBurst = nil
			portal.SpriteOffset = Vector.Zero
			sprite:Play("Close", true)
			
			local playerTears = 30 / (player.MaxFireDelay + 1)
			
			for i=1, playerTears * 3 do
				local tear = player:FireTear(portal.Position, RandomVector() * player.ShotSpeed * 10, false, true, false, portal)
				--tear.Color = portal.Color
				tear.Velocity = tear.Velocity * (0.5 + rng:RandomFloat()*0.5)
				tear.Scale = tear.Scale * (0.75 + rng:RandomFloat()*0.5)
				--tear.Height = -5 - rng:RandomFloat()*3
				tear.FallingSpeed = tear.FallingSpeed - 10 - rng:RandomFloat()*5
				tear.FallingAcceleration = 1.5 + rng:RandomFloat()*1.0
			end
			
			if isMainPortal then
				MaybeSpawnSomethingFromPortal(portal, rng)
			end
			
			local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, portal.Position + portal.PositionOffset, Vector.Zero, nil)
			eff.Color = BURST_COLOR
			eff.DepthOffset = 20
			local eff2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, portal.Position + portal.PositionOffset, Vector.Zero, nil)
			eff2.Color = BURST_COLOR
			eff2.DepthOffset = 20
			sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
		else
			data.wormholeRockPortalBurst = data.wormholeRockPortalBurst + 1
		end
	end
	
	portal.PositionOffset = Vector(0, -20)
	
	if sprite:IsFinished("Close") then
		portal.Position = GetPortalPos()
		sprite:Play("Open", true)
	end
	if sprite:IsFinished("Open") then
		sprite:Play("Idle", true)
	end
	
	portal:PickEnemyTarget(9999, 13, 1 << 0 | 2 << 0)
	
	if not portal.Child or not portal.Child:Exists() then
		local hitbox = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 0, portal.Position, Vector.Zero, portal)
		
		local hdata = hitbox:GetData()
		hdata.PositionOffset = Vector.Zero
		hdata.FixToSpawner = true
		hdata.AllowKnockback = false
		hdata.OnCollide = mod.wormholeRockPortalCollision
		
		hitbox.CollisionDamage = 0
		hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		
		portal.Child = hitbox
		hitbox.Parent = portal
		hitbox:AddCharmed(EntityRef(player), -1)
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.wormholeRockPortal, mod.ITEM.FAMILIAR.WORMHOLE_ROCK_PORTAL)

local RANDOM_TEARFLAGS = {
	TearFlags.TEAR_SPECTRAL,
	TearFlags.TEAR_PIERCING,
	TearFlags.TEAR_PULSE,
	TearFlags.TEAR_WIGGLE,
	TearFlags.TEAR_SPIRAL,
	TearFlags.TEAR_FLAT,
	TearFlags.TEAR_SQUARE,
	TearFlags.TEAR_TURN_HORIZONTAL,
	TearFlags.TEAR_BOOMERANG,
}

local TEAR_EFFECTS = {
	{ -- NOTHING!
		function(tear) end, 100
	},
	{ -- HOMING
		function(tear)
			if not tear:HasTearFlags(TearFlags.TEAR_HOMING) then
				tear:AddTearFlags(TearFlags.TEAR_HOMING)
			end
		end, 75
	},
	{ -- ZOOM
		function(tear)
			tear.Velocity = tear.Velocity * 1.5
		end, 10
	},
	{ -- MISC TEARFLAG
		function(tear, rng)
			local flag = RANDOM_TEARFLAGS[rng:RandomInt(#RANDOM_TEARFLAGS)+1]
			if not tear:HasTearFlags(flag) then
				tear:AddTearFlags(flag)
			end
		end, 50
	},
	{ -- DAMAGE
		function(tear)
			tear.CollisionDamage = tear.CollisionDamage * 2
			tear.Scale = tear.Scale * 1.25
			if tear:GetData().wormholeRockPortalExitScale then
				tear:GetData().wormholeRockPortalExitScale = tear:GetData().wormholeRockPortalExitScale * 1.5
			end
		end, 20
	},
	{ -- DUPLICATE
		function(tear, rng)
			local player = (tear.Parent and tear.Parent:ToPlayer()) or (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()) or Isaac.GetPlayer()
			local vel = tear.Velocity:Rotated((5 + rng:RandomInt(6)) * (rng:RandomInt(2) == 0 and -1 or 1))
			local newTear = player:FireTear(tear.Position - tear.Velocity, vel, false, true, false, tear)
			if newTear.Variant ~= tear.Variant then newTear:ChangeVariant(tear.Variant) end
			newTear.TearFlags = tear.TearFlags
			newTear.Height = tear.Height
			newTear.FallingAcceleration = tear.FallingAcceleration
			newTear.FallingSpeed = tear.FallingSpeed
			newTear.Scale = tear.Scale
			newTear.Color = tear.Color
			newTear:GetData().wormholeRockPortalExitScale = tear:GetData().wormholeRockPortalExitScale
			newTear:GetData().wormholeRockPortalExitHeight = tear:GetData().wormholeRockPortalExitHeight
			newTear:GetData().exitedWormholeRockPortalAt = tear:GetData().exitedWormholeRockPortalAt
			newTear:GetData().wentThroughWormholeRockPortal = true
		end, 33
	},
}

function mod:WormholeRockPostFireTear(tear, power, rng)
	local applyEffect = StageAPI.WeightedRNG(TEAR_EFFECTS, rng)
	applyEffect(tear, rng)
	
	tear.CollisionDamage = tear.CollisionDamage * power
	if power > 1.0 then
		local mult = mod:Lerp(power, 1.0, 0.75)
		tear.Scale = tear.Scale * mult
		if tear:GetData().wormholeRockPortalExitScale then
			tear:GetData().wormholeRockPortalExitScale = tear:GetData().wormholeRockPortalExitScale * mult
		end
	end
end

function mod:WormholeRockPostFireProjectile(proj, power, rng)
	proj.Color = PROJ_COLOR
	proj:ToProjectile():AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES)
	
	proj.CollisionDamage = proj.CollisionDamage * power
end

local BOMB_FLAGS = {
	{TearFlags.TEAR_HOMING, 40},
	{TearFlags.TEAR_GOLDEN_BOMB, 20},
	{TearFlags.TEAR_FAST_BOMB, 20},
	{TearFlags.TEAR_SAD_BOMB, 4},
	{TearFlags.TEAR_CROSS_BOMB, 4},
	{TearFlags.TEAR_BLOOD_BOMB, 4},
	{TearFlags.TEAR_BRIMSTONE_BOMB, 4},
	{TearFlags.TEAR_GLITTER_BOMB, 4},
}

function mod:WormholeRockPostFireBomb(bomb, power, rng)
	bomb.ExplosionDamage = bomb.ExplosionDamage * power
	if power > 1.0 then
		local mult = mod:Lerp(power, 1.0, 0.75)
		bomb.SpriteScale = bomb.SpriteScale * mult
		if bomb:GetData().wormholeRockPortalExitScale then
			bomb:GetData().wormholeRockPortalExitScale = bomb:GetData().wormholeRockPortalExitScale * mult
		end
	end
	
	if rng:RandomInt(3) == 0 then
		local flag = StageAPI.WeightedRNG(BOMB_FLAGS, rng)
		bomb:AddTearFlags(flag)
		
		if flag == TearFlags.TEAR_FAST_BOMB then
			bomb.Velocity = bomb.Velocity * 2
		end
		if flag == TearFlags.TEAR_GOLDEN_BOMB then
			bomb.ExplosionDamage = bomb.ExplosionDamage * 1.5
		end
	end
end

-- Tears, Bombs, or enemy Projectiles
function mod:wormholeRockProjUpdate(proj)
	local data = proj:GetData()
	
	if data.enteredWormholeRockPortalAt and data.goingThroughWormholeRockPortal and data.goingThroughWormholeRockPortal:Exists() then
		local entryPortal = data.goingThroughWormholeRockPortal
		local exitPortal = entryPortal:GetData().OtherPortal
		
		if not data.wormholeRockPortalEntryData then
			data.wormholeRockPortalEntryData = {
				Pos = proj.Position,
				Vel = proj.Velocity,
				Scale = proj.Scale or Vector(proj.SpriteScale.X, proj.SpriteScale.Y),
				Height = proj.Height,
				Offset = Vector(proj.SpriteOffset.X, proj.SpriteOffset.Y),
			}
		end
		
		if not data.wormholeRockPortalRotateDir then
			local rotateDir = 1
			if proj.Velocity.X < 0 then
				rotateDir = rotateDir * -1
			end
			if (proj.Position - entryPortal.Position).Y > 0 then
				rotateDir = rotateDir * -1
			end
			data.wormholeRockPortalRotateDir = rotateDir
		end
		
		if not data.wormholeRockPortalFrozenValues then
			data.wormholeRockPortalFrozenValues = {
				FallingAcceleration = proj.FallingAcceleration,
				FallingAccel = proj.FallingAccel,
				FallingSpeed = proj.FallingSpeed,
				WaitFrames = proj.WaitFrames,
			}
		end
		
		local t = game:GetFrameCount() - data.enteredWormholeRockPortalAt
		local dur = 15
		local targetPos = mod:Lerp(data.wormholeRockPortalEntryData.Pos, entryPortal.Position, t / dur)
		local scale = data.wormholeRockPortalEntryData.Scale * (1 - (t / dur))
		if proj:ToBomb() then
			proj.SpriteScale = scale
			if not data.wormholeRockPortalBombFuse then
				if proj:GetSprite():IsPlaying("Pulse") then
					data.wormholeRockPortalBombFuse = math.max(55 - proj:GetSprite():GetFrame(), 10)
				else
					data.wormholeRockPortalBombFuse = 20
				end
			end
			proj:SetExplosionCountdown(data.wormholeRockPortalBombFuse)
			proj.SpriteOffset = mod:Lerp(data.wormholeRockPortalEntryData.Offset, PORTAL_BOMB_OFFSET, t / dur)
		else
			proj.Scale = scale
			proj.Height = mod:Lerp(data.wormholeRockPortalEntryData.Height, PORTAL_TEAR_HEIGHT, t / dur)
		end
		targetPos = (targetPos - entryPortal.Position):Rotated(t * math.pi * 5 * data.wormholeRockPortalRotateDir) + entryPortal.Position
		proj.Velocity = targetPos - proj.Position
		
		for k, v in pairs(data.wormholeRockPortalFrozenValues) do
			if proj[k] then
				proj[k] = v
			end
		end
		
		if t >= dur then
			data.enteredWormholeRockPortalAt = nil
			proj.Position = exitPortal.Position
			if exitPortal.Target and exitPortal.Target:Exists() then
				proj.Velocity = (exitPortal.Target.Position - exitPortal.Position):Resized(data.wormholeRockPortalEntryData.Vel:Length())
			else
				proj.Velocity = data.wormholeRockPortalEntryData.Vel
			end
			
			local scale = data.wormholeRockPortalEntryData.Scale * 0.5
			if proj:ToBomb() then
				proj.SpriteScale = scale
				proj.SpriteOffset = PORTAL_BOMB_OFFSET
				data.wormholeRockPortalExitOffset = data.wormholeRockPortalEntryData.Offset
			else
				proj.Scale = scale
				proj.Height = PORTAL_TEAR_HEIGHT
				data.wormholeRockPortalExitHeight = data.wormholeRockPortalEntryData.Height
			end
			data.wormholeRockPortalExitScale = data.wormholeRockPortalEntryData.Scale
			data.exitedWormholeRockPortalAt = game:GetFrameCount()
			data.wormholeRockPortalEntryData = nil
			data.wormholeRockPortalFrozenValues = nil
			
			local player = exitPortal.Player or Isaac.GetPlayer()
			local rng = player:GetTrinketRNG(WORMHOLE_ROCK_ID)
			local power = 1.0 + 0.5 * FiendFolio.GetGolemTrinketPower(player, WORMHOLE_ROCK_ID)
			
			if proj:ToProjectile() then
				mod:WormholeRockPostFireProjectile(proj, power, rng)
			elseif proj:ToTear() then
				if data.wormholeRockPortalDisabledTearFlags then
					proj:AddTearFlags(data.wormholeRockPortalDisabledTearFlags)
				end
				mod:WormholeRockPostFireTear(proj, power, rng)
			elseif proj:ToBomb() then
				mod:WormholeRockPostFireBomb(proj, power, rng)
			end
		end
	end
	
	if data.exitedWormholeRockPortalAt then
		local t = game:GetFrameCount() - data.exitedWormholeRockPortalAt
		local dur = 10
		
		if data.wormholeRockPortalExitHeight then
			proj.Height = mod:Lerp(proj.Height, data.wormholeRockPortalExitHeight, t/dur)
		end
		if data.wormholeRockPortalExitOffset then
			proj.SpriteOffset = mod:Lerp(proj.SpriteOffset, data.wormholeRockPortalExitOffset, t/dur)
		end
		if data.wormholeRockPortalExitScale then
			local n = math.min(2*t/dur, 1)
			if proj:ToBomb() then
				proj.SpriteScale = mod:Lerp(proj.SpriteScale, data.wormholeRockPortalExitScale, n)
			else
				proj.Scale = mod:Lerp(proj.Scale, data.wormholeRockPortalExitScale, n)
			end
		end
		
		if t >= dur then
			if data.wormholeRockPortalExitHeight then
				proj.Height = data.wormholeRockPortalExitHeight
			end
			if data.wormholeRockPortalExitOffset then
				proj.SpriteOffset = data.wormholeRockPortalExitOffset
			end
			if data.wormholeRockPortalExitScale then
				if proj:ToBomb() then
					proj.SpriteScale = data.wormholeRockPortalExitScale
				else
					proj.Scale = data.wormholeRockPortalExitScale
				end
			end
			data.exitedWormholeRockPortalAt = nil
			data.wormholeRockPortalExitHeight = nil
			data.wormholeRockPortalExitScale = nil
			data.wormholeRockPortalExitOffset = nil
		end
	end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, randy)
	if catchRandy then
		randy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		randy.Position = catchRandy
		randy.Visible = false
		randy:GetData().isCupcakeWorm = true
		
		randy:GetSprite():ReplaceSpritesheet(0, "gfx/familiar/randy the snail/randy_wormhole.png")
		randy:GetSprite():LoadGraphics()
		
		mod.scheduleForUpdate(function()
			randy.Visible = true
			randy.Position = catchRandy
			catchRandy = false
			randy.Velocity = RandomVector() * 20
		end, 0)
	end
end, mod.ITEM.FAMILIAR.RANDY_THE_SNAIL)

function mod:WormholeRockFoxUpdate(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	
	if npc.StateFrame < 1 then
		data.moving = not data.moving
		npc.StateFrame = 30 + Random() % 60
	else
		npc.StateFrame = npc.StateFrame - 1
	end
	
	local anim = "Idle"
	
	if data.moving then
		npc.Pathfinder:MoveRandomly()
		
		local dir = mod:GetOrientationFromVector(npc.Velocity)
		if dir == "Left" or dir == "Right" then
			anim = "WalkHori"
		elseif dir == "Down" then
			anim = "WalkDown"
		elseif dir == "Up" then
			anim = "WalkUp"
		end
	else
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
	end
	
	if not sprite:IsPlaying(anim) then
		sprite:Play(anim, true)
	end
	
	sprite.PlaybackSpeed = math.min(npc.Velocity:Length() / 2, 1)
	
	if npc.Velocity.X > 1 then
		sprite.FlipX = false
	elseif npc.Velocity.X < -1 then
		sprite.FlipX = true
	end
end

function mod:WormholeRockFoxWormUpdate(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	
	if not sprite:IsPlaying("Hop") then
		sprite:Play("Hop", true)
	end
	
	if sprite:IsEventTriggered("Hop") then
		npc.Velocity = npc.Velocity + RandomVector() * 5
		data.jumping = true
	end
	
	if sprite:IsEventTriggered("Land") then
		sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 0.5, 0, false, 1.5)
		data.jumping = false
	end
	
	if not data.jumping then
		npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
	end
	
	if npc.Velocity.X > 1 then
		sprite.FlipX = true
	elseif npc.Velocity.X < -1 then
		sprite.FlipX = false
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if npc.Variant == mod.FF.HoneyFox.Var then
		mod:WormholeRockFoxUpdate(npc)
	elseif npc.Variant == mod.FF.HoneyFoxWorm.Var then
		mod:WormholeRockFoxWormUpdate(npc)
	end
end, mod.FFID.Connor)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, npc)
	if npc.Variant == mod.FF.HoneyFox.Var or npc.Variant == mod.FF.HoneyFoxWorm.Var then
		local effect = Isaac.Spawn(mod.FF.DummyEffect.ID, mod.FF.DummyEffect.Var, mod.FF.DummyEffect.Sub, npc.Position, Vector.Zero, nil):ToEffect()
		effect:GetSprite():Load(npc:GetSprite():GetFilename(), true)
		effect:GetSprite():Play("Death", true)
		effect:GetSprite().FlipX = npc:GetSprite().FlipX
		effect.Visible = true
	end
end, mod.FFID.Connor)

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, function(_, npc)
	if (npc.Variant == mod.FF.HoneyFox.Var or npc.Variant == mod.FF.HoneyFoxWorm.Var) and npc.FrameCount < 30 then
		return false
	end
end, mod.FFID.Connor)

local cleaverDetected

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, var, subt, _, _, _, seed)
	if id == mod.FFID.Connor and var == mod.FF.HoneyFox.Var and cleaverDetected and cleaverDetected < game:GetFrameCount() and game:GetFrameCount() - cleaverDetected <= 3 then
		return {mod.FFID.Connor, mod.FF.HoneyFoxWorm.Var, 0, seed}
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	cleaverDetected = game:GetFrameCount()
end, CollectibleType.COLLECTIBLE_MEAT_CLEAVER)
