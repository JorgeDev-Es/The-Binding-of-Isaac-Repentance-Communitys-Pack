local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:BasicRoll(scalar, cap, cappercent, customRNG)
	cappercent = cappercent or 1
	cap = cap + 1
	scalar = math.max(0, scalar)
	local rand = customRNG or rng

	local chance = math.min(cappercent, (cappercent / cap) * (cap + ((scalar + 1) - cap)))
	return (rng:RandomFloat() <=  chance)
end

mod:AddCustomCallback("FIRE_TEAR", function(_, tear, player, ignorePlayerEffects, isLudo)
	local data = tear:GetData()
	data.TaintedPlayerRef = player

	if player:HasCollectible(TaintedCollectibles.BUZZING_MAGNETS) then
		mod:BuzzingMagnetsOnFireTear(player, tear)
	end
	
	if player:HasCollectible(TaintedCollectibles.CONSECRATION) then
		mod:ConsecrationOnFireTear(player, tear)
	end

	if player:HasCollectible(TaintedCollectibles.SALT_OF_MAGNESIUM) then
		mod:SaltOfMagnesiumOnFireTear(player, tear)
	end
	
	if player:HasCollectible(TaintedCollectibles.ARROWHEAD) then
		mod:ArrowheadOnFireTear(player, tear)
	end
	
	if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
		mod:PolycoriaOnFireTear(player, tear)
	end
	
	if player:HasCollectible(TaintedCollectibles.COLORED_CONTACTS) then
		mod:ColoredContactsOnFireTear(tear, data)
	end

	if player:HasCollectible(TaintedCollectibles.DRYADS_BLESSING) then
		mod:DryadsBlessingOnFireTear(player, tear)
	end
	
	if player:HasCollectible(TaintedCollectibles.RAW_SOYLENT) then
		mod:RawSoylentOnFireTear(player, tear)
	end

	if player:HasCollectible(TaintedCollectibles.BUGULON_SUPER_FAN) then
		mod:BugulonFanOnFireTear(player, tear)
	end 

	if player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
		mod:LilSluggerOnFireTear(player, tear)
	end

	if player:HasCollectible(TaintedCollectibles.EVANGELISM) then
		mod:EvangelismOnFireTear(player, tear)
	end
end)

--Bombs (Dr Fetus checked with IsFetus tag)
mod:AddCustomCallback("FIRE_BOMB", function(_, bomb, player)
	local bdata = bomb:GetData()
	local bsprite = bomb:GetSprite()
	bdata.TaintedPlayerRef = player

	--Glad Bombs
	if player:HasCollectible(TaintedCollectibles.GLAD_BOMBS) then
		if bomb.IsFetus then
			if mod:BasicRoll(player.Luck, 20, 1, player:GetCollectibleRNG(TaintedCollectibles.GLAD_BOMBS)) then
				bdata.TaintedIsGladBomb = true
			end
		else
			bdata.TaintedIsGladBomb = true
		end
	end

	if bomb.IsFetus then --Dr. Fetus bombs only
	
		--Buzzing Magents 
		if player:HasCollectible(TaintedCollectibles.BUZZING_MAGNETS) then
			if mod:BasicRoll(player.Luck, 6, 1, player:GetCollectibleRNG(TaintedCollectibles.BUZZING_MAGNETS)) then
				bdata.TaintedRepulsion = true
				bomb.Color = mod.ColorBuzzingMagnet
			end
		end

		--Consecration 
		if player:HasCollectible(TaintedCollectibles.CONSECRATION) then
			if mod:BasicRoll(player.Luck, 9, 0.5, player:GetCollectibleRNG(TaintedCollectibles.CONSECRATION)) then
				bdata.TaintedFireWave = true
				bomb.Color = mod.ColorConsecration
			end
		end

		--Salt of Magnesium
		if player:HasCollectible(TaintedCollectibles.SALT_OF_MAGNESIUM) then
			if mod:BasicRoll(player.Luck, 9, 0.5, player:GetCollectibleRNG(TaintedCollectibles.SALT_OF_MAGNESIUM)) then
				bdata.TaintedPoopBlast = true
				bomb.Color = mod.ColorSaltOfMagnesium
			end
		end

		--Arrowhead
		if player:HasCollectible(TaintedCollectibles.ARROWHEAD) then
			mod:ArrowheadOnFireBomb(bomb, bdata)
		end

		--Colored Contacts
		if player:HasCollectible(TaintedCollectibles.COLORED_CONTACTS) then
			mod:ColoredContactOnFireBomb(bomb, bdata)
		end

		--Dryad's Blessing 
		if player:HasCollectible(TaintedCollectibles.DRYADS_BLESSING) then
			if mod:BasicRoll(player.Luck, 9, 1, player:GetCollectibleRNG(TaintedCollectibles.DRYADS_BLESSING)) then
				bdata.TaintedGermination = true
				bomb.Color = mod.ColorGerminated
			end
		end

		--Raw Soylent
		if player:HasCollectible(TaintedCollectibles.RAW_SOYLENT) and not bdata.TaintedRawSoylent then
			mod:RawSoylentOnFireBomb(player, bomb)
		end

		--Lil Slugger
		if player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
			mod:FireSawblade(player, bomb.Velocity)
		end

		--Evangelism
		if player:HasCollectible(TaintedCollectibles.EVANGELISM) then
			mod:EvangelismOnFireBomb(player, bomb)
		end
		
		--Polycoria
		if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
			mod:FireCluster(player, bomb.Velocity/4, nil, 1.5, 1, player.Position, bomb)
			bdata.DisableTearCollison = true
		end
	end
end)

