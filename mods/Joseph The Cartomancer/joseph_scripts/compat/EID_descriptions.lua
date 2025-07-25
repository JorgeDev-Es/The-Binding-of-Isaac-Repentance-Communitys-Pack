local descriptions = {}

local enums = JosephMod.enums

--[[
    Available Languages:
        -English: "en_us"
        -Russian: "ru"
        -French: "fr"
        -Portuguese: "pt"
        -Spanish: "spa"
        -Polish: "pl"
        -Bulgarian: "bul"
        -Turkish: "turkish"
        -Korean: "ko_kr"
        -Chinese: "zh_cn"

    How to add more descriptions:
        1- Add a new entry in the corresponding list, like this:
            [enums.X.X] = {

            },
        2- Inside those curly braces { } add an entry for each language description, like this:
            [enums.X.X] = {
                language_code =
                    {
                        name = "name",
                        description = "description",
                    },
            },
        3- To add more languages to an item, just add more language entries, like this:
            [enums.X.X] = {
                language_code = {
                        name = "name",
                        description = "description",
                },
                language_code_2 = {
                        name = "name 2",
                        description = "description 2",
                },
            },

    The language_code is the thing between quotes in the language list.
    To check what enum value correspond to the item, check the enums.lua file.
    Don't forget to add all the commas!
]]

local josephType = enums.PlayerType.PLAYER_JOSEPH

--COLLECTIBLE DESCRIPTIONS
descriptions.Collectibles = {
    [enums.Collectibles.LIL_SLOT_MACHINE] = {
        en_us = {
            name = "Lil Slot Machine",
            description = "{{Coin}} Picks up nearby coins#Spawns {{Slotmachine}} Slot Machine drops every 3 coins",
        },
        zh_cn={
            name="小抽奖机",
            description="{{Coin}} 自动拾取附近的硬币#{{Slotmachine}} 每拾取3硬币生成抽奖机奖励",
        },
        ru = {
            name = "Миниатюрная Слот Машина",
            description = "{{Coin}} Летает возле персонажа и собирает монеты#Создаёт выплаты {{Slotmachine}} слот машины каждые 3 собранные монеты",
        },
        spa = {
            name = "Pequeña Máquina Tragaperras",
            description = "{{Coin}} Recoge monedas cercanas#Genera recompensas de {{Slotmachine}} Máquina Tragaperras cada 3 monedas",
        },
    },
	[enums.Collectibles.LIL_FORTUNE_TELLER] = {
		en_us = {
			name = "Lil Fortune Teller",
			description = "{{Coin}} Picks up nearby coins#Spawns {{FortuneTeller}} Fortune Teller drops every 4 coins",
		},
        zh_cn={
            name="小预言机",
            description="{{Coin}} 自动拾取附近的硬币#{{FortuneTeller}} 每拾取4硬币生成预言机奖励",
        },
        ru = {
			name = "Миниатюрный Предсказатель",
			description = "{{Coin}} Летает возле персонажа и собирает монеты#Создаёт выплаты {{FortuneTeller}} автомата с предсказаниями каждые 4 собранные монеты",
        },
        spa = {
			name = "Pequeña Máquina Adivina",
			description = "{{Coin}} Recoge monedas cercanas#Genera recompensas de {{FortuneTeller}} Máquina Adivina cada 3 monedas",
		},
	},
	[enums.Collectibles.LIL_BLOOD_BANK] = {
		en_us = {
			name = "Lil Blood Bank",
			description = "{{Heart}} Picks up nearby Red Hearts#Spawns {{BloodDonationMachine}} Blood Donation Machine drops based on heart value",
		},
        zh_cn={
            name="小献血机",
            description="{{Heart}} 自动拾取附近的红心#{{BloodDonationMachine}} 每半颗心生成献血机奖励",
        },
        ru = {
			name = "Миниатюрный Банк Крови",
			description = "{{Heart}} Летает возле персонажа и собирает красные сердца#Создаёт выплаты {{BloodDonationMachine}} автомата по сдаче крови в зависимости от собранного сердца",
		},
        spa = {
			name = "Pequeñas Máquina de Sangre",
			description = "{{Heart}} Recoge Corazones Rojos cercanos#Genera recompensas de {{BloodDonationMachine}} Máquina de Sangre basadas eb ek valor del corazón",
		},
	},
	[enums.Collectibles.SCRAWL] = {
		en_us = {
			name = "Scrawl",
			description = "{{Card}} Entering an uncleared room gives Isaac a random card#{{Warning}} Cards vanish when dropping them on the floor",
		},
        zh_cn={
            name="施咒卡",
            description="{{Card}} 进入未清理的房间获得一张随机卡牌#!!! 试图丢弃这些卡牌会直接将其销毁",
        },
        ru = {
			name = "Испещрение",
			description = "{{Card}} При входе в незачищенную комнату даёт Айзеку случайную карту#{{Warning}} Карты исчезают сразу после выбрасывании их на пол",
		},
        spa = {
			name = "Garabatos",
			description = "{{Card}} Entrar en una habitación sin limpiar le da a Isaac una carta al azar#{{Warning}} Las cartas desaparecen al caer al suelo",
		},
	},
	[enums.Collectibles.POKER_MAT] = {
		en_us = {
			name = "Poker Mat",
			description = "{{Card}} Spawns a card #{{RedCard}} Playing card effects are doubled or enhanced",
		},
		zh_cn = {
			name = "扑克牌垫",
			description = "{{Card}} 生成一张卡牌#{{RedCard}} 扑克牌效果翻倍或增强",
		},
        ru = {
			name = "Коврик Для Покера",
			description = "{{Card}} Создаёт карту #{{RedCard}} Эффект игральных карт удвоен или усилен",
		},
        spa = {
			name = "Estera de Póquer",
			description = "{{Card}} Genera una carta#{{RedCard}} Los efectos de las cartas de juego son duplicados o mejoran",
		},
	},
	[enums.Collectibles.SOUL_OF_ENVY] = {
		en_us = {
			name = "Soul of Envy",
			description = "↑ +1 damage up for each consumable at a count of 0#the damage up decreases the more pickups Isaac have, returning to +0 at:#{{Blank}} {{Coin}} 15 coins#{{Blank}} {{Bomb}} 5 bombs#{{Blank}} {{Key}} 5 keys",
		},
		zh_cn = {
			name = "嫉妒之魂",
			description = "↑ {{Damage}} 每有一个物资的持有数为0则获得伤害+1#物资越多, 伤害增幅越少, 在达到{{Coin}}15硬币 /  {{Bomb}}5炸弹 / {{Key}}5钥匙时变为+0",
		},
        ru = {
			name = "Душа Зависти",
			description = "↑ +1 урона за каждый пикап значение которого 0#Повышение урона уменьшается за каждый пикап который есть у Айзека вплоть до +0 при:#{{Blank}} {{Coin}} 15 монет#{{Blank}} {{Bomb}} 5 бомб#{{Blank}} {{Key}} 5 ключей",
		},
        spa = {
			name = "Alma de Envidia",
			description = "↑ +1 de daño por cada recolectable con la cuenta de 0#la mejora de daño baja al tener más recolectables, volviendo a +0 con:#{{Blank}} {{Coin}} 15 monedas#{{Blank}} {{Bomb}} 5 bombas#{{Blank}} {{Key}} 5 llaves",
		},
	},
	[enums.Collectibles.CARD_SLEEVE] = {
		en_us = {
			name = "Card Sleeve",
			description = "{{Card}} Consumes the currently held Tarot Card, enchanting it onto Isaac while being held#{{Card}} Enchanting a new card will remove the previous enchant's effect",
		},
		zh_cn = {
			name = "塔罗卡套",
			description = "{{Card}} 消耗持有的塔罗牌, 并将其与角色融合#{{Card}} 只能拥有一张融合卡牌的力量, 后续的卡牌会覆盖已有的",
		},
        ru = {
			name = "Протектор Для Карт",
			description = "{{Card}} Убирает активную карту таро, зачаровывая её на Айзека пока у вас есть этот предмет#{{Card}} Зачарование другой карты заменит эффект предыдущего зачарования",
		},
        spa = {
			name = "Funda de Cartas",
			description = "{{Card}} Consume la carta del Tarot tenida actualmente, encantándola en usaac al ser tenida#{{Card}} Encantar una nueva carta elimina el efecto del encantamiento anterior",
		},
	},
	[enums.Collectibles.CALENDAR] = {
		en_us = {
			name = "Calendar",
			description = "Increases a stat based on the day of the week:",
		},
		zh_cn = {
			name = "日历",
			description = "根据今天是星期几获得属性提升",
		},
        ru = {
			name = "Календарь",
			description = "Повышает характеристику в зависимости от текущего дня недели:",
		},
        spa = {
			name = "Calendar",
			description = "Incrementa una estadística basada en el día de la semana:",
		},
	},
	[enums.Collectibles.SHREDDER] = {
		en_us = {
			name = "Shredder",
			description = "{{Card}} Shreds the currently selected card from Isaac's consumable slot, spawning 5 random pickups and permanently removing that card from the pool for the rest of the run",
		},
		zh_cn = {
			name = "碎纸机",
			description = "{{Card}} 粉碎角色当前副手槽持有的卡牌, 生成5个随机掉落物, 本局内永远不会再出现那张卡",
		},
        ru = {
			name = "Шредер",
			description = "{{Card}} Уничтожает карту в активном слоте расходников Айзека, Создаёт 5 случайных пикапов и перманентно удаляет эту карту из пула карт до конца текущего забега",
		},
        spa = {
			name = "Trituradora",
			description = "{{Card}} Tritura la carta actualemnte seleccionada como consumible, generandp 5 recolectables aleatorios y eliminando permanentemente esa carta de la pool por el resto de la partida",
		},
	},
    [enums.Collectibles.ACE_OF_HEARTS] = {
		en_us = {
			name = "Ace of Hearts",
			description = "{{Heart}} Decreases the spawn rate of hearts by 50%" ..
            "#{{Card}} All heart pickups turn into random cards" ..
            "#{{Card" .. Card.CARD_LOVERS .. "}} Hearts spawned by cards are unaffected",
		},
		zh_cn = {
			name = "红桃王牌",
			description = "!!! 所有的心掉落物被转化#50%转化成卡牌, 50%转化为其他掉落物#不影响由卡牌生成的心掉落物",
		},
        ru = {
			name = "Туз Червей",
			description = "Все пикапы сердца будут заменяться на 50% случайную карту или 50% другой случайный пикап#Сердца {{Heart}} созданные с помощью {{Card}} карт не будут заменяться",
		},
        spa = {
			name = "As de corazones",
			description = "{{Heart}} Disminuye la tasa de aparición de corazones en 50%" ..
            "#{{Card}} Todas las recolectables de corazones se convierten en cartas aleatorias" ..
            "#{{Card" .. Card.CARD_LOVERS .. "}} Los corazones generados por cartas no son afectados",
		},
	},
    [enums.Collectibles.MAGIC_SKIN_SINGLE_USE] = {
		en_us = {
			name = "Magic Skin",
			description = "{{Warning}} SINGLE USE {{Warning}}#Spawns an item from the current room's item pool#{{BrokenHeart}} Turns 1 heart container or 1 Bone Heart or 2 Soul Hearts into a Broken Heart#",
		},
		zh_cn = {
			name = "玄奇驴皮",
			description = "{{Warning}} 一次性 {{Warning}}#生成当前房间道具池的1个道具#{{BrokenHeart}} 将1心之容器或2魂心转换为1碎心",
		},
        ru = {
			name = "Магическая кожа",
			description = "{{Warning}} ОДНОРАЗОВОЕ {{Warning}}#Создаёт предмет пула текущей комнаты#{{BrokenHeart}} Превращает 1 контейнер сердец или 1 костяное сердце или 2 синих сердца в сломанное сердце#",
		},
        spa = {
			name = "Piel Mágica",
			description = "{{Warning}} UN SOLO USO {{Warning}}#Genera un objeto de la pool de objectos de la habitación actual#{{BrokenHeart}} Convierte 1 contenedor de corazón o 1 Corazón de Hueso o 2 corazones de alma en un corazón roto#",
		},
	},
}

