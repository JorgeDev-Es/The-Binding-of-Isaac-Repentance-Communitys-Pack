local Mod = RepMMod
local SaveManager = Mod.saveManager

SaveManager.Utility.AddDefaultRunData(SaveManager.DefaultSaveKeys.GLOBAL, {PortalD6 = {}})

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, function(_, col, player, varData, currentMaxCharge)
    local saveData = Mod:RunSave()
    local pD6Data = saveData["PortalD6"]

    if pD6Data[varData].Use == 1 then
        return 3
    elseif pD6Data[varData].Use == 2 then
        return 10
    end

end, Mod.RepmTypes.COLLECTIBLE_PORTAL_D6)

---@param collectible CollectibleType
---@param charge integer
---@param first boolean
---@param slot ActiveSlot | integer
---@param varData integer
---@param player EntityPlayer
Mod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, function(_, collectible, charge, first, slot, varData, player)
    local newVarData = varData
    local saveData = Mod:RunSave()
    local pD6Data = saveData["PortalD6"]
    if first then
        pD6Data[#pD6Data+1] = {
            Use = 0,
            Items = {}
        }
        newVarData = #pD6Data
    elseif pD6Data[newVarData] == nil then
        pD6Data[newVarData] = {
            Use = 0,
            Items = {}
        }
    end
    return {collectible, charge, first, slot, newVarData}
end, Mod.RepmTypes.COLLECTIBLE_PORTAL_D6)

local portalD6Sprite = Sprite("gfx/ui/PortalD62.anm2", true)
portalD6Sprite:Play("Idle", true)

---@param player EntityPlayer
---@param slot ActiveSlot | integer
---@param offset Vector
---@param alpha number
---@param scale number
---@param chargeBarOffset Vector
Mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, function(_, player, slot, offset, alpha, scale, chargeBarOffset)
    local varData = player:GetActiveItemDesc(slot).VarData
    local saveData = Mod:RunSave()
    local item = player:GetActiveItem(slot)
    local pD6Data = saveData["PortalD6"]
    if type(pD6Data[varData]) == "table" and item == Mod.RepmTypes.COLLECTIBLE_PORTAL_D6 then
        if pD6Data[varData].Use == 1 and player:IsCoopGhost() == false then

            local pkitem = player:GetPocketItem(0)
            local ispocketactive = (pkitem:GetSlot() == 3 and pkitem:GetType() == 2)

            local mode = 2

            local renderPos = Vector(16, 16)
            local renderScale = Vector(1, 1)

            
            if slot == ActiveSlot.SLOT_PRIMARY then
            elseif slot == ActiveSlot.SLOT_SECONDARY or (not ispocketactive) then
                renderPos = renderPos / 2
                renderScale = renderScale / 2
            end
            portalD6Sprite.Scale = renderScale
            portalD6Sprite:Render(renderPos + offset, Vector.Zero, Vector.Zero)
                
        end
    end
end)

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, function(_, pickup, pickupType, variant, subType, keepPrice, keepSeed, ignoreModifiers)
    if Mod:GetData(pickup).PortalD6NoMorph then
        return false
    end
    if Mod:GetData(pickup).PortalD6KeepPrice then
        return {pickupType, variant, subType, 0, keepSeed and 1 or 0, ignoreModifiers and 1 or 0}
    end
end)

