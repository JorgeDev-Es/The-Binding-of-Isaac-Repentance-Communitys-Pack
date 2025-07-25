local Scrawl = {}
local mod = JosephMod

local enums = JosephMod.enums
local utility = JosephMod.utility

local SCRAWL = enums.Collectibles.SCRAWL


local droppedCard = false
---@param player EntityPlayer
---@param pickup EntityPickup
---@param slot any
function Scrawl:DropCard(player, pickup, slot)
    if Isaac.GetItemConfig():GetCard(pickup.SubType):IsRune() then return end
    if not player:HasCollectible(SCRAWL) then return end
    pickup:Remove()
    local poof = Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
    poof.SpriteScale = poof.SpriteScale/1.5
    SFXManager():Play(SoundEffect.SOUND_SUMMON_POOF, 3, 2, false, 0.5)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_CARD, Scrawl.DropCard)


local droppedPill = false
---@param player EntityPlayer
---@param pickup EntityPickup
---@param slot any
function Scrawl:DropPill(player, pickup, slot)
    if not (player:HasCollectible(SCRAWL) and player:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_BAGGY)) then return end
    pickup:Remove()
    local poof = Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
    poof.SpriteScale = poof.SpriteScale/1.5
    SFXManager():Play(SoundEffect.SOUND_SUMMON_POOF, 3, 2, false, 0.5)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_PILL, Scrawl.DropPill)


---@param player EntityPlayer
function Scrawl:NewRoom(player)
    if Game():GetRoom():IsClear() or not Game():GetRoom():IsFirstVisit() then return end
    if not player:HasCollectible(SCRAWL) then return end
    local rng = player:GetCollectibleRNG(SCRAWL)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_BAGGY) then
        local pill = Game():GetItemPool():GetPill(rng:Next())
        player:AddPill(pill)
        player:AnimatePill(pill, "HideItem")
        SFXManager():Play(SoundEffect.SOUND_SHELLGAME)
    else
        local card = Game():GetItemPool():GetCard(rng:Next(), true, false, false)
        if card == Card.CARD_HIEROPHANT then
            card = Game():GetItemPool():GetCard(rng:Next(), true, false, false)
        end
        player:AddCard(card)
        player:AnimateCard(card, "HideItem")
        SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, Scrawl.NewRoom)


if EID then
    local function HideCardEIDCondition(descObj)
        if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 300 and
        not Isaac.GetItemConfig():GetCard(descObj.ObjSubType):IsRune() and
        PlayerManager.AnyoneHasCollectible(SCRAWL) and
        descObj.Entity ~= nil then
            return true
        end
    end
    local function HideCardEIDCallback(descObj)
        descObj.Name = "{{ColorError}}Unidentified Card"
        descObj.Description = ""
        descObj.Icon = EID.InlineIcons["Card"]
        return descObj
    end

    EID:addDescriptionModifier("Scrawl", HideCardEIDCondition, HideCardEIDCallback)
end


