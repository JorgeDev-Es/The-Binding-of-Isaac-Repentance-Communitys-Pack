local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local FIRERATE = 60 -- 2 seconds
local DISTANCE = 160 -- Distance for targeting enemies

local BEAM_DELAY = 3 -- Delay between individual beams
local BEAM_AMOUNT = 3
local BEAM_OFFSET = {20, 60}

local BLINK_FREQUENCY = 30 -- 1 second

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	local itemConfig = Isaac.GetItemConfig():GetCollectible(mod.Collectible.ASHERAH_POLE)
	local itemNum = math.min(mod.GetExpectedFamiliarNum(player, mod.Collectible.ASHERAH_POLE), 1)
	local itemRNG = player:GetCollectibleRNG(mod.Collectible.ASHERAH_POLE)
	
	player:CheckFamiliar(mod.Familiar.ASHERAH_POLE, itemNum, itemRNG, itemConfig)
end, CacheFlag.CACHE_FAMILIARS)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	fam:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	fam.TargetPosition = fam.Player.Position
end, mod.Familiar.ASHERAH_POLE)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local famSpr = fam:GetSprite()
	local room = game:GetRoom()
	local target = fam.Target
	
	if famSpr:IsEventTriggered("Creak") then sfx:Play(mod.Sound.WOOD_CREAK) end
	if famSpr:IsFinished("Appear") or famSpr:IsFinished("Close") then famSpr:Play("Idle") end
	
	if not target then
		if famSpr:IsFinished("Bless") then famSpr:Play("Close") end
	else
		if famSpr:IsPlaying("Wait") then famSpr:Play("Appear") end
		if famSpr:IsPlaying("Idle") then famSpr:Play("Bless") end
		if famSpr:IsFinished("Bless") and fam.FireCooldown <= 0 then
			local targetPos = mod.GetPredictedTargetPos(fam, target, 0.05) -- Until the original is fixed use this custom function
			
			Isaac.CreateTimer(function()
				local posOffset = RandomVector() * mod.RandomIntRange(BEAM_OFFSET[1], BEAM_OFFSET[2])
				local pos = room:GetClampedPosition(targetPos + posOffset, 0)
				
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, pos, Vector.Zero, fam)
			end, BEAM_DELAY, math.floor(BEAM_AMOUNT * fam:GetMultiplier()))
			
			fam.FireCooldown = mod.GetModifiedFireRate(fam, FIRERATE)
		end
		if target:IsFrame(BLINK_FREQUENCY, 0) then
			local color = target.Color
			
			color:SetOffset(0.5, 0.5, 0.5)
			color:SetColorize(1, 1, 1, 0.1)
			target:SetColor(color, BLINK_FREQUENCY // 2, -1, true, true)
		end
	end
	if room:GetFrameCount() == 0 then -- New room trigger
		fam.TargetPosition = room:FindFreePickupSpawnPosition(Isaac.GetRandomPosition())
		famSpr:Play("Wait")
	end
	if fam:IsFrame(3, 0) then fam:UpdateDirtColor() end -- This function is quite expensive
	fam.FireCooldown = math.max(fam.FireCooldown - 1, 0)
	fam:PickEnemyTarget(DISTANCE, nil, 1 << 1 | 1 << 2) -- No enums :(
	fam.Position = fam.TargetPosition
end, mod.Familiar.ASHERAH_POLE)