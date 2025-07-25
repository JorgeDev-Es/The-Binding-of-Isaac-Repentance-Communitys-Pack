local Mod = RepMMod
local json = require("json")
local SaveManager = Mod.saveManager

Mod.RNG = RNG()

local runData = {
	["PortalD6"] = {},
	["SimAxesCollected"] = 1,
	["RedLightSign"] = "GreenLight",
}

local MusicData = { Music = {}, Jingle = {} }
local StartThumbsUp = 1

local prefix = "Repentance Negative "
local MusicTable = {
	[Music.MUSIC_CELLAR] = prefix .. "Cellar",
	[Music.MUSIC_BURNING_BASEMENT] = prefix .. "Burning Basement",
	[Music.MUSIC_CAVES] = prefix .. "Caves",
	[Music.MUSIC_DEPTHS] = prefix .. "Depths",
	[Music.MUSIC_NECROPOLIS] = prefix .. "Necropolis",
	[Music.MUSIC_CATHEDRAL] = prefix .. "Cathedral",
	[Music.MUSIC_WOMB_UTERO] = prefix .. "Womb/Utero",
	[Music.MUSIC_BOSS] = prefix .. "Boss",
	[Music.MUSIC_BOSS2] = prefix .. "Boss (alternate)",
	[Music.MUSIC_BOSS_OVER] = prefix .. "Boss Room (empty)",
	[Music.MUSIC_SHOP_ROOM] = prefix .. "Shop Room",
	[Music.MUSIC_ARCADE_ROOM] = prefix .. "Arcade Room",
	[Music.MUSIC_DOWNPOUR] = prefix .. "Downpour",
	[Music.MUSIC_BOSS3] = prefix .. "Boss (alternate alternate)",
	[Music.MUSIC_DOWNPOUR_REVERSE] = prefix .. "Downpour (reversed)",
	[Music.MUSIC_TITLE_REPENTANCE] = prefix .. "Main Menu",
}

local JingleTable = {
	[Music.MUSIC_JINGLE_BOSS_OVER] = prefix .. "Boss Death (jingle)",
	[Music.MUSIC_JINGLE_SECRETROOM_FIND] = prefix .. "Secret Room Find (jingle)",
	[Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_1] = prefix .. "Treasure Room Entry (jingle) 2",
	[Music.MUSIC_JINGLE_BOSS_OVER2] = prefix .. "Boss Death Alternate (jingle)",
	[Music.MUSIC_JINGLE_BOSS_OVER3] = prefix .. "Boss Death Alternate Alternate (jingle)",
}

SaveManager.Utility.AddDefaultRunData(SaveManager.DefaultSaveKeys.GLOBAL, runData)

function Mod:GameSave()
	return SaveManager.GetPersistentSave()
end

function Mod:RunSave(ent, noHourglass, allowSoulSave)
	return SaveManager.GetRunSave(ent, noHourglass, allowSoulSave)
end

function Mod:FloorSave(ent, noHourglass, allowSoulSave)
	return SaveManager.GetFloorSave(ent, noHourglass, allowSoulSave)
end

function Mod:RoomSave(ent, noHourglass, gridIndex, allowSoulSave)
	return SaveManager.GetRoomSave(ent, noHourglass, gridIndex, allowSoulSave)
end

function Mod:AddDefaultFileSave(key, value)
	Mod:GameSave()[key] = value
	if key == "StartThumbsUp" then
		StartThumbsUp = value
	end
end

function Mod:GetDefaultFileSave(key)
	if SaveManager.Utility.IsDataInitialized() then
		return Mod:GameSave()[key]
	elseif key == "StartThumbsUp" then
		return StartThumbsUp
	end
end

function Mod:SaveGameData()
	if SaveManager.Utility.IsDataInitialized() and SaveManager.IsLoaded() then
		SaveManager.Save()
	elseif Mod:HasData() then
		local data = json.decode(Mod:LoadData())
		data = SaveManager.Utility.PatchSaveFile(
			{ file = { other = { StartThumbsUp = StartThumbsUp, Music = MusicData } } },
			data
		)
		Mod:SaveData(json.encode(data))
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isLoad)
	Mod.RNG:SetSeed(Mod.Game:GetSeeds():GetStartSeed())
	Mod:AnyPlayerDo(function(player)
		Mod:GetData(player).DiliriumEyeLastActivateFrame = 0
	end)
	if not isLoad then
		Mod:AnyPlayerDo(function(player)
			player:AddCacheFlags(CacheFlag.CACHE_ALL)
			player:EvaluateItems()
		end)
	end
end)

