local mod = APonySyn
local PonyCallbacks = {}

local Callbacks = {}
PonyCallbacks.POST_PONY_UPDATE = 1 --Runs off of MC_POST_PLAYER_UPDATE when the player is on A Pony
PonyCallbacks.ON_PONY_EFFECT = 2 --Runs every 5 or so frames while the player is on A Pony
PonyCallbacks.ON_PONY_INIT = 3 --Runs off of MC_USE_ITEM when the player uses A Pony
PonyCallbacks.POST_PONY_COLLISION = 4 --Runs when the player hits an enemy while on A Pony
PonyCallbacks.POST_PONY_DEATH = 5 --Runs when the player kills an enemy via the A Pony dash
Callbacks[PonyCallbacks.POST_PONY_UPDATE] = {}
Callbacks[PonyCallbacks.ON_PONY_EFFECT] = {}
Callbacks[PonyCallbacks.ON_PONY_INIT] = {}
Callbacks[PonyCallbacks.POST_PONY_COLLISION] = {}
Callbacks[PonyCallbacks.POST_PONY_DEATH] = {}

function PonyCallbacks.AddCallback(callback, func, arg)
  if true then
	table.insert(Callbacks[callback], func)
  end
end

function PonyCallbacks.RemoveCallback(callback, func, arg)
  if true then
	for i, v in ipairs(Callbacks[callback]) do
	  if v == func then
		table.remove(Callbacks[callback], i)
	  end
	end
  end
end

local enemyList = {}

local function hasPony(player)
  local has = player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_PONY) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHITE_PONY)
  local which = CollectibleType.COLLECTIBLE_PONY
  if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHITE_PONY) then which = CollectibleType.COLLECTIBLE_WHITE_PONY end
  return has, which
end

local function beenHit(enemy)
  for _, en in pairs(enemyList) do
	if GetPtrHash(en) == GetPtrHash(enemy) then
	  return true
	end
  end
  table.insert(enemyList, enemy)
  return false
end

local queued = {
  isQueued = false,
  player = nil,
  pony = CollectibleType.COLLECTIBLE_PONY,
}

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
  if queued.isQueued then
	queued.player:GetEffects():AddCollectibleEffect(queued.pony)
	queued.player = nil
	queued.isQueued = false
	local list = Callbacks[PonyCallbacks.ON_PONY_INIT]
	for _, func in pairs(list) do
	  func(self, player, false)
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
  local effects = player:GetEffects()
  local room = Game():GetRoom()
  local has, which = hasPony(player)
  for i = 0, 7 do
	local door = room:GetDoor(i)
	if has and door and room:IsDoorSlotAllowed(i) and room:GetFrameCount() > 5 then
	  local pos = room:GetDoorSlotPosition(i)
	  if player.Position:Distance(pos) <= 10 then
		queued.isQueued = true
		queued.player = player
		queued.pony = which
	  end
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider, low)
  if collider and collider:ToPlayer() and hasPony(collider:ToPlayer()) then
	if beenHit(npc) then return end
	numberHit = numberHit + 1
	local list = Callbacks[PonyCallbacks.POST_PONY_COLLISION]
	for _, func in pairs(list) do
	  func(self, player, npc, numberHit)
	end
	if npc:HasMortalDamage() then
	  local list = Callbacks[PonyCallbacks.POST_PONY_DEATH]
	  for _, func in pairs(list) do
		func(self, player, npc)
	  end
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
  if not hasPony(player) then
	enemyList = {}
	numberHit = 0
  end
  if hasPony(player) then
	local list = Callbacks[PonyCallbacks.POST_PONY_UPDATE]
	for _, func in pairs(list) do
	  func(self, player)
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
  for p = 0, Game():GetNumPlayers() - 1 do
	local player = Isaac.GetPlayer(p)
	if hasPony(player) then
	  if player.FrameCount % 5 == 0 then
		local list = Callbacks[PonyCallbacks.ON_PONY_EFFECT]
		for _, func in pairs(list) do
		  func(self, player)
		end
	  end
	end
  end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player)
  if item == CollectibleType.COLLECTIBLE_PONY or item == CollectibleType.COLLECTIBLE_WHITE_PONY then
	local list = Callbacks[PonyCallbacks.ON_PONY_INIT]
	for _, func in pairs(list) do
	  func(self, player, true)
	end
  end
end)

return PonyCallbacks
