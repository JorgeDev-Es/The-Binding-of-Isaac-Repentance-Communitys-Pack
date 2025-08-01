function mod:changeSprite(npc)
        local data = npc:GetData()
        if not data.init then
    if npc.Variant then
		local sprite = npc:GetSprite()
        local stage = Game():GetLevel():GetStage()
        local stageType = Game():GetLevel():GetStageType()
            if (stage == LevelStage.STAGE1_1 or stage == LevelStage.STAGE1_2)			and (stageType == StageType.STAGETYPE_REPENTANCE_B) then
				npc:GetSprite():Load("gfx/295.000_cornmine.anm2",true)
				npc:GetSprite():ReplaceSpritesheet(0, "gfx/corn_dross.png")
                npc:GetSprite():LoadGraphics()
            end
            data.init = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.changeSprite, 295)