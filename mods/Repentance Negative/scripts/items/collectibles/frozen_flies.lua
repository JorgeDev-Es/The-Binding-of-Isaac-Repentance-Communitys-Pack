local Mod = RepMMod

local tsunFlyVar = Isaac.GetEntityVariantByName("Tsun_Fly")
local tsunOrbitDistance = Vector(30.0, 30.0)
local tsunOrbitLayer = 127
local tsunOrbitSpeed = 0.02
local tsunCenterOffset = Vector(0.0, 0.0)
local whiteColor = Color(1, 1, 1, 1, 0, 0, 0)
whiteColor:SetColorize(1, 1, 1, 1)
whiteColor:SetTint(20, 20, 20, 2)

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache_flag)
	local familiar_count = player:GetCollectibleNum(Mod.RepmTypes.COLLECTIBLE_TSUNDERE_FLY) * 2
	player:CheckFamiliar(tsunFlyVar, familiar_count, player:GetCollectibleRNG(Mod.RepmTypes.COLLECTIBLE_TSUNDERE_FLY))
end, CacheFlag.CACHE_FAMILIARS)

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, orbital)
	orbital.OrbitDistance = tsunOrbitDistance
	orbital.OrbitSpeed = tsunOrbitSpeed
	orbital:AddToOrbit(tsunOrbitLayer)
end, tsunFlyVar)

Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider, low)
	if collider:IsVulnerableEnemy() then
		local player = familiar.Player
		if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			collider:TakeDamage(2, 0, EntityRef(familiar), 1)
		else
			collider:TakeDamage(1, 0, EntityRef(familiar), 1)
		end
	elseif collider:ToProjectile() ~= nil then
		local loopInt = 1
		local player = familiar.Player
		if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			loopInt = 2
		end
		for i = 1, loopInt, 1 do
			local tear = familiar:FireProjectile(collider.Velocity * Vector(-1, -1))
			tear.Velocity = collider.Velocity * Vector(-1, -1)
			tear.Position = collider.Position
			tear.CollisionDamage = collider.CollisionDamage
			--tear:AddTearFlags(TearFlags.TEAR_ICE)
			tear:AddTearFlags(TearFlags.TEAR_HOMING)
			tear:GetData().RepMinusWillFreeze = true
			collider:Remove()
		end
	end
end, tsunFlyVar)

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, orbital)
	orbital.OrbitDistance = tsunOrbitDistance
	orbital.OrbitSpeed = tsunOrbitSpeed
	local center_pos = (orbital.Player.Position + orbital.Player.Velocity) + tsunCenterOffset
	local orbit_pos = orbital:GetOrbitPosition(center_pos)
	orbital.Velocity = orbit_pos - orbital.Position
end, tsunFlyVar)

Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider, low)
	if tear:GetData().RepMinusWillFreeze == true and collider:IsVulnerableEnemy() and not collider:IsBoss() then
		collider:AddEntityFlags(EntityFlag.FLAG_ICE)
		tear.CollisionDamage = 9999
	elseif tear:GetData().RepMinusWillFreeze == true and collider:IsVulnerableEnemy() and collider:IsBoss() then
		collider:AddSlowing(EntityRef(tear), 30, 0.5, collider.Color)
	end
end)
