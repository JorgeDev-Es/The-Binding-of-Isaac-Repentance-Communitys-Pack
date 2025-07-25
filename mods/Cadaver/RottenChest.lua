local Helper = include("Helper")
local RottenChest = {}

PickupVariant.PICKUP_ROTTENCHEST = Isaac.GetEntityVariantByName("Rotten Chest")

local MyChestSubType = {
  CLOSED = 0,
  OPEN = 1
}

local ROTTEN_CHEST_TRINKETS = {
  TrinketType.TRINKET_FISH_HEAD,
  TrinketType.TRINKET_FISH_TAIL,
  TrinketType.TRINKET_LUCKY_TOE,
  TrinketType.TRINKET_ROTTEN_PENNY,
  TrinketType.TRINKET_APPLE_OF_SODOM,
  TrinketType.TRINKET_PROBIOTICS
}

function RottenChest.RemoveOpenChests()
  local entities = Isaac:GetRoomEntities()
  for i, entity in ipairs(entities) do
    if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_ROTTENCHEST and entity.SubType == MyChestSubType.OPEN then
      entity:Remove()
    end
  end
end

function RottenChest.ReplaceChests(pickup)
  local stage = Game():GetLevel():GetStage()
  CadaverItemRNG:SetSeed(pickup.DropSeed, 0)
  if CadaverAchievements.RottenChest and stage ~= LevelStage.STAGE6 and Game():GetRoom():GetType() ~= RoomType.ROOM_CHALLENGE and CadaverItemRNG:RandomFloat() < 0.05 then
    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_ROTTENCHEST, MyChestSubType.CLOSED)
    SFXManager():Play(SoundEffect.SOUND_CHEST_DROP)
  end
end

function RottenChest.SpawnReward(chest, collider)
  -- 15% chance to spawn pedestal item
  if CadaverRNG:RandomFloat() < 0.15 then
    local item = Game():GetItemPool():GetCollectible(ItemPoolType.POOL_ROTTEN_BEGGAR, true, Random(), CollectibleType.COLLECTIBLE_ROTTEN_MEAT)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, chest.Position, Helper.RandomVelocity(), nil)
    chest:Remove()
  else
    -- 2 normal pickups
    for i=1,2 do
      local roll = CadaverRNG:RandomFloat()
      if roll < 0.25 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, chest.Position, Helper.RandomVelocity(), nil)
      elseif roll < 0.5 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, chest.Position, Helper.RandomVelocity(), nil)
      elseif roll < 0.75 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, chest.Position, Helper.RandomVelocity(), nil)
      else
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, chest.Position, Helper.RandomVelocity(), nil)
      end
    end
    
    -- 1 "rotten" option
    roll = CadaverRNG:RandomFloat()
    if roll < 0.5 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, chest.Position, Helper.RandomVelocity(), nil)
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, chest.Position, Helper.RandomVelocity(), nil)
    elseif roll < 0.75 then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, chest.Position, Helper.RandomVelocity(), nil)
    else
      if not CadaverAchievements.Probiotics then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, ROTTEN_CHEST_TRINKETS[Helper.OneIndexedRandom(CadaverRNG, #ROTTEN_CHEST_TRINKETS - 1)], chest.Position, Helper.RandomVelocity(), nil)
      else
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, ROTTEN_CHEST_TRINKETS[Helper.OneIndexedRandom(CadaverRNG, #ROTTEN_CHEST_TRINKETS)], chest.Position, Helper.RandomVelocity(), nil)
      end
    end 
  end
end

function RottenChest.OpenChest(pickup, collider, low)
  if pickup.SubType == MyChestSubType.CLOSED and collider.Type == EntityType.ENTITY_PLAYER then
    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_ROTTENCHEST, MyChestSubType.OPEN)
    SFXManager():Play(SoundEffect.SOUND_CHEST_OPEN)
    
    local player = collider:ToPlayer()
    local numRewards = 1
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KEY) then
      numRewards = numRewards + 1
    end
    if player:HasTrinket(TrinketType.TRINKET_POKER_CHIP) then
      if CadaverRNG:RandomFloat() < 0.5 then
        numRewards = 0
      else
        numRewards = numRewards + 1
      end
    end
    for i=1,numRewards do
      RottenChest.SpawnReward(pickup, collider)
    end
  end
end

return RottenChest
