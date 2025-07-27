local mod = TaintedTreasure
local rng = RNG()
local game = Game()
local json = require("json")

function mod:AddTaintedTreasure(untainted, tainted) --For use in other mods, call this when a run is first started!
	if mod.taintedpoolloaded then
		table.insert(mod.savedata.taintedsets, {untainted, tainted})
		table.insert(mod.savedata.TaintedBeggarPool, untainted)
		mod:SaveData(json.encode(mod.savedata))
	else
		table.insert(mod.startingtaintedsets, {untainted, tainted})
	end
end

function mod:MergeTaintedTreasures(tbl) --Same as above, but lets you use a table organized like mod.startingtaintedsets to import multiple at once
	if mod.taintedpoolloaded then
		for i, entry in pairs(tbl) do
			table.insert(mod.savedata.taintedsets, {entry[1], entry[2]})
			table.insert(mod.savedata.TaintedBeggarPool, entry[1])
		end
		mod:SaveData(json.encode(mod.savedata))
	else
		for i, entry in pairs(tbl) do
			table.insert(mod.startingtaintedsets, {entry[1], entry[2]})
		end
	end
end

function mod:AddContract(playertype, desc, eiddesc) --Allows you to add your own effects to Contract of Servitude! Call this in POST_GAME_STARTED even when the run is continued
	mod.ContractEffects[playertype] = {desc, eiddesc}
end