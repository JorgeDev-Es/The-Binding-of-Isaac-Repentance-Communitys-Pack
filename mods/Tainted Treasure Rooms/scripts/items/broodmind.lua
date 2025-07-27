local mod = TaintedTreasure
local game = Game()
local rng = RNG()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	if player:HasCollectible(TaintedCollectibles.BROODMIND) then
		local data = familiar:GetData()
		familiar.Target = nil
		--Isaac.Spawn(EntityType.ENTITY_EFFECT, 123, 1, player.Position+(player:GetAimDirection()):Resized(20), Vector.Zero, nil)
		if familiar:GetOrbitPosition(player.Position):Distance(player.Position+(player:GetAimDirection()):Resized(30)) < 20 and player:GetFireDirection() ~= -1 then
			local lerpamount = (1/familiar.Position:Distance(player.Position))*0.15
			familiar.Velocity = mod:Lerp(familiar.Velocity, familiar.Position - player.Position+player:GetAimDirection():Resized(player.TearRange*0.4), lerpamount, 0.5, 0.5)
		end
	end
end, FamiliarVariant.BLUE_FLY)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	if player:HasCollectible(TaintedCollectibles.BROODMIND) then
		local data = familiar:GetData()
		
		if player:GetFireDirection() ~= -1 then
			for i, enemy in pairs(Isaac.FindInRadius(player.Position+player:GetAimDirection():Resized(player.TearRange/3), 60, EntityPartition.ENEMY)) do
				if not enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
					familiar.Target = enemy
				end
			end
		else
			familiar.Target = player
			if familiar:GetSprite():IsPlaying("Walk") then
				familiar.Velocity = mod:Lerp(familiar.Velocity, (player.Position - familiar.Position):Resized(20), rng:RandomFloat(), 0.2, 0.2)
			end
		end
	end
end, FamiliarVariant.BLUE_SPIDER)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	local player = familiar.Player
	if player:HasCollectible(TaintedCollectibles.BROODMIND) then
		familiar:SetColor(Color(0.7, 0.1, 0.1, 1, 0.2, 0, 0), -1, 1)
	
		if not player:GetData().TaintedAreExtraFliesSpawning and mod:RandomInt(1,4,player:GetCollectibleRNG(TaintedCollectibles.BROODMIND)) == 1 then
			player:GetData().TaintedAreExtraFliesSpawning = true
			Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, familiar.SubType, familiar.Position, familiar.Velocity, player)
		end
		player:GetData().TaintedAreExtraFliesSpawning = false
	end
end, FamiliarVariant.BLUE_FLY)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)	
	local player = familiar.Player
	if player:HasCollectible(TaintedCollectibles.BROODMIND) then
		familiar:SetColor(Color(1, 1, 1, 1, 0.2, 0, 0), -1, 1)
		familiar:GetSprite():Load("gfx/familiar/familiar_brood_spider.anm2", true)
	
		if not player:GetData().TaintedAreExtraSpidersSpawning and mod:RandomInt(1,4,player:GetCollectibleRNG(TaintedCollectibles.BROODMIND)) == 1 then
			player:GetData().TaintedAreExtraSpidersSpawning = true
			Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, familiar.SubType, familiar.Position, familiar.Velocity, player)
		end
		player:GetData().TaintedAreExtraSpidersSpawning = false
	end
end, FamiliarVariant.BLUE_SPIDER)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
	local player = familiar.Player
	if player:HasCollectible(TaintedCollectibles.BROODMIND) and collider:IsEnemy() then
		if rng:RandomFloat() < 0.75 then
			collider:TakeDamage(familiar.CollisionDamage*0.2, 0, EntityRef(familiar), 10)
			familiar.Velocity = mod:Lerp(familiar.Velocity, (familiar.Position - collider.Position), 0.8)
			return true
		else
			collider.Velocity = mod:Lerp(collider.Velocity, (collider.Position - familiar.Position), 0.2)
		end
	end
end, FamiliarVariant.BLUE_FLY)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
	local player = familiar.Player
	if player:HasCollectible(TaintedCollectibles.BROODMIND) and collider:IsEnemy() then
		if rng:RandomFloat() < 0.75 then
			collider:TakeDamage(familiar.CollisionDamage*0.2, 0, EntityRef(familiar), 10)
			familiar.Velocity = mod:Lerp(familiar.Velocity, (familiar.Position - collider.Position), 0.8)
			return true
		else
			collider.Velocity = mod:Lerp(collider.Velocity, (collider.Position - familiar.Position), 0.2)
		end
	end
end, FamiliarVariant.BLUE_SPIDER)