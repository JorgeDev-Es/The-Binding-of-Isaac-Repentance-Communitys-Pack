local mod = FiendFolio

-- Loading
local EnemyCommonPath	= "ffscripts.xalum.enemies."
local BossCommonPath	= "ffscripts.xalum.bosses."

include("ffscripts.xalum.declaration")

local toLoad = {
	Misc = { CommonPath = "", Files = {
		-- Utilities
		"ffscripts.xalum.utilities.events",
		"ffscripts.xalum.utilities.miniboss_manager",
		"ffscripts.xalum.utilities.red_room_doorslot_validator",
		"ffscripts.xalum.utilities.pill_conversion_manager",
		"ffscripts.xalum.utilities.shooting_detection",

		-- Challenges
		"ffscripts.xalum.challenges.china_challenge",
		
		-- Players
		"ffscripts.players.china",
	}},
	
	Items = { CommonPath = "ffscripts.xalum.items.", Files = {
		-- Collectibles
		"fiends_horn",
		"golden_plum_flute",
		"king_worm",
		"risks_reward",
		"horse_paste",
		"brick_figure",

		-- Trinkets
		"massive_amethyst",
		"petrified_gel",
		"shard_of_china",
		"hatred",
		"frog_puppet",
		"heartache",
		"cursed_urn",
		"conjoined_card",

		-- Rocks
		"rock_worm",
	}},

	PocketItems = { CommonPath = "ffscripts.xalum.pocketitems.", Files = {
		-- Changes to Vanilla
		"vanilla.berkano",

		-- Pills
		"holy_shit",
		"haemorrhoids",
		"fish_oil",
		"epidermolysis",
		"clairvoyance",
		"spider_unboxing",

		-- Cards
		"king_of_wands",
		"horse_pushpop",
		"three_of_wands",
		"king_of_spades",
		"king_of_swords",
		"two_of_cups",
		"lego_stud",
		"misprinted_two_of_clubs",
		"christmas_cracker",
	}},
}

for dataKey, data in pairs(toLoad) do
	for _, file in pairs(data.Files) do
		include(data.CommonPath .. file)
	end
end

local toLoadEnemies = {
	Bosses = { CommonPath = "ffscripts.xalum.bosses.", Files = {
		["Tsar"] =					"tsar",
		["Tsarball 1"] = 			"extras.tsar_ball",
		["Big Pipe"] =				"extras.tsar_pipe",
		["Big Grate"] =				"extras.tsar_grate",

		["Slinger"] =				"slinger",
		["Toothache Tooth"] =		"extras.slinger_tooth",
		["Slinger Head"] =			"extras.slinger_head",

		["Mr. Dead"] =				"mr_dead",
		["Mr. Dead's Eye"] =		"extras.mr_deads_eye",

		["Madomme"] =				"madomme",
		["Madomme's Skull"] =		"extras.madomme_skull",
		["Ballgag Projectile"] =	"extras.madomme_ballgag",
		["Madomme Dash Ball"] =		"extras.madomme_dash_ball",
		["Madomme Brimstone Ball"] ="extras.madomme_brimstone_ball",
		["G-Imp"] =					"extras.madomme_gimp",
		["Castle"] =				"extras.madomme_castle",
		["Gloria"] =				"extras.madomme_gloria",
		["Horse (Madomme)"] =		"extras.madomme_horse",
		["Champ"] =					"extras.madomme_champ",
	}},
}

