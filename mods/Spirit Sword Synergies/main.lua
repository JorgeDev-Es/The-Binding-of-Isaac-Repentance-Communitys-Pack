local mod = RegisterMod("Spirit Sword Synergies", 1) --Made by Jaemspio

local game = Game()
local nullVector = Vector.Zero
local sfx = SFXManager()

--My god this mod was hell to make

local function dealDamageInLine(pos, dam, angle, rad, steps, flags)
  flags = flags or 0
  local vel = Vector.FromAngle(angle) * (rad / 2)
  local seeds = {}
  for i = 1, steps * 2 do
	pos = pos + vel
	for _, e in pairs(Isaac.FindInRadius(pos, rad, EntityPartition.ENEMY)) do
	  if not seeds[e.InitSeed] then
		e:TakeDamage(dam, flags, EntityRef(nil), 5)
		seeds[e.InitSeed] = true
		break
	  end
	end
	--[[local h = Isaac.Spawn(10, 0, 0, pos, nullVector, nil) --Hitbox testing
	h.Size = rad
	h.Visible = false
	h.SizeMulti = Vector.One
	h:Remove()--]]
  end
end

local function findSwords()
  local ret = {}
  for _, e in ipairs(Isaac.FindByType(8, 10)) do ret[#ret + 1] = e end
  for _, e in ipairs(Isaac.FindByType(8, 11)) do ret[#ret + 1] = e end
  return ret
end

local function fixSwordSprite(sword) --Makes sword slash effect appear properly
  local sprite = sword:GetSprite()
  local path = sword.Variant == 11 and "gfx/008.011_Tech Sword.anm2" or "gfx/008.010_Spirit Sword.anm2"
  local anim = sprite:GetAnimation()
  sprite:Load(path, true)
  sprite:Play(anim, true)
end

local function wasSpawnedBy(e, p)
  return (e.SpawnerEntity and GetPtrHash(e.SpawnerEntity) == GetPtrHash(p)) or (e.Parent and GetPtrHash(e.Parent) == GetPtrHash(p))
end

local function isSpiritSword(sword)
  return sword:ToKnife() ~= nil and (sword.Variant == 10 or sword.Variant == 11)
end

--[[local function shouldApplyPenalties(flags)
  return not (flags & DamageFlag.DAMAGE_NO_PENALTIES == DamageFlag.DAMAGE_NO_PENALTIES or flags & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS)
end--]]

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife) --Charge Attack Detection/Sprite Stuff
  if not isSpiritSword(knife) or not knife.SpawnerEntity then return end
  local player = knife.SpawnerEntity:ToPlayer()
  if not player then return end
  local data = knife:GetData()
  local sprite = knife:GetSprite()
  if sprite:GetAnimation():find("Charged") then player:GetData().ChargedSpiritSword = true end
  if sprite:IsEventTriggered("SwingEnd") then player:GetData().ChargedSpiritSword = false end
  if knife.FrameCount > 8 and player:GetFireDirection() ~= -1 then
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
	  if not data.TargetSpawned then
		local t = Isaac.Spawn(1000, 30, 0, knife.Position, nullVector, player)
		t:GetData().IsSpiritTarget = true
		t.Parent = knife
		data.TargetSpawned = true
	  end
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) and knife.FrameCount <= 80 then
	  local s = 0.002
	  knife.SpriteScale = knife.SpriteScale + Vector(s, s)
	  knife.Scale = knife.Scale + s
	  knife.CollisionDamage = knife.CollisionDamage + (player.Damage * 0.05)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR) then
	  game:UpdateStrangeAttractor(knife.Position, 7, 450)
	  if knife.FrameCount == 9 then
		Isaac.Spawn(1000, 57, 0, knife.Position, nullVector, knife).Parent = knife
	  end
	end
  end
  if knife.FrameCount == 0 then
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TROPICAMIDE) then
	  local s = player:GetCollectibleCount(CollectibleType.COLLECTIBLE_TROPICAMIDE) * 0.05
	  knife.SpriteScale = knife.SpriteScale + Vector(s, s)
	  knife.Scale = knife.Scale + s
	end
  end
  if sprite:GetAnimation():find("Charged") and player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
	player:GetData().SoySpiritSwordSpin = sprite:GetAnimation():sub(8)
	knife:Remove()
  end
