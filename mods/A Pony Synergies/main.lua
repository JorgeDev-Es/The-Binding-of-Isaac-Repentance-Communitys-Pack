APonySyn = RegisterMod("A Pony Synergies", 1)
local mod = APonySyn
local game = Game()
local PonyCallbacks = include('custom_callbacks')
include('EID')

local timer = 0
local nullVector = Vector(0, 0)
local pos = nullVector
local freezePrevention = 0
local ponyTimer = 0
local oldVel = nil

local function hasPony(player)
  return player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_PONY) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHITE_PONY)
end

local function hasAnyTech(player)
  return player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) or
  player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)
end

local function vecToPos(from, to, speed)
  return (from - to):Normalized() * (speed or 1)
end

local function random(num1, num2)
  if not num2 then
	num2 = num1
	num1 = 1
  end
  return math.random(num1, num2) == 1
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
  local effects = player:GetEffects()
  local room = game:GetRoom()
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) and player:CollidesWithGrid() and ponyTimer > 1 then
	for i = 1, math.random(7, 13) do
	  player:FireTear(player.Position, (player.Velocity:Normalized() * 16):Rotated(math.random(-15, 15)), false, false, false, player, 0.5)
	end
	Game():ShakeScreen(20)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKWAVE, 0, player.Position, nullVector, player):ToEffect().Rotation = -player.Velocity:GetAngleDegrees()
  end
  if hasPony(player) then
	ponyTimer = 3
  elseif ponyTimer > 1 then
	ponyTimer = ponyTimer - 1
  end
  if timer > 0 then
	timer = timer - 1
  end
  if timer == 1 then
	player.Position = pos
	effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_PONY)
	effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_WHITE_PONY)
	oldVel = nil
	local grid = room:GetGridEntityFromPos(player.Position)
	while grid == nil do
	  player.Position = player.Position + player.Velocity
	  grid = room:GetGridEntityFromPos(player.Position)
	  freezePrevention = freezePrevention + 1
	  if freezePrevention == 1000 then
		freezePrevention = 0
		break
	  end
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
	if hasPony(player) then
	  player.GridCollisionClass = 0
	  local grid = room:GetGridEntityFromPos(player.Position)
	  if grid and (grid:GetType() == GridEntityType.GRID_WALL or grid:GetType() == GridEntityType.GRID_DOOR) and timer == 0 then
		pos = room:ScreenWrapPosition(player.Position, 0) + (player.Velocity * -4)
		timer = 5
	  end
	end
  end
end)

PonyCallbacks.AddCallback(PonyCallbacks.POST_PONY_UPDATE, function(_, player)
  local effects = player:GetEffects()
  if not Game():IsPaused() and player.ControlsEnabled and player.Velocity:Length() < 9 then
	effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_PONY)
	effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_WHITE_PONY)
	oldVel = nil
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_BAG) or player:HasCollectible(CollectibleType.COLLECTIBLE_STIGMATA) then
	Isaac.Spawn(1000, 46, 0, player.Position, nullVector, player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID) then
	Isaac.Spawn(1000, 53, 0, player.Position, nullVector, player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR) or player:HasCollectible(CollectibleType.COLLECTIBLE_LODESTONE) then
	Game():UpdateStrangeAttractor(player.Position + player.Velocity, 30, 600)
  end
end)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
  local data = fam:GetData()
  if data.isDashing then
	fam.Velocity = Vector(0, 0)
	fam.Position = Game():GetRoom():GetClampedPosition(fam.Position + fam.Player.Velocity * 1.6, 0)
	Isaac.Spawn(1000, Isaac.GetEntityVariantByName("After Image"), 0, (fam.Position - fam.Player.Velocity * 0.5), Vector(0, 0), fam)
	for _, enemy in pairs(Isaac.FindInRadius(fam.Position, (fam.Size + 3), EntityPartition.ENEMY)) do
	  enemy:TakeDamage(fam.Player.Damage / 2, 0, EntityRef(fam), 5)
	end
  end
  if not hasPony(fam.Player) then
	data.isDashing = false
  end
