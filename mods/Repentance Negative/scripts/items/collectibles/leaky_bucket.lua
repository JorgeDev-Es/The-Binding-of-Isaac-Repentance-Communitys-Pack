local Mod = RepMMod

--[[ Checks whether or not you have the item and deals w/ initialization
local function UpdateFaucet(player)
	HasLeakyFaucet = player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_LEAKY_BUCKET)
end

function Mod:onPlayerInit(player)
	UpdateFaucet(player)
end

--Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.onPlayerInit)
--Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,  Mod.onPlayerInit)
]]

-- Gives the Tears buff
local function cacheUpdate(_, player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_LEAKY_BUCKET) then
			if player.MaxFireDelay >= 7 then
				player.MaxFireDelay = Mod.TearsUp(player.MaxFireDelay, 2)
			elseif player.MaxFireDelay >= 5 then
				player.MaxFireDelay = 5
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheUpdate)

-- Randomly spawns Holy Water creep
local function onUpdate_LeakyFaucet(_, player)
	local pos = player.Position
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_LEAKY_BUCKET) and math.random(100) == 1 then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, pos, Vector(0, 0), player)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onUpdate_LeakyFaucet)