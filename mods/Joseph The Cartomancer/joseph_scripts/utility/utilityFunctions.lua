local utilityFunctions  = {}

JosephMod.ScheduleData = {}
function JosephMod.Schedule(delay, func, args)
  table.insert(JosephMod.ScheduleData, {
    Time = Game():GetFrameCount(),
    Delay = delay,
    Call = func,
    Args = args
  })
end

JosephMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
  local time = Game():GetFrameCount()
  for i = #JosephMod.ScheduleData, 1, -1 do
    local data = JosephMod.ScheduleData[i]
    if data.Time + data.Delay <= time then
      data.Call(table.unpack(data.Args))
      table.remove(JosephMod.ScheduleData, i)
    end
  end
end)


---Acts as a replacement for Entity:GetData()
---@param entity Entity
---@param identifier string | nil
---@return any
function utilityFunctions:GetData(entity, identifier)
  local data = TSIL.Entities.GetEntityData(
    JosephMod,
      entity,
      identifier or ""
  )

  if not data then
      data = {}
      TSIL.Entities.SetEntityData(
        JosephMod,
          entity,
          identifier or "",
          data
      )
  end

  return data
end


function utilityFunctions:CreateEmptyPlayerSaveDataVars(vars)
  if vars == nil then return end
  for i = 1, #vars do
    TSIL.SaveManager.AddPersistentVariable(
      JosephMod,
      vars[i],
      {{}, {}, {}, {}},
      TSIL.Enums.VariablePersistenceMode.RESET_RUN,
      false
    )
  end
end



function utilityFunctions:GetEnchantedCardsPerPlayer(player)
  return TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "EnchantedCards", player)
end

---@param player EntityPlayer
---@param slot CardSlot
function utilityFunctions:GetEnchantedCardInPlayerSlot(player, slot)

  local enchantedCards = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "EnchantedCards", player)
  return enchantedCards[slot]

end

function utilityFunctions:SetEnchantedCardInPlayerSlot(player, slot, card)
  local enchantedCards = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "EnchantedCards", player)

  enchantedCards[slot] = card
end


function utilityFunctions:toTearsPerSecond(maxFireDelay)
  return 30 / (maxFireDelay + 1)
end

function utilityFunctions:toMaxFireDelay(tearsPerSecond)
  return (30 / tearsPerSecond) - 1
end

function utilityFunctions:addTearMultiplier(player, multiplier)
  local tearsPerSecond = JosephMod.utility:toTearsPerSecond(player.MaxFireDelay)
  tearsPerSecond = tearsPerSecond * multiplier
  player.MaxFireDelay = JosephMod.utility:toMaxFireDelay(tearsPerSecond)
end

---Function to add a tears up that respects vanilla tear multipliers (Stolen from CHAPI)
---@param player EntityPlayer
---@return number
function utilityFunctions:GetTearMultiplier(player)
  local playerType = player:GetPlayerType()

  local multi = 1
  
  if playerType == PlayerType.PLAYER_THEFORGOTTEN or playerType == PlayerType.PLAYER_THEFORGOTTEN_B then
      multi = multi * 0.5
  end
  if playerType == PlayerType.PLAYER_EVE_B then
      multi = multi * 0.66
  end
  if playerType == PlayerType.PLAYER_AZAZEL_B or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
      multi = multi * 0.33
  elseif playerType == PlayerType.PLAYER_AZAZEL then
      multi = multi * 0.267
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
      multi = multi * 0.4
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA) then
      multi = multi * 0.66
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
      multi = multi * 0.33
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
      multi = multi / 4.3
  end
  
  if not player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
      if player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) or 
          player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) 
      then
          multi = multi * 0.42
      elseif player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) or
              player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)
      then
          multi = multi * 0.51
      end
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
      multi = multi * 5.5
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
      multi = multi * 0.66
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then
      multi = multi * 4
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BERSERK) then
      multi = multi * 0.5
  end
  
  if player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_CHARIOT) then
      multi = multi * 4
  end
  
  -- if player:GetData().CustomHealthAPIOtherData then
  --     local odata = player:GetData().CustomHealthAPIOtherData
  --     if (odata.InHallowAura or 0) > 0 or 
  --         (odata.InHallowDipAura or 0) > 0 or 
  --         (odata.InBethlehemAura or 0) > 0 or
  --         (odata.InHallowSpellAura or 0) > 0
  --     then
  --         multi = multi * 2.5
  --     end
      
  --     if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIPHORA) then
  --         local fireDirection = player:GetFireDirection()
  --         if fireDirection == Direction.NO_DIRECTION or
  --             (odata.PreviousEpiphoraDirection ~= Direction.NO_DIRECTION and fireDirection ~= odata.PreviousEpiphoraDirection)
  --         then
  --             odata.EpiphoraStart = Game():GetFrameCount()
  --         elseif Game():GetFrameCount() - (odata.EpiphoraStart or 0) >= 270 then
  --             multi = multi * 2
  --         elseif Game():GetFrameCount() - (odata.EpiphoraStart or 0) >= 180 then
  --             multi = multi * 1.66
  --         elseif Game():GetFrameCount() - (odata.EpiphoraStart or 0) >= 90 then
  --             multi = multi * 1.33
  --         end
  --         odata.PreviousEpiphoraDirection = fireDirection
  --     end
  -- end
  
  -- hallowed ground creep = *2.5 (this is hell to compute)
  -- fuck the d8 in particular


  return multi
