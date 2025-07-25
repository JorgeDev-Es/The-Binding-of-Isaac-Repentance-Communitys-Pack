local MOD = RegisterMod("UNIQUE SINS", 1);
local game = Game()
local player = Isaac.GetPlayer(0)
local Level = Game():GetLevel()
-- This code looks awfully long but I'm not a coder so ¯\_(ツ)_/¯
-- Thanks to mod "Unique Spikes" for the code I took to make this possible, credits to the author of that mod
function MOD:ENVY(entity)
	local room = game:GetRoom()
	local backdrop = room:GetBackdropType()
	local sprite = entity:GetSprite()
	local data = entity:GetData()
	if entity.Variant == 0 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/ENVY.png")
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/ENVY")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/ENVY.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:LoadGraphics()
			else -- default
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ENVY.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 1 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/ENVY.png")
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/ENVY")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/ENVY.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:LoadGraphics()
			else -- default
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ENVY.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 10 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/ENVY.png")
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/ENVY")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/ENVY.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:LoadGraphics()
			else -- default
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ENVY.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 11 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/ENVY.png")
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/ENVY")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/ENVY.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:LoadGraphics()
			else -- default
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ENVY.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 20 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/ENVY.png")
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/ENVY")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/ENVY.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:LoadGraphics()
			else -- default
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ENVY.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 21 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/ENVY.png")
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/ENVY")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/ENVY.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:LoadGraphics()
			else -- default
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ENVY.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 30 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/ENVY.png")
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/ENVY")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/ENVY.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:LoadGraphics()
			else -- default
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ENVY.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 31 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/ENVY.png")
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/ENVY")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/ENVY.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/ENVY.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/ENVY.png")
				sprite:LoadGraphics()
			else -- default
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ENVY.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ENVY.png")
				sprite:LoadGraphics()
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.ENVY, EntityType.ENTITY_ENVY)
function MOD:WRATH(entity)
	local room = game:GetRoom()
	local backdrop = room:GetBackdropType()
	local sprite = entity:GetSprite()
	local data = entity:GetData()
	if entity.Variant == 0 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/void/body_wrath.png")
                sprite:ReplaceSpritesheet(1, "gfx/unique_sins/void/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/void/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/body_wrath.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body_wrath.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body_wrath.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/WRATH.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/WRATH.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body_wrath.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/WRATH.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/WRATH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/WRATH.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 1 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/void/body_wrath.png")
                sprite:ReplaceSpritesheet(1, "gfx/unique_sins/void/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/void/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/WRATHS.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body_wrath.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body_wrath.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/WRATHS.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/WRATHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body_wrath.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/WRATHS.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/WRATHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/WRATHS.png")
				sprite:LoadGraphics()
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.WRATH, EntityType.ENTITY_WRATH)
function MOD:GLUTTONY(entity)
	local room = game:GetRoom()
	local backdrop = room:GetBackdropType()
	local sprite = entity:GetSprite()
	local data = entity:GetData()
	if entity.Variant == 0 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/GLUTT.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/GLUTT.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/GLUTT.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/GLUTT.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/GLUTT.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/GLUTT.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/GLUTT.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/GLUTT.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/GLUTT.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 1 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/GLUTTS.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/GLUTTS.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/GLUTTS.png")
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/GLUTTS.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/GLUTTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/GLUTTS.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/GLUTTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/GLUTTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/GLUTTS.png")
				sprite:LoadGraphics()
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.GLUTTONY, EntityType.ENTITY_GLUTTONY)
function MOD:SLOTH(entity)
	local room = game:GetRoom()
	local backdrop = room:GetBackdropType()
	local sprite = entity:GetSprite()
	local data = entity:GetData()
	if entity.Variant == 0 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/body_sloth.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/SLOTH.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/SLOTH.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/SLOTH.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/SLOTH.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/SLOTH.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/SLOTH.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 1 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/body_sloth.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/SLOTHS.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/SLOTHS.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/SLOTHS.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/SLOTHS.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/body_sloth.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/SLOTHS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/SLOTHS.png")
				sprite:LoadGraphics()
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.SLOTH, EntityType.ENTITY_SLOTH)
function MOD:LUST(entity)
	local room = game:GetRoom()
	local backdrop = room:GetBackdropType()
	local sprite = entity:GetSprite()
	local data = entity:GetData()
	if entity.Variant == 0 then
		if ReworkedFoes then
			if backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/burnt/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/burnt/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/caves/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/caves/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/catacombs/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/catacombs/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/drowned/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/drowned/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/depths/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/depths/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/necropolis/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/necropolis/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/scarred/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/scarred/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/darkroom/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/darkroom/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/dank/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/dank/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/womb/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/womb/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/sheol/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/sheol/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/cathedral/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/cathedral/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/shop/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/shop/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/chest/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/chest/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/downpour/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/downpour/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/mines/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/mines/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/mausoleum/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/mausoleum/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/corpse/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/corpse/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/dross/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/dross/LUST.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/modcomp/ashpit/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/ashpit/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/gehenna/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/gehenna/LUST.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/LUST.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/LUST.png")
				sprite:LoadGraphics()
			end
		elseif data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/body_lust.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/LUST.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/LUST.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/LUST.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/LUST.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/body_lust.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/LUST.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/LUST.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 1 then
		if ReworkedFoes then
			if backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/caves/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/caves/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/catacombs/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/catacombs/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/drowned/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/drowned/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/depths/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/depths/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/necropolis/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/necropolis/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/scarred/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/scarred/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/darkroom/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/darkroom/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/dank/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/dank/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/womb/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/womb/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/sheol/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/sheol/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/cathedral/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/cathedral/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/shop/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/shop/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/chest/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/chest/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/mines/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/mines/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/mausoleum/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/mausoleum/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/corpse/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/corpse/LUSTS.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/modcomp/ashpit/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/ashpit/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/gehenna/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/gehenna/LUSTS.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/LUSTS.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/LUSTS.png")
				sprite:LoadGraphics()
			end
		elseif data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/body_lustS.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/LUSTS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/LUSTS.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/LUSTS.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/LUSTS.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/body_lustS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/LUSTS.png")
				sprite:LoadGraphics()
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.LUST, EntityType.ENTITY_LUST)
function MOD:PRIDE(entity)
	local room = game:GetRoom()
	local backdrop = room:GetBackdropType()
	local sprite = entity:GetSprite()
	local data = entity:GetData()
	if entity.Variant == 0 then
		if ReworkedFoes then
			if backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/burnt/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/burnt/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/caves/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/caves/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/catacombs/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/catacombs/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/drowned/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/drowned/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/depths/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/depths/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/necropolis/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/necropolis/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/scarred/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/scarred/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/darkroom/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/darkroom/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/dank/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/dank/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/womb/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/womb/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/sheol/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/sheol/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/cathedral/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/cathedral/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/shop/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/shop/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/chest/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/chest/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/downpour/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/downpour/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/mines/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/mines/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/mausoleum/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/mausoleum/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/corpse/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/corpse/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/dross/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/dross/PRIDE.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/modcomp/ashpit/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/ashpit/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/gehenna/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/gehenna/PRIDE.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/PRIDE.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/PRIDE.png")
				sprite:LoadGraphics()
			end
		elseif data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/body.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/PRIDE.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/PRIDE.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/PRIDE.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/PRIDE.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/body_pride.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/PRIDE.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/PRIDE.png")
				sprite:LoadGraphics()
			end
		end
	elseif entity.Variant == 1 then
		if ReworkedFoes then
			if backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/caves/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/caves/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/catacombs/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/catacombs/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/drowned/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/drowned/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/depths/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/depths/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/necropolis/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/necropolis/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/scarred/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/scarred/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/darkroom/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/darkroom/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/dank/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/dank/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/womb/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/womb/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/sheol/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/sheol/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/cathedral/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/cathedral/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/shop/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/shop/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/chest/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/chest/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/downpour/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/downpour/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/mines/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/mines/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/mausoleum/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/mausoleum/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/corpse/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/corpse/PRIDES.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/modcomp/ashpit/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/ashpit/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/gehenna/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/gehenna/PRIDES.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/modcomp/PRIDES.png")
				sprite:ReplaceSpritesheet(1, "gfx/modcomp/PRIDES.png")
				sprite:LoadGraphics()
			end
		elseif data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/bodyB.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/PRIDES.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 5 then -- catacombs
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/catacombs/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/catacombs/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/catacombs/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/PRIDES.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/PRIDES.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/PRIDES.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/body_prideS.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/PRIDES.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/PRIDES.png")
				sprite:LoadGraphics()
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.PRIDE, EntityType.ENTITY_PRIDE)
function MOD:GREED(entity)
	local room = game:GetRoom()
	local backdrop = room:GetBackdropType()
	local sprite = entity:GetSprite()
	local data = entity:GetData()
	-- GREED
	if entity.Variant == 0 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/body.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/GREED.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/GREED.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/GREED.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/GREED.png")
				sprite:LoadGraphics()
			elseif Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/body.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/GREED.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/GREED.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/body.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/GREED.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/GREED.png")
				sprite:LoadGraphics()
			end
		end
		-- SUPER GREED
	elseif entity.Variant == 1 then
		if data.Changed == nil then
			data.Changed = true
			if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
				sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/bodyB.png")
                sprite:ReplaceSpritesheet(1,"gfx/unique_sins/void/GREEDS.png")
				sprite:ReplaceSpritesheet(2,"gfx/unique_sins/void/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 3 then -- burning basement
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/burnt/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/burnt/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 4 then -- caves
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/caves/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/caves/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 6 then -- flooded
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/drowned/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/drowned/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 7 then -- depths
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/depths/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/depths/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 8 then -- necropolis
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/necropolis/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/necropolis/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 12 then -- scarred
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/scarred/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/scarred/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 16 then -- dark room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/darkroom/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/darkroom/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 9 then -- dank
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dank/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dank/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 10 or backdrop == 11 then -- womb, utero
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/womb/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/womb/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 14 then -- sheol
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/sheol/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/sheol/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 15 then -- cathedral
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/cathedral/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/cathedral/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- shop, secret room, greed shop, error room
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/shop/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/shop/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/shop/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 17 then -- chest
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/chest/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/chest/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 31 then -- downpour
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/downpour/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/downpour/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 32 then -- mines
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mines/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mines/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/mausoleum/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/mausoleum/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/corpse/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/corpse/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 45 then -- dross
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/dross/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/dross/GREEDS.png")
				sprite:LoadGraphics()
		    elseif backdrop == 46 then -- ashpit
		    	sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/ashpit/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/ashpit/GREEDS.png")
				sprite:LoadGraphics()
			elseif backdrop == 47 then -- gehenna
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/gehenna/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/gehenna/GREEDS.png")
				sprite:LoadGraphics()
			else
				sprite:ReplaceSpritesheet(0, "gfx/unique_sins/bodyB.png")
				sprite:ReplaceSpritesheet(1, "gfx/unique_sins/GREEDS.png")
				sprite:ReplaceSpritesheet(2, "gfx/unique_sins/GREEDS.png")
				sprite:LoadGraphics()
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.GREED, EntityType.ENTITY_GREED)
function MOD:HOPPER(entity)
	local room = game:GetRoom()
	local backdrop = room:GetBackdropType()
	local sprite = entity:GetSprite()
	local data = entity:GetData()
	if Isaac.GetEntityVariantByName("Hopper") then
			-- HOPPER, WHEN GREED IS IN ROOM
		if #Isaac.FindByType(50, 0, -1, false, true) >= 1 or #Isaac.FindByType(50, 1, -1, false, true) >= 1 then
			if data.Changed == nil then
				data.Changed = true
				if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
					sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 3 then -- burning basement
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 4 then -- caves
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 6 then -- flooded
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 7 then -- depths
				    sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 8 then -- necropolis
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 12 then -- scarred
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 16 then -- dark room
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 9 then -- dank
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 10 or backdrop == 11 then -- womb, utero
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 14 then -- sheol
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 15 or backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- cathedral, shop, secret room, greed shop, error room
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 17 then -- chest
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 31 then -- downpour
				    sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 32 then -- mines
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/HOPPER.png")
				sprite:LoadGraphics()
				elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 45 then -- dross
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/HOPPER.png")
					sprite:LoadGraphics()
		   	 	elseif backdrop == 46 then -- ashpit
		    		sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/HOPPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 47 then -- gehenna
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/HOPPER.png")
					sprite:LoadGraphics()
				else
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/HOPPER.png")
					sprite:LoadGraphics()
				end
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.HOPPER, EntityType.ENTITY_HOPPER)
function MOD:KEEPER(entity)
local room = game:GetRoom()
local backdrop = room:GetBackdropType()
local sprite = entity:GetSprite()
local data = entity:GetData()
	if Isaac.GetEntityVariantByName("Keeper") then
			-- KEEPER, WHEN GREED IS IN ROOM
		if #Isaac.FindByType(50, 0, -1, false, true) >= 1 or #Isaac.FindByType(50, 1, -1, false, true) >= 1 then
			if data.Changed == nil then
				data.Changed = true
				if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
					sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 3 then -- burning basement
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 4 then -- caves
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/caves/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 6 then -- flooded
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 7 then -- depths
				    sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 8 then -- necropolis
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 12 then -- scarred
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 16 then -- dark room
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 9 then -- dank
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 10 or backdrop == 11 then -- womb, utero
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 14 then -- sheol
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 15 or backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- cathedral, shop, secret room, greed shop, error room
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 17 then -- chest
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 31 then -- downpour
				    sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 32 then -- mines
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/KEEPER.png")
				    sprite:LoadGraphics()
				elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 45 then -- dross
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/KEEPER.png")
					sprite:LoadGraphics()
		   	 	elseif backdrop == 46 then -- ashpit
		    		sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/KEEPER.png")
					sprite:LoadGraphics()
				elseif backdrop == 47 then -- gehenna
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/KEEPER.png")
						sprite:LoadGraphics()
				else
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/KEEPER.png")
					sprite:LoadGraphics()
				end
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.KEEPER, EntityType.ENTITY_KEEPER)
function MOD:CHARGER(entity)
local room = game:GetRoom()
local backdrop = room:GetBackdropType()
local sprite = entity:GetSprite()
local data = entity:GetData()
	if Isaac.GetEntityVariantByName("Charger") then
			-- KEEPER, WHEN GREED IS IN ROOM
		if #Isaac.FindByType(46, 0, -1, false, true) >= 1 or #Isaac.FindByType(46, 1, -1, false, true) >= 1 then
			if data.Changed == nil then
				data.Changed = true
				if Game():GetLevel():GetStage() == LevelStage.STAGE7 then -- void
					sprite:ReplaceSpritesheet(0,"gfx/unique_sins/void/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 3 then -- burning basement
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/burnt/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 6 then -- flooded
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/drowned/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 7 then -- depths
				    sprite:ReplaceSpritesheet(0, "gfx/unique_sins/depths/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 8 then -- necropolis
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/necropolis/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 12 then -- scarred
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/scarred/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 16 then -- dark room
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/darkroom/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 9 then -- dank
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dank/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 10 or backdrop == 11 then -- womb, utero
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/womb/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 14 then -- sheol
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/sheol/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 15 then -- cathedral
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 23 or backdrop == 26 or backdrop == 28 or backdrop == 20 then -- cathedral, shop, secret room, greed shop, error room
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/cathedral/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 17 then -- chest
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/chest/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 31 then -- downpour
				    sprite:ReplaceSpritesheet(0, "gfx/unique_sins/downpour/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 32 then -- mines
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mines/charger.png")
				    sprite:LoadGraphics()
				elseif backdrop == 33 or backdrop == 40 or backdrop == 41 or backdrop == 42 then -- mausoleum
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/mausoleum/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 34 or backdrop == 43 or backdrop == 44 or backdrop == 48 then -- corpse
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/corpse/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 45 then -- dross
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/dross/charger.png")
					sprite:LoadGraphics()
		   	 	elseif backdrop == 46 then -- ashpit
		    		sprite:ReplaceSpritesheet(0, "gfx/unique_sins/ashpit/charger.png")
					sprite:LoadGraphics()
				elseif backdrop == 47 then -- gehenna
					sprite:ReplaceSpritesheet(0, "gfx/unique_sins/gehenna/charger.png")
						sprite:LoadGraphics()
				end
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MOD.CHARGER, EntityType.ENTITY_CHARGER)