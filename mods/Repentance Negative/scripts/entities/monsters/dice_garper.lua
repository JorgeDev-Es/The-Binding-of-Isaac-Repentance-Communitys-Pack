local Mod = RepMMod

local DICE_GARPER = {
    Type = Isaac.GetEntityTypeByName("Dice Garper"),
    Variant = Isaac.GetEntityVariantByName("Dice Garper"),
    SubType = Isaac.GetEntitySubTypeByName("Dice Garper"),
}

local DiceGarper = {
	SPEED = 0.5,
	RANGE = 200,
}

local function onDiceGarper(_, entity)
    if not (entity.Variant == DICE_GARPER.Variant and entity.SubType == DICE_GARPER.SubType) then return end
	local sprite = entity:GetSprite()
	sprite:PlayOverlay("Head", false)
	entity:AnimWalkFrame("WalkHori", "WalkVert", 0.1)

	local target = entity:GetPlayerTarget()
	local data = entity:GetData()
	if data.GridCountdown == nil then
		data.GridCountdown = 0
	end

	if entity.State == 0 then
		if entity:IsFrame(8 / DiceGarper.SPEED, 0) then
			entity.Pathfinder:MoveRandomly(false)
		end
		if (entity.Position - target.Position):Length() < DiceGarper.RANGE then
			entity.State = 2
		end
	elseif entity.State == 2 then
		if entity:CollidesWithGrid() or data.GridCountdown > 0 then
			entity.Pathfinder:FindGridPath(target.Position, DiceGarper.SPEED, 1, false)
			if data.GridCountdown <= 0 then
				data.GridCountdown = 30
			else
				data.GridCountdown = data.GridCountdown - 1
			end
		else
			entity.Velocity = (target.Position - entity.Position):Normalized() * DiceGarper.SPEED * 6
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, onDiceGarper, DICE_GARPER.Type)

local BROKEN_DICE_GARPER = {
    Type = Isaac.GetEntityTypeByName("Broken Dice Garper"),
    Variant = Isaac.GetEntityVariantByName("Broken Dice Garper"),
    SubType = Isaac.GetEntitySubTypeByName("Broken Dice Garper"),
}

local BrokDiceGarper = {
	SPEED = 1.0,
	RANGE = 200,
}

local function onBrokDiceGarper(_, entity)
    if not (entity.Variant == BROKEN_DICE_GARPER.Variant and entity.SubType == BROKEN_DICE_GARPER.SubType) then return end
	local sprite = entity:GetSprite()
	sprite:PlayOverlay("Head", false)
	entity:AnimWalkFrame("WalkHori", "WalkVert", 0.1)

	local target = entity:GetPlayerTarget()
	local data = entity:GetData()
	if data.GridCountdown == nil then
		data.GridCountdown = 0
	end

	if entity.State == 0 then
		if entity:IsFrame(8 / BrokDiceGarper.SPEED, 0) then
			entity.Pathfinder:MoveRandomly(false)
		end
		if (entity.Position - target.Position):Length() < BrokDiceGarper.RANGE then
			entity.State = 2
		end
	elseif entity.State == 2 then
		if entity:CollidesWithGrid() or data.GridCountdown > 0 then
			entity.Pathfinder:FindGridPath(target.Position, BrokDiceGarper.SPEED, 1.4, false)
			if data.GridCountdown <= 0 then
				data.GridCountdown = 30
			else
				data.GridCountdown = data.GridCountdown - 1
			end
		else
			entity.Velocity = (target.Position - entity.Position):Normalized() * BrokDiceGarper.SPEED * 6
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, onBrokDiceGarper, BROKEN_DICE_GARPER.Type)

---@param npc EntityNPC
---@param tp EntityType
---@param variant integer
---@param subtype integer
---@param coloridx integer
---@return table | boolean
local function DiceGarperDeath(_, npc, tp, variant, subtype, coloridx)
	if npc.Type == DICE_GARPER.Type and npc.Variant == DICE_GARPER.Variant and
	npc.SubType == DICE_GARPER.SubType
	and tp == EntityType.ENTITY_GUSHER and npc:IsDead() then
		return {BROKEN_DICE_GARPER.Type, BROKEN_DICE_GARPER.Variant, BROKEN_DICE_GARPER.SubType, coloridx}
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_NPC_MORPH, DiceGarperDeath)

local function IsDoubleItemsGarperRoom()
	local roomData = Game():GetLevel():GetCurrentRoomDesc().Data
	local roomIds = {
		15023,
	}
	if roomData.Subtype == 20 and roomData.Type == RoomType.ROOM_DICE then
		for _, variant in ipairs(roomIds) do
			if variant == roomData.Variant then
				return true
			end
		end
	end
	return false
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if IsDoubleItemsGarperRoom() then
		for _, pickup in ipairs(Isaac.FindByType(5,100,-1)) do
			pickup = pickup:ToPickup()
			pickup.OptionsPickupIndex = 1
		end
	end
end)