descriptions.CalendarDays = {--add some icons for stats being added
    [1] = {
        en_us = "#{{ColorSilver}}Sunday:{{CR}} #↑ +1 Damage",
        zh_cn = "#{{ColorSilver}}周日:{{CR}}#↑ {{Damage}} 伤害+1",
        ru = "#{{ColorSilver}}Воскресенье:{{CR}} #↑ +1 урон",
        spa = "#{{ColorSilver}}Domingo:{{CR}} #↑ +1 de Daño",
    },
    [2] = {
        en_us = "#{{ColorSilver}}Monday:{{CR}} #↑ +0.7 Tears",
        zh_cn = "#{{ColorSilver}}周一:{{CR}} #↑ {{Tears}} 射速+0.7",
        ru = "#{{ColorSilver}}Понедельник:{{CR}} #↑ +0.7 Скорострельности",
        spa = "#{{ColorSilver}}Lunes:{{CR}} #↑ +0.7 de Lágrimas",
    },
    [3] = {
        en_us = "#{{ColorSilver}}Tuesday:{{CR}} #↑ +1 Damage",
        zh_cn = "#{{ColorSilver}}周二:{{CR}} #↑ {{Damage}} 伤害+1",
        ru = "#{{ColorSilver}}Вторник:{{CR}} #↑ +1 Урон",
        spa = "#{{ColorSilver}}Martes:{{CR}} #↑ +1 de Daño",
    },
    [4] = {
        en_us = "#{{ColorSilver}}Wednesday:{{CR}} #↑ +0.3 Speed",
        zh_cn = "#{{ColorSilver}}周三:{{CR}} #↑ {{Speed}} 移速+0.3",
        ru = "#{{ColorSilver}}Среда:{{CR}} #↑ +0.3 Скорости",
        spa = "#{{ColorSilver}}Miércoles:{{CR}} #↑ +0.3 de Velocidad"
    },
    [5] = {
        en_us = "#{{ColorSilver}}Thursday:{{CR}} #↑ +1 Health #{{HealingRed}} Heals 1 heart",
        zh_cn = "#{{ColorSilver}}周四:{{CR}} #↑ {{Heart}} 心之容器+1#{{HealingRed}} 治疗1红心",
        ru = "#{{ColorSilver}}Четверг:{{CR}} #↑ +1 к здоровью #{{HealingRed}} Лечит 1 красное сердце",
        spa = "#{{ColorSilver}}Jueves:{{CR}} #↑ +1 de Vida #{{HealingRed}} Cura 1 Corazón",
    },
    [6] = {
        en_us = "#{{ColorSilver}}Friday:{{CR}} #↑ +1 Health #{{HealingRed}} Heals 1 heart",
        zh_cn = "#{{ColorSilver}}周五:{{CR}} #↑ {{Heart}} 心之容器+1#{{HealingRed}} 治疗1红心",
        ru = "#{{ColorSilver}}Пятница:{{CR}} #↑ +1 к здоровью #{{HealingRed}} Лечит 1 красное сердце",
        spa = "#{{ColorSilver}}Miércoles:{{CR}} #↑ +1 de Vida #{{HealingRed}} Cura 1 Corazón",
    },
    [7] = {
        en_us = "#{{ColorSilver}}Saturday:{{CR}} #↑ +0.7 Tears",
        zh_cn = "#{{ColorSilver}}周六:{{CR}} #↑ {{Tears}} 射速+0.7",
        ru = "#{{ColorSilver}}Суббота:{{CR}} #↑ +0.7 Скорострельности",
        spa = "#{{ColorSilver}}Sábado:{{CR}} #↑ +0.7 de Lágrimas",
    },
}

