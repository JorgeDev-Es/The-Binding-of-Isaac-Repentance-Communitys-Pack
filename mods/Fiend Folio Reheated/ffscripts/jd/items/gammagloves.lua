local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player)
	game:ShakeScreen(5)
	SFXManager():Play(mod.Sounds.ForeseerClap, 0.3, 2, false, (math.random(140,160)/100))
	--[[mod.scheduleForUpdate(function()
		Isaac.Spawn(20, 0, 150, player.Position, Vector.Zero, nil)
		SFXManager():Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)
	end, 0)]]
	game:MakeShockwave(player.Position, 0.035, 0.025, 10)
	if player:GetPlayerType() == PlayerType.PLAYER_JUDAS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 10, player.Position, Vector.Zero, player):ToEffect()
		eff.MinRadius = 1
		eff.MaxRadius = 15
		eff.LifeSpan = 10
		eff.Timeout = 10
		eff.SpriteOffset = Vector(0, -15)
		eff.Color = Color(2,0.5,0.5,1,1,0,0)
		eff.Visible = false
		eff:FollowParent(player)
		eff:Update()
		eff.Visible = true
		
		for i, entity in pairs(Isaac.FindInRadius(player.Position, 150, EntityPartition.ENEMY)) do
			FiendFolio.scheduleForUpdate(function()
				if entity:IsEnemy() and entity:CollidesWithGrid() then
					entity:TakeDamage(player.Damage*0.2+2, 0, EntityRef(player), 2)
					
					if entity:HasMortalDamage() then
						entity:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
					end
				end
			end, 0)
		end
		
		game:UpdateStrangeAttractor(player.Position, -150, 9999999999)
	end
	
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
		game:UpdateStrangeAttractor(player.Position, -200, 9999999999)
	end
	game:UpdateStrangeAttractor(player.Position, -150, 9999999999)
	
end, mod.ITEM.COLLECTIBLE.GAMMA_GLOVES)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	if familiar.SubType == mod.ITEM.COLLECTIBLE.GAMMA_GLOVES then
		if familiar.FrameCount > 30 then
			familiar:Kill()
		end
	end
end, FamiliarVariant.WISP)