local ReverseLovers = {}

local utility = JosephMod.utility
local enums = JosephMod.enums

local RECOMMENDED_SHIFT_IDX = 35
local MAGICSKIN2 = enums.Collectibles.MAGIC_SKIN_SINGLE_USE
local MAGIC_SKIN_REPLACE_CHANCE = 0.33

local firstTimeMagicSkin = false
local dontReplace = false

---@param player EntityPlayer
---@param card Card
---@param firstTime boolean
function ReverseLovers:initReverseLovers(player, card, firstTime)
    if firstTime ~= true then return end
    firstTimeMagicSkin = true
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseLovers.initReverseLovers, Card.CARD_REVERSE_LOVERS)

---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseLovers:removeReverseLovers(player, card, slot)
    firstTimeMagicSkin = false
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseLovers.removeReverseLovers, Card.CARD_REVERSE_LOVERS)


function ReverseLovers:ReplaceItemSpawn(pool, _, seed)
    if not utility:AnyPlayerHasEnchantment(Card.CARD_REVERSE_LOVERS) then return end
    if dontReplace then return end
    local rng = RNG()
    rng:SetSeed(seed, RECOMMENDED_SHIFT_IDX)
    if rng:RandomFloat() < MAGIC_SKIN_REPLACE_CHANCE or firstTimeMagicSkin == true then
        firstTimeMagicSkin = false
        return MAGICSKIN2
    end
    firstTimeMagicSkin = false
end
JosephMod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, ReverseLovers.ReplaceItemSpawn)


---@param player EntityPlayer
function ReverseLovers:UseNewMagicSkin(item, rng, player, flags, slot)
    if player == nil then return end

    player:AddBrokenHearts(1)
    if player:GetMaxHearts() >= 2 then
        player:AddMaxHearts(-2)
    elseif player:GetBoneHearts() >= 1 then
        player:AddBoneHearts(-1)
    else
        player:AddSoulHearts(-4)
    end
    dontReplace = true
    local item = Isaac.Spawn(5, 100, 0, Isaac.GetFreeNearPosition(player.Position, 20), Vector.Zero, player)
    dontReplace = false
    item:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    local poof = Isaac.Spawn(1000, 15, 0, item.Position, Vector.Zero, item)
    poof.Color = Color(1, 0.2, 0.4, 1.0, 0.3)
    return {
        Remove = true,
        ShowAnim = true,
    }
end
JosephMod:AddCallback(ModCallbacks.MC_USE_ITEM, ReverseLovers.UseNewMagicSkin, MAGICSKIN2)