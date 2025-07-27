TaintedTreasure = RegisterMod("Tainted Treasure Rooms", 1)
local mod = TaintedTreasure
mod.RNG = RNG()
local rng = mod.RNG
local sfx = SFXManager()
local game = Game()
local json = require("json")

if mod:HasData() then
	mod.savedata = json.decode(mod:LoadData())
else
	mod.savedata = {}
end

function mod:GetSaveData()
    if not mod.savedata then
        if Isaac.HasModData(saveDataMod) then
            mod.savedata = json.decode(mod:LoadData())
        else
            mod.savedata = {}
        end
    end

    return mod.savedata
end

local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("scripts."..v)
    end
end

local modscripts = {
	"constants",

	"meta.callbacks.main",
	"meta.callbacks.usekey",
	"meta.callbacks.firetear",
	"meta.callbacks.firebomb",
	"meta.callbacks.firerocket", --Epic Fetus
	"meta.callbacks.firecreep", --Aquarius
	"meta.callbacks.fireknife", 
	"meta.callbacks.firelaser", 
	"meta.callbacks.gaincollectible",
	
	"effects",
	"roomgen",
	"statcache",
	"teareffects",
	"wispitems",
	"wallmovement",
	"challenges",
	"dssmenumanager",
	"api",
	
	"items.arrowhead",
	"items.atginajar",
	"items.atlas",
	"items.badonion",
	"items.basilisk",
	"items.bluecanary",
	"items.broodmind",
	"items.bugulonsuperfan",
	"items.buzzingmagnets",
	"items.coloredcontacts",
	"items.consecration",
	"items.crystalskull",
	"items.dpad",
	"items.dryadsblessing",
	"items.eternalcandle",
	"items.evangelism",
	"items.forkbender",
	"items.gazemaster",
	"items.gladbombs",
	"items.leviathan",
	"items.lilabyss",
	"items.lilslugger",
	"items.maelstrom",
	"items.nooptions",
	"items.overchargedbattery",
	"items.overstock",
	"items.poisoneddart",
	"items.polycoria",
	"items.ravenous",
	"items.rawsoylent",
	"items.reaper",
	"items.saltofmagnesium",
	"items.searedclub",
	"items.skeletonlock",
	"items.sorrowfulshallot",
	"items.sword",
	"items.techorganelle",
	"items.thebottle",
	"items.warmaiden",
	"items.whitebelt",
	"items.whoreofgalilee",
	"items.wormwood",
	
	"items.contract.bluebaby",
	"items.contract.judas",
	"items.contract.azazelb",
	"items.contract.bethany",
	"items.contract.bluebabyb",
	"items.contract.lilith",
	"items.contract.maggy",
	"items.contract.samson",
	"items.contract.forgotten",
	"items.contract.cainb",


	"trinkets.purplestar",

	"machines.taintedbeggar",

	"statuseffects",
}

LoadScripts(modscripts)

if StageAPI then
	mod.luarooms = {}
	mod.luarooms.TT = StageAPI.RoomsList("TaintedTreasureRooms", require("resources.luarooms.taintedtreasureluarooms"))
end


function mod.GetPersistentPlayerData(player) --From Retribution, by Xalum
	if mod.savedata and mod.savedata.persistentPlayerData then
		local seedReference = CollectibleType.COLLECTIBLE_SAD_ONION
		local playerType = player:GetPlayerType()

		if playerType == PlayerType.PLAYER_LAZARUS2_B then
			seedReference = CollectibleType.COLLECTIBLE_INNER_EYE
		elseif playerType ~= PlayerType.PLAYER_ESAU then
			player = player:GetMainTwin()
		end

		local tableIndex = player:GetCollectibleRNG(seedReference):GetSeed()
		tableIndex = tostring(tableIndex)

		mod.savedata.persistentPlayerData[tableIndex] = mod.savedata.persistentPlayerData[tableIndex] or {}
		return mod.savedata.persistentPlayerData[tableIndex]
	else
		return {}
	end
end

function mod:GetAllPlayers()
	local players = {}
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i)
		if player:Exists() then
			table.insert(players, player)
		end
	end
	return players
end

function mod:GetPlayersHoldingCollectible(collectible)
	local players = {}
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:HasCollectible(collectible) then
			table.insert(players, player)
		end
	end
	if players[1] then
		return players
	else
		return nil
	end
end

function mod:IsPlayerDying(player)
	return player:GetSprite():GetAnimation():sub(-#"Death") == "Death" --does their current animation end with "Death"?
end

function mod:isSuperpositionedPlayer(player)
	if player then
		local playertype = player:GetPlayerType()
		if playertype == PlayerType.PLAYER_LAZARUS_B or playertype == PlayerType.PLAYER_LAZARUS2_B then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) or
			   (player:GetOtherTwin() and player:GetOtherTwin():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))
			then
				local maintwin = player:GetMainTwin()
				if maintwin.Index ~= player.Index or maintwin.InitSeed ~= player.InitSeed then
					return true
				end
			end
		end
	end
	return false
end

function mod:isSirenCharmed(familiar)
	local helpers = Isaac.FindByType(EntityType.ENTITY_SIREN_HELPER, -1, -1, true)
	for _, helper in ipairs(helpers) do
		if helper.Target and helper.Target.Index == familiar.Index and helper.Target.InitSeed == familiar.InitSeed then
			return true, helper
		end
	end
	return false, nil
end

function mod:GetTotalCollectibleNum(collectible)
	local num = 0
	local players = mod:GetPlayersHoldingCollectible(collectible)
	if players then
		for _, player in pairs(players) do
			num = num + player:GetCollectibleNum(collectible)
		end
	end
	return num
end


function mod:GetPlayersHoldingTrinket(trinket)
	local players = {}
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:HasTrinket(trinket) then
			table.insert(players, player)
		end
	end
	if players[1] then
		return players
	else
		return nil
	end
end

function mod:GetTotalTrinketMult(trinket)
	local num = 0
	local players = mod:GetPlayersHoldingTrinket(trinket)
	if players then
		for _, player in pairs(players) do
			num = num + player:GetTrinketMultiplier(trinket)
		end
	end
	return num
end

function mod:IsGridWalkable(position, hasflight)
	local room = game:GetRoom()
	local grid = room:GetGridEntityFromPos(position)
	local isgridvalid = false
	if grid then
		if hasflight and grid.CollisionClass < 4 then
			isgridvalid = true
		elseif grid.CollisionClass < 1 then
			isgridvalid = true
		end
	else
		isgridvalid = true
	end
	return isgridvalid
end

local function runUpdates(tab) --This is from Fiend Folio
    for i = #tab, 1, -1 do
        local f = tab[i]
        f.Delay = f.Delay - 1
        if f.Delay <= 0 then
            f.Func()
            table.remove(tab, i)
        end
    end
end

mod.delayedFuncs = {}
function mod:scheduleForUpdate(foo, delay, callback)
    callback = callback or ModCallbacks.MC_POST_UPDATE
    if not mod.delayedFuncs[callback] then
        mod.delayedFuncs[callback] = {}
        mod:AddCallback(callback, function()
            runUpdates(mod.delayedFuncs[callback])
        end)
    end

    table.insert(mod.delayedFuncs[callback], { Func = foo, Delay = delay })
end

