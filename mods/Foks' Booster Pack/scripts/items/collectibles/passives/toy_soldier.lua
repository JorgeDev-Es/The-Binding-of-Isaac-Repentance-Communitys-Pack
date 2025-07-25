local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local heartSpr = Sprite("gfx/ui/ui_heart_toysoldier.anm2", true) heartSpr:SetFrame("Idle", 1)
local priceSpr = Sprite("gfx/shop_toysoldier.anm2", true) priceSpr:SetFrame("Price", 1)

local function getInvincibilityDuration(player)
	return 60 * math.max(1, player:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE) * 2) -- A second (same as Holy Mantle)
end

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, collectible, charge, firstTime, slot, data, player)
	if firstTime then player:GetEffects():AddCollectibleEffect(collectible) end
end, mod.Collectible.TOY_SOLDIER)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, function(_, player)
	local playerFx = player:GetEffects()
	local itemNum = player:GetCollectibleNum(mod.Collectible.TOY_SOLDIER)
	local effectNum = playerFx:GetCollectibleEffectNum(mod.Collectible.TOY_SOLDIER)
	local targetNum = itemNum - effectNum
	
	if targetNum > 0 then
		playerFx:AddCollectibleEffect(mod.Collectible.TOY_SOLDIER, true, targetNum)
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown)
	local player = entity:ToPlayer()
	
	if player and player:GetEffects():HasCollectibleEffect(mod.Collectible.TOY_SOLDIER) then
		if flag & DamageFlag.DAMAGE_EXPLOSION > 0 then
			heartSpr:Play("Shake")
			sfx:Play(mod.Sound.METAL_DEFLECT)
			
			return false
		end
		if flag & (DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES) == 0 then
			local effect = Isaac.Spawn(
				EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, 
				player.Position, Vector.Zero, player):ToEffect()
			effect:FollowParent(player)
			effect.ParentOffset = Vector(0, -12)
			effect.DepthOffset = 16
			effect.Color = Color(1, 1, 1, 1, 0.15, 0.3, 0.15, 0.5, 1, 0.5, 0.5)
			
			for effectIdx = 1, mod.RandomIntRange(2, 4) do
				local effect = Isaac.Spawn(
					EntityType.ENTITY_EFFECT, EffectVariant.POOP_PARTICLE, 0, 
					player.Position, RandomVector() * mod.RandomFloatRange(1, 4), player):ToEffect()
				effect:GetSprite():Load("gfx/effect_toysoldiergibs.anm2")
				effect:GetSprite():PlayRandom(effect.InitSeed)
				effect.SpriteRotation = RandomVector():GetAngleDegrees()
				effect.FallingSpeed = -mod.RandomFloatRange(8, 12)
			end
			player:GetEffects():RemoveCollectibleEffect(mod.Collectible.TOY_SOLDIER)
			player:SetMinDamageCooldown(getInvincibilityDuration(player))
			sfx:Play(mod.Sound.METAL_HIT)
			
			return false
		end
	end
end, EntityType.ENTITY_PLAYER)

-----------------
-- << DEALS >> --
-----------------
mod:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, function(_, variant, subType, shopIdx, price)
	if mod.AnyoneHasCollectibleEffect(mod.Collectible.TOY_SOLDIER) then
		if mod.IsDealPrice(price) then return mod.Price.TOY_SOLDIER end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if pickup.Price == mod.Price.TOY_SOLDIER then
		local player = collider:ToPlayer()
		
		if player and not player:GetEffects():HasCollectibleEffect(mod.Collectible.TOY_SOLDIER) then
			return true
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, function(_, pickup, player, price)
	if price == mod.Price.TOY_SOLDIER then
		player:GetEffects():RemoveCollectibleEffect(mod.Collectible.TOY_SOLDIER)
	end
end)

---------------------
-- << RENDERERS >> --
---------------------
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, function(_, offset, sprite, pos, _, player)
	if game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN > 0 then return end
	
	if player:GetEffects():HasCollectibleEffect(mod.Collectible.TOY_SOLDIER) then
		if heartSpr:IsFinished("Shake") then heartSpr:Play("Idle") end
		if heartSpr:IsPlaying("Shake") then heartSpr:Update() end
		
		for effectIdx = 0, player:GetEffects():GetCollectibleEffectNum(mod.Collectible.TOY_SOLDIER) - 1 do
			if effectIdx >= 6 then break end
			local isTwin = player:GetOtherTwin() and player:GetOtherTwin():GetPlayerIndex() < player:GetPlayerIndex()
			
			if isTwin then heartSpr.FlipX = true end
			if player:HasInstantDeathCurse() then heartSpr.Color.A = 0.314 end -- 80 / 255 should be The Forgotten opacity
			
			heartSpr:Render(pos + Vector(0, offset.Y) + Vector(0, 5 * effectIdx))
			
			if isTwin then heartSpr.FlipX = false end
			if player:HasInstantDeathCurse() then heartSpr.Color.A = 1 end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup, offset)
	if pickup.Price == mod.Price.TOY_SOLDIER then
		priceSpr:Render(Isaac.GetRenderPosition(pickup.Position) + offset)
	end
end)