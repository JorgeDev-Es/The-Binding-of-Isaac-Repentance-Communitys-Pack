---@param bomb EntityBomb
local function IsActive(bomb)
    local player = TSIL.Players.GetPlayerFromEntity(bomb)

    if not player then return end

    return player:HasCollectible(CollectibleType.COLLECTIBLE_HOT_BOMBS)
end


---@param center Vector
---@param radius number
---@param direction Vector
---@param spawner Entity
local function CreateRingOfFire(center, radius, direction, spawner)
    local room = Game():GetRoom()

    local angleWidth = 360

    local totalPerimeter = math.pi * 2 * radius
    local widthPerimeter = angleWidth * totalPerimeter / 360

    local numShockwaves = math.max(1, math.floor(widthPerimeter / 35 + 0.5))

    local angleOffset = angleWidth / numShockwaves
    local currentDirection = direction:Rotated(-angleWidth / 2)

    local hasSpawnedFire = false

    for _ = 0, numShockwaves, 1 do
        local spawningOffset = currentDirection * radius

        if room:CheckLine(center, center + spawningOffset, 3, 1000) then
            hasSpawnedFire = true

            local gridEntity = room:GetGridEntityFromPos(center + spawningOffset)

            if not gridEntity or gridEntity:GetType() ~= GridEntityType.GRID_PIT then
                local flame = TSIL.EntitySpecific.SpawnEffect(
                    EffectVariant.RED_CANDLE_FLAME,
                    0,
                    center + spawningOffset,
                    Vector.Zero,
                    spawner
                )

                flame.CollisionDamage = 50
            end
        end

        currentDirection = currentDirection:Rotated(angleOffset)
    end

    if hasSpawnedFire then
        GigaBombsSynergiesMod.Helpers.AddTemporarySchedule(CreateRingOfFire, 3, center, radius + 35, direction:Rotated(20), spawner)
    end
end


---@param bomb EntityBomb
local function OnExplode(bomb)
    GigaBombsSynergiesMod.Helpers.RemoveJustSpawnedEntities(
        EntityType.ENTITY_EFFECT,
        EffectVariant.RED_CANDLE_FLAME
    )

    local player = TSIL.Players.GetPlayerFromEntity(bomb)
    if not player then return end
    CreateRingOfFire(bomb.Position, 35, Vector(0, -1), player)
end


GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaHotBomb",
    IsActive,
    OnExplode
)
