local mod  = RegisterMod("Visible Cards Redux", 1);
local game = Game()


-- LIST OF CARDS TO REPLACE
mod.should_replace_card = {} -- key: card subtype, value: true


function mod:add_cards_skins(list)
	local set = {}
	for key, value in pairs(list) do
		mod.should_replace_card[value] = true
	end
	return set
end

local reskinnedCards = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 42, 44, 46, 48, 52, 53, 54, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 79 }
mod:add_cards_skins(reskinnedCards)

-- CARD TRACKING

mod.CollectedCards = {}

-- TODO saving and loading

-- PATHFINDING (EID)

local pathsChecked = {}
local function AttemptPathfind(card)
	-- skip if already pathfindable
	if pathsChecked[card.InitSeed] then return true end

	local numPlayers = game:GetNumPlayers()
	for i = 0, numPlayers - 1 do
		local player = game:GetPlayer(i)

		if (EID.Config["DisableObstructionOnFlight"] and player.CanFly) then
			pathsChecked[card.InitSeed] = true
			return true
		end

		if EID:HasPathToPosition(player.Position, card.Position) then
			pathsChecked[card.InitSeed] = true
			return true
		end
	end
end

-- reset values
function mod:OnNewFloor()
	pathsChecked = {}
	mod.CollectedCards = {}
end

local newCards = {} --newly spawned cards

function mod:OnCardInit(card)
	if mod.should_replace_card[card.SubType] then
		table.insert(newCards, card)
		if card.SpawnerEntity and card.SpawnerEntity.Type and card.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
			mod.CollectedCards[card.InitSeed] = true
		end
	end
end

-- CARD REPLACEMENT

local cardAnm = "gfx/VisibleCard.anm2"

function mod:UpdateCards()
	for _, card in pairs(newCards) do
		local visible = mod.CollectedCards[card.InitSeed]

		if not visible and EID then
			local descriptionObj = EID:getDescriptionObjByEntity(card)
			if EID:getEntityData(card, "EID_DontHide") ~= true then
				local hideinShop = card:IsShopItem() and (not EID.Config["DisplayCardInfoShop"])
				local isOptionsSpawn = EID.isRepentance and not EID.Config["DisplayCardInfoOptions?"] and
					card.OptionsPickupIndex > 0
				local obstructed = (not EID.Config["DisplayObstructedCardInfo"]) and (not AttemptPathfind(card))
				if not ((isOptionsSpawn or hideinShop or obstructed) and not descriptionObj.ShowWhenUnidentified) then
					mod.CollectedCards[card.InitSeed] = true
					visible = true
				end
			end
		end

		if visible then
			local sprite = card:GetSprite()
			local spritesheet = "gfx/ui/Card_" .. string.format("%02d", card.SubType) .. ".png"
			local appear = sprite:IsPlaying("Appear")


			sprite:Load(cardAnm, false)
			sprite:ReplaceSpritesheet(0, spritesheet)
			sprite:ReplaceSpritesheet(1, spritesheet)
			sprite:LoadGraphics()
			if appear then
				sprite:Play("Appear", true)
			else
				sprite:Play("Idle", true)
			end
			sprite:Update()
		end
	end
	newCards = {}
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.OnNewFloor)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.UpdateCards)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.OnCardInit, PickupVariant.PICKUP_TAROTCARD)
