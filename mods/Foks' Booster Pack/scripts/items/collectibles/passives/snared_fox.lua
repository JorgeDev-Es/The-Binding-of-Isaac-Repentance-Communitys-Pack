local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local TRIGGER_THRESHOLD = 6
local TEAR_DELAY = 2
local TEAR_AMOUNT = 6
local TEAR_SPEED = 12
local FLY_NUM = {3, 6}

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, collectible, charge, firstTime, slot, data, player)
	if not firstTime then return end
	
	local pickupPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
	local pickup = Isaac.Spawn(
		EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, 
		pickupPos, Vector.Zero, player):ToPickup()
	
	player:AddBlueFlies(mod.RandomIntRange(FLY_NUM[1], FLY_NUM[2]), player.Position, player)
end, mod.Collectible.SNARED_FOX)

mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, function(_, dir, amount, entity, weapon)
	local player = entity and mod.GetPlayerFromEntity(entity)
	
	if player and player:HasCollectible(mod.Collectible.SNARED_FOX) then
		if weapon and weapon:GetNumFired() % TRIGGER_THRESHOLD == 0 and amount > 0 then
			local function getDirection()
				if dir:Length() ~= 0 then
					return dir
				elseif weapon and weapon:GetDirection():Length() ~= 0 then
					return weapon:GetDirection()
				end
				return Vector.Zero
			end
			local tearDirection = getDirection()
			
			Isaac.CreateTimer(function()
				local tearParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS, nil, nil, entity)
				local tear = Isaac.Spawn(
					EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, entity.Position, 
					tearDirection:Resized(TEAR_SPEED), entity):ToTear()
				tear:AddVelocity(player:GetTearMovementInheritance(tear.Velocity))
				tear:AddTearFlags(TearFlags.TEAR_WIGGLE)
				tear.Scale = tearParams.TearScale * mod.RandomFloatRange(0.8, 1.4)
				tear.Color = Color.Lerp(Color.Default, Color.ProjectileCorpseGreen, RNG(tear.InitSeed):RandomFloat())
				tear.CollisionDamage = tearParams.TearDamage
				tear.CanTriggerStreakEnd = false
				tear.Mass = 0
				tear:Update()
			end, TEAR_DELAY, TEAR_AMOUNT, false)
		end
	end
end)