end



function utilityFunctions:AddTears(player, tears)
  local TPS = utilityFunctions:toTearsPerSecond(player.MaxFireDelay)
  local newTPS = TPS + tears * utilityFunctions:GetTearMultiplier(player)
  player.MaxFireDelay = utilityFunctions:toMaxFireDelay(newTPS)
end

function utilityFunctions:HUDOffset(x, y, anchor)
    local notches = math.floor(Options.HUDOffset * 10 + 0.5)
    local xoffset = (notches*2)
    local yoffset = ((1/8)*(10*notches+(-1)^notches+7))
    if anchor == 'topleft' then
      xoffset = x+xoffset
      yoffset = y+yoffset
    elseif anchor == 'topright' then
      xoffset = x-xoffset
      yoffset = y+yoffset
    elseif anchor == 'bottomleft' then
      xoffset = x+xoffset
      yoffset = y-yoffset
    elseif anchor == 'bottomright' then
      xoffset = x-xoffset * 0.8
      yoffset = y-notches * 0.6
    else
      error('invalid anchor provided. Must be one of: \'topleft\', \'topright\', \'bottomleft\', \'bottomright\'', 2)
    end
    return math.floor(xoffset + 0.5), math.floor(yoffset + 0.5)
end

function utilityFunctions:AddDamage(player, amount)
    local damageModifier = amount
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
        damageModifier = damageModifier*0.2
    end
    player.Damage = player.Damage + damageModifier
end


function utilityFunctions:AnyPlayerHasEnchantment(enchantment)
  local playerEnchantments = TSIL.SaveManager.GetPersistentVariable(JosephMod, "EnchantedCards") or {}
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local playerIndex = TSIL.Players.GetPlayerIndex(player)
        if not playerEnchantments or not playerEnchantments[playerIndex] or playerEnchantments[playerIndex] == {} then return false end
        for key, value in pairs(playerEnchantments[playerIndex]) do
          if value == enchantment then return true end
        end
    end
    return false
end


function utilityFunctions:GetEnchantmentCount(player, enchantment)
  local playerEnchantments = TSIL.SaveManager.GetPersistentVariable(JosephMod, "EnchantedCards") or {}
  local enchantmentCount = 0
  local playerIndex = TSIL.Players.GetPlayerIndex(player)
  if not playerEnchantments or not playerEnchantments[playerIndex] or playerEnchantments[playerIndex] == {} then return 0 end
  for key, value in pairs(playerEnchantments[playerIndex]) do
    if value == enchantment then enchantmentCount = enchantmentCount + 1 end
  end

  return enchantmentCount
end


function utilityFunctions:GetTotalEnchantmentCount(enchantment)
  local totalEnchants = 0
  for i = 0, Game():GetNumPlayers() - 1 do

    local player = Isaac.GetPlayer(i)
    local playerEnchants = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "EnchantedCards", player)

    for key, value in pairs(playerEnchants) do

      if value == enchantment then
        totalEnchants = totalEnchants + 1
      end
    end
  end

  return totalEnchants
