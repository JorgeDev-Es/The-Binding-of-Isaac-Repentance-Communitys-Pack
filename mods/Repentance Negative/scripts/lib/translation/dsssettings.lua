local strings = {
	Title = {
		en = "Rep-",
		es = "Rep-",
	},
	resume_game = {
		en = "Resume game",
		ru = "Вернуться в игру",
	},
	settings = {
		en = "Settings",
		ru = "Настройки",
	},
	yes = {
		en = "Yes",
		ru = "Да",
	},
	no = {
		en = "No",
		ru = "Нет",
	},
	enable = {
		en = "Enable",
		ru = "Включить",
	},
	disable = {
		en = "Disable",
		ru = "Выключить",
	},
	enabled = {
		en = "Enabled",
		ru = "Включен",
	},
	disabled = {
		en = "Disabled",
		ru = "Выключен",
	},
	startTooltip = {
		en = DeadSeaScrollsMenu and DeadSeaScrollsMenu.menuOpenToolTip or {
			strset = { "toggle menu", "", "keyboard:", "[c] or [f1]", "", "controller:", "press analog" },
			fsize = 2,
		},
		ru = {
			strset = {
				"переключение",
				"меню",
				"",
				"клавиатура:",
				"[c] или [f1]",
				"",
				"контроллер:",
				"нажатие",
				"на стик",
			},
			fsize = 2,
		},
	},
	unlock_manager = {
		en = "Unlock manager",
		ru = "Mенеджер анлоков"
	},
	unlocks = {
		en = "Unlocks",
		ru = "Анлоки"
	},
	unlocked = {
		en = "Unlocked",
		ru = "Разблокировано"
	},
	locked = {
		en = "Locked",
		ru = "Заблокировано"
	},
	unlock = {
		en = "Unlock all",
		ru = "Разблокировать все"
	},
	lock = {
		en = "Lock all",
		ru = "Заблокировать все"
	},
	thumbs_up = {
		en = "Thumbs up",
		--ru = "режим рюкзака",
	},
	tu_var1 = {
		en = "On",
		--ru = "взрывать особые",
	},
	tu_var2 = {
		en = "Off",
		--ru = "бомбы в руки",
	},
	music_manager = {
		en = "Music manager",
		ru = "Менеджер музыки",
	},
	music_settings = {
		en = "Music settings",
		ru = "Настройки музыки",
	},
	jingle_settings = {
		en = "Jingle settings",
		ru = "Настройки джинглов",
	},
	enable_all_music = {
		en = "Enable all music and jingles",
		ru = "Включить всю музыку и джинглы",
	},
	disable_all_music = {
		en = "Disable all music and jingles",
		ru = "Выключить всю музыку и джинглы",
	},
	other_settings = {
		en = "Other settings",
		ru = "Другие настройки",
	},
	happy_start = {
		en = "Happy start",
		ru = "Счастливый старт",
	},
	music_button_enable = {
		en = "Enables all mod's music and jingles",
		ru = "Включает всю музыку и джинглы из мода",
	},
	music_button_disable = {
		en = "Disables all mod's music and jingles",
		ru = "Выключает всю музыку и джинглы из мода",
	},
}

function RepMMod.GetDSSStr(str, lower)
	lower = lower == nil and true or lower
	local tmpstr = strings
	local returnstr = tmpstr[str] and (tmpstr[str][Options.Language] or tmpstr[str].en) or str
	return (lower and type(returnstr) == "string") and returnstr:lower() or returnstr
end

function RepMMod.SplitString(str, size)
	local endTable = {}
	size = size or 15
	local currentString = ""
	for w in str:gmatch("%S+") do
		local newString = currentString .. w .. " "
		if newString:len() >= size then
			table.insert(endTable, currentString)
			currentString = ""
		end

		currentString = currentString .. w .. " "
	end

	table.insert(endTable, currentString)
	return endTable
end
