local Mod = RepMMod

local function onUpdate_Rock(_, player)
    if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_BEEG_MINUS) and not player:IsDead() then
        player:Kill()
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onUpdate_Rock, PlayerVariant.PLAYER)