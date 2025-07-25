local Helper = {}

function Helper.RandomNearbyPosition(entity)
  local position = Vector(entity.Position.X + math.random(0, 80), entity.Position.Y + math.random(0, 80))
  position = Isaac.GetFreeNearPosition(position, 1)
  return position
end


function Helper.IsRedHeart(entityType, variant, subtype)
  if entityType == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_HEART and 
  (subtype == HeartSubType.HEART_FULL or
  subtype == HeartSubType.HEART_HALF or
  subtype == HeartSubType.HEART_DOUBLEPACK or
  subtype == HeartSubType.HEART_SCARED or
  subtype == HeartSubType.HEART_BLENDED)
  then
    return true
  else
    return false
  end
end

function Helper.RandomVelocity()
  return Vector(math.random() * 2, math.random() * 2)
end

function Helper.OneIndexedRandom(rng, max)
  return rng:RandomInt(max) + 1
end

return Helper