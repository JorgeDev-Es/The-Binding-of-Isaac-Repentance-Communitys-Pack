local Shredder = {}
local mod = JosephMod

local enums = JosephMod.enums
local utility = JosephMod.utility

local SHREDDER = enums.Collectibles.SHREDDER


TSIL.SaveManager.AddPersistentVariable(
    JosephMod,
    "ShreddedCards", 
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_RUN,
    false
)

---@param player EntityPlayer
function mod:UseShredder(item, rng, player, flags)
    local card = player:GetCard(0)
    if not (card and (card ~= 0) and Isaac.GetItemConfig():GetCard(card):IsCard()) then
        SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
        return {Discharge = false, ShowAnim = true}
    end
    player:RemovePocketItem(0)
    SFXManager():Play(SoundEffect.SOUND_ROCKET_BLAST_DEATH)
    local shreddedCards = TSIL.SaveManager.GetPersistentVariable(JosephMod, "ShreddedCards")
    table.insert(shreddedCards, card)
    TSIL.SaveManager.SetPersistentVariable(JosephMod, "ShreddedCards", shreddedCards)

    local pickupsToSpawn = 5
    for i=1, pickupsToSpawn, 1 do
        Isaac.CreateTimer(function()
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                player:AddWisp(SHREDDER, player.Position + Vector(0, -20))
            else
                Isaac.Spawn(5, 0, 1, player.Position, Vector(math.random(-3, 3), math.random(3, 6)), player)
            end
            SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 2, false, 1.2)
        end, i*2, 1, true)
    end
    return {Discharge = true, ShowAnim = true}

end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseShredder, SHREDDER)

local lastCardSpawned = 1
local ignoreShred = false
function mod:GetCard(rng, card)
    if not Isaac.GetItemConfig():GetCard(card):IsCard() then return end
    if ignoreShred == true then return end
    local shreddedCards = TSIL.SaveManager.GetPersistentVariable(JosephMod, "ShreddedCards")
    local isShredded = false
    for _, v in ipairs(shreddedCards) do
        if v == card then
            isShredded = true
        end
    end
    if not isShredded then return end

    ignoreShred = true
    local attempts = 0
    while attempts < 200 do
        local rng = Isaac.GetPlayer():GetCollectibleRNG(SHREDDER)
        local newCard = Game():GetItemPool():GetCard(rng:Next(), true, false, false)
        local isAlsoShredded = false
        for _, v in ipairs(shreddedCards) do
            if v == newCard then
                isAlsoShredded = true
            end
        end
        if isAlsoShredded == false and newCard ~= lastCardSpawned then 
            ignoreShred = false
            lastCardSpawned = newCard
            return newCard
        end
        attempts = attempts + 1
    end
    ignoreShred = false
    return 1


end
mod:AddCallback(ModCallbacks.MC_GET_CARD, mod.GetCard)


---@param entity Entity
function Shredder:OnWispDeath(entity)
    if entity.Variant ~= FamiliarVariant.WISP
    or entity.SubType ~= SHREDDER then
        return
    end

    Isaac.Spawn(5, 0, 1, entity.Position, Vector.Zero, entity)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Shredder.OnWispDeath, EntityType.ENTITY_FAMILIAR)
