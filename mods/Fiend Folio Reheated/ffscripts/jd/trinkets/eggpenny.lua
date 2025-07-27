local mod = FiendFolio
local sfx = SFXManager()

function mod:pennyPickupEgg(player, pickup, value)
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.EGG_PENNY) and pickup.SubType ~= 6 then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.TRINKET.EGG_PENNY)
		local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.EGG_PENNY)
		local chance = (1 - (7.5/9)^(value))*100
		for i=1,mult do
			if rng:RandomInt(100) < chance then
				sfx:Play(SoundEffect.SOUND_BOIL_HATCH)
				player:BloodExplode()
				
				local bobby = Isaac.Spawn(3, mod.ITEM.FAMILIAR.FRAGILE_BOBBY, 0, player.Position, Vector.Zero, player)
				
				local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, player.Position, Vector.Zero, player):ToEffect()
				smoke:GetData().longonly = true
				smoke.Color = Color(1, 0.1, 0.1, 0.5, 0, 0, 0)
				smoke:FollowParent(bobby)
				smoke.SpriteOffset = Vector(0, -10)
				smoke.SpriteScale = smoke.SpriteScale*1.25
			end
		end
	end
end