if MinimapAPI then
	local ttsprite = Sprite()
	ttsprite:Load("gfx/ui/minimapapi/taintedtreasureicon.anm2", true)
	ttsprite:SetFrame("CustomIconTaintedTreasureRoom", 0)
	MinimapAPI:AddIcon("TaintedTreasureRoom", ttsprite)
	
	local overstocksprite = Sprite()
	overstocksprite:Load("gfx/ui/minimapapi/overstockicon.anm2", true)
	MinimapAPI:AddMapFlag("Overstock", function() return TaintedTreasure:GetPlayersHoldingCollectible(TaintedCollectibles.OVERSTOCK) end, overstocksprite, "CustomIconOverstock", 0)
end
mod.minimaprooms = {} --Stores rooms that need to be updated on MinimapAPI

function mod:RandomInt(min, max, customRNG) --This and GetRandomElem were written by Guwahavel (hi)
    local rand = customRNG or rng
    if not max then
        max = min
        min = 0
    end  
    if min > max then 
        local temp = min
        min = max
        max = temp
    end
    return min + (rand:RandomInt(max - min + 1))
end

function mod:GetRandomElem(table, customRNG)
    if table and #table > 0 then
		local index = mod:RandomInt(1, #table, customRNG)
        return table[index], index
    end
end

function mod:GetAngleDifference(a1, a2)
    local sub = a1 - a2
    return (sub + 180) % 360 - 180
end

function mod:CappedVector(vector, length)
	if vector:Length() > length then
		return vector:Resized(length)
	end
	return vector
end

function mod:BoolToNumber(bool)
	if bool then
		return 1
	end
	return 0
end

function mod:GetConditionValue(obj)
	if type(obj) == "function" then
		return obj()
	end
	if type(obj) == "string" and mod[obj] and type(mod[obj]) == "function" then
		return mod[obj]()
	end
	return obj
end

function mod:PrintEntityId(entity)
    print(entity.Type.." "..entity.Variant.." "..entity.SubType)
end

function mod:PrintColor(color)
    print(color.R.." "..color.G.." "..color.B.." "..color.A.." "..color.RO.." "..color.GO.." "..color.BO)
end

function mod:PrintTable(table)
    for index, entry in pairs(table) do
        print(index.." "..entry)
    end
end

function mod:FlipSprite(sprite, pos1, pos2)
    if pos1.X > pos2.X then
        sprite.FlipX = true
    else
        sprite.FlipX = false
    end
end

local altPathItemChecked = {}
local questionMarkSprite = Sprite()
questionMarkSprite:Load("gfx/005.100_collectible.anm2",true)
questionMarkSprite:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
questionMarkSprite:LoadGraphics()
function mod:IsAltChoice(pickup) --From EID
	-- do not run this while Curse of the Blind is active, since this function is really just a "is collectible pedestal a red question mark" check
	if mod:HasCurse(LevelCurse.CURSE_OF_BLIND) or not REPENTANCE then
		return false
	end
	if altPathItemChecked[pickup.InitSeed] ~= nil then
		return altPathItemChecked[pickup.InitSeed]
	end
	if game:GetRoom():GetType() ~= RoomType.ROOM_TREASURE then
		altPathItemChecked[pickup.InitSeed] = false
		return false
	end

	local entitySprite = pickup:GetSprite()
	local name = entitySprite:GetAnimation()

	if name ~= "Idle" and name ~= "ShopIdle" then
		-- Collectible can be ignored. It's definitely not hidden
		altPathItemChecked[pickup.InitSeed] = false
		return false
	end
	
	questionMarkSprite:SetFrame(name,entitySprite:GetFrame())
	-- Quickly check some points in entitySprite to not need to check the whole sprite
	-- We check the range from Y -40 to 10 in 3 pixel steps and also X -1 to 1.  GetTexel() gets the color value of a sprite at a given location. the center of the sprite is here in the Pivot point of the sprite in the anm2 file. 
	-- therefore we go negative 40 pixels up to read the sprite as it is on a pedestal. We also look 10 pixel down to make comparing shop items more accurate
	
	for i = -1,1,1 do
		for j = -40,10,3 do
			local qcolor = questionMarkSprite:GetTexel(Vector(i,j),Vector.Zero,1,1)
			local ecolor = entitySprite:GetTexel(Vector(i,j),Vector.Zero,1,1)
			if qcolor.Red ~= ecolor.Red or qcolor.Green ~= ecolor.Green or qcolor.Blue ~= ecolor.Blue then
				-- it is not same with question mark sprite
				altPathItemChecked[pickup.InitSeed] = false
				return false
			end
		end
	end

	altPathItemChecked[pickup.InitSeed] = true
	return true
end

--ProAPI classic
function mod:Lerp(first, second, percent, smoothIn, smoothOut)
    if smoothIn then
        percent = percent ^ smoothIn
    end

    if smoothOut then
        percent = 1 - percent
        percent = percent ^ smoothOut
        percent = 1 - percent
    end

	return (first + (second - first)*percent)
end

function mod:LerpAngleDegrees(aStart, aEnd, percent)
    return aStart + mod:GetAngleDifference(aEnd, aStart) * percent
end

function mod:Sway(back, forth, interval, smoothIn, smoothOut, frameCnt)
    local time = (frameCnt or game:GetFrameCount()) % interval
    local halfInterval = interval / 2
    if time < halfInterval then
        return mod:Lerp(back, forth, time / halfInterval, smoothIn, smoothOut)
    else
        return mod:Lerp(forth, back, (time - halfInterval) / halfInterval, smoothIn, smoothOut)
    end
end

function mod:Shuffle(tbl)
	for i = #tbl, 2, -1 do
    local j = mod:RandomInt(1, i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function mod:isCollectibleUnlocked(collectibleID, itemPoolOfItem) --by Wofsauge, slightly modified
    local itemPool = Game():GetItemPool()
    local itemConfig = Isaac.GetItemConfig()
    for i= 1, itemConfig:GetCollectibles().Size - 1 do
        if ItemConfig.Config.IsValidCollectible(i) and i ~= collectibleID then
            itemPool:AddRoomBlacklist(i)
		end
    end
    local room = Game():GetRoom()
    local isUnlocked = false
    for i = 0,50 do -- some samples to make sure
        local collID = itemPool:GetCollectible(itemPoolOfItem, false)
        if collID == collectibleID then
            isUnlocked = true
            break
        end
    end
    itemPool:ResetRoomBlacklist()
    return isUnlocked
end

function mod:IsRoomDescTainted(roomdesc)
	if roomdesc and roomdesc.Data and roomdesc.Data.Type == RoomType.ROOM_DICE then
		if (roomdesc.Data.Variant >= 12000 and roomdesc.Data.Variant <= mod.maxvariant) or mod.savedata.TaintedLuarooms[roomdesc.GridIndex] then
			return true
		end
	end
	return false
end

function mod:UpdateTaintedItems()
	local level = game:GetLevel()
	if mod:IsRoomDescTainted(level:GetCurrentRoomDesc()) then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == TaintedEffects.ITEM_GHOST then
				entity:Remove()
			elseif entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
				local effect = false
				for j, set in pairs(mod.savedata.taintedsets) do
					if set[2] == entity.SubType and mod:GetPlayersHoldingCollectible(set[1]) and not effect then
						effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.ITEM_GHOST, 0, entity.Position+Vector(0, -80), Vector.Zero, entity)
						if level:GetCurses() & LevelCurse.CURSE_OF_BLIND > 0 then
							effect:GetSprite():ReplaceSpritesheet(0, "gfx/items/collectibles/questionmark.png")
						else
							effect:GetSprite():ReplaceSpritesheet(0, Isaac.GetItemConfig():GetCollectible(set[1]).GfxFileName)
						end
						effect:GetSprite():LoadGraphics()
						effect.DepthOffset = 1000
						effect:GetData().CollectibleType = set[1]
						
						set[3] = true --Prevents the item from appearing again
					end
				end
			end
		end
	end
end

function mod:ShouldBlacklistContract()
	local players = mod:GetAllPlayers()
	for i, player in pairs(players) do
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			if not mod.ContractEffects[player:GetPlayerType()] then
				return true
			end
		end
	end
	return false
end

function mod:CheckTaintedPool()
	local itemconfig = Isaac.GetItemConfig()
	for i, entry in pairs(mod.savedata.taintedsets) do
		print(itemconfig:GetCollectible(entry[1]).Name, itemconfig:GetCollectible(entry[2]).Name, entry[3])
	end
end

function mod:MakeDoorTainted(door)
	local doorSprite = door:GetSprite()
	local iscustomstage
	
	if StageAPI then
		iscustomstage = StageAPI.InOverriddenStage()
	end
	
	--if not iscustomstage then
		doorSprite:Load("gfx/grid/taintedtreasureroomdoor.anm2", true)
		doorSprite:ReplaceSpritesheet(0, "gfx/grid/taintedtreasureroomdoor.png")
	--end
	doorSprite:LoadGraphics()
	doorSprite:Play("Closed")
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, iscontinued)
	if not iscontinued then
		local taintedbeggarQ4chance = 1
		local itemconfig = Isaac:GetItemConfig()
		rng:SetSeed(Game():GetSeeds():GetStartSeed(), 35)
		mod.savedata.TaintedBeggarPool = {}
		mod.savedata.persistentPlayerData = {}
		mod.savedata.TaintedLuarooms = {}
		mod.savedata.spawnchancemultiplier = 1
		
		for _, items in pairs(mod.startingtaintedsets) do
			local item = items[1]
			local isQ4 = itemconfig:GetCollectible(item).Quality == 4
			if (not isQ4 or rng:RandomFloat() < taintedbeggarQ4chance) and not mod.TaintedBeggarBlacklist[item] then
				table.insert(mod.savedata.TaintedBeggarPool, item)
				if isQ4 then
					taintedbeggarQ4chance = taintedbeggarQ4chance*rng:RandomFloat()
				end
			end
		end
		
		mod.savedata.taintedsets = {}
		for i, entry in pairs(mod.startingtaintedsets) do
			table.insert(mod.savedata.taintedsets, entry)
		end
		table.insert(mod.savedata.taintedsets, {CollectibleType.COLLECTIBLE_BIRTHRIGHT, TaintedCollectibles.CONTRACT_OF_SERVITUDE, "ShouldBlacklistContract"})
		
		if mod:isCollectibleUnlocked(CollectibleType.COLLECTIBLE_RED_KEY, ItemPoolType.POOL_SECRET) and Isaac.GetChallenge() == 0 then
			table.insert(mod.savedata.taintedsets, {CollectibleType.COLLECTIBLE_POLAROID, TaintedCollectibles.FINALE})
			table.insert(mod.savedata.taintedsets, {CollectibleType.COLLECTIBLE_NEGATIVE, TaintedCollectibles.FINALE})
		end
		table.insert(mod.savedata.TaintedBeggarPool, CollectibleType.COLLECTIBLE_DAMOCLES)
	
		mod.taintedpoolloaded = true
		
		mod:SaveData(json.encode(mod.savedata))
	end

	if mod:HasData() then
		mod.savedata = json.decode(mod:LoadData())
	else
		mod.savedata = {}
	end
	
	if iscontinued and not BasementRenovator and not mod.roomdata and not mod.luarooms then
		mod:scheduleForUpdate(function()
			mod.roomdata = {}
			mod:InitializeRoomData("dice", 12000, mod.maxvariant, mod.roomdata)
		end, 0, ModCallbacks.MC_POST_RENDER)
	end
	
	
	if tmmc and not tmmc.enable[TaintedMachines.TAINTED_BEGGAR] then --TimeMachine mod compatibility
		tmmc.enable[TaintedMachines.TAINTED_BEGGAR] = true
	end
	
	rng:SetSeed(Game():GetSeeds():GetStartSeed(), 35)
