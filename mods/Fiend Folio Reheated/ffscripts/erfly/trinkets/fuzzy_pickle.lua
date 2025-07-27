local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:fuzzyPicklePlayerUpdate(player, data)
    if player:HasTrinket(mod.ITEM.TRINKET.FUZZY_PICKLE) then
        local heldItem = player.QueuedItem.Item
        if heldItem and (heldItem:IsCollectible() or heldItem:IsTrinket()) then
            data.lastHeldItemID = {heldItem.ID, heldItem:IsCollectible()}
        else
            if data.lastHeldItemID then
                local itemIsReference
                local partialRef
                if data.lastHeldItemID[2] then
                    --print("checking items")
                    for i = 1, #mod.ReferenceItems.Actives do
                        if mod.ReferenceItems.Actives[i].ID == data.lastHeldItemID[1] then
                            itemIsReference = mod.ReferenceItems.Actives[i].Reference
                            partialRef = mod.ReferenceItems.Actives[i].Partial
                            break
                        end   
                    end
                    if not itemIsReference then
                        for i = 1, #mod.ReferenceItems.Passives do
                            if mod.ReferenceItems.Passives[i].ID == data.lastHeldItemID[1] then
                                itemIsReference = mod.ReferenceItems.Passives[i].Reference
                                partialRef = mod.ReferenceItems.Passives[i].Partial
                                break
                            end   
                        end
                    end
                else
                    --print("checking trinkets")
                    for i = 1, #mod.ReferenceItems.Trinkets do
                        if mod.ReferenceItems.Trinkets[i].ID == data.lastHeldItemID[1] then
                            itemIsReference = mod.ReferenceItems.Trinkets[i].Reference
                            partialRef = mod.ReferenceItems.Trinkets[i].Partial
                            break
                        end   
                    end
                    if not itemIsReference then
                        for i = 1, #mod.ReferenceItems.Rocks do
                            if mod.ReferenceItems.Rocks[i].ID == data.lastHeldItemID[1] then
                                itemIsReference = mod.ReferenceItems.Rocks[i].Reference
                                partialRef = mod.ReferenceItems.Rocks[i].Partial
                                break
                            end   
                        end
                    end
                end
                if itemIsReference then
                    local str = {partialRef and "This item references" or "This item is a reference to", itemIsReference}
                    for i = 1, 120 do
                        mod.scheduleForUpdate(function()
                            for k = 1, 2 do
                                local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(mod.TempestFont:GetStringWidth(str[k]) * -0.5, -(player.SpriteScale.Y * 35) - i/3 - 15)
                                local opacity
                                local cap = 90
                                if i >= cap then
                                    opacity = 1 - ((i-cap)/30)
                                else
                                    opacity = i/cap
                                end
                                --Isaac.RenderText(str, pos.X, pos.Y, 1, 1, 1, opacity)
                                mod.TempestFont:DrawString(str[k], pos.X, pos.Y + (12 * k), KColor(1,1,1,opacity), 0, false)
                            end
                        end, i, ModCallbacks.MC_POST_RENDER)
                    end
                end
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
                data.lastHeldItemID = nil
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:HasTrinket(mod.ITEM.TRINKET.FUZZY_PICKLE) then
        local referenceCount = 0
        for i = 1, #mod.ReferenceItems.Actives do
            referenceCount = referenceCount + (player:GetCollectibleNum(mod.ReferenceItems.Actives[i].ID) * (mod.ReferenceItems.Actives[i].Partial and 0.5 or 1) * 5)
        end
        for i = 1, #mod.ReferenceItems.Passives do
            referenceCount = referenceCount + (player:GetCollectibleNum(mod.ReferenceItems.Passives[i].ID) * (mod.ReferenceItems.Passives[i].Partial and 0.5 or 1) * 1)
        end
        for i = 1, #mod.ReferenceItems.Trinkets do
            referenceCount = referenceCount + (player:GetTrinketMultiplier(mod.ReferenceItems.Trinkets[i].ID) * (mod.ReferenceItems.Trinkets[i].Partial and 0.5 or 1) * 2.5)
        end
        for i = 1, #mod.ReferenceItems.Rocks do
            referenceCount = referenceCount + (mod.GetGolemTrinketPower(player, mod.ReferenceItems.Rocks[i].ID) * (mod.ReferenceItems.Rocks[i].Partial and 0.5 or 1) * 2.5)
        end
        --print(referenceCount)
        player.Damage = player.Damage + (referenceCount * 0.1)
    end
