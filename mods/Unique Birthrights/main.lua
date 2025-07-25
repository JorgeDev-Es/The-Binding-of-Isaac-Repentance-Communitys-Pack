-- Credit to Stewartisme's "Custom Mr Dollys" mod for this item sprite-changing code
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2489635144

local Birthrights = RegisterMod("Unique Birthrights", 1)
local level = Game():GetLevel()

local iconsPath = "gfx/items/collectibles/birthright/"

local PlayerList = {
	"_isaac", 
	"_magdalene",
	"_cain",
	"_judas",
	"_bluebaby",
	"_eve",
	"_samson",
	"_azazel",
	"_lazarus",
	"_eden",
	"_thelost",
	"_lazarus2",
	"_darkjudas",
	"_lilith",
	"_keeper",
	"_apollyon",
	"_forgotten",
	"_forgottensoul",
	"_bethany",
	"_jacob",
	"_esau",
	"_isaacb",
	"_magdaleneb",
	"_cainb",
	"_judasb",
	"_bluebabyb",
	"_eveb",
	"_samsonb",
	"_azazelb",
	"_lazarusb",
	"_edenb",
	"_thelostb",
	"_lilithb",
	"_keeperb",
	"_apollyonb",
	"_forgottenb",
	"_bethanyb",
	"_jacobb",
	"_lazarus2b",
	"_jacobghostb",
	"_forgottensoulb"
	}

local TearFlagsBlood = {
	[TearVariant.BLOOD] = true,
	[TearVariant.CUPID_BLOOD] = true,
	[TearVariant.PUPULA_BLOOD] = true,
	[TearVariant.GODS_FLESH_BLOOD] = true,
	[TearVariant.NAIL_BLOOD] = true,
	[TearVariant.GLAUCOMA_BLOOD] = true,
	[TearVariant.EYE_BLOOD] = true
}
local SkinColorToString = {
	[SkinColor.SKIN_PINK] = "",
	[SkinColor.SKIN_WHITE] = "_white",
	[SkinColor.SKIN_BLACK] = "_black",
	[SkinColor.SKIN_BLUE] = "_blue",
	[SkinColor.SKIN_RED] = "_strawberry",
	[SkinColor.SKIN_GREEN] = "_green",
	[SkinColor.SKIN_GREY] = "_grey"
}
local DeletedModesCheck = {
	["HAPPY99"] = true,
	["ILOVEYOU"] = true,
	["MORRIS"] = true,
	["ZIP BOMBER"] = true,
	["CRYPTOLOCKER"] = true,
	["SPYWIPER"] = true,
	["JERUSALEM"] = true,
	["HICURDISMOS"] = true,
	["VCS"] = true,
	["LOCKED"] = true,
	["MEMZ"] = true,
	["MYDOOM"] = true,
	["REVETON"] = true
}

function Birthrights:BirthrightUpdate(e)
	local player = Isaac.GetPlayer(0)
	local playerType = player:GetPlayerType()
	
	if e.Type==5 and e.Variant==100 and e.SubType==619 and math.floor(level:GetCurses()/LevelCurse.CURSE_OF_BLIND)%2 == 0 then
		local sprite = e:GetSprite()
		
		-- Vanilla characters
		if playerType < 41 then 
			sprite:ReplaceSpritesheet(1, iconsPath..playerType..PlayerList[playerType + 1].."_birthright.png")
			
		-- Modded characters
		elseif playerType == Isaac.GetPlayerTypeByName("Andromeda") then
			sprite:ReplaceSpritesheet(1, iconsPath.."andromeda_birthright.png") -- art by Warhamm2000
			
			-- t!Andromeda's birthright matches their skin colour, with a higher priority on blood tears
		elseif playerType == Isaac.GetPlayerTypeByName("AndromedaB", 1) then
			local tearVariant = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 1, 1, nil).TearVariant
			if TearFlagsBlood[tearVariant] == true then
				sprite:ReplaceSpritesheet(1, iconsPath.."andromedab_birthright_blood.png") -- art by Warhamm2000
			else
				sprite:ReplaceSpritesheet(1, iconsPath.."andromedab_birthright"..SkinColorToString[player:GetHeadColor()]..".png") -- art by Warhamm2000
			end
			
			-- Deleted's birthright matches their mode
		elseif THEDELETED and playerType == Isaac.GetPlayerTypeByName("Deleted") then
			if DeletedModesCheck[theDeletedMode] == true then
				sprite:ReplaceSpritesheet(1, iconsPath.."deleted_birthright_"..string.lower(string.gsub(theDeletedMode," ",""))..".png")
			else 
				sprite:ReplaceSpritesheet(1, iconsPath.."deleted_birthright_happy99.png")
			end
		
		elseif playerType == Isaac.GetPlayerTypeByName("Deleted", 1) then
			sprite:ReplaceSpritesheet(1, iconsPath.."deletedb_birthright.png")
		elseif playerType == Isaac.GetPlayerTypeByName("Job") then
			sprite:ReplaceSpritesheet(1, iconsPath.."job_birthright.png")
		elseif playerType == Isaac.GetPlayerTypeByName("Job", 1) then
			sprite:ReplaceSpritesheet(1, iconsPath.."jobb_birthright.png")
		elseif playerType == Isaac.GetPlayerTypeByName("Mastema") then
			sprite:ReplaceSpritesheet(1, iconsPath.."mastema_birthright.png") -- art by Warhamm2000
		elseif playerType == Isaac.GetPlayerTypeByName("MastemaB", 1) then
			sprite:ReplaceSpritesheet(1, iconsPath.."mastemab_birthright.png") -- art by Warhamm2000
		elseif playerType == Isaac.GetPlayerTypeByName("Samael") then
			sprite:ReplaceSpritesheet(1, iconsPath.."samael_birthright.png")
		elseif playerType == Isaac.GetPlayerTypeByName("Steven") then
			sprite:ReplaceSpritesheet(1, iconsPath.."steven_birthright.png") -- art by lambchop_is_ok
		else
			sprite:ReplaceSpritesheet(1, iconsPath.."modded_default_birthright.png")
		
		end
		sprite:LoadGraphics()
		end
	end

Birthrights:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Birthrights.BirthrightUpdate)