end)

function mod:OnNewLevel()
	local level = game:GetLevel()
	mod.savedata.spawnchancemultiplier = mod.savedata.spawnchancemultiplier or 1
	mod.savedata.TaintedLuarooms = {}
	mod.DoneFullMapping = 0
	mod.SecretRoomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_SECRET, false, rng)
	mod.TreasureRoomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_TREASURE, false, rng)
	mod.BossRoomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_BOSS, false, rng)
	mod.SecretRoomVisited = false
	mod.TreasureRoomVisited = false
	mod.BossRoomVisited = false
	altPathItemChecked = {}
	
	
	
	--Handles Tainted Room spawning
	if not mod.roomdata and level:GetStage() ~= LevelStage.STAGE1_1 and not BasementRenovator and (not StageAPI or not StageAPI.InOverriddenStage()) and not mod.luarooms then
		mod.roomdata = {}
		mod:InitializeRoomData("dice", 12000, mod.maxvariant, mod.roomdata)
	end
	
	local spawnchance = 0
	local stagelimit = mod:GetTaintedTreasureRoomThreshold()
	if level:GetStage() ~= LevelStage.STAGE1_1 and level:GetStage() < stagelimit and not level:IsAscent() and Isaac.GetChallenge() == 0 and (not StageAPI or not StageAPI.InOverriddenStage()) then
		for _, player in pairs(mod:GetAllPlayers()) do
			for j, entry in pairs(mod.savedata.taintedsets) do
				if player:HasCollectible(entry[1], true) and not mod:GetConditionValue(entry[3]) then
					spawnchance = spawnchance + (0.2 * (1 + mod:GetTotalTrinketMult(TaintedTrinkets.PURPLE_STAR)))
				end
			end
		end
	end
	
	local totalchance = mod.savedata.spawnchancemultiplier*spawnchance
	local newchance = Isaac.RunCallback("POST_TAINTED_ROOM_CHANCE", totalchance)
	totalchance = newchance or totalchance

	--print(totalchance)
	if totalchance > 0 then
		if rng:RandomFloat() <= totalchance then
			if not game:IsGreedMode() then
				if not mod.luarooms then
					local newroomdesc = mod:GenerateRoomFromDataset(mod.roomdata, true)
				else
					local newroomdesc = mod:GenerateRoomFromLuarooms(mod.luarooms.TT, true)
					if newroomdesc then
						mod.savedata.TaintedLuarooms = mod.savedata.TaintedLuarooms or {}
						mod.savedata.TaintedLuarooms[newroomdesc.GridIndex] = true
					end
				end
			else
				local treasureroomidx = mod:GetRandomElem({98, 85}) --Silver, gold
				local currentroomidx = level:GetCurrentRoomIndex()
				if level:GetRoomByIdx(99).GridIndex == -1 and level:GetRoomByIdx(86).GridIndex == -1 then
					for i, player in pairs(mod:GetAllPlayers()) do
						player:GetData().ResetPosition = player.Position
					end
					Isaac.ExecuteCommand("goto s.dice."..mod:RandomInt(12000, mod.maxvariant))
					local data = level:GetRoomByIdx(-3,0).Data
					game:StartRoomTransition(currentroomidx, 0, RoomTransitionAnim.FADE)
					local levelstage = level:GetStage()
					local stagetype = level:GetStageType()
					level:SetStage(7, 0)
					if level:MakeRedRoomDoor(treasureroomidx, DoorSlot.RIGHT0) then
						local newroomdesc = level:GetRoomByIdx(treasureroomidx+1,0)
						newroomdesc.Data = data
						newroomdesc.Flags = 0
						table.insert(mod.minimaprooms, newroomdesc.GridIndex)
					end
					level:SetStage(levelstage, stagetype)
					mod:scheduleForUpdate(function()
						for i, player in pairs(mod:GetAllPlayers()) do
							player.Position = player:GetData().ResetPosition
						end
					end, 0)
					mod.savedata.spawnchancemultiplier = 0.5
				end
			end
		elseif mod.savedata.spawnchancemultiplier < 3 then
			mod.savedata.spawnchancemultiplier = mod.savedata.spawnchancemultiplier + 0.5
		end
	end

	if mod:HasCurse(LevelCurse.CURSE_OF_LABYRINTH) and mod:GetPlayersHoldingCollectible(TaintedCollectibles.ETERNAL_CANDLE) then
		mod:GenerateSpecialRoom("shop", 1, 4, true) --Room IDs have to be hard coded, IDs 1 through 4 are pretty average and balanced Shop layouts
	end
	
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.ATLAS) and not level:GetStage() ~= LevelStage.STAGE8 then
		mod:AtlasFloorLogic()
	end
	
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.OVERSTOCK) and (not StageAPI or not StageAPI.InOverriddenStage()) then
		mod:OverstockFloorLogic()
	end
	
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.GAZEMASTER) and (not StageAPI or not StageAPI.InOverriddenStage()) then
		mod:GazemasterFloorLogic()
	end
	
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.WORMWOOD) then
		for i, player in pairs(mod:GetPlayersHoldingCollectible(TaintedCollectibles.WORMWOOD)) do
			local savedata = mod.GetPersistentPlayerData(player)
			savedata.WormwoodStatus = 0
		end
	end
	
	if Isaac.GetChallenge() == TaintedChallenges.ART_OF_WAR then
		mod:ArtOfWarFloorLogic()
	end
	mod:SaveData(json.encode(mod.savedata))
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.OnNewLevel)

