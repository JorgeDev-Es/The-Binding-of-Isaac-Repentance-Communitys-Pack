function TSIL.Dimensions.GetDimension()
    local level = Game():GetLevel()
    local roomIndex = level:GetCurrentRoomIndex()

    for i = 0, 2 do
        if GetPtrHash(level:GetRoomByIdx(roomIndex, i)) == GetPtrHash(level:GetRoomByIdx(roomIndex, -1)) then
            return i
        end
    end

    return TSIL.Enums.Dimension.CURRENT
end