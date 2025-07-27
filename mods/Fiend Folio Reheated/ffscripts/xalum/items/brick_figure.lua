local mod = FiendFolio
local brickFigure = mod.ITEM.COLLECTIBLE.BRICK_FIGURE
local MORPH_CHANCE = 0.2

mod.AddItemPickupCallback(function(player, added)
	local room = Game():GetRoom()
	local position = room:FindFreePickupSpawnPosition(player.Position, 40, true)
	Isaac.Spawn(5, 300, mod.ITEM.CARD.BRICK_SEPERATOR, position, Vector.Zero, player)

	for i = 1, 4 do
		local position = room:FindFreePickupSpawnPosition(player.Position, 40, true)
		Isaac.Spawn(5, 300, mod.ITEM.CARD.STUD, position, Vector.Zero, player)
	end
end, nil, brickFigure)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if pickup.SubType == CoinSubType.COIN_PENNY then
		local data = pickup:GetData()
		data.wasAlreadyInRoom = data.wasAlreadyInRoom ~= nil and data.wasAlreadyInRoom or pickup.FrameCount == 0

		if pickup.FrameCount == 1 and not data.wasAlreadyInRoom then
			local someoneHasBrickFigure
			local rng
			mod.AnyPlayerDo(function(player)
				someoneHasBrickFigure = someoneHasBrickFigure or player:HasCollectible(brickFigure)
				rng = someoneHasBrickFigure and (rng or player:GetCollectibleRNG(brickFigure))
			end)

			if someoneHasBrickFigure and rng:RandomFloat() < MORPH_CHANCE then
				pickup:Morph(5, 300, mod.ITEM.CARD.STUD, true, true, true)
			end
		end
	end
end, PickupVariant.PICKUP_COIN)