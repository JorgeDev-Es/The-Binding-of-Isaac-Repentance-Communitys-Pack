local Helper = include("Helper")
local json = include("json")

local TaintedCadaver = {}

PlayerType.PLAYER_TAINTED_CADAVER = Isaac.GetPlayerTypeByName("Cadaver", true)

-- # SETUP #

function TaintedCadaver.PlayerInit(player)
  local cadaverCostume = Isaac.GetCostumeIdByPath("gfx/characters/tainted_cadaver.anm2")
  player:AddNullCostume(cadaverCostume)
  player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_HALITOSIS, ActiveSlot.SLOT_POCKET, true)
end

-- # STATS #

local MAX_HEALTH = 4
local TAINTED_CADAVER_STATS = {
  STATIC_TEAR_DELAY = 5.0,
  DAMAGE_MULTIPLIER = 0.6
}

local statCache = {}

function TaintedCadaver.ModifyStats(player, cacheFlag)
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER then
    local pHash = GetPtrHash(player)
    if not statCache[pHash] then
      statCache[pHash] = { lastItemDamage = -1.0, lastCalculatedDamage = -1.0, currentMultiplier = -1.0 }
    end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY or cacheFlag == CacheFlag.CACHE_DAMAGE then
      if string.format("%.2f", player.Damage) == string.format("%.2f", statCache[pHash].lastCalculatedDamage) and player.MaxFireDelay ~= TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY then
        local lockedRate = 30.0 / (TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY + 1.0)
        local newRate = 30.0 / (player.MaxFireDelay + 1)
        statCache[pHash].currentMultiplier = newRate / lockedRate
        player.MaxFireDelay = TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY
        statCache[pHash].lastCalculatedDamage = statCache[pHash].lastItemDamage * TAINTED_CADAVER_STATS.DAMAGE_MULTIPLIER * statCache[pHash].currentMultiplier
        player.Damage = statCache[pHash].lastCalculatedDamage
      end

      if string.format("%.2f", player.Damage) ~= string.format("%.2f", statCache[pHash].lastCalculatedDamage) and player.MaxFireDelay == TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY then
        statCache[pHash].lastItemDamage = player.Damage
        statCache[pHash].lastCalculatedDamage = player.Damage * TAINTED_CADAVER_STATS.DAMAGE_MULTIPLIER * statCache[pHash].currentMultiplier
        player.Damage = statCache[pHash].lastCalculatedDamage
      end

      if string.format("%.2f", player.Damage) ~= string.format("%.2f", statCache[pHash].lastCalculatedDamage) and player.MaxFireDelay ~= TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY then
        statCache[pHash].lastItemDamage = player.Damage
        local lockedRate = 30.0 / (TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY + 1.0)
        local newRate = 30.0 / (player.MaxFireDelay + 1)
        statCache[pHash].currentMultiplier = newRate / lockedRate
        player.MaxFireDelay = TAINTED_CADAVER_STATS.STATIC_TEAR_DELAY
        statCache[pHash].lastCalculatedDamage = player.Damage * TAINTED_CADAVER_STATS.DAMAGE_MULTIPLIER * statCache[pHash].currentMultiplier
        player.Damage = statCache[pHash].lastCalculatedDamage
      end 
    end
  end
end

-- # ARMY #

local SOLDIER_TYPE = {
  SMALL_MAGGOT = { Type = EntityType.ENTITY_SMALL_MAGGOT, Variant = 0, SubType = 0 },
  SMALL_LEECH = { Type = EntityType.ENTITY_SMALL_LEECH, Variant = 0, SubType = 0 },
  CHARGER = { Type = EntityType.ENTITY_CHARGER, Variant = 0, SubType = 0 },
  DROWNED_CHARGER = { Type = EntityType.ENTITY_CHARGER, Variant = 1, SubType = 0 },
  DANK_CHARGER = { Type = EntityType.ENTITY_CHARGER, Variant = 2, SubType = 0 },
  CARRION_PRINCESS = { Type = EntityType.ENTITY_CHARGER, Variant = 3, SubType = 0 },
  ROTTEN_GAPER_NORMAL = { Type = EntityType.ENTITY_GAPER, Variant = 3, SubType = 4 },
  ROTTEN_GAPER_FASTER = { Type = EntityType.ENTITY_GAPER, Variant = 3, SubType = 1 },
  ROTTEN_GAPER_FASTEST = { Type = EntityType.ENTITY_GAPER, Variant = 3, SubType = 2 },
  EVIS = { Type = EntityType.ENTITY_EVIS, Variant = 0, SubType = 0 },
  POOTER = { Type = EntityType.ENTITY_POOTER, Variant = 0, SubType = 0 },
  SUPER_POOTER = { Type = EntityType.ENTITY_POOTER, Variant = 1, SubType = 0 },
  MAZE_ROAMER = { Type = EntityType.ENTITY_MAZE_ROAMER, Variant = 0, SubType = 0 },
  VIS = { Type = EntityType.ENTITY_VIS, Variant = 0, SubType = 0 }
}

