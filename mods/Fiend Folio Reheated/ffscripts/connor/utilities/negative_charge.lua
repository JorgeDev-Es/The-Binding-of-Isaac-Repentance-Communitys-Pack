local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local VARIABLE_MAX_CHARGE = {
	[CollectibleType.COLLECTIBLE_BLANK_CARD]=true,
	[CollectibleType.COLLECTIBLE_CLEAR_RUNE]=true,
	[CollectibleType.COLLECTIBLE_D_INFINITY]=true,
}

function mod:GetActiveItemInfo(player, slot)
	local itemID = player:GetActiveItem(slot)
	if itemID > 0 then
		local itemConfigEntry = Isaac.GetItemConfig():GetCollectible(itemID)
		if itemConfigEntry then
			local maxCharges = itemConfigEntry.MaxCharges
			if VARIABLE_MAX_CHARGE[itemID] then
				-- Do some dumb stuff to detect the current MaxCharges of variable-charge actives.
				-- Shoooould be safe.
				local currentCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
				player:SetActiveCharge(9999, slot)
				maxCharges = player:GetActiveCharge(slot)
				player:SetActiveCharge(currentCharge, slot)
			end
			return {
				ID = itemID,
				ChargeType = itemConfigEntry.ChargeType,
				MaxCharges = maxCharges,
			}
		end
	end
end

------------------------------------------------------------
-- General handling of charge debt

local function GetAllChargeDebtData(player)
	local data = player:GetData().ffsavedata
	if not data.chargeDebtData then
		data.chargeDebtData = {}
	end
	return data.chargeDebtData
end

local function GetChargeDebtData(player, slot, chargeType)
	local data = GetAllChargeDebtData(player)
	local key = "" .. slot
	local subKey
	if chargeType ~= nil then
		subKey = ""..chargeType
	else
		local activeInfo = mod:GetActiveItemInfo(player, slot)
		if activeInfo and activeInfo.ChargeType == ItemConfig.CHARGE_TIMED then
			subKey = ""..ItemConfig.CHARGE_TIMED
		else
			subKey = ""..ItemConfig.CHARGE_NORMAL
		end
	end
	if not data[key] then
		data[key] = {}
	end
	if not data[key][subKey] then
		data[key][subKey] = {
			Debt = 0,
			PrevDebt = 0,
			LastChanged = 0,
		}
	end
	return data[key][subKey]
end

function mod:getChargeDebt(player, slot, chargeType)
	return GetChargeDebtData(player, slot, chargeType).Debt
end

function mod:setChargeDebt(player, slot, amount, chargeType)
	GetChargeDebtData(player, slot, chargeType).Debt = math.max(math.abs(amount), 0)
end

function mod:handleChargeDebt(player)
	for slot=0,2 do
		local activeInfo = mod:GetActiveItemInfo(player, slot)
		local currentChargeType = activeInfo and activeInfo.ChargeType or nil
		
		if activeInfo and currentChargeType ~= ItemConfig.CHARGE_SPECIAL then
			local data = GetChargeDebtData(player, slot)
			local debt = math.max(0, data.Debt)
			
			if debt > 0 then
				-- Drain charge from the player's active item to pay off debt.
				local charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
				if charge > 0 then
					local n = math.min(charge, debt)
					if n > 0 then
						charge = charge - n
						debt = debt - n
						player:SetActiveCharge(charge, slot)
						if sfx:IsPlaying(SoundEffect.SOUND_BATTERYCHARGE) then
							sfx:Stop(SoundEffect.SOUND_BATTERYCHARGE)
							sfx:Play(SoundEffect.SOUND_BEEP)
						end
					end
				end
				
				-- Drain Bethany's Soul Charge to pay off debt.
				local soulCharge = player:GetSoulCharge()
				if soulCharge > 0 then
					local n = math.min(soulCharge, debt)
					if n > 0 then
						soulCharge = soulCharge - n
						debt = debt - n
						player:SetSoulCharge(soulCharge)
					end
				end
				
				-- Drain Tainted Bethany's Blood Charge to pay off debt.
				local bloodCharge = player:GetBloodCharge()
				if bloodCharge > 0 then
					local n = math.min(bloodCharge, debt)
					if n > 0 then
						bloodCharge = bloodCharge - n
						debt = debt - n
						player:SetBloodCharge(bloodCharge)
					end
				end
			end
			
			data.Debt = debt
		end
		
		for _, chargeType in pairs({ItemConfig.CHARGE_NORMAL, ItemConfig.CHARGE_TIMED}) do
			local data = GetChargeDebtData(player, slot, chargeType)
			
			if chargeType == ItemConfig.CHARGE_TIMED and data.Debt > 0 and currentChargeType ~= ItemConfig.CHARGE_TIMED then
				-- Don't keep timed debt without a timed item.
				data.Debt = 0
			end
			
			local debt = math.max(0, data.Debt)
			
			if activeInfo and debt <= activeInfo.MaxCharges and activeInfo.ChargeType == chargeType and not player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_BATTERY) then
				data.MaxVisibleDebt = activeInfo.MaxCharges
			elseif player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_BATTERY) or not data.MaxVisibleDebt then
				data.MaxVisibleDebt = mod:getDadsBatteryMaxDebt(chargeType)
			end
			
			-- Track when the player's debt changes.
			if data.PrevDebt ~= debt then
				data.LastChanged = game:GetFrameCount()
				data.PrevDebt = debt
				if player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_BATTERY) then
					player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_COLOR)
					player:EvaluateItems()
				end
			end
		end
	end
