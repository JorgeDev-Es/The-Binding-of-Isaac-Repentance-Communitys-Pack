

function TSIL.EntitySpecific.GetEffects(effectVariant, subType)
	local entities = TSIL.Entities.GetEntities(EntityType.ENTITY_EFFECT, effectVariant, subType)

	local effects = {}

	for _, v in pairs(entities) do
		local effect = v:ToEffect()
		if effect then
			table.insert(effects, effect)
		end
	end

	return effects
end










function TSIL.EntitySpecific.GetPickups(pickupVariant, subType)
	local entities = TSIL.Entities.GetEntities(EntityType.ENTITY_PICKUP, pickupVariant, subType)
	local pickups = {}

	for _, v in pairs(entities) do
		local pickup = v:ToPickup()
		if pickup then
			table.insert(pickups, pickup)
		end
	end

	return pickups
end


function TSIL.EntitySpecific.GetProjectiles(projectileVariant, subType)
	local entities = TSIL.Entities.GetEntities(EntityType.ENTITY_PROJECTILE, projectileVariant, subType)
	local projectiles = {}

	for _, v in pairs(entities) do
		local projectile = v:ToProjectile()
		if projectile then
			table.insert(projectiles, projectile)
		end
	end

	return projectiles
end




function TSIL.EntitySpecific.GetTears(tearVariant, subType)
	local entities = TSIL.Entities.GetEntities(EntityType.ENTITY_TEAR, tearVariant, subType)
	local tears = {}

	for _, v in pairs(entities) do
		local tear = v:ToTear()
		if tear then
			table.insert(tears, tear)
		end
	end

	return tears
end