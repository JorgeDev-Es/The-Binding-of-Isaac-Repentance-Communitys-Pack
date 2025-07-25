--Api for this mod

--FUNCTIONS

---@param priority BombPriority
---@param data Table
function CustomBombHUDIcons:AddPriorityBombIcon(priority, data)
	local bombData = CustomBombHUDIcons.RenderBombsData

    data.Priority = priority

    --Check if it already exists and if so, overwrite it

    for i, dataAlready in ipairs(CustomBombHUDIcons.RenderBombsData) do
        if dataAlready.Name == data.Name then
            bombData[i] = data
            break
        end
    end

    --Add normal

    bombData[#bombData + 1] = data

    --Sort
    table.sort(bombData, function(a, b)
        return a.Priority < b.Priority
    end)
end

---@param data Table
function CustomBombHUDIcons:AddBombIcon(data)
	CustomBombHUDIcons:AddPriorityBombIcon(CustomBombHUDIcons.BombPriority.DEFAULT, data)
end

---@param data Table
function CustomBombHUDIcons:AddPreventRenderFunction(data)
	local prevRenderFunctions = CustomBombHUDIcons.PreventRenderFunctions

    --Check if it already exists and if so, overwrite it

    for i, dataAlready in ipairs(CustomBombHUDIcons.PreventRenderFunctions) do
        if dataAlready.Name == data.Name then
            prevRenderFunctions[i] = data
            return
        end
    end

    --Add normal

	prevRenderFunctions[#prevRenderFunctions + 1] = data
end

--ENUMS

---Priority enum for the order of render (if one renders, it stops the rest from rendering, so this is important!)
---@enum BombPriority
CustomBombHUDIcons.BombPriority = {
    ---Important bomb reminders.
    ---Use this if the bomb modifier can be harmful or the player should keep in mind this modifier a lot.
    IMPORTANT = -20,

    ---Bombs with extra utility other than doing something cool while exploding.
    ---Base game example: Blood bombs.
    EARLY = -10,

    ---Default value, no special priority over other bombs.
    DEFAULT = 0,

    ---Bombs with this priotity get checked after all the base game bombs.
    LATE = 10,
}

---Priority enum to for order of render (if one renders, it stops the rest from rendering)
CustomBombHUDIcons.spriteType = {
    ---No player owns a golden bomb.
    DEFAULT = 0,

    ---A player owns a golden bomb.
    GOLD = 1,

    ---[FIEND FOLIO] A player owns Copper Bombs.
    COPPER = 2,
}