local warpplayer = false --used for Clandestine Card
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_) --Andromeda was used as the reference for managing new room types
	local level = game:GetLevel()
	local roomidx = level:GetCurrentRoomIndex()
	local roomdesc = level:GetCurrentRoomDesc()
	local roomdata = roomdesc.Data
	local room = game:GetRoom()
	local roomtype = room:GetType()

	if roomtype == RoomType.ROOM_SECRET then
		if roomidx == mod.SecretRoomIndex then
			mod.SecretRoomVisited = true
		end
	elseif roomtype == RoomType.ROOM_TREASURE then
		if roomidx == mod.TreasureRoomIndex then
			mod.TreasureRoomVisited = true
		end
	elseif roomtype == RoomType.ROOM_BOSS then
		if roomidx == mod.BossRoomIndex then
			mod.BossRoomVisited = true
		end
	end

	if mod:HasCurse(LevelCurse.CURSE_OF_LABYRINTH) and mod:GetPlayersHoldingCollectible(TaintedCollectibles.ETERNAL_CANDLE) then
		if room:IsFirstVisit() then --Spawn hearts on first entry of Devil/Angel deal
			mod:EternalCandleNewRoom(room, roomtype)
		end
	end

	mod:BugulonSuperFanNewRoom(room, roomtype)

	local leviathans = mod:GetPlayersHoldingCollectible(TaintedCollectibles.LEVIATHAN)
	if leviathans then
		for _, player in pairs(leviathans) do
			mod:LeviathanNewRoom(player, room)
		end
	end
	
	local batteries = mod:GetPlayersHoldingCollectible(TaintedCollectibles.OVERCHARGED_BATTERY)
	if batteries then
		for _, player in pairs(batteries) do
			mod.GetPersistentPlayerData(player).TaintedNeededCharge = player:NeedsCharge()
		end
	end

	for _, basilisk in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, TaintedFamiliars.BASILISK, -1)) do
		mod:BasiliskNewRoom(basilisk:ToFamiliar())
	end

	for i = 0, DoorSlot.NUM_DOOR_SLOTS do
		local door = room:GetDoor(i)
		if door then
			local targetroomdesc = level:GetRoomByIdx(door.TargetRoomIndex)
			if mod:IsRoomDescTainted(targetroomdesc) then
				mod:MakeDoorTainted(door)
			end
		end
	end
	
	if mod:IsRoomDescTainted(roomdesc) then
		local haschaos = false
		local dice = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DICE_FLOOR)
		if #dice > 0 then
			for i = 1, #dice do
				dice[i]:Remove()
			end
		end
		
		mod:scheduleForUpdate(function()
			MusicManager():Play(TaintedTracks.SACRIFICIAL, 1)
			MusicManager():UpdateVolume()
		end, 0, ModCallbacks.MC_POST_RENDER)
		
		for i = 0, DoorSlot.NUM_DOOR_SLOTS do
			local door = room:GetDoor(i)
			if door then
				local doorSprite = door:GetSprite()
				mod:MakeDoorTainted(door)
				doorSprite:Play("Opened")

				--From Andromeda, probably don't even need this here but leaving it just to be safe: Fix for the room infinitely looping when using joker or similar card
				if door.TargetRoomIndex == GridRooms.ROOM_DEBUG_IDX then
					game:StartRoomTransition(84, 1, RoomTransitionAnim.FADE)
				end
			end
		end
		
		
		if room:GetBackdropType() ~= BackdropType.DARK_CLOSET then
			game:ShowHallucination(0, BackdropType.DARK_CLOSET)
			SFXManager():Stop(SoundEffect.SOUND_DEATH_CARD)
		end
		
		for i = 0, 118 do
			local grident = room:GetGridEntity(i)
			if grident and grident:ToRock() and grident:GetType() ~= 6 then
				grident:GetSprite():ReplaceSpritesheet(0, "gfx/grid/rocks_depths.png")
				grident:GetSprite():LoadGraphics()
			end
			if grident and grident:ToPit() then
				grident:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_pit_depths.png")
				grident:GetSprite():LoadGraphics()
			end
			if grident and grident:GetType() == GridEntityType.GRID_DECORATION then
				grident:GetSprite():ReplaceSpritesheet(0, "gfx/grid/props_05_depths.png")
				grident:GetSprite():LoadGraphics()
			end
		end

		mod:UpdateTaintedItems()
	end
	
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.CLANDESTINE_CARD) then
		local player = mod:GetPlayersHoldingCollectible(TaintedCollectibles.CLANDESTINE_CARD)[1]
		local trapdoorpos = Vector(440, 150)
		if roomdata.Type == RoomType.ROOM_SHOP then
			if warpplayer then
				player.Position = trapdoorpos
			end
			if room:GetBackdropType() == BackdropType.SECRET then
				game:ChangeRoom(-6, -1)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TALL_LADDER, 0, player.Position, Vector.Zero, player)
				warpplayer = true
			elseif room:IsFirstVisit() and room:GetGridIndex(trapdoorpos) then
				Isaac.GridSpawn(GridEntityType.GRID_STAIRS, 2, trapdoorpos)
			end
			
			if room:GetGridEntityFromPos(trapdoorpos) then
				local sprite = room:GetGridEntityFromPos(trapdoorpos):GetSprite()
				sprite:ReplaceSpritesheet(0, "gfx/grid/grid_clandestinetrapdoor.png")
				sprite:LoadGraphics()
			end
		else
			warpplayer = false
		end
		if roomdata.Type == RoomType.ROOM_BLACK_MARKET then
			mod:scheduleForUpdate(function()
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TALL_LADDER, 0, player.Position, Vector.Zero, player)
			end, 0, ModCallbacks.MC_POST_RENDER)
		end
	end
	
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.DIONYSIUS) and not room:IsClear() and mod:RandomInt(1, 2) == 1 then
		local player = mod:GetPlayersHoldingCollectible(TaintedCollectibles.DIONYSIUS)[1]
		mod:scheduleForUpdate(function()
			Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.DIONYSIUS, 0, room:GetCenterPos(), Vector.Zero, player)
		end, 0, ModCallbacks.MC_POST_RENDER)
	end
	
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.STEAMY_SURPRISE) and roomdata.Type == RoomType.ROOM_SHOP and room:IsFirstVisit() then
		local pickups = {}
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:ToPickup() and entity:ToPickup():IsShopItem() then
				table.insert(pickups, entity:ToPickup())
			end
		end
		if pickups[1] then
			pickups[1]:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_STORE_CREDIT, false)
		end
		if pickups[2] and #pickups ~= 2 then
			pickups[2]:Remove()
		end
	end
	
	if MinimapAPI and #mod.minimaprooms > 0 then
		for i, roomidx in pairs(mod.minimaprooms) do
			local minimaproom = MinimapAPI:GetRoomByIdx(roomidx)
			mod:scheduleForUpdate(function()
				if minimaproom then
					minimaproom.Color = Color(MinimapAPI.Config.DefaultRoomColorR, MinimapAPI.Config.DefaultRoomColorG, MinimapAPI.Config.DefaultRoomColorB, 1, 0, 0, 0)
					if mod:IsRoomDescTainted(minimaproom.Descriptor) then
						minimaproom.PermanentIcons = {"TaintedTreasureRoom"}
					end
					mod.minimaprooms[i] = nil
				end
			end, 0)
		end
	else
		mod.minimaprooms = {}
	end

	mod.CustomFireWaves = {}
	mod.GridPaths = {}
