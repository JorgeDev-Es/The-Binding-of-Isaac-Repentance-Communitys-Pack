local ForbiddenFruit = {}

CollectibleType.COLLECTIBLE_FORBIDDEN_FRUIT = Isaac.GetItemIdByName("Forbidden Fruit")
local TICKS_PER_DAMAGE = 120
local TEAR_DELAY_MULTIPLIER = 0.5
local DAMAGE_MULTIPLIER = 3.0

local fruitActive = false
local ticksSinceLastDamage = 0

function ForbiddenFruit.Reset(isContinued)
  if not isContinued then
    fruitActive = false
  end
end

function ForbiddenFruit.LoadData(table)
  fruitActive = table.fruitActive
end

function ForbiddenFruit.SaveData()
  return { fruitActive = fruitActive }
end

function ForbiddenFruit.Use()
  fruitActive = true
  return { Remove = true, ShowAnim = true }
end

function ForbiddenFruit.ModifyStats(player, cacheFlag)
  if fruitActive then
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
      player.MaxFireDelay = player.MaxFireDelay * TEAR_DELAY_MULTIPLIER
    elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage * DAMAGE_MULTIPLIER
    end
  end
end

function ForbiddenFruit.UpdateForbiddenFruitEffect(player)
  if fruitActive then
    if ticksSinceLastDamage > TICKS_PER_DAMAGE then
      player:TakeDamage(1, 0, EntityRef(player), 0)
      ticksSinceLastDamage = 0
    else
      ticksSinceLastDamage = ticksSinceLastDamage + 1
    end
  end
end

return ForbiddenFruit