end

function mod:chargeDebtPostUpdate()
	for i=0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(i)
		if player and player:Exists() then
			mod:handleChargeDebt(player)
		end
	end
end

------------------------------------------------------------
-- Detect when the player picks up batteries etc

-- Need to make it so the player still gets the full value from batteries if they have debt,
-- so they dont just pay off one pip of debt for a battery usually worth 6 pips when their active is 1 charge.

local function GetTotalCharge(player)
	local charge = 0
	for slot=0,2 do
		charge = charge + player:GetActiveCharge(slot) + player:GetBatteryCharge(slot) - mod:getChargeDebt(player, slot)
	end
	return charge
end

local BATTERY_CHARGES = {
	[BatterySubType.BATTERY_NORMAL] = 6,
	[BatterySubType.BATTERY_MICRO] = 2,
	[BatterySubType.BATTERY_MEGA] = 12,
	[BatterySubType.BATTERY_GOLDEN] = 6,
}
local function GetPickupCharge(pickup)
	if pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
		return BATTERY_CHARGES[pickup.SubType]
	elseif pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType == KeySubType.KEY_CHARGED then
		return 6
	end
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.LATE, function(_, player, collider)
	if collider.Type == EntityType.ENTITY_PICKUP and GetPickupCharge(collider) then
		local needsChargeInSlot = nil
		for slot=0, 2 do
			if player:NeedsCharge(slot) then
				needsChargeInSlot = slot
				break
			end
		end
		if collider.Variant == PickupVariant.PICKUP_LIL_BATTERY and not needsChargeInSlot then
			for slot=0,2 do
				if mod:getChargeDebt(player, slot, ItemConfig.CHARGE_NORMAL) > 0 then
					collider:GetSprite():Play("Collect", true)
					mod:addActiveCharge(player, GetPickupCharge(collider))
					collider:Die()
					return
				end
			end
		end
		for slot=0, 2 do
			if mod:getChargeDebt(player, slot) > 0 then
				collider:GetData().ffNegativeChargePlayerCol = {
					Player = EntityPtr(player),
					PrevCharge = GetTotalCharge(player),
					CollisionFrame = game:GetFrameCount(),
					ExpectedSlot = needsChargeInSlot or slot,
				}
				break
			end
		end
	end
end)

function mod:NegativeChargePostPickupUpdate(pickup)
	local expectedCharge = GetPickupCharge(pickup)
	local data = pickup:GetData().ffNegativeChargePlayerCol
	
	if expectedCharge and data and game:GetFrameCount() - data.CollisionFrame <= 1 and pickup:GetSprite():IsPlaying("Collect") and pickup:GetSprite():GetFrame() == 1 then
		local player = data.Player
		if player and player.Ref and player.Ref:Exists() then
			player = data.Player.Ref:ToPlayer()
		end
		if player and player:NeedsCharge(data.ExpectedSlot) then
			local prevCharge = data.PrevCharge
			local currentCharge = GetTotalCharge(player)
			local diff = currentCharge - prevCharge
			
			if diff > 0 and diff < expectedCharge then
				mod:addActiveCharge(player, expectedCharge - diff)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.NegativeChargePostPickupUpdate, PickupVariant.PICKUP_LIL_BATTERY)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.NegativeChargePostPickupUpdate, PickupVariant.PICKUP_KEY)

