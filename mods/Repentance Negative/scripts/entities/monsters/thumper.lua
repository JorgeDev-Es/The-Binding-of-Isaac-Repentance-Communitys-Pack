local mod = RepMMod

local Thumper = {}
Thumper.type = Isaac.GetEntityTypeByName("Thumper")
Thumper.variant = Isaac.GetEntityVariantByName("Thumper")
Thumper.regularProjectileVelocity = 9
Thumper.regularProjectileSpread = 15
Thumper.shotSpread = 45
Thumper.shotSpeed = 1 --6.5
Thumper.shotDistance = -10

function Thumper.OnShooting(_, shot)
	if shot.SpawnerType == Thumper.type and shot.SpawnerVariant == Thumper.variant then
		shot.ProjectileFlags = ProjectileFlags.SMART
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, Thumper.OnShooting)