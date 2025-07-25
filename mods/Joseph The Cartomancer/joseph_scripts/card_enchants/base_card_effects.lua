local BaseCardEffects = {}
local utility = JosephMod.utility
local enums = JosephMod.enums

local RED_HEART_REPLACE_CHANCE = 1/5
local SOUL_HEART_REPLACE_CHANCE = 1/8
local JUSTICE_DROP_REPLACE_CHANCE = 1/7

local firstTimeLovers = false
local firstTimeHeirophant = false
local firstTimeJustice = false


function BaseCardEffects:addCardStats(player, flag)
    local enchantedCards = utility:GetEnchantedCardsPerPlayer(player)
    for key, enchantedCard in pairs(enchantedCards) do
        if enchantedCard == Card.CARD_EMPRESS and flag == CacheFlag.CACHE_DAMAGE then
            utility:AddDamage(player, -0.5)
        end
    
        if enchantedCard == Card.CARD_STRENGTH and flag == CacheFlag.CACHE_DAMAGE and
        (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
        + player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) < 1) then
            player.Damage = player.Damage * 0.83
        end
    
        if enchantedCard == Card.CARD_DEVIL and flag == CacheFlag.CACHE_DAMAGE then
            utility:AddDamage(player, -0.5)
        end
    end
end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BaseCardEffects.addCardStats)


---@param player EntityPlayer
---@param card Card
---@param firstTime boolean | nil
function BaseCardEffects:InitCardEffect(player, card, firstTime)

    JosephMod.BaseCardEffects:AddInnateCollectibles(player, card)


    if card == Card.CARD_EMPRESS then
        player:UseCard(Card.CARD_EMPRESS, UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
    end

    if card == Card.CARD_HIEROPHANT and firstTime == true then
        firstTimeHeirophant = true
    end

    if card == Card.CARD_LOVERS and firstTime == true then
        firstTimeLovers = true
    end

    if card == Card.CARD_JUSTICE and firstTime == true then
        firstTimeJustice = true
    end

    if card == Card.CARD_MAGICIAN then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_SPOON_BENDER, true)
    end

    if card == Card.CARD_STRENGTH then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM, true)
    end

    if card == Card.CARD_HANGED_MAN then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE, true)
    end

    if card == Card.CARD_DEVIL then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, false)
    end

    if card == Card.CARD_WORLD and firstTime == true then
        Game():GetLevel():ShowMap()
    end

    if card == Card.CARD_MOON and firstTime == true then
        local allRooms = Game():GetLevel():GetRooms()
        local found = false
        for idx = 0, allRooms.Size - 1 do
            local room = allRooms:Get(idx)
            if found == false and room.Data.Type == RoomType.ROOM_SECRET then
                room.DisplayFlags = RoomDescriptor.DISPLAY_ICON | RoomDescriptor.DISPLAY_BOX
                found = true
            end
        end
    end

    if card == Card.CARD_SUN and firstTime == true then
        local allRooms = Game():GetLevel():GetRooms()
        for idx = 0, allRooms.Size - 1 do
            local room = allRooms:Get(idx)
            if room.Data.Type == RoomType.ROOM_BOSS then
                room.DisplayFlags = RoomDescriptor.DISPLAY_ICON | RoomDescriptor.DISPLAY_BOX
            end
        end
    end

end


