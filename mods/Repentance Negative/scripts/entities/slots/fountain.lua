local Mod = RepMMod
local sfx = SFXManager()
local SaveManager = Mod.saveManager
----------------------------------------------------------
--FOUNTAIN
----------------------------------------------------------

local conditionSlot = {}
local tempConditionSlot = {}

local function AddCondition(funcCond, funcDo)
	table.insert(conditionSlot, { Condition = funcCond, Function = funcDo })
end

local function AddTempCondition(slot, funcCond, funcDo)
	local data = Mod:GetData(slot)
	data.TempCondSlot = {}
	table.insert(data.TempCondSlot, { Condition = funcCond, Function = funcDo })
end

AddCondition(function(slot)
	return slot:GetState() == 2
end, function(slot)
	---@cast slot EntitySlot
	local sprite = slot:GetSprite()
	if sprite:IsOverlayFinished("PrizeOverlay") then
		if not sprite:IsPlaying("Idle") then
			sprite:Play("Idle", false)
		end
		slot:SetState(1)
	end
	if sprite:IsFinished("Wiggle") then
		sprite:Play("Idle", true)
		sprite:PlayOverlay("PrizeOverlay", true)
	end
	if sprite:IsOverlayFinished("PayCoin") and not sprite:IsPlaying("Wiggle") then
		sprite:Play("Wiggle", true)
	end
end)

AddCondition(function(slot)
	return slot:GetState() == 3
end, function(slot)
	local sprite = slot:GetSprite()
	if sprite:IsFinished("Death") then
		sprite:Play("Broken", true)
	end
end)

---@param slot EntitySlot
local function FountainInit(_, slot)
	slot:SetState(1)
end
Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, FountainInit, Mod.RepmTypes.SLOT_FOUNTAIN)

---@param slot EntitySlot
local function FountainUpdate(_, slot)
	for i, cond in ipairs(conditionSlot) do
		if cond.Condition(slot) then
			cond.Function(slot)
		end
	end
	local data = Mod:GetData(slot)
	data.TempCondSlot = data.TempCondSlot or {}
	for i, cond in ripairs(data.TempCondSlot) do
		if cond.Condition(slot) then
			cond.Function(slot)
			table.remove(data.TempCondSlot, i)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, FountainUpdate, Mod.RepmTypes.SLOT_FOUNTAIN)

local function FountainSoundUpdate()
	local nearestFountainDist
	local doPlay = false
	for i, fountain in ipairs(Isaac.FindByType(6, Mod.RepmTypes.SLOT_FOUNTAIN)) do
		---@diagnostic disable-next-line
		fountain = fountain:ToSlot()
		---@cast fountain EntitySlot
		if fountain:GetState() ~= 3 then
			doPlay = true
			local dist = 9999
			for _, player in ipairs(Isaac.FindInRadius(fountain.Position, 100, EntityPartition.PLAYER)) do
				if fountain.Position:Distance(player.Position) < dist then
					dist = fountain.Position:Distance(player.Position)
				end
			end
			if not nearestFountainDist or dist < nearestFountainDist then
				nearestFountainDist = dist
			end
		end
	end
	if doPlay then
		if not sfx:IsPlaying(Mod.RepmTypes.SFX_FOUNTAIN) then
			sfx:Play(Mod.RepmTypes.SFX_FOUNTAIN, 1, 0, true)
		end
		sfx:AdjustVolume(Mod.RepmTypes.SFX_FOUNTAIN, math.min(1, math.max(0, 1.15 - nearestFountainDist / 100)))
	elseif sfx:IsPlaying(Mod.RepmTypes.SFX_FOUNTAIN) then
		sfx:Stop(Mod.RepmTypes.SFX_FOUNTAIN)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_RENDER, FountainSoundUpdate)

---@param fount EntitySlot
---@param ent Entity
local function donationFount(_, fount, ent)
	if fount:GetState() == 1 and fount:GetSprite():IsPlaying("Idle") then
		if ent and ent:ToPlayer() then
			local player = ent:ToPlayer()
			if player:GetNumCoins() > 4 then
				player:AddCoins(-5)
				SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1.0, 0, false, 1.0)
				fount:SetState(2)
				local sprite = fount:GetSprite()
				sprite:PlayOverlay("PayCoin", true)
				AddTempCondition(fount, function(slot)
					return slot:GetState() == 2 and slot:GetSprite():WasOverlayEventTriggered("Prize")
				end, function(slot, ...)
					---@cast slot EntitySlot
					local weight = WeightedOutcomePicker()
					weight:AddOutcomeWeight(1, 85)
					weight:AddOutcomeWeight(2, 10)
					weight:AddOutcomeWeight(3, 5)
					weight:AddOutcomeWeight(4, 15)

					local out = weight:PickOutcome(slot:GetDropRNG())
					local outs = {
						[1] = function()
							local pdata = Mod:RunSave(player)
							pdata.repMBonusLuck = (pdata.repMBonusLuck or 0) + 0.5
							player:AddCacheFlags(CacheFlag.CACHE_LUCK, true)
							player:AnimateHappy()
							sfx:Play(SoundEffect.SOUND_THUMBSUP, 2)
						end,
						[2] = function() 
							local pdata = Mod:RunSave(player)
							pdata.repMBonusDamage = (pdata.repMBonusDamage or 0) + 0.5
							player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
							player:AnimateHappy()
							sfx:Play(SoundEffect.SOUND_THUMBSUP, 2)
						end,
						[3] = function()
							Isaac.Spawn(
								EntityType.ENTITY_PICKUP,
								PickupVariant.PICKUP_TAROTCARD,
								Card.CARD_SUN,
								slot.Position,
								EntityPickup.GetRandomPickupVelocity(slot.Position, slot:GetDropRNG(), 1),
								nil
							)
							sfx:Play(SoundEffect.SOUND_LUCKYPICKUP, 1.0, 0, false, 1.0)
						end,
						[4] = function()
							slot:SetState(3)
							Isaac.Explode(slot.Position, slot, 0)
							slot:CreateDropsFromExplosion()
							slot:GetSprite():Play("Death", true)
							slot:GetSprite():StopOverlay()
						end,
					}
					outs[out]()
				end)
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, donationFount, Mod.RepmTypes.SLOT_FOUNTAIN)

local function updateCache_Fountain(_, player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + (Mod:RunSave(player).repMBonusDamage or 0)
	elseif cacheFlag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + (Mod:RunSave(player).repMBonusLuck or 0)
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, updateCache_Fountain)

local function spawnFountBehavior(_, confess)
	local rng = confess:GetDropRNG()
	if rng:RandomInt(100) + 1 <= 50 then
		local pos = confess.Position
		confess:Remove()
		local fountain = Isaac.Spawn(6, Mod.RepmTypes.SLOT_FOUNTAIN, 0, pos, Vector.Zero, nil)
		fountain:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
end
Mod:AddCallback("REPM_SLOT_INIT_FIRST", spawnFountBehavior, SlotVariant.CONFESSIONAL)