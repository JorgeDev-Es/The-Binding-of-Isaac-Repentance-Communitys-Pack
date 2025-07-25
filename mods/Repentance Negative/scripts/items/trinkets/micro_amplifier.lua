local Mod = RepMMod

local function TrinketNewRoom() --Эта функция вызывается после смены комнаты
	for _, player in ipairs(PlayerManager.GetPlayers()) do --Цикл, в котором проходимся по всем игрокам
		if player:HasTrinket(Mod.RepmTypes.TRINKET_MICRO_AMPLIFIER) then
			local data = player:GetData()
			--local TrinkRNG = player:GetTrinketRNG(1)
			local TrinkRNG = RNG() --RNG отвечает за неслучайную случайность
			TrinkRNG:SetSeed(Game():GetLevel():GetCurrentRoomDesc().SpawnSeed + player.InitSeed, 35) --Сид, который отвечает за рандом
			data.PeremenuyEto = 1 << TrinkRNG:RandomInt(6)
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TrinketNewRoom)

local statUp = 0.6
local function TrinketBonus(_, player, cache) --Эта функция вызывается при перевычисление статов
	local data = player:GetData()
	if data and data.PeremenuyEto and player:HasTrinket(Mod.RepmTypes.TRINKET_MICRO_AMPLIFIER) then
		if cache == data.PeremenuyEto or cache == CacheFlag.CACHE_LUCK then
			local multi = player:GetTrinketMultiplier(Mod.RepmTypes.TRINKET_MICRO_AMPLIFIER)
			if cache == CacheFlag.CACHE_SPEED then --SPEED
				player.MoveSpeed = player.MoveSpeed + statUp * multi
			elseif cache == CacheFlag.CACHE_DAMAGE then --DAMAGE
				player.Damage = player.Damage + statUp * multi
			elseif cache == CacheFlag.CACHE_FIREDELAY then --FIREDELAY
				player.MaxFireDelay = Mod.TearsUp(player.MaxFireDelay, statUp * multi)
			elseif cache == CacheFlag.CACHE_RANGE then --RANGE
				player.TearRange = player.TearRange + statUp * 40 * multi
			elseif cache == CacheFlag.CACHE_SHOTSPEED then --SHOTSPEED
				player.ShotSpeed = player.ShotSpeed + statUp * multi
			elseif cache == CacheFlag.CACHE_LUCK and data.PeremenuyEto == CacheFlag.CACHE_TEARFLAG then --LUCK
				player.Luck = player.Luck + statUp * multi
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, TrinketBonus)

local function CheckTrinketHold(_, player) --Эта функция вызывается каждый кадр для каждого игрока
	local data = player:GetData()
	if player:HasTrinket(Mod.RepmTypes.TRINKET_MICRO_AMPLIFIER) then
		if not data.PeremenuyEto then --Если есть брелок, но нет статов, то есть поднятие брелока
			local TrinkRNG = RNG()
			TrinkRNG:SetSeed(Game():GetLevel():GetCurrentRoomDesc().SpawnSeed + player.InitSeed, 35)
			data.PeremenuyEto = 1 << TrinkRNG:RandomInt(6)
			player:AddCacheFlags(data.PeremenuyEto, true)
		end
	elseif not player:HasTrinket(Mod.RepmTypes.TRINKET_MICRO_AMPLIFIER) and data.PeremenuyEto then --Если нету есть брелока, но есть статы, то есть потеря брелока
		player:AddCacheFlags(data.PeremenuyEto)
		data.PeremenuyEto = nil
		player:EvaluateItems()
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CheckTrinketHold)
