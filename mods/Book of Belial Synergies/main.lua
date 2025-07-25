local mod = RegisterMod("Book of Belial Synergies", 1) --Made by Jaemspio

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()
local itemPool = game:GetItemPool()
local hud = game:GetHUD()
local nullVector = Vector(0, 0)
include("EID")

local synergies = {
  [CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK] = true,
  [CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS] = true,
  [CollectibleType.COLLECTIBLE_JAR_OF_FLIES] = true,
  [CollectibleType.COLLECTIBLE_D20] = true,
  [CollectibleType.COLLECTIBLE_DECK_OF_CARDS] = true,
  [CollectibleType.COLLECTIBLE_LEMON_MISHAP] = true,
  [CollectibleType.COLLECTIBLE_MR_BOOM] = true,
  [CollectibleType.COLLECTIBLE_NECRONOMICON] = true,
  [CollectibleType.COLLECTIBLE_TELEPORT] = true,
  [CollectibleType.COLLECTIBLE_PORTABLE_SLOT] = true,
  [CollectibleType.COLLECTIBLE_BOOK_OF_SIN] = true,
  [CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS] = true,
  [CollectibleType.COLLECTIBLE_D12] = true,
  [CollectibleType.COLLECTIBLE_TELEPORT_2] = true,
  [CollectibleType.COLLECTIBLE_D1] = true,
  [CollectibleType.COLLECTIBLE_COMPOST] = true,
  [CollectibleType.COLLECTIBLE_MYSTERY_GIFT] = true,
  [CollectibleType.COLLECTIBLE_MOVING_BOX] = true,
  [CollectibleType.COLLECTIBLE_FREE_LEMONADE] = true,
  [CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS] = true,
  [CollectibleType.COLLECTIBLE_CRYSTAL_BALL] = true,
  [CollectibleType.COLLECTIBLE_BEST_FRIEND] = true,
  [CollectibleType.COLLECTIBLE_DEAD_SEA_SCROLLS] = true,
  [CollectibleType.COLLECTIBLE_MONSTROS_TOOTH] = true,
  [CollectibleType.COLLECTIBLE_POOP] = true,
  [CollectibleType.COLLECTIBLE_YUM_HEART] = true,
  [CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD] = true,
  [CollectibleType.COLLECTIBLE_SHARP_STRAW] = true,
  [CollectibleType.COLLECTIBLE_KEEPERS_BOX] = true,
}
local bombsLeft = 0

local function spawnFireEffects(pos, sound)
  for i = 1, 5 do
	local dust = Isaac.Spawn(1000, 59, 0, pos - Vector(0, 4), Vector(math.random(-7, 11) / 10, math.random(-17, -3)), nil):ToEffect()
	dust:SetTimeout(math.random(8, 11))
	dust.Color = Color(3, 0.8, 0.8, 1, 0.2, 0, 0)
	dust.Scale = math.random(14, 23) / 10
  end
  local poof = Isaac.Spawn(1000, 15, 0, pos, nullVector, nil):ToEffect()
  poof.Color = Color(0.3, 0.3, 0.3, 0.6, 0, 0, 0)
  if sound then sfx:Play(SoundEffect.SOUND_DEVIL_CARD) end
end

--Somehow, no one else could figure this out, dispite how simple it is
local function translateName(str)
  if str:sub(1, 1) ~= "#" then return str end
  local ret = ""
  str = str:sub(2)
  str = str:sub(1, -5)
  str = str:gsub("_", " ")
  str = str:lower()
  for i = 1, #str do
	local letter = str:sub(i, i)
	if i == 1 or str:sub(i - 1, i - 1) == " " then
	  letter = letter:upper()
	end
	ret = ret..letter
  end
  return ret
end

