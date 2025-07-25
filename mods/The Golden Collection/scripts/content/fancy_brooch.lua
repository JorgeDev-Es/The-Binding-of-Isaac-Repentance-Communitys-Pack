--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Fancy brooch"),

    ITEM_POOL = {
        { ["sub"] = CollectibleType.COLLECTIBLE_MIDAS_TOUCH },
        { ["sub"] = CollectibleType.COLLECTIBLE_GOLDEN_RAZOR },
        { ["sub"] = CollectibleType.COLLECTIBLE_EYE_OF_GREED },
        { ["sub"] = CollectibleType.COLLECTIBLE_GREEDS_GULLET },
        { ["sub"] = CollectibleType.COLLECTIBLE_KEEPERS_SACK },
        { ["sub"] = CollectibleType.COLLECTIBLE_KEEPERS_KIN },
        { ["sub"] = CollectibleType.COLLECTIBLE_KEEPERS_BOX },
        { ["sub"] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER },
        { ["sub"] = CollectibleType.COLLECTIBLE_DADS_LOST_COIN },
        { ["sub"] = CollectibleType.COLLECTIBLE_MOMS_COIN_PURSE },
        { ["sub"] = CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER },
        { ["sub"] = CollectibleType.COLLECTIBLE_DOLLAR },
        { ["sub"] = CollectibleType.COLLECTIBLE_3_DOLLAR_BILL },
        { ["sub"] = CollectibleType.COLLECTIBLE_WOODEN_NICKEL },
        { ["sub"] = CollectibleType.COLLECTIBLE_CROOKED_PENNY },
        { ["sub"] = CollectibleType.COLLECTIBLE_DEEP_POCKETS },
        { ["sub"] = CollectibleType.COLLECTIBLE_STRAW_MAN },
        { ["sub"] = CollectibleType.COLLECTIBLE_DADS_RING },
        { ["sub"] = CollectibleType.COLLECTIBLE_SACK_OF_SACKS },
        { ["sub"] = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES },
        { ["sub"] = CollectibleType.COLLECTIBLE_MYSTERY_SACK },
        { ["sub"] = CollectibleType.COLLECTIBLE_CENSER },
        { ["sub"] = CollectibleType.COLLECTIBLE_PORTABLE_SLOT },
        { ["sub"] = CollectibleType.COLLECTIBLE_TELEPORT_2 },
        { ["sub"] = CollectibleType.COLLECTIBLE_MOMS_BRACELET },
        { ["sub"] = CollectibleType.COLLECTIBLE_QUARTER },
        { ["sub"] = CollectibleType.COLLECTIBLE_HOLY_GRAIL },
        { ["sub"] = CollectibleType.COLLECTIBLE_MOMS_KEY },
        { ["sub"] = CollectibleType.COLLECTIBLE_PAGEANT_BOY },
        { ["sub"] = CollectibleType.COLLECTIBLE_PIGGY_BANK },
        { ["sub"] = CollectibleType.COLLECTIBLE_STEAM_SALE },
        { ["sub"] = CollectibleType.COLLECTIBLE_MORE_OPTIONS },
        { ["sub"] = CollectibleType.COLLECTIBLE_PAY_TO_PLAY },
        { ["sub"] = CollectibleType.COLLECTIBLE_GLITCHED_CROWN },
        { ["sub"] = CollectibleType.COLLECTIBLE_MEMBER_CARD },

        { ["sub"] = CollectibleType.COLLECTIBLE_BUM_FRIEND },
        { ["sub"] = CollectibleType.COLLECTIBLE_KEY_BUM },
        { ["sub"] = CollectibleType.COLLECTIBLE_DARK_BUM },
        { ["sub"] = CollectibleType.COLLECTIBLE_BUMBO },

        -- { ["sub"] = CollectibleType.COLLECTIBLE_KEY_PIECE_1 },
        -- { ["sub"] = CollectibleType.COLLECTIBLE_KEY_PIECE_2 },

        { ["sub"] = Isaac.GetItemIdByName("Abundance"), ["price"] = 20 },
        { ["sub"] = Isaac.GetItemIdByName("Ancient hourglass") },
        { ["sub"] = Isaac.GetItemIdByName("Childrens fund") },
        { ["sub"] = Isaac.GetItemIdByName("Black card") },
        { ["sub"] = Isaac.GetItemIdByName("Flakes of gold") },
        { ["sub"] = Isaac.GetItemIdByName("Gold rope") },
        { ["sub"] = Isaac.GetItemIdByName("Golden god!"), ["price"] = 20 },
        { ["sub"] = Isaac.GetItemIdByName("Spinning cent") },
        { ["sub"] = Isaac.GetItemIdByName("Molten dime") },
        { ["sub"] = Isaac.GetItemIdByName("Nugget") },
        { ["sub"] = Isaac.GetItemIdByName("Quality stamp") },
        { ["sub"] = Isaac.GetItemIdByName("Shining clicker") },
        { ["sub"] = Isaac.GetItemIdByName("Stolen placard") },
        { ["sub"] = Isaac.GetItemIdByName("Temptation") },
        { ["sub"] = Isaac.GetItemIdByName("Silver lacquered chisel") }
    },
    TRINKET_POOL = {
        { ["sub"] = TrinketType.TRINKET_SWALLOWED_PENNY },
        { ["sub"] = TrinketType.TRINKET_CURSED_PENNY },
        { ["sub"] = TrinketType.TRINKET_CHARGED_PENNY },
        { ["sub"] = TrinketType.TRINKET_BLESSED_PENNY },
        { ["sub"] = TrinketType.TRINKET_ROTTEN_PENNY },
        { ["sub"] = TrinketType.TRINKET_COUNTERFEIT_PENNY },
        { ["sub"] = TrinketType.TRINKET_FLAT_PENNY },
        { ["sub"] = TrinketType.TRINKET_BURNT_PENNY },
        { ["sub"] = TrinketType.TRINKET_BLOODY_PENNY },
        { ["sub"] = TrinketType.TRINKET_BUTT_PENNY },

        { ["sub"] = TrinketType.TRINKET_GOLDEN_HORSE_SHOE },
        { ["sub"] = TrinketType.TRINKET_SHINY_ROCK },
        { ["sub"] = TrinketType.TRINKET_SILVER_DOLLAR },
        { ["sub"] = TrinketType.TRINKET_GILDED_KEY },
        { ["sub"] = TrinketType.TRINKET_LUCKY_SACK },
        { ["sub"] = TrinketType.TRINKET_TORN_POCKET },
        
        { ["sub"] = TrinketType.TRINKET_CRACKED_CROWN },
        { ["sub"] = TrinketType.TRINKET_WICKED_CROWN },
        { ["sub"] = TrinketType.TRINKET_HOLY_CROWN },
        { ["sub"] = TrinketType.TRINKET_DEVILS_CROWN },
        { ["sub"] = TrinketType.TRINKET_BLOODY_CROWN },

        { ["sub"] = Isaac.GetTrinketIdByName("Cracked penny") },
        { ["sub"] = Isaac.GetTrinketIdByName("Red penny") },
        { ["sub"] = Isaac.GetTrinketIdByName("Slot machine handle") },
        { ["sub"] = Isaac.GetTrinketIdByName("Slot reel") }
    },
    CARD_POOL = {
        { ["sub"] = Card.CARD_REVERSE_HERMIT },
        { ["sub"] = Card.CARD_HERMIT },
        { ["sub"] = Card.CARD_CREDIT },
        { ["sub"] = Card.CARD_ACE_OF_DIAMONDS },
        { ["sub"] = Card.CARD_DIAMONDS_2 },
        { ["sub"] = Card.CARD_WHEEL_OF_FORTUNE },
        { ["sub"] = Card.CARD_REVERSE_WHEEL_OF_FORTUNE },
        { ["sub"] = Card.CARD_SOUL_KEEPER }
    },
    PICKUP_POOL = {
        { ["var"] = PickupVariant.PICKUP_HEART, ["sub"] = HeartSubType.HEART_GOLDEN },
        { ["var"] = PickupVariant.PICKUP_COIN, ["sub"] = CoinSubType.COIN_GOLDEN },
        { ["var"] = PickupVariant.PICKUP_KEY, ["sub"] = KeySubType.KEY_GOLDEN },
        { ["var"] = PickupVariant.PICKUP_BOMB, ["sub"] = BombSubType.BOMB_GOLDEN },
        { ["var"] = PickupVariant.PICKUP_GRAB_BAG, ["sub"] = 0, ["price"] = 1 },
        { ["var"] = PickupVariant.PICKUP_PILL, ["sub"] = PillColor.PILL_GOLD },
        { ["var"] = PickupVariant.PICKUP_LIL_BATTERY, ["sub"] = BatterySubType.BATTERY_GOLDEN }
    },

    KEY="FANBROO",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
        ItemPoolType.POOL_OLD_CHEST,
        ItemPoolType.POOL_MOMS_CHEST,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Fancy Brooch", DESC = "{{Shop}} Spawns an extra item in shops#{{Coin}} These items are money themed" },
        { LANG = "ru",    NAME = "Необычная брошь", DESC = "{{Shop}} Создает дополнительный предмет в магазинах#{{Coin}} Эти предметы имеют денежную тематику" },
        { LANG = "spa",    NAME = "Broche de lujo", DESC = "{{Shop}} Genera un objeto extra en las tiendas#{{Coin}} Estos objetos tienen temática de dinero" },
        { LANG = "zh_cn", NAME = "花俏的胸针", DESC = "{{Shop}} 商店售卖额外的以金钱为主题的道具" },
        { LANG = "ko_kr", NAME = "팬시 브로치", DESC = "{{Shop}} 상점에 아이템을 추가로 판매합니다.#{{Coin}} 추가 아이템은 돈과 관련된 아이템으로 구성되어 있습니다." },
    },
    EID_TRANS = {"collectible", Isaac.GetItemIdByName("Fancy brooch"), 6},
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Shops will contain an extra item for sale."},
            {str = "These items will be gold/greed/money themed."},
            {str = "The price of these items will fluctuate."},
            {str = "Counts towards the mom transformation."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function TrySpawnItem(allowDupes)
    local numPlayers = GOLCG.GAME:GetNumPlayers()
    local playerHasItem = false
    local hasPoundOfFlesh = false
    local hasChaos = false
    local steamSaleMultiplier = 0

    -- Check if there are players carrying the item
    for i=1,numPlayers do
        local player = GOLCG.GAME:GetPlayer(tostring((i-1)))

        if player:HasCollectible(item.ID) then
            playerHasItem = player
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_POUND_OF_FLESH) then
            hasPoundOfFlesh = true
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
            hasChaos = true
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_STEAM_SALE) then
            steamSaleMultiplier = steamSaleMultiplier + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_STEAM_SALE)
        end
    end

    -- Spawn shop item
    if playerHasItem then
        local RNG = playerHasItem:GetCollectibleRNG(item.ID)

        for i=1, (allowDupes and TCC_API:HasGlo(item.KEY) or 1) do
            local startPos = ((GOLCG.GAME.Difficulty > 1) and Vector(1000, 320) or GOLCG.GAME:GetRoom():FindFreePickupSpawnPosition(Vector(320, 220), 0, true))
            local selectionVar = 0
            local selection = RNG:RandomInt(12)+1
            local selectionPrice = 25

            RNG:Next()

            if selection <= 6  then
                if hasChaos then
                    selection = { ['sub'] = 0 }
                else
                    -- try to get an unique item up to 5 times.
                    for i=1, 5 do
                        local option = item.ITEM_POOL[RNG:RandomInt(#item.ITEM_POOL)+1]
                        RNG:Next()

                        for i=1,numPlayers do
                            local player = GOLCG.GAME:GetPlayer(tostring((i-1)))
                
                            if player:HasCollectible(option.sub) then
                                goto skipend
                            end
                        end

                        selection = option
                        break

                        ::skipend::

                    end

                    if not selection.sub then selection = item.ITEM_POOL[RNG:RandomInt(#item.ITEM_POOL)+1] end
                end

                selectionVar = PickupVariant.PICKUP_COLLECTIBLE
                selectionPrice = selection.price or 12
            elseif selection <= 8 then
                selection = item.TRINKET_POOL[RNG:RandomInt(#item.TRINKET_POOL)+1]
                selectionVar = PickupVariant.PICKUP_TRINKET
                selectionPrice = selection.price or 8
            elseif selection <= 10 then
                selection = item.CARD_POOL[RNG:RandomInt(#item.CARD_POOL)+1]
                selectionVar = PickupVariant.PICKUP_TAROTCARD
                selectionPrice = selection.price or 5
            else
                selection = item.PICKUP_POOL[RNG:RandomInt(#item.PICKUP_POOL)+1]
                selectionVar = selection.var
                selectionPrice = selection.price or 8
            end

            local curitem = GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, selectionVar, selection.sub, startPos, Vector(0,0), playerHasItem):ToPickup()

            curitem.Price = GOLCG:getPrice(
                selectionPrice + RNG:RandomInt(math.ceil(selectionPrice/3)),
                selectionVar~=PickupVariant.PICKUP_COLLECTIBLE, 
                hasPoundOfFlesh, 
                steamSaleMultiplier
            )

            curitem.AutoUpdatePrice = false
            curitem.ShopItemId = -1

            GOLCG.GAME:SpawnParticles(curitem.Position, EffectVariant.GOLD_PARTICLE, 5, 1)
            GOLCG.GAME:SpawnParticles(curitem.Position, EffectVariant.CRACKED_ORB_POOF, 1, 0)
        end
    end
end

function item:OnNewRoom()
    local room = GOLCG.GAME:GetRoom()

    if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_SHOP then
        TrySpawnItem(true)
    end
end

function item:OnCollect(_, _, touched) -- Apply stats on pickup if they haven't been granted
    if not touched then    
        local room = GOLCG.GAME:GetRoom()
        if room:GetType() == RoomType.ROOM_SHOP then
            TrySpawnItem()
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()  GOLCG:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,    item.OnNewRoom) end
function item:Disable() GOLCG:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnNewRoom) end

TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCollect, item.ID)
TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item