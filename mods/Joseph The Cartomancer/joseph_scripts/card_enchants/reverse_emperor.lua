local ReverseEmperor = {}

local utility = JosephMod.utility
local enums = JosephMod.enums

local RECOMMENDED_SHIFT_IDX = 35
local EmperorPortal = enums.Effects.REVERSE_EMPEROR_PORTAL
local EmperorPortalSubType = 9

---@param player EntityPlayer
---@param card Card
---@param firstTime boolean
function ReverseEmperor:initReverseEmperor(player, card, firstTime)
    if firstTime ~= true then return end
    ReverseEmperor:checkSpawnPortal()
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseEmperor.initReverseEmperor, Card.CARD_REVERSE_EMPEROR)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseEmperor:removeReverseEmperor(player, card, slot)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseEmperor.removeReverseEmperor, Card.CARD_REVERSE_EMPEROR)


function ReverseEmperor:checkSpawnPortal(rng, spawnPos)
    local level = Game():GetLevel()
    local room = Game():GetRoom()
    local roomType = room:GetType()
    if roomType ~= RoomType.ROOM_BOSS or level:GetCurrentRoomIndex() == GridRooms.ROOM_EXTRA_BOSS_IDX then return end
    if not room:IsClear() then return end
    if not utility:AnyPlayerHasEnchantment(Card.CARD_REVERSE_EMPEROR) then return end

    JosephMod.BaseCardEffects:spawnPortal(EmperorPortalSubType)
end
JosephMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ReverseEmperor.checkSpawnPortal)
JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, ReverseEmperor.checkSpawnPortal)

function ReverseEmperor:portalInit(entity)
    if entity.SubType ~= EmperorPortalSubType then return end
    entity.Color = Color(1, 0, 0, 1, 0, 0)
    local sprite = entity:GetSprite()
    sprite:Play("Appear")

end
JosephMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ReverseEmperor.portalInit, EmperorPortal)


function ReverseEmperor:touchPortal(entity)
    if entity.SubType ~= EmperorPortalSubType then return end

    local sprite = entity:GetSprite()
    if sprite:IsFinished("Appear") and not sprite:IsPlaying("Idle") and not sprite:IsPlaying("Appear") then
        sprite:Play("Idle")
    end

    if sprite:IsPlaying("Appear") then return end --Stop collision while opening

    for _, v in ipairs(Isaac.FindInRadius(entity.Position + Vector(0, -10), 6, EntityPartition.PLAYER)) do
        local player = v:ToPlayer() ---@cast player EntityPlayer
        if not player then return end

        local data = utility:GetData(entity, "ReverseEmperor")
        if data.Used == true then return end
        data.Used = true
        
        local playerData = utility:GetData(player, "DisableDamage")
        playerData.DisableDamageActive = true

        -- local diff = (entity.Position + Vector(0, -10)) - player.Position
        -- player.Velocity = diff:Resized(math.min(diff:Length() * 0.1, 17.5))
        player.Velocity = Vector.Zero
        player.Position = Vector(entity.Position.X, entity.Position.Y-10)

        TSIL.Pause.Pause()

        player:AddControlsCooldown(30)

        player:AnimateTrapdoor()
        TSIL.Utils.Functions.RunInFramesTemporary(function ()
            ReverseEmperor:GoToExtraBossRoom(player)
            TSIL.Pause.Unpause()
        end, 15)
        --Isaac.RenderText("Hi", 50, 80, 1, 1, 1, 1)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ReverseEmperor.touchPortal, EmperorPortal)


function ReverseEmperor:GoToExtraBossRoom(player)

    for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
        local player = v:ToPlayer() ---@cast player EntityPlayer
        player:SetColor(Color(1, 1, 1, 0), 3, 99, false, false)
    end

    player:UseCard(Card.CARD_REVERSE_EMPEROR, UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM)

    for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
        local player = v:ToPlayer() ---@cast player EntityPlayer
        --player:SetColor(Color(1, 1, 1, 0), 3, 99, false, false)
        player.Visible = false
        player:StopExtraAnimation()
        local playerData = utility:GetData(player, "DisableDamage")
        playerData.DisableDamageActive = false
    end

    SFXManager():Stop(SoundEffect.SOUND_HELL_PORTAL1)
    SFXManager():Stop(SoundEffect.SOUND_HELL_PORTAL2)

    Game():StartRoomTransition(GridRooms.ROOM_EXTRA_BOSS_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.WALK)
end

---@param entity Entity
JosephMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity)
    if not utility:GetData(entity, "DisableDamage").DisableDamageActive == true then return end
    return false
end)

