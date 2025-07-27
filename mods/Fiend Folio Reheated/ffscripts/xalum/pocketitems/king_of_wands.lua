local mod = FiendFolio
local sfx = SFXManager()

local wandsKing = Card.KING_OF_WANDS
local transformationSeries = {
	BatterySubType.BATTERY_MICRO,
	BatterySubType.BATTERY_NORMAL,
	BatterySubType.BATTERY_MEGA,
	BatterySubType.BATTERY_GOLDEN,
}
local customUpgrades = {
	{{mod.PICKUP.VARIANT.FIREWORK_BATTERY}, {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MEGA}},
	{{mod.PICKUP.VARIANT.VIRTUOUS_BATTERY}, {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MEGA}},
	{{mod.PICKUP.VARIANT.CURSED_BATTERY}, {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL}},
	{{mod.PICKUP.VARIANT.POTATO_BATTERY}, {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO}},
}

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
	local sfxPass
	local goldenPass

	for i = 3, 1, -1 do
		for _, battery in pairs(Isaac.FindByType(5, 90, transformationSeries[i])) do
			Isaac.Spawn(1000, 15, 0, battery.Position, Vector.Zero, nil)
			Isaac.Spawn(5, 90, transformationSeries[i + 1], battery.Position, Vector.Zero, battery.SpawnerEntity)
			battery:Remove()

			sfxPass = true
			goldenPass = goldenPass or i == 3
		end
	end

	for _, card in pairs(Isaac.FindByType(5, 300)) do
		if card.SubType >= Card.STORAGE_BATTERY_0 and card.SubType <= Card.CORRODED_BATTERY_3 then
			Isaac.Spawn(1000, 15, 0, card.Position, Vector.Zero, nil)
			Isaac.Spawn(5, 90, BatterySubType.BATTERY_NORMAL, card.Position, Vector.Zero, card.SpawnerEntity)
			card:Remove()

			sfxPass = true
		end
	end

	for _, tab in pairs(customUpgrades) do
		local ids = tab[1]
		local tranformation = tab[2]
		for _, battery in pairs(Isaac.FindByType(5, ids[1], ids[2])) do
			Isaac.Spawn(1000, 15, 0, battery.Position, Vector.Zero, nil)
			local variant = tranformation[1] or 90
			local subtype = tranformation[2] or BatterySubType.BATTERY_MEGA
			Isaac.Spawn(5, variant, subtype, battery.Position, Vector.Zero, battery.SpawnerEntity)
			battery:Remove()

			sfxPass = true
		end
	end

	if sfxPass then
		sfx:Play(SoundEffect.SOUND_SUMMONSOUND)

		if goldenPass then
			sfx:Play(mod.Sounds.GoldenSlotPayout)
		end
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingWands, flags, 30)
	return true
end, wandsKing)