--Runs when removing an enchantment before applying a new one
function BaseCardEffects:RemoveCardEffect(player, card)

    local switch = {
        [Card.CARD_FOOL] = function()
             -- Code for CARD_FOOL
        end,
        [Card.CARD_MAGICIAN] = function()
            -- Code for CARD_MAGICIAN
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_SPOON_BENDER)
        end,
        [Card.CARD_HIGH_PRIESTESS] = function()
            -- Code for CARD_HIGH_PRIESTESS
        end,
        [Card.CARD_EMPRESS] = function()
            -- Code for CARD_EMPRESS
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON)
        end,
        [Card.CARD_EMPEROR] = function()
            -- Code for CARD_EMPEROR
            utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_THERES_OPTIONS)
        end,
        [Card.CARD_HIEROPHANT] = function()
            -- Code for CARD_HIEROPHANT
        end,
        [Card.CARD_LOVERS] = function()
            -- Code for CARD_LOVERS
        end,
        -- [Card.CARD_CHARIOT] = function()
        --     -- Code for CARD_CHARIOT
        --     utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_TAURUS)
        -- end,
        [Card.CARD_JUSTICE] = function()
            -- Code for CARD_JUSTICE
        end,
        [Card.CARD_HERMIT] = function()
            -- Code for CARD_HERMIT
            utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_MEMBER_CARD)
            JosephMod.Schedule(1, function ()
                BaseCardEffects:RemoveShopTrapdoor()
            end,{})

        end,
        [Card.CARD_WHEEL_OF_FORTUNE] = function()
            -- Code for CARD_WHEEL_OF_FORTUNE
            utility:RemoveInnateItem(player, enums.Collectibles.LIL_SLOT_MACHINE)
            utility:RemoveInnateItem(player, enums.Collectibles.LIL_FORTUNE_TELLER)
        end,
        [Card.CARD_STRENGTH] = function()
            -- Code for CARD_STRENGTH
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
        end,
        [Card.CARD_HANGED_MAN] = function()
            -- Code for CARD_HANGED_MAN
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE)
        end,
        [Card.CARD_DEATH] = function()
            -- Code for CARD_DEATH
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_DRY_BABY, -1)
        end,
        [Card.CARD_TEMPERANCE] = function()
            -- Code for CARD_TEMPERANCE
            utility:RemoveInnateItem(player, enums.Collectibles.LIL_BLOOD_BANK)
        end,
        [Card.CARD_DEVIL] = function()
            -- Code for CARD_DEVIL
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL)
        end,
        [Card.CARD_TOWER] = function()
            -- Code for CARD_TOWER
            utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER)
        end,
        [Card.CARD_STARS] = function()
            -- Code for CARD_STAR
            utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_MORE_OPTIONS)
        end,
        [Card.CARD_MOON] = function()
            -- Code for CARD_MOON
            utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_LUNA)
        end,
        [Card.CARD_SUN] = function()
            -- Code for CARD_SUN
            utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_SOL)
        end,
        [Card.CARD_JUDGEMENT] = function()
            -- Code for 
            utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_BUM_FRIEND)
            utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_DARK_BUM)
        end,
        [Card.CARD_WORLD] = function()
            -- Code for CARD_WORLD
        end,
        
        ["default"] = function()
            -- Code for default case
        end
    }
   
   if switch[card] then
      switch[card]()
   else
      switch["default"]()
   end
end


