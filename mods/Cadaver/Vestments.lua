local Helper = include("Helper")
local Vestments = {}

CollectibleType.COLLECTIBLE_VESTMENTS = Isaac.GetItemIdByName("Vestments")

local VESTMENTS_ITEMS = {
  CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR,
  CollectibleType.COLLECTIBLE_ROSARY,
  CollectibleType.COLLECTIBLE_HALO,
  CollectibleType.COLLECTIBLE_WAFER,
  CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL,
  CollectibleType.COLLECTIBLE_STIGMATA,
  CollectibleType.COLLECTIBLE_SCAPULAR,
  CollectibleType.COLLECTIBLE_HABIT,
  CollectibleType.COLLECTIBLE_CELTIC_CROSS,
  CollectibleType.COLLECTIBLE_MITRE,
  CollectibleType.COLLECTIBLE_HOLY_WATER,
  CollectibleType.COLLECTIBLE_SACRED_HEART,
  CollectibleType.COLLECTIBLE_HOLY_GRAIL,
  CollectibleType.COLLECTIBLE_DEAD_DOVE,
  CollectibleType.COLLECTIBLE_TRINITY_SHIELD,
  CollectibleType.COLLECTIBLE_HOLY_MANTLE,
  CollectibleType.COLLECTIBLE_GODHEAD,
  CollectibleType.COLLECTIBLE_SOUL,
  CollectibleType.COLLECTIBLE_SWORN_PROTECTOR,
  CollectibleType.COLLECTIBLE_HOLY_LIGHT,
  CollectibleType.COLLECTIBLE_CENSER,
  CollectibleType.COLLECTIBLE_SERAPHIM,
  CollectibleType.COLLECTIBLE_SPEAR_OF_DESTINY,
  CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT,
  CollectibleType.COLLECTIBLE_CIRCLE_OF_PROTECTION,
  CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE,
  CollectibleType.COLLECTIBLE_LIL_DELIRIUM,
  CollectibleType.COLLECTIBLE_7_SEALS,
  CollectibleType.COLLECTIBLE_ANGELIC_PRISM,
  CollectibleType.COLLECTIBLE_TRISAGION,
  CollectibleType.COLLECTIBLE_HALLOWED_GROUND,
  CollectibleType.COLLECTIBLE_DIVINE_INTERVENTION,
  CollectibleType.COLLECTIBLE_IMMACULATE_HEART,
  CollectibleType.COLLECTIBLE_MONSTRANCE,
  CollectibleType.COLLECTIBLE_SPIRIT_SWORD,
  CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION,
  CollectibleType.COLLECTIBLE_PURGATORY,
  CollectibleType.COLLECTIBLE_REVELATION,
  CollectibleType.COLLECTIBLE_SOUL_LOCKET
}

local currentVestmentsItem = -1
local vestmentsCostume = Isaac.GetCostumeIdByPath("gfx/characters/vestments.anm2")

function Vestments.Reset(isContinued)
  if not isContinued then
    currentVestmentsItem = -1
  end
end

function Vestments.SaveData()
  return { currentVestmentsItem = currentVestmentsItem }
end

function Vestments.LoadData(table)
  currentVestmentsItem = table.currentVestmentsItem
end

function Vestments.Exit()
  local numPlayers = Game():GetNumPlayers()
  for i = 0, numPlayers do
    local player = Isaac.GetPlayer(i)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_VESTMENTS, true) and currentVestmentsItem > 0 then
      player:RemoveCollectible(currentVestmentsItem)
    end
  end
end

function Vestments.GiveCostume(player)
  player:AddNullCostume(vestmentsCostume)
end

function Vestments.RemoveCostume(player)
  player:TryRemoveNullCostume(vestmentsCostume)
end

function Vestments.UpdateVestmentsEffect(player)
  if player:HasCollectible(CollectibleType.COLLECTIBLE_VESTMENTS, true) and currentVestmentsItem < 0 then
    Vestments.GiveCostume(player)
    Vestments.SwapVestmentsItem()
  elseif not player:HasCollectible(CollectibleType.COLLECTIBLE_VESTMENTS, true) and currentVestmentsItem > 0 then
    player:RemoveCollectible(currentVestmentsItem)
    Vestments.RemoveCostume(player)
  end
end

function Vestments.SwapVestmentsItem()
  local numPlayers = Game():GetNumPlayers()
  for i = 0, numPlayers do
    local player = Isaac.GetPlayer(i)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_VESTMENTS, true) then
      local roomSeedModifier = Game():GetLevel():GetCurrentRoomDesc().SafeGridIndex << 4
      local stageSeedModifier = Game():GetLevel():GetStage()
      local seed = Game():GetSeeds():GetStartSeed() + roomSeedModifier + stageSeedModifier
      math.randomseed(seed)
      
      if currentVestmentsItem > 0 then
        player:RemoveCollectible(currentVestmentsItem, false, ActiveSlot.SLOT_PRIMARY, false)
      end
      currentVestmentsItem = VESTMENTS_ITEMS[math.random(#VESTMENTS_ITEMS)]
      player:AddCollectible(currentVestmentsItem, 0, false)
    end
  end
end

return Vestments