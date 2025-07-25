--[[Итак мамкины программисты, кто решил залесть в код мода, то не удивляйтесь его странному оформлению и как он странно написан. 
    Если кто-то шарит за код, то это мой первый опыт]]
--[[So mom’s programmers, who decided to get into the mod’s code, don’t be surprised at its strange design and how strangely it is written.
    If anyone is looking for code, this is my first experience]]

local Mod = RegisterMod("RepentanceNegative", 1.0)
RepMMod = Mod
Mod.Game = Game()
Mod.Room = function() return Mod.Game:GetRoom() end
Mod.Level = function() return Mod.Game:GetLevel() end

local version = ": 1.3" --added by me (pedro), for making updating version number easier
local newRoomFreeze = false

if not REPENTOGON then
	error("REPENTOGON not installed, please download REPENTOGON!")
	return
end
print("Thanks for playing the TBOI REP NEGATIVE [Community Mod] - Currently running version" .. tostring(version))

Mod.saveManager = include("scripts.lib.save_manager")
local SaveManager = Mod.saveManager
SaveManager.Init(Mod)
local MinimapAPI = require("scripts.minimapapi")
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	SaveManager.InitMinimapAPI(MinimapAPI, "RepentanceNegative")
end)
Mod.hiddenItemManager = include("scripts.lib.hidden_item_manager")
Mod.hiddenItemManager:Init(Mod)
Mod.hiddenItemManager:HideCostumes()

---@type table[]
local getData = {}

---Slightly faster than calling GetData, a micromanagement at best
---
---However GetData() is wiped on POST_ENTITY_REMOVE, so this also helps retain the data until after entity removal
---@param ent Entity
---@return table
function Mod:GetData(ent)
	if not ent then return {} end
	local ptrHash = GetPtrHash(ent)
	local data = getData[ptrHash]
	if not data then
		local newData = {}
		getData[ptrHash] = newData
		data = newData
	end
	return data
end

---@param ent Entity
---@return table?
function Mod:TryGetData(ent)
	local ptrHash = GetPtrHash(ent)
	local data = getData[ptrHash]
	return data
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE, function(_, ent)
	getData[GetPtrHash(ent)] = nil
end)

include("scripts.lib.customhealthapi.core")
include("scripts.globals.saveData")
include("scripts.globals.enums")
include("scripts.globals.helpers")
include("scripts.globals.achievements")
include("scripts.lib.hellfirejuneMSHack")

include("scripts.lib.translation.dsssettings")
include("scripts.lib.customhealth")
include("scripts.lib.custom_shockwave_api")
include("scripts.CEAdd")
include("scripts.repentagui")
include("scripts.lib.DSSMenu")

include("scripts.characters.sim")
include("scripts.characters.frosty")
include("scripts.characters.t_frosty")

--ripairs stuff from revel
function ripairs_it(t,i)
	i=i-1
	local v=t[i]
	if v==nil then return v end
	return i,v
end
function ripairs(t)
	return ripairs_it, t, #t+1
end

-- shader crash fix by AgentCucco
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
	if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
		Isaac.ExecuteCommand("reloadshaders")
	end
end)

function Mod:AnyPlayerDo(foo)
	for _, player in ipairs(PlayerManager.GetPlayers()) do
		foo(player)
	end
end

function Mod:SetRoomFreeze(freeze)
	newRoomFreeze = freeze or false
end

function Mod:GetRoomFreeze()
	return newRoomFreeze
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	---@type EntityPlayer Player
	local Player = Isaac.GetPlayer(0)
	---@type Entity Entity
	for _, Entity in pairs(Isaac.GetRoomEntities()) do
		if Entity.Type == EntityType.ENTITY_BONY or Entity.Type == EntityType.ENTITY_BOOMFLY then
			if Entity:HasEntityFlags((1 << 29) + (1 << 8) + (1 << 37) + (1 << 59) + (1 << 19)) then
				Entity.Position = Player.Position
			end
		end
	end
