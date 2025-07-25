_FOKS_BOOSTER_PACK_MOD = RegisterMod("Foks' Booster Pack", 1)

local mod = _FOKS_BOOSTER_PACK_MOD
local version = "1.5.0"
local scriptsToLoad = {
	"enums",
	"utils",
	
	"items.collectibles.passives.toy_soldier",
	"items.collectibles.passives.ephemeral_torch",
	"items.collectibles.passives.covenant",
	"items.collectibles.passives.battle_banner",
	"items.collectibles.passives.demise_of_the_faithful",
	"items.collectibles.passives.appetizer",
	"items.collectibles.passives.grocery_bag",
	"items.collectibles.passives.cracked_mirror",
	"items.collectibles.passives.plastic_brick",
	"items.collectibles.passives.dirge_bell", -- Hybrid between passive and familiar
	"items.collectibles.passives.dead_orange",
	"items.collectibles.passives.snared_fox",
	"items.collectibles.passives.cometa", -- Hybrid between passive and familiar
	"items.collectibles.passives.pebble", -- Hybrid between passive and familiar
	
	"items.collectibles.familiars.asherah_pole",
	"items.collectibles.familiars.happy_fly",
	
	"items.collectibles.actives.clay_jar",
	"items.collectibles.actives.baals_altar",
	"items.collectibles.actives.toy_shovel",
	"items.collectibles.actives.del_key",
	"items.collectibles.actives.box_cutter",
	"items.collectibles.actives.spicy_bean",
	"items.collectibles.actives.dads_dumbbell",
	
	"items.trinkets.trumpet",
	"items.trinkets.white_flag",
	"items.trinkets.threshed_wheat",
	"items.trinkets.lucky_bug",
	"items.trinkets.moms_telephone",
	"items.trinkets.caution_sign",
	"items.trinkets.rune_stone",
	"items.trinkets.grenade_pin",
	"items.trinkets.moxies_yarn",
	"items.trinkets.devils_tongue",
	"items.trinkets.spare_battery",
	
	"items.pickups.mirror_shard",
	"items.pickups.plastic_brick",
	
	"compat.accurateblurbs",
	"compat.eid",
}

for _, path in pairs(scriptsToLoad) do
	include("scripts." .. path)
end

-----------------
-- << DEBUG >> --
-----------------
local messageToLoad = {
	"The API has been underwhelming for around " .. math.ceil(os.difftime(os.time(), os.time{year=2017, month=1, day=3}) / 86400) .. " days damn",
	"This mod is powered by Repentogon *fire**fire**fire*",
	
	"Unpacking 42.zip, please wait...",
	"Come meet me at my palace 50.06728536053054 14.54784267607723",
	"I have no clue what I am doing",
	"I forgor again",
	"The thing under the bed keeps stealing my socks",
	"May contain a Bitcoin miner",
	
	"Go outside and touch some grass",
	"Call your mom, she will appreciate it :)",
	"Drink some water!",
}

local currentDate = os.date("%d-%m")
if currentDate == "31-12" then
	table.insert(messageToLoad, "Happy New Year " .. os.date("%Y") + 1 .. "!")
	table.insert(messageToLoad, "Good luck on your New Year's resolutions!")
elseif currentDate == "24-12" or currentDate == "25-12" then
	table.insert(messageToLoad, "Merry Christmas!")
	table.insert(messageToLoad, "I hope you like coal, a lump of coal!")
elseif currentDate == "31-10" then
	table.insert(messageToLoad, "Happy Halloween!")
	table.insert(messageToLoad, "I thought my plants were safe\nThen the zombies appeared...")
	table.insert(messageToLoad, "I saw Jeff the Killer outside my window\nI hope he doesn't gonna jeff the kill me")
	table.insert(messageToLoad, "I sure hope this is a normal Charm\n\"No\", said the Evil Charm")
end
table.insert(messageToLoad, "There are currently around " .. (#messageToLoad + 1) .. " debug messages!")

local message = "[" .. mod.Name .. " V" .. version .. "] " .. messageToLoad[math.random(#messageToLoad)] .. "\n" -- I'll allow math.random() this once
Isaac.ConsoleOutput(message)