local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local function dropStoredCollectible(player, slot)
	local itemDesc = player:GetActiveItemDesc(math.max(slot, ActiveSlot.SLOT_PRIMARY))
	
	if itemDesc and itemDesc.VarData ~= CollectibleType.COLLECTIBLE_NULL then
		local pickupPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
		local pickup = Isaac.Spawn(
			EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemDesc.VarData, 
			pickupPos, Vector.Zero, player):ToPickup()
		pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
		pickup:RemoveCollectibleCycle()
		pickup.Charge = itemDesc.Charge
		
		itemDesc.VarData = CollectibleType.COLLECTIBLE_NULL
		itemDesc.Charge = 0
		
		sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, nil, nil, nil, mod.RandomFloatRange(1.4, 1.6))
		
		return true
	end
	return false
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, flag, slot, data)
	if player:GetItemState() == collectible or dropStoredCollectible(player, slot) then
		player:AnimateCollectible(collectible, "HideItem")
		player:ResetItemState()
	else
		player:AnimateCollectible(collectible, "LiftItem")
		player:SetItemState(collectible)
	end
end, mod.Collectible.BAALS_ALTAR)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if pickup.SubType == CollectibleType.COLLECTIBLE_NULL or pickup:IsShopItem() then return end
	local player = collider:ToPlayer()
	
	if player and player:GetItemState() == mod.Collectible.BAALS_ALTAR then
		local slot = player:GetActiveItemSlot(mod.Collectible.BAALS_ALTAR)
		local itemDesc = player:GetActiveItemDesc(math.max(slot, ActiveSlot.SLOT_PRIMARY))
		
		itemDesc.VarData = pickup.SubType
		itemDesc.Charge = math.max(pickup.Charge, 0) -- On cycling actives returns -1 which just prevents the item from being usable
		
		player:AnimateCollectible(mod.Collectible.BAALS_ALTAR, "HideItem")
		player:ResetItemState()
		
		pickup:TriggerTheresOptionsPickup()
		pickup:Remove()
		
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, pickup)
		sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, nil, nil, nil, mod.RandomFloatRange(0.6, 0.8))
		
		return true
	end
end, PickupVariant.PICKUP_COLLECTIBLE)

---------------------
-- << RENDERING >> --
---------------------
local shadowSpr = Sprite("gfx/ui/hud_baalsaltar.anm2", true) -- Cannot think of a better idea, maybe anm2 stuff
local itemSpr = Sprite("gfx/ui/hud_baalsaltar.anm2", true)

mod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, function(_, player, slot, offset, alpha, scale, chargeOffset)
	local itemDesc = player:GetActiveItemDesc(math.max(slot, ActiveSlot.SLOT_PRIMARY))
	
	if itemDesc and itemDesc.Item == mod.Collectible.BAALS_ALTAR and itemDesc.VarData ~= CollectibleType.COLLECTIBLE_NULL then
		shadowSpr:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(itemDesc.VarData).GfxFileName, true)
		shadowSpr.Scale = Vector(scale, scale)
		shadowSpr.Offset = Vector(2, 2) * scale
		shadowSpr:SetFrame("Idle", 1)
		shadowSpr.Color = Color(0, 0, 0, 0.3 * alpha) -- 0.3 seems close enough
		shadowSpr:Render(offset)
		
		itemSpr:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(itemDesc.VarData).GfxFileName, true)
		itemSpr.Scale = Vector(scale, scale)
		itemSpr:SetFrame("Idle", 1)
		itemSpr.Color.A = alpha
		itemSpr:Render(offset)
		
		return true
	end
end)