ScrapEnemyAlts = RegisterMod("Scrapped Enemy Alts", 1)
local mod = ScrapEnemyAlts
local game = Game()
local json = require("json")

include("lua.deadseascrolls")
if REPENTANCE_PLUS and REPENTOGON then
	include("lua.moddedrooms")
end

mod.savedata = nil

function mod:gaperInit(entity)
local sprite = entity:GetSprite()
local level = game:GetLevel()
local room = game:GetRoom()
	if room:GetBackdropType() == BackdropType.MINES or room:GetBackdropType() == BackdropType.MINES_ENTRANCE or room:GetBackdropType() == BackdropType.MINES_SHAFT or (level:GetStage() == LevelStage.STAGE2_1 or level:GetStage() == LevelStage.STAGE2_2) and level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
		if entity.Type == EntityType.ENTITY_GUSHER and entity.Variant == 0 and entity.SubType == 0 then
			entity:Morph(EntityType.ENTITY_GUSHER, 0, 101, -1)
			entity.HitPoints = entity.MaxHitPoints
		elseif entity.Type == EntityType.ENTITY_GUSHER and entity.Variant == 1 and entity.SubType == 0 then
			entity:Morph(EntityType.ENTITY_GUSHER, 1, 101, -1)
			entity.HitPoints = entity.MaxHitPoints
		end
		if entity.Type == EntityType.ENTITY_GAPER and entity.Variant == 0 and entity.SubType == 0 then
			entity:Morph(EntityType.ENTITY_GAPER, 0, 101, -1)
			entity.HitPoints = entity.MaxHitPoints
			if mod.spriteOption == 2 then
				entity:ReplaceSpritesheet(1, "gfx/monsters/compatibility/gapery gapers/monster_024_frowninggaper_mines.png", true)
				entity:ReplaceSpritesheet(2, "gfx/monsters/compatibility/gapery gapers/monster_017_gaper_lighting.png", true)
			elseif mod.spriteOption == 4 then
				entity:ReplaceSpritesheet(1, "gfx/monsters/compatibility/vee's resprites/monster_024_frowninggaper_mines.png", true)
				entity:ReplaceSpritesheet(2, "gfx/monsters/compatibility/vee's resprites/monster_017_gaper_lighting.png", true)
			else
				entity:ReplaceSpritesheet(1, "gfx/monsters/remix/monster_024_frowninggaper_mines.png", true)
				entity:ReplaceSpritesheet(2, "gfx/monsters/remix/monster_017_gaper_lighting.png", true)
			end
		elseif entity.Type == EntityType.ENTITY_GAPER and entity.Variant == 1 and entity.SubType == 0 then
			entity:Morph(EntityType.ENTITY_GAPER, 1, 101, -1)
			entity.HitPoints = entity.MaxHitPoints
			if mod.spriteOption == 2 then
				entity:ReplaceSpritesheet(1, "gfx/monsters/compatibility/gapery gapers/monster_017_gaper_mines.png", true)
				entity:ReplaceSpritesheet(2, "gfx/monsters/compatibility/gapery gapers/monster_017_gaper_lighting.png", true)
			elseif mod.spriteOption == 4 then
				entity:ReplaceSpritesheet(1, "gfx/monsters/compatibility/vee's resprites/monster_017_gaper_mines.png", true)
				entity:ReplaceSpritesheet(2, "gfx/monsters/compatibility/vee's resprites/monster_017_gaper_lighting.png", true)
			else
				entity:ReplaceSpritesheet(1, "gfx/monsters/remix/monster_017_gaper_mines.png", true)
				entity:ReplaceSpritesheet(2, "gfx/monsters/remix/monster_017_gaper_lighting.png", true)
			end
		end
		if FiendFolio then
			if entity.Type == 160 and entity.Variant == 1210 then
				if entity.SubType == 0 then
					entity:ToNPC():Morph(160, 1210, 101, -1)
					entity.HitPoints = entity.MaxHitPoints
				elseif entity.SubType == 100 then
					entity:ToNPC():Morph(160, 1210, 102, -1)
					entity.HitPoints = entity.MaxHitPoints
				end
			end
			if entity.Type == 160 and entity.Variant == 820 then
				if entity.SubType == 0 then
					entity:ToNPC():Morph(160, 820, 101, -1)
					entity.HitPoints = entity.MaxHitPoints
				elseif entity.SubType == 2 then
					entity:ReplaceSpritesheet(0, "gfx/enemies/slim/limb_mines.png", true)
				end
			end
			if entity.Type == 160 and entity.Variant == 50 then
				sprite:Load("gfx/enemies/morsel/morsel (mines).anm2", true)
			end
		end
	else
		if entity.Type == EntityType.ENTITY_GUSHER and entity.Variant == 0 and entity.SubType == 101 then
			entity:Morph(EntityType.ENTITY_GUSHER, 0, 0, -1)
			entity.HitPoints = entity.MaxHitPoints
		elseif entity.Type == EntityType.ENTITY_GUSHER and entity.Variant == 1 and entity.SubType == 101 then
			entity:Morph(EntityType.ENTITY_GUSHER, 1, 0, -1)
			entity.HitPoints = entity.MaxHitPoints
		end
		if entity.Type == EntityType.ENTITY_GAPER and entity.Variant == 0 and (entity.SubType == 101 or entity.SubType == 102 or entity.SubType == 103) then
			entity:Morph(EntityType.ENTITY_GAPER, 0, 0, -1)
			entity.HitPoints = entity.MaxHitPoints
		elseif entity.Type == EntityType.ENTITY_GAPER and entity.Variant == 1 and (entity.SubType == 101 or entity.SubType == 102 or entity.SubType == 103) then
			entity:Morph(EntityType.ENTITY_GAPER, 1, 0, -1)
			entity.HitPoints = entity.MaxHitPoints
		end
		if FiendFolio then
			if entity.Type == 160 and entity.Variant == 1210 then
				if entity.SubType == 101 then
					entity:ToNPC():Morph(160, 1210, 0, -1)
					entity.HitPoints = entity.MaxHitPoints
				elseif entity.SubType == 102 then
					entity:ToNPC():Morph(160, 1210, 100, -1)
					entity.HitPoints = entity.MaxHitPoints
				end
			end
			if entity.Type == 160 and entity.Variant == 820 then
				if entity.SubType == 101 then
					entity:ToNPC():Morph(160, 820, 0, -1)
					entity.HitPoints = entity.MaxHitPoints
				end
			end
			if entity.Type == 160 and entity.Variant == 50 and sprite:GetFilename() == "gfx/enemies/morsel/morsel (mines).anm2" then
				sprite:Load("gfx/enemies/morsel/morsel.anm2", true)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.gaperInit)