------------------------------------------------------------
-- Clear all debt if the player uses 48 hour energy

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, _, player)
	for _, chargeType in pairs({ItemConfig.CHARGE_NORMAL, ItemConfig.CHARGE_TIMED}) do
		for slot=0, 2 do
			GetChargeDebtData(player, slot, chargeType).Debt = 0
		end
	end
end, PillEffect.PILLEFFECT_48HOUR_ENERGY)

------------------------------------------------------------
-- Detect when the player swaps primary/secondary actives

function mod:handleChargeDebtSwap(player)
	if Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) > 0 and player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) > 0 then
			-- Swap debt data between the primary and secondary slots.
			local data = GetAllChargeDebtData(player)
			local firstData = data[""..ActiveSlot.SLOT_PRIMARY]
			local secondData = data[""..ActiveSlot.SLOT_SECONDARY]
			data[""..ActiveSlot.SLOT_PRIMARY] = secondData
			data[""..ActiveSlot.SLOT_SECONDARY] = firstData
		end
	end
end

------------------------------------------------------------
-- Remove a pip of debt on room clear if the player isn't still holding an appropriate active item.

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	for i=0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(i)
		if player and player:Exists() then
			for slot=0,2 do
				local debtData = GetChargeDebtData(player, slot, ItemConfig.CHARGE_NORMAL)
				
				local activeInfo = mod:GetActiveItemInfo(player, slot)
				
				if debtData.Debt > 0 and (not activeInfo or activeInfo.ChargeType ~= ItemConfig.CHARGE_NORMAL) then
					debtData.Debt = debtData.Debt - 1
					if not sfx:IsPlaying(SoundEffect.SOUND_BEEP) then
						sfx:Play(SoundEffect.SOUND_BEEP)
					end
				end
			end
		end
	end
end)

------------------------------------------------------------
-- HUD Rendering

local barSprite = Sprite()
barSprite:Load("gfx/ui/ui_chargebar.anm2", false)
barSprite:LoadGraphics()

local redBarColor = Color(1,1,1,1)
redBarColor:SetColorize(1,0,0,1)

local redBarFlashColor = Color(0.3,0.3,0.3,1)
redBarFlashColor:SetColorize(1,0,0,1)

local NULL_COLOR = Color(1,1,1,1)

local DEBT_OVERLAY = { 1,2,3,4,5,6,8,8,12,12,12,12 }

-- Returns the maximum pips that should currently be displayed on the bar for charge debt.
function mod:getMaxVisibleChargeDebt(player, slot, chargeType)
	return GetChargeDebtData(player, slot, chargeType).MaxVisibleDebt or mod:getDadsBatteryMaxDebt(chargeType)
end

-- If we should render the player's debt on top of the existing charge bar.
-- Requires debt and either holding a normally-charged active item, or no active, or an active with no charge bar.
local function shouldDisplayChargeDebt(player, slot)
	local activeInfo = mod:GetActiveItemInfo(player, slot)
	if activeInfo == nil and mod:getChargeDebt(player, slot, ItemConfig.CHARGE_NORMAL) > 0 then
		return true
	end
	return activeInfo ~= nil and activeInfo.ChargeType ~= ItemConfig.CHARGE_SPECIAL and mod:getChargeDebt(player, slot) > 0 and not mod.SPELL[activeInfo.ID]
end

-- If the player has debt, and is holding an active with a charge bar, but its not charged normally, render it in the back instead.
local function shouldDisplayBackupChargeDebt(player, slot)
	if not shouldDisplayChargeDebt(player, slot) then
		local activeInfo = mod:GetActiveItemInfo(player, slot)
		if activeInfo ~= nil and ((activeInfo.ChargeType ~= ItemConfig.CHARGE_NORMAL and activeInfo.MaxCharges > 0) or mod.SPELL[activeInfo.ID]) then
			local data = GetChargeDebtData(player, slot, ItemConfig.CHARGE_NORMAL)
			return data.Debt > 0 or game:GetFrameCount() - data.LastChanged < 20
		end
	end
