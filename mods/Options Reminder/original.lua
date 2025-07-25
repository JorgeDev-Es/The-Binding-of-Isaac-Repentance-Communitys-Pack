OptionsReminderMod = RegisterMod("Options? Reminder", 1)

local OPTION_GROUPS = {}

function IsHorizontallyAligned(pickups)
    local x1, y1 = pickups[1].Position.X, pickups[1].Position.Y - 8
    local x2, y2 = pickups[2].Position.X, pickups[2].Position.Y - 8
    return math.abs(x1 - x2) > math.abs(y1 - y2)
end


function GetReminderPosition(pickups)
    local x, y = 0, 0
    local x1, y1 = pickups[1].Position.X, pickups[1].Position.Y - 8
    local x2, y2 = pickups[2].Position.X, pickups[2].Position.Y - 8
    local isHorizontallyAligned = IsHorizontallyAligned(pickups)

    if isHorizontallyAligned then
        x = (x1 + x2) / 2
        y = math.min(y1, y2) -30
    else
        x = math.max(x1, x2) + 30
        y = (y1 + y2) / 2
    end

    return Vector(x, y)
end

function GetConnectorTransform(pickups, connectorIndex)
    local x, y = 0, 0
    local sx, sy = 1, 1
    local x1, y1 = 0, 0
    local x2, y2 = 0, 0
    local isHorizontallyAligned = IsHorizontallyAligned(pickups)
    local reminderPosition = GetReminderPosition(pickups)

    if isHorizontallyAligned then
        if pickups[1].Position.X > pickups[2].Position.X then
            x1, x2 = pickups[1].Position.X, pickups[2].Position.X
            y1, y2 = pickups[1].Position.Y - 8, pickups[2].Position.Y - 8
        else
            x1, x2 = pickups[2].Position.X, pickups[1].Position.X
            y1, y2 = pickups[2].Position.Y - 8, pickups[1].Position.Y - 8
        end
    else
        if pickups[1].Position.Y > pickups[2].Position.Y then
            x1, x2 = pickups[1].Position.X, pickups[2].Position.X
            y1, y2 = pickups[1].Position.Y - 8, pickups[2].Position.Y - 8
        else
            x1, x2 = pickups[2].Position.X, pickups[1].Position.X
            y1, y2 = pickups[2].Position.Y - 8, pickups[1].Position.Y - 8
        end
    end

    if isHorizontallyAligned then
        if connectorIndex == 1 then
            sx = math.abs(reminderPosition.X - x1) * 0.3333
            sy = 1
            x = (reminderPosition.X + x1) / 2
            y = reminderPosition.Y 
        end
        if connectorIndex == 2 then
            sx = 1
            sy = math.abs(reminderPosition.Y - y1) * 0.3333
            x = x1
            y = (reminderPosition.Y + y1) / 2
        end
        if connectorIndex == 3 then
            sx = math.abs(reminderPosition.X - x2) * 0.3333
            sy = 1
            x = (reminderPosition.X + x2) / 2
            y = reminderPosition.Y
        end
        if connectorIndex == 4 then
            sx = 1
            sy = math.abs(reminderPosition.Y - y2) * 0.3333
            x = x2
            y = (reminderPosition.Y + y2) / 2
        end
    else
        if connectorIndex == 1 then
            sx = 1
            sy = math.abs(reminderPosition.Y - y1) * 0.3333
            x = reminderPosition.X
            y = (reminderPosition.Y + y1) / 2
        end
        if connectorIndex == 2 then
            sx = math.abs(reminderPosition.X - x1) * 0.3333
            sy = 1
            x = (reminderPosition.X + x1) / 2
            y = y1
        end
        if connectorIndex == 3 then
            sx = 1
            sy = math.abs(reminderPosition.Y - y2) * 0.3333
            x = reminderPosition.X
            y = (reminderPosition.Y + y2) / 2
        end
        if connectorIndex == 4 then
            sx = math.abs(reminderPosition.X - x2) * 0.3333
            sy = 1
            x = (reminderPosition.X + x2) / 2
            y = y2
        end
    end

    return Vector(x, y), Vector(sx, sy)
end


