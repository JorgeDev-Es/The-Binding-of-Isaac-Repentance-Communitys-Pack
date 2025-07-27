local mod = FiendFolio

function mod:calculateRedAvailableForHealing(player, heartKey)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
		if player:CanPickRedHearts() then
			local bloodChargeToMax = 99 - player:GetBloodCharge()
			return bloodChargeToMax, 0
		end
		
		return 0, 0
	elseif player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
		player = player:GetSubPlayer()
		if player == nil then
			return 0, 0
		end
	end
	
	if CustomHealthAPI.Library.CanPickKey(player, heartKey) then
		local hpData = player:GetData().CustomHealthAPISavedata
		if hpData ~= nil then
			local redMasks = hpData.RedHealthMasks
			local addPriorityOfRed = CustomHealthAPI.PersistentData.HealthDefinitions[heartKey].AddPriority
			local heartsToOverwrite = 0
			local customMissingRed = 0
			for i = 1, #redMasks do
				local mask = redMasks[i]
				for j = 1, #mask do
					local health = mask[j]
					if health.Key ~= heartKey and
					   addPriorityOfRed >= CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].AddPriority
					then
						heartsToOverwrite = heartsToOverwrite + 1
					else
						local maxHP = CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].MaxHP
						customMissingRed = customMissingRed + (maxHP - health.HP)
					end
				end
			end
			
			local customUnoccupiedRedCapacity = CustomHealthAPI.Helper.GetAmountUnoccupiedContainers(player) * math.max(2, CustomHealthAPI.PersistentData.HealthDefinitions[heartKey].MaxHP)
			local customRedToFullHealth = customMissingRed + customUnoccupiedRedCapacity
			
			return customRedToFullHealth, heartsToOverwrite
		end
	end
	
	return 0, 0
end

function mod:calculateSoulAvailableForHealing(player, heartKey)
	local playerType = player:GetPlayerType()
	if playerType == PlayerType.PLAYER_BETHANY then
		if player:CanPickSoulHearts() then
			local heartsSpentReactivatingShackles = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
	
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			local soulChargeToMax = 99 - player:GetSoulCharge()
			return soulChargeToMax + alabasterChargesToAdd, heartsSpentReactivatingShackles
		end
		
		return 0, 0
	elseif playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or 
	       playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B
	then
		local heartsSpentReactivatingShackles = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
		
		local alabasterChargesToAdd = 0
		for i = 0, 2 do
			if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
				alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
			end
		end
		
		return alabasterChargesToAdd, heartsSpentReactivatingShackles
	elseif playerType == PlayerType.PLAYER_THEFORGOTTEN then
		if player:GetSubPlayer() == nil then
			local heartsSpentReactivatingShackles = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
			
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			return alabasterChargesToAdd, heartsSpentReactivatingShackles
		end
		player = player:GetSubPlayer()
	end
	
	if CustomHealthAPI.Library.CanPickKey(player, heartKey) then
		local hpData = player:GetData().CustomHealthAPISavedata
		if hpData ~= nil then
			local heartsSpentReactivatingShackles = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
	
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			local otherMasks = hpData.OtherHealthMasks
			local addPriorityOfSoul = CustomHealthAPI.PersistentData.HealthDefinitions[heartKey].AddPriority
			local heartsToOverwrite = 0
			local customMissingSoul = 0
			for i = 1, #otherMasks do
				local mask = otherMasks[i]
				for j = 1, #mask do
					local health = mask[j]
					if CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.SOUL then
						if health.Key ~= heartKey and
						   addPriorityOfSoul >= CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].AddPriority
						then
							heartsToOverwrite = heartsToOverwrite + 1
						else
							local maxHP = CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].MaxHP
							customMissingSoul = customMissingSoul + (maxHP - health.HP)
						end
					end
				end
			end
			
			local customUnoccupiedSoulCapacity = CustomHealthAPI.Helper.GetRoomForOtherKeys(player) * math.max(2, CustomHealthAPI.PersistentData.HealthDefinitions[heartKey].MaxHP)
			local customSoulToFullHealth = customMissingSoul + customUnoccupiedSoulCapacity
			
			return customSoulToFullHealth + alabasterChargesToAdd, heartsToOverwrite + heartsSpentReactivatingShackles
		end
	end
	
	return 0, 0
end

