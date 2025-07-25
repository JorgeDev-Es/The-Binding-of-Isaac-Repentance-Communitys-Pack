local mod = RegisterMod("Delirious Skin", 1)
local skin = Isaac.GetItemIdByName("Delirious Skin")
local RECOMMENDED_SHIFT_IDX = 35
local json = require("json")
local rng = RNG()
-- I always come back
local persistentData = {
    AFTON = 0,
}
-- there's a bug where if you rewind, the counter for how many times you used delirious skin doesn't go back to what it was
-- I have no idea how to fix this, as such I consider this a feature now
function mod:save()
    local jsonString = json.encode(persistentData)
    mod:SaveData(jsonString)
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.save)

function mod:autoSave()
    mod:save()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.autoSave)

function mod:start(bool)
    if mod:HasData() then
        persistentData = json.decode(mod:LoadData()) -- if savedata exists, load it
    else
        persistentData.AFTON = 0 -- if not, set it to 0
    end
    if bool == false then
        persistentData.AFTON = 0 -- set to 0 if this is a new run and not continued
    end
    local seed = Game():GetSeeds():GetStartSeed()
    rng:SetSeed(seed, RECOMMENDED_SHIFT_IDX) -- omfg
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.start)

function mod:skinUse(item, rng, player, flags, activeSlot, customVarData)
    local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position - Vector(0, -50))
    local soCalledRandomItem = Game():GetRoom():GetSeededCollectible(rng:GetSeed())
    if rng:RandomFloat() < 1/10 then
        soCalledRandomItem = 519
    end
    Isaac.Spawn(5, 100, soCalledRandomItem, pos, Vector.Zero, player)

    if player:GetPlayerType() == PlayerType.PLAYER_THELOST or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
        if rng:RandomFloat() < 1/12 then
            player:Kill()
        end
    else
        local brokenHearts = rng:RandomInt(5) - 2
        if brokenHearts == 0 then
            if player:GetMaxHearts() > 0 or player:GetBoneHearts() > 0 then
                player:AddMaxHearts(-2)
            else
                player:AddSoulHearts(-4)
            end
            brokenHearts = 1
        elseif brokenHearts < 0 then
            if player:GetBrokenHearts() == 0 then
                brokenHearts = brokenHearts * -1
            end
        end

        local maxHP = 12
        if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            maxHP = 18
        end
        if brokenHearts > 0 and (player:GetSoulHearts() / 2 + player:GetMaxHearts() / 2 + player:GetBoneHearts() + player:GetBrokenHearts()) >= maxHP then
            brokenHearts = 1
        end
        player:AddBrokenHearts(brokenHearts)
    end

    Game():ShowHallucination(10)
    persistentData.AFTON = persistentData.AFTON + 1

    return {
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.skinUse, skin)

function mod:replaceItems()
    if Isaac.GetPlayer():HasCollectible(skin) == false and rng:RandomInt(20) < persistentData.AFTON then 
        return skin 
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, mod.replaceItems)

if EID then
    EID:addCollectible(skin, "Spawns an item from the current room's item pool#10% chance for that item to be {{Collectible519}} Lil Delirium#{{BrokenHeart}} Randomly grants or removes Broken Hearts, sometimes removing hearts or heart containers#!!! Replaces future items if Isaac isn't holding it {{ColorSilver}}(+5% chance per use)#{{Player10}} 8% chance to kill you as The Lost")
end