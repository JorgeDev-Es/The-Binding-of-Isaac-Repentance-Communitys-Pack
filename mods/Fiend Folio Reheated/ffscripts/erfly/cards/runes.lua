local mod = FiendFolio

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, flags)
    player:UsePill(PillEffect.PILLEFFECT_AMNESIA, 1, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    mod:trySayAnnouncerLine(mod.Sounds.VARuneAnsus, flags, 20)
end, Card.RUNE_ANSUS)