local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local FAMILIAR_CAP = 10
local FOLLOW_PRIORITY = -100 -- I want them to be at the end of the chain all the time
local DAMAGE_MULT = 1.43 -- Results in 5 damage

mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, function(_, player)
	local itemNum = player:GetCollectibleNum(mod.Collectible.DIRGE_BELL)
	local ghostNum = Isaac.CountEntities(player, EntityType.ENTITY_FAMILIAR, mod.Familiar.BELL_GHOST)
	local targetNum = math.min(itemNum, FAMILIAR_CAP - ghostNum)
	
	if targetNum > 0 then
		for _ = 1, targetNum do	mod.AddBellGhostFamiliar(player) end
		sfx:Play(mod.Sound.SERVANT_BELL)
	end
end)

--------------------
-- << FAMILIAR >> --
--------------------
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	fam.SplatColor = Color(1, 1, 1, 1, 0.6, 0.6, 0.6, 1, 1, 1, 1)
	fam.Color = Color(1, 1, 1, 0)
	fam:AddToFollowers()
end, mod.Familiar.BELL_GHOST)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local famColor = Color(1, 1, 1, 0.75, 0.1, 0.1, 0.1)
	
	if fam.HitPoints <= 1 then
		famColor = Color(0.75, 0.75, 0.75, 0.75, 0.1, 0.1, 0.1)
		fam.SpriteScale = fam.SpriteScale * 0.85
	end
	fam.Color = Color.Lerp(fam.Color, famColor, 0.2)
	fam:FollowParent()
	fam:Shoot()
end, mod.Familiar.BELL_GHOST)

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, function(_, tear)
	if not tear:HasTearFlags(TearFlags.TEAR_HOMING) then -- Cannot find a better way
		tear.Color = Color(1, 1, 1, 0.5, 0.1, 0.1, 0.1, 1, 1, 1, 1)
	end
	tear.CollisionDamage = tear.CollisionDamage * DAMAGE_MULT
	tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
end, mod.Familiar.BELL_GHOST)

mod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, function(_, fam)
	return FOLLOW_PRIORITY
end, mod.Familiar.BELL_GHOST)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown)
	if entity and entity.Variant == mod.Familiar.BELL_GHOST then return {Damage = 1} end
end, EntityType.ENTITY_FAMILIAR)