function FiendFolio.HandleOddlySmoothHeartCollision(pickup, opp, alreadyDealtSpikesDamage)
	local dealtSpikesDamage = false

	if opp:ToPlayer() then
		local player = opp:ToPlayer()

		if player:HasTrinket(FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE) then
			if pickup.Price > player:GetNumCoins() then
				return nil, dealtSpikesDamage
			elseif pickup.Price == PickupPrice.PRICE_SPIKES and not alreadyDealtSpikesDamage then
				local tookDamage = player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				dealtSpikesDamage = true
				
				if not tookDamage then
					return nil, dealtSpikesDamage
				end
			end
			
			local mult = math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE))
			
			if player:CanPickRedHearts() and 
			   pickup.Variant == PickupVariant.PICKUP_HEART and
			   (pickup.SubType == HeartSubType.HEART_FULL or 
			    pickup.SubType == HeartSubType.HEART_HALF or 
			    pickup.SubType == HeartSubType.HEART_DOUBLEPACK or 
			    pickup.SubType == HeartSubType.HEART_SCARED)
			then
				local hpToAddFromPickup = 1
				if pickup.SubType == HeartSubType.HEART_FULL then
					hpToAddFromPickup = 2
				elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
					hpToAddFromPickup = 4
				elseif pickup.SubType == HeartSubType.HEART_SCARED then
					hpToAddFromPickup = 2
				end
				
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
					hpToAddFromPickup = hpToAddFromPickup * 2
				end
				
				local redToHeal, heartsToOverwrite = mod:calculateRedAvailableForHealing(player, "RED_HEART")
				while heartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					heartsToOverwrite = math.max(heartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				redToHeal = math.max(redToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				mult = math.min(mult, redToHeal + heartsToOverwrite * 2)
				if mult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "RED_HEART", mult, true) -- using this so as to ignore tainted maggie hp healing doubling
				end
			elseif player:CanPickRottenHearts() and 
			       pickup.Variant == PickupVariant.PICKUP_HEART and
			       pickup.SubType == HeartSubType.HEART_ROTTEN
			then
				local hpToAddFromPickup = 2
				
				local redToHeal, heartsToOverwrite = mod:calculateRedAvailableForHealing(player, "ROTTEN_HEART")
				while heartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					heartsToOverwrite = math.max(heartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				redToHeal = math.max(redToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				mult = math.ceil(math.min(mult, redToHeal + heartsToOverwrite * 2) / 2) * 2
				if mult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "ROTTEN_HEART", mult, true) -- using this so as to ignore tainted maggie hp healing doubling
				end
			elseif CustomHealthAPI.Library.CanPickKey(player, "MORBID_HEART") and 
			       (pickup.Variant == FiendFolio.PICKUP.VARIANT.MORBID_HEART or
			        pickup.Variant == FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART or
			        pickup.Variant == FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART)
			then
				local hpToAddFromPickup = 1
				if pickup.Variant == FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART then
					hpToAddFromPickup = 2
				elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.MORBID_HEART then
					hpToAddFromPickup = 3
				end
				
				local redToHeal, heartsToOverwrite = mod:calculateRedAvailableForHealing(player, "MORBID_HEART")
				while heartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					heartsToOverwrite = math.max(heartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 3, 0)
				end
				redToHeal = math.max(redToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				mult = math.min(mult, redToHeal + heartsToOverwrite * 3)
				if mult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "MORBID_HEART", mult, true) -- using this so as to ignore tainted maggie hp healing doubling
				end
			elseif player:CanPickSoulHearts() and 
			       pickup.Variant == PickupVariant.PICKUP_HEART and
			       (pickup.SubType == HeartSubType.HEART_SOUL or 
			        pickup.SubType == HeartSubType.HEART_HALF_SOUL)
			then
				local hpToAddFromPickup = 1
				if pickup.SubType == HeartSubType.HEART_SOUL then
					hpToAddFromPickup = 2
				end
				
				local soulToHeal, heartsToOverwrite = mod:calculateSoulAvailableForHealing(player, "SOUL_HEART")
				while heartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					heartsToOverwrite = math.max(heartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				soulToHeal = math.max(soulToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				mult = math.min(mult, soulToHeal + heartsToOverwrite * 2)
				if mult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "SOUL_HEART", mult, true)
				end
			elseif player:CanPickBlackHearts() and 
			       (pickup.Variant == PickupVariant.PICKUP_HEART and
			        pickup.SubType == HeartSubType.HEART_BLACK) or
			       pickup.Variant == FiendFolio.PICKUP.VARIANT.HALF_BLACK_HEART
			then
				local hpToAddFromPickup = 1
				if pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_BLACK then
					hpToAddFromPickup = 2
				end
				
				local soulToHeal, heartsToOverwrite = mod:calculateSoulAvailableForHealing(player, "BLACK_HEART")
				while heartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					heartsToOverwrite = math.max(heartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				soulToHeal = math.max(soulToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				mult = math.min(mult, soulToHeal + heartsToOverwrite * 2)
				if mult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "BLACK_HEART", mult, true)
				end
			elseif CustomHealthAPI.Library.CanPickKey(player, "IMMORAL_HEART") and 
			       (pickup.Variant == FiendFolio.PICKUP.VARIANT.IMMORAL_HEART or
			        pickup.Variant == FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART)
			then
				if pickup.SubType ~= 1 then
					local hpToAddFromPickup = 1
					if pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_BLACK then
						hpToAddFromPickup = 2
					end
					
					local soulToHeal, heartsToOverwrite = mod:calculateSoulAvailableForHealing(player, "IMMORAL_HEART")
					while heartsToOverwrite > 0 and hpToAddFromPickup > 0 do
						heartsToOverwrite = math.max(heartsToOverwrite - 1, 0)
						hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
					end
					soulToHeal = math.max(soulToHeal - hpToAddFromPickup, 0)
					hpToAddFromPickup = 0
					
					mult = math.min(mult, soulToHeal + heartsToOverwrite * 2)
					if mult > 0 then
						CustomHealthAPI.Library.AddHealth(player, "IMMORAL_HEART", mult, true)
					end
				end
			elseif (player:CanPickRedHearts() or player:CanPickSoulHearts()) and 
			       pickup.Variant == PickupVariant.PICKUP_HEART and
			       pickup.SubType == HeartSubType.HEART_BLENDED
			then
				local hpToAddFromPickup = 2
				
				local soulToHeal, soulHeartsToOverwrite = mod:calculateSoulAvailableForHealing(player, "SOUL_HEART")
				while soulHeartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					soulHeartsToOverwrite = math.max(soulHeartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				soulToHeal = math.max(soulToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
					hpToAddFromPickup = hpToAddFromPickup * 2
				end
				
				local redToHeal, redHeartsToOverwrite = mod:calculateRedAvailableForHealing(player, "RED_HEART")
				while redHeartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					redHeartsToOverwrite = math.max(redHeartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				redToHeal = math.max(redToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				local redMult = math.min(mult, redToHeal + redHeartsToOverwrite * 2)
				if redMult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "RED_HEART", redMult, true) -- using this so as to ignore tainted maggie hp healing doubling
				end
				
				local soulMult = math.min(math.max(mult - redMult, 0), soulToHeal + soulHeartsToOverwrite * 2)
				if soulMult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "SOUL_HEART", soulMult, true)
				end
			elseif (player:CanPickRedHearts() or player:CanPickBlackHearts()) and 
			       pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART
			then
				local hpToAddFromPickup = 2
				
				local soulToHeal, soulHeartsToOverwrite = mod:calculateSoulAvailableForHealing(player, "BLACK_HEART")
				while soulHeartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					soulHeartsToOverwrite = math.max(soulHeartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				soulToHeal = math.max(soulToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
					hpToAddFromPickup = hpToAddFromPickup * 2
				end
				
				local redToHeal, redHeartsToOverwrite = mod:calculateRedAvailableForHealing(player, "RED_HEART")
				while redHeartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					redHeartsToOverwrite = math.max(redHeartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				redToHeal = math.max(redToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				local redMult = math.min(mult, redToHeal + redHeartsToOverwrite * 2)
				if redMult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "RED_HEART", redMult, true) -- using this so as to ignore tainted maggie hp healing doubling
				end
				
				local soulMult = math.min(math.max(mult - redMult, 0), soulToHeal + soulHeartsToOverwrite * 2)
				if soulMult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "BLACK_HEART", soulMult, true)
				end
			elseif (player:CanPickRedHearts() or CustomHealthAPI.Library.CanPickKey(player, "IMMORAL_HEART")) and 
			       pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART
			then
				local hpToAddFromPickup = 2
				
				local soulToHeal, soulHeartsToOverwrite = mod:calculateSoulAvailableForHealing(player, "IMMORAL_HEART")
				while soulHeartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					soulHeartsToOverwrite = math.max(soulHeartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				soulToHeal = math.max(soulToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
					hpToAddFromPickup = hpToAddFromPickup * 2
				end
				
				local redToHeal, redHeartsToOverwrite = mod:calculateRedAvailableForHealing(player, "RED_HEART")
				while redHeartsToOverwrite > 0 and hpToAddFromPickup > 0 do
					redHeartsToOverwrite = math.max(redHeartsToOverwrite - 1, 0)
					hpToAddFromPickup = math.max(hpToAddFromPickup - 2, 0)
				end
				redToHeal = math.max(redToHeal - hpToAddFromPickup, 0)
				hpToAddFromPickup = 0
				
				local redMult = math.min(mult, redToHeal + redHeartsToOverwrite * 2)
				if redMult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "RED_HEART", redMult, true) -- using this so as to ignore tainted maggie hp healing doubling
				end
				
				local soulMult = math.min(math.max(mult - redMult, 0), soulToHeal + soulHeartsToOverwrite * 2)
				if soulMult > 0 then
					CustomHealthAPI.Library.AddHealth(player, "IMMORAL_HEART", soulMult, true)
				end
			else
				CustomHealthAPI.Library.AddHealth(player, "RED_HEART", mult, true) -- using this so as to ignore tainted maggie hp healing doubling
			end
		end
	end
	
	return nil, dealtSpikesDamage
end

function mod:intToBinary(num)
	local bin = ""
	while num ~= 0 do
		if num%2 == 0 then
			bin = "0" .. bin
		else
			bin = "1" .. bin
		end
		num = math.floor(num/2)
	end
	while string.len(bin) < 4 do
		bin = "0" .. bin
	end
	return bin
end