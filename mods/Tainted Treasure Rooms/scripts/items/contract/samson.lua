local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local sprite = familiar:GetSprite()
	local data = familiar:GetData()
	
	if sprite:IsPlaying("Stab") and sprite:GetFrame() < 30 then
		familiar.Velocity = mod:Lerp(familiar.Velocity, (player.Position - familiar.Position), 0.5)
	else
		familiar:FollowParent()
	end
	
	if sprite:IsFinished("Stab") then
		sprite:Play("Idle")
		familiar.DepthOffset = 0
	end
	
	if sprite:IsEventTriggered("Hit") then
		player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(familiar), 0)
		sfx:Play(SoundEffect.SOUND_KNIFE_PULL, 1, 2, false, 2)
	end
end, TaintedFamiliars.STIMS)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar:AddToFollowers()
end, TaintedFamiliars.STIMS)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if game:GetRoom():IsFirstVisit() and not game:GetRoom():IsClear() then
		for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, TaintedFamiliars.STIMS)) do
			if mod:RandomInt(1, 2) == 1 then
				entity:GetSprite():Play("Stab")
				entity.DepthOffset = 100
			end
		end
	end
end)