end, 228)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
  local player = heart:ToFamiliar().Player
  if hasPony(player) then
	heart.Velocity = vecToPos((player.Position - player.Velocity), heart.Position, 2) + heart.Velocity * 0.8
  end
end, 62)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
  if not effect.SpawnerEntity or effect.SpawnerEntity:IsDead() then --It's unlikey, but it might happen
	effect:Remove()
	return nil
  end
  local data = effect:GetData()
  local sprite = effect:GetSprite()
  local sprite2 = effect.SpawnerEntity:GetSprite()
  local timer = 7
  if sprite2:GetFilename() ~= sprite:GetFilename() then
	sprite:Load(sprite2:GetFilename(), true)
	data.time = timer
  end
  data.anim = data.anim or sprite2:GetAnimation()
  data.frame = data.frame or sprite2:GetFrame()
  sprite:SetFrame(data.anim, data.frame)
  if sprite2:GetOverlayAnimation() then
	data.ovAnim = data.ovAnim or sprite2:GetOverlayAnimation()
	data.ovFrame = data.ovFrame or sprite2:GetOverlayFrame()
	sprite:SetOverlayFrame(data.ovAnim, data.ovFrame)
  end
  effect.PositionOffset = effect.SpawnerEntity.PositionOffset
  sprite.Color = Color(1, 1, 1, data.time / timer, 0, 0, 0)
  data.time = data.time - 1
  if data.time == 0 then effect:Remove() end
end, Isaac.GetEntityVariantByName("After Image"))

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source)
  if entity.Type == 3 and entity.Variant == 228 and hasPony(entity:ToFamiliar().Player) then
	return false
  end
end)

