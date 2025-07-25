local mod = RegisterMod("Dr. Fetus Synergies", 1)

local game = Game()
local nullVector = Vector.Zero

--Please don't judge my spaghetti code, I'm italian
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
  if not bomb.SpawnerEntity then return end
  local player = bomb.SpawnerEntity:ToPlayer()
  if not player then return end
  if not bomb.IsFetus then return end
  local data = bomb:GetData()
  local room = game:GetRoom()
  data.BaseExplosionDamage = data.BaseExplosionDamage or bomb.ExplosionDamage
  data.BaseRadiusMultiplier = data.BaseRadiusMultiplier or bomb.RadiusMultiplier
  if bomb:IsDead() then
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
	  for i = -1, 2 do
		local laser = player:FireBrimstone(Vector.FromAngle(i * 90), bomb, 1)
		laser.DisableFollowParent = true
		laser.Position = bomb.Position
	  end
	elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then
	  for i = -1, 2 do
		local laser = player:FireBrimstone(Vector.FromAngle(i * 90), bomb, 0.5)
		laser.DisableFollowParent = true
		laser.Position = bomb.Position
	  end
	  for i = 1, math.random(38, 91) do
		local e = Isaac.Spawn(1000, 111, 1, bomb.Position, RandomVector() * math.random(-10, 10), nil):ToEffect()
		e.Scale = math.random(4, 9) / 10
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then e.Scale = e.Scale * 2 end
		e.Timeout = math.random(21, 37)
	  end
	  local blood = Isaac.Spawn(1000, 2, 2, bomb.Position, nullVector, nil)
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then blood.Scale = blood.Scale * 2 end
	  local r = 50
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then r = r * 2 end
	  for _, npc in pairs(Isaac.FindInRadius(bomb.Position, r, EntityPartition.ENEMY)) do
		if npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED) then
		  npc:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
		end
	  end
	elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL then
	  for i = -1, 2 do
		local laser = player:FireBrimstone(Vector.FromAngle(i * 90), bomb, 1)
		laser.DisableFollowParent = true
		laser.Position = bomb.Position
		laser.MaxDistance = math.max(60, 60 + ((player.TearRange - 110) / 5)) --I think this is pretty close to the in-game formula
	  end
	end
	if bomb:HasTearFlags(TearFlags.TEAR_SHIELDED) then --I really thought this flag already had a synergy, but it doesn't :(
	  for _, p in pairs(Isaac.FindInRadius(bomb.Position, 50, EntityPartition.BULLET)) do
		p:Remove()
	  end
	end
	if bomb:HasTearFlags(TearFlags.TEAR_LASERSHOT) then
	  for i = 1, 8 do
		local tri = EntityLaser.ShootAngle(3, bomb.Position, i * 45, 30, Vector.FromAngle(i * 45) * 5, player)
		tri.DisableFollowParent = true
		tri.MaxDistance = 30
		tri.Velocity = Vector.FromAngle(i * 45) * 10
	  end
	end
	if bomb:HasTearFlags(TearFlags.TEAR_ROCK) then
	  Isaac.Spawn(1000, 61, 0, bomb.Position, nullVector, player).Parent = player
	  game:ShakeScreen(10)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HEMOPTYSIS) then
	  for i = 1, math.random(38, 91) do
		local e = Isaac.Spawn(1000, 111, 1, bomb.Position, RandomVector() * math.random(-10, 10), nil):ToEffect()
		e.Scale = math.random(4, 9) / 10
		e.Timeout = math.random(21, 37)
	  end
	  Isaac.Spawn(1000, 2, 2, bomb.Position, nullVector, nil)
	  for _, npc in pairs(Isaac.FindInRadius(bomb.Position, 50, EntityPartition.ENEMY)) do
		if npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED) then
		  npc:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
		end
	  end
	end
	if bomb:HasTearFlags(TearFlags.TEAR_RIFT) then
	  Isaac.Spawn(1000, 180, 0, bomb.Position, nullVector, bomb):ToEffect().Scale = bomb.RadiusMultiplier
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then
	  for i = 1, math.random(7, 12) do
		local mult = 23
		local rand = Vector(math.random(-mult, mult), math.random(-mult, mult))
		local tear = player:FireTear(bomb.Position + rand, data.NeptunusStartingVelocity or nullVector, false, true, false, player, math.random(7, 12) / 10)
		tear.FallingSpeed = math.random(-32, -3)
		tear.FallingAcceleration = 2 + math.random(-2, 4) / 10
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE) then
	  for i = 1, math.random(0, 2) do
		Isaac.Spawn(3, 234, 0, bomb.Position, Vector(math.random(-5, 5), math.random(-5, 5)), player):ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	  end
	end
  end
  if bomb.FrameCount == 1 then
	if bomb:HasTearFlags(TearFlags.TEAR_POP) then
	  bomb:SetExplosionCountdown(90)
	  bomb.Velocity = bomb.Velocity * 1.2
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
	if not data.TechLaser then
	  local test = EntityLaser.ShootAngle(2, bomb.Position, ((player.Position - bomb.Position):Normalized()):GetAngleDegrees(), 10, nullVector, player)
	  for _, l in pairs(Isaac.FindByType(7, 2)) do
		if l.Index == test.Index then
		  data.TechLaser = l:ToLaser()
		  break
		end
	  end
	  data.TechLaser.DisableFollowParent = true
	  data.TechLaser.MaxDistance = bomb.Position:Distance(player.Position) - 10
	  data.TechLaser.Position = bomb.Position
	  data.TechLaser.CollisionDamage = player.Damage * 2
	  data.TechLaser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	else
	  data.TechLaser.MaxDistance = bomb.Position:Distance(player.Position) - 10
	  data.TechLaser.Angle = ((player.Position - bomb.Position):Normalized()):GetAngleDegrees()
	  data.TechLaser:SetTimeout(2)
	  data.TechLaser.Position = bomb.Position
	end
  end
  if bomb:HasTearFlags(TearFlags.TEAR_GLOW) then
	if bomb:IsDead() and data.GodAuraTear then
	  data.GodAuraTear:Remove()
	end
	if not data.GodAuraTear then
	  data.GodAuraTear = Isaac.Spawn(2, 0, 0, bomb.Position, nullVector, player):ToTear()
	  data.GodAuraTear:GetSprite():ReplaceSpritesheet(0, "")
	  data.GodAuraTear:GetSprite():LoadGraphics()
	  data.GodAuraTear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	  data.GodAuraTear:AddTearFlags(TearFlags.TEAR_PIERCING)
	  data.GodAuraTear:AddTearFlags(TearFlags.TEAR_GLOW)
	  data.GodAuraTear.CollisionDamage = player.Damage
	  data.GodAuraTear.Scale = 1.5
	  data.GodAuraTear:Update()
	else
	  data.GodAuraTear.Position = bomb.Position
	  data.GodAuraTear.Height = -10
	end
  end
  if bomb:HasTearFlags(TearFlags.TEAR_WAIT) then
	if player:GetFireDirection() ~= -1 then
	  data.GravityVelocity = data.GravityVelocity or bomb.Velocity
	  if data.GravityVelocity ~= "done" then
		bomb.Velocity = nullVector
	  end
	elseif data.GravityVelocity then
	  if data.GravityVelocity ~= "done" then
		bomb.Velocity = data.GravityVelocity
		data.GravityVelocity = "done"
	  end
	end
  end
  if bomb:HasTearFlags(TearFlags.TEAR_BOUNCE) then
	data.BombBounceCooldown = data.BombBounceCooldown or 0
	if data.BombBounceCooldown > 0 then
	  data.BombBounceCooldown = data.BombBounceCooldown - 1
	elseif bomb:CollidesWithGrid() then
	  bomb.Velocity = bomb.Velocity:Rotated(360) * 3
	  data.BombBounceCooldown = 5
	end
  end
  if bomb:HasTearFlags(TearFlags.TEAR_CONTINUUM) then
	if bomb:CollidesWithGrid() and data.WaitingInitVelocity then
	  bomb.Velocity = data.WaitingInitVelocity
	  data.WaitingInitVelocity = nil
	  bomb:Update()
	end
	bomb.GridCollisionClass = 0
	if not room:IsPositionInRoom(bomb.Position, 0) then
	  data.ContiVelocity = data.ContiVelocity or bomb.Velocity
	  bomb:SetExplosionCountdown(10 + bomb.FrameCount % 5)
	  bomb.Velocity = data.ContiVelocity
	  bomb.Position = room:ScreenWrapPosition(bomb.Position, -100)
	else
	  data.ContiVelocity = nil
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then
	data.NeptunusStartingVelocity = data.NeptunusStartingVelocity or bomb.Velocity
  end
  if bomb:HasTearFlags(TearFlags.TEAR_POP) then
	for _, e in pairs(Isaac.GetRoomEntities()) do
	  if bomb:CollidesWithGrid() and not bomb:HasTearFlags(TearFlags.TEAR_BOUNCE) then bomb:SetExplosionCountdown(0) end
	  if bomb.Index ~= e.Index and bomb.Position:Distance(e.Position) <= bomb.Size * 2 then
		if e:ToNPC() then
		  bomb:SetExplosionCountdown(0)
		elseif e:ToBomb() then
		  bomb.Velocity = bomb.Velocity * -1.5
		end
	  end
	end
	bomb.Velocity = bomb.Velocity * 0.95
  end
  if bomb:HasTearFlags(TearFlags.TEAR_GROW) then
	local s = 1 + (bomb.Position:Distance(player.Position) / 1000)
	bomb.SpriteScale = Vector(s, s)
	bomb.ExplosionDamage = data.BaseExplosionDamage * s
	bomb.RadiusMultiplier = data.BaseRadiusMultiplier * s
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
  if not bomb.SpawnerEntity then return end
  local player = bomb.SpawnerEntity:ToPlayer()
  if not player then return end
  if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end
  bomb:GetData().WaitingInitVelocity = bomb.Velocity
