local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Black card"),
    EFFECT = Isaac.GetEntityVariantByName("Black card effect"),

    BUY_COOLDOWN = 65,

    LUCK = 0.075,
    SPEED = 0.008,
    DAMAGE = 0.02,
    SHOTSPEED = 0.05,

    KEY = "BLCA",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Black Card", DESC = "Buy items without money#{{ArrowDown}} Get a stats down for pennies owed" },
        { LANG = "ru",    NAME = "Черная карта", DESC = "Покупайте вещи без денег#{{ArrowDown}} Получите уменьшение характеристики за покупку" },
        { LANG = "spa",   NAME = "Carta Negra", DESC = "Puedes comprar cosas sin pagar#{{ArrowDown}} recibes una baja de estadísticas dependiendo de los centavos que debas" },
        { LANG = "zh_cn", NAME = "黑金信用卡", DESC = "没有足够的硬币也能购买商品，不足的部分将计入负债#{{ArrowDown}} 每一分钱的负债都会降低属性：#-0.075 运气#-0.008 移速#-0.02 攻击#-0.05 弹速#获得的硬币将优先偿还负债#负债最高99分钱" },
        { LANG = "ko_kr", NAME = "검은 카드", DESC = "동전이 부족해도 빚을 져 상점 아이템을 구매할 수 있습니다.(최대 99{{Coin}})#{{ArrowDown}} 빚진 1{{Coin}} 당 이하 능력치 감소:#{{Blank}} {{Speed}}이동속도 -0.008#{{Blank}} {{Damage}}공격력 -0.02#{{Blank}} {{Shotspeed}}탄속 -0.05#{{Blank}} {{Luck}}운 -0.075" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Allows you to buy items while not having enough money"},
            {str = "You can owe up to 99 pennies"},
            {str = "For every penny owed the player loses: 0.075 luck, 0.008 speed, 0.02 damage and 0.05 shotspeed"},
        }
    }
}

local stats = {
    [CacheFlag.CACHE_SHOTSPEED] = {key = "SHOTSPEED", name = "ShotSpeed"},
    [CacheFlag.CACHE_SPEED] =  {key = "SPEED", name = "MoveSpeed"},
    [CacheFlag.CACHE_DAMAGE] = {key = "DAMAGE", name = "Damage"},
    [CacheFlag.CACHE_LUCK] = {key = "LUCK", name = "Luck"}
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function canBuy(player, pickup)
    if pickup.Variant == PickupVariant.PICKUP_HEART then
        if pickup.SubType == HeartSubType.HEART_FULL 
        or pickup.SubType == HeartSubType.HEART_HALF 
        or pickup.SubType == HeartSubType.HEART_DOUBLEPACK 
        or pickup.SubType == HeartSubType.HEART_SCARED then
            return player:CanPickRedHearts()
        elseif pickup.SubType == HeartSubType.HEART_SOUL 
        or pickup.SubType == HeartSubType.HEART_HALF_SOUL then
            return player:CanPickSoulHearts()
        elseif pickup.SubType == HeartSubType.HEART_BLACK then
            return player:CanPickBlackHearts()
        elseif pickup.SubType == HeartSubType.HEART_GOLDEN then
            return player:CanPickGoldenHearts()
        elseif pickup.SubType == HeartSubType.HEART_BONE then
            return player:CanPickBoneHearts()
        elseif pickup.SubType == HeartSubType.HEART_ROTTEN then
            return player:CanPickRottenHearts()
        elseif pickup.SubType == HeartSubType.HEART_BLENDED then
            return (player:CanPickSoulHearts() or player:CanPickRedHearts())
        end
    elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
        return (player:NeedsCharge(ActiveSlot.SLOT_PRIMARY) or player:NeedsCharge(ActiveSlot.SLOT_SECONDARY) or player:NeedsCharge(ActiveSlot.SLOT_POCKET))
    end

    return true
end

local function hasSlotAvailable(player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG) 
    and not player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) then
        return true
    end

    if not player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) then
        return true
    end

    return false
end

local function animateDebt(player, isRaised)
    local first =  string.sub(tostring(GOLCG.SAVEDATA.BLACK_CARD.Debt), 1, 1)
    local second =  string.sub(tostring(GOLCG.SAVEDATA.BLACK_CARD.Debt), 2, 2)

    local DebtEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, item.EFFECT, 0, player.Position, Vector(0,0), player)
    local effectSprite = DebtEffect:GetSprite()
    effectSprite:ReplaceSpritesheet(1, "gfx/effects/GOLCOL_num_" .. (second ~= '' and first or '0') .. ".png")
    effectSprite:ReplaceSpritesheet(2, "gfx/effects/GOLCOL_num_" .. (second ~= ''and second or first) .. ".png")
    effectSprite:Play(isRaised and 'Raise' or 'Lower')
    effectSprite:LoadGraphics()
    DebtEffect.DepthOffset = player.DepthOffset+100
    DebtEffect:Update()
end