end, 0)

local oldStatus = false

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife) --Main Code
  if not isSpiritSword(knife) or not knife.SpawnerEntity then return end
  local player = knife.SpawnerEntity:ToPlayer()
  if not player then return end
  local data = knife:GetData()
  local sprite = knife:GetSprite()
  local effects = player:GetEffects()
  local brim = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or player:GetPlayerType() == PlayerType.PLAYER_AZAZEL or player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B or effects:HasTrinketEffect(TrinketType.TRINKET_AZAZELS_STUMP)
  if knife.FrameCount == 0 then
	if brim then
	  for _, l in pairs(Isaac.FindByType(7, 1)) do
		if l:GetData().IsSpiritBrimstone then
		  l:Remove()
		end
	  end
	  local vel = Vector.FromAngle(knife.Rotation - 90)
	  if knife.Rotation == 180 then vel = -vel end
	  local scale = 1
	  if player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then scale = 0.5 end
	  local laser = player:FireBrimstone(vel, player, scale)
	  laser:GetData().IsSpiritBrimstone = true
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) and player:GetData().ChargedSpiritSword then
		laser.Parent = knife
	  end
	  laser.MaxDistance = 100 + ((player.TearRange - 110) / 10)
	  if player:GetPlayerType() == PlayerType.PLAYER_AZAZEL or effects:HasTrinketEffect(TrinketType.TRINKET_AZAZELS_STUMP) then laser.MaxDistance = math.max(60, 60 + ((player.TearRange - 110) / 5)) end
	  laser.DepthOffset = -20
	  laser.Size = laser.Size * 10
	  local rot = 180
	  local s = 40
	  local to = 6
	  if knife.Rotation == 180 then
		rot = -rot
		s = -s
	  end
	  if player:GetData().ChargedSpiritSword then
		rot = 360
		s = 40
		to = 10
		laser.Angle = laser.Angle + 90
		if knife.Rotation == 180 then laser.Angle = 180 end
	  end
	  laser:SetActiveRotation(0, rot, s, false)
	  laser:SetTimeout(to)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TROPICAMIDE) then
	  local s = player:GetCollectibleCount(CollectibleType.COLLECTIBLE_TROPICAMIDE) * 0.05
	  knife.SpriteScale = knife.SpriteScale + Vector(s, s)
	  knife.Scale = knife.Scale + s
	end
  end
  --Detect swing end
  if oldStatus ~= player:GetData().ChargedSpiritSword then
	oldStatus = player:GetData().ChargedSpiritSword
	if oldStatus == false then
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
		for i = 0, 6, 2 do
		  local vel = Vector.FromAngle(knife.Rotation) * ((i + 18) * player.ShotSpeed) + player:GetTearMovementInheritance(Vector.FromAngle(knife.Rotation)) * 2
		  player:FireTear(knife.Position, vel, false, false, true, player):ChangeVariant(47)
		end
	  end
	  for _, t in pairs(Isaac.FindByType(2, 47)) do
		if t.FrameCount <= 2 then
		  if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
			player:FireBomb(t.Position, t.Velocity, player)
			t:Remove()
		  end
		  if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
			player:FireTechXLaser(t.Position, t.Velocity, 42, player, 2)
		  end
		end
	  end
	end
  end
end, 4)

local dirs = {
  ["Down"] = 90,
  ["Bottom Left"] = 135,
  ["Left"] = 180,
  ["Top Left"] = 225,
  ["Top"] = 270,
  ["Top Right"] = 315,
  ["Right"] = 0,
  ["Bottom Right"] = 45
}