end

local function updateNegativeChargeBarUnderlay(player, slot, data, chargeType)
	data.Sprite:SetFrame("BarEmpty", 0)
	
	local maxVisibleDebt = mod:getMaxVisibleChargeDebt(player, slot, chargeType)
	if maxVisibleDebt and maxVisibleDebt > 0 and maxVisibleDebt <= 12 then
		data.Sprite:PlayOverlay("BarOverlay" .. maxVisibleDebt, true)
	else
		data.Sprite:RemoveOverlay()
	end
end

local function updateNegativeChargeBar(player, slot, data, chargeType)
	data.Sprite:SetFrame("BarFull", 0)
	
	local debtData = GetChargeDebtData(player, slot, chargeType)
	
	if not game:IsPaused() and game:GetFrameCount() - debtData.LastChanged < 10 and math.ceil(Isaac.GetFrameCount() * 0.5) % 4 == 0 then
		data.Color = redBarFlashColor
	else
		data.Color = redBarColor
	end
	
	data.TopLeftClamp = Vector(0,3)
	
	local debt = debtData.Debt
	local maxVisibleDebt = mod:getMaxVisibleChargeDebt(player, slot, chargeType)
	local overlay = "BarOverlay" .. maxVisibleDebt
	
	if maxVisibleDebt and maxVisibleDebt > 0 then
		local percent = debt / maxVisibleDebt
		-- 6 ~ 29
		local x = (29-6) * percent
		data.BottomRightClamp = Vector(0, math.max(29 - x, 0))
	else
		data.BottomRightClamp = Vector.Zero
	end
	
	if maxVisibleDebt and maxVisibleDebt > 0 and maxVisibleDebt <= 12 then
		data.Sprite:PlayOverlay(overlay, true)
	else
		data.Sprite:RemoveOverlay()
	end
end

-- Lower layer renders an empty charge bar.
mod:addActiveRender({
	Sprite = barSprite,
	IsChargeBar = true,
	Condition = shouldDisplayChargeDebt,
	Update = function(player, slot, data)
		updateNegativeChargeBarUnderlay(player, slot, data)
	end,
})

-- Upper layer renders the bar partially filled with red, from the top, to represent charge debt.
mod:addActiveRender({
	Sprite = barSprite,
	IsChargeBar = true,
	Condition = shouldDisplayChargeDebt,
	Update = function(player, slot, data)
		updateNegativeChargeBar(player, slot, data)
	end,
})

-- If the player has debt accumulated but is currently holding an active item that doesn't use normal charges, display the debt behind the main charge bar.
mod:addActiveRender({
	Sprite = barSprite,
	RenderAbove = false,
	IsChargeBar = true,
	Condition = shouldDisplayBackupChargeDebt,
	Offset = Vector(-3,0),
	Update = function(player, slot, data)
		updateNegativeChargeBarUnderlay(player, slot, data, ItemConfig.CHARGE_NORMAL)
		data.BottomRightClamp = Vector(6,0)
		
		local debtData = GetChargeDebtData(player, slot, ItemConfig.CHARGE_NORMAL)
		if not game:IsPaused() and debtData.Debt == 0 and game:GetFrameCount() - debtData.LastChanged < 20 then
			data.Color = Color(1,1,1, 1 - ((game:GetFrameCount() - debtData.LastChanged) / 20))
		else
			data.Color = NULL_COLOR
		end
	end,
})
mod:addActiveRender({
	Sprite = barSprite,
	RenderAbove = false,
	IsChargeBar = true,
	Condition = shouldDisplayBackupChargeDebt,
	Offset = Vector(-3,0),
	Update = function(player, slot, data)
		updateNegativeChargeBar(player, slot, data, ItemConfig.CHARGE_NORMAL)
		data.BottomRightClamp = (data.BottomRightClamp or Vector.Zero) + Vector(6,0)
	end,
})