local ARMY_LEVELS = {
  { Entity = SOLDIER_TYPE.SMALL_LEECH, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_MAGGOT, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_LEECH, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_MAGGOT, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_LEECH, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_MAGGOT, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.DROWNED_CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.DANK_CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.CARRION_PRINCESS, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_NORMAL, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_NORMAL, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTER, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTER, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTEST, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTEST, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.VIS, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_LEECH, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_MAGGOT, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.DROWNED_CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.DANK_CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.CARRION_PRINCESS, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_NORMAL, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTER, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTEST, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.VIS, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_LEECH, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_MAGGOT, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.DROWNED_CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.DANK_CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.CARRION_PRINCESS, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_NORMAL, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTER, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTEST, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.VIS, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_LEECH, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.SMALL_MAGGOT, Cooldown = PET_COOLDOWN, Scale = 1 },
  { Entity = SOLDIER_TYPE.CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.DROWNED_CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.DANK_CHARGER, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.CARRION_PRINCESS, Cooldown = PET_COOLDOWN, Scale = 0.8 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_NORMAL, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTER, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.ROTTEN_GAPER_FASTEST, Cooldown = PET_COOLDOWN, Scale = 0.5 },
  { Entity = SOLDIER_TYPE.VIS, Cooldown = PET_COOLDOWN, Scale = 1 }
}

EntityFlag.FLAG_CADAVER_PET = 1<<61
local SOLDIER_DAMAGE = 3.0
local VIS_SOLDIER_DAMAGE = 1.0
local PET_COOLDOWN = 90
local STARTING_LEVEL = 4
local STARTING_BANK = -1
local MAX_LEVEL = #ARMY_LEVELS

local currentLevel = STARTING_LEVEL
local bankedSoulHearts = STARTING_BANK
local initialized = false

function TaintedCadaver.ManageArmy(player)
  if not initialized then return end

  local army = {}
  for i=1,currentLevel do
    army[i] = false
  end

  local entities = Isaac:GetRoomEntities()
  for i, entity in ipairs(entities) do
    if entity:HasEntityFlags(EntityFlag.FLAG_CADAVER_PET) then
      for i=1,#army do
        if not army[i] and entity.Type == ARMY_LEVELS[i].Entity.Type and entity.Variant == ARMY_LEVELS[i].Entity.Variant and entity.SubType == ARMY_LEVELS[i].Entity.SubType then
          army[i] = true
          break
        end
      end
    end
  end

  for i=1,#army do
    if not army[i] then
      if ARMY_LEVELS[i].Cooldown >= PET_COOLDOWN then
        ARMY_LEVELS[i].Cooldown = 0
        local soldier = Isaac.Spawn(ARMY_LEVELS[i].Entity.Type, ARMY_LEVELS[i].Entity.Variant, ARMY_LEVELS[i].Entity.SubType, player.Position, Vector(0,0), nil)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
          soldier:ToNPC().Scale = ARMY_LEVELS[i].Scale * 1.25
        else
          soldier:ToNPC().Scale = ARMY_LEVELS[i].Scale
        end
        soldier:AddEntityFlags(EntityFlag.FLAG_CADAVER_PET)
        soldier:AddCharmed(EntityRef(player), -1)
        if (soldier.Type == EntityType.ENTITY_VIS) then
          soldier:GetSprite():ReplaceSpritesheet(0, "gfx/monsters/classic/monster_176_cagevis.png")
          soldier:GetSprite():ReplaceSpritesheet(1, "gfx/monsters/classic/monster_176_cagevis.png")
          soldier:GetSprite():LoadGraphics()
        end
      elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        ARMY_LEVELS[i].Cooldown = ARMY_LEVELS[i].Cooldown + 1
      end
    end
  end
end

function TaintedCadaver.KillArmy()
  local entities = Isaac:GetRoomEntities()
  for i, entity in ipairs(entities) do
    if entity:HasEntityFlags(EntityFlag.FLAG_CADAVER_PET) then
      entity:Die()
    end
  end

  for i=1,#ARMY_LEVELS do
    ARMY_LEVELS[i].Cooldown = PET_COOLDOWN
  end
end

