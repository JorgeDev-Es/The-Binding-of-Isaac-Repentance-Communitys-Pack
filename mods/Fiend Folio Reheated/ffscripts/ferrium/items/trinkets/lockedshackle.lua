local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:openAllRedDoors(makeSound)
	makeSound = makeSound or false
	local room = game:GetRoom()
	local level = game:GetLevel()
	local rind = level:GetCurrentRoomIndex()
	local doors = mod.availableDoors[room:GetRoomShape()]
	local nilDoors = {}
	for _,checkDoor in ipairs(doors) do
		local checkedDoor = room:GetDoor(checkDoor)
		if checkedDoor == nil then
			table.insert(nilDoors, checkDoor)
		end
	end

	local doored
	for _,door in ipairs(nilDoors) do
		local newDoor = level:MakeRedRoomDoor(rind, door)
		if newDoor == true then
			doored = true
		end
	end
	if doored then
		if makeSound then
			sfx:Play(SoundEffect.SOUND_GOLDENKEY, 1, 0, false, 1)
		end
		return true
	else
		return false
	end
end

local keyTrinkets = {
	[TrinketType.TRINKET_PAPER_CLIP] = function(p)
		p:GetData().dontDeleteLockedShackle = p.FrameCount+2
		--just does nothing and lets you drop it normally
		return false
	end,
	[TrinketType.TRINKET_RUSTED_KEY] = function(p, mult, a, sd)
		sd.lockedShackleBoost = sd.lockedShackleBoost or 0
		sd.lockedShackleBoost = sd.lockedShackleBoost+mult*2
		return true
	end,
	[TrinketType.TRINKET_STORE_KEY] = function(p, mult, rng, sd)
		sd.lockedShackleBoost = sd.lockedShackleBoost or 0
		sd.lockedShackleBoost = sd.lockedShackleBoost+mult/2
		sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 0, false, 1)
		for i=1,5*mult do
			Isaac.Spawn(5, 20, 0, p.Position, Vector(rng:RandomInt(5)/3, 0):Rotated(rng:RandomInt(360)), p)
		end
		for i=1,5 do
			Isaac.Spawn(1000, EffectVariant.COIN_PARTICLE, 0, p.Position, Vector(rng:RandomInt(4)+0.5, 0):Rotated(rng:RandomInt(360)), p)
		end
		return true
	end,
	[TrinketType.TRINKET_BLUE_KEY] = function(p, mult, a, sd)
		sd.lockedShackleBlueKey = mult
		sd.lockedShackleBoost = sd.lockedShackleBoost or 0
		sd.lockedShackleBoost = sd.lockedShackleBoost+mult/2
		return true
	end,
	[TrinketType.TRINKET_CRYSTAL_KEY] = function(p, mult, rng, sd)
		sd.lockedShackleBoost = sd.lockedShackleBoost or 0
		sd.lockedShackleBoost = sd.lockedShackleBoost+mult/2
		mod:openAllRedDoors(true)
		sd.lockedShackleRedDoors = sd.lockedShackleRedDoors or 0
		sd.lockedShackleRedDoors = sd.lockedShackleRedDoors+mult*2
		return true
	end,
	[TrinketType.TRINKET_GILDED_KEY] = function(p, mult, rng, sd)
		sd.lockedShackleBoost = sd.lockedShackleBoost or 0
		sd.lockedShackleBoost = sd.lockedShackleBoost+mult/2

		for i=1,2+mult do
			Isaac.Spawn(5, 60, 0, p.Position, Vector(mod:getRoll(5,10, rng), 0):Rotated(rng:RandomInt(360)), p)
		end
		return true
	end,
	[TrinketType.TRINKET_STRANGE_KEY] = function(p, mult, rng, sd)
		sd.lockedShackleBoost = sd.lockedShackleBoost or 0
		sd.lockedShackleBoost = sd.lockedShackleBoost+mult*2
		mod.scheduleForUpdate(function()
			p:UseActiveItem(CollectibleType.COLLECTIBLE_BLUE_BOX, 0)
		end, 0)
		return true
	end,
	[FiendFolio.ITEM.TRINKET.WACKEY] = function(p, mult, rng, sd)
		sfx:Play(mod.Sounds.SlideWhistle, 1, 0, false, mod:getRoll(80,120,rng)/100)
		sd.lockedShackleBoost = sd.lockedShackleBoost or 0
		sd.lockedShackleBoost = sd.lockedShackleBoost+mult/1.3
		p:UseCard(mod.ITEM.CARD.THREE_OF_SPADES, UseFlag.USE_NOANIM)
		return true
	end,
}

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()
		local t0 = player:GetTrinket(0)
		local t1 = player:GetTrinket(1)
		if keyTrinkets[pickup.SubType] and player:HasTrinket(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE) then
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
			local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
			local sd = player:GetData().ffsavedata.RunEffects
			local answer = keyTrinkets[pickup.SubType](player, mult, rng, sd)
			if answer then
				for i=1,mult do
					player:TryRemoveTrinket(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
				end
				sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK, 1, 0, false, 1)
				for i=1,5 do
					local gib = Isaac.Spawn(1000, 163, 0, player.Position, Vector(0,mod:getRoll(2, 6, rng)):Rotated(rng:RandomInt(360)), player):ToEffect()
				end
				player:AddCacheFlags(CacheFlag.CACHE_ALL)
				player:EvaluateItems()
			end
		elseif mod:GetRealTrinketId(t0) == FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE then
			if keyTrinkets[pickup.SubType] then
			elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PURSE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BELLY_BUTTON) then
				if (mod:GetRealTrinketId(t1) == TrinketType.TRINKET_TICK or mod:GetRealTrinketId(t1) == FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE) then
					return false
				elseif t1 > 0 then
					player:TryRemoveTrinket(t1)
					player:TryRemoveTrinket(t0)
					player:AddTrinket(t1)
					player:AddTrinket(t0)
				end
			else
				return false
			end
		end

		if mod:GetRealTrinketId(t0) == TrinketType.TRINKET_TICK then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PURSE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BELLY_BUTTON) then
				if mod:GetRealTrinketId(t1) == FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE then
					return false
				end
			end
		end
	end
