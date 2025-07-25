--Time Machine PLUS Modded Machine Compatibility Template--
local function TMplusCompatibility()
	if not yourModsGlobalVariable.TMPSlotIndex then
		yourModsGlobalVariable.TMPSlotIndex = {
			[Your Machine's Variant] = {"Your Machine's Display Name", true}, --The bracketed item on the left is the Variant of your slot (the next integer after Type in an Entity's ID; eg a Beggar (6.4.0) is Variant 4).
			[Your Machine's Variant] = {"Your Machine's Display Name", true}, --The string is what name will be shown in the procedurally-generated ModConfigMenu button; it doesn't have to be the same as the slot's internal name.
			[Your Machine's Variant] = {"Your Machine's Display Name", true}, --The boolean is the default setting for the slot, before it's overridden by the player. True = enable, false = disable.
		}
	TMplus:AddCompatibility("Your Mod's Display Name", Your Mod's Compatibility Version, yourModsGlobalVariable.TMPSlotIndex) --The string is what name will be on the ModConfigMenu tab that houses the settings for your mod's individual slots. Be mindful of the length so it doesn't overlap with the names of other tabs.
end																															  --The middle value is the compatibility's version number (it can be a string or a true number, and can also be your mod's existing version variable as long as it's an operable number (max 1 decimal point)).
YourModsGlobalVariable:AddCallback("TM+_REQUEST_COMPATIBILITY_DATA", TMplusCompatibility)											  --If you ever add, remove, or change the name/variant of any of your mod's slots, then alter the table and increment the version number.
	--Your mod's data can now be read by Time Machine PLUS.																  	  		  --If it's larger than the version number currently stored by a user, then all of the old data will be deleted, and the new data loaded in its place.
																															  --The final value is the table defined at the top of this file.
--You can either put this code in your main.lua somewhere, or run this file with include().