function mod:enemyInit(entity)
local sprite = entity:GetSprite()
local level = game:GetLevel()
local room = game:GetRoom()
	if room:GetBackdropType() == BackdropType.WOMB or room:GetBackdropType() == BackdropType.UTERO or room:GetBackdropType() == BackdropType.SCARRED_WOMB or (level:GetStage() == LevelStage.STAGE4_1 or level:GetStage() == LevelStage.STAGE4_2) and (level:GetStageType() == StageType.STAGETYPE_ORIGINAL or level:GetStageType() == StageType.STAGETYPE_WOTL or level:GetStageType() == StageType.STAGETYPE_AFTERBIRTH) then
		if entity.Type == EntityType.ENTITY_BLURB and entity.Variant == 0 and entity.SubType == 0 then
			entity:Morph(EntityType.ENTITY_BLURB, 0, 1, -1)
			entity.HitPoints = entity.MaxHitPoints
		end
		if entity.Type == EntityType.ENTITY_ROUND_WORM and entity.Variant == 1 and entity.SubType == 0 then
			if mod.spriteOption == 5 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/tubeworm_womb.png", true)
				entity:ReplaceSpritesheet(1, "gfx/monsters/compatibility/last judgement/tubeworm_womb.png", true)
			else
				entity:ReplaceSpritesheet(0, "gfx/monsters/afterbirthplus/tubeworm_womb.png", true)
				entity:ReplaceSpritesheet(1, "gfx/monsters/afterbirthplus/tubeworm_womb.png", true)
			end
		end
		if entity.Type == EntityType.ENTITY_ROUND_WORM and entity.Variant == 3 and entity.SubType == 0 then
			entity:ReplaceSpritesheet(0, "gfx/monsters/repentance/ultra/tube_worm_womb.png", true)
			entity:ReplaceSpritesheet(1, "gfx/monsters/repentance/ultra/tube_worm_womb.png", true)
		end
	else
		if entity.Type == EntityType.ENTITY_BLURB and entity.Variant == 0 and entity.SubType == 1 then
			entity:Morph(EntityType.ENTITY_BLURB, 0, 0, -1)
			entity.HitPoints = entity.MaxHitPoints
		end
		if entity.Type == EntityType.ENTITY_ROUND_WORM and entity.Variant == 3 and entity.SubType == 0 then
			entity:ReplaceSpritesheet(0, "gfx/monsters/repentance/ultra/tube_worm.png", true)
			entity:ReplaceSpritesheet(1, "gfx/monsters/repentance/ultra/tube_worm.png", true)
		end
	end
	if room:GetBackdropType() == BackdropType.SCARRED_WOMB or (level:GetStage() == LevelStage.STAGE4_1 or level:GetStage() == LevelStage.STAGE4_2) and level:GetStageType() == StageType.STAGETYPE_AFTERBIRTH then
		if entity.Type == EntityType.ENTITY_LUMP and entity.Variant == 0 and entity.SubType == 0 then
			if mod.lumpOption == 1 then
				if mod.spriteOption == 5 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_scarred.png", true)
				else
					entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_198_lump_scarred.png", true)
				end
			else
				if mod.spriteOption == 5 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse_alt.png", true)
				else
					entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_198_lump.png", true)
				end
			end
		end
	end
	if room:GetBackdropType() == BackdropType.CORPSE or room:GetBackdropType() == BackdropType.CORPSE_ENTRANCE or room:GetBackdropType() == BackdropType.CORPSE2 or room:GetBackdropType() == BackdropType.CORPSE3 or (level:GetStage() == LevelStage.STAGE4_1 or level:GetStage() == LevelStage.STAGE4_2) and level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
		if entity.Type == EntityType.ENTITY_PARA_BITE and entity.Variant == 0 then
			entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_199_parabite_corpse.png", true)
			entity:ReplaceSpritesheet(1, "gfx/monsters/remix/monster_199_parabite_corpse.png", true)
		end
		if entity.Type == EntityType.ENTITY_POOTER and entity.Variant == 1 then
			if mod.spriteOption == 3 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/flash pooters/monster_007_superpooter_corpse.png", true)
			elseif mod.spriteOption == 4 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/vee's resprites/monster_007_superpooter_corpse.png", true)
			elseif mod.spriteOption == 5 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_007_superpooter_corpse.png", true)
			else
				entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_007_superpooter_corpse.png", true)
			end
		end
		if entity.Type == EntityType.ENTITY_PIN and entity.Variant == 3 then
			sprite:ReplaceSpritesheet(0, "gfx/bosses/repentance/wormwood_corpse.png", true)
		end
	end
	if room:GetBackdropType() == BackdropType.CORPSE or room:GetBackdropType() == BackdropType.CORPSE_ENTRANCE then
		if entity.Type == EntityType.ENTITY_LUMP and entity.Variant == 0 then
			if mod.lumpOption == 1 then
				if mod.spriteOption == 5 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse.png", true)
				else
					entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse.png", true)
				end
			else
				if mod.spriteOption == 5 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse_alt.png", true)
				else
					entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse_alt.png", true)
				end
			end
		end
	elseif room:GetBackdropType() == BackdropType.CORPSE2 then
		if entity.Type == EntityType.ENTITY_LUMP and entity.Variant == 0 then
			if mod.lumpOption == 1 then
				if mod.spriteOption == 5 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse2.png", true)
				else
					entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse2.png", true)
				end
			else
				if mod.spriteOption == 5 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse_alt.png", true)
				else
					entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse_alt.png", true)
				end
			end
		end
		if entity.Type == EntityType.ENTITY_ADULT_LEECH and entity.Variant == 0 and not ReworkedFoes then
			entity:ReplaceSpritesheet(0, "gfx/monsters/remix/854.000_adultleech2.png", true)
		end
		if entity.Type == EntityType.ENTITY_GASBAG and entity.Variant == 0 then
			entity:ReplaceSpritesheet(0, "gfx/monsters/repentance/856.000_gasbag2.png", true)
		end
	elseif room:GetBackdropType() == BackdropType.CORPSE3 then
		if entity.Type == EntityType.ENTITY_LUMP and entity.Variant == 0 then
			entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_198_lump.png", true)
		end
	end
	if FiendFolio then
		if FiendFolio.roomBackdrop == 10 then
			if entity.Type == EntityType.ENTITY_LUMP and entity.Variant == 0 then
				if mod.lumpOption == 1 then
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_morbus.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_morbus.png", true)
					end
				else
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse_alt.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse_alt.png", true)
					end
				end
			end
		end
		if entity.Type == 114 and entity.Variant == 1004 and entity.SubType == 15 and not ReworkedFoes then
			if room:GetBackdropType() == BackdropType.CORPSE2 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/remix/854.000_adultleech2.png", true)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.enemyInit)

