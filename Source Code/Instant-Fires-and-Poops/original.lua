-- Register the mod in the API
local mod = RegisterMod("Instant Fires and Poops", 1)
Poops = {}


local function init()
    Poops = {}
end


local function poops()
    local room = Game():GetRoom()

    -- Find poops in room
    for i = 0, room.GetGridSize(room) do
        local gridEntity = room.GetGridEntity(room, i)

        -- Get poops that are not destroyed
        if gridEntity ~= nil and gridEntity:ToPoop() ~= nil and gridEntity:ToPoop().State < 1000 then
            local state = gridEntity:ToPoop().State

            -- Initialise state
            if (Poops[i+1] == nil) then Poops[i+1] = state end

            if Game():GetRoom():IsClear() then
                -- Destroy if room clear and state changed
                if (state > Poops[i+1]) then
                    gridEntity.Destroy(gridEntity)
                end
            else
                -- Update state
                Poops[i+1] = state
            end
        end
    end
end


-- Thanks hgrfff
local function fires(_, entity)
    if entity.Variant == 0 then
        if Game():GetRoom():IsClear() then
            entity:Die()
            return true
        end
    end
end


mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, init)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, poops)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, fires, EntityType.ENTITY_FIREPLACE)