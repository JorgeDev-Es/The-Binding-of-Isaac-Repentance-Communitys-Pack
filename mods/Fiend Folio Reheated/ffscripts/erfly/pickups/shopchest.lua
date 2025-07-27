local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.shopChestStates = {
	Closed = 0,
	Opening = 1,
	Opened = 2,
	Leaving = 3,
	DoneLeaving = 4,
	Exploded = 5
}

mod.shopChestChances = {
1,1,1,1,1,
2,2,2,2,2,2,2,2,2,2,
3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
4,4,
5
}

mod.shopChestItemSpawnRots = {
[1] = {StartVec = Vector(0,40), Rotval = 0},
[2] = {StartVec = Vector(-40,0), Rotval = -180},
[3] = {StartVec = Vector(-40,0), Rotval = -90},
[4] = {StartVec = Vector(-40,-20), Rotval = -75},
[5] = {StartVec = Vector(-40,0), Rotval = -45}
}

function mod:spawnShopChestItems(chest, d)
	sfx:Play(SoundEffect.SOUND_SUMMONSOUND,1,1,false,1)
	local count = mod.shopChestChances[math.random(#mod.shopChestChances)]
	local room = Game():GetRoom()
	if room:GetType() == RoomType.ROOM_DEVIL then
		count = 1
	end
	for i = 1, count do
		if room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET then
			local spawnpos = room:FindFreePickupSpawnPosition(chest.Position + mod.shopChestItemSpawnRots[count].StartVec:Rotated((i - 1) * mod.shopChestItemSpawnRots[count].Rotval), 0, false)
			local item
			local rng = chest:GetDropRNG()
			if rng:RandomInt(20) == 0 then
				item = Isaac.Spawn(5,100,0, spawnpos, nilvector, chest):ToPickup()
			else
				item = Isaac.Spawn(5,0,3, spawnpos, nilvector, chest):ToPickup()
			end
			local rand = rng:RandomInt(20)
			if rand < 5 then
				item.AutoUpdatePrice = false
				local rando = rng:RandomInt(3)
                if rando == 1 then
                    item.Price = rng:RandomInt(10) + 1
                elseif rando == 2 then
                    item.Price = rng:RandomInt(20) + 1
                else
                    item.Price = rng:RandomInt(99) + 1
                end
			else
				item.AutoUpdatePrice = true
				item.Price = 1
			end
			item.ShopItemId = -1
			local poof = Isaac.Spawn(1000, EffectVariant.POOF01, 15, item.Position, nilvector, nil)
	
			d.items[i] = item.InitSeed
			d.itemCount = count
		else
			local spawnpos = room:FindFreePickupSpawnPosition(chest.Position + mod.shopChestItemSpawnRots[count].StartVec:Rotated((i - 1) * mod.shopChestItemSpawnRots[count].Rotval), 0, false)
			local item = Isaac.Spawn(5,150,0, spawnpos, nilvector, chest)
			local poof = Isaac.Spawn(1000, EffectVariant.POOF01, 15, item.Position, nilvector, nil)

			d.items[i] = item.InitSeed
			d.itemCount = count
		end
	end
end

mod.ShopChestGfxVariants = {
  [RoomType.ROOM_SHOP] = "slot_shop_shop_begger.png",
  [RoomType.ROOM_BOSS] = "slot_shop_boss_begger.png",
  [RoomType.ROOM_SECRET] = "slot_shop_secret_begger.png",
  [RoomType.ROOM_CURSE] = "slot_shop_devil_begger.png",
  [RoomType.ROOM_DEVIL] = "slot_shop_devil_begger.png",
  [RoomType.ROOM_LIBRARY] = "slot_shop_library_begger.png",
  [RoomType.ROOM_ANGEL] = "slot_shop_angel_begger.png",
  [RoomType.ROOM_CHEST] = "slot_shop_chest_begger.png",
  [RoomType.ROOM_BLACK_MARKET] = "slot_shop_black_market_begger.png",
  [RoomType.ROOM_PLANETARIUM]  = "slot_shop_planetarium_begger.png",
  [RoomType.ROOM_ULTRASECRET]  = "slot_shop_ultrasecret_begger.png",
  }

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, chest)
  local gfxVar = mod.ShopChestGfxVariants[Game():GetRoom():GetType()]
  if gfxVar then
	local sprite = chest:GetSprite()
	sprite:ReplaceSpritesheet(0, "gfx/items/slots/" .. gfxVar)
	sprite:ReplaceSpritesheet(1, "gfx/items/slots/" .. gfxVar)
	sprite:LoadGraphics()
  end
end, 711)