end)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng, spawnpos)
	if mod:HasCurse(LevelCurse.CURSE_OF_THE_LOST) and mod:GetPlayersHoldingCollectible(TaintedCollectibles.ETERNAL_CANDLE) then
		mod:EternalCandleRoomClear(rng, spawnpos)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	local room = game:GetRoom()

	local players = mod:GetAllPlayers()

	for _, player in pairs(players) do
		local data = player:GetData()
		mod:TrackPlayerUnlocking(player, data)
		mod:ResetGerminatedBoosts(player, data)
	end

	for i = 0, room:GetGridSize() - 1 do 
        local grid = room:GetGridEntity(i)
		if grid then
			mod:RunCustomCallback("GRID_UPDATE", {grid})
		end
	end

	for i = 0, DoorSlot.NUM_DOOR_SLOTS do
		local door = room:GetDoor(i)
		if door then
			mod:CheckDoorForUnlock(door)
		end
	end

	local entities = Isaac.GetRoomEntities()
	for _, entity in ipairs(entities) do
		if entity:ToNPC() and entity:IsEnemy() then
			local npc = entity:ToNPC()
			local data = npc:GetData()
			mod:CustomStatusUpdate(npc, data)
			mod:EvangelismEnemyUpdate(npc, data)
			mod:ForcedKnockbackEnemyLogic(npc, data)
	
			if data.WeaknessDebuffed then
				data.WeaknessDebuffed = data.WeaknessDebuffed - 1
				if data.WeaknessDebuffed <= 0 then
					npc:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)
					data.WeaknessDebuffed = nil
				end
			end

			if data.BleedDebuffed then
				data.BleedDebuffed = data.BleedDebuffed - 1
				if data.BleedDebuffed <= 0 then
					npc:ClearEntityFlags(EntityFlag.FLAG_BLEED_OUT)
					data.BleedDebuffed = nil
				end
			end

			if data.BrimCurseDebuffed then
				data.BrimCurseDebuffed = data.BrimCurseDebuffed - 1
				if data.BrimCurseDebuffed <= 0 then
					npc:ClearEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
					data.BrimCurseDebuffed = nil
				end
			end
		elseif entity.Type == 6 then --Slots/machines
			local slot = entity
			mod:RunCustomCallback("SLOT_UPDATE", {slot})
			for _, player in pairs(players) do
				if slot.Position:Distance(player.Position) <= slot.Size + player.Size then
					mod:RunCustomCallback("SLOT_TOUCH", {player, slot})
				end
			end
		end
	end

	for _, player in pairs(players) do
		local data = player:GetData()
		mod:EvaluateGerminatedBoosts(player, data)
	end

	for i, firewave in pairs(mod.CustomFireWaves) do
		if not mod:CustomFireWaveUpdate(firewave) then
			table.remove(mod.CustomFireWaves, i)
		end
	end

	mod:GatherGridPaths()
	mod:UpdateCustomStatusIcons()
	mod:EnlightenedStatusLogic()
end)

mod:AddCustomCallback("USE_KEY", function(_, player)
	local data = player:GetData()
	local savedata = mod.GetPersistentPlayerData(player)

	--print("Used a key")

    if player:HasCollectible(TaintedCollectibles.SKELETON_LOCK) then
		mod:SkeletonLockOnUseKey(player, savedata)
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, function(_)
	local level = game:GetLevel()
	local roomdesc = level:GetCurrentRoomDesc()
	local haschaos = mod:GetPlayersHoldingCollectible(CollectibleType.COLLECTIBLE_CHAOS)
	
	local pageplayers = mod:GetPlayersHoldingCollectible(TaintedCollectibles.YEARNING_PAGE)
	if pageplayers then
		for i, player in pairs(pageplayers) do
			if not player:HasCollectible(CollectibleType.COLLECTIBLE_NECRONOMICON) and mod:RandomInt(1, 8) == 1 then
				return CollectibleType.COLLECTIBLE_NECRONOMICON
			end
		end
	end
	
	if mod:IsRoomDescTainted(roomdesc) then
		mod:scheduleForUpdate(mod.UpdateTaintedItems, 0)
			
		local spawnitems = {}
		for _, player in pairs(mod:GetAllPlayers()) do
			if player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE, true) and not haschaos then
				return TaintedCollectibles.DIONYSIUS
			end
			for j, entry in pairs(mod.savedata.taintedsets) do
				if player:HasCollectible(entry[1], true) and not mod:GetConditionValue(entry[3]) then
					table.insert(spawnitems, entry[2])
					if entry[2] == TaintedCollectibles.FINALE then
						return TaintedCollectibles.FINALE
					end
				end
			end
		end
		
		local ranitem = mod:GetRandomElem(spawnitems)
			
		if not haschaos and ranitem then
			return ranitem
		end
	end
