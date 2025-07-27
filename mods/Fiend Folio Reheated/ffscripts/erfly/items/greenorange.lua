local mod = FiendFolio
local game = Game()

FiendFolio.AddItemPickupCallback(function(player, added)
    local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 1, true)
    local card = Isaac.Spawn(5, 10, 3, pos, Vector.Zero, nil)
end, nil, mod.ITEM.COLLECTIBLE.GREEN_ORANGE)
