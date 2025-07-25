local JosephAchievements = {}

local enums = JosephMod.enums
local utility = JosephMod.utility
local JosephChar = JosephMod.josephCharacter


TSIL.SaveManager.AddPersistentVariable(
      JosephMod,
      "CardsUsed",
      {[Card.CARD_FOOL] = false,
      [Card.CARD_MAGICIAN] = false,
      [Card.CARD_HIGH_PRIESTESS] = false,
      [Card.CARD_EMPRESS] = false,
      [Card.CARD_EMPEROR] = false,
      [Card.CARD_HIEROPHANT] = false,
      [Card.CARD_LOVERS] = false,
      [Card.CARD_CHARIOT] = false,
      [Card.CARD_JUSTICE] = false,
      [Card.CARD_HERMIT] = false,
      [Card.CARD_WHEEL_OF_FORTUNE] = false,
      [Card.CARD_STRENGTH] = false,
      [Card.CARD_HANGED_MAN] = false,
      [Card.CARD_DEATH] = false,
      [Card.CARD_TEMPERANCE] = false,
      [Card.CARD_DEVIL] = false,
      [Card.CARD_TOWER] = false,
      [Card.CARD_STARS] = false,
      [Card.CARD_MOON] = false,
      [Card.CARD_SUN] = false,
      [Card.CARD_JUDGEMENT] = false,
      [Card.CARD_WORLD] = false,},
      TSIL.Enums.VariablePersistenceMode.NONE,
      false
)

function JosephAchievements:unlock(unlock, force)
	local gameData = Isaac.GetPersistentGameData()
	if not force then
		if not Game():AchievementUnlocksDisallowed() then
			if not gameData:Unlocked(unlock) then
				gameData:TryUnlock(unlock)
			end
		end
	else
		gameData:TryUnlock(unlock)
	end
end

local function allTrue(table)
    for i = 1, 22, 1 do
        if table[i] ~= true then return false end
    end
    return true
end

function JosephAchievements:UseCard(card, player, flags)
    local gameData = Isaac.GetPersistentGameData()
    if gameData:Unlocked(enums.Achievements.JOSEPH) then return end

    if not (card >= Card.CARD_FOOL and card <= Card.CARD_WORLD) then return end

    local cardsUsed = TSIL.SaveManager.GetPersistentVariable(JosephMod, "CardsUsed")
    cardsUsed[card] = true
    TSIL.SaveManager.SetPersistentVariable(JosephMod, "CardsUsed", cardsUsed)

    if allTrue(cardsUsed) then
        gameData:TryUnlock(enums.Achievements.JOSEPH)
        gameData:TryUnlock(enums.Achievements.THE_AEON)
    end

end
JosephMod:AddCallback(ModCallbacks.MC_USE_CARD, JosephAchievements.UseCard)


function JosephAchievements:LoadFile(saveSlot, isSlotSelected)
    if isSlotSelected ~= true then return end
    local gameData = Isaac.GetPersistentGameData()
    if gameData:Unlocked(enums.Achievements.JOSEPH) then return end

    if gameData:IsBossKilled(BossType.DELIRIUM) or gameData:IsBossKilled(BossType.MOTHER) then
        gameData:TryUnlock(enums.Achievements.JOSEPH)
        gameData:TryUnlock(enums.Achievements.THE_AEON)
    end

end
JosephMod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, JosephAchievements.LoadFile)


function JosephAchievements:UnlockEvent(mark)
    local players = PlayerManager.GetPlayers()
    for key, player in ipairs(players) do
        if player:GetPlayerType() == enums.PlayerType.PLAYER_JOSEPH and not player.Parent then
            local marks = {
                [CompletionType.MOMS_HEART] = nil,
                [CompletionType.ISAAC] = enums.Achievements.SOUL_OF_ENVY,
                [CompletionType.SATAN] = enums.Achievements.POKER_MAT,
                [CompletionType.BOSS_RUSH] = enums.Achievements.CUPPA_JOE,
                [CompletionType.BLUE_BABY] = enums.Achievements.ACE_OF_HEARTS,
                [CompletionType.LAMB] = enums.Achievements.SHREDDER,
                [CompletionType.MEGA_SATAN] = nil,
                [CompletionType.ULTRA_GREED] = enums.Achievements.LIL_SLOTS,
                [CompletionType.ULTRA_GREEDIER] = enums.Achievements.LIL_BLOOD,
                [CompletionType.DELIRIUM] = enums.Achievements.CARD_SLEEVE,
                [CompletionType.MOTHER] = enums.Achievements.EAR_OF_GRAIN,
                [CompletionType.BEAST] = enums.Achievements.SCRAWL,
                [CompletionType.HUSH] = enums.Achievements.CALENDAR,
            }
            if mark == CompletionType.ULTRA_GREEDIER then -- make damn sure greedier unlocks greed too
                -- communityRemix.unlock(marks[CompletionType.ULTRA_GREED])
            end
            if marks[mark] then
                JosephAchievements:unlock(marks[mark])
            end
        end
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, JosephAchievements.UnlockEvent)