end, 350)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() then
		local player = opp:ToPlayer()
		if player:HasTrinket(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE) then
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
			local mult = player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
			local chance = 25
			if rng:RandomInt(100) < chance then
				for i=1,mult do
					player:TryRemoveTrinket(FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE)
				end
				sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK, 1, 0, false, 1)
				for i=1,5 do
					local gib = Isaac.Spawn(1000, 163, 0, player.Position, Vector(0,mod:getRoll(2, 6, rng)):Rotated(rng:RandomInt(360)), player):ToEffect()
				end
				player:AddCacheFlags(CacheFlag.CACHE_ALL)
				player:EvaluateItems()
				if not player:HasGoldenKey() then
					mod.scheduleForUpdate(function()
						player:AddKeys(-1)
					end, 0)
				end
			else
				sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.5, 0, false, 1.2)
				for i=1,2 do
					local gib = Isaac.Spawn(1000, 163, 0, player.Position, Vector(0,mod:getRoll(2, 6, rng)):Rotated(rng:RandomInt(360)), player):ToEffect()
				end
			end
		end
	end
end, 30)

mod.AddTrinketPickupCallback(nil, function(player)
	if (player:GetData().dontDeleteLockedShackle or 0) < player.FrameCount then
		for _,trinket in ipairs(Isaac.FindByType(5,350,-1,false,false)) do
			if mod:GetRealTrinketId(trinket.SubType) == FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE and trinket.FrameCount < 2 then
				trinket.Visible = false
				trinket:Remove()
				player:AddTrinket(trinket.SubType)
			end
		end
		player:GetData().dontDeleteLockedShackle = nil
	end
end, FiendFolio.ITEM.TRINKET.LOCKED_SHACKLE, nil)

function mod:lockedShackleNewRoom(player, d)
	local data = d.ffsavedata
	if data.RunEffects.lockedShackleRedDoors and data.RunEffects.lockedShackleRedDoors > 0 then
		local door = mod:openAllRedDoors(true)
		if door then
			data.RunEffects.lockedShackleRedDoors = data.RunEffects.lockedShackleRedDoors-1
		end
	end
	if data.RunEffects.lockedShackleBlueKey then
		local room = game:GetRoom()
		if room:GetType() == RoomType.ROOM_BLUE then
			for _,fly in ipairs(Isaac.FindByType(EntityType.ENTITY_HUSH_FLY, 0, 0, false, true)) do
				fly:AddCharmed(EntityRef(player), -1)
				fly.HitPoints = fly.HitPoints/2
			end
			for _,gaper in ipairs(Isaac.FindByType(EntityType.ENTITY_HUSH_GAPER, 0, 0, false, true)) do
				gaper:AddCharmed(EntityRef(player), -1)
				gaper.HitPoints = gaper.HitPoints/2
			end
			for _,boil in ipairs(Isaac.FindByType(EntityType.ENTITY_HUSH_BOIL, 0, 0, false, true)) do
				boil:AddCharmed(EntityRef(player), -1)
				boil.HitPoints = boil.HitPoints/2
			end
			for _,fat in ipairs(Isaac.FindByType(EntityType.ENTITY_CONJOINED_FATTY, 1, 0, false, true)) do
				fat:AddCharmed(EntityRef(player), -1)
				fat.HitPoints = fat.HitPoints/2
			end
		end
	end
end