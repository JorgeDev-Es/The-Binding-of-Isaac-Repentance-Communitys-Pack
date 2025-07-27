local mod = FiendFolio

mod.spireGrowthSpecials = { --Face cards might not be used, remember that fool starts at 1.
	[Card.CARD_CLUBS_2] = 3,
	[Card.CARD_DIAMONDS_2] = 3,
	[Card.CARD_SPADES_2] = 3,
	[Card.CARD_HEARTS_2] = 3,
	[Card.CARD_ACE_OF_CLUBS] = 2,
	[Card.CARD_ACE_OF_DIAMONDS] = 2,
	[Card.CARD_ACE_OF_SPADES] = 2,
	[Card.CARD_ACE_OF_HEARTS] = 2,
	[Card.CARD_SUICIDE_KING] = 14,
	[Card.CARD_QUEEN_OF_HEARTS] = 13,
	[mod.ITEM.CARD.THREE_OF_CLUBS] = 4,
	[mod.ITEM.CARD.JACK_OF_CLUBS] = 12,
	[mod.ITEM.CARD.QUEEN_OF_CLUBS] = 13,
	[mod.ITEM.CARD.KING_OF_CLUBS] = 14,
	[mod.ITEM.CARD.THREE_OF_DIAMONDS] = 4,
	[mod.ITEM.CARD.JACK_OF_DIAMONDS] = 12,
	[mod.ITEM.CARD.QUEEN_OF_DIAMONDS] = 13,
	[mod.ITEM.CARD.KING_OF_DIAMONDS] = 14,
	[mod.ITEM.CARD.THREE_OF_SPADES] = 4,
	[mod.ITEM.CARD.JACK_OF_SPADES] = 12,
	[mod.ITEM.CARD.QUEEN_OF_SPADES] = 13,
	[mod.ITEM.CARD.KING_OF_SPADES] = 14,
	[mod.ITEM.CARD.THREE_OF_HEARTS] = 4,
	[mod.ITEM.CARD.JACK_OF_HEARTS] = 12,
	[mod.ITEM.CARD.MISPRINTED_JACK_OF_CLUBS] = 12,
	[mod.ITEM.CARD.MISPRINTED_TWO_OF_CLUBS] = 3,
	[mod.ITEM.CARD.THIRTEEN_OF_STARS] = 14,
	[mod.ITEM.CARD.ACE_OF_WANDS] = 2,
	[mod.ITEM.CARD.ACE_OF_PENTACLES] = 2,
	[mod.ITEM.CARD.ACE_OF_SWORDS] = 2,
	[mod.ITEM.CARD.ACE_OF_CUPS] = 2,
	[mod.ITEM.CARD.TWO_OF_WANDS] = 3,
	[mod.ITEM.CARD.TWO_OF_PENTACLES] = 3,
	[mod.ITEM.CARD.TWO_OF_SWORDS] = 3,
	[mod.ITEM.CARD.TWO_OF_CUPS] = 3,
	[mod.ITEM.CARD.THREE_OF_WANDS] = 4,
	[mod.ITEM.CARD.THREE_OF_PENTACLES] = 4,
	[mod.ITEM.CARD.THREE_OF_SWORDS] = 4,
	[mod.ITEM.CARD.THREE_OF_CUPS] = 4,
	[mod.ITEM.CARD.KING_OF_WANDS] = 14,
	[mod.ITEM.CARD.KING_OF_PENTACLES] = 14,
	[mod.ITEM.CARD.KING_OF_SWORDS] = 14,
	[mod.ITEM.CARD.KING_OF_CUPS] = 14,
	[mod.ITEM.CARD.REVERSE_KING_OF_CLUBS] = 14,
}

function mod:spireGrowthUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH) then
		local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH)-1
		if data.spireGrowth then
			if data.spireGrowth > 0 then
				data.spireGrowth = data.spireGrowth-0.002
			else
				data.spireGrowth = 0
			end
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
	
	if data.spireGrowth and not player:HasTrinket(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH) then
		data.spireGrowth = nil
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag) --what the fuck is this code I'm returning here it's like gibberish
	local data = player:GetData()
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH) then
		local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.SPIRE_GROWTH)-1
		data.spireGrowth = data.spireGrowth or 0
		local bonus = 0
		--print("1: " .. player:GetCard(0) .. ", 2: " .. player:GetCard(1) .. ", 3: " .. player:GetCard(2))
		if card > 55 and card < 78 then
			card = card-55
		end
		if mod.spireGrowthSpecials[card] ~= nil then
			card = mod.spireGrowthSpecials[card]
		end
		if card > 0 and card < 23 then
			if card > bonus then
				bonus = card
				local val = 0.2*card ^ (5*0.1752)*(1+mult)
				if data.spireGrowth < val then
					data.spireGrowth = val
				end
			end
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end)