local function LoadSettingsData()
	if Mod:HasData() then
		local perData = json.decode(Mod:LoadData())
		if perData and perData.file and perData.file.other then
			if type(perData.file.other.StartThumbsUp) == "number" then
				StartThumbsUp = perData.file.other.StartThumbsUp
			end
			if type(perData.file.other.Music) == "table" then
				MusicData = SaveManager.Utility.PatchSaveFile(perData.file.other.Music, MusicData)
			end
		end
	else
		Mod:SaveData(json.encode({ file = { other = { StartThumbsUp = StartThumbsUp, Music = MusicData } } }))
	end
	if not SoundtrackSongList then
		if
			MusicData.Music[MusicTable[Music.MUSIC_TITLE_REPENTANCE]] == 1
			and MusicManager():GetCurrentMusicID() ~= Isaac.GetMusicIdByName(MusicTable[Music.MUSIC_TITLE_REPENTANCE])
		then
			MusicManager():Play(Isaac.GetMusicIdByName(MusicTable[Music.MUSIC_TITLE_REPENTANCE]), Options.MusicVolume)
		elseif
			MusicData.Music[MusicTable[Music.MUSIC_TITLE_REPENTANCE]] == 2
			and MusicManager():GetCurrentMusicID() == Isaac.GetMusicIdByName(MusicTable[Music.MUSIC_TITLE_REPENTANCE])
		then
			MusicManager():Play(Music.MUSIC_TITLE_REPENTANCE, Options.MusicVolume)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, function(_, _, selected)
	if selected then
		LoadSettingsData()
	end
end)

Mod:AddCallback(SaveManager.SaveCallbacks.PRE_DATA_SAVE, function(_, data)
	local musicData = Mod.GetModdedMusicData()
	local newData = {
		game = {
			run = {
				HiddenItemManager = Mod.hiddenItemManager:GetSaveData(),
			},
		},
		file = {
			other = {
				Music = musicData,
			},
		},
	}
	return SaveManager.Utility.PatchSaveFile(newData, data)
end)

Mod:AddCallback(SaveManager.SaveCallbacks.PRE_DATA_LOAD, function(_, data, luaMod)
	if not luaMod then
		if type(data.file.other.Music) == "table" and data.file.other.Music ~= nil then
			MusicData = data.file.other.Music
		end
		return data
	end
end)

Mod:AddCallback(SaveManager.SaveCallbacks.POST_DATA_LOAD, function(_, data, luaMod)
	if not luaMod then
		Mod.hiddenItemManager:LoadData(data.game.run.HiddenItemManager)
	end
end)

CustomHealthAPI.Library.AddCallback(
	"RestoredHearts",
	CustomHealthAPI.Enums.Callbacks.ON_SAVE,
	0,
	function(save, isSaving)
		if isSaving then
			local chapiSave = Mod:RunSave()
			chapiSave.CustomHealthAPI = save
		end
	end
)

CustomHealthAPI.Library.AddCallback("RestoredHearts", CustomHealthAPI.Enums.Callbacks.ON_LOAD, 0, function()
	local chapiSave = Mod:RunSave()
	if chapiSave.CustomHealthAPI ~= nil and chapiSave.CustomHealthAPI ~= "" then
		return chapiSave.CustomHealthAPI
	end
end)

function Mod.GetModdedMusicData()
	return MusicData
end

function Mod.GetModdedMusicTable()
	return MusicTable, JingleTable
end

function Mod.ChangeFloorMusicTo(id, id2, change)
	if StageAPI and StageAPI.InOverriddenStage() then
		return
	end
	if not change then
		id, id2 = id2, id
	end
	if id == MusicManager():GetCurrentMusicID() then
		MusicManager():Play(id2, Options.MusicVolume)
		Isaac.SetCurrentFloorMusic(id2)
	end
end

local function CheckSoundtrackMenu()
	if SoundtrackSongList then
		AddSoundtrackToMenu("Repentance Negative")
	else
		local function MusicSwitcher(_, id, volumeFade, isFade)
			local newId = id
			if
				MusicTable[id]
				and Isaac.GetMusicIdByName(MusicTable[id]) ~= -1
				and MusicData.Music[MusicTable[id]] == 1
			then
				newId = Isaac.GetMusicIdByName(MusicTable[id])
			end
			return newId
		end
		Mod:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, MusicSwitcher)

		local function JingleSwitcher(_, id)
			local newId = id
			if
				JingleTable[id]
				and Isaac.GetMusicIdByName(JingleTable[id]) ~= -1
				and MusicData.Jingle[JingleTable[id]] == 1
			then
				newId = Isaac.GetMusicIdByName(JingleTable[id])
			end
			return newId
		end
		Mod:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY_JINGLE, JingleSwitcher)
	end
	LoadSettingsData()
end
Mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, CheckSoundtrackMenu)
