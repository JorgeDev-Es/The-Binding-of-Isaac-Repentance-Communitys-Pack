local mod = TaintedTreasure
local game = Game()

function mod:TrackPlayerUnlocking(player, data) --If key count drops, tag that player for 2 frames
	data.KeyCountTracker = data.KeyCountTracker or player:GetNumKeys()
	data.UnlockTimer = data.UnlockTimer or 0
	data.UnlockTimer = data.UnlockTimer - 1
	if data.KeyCountTracker > player:GetNumKeys() then
		data.UnlockTimer = 2
	end
	player:GetData().KeyCountTracker = player:GetNumKeys()
end

function mod:GetMostValidUnlocker(pos, dist) --Returns the closest player who is very likely to have recently used a key (update later to check for Sharp Key projectiles)
	local unlocker
	dist = dist or 10000
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i)
		if (player:GetData().UnlockTimer > 0 or player:HasGoldenKey()) and player.Position:Distance(pos) < dist then
			unlocker = player
			dist = player.Position:Distance(pos)
		end
	end
	return unlocker
end

function mod:CanPlayerUnlock(player, isChest)
	if isChest then
		return (player:GetNumKeys() > 0 or player:HasGoldenKey() or player:HasTrinket(TrinketType.TRINKET_PAPER_CLIP))
	else
		return (player:GetNumKeys() > 0 or player:HasGoldenKey())
	end
end

function mod:CheckChestForUnlock(pickup, collider) --Check chests
	local player = collider:ToPlayer()
	if player and mod:CanPlayerUnlock(player, true) then
        if pickup.Variant == PickupVariant.PICKUP_MEGACHEST then
            local sprite = pickup:GetSprite()
            if sprite:GetFrame() == 1 and (sprite:GetAnimation() == "UseKey" or sprite:GetAnimation() == "UseGoldenKey") then
                mod:RunCustomCallback("USE_KEY", {player})
            end
        elseif pickup.SubType == 1 and not mod:GetPlayersHoldingCollectible(CollectibleType.COLLECTIBLE_PAY_TO_PLAY) then
            mod:RunCustomCallback("USE_KEY", {player})
        end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.CheckChestForUnlock, PickupVariant.PICKUP_LOCKEDCHEST)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.CheckChestForUnlock, PickupVariant.PICKUP_ETERNALCHEST)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.CheckChestForUnlock, PickupVariant.PICKUP_OLDCHEST)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.CheckChestForUnlock, PickupVariant.PICKUP_MEGACHEST)

function mod:CheckDoorForUnlock(door) --Check doors
    local sprite = door:GetSprite()
    if sprite:GetFrame() == 0 or door.ExtraSprite:GetFrame() == 0 then --EXTRA SPRITE INSTEAD OF OVERLAY WHY?!?!?
        local anim = sprite:GetAnimation() 
        local anim2 = door.ExtraSprite:GetAnimation()
        if anim == "KeyOpen" --List of possible key opening anims
        or anim == "GoldenKeyOpen"
        or anim2 == "KeyOpenChain1"
        or anim2 == "KeyOpenChain2"
        or anim2 == "GoldenKeyOpenChain1"
        or anim2 == "GoldenKeyOpenChain2" 
        then
            local player = mod:GetMostValidUnlocker(door.Position, 100)
            if player then
                mod:RunCustomCallback("USE_KEY", {player})
            end
        end
    end
end

function mod:GetNumLocks(door) --Didn't wind up using this
	if door:IsRoomType(RoomType.ROOM_CHEST) or door:IsRoomType(RoomType.ROOM_DICE) then
		return 2
	elseif door:IsRoomType(RoomType.ROOM_TREASURE) or door:IsRoomType(RoomType.ROOM_SHOP) or door:IsRoomType(RoomType.ROOM_LIBRARY) or door:IsRoomType(RoomType.ROOM_PLANETARIUM) then
		return 1
	else
		return 0
	end
end

mod:AddCustomCallback("GRID_UPDATE", function(_, grid) --Check key blocks 
	local sprite = grid:GetSprite()
	if sprite:GetFrame() == 1 and (sprite:GetAnimation() == "Breaking" or sprite:GetAnimation() == "BreakingGolden") then
		local player = mod:GetMostValidUnlocker(grid.Position)
		if player then
			mod:RunCustomCallback("USE_KEY", {player})
		end
	end
end, GridEntityType.GRID_LOCK)