--Epic Fetus
mod:AddCustomCallback("FIRE_ROCKET", function(_, rocket, player)
	local rdata = rocket:GetData()
	rdata.TaintedPlayerRef = player

	--Buzzing Magents 
	if player:HasCollectible(TaintedCollectibles.BUZZING_MAGNETS) then
		if mod:BasicRoll(player.Luck, 6, 1, player:GetCollectibleRNG(TaintedCollectibles.BUZZING_MAGNETS)) then
			rdata.TaintedRepulsion = true
		end
	end

	--Consecration 
	if player:HasCollectible(TaintedCollectibles.CONSECRATION) then
		if mod:BasicRoll(player.Luck, 9, 0.5, player:GetCollectibleRNG(TaintedCollectibles.CONSECRATION)) then
			rdata.TaintedFireWave = true
		end
	end

	--Salt of Magnesium
	if player:HasCollectible(TaintedCollectibles.SALT_OF_MAGNESIUM) then
		if mod:BasicRoll(player.Luck, 9, 0.5, player:GetCollectibleRNG(TaintedCollectibles.SALT_OF_MAGNESIUM)) then
			rdata.TaintedPoopBlast = true
		end
	end 

	--Dryad's Blessing 
	if player:HasCollectible(TaintedCollectibles.DRYADS_BLESSING) then
		if mod:BasicRoll(player.Luck, 9, 1, player:GetCollectibleRNG(TaintedCollectibles.DRYADS_BLESSING)) then
			rdata.TaintedGermination = true
		end
	end
end)

--Aquarius
mod:AddCustomCallback("FIRE_CREEP", function(_, creep, player)
	local cdata = creep:GetData()

	--Buzzing Magents 
	if player:HasCollectible(TaintedCollectibles.BUZZING_MAGNETS) then
		if mod:BasicRoll(player.Luck, 6, 1, player:GetCollectibleRNG(TaintedCollectibles.BUZZING_MAGNETS)) then
			cdata.TaintedRepulsion = true
			cdata.ForceColor = mod.ColorBuzzingMagnetCreep
		end
	end

	--Consecration 
	if player:HasCollectible(TaintedCollectibles.CONSECRATION) then
		if mod:BasicRoll(player.Luck, 9, 0.5, player:GetCollectibleRNG(TaintedCollectibles.CONSECRATION)) then
			cdata.TaintedFireWave = true
			cdata.TaintedFireWaveCooldown = 0
			cdata.ForceColor = mod.ColorConsecration
		end
	end

	--Dryad's Blessing 
	if player:HasCollectible(TaintedCollectibles.DRYADS_BLESSING) then
		if mod:BasicRoll(player.Luck, 9, 1, player:GetCollectibleRNG(TaintedCollectibles.DRYADS_BLESSING)) then
			cdata.TaintedGermination = true
			cdata.ForceColor = mod.ColorGerminatedCreep
		end
	end
end)

