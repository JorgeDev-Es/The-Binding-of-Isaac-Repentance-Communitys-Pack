
local Mod = RepMMod

local function onUseNumbHeart(_, collectible, thisRng, player, useflags, activeslot, customvardata)
	CustomHealthAPI.Library.AddHealth(player, "HEART_ICE", 2, true)
	SFXManager():Play(SoundEffect.SOUND_FREEZE, 1, 0, false, 1.0)
	return {
		Discharge = true,
		Remove = false,
		ShowAnim = true,
	}
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, onUseNumbHeart, Mod.RepmTypes.COLLECTIBLE_NUMB_HEART)