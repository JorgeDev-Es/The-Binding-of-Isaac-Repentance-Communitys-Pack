local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local sprite = familiar:GetSprite()
	local data = familiar:GetData()
	familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	
	if not familiar.Target then
		if familiar.Position:Distance(player.Position) > 70 then
			familiar.Velocity = mod:Lerp(familiar.Velocity, (player.Position - familiar.Position), 0.005)
			familiar.Velocity = mod:CappedVector(familiar.Velocity, 5.5)
		else
			familiar.Velocity = familiar.Velocity*0.8
		end
	else	
		local target = familiar.Target
		if familiar.Position:Distance(target.Position) > 120 then
			familiar.Velocity = mod:Lerp(familiar.Velocity, (target.Position - familiar.Position), 0.005)
			familiar.Velocity = mod:CappedVector(familiar.Velocity, 8)
		else
			familiar.Velocity = familiar.Velocity*0.7
			if familiar.Velocity:Length() < 3 then
				sprite:Play("Throw")
			end
		end
	end
	
	if data.Poop then	
		local poop = data.Poop
		poop.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		poop.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		if poop:Exists() and poop.HitPoints > 1 then
			poop.SpriteOffset = Vector(0, -35)
			poop.Velocity = mod:Lerp(poop.Velocity, (familiar.Position+familiar.Velocity - poop.Position), 1.5)
			poop.DepthOffset = -20
		else
			data.Poop = nil
		end
		familiar:PickEnemyTarget(999999, 13, 1 << 2)
	else
		for i, entity in pairs(Isaac.FindInRadius(familiar.Position, 10)) do
			if entity.Type == EntityType.ENTITY_POOP and entity.PositionOffset:Length() > 3 then
				data.Poop = entity
				entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				sprite:Play("Pickup")
				entity.Position = familiar.Position
				entity.Velocity = Vector.Zero
				mod:scheduleForUpdate(function()
					entity.Position = familiar.Position
				end, 0)
			end
		end
		familiar.Target = nil
	end
	
	if sprite:IsFinished("Pickup") or sprite:IsFinished("Throw") then
		sprite:Play("PickupIdle")
	end
	
	if not data.Poop and sprite:IsPlaying("PickupIdle") then
		sprite:Play("Idle")
	end
	
	if sprite:IsEventTriggered("PickupThrow") then
		local poop = data.Poop
		if familiar.Target then
			poop:GetData().TaintedThrowVelocity = (familiar.Target.Position - familiar.Position):Resized(30)
		end
		poop:GetData().TaintedIsBeingThrown = true
		poop.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		data.Poop = nil
	end
end, TaintedFamiliars.BYGONE)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if npc:GetData().TaintedIsBeingThrown then
		if npc.SpriteOffset.Y < 0 then
			npc.SpriteOffset = Vector(0, npc.SpriteOffset.Y + 4)
			if npc:GetData().TaintedThrowVelocity then
				npc.Velocity = npc:GetData().TaintedThrowVelocity
			end
		else
			npc.SpriteOffset = Vector.Zero
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			npc:GetData().TaintedIsBeingThrown = false
		end
	end
end, EntityType.ENTITY_POOP)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider)
	if npc:GetData().TaintedIsBeingThrown and collider:IsEnemy() and collider.Type ~= EntityType.ENTITY_POOP then
		collider:TakeDamage(15, 0, EntityRef(npc), 5)
		npc:Kill()
	end
end, EntityType.ENTITY_POOP)