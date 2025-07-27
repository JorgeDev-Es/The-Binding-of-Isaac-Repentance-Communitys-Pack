function TSIL.EntitySpecific.GetBombs(bombVariant, subType)
	local entities = TSIL.Entities.GetEntities(EntityType.ENTITY_BOMB, bombVariant, subType)

	local bombs = {}

	for _, v in pairs(entities) do
		local bomb = v:ToBomb()
		if bomb then
			table.insert(bombs, bomb)
		end
	end

	return bombs
end


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








function TSIL.EntitySpecific.GetNPCs(entityType, variant, subType, ignoreFriendly)
	local entities = TSIL.Entities.GetEntities(entityType, variant, subType, ignoreFriendly)

	local npcs = {}

	for _, v in pairs(entities) do
		local npc = v:ToNPC()
		if npc then
			table.insert(npcs, npc)
		end
	end

	return npcs
end







