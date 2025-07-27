local mod = FiendFolio
local game = Game()

local customPoolConstituents = {}
mod.CustomPool = {}

mod.CustomItemPoolType = {
	COLLECTIBLE = 0,
	TRINKET = 1,
	MIXED = 2,

	-- To-do:
	--[[
		COLLECTIBLE_WEIGHTED
		TRINKET_WEIGHTED
		MIXED_WEIGHTED
	]]
}

function mod.RegisterCustomItemPool(identifier, poolType, poolConstituents)
	local activeKey = "Active" .. identifier

	mod.CustomPool[identifier] = {activeKey, poolType}
	mod.ActiveItemPools = mod.ActiveItemPools or {}

	mod.ActiveItemPools[activeKey] = mod.ActiveItemPools[activeKey] or {}
	customPoolConstituents[activeKey] = poolConstituents
end

function mod.ResetEmptiedCustomItemPool(activePoolName, poolType, firstBuild)
	mod.ActiveItemPools[activePoolName] = {}

	if poolType == mod.CustomItemPoolType.MIXED then
		for _, part in pairs(customPoolConstituents[activePoolName].Collectibles) do
			for _, item in pairs(mod[part]) do
				if not mod.IsCollectibleLocked(item) then
					table.insert(mod.ActiveItemPools[activePoolName], {PickupVariant.PICKUP_COLLECTIBLE, item})
				end
			end
		end

		for _, part in pairs(customPoolConstituents[activePoolName].Trinkets) do
			for _, item in pairs(mod[part]) do
				if not mod.IsTrinketLocked(item) then
					table.insert(mod.ActiveItemPools[activePoolName], {PickupVariant.PICKUP_TRINKET, item})
				end
			end
		end
	else
		for _, part in pairs(customPoolConstituents[activePoolName]) do
			for _, item in pairs(mod[part]) do
				local pass = true
				if poolType == mod.CustomItemPoolType.COLLECTIBLE then
					if mod.IsCollectibleLocked(item) then
						pass = false
					end
				elseif poolType == mod.CustomItemPoolType.TRINKET then
					if mod.IsTrinketLocked(item) then
						pass = false
					end
				end

				if pass then
					table.insert(mod.ActiveItemPools[activePoolName], item)
				end
			end
		end
	end

	mod.savedata[activePoolName .. "Recycled"] = not firstBuild
end

function mod.BuildCustomItemPools()
	mod.ActiveItemPools = mod.ActiveItemPools or {}

	for _, data in pairs(mod.CustomPool) do
		local activePoolName = data[1]
		local poolType = data[2]

		mod.ResetEmptiedCustomItemPool(activePoolName, poolType, true)
		if #mod.ActiveItemPools[activePoolName] == 0 then
			mod.ResetEmptiedCustomItemPool(activePoolName, poolType, false)
		end
	end
end

function mod.RemoveItemFromCustomItemPools(item)
	for _, data in pairs(mod.CustomPool) do
		local poolName = data[1]
		local poolType = data[2]
		local pool = mod.ActiveItemPools[poolName]

		if poolType == mod.CustomItemPoolType.COLLECTIBLE then
			for i = #pool, 1, -1 do
				if pool[i] == item then
					table.remove(pool, i)
				end
			end
		elseif poolType == mod.CustomItemPoolType.MIXED then
			for i = #pool, 1, -1 do
				if pool[i][1] == PickupVariant.PICKUP_COLLECTIBLE and pool[i][2] == item then
					table.remove(pool, i)
				end
			end
		end

		if #pool == 0 then
			mod.ResetEmptiedCustomItemPool(poolName, poolType, false)
		end
	end
end

function mod.RemoveTrinketFromCustomItemPools(trinket)
	for _, data in pairs(mod.CustomPool) do
		local poolName = data[1]
		local poolType = data[2]
		local pool = mod.ActiveItemPools[poolName]

		if poolType == mod.CustomItemPoolType.TRINKET then
			for i = #pool, 1, -1 do
				if pool[i] == trinket then
					table.remove(pool, i)
				end
			end
		elseif poolType == mod.CustomItemPoolType.MIXED then
			for i = #pool, 1, -1 do
				if pool[i][1] == PickupVariant.PICKUP_TRINKET and pool[i][2] == trinket then
					table.remove(pool, i)
				end
			end
		end

		if #pool == 0 then
			mod.ResetEmptiedCustomItemPool(poolName, poolType, false)
		end
	end
end

