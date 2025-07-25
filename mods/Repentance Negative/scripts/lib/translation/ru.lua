return function(mod)
	local function GI(i)
		return Isaac.GetItemIdByName(i) > 0 and Isaac.GetItemIdByName(i) or Isaac.GetTrinketIdByName(i)
	end

	local Collectible = {
		[GI("Friendly Rocks")] = { ru = { "Дружелюбные камни", "Любитель камней" } },
		[GI("Like")] = { ru = { "Лайк", "Фарм" } },
		[GI("Frozen Flies")] = { ru = { "Морозные мухи", "Они относятся с холодом" } },
		[GI("Frozen Food")] = { ru = { "Замороженная еда", "HP + заморозка мозга" } },
		[GI("Numb Heart")] = { ru = { "Онемевшее сердце", "Многоразовая апатия" } },
		[GI("Book of Tales")] = { ru = { "Книга сказок", "Zzzz..." } },
		[GI("Advanced Kamikaze")] = {
			ru = {
				"Продвинутый Камикадзе",
				"Ну, это имело неприятные последствия...",
			},
		},
		[GI("Lost Shroom")] = { ru = { "Потерянный гриб", "На вкус как носки..." } },
		[GI("Curious Heart")] = { ru = { "Любопытное сердце", "...вместе с Lyte" } },
		[GI("Strawberry Milk")] = {
			ru = { "Клубничное молоко", "Запутайте своих врагов" },
		},
		[GI("Holy shell")] = { ru = { "Святая оболочка", "Помощь свыше!" } },
		[GI("Leaky Bucket")] = { ru = { "Дырявое ведро", "Оно сочится" } },
		[GI("Delirious Tech")] = { ru = { "Технология сумашествия", "Безумная наука" } },
		[GI("Minus")] = { ru = { "Минус", "Не смей брать это!" } },
		[GI("110V")] = { ru = { "110 Вольт", "Высокое напряжение" } },
		[GI("Deliriums Eye")] = { ru = {
			"Глаз сумашествия",
			"У меня двоится в глазах",
		} },
		[GI("Holy Master Key")] = { ru = { "Святая отмычка", "Вечная рулетка" } },
		[GI("Flower Tea")] = { ru = { "Цветочный чай", "Это успокаивает?" } },
		[GI("Faustian Bargain")] = {
			ru = {
				"Фаустова сделка",
				"Все характеристикти+ Но какой ценой?",
			},
		},
		[GI("Sandwich")] = { ru = { "Бутерброд", "Вкусно" } },
		[GI("Necronomicon Vol. 3")] = { ru = { "Некрономикон", "Смерть служит тебе" } },
		[GI("VHS Cassette")] = { ru = { "ВХС Кассета", "Старый фильтр" } },
		[GI("Rot")] = { ru = { "Гниль", "Фуу..." } },
		[GI("Bloody Negative")] = { ru = { "Кровавый минус", "глупый, это минус." } },
		[GI("Siren Horns")] = { ru = { "Рога Сирены", "Подойди поближе" } },
		[GI("How To Dig")] = { ru = { "Как копать", "Время копать!" } },
		[GI("Battered Lighter")] = { ru = { "Потрепанная зажигалка", "Ещё рабочая" } },
		[GI("Holy Lighter")] = { ru = { "Святая зажигалка", "Обратное превращение" } },
		[GI("Portal D6")] = { ru = { "Портальный Д6", "Портал?" } },
		[GI("Saw Shield")] = { ru = { "Пилощит", "Рви их на расстоянии!" } },
		[GI("String Spirit")] = { ru = { "Сильный дух", "Пора решить это!" } },
	}

	local Trinket = {
		[GI("Frozen Polaroid")] = {
			ru = { "Замороженный полароид", "Они сохранили тебя во льду" },
		},
		[GI("Hammer")] = { ru = { "Молоточек", "Глушилка" } },
		[GI("Micro Amplifier")] = { ru = { "Микро усилитель", "СТОП!" } },
		[GI("Burnt Clover")] = { ru = { "Жженый клевер", "Cокровищница удивляет" } },
		[GI("MORE OPTIONS")] = { ru = { "БОЛЬШЕ ОПЦИЙ", "Почему этого нет в игре? :(" } },
		[GI("Pocket Technology")] = {
			ru = { "Карманная технология", "Вроде технология но... нет?" },
		},
		[GI("Ice Penny")] = {
			ru = { "Ледяной пенни", "Богатство холода" },
		},
	}
	local Cards = {
		["Minus Shard"] = { ru = { "Осколок минуса", "Одни плюсы!" } },
		--['']={ru={"",""},},
	}

	local ModTranslate = {
		["Collectibles"] = Collectible,
		["Trinkets"] = Trinket,
		["Cards"] = Cards,
		--['Pills'] = Pills,
	}
	ItemTranslate.AddModTranslation("RepMinus", ModTranslate, { ru = true })
end

--При разрушении камней есть 20% шанс заспавнить каменную дружелюбную какашку    Каждый раз, когда Айзек показывает Лайк, дается прибавка к характеристикам
