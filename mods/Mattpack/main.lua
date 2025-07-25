MattPack = RegisterMod("MattPack", 1)
local mod = MattPack

MattPack.Items = {
    Balor = Isaac.GetItemIdByName("Balor"),
    RockCounter = Isaac.GetItemIdByName("Rock Counter"),
    AltRock = Isaac.GetItemIdByName("Alt Rock"),
    DevilsYoYo = Isaac.GetItemIdByName("Devil's Yo-Yo"),
    KnifeBender = Isaac.GetItemIdByName("Knife Bender"),
    TechOmega = Isaac.GetItemIdByName("Tech Omega"),
    MultiMush = Isaac.GetItemIdByName("Multi Mush"),
    BoulderBottom = Isaac.GetItemIdByName("Boulder Bottom"),
    BenightedHeart = Isaac.GetItemIdByName("Benighted Heart"),
    MutantMycelium = Isaac.GetItemIdByName("Mutant Mycelium"),
    CLSpoonBender = Isaac.GetItemIdByName("Comically Large Spoon Bender"),
    KitchenKnife = Isaac.GetItemIdByName("Kitchen Knife"),
    Tech5090 = Isaac.GetItemIdByName("Tech 5090"),
    BloatedBody = Isaac.GetItemIdByName("Bloated Body"),
    DeadLitter = Isaac.GetItemIdByName("Dead Litter"),
    DivineHeart = Isaac.GetItemIdByName("Divine Heart"),
    WarpedLegion = Isaac.GetItemIdByName("Warped Legion"),
}

MattPack.Q5s = {
    MattPack.Items.Balor,
    MattPack.Items.DevilsYoYo,
    MattPack.Items.KnifeBender,
    MattPack.Items.MultiMush,
    MattPack.Items.BoulderBottom,
    MattPack.Items.BenightedHeart, -- technically not q5 but i'm just using this as a list of conditionals
    MattPack.Items.CLSpoonBender,
    MattPack.Items.BloatedBody,
    MattPack.Items.DeadLitter,
    MattPack.Items.DivineHeart,
    MattPack.Items.WarpedLegion,
}

mod.ItemCacheData = {} -- [ItemID] = {Add, Multiply} -- For simple stat changes

MattPack.Sounds = {
    SawLoop = Isaac.GetSoundIdByName("MP_SawLoop"),
    SawEnd0 = Isaac.GetSoundIdByName("MP_SawEnd0"),
    SawEnd1 = Isaac.GetSoundIdByName("MP_SawEnd1"),
    KnifeBoo = Isaac.GetSoundIdByName("KP_Boo"),
    TechOmegaLoop = Isaac.GetSoundIdByName("TO_Loop"),
    MultiMushPickup = Isaac.GetSoundIdByName("MM_Pickup"),
    BoulderBottomPickup = Isaac.GetSoundIdByName("BB_Pickup"),
    ThePact = Isaac.GetSoundIdByName("MP_ThePact"),
    ChoirDark = Isaac.GetSoundIdByName("MP_ChoirDark"),
    OrbBreak = Isaac.GetSoundIdByName("MP_UKOrb"),
    FountainCreate = Isaac.GetSoundIdByName("DK_FountainCreate"),
    FountainMarker = Isaac.GetSoundIdByName("DK_FountainMarker"),
    FountainCancel = Isaac.GetSoundIdByName("DK_FountainCancel"),
    Tech5090Loop = Isaac.GetSoundIdByName("MP_5090_Loop")
}


local SaveManager = include("scripts.mp_save_manager") -- thank u catinsurance and benny
mod.SaveManager = SaveManager
mod.SaveManager.Init(mod)

MattPack.Config = {
    EIDHintsEnabled = true,
    lbReworkEnabled = true,
    bbBlacklist = true,
    itemPoolConfig = 2,
    balorScreenshakeIntensity = 2
}

if REPENTOGON then
    include("scripts.util")
end

include("scripts.dss")
include("scripts.changelogs")