--TRINKET DESCRIPTIONS
descriptions.Trinkets = {
	[enums.Trinkets.CUPPA_JOE] = {
		en_us = {
			name = "Cup of Joe",
			description = "Copies the effect of the last item you picked up#Changes upon picking up a new item",
		},
		zh_cn = {
			name = "约瑟夫的茶杯",
			description = "复制最后一个拾取的道具的效果",
		},
        ru = {
			name = "Чашка радости",
			description = "Копирует эффект последнего подобранного пассивного предмета",
		},
        spa = {
			name = "Taza de José",
			description = "Copia el efecto del último objeto recolectado#Cambia al recolectar un objeto nuevo",
		},
	},
	[enums.Trinkets.EAR_OF_GRAIN] = {
		en_us = {
			name = "Ear of Grain",
			description = "Famine appears as an additional boss to fight upon entering a {{BossRoom}} boss room. #Defeating Famine drops a bonus {{Collectible73}} cube of meat/{{Collectible207}} ball of bandages #Famine's health scales per floor",
		},
		zh_cn = {
			name = "谷物穗",
			description = "{{BossRoom}} 进入头目房时, 额外与饥荒骑士进行战争#击败饥荒骑士仍会掉落额外的{{Collectible73}} 肉块/{{Collectible207}} 绷带球#饥荒骑士的生命值会动态变化",
		},
        ru = {
			name = "Колос Зерна",
			description = "Голод появляется как дополнительный босс при входе в {{BossRoom}} комнату босса. #При смерти Голод создаст {{Collectible73}} кубик мяса/{{Collectible207}} шар из пластырей #Количество здоровья Голода зависит от текущего этажа",
		},
        spa = {
			name = "Espiga de Trigo",
			description = "Hambruna aparece como un Jefe adicional contra el que luchar al entrar a una {{BossRoom}} Sala de Jefe. #Derrotar a Hamburna suelta un {{Collectible73}} Cubo de Carno/{{Collectible207}} Bola de Vendas adicional#La vida de Hambruna escala con el piso",
		},
	},
}
--PICKUP Cards
descriptions.Cards = {
	[enums.Cards.THE_AEON] = {
		en_us = {
			name = "XX - The Aeon",
			description = "Brings Isaac back to the previous room and reverses all actions done in the room the card was used in",
		},
		zh_cn = {
			name = "XX - 宙",
			description = "{{Collectible422}} 时间倒流回到上一个房间",
		},
        ru = {
			name = "XX - Эон",
			description = "Перенесет вас в предыдущую комнату#Все вокруг восстанавливает свое первоначальное состояние, какое они имели, когда вы были в предыдущей комнате",
		},
        spa = {
			name = "XX - El Eón",
			description = "Regresa a Isaac a la habitación anterior y y revierte todas las acciones hechas en la habitación en la que la carta fue usada",
		},
	},
}

--BIRTHRIGHTS (Dur)
descriptions.Birthrights = {
    [enums.PlayerType.PLAYER_JOSEPH] = {
        en_us = {
            name = "Joseph",
            description = "Adds an additional permanent card enchant slot." ..
            "#The currently enchanted card will automatically be placed into this slot.",
        },
        zh_cn = {
            name = "约瑟夫",
            description = "可以拥有第2张融合卡牌的力量" ..
            "#立即将当前的融合卡牌放到这个额外槽位中"
        },
        ru = {
            name = "Джозеф",
            description = "Добавляет второй перманентный слот для зачарования карты." ..
            "#Текущая зачарованная карта будет автоматически помещена в этот слот.",
        },
        spa = {
            name = "José",
            description = "Añade un espacio adicional permanente para encantar cartas." ..
            "#La carta actualmente encantada se pondrá automáticamente en este espacio.",
        },
    }
}


descriptions.Characters = {
    [enums.PlayerType.PLAYER_JOSEPH] = {
        en_us = {
            name = "Joseph",
            description = "Can carry 2 cards/runes at once"..
            "#Holding down the use button will consume the currently held Tarot Card, enchanting it onto Joseph"..
            "#Enchanting a new card will remove the previous enchant's effect"..
            "#!!! Taking non-self damage will have chance to remove the enchanted card"
        },
        zh_cn = {
            name = "约瑟夫",
            description = "#长按使用键以将选定的塔罗牌融合, 持续获得其力量"..
            "#只能拥有一张融合卡牌的力量, 后续的卡牌会覆盖已有的"..
            "#!!! 受到惩罚伤害有概率失去融合的塔罗牌"
        },
        ru = {
            name = "Джозеф",
            description = "Может носить 2 карты/руны одновременно"..
            "#Зажатие кнопки использования поглотит активную карту Таро, зачаруя её на Джозефа"..
            "#Зачарование новой карты убирает эффект предыдущего зачарования"..
            "#!!! При получении урона не самповреждения с шансом снимает зачарованную карту"
        },
        spa = {
            name = "José",
            description = "Puede llevar 2 cartas/runas a la vez"..
            "#Mantener presionado el botón de uso consumirá la carta del Tarot que se tenga en ese momento, encantándola en José"..
            "#Encantar una nueva carta eliminará el efecto del encantamiento anterior"..
            "#!!! Recibir daño no propio tiene una probabilidad de eliminar la carta encantada"
        },
    }
}

