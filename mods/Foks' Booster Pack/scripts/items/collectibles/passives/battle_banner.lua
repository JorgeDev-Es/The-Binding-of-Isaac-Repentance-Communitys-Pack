local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local DAMAGE_MULT = 1.8
local BACKTRACK_NUM = 3 -- Amount of rooms Isaac can backtrack into

mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function(_, player, collectible)
	player:GetEffects():RemoveCollectibleEffect(collectible, -1) -- Removes all instances of the effect when the item is removed
end, mod.Collectible.BATTLE_BANNER)

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, collectible, charge, firstTime, slot, data, player)
	local playerFx = player:GetEffects()
	
	playerFx:AddCollectibleEffect(collectible)
	playerFx:GetCollectibleEffect(collectible).Count = BACKTRACK_NUM + player:GetCollectibleNum(collectible)
	
	mod.RevealLastBossRoom(game:GetLevel())
end, mod.Collectible.BATTLE_BANNER)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, function(_, player)
	if player:HasCollectible(mod.Collectible.BATTLE_BANNER) then
		local playerFx = player:GetEffects()
		
		playerFx:AddCollectibleEffect(mod.Collectible.BATTLE_BANNER)
		playerFx:GetCollectibleEffect(mod.Collectible.BATTLE_BANNER).Count = BACKTRACK_NUM + player:GetCollectibleNum(mod.Collectible.BATTLE_BANNER)
		
		mod.RevealLastBossRoom(game:GetLevel())
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, function(_, player)
	local playerFx = player:GetEffects()
	
	if playerFx:HasCollectibleEffect(mod.Collectible.BATTLE_BANNER) and not game:GetRoom():IsFirstVisit() then
		playerFx:RemoveCollectibleEffect(mod.Collectible.BATTLE_BANNER)
		
		if playerFx:GetCollectibleEffectNum(mod.Collectible.BATTLE_BANNER) <= 0 then
			player:AnimateSad()
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	if player:GetEffects():HasCollectibleEffect(mod.Collectible.BATTLE_BANNER) then
		player.Damage = player.Damage * DAMAGE_MULT
	end
end, CacheFlag.CACHE_DAMAGE)

---------------------
-- << RENDERING >> --
---------------------
local indicatorSpr = Sprite("gfx/ui/indicator_battlebanner.anm2")

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player, offset)
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	local playerFx = player:GetEffects()
	
	if playerFx:HasCollectibleEffect(mod.Collectible.BATTLE_BANNER) then
		local posOffset = player:GetFlyingOffset() - Vector(0, 34) * player.SpriteScale
		local xOffset, yOffset = 0, math.sin(player.FrameCount * 0.1) * 2
		
		indicatorSpr.Scale = player.SpriteScale
		indicatorSpr:SetFrame("Idle", playerFx:GetCollectibleEffectNum(mod.Collectible.BATTLE_BANNER) - 1)
		indicatorSpr:Render(Isaac.GetRenderPosition(player.Position + player.PositionOffset) + posOffset + offset + Vector(xOffset, yOffset))
	end
end)