end)

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if newRoomFreeze then
		newRoomFreeze = false
		Mod.Game:SetColorModifier(ColorModifier(0, 0.02, 1, 0.3, 0, 0.8), true, 0.04)
		Isaac.CreateTimer(function()
			Mod.Room():UpdateColorModifier(true, true, 0.03)
		end, 90, 1, false)
	end
end)

local function Anm(_, player)
	if Mod.Game:GetFrameCount() == 1 and Mod:GetDefaultFileSave("StartThumbsUp") ~= 2 then
		player:AnimateHappy()
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Anm)

include("scripts.items.collectibles.advanced_kamikaze")
include("scripts.items.collectibles.sims_axe")

include("scripts.items.collectibles.holy_shell")
include("scripts.items.collectibles.book_of_tales")

include("scripts.items.collectibles.curious_heart")

include("scripts.items.collectibles.strawberry_milk")

include("scripts.items.trinkets.micro_amplifier")

include("scripts.items.collectibles.leaky_bucket")

include("scripts.items.trinkets.burnt_clover")

include("scripts.items.trinkets.pocket_technology")

include("scripts.items.trinkets.more_options")

include("scripts.entities.monsters.dice_garper")

include("scripts.items.collectibles.delirious_tech")

include("scripts.items.collectibles.pixelated_cube")

include("scripts.items.collectibles.beeg_minus")

include("scripts.items.collectibles.110v")

include("scripts.items.collectibles.deliriums_eye")
include("scripts.items.collectibles.flower_tea")
include("scripts.items.collectibles.holy_otmichka")

include("scripts.items.collectibles.deal_of_the_death")

include("scripts.items.collectibles.sandwich")

include("scripts.items.collectibles.book_of_necromancer")

include("scripts.items.collectibles.vhs")

include("scripts.items.trinkets.hammer")

include("scripts.entities.monsters.thumper")

include("scripts.items.collectibles.rot")

include("scripts.items.pick ups.cards.minus_shard")

include("scripts.items.collectibles.frozen_flies")

include("scripts.items.trinkets.frozen_polaroid")

include("scripts.entities.slots.fountain")

include("scripts.challenges.traffic_light")

include("scripts.items.collectibles.friendly_rock")

include("scripts.items.collectibles.like")

include("scripts.challenges.locust_king")

include("scripts.items.pick ups.cards.enhanced_cards")

include("scripts.items.collectibles.sirens_horns")

include("scripts.items.collectibles.how_to_dig")

include("scripts.items.collectibles.battered_lighter")

include("scripts.items.collectibles.holy_lighter")

include("scripts.items.collectibles.saw_shield")

include("scripts.items.trinkets.ice_penny")
include("scripts.items.collectibles.frozen_food")
include("scripts.items.collectibles.numb_heart")
include("scripts.items.pick ups.cards.hammer_card")
include("scripts.items.pick ups.pills.groovy")
include("scripts.items.collectibles.strong_spirit")
include("scripts.items.collectibles.portal_d6")
include("scripts.items.pick ups.chests.eee_chest")

Mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function()
	if TitleMenu.GetSprite():GetFilename() ~= "gfx/ui/main menu/titlemenu_repm.anm2" then
		TitleMenu.GetSprite():Load("gfx/ui/main menu/titlemenu_repm.anm2", true)
		TitleMenu.GetSprite():Play("Idle", true)
	end
end)
----------------------------------------------------------
--EID, keep this at the bottom!!
----------------------------------------------------------