--ENCHANT DESCRIPTIONS
descriptions.Enchants = {
    ENCHANT_HEADER = {
        en_us = {
            description = "{{EnchantIcon}} {{ColorPurpleGlow}}When enchanted: "
        },
        zh_cn = {
            description = "{{EnchantIcon}} {{ColorPurpleGlow}}当融合这张卡时: "
        },
        ru = {
            description = "{{EnchantIcon}} {{ColorPurpleGlow}}Когда зачарована: "
        },
        spa = {
            description = "{{EnchantIcon}} {{ColorPurpleGlow}}Al encantarse: "
        },
    },
    ZERO = {
        en_us = {
            description = "{{Warning}} {{ColorLime}}0%{{CR}} Disenchant Chance "
        },
        zh_cn = {
            description = "{{Warning}} {{ColorLime}}绝对不会{{CR}}受击失效"
        },
        ru = {
            description = "{{Warning}} {{ColorLime}}0%{{CR}} Шанс Потери Зачарования "
        },
        spa = {
            description = "{{Warning}} {{ColorLime}}0%{{CR}} de Probabilidad de Desencantarse "
        },
    },
    LOW = {
        en_us = {
            description = "{{Warning}} {{ColorGreen}}LOW{{CR}} Disenchant Chance"
        },
        zh_cn = {
            description = "{{Warning}} {{ColorGreen}}小概率{{CR}}受击失效"
        },
        ru = {
            description = "{{Warning}} {{ColorGreen}}НИЗКИЙ{{CR}} Шанс Потери Зачарования"
        },
        spa = {
            description = "{{Warning}} {{ColorGreen}}BAJA{{CR}} Probabilidad de Desencantarse"
        },
    },
    MED = {
        en_us = {
            description = "{{Warning}} {{ColorYellow}}MEDIUM{{CR}} Disenchant Chance"
        },
        zh_cn = {
            description = "{{Warning}} {{ColorYellow}}中等概率{{CR}}受击失效"
        },
        ru = {
            description = "{{Warning}} {{ColorYellow}}СРЕДНИЙ{{CR}} Шанс Потери Зачарования"
        },
        spa = {
            description = "{{Warning}} {{ColorYellow}}MEDIA{{CR}} Probabilidad de Desencantarse"
        },
    },
    HIGH = {
        en_us = {
            description = "{{Warning}} {{ColorRed}}HIGH{{CR}} Disenchant Chance"
        },
        zh_cn = {
            description = "{{Warning}} {{ColorRed}}高概率{{CR}}受击失效"
        },
        ru = {
            description = "{{Warning}} {{ColorRed}}ВЫСОКИЙ{{CR}} Шанс Потери Зачарования"
        },
        spa = {
            description = "{{Warning}} {{ColorRed}}ALTA{{CR}} Probabilidad de Desencantars"
        },
    },
    HUNDRED = {
        en_us = {
            description = "{{Warning}} {{ColorRed}}100%{{CR}} Disenchant Chance"
        },
        zh_cn = {
            description = "{{Warning}} {{ColorRed}}受击后立即失效{{CR}}"
        },
        ru = {
            description = "{{Warning}} {{ColorRed}}100%{{CR}} Шанс Потери Зачарования"
        },
        spa = {
            description = "{{Warning}} {{ColorRed}}100%{{CR}} de Probabilidad de Desencantarse"
        },
    },
    [Card.CARD_FOOL] = {
        en_us = {
            description = "Spawns a Portal to an unexplored regular room on room clear"
        },
        zh_cn = {
            description = "清理一个有敌人的房间后, 生成一个前往未探索房间的传送门"
        },
        ru = {
            description = "Создаёт портал в незачищенную обычную комнату при зачистке комнаты"
        },
        spa = {
            description = "Genera un Portal a una habitación sin explorar al limpiar una habitación"
        },
    },
    [Card.CARD_MAGICIAN] = {
        en_us = {
            description = "Homing Tears"
        },
        zh_cn = {
            description = "获得跟踪泪弹"
        },
        ru = {
            description = "Самонаводящиеся Слёзы"
        },
        spa = {
            description = "Lágrimas Teledirigidas"
        },
    },
    [Card.CARD_HIGH_PRIESTESS] = {
        en_us = {
            description = "50% chance for Mom's foot to stomp on an enemy when entering a new room"
        },
        zh_cn = {
            description = "50%的概率在进入房间后触发{{Card3}} 女祭司效果"--50% chance to trigger The High Priestess when entering a new room
        },
        ru = {
            description = "50% шанс активировать верховную жрицу при входе в новую комнату"
        },
    },
    [Card.CARD_EMPRESS] = {
        en_us = {
            description = "↑ {{Speed}} +0.3 Speed#↑ {{Damage}} {{ColorYellow}}+1 Damage"
        },
        zh_cn = {
            description = "↑ {{Speed}} 移速+0.3#↑ {{Damage}} {{ColorYellow}}伤害+1"
        },
        ru = {
            description = "↑ {{Speed}} +0.3 Скорости#↑ {{Damage}} {{ColorYellow}}+1 Урон"
        },
        spa = {
            description = "↑ {{Speed}} Velocidad +0.3#↑ {{Damage}} {{ColorYellow}}Daño +1.5"
        },
    },
    [Card.CARD_EMPEROR] = {
        en_us = {
            description = "{{BossRoom}} Allows Isaac to choose between 2 items after beating a boss"
        },
        zh_cn = {
            description = "{{BossRoom}} 允许头目房道具二选一"
        },
        ru = {
            description = "{{BossRoom}} Даёт Айзеку выбор между 2 предметами после победы над боссом"
        },
        spa = {
            description = "{{BossRoom}} Permite elegir entre 2 objetos al derrotar un jefe"
        },
    },
    [Card.CARD_HIEROPHANT] = {
        en_us = {
            description = "{{SoulHeart}} 13% chance to spawn a bonus Soul Heart on room clear, first room is guaranteed"
        },
        zh_cn = {
            description = "{{SoulHeart}} 13%的概率在清理房间后额外生成魂心(首次清理必定触发)"
        },
        ru = {
            description = "{{SoulHeart}} 13% шанс создать дополнительную награду в виде синего сердца при зачистке комнаты, первая комната гарантированно создаст синее сердце"
        },
        spa = {
            description = "{{SoulHeart}} 13% de probabilidad de generar un Corazón de Alma extra al terminar una habitación, está garantizado en la primera habitación"
        },
    },
    [Card.CARD_LOVERS] = {
        en_us = {
            description = "{{Heart}} 20% chance to spawn a bonus Red Heart on room clear, first room is guaranteed"
        },
        zh_cn = {
            description = "{{Heart}} 20%的概率在清理房间后额外生成红心(首次清理必定触发)"
        },
        ru = {
            description = "{{Heart}} 20% шанс создать дополнительную награду в виде красного сердца при зачистке комнаты, первая комната гарантированно создаст красное сердце"
        },
        spa = {
            description = "{{Heart}} 20% de probabilidad de generar un Corazón Rojo extra al terminar una habitación, está garantizado en la primera habitación"
        },
    },
    [Card.CARD_CHARIOT] = {
        en_us = {
            description = "{{Chargeable}} Activates the effect of {{Card8}} The Chariot by constantly moving for 10 seconds"
        },
        zh_cn = {
            description = "{{Chargeable}} 持续移动10s后触发{{Card8}} 战车的效果"
        },
        ru = {
            description = "{{Chargeable}} Активирует эффект {{Card8}} Колесницы при неприрывном движении в течении 10 секунд"
        },
        spa = {
            description = "{{Chargeable}} Activa el efecto de {{Card8}} El Carruaje al moverse constantemente por 10 segundos"
        },
    },
    [Card.CARD_JUSTICE] = {
        en_us = {
            description = "{{Card9}} 14% chance to proc the effect of Justice on room clear, first room is guaranteed#{{Warning}} Not all pickups may spawn"
        },
        zh_cn = {
            description = "{{Card9}} 14%的概率在清理房间后触发正义的效果(首次清理必定触发)#{{Warning}} 效果可能并不完整"
        },
        ru = {
            description = "{{Card9}} 14% шанс активировать эффект карты Справедливость при зачистке комнаты , первая комната гарантированно активрует эффект#{{Warning}} Не все 4 пикапа могут появиться"
        },
        spa = {
            description = "{{Card9}} 14% de probabilidad de activar el efecto de Justicia al limpiar una habitación, está garantizado en la primera habitación#{{Warning}} No todos los recolectables aparecen"
        },
    },
    [Card.CARD_HERMIT] = {
        en_us = {
            description = "{{Shop}} Opens a trapdoor in every Shop#The trapdoor leads to an underground shop that sells trinkets, runes, cards, special hearts and items from any pool"
        },
        zh_cn = {
            description = "{{Shop}} 在商店内生成1个通往地下商店的暗门, 售卖饰品, 符文, 卡牌, 特殊心和任意道具池的道具"
        },
        ru = {
            description = "{{Shop}} Добавляет люк в каждый магазин#Который ведет во второй магазин в котором продаются брелоки, руны, карты, специальные средца и предметы из любого пула"
        },
        spa = {
            description = "{{Shop}} Abre una trampilla en cada tienda#La trampilla lleva a una tienda subterránea que vende baratijas, runas, cartas, corazones especiales y objetos de cualquier pool"
        },
    },
    [Card.CARD_WHEEL_OF_FORTUNE] = {
        en_us = {
            description = "{{Collectible" .. enums.Collectibles.LIL_SLOT_MACHINE .. "}} Spawns a Lil Slot Machine Familiar#{{Collectible" .. enums.Collectibles.LIL_FORTUNE_TELLER .. "}} or a Lil Fortune Teller Familiar"
        },
        zh_cn = {
            description = "{{Collectible" .. enums.Collectibles.LIL_SLOT_MACHINE .. "}} 生成一个小抽奖机跟班#{{Collectible" .. enums.Collectibles.LIL_FORTUNE_TELLER .. "}} 也有可能出现小预言机跟班"
        },
        ru = {
            description = "{{Collectible" .. enums.Collectibles.LIL_SLOT_MACHINE .. "}} Создаёт Миниатюрную Слот Машину фамильяра #{{Collectible" .. enums.Collectibles.LIL_FORTUNE_TELLER .. "}} или фамильяра Миниатюрного Предсказателя"
        },
        spa = {
            description = "{{Collectible" .. enums.Collectibles.LIL_SLOT_MACHINE .. "}} Genera una Pequeña Máquina Tragaperras Familiar#{{Collectible" .. enums.Collectibles.LIL_FORTUNE_TELLER .. "}} o una Pequeña Máquina Adivina Familiar"
        },
    },
    [Card.CARD_STRENGTH] = {
        en_us = {
            description = "↑ {{Speed}} +0.3 Speed#↑ {{Damage}} +0.3 Damage#↑ {{Damage}} {{ColorYellow}}x1.25 Damage multiplier#↑ {{Range}} +5.25 Range#↑ +0.5 Tear height"
        },
        zh_cn = {
            description = "↑ {{Speed}} 移速+0.3#↑ {{Damage}} 伤害+0.3#↑ {{Damage}} {{ColorYellow}}伤害倍率x1.25#↑ {{Range}} 射程+5.25#↑ 泪弹高度+0.5"
        },
        ru = {
            description = "↑ {{Speed}} +0.3 Скорости#↑ {{Damage}} +0.3 Урона#↑ {{Damage}} {{ColorYellow}}x1.25 Множитель Урона#↑ {{Range}} +5.25 Дальности#↑ +0.5 Высота Полёта Слезы"
        },
        spa = {
            description = "↑ {{Speed}} Velocidad +0.3#↑ {{Damage}} Daño +0.3#↑ {{Damage}} {{ColorYellow}}Daño x1.25#↑{{Range}} Alcance +5.25#↑ Altura de lágrimas +0.5"
        },
    },
    [Card.CARD_HANGED_MAN] = {
        en_us = {
            description = "Permanent Flight"
        },
        zh_cn = {
            description = "永久的飞行"
        },
        ru = {
            description = "Постоянный Полёт"
        },
        spa = {
            description = "Vuelo Permanente"
        },
    },
    [Card.CARD_DEATH] = {
        en_us = {
            description = "{{Collectible265}} Spawns a Dry Baby"
        },
        zh_cn = {
            description = "{{Collectible265}} 生成一个枯骨宝宝"
        },
        ru = {
            description = "{{Collectible265}} Создаёт Высушенного Малыша"
        },
        spa = {
            description = "{{Collectible265}} Genera un Bebé Seco"
        },
    },
    [Card.CARD_TEMPERANCE] = {
        en_us = {
            description = "{{Collectible" .. enums.Collectibles.LIL_BLOOD_BANK .. "}}Spawns a Lil Blood Bank Familiar"
        },
        zh_cn = {
            description = "{{Collectible" .. enums.Collectibles.LIL_BLOOD_BANK .. "}} 生成一个小献血机跟班"
        },
        ru = {
            description = "{{Collectible" .. enums.Collectibles.LIL_BLOOD_BANK .. "}}Создаёт фамильяра Миниатюрный Банк Крови"
        },
        spa = {
            description = "{{Collectible" .. enums.Collectibles.LIL_BLOOD_BANK .. "}}Genera una Máquina de Donación de Sangre Familiar"
        },
    },
    [Card.CARD_DEVIL] = {
        en_us = {
            description = "↑ {{Damage}} {{ColorYellow}}+1.5 Damage"
        },
        zh_cn = {
            description = "↑ {{Damage}} {{ColorYellow}}伤害+1.5"
        },
        ru = {
            description = "↑ {{Damage}} {{ColorYellow}}+1.5 Урона"
        },
        spa = {
            description = "↑ {{Damage}} {{ColorYellow}}Daño +1.5"
        },
    },
    [Card.CARD_TOWER] = {
        en_us = {
            description = "{{Warning}} Taking damage spawns 6 Troll Bombs#The Troll Bombs inherit Isaac's bomb effects"
        },
        zh_cn = {
            description = "{{Warning}} 受伤时, 生成6个即爆炸弹#该炸弹继承角色的炸弹效果"
        },
        ru = {
            description = "{{Warning}} Получение урона создаёт 6 Тролль Бомб#Тролль Бомбы имеют эффекты бомб Айзека"
        },
        spa = {
            description = "{{Warning}} Genera 6 bombas troll al recibir daño#Las bombas copian los efectos de tus bombas"
        },
    },
    [Card.CARD_STARS] = {
        en_us = {
            description = "{{TreasureRoom}} Allows Isaac to choose between 2 items in treasure rooms"
        },
        zh_cn = {
            description = "{{TreasureRoom}} 允许宝箱房道具二选一"
        },
        ru = {
            description = "{{TreasureRoom}} Даёт Айзеку выбор между двумя предметами в комнате сокровищ"
        },
        spa = {
            description = "{{TreasureRoom}} Permite elegir entre 2 objetos en la sala del tesoro"
        },
    },
    [Card.CARD_MOON] = {
        en_us = {
            description = "Adds an extra {{SecretRoom}} Secret Room and {{SuperSecretRoom}} Super Secret Room to each floor#Reveals one Secret Room each floor#{{Timer}} Secret Rooms contain a beam of light that grant for the floor:#↑ {{Tears}} +0.5 Fire rate#↑ {{Tears}} Additional +0.5 Fire rate from the first beam per floor#{{HalfSoulHeart}} Half a Soul Heart"
        },
        zh_cn = {
            description = "每层额外增加1个{{SecretRoom}}隐藏房和{{SuperSecretRoom}}超级隐藏房#每层揭示1个隐藏房#{{Timer}} 隐藏房内有光束, 接触时在本层获得:#↑ {{Tears}} 射速+0.5#↑ {{Tears}} 每层首个光柱额外+0.5射速#{{HalfSoulHeart}} 1半魂心"
        },
        ru = {
            description = "Добавляет дополнительную {{SecretRoom}} Секретную комнату и {{SuperSecretRoom}} Супер Секретную Комнату на каждый этаж#Показывает местоположение одной секретной комнаты#{{Timer}} В секретных комнатах находится луч света который до конца этажа даёт:#↑ {{Tears}} +0.5 Скорострельности#↑ {{Tears}} дополнительно +0.5 Скорострельности за первый луч света на этаже#{{HalfSoulHeart}} Половинку Синего Сердца"
        },
        spa = {
            description = "Agrega una {{SecretRoom}} habitación secreta y una {{SuperSecretRoom}} súper secreta adicional a cada piso#Las habitaciones secretas contienen un rayo de luz que al tocarlo otorga lo siguiente: #↑ {{Tears}} Lágrimas +1 al tocar el primer rayo#↑ {{Tears}} Lágrimas +0.5 al tocar los siguientes rayos#{{HalfSoulHeart}} Medio Corazón de alma"
        },
    },
    [Card.CARD_SUN] = {
        en_us = {
            description = "{{Burning}} Entering a room burns all enemies#When the floor boss is defeated, receive for the floor:#↑ {{Damage}} +3 Damage#↑ {{Luck}} +1 Luck#{{Card20}} The Sun effect#{{Battery}} Fully recharges the active item#{{CurseBlind}} Removes any curses"
        },
        zh_cn = {
            description = "{{Burning}} 进入房间灼烧所有的敌人#击败头目后, 在本层获得:#↑ {{Damage}} 伤害+3#↑ {{Luck}} 幸运+1#{{Card20}} 太阳的效果#{{Battery}} 将主动道具完全充能#{{CurseBlind}} 移除诅咒"
        },
        ru = {
            description = "{{Burning}} При входе в комнату поджигает всех врагов#При убийстве босса этажа, Айзек получает:#↑ {{Damage}} +3 Урона#↑ {{Luck}} +1 Удачу#{{Card20}} Эффект карты Солнце#{{Battery}} Полностью заряжает активный предмет#{{CurseBlind}} Убирает проклятье этажа"
        },
        spa = {
            description = "{{Burning}} Entrar a una habitación quema a todos los enemigos#Al matar al jefe del piso, otorga lo siguiente para el resto del piso:↑{{Damage}} Daño +3#↑ {{Luck}} Suerte +1#{{Card20}} Efecto de el Sol#{{Battery}} Recarga el objeto activo#{{CurseBlind}} Quita todas las maldiciones"
        },
    },
    [Card.CARD_JUDGEMENT] = {
        en_us = {
            description = "{{Collectible144}} Spawns a Bum Friend Familiar#{{Collectible278}} or a Dark Bum Familiar"
        },
        zh_cn = {
            description = "{{Collectible144}} 生成一个乞丐朋友跟班#{{Collectible278}} 或一个黑暗乞丐跟班"
        },
        ru = {
            description = "{{Collectible144}} Создаёт фамильяра попрошайку#{{Collectible278}} или дьявольского попрошайку"
        },
        spa = {
            description = "{{Collectible144}} Genera un Amigo Pordiosero Familiar#{{Collectible278}} o un Pordiosero Oscuro Familiar"
        },
    },
    [Card.CARD_WORLD] = {
        en_us = {
            description = "Full mapping effect for each floor (except {{SuperSecretRoom}} Super Secret Room)"
        },
        zh_cn = {
            description = "揭示每层全图并显示房间类型(无法揭示{{SuperSecretRoom}}超级隐藏房的位置)"
        },
        ru = {
            description = "Полностью раскрывает карту каждого этажа (за исключением {{SuperSecretRoom}} Супер Секретной Комнаты)"
        },
        spa = {
            description = "Revela el mapa del piso actual (excepto la {{SuperSecretRoom}} Habitación Súper Secreta)"
        },
    },
    [Card.CARD_REVERSE_FOOL] = {
        en_us = {
            description = "Taking damage makes Isaac drop 3-5 coins, bombs or keys#The pickups can be replaced with other variants, such as golden keys, nickels, dimes, etc# 40% chance for Coins and bombs to be dropped as {{Collectible74}} The Quarter or {{Collectible19}} Boom! if possible)"
        },
        zh_cn = {
            description = "受到伤害掉落3-5个硬币, 炸弹或钥匙#可能生成变种掉落物#40%的概率尝试掉落{{Collectible74}} 25美分或{{Collectible19}} 砰! 的道具底座"
        },
        ru = {
            description = "При получении урона Айзек роняет 3-5 монет, бомб или ключей#Пикапы могут замениться другим типом того же пикапа, такими как золотой ключ, никель, дайм, и так далее# 40% шанс для монет и бомб выпасть в виде предмета {{Collectible74}} Четвертак или {{Collectible19}} Бум! если хватает пикапов)"
        },
        spa = {
            description = "recibir daño hace que Isaac suelte de 3 a 5 monedas, bombas or llaves#Los recolectables pueden ser reemplazados con otras variantes, como llaves de oro, monedas de cinco y diez centavos, etc# 40% de probabilidad de que las Monedas y Bombas sean soltadas como {{Collectible74}} Un Cuarto o {{Collectible19}} ¡Buum! a ser posible)"
        },
    },
    [Card.CARD_REVERSE_MAGICIAN] = {
        en_us = {
            description = "Grants an aura that repels enemies and projectiles"
        },
        zh_cn = {
            description = "获得一个驱散敌人和敌弹的光环"
        },
        ru = {
            description = "Даёт ауру которая отталкивает врагов и вражеские снаряды"
        },
        spa = {
            description = "Otorga un aura que empuja a enemigos y proyectiles"
        },
    },
    [Card.CARD_REVERSE_HIGH_PRIESTESS] = {
        en_us = {
            description = "{{Card58}} Removes the 60 second time limit from the effect of The Highpriestess? :)"
        },
        zh_cn = {
            description = "{{Card58}} 无限时间的逆位女祭司  :)嘻嘻"
        },
        ru = {
            description = "{{Card58}} Постоянно призывает мамины ноги на персонажа"
        },
        spa = {
            description = "{{Card58}} Quita el límite de 60 segundos del efecto de ¿La Suma Sacerdotisa? :)"
        },
    },
    [Card.CARD_REVERSE_EMPRESS] = {
        en_us = {
            description = "↑ {{Heart}} +2 Health#↑ {{Tears}} {{ColorYellow}}+1 Fire rate#↓ {{Speed}} -0.1 Speed"
        },
        zh_cn = {
            description = "↑ {{Heart}} 临时获得心之容器+2#↑ {{Tears}} {{ColorYellow}}射速修正+1#↓ {{Speed}} 移速-0.1"
        },
        ru = {
            description = "↑ {{Heart}} +2 к здоровью#↑ {{Tears}} {{ColorYellow}}+1 Скорострельности#↓ {{Speed}} -0.1 Скорости"
        },
        spa = {
            description = "↑ {{Heart}} +2 corazones rojos#↑ {{Tears}} {{ColorYellow}}Lágrimas +1#↓ {{Speed}} Velocidad -0.1"
        },
    },
    [Card.CARD_REVERSE_EMPEROR] = {
        en_us = {
            description = "{{Card60}} A Portal leading to The Emperor? Boss Room appears after defeating the Boss of the floor"
        },
        zh_cn = {
            description = "{{Card60}} 击败本层头目后生成一个通往额外头目房的传送门#"
        },
        ru = {
            description = "{{Card60}} Портал ведущий в босс комнату карты Император? появляется после победы над боссом этажа"
        },
        spa = {
            description = "{{Card60}} Un Portal que lleva a la Sala de Jefe de ¿El Emperador? aparece tras derrotar a la Jefe del piso"
        },
    },
    [Card.CARD_REVERSE_HIEROPHANT] = {
        en_us = {
            description = "{{EmptyBoneHeart}} 14% chance to spawn a bone heart on room clear, first room is guaranteed"
        },
        zh_cn = {
            description = "{{EmptyBoneHeart}} 14%的概率在清理房间后额外生成骨心(首次清理必定触发)"
        },
        ru = {
            description = "{{EmptyBoneHeart}} 14% шанс создать дополнительную награду в виде костяного сердца при зачистке комнаты, первая комната гарантированно создаст костяное сердце"
        },
        spa = {
            description = "{{EmptyBoneHeart}} 14% de probabilidad de generar un Corazón de Hueso al terminar una habitación, está garantizado en la primera habitación"
        },
    },
    [Card.CARD_REVERSE_LOVERS] = {
        en_us = {
            description = "{{Collectible642}} Items are sometimes replaced with a Single Use Magic Skin"
        },
        zh_cn = {
            description = "{{Collectible642}} 有概率将道具替换为一次性的玄奇驴皮"
        },
        ru = {
            description = "{{Collectible642}} Предметы иногда заменяются на Волшебную Кожу с одним использованием"
        },
        spa = {
            description = "{{Collectible642}} Los objectos pueden ser reemplazados con una Piel Mágica de 1 Solo Uso"
        },
    },
    [Card.CARD_REVERSE_CHARIOT] = {
        en_us = {
            description = "{{Chargeable}} Activates the effect of {{Card63}} The Chariot? by standing still for 4 seconds"
        },
        zh_cn = {
            description = "{{Chargeable}} 静止不动4s触发{{Card63}}逆位战车的效果"
        },
        ru = {
            description = "{{Chargeable}} Активирует эффект {{Card63}} Колесницы? если не двигаться в течении 4 секунд"
        },
        spa = {
            description = "{{Chargeable}} Activa el efecto de {{Card63}} ¿El Carruaje? permaneciendo quieto durante 4 segundos"
        },
    },
    [Card.CARD_REVERSE_JUSTICE] = {
        en_us = {
            description = "25% chance to replace room clear reward with a gold chest"
        },
        zh_cn = {
            description = "25%的概率将清理房间战利品替换为金箱子"
        },
        ru = {
            description = "25% шанс заменить награду за зачистку комнаты на золотой сундук"
        },
        spa = {
            description = "25% de probabilidad de reemplazar la recompensa al limpiar una habitación con un cofre dorado"
        },
    },
    [Card.CARD_REVERSE_HERMIT] = {
        en_us = {
            description = "Touching any non coin pick up will turn them into a number of coins equal to their Shop value"
        },
        zh_cn = {
            description = "触碰任何非硬币掉落物会将其分解为等价的硬币"
        },
        ru = {
            description = "При касании пикапа не монеты превращает этот пикап в количество монет по стоимости магазина"
        },
        spa = {
            description = "Tocar cualquier recolectable que no sea una moneda los convertire un número de monedas igual a su Valor en la Tienda"
        },
    },
    [Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = {
        en_us = {
            description = "{{DiceRoom}} Spawns a dice room on the floor if possible"
        },
        zh_cn = {
            description = "{{DiceRoom}} 尝试在合适的位置生成骰子房"
        },
        ru = {
            description = "{{DiceRoom}} Создаёт кубик-комнату на этаже если возможно"
        },
        spa = {
            description = "{{DiceRoom}} Genera una sala de dado en el suelo a ser posible"
        },
    },
    [Card.CARD_REVERSE_STRENGTH] = {
        en_us = {
            description = "{{Weakness}} Entering a room weakens all enemies for 10 seconds"
        },
        zh_cn = {
            description = "{{Weakness}} 进入新房间虚弱所有敌人10s"
        },
        ru = {
            description = "{{Weakness}} При входе в комнату накладывает эффект слабости на всех врагов на 10 секунд"
        },
        spa = {
            description = "{{Weakness}} Entrar a una habitación debilita a todos los enemigos por 10 segundos"
        },
    },
    [Card.CARD_REVERSE_HANGED_MAN] = {
        en_us = {
            description = "↓ {{Speed}} -0.1 Speed#Triple shot#{{Coin}} Killed enemies drop vanishing coins"
        },
        zh_cn = {
            description = "↓ {{Speed}} 移速-0.1#三重泪弹#{{Coin}} 击杀的敌人掉落硬币"
        },
        ru = {
            description = "↓ {{Speed}} -0.1 Скорости#Тройной выстрел#{{Coin}} С убитых врагов падают исчезающие монеты"
        },
        spa = {
            description = "↓ {{Speed}} Velocidad -0.1#Disparo triple#{{Coin}} Los enemigos asesinados dejan caer monedas que desaparecen"
        },
    },
    [Card.CARD_REVERSE_DEATH] = {
        en_us = {
            description = "Enemies have a chance to spawn friendly Bone entities or shards on death"
        },
        zh_cn = {
            description = "敌人死亡后有概率生成骨头"
        },
        ru = {
            description = "Враги при смерти могут создать летающие осколки костей или дружелюбного скелета"
        },
        spa = {
            description = "Los enemigos asesinados tienen una probabilidad de generar entidades de hueso o fragmentos amigables"
        },
    },
    [Card.CARD_REVERSE_TEMPERANCE] = {
        en_us = {
            description = "{{Pill}} Entering a new room has a 20% Chance to force Isaac to eat a random pill#{{Collectible252}} Gives the effects of Little Baggy"
        },
        zh_cn = {
            description = "{{Pill}} 进入新房间有20%的概率强制服用一个随机药丸#{{Collectible252}} 获得小药袋的效果"
        },
        ru = {
            description = "{{Pill}} При входе в новую комнату с шансом 20% Айзек использует случайную пилюлю#{{Collectible252}} Даёт эффект предмета Маленький Мешочек"
        },
        spa = {
            description = "{{Pill}} Entrar a una nueva habitación tiene una probabilidad del 20% de obligar a Isaac a comer una píldora al azar#{{Collectible252}} Otorga los efectos de Pequeña Bolsa"
        },
    },
    [Card.CARD_REVERSE_DEVIL] = {
        en_us = {
            description = "Grants Flight#{{Collectible390}} Spawns a Seraphim familiar"
        },
        zh_cn = {
            description = "获得飞行#{{Collectible390}} 生成撒拉弗跟班"
        },
        ru = {
            description = "Даёт полёт#{{Collectible390}} Создаёт фамильяра Серафима"
        },
        spa = {
            description = "Permite volar#{{Collectible390}} Genera un familiar Serafín"
        },
    },
    [Card.CARD_REVERSE_TOWER] = {
        en_us = {
            description = "{{Card72}} Taking damage activates the effect of The Tower?"
        },
        zh_cn = {
            description = "{{Card72}} 受到伤害后触发逆位高塔的效果"
        },
        ru = {
            description = "{{Card72}} При получении урона активирует эффект карты Башня?"
        },
        spa = {
            description = "{{Card72}} Recibir daño activa los efectos de ¿La Torre?"
        },
    },
    [Card.CARD_REVERSE_STARS] = {
        en_us = {
            description = "Hangs a golden sword above Isaac's head, which doubles all pedestal items#{{Warning}} After taking damage, the sword will fall and deal 3 hearts of non-lethal damage to Isaac, rerolling all his passive items#Invincibility effects can prevent the damage, but your items will still be rerolled"
        },
        zh_cn = {
            description = "角色的头顶悬挂金剑, 复制所有的底座道具#{{Warning}} 受到任何伤害会导致金剑立即掉落, 造成3颗心额外伤害(不致死), 重随持有的所有被动道具#无敌效果只会保护你不受到额外伤害, 仍会重随道具"
        },
        ru = {
            description = "Создаёт Золотой меч висящий над головой Айзека, который удваивает все пьедесталы#{{Warning}} После получения урона, меч упадёт и нанесёт не летальный урон в три полных сердца Айзеку, Изменяя все его пассивные предметы#С помощью неуязвимости можно избежать урона но предметы всё равно будут изменены"
        },
        spa = {
            description = "Genera una espada de oro sobre tu cabeza, que duplica los objetos en pedestales#{{Warning}} Tras recibir daño, la espada se cae y hace 3 corazones de daño no letal a Isaac, rerolleando todos sus objetos pasivos#Invincibility effects can prevent the damage, pero tus objectos todavía serán rerolleados"
        },
    },
    [Card.CARD_REVERSE_MOON] = {
        en_us = {
            description = "Clearing a room will create a Red Key room if possible#50% chance to occur when in a red room"
        },
        zh_cn = {
            description = "清理房间后有概率打开一个红房间#在红房间中有50%的概率触发"
        },
        ru = {
            description = "Создаёт проход в красную комнату после зачистки комнаты если возможно#50% шанс на срабатывание в красных комнатах"
        },
        spa = {
            description = "Limpiar una habitación genera una Habitación Roja a ser posiblr#50% de probabilidad dentro de una habitación roja"
        },
    },
    [Card.CARD_REVERSE_SUN] = {
        en_us = {
            description = "#↑ {{Damage}} {{ColorYellow}}+1 Damage#Flight and spectral tears#{{BoneHeart}} Converts heart containers into Bone Hearts (reverts)#{{CurseDarkness}} Curse of Darkness"
        },
        zh_cn = {
            description = "#↑ {{Damage}} {{ColorYellow}}伤害+1#飞行和灵体泪弹#{{BoneHeart}} 心之容器变为骨心(可恢复)#{{CurseDarkness}} 黑暗诅咒"
        },
        ru = {
            description = "#↑ {{Damage}} {{ColorYellow}}+1 Урон#Полёт и спектральные слёзы#{{BoneHeart}} Превращает красные сердца в костяные (Обратимо)#{{CurseDarkness}} Проклятие Темноты"
        },
        spa = {
            description = "#↑ {{Damage}} {{ColorYellow}}Daño +1.5#Permite volar#Lágrimas espectrales#{{BoneHeart}} Convierte los contenedores de corazón en corazones de hueso (reversible)#{{CurseDarkness}} Otorga Maldición de Oscuridad"
        },
    },
    [Card.CARD_REVERSE_JUDGEMENT] = {
        en_us = {
            description = "Item pedestals will now cycle between 2 random items"
        },
        zh_cn = {
            description = "所有底座道具在2个道具之间切换"
        },
        ru = {
            description = "Пьедесталы переключаются между 2 предметами"
        },
        spa = {
            description = "Los objetos en pedestales alternan entre 2 objetos"
        },
    },
    [Card.CARD_REVERSE_WORLD] = {
        en_us = {
            description = "{{LadderRoom}} Spawns a trap door to a crawlspace in the starting room"
        },
        zh_cn = {
            description = "{{LadderRoom}} 每层初始房间生成一个暗门"
        },
        ru = {
            description = "{{LadderRoom}} Создаёт люк в полу в стартовой комнате который ведёт в Ретро сокровищницу"
        },
        spa = {
            description = "{{LadderRoom}} Genera una trampilla a una mazmorra en la primera sala del piso"
        },
    },

}

return descriptions