RoarysNeptunusSynergies = RegisterMod("Neptunus Synergies", 1)	-- shortened to "rns" prefix in entity data
local mod = RoarysNeptunusSynergies
local json = require("json")
-- p.s. special gratitude to:
-- whole TBoI community for english wiki
-- Neonomi for dead-god.ru

mod.config = {
	changeSprites = true,	
	-- apply visual effects that can be viewed as excessive.
	-- These ARE affected:
		-- blue tears instead of blood ones;
		-- makes lasers and their effects tear-like (impacts, anti-gravity swirl, e.t.c);
		-- unique sword sprite (both normal and lightsaber);
	-- These are NOT affected:
		-- water explosions from Dr./Epic Fetus's bombs;
		-- chargebars (depend on game's options instead).
	overwriteUniqueSprites = false,
	-- wheteher to overwrite sprites from unique <x> mods
		-- currently interacts only with unique swords mods
	waterBombs = true,
	-- affects Dr. Fetus bombs and Epic Fetus rockets
		-- changes visuals into water explosions
		-- spawns creep
	--splashLasers = false,
	-- since REPENTOGON added POST_LASER_COLLISSION, maybe will try to return feature from old versions of mod,
	-- that lasers (Brim, Tech, Tech X) create tears on contact
	-- of course, new version will create tears depending on Neptunus charge: more charge - more tears
	-- obviously, REPENTOGON will be required; does nothing as of now
}

function mod:LoadConfig()
	if mod:HasData() then
		local modData = json.decode(mod:LoadData())
		for i,v in pairs(mod.config) do
			if modData ~= nil then
				mod.config[i] = modData[i]
			end
		end
	end
end

function mod.SaveConfig()
	if mod.UpdateImGUIData then
		mod.UpdateImGUIData()
	end
	
	mod:SaveData(json.encode(mod.config))
end



if REPENTOGON then
	require("neptunus_synergies_src.synergies_rgon")
	require("neptunus_synergies_src.imgui")
elseif REPENTANCE_PLUS then
	--require("neptunus_synergies_src.synergies_repplus")	--no need currently
	require("neptunus_synergies_src.synergies_rep")
elseif REPENTANCE then
	require("neptunus_synergies_src.synergies_rep")
end

require("neptunus_synergies_src.mcm")



if REPENTOGON then
	mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, function(_, saveslot, isslotselected, rawslot)
		if rawslot == saveslot then
			mod:LoadConfig()
			mod.UpdateImGUIData()
		end
	end)
else
	mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.LoadConfig)
end