local mod = FiendFolio
local game = Game()

FiendFolio.DadsBattery = {
	-- Do not allow the player to go into charge debt with these items, for one reason or another.
	BLACKLIST = {
		[CollectibleType.COLLECTIBLE_EVERYTHING_JAR] = true,
		[CollectibleType.COLLECTIBLE_ESAU_JR] = true,
		[mod.ITEM.COLLECTIBLE.KALUS_HEAD] = true,
		[mod.ITEM.COLLECTIBLE.ASTROPULVIS] = true,
	},
	-- Actives that should be removed on use.
	REMOVE_ON_USE = {
		[CollectibleType.COLLECTIBLE_EDENS_SOUL] = true,
	},
	-- Block these items from being used with Dad's Battery if their corresponding TemporaryEffect is present.
	BLOCK_IF_EFFECT_PRESENT = {
		[CollectibleType.COLLECTIBLE_PONY] = true,
		[CollectibleType.COLLECTIBLE_WHITE_PONY] = true,
	},
	-- Block these items from being used with Dad's Battery if the player is holding something over their head.
	BLOCK_IF_HOLDING_SOMETHING = {
		[mod.ITEM.COLLECTIBLE.CHERRY_BOMB] = true,
	},
	-- Block usage of the item if the corresponding function returns TRUE.
	BLOCK_IF_FUNCTION = {
		[CollectibleType.COLLECTIBLE_ANIMA_SOLA] = function(player)
			for _, chain in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ANIMA_CHAIN)) do
				if chain.SpawnerEntity and chain.SpawnerEntity.InitSeed == player.InitSeed then
					return true
				end
			end
		end,
		[CollectibleType.COLLECTIBLE_RED_KEY] = function(player)
			for _, outline in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DOOR_OUTLINE)) do
				if player.Position:Distance(outline.Position) <= 100 then
					return false
				end
			end
			return true
		end,
		[CollectibleType.COLLECTIBLE_MINE_CRAFTER] = function(player)
			for _, tnt in pairs(Isaac.FindByType(EntityType.ENTITY_MOVABLE_TNT, 1)) do
				if tnt.SpawnerEntity and tnt.SpawnerEntity.InitSeed == player.InitSeed and tnt:ToNPC().State < 16 then
					return true
				end
			end
		end,
		[CollectibleType.COLLECTIBLE_DECAP_ATTACK] = function(player)
			for _, head in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DECAP_ATTACK)) do
				if head.SpawnerEntity and head.SpawnerEntity.InitSeed == player.InitSeed then
					return true
				end
			end
		end,
		[mod.ITEM.COLLECTIBLE.MALICE] = function(player)
			return player:GetData().MaliceDashing or player:GetData().MaliceReforming
		end,
		[mod.ITEM.COLLECTIBLE.MALICE_REFORM] = function(player)
			return player:GetData().MaliceDashing or player:GetData().MaliceReforming
		end,
	},
}

local function ShouldRemoveItemOnUse(player, itemID)
	if mod.DadsBattery.REMOVE_ON_USE[itemID] then return true end
	
	local pType = player:GetPlayerType()
	return itemID == CollectibleType.COLLECTIBLE_MAGIC_SKIN
		and (pType == PlayerType.PLAYER_THELOST or pType == PlayerType.PLAYER_THELOST_B)
end

function mod:getDadsBatteryMaxDebt(chargeType)
	return (chargeType == ItemConfig.CHARGE_TIMED) and 500 or 12
end

local function GetDadsBatteryData(player, itemID, slot)
	if itemID == 0 then return end
	local data = player:GetData()
	if not data.ffDadsBattery then
		data.ffDadsBattery = {}
	end
	if not data.ffDadsBattery[itemID] then
		data.ffDadsBattery[itemID] = {}
	end
	if not data.ffDadsBattery[itemID][slot] then
		data.ffDadsBattery[itemID][slot] = {}
	end
	return data.ffDadsBattery[itemID][slot]
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, itemID, _, player, useFlags, slot)
	if (slot == ActiveSlot.SLOT_PRIMARY or slot == ActiveSlot.SLOT_POCKET) and useFlags & UseFlag.USE_OWNED ~= 0 and player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_BATTERY) then
		GetDadsBatteryData(player, itemID, slot).PRE = true
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, _, player, useFlags, slot)
	if (slot == ActiveSlot.SLOT_PRIMARY or slot == ActiveSlot.SLOT_POCKET) and useFlags & UseFlag.USE_OWNED ~= 0 and player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_BATTERY) then
		GetDadsBatteryData(player, itemID, slot).POST = true
	end
end)

--[[
-- This is how I thought I'd do pocket active detection for J&E, even though they aren't supposed to have them, just for posterity.
-- But it looks like in actuality, Q activates both of their pocket actives alongside Esau's normal active.
-- CTRL+SPACE / CTRL+Q doesn't work even though that's the card input. Funny.
local function IsUseItemTriggered(player, pocketActive)
	local pType = player:GetPlayerType()
	if (pType == PlayerType.PLAYER_JACOB or pType == PlayerType.PLAYER_ESAU) and pocketActive ~= Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
		return false
	end
	local useItemAction = ButtonAction.ACTION_ITEM
	if (pocketActive or pType == PlayerType.PLAYER_ESAU) and pType ~= PlayerType.PLAYER_JACOB then
		useItemAction = ButtonAction.ACTION_PILLCARD
	end
	return Input.IsActionTriggered(useItemAction, player.ControllerIndex)
end]]

