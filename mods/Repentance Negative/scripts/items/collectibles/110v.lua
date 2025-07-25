local Mod = RepMMod

local function OnRoomClear(_, rng)
	--110V double charge part
	for _, player in ipairs(PlayerManager.GetPlayers()) do
		if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_110V) then
			local maxCharge = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(0)).MaxCharges
			if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) ~= maxCharge then
				player:AddActiveCharge(1, ActiveSlot.SLOT_PRIMARY)
			end
		end
	end
end
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.EARLY, OnRoomClear)

Mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.EARLY, function(_, col, rng, player, flags, slot)
	--110V damage on using active part
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_110V) then
		local maxCharge = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(slot)).MaxCharges
		if maxCharge == 2 or maxCharge == 3 then
			player:TakeDamage(
				1,
				DamageFlag.DAMAGE_NO_PENALTIES
					| DamageFlag.DAMAGE_NOKILL
					| DamageFlag.DAMAGE_INVINCIBLE
					| DamageFlag.DAMAGE_NO_MODIFIERS,
				EntityRef(player),
				0
			)
		end
		if maxCharge == 4 then
			player:TakeDamage(
				2,
				DamageFlag.DAMAGE_NO_PENALTIES
					| DamageFlag.DAMAGE_NOKILL
					| DamageFlag.DAMAGE_INVINCIBLE
					| DamageFlag.DAMAGE_NO_MODIFIERS,
				EntityRef(player),
				0
			)
		end
		if maxCharge == 6 then
			player:TakeDamage(
				3,
				DamageFlag.DAMAGE_NO_PENALTIES
					| DamageFlag.DAMAGE_NOKILL
					| DamageFlag.DAMAGE_INVINCIBLE
					| DamageFlag.DAMAGE_NO_MODIFIERS,
				EntityRef(player),
				0
			)
		end
		if maxCharge == 12 then
			player:TakeDamage(
				5,
				DamageFlag.DAMAGE_NO_PENALTIES
					| DamageFlag.DAMAGE_NOKILL
					| DamageFlag.DAMAGE_INVINCIBLE
					| DamageFlag.DAMAGE_NO_MODIFIERS,
				EntityRef(player),
				0
			)
		end
	end
end)