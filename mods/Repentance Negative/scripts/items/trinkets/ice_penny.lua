local Mod = RepMMod

---@param coin EntityPickup
---@param collider Entity
---@param low boolean
---@return boolean | nil?
function PostCollisionWithIcePenny(_, coin, collider, low)
	if collider and collider:ToPlayer() then
		local player = collider:ToPlayer()
		---@cast player EntityPlayer
		if not player:HasTrinket(Mod.RepmTypes.TRINKET_ICE_PENNY) then
			return
		end
		local sprite = coin:GetSprite()
		if sprite:IsPlaying("Collect") and sprite:GetFrame() == 0 then
			local rng = coin:GetDropRNG()
			local iceChance = {
				[CoinSubType.COIN_PENNY] = 0.1245,
				[CoinSubType.COIN_GOLDEN] = 0.1245,
				[CoinSubType.COIN_LUCKYPENNY] = 0.1245,
				[CoinSubType.COIN_NICKEL] = 0.22875,
				[CoinSubType.COIN_DOUBLEPACK] = 0.22875,
				[CoinSubType.COIN_DIME] = 0.62475,
				Default = 0.1245
			}
			local chance = rng:RandomFloat()
			local coinChance = iceChance[coin.SubType] or iceChance.Default
			if chance <= coinChance then
				local heart = rng:RandomFloat() <= 0.05 and Mod.RepmTypes.PICKUP_HEART_FROZEN
					or Mod.RepmTypes.PICKUP_HEART_FROZEN_HALF
				Isaac.Spawn(
					EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_HEART,
					heart,
					Game():GetRoom():FindFreePickupSpawnPosition(coin.Position),
					Vector.Zero,
					nil
				)
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, PostCollisionWithIcePenny, PickupVariant.PICKUP_COIN)