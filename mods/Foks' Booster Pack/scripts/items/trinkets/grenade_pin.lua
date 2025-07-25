local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local EXPLOSION_COUNTDOWN = 10 -- ~0.33 seconds

local function delayOtherBombs(bomb)
	for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
		local bomb2 = entity:ToBomb()
		
		if bomb2 and bomb2.SpawnerType == EntityType.ENTITY_PLAYER and GetPtrHash(bomb) ~= GetPtrHash(bomb2) then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 1, bomb2.Position, Vector.Zero, nil)
			bomb2:SetExplosionCountdown(bomb:GetExplosionCountdown())
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, function(_, player, bomb)
	if player:GetTrinketMultiplier(mod.Trinket.GRENADE_PIN) > 0 then
		bomb:SetExplosionCountdown(bomb:GetExplosionCountdown() + EXPLOSION_COUNTDOWN)
		delayOtherBombs(bomb)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, function(_, bomb)
	local player = mod.GetPlayerFromEntity(bomb)
	if not player then return end
	
	if player:GetTrinketMultiplier(mod.Trinket.GRENADE_PIN) > 0 then
		bomb:SetExplosionCountdown(bomb:GetExplosionCountdown() + EXPLOSION_COUNTDOWN)
		delayOtherBombs(bomb)
	end
end)