mod.BrimLasers = {
	[1] = true,
	[6] = true,
	[9] = true,
	[11] = true,
	[14] = true,
	[15] = true,
}

mod:AddCustomCallback("FIRE_LASER", function(_, laser, player)
	local data = laser:GetData()
	if laser.SubType == 0 then
		if laser.Variant == 2 then 
			if laser.OneHit then --Technology
				if player:HasCollectible(TaintedCollectibles.RAW_SOYLENT) and not data.TaintedRawSoylent then
					mod:RawSoylentOnFireTechLaser(player, laser)
				end
				if player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
					mod:FireSawblade(player, Vector(10,0):Rotated(laser.AngleDegrees), mod.ColorElectricRed)
				end
				if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
					mod:FireCluster(player, Vector(10,0):Rotated(laser.AngleDegrees), mod.ColorElectricRed, 1, 1, laser.Position)
				end
			else --Tech 2.0

			end
		elseif mod.BrimLasers[laser.Variant] then --Brimstone
			if player:HasCollectible(TaintedCollectibles.RAW_SOYLENT) and not data.TaintedRawSoylent then
				mod:RawSoylentOnFireBrimLaser(player, laser)
			end
			if player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
				mod:FireSawblade(player, Vector(10,0):Rotated(laser.AngleDegrees), mod.ColorElectricRed, 1.5)
			end
			if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
				mod:FireCluster(player, Vector(10,0):Rotated(laser.AngleDegrees), mod.ColorElectricRed, 1.5)
			end
		end
	elseif laser.SubType == 2 then --Tech X
		if player:HasCollectible(TaintedCollectibles.RAW_SOYLENT) and not data.TaintedRawSoylent then
			mod:RawSoylentOnFireTechX(player, laser)
		end
		if player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
			mod:FireSawblade(player, laser.Velocity, mod.ColorElectricRed, 1.5 * (laser.Radius / 60))
		end
		if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
			mod:FireCluster(player, laser.Velocity, mod.ColorElectricRed, 1.5 * (laser.Radius / 60), 1.5, laser.Position, laser)
		end
	end
end)

mod:AddCustomCallback("FIRE_KNIFE", function(_, knife, player, isclub)
	local data = knife:GetData()
	local isclub = mod:IsBoneClub(knife)
	if knife.Variant ~= 4 and knife.Variant ~= 9 and knife.Variant ~= 10 then --Bag of Crafting, Notched Axe, Spirit Sword
		if player:HasCollectible(TaintedCollectibles.RAW_SOYLENT) and not data.TaintedRawSoylent then
			if not isclub then
				mod:RawSoylentOnFireKnife(player, knife)
			else
				mod:RawSoylentOnFireClub(player, knife)
			end
		end
		if player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
			if not isclub then
				mod:FireSawblade(player, Vector(10,0):Rotated(knife.Rotation), nil, 1.5 * knife.Charge)
			else
				mod:FireSawblade(player, player:GetLastDirection(), Color.Default, 1, knife.Position, knife)
			end
		end
		if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
			if not isclub then
				mod:FireCluster(player, Vector(10,0):Rotated(knife.Rotation)/10, nil, 1.5 * knife.Charge, 2.2 * knife.Charge, player.Position, knife)
			else
				mod:FireCluster(player, player:GetLastDirection():Resized(player.ShotSpeed*10))
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider)
	local data = tear:GetData()
	if collider.Type == EntityType.ENTITY_BOMB then
		if data.TaintedIsGladBombTear then
			return true
		end
	
		if collider:GetData().DisableTearCollison then
			return true
		end
	end
	
	if data.TaintedClusterParent and collider:IsEnemy() then
		for i, newtear in pairs(data.TaintedCorpseClusters) do
			newtear:GetData().TaintedParentCollidedEnemy = true
		end
	end
