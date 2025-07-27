local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

function mod:getRealPlayer(checkedPlayer)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if checkedPlayer.InitSeed and checkedPlayer.InitSeed == player.InitSeed then
            return player
        end
    end
    return Isaac.GetPlayer()
end

function mod.isaacDEulogyQueueHandling()
    if mod.IsaacDEulogyQueue then
        if game:GetFrameCount() % 5 == 0 and #mod.IsaacDEulogyQueue > 0 then
            local player = mod:getRealPlayer(mod.IsaacDEulogyQueue[1])
            table.remove(mod.IsaacDEulogyQueue, 1)
            local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.ISAACD_EULOGY)

            local diceOptions = {
                {Weight = 10, Output = mod.ITEM.COLLECTIBLE.D2},
                {Weight = 1, Output = CollectibleType.COLLECTIBLE_D7},
                {Weight = 10, Output = CollectibleType.COLLECTIBLE_D8},
                {Weight = 10, Output = CollectibleType.COLLECTIBLE_D10},
                {Weight = 10, Output = CollectibleType.COLLECTIBLE_D12},
                {Weight = 5, Output = mod.ITEM.COLLECTIBLE.ETERNAL_D10},
                {Weight = 3, Output = mod.ITEM.COLLECTIBLE.ETERNAL_D12},
                {Weight = 3, Output = mod.ITEM.COLLECTIBLE.ETERNAL_D12_ALT},
                {Weight = 5, Output = mod.ITEM.COLLECTIBLE.DUSTY_D10},
            }
            local itemCount = mod.GetEntityCount(5, 100)
            local trinketCount = mod.GetEntityCount(5, 350)
            local pickupCount = mod.GetEntityCount(5)
            if itemCount > 0 then
                table.insert(diceOptions, {Weight = 15, Output = CollectibleType.COLLECTIBLE_D6})
                table.insert(diceOptions, {Weight = 10, Output = CollectibleType.COLLECTIBLE_ETERNAL_D6})
                table.insert(diceOptions, {Weight = 10, Output = CollectibleType.COLLECTIBLE_SPINDOWN_DICE})
                table.insert(diceOptions, {Weight = 10, Output = mod.ITEM.COLLECTIBLE.LOADED_D6})
            end
            if trinketCount > 0 then
                table.insert(diceOptions, {Weight = 20, Output = mod.ITEM.COLLECTIBLE.AZURITE_SPINDOWN})
            end
            if pickupCount > itemCount then --Just means there's pickups that aren't collectibles in the room
                table.insert(diceOptions, {Weight = 8, Output = CollectibleType.COLLECTIBLE_D1})
                table.insert(diceOptions, {Weight = 8, Output = CollectibleType.COLLECTIBLE_D20})
            end
            local dice = mod.randomArrayWeightBased(diceOptions)
            --Rare chance
            if rng:RandomInt(10000) == 1 then
                if rng:RandomInt(2) == 1 then
                    dice = CollectibleType.COLLECTIBLE_D4
                else
                    dice = CollectibleType.COLLECTIBLE_D100
                end
            end
            player:UseActiveItem(dice, false, false, true, false)
            if dice ~= mod.ITEM.COLLECTIBLE.D2 then
                player:AnimateCollectible(dice, "UseItem")
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
    if not npc:HasEntityFlags(EntityFlag.FLAG_NO_REWARD) and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
        mod.AnyPlayerDo(function(player)
            if player:HasCollectible(mod.ITEM.COLLECTIBLE.ISAACD_EULOGY) then
                for k = 1, player:GetCollectibleNum(mod.ITEM.COLLECTIBLE.ISAACD_EULOGY) do
                    local chance = math.max(20 + (player.Luck * 5), 1)
                    local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.ISAACD_EULOGY)
                    local roll = rng:RandomFloat() * 200
                    local d = player:GetData()
                    d.isaacDEulogyPity = d.isaacDEulogyPity or 0
                    roll = roll - d.isaacDEulogyPity
                    if chance > roll then
                        d.isaacDEulogyPity = 0
                        mod.IsaacDEulogyQueue = mod.IsaacDEulogyQueue or {}
                        table.insert(mod.IsaacDEulogyQueue, player)
                    else
                        d.isaacDEulogyPity = d.isaacDEulogyPity + 5
                    end
                end
            end
        end)
    end
end)