---@param item CollectibleType | integer
---@param rng RNG
---@param player EntityPlayer
---@param Flags UseFlag | integer
---@param slot ActiveSlot | integer
---@param customVarData integer
---@return boolean | table
local function PortalUse(_, item, rng, player, Flags, slot, customVarData)
    if Flags & UseFlag.USE_CARBATTERY > 0 then
        return
    end
    local saveData = Mod:RunSave()
    local varData = player:GetActiveItemDesc(slot).VarData

    if type(saveData["PortalD6"][varData]) == "table" then
        if saveData["PortalD6"][varData].Use ~= 1 then
            saveData["PortalD6"][varData].Use = 1
            saveData["PortalD6"][varData].Items = {}
            local roomsList = Game():GetLevel():GetRooms()
            local roomEntities = Isaac.FindByType(5)
            for _, entity in ipairs(roomEntities) do
                print(entity.Variant .. "/" .. entity.SubType)
                if entity.Variant == 100 then
                    if entity.SubType == 0 then
                    else
                        table.insert(saveData["PortalD6"][varData].Items, {
                            Variant = entity.Variant,
                            SubType = entity.SubType,
                            Position = {X = entity.Position.X, Y = entity.Position.Y},
                            price = entity:ToPickup().Price,
                            roomType = roomsList:Get(math.random(0, roomsList.Size - 1)).Data.Type,
                            seed = entity.InitSeed
                        })
                        Isaac.Spawn(1000, 15, 0, entity.Position, Vector.Zero, entity)
                        entity:Remove()
                    end
                elseif
                    entity.Variant == 50
                    or entity.Variant == 52
                    or entity.Variant == 51
                    or entity.Variant == 53
                    or entity.Variant == 54
                    or entity.Variant == 55
                    or entity.Variant == 56
                    or entity.Variant == 57
                    or entity.Variant == 58
                    or entity.Variant == 60
                    or entity.Variant == 390
                    or entity.Variant == 360
                then
                    if entity.SubType == 0 then
                    else
                        table.insert(saveData["PortalD6"][varData].Items, {
                            Variant = entity.Variant,
                            SubType = entity.SubType,
                            Position = {X = entity.Position.X, Y = entity.Position.Y},
                            price = entity:ToPickup().Price,
                            roomType = roomsList:Get(math.random(0, roomsList.Size - 1)).Data.Type,
                            seed = entity.InitSeed
                        })
                        Isaac.Spawn(1000, 15, 0, entity.Position, Vector.Zero, entity)
                        entity:Remove()
                    end
                elseif
                    entity.Variant == 370
                    or entity.Variant == 380
                    or entity.Variant == 340
                    or entity.Variant == 150
                    or entity.Variant == 110
                    or entity.Variant == 41
                then
                else
                    table.insert(saveData["PortalD6"][varData].Items, {
                        Variant = entity.Variant,
                        SubType = entity.SubType,
                        Position = {X = entity.Position.X, Y = entity.Position.Y},
                        price = entity:ToPickup().Price,
                        seed = entity.InitSeed
                    })
                    Isaac.Spawn(1000, 15, 0, entity.Position, Vector.Zero, entity)
                    entity:Remove()
                end
            end
            --Isaac.GetItemConfig():GetCollectible(Mod.RepmTypes.COLLECTIBLE_PORTAL_D6).MaxCharges = 3
            return {ShowAnim = true}
        else
            saveData["PortalD6"][varData].Use = 0
            if #saveData["PortalD6"][varData].Items == 0 or type(saveData["PortalD6"][varData].Items) == "nil" then
                --Isaac.GetItemConfig():GetCollectible(Mod.RepmTypes.COLLECTIBLE_PORTAL_D6).MaxCharges = 6
                return {ShowAnim = true}
            end
            saveData["PortalD6"][varData].Use = 2
            for _, pickup in ipairs(Isaac.FindByType(5)) do
                Mod:GetData(pickup).PortalD6NoMorph = true
            end
            for _, table in ipairs(saveData["PortalD6"][varData].Items) do
                local item
                local pos = table.Position and Vector(table.Position.X, table.Position.Y) or game:GetRoom():GetCenterPos()
                local newpos = Game():GetRoom():FindFreePickupSpawnPosition(pos, 0, true, false)
                if table.Variant == 100 then
                    local newid
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHAOS) or table.roomType == RoomType.ROOM_ERROR then
                        newid = Game():GetItemPool():GetCollectible(math.random(1, 30), true, Random(), 25)
                    elseif table.roomType == 2 then
                        newid = Game():GetItemPool():GetCollectible(1, true, Random(), 25)
                    elseif table.roomType == 24 then
                        newid = Game():GetItemPool():GetCollectible(26, true, Random(), 25)
                    elseif table.roomType == 5 then
                        newid = Game():GetItemPool():GetCollectible(2, true, Random(), 25)
                    elseif table.roomType == 7 or table.roomType == 8 then
                        newid = Game():GetItemPool():GetCollectible(5, true, Random(), 25)
                    elseif table.roomType == 9 then
                        newid = Game():GetItemPool():GetCollectible(10, true, Random(), 25)
                    elseif table.roomType == 10 then
                        newid = Game():GetItemPool():GetCollectible(12, true, Random(), 25)
                    elseif table.roomType == 12 then
                        newid = Game():GetItemPool():GetCollectible(6, true, Random(), 25)
                    elseif table.roomType == 14 then
                        newid = Game():GetItemPool():GetCollectible(3, true, Random(), 25)
                    elseif table.roomType == 15 then
                        newid = Game():GetItemPool():GetCollectible(4, true, Random(), 25)
                    elseif table.roomType == 29 then
                        newid = Game():GetItemPool():GetCollectible(24, true, Random(), 25)
                    else
                        newid = Game():GetItemPool():GetCollectible(0, true, Random(), 25)
                    end
                    item = Isaac.Spawn(
                        5,
                        table.Variant,
                        newid,
                        newpos,
                        Vector.Zero,
                        nil
                    )
                else
                    item = Isaac.Spawn(
                        5,
                        table.Variant,
                        table.SubType,
                        newpos,
                        EntityPickup.GetRandomPickupVelocity(newpos, Mod.RNG, 0),
                        nil
                    )
                end
                Isaac.Spawn(
                    1000,
                    15,
                    0,
                    newpos,
                    Vector.Zero,
                    player
                )
                if table.price then
                    item:ToPickup().AutoUpdatePrice = false
                    item:ToPickup().Price = table.price
                end
                Mod:GetData(item).PortalD6KeepPrice = true
            end
            player:UseActiveItem(CollectibleType.COLLECTIBLE_D20, false, false, true, false, -1, 0)
            for _, pickup in ipairs(Isaac.FindByType(5)) do
                Mod:GetData(pickup).PortalD6NoMorph = nil
                Mod:GetData(pickup).PortalD6KeepPrice = nil
            end
            saveData["PortalD6"][varData].Items = {}
            --Isaac.GetItemConfig():GetCollectible(Mod.RepmTypes.COLLECTIBLE_PORTAL_D6).MaxCharges = 10
            return {
                Discharge = true,
                Remove = false,
                ShowAnim = true,
            }
        end
    end
end
RepMMod:AddCallback(ModCallbacks.MC_USE_ITEM, PortalUse, Mod.RepmTypes.COLLECTIBLE_PORTAL_D6)