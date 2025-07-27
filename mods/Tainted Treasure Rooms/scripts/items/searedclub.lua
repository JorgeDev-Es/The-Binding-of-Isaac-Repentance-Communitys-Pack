local mod = TaintedTreasure
local game = Game()

mod.SearedClubBlacklist = { --There are some automatic systems in place to prevent certain enemies from exploding, but some need to be handled manually
    [EntityType.ENTITY_MOM] = true,
	[EntityType.ENTITY_SATAN] = true,
}

mod.SearedClubGigaBlacklist = { --These entities will still explode but can't make a giga explosion
    [EntityType.ENTITY_ENVY] = true,
	[EntityType.ENTITY_BLASTOCYST_BIG] = true,
	[EntityType.ENTITY_BLASTOCYST_MEDIUM] = true,
	[EntityType.ENTITY_BLASTOCYST_SMALL] = true,
}

mod.VictoryPickupVariants = { --Softlock prevention
    PickupVariant.PICKUP_BIGCHEST,
	PickupVariant.PICKUP_TROPHY
}

function mod:SearedClubOnKill(npc)
	if not mod.SearedClubBlacklist[npc.Type] then
		local players = mod:GetPlayersHoldingCollectible(TaintedCollectibles.SEARED_CLUB)
		local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, 0, npc.Position, Vector.Zero, players[1]):ToBomb()
		local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, npc.Position, Vector.Zero, players[1]):ToEffect()
		local blastscale = ((npc.MaxHitPoints*120)/(npc.MaxHitPoints+10))+20
		explosion.SpriteScale = Vector(blastscale,blastscale)/100
		local color = bomb.Color
		bomb:SetColor(Color(color.R,color.G,color.B,0,color.RO,color.GO,color.BO),-1,1,true,false)
		bomb:SetExplosionCountdown(0)
		bomb.ExplosionDamage = blastscale
		bomb.RadiusMultiplier = blastscale/90
		for i, player in pairs(players) do
			bomb:AddTearFlags(player:GetBombFlags())
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
				bomb.ExplosionDamage = bomb.ExplosionDamage * 1.85
				bomb.RadiusMultiplier = bomb.RadiusMultiplier * 1.25
			end
		end
		if npc:IsBoss() and not mod.SearedClubGigaBlacklist[npc.Type] and not npc.ChildNPC and not npc.ParentNPC then
			bomb:AddTearFlags(TearFlags.TEAR_GIGA_BOMB)
			mod:scheduleForUpdate(function()
				for i, variant in pairs(mod.VictoryPickupVariants) do
					for j, entity in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, variant)) do
						if not mod:IsGridWalkable(entity.Position, false) then
							entity.TargetPosition = game:GetRoom():FindFreePickupSpawnPosition(entity.Position, 0, true)
						end
					end
				end
			end, 10)
		end
	end
end