PonyCallbacks.AddCallback(PonyCallbacks.POST_PONY_COLLISION, function(_, player, enemy, amount)
  --Items
  if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
	enemy:AddPoison(EntityRef(player), 100, player.Damage)
	Isaac.Explode(enemy.Position, player, player.Damage)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_BEAN) then
	Game():Fart(player.Position, 20, player, 1, 0)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_FANNY_PACK) and random(5) then
	local vaildPickups = {10, 20, 30, 40, 70, 90, 300}
	Isaac.Spawn(5, vaildPickups[math.random(1, #vaildPickups)], 0, player.Position, Vector(math.random(-5, 5), math.random(-5, 5)), player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN) and random(5) then
	player:AddBlueFlies(1, player.Position, nil)
  end
  if player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then
	player:AddBlueFlies(1, player.Position, nil)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIDERBABY) or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_WIG) then
	player:AddBlueSpider(player.Position)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT) then
	local rand = math.random(1, 4)
	if rand == 1 then enemy:AddPoison(EntityRef(player), 150, player.Damage) end
	if rand == 2 then enemy:AddBurn(EntityRef(player), 150, player.Damage) end
	if rand == 3 then enemy:AddConfusion(EntityRef(player), 150, false) end
	if rand == 4 then enemy:AddSlowing(EntityRef(player), 150, 0.7, Color(1, 1, 1, 1, 0.2, 0.2, 0.2)) end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) and random(5) then
	enemy:AddBurn(EntityRef(player), 100, player.Damage)
	Isaac.Explode(enemy.Position, player, player.Damage + 40)
	Isaac.Spawn(1000, 52, 0, enemy.Position, Vector(0, 0), player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER) then
	enemy:AddFear(EntityRef(player), 150)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SCORPIO) then
	enemy:AddPoison(EntityRef(player), 150, player.Damage)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_FRUIT_CAKE) or player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) then
	local rand = math.random(1, 7)
	if rand == 1 then enemy:AddPoison(EntityRef(player), 150, player.Damage) end
	if rand == 2 then enemy:AddBurn(EntityRef(player), 150, player.Damage) end
	if rand == 3 then enemy:AddConfusion(EntityRef(player), 150, false) end
	if rand == 4 then enemy:AddSlowing(EntityRef(player), 150, 0.7, Color(1, 1, 1, 1, 0.2, 0.2, 0.2)) end
	if rand == 5 then enemy:AddCharmed(EntityRef(player), 150) end
	if rand == 6 then enemy:AddFreeze(EntityRef(player), 150) end
	if rand == 7 then enemy:AddFear(EntityRef(player), 150) end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SACK_HEAD) and random(7) then
	Isaac.Spawn(5, 69, 1, player.Position, Vector(math.random(-5, 5), math.random(-5, 5)), player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) and random(3) then
	Isaac.Spawn(5, 20, 1, enemy.Position, Vector(math.random(-5, 5), math.random(-5, 5)), player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SINUS_INFECTION) then
	for i=1, math.random(1, 3) do
	  local tear = Isaac.Spawn(2, 26, 0, (enemy.Position + Vector(math.random(-5, 5), math.random(-5, 5))), Vector(0, 0), player):ToTear()
	  tear.CollisionDamage = player.Damage
	  tear.TearFlags = TearFlags.TEAR_BOOGER
	  tear.DepthOffset = 10
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA) and random(3) then
	if enemy:IsBoss() then
	  enemy:AddConfusion(EntityRef(player), 300, false)
	else
	  enemy:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MUCORMYCOSIS) then
	for i=1, math.random(1, 3) do
	  local tear = Isaac.Spawn(2, 48, 0, (enemy.Position + Vector(math.random(-5, 5), math.random(-5, 5))), Vector(0, 0), player):ToTear()
	  tear.CollisionDamage = player.Damage
	  tear.TearFlags = TearFlags.TEAR_SPORE
	  tear.DepthOffset = 10
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) and random(4) then
	Isaac.Spawn(1000, 180, 0, enemy.Position, Vector(0, 0), player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then
	amount = math.min(amount, 8)
	enemy:TakeDamage(8 * amount, 0, EntityRef(player), 0)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SALVATION) and random(2) then
	for i = -1, 2 do
	  local rev = Isaac.Spawn(7, 5, 0, player.Position, nullVector, player):ToLaser()
	  rev.Angle = 90 * i
	  rev.Timeout = 7
	end
  end
  --Trinkets
  if player:HasTrinket(TrinketType.TRINKET_PETRIFIED_POOP) and random(7) then
	Isaac.Spawn(245, 0, 0, enemy.Position, Vector(0, 0), nil)
  end
  if player:HasTrinket(TrinketType.TRINKET_BIBLE_TRACT) and random(5) then
	local beam = Isaac.Spawn(1000, 19, 0, player.Position, nullVector, player)
	beam.CollisionDamage = player.Damage * 3
  end
  if player:HasTrinket(TrinketType.TRINKET_PINKY_EYE) and random(5) then
	enemy:AddPoison(EntityRef(player), 150, player.Damage)
  end
end)