-- Special case handling for if Dad's Battery shouldn't trigger at this specific moment for this specific item.
local function BlockDadsBatteryActivation(player, itemID)
	local pData = player:GetData()
	if itemID == player:GetItemState() or itemID == pData.ffDadsBatteryLastItemState then
		return true
	elseif mod.DadsBattery.BLOCK_IF_FUNCTION[itemID] then
		return mod.DadsBattery.BLOCK_IF_FUNCTION[itemID](player)
	elseif itemID == mod.ITEM.COLLECTIBLE.MALICE or itemID == mod.ITEM.COLLECTIBLE.MALICE_REFORM then
		return pData.MaliceDashing or pData.MaliceReforming
	elseif mod.DadsBattery.BLOCK_IF_EFFECT_PRESENT[itemID] then
		return player:GetEffects():HasCollectibleEffect(itemID)
	elseif mod.DadsBattery.BLOCK_IF_HOLDING_SOMETHING[itemID] then
		return player:IsHoldingItem()
	end
	return false
end

local function IsUseItemTriggered(player, pocketActive)
	local useItemAction = ButtonAction.ACTION_ITEM
	if pocketActive or player:GetPlayerType() == PlayerType.PLAYER_ESAU then
		useItemAction = ButtonAction.ACTION_PILLCARD
	end
	return Input.IsActionTriggered(useItemAction, player.ControllerIndex)
end

function mod:dadsBattery(player)
	if not player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_BATTERY) then return end
	
	local pData = player:GetData()
	if not pData.ffDadsBatteryPrevCharge then
		pData.ffDadsBatteryPrevCharge = {}
	end
	
	-- Allow the player to use their active item if all of the following are true within the current frame:
	--  > The player did the appropriate input to use the active item
	--  > Neither MC_PRE_USE_ITEM nor MC_USE_ITEM fired for the active item in the correct slot (with the USE_OWNED flag)
	--  > The active item does not have the "SPECIAL" charge type, and has non-zero MaxCharges
	--  > For pocket actives, the player (most likely) has the pocket active in the selected pocket slot (ie, its not a card or pill)
	--  > The player does not currently have enough active charge to use the item
	--  > The player does not currently have too much charge debt for the active slot
	--  > The active item is not blacklisted
	for _, slot in pairs({ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET}) do
		local isPocketActive = (slot == ActiveSlot.SLOT_POCKET)
		local currentCharge = player:GetActiveCharge(slot)
		
		if IsUseItemTriggered(player, isPocketActive) then
			local activeInfo = mod:GetActiveItemInfo(player, slot)
			
			if activeInfo and not mod.DadsBattery.BLACKLIST[activeInfo.ID]
					and activeInfo.MaxCharges > 0 and activeInfo.ChargeType ~= ItemConfig.CHARGE_SPECIAL
					and (not isPocketActive or pData.ffDadsBatteryPocketActiveSelected) then
				local itemID = activeInfo.ID
				local debtCap = mod:getDadsBatteryMaxDebt(activeInfo.ChargeType)
				local currentDebt = mod:getChargeDebt(player, slot)
				local dadsBatteryData = GetDadsBatteryData(player, itemID, slot)
				if not dadsBatteryData.PRE and not dadsBatteryData.POST
						and currentCharge >= (pData.ffDadsBatteryPrevCharge[slot] or 0)
						and currentDebt + activeInfo.MaxCharges <= debtCap
						and currentCharge < activeInfo.MaxCharges
						and not BlockDadsBatteryActivation(player, itemID) then
					player:UseActiveItem(itemID, UseFlag.USE_OWNED, slot)
					if ShouldRemoveItemOnUse(player, itemID) then
						player:RemoveCollectible(itemID, true, slot)
					end
					if pData.ffDadsBatteryWasHoldingFFItem ~= itemID then
						mod:setChargeDebt(player, slot, mod:getChargeDebt(player, slot) + activeInfo.MaxCharges)
					end
				end
			end
		end
		pData.ffDadsBatteryPrevCharge[slot] = currentCharge
	end
	
	pData.ffDadsBatteryPocketActiveSelected = player:GetActiveItem(ActiveSlot.SLOT_POCKET) > 0 and player:GetPill(0) == 0 and player:GetCard(0) == 0
	pData.ffDadsBatteryLastItemState = player:GetItemState()
	pData.ffDadsBatteryWasHoldingFFItem = pData.holdingFFItem
end

function mod:dadsBatteryPostUpdate()
	for i=0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(i)
		if player and player:Exists() then
			player:GetData().ffDadsBattery = {}
		end
	end
end

function mod:dadsBatteryDebuff(player, cacheFlag)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_BATTERY) then
		local penalty = 0
		for _, chargeType in pairs({ItemConfig.CHARGE_NORMAL, ItemConfig.CHARGE_TIMED}) do
			for slot=0, 2 do
				local chargeDebt = mod:getChargeDebt(player, slot, chargeType)
				if chargeDebt > 0 then
					local maxDebt = mod:getDadsBatteryMaxDebt(chargeType)
					penalty = math.max(penalty, chargeDebt / maxDebt)
				end
			end
		end
		if penalty > 0 then
			penalty = math.min(penalty, 1)
			
			if cacheFlag & CacheFlag.CACHE_SPEED ~= 0 then
				player.MoveSpeed = mod:Lerp(math.min(player.MoveSpeed, 2.0), 0.1, penalty)
			end
			if cacheFlag & CacheFlag.CACHE_SHOTSPEED ~= 0 then
				player.ShotSpeed = mod:Lerp(player.ShotSpeed, 0.6, penalty)
			end
			if cacheFlag & CacheFlag.CACHE_COLOR ~= 0 then
				local m = (1 - 0.75 * penalty)
				local c = player.Color
				c:SetTint(c.R * m, c.G * m, c.B * m, c.A)
				player.Color = c
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.dadsBatteryDebuff)
