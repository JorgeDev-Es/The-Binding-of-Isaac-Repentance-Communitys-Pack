local TechDrones = {}

CollectibleType.COLLECTIBLE_TECH_DRONES = Isaac.GetItemIdByName("Tech Drones")
FamiliarVariant.TECH_DRONES = 1300

local ORBIT_DISTANCE = Vector(175, 175)
local ORBIT_SPEED = 0.02
local ORBIT_LAYER = 130

function TechDrones.Update(familiar)
  local player = familiar.Player
  familiar.OrbitDistance = ORBIT_DISTANCE
	familiar.OrbitSpeed = ORBIT_SPEED
  familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position

  -- Only do laser management on the "shooters"
  if familiar.SubType == 1 then return end

  local truePosition = familiar.Position + familiar.Velocity
  local data = familiar:GetData()

  -- Remove active lasers
  if data.laser ~= nil and (player:GetShootingInput():Length() == 0 or not data.laser:Exists()) then
    familiar:GetSprite():Play("Move")
    data.target:GetSprite():Play("Move")
    data.laser:Remove()
    data.laser = nil
  end

  -- Create new lasers
  if player:GetShootingInput():Length() > 0 and data.laser == nil then
    data.target = player
    local distance = 0

    -- Find farthest receiver
    local entities = Isaac:GetRoomEntities()
    for i, entity in ipairs(entities) do
      if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.TECH_DRONES and entity.SubType == 1 then
        local diff = entity.Position - familiar.Position
        if diff:Length() > distance then
          data.target = entity
          distance = diff:Length()
        end
      end
    end

    data.laser = EntityLaser.ShootAngle(2, truePosition, (data.target.Position - truePosition):GetAngleDegrees(), -1, Vector(0,0), familiar)
    data.laser.TearFlags = TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING
    data.laser.DisableFollowParent = true
    data.laser.GridCollisionClass = GridCollisionClass.COLLISION_NONE
    familiar:GetSprite():Play("Shoot")
    data.target:GetSprite():Play("Shoot")
  end
  
  -- Update current lasers
  if data.laser ~= nil then
    data.laser.Position = truePosition
    local trueTargetPosition = data.target.Position + data.target.Velocity
    data.laser.MaxDistance = (trueTargetPosition - truePosition):Length() - 10
    local angle = (trueTargetPosition - truePosition):GetAngleDegrees()
    data.laser.Angle = angle
  end
end

function TechDrones.LaserDamage(entity, amount, flags, source, countdownFrames)
  if source ~= nil and source.Entity ~= nil and source.Entity.Type == EntityType.ENTITY_FAMILIAR and source.Entity.Variant == FamiliarVariant.TECH_DRONES then
    local player = source.Entity:ToFamiliar().Player
    local damageMultiplier = 0.4
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      damageMultiplier = 0.6
    end
    entity:TakeDamage(player.Damage * damageMultiplier, 0, EntityRef(nil), 0)
    return false
  end
  return true
end

function TechDrones.UpdateCache(player, cacheFlag)
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
    local pairs = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECH_DRONES)
    local entities = Isaac:GetRoomEntities()
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_DRONES)) then
      pairs = pairs + player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    end

    for i, entity in ipairs(entities) do
      if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.TECH_DRONES then
        if entity:GetData().laser ~= nil then
          entity:GetData().laser:Remove()
        end
        entity:Remove()
      end
    end

    if pairs > 0 then
      local bots = {}
      for i=1,pairs do
        local ent = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.TECH_DRONES, 0, player.Position, Vector(0,0), nil)
        local fam = ent:ToFamiliar()
        fam.Player = player
        table.insert(bots, fam)
        fam:AddToOrbit(ORBIT_LAYER)
        fam.OrbitDistance = ORBIT_DISTANCE
        fam.OrbitSpeed = ORBIT_SPEED
      end
      for i=1,pairs do
        local ent = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.TECH_DRONES, 1, player.Position, Vector(0,0), nil)
        local fam = ent:ToFamiliar()
        fam.Player = player
        table.insert(bots, fam)
        fam:AddToOrbit(ORBIT_LAYER)
        fam.OrbitDistance = ORBIT_DISTANCE
        fam.OrbitSpeed = ORBIT_SPEED
      end
      for i, bot in ipairs(bots) do
        bot.Position = bot:GetOrbitPosition(player.Position + player.Velocity)
      end
    end
  end
end

return TechDrones