PonyCallbacks.AddCallback(PonyCallbacks.POST_PONY_DEATH, function(_, player, enemy)
  --Items
  if player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
	if enemy:IsVulnerableEnemy() then
	  enemy:AddEntityFlags(EntityFlag.FLAG_ICE)
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_DIRTY_MIND) then
	Isaac.Spawn(3, 201, 0, player.Position, Vector(0, 0), player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_DEATHS_TOUCH) and random(2) then
	local bone = Isaac.Spawn(EntityType.ENTITY_BONY, 0, 0, enemy.Position, Vector(0, 0), player)
	bone:AddCharmed(EntityRef(player), -1)
  end
  --Trinkets
  if player:HasTrinket(TrinketType.TRINKET_PURPLE_HEART) and random(3) then
	local vaildPickups = {10, 20, 30, 40, 70, 90, 300}
	if enemy:IsChampion() then
	  Isaac.Spawn(5, vaildPickups[math.random(#vaildPickups)], 0, enemy.Position, Vector(0, 0), enemy)
	end
  end
end)

PonyCallbacks.AddCallback(PonyCallbacks.ON_PONY_EFFECT, function(_, player)
  if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then
	local beam = Isaac.Spawn(1000, 19, 0, player.Position, nullVector, player)
	beam.CollisionDamage = player.Damage * 3
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_JUPITER) then
	local tear = player:FireTear(player.Position, -player.Velocity:Normalized() * 14, false, true, false, player, 1)
	tear:AddTearFlags(TearFlags.TEAR_POISON)
	tear.Color = Color(0.4, 0.97, 0.5, 1, 0, 0, 0)
	tear.Scale = tear.Scale * 1.5
	tear.CollisionDamage = tear.CollisionDamage * 2
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) then
	for i = 0, 3 do
	  local tear = player:FireTear(player.Position, (Vector.FromAngle(i * 90) * 8), false, true, false, player, 1)
	end
  end
  for _, bag in pairs(Isaac.FindByType(3, 20)) do --Bomb Bag Synergy
	local bomb = Isaac.Spawn(4, 0, 0, bag.Position, nullVector, nil):ToBomb()
	bomb:SetExplosionCountdown(10)
	bomb.EntityCollisionClass = 0
  end
  for _, heart in pairs(Isaac.FindByType(3, 62)) do --Isaac's Heart Synergy
	local player = heart:ToFamiliar().Player
	Isaac.Spawn(2, 1, 0, heart.Position, player.Velocity:Normalized() * 14 * -0.5, heart)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BONE_SPURS) then
	Isaac.Spawn(3, 234, 0, player.Position, Vector(math.random(-10, 10), math.random(-10, 10)), player)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_TWO) then
	local butt = Isaac.Spawn(4, 9, 0, player.Position, nullVector, nil):ToBomb()
	butt:AddTearFlags(TearFlags.TEAR_BUTT_BOMB)
	butt:SetExplosionCountdown(40)
	butt.EntityCollisionClass = 0
  end
end)

PonyCallbacks.AddCallback(PonyCallbacks.ON_PONY_INIT, function(_, player, first)
  if hasAnyTech(player) then
	for i = 0, 3 do
	  local tech = Isaac.Spawn(7, 2, 0, player.Position, nullVector, player):ToLaser()
	  tech:GetData().IsSpecialPonyLaser = true
	  tech.Angle = i * 90
	  tech.PositionOffset = Vector(0, -20)
	  tech.SpawnerEntity = player
	  tech.CollisionDamage = player.Damage * 3
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
	local vel = -player.Velocity
	if first then oldVel = vel end
	if not first and oldVel then vel = oldVel end
	local brim = player:FireBrimstone(vel, player, DamageMultiplier)
	brim:GetData().IsSpecialPonyLaser = true
	brim.SpawnerEntity = player
	brim.DepthOffset = -5
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
	local tri = EntityLaser.ShootAngle(3, player.Position, player.Velocity:GetAngleDegrees(), 1, Vector(0, -15), player)
	tri:GetData().IsSpecialPonyLaser = true
	tri:SetMaxDistance(30)
	tri.DepthOffset = -60
	tri.CollisionDamage = player.Damage
  end
  for _, fam in pairs(Isaac.FindInRadius(player.Position, 75, EntityPartition.FAMILIAR)) do
	if fam.Variant == 228 then
	  fam:GetData().isDashing = true
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
  if laser:GetData().IsSpecialPonyLaser then
	local player = laser.SpawnerEntity:ToPlayer()
	laser.Position = player.Position
	laser.Velocity = nullVector
	if hasPony(player) then
	  laser.Shrink = false
	else
	  laser.Shrink = true
	end
	if laser.Variant == 3 then
	  if laser.FrameCount == 3 then
		laser.SpriteScale = laser.SpriteScale * 1.75
		laser.Size = laser.Size * 2.5
	  end
	  if laser.Shrink == false then
		laser.Angle = player.Velocity:GetAngleDegrees()
	  end
	  laser.PositionOffset = Vector(0, -15) - player.Velocity * 3
	end
  end
end)
