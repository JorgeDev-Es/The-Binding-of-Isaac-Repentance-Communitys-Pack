local Mod = RepMMod
local sfx = SFXManager()
local SaveManager = Mod.saveManager

local function useHolyLighter(_, collectibletype, rng, player, useflags, slot, vardata)
	local pdata = Mod:RunSave(player)
	sfx:Play(Mod.RepmTypes.SFX_LIGHTER)
	sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT)
	local Effect =
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 0, player.Position, Vector(0, 0), player)
			:ToEffect()
	Effect:SetDamageSource(EntityType.ENTITY_PLAYER)
	Effect:SetTimeout(300)
	local wisps = Mod.Filter(
		Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, Mod.RepmTypes.COLLECTIBLE_HOLY_LIGHTER),
		function(_, wisp)
			return GetPtrHash(wisp:ToFamiliar().Player) == GetPtrHash(player)
		end
	)
	if #wisps >= 8 then
		for _, wisp in ipairs(wisps) do
			wisp:Remove()
		end
		pdata.TFrosty_FreezeTimer = 3000
		player:ChangePlayerType(Mod.RepmTypes.CHARACTER_FROSTY_B)
		player:SetPocketActiveItem(Mod.RepmTypes.COLLECTIBLE_BATTERED_LIGHTER, ActiveSlot.SLOT_POCKET, false)
		if not (game:GetRoom():IsMirrorWorld() or StageAPI and StageAPI.IsMirrorDimension()) then
			player:GetEffects():RemoveNullEffect(NullItemID.ID_LOST_CURSE, -1)
		end
	elseif #wisps <= 3 then
		player:AddWisp(Mod.RepmTypes.COLLECTIBLE_HOLY_LIGHTER, player.Position, true, false)
	end
	return {
		Discharge = true,
		Remove = false,
		ShowAnim = true,
	}
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, useHolyLighter, Mod.RepmTypes.COLLECTIBLE_HOLY_LIGHTER)
