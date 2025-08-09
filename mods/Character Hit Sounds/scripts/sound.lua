return {
	HIT = {
		["Default"] = SoundEffect.SOUND_NULL,
		["Isaac"] = SoundEffect.SOUND_ISAAC_HURT_GRUNT,
		["Magdalene"] = Isaac.GetSoundIdByName("hit_magdalene"),
		["Blue"] = Isaac.GetSoundIdByName("hit_blue"),
		["Blue v2"] = Isaac.GetSoundIdByName("hit_blue_v2"),
		["Bone"] = Isaac.GetSoundIdByName("hit_bone"),
		["Ghost"] = Isaac.GetSoundIdByName("hit_ghost"),
		["Stone"] = Isaac.GetSoundIdByName("hit_stone"),
		["Demon"] = Isaac.GetSoundIdByName("hit_demon")
	},
	DEATH = {
		["Default"] = SoundEffect.SOUND_NULL,
		["Isaac"] = SoundEffect.SOUND_ISAACDIES,
		["Magdalene"] = Isaac.GetSoundIdByName("death_magdalene"),
		["Blue"] = Isaac.GetSoundIdByName("death_blue"),
		["Blue v2"] = Isaac.GetSoundIdByName("death_blue_v2"),
		["Bone"] = Isaac.GetSoundIdByName("death_bone"),
		["Ghost"] = Isaac.GetSoundIdByName("death_ghost"),
		["Stone"] = Isaac.GetSoundIdByName("death_stone"),
		["Demon"] = Isaac.GetSoundIdByName("death_demon")
	}
}