end)

local fireDirs = {
  [Direction.LEFT] = Vector(-1, 0),
  [Direction.UP] = Vector(0, -1),
  [Direction.RIGHT] = Vector(1, 0),
  [Direction.DOWN] = Vector(0, 1),
}

local function fireChoclateBomb(player, charge, dir)
  dir = fireDirs[dir] or Vector(1, 0)
  local vel = dir * (12 * player.ShotSpeed)
  local mult = charge / 100
  if charge <= 35 then
	local test = player:FireBomb(player.Position, nullVector, player)
	local bomb = Isaac.Spawn(4, 14, 0, player.Position, vel, player):ToBomb()
	bomb.Flags = test.Flags
	bomb.ExplosionDamage = test.ExplosionDamage * (0.2 + mult)
	bomb.Color = test.Color
	bomb.IsFetus = true
	test:Remove()
  elseif charge <= 80 then
	local test = player:FireBomb(player.Position, nullVector, player)
	local bomb = Isaac.Spawn(4, 0, 0, player.Position, vel, player):ToBomb()
	bomb.Flags = test.Flags
	bomb.ExplosionDamage = test.ExplosionDamage * (0.5 + mult)
	bomb.Color = test.Color
	bomb.IsFetus = true
	test:Remove()
  else
	local test = player:FireBomb(player.Position, nullVector, player)
	local bomb = Isaac.Spawn(4, 10, 0, player.Position, vel, player):ToBomb()
	bomb.Flags = test.Flags
	bomb.ExplosionDamage = test.ExplosionDamage * (1.5 + mult)
	bomb.Color = test.Color
	bomb.IsFetus = true
	bomb:Update()
	local size = 1.01
	bomb.SpriteScale = Vector(size, size)
	test:Remove()
  end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
  for p = 0, game:GetNumPlayers() - 1 do
	local player = Isaac.GetPlayer(p)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) and player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
	  local data = player:GetData()
	  if data.ChoclateCharge > -1 or data.ChoclateChargeBar:IsPlaying("Disappear") then
		local pos = Isaac.WorldToScreen(player.Position - Vector(-20, 55))
		data.ChoclateChargeBar:Render(pos)
		if not data.ChoclateChargeBar:IsPlaying("Charging") then
		  data.ChoclateChargeBar:Update()
		end
	  end
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
  if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end
  local data = player:GetData()
  if not data.ChoclateChargeBar then
	data.ChoclateChargeBar = Sprite()
	data.ChoclateChargeBar:Load("gfx/chargebar.anm2", true)
	data.ChoclateFireDirection = -1
	data.ChoclateChargeBar.PlaybackSpeed = 0.5
	data.ChoclateCharge = -1
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
	if player:GetFireDirection() ~= -1 then
	  data.ChoclateFireDirection = player:GetFireDirection()
	  data.ChoclateCharge = data.ChoclateCharge + (30 / (player.MaxFireDelay + 1)) * 2
	  data.ChoclateCharge = math.min(data.ChoclateCharge, 100)
	  if data.ChoclateCharge == 100 then
		if not data.ChoclateChargeBar:IsPlaying("Charged") then
		  data.ChoclateChargeBar:Play("Charged", true)
		end
	  else
		data.ChoclateChargeBar:SetFrame("Charging", math.floor(data.ChoclateCharge))
	  end
	else
	  if data.ChoclateCharge > -1 then
		data.ChoclateChargeBar:Play("Disappear", true)
		fireChoclateBomb(player, data.ChoclateCharge, data.ChoclateFireDirection)
	  end
	  data.ChoclateCharge = -1
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS) then
	if player.MaxFireDelay == player.FireDelay then
	  player.FireDelay = player.FireDelay / 1.5
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
  if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
	player.FireDelay = 999 --Prevents the player from shooting
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
  if not tear.SpawnerEntity then return end
  if not tear:HasTearFlags(TearFlags.TEAR_ORBIT_ADVANCED) then return end
  local player = tear.SpawnerEntity:ToPlayer()
  if player then
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
	  tear.Visible = false
	  tear.EntityCollisionClass = 0
	  tear.FallingAcceleration = -0.1
	  tear.FallingSpeed = 0
	  if not tear.Child then
		local bomb = player:FireBomb(tear.Position, nullVector, player)
		tear.Child = bomb
	  else
		local bomb = tear.Child:ToBomb()
		bomb.Position = tear.Position
		bomb.EntityCollisionClass = 0
		bomb.GridCollisionClass = 0
		bomb.RadiusMultiplier = 0.7 --Safety First
		bomb:SetExplosionCountdown(35)
		bomb:AddTearFlags(TearFlags.TEAR_ORBIT_ADVANCED)
	  end
	  for _, npc in pairs(Isaac.FindInRadius(tear.Position, 20, EntityPartition.ENEMY)) do
		if npc:ToNPC() and game:GetRoom():GetFrameCount() >= 15 then
		  tear.Child:ToBomb():SetExplosionCountdown(0)
		  tear:Remove()
		end
	  end
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
  for _, b in pairs(Isaac.FindByType(4)) do
	b = b:ToBomb()
	if b and b.IsFetus and b:HasTearFlags(TearFlags.TEAR_ORBIT_ADVANCED) then b:Remove() end --Leftover Saturus bombs
  end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
  for _, b in pairs(Isaac.FindByType(4)) do
	b = b:ToBomb()
	if b.IsFetus then
	  for i = 1, 8 do
		local vel = Vector.FromAngle(i * 45)
		local n = Isaac.Spawn(4, 14, 0, b.Position + vel * 15, vel * 10, b):ToBomb()
		n.Flags = b.Flags
		n.EntityCollisionClass = 0
		n.IsFetus = true
		n.SpawnerEntity = b.SpawnerEntity
	  end
	  b:Remove()
	end
  end
