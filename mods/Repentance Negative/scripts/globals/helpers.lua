local Mod = RepMMod
local json = require("json")

function Mod.Filter(toFilter, predicate)
	local filtered = {}

	for index, value in pairs(toFilter) do
		if predicate(index, value) then
			filtered[#filtered + 1] = value
		end
	end

	return filtered
end

function Mod.Lerp(a, b, t)
	t = t or 0.2
	return a + (b - a) * t
end

function Mod.GetPlayers(...)
	local players = {}
	local playertypes = { ... }
	if #playertypes == 0 then
		return PlayerManager.GetPlayers()
	end
	for _, playertype in ipairs(playertypes) do
		for _, player in ipairs(PlayerManager.GetPlayers()) do
			if player:GetPlayerType() == playertype then
				table.insert(players, player)
			end
		end
	end
	return players
end

function Mod.GetPlayersWithout(...)
	local players = {}
	local playertypes = { ... }
	if #playertypes > 0 then
		for _, player in ipairs(PlayerManager.GetPlayers()) do
			local add = true
			for _, playertype in ipairs(playertypes) do
				if player:GetPlayerType() ~= playertype then
					add = false
					break
				end
			end
			if add then
				table.insert(players, player)
			end
		end
	end
	return players
end

function Mod.TearsUp(firedelay, val, limit) --Скорострельность вычисляется через эту формулу
	limit = type(limit) == "number" and math.max(-0.75, limit) or -0.75
	return Mod.TearsToFireDelay(math.max(limit, Mod.FireDelayToTears(firedelay) + val))
end

function Mod.FireDelayToTears(firedelay)
	return 30 / (firedelay + 1)
end

function Mod.TearsToFireDelay(tears)
	return (30 / tears) - 1
end

function Mod.GetTrueRange(player)
	return player.Range / 40.0
end

function Mod.RangeUp(range, val)
	local currentRange = range / 40.0
	local newRange = currentRange + val
	return math.max(1.0, newRange) * 40.0
end

function Mod.IsBaby(variant)
	return variant == FamiliarVariant.INCUBUS
		or variant == FamiliarVariant.TWISTED_BABY
		or variant == FamiliarVariant.BLOOD_BABY
		or variant == FamiliarVariant.CAINS_OTHER_EYE
		or variant == FamiliarVariant.UMBILICAL_BABY
		or variant == FamiliarVariant.SPRINKLER
end

function Mod:GetPlayerFromTear(tear)
	for i = 1, 2 do
		local check = nil
		if i == 1 then
			check = tear.Parent
		elseif i == 2 then
			check = tear.SpawnerEntity
		end
		if check then
			if check.Type == EntityType.ENTITY_PLAYER then
				return check:ToPlayer(), nil
			elseif check.Type == EntityType.ENTITY_FAMILIAR and Mod.IsBaby(check.Variant) then
				local data = tear:GetData()
				data.IsIncubusTear = true
				return check:ToFamiliar().Player:ToPlayer(), check:ToFamiliar()
			end
		end
	end
	return nil, nil
end

function Mod:getPlayerFromKnifeLaser(entity)
	if entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer() then
		return entity.SpawnerEntity:ToPlayer()
	elseif entity.SpawnerEntity and entity.SpawnerEntity:ToFamiliar() and entity.SpawnerEntity:ToFamiliar().Player then
		local familiar = entity.SpawnerEntity:ToFamiliar()

		if Mod.IsBaby(familiar.Variant) then
			return familiar.Player
		else
			return nil
		end
	else
		return nil
	end
end

function Mod.GetByQuality(min, max, pool, rnd, descrease)
	local Itempool = Game():GetItemPool()
	descrease = type(descrease) ~= "nil" and descrease or true
    while min >= 0 do
        local rng = type(rnd) == "number" and RNG(rnd) or rnd
        rng:Next()
        for i = 1, 100 do
            local new = Itempool:GetCollectible(pool, false, rng:GetSeed())
            local data = Isaac.GetItemConfig():GetCollectible(new)
            if data.Quality and data.Quality >= min and data.Quality <= max then
				if descrease then
					Itempool:RemoveCollectible(new)
				end
                return new
            end
            rng:Next()
        end
        min = min - 1
    end
end

local function doRunInitFirstCallback()
	local room = Game():GetRoom()
	local level = Game():GetLevel()
	local roomDesc = level:GetCurrentRoomDesc()

	local roomFrameCount = room:GetFrameCount()
	local visitedCount = roomDesc.VisitedCount

	return roomFrameCount > 0 or visitedCount == 0
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.LATE, function(_, pickup)
	if doRunInitFirstCallback() then
		Isaac.RunCallbackWithParam("REPM_PICKUP_INIT_FIRST", pickup.Variant, pickup)
	end
end)

Mod:AddPriorityCallback(ModCallbacks.MC_POST_SLOT_INIT, CallbackPriority.LATE, function(_, slot)
	if doRunInitFirstCallback() then
		Isaac.RunCallbackWithParam("REPM_SLOT_INIT_FIRST", slot.Variant, slot)
	end
end)