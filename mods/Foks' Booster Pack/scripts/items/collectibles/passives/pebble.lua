local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local ORBIT_LAYER = 5
local MAX_SUBTYPE = 8
local PEBBLE_NUM = {1, 2} -- Min and max num
local SPEED = {20, 60}
local SPEED_THRESHOLD = 60 -- When the speed changes
local TINTED_ROCK_CHANCE = 0.1

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	local famSpr = fam:GetSprite()
	local famRNG = RNG(fam.DropSeed)
	
	fam:AddToOrbit(ORBIT_LAYER)
	fam.SubType = famRNG:RandomInt(MAX_SUBTYPE)
	famSpr.FlipX = famRNG:RandomFloat() <= 0.5
	famSpr:Play("Appear" .. fam.SubType)
end, mod.Familiar.PEBBLE)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local famSpr = fam:GetSprite()
	
	if famSpr:IsFinished() then famSpr:Play("Idle" .. fam.SubType) end
	if famSpr:GetCurrentAnimationData():IsLoopingAnimation() then
		local famPos = fam:GetOrbitPosition(fam.Player.Position) - fam.Position
		local famSpd = fam.FrameCount > SPEED_THRESHOLD and SPEED[2] or SPEED[1]
		
		fam.Velocity = famPos:Length() > famSpd and famPos:Resized(famSpd) or famPos
	end
	fam:MultiplyFriction(0.8)
end, mod.Familiar.PEBBLE)

mod:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, function(_, rock, gridType, immediate)
	if gridType == GridEntityType.GRID_ROCKT or gridType == GridEntityType.GRID_ROCK_SS then
		local entity = mod.GetNearestEntity(rock, function(entity)
			local player = entity:ToPlayer()
			
			return player and player:HasCollectible(mod.Collectible.PEBBLE) -- Only returns entity without :ToPlayer() keep that in mind
		end)
		if entity then
			for _ = 1, mod.RandomIntRange(PEBBLE_NUM[1], PEBBLE_NUM[2]) do
				local fam = mod.AddPebbleOrbital(entity, rock.Position)
				
				fam.Velocity = EntityPickup.GetRandomPickupVelocity(rock.Position) * 2
				fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
		end
		if RNG(rock:GetSaveState().SpawnSeed):RandomFloat() <= TINTED_ROCK_CHANCE then
			if game:GetItemPool():RemoveCollectible(mod.Collectible.PEBBLE) then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, mod.Collectible.PEBBLE, rock.Position, Vector.Zero, nil)
			end
		end
	end
end)