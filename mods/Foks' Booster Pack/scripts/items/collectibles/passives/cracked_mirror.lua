local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local DROP_CHANCE = 0.125 -- Chance at 0 luck
local DROP_CHANCE_LUCK = 0.025
local DROP_CHANCE_MIN = 0.05
local DROP_CHANCE_MAX = 0.5 -- Maxes out at -15 luck
local DISAPPEAR_TIME = 210 -- 7 seconds

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, collectible, charge, firstTime, slot, data, player)
	if firstTime then game:GetItemPool():ForceAddPillEffect(PillEffect.PILLEFFECT_LUCK_DOWN) end
end, mod.Collectible.CRACKED_MIRROR)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	player.Luck = player.Luck - player:GetCollectibleNum(mod.Collectible.CRACKED_MIRROR)
end, CacheFlag.CACHE_LUCK)

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	local player = PlayerManager.FirstCollectibleOwner(mod.Collectible.CRACKED_MIRROR)
	if not player then return end
	local dropChance = mod.Clamp(-player.Luck * DROP_CHANCE_LUCK + DROP_CHANCE, DROP_CHANCE_MIN, DROP_CHANCE_MAX)
	
	if npc:GetDropRNG():RandomFloat() <= dropChance then
		local pickup = Isaac.Spawn(
			EntityType.ENTITY_PICKUP, mod.Pickup.MIRROR_SHARD, 0, 
			npc.Position, Vector.Zero, player):ToPickup()
		pickup.Timeout = DISAPPEAR_TIME
	end
end)