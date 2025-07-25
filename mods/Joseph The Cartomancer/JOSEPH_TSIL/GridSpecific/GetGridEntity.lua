local function GetAllGridEntitiesOfTypeAndVariant(type, variant, conversion)
    local gridEntities = TSIL.GridEntities.GetGridEntities(type)
    local convertedGridEntities = {}

    for _, gridEntity in ipairs(gridEntities) do
        if (not variant or variant == -1) or variant == gridEntity:GetVariant() then
            convertedGridEntities[#convertedGridEntities+1] = conversion(gridEntity)
        end
    end

    return convertedGridEntities
end

















function TSIL.GridSpecific.GetStairs(stairsVariant)
    return GetAllGridEntitiesOfTypeAndVariant(
        GridEntityType.GRID_STAIRS,
        stairsVariant,
        function (gridEntity)
            return gridEntity:ToStairs()
        end
    )
end







