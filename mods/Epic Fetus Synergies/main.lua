local mod = RegisterMod("Epic Fetus Synergies", 1) --Made by Jaemspio

local game = Game()
local nullVector = Vector.Zero
local inf = 9999999999

local function floatToInt(float)
  return math.floor(float * 10000) --4 digits is enough percision in my books
end

local function spawnRocket(player, pos, delay, damage)
  local rocket = Isaac.Spawn(1000, 31, 0, pos, nullVector, player):ToEffect()
  rocket:SetTimeout(delay or 10)
  if damage then rocket.DamageSource = floatToInt(damage) end
  rocket:Update()
  return rocket
end

local function spawnCreep(npc, t, scale, timeout, color)
  local pos
  if type(npc) == "table" then
	pos = npc[2]
	npc = npc[1]
  else
	pos = npc.Position
  end
  t = t or 22
  local creep = Isaac.Spawn(1000, t, 0, pos, nullVector, npc):ToEffect()
  if scale then
	creep.Size = creep.Size * scale
	creep.SpriteScale = creep.SpriteScale * scale
  end
  if timeout then creep:SetTimeout(timeout) end
  if color then creep.Color = color end
  creep:Update() --Fixes creep looking scuffed on init (l + ratio Fiend Foilo Devs)
  return creep
end

local function spawnBomb(player, variant, pos, vel, countdown, damage)
  local test = player:FireBomb(player.Position, nullVector, player)
  local bomb = Isaac.Spawn(4, variant, 0, pos, vel or nullVector, player):ToBomb()
  bomb.Flags = test.Flags
  bomb.ExplosionDamage = test.ExplosionDamage
  bomb.Color = test.Color
  if countdown then bomb:SetExplosionCountdown(countdown) end
  bomb.IsFetus = true
  test:Remove()
  return bomb
end

local function isRocketTarget(effect, player)
  return effect:ToEffect() ~= nil and effect.Variant == 30 and ((player:GetActiveWeaponEntity() ~= nil and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(effect))
  or effect:GetData().IsSoyMilkTarget or effect:GetData().IsLudoTarget)
end

local function getMultiShot(player)
  local ret = 1
  if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then ret = ret + 1 end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) then ret = ret + 1 end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) then ret = ret + 2 end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then ret = ret + 3 end
  return ret
end

