local GuppysEyeRemovesBlindCurse = RegisterMod("Guppy's Eye Isn't Blind", 1)

local function tryRemoveCurseOfBlind()
	if LevelCurse.CURSE_OF_BLIND & Game():GetLevel():GetCurses() == LevelCurse.CURSE_OF_BLIND then -- if Curse of the Blind is found within the total curses, then
		Game():GetLevel():RemoveCurses(LevelCurse.CURSE_OF_BLIND)
	end
end

---@param collectibleID CollectibleType
local function anyPlayerHasCollectible(collectibleID)
	for i = 0, Game():GetNumPlayers() - 1 do
		if Game():GetPlayer(i):HasCollectible(collectibleID) then -- if any player has the collectible, then
			return true
		end
	end

	return false
end

---@param pickup EntityPickup
local function setFlagIfTreasureRoom(pickup)
	if Game():GetRoom():GetType() == RoomType.ROOM_TREASURE and (Game():GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE or Game():GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE_B) then
		pickup:GetData()["needsVisualization"] = true -- assign flag to draw over this pickup's sprite during ModCallbacks.MC_POST_PICKUP_RENDER
	end
end

---@param pickup EntityPickup
---@param collider Entity
function GuppysEyeRemovesBlindCurse:BeforePickupCollision(pickup, collider)
	if collider:ToPlayer() and pickup.Type == EntityType.ENTITY_PICKUP and pickup.SubType == CollectibleType.COLLECTIBLE_GUPPYS_EYE then -- if player collided with Guppy's Eye, then
		tryRemoveCurseOfBlind()

		local entitiesInRoom = Game():GetRoom():GetEntities()
		for i = 0, #entitiesInRoom do
			local entity = entitiesInRoom:Get(i)
			if entity ~= pickup and entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then -- if entity in room is not Guppy's Eye and it's an item, then try to reveal it
				setFlagIfTreasureRoom(entity:ToPickup())
			end
		end
	end
end

function GuppysEyeRemovesBlindCurse:OnNewFloor()
	if anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_EYE) then -- if any player has Guppy's Eye, then
		tryRemoveCurseOfBlind()
	end
end

---@param isContinued boolean
function GuppysEyeRemovesBlindCurse:OnGameStart(isContinued)
	if isContinued then -- if an existing run was continued, do the check for the curse
		GuppysEyeRemovesBlindCurse:OnNewFloor()
	end
end

---@param pickup EntityPickup
function GuppysEyeRemovesBlindCurse:OnPickupInitialized(pickup)
	if pickup.Type == EntityType.ENTITY_PICKUP then
		if anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_EYE) then -- if any player has Guppy's Eye, then
			setFlagIfTreasureRoom(pickup) -- assign flag to draw over all sprites in the room during ModCallbacks.MC_POST_PICKUP_RENDER
		end
	end
end

---@param entityPickup EntityPickup
function GuppysEyeRemovesBlindCurse:OnPickupRendered(entityPickup)
	if entityPickup:GetData()["needsVisualization"] then -- if flagged to overwrite the sprite (cannot tell difference between normal sprites and questionmark sprites)
		entityPickup:GetData()["needsVisualization"] = false

		local sprite = entityPickup:GetSprite()
		sprite:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(entityPickup.SubType).GfxFileName) -- replace sprite with item's real sprite (effectively gets rid of alt floor blind items)
		sprite:LoadGraphics()
	end
end

GuppysEyeRemovesBlindCurse:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, GuppysEyeRemovesBlindCurse.BeforePickupCollision, PickupVariant.PICKUP_COLLECTIBLE)
GuppysEyeRemovesBlindCurse:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, GuppysEyeRemovesBlindCurse.OnNewFloor)
GuppysEyeRemovesBlindCurse:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, GuppysEyeRemovesBlindCurse.OnGameStart)
GuppysEyeRemovesBlindCurse:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, GuppysEyeRemovesBlindCurse.OnPickupInitialized, PickupVariant.PICKUP_COLLECTIBLE)
GuppysEyeRemovesBlindCurse:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, GuppysEyeRemovesBlindCurse.OnPickupRendered, PickupVariant.PICKUP_COLLECTIBLE)