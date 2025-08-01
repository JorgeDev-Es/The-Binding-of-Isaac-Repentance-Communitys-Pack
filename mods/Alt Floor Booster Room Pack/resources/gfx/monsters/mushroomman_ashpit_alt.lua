function mod:changeSprite3(npc)
        local data = npc:GetData()
        if not data.init then
    if npc.Variant then
		local sprite = npc:GetSprite()
        local stage = Game():GetLevel():GetStage()
        local stageType = Game():GetLevel():GetStageType()
            if (stage == LevelStage.STAGE2_1 or stage == LevelStage.STAGE2_2)			and (stageType == StageType.STAGETYPE_REPENTANCE_B) then
				npc:GetSprite():Load("gfx/300.000_MushroomMan.anm2",true)
				npc:GetSprite():ReplaceSpritesheet(0, "gfx/monster_300_mushroomman_ashpit.png")
                npc:GetSprite():LoadGraphics()
            end
            data.init = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.changeSprite3, 300)