--Runs when first enchanting a card or continuing a run
function BaseCardEffects:AddInnateCollectibles(player, card)

    local switch = {
        [Card.CARD_EMPEROR] = function()
            -- Code for CARD_EMPEROR
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_THERES_OPTIONS, 1)
        end,
        -- [Card.CARD_CHARIOT] = function()
        --     -- Code for CARD_CHARIOT
        --     player:AddInnateCollectible(CollectibleType.COLLECTIBLE_TAURUS, 1)
        -- end,
        [Card.CARD_HERMIT] = function()
            -- Code for CARD_HERMIT
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_MEMBER_CARD, 1)
            if Game():GetRoom():GetType() == RoomType.ROOM_SHOP then
                TSIL.GridEntities.SpawnGridEntity(
                    GridEntityType.GRID_STAIRS,
                    TSIL.Enums.StairsVariant.SECRET_SHOP,
                    Vector(440, 160),
                    true
                )
            end
        end,
        [Card.CARD_WHEEL_OF_FORTUNE] = function()
            -- Code for CARD_WHEEL_OF_FORTUNE
    
            JosephMod.Schedule(3, function ()
                local rng = player:GetCardRNG(Card.CARD_WHEEL_OF_FORTUNE)
                local rand = rng:RandomInt(2) + 1
                if rand == 1 then
                    player:AddInnateCollectible(enums.Collectibles.LIL_SLOT_MACHINE)
                else
                    player:AddInnateCollectible(enums.Collectibles.LIL_FORTUNE_TELLER)
                end
            end,{})
        end,
        [Card.CARD_DEATH] = function()
            -- Code for CARD_DEATH
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_DRY_BABY, 1)
        end,
        [Card.CARD_TEMPERANCE] = function()
            -- Code for CARD_TEMPERANCE
            JosephMod.Schedule(3, function ()
                player:AddInnateCollectible(enums.Collectibles.LIL_BLOOD_BANK)
            end,{})
        end,
        [Card.CARD_TOWER] = function()
            -- Code for CARD_TOWER
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER)
        end,
        [Card.CARD_STARS] = function()
            -- Code for CARD_STAR
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS)
        end,
        [Card.CARD_MOON] = function()
            -- Code for CARD_MOON
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_LUNA)
        end,
        [Card.CARD_SUN] = function()
            -- Code for CARD_SUN
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SOL)
        end,
        [Card.CARD_JUDGEMENT] = function()
            -- Code for CARD_JUDGEMENT
            if card == Card.CARD_JUDGEMENT then
                local rng = player:GetCardRNG(Card.CARD_JUDGEMENT)
                local rand = rng:RandomInt(2) + 1
                if rand == 1 then
                    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_BUM_FRIEND)
                else
                    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_DARK_BUM)
                end
            end
        end,
        
        ["default"] = function()
            -- Code for default case
        end
    }
   
   if switch[card] then
      switch[card]()
   else
      switch["default"]()
   end
end



function BaseCardEffects:EnchantmentEffects(player, enchantedCard, slot)

    local room = Game():GetRoom()
    BaseCardEffects:RemoveShopTrapdoor()

    if enchantedCard == Card.CARD_MAGICIAN then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_SPOON_BENDER, true)
    end

    if enchantedCard == Card.CARD_HIGH_PRIESTESS and (room:IsFirstVisit() or not room:IsClear()) then
        local rng = player:GetCardRNG(Card.CARD_HIGH_PRIESTESS)
        if rng:RandomFloat() > 0.5 or (room:IsFirstVisit() and room:IsClear()) then
            player:UseCard(Card.CARD_HIGH_PRIESTESS, UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD | UseFlag.USE_NOANIM)
        end
    end

    if enchantedCard == Card.CARD_EMPRESS then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, true)
    end

    if enchantedCard == Card.CARD_STRENGTH then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM, true)
    end

    if enchantedCard == Card.CARD_HANGED_MAN then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE, true)
    end

    if enchantedCard == Card.CARD_DEVIL then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, true)
    end

    if room:IsClear() and room:IsFirstVisit() then
        if enchantedCard == Card.CARD_FOOL then
            JosephMod.BaseCardEffects:spawnPortal(3)
        end
    end

    if enchantedCard == Card.CARD_SUN then
        if not room:IsClear() then
            local entities = Isaac.GetRoomEntities()
            for i, entity in pairs(entities) do
                if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
                    entity:AddBurn(EntityRef(player), 60, player.Damage)
                end
            end
        end
    end
end

local gameContinued = false
function BaseCardEffects:ReapplyCardEffects()
    local room = Game():GetRoom()
    BaseCardEffects:RemoveShopTrapdoor()
    local anyPlayerHasMoreOptions = false
    local choicePedestalCount = 0

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)

        if player:HasCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS, false, true) then
            anyPlayerHasMoreOptions = true
        end

        local enchantedCards = utility:GetEnchantedCardsPerPlayer(player)
        for slot, enchantedCard in pairs(enchantedCards) do
            BaseCardEffects:EnchantmentEffects(player, enchantedCard, slot)
        end

        --Handle stars
        choicePedestalCount = choicePedestalCount + utility:GetEnchantmentCount(player, Card.CARD_STARS)
    end
    if anyPlayerHasMoreOptions then 
        choicePedestalCount = choicePedestalCount + 1
    end

    if utility:AnyPlayerHasEnchantment(Card.CARD_STARS) and room:IsFirstVisit() == true and room:GetType() == RoomType.ROOM_TREASURE then
        for i = 0, choicePedestalCount - 2 do
            local choiceA = Isaac.Spawn(EntityType.ENTITY_PICKUP, 100, 0, room:FindFreePickupSpawnPosition(room:GetGridPosition(65), 0, true, false), Vector(0, 0), nil)
            choiceA:ToPickup().OptionsPickupIndex = 1
        end
    end