function mod:knightInit(entity)
local room = game:GetRoom()
	if room:GetBackdropType() == BackdropType.MAUSOLEUM or room:GetBackdropType() == BackdropType.MAUSOLEUM_ENTRANCE or room:GetBackdropType() == BackdropType.MAUSOLEUM2 or room:GetBackdropType() == BackdropType.MAUSOLEUM3 or room:GetBackdropType() == BackdropType.MAUSOLEUM4 then
		if entity.Variant == 4 then
			entity:Morph(EntityType.ENTITY_KNIGHT, 4, 1, -1)
			entity.HitPoints = entity.MaxHitPoints
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.knightInit, EntityType.ENTITY_KNIGHT)

function mod:knightJetInit(effect)
local sprite = effect:GetSprite()
local room = game:GetRoom()
	if room:GetBackdropType() == BackdropType.MAUSOLEUM or room:GetBackdropType() == BackdropType.MAUSOLEUM_ENTRANCE or room:GetBackdropType() == BackdropType.MAUSOLEUM2 or room:GetBackdropType() == BackdropType.MAUSOLEUM3 or room:GetBackdropType() == BackdropType.MAUSOLEUM4 then
		if effect.SpawnerType == EntityType.ENTITY_KNIGHT and effect.SpawnerVariant == 4 then
			effect.Color = Color(1,1,1, 1, 0,0,0)
			sprite:ReplaceSpritesheet(0, "gfx/effects/fire_jet_purple.png", true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.knightJetInit, EffectVariant.FIRE_JET)

