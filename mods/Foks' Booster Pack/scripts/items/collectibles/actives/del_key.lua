local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local DAMAGE = 1
local GLITCH_INTERVAL = 9

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, flag, slot, data)
	game:SetColorModifier(ColorModifier(2, -0.25, 0, 0.25, 0, 1), true, 0.1)
	game:GetRoom():GetEffects():AddCollectibleEffect(collectible)
	sfx:Play(mod.Sound.GLITCH)
	
	return {ShowAnim = true, Remove = true}
end, mod.Collectible.DEL_KEY)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if mod.IsActiveVulnerableEnemy(npc) and npc:IsFrame(GLITCH_INTERVAL // 3, 0) then
		if game:GetRoom():GetEffects():HasCollectibleEffect(mod.Collectible.DEL_KEY) or mod.GetEntityData(npc).TookDamageFromDelKeyWisp then
			npc:TakeDamage(DAMAGE, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(nil), 0)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
	if mod.IsActiveVulnerableEnemy(npc) and npc:IsFrame(GLITCH_INTERVAL, 0) then
		if game:GetRoom():GetEffects():HasCollectibleEffect(mod.Collectible.DEL_KEY) or mod.GetEntityData(npc).TookDamageFromDelKeyWisp then
			for _, layer in pairs(npc:GetSprite():GetAllLayers()) do
				layer:SetCropOffset(RandomVector():Resized(mod.RandomFloatRange(2, 20)))
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown) -- Book of Virtues synergy
	local fam = entity:ToFamiliar()
	
	if fam and fam.Variant == FamiliarVariant.WISP and fam.SubType == mod.Collectible.DEL_KEY then
		local sourceEnt = source and source.Entity
		
		if sourceEnt and sourceEnt:ToNPC() and mod.IsActiveVulnerableEnemy(sourceEnt) then
			mod.GetEntityData(sourceEnt).TookDamageFromDelKeyWisp = true
			sourceEnt.Color = Color(1.5, -0.25, 0.5)
		end
	end
end, EntityType.ENTITY_FAMILIAR)