if REPENTOGON then
    include("scripts.compatibility")
    include("scripts.items.balor")
    include("scripts.items.rock_counter")
    include("scripts.items.devils_yoyo")
    include("scripts.items.knife_bender")
    include("scripts.items.tech_omega")
    include("scripts.items.multi_mush")
    include("scripts.items.boulder_bottom")
    include("scripts.items.mutant_mycelium")
    include("scripts.items.comically_large_spoon_bender")
    include("scripts.items.kitchen_knife")
    include("scripts.items.tech_5090")
    include("scripts.items.bloated_body")
    include("scripts.items.dead_litter")
    include("scripts.items.divine_heart")
    include("scripts.items.benighted_heart")
    include("scripts.items.warped_legion")
    
    include("scripts.tweaks.linger_bean")
    include("scripts.tweaks.knife_piece_gua")
    include("scripts.tweaks.belial_room")
    
    include("scripts.items.other")
    include("scripts.tweaks.other")
    

    local divineHeartResConversion = {
        [1] = 4,
        [2] = 3,
        [3] = 2,
        [4] = 1,
    }

    mod.RunPostDataLoad = {}

    function mod:updateSaveData() -- ough im so tired
        local settingsSave = SaveManager.GetSettingsSave()
        if settingsSave then
            MattPack.Config.itemPoolConfig = (settingsSave.ItemPoolOption or 2)
            MattPack.Config.EIDHintsEnabled = (settingsSave.EIDQ5Hints or 1) == 1
            MattPack.Config.lbReworkEnabled = (settingsSave.LingerBeanReworkToggle or 1) == 1
            MattPack.Config.bbBlacklist = (settingsSave.bbBlacklist or 1) == 1
            MattPack.Config.balorScreenshakeIntensity = (settingsSave.BalorScreenshake or 2)
            MattPack.Config.divineHeartResolution = divineHeartResConversion[settingsSave.DivineHeartResolution or 2] or 2
            mod.updateLingerBean((MattPack.Config.lbReworkEnabled and 1) or 2)
            mod:setBBBlacklist()
            mod:setItemPools()
        end
    end
    SaveManager.AddCallback(mod.SaveManager.Utility.CustomCallback.POST_DATA_SAVE, mod.updateSaveData)
    SaveManager.AddCallback(mod.SaveManager.Utility.CustomCallback.POST_DATA_LOAD, mod.updateSaveData)

    
    SaveManager.AddCallback(mod.SaveManager.Utility.CustomCallback.POST_GLOBAL_DATA_LOAD, function(_)
        for _,func in ipairs(mod.RunPostDataLoad) do
            func()
        end
        mod.RunPostDataLoad = {}
    end)

    local q5Sprite = Sprite()
    q5Sprite:Load("gfx/quality5icon.anm2")
    
    local megaUpSprite = Sprite()
    megaUpSprite:Load("gfx/eid_inline_icons.anm2")
    megaUpSprite:SetRenderFlags(megaUpSprite:GetRenderFlags() | AnimRenderFlags.GOLDEN | AnimRenderFlags.IGNORE_GAME_TIME)
    
    local lazyWormSprite = Sprite()
    lazyWormSprite:Load("gfx/005.350_trinket.anm2")
    lazyWormSprite:ReplaceSpritesheet(0, 'gfx/items/trinkets/trinket_066_lazyworm.png', true)
    lazyWormSprite:GetLayer(0):SetSize(Vector.One * (1/2))
    if EID then
        EID:addIcon("Quality5", "Quality5", 0, 10, 10, 0, 0, q5Sprite)
        EID:addIcon("MegaArrowUp", "ArrowUp", 0, 10, 10, 0, 0, megaUpSprite)
        EID:addIcon("MPLazyWorm", "Idle", 0, 16, 16, 6, 9, lazyWormSprite)
    end
    
    if FiendFolio then
        -- Fuzzy Pickle Compatibility
        local fuzzyPickleMap = FiendFolio.ReferenceItems
    
        table.insert(fuzzyPickleMap.Actives, {ID = MattPack.Items.KitchenKnife, Reference = "DELTARUNE"})
    
        table.insert(fuzzyPickleMap.Passives, {ID = MattPack.Items.Balor, Reference = "Irish mythology"})
        table.insert(fuzzyPickleMap.Passives, {ID = MattPack.Items.BoulderBottom, Reference = "Memes", Partial = true})
        table.insert(fuzzyPickleMap.Passives, {ID = MattPack.Items.CLSpoonBender, Reference = "Memes"})
        table.insert(fuzzyPickleMap.Passives, {ID = MattPack.Items.AltRock, Reference = "Alt rock, Kurt Cobain, New Radicals"})
        table.insert(fuzzyPickleMap.Passives, {ID = MattPack.Items.Tech5090, Reference = "the NVIDIA GeForce RTX 5090"})
        table.insert(fuzzyPickleMap.Passives, {ID = MattPack.Items.MultiMush, Reference = "Mario Kart"})
    end
else
    function mod:displayWarning()
        DeadSeaScrollsMenu.QueueMenuOpen("Lazy MattPack", "rgonpopup", 1, true)
    end
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.displayWarning)
end