local function random(rng, min, max)
  if not max then max = min; min = 1 end
  if min > max then return error("Invaild limits!", 2) end
  return rng:RandomInt((max + 1) - min) + min
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, rocket) --Main Code
  if not rocket.SpawnerEntity then return end
  local player = rocket.SpawnerEntity:ToPlayer()
  if not player then return end
  local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EPIC_FETUS)
  local data = rocket:GetData()
  if rocket.DamageSource == 0 then
	local dam = player.Damage * 20
	local mult = 1
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
	  mult = mult + 0.2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
	  mult = mult - 0.3
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL) then
	  mult = mult + rocket.Position:Distance(player.Position) / 1000
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE) then
	  mult = mult + 2.2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_APPLE) then
	  mult = mult + 3
	end
	rocket.DamageSource = floatToInt(dam * mult) --DamageSource only takes integers
  end
  local stump = player:GetEffects():HasTrinketEffect(TrinketType.TRINKET_AZAZELS_STUMP)
  if rocket:IsDead() and not rocket:Exists() then
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
	  local bomb = player:FireBomb(rocket.Position, nullVector, player)
	  bomb:SetExplosionCountdown(20)
	  bomb.DepthOffset = -10 --Appear behind the smoke
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
	  --Cheese
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS) then
	  for i = 0, 3 do
		local laser = player:FireBrimstone(Vector.FromAngle(i * 90), rocket, 1)
		laser.DisableFollowParent = true
		laser.Position = rocket.Position
	  end
	elseif (player:GetPlayerType() == PlayerType.PLAYER_AZAZEL or stump) then
	  for i = 1, 8 do
		local angle = (i * 45) + 25
		local laser = player:FireBrimstone(Vector.FromAngle(angle), rocket, 1)
		laser.DisableFollowParent = true
		laser.Position = rocket.Position
		laser.MaxDistance = math.max(60, 60 + ((player.TearRange - 110) / 5)) --I think this is pretty close to the in-game formula
	  end
	elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then
	  for i = 1, 8 do
		local angle = (i * 45) + 25
		local laser = player:FireBrimstone(Vector.FromAngle(angle), rocket, 0.5)
		laser.DisableFollowParent = true
		laser.Position = rocket.Position
	  end
	  for i = 1, math.random(38, 91) do
		local e = Isaac.Spawn(1000, 111, 1, rocket.Position, RandomVector() * math.random(-10, 10), nil):ToEffect()
		e.Scale = math.random(4, 9) / 10
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then e.Scale = e.Scale * 2 end
		e.Timeout = math.random(21, 37)
	  end
	  local blood = Isaac.Spawn(1000, 2, 2, rocket.Position, nullVector, nil)
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then blood.Scale = blood.Scale * 2 end
	  local r = 50
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then r = r * 2 end
	  for _, npc in pairs(Isaac.FindInRadius(rocket.Position, r, EntityPartition.ENEMY)) do
		if npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED) then
		  npc:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
		end
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE) then
	  for i = 6, random(rng, 9, 12) do
		Isaac.Spawn(1000, 35, 0, rocket.Position, RandomVector() * 1.5, rocket)
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_APPLE) then
	  for i = 6, random(rng, 9, 12) do
		Isaac.Spawn(1000, 86, 1, rocket.Position, RandomVector() * 1.5, rocket)
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY) then
	  for i = 0, 3 do
		local b = spawnBomb(player, 14, rocket.Position, Vector.FromAngle(i * 90) * 4, 10)
		b:ClearTearFlags(TearFlags.TEAR_QUADSPLIT)
		b.ExplosionDamage = b.ExplosionDamage / 4
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR) then
	  spawnCreep({player, rocket.Position}, 45, 3)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
	  if not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
		for _, l in pairs(Isaac.FindByType(7)) do
		  if l.FrameCount <= 2 and rocket.Position:Distance(l.Position) <= 1 then
			l:Remove() --Removes the lasers from the boring Tech X synergy
		  end
		end
	  end
	  for i = 0, 3 do
		player:FireTechXLaser(rocket.Position, Vector.FromAngle(i * 90) * 10, 30, player)
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE) then
	  for i = 1, random(rng, 3, 5) do
		local t = Isaac.Spawn(2, 29, 0, rocket.Position, RandomVector() * 8, player):ToTear()
		t:AddTearFlags(TearFlags.TEAR_BONE)
		t.CollisionDamage = player.Damage
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
	  local t = player:FireTear(rocket.Position, nullVector, false, true, false, player, 2)
	  t.Height = 0
	  t:Update()
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) then
	  Isaac.Spawn(1000, 180, 0, rocket.Position, nullVector, player)
	end
  end
end, 31)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player, amount, flags) --Cursed Eye Code
  player = player:ToPlayer()
  if not player:GetActiveWeaponEntity() or not player:GetActiveWeaponEntity():ToEffect() then return end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then return end
  --Reimplements Cursed Eye teleport
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, false, false, false, false)
  end
end, 1)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, countdown) --Damage changing nonsense/On hit effects
  if entity:ToPlayer() then return end
  if not source or not source.Entity then return end
  if flags & DamageFlag.DAMAGE_FAKE ~= 0 then return end --DAMAGE_FAKE is used because it will never occur naturally and something like DAMAGE_CLONES is too commonmly used
  local rocket = source.Entity:ToEffect()
  if rocket and source.Variant == 31 and rocket.DamageSource ~= 0 then
	local dam = rocket.DamageSource / 10000 --Convert the integer back into a float
	entity:TakeDamage(dam, flags | DamageFlag.DAMAGE_FAKE, source, countdown)
	if entity:HasMortalDamage() and rocket.SpawnerEntity then
	  local player = rocket.SpawnerEntity:ToPlayer()
	  if player then
		local rng = RNG()
		rng:SetSeed(entity.DropSeed, 35)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GLITTER_BOMBS) and random(rng, 6) == 1 then
		  Isaac.Spawn(5, 0, 0, entity.Position, nullVector, nil)
		end
	  end
	end
	return false
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player) --Player-Based Code
  if not player:HasWeaponType(WeaponType.WEAPON_ROCKETS) then return end
  local data = player:GetData()
  if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
	player.FireDelay = 10 --Prevents the player from shooting
	if data.LudoEpicTarget and not data.LudoEpicTarget:Exists() then data.LudoEpicTarget = nil end
	if not data.LudoEpicTarget then
	  local target = Isaac.Spawn(1000, 30, 0, player.Position, nullVector, player):ToEffect()
	  target.LifeSpan = 10
	  target:GetData().IsLudoTarget = true
	  data.LudoEpicTarget = target
	end
  elseif data.LudoEpicTarget then
	data.LudoEpicTarget:Remove()
	data.LudoEpicTarget = nil
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
	local color = Color(1.3, 1.5, 1.5, 1, 0, 0, 0) --Makes targets white
	player.FireDelay = math.max(player.FireDelay, 1)
	if player:GetFireDirection() ~= -1 and player.FireDelay <= 1 then --Reimplements firing
	  player.FireDelay = player.MaxFireDelay * 5 + 2
	  local target = Isaac.Spawn(1000, 30, 0, player.Position, nullVector, player):ToEffect()
	  target.Parent = player
	  target:SetTimeout(30)
	  target:SetColor(color, inf, inf, false, false)
	  target:GetData().IsSoyMilkTarget = true
	  target:GetData().RemainingShots = getMultiShot(player) - 1
	end
  end