function TaintedCadaver.SoldierDamage(entity, amount, flags, source, countdownFrames)
  local player = Isaac.GetPlayer(0)

  -- Blue fly damage bug-fix
  if source ~= nil
      and source.Entity ~= nil
      and source.Entity.Type == EntityType.ENTITY_FAMILIAR
      and source.Entity.Variant == FamiliarVariant.BLUE_FLY
      and source.Entity.SubType == 0
      and player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER then
    if player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
      entity:TakeDamage(player.Damage * 4, 0, EntityRef(nil), 0)
    else
      entity:TakeDamage(player.Damage * 2, 0, EntityRef(nil), 0)
    end
    return false
  -- Army Damage
  elseif source ~= nil and source.Entity ~= nil and source.Entity:HasEntityFlags(EntityFlag.FLAG_CADAVER_PET) then
    local damageMultiplier = 1
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      damageMultiplier = 1.5
    end

    if source.Entity.Type == EntityType.ENTITY_VIS then
      entity:TakeDamage(VIS_SOLDIER_DAMAGE * damageMultiplier, 0, EntityRef(nil), 0)
    else
      entity:TakeDamage(SOLDIER_DAMAGE * damageMultiplier, 0, EntityRef(nil), 0)
    end
    return false
  end
  return true
end

function TaintedCadaver:InitSoldierLasers(laser)
  if laser.SpawnerEntity ~= nil and laser.SpawnerEntity:HasEntityFlags(EntityFlag.FLAG_CADAVER_PET) then
    laser:SetColor(Color(0.3, 0.5, 0.4, 1, 0.3, 0.5, 0.4), 1000, 1, false, false)
  end
end

-- # HEALTH #

function TaintedCadaver.ConvertHealth(player)
  if player:GetBlackHearts() == 0 and player:GetEffectiveMaxHearts() == 0 and player:GetEternalHearts() == 0 and player:GetSoulHearts() == 1 then
    player:AddBoneHearts(2)
    player:AddHearts(4)
  else
    -- Convert Hearts to Rotten
    local hearts = player:GetHearts()
    local rottenHearts = player:GetRottenHearts()
    local rottenReplacements = hearts - (rottenHearts * 2) 
    player:AddHearts(-rottenReplacements)
    player:AddRottenHearts(rottenReplacements)

    -- Take away soul hearts for army levels
    local soulHearts = player:GetSoulHearts()
    player:AddSoulHearts(-soulHearts)
    bankedSoulHearts = bankedSoulHearts + soulHearts % 2
    currentLevel = currentLevel + math.floor(soulHearts / 2)
    if bankedSoulHearts > 1 then
      bankedSoulHearts = bankedSoulHearts % 2
      currentLevel = currentLevel + math.floor(bankedSoulHearts / 2)
    end
    if currentLevel > MAX_LEVEL then
      currentLevel = MAX_LEVEL
    end

    -- Convert heart containers to bone hearts
    if rottenReplacements == 0 then
      local containers = player:GetMaxHearts()
      local boneReplacements = math.floor(containers / 2)
      player:AddBoneHearts(boneReplacements)
      if (boneReplacements > 1) then
        player:AddRottenHearts(boneReplacements - 1)
      end
      player:AddMaxHearts(-containers, true)
    end

    -- Limit Max Bone Hearts
    local boneHearts = player:GetBoneHearts()
    if boneHearts > MAX_HEALTH then
      player:AddBoneHearts(MAX_HEALTH - boneHearts)
    end
  end
end

function TaintedCadaver.ReplaceHearts(pickup)
  local player = Isaac.GetPlayer(0)
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER then
      -- Bail if we're in the secret room that only allows red hearts
      local room = Game():GetLevel():GetCurrentRoomDesc().Data
      if room.Type == RoomType.ROOM_SUPERSECRET and room.Variant == 0 then return end

      if Helper.IsRedHeart(pickup.Type, pickup.Variant, pickup.SubType) then
          if pickup:IsShopItem() then
              pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, true)
          else
              if CadaverRNG:RandomFloat() < 0.1 then
                  pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, false, false, true)
              else
                  pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, false, false, true)
              end
          end
      end
  end
end

-- # EXIT SAVE ETC. #

function TaintedCadaver.Exit()
  initialized = false
  local entities = Isaac:GetRoomEntities()
  for i, entity in ipairs(entities) do
    if entity:HasEntityFlags(EntityFlag.FLAG_CADAVER_PET) then
      entity:ToNPC():Morph(EntityType.ENTITY_EFFECT, EffectVariant.EFFECT_NULL, 0, -1)
    end
  end
end

function TaintedCadaver.Reset(isContinued)
  for i=1,#ARMY_LEVELS do
    ARMY_LEVELS[i].Cooldown = PET_COOLDOWN
  end

  if not isContinued then
    currentLevel = STARTING_LEVEL
    bankedSoulHearts = STARTING_BANK  
  end
  initialized = true
end

function TaintedCadaver.LoadData(table)
  if table ~= nil then
    currentLevel = table.currentLevel
    bankedSoulHearts = table.bankedSoulHearts
  end
end

function TaintedCadaver.SaveData()
  return { currentLevel = currentLevel, bankedSoulHearts = bankedSoulHearts }
end

-- # TESTING / DEBUGGING #

function TaintedCadaver.GetArmyStats()
  print("Army Level: " .. currentLevel)
  print("Banked Soul Hearts: " .. bankedSoulHearts)
end

return TaintedCadaver