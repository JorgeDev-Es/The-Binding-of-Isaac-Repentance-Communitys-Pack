local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local REMOVE_CHANCE = 0.03
local TRIGGER_CHANCE = 0.15
local DISAPPEAR_COUNTDOWN = 45 -- 1.5 seconds
local DROP_VELOCITY_MULT = 2

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	player.Luck = player.Luck + player:GetEffects():GetTrinketEffectNum(mod.Trinket.LUCKY_BUG)
end, CacheFlag.CACHE_LUCK)

mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, function(_, player)
	if player:HasTrinket(mod.Trinket.LUCKY_BUG) then
		local trinketMult = player:GetTrinketMultiplier(mod.Trinket.LUCKY_BUG)
		local trinketRoll = player:GetTrinketRNG(mod.Trinket.LUCKY_BUG):RandomFloat()
		local playerFx = player:GetEffects()
		
		if trinketRoll <= REMOVE_CHANCE and playerFx:HasTrinketEffect(mod.Trinket.LUCKY_BUG) then
			local pickupVel = EntityPickup.GetRandomPickupVelocity(player.Position) * DROP_VELOCITY_MULT
			local pickup = Isaac.Spawn(
				EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, mod.Trinket.LUCKY_BUG, 
				player.Position, pickupVel, player):ToPickup()
			pickup.Timeout = DISAPPEAR_COUNTDOWN
			pickup.Touched = true -- Just in case
			
			player:AnimateSad()
			player:TryRemoveTrinket(mod.Trinket.LUCKY_BUG)
			playerFx:RemoveTrinketEffect(mod.Trinket.LUCKY_BUG, -1)
		elseif trinketRoll <= TRIGGER_CHANCE * trinketMult + REMOVE_CHANCE then
			player:AnimateHappy()
			playerFx:AddTrinketEffect(mod.Trinket.LUCKY_BUG)
		end
	end
end)