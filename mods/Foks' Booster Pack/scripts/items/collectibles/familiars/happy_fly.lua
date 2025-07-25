local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local SPEED = 0.3
local MAX_SPEED = 9
local POSITION_INTERVAL = 60 -- 2 seconds
local CHARM_DURATION = 36 -- 1.2 seconds

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	local itemConfig = Isaac.GetItemConfig():GetCollectible(mod.Collectible.HAPPY_FLY)
	local itemNum = mod.GetExpectedFamiliarNum(player, mod.Collectible.HAPPY_FLY)
	local itemRNG = player:GetCollectibleRNG(mod.Collectible.HAPPY_FLY)

	player:CheckFamiliar(mod.Familiar.HAPPY_FLY, itemNum, itemRNG, itemConfig)
end, CacheFlag.CACHE_FAMILIARS)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local famPos = game:GetRoom():GetClampedPosition(fam.Position, 0)
	local famPush = (famPos - fam.Position):Normalized() -- Pushes the familiar away from walls
	local famSeek = (fam.TargetPosition - fam.Position):Resized(SPEED) -- Slowly moves towards the target position
	
	fam:AddVelocity(famPush + famSeek)
	
	if fam.Velocity:Length() > MAX_SPEED then fam.Velocity = fam.Velocity:Resized(MAX_SPEED) end
	if fam:IsFrame(POSITION_INTERVAL, 0) then fam.TargetPosition = Isaac.GetRandomPosition() end
end, mod.Familiar.HAPPY_FLY)

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function(_, fam, collider)
	local player = collider:ToPlayer()
	if not player then return end
	local charmDuration = CHARM_DURATION * fam:GetMultiplier()
	
	if not player:HasEntityFlags(EntityFlag.FLAG_CHARM) then
		sfx:Play(SoundEffect.SOUND_KISS_LIPS1, nil, nil, nil, 1.5)
	end
	player:AddCharmed(EntityRef(fam), charmDuration)
	player:SetMinDamageCooldown(charmDuration * 2) -- double duration due to this function working at 60 fps instead of 30 fps
	player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
end, mod.Familiar.HAPPY_FLY)

-----------------
-- << DEBUG >> --
-----------------
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, fam, offset)
	if game:GetDebugFlags() & DebugFlag.ENTITY_POSITIONS > 0 then
		local startPos = Isaac.GetRenderPosition(fam.Position)
		local endPos = Isaac.GetRenderPosition(fam.TargetPosition)
		
		Isaac.DrawLine(startPos + offset, endPos + offset, KColor.Magenta, KColor.Magenta)
	end
end, mod.Familiar.HAPPY_FLY)