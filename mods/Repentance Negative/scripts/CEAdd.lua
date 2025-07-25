Console.RegisterCommand(
	"unlockrepnegative",
	'Unlock all content in mode "Repentance Negative"',
	'Unlock all content in mode "Repentance Negative"',
	true,
	16
)
Console.RegisterCommand(
	"lockrepnegative",
	'Lock all content in mode "Repentance Negative"',
	'Lock all content in mode "Repentance Negative"',
	true,
	16
)

function RepMMod.oncmd(_, command, args)
	if command == "unlockrepnegative" then
		for name, ach in pairs(RepMMod.RepmAchivements) do
			Isaac.GetPersistentGameData():TryUnlock(ach.ID, false)
		end
	elseif command == "lockrepnegative" then
		for name, ach in pairs(RepMMod.RepmAchivements) do
			Isaac.ExecuteCommand("lockachievement " .. ach.ID)
		end
	end
end
RepMMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, RepMMod.oncmd)