end


--On new room, runs all card effects for all players
JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, BaseCardEffects.ReapplyCardEffects)


JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_LEVEL_REORDERED, function ()
    if gameContinued then 
        gameContinued = false
        return
    end
    JosephMod.Schedule(1, function ()
        JosephMod.BaseCardEffects:ReapplyCardEffects()
    end,{})
end)


JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_GAME_STARTED_REORDERED, function (isContinued)
    if not isContinued then return end
    gameContinued = true
    JosephMod.Schedule(1, function ()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            local enchantedCards = utility:GetEnchantedCardsPerPlayer(player)
            for key, enchantedCard in pairs(enchantedCards) do
                --BaseCardEffects:EnchantmentEffects(player, enchantedCard)
                BaseCardEffects:AddInnateCollectibles(player, enchantedCard)
                Isaac.RunCallbackWithParam(enums.Callbacks.JOSEPH_GAME_START_ENCHANT_REFRESH, enchantedCard, player, enchantedCard, false)
            end
        end
    end,{})
end)


function BaseCardEffects:RoomClearEffectPerPlayer(player, enchantedCard, rng, spawnPos)
    local room = Game():GetRoom()
    local roomType = room:GetType()

    if roomType == RoomType.ROOM_BOSS then return end

    if enchantedCard == Card.CARD_LOVERS then
        for i=0, utility:GetEnchantmentCount(player, Card.CARD_LOVERS)-1, 1 do
            if (rng:RandomFloat() <= RED_HEART_REPLACE_CHANCE or firstTimeLovers == true) then
                local pos = room:FindFreePickupSpawnPosition(spawnPos)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 1, pos, Vector(0, 0), nil)
                SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
                firstTimeLovers = false
            end
        end
    end

    if enchantedCard == Card.CARD_HIEROPHANT then
        for i=0, utility:GetEnchantmentCount(player, Card.CARD_HIEROPHANT)-1, 1 do
            if (rng:RandomFloat() <= SOUL_HEART_REPLACE_CHANCE or firstTimeHeirophant == true) then
                local pos = room:FindFreePickupSpawnPosition(spawnPos)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, Vector(0, 0), nil)
                SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
                firstTimeHeirophant = false
            end
        end
    end

    if enchantedCard == Card.CARD_JUSTICE then

        for i=0, utility:GetEnchantmentCount(player, Card.CARD_JUSTICE)-1, 1 do
            if (rng:RandomFloat() <= JUSTICE_DROP_REPLACE_CHANCE or firstTimeJustice == true) then
                for j=10, 40, 10 do
                    if rng:RandomFloat() <= 0.80 then
                        local pos = room:FindFreePickupSpawnPosition(spawnPos)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, j, 0, pos, Vector(0, 0), nil)
                    end
                end
                SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
                firstTimeJustice = false
            end
        end
    end

    local level = Game():GetLevel()
    local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
    roomDesc.AwardSeed = rng:GetSeed()

end