--- @param pickup EntityPickup
function OptionsReminderMod:PickupUpdate(pickup)
    if pickup.OptionsPickupIndex <= 0 then return end
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then return end
    local index = pickup.OptionsPickupIndex - 1

    -- Add pickup to GROUPED_PICKUPS
    OPTION_GROUPS[index] = OPTION_GROUPS[index] or { pickups = {} }

    for _, existingPickup in ipairs(OPTION_GROUPS[index].pickups) do
        if existingPickup.InitSeed == pickup.InitSeed then
            -- Check if the pickup's group only has one pickup for multiple frames (Prevents edge case with troll bombs)
            local numGroupPickups = #OPTION_GROUPS[index].pickups
            if numGroupPickups == 1 then
                local framesWithSinglePickup = OPTION_GROUPS[index].framesWithSinglePickup or 0
                if framesWithSinglePickup > 4 then
                    OPTION_GROUPS[index].pickups = {}
                    OPTION_GROUPS[index].framesWithSinglePickup = 0
                else
                    OPTION_GROUPS[index].framesWithSinglePickup = framesWithSinglePickup + 1
                end
            end
            return
        end
    end

    table.insert(OPTION_GROUPS[index].pickups, pickup)

    -- Spawn question mark reminder sprite above pickups
    if not OPTION_GROUPS[index] or OPTION_GROUPS[index].reminder then
        return
    end

    if #OPTION_GROUPS[index].pickups >= 2 then
        OPTION_GROUPS[index].framesWithSinglePickup = 0
        local reminder = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Vector(0,0), Vector(0, 0), nil)
        reminder:GetSprite():Load("gfx/optionsreminder.anm2", true)
        reminder:GetSprite():Play("Spawn", true)
        local reminderData = reminder:GetData()
        reminderData.OptionsReminder = true
        reminderData.Pickups = OPTION_GROUPS[index].pickups
        OPTION_GROUPS[index].reminder = reminder

        for i = 1, 4, 1 do
            local connector = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, Vector(0,0), Vector(0, 0), nil)
            connector:GetSprite():Load("gfx/optionsreminder_connector.anm2", true)
            connector:GetSprite():Play("Spawn", true)
            local connectorData = connector:GetData()
            connectorData.OptionsReminderConnector = true
            connectorData.Pickups = OPTION_GROUPS[index].pickups
            connectorData.ConnectorIndex = i
            OPTION_GROUPS[index].connectors = OPTION_GROUPS[index].connectors or {}
            OPTION_GROUPS[index].connectors[i] = connector
        end
    end
end
OptionsReminderMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, OptionsReminderMod.PickupUpdate)

--- @param entity Entity
function OptionsReminderMod:RemovePickup(entity)
    local pickup = entity:ToPickup()
    if not pickup or pickup.OptionsPickupIndex <= 0 then return end
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then return end

    -- Remove pickup from GROUPED_PICKUPS
    local index = pickup.OptionsPickupIndex - 1
    if OPTION_GROUPS[index] then
        -- Remove all pickups from the group
        OPTION_GROUPS[index].pickups = {}

        -- Despawn the reminder
        if OPTION_GROUPS[index].reminder then
            local reminder = OPTION_GROUPS[index].reminder
            reminder:GetSprite():Play("Death", true)
            OPTION_GROUPS[index].reminder = nil
        end

        -- Despawn the connectors
        if OPTION_GROUPS[index].connectors then
            for _, connector in ipairs(OPTION_GROUPS[index].connectors) do
                connector:GetSprite():Play("Death", true)
            end
            OPTION_GROUPS[index].connectors = nil
        end
    end
end
OptionsReminderMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, OptionsReminderMod.RemovePickup)

--- @param effect EntityEffect
function OptionsReminderMod:UpdateReminder(effect)
    local Data = effect:GetData()
    if Data.OptionsReminder  then
        if #Data.Pickups >= 2 then
            effect.Position = GetReminderPosition(Data.Pickups)
        end
        if effect:GetSprite():IsEventTriggered("SpawnFinish") then
            effect:GetSprite():Play("Idle", true)
        end
    elseif Data.OptionsReminderConnector then
        if #Data.Pickups >= 2 then
            local postion, scale = GetConnectorTransform(Data.Pickups, Data.ConnectorIndex)
            effect.Position = postion
            effect:GetSprite().Scale = scale
        end
        if effect:GetSprite():IsEventTriggered("SpawnFinish") then
            effect:GetSprite():Play("Idle", true)
        end
    end
end
OptionsReminderMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OptionsReminderMod.UpdateReminder)