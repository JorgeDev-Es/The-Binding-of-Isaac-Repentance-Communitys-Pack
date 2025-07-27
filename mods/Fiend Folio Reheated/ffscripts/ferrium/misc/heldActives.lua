local mod = FiendFolio

local heldItems = {
    [CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD] = true,
        --wait why am I doing this
		--[[mod.scheduleForUpdate(function()
			local anim = player:GetSprite():GetAnimation()
            print(anim)
			if string.find(anim, "Pickup") then
                print("pickup")
				data.overheadActiveItem = true
				data.overheadActiveItemID = CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD
            else
                print("reset")
                data.overheadActiveItem = nil
				data.overheadActiveItemID = nil
            end
		end, 2)]]
    [CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP] = true,
    [CollectibleType.COLLECTIBLE_NOTCHED_AXE] = true,
    [CollectibleType.COLLECTIBLE_CANDLE] = true,
    [CollectibleType.COLLECTIBLE_RED_CANDLE] = true,
    [CollectibleType.COLLECTIBLE_BOOMERANG] = true,
    [CollectibleType.COLLECTIBLE_GLASS_CANNON] = true,
    [CollectibleType.COLLECTIBLE_FRIEND_BALL] = true,
    [CollectibleType.COLLECTIBLE_BLACK_HOLE] = true,
    [CollectibleType.COLLECTIBLE_SHARP_KEY] = true,
    [CollectibleType.COLLECTIBLE_ERASER] = true,
    [CollectibleType.COLLECTIBLE_GELLO] = true,
    [CollectibleType.COLLECTIBLE_DECAP_ATTACK] = true,
    [mod.ITEM.COLLECTIBLE.D2] = true,
}

function mod:overheadHeldActive(item, rng, player)
	if heldItems[item] then
        local donot = false
        if item == CollectibleType.COLLECTIBLE_SHARP_KEY and player:GetNumKeys() == 0 then
            donot = true
        end
        local data = player:GetData()
        if donot then
            data.overheadActiveItem = nil
			data.overheadActiveItemID = nil
		elseif not data.overheadActiveItem or (data.overheadActiveItemID and item ~= data.overheadActiveItemID) then
            data.overheadActiveItem = true
			data.overheadActiveItemID = item
        else
            data.overheadActiveItem = nil
			data.overheadActiveItemID = nil
        end
	end
end

function mod:overheadHeldActiveUpdate(player, data)
    if data.overheadActiveItem then
        local frames = player.FrameCount-(data.LastFirePress or 0)
        if data.overheadActiveItemID ~= CollectibleType.COLLECTIBLE_NOTCHED_AXE then
            if frames == 1 then
                data.justThrewActive = data.overheadActiveItemID
                data.justThrewActiveFrames = player.FrameCount
                data.overheadActiveItem = nil
                data.overheadActiveItemID = nil
            end
        else
            local slot = 0
			for i=0,2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_NOTCHED_AXE then
					slot = i
					break
				end
			end
            if player:GetActiveCharge(slot) == 0 then
                data.overheadActiveItem = nil
                data.overheadActiveItemID = nil
            end
        end
    end
    if data.justThrewActiveFrames and player.FrameCount-data.justThrewActiveFrames > 3 then
        data.justThrewActive = nil
        data.justThrewActiveFrames = nil
    end
end