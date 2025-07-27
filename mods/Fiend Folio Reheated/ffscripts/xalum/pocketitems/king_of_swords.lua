local mod = FiendFolio
local kingOfSwords = mod.ITEM.CARD.KING_OF_SWORDS

local function getKingOfSwordsWisp(player, data)
	for _, wisp in pairs(Isaac.FindByType(3, 237, CollectibleType.COLLECTIBLE_BFFS)) do
		if wisp.InitSeed == data.kingOfSwordsWisp then
			return wisp:ToFamiliar()
		end
	end
	--BACKUP
	local wisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_BFFS, Vector(-1000, -1000)):ToFamiliar()
	wisp:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
	wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	wisp.Visible = false

	data.kingOfSwordsWisp = wisp.InitSeed
	return wisp:ToFamiliar()
end
local function getKingOfSwordsWisp2(player, data)
	for _, wisp in pairs(Isaac.FindByType(3, 237, CollectibleType.COLLECTIBLE_HIVE_MIND)) do
		if wisp.InitSeed == data.kingOfSwordsWisp2 then
			return wisp:ToFamiliar()
		end
	end
	--BACKUP
	local wisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_HIVE_MIND, Vector(-1000, -1000)):ToFamiliar()
	wisp:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
	wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	wisp.Visible = false

	data.kingOfSwordsWisp2 = wisp.InitSeed
	return wisp:ToFamiliar()
end

local commonDips = {
	[0] = true,
	[1] = true,
	[2] = true,
	[20] = true,
}


mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
	local data = mod.GetPersistentPlayerData(player)
	if not data.kingOfSwordsWisp then
		local wisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_BFFS, Vector(-1000, -1000)):ToFamiliar()
		wisp:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
		wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		wisp.Visible = false

		data.kingOfSwordsWisp = wisp.InitSeed
	end
	if not data.kingOfSwordsWisp2 then
		local wisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_HIVE_MIND, Vector(-1000, -1000)):ToFamiliar()
		wisp:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
		wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		wisp.Visible = false

		data.kingOfSwordsWisp2 = wisp.InitSeed
	end

	--Upgrade familiars
	local rng = player:GetCardRNG(kingOfSwords)
	for _, fly in pairs(Isaac.FindByType(3, FamiliarVariant.BLUE_FLY, 0)) do
		local fly = fly:ToFamiliar()
		local rand = rng:RandomInt(5) + 1
		if rand == 5 then
			for i = 1, 3 do
				local newFly = Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, rand, fly.Position + RandomVector() * 10, Vector.Zero, fly.Player)
				newFly:Update()
			end
		else
			local newFly = Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, rand, fly.Position, Vector.Zero, fly.Player)
			newFly:Update()
		end
		fly:Remove()
	end
	for _, dip in pairs(Isaac.FindByType(3, FamiliarVariant.DIP, -1)) do
		if commonDips[dip.SubType] then
			local dip = dip:ToFamiliar()
			local newVar = rng:RandomInt(#mod.poopyFamiliars.Rare2) + 1
			local newDip = Isaac.Spawn(3, FamiliarVariant.DIP, mod.poopyFamiliars.Rare2[newVar], dip.Position, Vector.Zero, dip.Player)
			newDip:Update()
			dip:Remove()
		elseif dip.SubType == 3 then
			local dip = dip:ToFamiliar()
			local newDip = Isaac.Spawn(3, FamiliarVariant.DIP, 669, dip.Position, Vector.Zero, dip.Player)
			newDip:Update()
			dip:Remove()
		elseif dip.SubType ~= 669 then
			local dip = dip:ToFamiliar()
			local newDip = Isaac.Spawn(3, FamiliarVariant.DIP, 3, dip.Position, Vector.Zero, dip.Player)
			newDip:Update()
			dip:Remove()
		end
	end
	for _, skuzz in pairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.ATTACK_SKUZZ, 0)) do
		local skuzz = skuzz:ToFamiliar()
		local rand = rng:RandomInt(4) + 1
		local newSkuzz = Isaac.Spawn(3, mod.ITEM.FAMILIAR.ATTACK_SKUZZ, rand, skuzz.Position, Vector.Zero, skuzz.Player)
		newSkuzz:Update()
		skuzz:Remove()
	end

	FiendFolio:trySayAnnouncerLine(mod.Sounds.VACardPlayingKingSwords, flags, 20)
end, kingOfSwords)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local data = mod.GetPersistentPlayerData(player)
	if data.kingOfSwordsWisp then
		local wisp = getKingOfSwordsWisp(player, data)
		wisp.Position = Vector(-1000, -1000)
		wisp.Velocity = Vector.Zero
		wisp.Visible = false
		wisp:RemoveFromOrbit()
	end
	if data.kingOfSwordsWisp2 then
		local wisp = getKingOfSwordsWisp2(player, data)
		wisp.Position = Vector(-1000, -1000)
		wisp.Velocity = Vector.Zero
		wisp.Visible = false
		wisp:RemoveFromOrbit()
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	mod.AnyPlayerDo(function(player)
		local data = mod.GetPersistentPlayerData(player)
		if data.kingOfSwordsWisp then
			local wisp = getKingOfSwordsWisp(player, data)
			wisp:Remove()
			wisp:Kill()
			data.kingOfSwordsWisp = nil
		end
		if data.kingOfSwordsWisp2 then
			local wisp = getKingOfSwordsWisp2(player, data)
			wisp:Remove()
			wisp:Kill()
			data.kingOfSwordsWisp2 = nil
		end
	end)
end)