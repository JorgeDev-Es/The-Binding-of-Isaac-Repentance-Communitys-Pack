local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local BURN_DURATION = 120 -- 4 seconds
local FART_DAMAGE = 8
local FART_RADIUS = 85
local KNOCKBACK_RADIUS = 120

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, flag, slot, data)
	game:ButterBeanFart(player.Position, KNOCKBACK_RADIUS, player, false, false)
	mod.Fart(player.Position, FART_RADIUS, player, 1, 1, nil, function(entity)
		entity:TakeDamage(FART_DAMAGE, 0, EntityRef(player), 30)
		entity:AddBurn(EntityRef(player), BURN_DURATION, 0)
	end)
end, mod.Collectible.SPICY_BEAN)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity)
	local fam = entity:ToFamiliar()
	
	if fam and fam.Variant == FamiliarVariant.WISP and fam.SubType == mod.Collectible.SPICY_BEAN then
		local player = fam.Player
		
		game:ButterBeanFart(fam.Position, KNOCKBACK_RADIUS, player, false, false)
		mod.Fart(fam.Position, FART_RADIUS, fam, 1, 1, nil, function(entity2)
			entity2:TakeDamage(FART_DAMAGE, 0, EntityRef(player), 30)
			entity2:AddBurn(EntityRef(player), BURN_DURATION, 0)
		end)
	end
end, EntityType.ENTITY_FAMILIAR)