end


function utilityFunctions:IsPlayingCard(card)
  if card >= Card.CARD_CLUBS_2 and card <= Card.CARD_JOKER then
    return true
  end
  if card == Card.CARD_RULES then return true end
  if card == Card.CARD_SUICIDE_KING then return true end
  if card == Card.CARD_SUICIDE_KING then return true end
  return false
end


function utilityFunctions:HasEnchantment(player, enchantment)
  local playerEnchantments = TSIL.SaveManager.GetPersistentVariable(JosephMod, "EnchantedCards") or {}
  local hasEnchantment = false
  local playerIndex = TSIL.Players.GetPlayerIndex(player)
  if not playerEnchantments or not playerEnchantments[playerIndex] or playerEnchantments[playerIndex] == {} then return false end
  for key, value in pairs(playerEnchantments[playerIndex]) do
    if value == enchantment then hasEnchantment = true end
  end

  return hasEnchantment
end

function utilityFunctions:IsEnchantmentSlotEmpty(player, slot)
  local enchantedCard = utilityFunctions:GetEnchantedCardInPlayerSlot(player, slot)
  if enchantedCard == nil or enchantedCard == 0 then return true end
  return false
end


function utilityFunctions:RemoveInnateItem(player, item)
  if player:GetCollectibleNum(item) - player:GetCollectibleNum(item, false, true) > 0 then
    player:AddInnateCollectible(item, -1)
    local config = Isaac.GetItemConfig():GetCollectible(item)
    player:RemoveCostume(config)
  end
end


-- get nearest entity
---@param position Vector
---@param entitytype integer
---@param entityvariant integer
---@param entitysubtype integer
---@return Entity|nil
function utilityFunctions:GetNearestEntity(position, entitytype, entityvariant, entitysubtype)
  local nearestEntity = nil;
  local nearestDistance = math.huge;
      
  for _, entity in ipairs(Isaac.FindByType(entitytype, entityvariant or -1, entitysubtype or -1, false, true)) do
      local distanceSqr = position:DistanceSquared(entity.Position);
          
  if distanceSqr < nearestDistance then
      nearestEntity = entity;
      nearestDistance = distanceSqr;
  end
  end
      
  return nearestEntity
end



---Returns the regular or greed version of an ItemPoolType
---@param poolType ItemPoolType
---@return ItemPoolType
local function GetProperPool(poolType)
  local isGreedMode = Game():IsGreedMode()

  if not isGreedMode then
      return poolType
  end

  if poolType == ItemPoolType.POOL_TREASURE then
      return ItemPoolType.POOL_GREED_TREASURE

  elseif poolType == ItemPoolType.POOL_DEVIL then
      return ItemPoolType.POOL_GREED_DEVIL

  else
      return poolType
  end
end

function utilityFunctions:GetCollectible(rng)
  local itemPool = Game():GetItemPool()
  local roomType = Game():GetRoom():GetType()
  local seed = rng:GetSeed()
  local poolType = itemPool:GetPoolForRoom(roomType, seed)

  if poolType == ItemPoolType.POOL_NULL then
    poolType = ItemPoolType.POOL_TREASURE
  end
  
  return itemPool:GetCollectible(poolType, true)
end


function utilityFunctions:IsFinalBossRoom()
  local room = Game():GetRoom()
  local bossID = room:GetBossID()

  if bossID == BossType.MOM or
  bossID == BossType.MOMS_HEART or
  bossID == BossType.IT_LIVES or
  bossID == BossType.SATAN or
  bossID == BossType.ISAAC or
  bossID == BossType.BLUE_BABY or
  bossID == BossType.LAMB or
  bossID == BossType.MEGA_SATAN or
  bossID == BossType.HUSH or
  bossID == BossType.DELIRIUM or
  bossID == BossType.MOTHER or
  bossID == BossType.DOGMA or
  bossID == BossType.BEAST then
    return true
  end
  return false
end

return utilityFunctions