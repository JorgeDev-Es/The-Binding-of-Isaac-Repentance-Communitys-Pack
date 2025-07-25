local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function(_, player, collider)
	local trinketMult = player:GetTrinketMultiplier(mod.Trinket.DEVILS_TONGUE)
	
	if trinketMult > 0 and collider and mod.IsActiveVulnerableEnemy(collider) then
		if not collider:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
			collider:SetBossStatusEffectCooldown(0)
			collider:AddBurn(EntityRef(player), 60, 0)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown)
	local player = entity:ToPlayer()
	
	if player and player:GetTrinketMultiplier(mod.Trinket.DEVILS_TONGUE) > 1 then
		if flag & DamageFlag.DAMAGE_FIRE > 0 then return false end
	end
end, EntityType.ENTITY_PLAYER)