--It's very hacky, but because MC_PRE_USE_ITEM is bugged with Judas's Birthright, it's needed
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, button)
  if entity and button == ButtonAction.ACTION_ITEM then
	local player = entity:ToPlayer()
	if player and player:GetActiveItem() ~= 0 then
	  local data = player:GetData()
	  local item = player:GetActiveItem()
	  local charges = player:GetActiveCharge()
	  local maxCharges = config:GetCollectible(item).MaxCharges
	  if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) and synergies[item] then
		if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) and charges >= maxCharges then
		  data.OldCoinCount = player:GetNumCoins()
		  player:UseActiveItem(item, UseFlag.USE_NOHUD, ActiveSlot.SLOT_PRIMARY)
		  player:SetActiveCharge(player:GetBatteryCharge() or 0) --Just in case
		  if item ~= CollectibleType.COLLECTIBLE_JAR_OF_FLIES and item ~= CollectibleType.COLLECTIBLE_PORTABLE_SLOT then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then player:AddWisp(item, player.Position) end
		  end
		  if item == CollectibleType.COLLECTIBLE_MYSTERY_GIFT then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_MYSTERY_GIFT)
		  end
		  return false
		end
	  end
	end
  end
end, InputHook.IS_ACTION_TRIGGERED)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, flags, slot)
  if flags & UseFlag.USE_NOHUD == 0 then return end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) and synergies[item] then
	local room = game:GetRoom()
	local data = player:GetData()
	local sprite = player:GetSprite()
	local effects = player:GetEffects()
	if not data.damageBuff then data.damageBuff = 0 end
	if item == CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK then
	  bombsLeft = bombsLeft + 6
	elseif item == CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS then
	  for _, s in pairs(Isaac.FindByType(3, 73)) do
		if s.FrameCount <= 1 then
		  s.SubType = 666
		  s:SetColor(Color(2, 1, 0, 1, 0.3, 0, -0.5), 2, 999, false, true)
		end
	  end
	  spawnFireEffects(player.Position, true)
	elseif item == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then
	  local didSpawn = false
	  for _, f in pairs(Isaac.FindByType(3, 43)) do
		if f.FrameCount <= 1 then
		  f.SubType = 666
		  f:SetColor(Color(1.8, 0.2, 0.2, 1, 0.35, -0.2, -0.3), 2, 999, false, true)
		  didSpawn = true
		end
	  end
	  if didSpawn then
		spawnFireEffects(player.Position, true)
	  end
	elseif item == CollectibleType.COLLECTIBLE_D20 then
	  for _, pickup in pairs(Isaac.FindByType(5, 10)) do
		pickup = pickup:ToPickup()
		if rng:RandomInt(4) == 1 then
		  pickup:Morph(5, 10, 6, true, true, true)
		  spawnFireEffects(pickup.Position)
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_DECK_OF_CARDS then
	  Isaac.Spawn(5, 300, 16, Isaac.GetFreeNearPosition(player.Position, 20), nullVector, nil)
	elseif item == CollectibleType.COLLECTIBLE_LEMON_MISHAP then
	  for _, creep in pairs(Isaac.FindByType(1000, 32)) do
		if creep.FrameCount <= 1 then
		  local color = Color.Default
		  color:SetColorize(2.2, 0.2, 0.2, 1)
		  creep.Color = color
		  creep.CollisionDamage = player.Damage * 4
		end
	  end
	  spawnFireEffects(player.Position, true)
	elseif item == CollectibleType.COLLECTIBLE_MR_BOOM then
	  for _, bomb in pairs(Isaac.FindByType(4, 1)) do
		bomb = bomb:ToBomb()
		if bomb.FrameCount <= 1 then
		  bomb:AddTearFlags(TearFlags.TEAR_BURN)
		  bomb.ExplosionDamage = bomb.ExplosionDamage * 2
		  spawnFireEffects(bomb.Position, true)
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_NECRONOMICON then
	  for _, npc in pairs(Isaac.GetRoomEntities()) do
		npc = npc:ToNPC()
		if npc then
		  npc:AddBurn(EntityRef(player), 102, player.Damage * 2)
		  spawnFireEffects(npc.Position)
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_TELEPORT then
	  if rng:RandomInt(6) == 0 then
		player:UseCard(Card.CARD_JOKER, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
		spawnFireEffects(player.Position, true)
	  end
	elseif item == CollectibleType.COLLECTIBLE_PORTABLE_SLOT and (data.OldCoinCount or player:GetNumCoins()) > 0 then
	  if not (sprite:IsPlaying("Sad") and sprite:GetFrame() == 0) then
		data.damageBuff = data.damageBuff + 0.5
		spawnFireEffects(player.Position, true)
	  end
	elseif item == CollectibleType.COLLECTIBLE_BOOK_OF_SIN then
	  local toAdd = math.random(87, 94)
	  for _, p in pairs(Isaac.FindByType(5)) do
		if p.FrameCount <= 1 then
		  local var = p.Variant / 10
		  if var == 1 or var == 3 or var == 4 or var == 9 then
			toAdd = toAdd * 2
		  elseif var == 6.9 then
			toAdd = toAdd * 4
		  elseif var == 30 or var == 7 then
			toAdd = toAdd * 3
		  end
		  break
		end
	  end
	  data.damageBuff = data.damageBuff + toAdd / 100
	  spawnFireEffects(player.Position, true)
	elseif item == CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS then
	  local didSpawn = false
	  for _, fam in pairs(Isaac.FindByType(3)) do
		fam = fam:ToFamiliar()
		if fam.Player.Index == player.Index and fam.Variant ~= 43 and fam.Variant ~= 73 then
		  spawnFireEffects(fam.Position)
		  data.damageBuff = data.damageBuff + 1
		  didSpawn = true
		end
	  end
	  if not didSpawn then
		effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_DEMON_BABY)
		effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LIL_BRIMSTONE)
		spawnFireEffects(player.Position, true)
	  end
	elseif item == CollectibleType.COLLECTIBLE_D12 then
	  for i = 0, room:GetGridSize() do
		local grid = room:GetGridEntity(i)
		local pos = room:GetGridPosition(i)
		local fire = false
		for _, f in pairs(Isaac.FindByType(33)) do
		  if pos:Distance(f.Position) <= 1 and f.HitPoints > 1 then
			fire = true
		  end
		end
		if (grid and grid:GetType() ~= GridEntityType.GRID_DECORATION and grid:GetType() ~= GridEntityType.GRID_WALL and not grid:ToDoor() and not grid:ToPressurePlate())
		or fire then
		  if not grid:ToPoop() or (grid:ToPoop() and grid.Desc.State ~= 1000) then
			data.damageBuff = data.damageBuff + 0.15
			spawnFireEffects(pos)
		  end
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_TELEPORT_2 then
	  data.WaitingForTeleportTwo = true
	elseif item == CollectibleType.COLLECTIBLE_D1 then
	  for _, pickup in pairs(Isaac.FindByType(5, 10)) do
		pickup = pickup:ToPickup()
		if pickup.FrameCount <= 1 and rng:RandomInt(3) == 1 then
		  pickup:Morph(5, 10, 6, true, true, true)
		  spawnFireEffects(pickup.Position)
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_COMPOST then
	  for _, fam in pairs(Isaac.FindByType(3)) do
		fam = fam:ToFamiliar()
		if fam.Player.Index == player.Index and (fam.Variant == 43 or fam.Variant == 73) then
		  data.damageBuff = data.damageBuff + 0.1
		end
	  end
	  spawnFireEffects(player.Position, true)
	elseif item == CollectibleType.COLLECTIBLE_MYSTERY_GIFT then
	  for _, poop in pairs(Isaac.FindByType(5, 100, 36)) do
		poop = poop:ToPickup()
		if poop.FrameCount <= 1 then
		  poop:Morph(5, 100, itemPool:GetCollectible(ItemPoolType.POOL_DEVIL, true, rng:GetSeed(), 51), true, true, true)
		  for _, fart in pairs(Isaac.FindByType(1000, 34)) do
			if fart.FrameCount <= 1 then fart:Remove() end
		  end
		  sfx:Stop(SoundEffect.SOUND_FART)
		  spawnFireEffects(poop.Position, true)
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_MOVING_BOX then
	  data.MovingBoxExtraDamage = 0
	  for _, pickup in pairs(Isaac.FindByType(5)) do
		if not pickup:Exists() then
		  local toAdd = pickup.Variant == 100 and 0.9 or 0.2
		  data.MovingBoxExtraDamage = data.MovingBoxExtraDamage + toAdd
		  spawnFireEffects(pickup.Position)
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_FREE_LEMONADE then
	  for _, creep in pairs(Isaac.FindByType(1000, 78)) do
		if creep.FrameCount <= 1 then
		  local color = Color.Default
		  color:SetColorize(2.2, 0.2, 0.2, 1)
		  creep.Color = color
		  creep.CollisionDamage = player.Damage * 4
		end
	  end
	  spawnFireEffects(player.Position, true)
	elseif item == CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS then
	  spawnFireEffects(player.Position, true)
	elseif item == CollectibleType.COLLECTIBLE_CRYSTAL_BALL then
	  --Copy pasted code :)
	  for _, pickup in pairs(Isaac.FindByType(5, 10, 3)) do
		pickup = pickup:ToPickup()
		if pickup.FrameCount <= 1 then
		  pickup:Morph(5, 10, 6, true, true, true)
		  spawnFireEffects(pickup.Position, true)
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_BEST_FRIEND then
	  spawnFireEffects(player.Position, true)
	elseif item == CollectibleType.COLLECTIBLE_MONSTROS_TOOTH then
	  for _, monstro in pairs(Isaac.FindByType(1000, 28)) do
		if monstro.FrameCount <= 1 then
		  local sprite = monstro:GetSprite()
		  sprite:Load("gfx/043.000_monstro ii.anm2", true)
		  sprite:Play("JumpDown", true)
		  monstro.Parent = player
		  monstro:GetData().IsBelialMonstro = true
		end
	  end
	  spawnFireEffects(player.Position, true)
	elseif item == CollectibleType.COLLECTIBLE_YUM_HEART then
	  data.damageBuff = data.damageBuff + player:GetHearts() * math.random(78, 93) / 100
	  if player:GetHearts() > 0 then
		spawnFireEffects(player.Position, true)
	  end
	elseif item == CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD then
	  for _, bony in pairs(Isaac.FindByType(227)) do
		if bony.FrameCount <= 1 then
		  bony:ToNPC():Morph(bony.Type, bony.Variant, bony.SubType, 0)
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_SHARP_STRAW then
	  for _, npc in pairs(Isaac.GetRoomEntities()) do
		npc = npc:ToNPC()
		if npc and npc:IsActiveEnemy() and rng:RandomInt(20) == 0 then
		  Isaac.Spawn(5, 10, 6, Isaac.GetFreeNearPosition(player.Position, 20), nullVector, nil)
		  spawnFireEffects(player.Position, true)
		  break
		end
	  end
	elseif item == CollectibleType.COLLECTIBLE_KEEPERS_BOX then
	  for _, item in pairs(Isaac.FindByType(5, 100)) do
		if item.FrameCount <= 1 and item.Price ~= 0 then
		  item:ToPickup():Morph(5, 100, itemPool:GetCollectible(ItemPoolType.POOL_CURSE, true, rng:GetSeed(), 25), true, true, true)
		  spawnFireEffects(item.Position)
		  rng:Next()
		end
	  end
	end
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
  end