function mod:knightWaveInit(effect)
local sprite = effect:GetSprite()
local room = game:GetRoom()
	if room:GetBackdropType() == BackdropType.MAUSOLEUM or room:GetBackdropType() == BackdropType.MAUSOLEUM_ENTRANCE or room:GetBackdropType() == BackdropType.MAUSOLEUM2 or room:GetBackdropType() == BackdropType.MAUSOLEUM3 or room:GetBackdropType() == BackdropType.MAUSOLEUM4 then
		if effect.SpawnerType == EntityType.ENTITY_KNIGHT and effect.SpawnerVariant == 4 then
			effect.Color = Color(1,1,1, 1, 0,0,0)
			sprite:ReplaceSpritesheet(0, "gfx/effects/fire_jet_purple.png", true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.knightWaveInit, EffectVariant.FIRE_WAVE)

function mod:lilHauntInit(entity)
local level = game:GetLevel()
local room = game:GetRoom()
	if room:GetBackdropType() == BackdropType.DOWNPOUR or room:GetBackdropType() == BackdropType.DOWNPOUR_ENTRANCE or (level:GetStage() == LevelStage.STAGE1_1 or level:GetStage() == LevelStage.STAGE1_2) and level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
		if entity.Variant == 10 then
			entity:Morph(EntityType.ENTITY_THE_HAUNT, 10, 20, -1)
			entity.HitPoints = entity.MaxHitPoints
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.lilHauntInit, EntityType.ENTITY_THE_HAUNT)

