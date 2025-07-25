local mod = RegisterMod("Mom's Knife Synergies", 1) --Made by Jaemspio

local game = Game()
local nullVector = Vector.Zero
local vOne = Vector.One

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
  creep:Update()
  return creep
end

local function getTrueVelocity(knife)
  knife = knife:ToKnife()
  return Vector.FromAngle(knife.Rotation) * knife:GetKnifeVelocity()
end

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
  if knife.Variant ~= 0 or not knife.SpawnerEntity then return end
  local player = knife.SpawnerEntity:ToPlayer()
  if not player then return end
  local sprite = knife:GetSprite()
  local data = knife:GetData()
  local effects = player:GetEffects()
  local room = game:GetRoom()
  local damage = player.Damage
  local mult = 1
  data.OnHitEffectCooldown = data.OnHitEffectCooldown or 10
  data.OnHitEffectCooldown = math.max(0, data.OnHitEffectCooldown - 1)
  data.OldIsFlying = data.OldIsFlying == nil and false or data.OldIsFlying
  data.KnifeShots = data.KnifeShots or 0
  if knife:GetKnifeDistance() > knife.MaxDistance - 0.1 and not data.IsKnifeAtPeak then
	data.IsKnifeAtPeak = true
	if player:HasCollectible(CollectibleType.COLLECTIBLE_POP) then
	  for i = 1, math.floor(knife.Charge * 8) do
		local vel = (Vector.FromAngle(knife.Rotation):Normalized() * 8 * player.ShotSpeed)
		player:FireTear(knife.Position, vel:Rotated(math.random(-20, 20)), false, true, false)
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION) and not player:HasCollectible(CollectibleType.COLLECTIBLE_TINY_PLANET) then
	  Isaac.Spawn(1000, 14, 0, knife.Position, nullVector, nil)
	  for _, e in pairs(Isaac.FindInRadius(knife.Position, 50, EntityPartition.ENEMY)) do
		e:TakeDamage(player.Damage * 5, 0, EntityRef(knife), 2)
	  end
	  knife:Reset()
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) and knife.Charge > 0.5 then
	  Isaac.Spawn(1000, 180, 0, knife.Position, nullVector, player):ToEffect():SetTimeout(math.floor(180 * knife.Charge))
	end
  end
  if not knife:IsFlying() then
	data.IsKnifeAtPeak = false
  end
  if data.OldIsFlying ~= knife:IsFlying() then --Detect knife throw
	data.OldIsFlying = knife:IsFlying()
	if knife:IsFlying() then
	  data.KnifeShots = data.KnifeShots + 1
	end
  end
  if data.KnifeShots % 2 == 1 then
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_CLOT) then
	  knife:SetColor(Color(2, 1, 1, 1, 1, -0.4, -0.4), 2, 5, false, true)
	  damage = damage + 1
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL) then
	local dis = knife:GetKnifeDistance() / 200
	knife.SizeMulti = Vector(1 + dis / 2, 1 + dis / 2)
	knife.SpriteScale = Vector(1 + dis / 4, 1 + dis / 4)
	mult = mult + dis
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
	if knife:IsFlying() and data.AntiGravPosition then
	  knife.Position = data.AntiGravPosition + getTrueVelocity(knife)
	  data.AntiGravPosition = knife.Position
	else
	  if player:GetFireDirection() ~= -1 then
		data.AntiGravPosition = data.AntiGravPosition or knife.Position
		knife.Position = data.AntiGravPosition
	  else
		data.AntiGravPosition = nil
	  end
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_RUBBER_CEMENT) then
	knife.Position = room:GetClampedPosition(knife.Position, 0)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR) and math.random(6) == 1 and knife:IsFlying() then
	spawnCreep(knife, 45)
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
	mult = mult + 0.3
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
	if player:GetFireDirection() ~= -1 and not knife:IsFlying() and knife.Rotation == player:GetLastDirection():GetAngleDegrees() then
	  knife:Shoot(1.1, player.TearRange / 3)
	end
	if knife:IsFlying() and knife.Charge <= 1 then
	  knife:Reset()
	end
  end
  if knife:HasTearFlags(TearFlags.TEAR_GLOW) then
	if not data.GodAuraTear or not data.GodAuraTear:Exists() then
	  data.GodAuraTear = Isaac.Spawn(2, 0, 0, knife.Position, nullVector, player):ToTear()
	  data.GodAuraTear:GetSprite():ReplaceSpritesheet(0, "")
	  data.GodAuraTear:GetSprite():LoadGraphics()
	  data.GodAuraTear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	  data.GodAuraTear:AddTearFlags(TearFlags.TEAR_PIERCING)
	  data.GodAuraTear:AddTearFlags(TearFlags.TEAR_GLOW)
	  data.GodAuraTear.CollisionDamage = player.Damage
	  data.GodAuraTear.Scale = 1.2
	  data.GodAuraTear:Update()
	else
	  data.GodAuraTear.Position = knife.Position
	  data.GodAuraTear.Height = -10
	end
  end
  if data.IsBelialActive then
	if not knife:IsFlying() then
	  data.IsBelialActive = false
	  effects:RemoveCollectibleEffect(3)
	else
	  knife:SetColor(Color(0.8, 0.5, 0.5, 1, 0, 0, 0), 2, 4, false, true)
	  mult = mult + 1
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) then
	if knife:IsFlying() then
	  if not data.TechnologyZeroLaser then
		local l = EntityLaser.ShootAngle(10, player.Position, (knife.Position - player.Position):GetAngleDegrees(), 2, knife.PositionOffset, player)
		l.MaxDistance = knife.Position:Distance(player.Position)
		data.TechnologyZeroLaser = l
	  else
		local l = data.TechnologyZeroLaser:ToLaser()
		l.Angle = (knife.Position - player.Position):GetAngleDegrees()
		l.Position = player.Position
		l.SpriteOffset = knife.PositionOffset
		l.MaxDistance = knife.Position:Distance(player.Position)
		l.Timeout = 2
	  end
	else
	  data.TechnologyZeroLaser = nil
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
	if knife:IsFlying() then
	  if not data.TrisagionLaser then
		local l = EntityLaser.ShootAngle(3, knife.Position + knife.PositionOffset, knife.Rotation, 99999, nullVector, knife)
		l.MaxDistance = 20
		l.DepthOffset = -10
		data.TrisagionLaser = l
	  end
	elseif data.TrisagionLaser then
	  data.TrisagionLaser:Remove()
	  data.TrisagionLaser = nil
	end
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
	if knife:IsFlying() then
	  local md = knife.MaxDistance + 36
	  if not data.OccultTarget then
		local t = Isaac.Spawn(1000, 153, 0, player.Position + Vector.FromAngle(knife.Rotation) * md, nullVector, player):ToEffect()
		t:SetTimeout(10)
		data.OccultTarget = t
	  else
		local t = data.OccultTarget:ToEffect()
		t.Position = t.Position + player.Velocity
		t:SetTimeout(10 + t.FrameCount % 10)
		t.Velocity = player:GetShootingInput() * 16
		local rot = (t.Position - player.Position):GetAngleDegrees()
		knife.Rotation = rot
	  end
	elseif data.OccultTarget then
	  data.OccultTarget:Remove()
	  data.OccultTarget = nil
	end
  end
  knife.CollisionDamage = damage * mult
