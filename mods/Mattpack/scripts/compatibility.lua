local mod = MattPack
local game = mod.constants.game

function mod:modCompat()
    -- Sheriff
    if Sheriff then
        Sheriff.Characters.TheSheriff.MaxAmmoSubtract[MattPack.Items.Balor] = 3
        table.insert(Sheriff.Entities.Revolver.GUN_REPLACEMENTS[4].AnyOneCollectibles, MattPack.Items.Balor)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, mod.modCompat)
mod:modCompat()

-- [Q%] Golden Brimstone!!
local brimsone = Isaac.GetItemIdByName("Golden Brimstone") -- ensure the mod is on :sob:
if brimsone then
    -- this is stupid LMAO thanks eid
    local OldRegisterMod = RegisterMod
    mod.hijackedModReferences = {}
    RegisterMod = function (modName, apiVersion, ...)
        local reference = OldRegisterMod(modName, apiVersion, ...)
        mod.hijackedModReferences[modName] = reference
        return reference
    end
    
    local goldenBrimstoneReference = MattPack.hijackedModReferences["Best Mod Ever btw if you didnt know"]
    if goldenBrimstoneReference then
        local config = Isaac.GetItemConfig()
        local q5s = {brimsone}
        for i = 1, config:GetCollectibles().Size - 1 do
            local item = config:GetCollectible(i)
            if item and item.Quality == 5 then
                table.insert(q5s, i)
            end
        end
    
        local anyPlayer
        goldenBrimstoneReference.PickupInit = function(goldenBrimstoneReference, pickup)
            for i = 0, game:GetNumPlayers() - 1 do
                if Isaac.GetPlayer(i):HasCollectible(brimsone) then
                    anyPlayer = true
                end
            end
            local itemConfig = config:GetCollectible(pickup.SubType)
            if not pickup.Touched and anyPlayer and pickup.SubType ~= brimsone and itemConfig.Quality ~= 5 then
                local q5ID = q5s[math.random(1, #q5s)]
                if pickup.Variant == PickupVariant.PICKUP_SHOPITEM or PickupVariant == PickupVariant.PICKUP_COLLECTIBLE then
                    pickup:Morph(pickup.Type, pickup.Variant, q5ID, true)
                else
                    pickup:Morph(pickup.Type, PickupVariant.PICKUP_COLLECTIBLE, q5ID)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
                end
            end
        end
    end
end    