end)

local validDevilActives = {
  34,
  83,
  84,
  123,
  145,
  292,
  441,
  545,
  556,
  704,
  705,
  712,
}

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, item, rng, player, flags, slot)
  if flags & UseFlag.USE_NOHUD == 0 then return end
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) and synergies[item] then
	local room = game:GetRoom()
	local data = player:GetData()
	local sprite = player:GetSprite()
	local effects = player:GetEffects()
	if not data.damageBuff then data.damageBuff = 0 end
	if item == CollectibleType.COLLECTIBLE_DEAD_SEA_SCROLLS then
	  player:AnimateCollectible(CollectibleType.COLLECTIBLE_DEAD_SEA_SCROLLS, "UseItem")
	  local item = config:GetCollectible(validDevilActives[rng:RandomInt(#validDevilActives) + 1])
	  hud:ShowItemText(translateName(item.Name))
	  player:UseActiveItem(item.ID, false, false, true, true)
	  spawnFireEffects(player.Position, true)
	  return true
	elseif item == CollectibleType.COLLECTIBLE_POOP then
	  local pos = Isaac.GetFreeNearPosition(player.Position, 0)
	  local var = rng:RandomInt(2) * 5
	  Isaac.GridSpawn(14, var, pos, true)
	  if var == 5 then spawnFireEffects(pos) end
	  return true
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, monstro) --Monstro's Tooth
  if not monstro:GetData().IsBelialMonstro then return end
  local player = monstro.Parent:ToPlayer()
  local sprite = monstro:GetSprite()
  if sprite:IsPlaying("JumpDown") and sprite:GetFrame() == 58 then
	sprite:Play("Taunt", true)
	for i = 0, 1000, 5 do
	  for _, npc in pairs(Isaac.GetRoomEntities()) do
		npc:ToNPC()
		if npc and npc.Position:Distance(monstro.Position) <= i then
		  if npc.Position.X - monstro.Position.X > 0 then
			monstro.FlipX = true
		  end
		  break
		end
	  end
	end
  elseif sprite:IsPlaying("Taunt") and sprite:IsEventTriggered("Shoot") then
	local dir = Vector(-1, 0)
	if monstro.FlipX then dir = -dir end
	local brim = player:FireBrimstone(dir, monstro)
	brim.Parent = monstro
	brim.Position = monstro.Position
	brim:SetTimeout(24)
  elseif sprite:IsFinished("Taunt") then
	monstro.FlipX = false
	sprite:Play("JumpUp", true)
  end
end, 28)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
  for p = 0, game:GetNumPlayers() - 1 do
	local player = Isaac.GetPlayer(p)
	local data = player:GetData()
	data.damageBuff = 0
	if data.WaitingForTeleportTwo then
	  data.WaitingForTeleportTwo = false
	  data.damageBuff = data.damageBuff + 2
	  spawnFireEffects(player.Position, true)
	end
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
  end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider, low)
  if not collider then return end
  local player = collider:ToPlayer()
  if not player then return end
  local effects = player:GetEffects()
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) and effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS) then
	if not npc:HasEntityFlags(EntityFlag.FLAG_BURN) then
	  spawnFireEffects(npc.Position)
	  npc:AddBurn(EntityRef(player), 82, player.Damage)
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
  if cache == CacheFlag.CACHE_DAMAGE then
	local data = player:GetData()
	for _, fly in pairs(Isaac.FindByType(3, 43, 666)) do
	  fly = fly:ToFamiliar()
	  if fly.Player.Index == player.Index then
		player.Damage = player.Damage + 0.47
	  end
	end
	if data.MovingBoxExtraDamage then
	  player.Damage = player.Damage + data.MovingBoxExtraDamage
	end
	data.damageBuff = data.damageBuff or 0
	player.Damage = player.Damage + data.damageBuff
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb) --Anarchist's Cookbook
  if bombsLeft == 0 then return end
  if not bomb.SpawnerEntity then return end
  local player = bomb.SpawnerEntity:ToPlayer()
  if not player then return end
  if bomb.FrameCount == 1 then
	bomb:AddTearFlags(TearFlags.TEAR_BURN)
	bomb.ExplosionDamage = bomb.ExplosionDamage * 1.2
	spawnFireEffects(bomb.Position)
	bombsLeft = math.max(0, bombsLeft - 1)
  end
end, 3)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb) --Best Friend
  if not bomb.SpawnerEntity then return end
  local player = bomb.SpawnerEntity:ToPlayer()
  if not player then return end
  if bomb:IsDead() and player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
	for i = 0, 360, 60 do
	  Isaac.Spawn(1000, 52, 0, bomb.Position, Vector.FromAngle(i) * 8, bomb)
	end
  end
end, 2)

--Box of Spiders
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
  if fam.SubType == 666 then
	fam:SetColor(Color(2, 1, 0, 1, 0.3, 0, -0.5), 2, 999, false, true)
	fam.CollisionDamage = fam.Player.Damage * 3
  end
end, 73)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider, low)
  if fam.SubType ~= 666 then return end
  if collider and collider:ToNPC() then
	collider:AddBurn(EntityRef(fam), 62, fam.CollisionDamage)
  end
end, 73)

--Jar of Flies
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
  if fam.SubType == 666 then
	fam:SetColor(Color(1.8, 0.2, 0.2, 1, 0.35, -0.2, -0.3), 2, 999, false, true)
  end
end, 43)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider, low)
  if fam.SubType ~= 666 then return end
  if collider and collider:ToNPC() then
	local player = fam.Player
	fam.SubType = 0
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
  end
end, 43)
