local LilSlots = {}
local enums = JosephMod.enums

local RNG_SHIFT_INDEX = 35

local itemConfig = Isaac.GetItemConfig()
local LIL_SLOT = enums.Collectibles.LIL_SLOT_MACHINE
local LIL_FORTUNE = enums.Collectibles.LIL_FORTUNE_TELLER
local LIL_BLOOD = enums.Collectibles.LIL_BLOOD_BANK
local CONFIG_SLOT = itemConfig:GetCollectible(LIL_SLOT)
local CONFIG_FORTUNE = itemConfig:GetCollectible(LIL_FORTUNE)
local CONFIG_BLOOD = itemConfig:GetCollectible(LIL_BLOOD)

---@param player EntityPlayer
function LilSlots:EvaluateCache(player)
    local effects = player:GetEffects()
    local count = effects:GetCollectibleEffectNum(LIL_SLOT) + player:GetCollectibleNum(LIL_SLOT)
    local rng = RNG()
    local seed = math.max(Random(), 1)
    rng:SetSeed(seed, RNG_SHIFT_INDEX)

    player:CheckFamiliar(LIL_SLOT, count, rng, CONFIG_SLOT)
end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LilSlots.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function LilSlots:HandleInit(familiar)
    familiar:AddToFollowers()
end
JosephMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LilSlots.HandleInit, LIL_SLOT)


---@param familiar EntityFamiliar
function LilSlots:HandleUpdate(familiar)
    local sprite = familiar:GetSprite()
    local player = familiar.Player



end