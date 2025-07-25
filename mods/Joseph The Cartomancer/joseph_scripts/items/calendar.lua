local Calendar = {}

local enums = JosephMod.enums
local utility = JosephMod.utility

local CALENDAR = Isaac.GetItemIdByName("Calendar")


TSIL.SaveManager.AddPersistentVariable(
    JosephMod,
    "CalendarDayStacks", --1 is sunday, 2 is monday and so on
    {
        [1] = 0, --Damage
        [2] = 0, --Tears
        [3] = 0, --Damage
        [4] = 0, --Speed
        [5] = 0, --Health
        [6] = 0, --Health
        [7] = 0, --Tears
    },
    TSIL.Enums.VariablePersistenceMode.RESET_RUN,
    false
)

TSIL.SaveManager.AddPersistentVariable(
    JosephMod,
    "CalendarOrder",
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_RUN,
    false
)



function Calendar:UpdateCache(player, flag)
    if not (flag == CacheFlag.CACHE_DAMAGE or flag == CacheFlag.CACHE_FIREDELAY or flag == CacheFlag.CACHE_SPEED) then return end
    if not player:HasCollectible(CALENDAR) then return end

    local dayStacks = TSIL.SaveManager.GetPersistentVariable(JosephMod, "CalendarDayStacks")
    if flag == CacheFlag.CACHE_DAMAGE then
        if (dayStacks[1] >= 1 or dayStacks[3]) then
            player.Damage = player.Damage + (1 * (dayStacks[1] + dayStacks[3]))
        end
    elseif flag == CacheFlag.CACHE_FIREDELAY then
        if (dayStacks[2] >= 1 or dayStacks[7] >= 1) then
            utility:AddTears(player, 0.7 * (dayStacks[2] + dayStacks[7]))
        end
    elseif flag == CacheFlag.CACHE_SPEED then
        if (dayStacks[4] >= 1) then
            player.MoveSpeed = player.MoveSpeed + (0.3 * dayStacks[4])
        end
    end
end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Calendar.UpdateCache)


-- function Calendar:AddCalendar(_, _, firstTime, _, _, player)
--     if not firstTime then return end
--     if weekday == 5 or weekday == 6 then
--         player:AddMaxHearts(2)
--         player:AddHearts(4)
--     end

-- end
-- JosephMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Calendar.AddCalendar, CALENDAR)


function Calendar:AddCalendar(_, _, firstTime, _, _, player)
    if not firstTime then return end

    local weekday = os.date("*t").wday
    if weekday == 5 or weekday == 6 then
        player:AddMaxHearts(2)
        player:AddHearts(4)
    end

    local dayStacks = TSIL.SaveManager.GetPersistentVariable(JosephMod, "CalendarDayStacks")

    local order = TSIL.SaveManager.GetPersistentVariable(JosephMod, "CalendarOrder")
    table.insert(order, weekday)
    TSIL.SaveManager.SetPersistentVariable(JosephMod, "CalendarOrder", order)

    if weekday and dayStacks[weekday] then
        dayStacks[weekday] = dayStacks[weekday] + 1
    else
        dayStacks[7] = dayStacks[7] + 1 --Default to tears but this shouldn't happen ever but just in case
    end

    TSIL.SaveManager.SetPersistentVariable(JosephMod, "CalendarDayStacks", dayStacks)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    player:EvaluateItems()

end
JosephMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Calendar.AddCalendar, CALENDAR)



function Calendar:RemoveCalendar(player, item)

    local order = TSIL.SaveManager.GetPersistentVariable(JosephMod, "CalendarOrder")
    local removedDay = order[#order]
    table.remove(order, #order)
    TSIL.SaveManager.SetPersistentVariable(JosephMod, "CalendarOrder", order)

    local dayStacks = TSIL.SaveManager.GetPersistentVariable(JosephMod, "CalendarDayStacks")
    if removedDay and dayStacks[removedDay] then
        dayStacks[removedDay] = dayStacks[removedDay] - 1
    end

    TSIL.SaveManager.SetPersistentVariable(JosephMod, "CalendarDayStacks", dayStacks)

end
JosephMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, Calendar.RemoveCalendar, CALENDAR)


if EID then
    local function CalendarCondition(descObj)
        if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CALENDAR then
            return true
        end
    end
    local function CalendarDisplay(descObj)
        local lang = EID:getLanguage()
        local weekday = os.date("*t").wday
        local dayDesc = (JosephMod.Descriptions).CalendarDays[weekday][lang] or JosephMod.Descriptions.CalendarDays[weekday]["en_us"] or "wtf"
        EID:appendToDescription(descObj, "#" .. dayDesc)
        return descObj
    end

    EID:addDescriptionModifier("CalendarDay", CalendarCondition, CalendarDisplay)
end