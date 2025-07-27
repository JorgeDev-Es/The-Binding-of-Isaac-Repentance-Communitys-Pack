
local mod = FiendFolio

local blueShit = {
    FiendFolio.ITEM.COLLECTIBLE.GOLEMS_ORB,
    FiendFolio.ITEM.COLLECTIBLE.PEACH_CREEP,
    FiendFolio.ITEM.COLLECTIBLE.OPHIUCHUS,
    FiendFolio.ITEM.COLLECTIBLE.CETUS,
    FiendFolio.ITEM.COLLECTIBLE.DEIMOS,
    FiendFolio.ITEM.COLLECTIBLE.PAGE_OF_VIRTUES,
    FiendFolio.ITEM.COLLECTIBLE.MUSCA,
    FiendFolio.ITEM.COLLECTIBLE.ROBOBABY3,
    FiendFolio.ITEM.COLLECTIBLE.NYX,
    FiendFolio.ITEM.COLLECTIBLE.SPINDLE,
    FiendFolio.ITEM.COLLECTIBLE.AZURITE_SPINDOWN,
    FiendFolio.ITEM.COLLECTIBLE.D3,
    FiendFolio.ITEM.COLLECTIBLE.BAG_OF_BOBBIES,
    FiendFolio.ITEM.COLLECTIBLE.BOTTLE_OF_WATER,
    FiendFolio.ITEM.COLLECTIBLE.DADS_BATTERY,
}
local considerablyBlueShit = {
    FiendFolio.ITEM.COLLECTIBLE.MAMA_SPOOTER,
    FiendFolio.ITEM.COLLECTIBLE.PINHEAD,
    FiendFolio.ITEM.COLLECTIBLE.CHIRUMIRU,
    FiendFolio.ITEM.COLLECTIBLE.BEDTIME_STORY,
    FiendFolio.ITEM.COLLECTIBLE.TELEBOMBS,
}

mod:AddCallback( ModCallbacks.MC_POST_GAME_STARTED, function()
    if PandorasBoxTweaked then
        if not FiendFolioConsideredBlueItems then
            for i = 1, #blueShit do
                table.insert(PandorasBoxTweaked.TRUE_BLUE_ITEMS, blueShit[i])
            end
            for i = 1, #considerablyBlueShit do
                table.insert(PandorasBoxTweaked.SLIGHT_BLUE_ITEMS, considerablyBlueShit[i])
            end
            FiendFolioConsideredBlueItems = true
        end
    end
end)