---@param player EntityPlayer
JosephMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function (_, player)
    if not utility:GetData(player, "DisableDamage").DisableDamageActive == true then return end
    return true
end)

-- ---@param player EntityPlayer
-- ---@param useFlags UseFlag
-- function Leviticus:onLeviticusUse(_, _, player, useFlags)
--     if TSIL.Utils.Flags.HasFlags(useFlags, UseFlag.USE_CARBATTERY) then return end

--     -- light:FollowParent(player)

--     local usedLeviticus = TSIL.SaveManager.GetPersistentVariable(
--         MilkshakeVol1,
--         "UsedLeviticus"
--     )

--     if usedLeviticus == true then 
--         return {
--             Discharge = false,
--             Remove = false,
--             ShowAnim = true,
--         } 
--     end

--     TSIL.SaveManager.SetPersistentVariable(
--         MilkshakeVol1,
--         "UsedLeviticus",
--         true
--     )

--     local data = MilkshakeVol1.utility:GetDataEx(player, "LeviticusBeam")

--     data.Used = true

--     local light

--     TSIL.Utils.Functions.RunInFramesTemporary(function ()
--         light = TSIL.EntitySpecific.SpawnEffect(MilkshakeVol1.enums.Effects.LEVITICUS_LIGHT, 0, player.Position)
--         if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
--             light.Color = Color(1, 0, 0)
--         end
--         light:FollowParent(player)
--     end, 3)

--     TSIL.Utils.Functions.RunInFramesTemporary(function ()
--         data.Used = false

--         if not light or not light:Exists() then return end

--         local players = Isaac.FindByType(EntityType.ENTITY_PLAYER)

--         ---@param a Entity
--         ---@param b Entity
--         table.sort(players, function (a, b)
--             return a.Position:Distance(light.Position) < b.Position:Distance(light.Position)
--         end)

--         ---@type EntityPlayer[]
--         local filtered = {}

--         for _, v in ipairs(players) do
--             ---@diagnostic disable-next-line: cast-local-type
--             v = v:ToPlayer() ---@cast v EntityPlayer

--             if not v:IsDead() then
--                 table.insert(filtered, v)
--             end
--         end

--         for i, v in ipairs(filtered) do
--             local data = MilkshakeVol1.utility:GetDataEx(v, "LeviticusBeam")

--             data.Queued = true

--             TSIL.Utils.Functions.RunInFramesTemporary(function ()
--                 data.LightTravelPos = light.Position
--                 data.DisableDamage = true

--                 v:AnimateLightTravel()
--                 v:AddCacheFlags(CacheFlag.CACHE_FLYING)
--                 v:EvaluateItems()
--             end, (i - 1) * 5 + 1)
--         end
--     end, 15)

--     if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
--         SFXManager():Play(SoundEffect.SOUND_UNHOLY)
--     else
--         SFXManager():Play(SoundEffect.SOUND_SUPERHOLY)
--     end

--     return true
-- end
-- for _, item in pairs(LEVITICUS_ITEM_PER_OPTIONS) do
--     MilkshakeVol1:AddCallback(
--         ModCallbacks.MC_USE_ITEM,
--         Leviticus.onLeviticusUse,
--         item
--     )
-- end

-- ---@param player EntityPlayer
-- local function Cancel(player)
--     local data = MilkshakeVol1.utility:GetDataEx(player, "LeviticusBeam")

--     data.State = nil
--     data.LightTravelPos = nil
--     data.Queued = nil

--     player:AddCacheFlags(CacheFlag.CACHE_FLYING)
--     player:EvaluateItems()

--     TSIL.Utils.Functions.RunInFrames(function ()
--         data.DisableDamage = false
--     end, 2)
-- end

-- ---@param player EntityPlayer
-- MilkshakeVol1:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
--     local data = MilkshakeVol1.utility:GetDataEx(player, "LeviticusBeam") if not data.LightTravelPos then return end

--     if player:IsDead() then
--         Cancel(player)
--         return
--     end

--     local sprite = player:GetSprite()
--     local animation = sprite:GetAnimation()
--     ---@type Vector
--     local diff = data.LightTravelPos - player.Position

--     player.Velocity = diff:Resized(math.min(diff:Length() * 0.1, 17.5))

--     if data.State == 2 then
--         local players = Isaac.FindByType(EntityType.ENTITY_PLAYER)

--         for i, v in ipairs(players) do
--             local vData = MilkshakeVol1.utility:GetDataEx(v, "LeviticusBeam") if vData.Queued then
--                 ---@diagnostic disable-next-line: cast-local-type
--                 v = v:ToPlayer() ---@cast v EntityPlayer

--                 if vData.State ~= 2 then
--                     break
--                 end

