local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()
local roomslist = StageAPI.RoomsList("TooManyOptionsRooms", require("resources.luarooms.toomanyoptions"))

local TMOTypes = {
	{RoomType.ROOM_TREASURE, 0.5},
	{RoomType.ROOM_SHOP, 1},
	{RoomType.ROOM_DICE, 1},
	{RoomType.ROOM_LIBRARY, 0.1},
	{RoomType.ROOM_CHEST, 1},
	{RoomType.ROOM_CURSE, 0.5},
	{RoomType.ROOM_ARCADE, 0.5},
	{RoomType.ROOM_SACRIFICE, 0.5},
	{RoomType.ROOM_PLANETARIUM, 0.05},
	{RoomType.ROOM_ANGEL, 0.07},
	{RoomType.ROOM_DEVIL, 0.1},
	{RoomType.ROOM_ERROR, 0.01},
	{RoomType.ROOM_ISAACS, 0.07},
	--{RoomType.ROOM_BOSSRUSH, 10}, --BREAK IN CASE OF EMERGENCY
}

local TypeToSpritesheet = {
	[RoomType.ROOM_TREASURE] = "gfx/grid/toomanyoptions/grid_tmotreasuredoor.png",
	[RoomType.ROOM_SHOP] = "gfx/grid/toomanyoptions/grid_tmoshopdoor.png",
	[RoomType.ROOM_DICE] = "gfx/grid/toomanyoptions/grid_tmodicedoor.png",
	[RoomType.ROOM_LIBRARY] = "gfx/grid/toomanyoptions/grid_tmolibrarydoor.png",
	[RoomType.ROOM_CHEST] = "gfx/grid/toomanyoptions/grid_tmovaultdoor.png",
	[RoomType.ROOM_DEVIL] = "gfx/grid/toomanyoptions/grid_tmodevildoor.png",
	[RoomType.ROOM_CURSE] = "gfx/grid/toomanyoptions/grid_tmocursedoor.png",
	[RoomType.ROOM_ARCADE] = "gfx/grid/toomanyoptions/grid_tmoarcadedoor.png",
	[RoomType.ROOM_SACRIFICE] = "gfx/grid/toomanyoptions/grid_tmosacrificedoor.png",
	[RoomType.ROOM_PLANETARIUM] = "gfx/grid/toomanyoptions/grid_tmoplanetariumdoor.png",
	[RoomType.ROOM_ANGEL] = "gfx/grid/toomanyoptions/grid_tmoangeldoor.png",
	[RoomType.ROOM_ERROR] = "gfx/grid/toomanyoptions/grid_tmoerrordoor.png",
	[RoomType.ROOM_ISAACS] = "gfx/grid/toomanyoptions/grid_tmobedroomdoor.png",
	[RoomType.ROOM_BARREN] = "gfx/grid/toomanyoptions/grid_tmobedroomdoor.png",
	--[RoomType.ROOM_BOSSRUSH] = "gfx/grid/toomanyoptions/grid_tmobasedoor.png",
}

local shopval = 0 
local gettingshopcollectible = false

function mod:CheckDoorForUnlock(door) --Check doors, thanks Guwah
    local sprite = door:GetSprite()
    if sprite:GetFrame() == 0 or door.ExtraSprite:GetFrame() == 0 then --EXTRA SPRITE INSTEAD OF OVERLAY WHY?!?!?
        local anim = sprite:GetAnimation() 
        local anim2 = door.ExtraSprite:GetAnimation()
        if anim == "KeyOpen" --List of possible key opening anims
        or anim == "GoldenKeyOpen"
		or anim == "CoinOpen"
        or anim2 == "KeyOpenChain1"
        or anim2 == "KeyOpenChain2"
        or anim2 == "GoldenKeyOpenChain1"
        or anim2 == "GoldenKeyOpenChain2" 
		or anim2 == "Damaged" 
        then
            return true
        end
    end
end