function mod:lumpUpdate(entity)
local sprite = entity:GetSprite()
local room = game:GetRoom()
	if entity.Type == EntityType.ENTITY_LUMP and entity.Variant == 0 then
		if entity.SubType == 0 then
			if room:GetBackdropType() == BackdropType.CORPSE or room:GetBackdropType() == BackdropType.CORPSE_ENTRANCE then
				if mod.lumpOption == 1 then
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse.png", true)
					end
				else
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse_alt.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse_alt.png", true)
					end
				end
			elseif room:GetBackdropType() == BackdropType.CORPSE2 then
				if mod.lumpOption == 1 then
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse2.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse2.png", true)
					end
				else
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse_alt.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse_alt.png", true)
					end
				end
			elseif room:GetBackdropType() == BackdropType.CORPSE3 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_198_lump", true)
				if sprite:GetLayer(0):GetSpritesheetPath() == "gfx/monsters/repentance/monster_198_lump_corpse.png" then
					entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_198_lump.png", true)
				end
				if sprite:GetLayer(1):GetSpritesheetPath() == "gfx/monsters/repentance/monster_198_lump_corpse.png" then
					entity:ReplaceSpritesheet(1, "gfx/monsters/classic/monster_198_lump.png", true)
				end
			end
			if room:GetBackdropType() == BackdropType.SCARRED_WOMB then
				if mod.lumpOption == 1 then
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_scarred.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_198_lump_scarred.png", true)
					end
				else
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse_alt.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_198_lump.png", true)
					end
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.lumpUpdate)

function mod:paraUpdate(entity)
local room = game:GetRoom()
	if room:GetBackdropType() == BackdropType.CORPSE or room:GetBackdropType() == BackdropType.CORPSE_ENTRANCE or room:GetBackdropType() == BackdropType.CORPSE2 or room:GetBackdropType() == BackdropType.CORPSE3 then
		if entity.Type == EntityType.ENTITY_PARA_BITE and entity.Variant == 0 then
			entity:Morph(EntityType.ENTITY_PARA_BITE, 0, 100, -1)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.paraUpdate)