end)

local pickingupitem = {}
local reviving = false
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local level = game:GetLevel()
	local roomdesc = level:GetCurrentRoomDesc()
	local data = player:GetData()
	local savedata = mod.GetPersistentPlayerData(player)
	
	if not player:IsItemQueueEmpty() and player.QueuedItem.Item:IsCollectible() then
		if mod:IsRoomDescTainted(roomdesc) then
			if player.QueuedItem.Item.ID == TaintedCollectibles.CONTRACT_OF_SERVITUDE and not pickingupitem[player.InitSeed] then
				local desc = mod.ContractEffects[player:GetPlayerType()]
				if desc then
					game:GetHUD():ShowItemText("Contract of Servitude", desc[1])
				end
			end
			for i, entry in pairs(mod.savedata.taintedsets) do
				if not pickingupitem[player.InitSeed] and player.QueuedItem.Item.ID == entry[2] and player:HasCollectible(entry[1], true) then
					player:RemoveCollectible(entry[1])
					SFXManager():Play(TaintedSounds.POWERUPTAINTED, 3, 2, false, 1)
					SFXManager():Stop(SoundEffect.SOUND_CHOIR_UNLOCK)
					for j, entity in pairs(Isaac.GetRoomEntities()) do
						if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == TaintedEffects.ITEM_GHOST and entity:GetData().CollectibleType and entity:GetData().CollectibleType == entry[1] then
							entity:Remove()
							pickingupitem[player.InitSeed] =  true
						end
					end
				elseif player:GetPlayerType() == PlayerType.PLAYER_CAIN_B and player.QueuedItem.Item and player.QueuedItem.Item.ID == entry[2] and not (string.find(player:GetSprite():GetAnimation(), "Pickup") or string.find(player:GetSprite():GetAnimation(), "Walk")) then
					player:FlushQueueItem()
				end
			end
		end
		pickingupitem[player.InitSeed] =  true
	else
		pickingupitem[player.InitSeed] = false
	end
	
	mod:BadOnionPlayerLogic(player, savedata)

	mod:DPadPlayerLogic(player, data, savedata)
	
	mod:WarMaidenPlayerLogic(player, data)
	
	mod:PoisonedDartPlayerLogic(player, data)
	
	mod:ReaperPlayerLogic(player, data)

	mod:LeviathanPlayerLogic(player, data)

	if data.SuccRing then
		mod:BuzzingMagnetPlayerLogic(player, data)
	end

	if player:HasCollectible(TaintedCollectibles.SKELETON_LOCK) then
		mod:SkeletonLockKeyLimiting(player)
	end

	if player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
		mod:LilSluggerPlayerLogic(player)
	end

	mod:SorrowfulShallotPlayerLogic(player, data, savedata)
	
	mod:WhiteBeltPlayerLogic(player, data, savedata)

	mod:TheBottlePlayerLogic(player, data, savedata)

	mod:WhoreOfGalileePlayerLogic(player, data)

	mod:EternalCandlePlayerLogic(player, data, level)
	
	mod:OverchargedBatteryPlayerLogic(player, data)
	
	mod:BlueCanaryPlayerLogic(player, data)

	mod:MaelstromPlayerLogic(player, data, savedata)

	mod:CheckItemWisps(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER, player:GetCollectibleNum(TaintedCollectibles.SPIDER_FREAK) * 2)
	
	mod:CheckItemWisps(player, CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM, mod:BoolToNumber(player:HasCollectible(TaintedCollectibles.WORMWOOD)))
	
	--For comparison to check for new room
	data.CurrentRoomIndex = level:GetCurrentRoomIndex()
	
	data.TaintedFamiliarDoubleTapped = data.TaintedDoubleTapped
	
	--Reset double-tap shoot tag
	data.TaintedDoubleTapped = false
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	local data = player:GetData()
	local savedata = mod.GetPersistentPlayerData(player)
	
	mod:CrystalSkullPlayerLogic(player, data) --I don't think it's consistent on PEFFECT_UPDATE
	mod:DPadInputLogic(player, data, savedata)
	mod:ATGInputLogic(player, data)
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
	local data = player:GetData()
	mod:DPadIconRender(player, data)
	mod:ReaperBarRender(player, data)
end)

mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function(_, player, collider)
	if collider:ToBomb() and collider:GetData().TaintedArrowhead then
		return true
	end
end)

mod:AddCustomCallback("GAIN_COLLECTIBLE", function(_, player, collectible)
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.FADE_IN, 0, Vector(320,870), Vector(0, 0), player)
	effect:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
end, TaintedCollectibles.FINALE)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local player = collider:ToPlayer()
	
	if mod:IsRoomDescTainted(game:GetLevel():GetCurrentRoomDesc()) and player then
		local hasuntainted = false
		local istainted = false
		for i, entry in pairs(mod.savedata.taintedsets) do
			if entry[2] == pickup.SubType then
				istainted = true
				if player:HasCollectible(entry[1], true) then
					hasuntainted = true
				end
			end
		end
		
		if istainted then
			if player:GetPlayerType() == PlayerType.PLAYER_CAIN_B and hasuntainted and player:IsItemQueueEmpty() and pickup.SubType ~= 0 then
				local collectible = pickup.SubType
				
				player:AnimateCollectible(collectible)
				player:QueueItem(Isaac.GetItemConfig():GetCollectible(collectible), 12, true)
				
				game:GetHUD():ShowItemText(player, Isaac.GetItemConfig():GetCollectible(collectible))
				mod:RunCustomCallback("GAIN_COLLECTIBLE", {player, pickup.SubType})
				
				pickup.SubType = 0
				pickup:GetSprite():SetAnimation("Empty")
				pickup:GetSprite():ReplaceSpritesheet(4, "gfx/effects/effect_015_tearpoofnotear.png") --Makes the item shadow invisible
				pickup:GetSprite():LoadGraphics()
			elseif not hasuntainted or (player:GetPlayerType() == PlayerType.PLAYER_CAIN_B and player:IsItemQueueEmpty()) then
				return true
			end
		end
	end
