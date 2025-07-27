local ScheduledFunctions = {}
local TemporaryScheduledFunctions = {}


local function UpdateScheludedFunctions(functions)
	TSIL.Utils.Tables.ForEach(functions, function (_, scheduledFunction)
		scheduledFunction.frames = scheduledFunction.frames - 1

		if scheduledFunction.frames <= 0 then
			scheduledFunction.funct(table.unpack(scheduledFunction.params))
		end
	end)

	return TSIL.Utils.Tables.Filter(functions, function (_, scheduledFunction)
		return scheduledFunction.frames > 0
	end)
end


local function OnFrameUpdate()
	ScheduledFunctions = UpdateScheludedFunctions(ScheduledFunctions)
	TemporaryScheduledFunctions = UpdateScheludedFunctions(TemporaryScheduledFunctions)
end
TSIL.__AddInternalCallback(
	"SCHEDULER_POST_UPDATE",
	ModCallbacks.MC_POST_UPDATE,
	OnFrameUpdate
)


local function OnNewRoom()
	TemporaryScheduledFunctions = {}
end
TSIL.__AddInternalCallback(
	"SCHEDULER_POST_NEW_ROOM",
	ModCallbacks.MC_POST_NEW_ROOM,
	OnNewRoom
)


local function OnGameExit()
	ScheduledFunctions = {}
	TemporaryScheduledFunctions = {}
end
TSIL.__AddInternalCallback(
	"SCHEDULER_PRE_GAME_EXIT",
	ModCallbacks.MC_PRE_GAME_EXIT,
	OnGameExit
)


function TSIL.Utils.Functions.RunInFrames(funct, frames, ...)
	local args = {...}
	table.insert(ScheduledFunctions, {funct = funct, frames = frames, params = args})
end