local function MakeDoorTMO(door, typ)
	local sprite = door:GetSprite()
	local extrasprite = door.ExtraSprite
	local roomdesc = game:GetLevel():GetCurrentRoomDesc()
	for i = 0, 4 do
		sprite:ReplaceSpritesheet(i, TypeToSpritesheet[typ])
	end
	if extrasprite:GetFilename() == "gfx/grid/door_16_doublelock.anm2" then
		for i = 1, 2 do
			extrasprite:ReplaceSpritesheet(i, "gfx/grid/toomanyoptions/tmodoublelock.png")
		end
	end
	if extrasprite:GetFilename() == "gfx/grid/door_18_crackeddoor.anm2" then
		extrasprite:ReplaceSpritesheet(0, "gfx/grid/toomanyoptions/tmocrackeddoor.png")
	end
	if game:GetLevel():GetRoomByIdx(door.TargetRoomIndex).Data.Type == RoomType.ROOM_CURSE or roomdesc.Data.Type == RoomType.ROOM_CURSE then
		sprite:ReplaceSpritesheet(0, "gfx/grid/toomanyoptions/tmocursebg.png")
	end
	if game:GetLevel():GetRoomByIdx(door.TargetRoomIndex).Data.Type == RoomType.ROOM_ARCADE or roomdesc.Data.Type == RoomType.ROOM_ARCADE then
		sprite:ReplaceSpritesheet(1, "gfx/grid/toomanyoptions/tmocoinslot.png")
		sprite:ReplaceSpritesheet(2, "gfx/grid/toomanyoptions/tmocoinslot.png")
		sprite:ReplaceSpritesheet(4, "gfx/grid/toomanyoptions/tmocoinslot.png")
		sprite:ReplaceSpritesheet(5, "gfx/nothing.png")
	end
	if #mod:GetPlayersHoldingCollectible(CollectibleType.COLLECTIBLE_PAY_TO_PLAY) > 0 then
		sprite:ReplaceSpritesheet(1, "gfx/grid/toomanyoptions/tmocoinslot.png")
		sprite:ReplaceSpritesheet(2, "gfx/grid/toomanyoptions/tmocoinslot.png")
		sprite:ReplaceSpritesheet(4, "gfx/grid/toomanyoptions/tmocoinslot.png")
	end
	extrasprite:LoadGraphics()
	door.ExtraSprite = extrasprite
	sprite:LoadGraphics()
end

function SetShopVal()
	if game.Difficulty == Difficulty.DIFFICULTY_NORMAL then
		local ranfloat = rng:RandomFloat()
		if ranfloat > 0.9 then
			shopval = 4
		else
			shopval = 3
		end
	else
		local ranfloat = rng:RandomFloat()
		if ranfloat > 0.9 then
			shopval = 4
		else
			shopval = mod:RandomInt(0, 3)
		end
	end
end

function PickTMORoom(roomdesc, typ)
	if typ == RoomType.ROOM_SHOP then
		SetShopVal()
	end
	return StageAPI.LevelRoom{
		RoomType = typ,
		RequireRoomType = true,
		RoomsList = roomslist,
		RoomDescriptor = roomdesc
	}
end

StageAPI.AddCallback("FiendFolio", "POST_CHECK_VALID_ROOM", 1, function(layout, roomsList)
    if roomsList.Name == "TooManyOptionsRooms" then
        local sub = layout.SubType
		local typ = layout.Type
		
		if typ == RoomType.ROOM_ARCADE and mod:IsPlayerWithCollectibleOfType(CollectibleType.COLLECTIBLE_BIRTHRIGHT, PlayerType.PLAYER_CAIN) then
			return sub == 1
		end
		if typ == RoomType.ROOM_CURSE and mod:IsPlayerWithCollectible(CollectibleType.COLLECTIBLE_VOODOO_HEAD) then
			return sub == 1
		end
		if typ == RoomType.ROOM_TREASURE then
			local newsub = 0
			local shouldbrokenglasses = true
			if mod:IsPlayerWithCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS) then
				newsub = newsub + 1
				shouldbrokenglasses = false
			end
			if mod:IsPlayerWithTrinket(TrinketType.TRINKET_PAY_TO_WIN) then
				newsub = newsub + 2
			end
			if (game:GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE or game:GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE_B) then
				newsub = newsub + 100
				shouldbrokenglasses = false
			end
			if shouldbrokenglasses and mod:IsPlayerWithTrinket(TrinketType.TRINKET_BROKEN_GLASSES) then
				newsub = newsub + mod:RandomInt(0, 1)
			end
			return sub == newsub
		end
		if typ == RoomType.ROOM_SHOP then
			local newsub = 0
			if mod:IsPlayerOfType(PlayerType.PLAYER_KEEPER_B) or (TaintedCollectibles and mod:IsPlayerWithCollectible(TaintedCollectibles.OVERSTOCK)) then
				newsub = newsub + 100
			end
			newsub = newsub + shopval
			return sub == newsub
		end
		if typ == RoomType.ROOM_DEVIL and mod:IsPlayerWithTrinket(TrinketType.TRINKET_NUMBER_MAGNET) then
			return sub == 1
		end
		
		return sub == 0
    end
