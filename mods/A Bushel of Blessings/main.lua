--Mod registered
BlessingsBushel = RegisterMod("A Bushel of Blessings", 1)
local mod = BlessingsBushel

local json = require("json")

CollectibleType.COLLECTIBLE_ISAACS_BLESSING = Isaac.GetItemIdByName("Isaac's Blessing")
CollectibleType.COLLECTIBLE_MAGGYS_BLESSING = Isaac.GetItemIdByName("Maggy's Blessing")
CollectibleType.COLLECTIBLE_CAINS_BLESSING = Isaac.GetItemIdByName("Cain's Blessing")
CollectibleType.COLLECTIBLE_JUDAS_BLESSING = Isaac.GetItemIdByName("Judas' Blessing")
CollectibleType.COLLECTIBLE_QQQS_BLESSING = Isaac.GetItemIdByName("???'s Blessing")
CollectibleType.COLLECTIBLE_EVES_BLESSING = Isaac.GetItemIdByName("Eve's Blessing")
CollectibleType.COLLECTIBLE_SAMSONS_BLESSING = Isaac.GetItemIdByName("Samson's Blessing")
CollectibleType.COLLECTIBLE_AZAZELS_BLESSING = Isaac.GetItemIdByName("Azazel's Blessing")
CollectibleType.COLLECTIBLE_LAZARUS_BLESSING = Isaac.GetItemIdByName("Lazarus' Blessing")
CollectibleType.COLLECTIBLE_LOSTS_BLESSING = Isaac.GetItemIdByName("The Lost's Blessing")
CollectibleType.COLLECTIBLE_LILITHS_BLESSING = Isaac.GetItemIdByName("Lilith's Blessing")
CollectibleType.COLLECTIBLE_KEEPERS_BLESSING = Isaac.GetItemIdByName("Keeper's Blessing")
CollectibleType.COLLECTIBLE_APOLLYONS_BLESSING = Isaac.GetItemIdByName("Apollyon's Blessing")
CollectibleType.COLLECTIBLE_THEFORGOTTENS_BLESSING = Isaac.GetItemIdByName("The Forgotten's Blessing")
CollectibleType.COLLECTIBLE_BETHANYS_BLESSING = Isaac.GetItemIdByName("Bethany's Blessing")
CollectibleType.COLLECTIBLE_JACOB_AND_ESAUS_BLESSING = Isaac.GetItemIdByName("Jacob and Esau's Blessing")
CollectibleType.NUM_COLLECTIBLES = CollectibleType.NUM_COLLECTIBLES + 16

