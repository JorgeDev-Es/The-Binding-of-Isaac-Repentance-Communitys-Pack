local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local FIREPLACE_CHANCE = 0.05

local function getMaxLuckAmount(player)
	local itemNum = player:GetCollectibleNum(mod.Collectible.EPHEMERAL_TORCH)
	
	return 10 + (itemNum - 1) * 5
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	if player:HasCollectible(mod.Collectible.EPHEMERAL_TORCH) then
		local effectNum = player:GetEffects():GetCollectibleEffectNum(mod.Collectible.EPHEMERAL_TORCH)
		
		player.Luck = player.Luck + (getMaxLuckAmount(player) - effectNum)
	end
end, CacheFlag.CACHE_LUCK)

mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, function(_, player)
	if player:HasCollectible(mod.Collectible.EPHEMERAL_TORCH) then
		local playerFx = player:GetEffects()
		
		if playerFx:GetCollectibleEffectNum(mod.Collectible.EPHEMERAL_TORCH) < getMaxLuckAmount(player) then
			playerFx:AddCollectibleEffect(mod.Collectible.EPHEMERAL_TORCH)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function(_, player, collider)
	if player:HasCollectible(mod.Collectible.EPHEMERAL_TORCH) then
		if collider.Type == EntityType.ENTITY_FIREPLACE then
			collider:TakeDamage(1, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0) -- Explosion flag instantly kills the fire
			player:GetEffects():RemoveCollectibleEffect(mod.Collectible.EPHEMERAL_TORCH, -1)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function(_, player, collectible)
	player:GetEffects():RemoveCollectibleEffect(collectible, -1)
end, mod.Collectible.EPHEMERAL_TORCH)

----------------
-- << GRID >> --
----------------
mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function(_, entityType, entityVariant, entitySubType, gridIndex, seed)
	if PlayerManager.AnyoneHasCollectible(mod.Collectible.EPHEMERAL_TORCH) then
		if entityType == StbGridType.ROCK and RNG(seed):RandomFloat() <= FIREPLACE_CHANCE then
			return {EntityType.ENTITY_FIREPLACE}
		end
	end
end)

--------------------
-- << LIGHTING >> --
--------------------
mod:AddCallback(ModCallbacks.MC_PRE_RENDER_ENTITY_LIGHTING, function(_, entity, offset)
	local player = entity and entity:ToPlayer()
	if not player then return end
	local playerData = mod.GetEntityData(player)
	
	if player:HasCollectible(mod.Collectible.EPHEMERAL_TORCH) then
		local effectNum = player:GetEffects():GetCollectibleEffectNum(mod.Collectible.EPHEMERAL_TORCH)
		local scaleMult = (getMaxLuckAmount(player) - effectNum) / getMaxLuckAmount(player)
		local scaleFactor = mod.Lerp(1, 2, scaleMult)
		
		if not playerData.LightEffect or not playerData.LightEffect:Exists() then
			playerData.LightEffect = EntityEffect.CreateLight(player.Position, scaleFactor, nil, nil, Color(1, 0.75, 0.5))
			playerData.LightEffect:GetSprite():SetFrame(1)
			playerData.LightEffect:FollowParent(player)
			playerData.LightEffect.Scale = 3 -- Makes the light flicker
		end
		playerData.LightEffect.SpriteScale = mod.Lerp(playerData.LightEffect.SpriteScale, Vector.One * scaleFactor, 0.05)
		
		return false
	elseif playerData.LightEffect then
		if playerData.LightEffect:Exists() then
			playerData.LightEffect:Remove()
		end
		playerData.LightEffect = nil
	end
end, EntityType.ENTITY_PLAYER)