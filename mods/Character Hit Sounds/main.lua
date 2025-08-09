local JSON = require("json")
local SFX = SFXManager()

local TITLE = "Character Hit Sounds"
local TITLE_MCM = "Char. Hit Sounds"

CHS = RegisterMod(TITLE, 1)

local function GetIndexByValue(Table, Value)
	for i, v in ipairs(Table) do
		if v == Value then
			return i
		end
	end
	return nil
end

local function CopyTable(Table)
	local OriginalType = type(Table)
	local Copy
	if OriginalType == 'table' then
		Copy = {}
		for k, v in pairs(Table) do
			Copy[k] = CopyTable(v)
		end
	else
		Copy = Table
	end
	return Copy
end

CHS.PLAYER_NAME = require("scripts.player_name")
CHS.SOUND = require("scripts.sound")
CHS.DEFAULT_SOUND = require("scripts.default_sound")
CHS.DEFAULT_DATA = require("scripts.default_data")
CHS.MCM_STRINGS = require("scripts.mcm_strings")

CHS.Data = CopyTable(CHS.DEFAULT_DATA)

function CHS:CreateMCM()
	ModConfigMenu.AddSetting(TITLE_MCM, nil, {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		Display = "[ RESTORE DEFAULT SETTINGS ]",
		CurrentSetting = function() return false end,
		OnChange = function()
			CHS.Data = CopyTable(CHS.DEFAULT_DATA)
			SFX:Play(SoundEffect.SOUND_FLUSH)
		end,
		Color = {0.62, 0.04, 0.06, 1}
	})

	ModConfigMenu.AddSpace(TITLE_MCM, nil)

	for i, v in ipairs(CHS.MCM_STRINGS.PLAYER) do
		ModConfigMenu.AddTitle(TITLE_MCM, nil, v, {0.08, 0.27, 0.66, 1})
		ModConfigMenu.AddSetting(TITLE_MCM, nil, {
			Type = ModConfigMenu.OptionType.NUMBER,
			Minimum = 1,
			Maximum = #CHS.MCM_STRINGS.HIT,
			Display = function()
				return "Hit: " .. CHS.Data.Config[v].Hit
			end,
			CurrentSetting = function()
				return GetIndexByValue(CHS.MCM_STRINGS.HIT, CHS.Data.Config[v].Hit)
			end,
			OnChange = function(Value)
				local SoundName =  CHS.MCM_STRINGS.HIT[Value]
				CHS.Data.Config[v].Hit = SoundName

				if SoundName == "Default" then SoundName = CHS.DEFAULT_SOUND[v].HIT end

				SFX:Play(SoundEffect.SOUND_PLOP, 0, 1)
				SFX:Play(CHS.SOUND.HIT[SoundName], 0.75)
			end
		})
		ModConfigMenu.AddSetting(TITLE_MCM, nil, {
			Type = ModConfigMenu.OptionType.NUMBER,
			Minimum = 1,
			Maximum = #CHS.MCM_STRINGS.DEATH,
			Display = function()
				return "Death: " .. CHS.Data.Config[v].Death
			end,
			CurrentSetting = function()
				return GetIndexByValue(CHS.MCM_STRINGS.DEATH, CHS.Data.Config[v].Death)
			end,
			OnChange = function(Value)
				local SoundName =  CHS.MCM_STRINGS.DEATH[Value]
				CHS.Data.Config[v].Death = SoundName

				if SoundName == "Default" then SoundName = CHS.DEFAULT_SOUND[v].DEATH end

				SFX:Play(SoundEffect.SOUND_PLOP, 0, 1)
				SFX:Play(CHS.SOUND.DEATH[SoundName], 0.75)
			end
		})
		ModConfigMenu.AddSpace(TITLE_MCM, nil)
	end
end

function CHS:DestroyMCM()
	ModConfigMenu.RemoveCategory(TITLE_MCM)
end

function CHS:PostGameStarted()
	if ModConfigMenu == nil then return end

	if CHS:HasData() then
		local LoadedData = JSON.decode(CHS:LoadData())

		if LoadedData.DATA_VERSION and LoadedData.DATA_VERSION >= CHS.DEFAULT_DATA.DATA_VERSION then
			CHS.Data = LoadedData
		end
	end

	CHS.CreateMCM()
end

function CHS:PreGameExit()
	if ModConfigMenu == nil then return end

	CHS.DestroyMCM()
	CHS:SaveData(JSON.encode(CHS.Data))
end

function CHS:EntityTakeDamage(Entity, Amount, DamageFlags, Source, CountdownFrames)
	local Player = Entity:ToPlayer()
	local PlayerType = Player:GetPlayerType()
	local PlayerName = CHS.PLAYER_NAME[PlayerType]
	if PlayerName == nil then return end

	local SoundName = CHS.Data.Config[PlayerName].Hit

	if SoundName == "Default" then SoundName = CHS.DEFAULT_SOUND[PlayerName].HIT end
	if SoundName == "Isaac" then return end

	SFX:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 0, 1)
	SFX:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT, 0, 1)
	SFX:Play(CHS.SOUND.HIT[SoundName])
end

function CHS:PostEntityKill(Entity)
	local Player = Entity:ToPlayer()
	local PlayerType = Player:GetPlayerType()
	local PlayerName = CHS.PLAYER_NAME[PlayerType]
	if PlayerName == nil then return end

	local SoundName = CHS.Data.Config[PlayerName].Death

	if SoundName == "Default" then SoundName = CHS.DEFAULT_SOUND[PlayerName].DEATH end
	if SoundName == "Isaac" then return end

	SFX:Play(SoundEffect.SOUND_ISAACDIES, 0, 16)
	SFX:Play(CHS.SOUND.DEATH[SoundName])
end

CHS:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CHS.PostGameStarted)
CHS:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, CHS.PreGameExit)
CHS:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CHS.EntityTakeDamage, EntityType.ENTITY_PLAYER)
CHS:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, CHS.PostEntityKill, EntityType.ENTITY_PLAYER)