if EID then
	EID:addCollectible(Isaac.GetItemIdByName("Isaac's Blessing"), "Triggers the effect of Isaac's Soul {{Card81}} upon entering a new room.#On your next run, triggers the effect of Isaac's Soul {{Card81}} for the first item pedestal the player finds.", "Isaac's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Maggy's Blessing"), "↑ +1 Health up.#↑ +1 Health up at the start of your next run.", "Maggy's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Cain's Blessing"), "↑ +2 Luck up.#↑ +2 Luck up at the start of your next run.", "Cain's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Judas' Blessing"), "↑ +2 Damage up.#↑ +2 Damage up at the start of your next run.", "Judas' Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("???'s Blessing"), "Spawns 12 Blue Flies and a Pretty Fly.#Spawns 12 Blue Flies and a Pretty Fly at the start of your next run.", "???'s Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Eve's Blessing"), "↑ +1 Black Heart.#Grants a random Devil Deal item at the start of your next run.", "Eve's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Samson's Blessing"), "Triggers the effect of Berserk! {{Collectible704}} upon pickup, at the start of each floor, and on the first floor of your next run.", "Samson's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Azazel's Blessing"), "↑ +1 Black Heart#↑ +0.3 Speed up.#↑ +0.3 Speed up at the start of your next run.", "Azazel's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Lazarus' Blessing"), "Spawns two random trinkets.#Spawn two more trinkets at the start of your next run.", "Lazarus' Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("The Lost's Blessing"), "Grants flight and a temporary Holy Mantle.#Grants a temporary Holy Mantle at the start of your next run.", "The Lost's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Lilith's Blessing"), "Grants Isaac a random familiar.#Grants another random familiar at the start of your next run.", "Lilith's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Keeper's Blessing"), "{{Coin}} +10 Coins.#{{Coin}} +10 Coins at the start of your next run.#33% chance to also give another copy of Keeper's Blessing.", "Keeper's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Apollyon's Blessing"), "Spawns one of each Locust, and triggers the effect of Book of Revelations. {{Collectible78}}#Triggers the effect of Book of Revelations {{Collectible78}} at the start of your next run.", "Apollyon's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("The Forgotten's Blessing"), "↑ +1 Bone Heart#↑ +1 Bone Heart at the start of your next run.", "The Forgotten's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Bethany's Blessing"), "Spawns 8 Blue Wisps.#Spawns 8 Blue Wisps at the start of your next run.", "Bethany's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Jacob and Esau's Blessing"), "Grants a copy of an item Isaac already has.#Grants a copy of that same item at the start of your next run.", "Jacob and Esau's Blessing", "en_us")
	EID:addCollectible(Isaac.GetItemIdByName("Isaac's Blessing"), "Активирует эффект души Исаака {{Card81}} при входе в новую комнату.#В начале следующего забега, активирует эффект души Исаака {{Card81}} для первого предмета, который игрок найдет на пьедестале.", "Благословение Исаака", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Maggy's Blessing"), "↑ +1 к здоровью.#↑ +1 к здоровью в начале следующего забега.", "Благословение Мэгги", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Cain's Blessing"), "↑ +2 к удаче.#↑ +2 к удаче в начале следующего забега.", "Благословение Каина", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Judas' Blessing"), "↑ +2 урона.#↑ +2 урона в начале следующего забега.", "Благословение Иуды", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("???'s Blessing"), "Создаёт 12 синих мух и милую мушку.#Создаёт 12 синих мух и милую мушку в начале следующего забега.", "Благословение ???", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Eve's Blessing"), "↑ +1 чёрное сердце.#Даёт случайный артефакт дьявольской сделки в начале следующего забега.", "Благословение Евы", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Samson's Blessing"), "Активирует эффект Берсерк! {{Collectible704}} при поднятии, в начале каждого этажа, и первого этажа следующего забега.", "Благословение Самсона", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Azazel's Blessing"), "↑ +1 чёрное сердце#↑ +0.3 скорости.#↑ +0.3 скорости в начале следующего забега.", "Благословение Азазеля", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Lazarus' Blessing"), "Создаёт два случайных брелка.#Создаёт ещё два брелка в начале следующего забега.", "Благословение Лазаря", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("The Lost's Blessing"), "Даёт полёт и временную Святую Мантию.#Даёт временную Святую Мантию в начале следующего забега.", "Благословение Потерянного", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Lilith's Blessing"), "Даёт Исааку случайного спутника.#Даёт другого случайного спутника в начале следующего забега.", "Благословение Лилит", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Keeper's Blessing"), "{{Coin}} +10 монет.#{{Coin}} +10 монет в начале следующего забега.#Также 33% шанса дать другую копию Благословения Хранителя.", "Благословение Хранителя", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Apollyon's Blessing"), "Создаёт по одному экземпляру каждой саранчи, и активирует эффект Книги Откровений. {{Collectible78}}#Активирует эффект Книги Откровений {{Collectible78}} в начале следующего забега.", "Благословение Аполлиона", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("The Forgotten's Blessing"), "↑ +1 костяное сердце#↑ +1 костяное сердце в начале следующего забега.", "Благословение Забытого", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Bethany's Blessing"), "Создаёт 8 синих огоньков.#Создаёт 8 синих огоньков в начале следующего забега.", "Благословение Вифании", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Jacob and Esau's Blessing"), "Даёт копию артефакта, который уже есть у Исаака.#Даёт копию этого же артефакта в начале следующего забега.", "Благословение Иакова и Исава", "ru")
	EID:addCollectible(Isaac.GetItemIdByName("Isaac's Blessing"), "Запускає ефект душі Ісаака {{Card81}} при вході в нову кімнату.#Під час наступної пробіжки, викликає ефект душі Ісаака {{Card81}} для першого знайденого гравцем п’єдесталу.", "Ісааківське благословення", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Maggy's Blessing"), "↑ +1 здоров'я.#↑ +1 до здоров’я на початку вашого наступного забігу.", "Благословення Меггі", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Cain's Blessing"), "↑ +2 удачі.#↑ +2 удачі на початку вашого наступного забігу.", "Благословення Каїна", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Judas' Blessing"), "↑ +2 до шкоди.#↑ +2 до шкоди на початку вашого наступного забігу.", "Благословення Юди", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("???'s Blessing"), "Викликає 12 синіх мух і красиву муху.#Викликає 12 синіх мушок і красиву муху на початку вашого наступного забігу.", "Благословення ???", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Eve's Blessing"), "↑ +1 Чорне серце.#Надає випадковий предмет Диявольська угода на початку наступного забігу.", "Благословення Єви", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Samson's Blessing"), "Запускає ефект Берсерка! {{Collectible704}} при отриманні, на початку кожного поверху, і на першому поверсі вашої наступної пробіжки.", "Благословення Самсона", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Azazel's Blessing"), "↑ +1 Чорне серце#↑ +0,3 до прискорення.#↑ +0,3 прискорення на початку наступного забігу.", "Благословення Азазеля", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Lazarus' Blessing"), "Створює дві випадкові дрібнички.#Витворіть ще дві дрібнички на початку наступного забігу.", "Благословення Лазаря", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("The Lost's Blessing"), "Дарує політ і тимчасову священну мантію.#Надає тимчасову священну мантію на початку вашого наступного забігу.", "Благословення Загублених", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Lilith's Blessing"), "Надає Ісааку випадкового фамільяра.#Надає ще одного випадкового фамільяра на початку наступного забігу.", "Благословення Ліліт", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Keeper's Blessing"), "{{Coin}} +10 монет.#{{Coin}} +10 монет на початку вашого наступного пробігу.#33% шанс також дати ще одну копію Благословення хранителя.", "Благословення хранителя", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Apollyon's Blessing"), "Викликає по одній Сарані, і запускає ефект Книги Одкровень. {{Collectible78}}#Запускає ефект Книги Одкровень {{Collectible78}} на початку вашої наступної пробіжки.", "Благословення Аполліона", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("The Forgotten's Blessing"), "↑ +1 кісткове серце#↑ +1 кісткове серце на початку вашого наступного забігу.", "Благословення Забутого", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Bethany's Blessing"), "Викликає 8 блакитних вогників.#На початку вашого наступного забігу створюється 8 блакитних вогників.", "Благословення Віфанії", "uk_ua")
	EID:addCollectible(Isaac.GetItemIdByName("Jacob and Esau's Blessing"), "Надає копію предмета, який уже є у Ісаака.#Надає копію того самого предмета на початку наступного запуску.", "Благословення Якова та Ісава", "uk_ua")
end

local persistent

if mod:HasData() then
	persistent = json.decode(mod:LoadData())
else
	persistent = {blessing_queue = {}, isaac_blessing = false, isaac_blessing_mini = false, samson_rage = false, cain_luck = 0, judas_damage = 0, azazel_speed = 0.3, lost_flight = false}
end

-- Sourced from the Isaac Lua Documentation: https://wofsauge.github.io/IsaacDocs/rep/Isaac.html?h=getplayer#getplayer

local function GetPlayers()
	local game = Game()
	local numPlayers = game:GetNumPlayers()
  
	local players = {}
	for i = 0, numPlayers - 1 do
	  local player = Isaac.GetPlayer(i)
	  table.insert(players, player)
	end
  
	return players
end

local function GetItems(player,getKeyItems)
	local getKeyItems = getKeyItems or false
	local blacklist = {CollectibleType.COLLECTIBLE_POLAROID, CollectibleType.COLLECTIBLE_NEGATIVE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2, CollectibleType.COLLECTIBLE_KEY_PIECE_1, CollectibleType.COLLECTIBLE_KEY_PIECE_2, CollectibleType.COLLECTIBLE_DADS_NOTE, CollectibleType.COLLECTIBLE_EDENS_BLESSING}
	local list = {}
	local startpoint = Isaac.GetItemIdByName("Isaac's Blessing")
	for i=startpoint,Isaac.GetItemIdByName("Jacob and Esau's Blessing")+1,1 do
		table.insert(blacklist,i)
	end

	for i=1,Isaac.GetItemIdByName("Jacob and Esau's Blessing"),1 do
		if getKeyItems then
			for _,b_item in ipairs(blacklist) do
				if i == b_item then goto next end
			end
		end
		
		if player:HasCollectible(i,true) then
			table.insert(list,i)
		end

		::next::
	end

	local s = ""
	for _,v in ipairs(list) do
		s = s .. v .. ", "
	end

	--print(s)

	return list
end

local queues = {}

function mod:onUpdate()

	for i,player in ipairs(GetPlayers()) do
		if (queues[i] ~= nil and player.QueuedItem.Item == nil) then
			local sp = {}
			for i=0,16,1 do
				table.insert(sp,Isaac.GetItemIdByName("Isaac's Blessing")+i)
			end
			if (queues[i].ID == sp[1]) then
				persistent.isaac_blessing = true
				table.insert(persistent.blessing_queue,"isaac")
			elseif (queues[i].ID == sp[2]) then
				player:AddMaxHearts(2)
				player:AddHearts(4)
				table.insert(persistent.blessing_queue,"maggy")
			elseif (queues[i].ID == sp[3]) then
				persistent.cain_luck = persistent.cain_luck + 2
				table.insert(persistent.blessing_queue,"cain")
			elseif (queues[i].ID == sp[4]) then
				persistent.judas_damage = persistent.judas_damage + 1
				table.insert(persistent.blessing_queue,"judas")
			elseif (queues[i].ID == sp[5]) then
				player:AddBlueFlies(12,player.Position,player)
				player:AddPrettyFly()
				table.insert(persistent.blessing_queue,"bluebaby")
			elseif (queues[i].ID == sp[6]) then
				player:AddBlackHearts(2)
				table.insert(persistent.blessing_queue,"eve")
			elseif (queues[i].ID == sp[7]) then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK)
				persistent.samson_rage = true
				table.insert(persistent.blessing_queue,"samson")
			elseif (queues[i].ID == sp[8]) then
				player:AddBlackHearts(2)
				persistent.azazel_speed = persistent.judas_damage + 0.3
				table.insert(persistent.blessing_queue,"azazel")
			elseif (queues[i].ID == sp[9]) then
				Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,0,player.Position,RandomVector()*6,player)
				Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,0,player.Position,RandomVector()*6,player)
				table.insert(persistent.blessing_queue,"lazarus")
			elseif (queues[i].ID == sp[10]) then
				player:UseCard(Card.CARD_HOLY,259)
				persistent.lost_flight = true
				table.insert(persistent.blessing_queue,"lost")
			elseif (queues[i].ID == sp[11]) then
				player:UseCard(Card.CARD_SOUL_LILITH,259)
				table.insert(persistent.blessing_queue,"lilith")
			elseif (queues[i].ID == sp[12]) then
				player:AddCoins(10)
				table.insert(persistent.blessing_queue,"keeper")
			elseif (queues[i].ID == sp[13]) then
				for i=0,4,1 do
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, i+1, player.Position, Vector(0,0), nil)
				end
				player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS,259)
				table.insert(persistent.blessing_queue,"apollyon")
			elseif (queues[i].ID == sp[14]) then
				player:AddBoneHearts(2)
				table.insert(persistent.blessing_queue,"theforgotten")
			elseif (queues[i].ID == sp[15]) then
				for i=0,8,1 do
					player:AddWisp(0,player.Position,false,false)
				end
				table.insert(persistent.blessing_queue,"bethany")
			elseif (queues[i].ID == sp[16]) then
				local item_list = GetItems(player,true)
				local selection = item_list[math.random(#item_list)]
				player:AddCollectible(selection)
				table.insert(persistent.blessing_queue,"jacobandesau"..selection)
			end
			if (queues[i].ID >= Isaac.GetItemIdByName("Isaac's Blessing") and queues[i].ID <= Isaac.GetItemIdByName("Isaac's Blessing")+16) then
				mod:SaveData(json.encode(persistent))
				player:AddCacheFlags(CacheFlag.CACHE_ALL)
				player:EvaluateItems()
			end
			
		end

		queues[i] = player.QueuedItem.Item
	end
end

function mod:onGameStart(isCont)
	if isCont then return end
	persistent.azazel_speed = 0
	persistent.cain_luck = 0
	persistent.judas_damage = 0
	persistent.lost_flight = false
	persistent.isaac_blessing = false
	persistent.samson_rage = false

	local temp = {}

		for _,v in ipairs(persistent.blessing_queue) do
			if v == "isaac" then
				persistent.isaac_blessing_mini = true
			elseif v == "maggy" then
				for i,player in ipairs(GetPlayers()) do
				player:AddMaxHearts(2)
				player:AddHearts(4)
				end
			elseif v == "cain" then
				persistent.cain_luck = persistent.cain_luck + 2
			elseif v == "judas" then
				persistent.judas_damage = persistent.judas_damage + 2
			elseif v == "bluebaby" then
				for i,player in ipairs(GetPlayers()) do
				player:AddBlueFlies(12,player.Position,player)
				player:AddPrettyFly()
				end
			elseif v == "eve" then
				local devilot = Game():GetItemPool():GetCollectible(ItemPoolType.POOL_DEVIL)
				Isaac.GetPlayer():AddCollectible(devilot)
			elseif v == "samson" then
				Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK)
			elseif v == "azazel" then
				persistent.azazel_speed = persistent.azazel_speed + 0.3
			elseif v == "lazarus" then
				Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,0,Isaac.GetPlayer().Position,RandomVector()*6,Isaac.GetPlayer())
				Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,0,Isaac.GetPlayer().Position,RandomVector()*6,Isaac.GetPlayer())
			elseif v == "lost" then
				for i,player in ipairs(GetPlayers()) do
				player:UseCard(Card.CARD_HOLY,259)
				end
				persistent.lost_flight = true
			elseif v == "lilith" then
				Isaac.GetPlayer():UseCard(Card.CARD_SOUL_LILITH,259)
			elseif v == "keeper" then
				Isaac.GetPlayer():AddCoins(10)
				if math.random(3) ~= 1 then
					table.insert(temp,"keeper")
					Isaac.GetPlayer():AddCollectible(Isaac.GetItemIdByName("Keeper's Blessing"))
				end
			elseif v == "apollyon" then
				Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS,259)
			elseif v == "theforgotten" then
				Isaac.GetPlayer():AddBoneHearts(2)
			elseif v == "bethany" then
				for i=0,8,1 do
					Isaac.GetPlayer():AddWisp(0,Isaac.GetPlayer().Position,false,false)
				end
			elseif string.sub(v,1,12) == "jacobandesau" then
				if (tonumber(string.sub(v,13)) ~= nil) then
					Isaac.GetPlayer():AddCollectible(tonumber(string.sub(v,13)))
				end
			end
		
	end
	persistent.blessing_queue = temp
	mod:SaveData(json.encode(persistent))