local function spawnSoySword(player, rot)
  local var = player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) and 11 or 10
  local k = player:FireKnife(player, dirs[rot] or 0, true, 0, var)
  local s = k:GetSprite()
  s:SetFrame("Spin"..rot, 2)
  s.PlaybackSpeed = 1.5
  k.CollisionDamage = player.Damage * 20 --So it doesn't take forever to kill everything
  k.Scale = k.Scale + 0.2
  k:Update()
  k:GetData().IsSoySpinningSword = true
  fixSwordSprite(k)
  sfx:Play(SoundEffect.SOUND_SHELLGAME)
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player) --Ludo/Soy milk Code
  if not player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then return end
  local data = player:GetData()
  if data.ChargedSpiritSword and not player:GetActiveWeaponEntity() then
	data.ChargedSpiritSword = false
  end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
	if not data.LudoSpiritSword or not data.LudoSpiritSword:Exists() then
	  data.LudoSpiritSword = player:FireTear(player.Position, nullVector, false, true, false, player, 2)
	  data.LudoSpiritSword:AddTearFlags(TearFlags.TEAR_LUDOVICO | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
	  data.LudoSpiritSword:GetSprite():Load("blank.anm2", true) --Hide the tear without removing the shadow
	  local e = Isaac.Spawn(1000, 8, 0, data.LudoSpiritSword.Position, nullVector, player) --Spawn a ladder to be used as the tear sprite
	  e:GetSprite():Load("gfx/002.047_sword tear.anm2", true) --This is needed because of how ludo tears don't like having their variant changed
	  e.SpriteOffset = Vector(0, -15)
	  data.LudoSpiritSword:GetData().SwordEffect = e
	else
	  data.LudoSpiritSword = data.LudoSpiritSword:ToTear()
	  local v = player:GetShootingInput() * (14 * player.ShotSpeed)
	  data.LudoSpiritSword.Velocity = v
	  data.LudoSpiritSword.FallingAcceleration = -0.1
	  data.LudoSpiritSword.FallingSpeed = 0
	  local c = data.LudoSpiritSword:GetData().SwordEffect:ToEffect()
	  c.Position = data.LudoSpiritSword.Position + data.LudoSpiritSword.Velocity
	  c.SpriteRotation = v:GetAngleDegrees()
	  c.SpriteScale = Vector(1.3, 1.3)
	  c:SetTimeout(100)
	  c:GetSprite():Play("Idle")
	end
  end
  if data.SoySpiritSwordSpin then
	spawnSoySword(player, data.SoySpiritSwordSpin)
	data.SoySpiritSwordSpin = nil
	data.ChargedSpiritSword = false
  end
  for _, s in pairs(findSwords()) do
	if wasSpawnedBy(s, player) and s:GetData().IsSoySpinningSword then
	  s = s:ToKnife()
	  local spr = s:GetSprite()
	  if not s.Child then
		local k = player:FireKnife(player, s.Rotation, true, 4, s.Variant)
		local spr = k:GetSprite()
		spr:SetFrame(spr:GetAnimation(), 2)
		spr.PlaybackSpeed = 1.5
		k.Visible = false
		k.CollisionDamage = s.CollisionDamage
		k.Scale = s.Scale
		k:Update()
		s.Child = k
	  end
	  if player:GetFireDirection() ~= -1 then
		if spr:GetFrame() >= 10 then
		  spawnSoySword(player, spr:GetAnimation():sub(5))
		  s:Remove()
		  s:Update()
		end
	  else
		s:Remove()
		s:Update()
	  end
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam) --Sprinkler Code
  if not fam.Player then return end
  local player = fam.Player
  local sprite = fam:GetSprite()
  local anim = sprite:GetAnimation()
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
	if fam.FireCooldown > 0 then fam.FireCooldown = fam.FireCooldown - 1 end
	if anim:find("MomsEye") then
	  local angle = dirs[anim:sub(9)]
	  if angle and fam.FireCooldown == 0 then
		for i = 0, 1 do
		  local k = player:FireKnife(fam, angle + 180 * i, true, 0, 10)
		  k.Position = fam.Position
		  k:GetData().Rotation = angle + 180 * i
		  fixSwordSprite(k)
		end
		fam.FireCooldown = 10
	  end
	elseif anim:find("Loki") then
	  local angle = dirs[anim:sub(6)]
	  if angle and fam.FireCooldown == 0 then
		for i = 0, 3 do
		  local k = player:FireKnife(fam, angle + 90 * i, true, 0, 10)
		  k.Position = fam.Position
		  k:GetData().Rotation = angle + 90 * i
		  fixSwordSprite(k)
		end
		fam.FireCooldown = 10
	  end
	else
	  local angle = dirs[anim]
	  if angle and fam.FireCooldown == 0 then
		local k = player:FireKnife(fam, angle, true, 0, 10)
		k.Position = fam.Position
		k:GetData().Rotation = angle
		fixSwordSprite(k)
		fam.FireCooldown = 10
	  end
	end
	for _, s in ipairs(findSwords()) do
	  if wasSpawnedBy(s, fam) then
		if s:GetSprite():IsEventTriggered("SwingEnd") then
		  local t = player:FireTear(s.Position, Vector.FromAngle(s:GetData().Rotation) * 10, false, true, false, s)
		  t:ChangeVariant(47)
		  t:Update()
		end
		if s.FrameCount >= 8 then s:Remove() end
	  end
	end
  end
