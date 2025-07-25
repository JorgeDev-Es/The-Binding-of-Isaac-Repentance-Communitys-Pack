local other_mods = {}

local enums = JosephMod.enums
local mod = JosephMod

function other_mods:CompatScripts()
    if TheFuture then
        TheFuture.ModdedCharacterDialogue["Joseph​"] = {
            "you look like you know your way around cards",
            "...",
            "up for a game of four souls?",
        }
    end

    if UniqueItemsAPI then
        UniqueItemsAPI.RegisterMod("Joseph")
        UniqueItemsAPI.RegisterCharacter("Joseph​", false, "Joseph")
        UniqueItemsAPI.AssignUniqueObject({
            PlayerType = enums.PlayerType.PLAYER_JOSEPH,
            ObjectID = CollectibleType.COLLECTIBLE_BIRTHRIGHT,
            SpritePath = {"gfx/items/collectibles/joseph_birthright.png"},
            GlobalMod = false
        }, UniqueItemsAPI.ObjectType.COLLECTIBLE)
    end



























end
mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, other_mods.CompatScripts)