function item:OnCollision(pickup, collider, _)
    if GOLCG.SAVEDATA.BLACK_CARD then
        -- If can buy (using black card) then make item free so the player can buy the item next frame
        if collider.Type == EntityType.ENTITY_PLAYER
        and collider:ToPlayer():HasCollectible(item.ID)
        then
            local player = collider:ToPlayer()

            if pickup:IsShopItem()
            and GOLCG.SAVEDATA.BLACK_CARD.IgnoreUpdates <= 0
            and GOLCG.SAVEDATA.BLACK_CARD.Debt < 99
            and player:GetNumCoins() < pickup.Price 
            and canBuy(player, pickup) then
                if not player:CanPickupItem() 
                or player:IsHoldingItem() 
                or not player:IsItemQueueEmpty() then
                    return true
                end

                -- local healthPadding = 0

                -- if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                --     healthPadding = player:GetMaxHearts() - player:GetHearts()
                -- end

                -- player:AddCoins(tempPrice + healthPadding)

                -- if healthPadding then
                --     player:AddHearts(-healthPadding)
                --     player:Update()
                -- end

                GOLCG.SAVEDATA.BLACK_CARD.OldPrice = pickup.Price
                
                pickup.Price = PickupPrice.PRICE_FREE
                pickup.AutoUpdatePrice = false
                pickup.Visible = false
                pickup.Position = player.Position
                pickup:Update()

                GOLCG.SAVEDATA.BLACK_CARD.IgnoreUpdates = item.BUY_COOLDOWN
                GOLCG.SAVEDATA.BLACK_CARD.PickupFilter = pickup.InitSeed
                
                return true
            end
        end

        -- Make sure a pickup isn't grabbed on the same frame (or while in cooldown) an item is supposed to be bought
        if GOLCG.SAVEDATA.BLACK_CARD.PickupFilter then
            if GOLCG.SAVEDATA.BLACK_CARD.PickupFilter ~= pickup.InitSeed and GOLCG.SAVEDATA.BLACK_CARD.IgnoreUpdates > 0 then
                return true
            else
                local player = collider:ToPlayer()

                local tempPrice = GOLCG.SAVEDATA.BLACK_CARD.OldPrice-player:GetNumCoins()
                GOLCG.SAVEDATA.BLACK_CARD.Debt = ((GOLCG.SAVEDATA.BLACK_CARD.Debt + tempPrice) > 99 and 99 or (GOLCG.SAVEDATA.BLACK_CARD.Debt + tempPrice))
                player:AddCoins(-GOLCG.SAVEDATA.BLACK_CARD.OldPrice)

                animateDebt(player, true)	
                GOLCG.SFX:Play(SoundEffect.SOUND_CASH_REGISTER, 2, 0)
                GOLCG.SAVEDATA.BLACK_CARD.PickupFilter = nil
                GOLCG.SAVEDATA.BLACK_CARD.OldPrice = nil
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()

                GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))
            end
        end
    end
end

function item:OnUpdate()
    if GOLCG.SAVEDATA.BLACK_CARD then
        if GOLCG.SAVEDATA.BLACK_CARD.Debt and GOLCG.SAVEDATA.BLACK_CARD.Debt > 0 and Isaac.GetPlayer(0):GetNumCoins() > 0 and GOLCG.SAVEDATA.BLACK_CARD.IgnoreUpdates <= 48 then
            local player = Isaac.GetPlayer(0)
            local amount = player:GetNumCoins()

            player:AddCoins(-GOLCG.SAVEDATA.BLACK_CARD.Debt)
            
            GOLCG.SAVEDATA.BLACK_CARD.Debt = ((GOLCG.SAVEDATA.BLACK_CARD.Debt - amount > 0) and (GOLCG.SAVEDATA.BLACK_CARD.Debt - amount) or 0)

            if GOLCG.SAVEDATA.BLACK_CARD.IgnoreUpdates < 40 then
                animateDebt(player, false)
                GOLCG.SFX:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE, 1.5, 0)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        elseif GOLCG.SAVEDATA.BLACK_CARD.IgnoreUpdates > 0 then
            GOLCG.SAVEDATA.BLACK_CARD.IgnoreUpdates = GOLCG.SAVEDATA.BLACK_CARD.IgnoreUpdates - 1
        end
    end
end

function item:OnCache(player, flag) -- Reload/Apply room and floor based stats
    if GOLCG.SAVEDATA.BLACK_CARD.Debt > 0 and player:HasCollectible(item.ID) and not player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM) then
        if stats[flag] then
            local stat = stats[flag]
            player[stat.name] = (player[stat.name] - (item[stat.key] * GOLCG.SAVEDATA.BLACK_CARD.Debt))
        end
    end
end

function item:OnEffectUpdate(effect)
    if effect.FrameCount > 17 then
        effect:Remove()
    end
end

function item:OnDoor(player)
	if TCC_API:Has(item.KEY, player) and player:GetNumCoins() == 0 and GOLCG.SAVEDATA.BLACK_CARD.Debt < 99 then
		local pos = player.Position + player.Velocity:Resized(player.Size + 20)
		local room = GOLCG.GAME:GetRoom()
		local ent = room:GetGridEntityFromPos(pos)

		if ent ~= nil and ent.Desc.Type == GridEntityType.GRID_DOOR then	
            local door = ent:ToDoor()
            if door:IsLocked() and door:GetVariant() == DoorVariant.DOOR_LOCKED and string.find(door:GetSprite():GetFilename(), "Arcade") then
                door:TryUnlock(player, true)
                GOLCG.SAVEDATA.BLACK_CARD.Debt = GOLCG.SAVEDATA.BLACK_CARD.Debt+1
                animateDebt(player, true)
                GOLCG.SFX:Play(SoundEffect.SOUND_CASH_REGISTER, 2, 0)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()

                GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))
            end
		end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    GOLCG:AddCallback(ModCallbacks.MC_POST_UPDATE,          item.OnUpdate   )
    GOLCG:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,       item.OnCache    )
    GOLCG:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, item.OnCollision)
    GOLCG:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE,  item.OnDoor)
end

function item:Disable()
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_UPDATE,          item.OnUpdate   )
    GOLCG:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,       item.OnCache    )
    GOLCG:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, item.OnCollision)
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE,  item.OnDoor)

    local numPlayers = GOLCG.GAME:GetNumPlayers()
    for i=1,numPlayers do
        local player = GOLCG.GAME:GetPlayer(tostring((i-1)))
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
    end
end

GOLCG:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, item.OnEffectUpdate, item.EFFECT)
TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item