function mod:ffUpdate(entity)
local room = game:GetRoom()
	if entity.Type == EntityType.ENTITY_LUMP and entity.Variant == 0 then 
		if FiendFolio then
			if FiendFolio.roomBackdrop == 10 then
				if mod.lumpOption == 1 then
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_morbus.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_morbus.png", true)
					end
				else
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse_alt.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse_alt.png", true)
					end
				end
			end
		end
	end
	if entity.Type == 150 and entity.Variant == 16 and entity.SubType == 10 then
		if mod.lumpOption == 1 then
			if game:GetRoom():GetBackdropType() == BackdropType.CORPSE or game:GetRoom():GetBackdropType() == BackdropType.CORPSE_ENTRANCE then
				if mod.spriteOption == 5 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse.png", true)
				else
					entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse.png", true)
				end
			elseif game:GetRoom():GetBackdropType() == BackdropType.CORPSE2 then
				if mod.spriteOption == 5 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_corpse2.png", true)
				else
					entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse2.png", true)
				end
			elseif game:GetRoom():GetBackdropType() == BackdropType.CORPSE3 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_198_lump.png", true)
				if FiendFolio.roomBackdrop == 10 then
					if mod.spriteOption == 5 then
						entity:ReplaceSpritesheet(0, "gfx/monsters/compatibility/last judgement/monster_198_lump_morbus.png", true)
					else
						entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_morbus.png", true)
					end
				end
			end
		else
			if game:GetRoom():GetBackdropType() ~= BackdropType.CORPSE3 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_198_lump_corpse_alt.png", true)
			end
		end
	end
	if room:GetBackdropType() == BackdropType.CORPSE or room:GetBackdropType() == BackdropType.CORPSE_ENTRANCE or room:GetBackdropType() == BackdropType.CORPSE2 or room:GetBackdropType() == BackdropType.CORPSE3 then
		if FiendFolio then
			if entity.Type == 150 and entity.Variant == 16 and entity.SubType == 6 then
				entity:ReplaceSpritesheet(0, "gfx/monsters/remix/monster_199_parabite_corpse.png", true)
				if FiendFolio.roomBackdrop == 10 then
					entity:ReplaceSpritesheet(0, "gfx/monsters/classic/monster_199_parabite_morbus.png", true)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.ffUpdate)

function mod:gusherSpawn(entity)
local data = entity:GetData()
local room = game:GetRoom()
	if room:GetBackdropType() == BackdropType.MINES or room:GetBackdropType() == BackdropType.MINES_ENTRANCE or room:GetBackdropType() == BackdropType.MINES_SHAFT then
		if entity:HasMortalDamage() and (entity.Variant == 0 or entity.Variant == 1) and (entity.SubType == 101 or entity.SubType == 102 or entity.SubType == 103) then
			entity:Kill()
			if math.random(12) >= 10 then
				local pacer = Isaac.Spawn(EntityType.ENTITY_GUSHER, 1, 101, entity.Position, Vector.Zero, entity):ToNPC()
				pacer:Morph(pacer.Type, pacer.Variant, pacer.SubType, entity:GetChampionColorIdx())
				pacer.HitPoints = pacer.MaxHitPoints
				pacer:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				if entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					pacer:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
				end
				data.spawned = true
				if entity:GetMinecart() ~= nil then
					pacer:GiveMinecart(entity:GetMinecart().Position, entity:GetMinecart().Velocity)
				end
			elseif math.random(12) <= 3 then
				local gusher = Isaac.Spawn(EntityType.ENTITY_GUSHER, 0, 101, entity.Position, Vector.Zero, entity):ToNPC()
				gusher:Morph(gusher.Type, gusher.Variant, gusher.SubType, entity:GetChampionColorIdx())
				gusher.HitPoints = gusher.MaxHitPoints
				gusher:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				if entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					gusher:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
				end
				data.spawned = true
				if entity:GetMinecart() ~= nil then
					gusher:GiveMinecart(entity:GetMinecart().Position, entity:GetMinecart().Velocity)
				end
			end
			if data.spawned == true and entity:GetMinecart() ~= nil then
				entity:GetMinecart():Remove()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.gusherSpawn, EntityType.ENTITY_GAPER)

function mod.getSaveData()
	if not mod.savedata then
		if Isaac.HasModData(mod) then
			mod.savedata = json.decode(Isaac.LoadModData(mod))
		else
			mod.savedata = {}
		end
	end
	mod.spriteOption = mod.savedata.spriteOption or mod.spriteOption
	mod.lumpOption = mod.savedata.lumpOption or mod.lumpOption
	return mod.savedata
end

function mod.storeSaveData()
	mod.savedata.spriteOption = mod.spriteOption
	mod.savedata.lumpOption = mod.lumpOption
	Isaac.SaveModData(mod, json.encode(mod.savedata))
end