end)

function mod:TMOLogic()
	local room = game:GetRoom()
	FiendFolio.savedata.run.level.TooManyOptions = FiendFolio.savedata.run.level.TooManyOptions or {}
	local savedata = FiendFolio.savedata.run.level.TooManyOptions
	
	for i = 0, DoorSlot.NUM_DOOR_SLOTS do
		local door = room:GetDoor(i)
		if door and TypeToSpritesheet[door.TargetRoomType] then
			local roomdesc = game:GetLevel():GetRoomByIdx(door.TargetRoomIndex)
			
			if roomdesc.Data and (roomdesc.Data.Shape == RoomShape.ROOMSHAPE_1x1 or roomdesc.Data.Shape == RoomShape.ROOMSHAPE_IH or roomdesc.Data.Shape == RoomShape.ROOMSHAPE_IV) then
				local sprite = door:GetSprite()
				savedata[door.TargetRoomIndex] = savedata[door.TargetRoomIndex] or {}
				local doordata = savedata[door.TargetRoomIndex]
				
				if roomdesc.VisitedCount > 0 and not doordata.LockedIn then
					doordata.LockedIn = true
					doordata.RoomType = roomdesc.Data.Type
				end
				
				if not doordata.RoomTypes then
					doordata.RoomTypes = {}
					--[[if game:GetLevel():GetCurrentRoomDesc().Data.Type ~= RoomType.ROOM_SECRET then
						door:SetLocked(true)
					end]]
					local typescopy = StageAPI.DeepCopy(TMOTypes)
					if game:IsGreedMode() then
						for i, entry in pairs(typescopy) do
							if entry[1] == RoomType.ROOM_SHOP then
								table.remove(typescopy, i)
							end
						end
					end
					for i = 1, 2 + mod:GetTotalCollectibleNum(mod.ITEM.COLLECTIBLE.TOO_MANY_OPTIONS) do
						if #typescopy == 0 then
							break
						end
						local entry, index = StageAPI.WeightedRNG(typescopy)
						if entry == RoomType.ROOM_ISAACS then
							entry = entry + mod:RandomInt(0, 1)
						end
						table.insert(doordata.RoomTypes, entry)
						table.remove(typescopy, index)
					end
				end
				
				doordata.RoomType = doordata.RoomType or doordata.RoomTypes[1]
				doordata.CycleCount = doordata.CycleCount or 1
				
				if ((mod:CheckDoorForUnlock(door) and not (game:GetLevel():GetCurrentRoomDesc().Flags & RoomDescriptor.FLAG_RED_ROOM > 0)) or mod:GetClosest(door.Position, mod:GetAllPlayers()).Position:Distance(door.Position) < 10) and not doordata.LockedIn then
					doordata.LockedIn = true
					local newdata = StageAPI.GetGotoDataForTypeShape(doordata.RoomType, roomdesc.Data.Shape)
					local dimension = 0
					
					if roomdesc.Data.Type == RoomType.ROOM_DEVIL or roomdesc.Data.Type == RoomType.ROOM_ANGEL then
						dimension = -2
					end
					
					roomdesc.Data = newdata
					local levelroom = PickTMORoom(roomdesc, doordata.RoomType)
					StageAPI.SetLevelRoom(levelroom, roomdesc.ListIndex, dimension)
				end
				
				if not doordata.LockedIn and game:GetFrameCount() % math.max(11 - mod:GetTotalCollectibleNum(mod.ITEM.COLLECTIBLE.TOO_MANY_OPTIONS), 1)  == 0 then
					if doordata.RoomTypes[doordata.CycleCount + 1] then
						doordata.CycleCount = doordata.CycleCount + 1
						doordata.RoomType = doordata.RoomTypes[doordata.CycleCount]
					else
						doordata.CycleCount = 1
						doordata.RoomType = doordata.RoomTypes[1]
					end
				end
				
				if sprite:GetAnimation() ~= "KeyOpen" and game:GetLevel():GetCurrentRoomDesc().Data.Type ~= RoomType.ROOM_SECRET and not (mod:GetClosest(door.Position, mod:GetAllPlayers()).Position:Distance(door.Position) < 10) then
					MakeDoorTMO(door, doordata.RoomType)
				end
			end
			
		end
		if door and savedata[game:GetLevel():GetCurrentRoomIndex()] then
			local roomdesc = game:GetLevel():GetCurrentRoomDesc()
			local sprite = door:GetSprite()
			
			if door.TargetRoomType ~= RoomType.ROOM_SECRET and not TypeToSpritesheet[door.TargetRoomType] then
				MakeDoorTMO(door, roomdesc.Data.Type)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_)
	if mod:IsPlayerWithCollectible(mod.ITEM.COLLECTIBLE.TOO_MANY_OPTIONS) and FiendFolio.savedata.run.level and not game:GetRoom():IsMirrorWorld() then
		mod:TMOLogic()
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
	if mod:IsPlayerWithCollectible(mod.ITEM.COLLECTIBLE.TOO_MANY_OPTIONS) and FiendFolio.savedata.run.level and not game:GetRoom():IsMirrorWorld() then
		local room = game:GetRoom()
		local level = game:GetLevel()
		FiendFolio.savedata.run.level.TooManyOptions = FiendFolio.savedata.run.level.TooManyOptions or {}
		local savedata = FiendFolio.savedata.run.level.TooManyOptions
		
		mod:TMOLogic()
		
		if savedata[level:GetCurrentRoomIndex()] and room:IsFirstVisit() then
			local roomdesc = level:GetCurrentRoomDesc()
			if roomdesc.Data.Type == RoomType.ROOM_DICE then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DICE_FLOOR, mod:RandomInt(0, 5), room:GetCenterPos(), Vector.Zero, nil)
			elseif roomdesc.Data.Type == RoomType.ROOM_DEVIL and mod:IsPlayerWithCollectible(CollectibleType.COLLECTIBLE_SANGUINE_BOND) then
				Isaac.GridSpawn(GridEntityType.GRID_SPIKES, 102, room:GetCenterPos())
			elseif roomdesc.Data.Type == RoomType.ROOM_TREASURE and Isaac.CountEntities(nil, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE) > 1 then
				for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
					local pickup = entity:ToPickup()
					pickup.OptionsPickupIndex = 1
					if (game:GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE or game:GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE_B) and i == 2 then
						if not (mod:IsPlayerWithTrinket(TrinketType.TRINKET_BROKEN_GLASSES) and mod:RandomInt(1,2) == 1) then
							local sprite = pickup:GetSprite()
							sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
							sprite:LoadGraphics()
						else
							local sprite = pickup:GetSprite()
							sprite:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(pickup.SubType).GfxFileName)
							sprite:LoadGraphics()
						end
					end
				end
			elseif roomdesc.Data.Type == RoomType.ROOM_ANGEL and Isaac.CountEntities(nil, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE) > 1 then
				for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
					local pickup = entity:ToPickup()
					pickup.OptionsPickupIndex = 1
				end
			elseif roomdesc.Data.Type == RoomType.ROOM_ISAACS or roomdesc.Data.Type == RoomType.ROOM_BARREN then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ISAACS_CARPET, 0, room:GetCenterPos(), Vector.Zero, nil)
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, function(_, pooltype, decrease, seed)
	if mod:IsPlayerWithCollectible(mod.ITEM.COLLECTIBLE.TOO_MANY_OPTIONS) and FiendFolio.savedata.run.level then
		local room = game:GetRoom()
		FiendFolio.savedata.run.level.TooManyOptions = FiendFolio.savedata.run.level.TooManyOptions or {}
		local savedata = FiendFolio.savedata.run.level.TooManyOptions
		
		if not gettingshopcollectible and savedata[game:GetLevel():GetCurrentRoomIndex()] and game:GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_SHOP and (mod:IsPlayerOfType(PlayerType.PLAYER_KEEPER_B) or (TaintedCollectibles and mod:IsPlayerWithCollectible(TaintedCollectibles.OVERSTOCK)))and pooltype == ItemPoolType.POOL_SHOP then
			gettingshopcollectible = true
			local itempool = game:GetItemPool()
			local ranint = mod:RandomInt(1, 3)
			local newcollectible
			
			if ranint == 1 then
				newcollectible = itempool:GetCollectible(ItemPoolType.POOL_SHOP, decrease, seed)
			elseif ranint == 2 then
				newcollectible = itempool:GetCollectible(ItemPoolType.POOL_TREASURE, decrease, seed)
			else
				newcollectible = itempool:GetCollectible(ItemPoolType.POOL_BOSS, decrease, seed)
			end
			
			gettingshopcollectible = false
			return newcollectible
		end
	end
end)