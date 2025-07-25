local Helper = include("Helper")
local MorgueKey = {}

CollectibleType.COLLECTIBLE_MORGUE_KEY = Isaac.GetItemIdByName("Morgue Key")
local MAX_ITEM_ID = Isaac.GetItemConfig():GetCollectibles().Size - 1
local MORGUE_ROOM_IDS = { 1300, 1301, 1302, 1303 }
local TELPORT_ANIMATION_FRAMES = 14

local ITEM_BLACKLIST = {}
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_NULL] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_POLAROID] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_NEGATIVE] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_KEY_PIECE_1] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_KEY_PIECE_2] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_MOMS_SHOVEL] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_BROKEN_SHOVEL] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_1] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_2] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_DADS_NOTE] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_DOGMA] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_KNIFE_PIECE_1] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_KNIFE_PIECE_2] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_HOLD] = true
ITEM_BLACKLIST[CollectibleType.COLLECTIBLE_BROKEN_GLASS_CANNON] = true

local SHOPKEEPER_SPRITES = {}
SHOPKEEPER_SPRITES[PlayerType.PLAYER_ISAAC] = "gfx/effects/isaac_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_MAGDALENA] = "gfx/effects/mag_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_CAIN] = "gfx/effects/cain_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_JUDAS] = "gfx/effects/judas_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_XXX] = "gfx/effects/xxx_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_EVE] = "gfx/effects/eve_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_SAMSON] = "gfx/effects/samson_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_AZAZEL] = "gfx/effects/azazel_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_LAZARUS] = "gfx/effects/laz_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_EDEN] = "gfx/effects/eden_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_THELOST] = "gfx/effects/lost_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_LAZARUS2] = "gfx/effects/laz_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_BLACKJUDAS] = "gfx/effects/judas_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_LILITH] = "gfx/effects/lilith_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_KEEPER] = "gfx/effects/keeper_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_APOLLYON] = "gfx/effects/apollyon_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_THEFORGOTTEN] = "gfx/effects/forgotten_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_THESOUL] = "gfx/effects/forgotten_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_BETHANY] = "gfx/effects/beth_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_JACOB] = "gfx/effects/jacob_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_ESAU] = "gfx/effects/jacob_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_ISAAC_B] = "gfx/effects/t_isaac_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_MAGDALENA_B] = "gfx/effects/t_mag_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_CAIN_B] = "gfx/effects/t_cain_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_JUDAS_B] = "gfx/effects/t_judas_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_XXX_B] = "gfx/effects/t_xxx_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_EVE_B] = "gfx/effects/t_eve_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_SAMSON_B] = "gfx/effects/t_samson_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_AZAZEL_B] = "gfx/effects/t_azazel_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_LAZARUS_B] = "gfx/effects/t_laz_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_EDEN_B] = "gfx/effects/eden_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_THELOST_B] = "gfx/effects/t_lost_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_LILITH_B] = "gfx/effects/t_lilith_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_KEEPER_B] = "gfx/effects/t_keeper_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_APOLLYON_B] = "gfx/effects/t_apollyon_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_THEFORGOTTEN_B] = "gfx/effects/t_forgotten_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_BETHANY_B] = "gfx/effects/t_beth_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_JACOB_B] = "gfx/effects/t_jacob_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_LAZARUS2_B] = "gfx/effects/t_laz_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_JACOB2_B] = "gfx/effects/t_jacob_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_THESOUL_B] = "gfx/effects/t_forgotten_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_CADAVER] = "gfx/effects/cadaver_shopkeeper.png"
SHOPKEEPER_SPRITES[PlayerType.PLAYER_TAINTED_CADAVER] = "gfx/effects/t_cadaver_shopkeeper.png"

local lastWinItems = {}
local lastCharacter = PlayerType.PLAYER_ISAAC

local morgueItems = {}
local keyUsed = false
local tpCountdown = -1

function MorgueKey.Use(collectibleType, RNG, player, useFlags, slot)
  if Game():GetRoom():GetType() ~= RoomType.ROOM_DUNGEON then
    player:AnimateTeleport(true)
    tpCountdown = TELPORT_ANIMATION_FRAMES
    return { Remove = true, ShowAnim = false }
  end
end

function MorgueKey.UpdateMorgueKeyEffect()
  if tpCountdown > -1 then
    tpCountdown = tpCountdown - 1
  end
  if tpCountdown == 0 then
    Isaac.ExecuteCommand("goto s.supersecret." .. MORGUE_ROOM_IDS[Helper.OneIndexedRandom(CadaverRNG, #MORGUE_ROOM_IDS)])
    keyUsed = true
  end
end

function MorgueKey.InitRoom()
  local room = Game():GetRoom()
  if room:GetType() == RoomType.ROOM_SUPERSECRET and keyUsed then
    local player = Isaac.GetPlayer(0)
    player:AnimateTeleport(false)

    local entities = Isaac:GetRoomEntities()
    for i, entity in ipairs(entities) do
      if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_GRAB_BAG and #morgueItems > 0 then
        local itemIndex = Helper.OneIndexedRandom(CadaverRNG, #morgueItems)
        local pickup = entity:ToPickup()
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, morgueItems[itemIndex], false, false, true)
        pickup.OptionsPickupIndex = 1
        table.remove(morgueItems, itemIndex)
      end

      if entity.Type == EntityType.ENTITY_SHOPKEEPER and (entity.Variant == 0 or entity.Variant == 3) and SHOPKEEPER_SPRITES[lastCharacter] ~= nil then
        local sprite = entity:GetSprite()
        sprite:ReplaceSpritesheet(0, SHOPKEEPER_SPRITES[lastCharacter])
        sprite:LoadGraphics()
      end
    end

    room:GetDoor(DoorSlot.DOWN0):TryBlowOpen(false, nil)
    keyUsed = false
  end
end

function MorgueKey.SaveItems(isGameOver)
  if not isGameOver then
    local player = Isaac.GetPlayer(0)
    lastCharacter = player:GetPlayerType()

    lastWinItems = {}
    for i=1,MAX_ITEM_ID do
      if player:HasCollectible(i) then
        table.insert(lastWinItems, i)
      end
    end
  end
end

function MorgueKey.Reset(isContinued)
  if not isContinued then
    morgueItems = {}
    if #lastWinItems > 0 then
      for i, collectibleType in ipairs(lastWinItems) do
        if not ITEM_BLACKLIST[collectibleType] then
          table.insert(morgueItems, collectibleType)
        end
      end
    end
  end
end

function MorgueKey.LoadData(table)
  if table ~= nil then
    lastWinItems = table.lastWinItems
    lastCharacter = table.lastCharacter
    morgueItems = table.morgueItems
  end
end

function MorgueKey.SaveData()
  return {
    lastWinItems = lastWinItems,
    lastCharacter = lastCharacter,
    morgueItems = morgueItems
  }
end

return MorgueKey