end, CacheFlag.CACHE_DAMAGE)

mod.ReferenceItems = {
    Actives = {
        {ID = CollectibleType.COLLECTIBLE_BIBLE,            Reference = "King Gizzard & the Lizard Wizard"}, --Thank you June, this is so stupid
        {ID = CollectibleType.COLLECTIBLE_NECRONOMICON,     Reference = "Evil Dead"},
        {ID = CollectibleType.COLLECTIBLE_TELEPORT,         Reference = "Spelunky"},
        {ID = CollectibleType.COLLECTIBLE_DOCTORS_REMOTE,   Reference = "Super Meat Boy"},
        {ID = CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP,   Reference = "Racism"},
        {ID = CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK, Reference = "The Anarchist Cookbook"},
        {ID = CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, Reference = "My Little Pony"},
        {ID = CollectibleType.COLLECTIBLE_THE_NAIL,         Reference = "Castlevania"},
        {ID = CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, Reference = "Inception"},
        {ID = CollectibleType.COLLECTIBLE_GAMEKID,          Reference = "The Nintendo GameBoy"},
        {ID = CollectibleType.COLLECTIBLE_MONSTER_MANUAL,   Reference = "Dungeons and Dragons"},
        {ID = CollectibleType.COLLECTIBLE_FORGET_ME_NOW,    Reference = "Arrested Development"},
        {ID = CollectibleType.COLLECTIBLE_NOTCHED_AXE,      Reference = "Minecraft"},
        {ID = CollectibleType.COLLECTIBLE_CANDLE,           Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_TELEPATHY_BOOK,   Reference = [["For Dummies" book series]]},
        {ID = CollectibleType.COLLECTIBLE_HOW_TO_JUMP,      Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_RED_CANDLE,       Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_THE_JAR,          Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_BOOMERANG,        Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_FRIEND_BALL,      Reference = "Pokemon"},
        {ID = CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR,  Reference = "Portal"},
        {ID = CollectibleType.COLLECTIBLE_MINE_CRAFTER,     Reference = "Minecraft"},
        {ID = CollectibleType.COLLECTIBLE_JAR_OF_FLIES,     Reference = "Alice In Chains"},
        {ID = CollectibleType.COLLECTIBLE_WAIT_WHAT,        Reference = "I Can't Believe It's Not Butter!", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_POTATO_PEELER,    Reference = "The Merchant of Venice", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_METRONOME,        Reference = "Pokemon"},
        {ID = CollectibleType.COLLECTIBLE_MR_ME,            Reference = "Rick and Morty"},
        {ID = CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD, Reference = "NetHack, Altered Beast"},
        {ID = CollectibleType.COLLECTIBLE_GOLDEN_RAZOR,     Reference = "Four Souls"},
        {ID = CollectibleType.COLLECTIBLE_FREE_LEMONADE,    Reference = "Pornography", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_STAIRWAY,         Reference = "Led Zeppelin"},
        {ID = CollectibleType.COLLECTIBLE_MOMS_BRACELET,    Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_ETERNAL_D6,       Reference = "Florian Himsl"},
        {ID = CollectibleType.COLLECTIBLE_GENESIS,          Reference = "Genesis MOD"},
        {ID = CollectibleType.COLLECTIBLE_MEGA_MUSH,        Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_R_KEY,            Reference = "Enter the Gungeon", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_MAGIC_SKIN,       Reference = "The Wild Ass's Skin"},
        {ID = CollectibleType.COLLECTIBLE_PLUM_FLUTE,       Reference = "Pokemon"},
        {ID = CollectibleType.COLLECTIBLE_VADE_RETRO,       Reference = "Nuclear Throne"},
        {ID = CollectibleType.COLLECTIBLE_SPIN_TO_WIN,      Reference = "Beyblade"},
        {ID = CollectibleType.COLLECTIBLE_BERSERK,          Reference = "DOOM"},
        {ID = CollectibleType.COLLECTIBLE_SUPLEX,           Reference = "Final Fantasy, Kirby"},
        {ID = CollectibleType.COLLECTIBLE_SPINDOWN_DICE,    Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_DECAP_ATTACK,     Reference = "Decap Attack"},
        --Fiend Folio
        {ID = mod.ITEM.COLLECTIBLE.FIEND_FOLIO,             Reference = "Fiend Folio (MOD)"},
        {ID = mod.ITEM.COLLECTIBLE.MARIAS_IPAD,             Reference = "Apple"},
        {ID = mod.ITEM.COLLECTIBLE.FROG_HEAD,               Reference = "Nuclear Throne"},
        {ID = mod.ITEM.COLLECTIBLE.SANGUINE_HOOK,           Reference = "Madness Combat"},
        {ID = mod.ITEM.COLLECTIBLE.AVGM,                    Reference = "A.V.G.M."},
        {ID = mod.ITEM.COLLECTIBLE.BEDTIME_STORY,           Reference = "Go the **** to sleep!"},
        {ID = mod.ITEM.COLLECTIBLE.FIEND_MIX,               Reference = "Making Fiends"},
        {ID = mod.ITEM.COLLECTIBLE.WHITE_PEPPER,            Reference = "Ween"},
        {ID = mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1, Reference = "Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_2, Reference = "Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_3, Reference = "Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4, Reference = "Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_5, Reference = "Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_6, Reference = "Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_8, Reference = "Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_12,Reference = "Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.WRONG_WARP,              Reference = "Super Mario"},
        {ID = mod.ITEM.COLLECTIBLE.DOGBOARD,                Reference = "Dogboard"},
        {ID = mod.ITEM.COLLECTIBLE.TOY_CAMERA,              Reference = "Touhou Project"},
        {ID = mod.ITEM.COLLECTIBLE.SNOW_GLOBE,              Reference = "The Legend of Bum-Bo"},
        {ID = mod.ITEM.COLLECTIBLE.KING_WORM,               Reference = "Adventure Time and Homestuck"},
        {ID = mod.ITEM.COLLECTIBLE.KALUS_HEAD,              Reference = "#MyDogKalu"},
        {ID = mod.ITEM.COLLECTIBLE.YICK_HEART,              Reference = "YIIK: A Postmodern RPG"},
        {ID = mod.ITEM.COLLECTIBLE.GAMMA_GLOVES,            Reference = "She-Hulk: Attorney at Law"},
        {ID = mod.ITEM.COLLECTIBLE.HEDONISTS_COOKBOOK,      Reference = "Natural Harvest"},
        {ID = mod.ITEM.COLLECTIBLE.ERRORS_CRAZY_SLOTS,      Reference = "Hunter x Hunter"},
        {ID = mod.ITEM.COLLECTIBLE.SCULPTED_PEPPER,         Reference = "Pizza Tower"},
    },
    Passives = {
        {ID = CollectibleType.COLLECTIBLE_1UP,              Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM,   Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_TRANSCENDENCE,    Reference = "IT", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_COMPASS,          Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_STEVEN,           Reference = "Time Fcuk"},
        {ID = CollectibleType.COLLECTIBLE_DR_FETUS,         Reference = "Super Meat Boy"},
        {ID = CollectibleType.COLLECTIBLE_MAGNETO,          Reference = "X-Men"},
        {ID = CollectibleType.COLLECTIBLE_TREASURE_MAP,     Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_LADDER,           Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_STEAM_SALE,       Reference = "Steam"},
        {ID = CollectibleType.COLLECTIBLE_MINI_MUSH,        Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT,     Reference = "Super Meat Boy"},
        {ID = CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT,  Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_SPELUNKER_HAT,    Reference = "Spelunky"},
        {ID = CollectibleType.COLLECTIBLE_SUPER_BANDAGE,    Reference = "Super Meat Boy"},
        {ID = CollectibleType.COLLECTIBLE_LITTLE_CHAD,      Reference = "Super Meat Boy"},
        {ID = CollectibleType.COLLECTIBLE_LITTLE_GISH,      Reference = "Gish"},
        {ID = CollectibleType.COLLECTIBLE_LITTLE_STEVEN,    Reference = "Time Fcuk"},
        {ID = CollectibleType.COLLECTIBLE_PARASITE,         Reference = "The Visitor"},
        {ID = CollectibleType.COLLECTIBLE_DEAD_BIRD,        Reference = "Thicker Than Water"},
        {ID = CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, Reference = "Castlevania"},
        {ID = CollectibleType.COLLECTIBLE_BOBBY_BOMB,       Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_FOREVER_ALONE,    Reference = "Rage Comics"},
        {ID = CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT, Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_ANKH,             Reference = "Spelunky", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_EPIC_FETUS,       Reference = "Super Meat Boy"},
        {ID = CollectibleType.COLLECTIBLE_HOLY_WATER,       Reference = "Castlevania"},
        {ID = CollectibleType.COLLECTIBLE_SMB_SUPER_FAN,    Reference = "Super Meat Boy"},
        {ID = CollectibleType.COLLECTIBLE_MEAT,             Reference = "Bonk's Adventure"},
        {ID = CollectibleType.COLLECTIBLE_MOMS_KEY,         Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE, Reference = "Humble Bundle"},
        {ID = CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES, Reference = "Super Meat Boy"},
        {ID = CollectibleType.COLLECTIBLE_GNAWED_LEAF,      Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_ANTI_GRAVITY,     Reference = "Watchmen"},
        {ID = CollectibleType.COLLECTIBLE_GIMPY,            Reference = "Pulp Fiction"},
        {ID = CollectibleType.COLLECTIBLE_BLACK_LOTUS,      Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_BALL_OF_TAR,      Reference = "Gish"},
        {ID = CollectibleType.COLLECTIBLE_STOP_WATCH,       Reference = "Castlevania"},
        {ID = CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW, Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_INFAMY,           Reference = "Castlevania"},
        {ID = CollectibleType.COLLECTIBLE_STARTER_DECK,     Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_MISSING_NO,       Reference = "Pokemon"},
        {ID = CollectibleType.COLLECTIBLE_DARK_MATTER,      Reference = "Kirby"},
        {ID = CollectibleType.COLLECTIBLE_MISSING_PAGE_2,   Reference = "Evil Dead"},
        {ID = CollectibleType.COLLECTIBLE_DRY_BABY,         Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_BBF,              Reference = "Pornography"},
        {ID = CollectibleType.COLLECTIBLE_HOLY_MANTLE,      Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE, Reference = "Clockwork Orange"},
        {ID = CollectibleType.COLLECTIBLE_BROKEN_WATCH,     Reference = "Castlevania"},
        {ID = CollectibleType.COLLECTIBLE_BOMBER_BOY,       Reference = "Bomberman"},
        {ID = CollectibleType.COLLECTIBLE_CRACK_JACKS,      Reference = "Cracker Jack"},
        {ID = CollectibleType.COLLECTIBLE_THE_WIZ,          Reference = "NetHack"},
        {ID = CollectibleType.COLLECTIBLE_8_INCH_NAILS,     Reference = "Nine Inch Nails"},
        {ID = CollectibleType.COLLECTIBLE_ZODIAC,           Reference = "The Zodiac Killer", RareDesc = "Ted Cruz"},
        {ID = CollectibleType.COLLECTIBLE_CHAOS,            Reference = "Eternal Champion"},
        {ID = CollectibleType.COLLECTIBLE_SPIDER_MOD,       Reference = "Spidermod"},
        {ID = CollectibleType.COLLECTIBLE_GB_BUG,           Reference = "Indie Game: The Movie"},
        {ID = CollectibleType.COLLECTIBLE_BLACK_POWDER,     Reference = "Pearl Jam", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_MY_SHADOW,        Reference = "Frank Sinatra", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_METAL_PLATE,      Reference = "Texas Chainsaw Massacre 2"},
        {ID = CollectibleType.COLLECTIBLE_CONE_HEAD,        Reference = "Saturday Night Live"},
        {ID = CollectibleType.COLLECTIBLE_DADS_LOST_COIN,   Reference = "Alcoholics Anonymous"},
        {ID = CollectibleType.COLLECTIBLE_FINGER,           Reference = "Fingered"},
        {ID = CollectibleType.COLLECTIBLE_KING_BABY,        Reference = "Army of Darkness", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_YO_LISTEN,        Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_LITTLE_HORN,      Reference = "1984, Science!", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_POKE_GO,          Reference = "Pokemon"},
        {ID = CollectibleType.COLLECTIBLE_BOZO,             Reference = "Bozo the Clown"},
        {ID = CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX,   Reference = "Funko POP!"},
        {ID = CollectibleType.COLLECTIBLE_LEPROSY,          Reference = "The Room", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_ANGELIC_PRISM,    Reference = "Pink Floyd"},
        {ID = CollectibleType.COLLECTIBLE_LIL_SPEWER,       Reference = "Spewer"},
        {ID = CollectibleType.COLLECTIBLE_BRITTLE_BONES,    Reference = "Nuclear Throne"},
        {ID = CollectibleType.COLLECTIBLE_2SPOOKY,          Reference = "Memes"},
        {ID = CollectibleType.COLLECTIBLE_SPIRIT_SWORD,     Reference = "The Legend of Zelda"},
        {ID = CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR,  Reference = "Metroid"},
        {ID = CollectibleType.COLLECTIBLE_MEMBER_CARD,      Reference = "Fire Emblem"},
        {ID = CollectibleType.COLLECTIBLE_OCULAR_RIFT,      Reference = "Oculus Rift"},
        {ID = CollectibleType.COLLECTIBLE_FREEZER_BABY,     Reference = "Vanilla Ice", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_LIL_DUMPY,        Reference = "Badlands"},
        {ID = CollectibleType.COLLECTIBLE_ROTTEN_TOMATO,    Reference = "Rotten Tomatoes"},
        {ID = CollectibleType.COLLECTIBLE_BIRTHRIGHT,       Reference = "Nuclear Throne", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_BOOSTER_PACK,     Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_BOT_FLY,          Reference = "FTL: Faster Than Light"},
        {ID = CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL,   Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_GUPPYS_EYE,       Reference = "Four Souls"},
        {ID = CollectibleType.COLLECTIBLE_POUND_OF_FLESH,   Reference = "The Merchant of Venice"},
        {ID = CollectibleType.COLLECTIBLE_BONE_SPURS,       Reference = "The Legend of Bum-Bo"},
        {ID = CollectibleType.COLLECTIBLE_GLITCHED_CROWN,   Reference = "Super Mario"},
        {ID = CollectibleType.COLLECTIBLE_JELLY_BELLY,      Reference = "Jelly Belly"},
        {ID = CollectibleType.COLLECTIBLE_SANGUINE_BOND,    Reference = "Magic: The Gathering"},
        {ID = CollectibleType.COLLECTIBLE_TWISTED_PAIR,     Reference = "Neil Breen"},
        {ID = CollectibleType.COLLECTIBLE_ECHO_CHAMBER,     Reference = "Magic: The Gathering", Partial = true},
        {ID = CollectibleType.COLLECTIBLE_TMTRAINER,        Reference = "Pokemon"},
        --Fiend Folio
        {ID = mod.ITEM.COLLECTIBLE.RANDY_THE_SNAIL,         Reference = "LeatherIceCream"},
        {ID = mod.ITEM.COLLECTIBLE.GMO_CORN,                Reference = "The 1958 FDA Coverup"},
        {ID = mod.ITEM.COLLECTIBLE.DEVILS_UMBRELLA,         Reference = "BOY BAND"},
        {ID = mod.ITEM.COLLECTIBLE.BEE_SKIN,                Reference = "Hivemind"},
        {ID = mod.ITEM.COLLECTIBLE.YOUR_ETERNAL_REWARD,     Reference = "Team Fortress 2"},
        {ID = mod.ITEM.COLLECTIBLE.GRABBER,                 Reference = "Grabber"},
        {ID = mod.ITEM.COLLECTIBLE.IMP_SODA,                Reference = "Fanta"},
        {ID = mod.ITEM.COLLECTIBLE.DICHROMATIC_BUTTERFLY,   Reference = "Touhou Project"},
        {ID = mod.ITEM.COLLECTIBLE.CHIRUMIRU,               Reference = "Touhou Project"},
        {ID = mod.ITEM.COLLECTIBLE.MODERN_OUROBOROS,        Reference = "Lisa: The Pointless"},
        {ID = mod.ITEM.COLLECTIBLE.DEVILS_HARVEST,          Reference = "Devil's Harvest (MOD)"},
        {ID = mod.ITEM.COLLECTIBLE.OPHIUCHUS,               Reference = "Homestuck", Partial = true},
        {ID = mod.ITEM.COLLECTIBLE.DEIMOS,                  Reference = "Madness Combat"},
        {ID = mod.ITEM.COLLECTIBLE.BIRTHDAY_GIFT,           Reference = "Earthbound"},
        {ID = mod.ITEM.COLLECTIBLE.SECRET_STASH,            Reference = "Touhou Project"},
        {ID = mod.ITEM.COLLECTIBLE.BLACK_MOON,              Reference = "Evangelion"},
        {ID = mod.ITEM.COLLECTIBLE.HYPNO_RING,              Reference = "Captain Underpants"},
        {ID = mod.ITEM.COLLECTIBLE.GREG_THE_EGG,            Reference = "Kinder Eggs"},
        {ID = mod.ITEM.COLLECTIBLE.CYANIDE_DEADLY_DOSE,     Reference = "Memes"},
        {ID = mod.ITEM.COLLECTIBLE.DADS_POSTICHE,           Reference = "YIIK: A Postmodern RPG"},
        {ID = mod.ITEM.COLLECTIBLE.EXCELSIOR,               Reference = "Marvel"},
        {ID = mod.ITEM.COLLECTIBLE.HAPPYHEAD_AXE,           Reference = "Shrek, Club Penguin, Vampire Survivors"},
        {ID = mod.ITEM.COLLECTIBLE.WIMPY_BRO,               Reference = "Super Mario"},
        {ID = mod.ITEM.COLLECTIBLE.NYX,                     Reference = "Hades"},
        {ID = mod.ITEM.COLLECTIBLE.DICE_GOBLIN,             Reference = "Dice Goblin"},
        {ID = mod.ITEM.COLLECTIBLE.DEVILS_DAGGER,           Reference = "Devil Daggers"},
        {ID = mod.ITEM.COLLECTIBLE.CRAZY_JACKPOT,           Reference = "beatmania, REFLEC BEAT VOLZZA, Hommarju feat. Mayumi Morinaga - Crazy Jackpot, also appearing in beatmania IIDX 28 BISTROVER"},
        {ID = mod.ITEM.COLLECTIBLE.NIL_PASTA,               Reference = "Nil Pasta"},
        {ID = mod.ITEM.COLLECTIBLE.TIME_ITSELF,             Reference = "Time Fcuk"},
        {ID = mod.ITEM.COLLECTIBLE.HOST_ON_TOAST,           Reference = "Dad's Nuke"},
        {ID = mod.ITEM.COLLECTIBLE.KINDA_EGG,               Reference = "Kinder Eggs"},
        {ID = mod.ITEM.COLLECTIBLE.SMASH_TROPHY,            Reference = "The Maria vs Jon Series"},
        {ID = mod.ITEM.COLLECTIBLE.FISTFUL_OF_ASH,          Reference = "Perfect Vermin"},
        {ID = mod.ITEM.COLLECTIBLE.ISAAC_DOT_CHR,           Reference = "Doki Doki Literature Club!"},
        {ID = mod.ITEM.COLLECTIBLE.ISAACD_EULOGY,           Reference = "A Disey Adventure"},
        {ID = mod.ITEM.COLLECTIBLE.BRICK_FIGURE,            Reference = "LEGO"},
        {ID = mod.ITEM.COLLECTIBLE.GOLDSHI_LUNCH,           Reference = "Uma Musume, FamilyMart"},
        {ID = mod.ITEM.COLLECTIBLE.TWINKLE_OF_CONTAGION,    Reference = "Battle for BFDI"},
        {ID = mod.ITEM.COLLECTIBLE.REHEATED_PIZZA,          Reference = "Pizza Tower", Partial = true},
        {ID = mod.ITEM.COLLECTIBLE.GREEN_ORANGE,            Reference = "ZeroRanger"},
    },
    Trinkets = {
        {ID = TrinketType.TRINKET_CARTRIDGE,                Reference = "The Nintendo Entertainment System"},
        {ID = TrinketType.TRINKET_BIBLE_TRACT,              Reference = "Chick Tracts"},
        {ID = TrinketType.TRINKET_MONKEY_PAW,               Reference = "W. W. Jacobs"},
        {ID = TrinketType.TRINKET_BROKEN_ANKH,              Reference = "Spelunky", Partial = true},
        {ID = TrinketType.TRINKET_LIBERTY_CAP,              Reference = "Yoshi's Island", Partial = true},
        {ID = TrinketType.TRINKET_MISSING_PAGE,             Reference = "Evil Dead"},
        {ID = TrinketType.TRINKET_LOUSE,                    Reference = "Resident Evil", Partial = true},
        {ID = TrinketType.TRINKET_ERROR,                    Reference = "The Hypertext Transfer Protocol"},
        {ID = TrinketType.TRINKET_ENDLESS_NAMELESS,         Reference = "Nirvana, Time Fcuk"},
        {ID = TrinketType.TRINKET_OUROBOROS_WORM,           Reference = "Ouroboros"},
        {ID = TrinketType.TRINKET_NOSE_GOBLIN,              Reference = "Ren and Stimpy"},
        {ID = TrinketType.TRINKET_M,                        Reference = "Pokemon"},
        {ID = TrinketType.TRINKET_FORGOTTEN_LULLABY,        Reference = "Mudeth"},
        {ID = TrinketType.TRINKET_MODELING_CLAY,            Reference = "Four Souls"},
        {ID = TrinketType.TRINKET_OLD_CAPACITOR,            Reference = "Voltage Voltage Starving", Partial = true},
        {ID = TrinketType.TRINKET_BLUE_KEY,                 Reference = "The SCP Foundation"},
        {ID = TrinketType.TRINKET_FOUND_SOUL,               Reference = "Memes"},
        {ID = TrinketType.TRINKET_EXPANSION_PACK,           Reference = "The Nintendo 64"},
        --Fiend Folio
        {ID = mod.ITEM.TRINKET.CHILI_POWDER,                Reference = "Breaking Bad"},
        {ID = mod.ITEM.TRINKET.YIN_YANG_ORB,                Reference = "Touhou Project"},
        {ID = mod.ITEM.TRINKET.AUTOPSY_KIT,                 Reference = "_Kilburn"},
        {ID = mod.ITEM.TRINKET.SPIRE_GROWTH,                Reference = "Slay the Spire"},
        {ID = mod.ITEM.TRINKET.JEVILSTAIL,                  Reference = "DELTARUNE"},
        {ID = mod.ITEM.TRINKET.DEALMAKERS,                  Reference = "DELTARUNE"},
        {ID = mod.ITEM.TRINKET.SOLEMN_VOW,                  Reference = "Team Fortress 2"},
        {ID = mod.ITEM.TRINKET.LOST_FLOWER_CROWN,           Reference = "OMORI"},
        {ID = mod.ITEM.TRINKET.ANGRY_FAIC,                  Reference = "Newgrounds"},
        {ID = mod.ITEM.TRINKET.POCKET_DICE,                 Reference = "Hypnosis Microphone"},
        {ID = mod.ITEM.TRINKET.FROG_PUPPET,                 Reference = "The Muppets"},
        {ID = mod.ITEM.TRINKET.TATTERED_FROG_PUPPET,        Reference = "The Muppets"},
        {ID = mod.ITEM.TRINKET.REDHAND,                     Reference = "Grabber"},
        {ID = mod.ITEM.TRINKET.ENERGY_SEARCHER,             Reference = "Pokemon"},
        {ID = mod.ITEM.TRINKET.BROKEN_RECORD,               Reference = "Ween"},
        {ID = mod.ITEM.TRINKET.FUZZY_PICKLE,                Reference = "Earthbound"},
        {ID = mod.ITEM.TRINKET.LEFTOVERS,                   Reference = "Pokemon"},
        {ID = mod.ITEM.TRINKET.DUDS_FLOWER,                 Reference = "The Simpsons"},
        {ID = mod.ITEM.TRINKET.BOMB_TOKEN,                  Reference = "Bee Swarm Simulator"},
    },
    Rocks = {
        {ID = mod.ITEM.ROCK.ROLLING_ROCK,                   Reference = "The Rolling Stones"},
        {ID = mod.ITEM.ROCK.POCKET_SAND,                    Reference = "King of the Hill"},
        {ID = mod.ITEM.ROCK.ARCADE_ROCK,                    Reference = "Minecraft", Partial = true},
        {ID = mod.ITEM.ROCK.THORNY_ROCK,                    Reference = "Hollow Knight"},
        {ID = mod.ITEM.ROCK.SAPPHIC_SAPPHIRE,               Reference = "Stone Butch Blues, Stephen Universe"},
        {ID = mod.ITEM.ROCK.ROSE_QUARTZ,                    Reference = "Steven Universe"},
        {ID = mod.ITEM.ROCK.RAMBLIN_OPAL,                   Reference = "Earthbound"},
        {ID = mod.ITEM.ROCK.HECTOR,                         Reference = "OMORI"},
        {ID = mod.ITEM.ROCK.ROBOT_ROCK,                     Reference = "Daft Punk"},
        {ID = mod.ITEM.ROCK.MEAT_SLAB,                      Reference = "Memes", Partial = true},
        {ID = mod.ITEM.ROCK.FOCUS_CRYSTAL,                  Reference = "Risk of Rain 2"},
        {ID = mod.ITEM.ROCK.ODDLY_SMOOTH_STONE,             Reference = "Slay the Spire"},
        {ID = mod.ITEM.ROCK.CAST_GEM,                       Reference = "Hades"},
        {ID = mod.ITEM.ROCK.AMAZONITE,                      Reference = "Amazon"},
        {ID = mod.ITEM.ROCK.STAR_SAPPHIRE,                  Reference = "Touhou Project"},
        {ID = mod.ITEM.ROCK.TROLLITE,                       Reference = "Rage Comics"},
        {ID = mod.ITEM.ROCK.HEARTHSTONE,                    Reference = "Warcraft"},
        {ID = mod.ITEM.ROCK.NITRO_CRYSTAL,                  Reference = "Discord"},
        {ID = mod.ITEM.ROCK.FRUITY_PEBBLE,                  Reference = "The Flintstones"},
        {ID = mod.ITEM.ROCK.HOMOEROTIC_RUBY,                Reference = "Steven Universe"},
        {ID = mod.ITEM.ROCK.GAY_GARNET,                     Reference = "Steven Universe"},
        --Fossils
        {ID = mod.ITEM.ROCK.FISH_FOSSIL,                    Reference = "Nuclear Throne"},
        {ID = mod.ITEM.ROCK.BURIED_FOSSIL,                  Reference = "Animal Crossing"},
        {ID = mod.ITEM.ROCK.MAXS_FOSSIL,                    Reference = "Memes", Partial = true},
        {ID = mod.ITEM.ROCK.BOMB_SACK_FOSSIL,               Reference = "The Legend of Zelda: Twilight Princess"},
        {ID = mod.ITEM.ROCK.THANK_YOU_FOSSIL,               Reference = "OMORI"},
        --Geodes
        {ID = mod.ITEM.ROCK.QUANTUM_GEODE,                       Reference = "Noita"},
    },
}