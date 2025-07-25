local Mod = RepMMod
local pgd = Isaac.GetPersistentGameData()
local game = Mod.Game

local function IsKeeper(player)
	return player:GetHealthType() == HealthType.COIN
		or Epiphany and player:GetPlayerType() == Epiphany.PlayerType.KEEPER
end

local function IsLost(player)
	return player:GetHealthType() == HealthType.LOST or Epiphany and player:GetPlayerType() == Epiphany.PlayerType.LOST
end

local function OnEnhancedTwoHearts(_, card, player, useflags)
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) and IsLost(player) then
		player:AddBlueFlies(12, player.Position, nil)
		player:AnimateCard(card)
		return true
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedTwoHearts, Card.CARD_HEARTS_2)

local function OnEnhancedHierophant(_, card, player, useflags)
	local room = game:GetRoom()
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) then
		if IsKeeper(player) then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COIN,
				CoinSubType.COIN_NICKEL,
				room:FindFreePickupSpawnPosition(player.Position),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COIN,
				CoinSubType.COIN_NICKEL,
				room:FindFreePickupSpawnPosition(player.Position),
				Vector.Zero,
				nil
			)
			player:AnimateCard(card)
			return true
		end
		if IsLost(player) then
			if pgd:Unlocked(Achievement.HOLY_CARD) then
				Isaac.Spawn(
					EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_TAROTCARD,
					Card.CARD_HOLY,
					room:FindFreePickupSpawnPosition(player.Position),
					Vector.Zero,
					nil
				)
				Isaac.Spawn(
					EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_TAROTCARD,
					0,
					room:FindFreePickupSpawnPosition(player.Position),
					Vector.Zero,
					nil
				)
			else
				player:AddBlueFlies(10, player.Position, nil)
			end
			player:AnimateCard(card)
			return true
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedHierophant, Card.CARD_HIEROPHANT)

local function OnEnhancedLovers(_, card, player, useflags)
	local room = game:GetRoom()
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) then
		if IsKeeper(player) then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COIN,
				CoinSubType.COIN_PENNY,
				room:FindFreePickupSpawnPosition(player.Position),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COIN,
				CoinSubType.COIN_PENNY,
				room:FindFreePickupSpawnPosition(player.Position),
				Vector.Zero,
				nil
			)
			player:AnimateCard(card)
			return true
		end
		if IsLost(player) then
			if pgd:Unlocked(Achievement.HOLY_CARD) then
				Isaac.Spawn(
					EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_TAROTCARD,
					Card.CARD_HOLY,
					room:FindFreePickupSpawnPosition(player.Position),
					Vector.Zero,
					nil
				)
			else
				player:AddBlueFlies(5, player.Position, nil)
			end
			player:AnimateCard(card)
			return true
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedLovers, Card.CARD_LOVERS)

local function OnEnhancedTemperance(_, card, player, useflags)
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) and IsLost(player) then
		local room = game:GetRoom()
		SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND, 1, 0, false, 1)
		local slot = Isaac.Spawn(
			EntityType.ENTITY_SLOT,
			SlotVariant.FORTUNE_TELLING_MACHINE,
			0,
			room:FindFreePickupSpawnPosition(player.Position),
			Vector.Zero,
			nil
		)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, slot.Position, Vector(0, 0), nil)
		player:AnimateCard(card)
		return true
	end
end -- to do, add a poof and spawn sound
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedTemperance, Card.CARD_TEMPERANCE)

local function OnEnhancedDagaz(_, card, player, useflags)
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) and IsKeeper(player) then
		local room = game:GetRoom()
		Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_COIN,
			CoinSubType.COIN_NICKEL,
			room:FindFreePickupSpawnPosition(player.Position),
			Vector.Zero,
			nil
		)
	end
end -- to do, add a poof and spawn sound
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedDagaz, Card.RUNE_DAGAZ)

local function OnEnhancedHierophantB(_, card, player, useflags)
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) then
		if IsKeeper(player) then
			--player:AddBlueFlies(12, player.Position, nil)
			local room = game:GetRoom()
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COIN,
				CoinSubType.COIN_DIME,
				room:FindFreePickupSpawnPosition(player.Position),
				Vector.Zero,
				nil
			)
			player:AnimateCard(card)
			return true
		end
		if IsLost(player) then
			player:AddBlueFlies(8, player.Position, nil)
			player:AnimateCard(card)
			return true
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedHierophantB, Card.CARD_REVERSE_HIEROPHANT)

local function OnEnhancedQueenHearts(_, card, player, useflags)
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) and IsLost(player) then
		local amountTotal = Mod.RNG:RandomInt(2, 40)
		local amountSpiders = Mod.RNG:RandomInt(1, amountTotal)
		player:AddBlueFlies(amountTotal - amountSpiders, player.Position, nil)
		for i = 1, amountSpiders, 1 do
			player:AddBlueSpider(player.Position)
		end
		player:AnimateCard(card)
		return true
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedQueenHearts, Card.CARD_QUEEN_OF_HEARTS)

local function OnEnhancedEmpressB(_, card, player, useflags)
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) then
		if IsKeeper(player) then
			local room = game:GetRoom()
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COIN,
				CoinSubType.COIN_DIME,
				room:FindFreePickupSpawnPosition(player.Position),
				Vector.Zero,
				nil
			)
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COIN,
				CoinSubType.COIN_DIME,
				room:FindFreePickupSpawnPosition(player.Position),
				Vector.Zero,
				nil
			)
			player:AnimateCard(card)
			return true
		end
		if IsLost(player) then
			player:AddBlueFlies(8, player.Position, nil)
			player:AnimateCard(card)
			return true
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedEmpressB, Card.CARD_REVERSE_EMPRESS)

local function OnEnhancedJudgement(_, card, player, useflags)
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) and IsLost(player) then
		for i, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, SlotVariant.DEVIL_BEGGAR, -1)) do
			if entity.FrameCount <= 15 then
				local oldPos = entity.Position
				entity:Remove()
				Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.BEGGAR, 0, oldPos, Vector.Zero, nil)
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, OnEnhancedJudgement, Card.CARD_JUDGEMENT)

---@param player EntityPlayer
local function OnEnhancedStrengthB(_, card, player, useflags)
	if pgd:Unlocked(Mod.RepmAchivements.IMPROVED_CARDS.ID) and IsLost(player) then
		player:GetEffects():AddNullEffect(Mod.RepmTypes.NULL_IMPR_REV_STRENTH)
		player:AnimateCard(card)
		return true
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, OnEnhancedStrengthB, Card.CARD_REVERSE_STRENGTH)

---@param player EntityPlayer
local function ImprRevStrengthCache(_, player, cache)
	player.MoveSpeed = player.MoveSpeed
		+ player:GetEffects():GetNullEffectNum(Mod.RepmTypes.NULL_IMPR_REV_STRENTH) * 0.2
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ImprRevStrengthCache, CacheFlag.CACHE_SPEED)
