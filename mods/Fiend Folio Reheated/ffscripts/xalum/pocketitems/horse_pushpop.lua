local mod = FiendFolio
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, useFlags)
	player:AddBrokenHearts(-1)
	sfx:Play(SoundEffect.SOUND_VAMP_GULP)
	FiendFolio:trySayAnnouncerLine(mod.Sounds.VAObjectHorsePushPop, useFlags, 30)
end, mod.ITEM.CARD.HORSE_PUSHPOP)