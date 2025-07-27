local mod = FiendFolio

function mod:pennyPickupSharp(player, pickup, value)
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.SHARP_PENNY) then
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.TRINKET.SHARP_PENNY)
		local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.SHARP_PENNY)
		local chance = (1 - (7.5/9)^(value))*100
		for i=1,mult do
			if rng:RandomInt(100) < chance then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM, -1)
				player:BloodExplode()
				local rangle = math.random(360)
				for i=-6,6,2 do
					Isaac.Spawn(1000, 5, 0, player.Position, Vector(i+math.random(-1,1),0):Rotated(rangle), player)
				end
				for i=1,3 do
					Isaac.Spawn(1000, 5, 0, player.Position, RandomVector()*math.random(1,3), player)
				end
				local poof = Isaac.Spawn(1000, 2, 160, player.Position, Vector.Zero, player):ToEffect()
				poof:FollowParent(player)
				SFXManager():Play(SoundEffect.SOUND_KNIFE_PULL, 0.6, 0, false, math.random(100,120)/100)
				break
			end
		end
	end
end