if EID then
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_TSUNDERE_FLY,
		"Spawns two fly orbitals that deflect projectiles#Deflected shots become homing, and freeze any non-boss enemy they touch",
		"Frozen Flies"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_FRIENDLY_ROCKS,
		"Friendly Stone Dips will have a 40% chance to spawn out of rocks when they are broken",
		"Friendly Rocks"
	)
	EID:addCollectible(Mod.RepmTypes.COLLECTIBLE_NUMB_HEART, "On use, adds 1 frozen heart", "Numb Heart")
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_LIKE,
		"{{ArrowUp}} Adds stats when Isaac plays 'Thumbs up' animation",
		"Like"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BOOK_OF_TALES,
		"Guaranteed to create a crawlspace `I am error` room #Lowers the chance of the devil and angel deal",
		"Book of Tales"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_ADVANCED_KAMIKAZE,
		"Spews fire, depending on the number of enemies in the room",
		"Advanced Kamikadze"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_AXE_ACTIVE,
		"Upon use, you swing around an axe, dealing damage to enemies",
		"Sim's Axe"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_CURIOUS_HEART,
		"On use, spawns almost all types of hearts",
		"Curious Heart"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_STRAWBERRY_MILK,
		"Creates puddles when fired #If an enemy steps on a puddle, he will turn into stone#Bosses get the slowness effect",
		"strawberry milk"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_HOLY_SHELL,
		"When fully charged, Isaac fires 4 holy beams",
		"Holy shell"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_LEAKY_BUCKET,
		"Sometimes creates a puddle of holy water under Isaac",
		"Leaky Bucket"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_DELIRIOUS_TECH,
		"Changes your tears into random lasers of tech items # The lasers come with a random modifier, and the lasers change sometimes",
		"Delirious tech"
	)
	-- EID:addCollectible(Mod.RepmTypes.COLLECTIBLE_VACUUM, "Gives 5,25 range#Have a chance to shoot a boomerang tear that deals damage to enemies.", "vacuum" )
	EID:addCollectible(Mod.RepmTypes.COLLECTIBLE_BEEG_MINUS, "Kills player on pick up#Thats litteraly it", "Minus")
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_PIXELATED_CUBE,
		"On use, spawns 3 random familiers on 1 room",
		"Pixelated cube"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_110V,
		"Gives 2 charges for the active item, instead of 1#Damages the player when using the active item",
		"110V"
	)
	EID:addCollectible(Mod.RepmTypes.COLLECTIBLE_DILIRIUM_EYE, "Make your tears fragmented", "Delirium eye")
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_HOLY_OTMICHKA,
		"There is a chance to create a eternal chest after clearing a room.",
		"Holy master key"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_FLOWER_TEA,
		"{{ArrowUp}} {{Blank}} {{Damage}} +0.60 damage#{{ArrowUp}} {{Blank}} {{Range}} +0.50 range#{{ArrowDown}} {{Blank}} {{Shotspeed}} -0.20 shot speed",
		"Flower tea"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_DEAL_OF_THE_DEATH,
		"{{ArrowUp}} {{Blank}} {{Speed}} +0.30 speed#{{ArrowUp}} {{Blank}} {{Damage}} +1 damage#{{ArrowUp}} {{Blank}} {{Tears}} +0.61 tears#{{ArrowUp}} {{Blank}} {{Luck}} +5 luck#{{ArrowDown}} {{Blank}} {{Shotspeed}} -0.10 shot speed#Gives flight and spectral tears#{{DeathMark}} Getting hit kills you",
		"Deal of the death"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_SANDWICH,
		"{{ArrowUp}} {{Blank}} {{Damage}} +0.50 damage#{{ArrowUp}} {{Blank}} {{Tears}} +0.09 tears",
		"Sandwich"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BOOK_OF_NECROMANCER,
		"On use, spawns any charmed skeleton enemies#8% chance to give user a {{EmptyBoneHeart}} bone heart",
		"Book of necromancer"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_VHS,
		"{{ArrowUp}} {{Blank}} {{Speed}} +0.4 speed#{{ArrowUp}} {{Blank}} {{TearsizeSmall}} Gives from 0 to 4 extra tear damage#Gives the screen a vhs effect for the rest of the run#More copies make effect stronger",
		"VHS cassette"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_ROT,
		"When entering a room, the player leaves a poisonous clouds that follows him#Effect last for 6 seconds",
		"Rot"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BLOODY_NEGATIVE,
		"{{ArrowUp}} On use, removes {{EmptyHeart}} 1 heart container, but in return it gives {{Speed}} +0.15 speed, {{Tears}} +0.20 tears, {{Damage}} +0.20 damage and {{Range}} range#{{ArrowUp}} If you use the active again, the added characteristics are multiplied by 2",
		"Bloddy negative"
	)
	EID:addCollectible(Mod.RepmTypes.COLLECTIBLE_FROZEN_FOOD, "+1 Frozen heart", "Frozen Food")
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_SIREN_HORNS,
		"{{Chargeable}} When fully charged, Isaac begins to sing to charm enemies#Сharmed enemies give familiars small buff on death",
		"Siren Horns"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_HOW_TO_DIG,
		"Isaac burrows underground with the ability to break stones and doors #Monsters cannot attack him",
		"How To Dig"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BATTERED_LIGHTER,
		"Lights fires if Isaac is near him",
		"Battered Lighter"
	)
	EID:addCollectible(Mod.RepmTypes.COLLECTIBLE_HOLY_LIGHTER, "Reverse transformation", "Holy Lighter")

	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_PORTAL_D6,
		"When used, it sucks in all pickups and objects#!!! All items previosly affected Portal D6 will back, but rerolled on another pool of room in this stage",
		"Portal D6"
	)

	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_SAW_SHIELD,
		"{{Throwable}} Creates throwable shield with saws#After being thrown, flies and bownces of the walls and rocks#After "
			.. Mod.sawShieldBounces
			.. " bounces shield slows down#After full stop will return automatically to thrower after "
			.. Mod.sawShieldReturnCooldown
			.. " seconds if not picked up#{{BleedingOut}} Enemies hit by shield can get bleeding",
		"Saw Shield"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_STRONG_SPIRIT,
		"Taking fatal damage invokes the effects of {{Collectible58}} Book of Shadows, heals {{Heart}} 2 full Red Heart containers, and adds a {{SoulHeart}} Soul Heart#Taking fatal also grants {{ArrowUp}} {{Blank}} {{Damage}} +5 flat damage which fades over the course of 20 seconds#The effect can be triggered once per floor. Its availability is indicated by a white halo high above Isaac's head",
		"Strong Spirit"
	)

	--ru
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_TSUNDERE_FLY,
		"Создает двух орбитальных мух, которые отражают снаряды.#Отражённые выстрелы становятся самонаводящимися и замораживают любого врага (кроме боссов), которого они касаются",
		"Морозные мухи",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_FRIENDLY_ROCKS,
		"Дружелюбные камни-какашки, могут появится из разрушенных камней с вероятностью 40%",
		"Дружелюбные камни",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_NUMB_HEART,
		"При использовании даёт 1 замороженное сердце",
		"Онемевшее сердце",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_LIKE,
		"{{ArrowUp}} Дает прибавку к характеристикам, когда Айзек проигрывает анимацию большого пальца",
		"Лайк",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BOOK_OF_TALES,
		"Гарантировано создаёт подполье с комнатой: «Я ошибка». # Снижает вероятность сделки дьявола и ангела",
		"Книга сказок",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_ADVANCED_KAMIKAZE,
		"Извергает огонь от Айзека в зависимости от количества врагов в комнате",
		"Продвинутый Камикадзе",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_AXE_ACTIVE,
		"При использовании вы размахиваете топором",
		"Топор Сима",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_CURIOUS_HEART,
		"При использовании создает почти все типы сердец",
		"Любопытное сердце",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_STRAWBERRY_MILK,
		"Создает лужи при выстреле#Если враг наступит на лужу, то он превратится в камень#Боссы получат эффект замедления",
		"Клубничное молоко",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_HOLY_SHELL,
		"При полной зарядке Айзек выпускает 4 святых луча",
		"Святая оболочка",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_LEAKY_BUCKET,
		"Иногда создает лужу святой воды под Айзеком",
		"Дырявое ведро",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_DELIRIOUS_TECH,
		"Превращает ваши слезы в случайные лазеры технологий # Лазеры имеют случайный модификатор",
		"Технология сумашествия",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BEEG_MINUS,
		"Убивает игрока при поднятии#Буквально",
		"Минус",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_PIXELATED_CUBE,
		"При использовании создает 3 случайных фамильяров в 1 комнате",
		"Пиксилизированый куб",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_110V,
		"Заряжает предмет на 2 деления вместо 1#Наносит урон игроку при использовании активного предмета",
		"110 Вольт",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_DILIRIUM_EYE,
		"При подборе дает 1 треснутое сердце {{BrokenHeart}}, и случайный тип слезы со случайным эффектом #{{Warning}}Всего 3 раза{{Warning}}",
		"Глаз сумашествия",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_HOLY_OTMICHKA,
		"Есть шанс создать вечный сундук после зачистки комнаты",
		"Святая отмычка",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_FLOWER_TEA,
		"{{ArrowUp}} {{Blank}} {{Damage}} +0.60 урона, {{ArrowUp}} {{Blank}} {{Range}} -0.50 дальность#{{ArrowDown}}#{{ArrowDown}} {{Blank}} {{Shotspeed}} -0.20 скорость слезы",
		"Цветочный чай",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_DEAL_OF_THE_DEATH,
		"{{ArrowUp}} {{Blank}} {{Damage}} +1 к урону#{{ArrowUp}} {{Blank}} {{Luck}} +5 удачи#{{ArrowUp}} {{Blank}} {{Tears}} +0.61 к скорострельности#{{ArrowUp}} {{Blank}} {{Speed}} +0.30 скорости#{{ArrowDown}} {{Blank}} {{Shotspeed}} -0.10 к скорости слезы#Дает полет и призрачные слезы#{{DeathMark}} Убивает при получении любого урона",
		"Сделка со смертью",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_SANDWICH,
		"{{ArrowUp}} {{Blank}} {{Damage}} +0.50 урона# {{ArrowUp}} {{Blank}} {{Tears}} +0.09 к скорострельности",
		"Бутерброд",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BOOK_OF_NECROMANCER,
		"При использовании создает дружелюбных скелетов#8% шанс дать Айзеку {{EmptyBoneHeart}} костяное сердце",
		"Книга некроманта",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_VHS,
		"{{ArrowUp}} {{Blank}} {{Speed}} +0.4 скорости#{{ArrowUp}} {{Blank}} {{TearsizeSmall}} Дает от 0 до 4 дополнительного урона слезы#Придает экрану эффект Кассеты до конца забега#Чем больше кассет, тем сильнее эффект",
		"ВХС Кассета",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_ROT,
		"При входе в комнату игрок оставляет за собой ядовитые облака #Эффект длится 6 секунд",
		"Гниль",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BLOODY_NEGATIVE,
		"{{ArrowUp}} При использовании убирает {{EmptyHeart}} 1 контейнер сердца, но взамен дает {{Speed}} +0.15 скорости, {{Tears}} +0.20 скорострельность, {{Damage}} +0.20 урона и {{Range}} дальности действия#{{ArrowUp}} При повторном использовании активки добавленные характеристики умножаются на 2",
		"Кровавый минус",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_FROZEN_FOOD,
		"+1 Лдеяное сердце",
		"Замороженная еда",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_SIREN_HORNS,
		"{{Chargeable}} При полной зарядке Айзек начинает петь, очаровывая врагов#Очарованные враги при смерти дают небольшой бонус фамильярам",
		"Рога сирены",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_HOW_TO_DIG,
		"Айзек закапывается под землю с возможностью ломать камни и двери #Монстры не могут на него напасть",
		"Как копать",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_BATTERED_LIGHTER,
		"Зажигает костры, если Айзек рядом с ним",
		"Потрепанная зажигалка",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_HOLY_LIGHTER,
		"Обратная трансформация",
		"Святая зажигалка",
		"ru"
	)
	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_PORTAL_D6,
		"При использовании засасывает все пикапы и предметы#!!! Все ранее всосанные предметы появятся в этой комнате, но будут переролены в другой предмет другого пула одной из комнат на этаже",
		"Портальный Д6",
		"ru"
	)

	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_SAW_SHIELD,
		"{{Throwable}} Создает щит с лезвиями, который можно бросать#После броска летает и отскакивает от стен и камней#После "
			.. Mod.sawShieldBounces
			.. " отскоков замедляется#После полной остановки возвращается к бросившему игроку после "
			.. Mod.sawShieldReturnCooldown
			.. " секунд, если его не подобрать#{{BleedingOut}} Враги могут начать истекать кровью при получении урона",
		"Пилощит",
		"ru"
	)

	EID:addCollectible(
		Mod.RepmTypes.COLLECTIBLE_STRONG_SPIRIT,
		"Получение смертельного урона вызывает эффект {{Collectible58}} Книги теней, исцеляет {{Heart}} 2 полных контейнера красного сердца и добавляет {{SoulHeart}} сердце души#Получение смертельного урона также дает {{ArrowUp}} {{Blank}} {{Damage}} +5 урона, который исчезает в течение 20 секунд#Эффект может быть вызван один раз за этаж. На его наличие указывает белый ореол над головой Айзека",
		"Сильный дух",
		"ru"
	)

	--trinkets
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_POCKET_TECHNOLOGY,
		"Increases damage taken by champion monsters",
		"Pocket Technology"
	)
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_MICRO_AMPLIFIER,
		"Each new floor adds 1 characteristic#Only 1 characteristic changes",
		"Micro Amplifier"
	)
	EID:addTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID, "???", "Frozen Polaroid")
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_BURNT_CLOVER,
		"{{Warning}}Disposable{{Warning}}#When entering the treasure room{{TreasureRoom}}, the item is replaced with an item with quality{{Quality4}}",
		"Burnt Clover"
	)
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_MORE_OPTIONS,
		"Creates a special item next to goods for 30 cents in the shop{{Shop}}",
		"MORE OPTIONS"
	)
	EID:addTrinket(Mod.RepmTypes.TRINKET_HAMMER, "Аllows you to destroy stones using tears", "Hammer")
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_ICE_PENNY,
		"Picking up coins has chance to spawn half ice heart. Rarely full one",
		"Ice Penny"
	)
	--ru
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_POCKET_TECHNOLOGY,
		"Увеличивает получаемый урон монстрам-чемпионам",
		"Карманная технология",
		"ru"
	)
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_MICRO_AMPLIFIER,
		"Каждый новый этаж прибавляет 1 характеристику#Меняется только 1 характеристика",
		"Микро усилитель",
		"ru"
	)
	EID:addTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID, "???", "Замороженный полароид", "ru")
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_BURNT_CLOVER,
		"{{Warning}}Одноразовый{{Warning}}#При входе в сокровищницу{{TreasureRoom}} предмет заменяется предметом с качеством{{Quality4}}",
		"Жженый клевер",
		"ru"
	)
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_MORE_OPTIONS,
		"Cоздает рядом с товарами особый предмет за 30 центов в магазине{{Shop}}",
		"БОЛЬШЕ ОПЦИЙ",
		"ru"
	)
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_HAMMER,
		"Позволяет разрушать камни с помощью слез",
		"Молоточек",
		"ru"
	)
	EID:addTrinket(
		Mod.RepmTypes.TRINKET_ICE_PENNY,
		"Шанс заспавнить половинку ледяного серца при подборе монет. Реже - полное ледяное сердце",
		"Ледяной пенни",
		"ru"
	)
end

local ItemTranslate = include("scripts.lib.translation.ItemTranslation")
ItemTranslate("RepMinus")

local translations = {
	"ru",
}
for i = 1, #translations do
	local module = include("scripts.lib.translation." .. translations[i])
	module(Mod)
end

--example:
--EID:addCollectible(id of the item, "description of the item", "item name", "en_us(language)")
