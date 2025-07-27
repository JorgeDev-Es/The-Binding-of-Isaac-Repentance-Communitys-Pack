local mod = TaintedTreasure
local game = Game()

mod.CustomCallbacks = {
	["GRID_UPDATE"] = {},
	["USE_KEY"] = {},
	["FIRE_TEAR"] = {},
	["FIRE_BOMB"] = {},
	["FIRE_ROCKET"] = {},
	["FIRE_CREEP"] = {},
	["GAIN_COLLECTIBLE"] = {},
	["SLOT_UPDATE"] = {},
	["SLOT_TOUCH"] = {},
	["FIRE_KNIFE"] = {},
	["FIRE_LASER"] = {},
}

mod.CallbackCollectibles = {}

function mod:AddCustomCallback(callback, funct, optionalArg)
	table.insert(mod.CustomCallbacks[callback], {funct, optionalArg})
	if callback == "GAIN_COLLECTIBLE" then
		mod.CallbackCollectibles[optionalArg] = true
	end
end

function mod:RunCustomCallback(callback, args)
	local callbacks = mod.CustomCallbacks[callback]
	if callback == "GRID_UPDATE" then
		for _, callback in pairs(callbacks) do
			if args[1]:GetType() == callback[2] or not callback[2] then
				--print(args[1]:GetGridIndex())
				callback[1](_, args[1])
			end
		end
	elseif callback == "SLOT_UPDATE" then
		for _, callback in pairs(callbacks) do
			if args[1].Variant == callback[2] or not callback[2] then
				callback[1](_, args[1])
			end
		end
	elseif callback == "SLOT_TOUCH" then
		for _, callback in pairs(callbacks) do
			if args[2].Variant == callback[2] or not callback[2] then
				callback[1](_, args[1], args[2])
			end
		end
	elseif callback == "GAIN_COLLECTIBLE" then
		for _, callback in pairs(callbacks) do
			if args[2] == callback[2] or not callback[2] then
				callback[1](_, args[1], args[2])
			end
		end
	elseif callback == "USE_KEY" then
		for _, callback in pairs(callbacks) do
			callback[1](_, args[1])
		end
	elseif callback == "FIRE_TEAR" then
		for _, callback in pairs(callbacks) do
			callback[1](_, args[1], args[2], args[3], args[4])
		end
	elseif callback == "FIRE_BOMB" or callback == "FIRE_ROCKET" or callback == "FIRE_CREEP" or callback == "FIRE_KNIFE" or callback == "FIRE_LASER" then
		for _, callback in pairs(callbacks) do
			callback[1](_, args[1], args[2])
		end
	end
end

function mod:DoesFamiliarShootPlayerTears(familiar)
	return (familiar.Variant == FamiliarVariant.INCUBUS
	or familiar.Variant == FamiliarVariant.SPRINKLER 
	or familiar.Variant == FamiliarVariant.TWISTED_BABY 
	or familiar.Variant == FamiliarVariant.BLOOD_BABY 
	or familiar.Variant == FamiliarVariant.UMBILICAL_BABY) 
end

function mod:TTCopyEntStatus(ent1, ent2)
	local dat1 = ent1:GetData()
	local dat2 = ent2:GetData()

	dat2.TaintedPlayerRef = dat1.TaintedPlayerRef
	dat2.TaintedPoopBlast = dat1.TaintedPoopBlast
	dat2.TaintedFireWave = dat1.TaintedFireWave
	dat2.TaintedRepulsion = dat1.TaintedRepulsion
	dat2.TaintedArrowhead = dat1.TaintedArrowhead
	dat2.TaintedColoredContact = dat1.TaintedColoredContact
	dat2.TaintedGermination = dat1.TaintedGermination
end