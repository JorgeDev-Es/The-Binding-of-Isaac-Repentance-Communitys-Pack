local mod = TaintedTreasure
local game = Game()

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider, low)
	local collectibleConfig = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
	local isActive = nil
	if collectibleConfig then
		isActive = collectibleConfig.Type == ItemType.ITEM_ACTIVE
	end

	if collider.Type == EntityType.ENTITY_PLAYER and
	   collider.Variant == 0
	then
		local player = collider:ToPlayer()
		local data = mod.GetPersistentPlayerData(player)
		if player:CanPickupItem() and
		   player:IsExtraAnimationFinished() and
		   player.ItemHoldCooldown <= 0 and
		   not player:IsCoopGhost() and
		   (collider.Parent == nil or (data and data.SpawnedAsKeeper and not isActive)) and --Strawman
		   player:GetPlayerType() ~= PlayerType.PLAYER_CAIN_B and
		   pickup.SubType ~= 0 and
		   pickup.Wait <= 0 and
		   not pickup.Touched and
		   (pickup.Price <= 0 or player:GetNumCoins() >= pickup.Price) and
		   mod.CallbackCollectibles[pickup.SubType]
		then
			if data ~= nil then
				data.TTcurrentQueuedItem = pickup.SubType
			end
		end
	end
end, PickupVariant.PICKUP_COLLECTIBLE)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    -- IsHoldingItem is true for the entire pickup animation
    -- IsHeldItemVisible is true only when item is lifted... but on the first frame it's false so the cache would be updated
    -- therefore, on the first frame of a pickup animation, set a flag indicating the animation has started and from then on when IsHeldItem item is false ignore it
    -- until the player is no longer holding an item, then reset it
    local basedata = player:GetData()
    local data = mod.GetPersistentPlayerData(player)
    local playerIsHoldingItem = player:IsHoldingItem()

	local queuedItem = player.QueuedItem
	if data.TTcurrentQueuedItem ~= nil and (queuedItem.Item == nil or queuedItem.Item.ID ~= data.TTcurrentQueuedItem) and data.StartedPickupAnimation then
		local item = data.TTcurrentQueuedItem
		data.TTcurrentQueuedItem = nil
        mod:RunCustomCallback("GAIN_COLLECTIBLE", {player, item})
	end
	if data.TTcurrentQueuedItem == nil and queuedItem.Item ~= nil and not queuedItem.Touched and queuedItem.Item:IsCollectible() and mod.CallbackCollectibles[queuedItem.Item.ID] then
		data.TTcurrentQueuedItem = queuedItem.Item.ID
	end
	
	if playerIsHoldingItem then
        if not player:IsHeldItemVisible() then
            if data.StartedPickupAnimation then
                playerIsHoldingItem = false
            else
                data.StartedPickupAnimation = true
            end
        end
    else
        data.StartedPickupAnimation = nil
    end
end)
