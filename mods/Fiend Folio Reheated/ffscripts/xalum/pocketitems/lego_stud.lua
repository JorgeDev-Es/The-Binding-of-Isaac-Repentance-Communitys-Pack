local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local stud = mod.ITEM.CARD.STUD

local studs = {
	mod.ITEM.CARD.STUD,
	mod.ITEM.CARD.STUD_2,
	mod.ITEM.CARD.STUD_3,
	mod.ITEM.CARD.STUD_4,
	mod.ITEM.CARD.STUD_5,
	mod.ITEM.CARD.STUD_6,
}

local studToValue = {
	[mod.ITEM.CARD.STUD] 	= 1,
	[mod.ITEM.CARD.STUD_2] 	= 2,
	[mod.ITEM.CARD.STUD_3] 	= 3,
	[mod.ITEM.CARD.STUD_4] 	= 4,
	[mod.ITEM.CARD.STUD_5] 	= 5,
	[mod.ITEM.CARD.STUD_6]	= 6,
}

local valueToStud = {
	[1] = mod.ITEM.CARD.STUD,
	[2] = mod.ITEM.CARD.STUD_2,
	[3] = mod.ITEM.CARD.STUD_3,
	[4] = mod.ITEM.CARD.STUD_4,
	[5] = mod.ITEM.CARD.STUD_5,
	[6] = mod.ITEM.CARD.STUD_6,
}

local studToLast = {
	[mod.ITEM.CARD.STUD_2]	= mod.ITEM.CARD.STUD,
	[mod.ITEM.CARD.STUD_3]	= mod.ITEM.CARD.STUD_2,
	[mod.ITEM.CARD.STUD_4]	= mod.ITEM.CARD.STUD_3,
	[mod.ITEM.CARD.STUD_5]	= mod.ITEM.CARD.STUD_4,
	[mod.ITEM.CARD.STUD_6]	= mod.ITEM.CARD.STUD_5,
}

local function isCardStud(id)
	return studToValue[id] and studToValue[id] ~= 0
end

for _, id in pairs(studs) do
	mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flags)
		Isaac.Spawn(5, 20, mod.PICKUP.COIN.LEGOSTUD, player.Position, Vector.Zero, player)

		if flags & UseFlag.USE_MIMIC == 0 and studToLast[id] then
			player:AddCard(studToLast[id])
		end
		FiendFolio:trySayAnnouncerLine(mod.Sounds.VAObjectLegoStud, flags, 40)
	end, id)
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if pickup.SubType == mod.PICKUP.COIN.LEGOSTUD then
		if pickup:GetSprite():IsEventTriggered("DropSound") then
			sfx:Play(SoundEffect.SOUND_SCAMPER)
		end

		if pickup.EntityCollisionClass ~= 0 and pickup.FrameCount % 5 == 0 then
			for _, entity in pairs(Isaac.FindInRadius(pickup.Position, pickup.Size * 1.5, EntityPartition.ENEMY)) do
				if entity:ToNPC() and entity:IsVulnerableEnemy() then
					entity:TakeDamage(5, 0, EntityRef(pickup.SpawnerEntity or pickup), 0)
				end
			end
		end
	end
end, PickupVariant.PICKUP_COIN)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if pickup.SubType == mod.PICKUP.COIN.LEGOSTUD then
		if collider:ToPlayer() or collider:ToFamiliar() then
			pickup.SubType = 1

			mod.scheduleForUpdate(function()
				sfx:Stop(SoundEffect.SOUND_PENNYPICKUP)
				sfx:Play(mod.Sounds.LegoStudPickup)
			end, 1)

			local player = collider:ToPlayer()
			if player then
				player:TakeDamage(1, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
			end
		end
	end
end, PickupVariant.PICKUP_COIN)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if isCardStud(pickup.SubType) and collider:ToPlayer() then
		local pickupValue = studToValue[pickup.SubType]
		local studSlot
		local slotvalue = 9
		local player = collider:ToPlayer()

		for i = 0, 3 do
			local card = player:GetCard(i)
			if isCardStud(card) then
				local value = studToValue[card]
				if value < slotvalue then
					slotvalue = value
					studSlot = i
				end
			end
		end

		local combinedValue = pickupValue + slotvalue
		if studSlot and combinedValue <= 6 then
			local newCard = valueToStud[combinedValue]
			player:SetCard(studSlot, newCard)

			sfx:Play(mod.Sounds.LegoClick, 3, 0, false, math.random(10, 12) / 10)
			pickup:GetSprite():Play("Collect")
			pickup:Die()
			return true
		end
	end
end, 300)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, useFlags)
	for _, card in pairs(Isaac.FindByType(5, 300)) do
		if isCardStud(card.SubType) then
			local value = studToValue[card.SubType]
			if value > 1 then
				card:Remove()
				for i = 1, value do
					local pickup = Isaac.Spawn(5, 300, mod.ITEM.CARD.STUD, card.Position, RandomVector() * 5, card)
					pickup:GetSprite():Play("Idle")
					pickup.EntityCollisionClass = 4
				end

				game:BombExplosionEffects(card.Position, 20, TearFlags.TEAR_NORMAL, Color.Default, player, 0.5)
			end
		end
	end

	for _, coin in pairs(Isaac.FindByType(5, 20, mod.PICKUP.COIN.LEGOSTUD)) do
		coin:Remove()
		local pickup = Isaac.Spawn(5, 300, mod.ITEM.CARD.STUD, coin.Position, RandomVector(), coin)
	end
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VAObjectBrickSeperator, useFlags, 30)
end, mod.ITEM.CARD.BRICK_SEPERATOR)