end)

function mod:effectUpdate(effect, shouldFire) --Target-Based code
  if not effect.SpawnerEntity then return end
  local player = effect.SpawnerEntity:ToPlayer()
  if not player or not isRocketTarget(effect, player) then return end
  local sprite = effect:GetSprite()
  local data = effect:GetData()
  local rng = effect:GetDropRNG()
  if data.IsLudoTarget then
	effect.Velocity = player:GetShootingInput() * (20 * player.ShotSpeed)
	sprite.PlaybackSpeed = 0.5
	if effect.FrameCount % 4 == 0 then sprite:Play("Blink", true) end --Targets without a timeout value don't animate
	for _, npc in pairs(Isaac.FindInRadius(effect.Position, 25, EntityPartition.ENEMY)) do
	  if npc:ToNPC() and effect.LifeSpan == 1 then
		spawnRocket(player, effect.Position)
		effect.LifeSpan = math.ceil(player.MaxFireDelay * 5 + 3)
	  end
	end
	if effect.LifeSpan > 1 then effect.LifeSpan = effect.LifeSpan - 1 end
  end
  if data.IsSoyMilkTarget then
	if effect.Timeout == 10 or shouldFire then
	  spawnRocket(player, effect.Position)
	  if data.RemainingShots and data.RemainingShots > 0 then
		effect:SetTimeout(20)
		data.RemainingShots = data.RemainingShots - 1
	  end
	end
	local vel = player:GetShootingInput() * 32
	if player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) then vel = vel:Rotated(45) end
	effect.Velocity = vel
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_REMOTE_DETONATOR) and not data.IsLudoTarget then
	if effect.Timeout <= 15 then
	  effect:SetTimeout(20)
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
	if effect.Timeout == 10 or shouldFire then
	  for i = 1, 2 do
		spawnRocket(player, effect.Position + (RandomVector() * random(rng, 8, 25)))
	  end
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION) then
	effect.Velocity = effect.Velocity + (player.Position - effect.Position):Normalized() * 6
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE) and effect.FrameCount == 1 then
	effect:SetTimeout(20)
  end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.effectUpdate, 30)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
  local data = player:GetData()
  if data.LudoEpicTarget then
	local target = data.LudoEpicTarget:ToEffect()
	if target.LifeSpan == 1 then
	  target.LifeSpan = math.ceil(player.MaxFireDelay * 5 + 3)
	  spawnRocket(player, target.Position)
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
	for _, t in pairs(Isaac.FindByType(1000, 30)) do
	  if t:GetData().IsSoyMilkTarget then
		local target = t:ToEffect()
		target:SetTimeout(10)
		target:Update()
		mod:effectUpdate(target, true)
		target:Remove()
	  end
	end
  end
  if not player:GetActiveWeaponEntity() then return end
  local target = player:GetActiveWeaponEntity():ToEffect()
  if not target then return end
  if target and isRocketTarget(target, player) then
	target:SetTimeout(10)
	target:Update()
	mod:effectUpdate(target, true)
	target:Remove()
  end
end, CollectibleType.COLLECTIBLE_REMOTE_DETONATOR)
