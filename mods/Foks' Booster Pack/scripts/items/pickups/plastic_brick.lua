local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local DAMAGE = 2

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if pickup:GetSprite():IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_SCAMPER, nil, nil, nil, 1.2)
	end
end, mod.Pickup.PLASTIC_BRICK)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local player = collider:ToPlayer()
	
	if player and player:CanPickupItem() and not player:IsHoldingItem() then
		player:TakeDamage(DAMAGE, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
		
		pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		pickup:GetSprite():Play("Collect", true)
		pickup:Die()
		
		return true
	end
end, mod.Pickup.PLASTIC_BRICK)