local Mod = RepMMod

---@param item CollectibleType | integer
---@param rng RNG
---@param p EntityPlayer
---@param flags UseFlag | integer
---@param slot ActiveSlot | integer
---@param customVData integer
---@return table | boolean | nil?
local function RedButtonUse(_, item, rng, p, flags, slot, customVData)
	local roomEntities = Isaac.GetRoomEntities()
	for _, entity in ipairs(roomEntities) do
		if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
			for i = 1, rng:RandomInt(3, 5) do
				local flame = Isaac.Spawn(
					EntityType.ENTITY_EFFECT,
					EffectVariant.RED_CANDLE_FLAME,
					0,
					p.Position,
					RandomVector():Resized(10),
					p
				)
				flame.CollisionDamage = 5
			end
		end
	end
	return {
		Discharge = true,
		Remove = false,
		ShowAnim = true,
	}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, RedButtonUse, Mod.RepmTypes.COLLECTIBLE_ADVANCED_KAMIKAZE)