end)

local tearpoofs = {EffectVariant.TEAR_POOF_A, EffectVariant.TEAR_POOF_B, EffectVariant.TEAR_POOF_SMALL, EffectVariant.TEAR_POOF_VERYSMALL}

--Tear death
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, tear)
	local data = tear:GetData()
	if data.TaintedFireWave then
		mod:DoConsecrationWave(mod:GetPlayerFromTear(tear), tear.Position)
	end
	if data.CustomSplat then
		for _, poofvar in pairs(tearpoofs) do
			for _, splat in pairs(Isaac.FindByType(1000, poofvar, -1, false, false)) do
				if splat.FrameCount <= 0 and splat.Position:Distance(tear.Position) <= 1 then
					local sprite = splat:GetSprite()
					sprite:ReplaceSpritesheet(0, data.CustomSplat)
					sprite:LoadGraphics()
				end
			end
		end
	end
end, EntityType.ENTITY_TEAR)

--Bomb death
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bomb)
	if bomb:GetData().TaintedFireWave then
		mod:DoConsecrationWave(bomb:GetData().TaintedPlayerRef, bomb.Position)
	end
end, EntityType.ENTITY_BOMBDROP)

--Rocket death
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, rocket)
	if rocket.Variant == EffectVariant.ROCKET then
		if rocket:GetData().TaintedFireWave then
			mod:DoConsecrationWave(rocket:GetData().TaintedPlayerRef, rocket.Position)
		end
		
		if rocket.SpawnerEntity then
			local player = rocket.SpawnerEntity:ToPlayer()
			if player then
				if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
					player:GetData().TaintedArePolycoriaTearsSpawning = true
					local tearstospawn = mod:RandomInt(10,20)
					for i = 1, tearstospawn do
						local newtear = player:FireTear(rocket.Position, RandomVector():Resized(mod:RandomInt(10, 20)), true, true, false, player, 1):ToTear()
						newtear.CollisionDamage = (newtear.CollisionDamage + mod:RandomInt(-3, 3)*rng:RandomFloat())*0.8
						if newtear.CollisionDamage < 0.1 then
							newtear.CollisionDamage = 0.1
						end
						newtear.Scale = newtear.Scale + (rng:RandomFloat()/2)*mod:RandomInt(-1, 1)
						newtear.Position = newtear.Position + Vector(mod:RandomInt(-15, 15), mod:RandomInt(-15, 15))
						newtear:ClearTearFlags(TearFlags.TEAR_ORBIT, TearFlags.TEAR_OCCULT)
					end
					player:GetData().TaintedArePolycoriaTearsSpawning = false
				end
			end
		end
	end