local enemyAIs = {
	-- Enemies
	Lurker				= include(EnemyCommonPath .. "lurker"), -- Lurkers are a living nightmare

	Possessed			= include(EnemyCommonPath .. "possessed"),
	PossessedCorpse		= include(EnemyCommonPath .. "possessed_corpse"),
	Moaner				= include(EnemyCommonPath .. "moaner"),
	Unpawtunate			= include(EnemyCommonPath .. "unpawtunate"),
	UnpawtunateSkull	= include(EnemyCommonPath .. "extras.unpawtunate_skull"),
	BoneRocket			= include(EnemyCommonPath .. "extras.bone_rocket"),
	MamaPooter			= include(EnemyCommonPath .. "mama_pooter"),
	CreepyMaggot		= include(EnemyCommonPath .. "creepy_maggot"),
	Gravedigger			= include(EnemyCommonPath .. "gravedigger"),
	Gravefire			= include(EnemyCommonPath .. "gravefire"),
	Sackboy				= include(EnemyCommonPath .. "sackboy"),
	Gnawful				= include(EnemyCommonPath .. "gnawful"),
	Ragurge				= include(EnemyCommonPath .. "ragurge"),
	Wick				= include(EnemyCommonPath .. "wick"),
	Banshee				= include(EnemyCommonPath .. "banshee"),
	Furnace				= include(EnemyCommonPath .. "furnace"),
	--InfectedMushroom	= include(EnemyCommonPath .. "infected_mushroom"),
	SporeProjectile		= include(EnemyCommonPath .. "extras.spore_projectile"),
	Cracker				= include(EnemyCommonPath .. "cracker"),
	Nuchal				= include(EnemyCommonPath .. "nuchal"),
	NuchalDetached		= include(EnemyCommonPath .. "nuchal_detached"),
	NuchalCord			= include(EnemyCommonPath .. "nuchal_cord"),
	Ossularry			= include(EnemyCommonPath .. "ossularry"),
	RotspinCore			= include(EnemyCommonPath .. "rotspin_core"),
	RotspinMoon			= include(EnemyCommonPath .. "rotspin_moon"),
	Spoilie				= include(EnemyCommonPath .. "spoilie"),
	SpoilieSpider		= include(EnemyCommonPath .. "spoilie_spider"),
	ClicketyClash		= include(EnemyCommonPath .. "clickety_clash"),
	ConglobberateSmall	= include(EnemyCommonPath .. "conglobberate_small"),
	ConglobberateMedium	= include(EnemyCommonPath .. "conglobberate_medium"),
	ConglobberateLarge	= include(EnemyCommonPath .. "conglobberate_large"),
	TomaChunk			= include(EnemyCommonPath .. "toma_chunk"),
	Strobila			= include(EnemyCommonPath .. "strobila"),
	Globwad				= include(EnemyCommonPath .. "globwad"),
	LonelyKnight		= include(EnemyCommonPath .. "lonely_knight"),
	LonelyKnightHurtbox = include(EnemyCommonPath .. "lonely_knight_hurtbox"),
	LonelyKnightShell	= include(EnemyCommonPath .. "lonely_knight_shell"),
	Ripcord				= include(EnemyCommonPath .. "ripcord"),
	BeadFly				= include(EnemyCommonPath .. "beadfly"),
	BeadFlyOutline		= include(EnemyCommonPath .. "beadfly_outline"),
	RingGib				= include(EnemyCommonPath .. "extras.ring_gib"),
	Spoop				= include(EnemyCommonPath .. "spoop"),
	Croca				= include(EnemyCommonPath .. "croca"),
	Haemo				= include(EnemyCommonPath .. "haemo"),
	HaemoGlobin			= include(EnemyCommonPath .. "extras.haemoglobin"),
	Chops				= include(EnemyCommonPath .. "chops"),
	Knot				= include(EnemyCommonPath .. "knot"),
	SuperShottie		= include(EnemyCommonPath .. "super_shottie"),
	SuperShottieHook	= include(EnemyCommonPath .. "extras.super_shottie_hook"),

	RockBalls			= include(EnemyCommonPath .. "rockballs"),
}

mod.XalumFiles = enemyAIs

-- Transferring to be run in main.lua
function mod:bonerocketAI(npc)		enemyAIs.BoneRocket.AI(npc) end
function mod:sporeProjectileAI(npc)	enemyAIs.SporeProjectile.AI(npc) end
function mod.spoiliespiderAI(npc)	enemyAIs.SpoilieSpider.AI(npc) end

-- Registration
local PreUpdate	= {}
local Init		= {}
local AI		= {}
local Damage	= {}
local Collision = {}
local Death		= {}
local Render	= {}

local function RegisterEnemy(...)
	local data = {...}
	local typ, var, file = ...

	if #data == 2 and type(data[1]) == "string" then
		typ = Isaac.GetEntityTypeByName(data[1])
		var = Isaac.GetEntityVariantByName(data[1])
		file = data[2]
	end

	if file then
		if file.PreUpdate then
			PreUpdate[typ] = PreUpdate[typ] or {}
			PreUpdate[typ][var] = file.PreUpdate
		end

		if file.Init then
			Init[typ] = Init[typ] or {}
			Init[typ][var] = file.Init
		end

		if file.AI then
			AI[typ] = AI[typ] or {}
			AI[typ][var] = file.AI
		end

		if file.Damage then
			Damage[typ] = Damage[typ] or {}
			Damage[typ][var] = file.Damage
		end

		if file.Collision then
			Collision[typ] = Collision[typ] or {}
			Collision[typ][var] = file.Collision
		end

		if file.Death then
			Death[typ] = Death[typ] or {}
			Death[typ][var] = file.Death
		end

		if file.Render then
			Render[typ] = Render[typ] or {}
			Render[typ][var] = file.Render
		end
	end
end

for dataKey, data in pairs(toLoadEnemies) do
	for entityName, filePath in pairs(data.Files) do
		local ai = include(data.CommonPath .. filePath)
		RegisterEnemy(entityName, ai)
	end
end

