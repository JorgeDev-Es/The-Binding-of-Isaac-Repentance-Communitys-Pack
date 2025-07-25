local Mod = RepMMod

---@param Player EntityPlayer
---@param RNG RNG
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, RNG, Player)
	local Flags = (1 << 29) + (1 << 8) + (1 << 37) + (1 << 59) + (1 << 19)
	if RNG:RandomInt(2) == 1 then
		for _ = 1, 2 do
			Isaac.Spawn(
				EntityType.ENTITY_BONY,
				0,
				0,
				Player.Position + Vector(0, 5):Rotated(RNG:RandomInt(360)),
				Vector(0, 0),
				Player
			)
				:ToNPC()
				:AddEntityFlags(Flags)
		end
	else
		for _ = 1, 2 do
			Isaac.Spawn(
				EntityType.ENTITY_BOOMFLY,
				4,
				0,
				Player.Position + Vector(0, 5):Rotated(RNG:RandomInt(360)),
				Vector(0, 0),
				Player
			)
				:ToNPC()
				:AddEntityFlags(Flags)
		end
	end
	if RNG:RandomFloat() <= 0.08 then
		Player:AddBoneHearts(1)
	end
	SFXManager():Play(8)
	return {
		Discharge = true,
		Remove = false,
		ShowAnim = true,
	}
end, Mod.RepmTypes.COLLECTIBLE_BOOK_OF_NECROMANCER)