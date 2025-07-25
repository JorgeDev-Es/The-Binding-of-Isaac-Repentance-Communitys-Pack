local Mod = RepMMod

local vhsStrengh = 1
local function onShaderParams(_, shaderName)
	if shaderName == "RandomColors" then
		local Amount = 1

		for _ = 1, PlayerManager.GetNumCollectibles(Mod.RepmTypes.COLLECTIBLE_VHS), 1 do
			Amount = Amount * 0.7
		end

		vhsStrengh = Mod.Lerp(vhsStrengh, Amount, 0.01)

		return {
			Amount = vhsStrengh,
		}
	end
end
Mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, onShaderParams)

local function updateCache(_, player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_SPEED then
		if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_VHS) then
			player.MoveSpeed = player.MoveSpeed + 0.4
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, updateCache)

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() then
		if tear.SpawnerEntity:ToPlayer():HasCollectible(Mod.RepmTypes.COLLECTIBLE_VHS) then
			tear.CollisionDamage = tear.CollisionDamage + tear:GetDropRNG():RandomInt(4)
		end
	end
end)