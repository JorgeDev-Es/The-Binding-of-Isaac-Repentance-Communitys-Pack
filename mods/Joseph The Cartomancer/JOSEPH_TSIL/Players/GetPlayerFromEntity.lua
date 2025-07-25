function TSIL.Players.GetPlayerFromEntity(entity)
  if entity.Parent then
    local player = entity.Parent:ToPlayer()

    if player then
      return player
    end

    local familiar = entity.Parent:ToFamiliar()

    if familiar then
      return familiar.Player
    end
  end

  if entity.SpawnerEntity then
    local player = entity.SpawnerEntity:ToPlayer()

    if player then
      return player
    end

    local familiar = entity.SpawnerEntity:ToFamiliar()

    if familiar then
      return familiar.Player
    end
  end

  return entity:ToPlayer()
end
