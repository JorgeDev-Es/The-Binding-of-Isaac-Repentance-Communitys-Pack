local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    widowHPMult = 1.5,
    wretchedHPMult = 1.4,
    hitboxMult = Vector(2,1),
}

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    local hpMult = (npc.Variant == 1 and bal.wretchedHPMult or bal.widowHPMult)
    npc.MaxHitPoints = npc.MaxHitPoints * hpMult
    npc.HitPoints = npc.MaxHitPoints
    npc.SizeMulti = bal.hitboxMult
end, EntityType.ENTITY_WIDOW)