end, EntityType.ENTITY_EFFECT)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, damage, flags, source, countdown) --On-hit attacks from players
	if npc:IsEnemy() and source and source.Entity and not (flags == flags | DamageFlag.DAMAGE_CLONES) and not npc:IsInvincible() and npc.Type ~= EntityType.ENTITY_FIREPLACE then
		local data = source.Entity:GetData()
		if source.Type == EntityType.ENTITY_TEAR then --Tear hits
			local tear = source.Entity:ToTear()
			local player = mod:GetPlayerFromTear(tear)

			--Buzzing Magnets
			if data.TaintedRepulsion then
				mod:ApplyCustomStatus(npc, "Repulsion", 90, player)
			end

			--Salt of Magnesium
			if data.TaintedPoopBlast then
				mod:ApplyPoopKnockback(npc, tear.Velocity:Resized(20), damage, tear, flags)
			end

			--Dryad's Blessing
			if data.TaintedGermination then
				mod:ApplyCustomStatus(npc, "Germinated", 180, player)
			end
		end
		if source.Type == EntityType.ENTITY_BOMBDROP and flags == flags | DamageFlag.DAMAGE_EXPLOSION then --Bomb hits
			local bomb = source.Entity:ToBomb()
			local player = data.TaintedPlayerRef
			if player and player:Exists() then
				--Buzzing Magnets
				if data.TaintedRepulsion then
					mod:ApplyCustomStatus(npc, "Repulsion", 90, player)
				end

				--Salt of Magnesium
				if data.TaintedPoopBlast then
					mod:ApplyPoopKnockback(npc, (npc.Position - bomb.Position):Resized(20), damage, bomb, flags)
				end

				--Dryad's Blessing
				if data.TaintedGermination then
					mod:ApplyCustomStatus(npc, "Germinated", 180, player)
				end
			end
		elseif source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.ROCKET then --Epic Fetus hits
			local player = data.TaintedPlayerRef
			if player and player:Exists() then
				--Buzzing Magnets
				if data.TaintedRepulsion then
					mod:ApplyCustomStatus(npc, "Repulsion", 90, player)
				end

				--Salt of Magnesium
				if data.TaintedPoopBlast then
					mod:ApplyPoopKnockback(npc, (npc.Position - source.Position):Resized(20), damage, source.Entity, flags)
				end

				--Dryad's Blessing
				if data.TaintedGermination then
					mod:ApplyCustomStatus(npc, "Germinated", 180, player)
				end
			end
		elseif source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL then --Aquarius hits
			if source.Entity.SpawnerEntity and source.Entity.SpawnerType == EntityType.ENTITY_PLAYER then
				local player = source.Entity.SpawnerEntity:ToPlayer()
				local creep = source.Entity

				--Buzzing Magnets
				if data.TaintedRepulsion then
					mod:ApplyCustomStatus(npc, "Repulsion", 90, player)
				end

				--Consecration
				if data.TaintedFireWave and data.TaintedFireWaveCooldown <= 0 then
					mod:DoConsecrationWave(player, creep.Position)
					data.TaintedFireWaveCooldown = 15
				end

				--Dryad's Blessing
				if data.TaintedGermination then
					mod:ApplyCustomStatus(npc, "Germinated", 180, player)
				end

				if player:HasCollectible(TaintedCollectibles.EVANGELISM) then
					mod:EvangelismOnHitIncrementing(player, npc)
				end
			end
		elseif source.Type == EntityType.ENTITY_KNIFE then --Mom's Knife hits
			local player = mod:getPlayerFromKnife(source.Entity)
			if player then
				local knife = source.Entity:ToKnife()
				local data = knife:GetData()

				--Buzzing Magnets
				if player:HasCollectible(TaintedCollectibles.BUZZING_MAGNETS) then
					if mod:BasicRoll(player.Luck, 12, 1, player:GetCollectibleRNG(TaintedCollectibles.BUZZING_MAGNETS)) then
						mod:ApplyCustomStatus(npc, "Repulsion", 90, player)
					end	
				end

				--Salt of Magnesium
				if player:HasCollectible(TaintedCollectibles.SALT_OF_MAGNESIUM) then
					if mod:BasicRoll(player.Luck, 18, 0.5, player:GetCollectibleRNG(TaintedCollectibles.SALT_OF_MAGNESIUM)) then
						mod:ApplyPoopKnockback(npc, Vector(20,0):Rotated(knife.Rotation), damage, knife, flags)
					end	
				end

				--Consecration
				if player:HasCollectible(TaintedCollectibles.CONSECRATION) then
					if mod:BasicRoll(player.Luck, 18, 0.5, player:GetCollectibleRNG(TaintedCollectibles.CONSECRATION)) then
						mod:DoConsecrationWave(player, npc.Position)
					end
				end

				--Dryad's Blessing
				if player:HasCollectible(TaintedCollectibles.DRYADS_BLESSING) then
					if mod:BasicRoll(player.Luck, 18, 1, player:GetCollectibleRNG(TaintedCollectibles.DRYADS_BLESSING)) then
						mod:ApplyCustomStatus(npc, "Germinated", 180, player)
					end
				end

				--The Bottle
				if data.IsTaintedBottle then
					return mod:BottleKnifeOnHit(knife, data, npc, flags, damage, countdown)
				end

				if data.TaintedRawSoylent then
					npc:TakeDamage(damage * 0.2, flags | DamageFlag.DAMAGE_CLONES, EntityRef(knife), countdown)  
					return false
				end
			end
		elseif source.Type == EntityType.ENTITY_PLAYER and flags == flags | DamageFlag.DAMAGE_LASER then --Laser hits
			local player = source.Entity:ToPlayer()

			--Buzzing Magnets
			if player:HasCollectible(TaintedCollectibles.BUZZING_MAGNETS) then
				if mod:BasicRoll(player.Luck, 9, 1, player:GetCollectibleRNG(TaintedCollectibles.BUZZING_MAGNETS)) then
					mod:ApplyCustomStatus(npc, "Repulsion", 90, player)
				end	
			end

			--Salt of Magnesium
			if player:HasCollectible(TaintedCollectibles.SALT_OF_MAGNESIUM) then
				if mod:BasicRoll(player.Luck, 13, 0.5, player:GetCollectibleRNG(TaintedCollectibles.SALT_OF_MAGNESIUM)) then
					mod:ApplyPoopKnockback(npc, (npc.Position - player.Position):Resized(20), damage, player, flags)
				end
			end

			--Consecration
			if player:HasCollectible(TaintedCollectibles.CONSECRATION) then
				if mod:BasicRoll(player.Luck, 13, 0.5, player:GetCollectibleRNG(TaintedCollectibles.CONSECRATION)) then
					mod:DoConsecrationWave(player, npc.Position)
				end
			end

			--Dryad's Blessing
			if player:HasCollectible(TaintedCollectibles.DRYADS_BLESSING) then
				if mod:BasicRoll(player.Luck, 13, 1, player:GetCollectibleRNG(TaintedCollectibles.DRYADS_BLESSING)) then
					mod:ApplyCustomStatus(npc, "Germinated", 180, player)
				end
			end

			if player:HasCollectible(TaintedCollectibles.EVANGELISM) then
				mod:EvangelismOnHitIncrementing(player, npc)
			end
		elseif source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.DARK_SNARE then --Dark Arts hits (yes these apply synergies)
			if source.Entity and source.Entity.SpawnerEntity and source.Entity.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
				local player = source.Entity.SpawnerEntity:ToPlayer()

				--Buzzing Magnets
				if player:HasCollectible(TaintedCollectibles.BUZZING_MAGNETS) then
					if mod:BasicRoll(player.Luck, 3, 1, player:GetCollectibleRNG(TaintedCollectibles.BUZZING_MAGNETS)) then
						mod:ApplyCustomStatus(npc, "Repulsion", 90, player)
					end	
				end

				--Consecration
				if player:HasCollectible(TaintedCollectibles.CONSECRATION) then
					if mod:BasicRoll(player.Luck, 5, 0.5, player:GetCollectibleRNG(TaintedCollectibles.CONSECRATION)) then
						mod:DoConsecrationWave(player, npc.Position)
					end
				end

				--Dryad's Blessing
				if player:HasCollectible(TaintedCollectibles.DRYADS_BLESSING) then
					if mod:BasicRoll(player.Luck, 5, 1, player:GetCollectibleRNG(TaintedCollectibles.DRYADS_BLESSING)) then
						mod:ApplyCustomStatus(npc, "Germinated", 180, player)
					end
				end
			end
		elseif source.Type == EntityType.ENTITY_PLAYER then --Checks for club hits
			local player = source.Entity:ToPlayer()
			if player:HasWeaponType(WeaponType.WEAPON_BONE) or player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD) then
				local knife = mod:GetNearbyClub(npc.Position, 140)
				if knife and mod:getPlayerFromKnife(knife) and GetPtrHash(mod:getPlayerFromKnife(knife)) == GetPtrHash(player) and mod:IsBoneClub(knife) then
					if knife.Variant ~= 4 and knife.Variant ~= 9 then --Bag of Crafting, Notched Axe
						--Buzzing Magnets
						if player:HasCollectible(TaintedCollectibles.BUZZING_MAGNETS) then
							if mod:BasicRoll(player.Luck, 3, 1, player:GetCollectibleRNG(TaintedCollectibles.BUZZING_MAGNETS)) then
								mod:ApplyCustomStatus(npc, "Repulsion", 90, player)
							end	
						end

						--Consecration
						if player:HasCollectible(TaintedCollectibles.CONSECRATION) then
							if mod:BasicRoll(player.Luck, 5, 0.5, player:GetCollectibleRNG(TaintedCollectibles.CONSECRATION)) then
								mod:DoConsecrationWave(player, npc.Position)
							end	
						end

						--Salt of Magnesium
						if player:HasCollectible(TaintedCollectibles.SALT_OF_MAGNESIUM) then
							if mod:BasicRoll(player.Luck, 5, 0.5, player:GetCollectibleRNG(TaintedCollectibles.SALT_OF_MAGNESIUM)) then
								mod:ApplyPoopKnockback(npc, Vector(20,0):Rotated(knife.Rotation), damage, knife, flags)
							end	
						end

						--Dryad's Blessing
						if player:HasCollectible(TaintedCollectibles.DRYADS_BLESSING) then
							if mod:BasicRoll(player.Luck, 5, 1, player:GetCollectibleRNG(TaintedCollectibles.DRYADS_BLESSING)) then
								mod:ApplyCustomStatus(npc, "Germinated", 180, player)
							end
						end
						
						--Bottle
						if player:HasCollectible(TaintedCollectibles.THE_BOTTLE) then
							if mod:BasicRoll(player.Luck, 5, 1, player:GetCollectibleRNG(TaintedCollectibles.THE_BOTTLE)) then
								sfx:Play(TaintedSounds.BOTTLE_BREAK)
								local shardvec = RandomVector()
								for i = 1, mod:RandomInt(2,4) do
									local shard = Isaac.Spawn(1000, TaintedEffects.BOTTLE_SHARD, 0, npc.Position, (shardvec * mod:RandomInt(2,4,knife:GetDropRNG())):Rotated(i * (360/5)), knife)
									shard.CollisionDamage = math.max(3.5, knife.CollisionDamage*1.5)
								end
							end	
						end
					end
				end
			end
		end
	end
end)

--Knife stuff
function mod:IsBoneClub(knife)
	return (knife.Variant ~= 0 and knife.Variant ~= 5)
end

function mod:getPlayerFromKnife(knife)
	if knife.SpawnerEntity and knife.SpawnerEntity:ToPlayer() then
		return knife.SpawnerEntity:ToPlayer()
	elseif knife.SpawnerEntity and knife.SpawnerEntity:ToFamiliar() and knife.SpawnerEntity:ToFamiliar().Player then
		local familiar = knife.SpawnerEntity:ToFamiliar()
		if mod:DoesFamiliarShootPlayerTears(familiar) then
			return familiar.Player
		else
			return nil
		end
	else
		return nil
	end
end

function mod:GetNearbyClub(position, radius)
	local knives = Isaac.FindByType(EntityType.ENTITY_KNIFE)
	local distance = radius
	local nearbyknife = false
	for i, knife in pairs(knives) do
		if knife.Position:Distance(position) < distance and knife.SubType == 4 then
			nearbyknife = knife
			distance = knife.Position:Distance(position)
		end
	end
	if distance < radius then
		return nearbyknife:ToKnife()
	end
end