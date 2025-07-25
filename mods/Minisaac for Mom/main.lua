local mod = RegisterMod("Minisaac for Mom", 1)

local IMMORTAL_VALUE = 10

local function checkImmortalMinisaac(player)
	for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.MINISAAC)) do
		local fam = entity:ToFamiliar()
		
		if fam and fam.Hearts == IMMORTAL_VALUE and GetPtrHash(fam.Player) == GetPtrHash(player) then
			return true
		end
	end
	return false
end

local function removeImmortalMinisaac(player)
	for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.MINISAAC)) do
		local fam = entity:ToFamiliar()
		
		if fam and fam.Hearts == IMMORTAL_VALUE and GetPtrHash(fam.Player) == GetPtrHash(player) then
			fam:Kill()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown)
	local fam = entity:ToFamiliar()
	
	if fam and fam.Variant == FamiliarVariant.MINISAAC and fam.Hearts == IMMORTAL_VALUE then
		return false -- Makes the Minisaac immortal
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if player:HasPlayerForm(PlayerForm.PLAYERFORM_MOM) then
		if not checkImmortalMinisaac(player) then
			player:AddMinisaac(player.Position).Hearts = IMMORTAL_VALUE
		end
	elseif checkImmortalMinisaac(player) then
		removeImmortalMinisaac(player)
	end
end)