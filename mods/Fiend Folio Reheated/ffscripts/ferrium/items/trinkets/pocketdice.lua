local mod = FiendFolio
local game = Game()

mod.pocketDiceSelection = {
	--5
	FiendFolio.ITEM.CARD.GLASS_D6, FiendFolio.ITEM.CARD.GLASS_D6, FiendFolio.ITEM.CARD.GLASS_D6, FiendFolio.ITEM.CARD.GLASS_D6, FiendFolio.ITEM.CARD.GLASS_D6,
	--2
	FiendFolio.ITEM.CARD.GLASS_D4, FiendFolio.ITEM.CARD.GLASS_D4,
	--4
	FiendFolio.ITEM.CARD.GLASS_D8, FiendFolio.ITEM.CARD.GLASS_D8, FiendFolio.ITEM.CARD.GLASS_D8, FiendFolio.ITEM.CARD.GLASS_D8,
	--1
	FiendFolio.ITEM.CARD.GLASS_D100,
	--3
	FiendFolio.ITEM.CARD.GLASS_D10, FiendFolio.ITEM.CARD.GLASS_D10, FiendFolio.ITEM.CARD.GLASS_D10,
	--4
	FiendFolio.ITEM.CARD.GLASS_D20, FiendFolio.ITEM.CARD.GLASS_D20, FiendFolio.ITEM.CARD.GLASS_D20, FiendFolio.ITEM.CARD.GLASS_D20,
	--4
	FiendFolio.ITEM.CARD.GLASS_D12, FiendFolio.ITEM.CARD.GLASS_D12, FiendFolio.ITEM.CARD.GLASS_D12, FiendFolio.ITEM.CARD.GLASS_D12,
	--5
	FiendFolio.ITEM.CARD.GLASS_SPINDOWN, FiendFolio.ITEM.CARD.GLASS_SPINDOWN, FiendFolio.ITEM.CARD.GLASS_SPINDOWN, FiendFolio.ITEM.CARD.GLASS_SPINDOWN, FiendFolio.ITEM.CARD.GLASS_SPINDOWN,
	--4
	FiendFolio.ITEM.CARD.GLASS_D2, FiendFolio.ITEM.CARD.GLASS_D2, FiendFolio.ITEM.CARD.GLASS_D2, FiendFolio.ITEM.CARD.GLASS_D2,
	--4
	FiendFolio.ITEM.CARD.GLASS_AZURITE_SPINDOWN, FiendFolio.ITEM.CARD.GLASS_AZURITE_SPINDOWN, FiendFolio.ITEM.CARD.GLASS_AZURITE_SPINDOWN, FiendFolio.ITEM.CARD.GLASS_AZURITE_SPINDOWN,
}

function mod:pocketDiceNewLevel(player)
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.POCKET_DICE) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.TRINKET.POCKET_DICE)
		for i=1,3 do
			mod.scheduleForUpdate(function()
				local room = game:GetRoom()
				if i == 1 then
					Isaac.Spawn(5, 20, 1, room:FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, nil)
				else
					Isaac.Spawn(5, 300, mod.pocketDiceSelection[rng:RandomInt(#mod.pocketDiceSelection)+1], room:FindFreePickupSpawnPosition(player.Position, 20)+mod:shuntedPosition(10, rng), Vector.Zero, nil)
				end
			end, i)
		end
	end
end