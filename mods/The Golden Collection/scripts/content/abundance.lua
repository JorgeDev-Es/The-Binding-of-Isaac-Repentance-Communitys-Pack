--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Abundance"),

    ITEM_REMOVE_CHANCE = 40,
    CURSES = {
        LevelCurse.CURSE_OF_THE_UNKNOWN,
        LevelCurse.CURSE_OF_BLIND,
        LevelCurse.CURSE_OF_THE_LOST
    },

    KEY="AB",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CURSE,
        ItemPoolType.POOL_GREED_SECRET
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Abundance", DESC = "Makes shops free#Entering a shop triggers a random bad event" },
        { LANG = "ru",    NAME = "Избыток", DESC = "Делает магазины бесплатными#Вход в магазин вызывает случайное плохое событие" },
        { LANG = "spa",   NAME = "Abundancia", DESC = "Las tiendas son gratuitas#Entrar a las tiendas provocará un evento aleatorio desafortunado" },
        { LANG = "zh_cn", NAME = "富庶", DESC = "富庶#{{ArrowDown}} 每层首次进入商店时随机触发一项事件：#受到两颗心的伤害 (不会致死)#使用一次主动道具#失去金钥匙、金炸弹和主动道具充能#商品反而更贵并且要与贪婪作战#只能买一件商品#商品售卖位置减少#赋予致盲、迷途或未知诅咒#店长被替换成一群怪物#摧毁所有机器和乞丐" },
        { LANG = "ko_kr", NAME = "풍요", DESC = "모든 상점 아이템의 가격이 0원이 됩니다.#{{ArrowDown}} 상점 진입 시 아래의 해로운 효과 중 하나 발생:#캐릭터에게 체력 2칸의 피해(이 효과로 인해 사망하지 않음)#액티브 아이템 강제 사용#황금폭탄, 황금열쇠, 액티브 충전량 강제 소모#Greed 미니보스 소환#판매 중인 아이템 중 하나만 구입 가능#일부 상점 아이템 소멸#Unknown, Lost, Blind 저주 중 1~2개 발동#상점 시체 위치에 적들 소환#모든 슬롯머신(!!!기부기계 포함)과 거지 파괴" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Makes shops free."},
            {str = "Triggers a random negative event when entering a shop for the first time. The following events may occur:"},
            {str = "Take two hearts of damage. (can't happen if it would kill the player)"},
            {str = "Use your active items."},
            {str = "lose golden keys and golden bombs and your active charges."},
            {str = "The shop gets more expensive (x1.5) and a greed fight spawns."},
            {str = "The shop turns into an option in which only one item may be taken."},
            {str = "Some of the shops items will be destroyed."},
            {str = "Gain curse of the unknown, blind or lost (between one and two curses may be granted)."},
            {str = "Spawn a bunch of enemies in place of the shopkeeper."},
            {str = "Destroy all slot machines and beggars."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function defaultEvent()
    local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)

    for i=1, #pickups do
        if RNG:RandomInt(100)+1 <= item.ITEM_REMOVE_CHANCE / pickups[i].Variant == 100 and 1.5 or 1 then
            pickups[i]:Remove()
            GOLCG.GAME:SpawnParticles(pickups[i].Position, EffectVariant.WOOD_PARTICLE, 2, 1)
            GOLCG.GAME:SpawnParticles(pickups[i].Position, EffectVariant.ROCK_PARTICLE, 3, 1)
            GOLCG.GAME:SpawnParticles(pickups[i].Position, EffectVariant.CRACKED_ORB_POOF, 1, 0)
        end
    end
end

local function getCarriedPlayers()
    local players = {}
    local numPlayers = GOLCG.GAME:GetNumPlayers()

    for i=1,numPlayers do
        local player = GOLCG.GAME:GetPlayer(tostring((i-1)))
        if TCC_API:Has(item.KEY, player) then
            players[#players+1] = player
        end
    end

    return players
end

local function canPlayersTakeDamage(players)
    for i=1, #players do
        if players[i]:GetHearts() + players[i]:GetSoulHearts() < 3 then
            return false
        end
    end

    return true
end

local function doPlayersHaveActive(players)
    for i=1, #players do
        if players[i]:GetActiveItem() then
            return true
        end
    end

    return false
end

local function damagePlayers(players)
    for i=1, #players do players[i]:TakeDamage(2, 0, EntityRef(players[i]), 0) end
end

function item:OnNewRoom()
    local room = GOLCG.GAME:GetRoom()

    if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_SHOP then
        local players = getCarriedPlayers()

        if #players <= 0 then return end -- Exit prematurely if no players are carrying the item.

        local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)

        if #pickups <= 0 then return end -- Exit prematurely if the shop is empty (greed fight).

        local allowDamage = canPlayersTakeDamage(players)

        -- Run negative event
        local RNG = players[1]:GetCollectibleRNG(item.ID)
        local eventSelection = 0

        if allowDamage then
            eventSelection = RNG:RandomInt(8) + 1
        else
            eventSelection = RNG:RandomInt(7) + 2
        end

        if eventSelection == 1 then -- Take damage
            damagePlayers(players)
        elseif eventSelection == 2 then -- Use active item
            local canDoActive = doPlayersHaveActive(players)
            if canDoActive then
                for i=1, #players do
                    local player = players[i]
                    if player:GetActiveItem() then
                        player:UseActiveItem(player:GetActiveItem(), UseFlag.USE_OWNED, ActiveSlot.SLOT_PRIMARY)
                        player:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
    
                        if player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) then
                            player:UseActiveItem(player:GetActiveItem(ActiveSlot.SLOT_SECONDARY), UseFlag.USE_OWNED, ActiveSlot.SLOT_SECONDARY)
                            player:DischargeActiveItem(ActiveSlot.SLOT_SECONDARY)
                        end
                    end
                end
            else
                if allowDamage then
                    damagePlayers(players)
                else
                    defaultEvent()
                end
            end
        elseif eventSelection == 3 then -- Lose consumables and discharge actives
            players[1]:RemoveGoldenBomb()
            players[1]:RemoveGoldenKey()

            for i=1, #players do            
                players[i]:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
                players[i]:DischargeActiveItem(ActiveSlot.SLOT_SECONDARY)
                players[i]:DischargeActiveItem(ActiveSlot.SLOT_POCKET)
            end

            GOLCG.SFX:Play(SoundEffect.SOUND_BATTERYDISCHARGE, 1)
        elseif eventSelection == 4 then -- Shop gets more expensive and greed spawns
            GOLCG.SFX:Play(SoundEffect.SOUND_ULTRA_GREED_ROAR_1, 1)
            GOLCG.SeedSpawn(EntityType.ENTITY_GREED, ((RNG:RandomInt(2) > 0) and 2 or 1), 0, room:GetCenterPos(), Vector(0,0), nil)
        elseif eventSelection == 5 then -- turn shop into option
            for i=1, #pickups do
                if pickups[i]:ToPickup():IsShopItem() then
                    pickups[i]:ToPickup().OptionsPickupIndex = 3322
                end
            end
        elseif eventSelection == 6 then -- apply curses
            local level = GOLCG.GAME:GetLevel()

            for i=1, 2 do
                local curse = item.CURSES[RNG:RandomInt(#item.CURSES)+1]
                level:AddCurse(curse)

                if curse ==  LevelCurse.CURSE_OF_BLIND then
                    for _, pickup in pairs(pickups) do
                        if pickup.Variant == 100 then
                            pickup:GetSprite():ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
                            pickup:GetSprite():LoadGraphics()
                        end
                    end
                end
            end
            
            GOLCG.SFX:Play(SoundEffect.SOUND_BLACK_POOF, 2, 0, false, 0.5)
        elseif eventSelection == 7 then --Blows up donation machine/reroll machine
            local slots = Isaac.FindByType(6)

            if slots then
                for i=1, #slots do
                    slots[i]:TakeDamage(99, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(players[1]), 20)
                end
            else
                defaultEvent()
            end
        elseif eventSelection == 8 then -- Replace shopkeepers with enemies
            local shopboys = Isaac.FindByType(EntityType.ENTITY_SHOPKEEPER)
            local pos = GOLCG.GAME:GetRoom():GetCenterPos()

            if shopboys then
                for i=1, #shopboys do
                    local RNG = shopboys[i]:GetDropRNG()

                    GOLCG.SeedSpawn(86,-1, -1, pos, Vector(2,2):Rotated(math.random(360)), nil)
                    GOLCG.SeedSpawn(RNG:RandomInt(2) > 0 and 299 or 90,-1, -1, pos, Vector(2,2):Rotated(math.random(360)), nil)
                    GOLCG.SeedSpawn(RNG:RandomInt(2) > 0 and 299 or 90,-1, -1, pos, Vector(2,2):Rotated(math.random(360)), nil)

                    shopboys[i]:Remove()
                end
            else
                GOLCG.SeedSpawn(86,-1, -1, pos, Vector(2,2):Rotated(math.random(360)), nil)
                GOLCG.SeedSpawn(RNG:RandomInt(2) > 0 and 299 or 90,-1, -1, pos, Vector(2,2):Rotated(math.random(360)), nil)
                GOLCG.SeedSpawn(RNG:RandomInt(2) > 0 and 299 or 90,-1, -1, pos, Vector(2,2):Rotated(math.random(360)), nil)
            end
        else
            defaultEvent()
        end

        for i = 1, #pickups do
            local pickup = pickups[i]:ToPickup()
            if pickup:IsShopItem() then
                pickup.AutoUpdatePrice = false
                pickup.Price = eventSelection == 4 and math.ceil(pickup.Price*1.5) or PickupPrice.PRICE_FREE
            end
        end

        for i=1, #players do
            players[i]:AnimateSad()
        end
    end
end

function item:OnSpawn(pickup)
    if GOLCG.GAME:GetRoom():GetType() == RoomType.ROOM_SHOP then
        pickup.AutoUpdatePrice = false
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable() 
    GOLCG:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnNewRoom)
    GOLCG:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, item.OnSpawn)
end
function item:Disable() 
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnNewRoom)
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_PICKUP_INIT, item.OnSpawn)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item