end

function mod:evalCache(player, flag)
	if (flag == CacheFlag.CACHE_LUCK) then
		player.Luck = player.Luck + persistent.cain_luck
	end
	if (flag == CacheFlag.CACHE_DAMAGE) then
		player.Damage = player.Damage + persistent.judas_damage
	end
	if (flag == CacheFlag.CACHE_SPEED) then
		player.MoveSpeed = math.min(player.MoveSpeed+persistent.azazel_speed,2) 
	end
	if (flag == CacheFlag.CACHE_FLYING and persistent.lost_flight) then
		player.CanFly = true
	end
end

function mod:onNewRoom()
	if Game():GetRoom():IsFirstVisit() and persistent.isaac_blessing then
		Isaac.GetPlayer():UseCard(Card.CARD_SOUL_ISAAC,259)
	end
	for _,entity in ipairs(Isaac.GetRoomEntities()) do
		if (entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and persistent.isaac_blessing_mini) then
			Isaac.GetPlayer():UseCard(Card.CARD_SOUL_ISAAC,259)
			persistent.isaac_blessing_mini = false
			break
		end
	end
end

function mod:onNewFloor()
	if persistent.samson_rage then
		for _,player in ipairs(GetPlayers()) do
			player:UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onGameStart)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.evalCache)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloor)