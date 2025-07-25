local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local DAMAGE = 2 -- Equals to +1 damage
local SIZE_BOOST = 0.25 -- Similar to Magic Mush
local SPEED_LIMIT = 0.5
local STOMPY_PROGRESS = 1
local dumbbellSpr = Sprite("gfx/dadsdumbbell.anm2")
dumbbellSpr:SetFrame("Idle", 0)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	if player:HasCollectible(mod.Collectible.DADS_DUMBBELL) then
		player.MoveSpeed = math.min(player.MoveSpeed, SPEED_LIMIT)
	end
end, CacheFlag.CACHE_SPEED)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	local effectNum = player:GetEffects():GetCollectibleEffectNum(mod.Collectible.DADS_DUMBBELL)
	local size = effectNum * SIZE_BOOST
	
	player.SpriteScale = player.SpriteScale + Vector(size, size)
end, CacheFlag.CACHE_SIZE)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, flag, slot, data)
	player:GetEffects():AddNullEffect(NullItemID.ID_LAZARUS_BOOST, false, DAMAGE) -- Would be handled by the item's effect itself otherwise
	player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_STOMPY, STOMPY_PROGRESS)
	player:AnimatePickup(dumbbellSpr)
end, mod.Collectible.DADS_DUMBBELL)