end, CollectibleType.COLLECTIBLE_TEAR_DETONATOR)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
  local player = fam.Player
  if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end
  local activeButton = ButtonAction.ACTION_ITEM
  if player:GetPlayerType() == PlayerType.PLAYER_ESAU then activeButton = ButtonAction.ACTION_PILLCARD end
  if fam.Visible and Input.IsActionPressed(activeButton, player.ControllerIndex) then
	Isaac.Explode(fam.Position, player, 100)
	fam.Visible = false
	fam.Position = player.Position
  end
end, 243)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
  if not knife.SpawnerEntity then return end
  local player = knife.SpawnerEntity:ToPlayer()
  if not player then return end
  if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end
  local data = knife:GetData()
  if knife.Variant == 0 then
	if knife:GetKnifeDistance() > 30 then
	  if not data.FetusBomb and data.CanSpawnBomb then
		data.FetusBomb = player:FireBomb(knife.Position, nullVector, knife)
		data.FetusBomb.IsFetus = true
	  elseif data.FetusBomb then
		data.FetusBomb.Position = knife.Position
		for _, npc in pairs(Isaac.FindInRadius(knife.Position, 20, EntityPartition.ENEMY)) do
		  if npc:ToNPC() then
			data.FetusBomb:SetExplosionCountdown(0)
			data.FetusBomb = nil
			data.CanSpawnBomb = false
		  end
		end
		if knife:GetKnifeDistance() > knife.MaxDistance - 0.1 then
		  data.FetusBomb.Velocity = nullVector
		  data.FetusBomb = nil
		  data.CanSpawnBomb = false
		end
	  end
	else
	  data.CanSpawnBomb = true
	end
	if data.FetusBomb and not data.FetusBomb:Exists() then data.FetusBomb = nil end
  end
end)
