---@param bomb EntityBomb
local function IsActive(bomb)
    local player = TSIL.Players.GetPlayerFromEntity(bomb)

    if not player then return false end

    return player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
end


GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaNancyBomb",
    IsActive,
    nil,
    nil,
    "GigaNancyBomb"
)