end, PickupVariant.PICKUP_COLLECTIBLE)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	local data = pickup:GetData()
	local sprite = pickup:GetSprite()
	if not (mod:HasCurse(LevelCurse.CURSE_OF_BLIND) or mod:IsAltChoice(pickup)) then
		if mod:IsSettingOn(mod.savedata.config.PurpleSparkle) and pickup.FrameCount % 10 == 0 then
			local tainted = false
			for i, entry in pairs(mod.savedata.taintedsets) do
				if pickup.SubType == entry[1] then
					tainted = true
				end
			end
			if (tainted or mod.PurpleSparkleWhitelist[pickup.SubType]) and not mod.PurpleSparkleBlacklist[pickup.SubType] then
				local sparklestospawn = mod:RandomInt(0, 3)
				for i = 1, sparklestospawn do
					local sparkle = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.SPARKLE, 0, pickup.Position+Vector(mod:RandomInt(-20, 20), mod:RandomInt(-60, -20)), Vector.Zero, nil):ToEffect()
					if pickup:IsShopItem() then
						sparkle.Position = sparkle.Position + Vector(0, 40)
					end
					sparkle:GetSprite().PlaybackSpeed = 0.9
				end
			end
		end
		if pickup.SubType == TaintedCollectibles.EVANGELISM then
			if not (data.StaticInit or pickup:IsShopItem()) then 
				local dogma = Isaac.Spawn(TaintedNPCs.DOGMA_RENDERER.ID, TaintedNPCs.DOGMA_RENDERER.Var, 0, pickup.Position, Vector.Zero, pickup)
				local dsprite = dogma:GetSprite()
				dsprite:Load("gfx/005.100_collectible.anm2", true)
				dsprite:Play("Idle", true)
				dsprite:SetFrame(sprite:GetFrame())
				dsprite:ReplaceSpritesheet(1, "gfx/items/collectibles/collectible_evangelism.png")
				dsprite:LoadGraphics()

				dogma.Parent = pickup
				dogma.DepthOffset = pickup.DepthOffset + 1
				dogma:GetData().EnforceSubtype = TaintedCollectibles.EVANGELISM
				data.StaticInit = true
			end
		end
	end
end, PickupVariant.PICKUP_COLLECTIBLE)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local player = collider:ToPlayer()
	if player then
		if player:HasCollectible(TaintedCollectibles.SKELETON_LOCK) then
			return mod:SkeletonLockKeyColl(pickup, player)
		end
	end
end, PickupVariant.PICKUP_KEY)


mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	local badonionplayers = mod:GetPlayersHoldingCollectible(TaintedCollectibles.BAD_ONION)
	if badonionplayers then
		for i, player in pairs(badonionplayers) do
			mod:BadOnionOnKill(player, mod.GetPersistentPlayerData(player))
		end
	end

	local sorrowfulplayers = mod:GetPlayersHoldingCollectible(TaintedCollectibles.SORROWFUL_SHALLOT)
	if sorrowfulplayers then
		for i, player in pairs(sorrowfulplayers) do
			mod:SorrowfulShallotOnKill(player, mod.GetPersistentPlayerData(player))
		end
	end
	
	local searedclubplayers = mod:GetPlayersHoldingCollectible(TaintedCollectibles.SEARED_CLUB)
	if searedclubplayers and npc:IsEnemy() and not npc:IsInvincible() then
		mod:SearedClubOnKill(npc)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc, offset)
	mod:StatusIconRendering(npc, npc:GetData())
end)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, projectile)
	local data = projectile:GetData()
	mod:ForkBenderProjectileSpawn(projectile, data)
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	mod:discItemWispTears(tear)
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	local data = tear:GetData()
	if data.TaintedPlayerRef and not data.TaintedPlayerRef:Exists() then
		data.TaintedPlayerRef = nil
	end
	local player = data.TaintedPlayerRef

	if data.TaintedFireWave then
		if tear.FrameCount % 3 == 0 then
			local spark = Isaac.Spawn(1000, 66, 0, tear.Position + RandomVector()*5, tear.Velocity / 4, tear)
			spark.PositionOffset = Vector(0, tear.Height)
		end
	end
	if data.TaintedArrowhead then
		mod:ArrowheadTearUpdate(tear, data)
	end
	if data.TaintedCluster then
		mod:PolycoriaTearUpdate(tear, data)
	end
	if data.TaintedColoredContact then
		mod:ColoredContactTearUpdate(tear, data)
	end
	if player and player:Exists() then
		if player:HasCollectible(TaintedCollectibles.TECH_ORGANELLE) then
			mod:TechOrganelleTearUpdate(tear, data, player)
		end
	end
	if data.BBTear then
		if tear.FrameCount % 2 == 0 then
			local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, tear.Position + tear.PositionOffset + RandomVector()*5, tear.Velocity/3, player):ToEffect()
			smoke:GetSprite().PlaybackSpeed = 0.4
			smoke.Timeout = 80
			smoke.Color = Color(1,1,1,0)
			smoke.SpriteScale = smoke.SpriteScale*0.8
			smoke:SetColor(Color(1, 0.2, 0.2, 0.2, 20, 0, 0), 10, 1, true, false)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, projectile)
	local data = projectile:GetData()
	if data.ForkBenderTimer then
		mod:ForkBenderProjectileUpdate(projectile, data)
	end
end)

function mod:IsDefaultColor(color)
	local dcolor = Color.Default
	return (color.R == dcolor.R and color.G == dcolor.G and color.B == dcolor.B and color.A == dcolor.A and color.RO == dcolor.RO and color.GO == dcolor.GO and color.BO == dcolor.BO)
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
	local whitebelts = mod:GetPlayersHoldingCollectible(TaintedCollectibles.WHITE_BELT)
	if npc:IsChampion() and whitebelts then
		mod:WhiteBeltNPCInit(npc, whitebelts[1]:GetCollectibleRNG(TaintedCollectibles.WHITE_BELT))
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, collectible)
	if collectible.SubType == TaintedCollectibles.CONTRACT_OF_SERVITUDE and EID then
		local players = mod:GetAllPlayers()
		for i, player in pairs(players) do
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and mod.ContractEffects[player:GetPlayerType()][2] then
				if not collectible:GetData()["EID_Description"] then
					collectible:GetData()["EID_Description"] = "Grants a unique familiar for each character" .. mod.ContractEffects[player:GetPlayerType()][2]
				else
					collectible:GetData()["EID_Description"] = collectible:GetData()["EID_Description"] .. mod.ContractEffects[player:GetPlayerType()][2]
				end
			end
		end
	end