function BaseCardEffects:RoomClearEffect(rng, spawnPos)
    local room = Game():GetRoom()
    local roomType = room:GetType()
    local anyPlayerHasTheresOptions = false
    local choicePedestalCount = 0

    if utility:AnyPlayerHasEnchantment(Card.CARD_FOOL) then
        JosephMod.BaseCardEffects:spawnPortal(3)
    end

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_THERES_OPTIONS, false, true) then
            anyPlayerHasTheresOptions = true
        end

        local enchantedCards = utility:GetEnchantedCardsPerPlayer(player)
        for key, enchantedCard in pairs(enchantedCards) do
            BaseCardEffects:RoomClearEffectPerPlayer(player, enchantedCard, rng, spawnPos)
        end
        --Handle emperor
        choicePedestalCount = choicePedestalCount + utility:GetEnchantmentCount(player, Card.CARD_EMPEROR)
    end

    if anyPlayerHasTheresOptions then
        choicePedestalCount = choicePedestalCount + 1
    end
    
    if utility:AnyPlayerHasEnchantment(Card.CARD_EMPEROR) and roomType == RoomType.ROOM_BOSS and Game():GetLevel():GetStage() <= LevelStage.STAGE4_2 then
        Isaac.CreateTimer( function()
            for i = 0, choicePedestalCount - 2 do
                local choiceA = Isaac.Spawn(EntityType.ENTITY_PICKUP, 100, 0, room:FindFreePickupSpawnPosition(room:GetGridPosition(65), 0, true, false), Vector(0, 0), nil)
                choiceA:ToPickup().OptionsPickupIndex = 3
            end
        end, 1, 1, false)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, BaseCardEffects.RoomClearEffect)



function BaseCardEffects:ApplyNewFloorEffect()
    if not utility:AnyPlayerHasEnchantment(Card.CARD_WORLD) then return end
    Game():GetLevel():ShowMap()
end
JosephMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BaseCardEffects.ApplyNewFloorEffect)



local function isDoor(pos)
	local gridEntity = Game():GetRoom():GetGridEntityFromPos(pos)
	if gridEntity then
		return gridEntity:GetType() == GridEntityType.GRID_DOOR
	end
	return false
end

function BaseCardEffects:spawnPortal(portalType)
    local player = Isaac.GetPlayer()
    local room = Game():GetRoom()
    local marg = 40
    local canFly = player.CanFly
    local tempNPC, pathFinder
    local attempts = 0
    local centerPos = room:IsLShapedRoom() and Vector(853, 270) or room:GetCenterPos()
    local offset = 40
    local pos = Isaac.GetFreeNearPosition(Vector((centerPos.X + offset), centerPos.Y + offset), 10)

    repeat
        if not canFly then
            tempNPC = Isaac.Spawn(EntityType.ENTITY_GAPER, 0, 0, pos, Vector.Zero, nil):ToNPC()
            tempNPC.Visible = false
            if tempNPC then pathFinder = tempNPC.Pathfinder end
        end
        local overlaps

        local scale = 40
        local X = pos.X
        local Y = pos.Y
        local Up = Vector(X, Y - scale)
	    local Down = Vector(X, Y + scale)
	    local Left = Vector(X - scale, Y)
	    local Right = Vector(X + scale, Y)
        if ((pathFinder and not pathFinder:HasPathToPos(player.Position, true)) or isDoor(Up) or isDoor(Down) or isDoor(Left) or isDoor(Right)) then
            overlaps = true
            marg = marg + 10
            pos = Isaac.GetFreeNearPosition(pos, marg)
        end
        if tempNPC then tempNPC:Remove() end
        attempts = attempts + 1 
    until not overlaps or attempts > 20
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PORTAL_TELEPORT, portalType, pos, Vector.Zero, player):ToEffect()
end

function BaseCardEffects:RemoveShopTrapdoor()
    if Game():GetRoom():GetType() ~= RoomType.ROOM_SHOP then return end
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MEMBER_CARD) then return end
    if utility:AnyPlayerHasEnchantment(Card.CARD_HERMIT) then return end
    local shopCrawlSpaces = TSIL.GridSpecific.GetStairs(TSIL.Enums.StairsVariant.SECRET_SHOP)
    if (next(shopCrawlSpaces) ~= nil) then
        local shopDoor = shopCrawlSpaces[1]
        Isaac.Spawn(1000, 15, 0, shopDoor.Position, Vector(0, 0), nil)
        TSIL.GridEntities.RemoveGridEntity(shopDoor)
    end

end


return BaseCardEffects