RegisterEnemy("Possessed",			enemyAIs.Possessed)
RegisterEnemy("Possessed Corpse",	enemyAIs.PossessedCorpse)
RegisterEnemy("Moaner",				enemyAIs.Moaner)
RegisterEnemy("Unpawtunate",		enemyAIs.Unpawtunate)
RegisterEnemy("Unpawtunate Skull",	enemyAIs.UnpawtunateSkull)
RegisterEnemy("Mama Pooter",		enemyAIs.MamaPooter)
RegisterEnemy("Creepy Maggot",		enemyAIs.CreepyMaggot)
RegisterEnemy("Gravedigger",		enemyAIs.Gravedigger)
RegisterEnemy("Gravefire",			enemyAIs.Gravefire)
RegisterEnemy("Sackboy",			enemyAIs.Sackboy)
RegisterEnemy("Gnawful",			enemyAIs.Gnawful)
RegisterEnemy("Ragurge",			enemyAIs.Ragurge)
RegisterEnemy("Wick",				enemyAIs.Wick)
RegisterEnemy("Banshee",			enemyAIs.Banshee)
RegisterEnemy("Furnace",			enemyAIs.Furnace)
--RegisterEnemy("Infected Mushroom",	enemyAIs.InfectedMushroom)
RegisterEnemy("Cracker",			enemyAIs.Cracker)
RegisterEnemy("Nuchal",				enemyAIs.Nuchal)
RegisterEnemy("Nuchal (Detached)",	enemyAIs.NuchalDetached)
RegisterEnemy("Nuchal (Cord)",		enemyAIs.NuchalCord)
RegisterEnemy("Ossularry",			enemyAIs.Ossularry)
RegisterEnemy("Rotspin",			enemyAIs.RotspinCore)
RegisterEnemy("Rotspin Moon",		enemyAIs.RotspinMoon)
RegisterEnemy("Spoilie",			enemyAIs.Spoilie)
RegisterEnemy("Clickety Clash",		enemyAIs.ClicketyClash)
RegisterEnemy("Conglobberate (Small)",	enemyAIs.ConglobberateSmall)
RegisterEnemy("Conglobberate (Medium)",	enemyAIs.ConglobberateMedium)
RegisterEnemy("Conglobberate (Large)",	enemyAIs.ConglobberateLarge)
RegisterEnemy("Toma Chunk",				enemyAIs.TomaChunk)
RegisterEnemy("Strobila",				enemyAIs.Strobila)
RegisterEnemy("Globwad",				enemyAIs.Globwad)
RegisterEnemy("Lonely Knight",			enemyAIs.LonelyKnight)
RegisterEnemy("Lonely Knight Brain",	enemyAIs.LonelyKnightHurtbox)
RegisterEnemy("Lonely Knight Shell",	enemyAIs.LonelyKnightShell)
RegisterEnemy("Ripcord",			enemyAIs.Ripcord)
RegisterEnemy("Bead Fly",			enemyAIs.BeadFly)
RegisterEnemy("Spoop",				enemyAIs.Spoop)
RegisterEnemy("Croca",				enemyAIs.Croca)
RegisterEnemy("Haemo",				enemyAIs.Haemo)
RegisterEnemy("Haemo Globin",		enemyAIs.HaemoGlobin)
RegisterEnemy("Chops",				enemyAIs.Chops)
RegisterEnemy("Knot",				enemyAIs.Knot)
RegisterEnemy("Super Shottie",		enemyAIs.SuperShottie)
RegisterEnemy("Super Shottie Hook",	enemyAIs.SuperShottieHook)

RegisterEnemy("Rock Ball (Mines)",	enemyAIs.RockBalls)

-- Callbacks
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
	if PreUpdate[npc.Type] and PreUpdate[npc.Type][npc.Variant] then
		return PreUpdate[npc.Type][npc.Variant](npc)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
	if Init[npc.Type] and Init[npc.Type][npc.Variant] then
		Init[npc.Type][npc.Variant](npc)
	end
end)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if AI[npc.Type] and AI[npc.Type][npc.Variant] then
		AI[npc.Type][npc.Variant](npc)
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, cooldown)
	if Damage[entity.Type] and Damage[entity.Type][entity.Variant] then
		return Damage[entity.Type][entity.Variant](entity:ToNPC(), amount, flags, source, cooldown)
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider, first)
	if Collision[npc.Type] and Collision[npc.Type][npc.Variant] then
		return Collision[npc.Type][npc.Variant](npc, collider, first)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity)
	if Death[entity.Type] and Death[entity.Type][entity.Variant] then
		return Death[entity.Type][entity.Variant](entity:ToNPC())
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, entity)
	if Render[entity.Type] and Render[entity.Type][entity.Variant] then
		return Render[entity.Type][entity.Variant](entity:ToNPC())
	end
end)