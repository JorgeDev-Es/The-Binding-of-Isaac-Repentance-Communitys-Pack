local Mod = RepMMod
local SaveManager = Mod.saveManager

local function useBatteredLighter(_, collectibletype, rng, player, useflags, slot, vardata)
	local fireplaces = Isaac.FindInRadius(player.Position, 150)
	local fireplacesTotal = Isaac.FindByType(33)
	local pdata = Mod:RunSave(player)
	SFXManager():Play(Mod.RepmTypes.SFX_LIGHTER)
	for i, place in ipairs(fireplacesTotal) do
		if place.Position:Distance(player.Position) < 100 then
			local pos = place.Position
			place:Remove()
			Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 2, 0, pos, Vector.Zero, nil)
			if pdata.TFrosty_FreezeTimer <= 250 then
				pdata.TFrosty_FreezeTimer = pdata.TFrosty_FreezeTimer + 1500
			elseif pdata.TFrosty_FreezeTimer <= 500 then
				pdata.TFrosty_FreezeTimer = pdata.TFrosty_FreezeTimer + 1000
			elseif pdata.TFrosty_FreezeTimer <= 1000 then
				pdata.TFrosty_FreezeTimer = pdata.TFrosty_FreezeTimer + 500
			else
				pdata.TFrosty_FreezeTimer = pdata.TFrosty_FreezeTimer + 250
			end
			SFXManager():Play(SoundEffect.SOUND_CANDLE_LIGHT)
			break
		end
	end

	return {
		Discharge = true,
		Remove = false,
		ShowAnim = true,
	}
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, useBatteredLighter, Mod.RepmTypes.COLLECTIBLE_BATTERED_LIGHTER)