end, 0)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, countdown) --Damage changing nonsense/On hit effects
  if entity:ToPlayer() then return end
  if not source or not source.Entity then return end
  if flags & DamageFlag.DAMAGE_FAKE ~= 0 then return end --DAMAGE_FAKE is used because it will never occur naturally and something like DAMAGE_CLONES is too commonmly used
  local knife = source.Entity:ToKnife()
  if knife and source.Variant == 0 and knife.CollisionDamage ~= 0 then
	local player = knife.SpawnerEntity:ToPlayer()
	if not player then return end
	if knife:IsFlying() then
	  local dam = knife.CollisionDamage * math.min(6, knife.Charge * 18) --I'm pretty sure this is the thrown attack damage formula, or at least is close
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then dam = knife.CollisionDamage * math.min(8, math.max(0.1, 1 - knife.Charge) * 10) end
	  entity:TakeDamage(dam, flags | DamageFlag.DAMAGE_FAKE, source, countdown)
	else
	  entity:TakeDamage(knife.CollisionDamage * 2, flags | DamageFlag.DAMAGE_FAKE, source, countdown)
	end
	if knife.SpawnerEntity and knife.SpawnerEntity:ToPlayer() then
	  local player = knife.SpawnerEntity:ToPlayer()
	  local data = knife:GetData()
	  if data.OnHitEffectCooldown == 0 then
		data.OnHitEffectCooldown = 10
		if knife:HasTearFlags(TearFlags.TEAR_QUADSPLIT) then
		  for i = 0, 3 do
			local t = player:FireTear(knife.Position, Vector.FromAngle(i * 90):Rotated(40) * 6, false, true, false, knife)
			t.CollisionDamage = t.CollisionDamage / 4
			t.Scale = t.Scale / 1.5
			t:ClearTearFlags(TearFlags.TEAR_QUADSPLIT)
		  end
		end
	  end
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_SINUS_INFECTION) and math.random(6) == 1 then
		local t = Isaac.Spawn(2, 26, 0, entity.Position + RandomVector() * math.random(math.floor(entity.Size / 2)), nullVector, player):ToTear()
		t:AddTearFlags(TearFlags.TEAR_BOOGER)
		t.CollisionDamage = player.Damage
	  end
	  if knife:HasTearFlags(TearFlags.TEAR_BELIAL) and knife:IsFlying() and not data.IsBelialActive then
		data.IsBelialActive = true
		player:GetEffects():AddCollectibleEffect(3, false)
	  end
	end
	return false
  end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player, amount, flags) --Cursed Eye Code
  local player = player:ToPlayer()
  local w = player:GetActiveWeaponEntity()
  if not w or not w:ToKnife() or w.Variant ~= 0 then return end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then return end
  --Reimplements Cursed Eye teleport
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) and not w:ToKnife():IsFlying() and player:GetFireDirection() ~= -1 then
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, false, false, false, false)
  end
end, 1)