--                 if i == #players then
--                     for _, _v in ipairs(players) do
--                         ---@diagnostic disable-next-line: cast-local-type
--                         _v = _v:ToPlayer() ---@cast _v EntityPlayer
--                         Cancel(_v)
--                     end

--                     if not player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
--                         leviticusTransitioning = true
--                         Isaac.ExecuteCommand("goto s.angel." .. LEVITICUS_ANGEL_ROOMS[v:GetCollectibleRNG(MilkshakeVol1.enums.Collectibles.LEVITICUS):RandomInt(#LEVITICUS_ANGEL_ROOMS) + 1])
--                     else
--                         Isaac.ExecuteCommand("goto s.devil." .. LEVITICUS_DEVIL_ROOMS[v:GetCollectibleRNG(MilkshakeVol1.enums.Collectibles.LEVITICUS):RandomInt(#LEVITICUS_DEVIL_ROOMS) + 1])
--                     end
--                 end
--             end
--         end

--         player:SetColor(Color(1, 1, 1, 0), 2, 100, false, false)
--     elseif (animation == "LightTravel" and sprite:GetFrame() >= 34 and data.State ~= 2) or player:IsExtraAnimationFinished() then
--         data.State = 2
--     end
-- end)

-- ---@param entity Entity
-- ---@param hook InputHook
-- MilkshakeVol1:AddCallback(ModCallbacks.MC_INPUT_ACTION, function (_, entity, hook)
--     if not entity then return end
--     local data = MilkshakeVol1.utility:GetDataEx(entity, "LeviticusBeam") if not (data.Used or data.LightTravelPos) then return end

--     if hook ~= InputHook.GET_ACTION_VALUE then
--         return false
--     end

--     return 0
-- end)

-- ---@param entity Entity
-- MilkshakeVol1:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity)
--     if not MilkshakeVol1.utility:GetDataEx(entity, "LeviticusBeam").DisableDamage then return end
--     return false
-- end)

-- ---@param player EntityPlayer
-- MilkshakeVol1:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function (_, player)
--     if not MilkshakeVol1.utility:GetDataEx(player, "LeviticusBeam").DisableDamage then return end
--     return true
-- end)

-- ---@param player EntityPlayer
-- MilkshakeVol1:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
--     if not MilkshakeVol1.utility:GetDataEx(player, "LeviticusBeam").LightTravelPos then return end
--     player.CanFly = true
-- end, CacheFlag.CACHE_FLYING)

-- MilkshakeVol1:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
--     for _, v in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
--         local player = v:ToPlayer() ---@cast player EntityPlayer

--         local data = MilkshakeVol1.utility:GetDataEx(player, "LeviticusBeam")

--         data.Used = false

--         if data.LightTravelPos then
--             player:StopExtraAnimation()
--             Cancel(player)
--         end
--     end

--     if leviticusTransitioning then
--         local type = Game():GetRoom():GetType()
--         if type == RoomType.ROOM_ANGEL or type == RoomType.ROOM_DEVIL then
--             local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
--             local truePickups = {}
--             local itemIdx

--             for i, v in ipairs(pickups) do
--                 if v.Variant == PickupVariant.PICKUP_COLLECTIBLE and v:ToPickup().Price == 0 then
--                     itemIdx = i
--                 else
--                     table.insert(truePickups, v)
--                 end
--             end

--             local rng = TSIL.RNG.NewRNG(Game():GetRoom():GetDecorationSeed())

--             local holyCardIdx = rng:RandomInt(#truePickups) + 1

--             if itemIdx then
--                 table.insert(truePickups, pickups[itemIdx])
--             end

--             for i, v in ipairs(truePickups) do
--                 if i == #truePickups then
--                     break
--                 end

--                 ---@diagnostic disable-next-line: cast-local-type
--                 v = v:ToPickup() ---@cast v EntityPickup

--                 if v.Price > 0 then
--                     if v.Variant == PickupVariant.PICKUP_COLLECTIBLE then
--                         for i = 1, 100 do
--                             v:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_SHOPITEM, 0, false, true, true)

--                             if v.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
--                                 v.AutoUpdatePrice = true
--                                 v.Price = 5
--                                 break
--                             end
--                         end
--                     end
--                 elseif v.Variant == PickupVariant.PICKUP_TAROTCARD and MilkshakeVol1.utility:IsSpiritOrb(v.SubType) then
--                     v.AutoUpdatePrice = true
--                     v.Price = 5
--                 end

--                 if i == holyCardIdx then
--                     v:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HOLY, false, true)
--                     v.AutoUpdatePrice = true
--                     v.Price = 5
--                 end
--             end
--         end
--     end

--     leviticusTransitioning = nil
-- end)