local function isCollectibleValid(id, ignoreModifiers, someoneHasNo, poolRecycled)
	local itempool = game:GetItemPool()
	local itemConfig = Isaac.GetItemConfig()

	if ignoreModifiers or (not someoneHasNo or itemConfig:GetCollectible(id).Type ~= ItemType.ITEM_ACTIVE) then
		local itemIsAvailable = itemConfig:GetCollectible(id):IsAvailable()
		local itemWasInRealPools = itempool:RemoveCollectible(id)
		mod.RemoveItemFromCustomItemPools(id)

		if itemIsAvailable and (itemWasInRealPools or poolRecycled) then
			return true
		end
	end

	return false
end

local function isTrinketValid(id, poolRecycled)
	local itempool = game:GetItemPool()
	local itemConfig = Isaac.GetItemConfig()

	local trinketIsAvailable = itemConfig:GetTrinket(id):IsAvailable()
	local trinketWasInRealPools = itempool:RemoveTrinket(id)
	mod.RemoveTrinketFromCustomItemPools(id)

	if trinketIsAvailable and (trinketWasInRealPools or poolRecycled) then
		return true
	end

	return false
end

local function tryGildTrinket(id, rng)
	if FiendFolio.AchievementTrackers.GoldenTrinketsUnlocked and rng:RandomFloat() < 0.02 then
		return id | TrinketType.TRINKET_GOLDEN_FLAG
	end

	return id
end

function mod.GetItemFromCustomItemPool(poolData, rng, ignoreModifiers)
	local someoneHasNo = false
	local someoneHasChaos = false
	local poolName = poolData[1]
	local poolType = poolData[2]
	local pool = mod.ActiveItemPools[poolName]
	local returnValue = 0
	local itempool = game:GetItemPool()
	local itemConfig = Isaac.GetItemConfig()
	local poolRecycled = mod.savedata[poolName .. "Recycled"]

	if not rng then
		rng = RNG()
		rng:SetSeed(game:GetSeeds():GetStartSeed(), 35)
	end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(TrinketType.TRINKET_NO) then someoneHasNo = true end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then someoneHasChaos = true end
    end

	if someoneHasChaos and not ignoreModifiers then
		if poolType == mod.CustomItemPoolType.MIXED then
			return {PickupVariant.PICKUP_COLLECTIBLE, 0}
		else
			return 0
		end
	end

	if poolType == mod.CustomItemPoolType.COLLECTIBLE then
		for i = 1, 32 do
			local roll = rng:RandomInt(#pool) + 1
			local item = pool[roll]

			if isCollectibleValid(item, ignoreModifiers, someoneHasNo, poolRecycled) then
				returnValue = item
				mod:brokenRecordPostGetCollectible(item, poolName, true)
				break
			end
		end
	elseif poolType == mod.CustomItemPoolType.TRINKET then
		for i = 1, 32 do
			local roll = rng:RandomInt(#pool) + 1
			local trinket = pool[roll]

			if isTrinketValid(trinket, poolRecycled) then
				returnValue = tryGildTrinket(trinket, rng)
				break
			end
		end
	elseif poolType == mod.CustomItemPoolType.MIXED then
		for i = 1, 32 do
			local roll = rng:RandomInt(#pool) + 1
			local chosenData = pool[roll]
			returnValue = chosenData

			if chosenData[1] == PickupVariant.PICKUP_COLLECTIBLE then -- Collectible
				if isCollectibleValid(chosenData[2], ignoreModifiers, someoneHasNo, poolRecycled) then
					mod:brokenRecordPostGetCollectible(chosenData[2], poolName, true)
					break
				end
			elseif chosenData[1] == PickupVariant.PICKUP_TRINKET then -- Trinket
				if isTrinketValid(chosenData[2], poolRecycled) then
					returnValue = {chosenData[1], tryGildTrinket(chosenData[2], rng)}
					break
				end
			end
		end
	end

	return returnValue
end

function mod.ShowcaseAllCustomPoolItems(poolData)
	local i = 0
	local room = game:GetRoom()

	local poolName = poolData[1]
	local poolType = poolData[2]
	local pool = mod.ActiveItemPools[poolName]

	if poolType == mod.CustomItemPoolType.MIXED then
		for _, data in pairs(pool) do
			while room:GetGridCollision(i) ~= 0 do
				i = i + 1
			end

			Isaac.Spawn(5, data[1], data[2], room:GetGridPosition(i), Vector.Zero, nil)
			i = i + 1
		end
	else
		for _, item in pairs(pool) do
			while room:GetGridCollision(i) ~= 0 do
				i = i + 1
			end

			Isaac.Spawn(5, poolType == mod.CustomItemPoolType.COLLECTIBLE and PickupVariant.PICKUP_COLLECTIBLE or PickupVariant.PICKUP_TRINKET, item, room:GetGridPosition(i), Vector.Zero, nil)
			i = i + 1
		end
	end
end