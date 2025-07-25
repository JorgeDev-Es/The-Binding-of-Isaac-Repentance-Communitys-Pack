-- Function to add a collectible with EID
function addBlessing(collectibleName, descriptionEN, descriptionRU, descriptionUA)
    EID:addCollectible(Isaac.GetItemIdByName(collectibleName), descriptionEN, collectibleName, "en_us")
    EID:addCollectible(Isaac.GetItemIdByName(collectibleName), descriptionRU, collectibleName, "ru")
    EID:addCollectible(Isaac.GetItemIdByName(collectibleName), descriptionUA, collectibleName, "uk_ua")
end

if EID then
    -- Add each blessing using the function
    addBlessing("Isaac's Blessing", 
        "↑ On this run, entering a room with item pedestals has a 20% chance to trigger soul of Isaac {{Card81}}. #Additional 10% chance per pedestal excluding the first one. #{{Luck}} Each point of luck increases the chance by 2%. #↓ The base chance for one pedestal decreases to 10% during your next run.",
        "В этом забеге при входе в комнату с пьедесталами с предметами есть 20% шанс активировать душу Исаака {{Card81}}. #Дополнительно 10% за каждый предмет, кроме первого. #{{Luck}} Каждый пункт удачи увеличивает шанс на 2%. #Базовый шанс для одного пьедестала снижается до 10% в следующем забеге.",
        "У цьому забігу при вході в кімнату з предметами на п’єдесталах є 20% шанс активувати душу Ісаака {{Card81}}. #Додаткові 10% за кожен предмет, окрім першого. #{{Luck}} Кожна одиниця вдачі підвищує шанс на 2%. #Базовий шанс для одного п’єдесталу знижується до 10% у наступному забігу."
    )

    addBlessing("Maggy's Blessing", 
        "↑ +2 Health up.#↑ +3 Health up at the start of your next run.#↑ +2 Health up at the start of the run after that.#↑ +1 Health up at the start of the run after that.#Stacks with itself for up to 10 bonus hearts.",
        "↑ +2 к здоровью.#↑ +3 к здоровью в начале следующего забега.#↑ +2 к здоровью в начале забега после этого.#↑ +1 к здоровью в следующем забеге после этого.#Складывается до 10 бонусных сердец.",
        "↑ +2 здоров'я.#↑ +3 до здоров’я на початку вашого наступного забігу.#↑ +2 до здоров’я на початку забігу після цього.#↑ +1 до здоров’я в забігу після цього.#Складається до 10 бонусних сердець."
    )


    addBlessing("Cain's Blessing", 
        "↑ Each door has a 25% chance to be open. #↑5% chance to open every door in a room including red rooms. #{{Luck}} Luck increases each chance by 2% and 1% per point of luck respectively.",
        "Каждая дверь имеет 25% шанс быть открытой. #5% шанс открыть все двери в комнате, включая красные. #{{Luck}} Каждое очко удачи увеличивает шансы на 2% и 1% соответственно.",
        "Кожні двері мають 25% шанс бути відкритими. #5% шанс відкрити всі двері в кімнаті, включаючи червоні. #{{Luck}} Кожен пункт удачі підвищує ці шанси на 2% та 1% відповідно."
    )


    addBlessing("Judas' Blessing", 
        "↓ Sets the player to one heart.#↑Grants a random quality {{Quality3}} or {{Quality4}} item from the devil pool {{ItemPoolDevil}}.#Grants the same effect at the beginning of the next run.",
        "↓ Устанавливает здоровье игрока на одно сердце.#Дарует случайный предмет качества {{Quality3}} или {{Quality4}} из дьявольского пула {{ItemPoolDevil}}.#Даёт тот же эффект в начале следующего забега.",
        "↓ Встановлює одне серце.#Дарує випадковий предмет якості {{Quality3}} або {{Quality4}} з диявольського пулу {{ItemPoolDevil}}.#Надає той самий ефект на початку наступного забігу."
    )

    addBlessing("???'s Blessing", 
        "↑ All Locked Chests also spawn a completely random pedestal item upon opening.#Applies to this run and the next.",
        "Все запертые сундуки создают случайный предмет на пьедестале при открытии.#Эффект действует в этом и следующем забеге.",
        "Всі зачинені скрині створюють випадковий предмет на п'єдесталі при відкритті.#Діє в цьому та наступному забігу."
    )


    addBlessing("Eve's Blessing", 
        "↑ Spawns a choice of three Devil Deal {{ItemPoolDevil}} items now and at the start of the next run.",
        "↑ Создаёт выбор из трёх предметов {{ItemPoolDevil}} сделки с дьяволом сейчас и в начале следующего забега.",
        "↑ Створює вибір з трьох предметів {{ItemPoolDevil}} угоди з дияволом зараз та на початку наступного забігу."
    )

    addBlessing("Samson's Blessing", 
        "Grants Bloody Lust on pickup and the next run.",
        "Даёт Кровавую ярость при поднятии и в начале следующего забега.",
        "Надає Криваву лють при отриманні та на початку наступного забігу."
    )

    addBlessing("Azazel's Blessing", 
        "↑ During this run and the next, every tear has a 10% chance to be replaced by a Brimstone beam that deals double the player's damage.",
        "↑ В этом и следующем забеге каждая слеза имеет 10% шанс быть заменённой на луч Кровавого лазера, наносящий двойной урон игрока.",
        "↑ У цьому та наступному забігу кожна сльоза має 10% шанс бути заміненою на Промінь Кривавого лазера, що завдає подвійної шкоди гравця."
    )

    addBlessing("Lazarus' Blessing", 
        "Grants and Gulps two random trinkets.#Grants and Gulps two more trinkets at the start of your next run.",
        "Даёт и проглатывает два случайных брелка.#Даёт и проглатывает ещё два брелка в начале следующего забега.",
        "Надає та ковтає дві випадкові дрібнички.#Надає та ковтає ще дві дрібнички на початку наступного забігу."
    )

    addBlessing("The Lost's Blessing", 
        "15% chance each room to grant Holy Mantle until it is lost.",
        "15% шанс в каждой комнате дать Святую Мантию до её потери.",
        "15% шанс у кожній кімнаті надати Святу Мантію до її втрати."
    )
    addBlessing("Lilith's Blessing", 
        "Grants Isaac a random familiar.#Grants another random familiar at the start of your next run. #↑Counts towards Conjoined transformation.#Stacks with itself infinitely",
        "Даёт Исааку случайного спутника.#Даёт другого случайного спутника в начале следующего забега.",
        "Надає Ісааку випадкового фамільяра.#Надає ще одного випадкового фамільяра на початку наступного забігу."
    )

    addBlessing("Keeper's Blessing", 
    "33% chance to spawn 1-3 coins when entering a new room.",
    "33% шанс заспавнить 1-3 монеты при входе в новую комнату",
    "33% шанс на появу 1-3 монет при вході в нову кімнату"
    )

    addBlessing("Apollyon's Blessing", 
    "Gives Void to the pocket slot this run and the next, or the main slot if the pocket slot isn't available. #Spawns two abyss locusts on the next run.",
    "Даёт Вакуум в карманный слот в этом и следующем забеге, или в основной слот, если карманный слот недоступен. #Призывает двух саранч из Бездны в начале следующего забега.",
    "Дає Пустоту в кишеньковий слот у цьому та наступному забігу, або в основний, якщо кишеньковий слот недоступний. #Призиває дві сарани з Безодні на початку наступного забігу."
)

    addBlessing("The Forgotten's Blessing", 
    "Spawns five orbiting bones every room for this run and the next.",
    "Призывает пять вращающихся костей в каждой комнате в этом и следующем забеге.",
    "Призиває п’ять кісток, що обертаються, у кожній кімнаті цього та наступного забігу."
)

    addBlessing("Bethany's Blessing", 
        "Spawns a wisp every room for this run and the next. #30% chance to be a random wisp. #10% chance to be a lemegeton wisp.",
        "Создаёт огонёк в каждой комнате в этом и следующем забеге. #30% шанс, что это будет случайный огонёк. #10% шанс на огонёк Лемегетона.",
        "Створює вогник у кожній кімнаті цього та наступного забігу. #30% шанс, що це буде випадковий вогник. #10% шанс на вогник Лемегетона."
)


    addBlessing("Jacob and Esau's Blessing", 
        "Grants a copy of an item Isaac already has, twice.#Grants a copy of those same items at the start of your next run.",
        "Даёт две копии артефактов, которые уже есть у Исаака.#Даёт копии этих же артефактов в начале следующего забега.",
        "Надає дві копії предметів, які вже є в Ісаака.#Надає копії тих самих предметів на початку наступного забігу."
    )

end