end, PickupVariant.PICKUP_COLLECTIBLE)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, damage, flags, source, countdown)
	if npc:ToNPC() and damage > 0 then
		if source.Entity then
			if source.Type == 3 and source.Variant == TaintedFamiliars.BASILISK then
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS,0.2,0,false,mod:RandomInt(150,200)/100)
				local effect = Isaac.Spawn(1000, 2, 1, npc.Position + Vector(0, 1), Vector.Zero, nil)
				effect.Color = npc.SplatColor
				effect.SpriteOffset = npc.SpriteOffset + Vector(0,-5) + RandomVector() * mod:RandomInt(1,15)
				effect:Update()
			end
		end
	end
	
	if source.Entity and source.Entity:GetData().TaintedReaperFire and npc.HitPoints < damage and mod:RandomInt(1, 6) == 1 then
		local ghost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, npc.Position, Vector.Zero, nil)
		ghost:GetSprite():Play("Charge")
	end
	
	if source.Entity and source.Type == EntityType.ENTITY_FAMILIAR and source.Variant == TaintedFamiliars.BLUEBABYS_BEST_FRIEND then
		if rng:RandomFloat() <= 0.02 and game:GetRoom():GetGridIndex(source.Entity.Position) ~= -1 then
			local poop = Isaac.GridSpawn(GridEntityType.GRID_POOP, 0, npc.Position, false, false, true)
			if poop then
				sfx:Play(SoundEffect.SOUND_FART)
				game:ButterBeanFart(source.Entity.Position, 85, source.Entity:ToFamiliar().Player)
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider)
	local data = npc:GetData()
	if collider:ToNPC() then
		if data.TaintedStatus == "Repulsion" then
			mod:BuzzingMagnetsEnemyColl(npc, collider, data)
		end
		if collider:GetData().ForcedKnockbackImpactDamage and data.ImpactDamageCooldown and data.ImpactDamageCooldown <= 0 then
			data.ImpactDamageCooldown = 10
			npc:TakeDamage(10 + (2 * game:GetLevel():GetStage()), 0, EntityRef(nil), 0)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, type, rng, player, flags, slot)
	if type == CollectibleType.COLLECTIBLE_NECRONOMICON and player:HasCollectible(TaintedCollectibles.YEARNING_PAGE) then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:ToNPC() then
				entity:TakeDamage(40, 0, EntityRef(player), 1)
			end
		end
	end
	
	if player:GetPlayerType() == PlayerType.PLAYER_JUDAS and player:HasCollectible(TaintedCollectibles.CONTRACT_OF_SERVITUDE) then
		for i, familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, TaintedFamiliars.BELIAL_BOY)) do
			if GetPtrHash(player) == GetPtrHash(familiar:ToFamiliar().Player) then
				mod:BelialBoyGoBigMode(familiar, player:GetActiveCharge(slot)*1.5)
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
	local data = bomb:GetData()
	local sprite = bomb:GetSprite()
	local player = mod:GetPlayerFromTear(bomb)

	if player and data.TaintedIsGladBomb then
		mod:GladBombUpdate(bomb, player, data, sprite)
	end

	if data.TaintedArrowhead then
		mod:ArrowheadBombUpdate(bomb, data)
	end

	if data.TaintedColoredContact then
		mod:ColoredContactTearUpdate(bomb, data)
	end
	
	if player and player:HasCollectible(TaintedCollectibles.TECH_ORGANELLE) then
		mod:TechOrganelleBombUpdate(bomb, data, player)
	end
end)

--Poached from FF
function mod:spritePlay(sprite, anim)
	if not sprite:IsPlaying(anim) then
		sprite:Play(anim)
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player, amount, flags, source) --Player damage
	player = player:ToPlayer()
	local data = player:GetData()
	local savedata = mod.GetPersistentPlayerData(player)
	if player:HasCollectible(TaintedCollectibles.CONSECRATION) and flags & DamageFlag.DAMAGE_FIRE > 1 then
		return false
	end

	if data.HeldBugulonProp then
		mod:ThrowBugulonProp(data.HeldBugulonProp, player, RandomVector() * 5, 20)
	end

	if player:HasCollectible(TaintedCollectibles.WHITE_BELT) then
		savedata.WhiteBeltRepulsion = 120
	end

	if player:HasCollectible(TaintedCollectibles.MAELSTROM) then
		savedata.ExpectedMaelstroms = savedata.ExpectedMaelstroms + 1
	end

	for _, basilisk in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, TaintedFamiliars.BASILISK, -1)) do
		basilisk = basilisk:ToFamiliar()
		if basilisk.Player.InitSeed == player.InitSeed then
			mod:BasiliskOnPlayerHit(basilisk, player)
		end
	end
end, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
	local data = knife:GetData()
	local player = mod:getPlayerFromKnife(knife)

	mod:CheckForBugulonKnifeSkin(knife, data)
	mod:BottleKnifeUpdate(knife, data)
	mod:TechOrganelleKnifeUpdate(knife, data)

	if player then --Should refator prior stuff to check for this here also tbh
		mod:EvangelismKnifeUpdate(knife, data, player)
	end

	if data.TaintedRawSoylent and not knife:IsFlying() then
		knife:Remove()
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
	if shouldSave then
		mod:SaveData(json.encode(mod.savedata))
	end
end)

function mod:IsNormalRender()
    local isPaused = game:IsPaused()
    local isReflected = (game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
    return (isPaused or isReflected) == false
end

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, var, sub, pos, vel, spawner, seed)
	rng:SetSeed(seed, 0)
	if id == 6 and var == 4 then --Tainted Beggar replacement
		local stagelimit = mod:GetTaintedTreasureRoomThreshold()
		local spawnchance = 0.2
		for _, player in pairs(mod:GetAllPlayers()) do
			for j, entry in pairs(mod.savedata.taintedsets) do
				if player:HasCollectible(entry[2], true) or player:HasCollectible(entry[1], true) then
					spawnchance = spawnchance * 0.5
				end
			end
		end
		if rng:RandomFloat() <= spawnchance and game:GetLevel():GetStage() < stagelimit - 1 and mod:IsSettingOn(mod.savedata.config.TaintedBeggars) then
			return {id, TaintedMachines.TAINTED_BEGGAR, sub, seed}
		end
	end
	if id == 6 and var == TaintedMachines.TAINTED_BEGGAR and not mod:IsSettingOn(mod.savedata.config.TaintedBeggars) then
		return {id, 4, sub, seed}
	end
end)

--From FiendFolio, i think Budj wrote this?
function mod.DetectDoubleTapFire(player, isFiring, action, throughMouse)
    if not isFiring then return end
    if throughMouse then
        action = 160160
    end

    local inputFrames = 7

    local data = player:GetData()

    local frame = player.FrameCount
    local fireFrame = data.TaintedLastFirePress
    local fireAction = data.TaintedLastFireAction

    data.TaintedLastFirePress = frame
    data.TaintedLastFireAction = action

    -- activate double tap fire
    if action == fireAction
    and fireFrame and frame - fireFrame <= inputFrames then
        data.TaintedLastFirePress = nil
        data.TaintedLastFireAction = nil

        data.TaintedDoubleTapped = true
    end
end

function mod.resetDoubleTap(player, isDropping)
    local inputFrames = 7

    local data = player:GetData()

    local frame = player.FrameCount
    local dropFrame = data.TaintedLastResetPress

    data.TaintedLastResetPress = frame

    if dropFrame and frame - dropFrame <= inputFrames then
        data.TaintedLastResetPress = nil
        Isaac.ExecuteCommand('restart')
        return
    end
end

local shootInputs = {
    ButtonAction.ACTION_SHOOTLEFT,
    ButtonAction.ACTION_SHOOTRIGHT,
    ButtonAction.ACTION_SHOOTUP,
    ButtonAction.ACTION_SHOOTDOWN
}

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if game:IsPaused() then return end

    for i = 1, game:GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)
        local controllerIndex = player.ControllerIndex

        for _, buttonAction in pairs(shootInputs) do
            local isFiring
            local throughMouse
            if player.ControllerIndex == 0 and Options.MouseControl then
                if Input.IsMouseBtnPressed(0) then
                    if not mod.Player0IsClickingMouse then
                        isFiring = true
                        throughMouse = true
                        mod.Player0IsClickingMouse = true
                    end
                else
                    mod.Player0IsClickingMouse = nil
                end
            end
            if not throughMouse then
                isFiring = Input.IsActionTriggered(buttonAction, controllerIndex)
            end
            mod.DetectDoubleTapFire(player, isFiring, buttonAction, throughMouse)
        end

        if Input.IsActionTriggered(ButtonAction.ACTION_RESTART, controllerIndex) then
            mod.resetDoubleTap(player)
        end
    end
end)