--Shop chest, storechestai, shopchestai, store chest,
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, chest)
	local room = game:GetRoom()
	chest = chest:ToPickup()
	local sprite = chest:GetSprite()
  --if chest.FrameCount == 1 then setShopChestGFX(sprite) end
	local chestseed = tostring(chest.InitSeed)
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'ChestData', chestseed, {})
	local gd = chest:GetData()
	chest.Velocity = chest.Velocity * 0.8
	d.items = d.items or {}

	chest.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
	--print(chest.SubType)
	--[[if gd.Opened then
		d.Opened = true
		--chest.InitSeed = 10
	end]]

	--[[if chest.FrameCount % 5 == 1 then
		print(chest.InitSeed)
		chest:Morph(5, 711, 0, false)
	end]]

	if chest.SubType > 0 and not gd.Position then
		--Keep Pos
		gd.Position = room:GetGridPosition(room:GetGridIndex(chest.Position))
	end

	if chest.SubType > 1 then
		gd.dontSpawnItems = true
	end

	if not chest:GetData().init then
		if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_PAY_TO_PLAY) then
			gd.payToPlayMode = true
		end
		if chest.SubType > 2 then
			if chest.SubType == mod.shopChestStates.Leaving then
				local rng = chest:GetDropRNG()
				if rng:RandomInt(10) <= 7 then
					Isaac.Spawn(5, 0, 0, chest.Position, RandomVector(), nil)
				end
			end
			chest:Remove()
		elseif chest.SubType > 0 then
			if chest.SubType == mod.shopChestStates.Opening then
				if gd.funny then
					sprite:Play("Open", true)
					sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 0, false, 1)
				else
					sprite:Play("Opened", true)
					mod:spawnShopChestItems(chest, d)
					chest.SubType = mod.shopChestStates.Opened
				end
			else
				sprite:Play("Opened", true)
			end
		else
			if gd.payToPlayMode then
				sprite:Play("AppearP2P", true)
			end
		end
		gd.init = true
	end

	local p2pAmmend = ""
	if gd.payToPlayMode then
		p2pAmmend = "P2P"
	end

	if sprite:IsFinished("Appear" .. p2pAmmend) then
		sprite:Play("Idle" .. p2pAmmend, true)
	end
	if sprite:IsFinished("Open" .. p2pAmmend) then
		sprite:Play("Opened", true)
	end
	--[[if sprite:IsPlaying("Open") and sprite:GetFrame() == 5 then
	end]]
	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 0, false, 1.0)
	end
	if sprite:IsEventTriggered("Spawnem") then
		--Spawn Items
		if not gd.dontSpawnItems then
			mod:spawnShopChestItems(chest, d)
		end
		chest.SubType = mod.shopChestStates.Opened
	end
	if d.Opened and sprite:IsPlaying("Idle") then
		chest:Remove()
	end

	if chest.SubType > 1 and chest.SubType < 3 then
		local itemCountNew = 0
		for _, item in ipairs(Isaac.FindByType(5, -1, -1, false, false)) do
			for i = 1, #d.items do
				if item.InitSeed == d.items[i] then
					itemCountNew = itemCountNew + 1
				end
			end
		end
		--print ("#items spawned = " .. d.itemCount .. " #items detected = " .. itemCountNew)
		if itemCountNew < 1 then
			mod:spritePlay(sprite, "Close")
			chest.SubType = mod.shopChestStates.Leaving
		elseif itemCountNew < d.itemCount then
			d.itemCount = itemCountNew
			sprite:Play("OpenedHappy", true)
		end

		for _, explosion in ipairs(Isaac.FindByType(1000, 1, -1, false, false)) do
			if explosion.Position:Distance(chest.Position) < 80 then
				chest.SubType = mod.shopChestStates.Exploded
				sprite:Play("Destroyed", true)
				--Just slapping this code in as is from happy pack
				local keeper = Isaac.Spawn(EntityType.ENTITY_SHOPKEEPER, 0, 0, chest.Position, nilvector, nil)
				keeper.Visible = false
				keeper:TakeDamage(999, 0, EntityRef(explosion), 0)
				keeper:Update()
			end
		end
	end

	if sprite:IsPlaying("Close") and sprite:GetFrame() == 21 then
		chest.SubType = mod.shopChestStates.DoneLeaving
		local rng = chest:GetDropRNG()
		if rng:RandomInt(10) <= 7 then
			Isaac.Spawn(5, 0, 0, chest.Position, RandomVector(), nil)
		end
	end
	if sprite:IsFinished("Close") then
		chest:Remove()
	end

	if gd.Position and chest.SubType ~= mod.shopChestStates.Exploded then
		chest.Velocity = (gd.Position - chest.Position)
	end
end, 711)