local mod = FiendFolio
local game = Game()
local jokes = include("ffscripts.xalum.pocketitems.extras.kill_me")

local function showJoke(rng)
	local joke = jokes[rng:RandomInt(#jokes) + 1]
	local hud = game:GetHUD()
	hud:ShowFortuneText(table.unpack(joke))
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player)
	game:BombExplosionEffects(player.Position, 20, TearFlags.TEAR_NORMAL, Color.Default, player, 0.5)

	local rng = player:GetCardRNG(mod.ITEM.CARD.CHRISTMAS_CRACKER)
	local new = mod.GetRandomObject(rng)
	Isaac.Spawn(5, 300, new, player.Position, RandomVector() * 2, player)

	showJoke(rng)
end, mod.ITEM.CARD.CHRISTMAS_CRACKER)