end, 120)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam) --Shade Code
  local player = fam.Player
  if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then return end
  local data = fam:GetData()
  fam.FireCooldown = fam.FireCooldown or 0
  for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, 55, EntityPartition.ENEMY)) do
	if enemy:ToNPC() and fam.FireCooldown <= 0 then
	  local var = player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) and 11 or 10
	  local k = player:FireKnife(fam, (enemy.Position - fam.Position):GetAngleDegrees(), true, 0, var)
	  fixSwordSprite(k)
	  k.Position = fam.Position
	  k.Color = Color(0, 0, 0, 1, 0, 0, 0)
	  k:GetSprite().PlaybackSpeed = 1.5
	  k:GetData().IsShadeSword = true
	  k.CollisionDamage = player.Damage * 1.5
	  fam.FireCooldown = 6
	  break
	end
  end
  if fam.FireCooldown > 0 then fam.FireCooldown = fam.FireCooldown - 1 end
  for _, s in ipairs(findSwords()) do
	local spr = s:GetSprite()
	if s:GetData().IsShadeSword and wasSpawnedBy(s, fam) and spr:IsFinished(spr:GetAnimation()) then s:Remove() end
  end
end, 106)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player, amount, flags) --Cursed Eye Code
  player = player:ToPlayer()
  local w = player:GetActiveWeaponEntity()
  if not w then return end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then return end
  if not isSpiritSword(w) then return end
  --Reimplements Cursed Eye teleport
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) and w:GetSprite():GetAnimation():find("Idle") then
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, false, false, false, false)
  end
end, 1)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, l) --Brimstone Code
  if l:GetData().IsSpiritBrimstone then
	local player = l.SpawnerEntity:ToPlayer()
	l.CollisionDamage = 0
	local d = player.Damage
	if player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then d = d / 2 end
	dealDamageInLine(l.Position, player.Damage, l.Angle, 30, 4, DamageFlag.DAMAGE_LASER)
	if l.Shrink then l:Remove() end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect) --Epic Fetus Code
  if not effect:GetData().IsSpiritTarget then return end
  local player = effect.SpawnerEntity:ToPlayer()
  local sprite = effect:GetSprite()
  sprite.PlaybackSpeed = 0.5
  if effect.FrameCount % 4 == 0 then sprite:Play("Blink", true) end --Spawned targets don't animate properly
  effect.Velocity = player:GetShootingInput() * 20
  if player:GetFireDirection() == -1 or not effect.Parent then
	local rocket = Isaac.Spawn(1000, 31, 0, effect.Position, nullVector, player):ToEffect()
	rocket:SetTimeout(10)
	rocket:Update()
	effect:Remove()
  end
end, 30)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player) --Tammy's Head Code
  if not player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then return end
  for _, t in pairs(Isaac.FindByType(2)) do
	if t.FrameCount <= 1 then
	  t = t:ToTear()
	  t:ChangeVariant(47)
	  t.CollisionDamage = t.CollisionDamage * 1.5
	  t.Scale = t.Scale + 0.2
	end
  end
end, CollectibleType.COLLECTIBLE_TAMMYS_HEAD)
