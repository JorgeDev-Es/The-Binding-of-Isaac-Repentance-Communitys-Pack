-- Leftovers --

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:calculateRedLeftovers(pickup, player, overrideHpToAdd)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
		if player:CanPickRedHearts() then
			local hearttype = pickup.SubType
			local hpToAdd = 0
			if overrideHpToAdd then
				hpToAdd = overrideHpToAdd
			elseif hearttype == HeartSubType.HEART_FULL then
				hpToAdd = 2
			elseif hearttype == HeartSubType.HEART_DOUBLEPACK then
				hpToAdd = 4
			elseif hearttype == HeartSubType.HEART_SCARED then
				hpToAdd = 2
			else
				return 0, false
			end
				
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
				hpToAdd = hpToAdd * 2
			end
			
			local bloodChargeToMax = 99 - player:GetBloodCharge()
			local leftoverHP = math.max(0, hpToAdd - bloodChargeToMax)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
				leftoverHP = math.floor(leftoverHP / 2)
			end
			return leftoverHP, true
		end
		
		return 0, false
	end
	
	if player:CanPickRedHearts() then
		local hpData = player:GetData().CustomHealthAPISavedata
		if hpData ~= nil then
			local hearttype = pickup.SubType
			local hpToAdd = 0
			if overrideHpToAdd then
				hpToAdd = overrideHpToAdd
			elseif hearttype == HeartSubType.HEART_FULL then
				hpToAdd = 2
			elseif hearttype == HeartSubType.HEART_DOUBLEPACK then
				hpToAdd = 4
			elseif hearttype == HeartSubType.HEART_SCARED then
				hpToAdd = 2
			else
				return 0, false
			end
			
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
				hpToAdd = hpToAdd * 2
			end
		
			local redMasks = hpData.RedHealthMasks
			local addPriorityOfRed = CustomHealthAPI.PersistentData.HealthDefinitions["RED_HEART"].AddPriority
			local hpToOverwrite = 0
			local customMissingRed = 0
			for i = 1, #redMasks do
				local mask = redMasks[i]
				for j = 1, #mask do
					local health = mask[j]
					if health.Key ~= "RED_HEART" and
					   addPriorityOfRed >= CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].AddPriority
					then
						hpToOverwrite = hpToOverwrite + 2
					else
						local maxHP = CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].MaxHP
						customMissingRed = customMissingRed + (maxHP - health.HP)
					end
				end
			end
			
			local customUnoccupiedRedCapacity = CustomHealthAPI.Helper.GetAmountUnoccupiedContainers(player) * 2
			local customRedToFullHealth = customMissingRed + customUnoccupiedRedCapacity
			
			if customRedToFullHealth == 0 and hpToOverwrite == 0 then
				return 0, false
			end
			
			local leftoverHP = math.max(0, hpToAdd - (customRedToFullHealth + hpToOverwrite))
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
				leftoverHP = math.floor(leftoverHP / 2)
			end
			return leftoverHP, true
		end
	end
	
	return 0, false
end

function mod:calculateMorbidLeftovers(pickup, player)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
		if CustomHealthAPI.Library.CanPickKey(player, "MORBID_HEART") then
			local hearttype = pickup.Variant
			local hpToAdd = 0
			if hearttype == FiendFolio.PICKUP.VARIANT.MORBID_HEART then
				hpToAdd = 3
			elseif hearttype == FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART then
				hpToAdd = 2
			elseif hearttype == FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART then
				hpToAdd = 1
			else
				return 0
			end
			
			local bloodChargeToMax = 99 - player:GetBloodCharge()
			local leftoverHP = math.max(0, hpToAdd - bloodChargeToMax)
			return leftoverHP
		end
		
		return 0
	end
	
	if CustomHealthAPI.Library.CanPickKey(player, "MORBID_HEART") then
		local hpData = player:GetData().CustomHealthAPISavedata
		if hpData ~= nil then
			local hearttype = pickup.Variant
			local hpToAdd = 0
			if hearttype == FiendFolio.PICKUP.VARIANT.MORBID_HEART then
				hpToAdd = 3
			elseif hearttype == FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART then
				hpToAdd = 2
			elseif hearttype == FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART then
				hpToAdd = 1
			else
				return 0
			end
		
			local redMasks = hpData.RedHealthMasks
			local addPriorityOfMorbid = CustomHealthAPI.PersistentData.HealthDefinitions["MORBID_HEART"].AddPriority
			local hpToOverwrite = 0
			local customMissingRed = 0
			for i = 1, #redMasks do
				local mask = redMasks[i]
				for j = 1, #mask do
					local health = mask[j]
					if health.Key ~= "MORBID_HEART" and
					   addPriorityOfMorbid >= CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].AddPriority
					then
						hpToOverwrite = hpToOverwrite + 3
					else
						local maxHP = CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].MaxHP
						customMissingRed = customMissingRed + (maxHP - health.HP)
					end
				end
			end
			
			local customUnoccupiedMorbidCapacity = CustomHealthAPI.Helper.GetAmountUnoccupiedContainers(player) * 3
			local customMorbidToFullHealth = customMissingRed + customUnoccupiedMorbidCapacity
			
			if customMorbidToFullHealth == 0 and hpToOverwrite == 0 then
				return 0
			end
			
			local leftoverHP = math.max(0, hpToAdd - (customMorbidToFullHealth + hpToOverwrite))
			return leftoverHP
		end
	end
	
	return 0
end

function mod:calculateSoulLeftovers(pickup, player, overrideHpToAdd)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
		if player:CanPickSoulHearts() then
			local hearttype = pickup.SubType
			local hpToAdd = 0
			if overrideHpToAdd then
				hpToAdd = overrideHpToAdd
			elseif hearttype == HeartSubType.HEART_SOUL then
				hpToAdd = 2
			else
				return 0, false
			end
			
			local numShacklesDisabled = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
			local hpSpentReactivatingShackles = math.max(0, 2 * numShacklesDisabled)
	
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			local soulChargeToMax = 99 - player:GetSoulCharge()
			local leftoverHP = math.max(0, hpToAdd - (soulChargeToMax + alabasterChargesToAdd + hpSpentReactivatingShackles))
			return leftoverHP, true
		end
		
		return 0, false
	end
	
	if player:CanPickSoulHearts() then
		local hpData = player:GetData().CustomHealthAPISavedata
		if hpData ~= nil then
			local hearttype = pickup.SubType
			local hpToAdd = 0
			if overrideHpToAdd then
				hpToAdd = overrideHpToAdd
			elseif hearttype == HeartSubType.HEART_SOUL then
				hpToAdd = 2
			else
				return 0, false
			end
			
			local numShacklesDisabled = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
			if numShacklesDisabled > 0 then
				return 0, true
			end
	
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			local otherMasks = hpData.OtherHealthMasks
			local addPriorityOfSoul = CustomHealthAPI.PersistentData.HealthDefinitions["SOUL_HEART"].AddPriority
			local hpToOverwrite = 0
			local customMissingSoul = 0
			for i = 1, #otherMasks do
				local mask = otherMasks[i]
				for j = 1, #mask do
					local health = mask[j]
					if CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.SOUL then
						if health.Key ~= "SOUL_HEART" and
						   addPriorityOfSoul >= CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].AddPriority
						then
							hpToOverwrite = hpToOverwrite + 2
						else
							local maxHP = CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].MaxHP
							customMissingSoul = customMissingSoul + (maxHP - health.HP)
						end
					end
				end
			end
			
			local customUnoccupiedSoulCapacity = CustomHealthAPI.Helper.GetRoomForOtherKeys(player) * 2
			local customSoulToFullHealth = customMissingSoul + customUnoccupiedSoulCapacity
			
			if alabasterChargesToAdd == 0 and customSoulToFullHealth == 0 and hpToOverwrite == 0 then
				return 0, false
			end
			
			local leftoverHP = math.max(0, hpToAdd - (customSoulToFullHealth + hpToOverwrite + alabasterChargesToAdd))
			return leftoverHP, true
		end
	end
	
	return 0, false
end

function mod:calculateBlackLeftovers(pickup, player, overrideHpToAdd)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
		if player:CanPickBlackHearts() then
			local hearttype = pickup.SubType
			local hpToAdd = 0
			if overrideHpToAdd then
				hpToAdd = overrideHpToAdd
			elseif hearttype == HeartSubType.HEART_BLACK then
				hpToAdd = 2
			else
				return 0, false
			end
			
			local numShacklesDisabled = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
			local hpSpentReactivatingShackles = math.max(0, 2 * numShacklesDisabled)
	
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			local soulChargeToMax = 99 - player:GetSoulCharge()
			local leftoverHP = math.max(0, hpToAdd - (soulChargeToMax + alabasterChargesToAdd + hpSpentReactivatingShackles))
			return leftoverHP, true
		end
		
		return 0, false
	end
	
	if player:CanPickBlackHearts() then
		local hpData = player:GetData().CustomHealthAPISavedata
		if hpData ~= nil then
			local hearttype = pickup.SubType
			local hpToAdd = 0
			if overrideHpToAdd then
				hpToAdd = overrideHpToAdd
			elseif hearttype == HeartSubType.HEART_BLACK then
				hpToAdd = 2
			else
				return 0, false
			end
			
			local numShacklesDisabled = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
			if numShacklesDisabled > 0 then
				return 0, true
			end
	
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			local otherMasks = hpData.OtherHealthMasks
			local addPriorityOfBlack = CustomHealthAPI.PersistentData.HealthDefinitions["BLACK_HEART"].AddPriority
			local hpToOverwrite = 0
			local customMissingBlack = 0
			for i = 1, #otherMasks do
				local mask = otherMasks[i]
				for j = 1, #mask do
					local health = mask[j]
					if CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.SOUL then
						if health.Key ~= "BLACK_HEART" and
						   addPriorityOfBlack >= CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].AddPriority
						then
							hpToOverwrite = hpToOverwrite + 2
						else
							local maxHP = CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].MaxHP
							customMissingBlack = customMissingBlack + (maxHP - health.HP)
						end
					end
				end
			end
			
			local customUnoccupiedBlackCapacity = CustomHealthAPI.Helper.GetRoomForOtherKeys(player) * 2
			local customBlackToFullHealth = customMissingBlack + customUnoccupiedBlackCapacity
			
			if alabasterChargesToAdd == 0 and customBlackToFullHealth == 0 and hpToOverwrite == 0 then
				return 0, false
			end
			
			local leftoverHP = math.max(0, hpToAdd - (customBlackToFullHealth + hpToOverwrite + alabasterChargesToAdd))
			return leftoverHP, true
		end
	end
	
	return 0, false
end

function mod:calculateImmoralLeftovers(pickup, player, overrideHpToAdd)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
			if CustomHealthAPI.Library.CanPickKey(player, "IMMORAL_HEART") then
			local hearttype = pickup.Variant
			local hpToAdd = 0
			if overrideHpToAdd then
				hpToAdd = overrideHpToAdd
			elseif hearttype == FiendFolio.PICKUP.VARIANT.IMMORAL_HEART then
				hpToAdd = 2
			else
				return 0, false
			end
			
			local numShacklesDisabled = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
			local hpSpentReactivatingShackles = math.max(0, 2 * numShacklesDisabled)
	
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			local soulChargeToMax = 99 - player:GetSoulCharge()
			local leftoverHP = math.max(0, hpToAdd - (soulChargeToMax + alabasterChargesToAdd + hpSpentReactivatingShackles))
			return leftoverHP, true
		end
		
		return 0, false
	end
	
	if CustomHealthAPI.Library.CanPickKey(player, "IMMORAL_HEART") then
		local hpData = player:GetData().CustomHealthAPISavedata
		if hpData ~= nil then
			local hearttype = pickup.Variant
			local hpToAdd = 0
			if overrideHpToAdd then
				hpToAdd = overrideHpToAdd
			elseif hearttype == FiendFolio.PICKUP.VARIANT.IMMORAL_HEART then
				hpToAdd = 2
			else
				return 0, false
			end
			
			local numShacklesDisabled = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
			if numShacklesDisabled > 0 then
				return 0, true
			end
	
			local alabasterChargesToAdd = 0
			for i = 0, 2 do
				if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					alabasterChargesToAdd = alabasterChargesToAdd + (12 - player:GetActiveCharge(i))
				end
			end
			
			local otherMasks = hpData.OtherHealthMasks
			local addPriorityOfImmoral = CustomHealthAPI.PersistentData.HealthDefinitions["IMMORAL_HEART"].AddPriority
			local hpToOverwrite = 0
			local customMissingImmoral = 0
			for i = 1, #otherMasks do
				local mask = otherMasks[i]
				for j = 1, #mask do
					local health = mask[j]
					if CustomHealthAPI.Library.GetInfoOfHealth(health, "Type") == CustomHealthAPI.Enums.HealthTypes.SOUL then
						if health.Key ~= "IMMORAL_HEART" and
						   addPriorityOfImmoral >= CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].AddPriority
						then
							hpToOverwrite = hpToOverwrite + 2
						else
							local maxHP = CustomHealthAPI.PersistentData.HealthDefinitions[health.Key].MaxHP
							customMissingImmoral = customMissingImmoral + (maxHP - health.HP)
						end
					end
				end
			end
			
			local customUnoccupiedImmoralCapacity = CustomHealthAPI.Helper.GetRoomForOtherKeys(player) * 2
			local customImmoralToFullHealth = customMissingImmoral + customUnoccupiedImmoralCapacity
			
			if alabasterChargesToAdd == 0 and customImmoralToFullHealth == 0 and hpToOverwrite == 0 then
				return 0, false
			end
			
			local leftoverHP = math.max(0, hpToAdd - (customImmoralToFullHealth + hpToOverwrite + alabasterChargesToAdd))
			return leftoverHP, true
		end
	end
	
	return 0, false
end

local redHeartsToLeftovers = {}
local morbidHeartsToLeftovers = {}
local soulHeartsToLeftovers = {}
local blackHeartsToLeftovers = {}
local immoralHeartsToLeftovers = {}

function mod:setLeftovers(pickup, a)
	local amount = a - (pickup:GetData().FFOverhealSpentByChinaShardForLeftovers or 0)
	if amount <= 0 then
		return
	end
	
	if pickup.Variant == PickupVariant.PICKUP_HEART then
		if pickup.SubType == HeartSubType.HEART_FULL or
		   pickup.SubType == HeartSubType.HEART_HALF or
		   pickup.SubType == HeartSubType.HEART_DOUBLEPACK or
		   pickup.SubType == HeartSubType.HEART_SCARED
		then
			table.insert(redHeartsToLeftovers, {Pickup = pickup, Amount = amount})
		elseif pickup.SubType == HeartSubType.HEART_SOUL or 
		       pickup.SubType == HeartSubType.HEART_BLENDED 
		then
			table.insert(soulHeartsToLeftovers, {Pickup = pickup, Amount = amount})
		elseif pickup.SubType == HeartSubType.HEART_BLACK then
			table.insert(blackHeartsToLeftovers, {Pickup = pickup, Amount = amount})
		end
	elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.HALF_BLACK_HEART or
	       pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART
	then
		table.insert(blackHeartsToLeftovers, {Pickup = pickup, Amount = amount})
	elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART or
	       pickup.Variant == FiendFolio.PICKUP.VARIANT.IMMORAL_HEART or
	       pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART
	then
		table.insert(immoralHeartsToLeftovers, {Pickup = pickup, Amount = amount})
	elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.MORBID_HEART or
	       pickup.Variant == FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART or
	       pickup.Variant == FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART
	then
		table.insert(morbidHeartsToLeftovers, {Pickup = pickup, Amount = amount})
	end
end

function FiendFolio.HandleLeftoversHeartCollision(pickup, p, alreadyDealtSpikesDamage)
	local dealtSpikesDamage = false

	local player = p:ToPlayer()
	if player == nil then
		return nil, dealtSpikesDamage
	end
	
	local playerType = player:GetPlayerType()
	if playertype == PlayerType.PLAYER_THELOST or
	   playertype == PlayerType.PLAYER_THELOST_B or
	   playertype == PlayerType.PLAYER_KEEPER or
	   playertype == PlayerType.PLAYER_KEEPER_B or
	   (player.Variant == 1 and player.SubType == BabySubType.BABY_FOUND_SOUL) or
	   player:IsCoopGhost()
	then
		return nil, dealtSpikesDamage
	elseif playertype == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			player = player:GetOtherTwin()
		else
			return nil, dealtSpikesDamage
		end
	end
	
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.LEFTOVERS) then
		if pickup.Price == PickupPrice.PRICE_SPIKES and not alreadyDealtSpikesDamage then
			local tookDamage = player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
			dealtSpikesDamage = true
			
			if not tookDamage then
				return nil, dealtSpikesDamage
			end
		end
		
		if pickup.Variant == PickupVariant.PICKUP_HEART then
			local hearttype = pickup.SubType
			if hearttype == HeartSubType.HEART_FULL or
			   hearttype == HeartSubType.HEART_DOUBLEPACK or
			   hearttype == HeartSubType.HEART_SCARED
			then
				if playerType == PlayerType.PLAYER_THESOUL then
					if player:GetSubPlayer() ~= nil then
						player = player:GetSubPlayer()
					else
						return nil, dealtSpikesDamage
					end
				end
				
				local leftovers = mod:calculateRedLeftovers(pickup, player)
				if leftovers > 0 then
					mod:setLeftovers(pickup, leftovers)
				end
			elseif hearttype == HeartSubType.HEART_SOUL then
				if playerType == PlayerType.PLAYER_THEFORGOTTEN then
					if player:GetSubPlayer() ~= nil then
						player = player:GetSubPlayer()
					else
						return nil, dealtSpikesDamage
					end
				end
				
				local leftovers = mod:calculateSoulLeftovers(pickup, player)
				if leftovers > 0 then
					mod:setLeftovers(pickup, leftovers)
				end
			elseif hearttype == HeartSubType.HEART_BLACK then
				if playerType == PlayerType.PLAYER_THEFORGOTTEN then
					if player:GetSubPlayer() ~= nil then
						player = player:GetSubPlayer()
					else
						return nil, dealtSpikesDamage
					end
				end
				
				local leftovers = mod:calculateBlackLeftovers(pickup, player)
				if leftovers > 0 then
					mod:setLeftovers(pickup, leftovers)
				end
			elseif hearttype == HeartSubType.HEART_BLENDED then
				local leftoversAfterRed, usedRedHeart = 0, false
				if playerType == PlayerType.PLAYER_THESOUL then
					if player:GetSubPlayer() ~= nil then
						leftoversAfterRed, usedRedHeart = mod:calculateRedLeftovers(pickup, player:GetSubPlayer(), 2)
					end
				else
					leftoversAfterRed, usedRedHeart = mod:calculateRedLeftovers(pickup, player, 2)
				end
				
				local soulToTest = 0
				if not usedRedHeart then
					soulToTest = 2
				elseif leftoversAfterRed > 0 then
					soulToTest = leftoversAfterRed
				else
					return nil, dealtSpikesDamage
				end
				
				local leftoversAfterSoul, usedSoulHeart = 0, false
				if playerType == PlayerType.PLAYER_THEFORGOTTEN then
					if player:GetSubPlayer() ~= nil then
						leftoversAfterSoul, usedSoulHeart = mod:calculateSoulLeftovers(pickup, player:GetSubPlayer(), soulToTest)
					end
				else
					leftoversAfterSoul, usedSoulHeart = mod:calculateSoulLeftovers(pickup, player, soulToTest)
				end
				
				if leftoversAfterSoul > 0 then
					mod:setLeftovers(pickup, leftoversAfterSoul)
				elseif not usedSoulHeart then
					mod:setLeftovers(pickup, soulToTest)
				end
			end
		elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.MORBID_HEART or
		       pickup.Variant == FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART or
		       pickup.Variant == FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART
		then
			if playerType == PlayerType.PLAYER_THESOUL then
				if player:GetSubPlayer() ~= nil then
					player = player:GetSubPlayer()
				else
					return nil, dealtSpikesDamage
				end
			end
			
			local leftovers = mod:calculateMorbidLeftovers(pickup, player)
			if leftovers > 0 then
				mod:setLeftovers(pickup, leftovers)
			end
		elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.IMMORAL_HEART then
			if playerType == PlayerType.PLAYER_THEFORGOTTEN then
				if player:GetSubPlayer() ~= nil then
					player = player:GetSubPlayer()
				else
					return nil, dealtSpikesDamage
				end
			end
			
			local leftovers = mod:calculateImmoralLeftovers(pickup, player)
			if leftovers > 0 then
				mod:setLeftovers(pickup, leftovers)
			end
		elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART then
			local leftoversAfterRed, usedRedHeart = 0, false
			if playerType == PlayerType.PLAYER_THESOUL then
				if player:GetSubPlayer() ~= nil then
					leftoversAfterRed, usedRedHeart = mod:calculateRedLeftovers(pickup, player:GetSubPlayer(), 2)
				end
			else
				leftoversAfterRed, usedRedHeart = mod:calculateRedLeftovers(pickup, player, 2)
			end
			
			local blackToTest = 0
			if not usedRedHeart then
				blackToTest = 2
			elseif leftoversAfterRed > 0 then
				blackToTest = leftoversAfterRed
			else
				return nil, dealtSpikesDamage
			end
			
			local leftoversAfterBlack, usedBlackHeart = 0, false
			if playerType == PlayerType.PLAYER_THEFORGOTTEN then
				if player:GetSubPlayer() ~= nil then
					leftoversAfterBlack, usedBlackHeart = mod:calculateBlackLeftovers(pickup, player:GetSubPlayer(), blackToTest)
				end
			else
				leftoversAfterBlack, usedBlackHeart = mod:calculateBlackLeftovers(pickup, player, blackToTest)
			end
			
			if leftoversAfterBlack > 0 then
				mod:setLeftovers(pickup, leftoversAfterBlack)
			elseif not usedBlackHeart then
				mod:setLeftovers(pickup, blackToTest)
			end
		elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART then
			local leftoversAfterRed, usedRedHeart = 0, false
			if playerType == PlayerType.PLAYER_THESOUL then
				if player:GetSubPlayer() ~= nil then
					leftoversAfterRed, usedRedHeart = mod:calculateRedLeftovers(pickup, player:GetSubPlayer(), 2)
				end
			else
				leftoversAfterRed, usedRedHeart = mod:calculateRedLeftovers(pickup, player, 2)
			end
			
			local immoralToTest = 0
			if not usedRedHeart then
				immoralToTest = 2
			elseif leftoversAfterRed > 0 then
				immoralToTest = leftoversAfterRed
			else
				return nil, dealtSpikesDamage
			end
			
			local leftoversAfterImmoral, usedImmoralHeart = 0, false
			if playerType == PlayerType.PLAYER_THEFORGOTTEN then
				if player:GetSubPlayer() ~= nil then
					leftoversAfterImmoral, usedImmoralHeart = mod:calculateImmoralLeftovers(pickup, player:GetSubPlayer(), immoralToTest)
				end
			else
				leftoversAfterImmoral, usedImmoralHeart = mod:calculateImmoralLeftovers(pickup, player, immoralToTest)
			end
			
			if leftoversAfterImmoral > 0 then
				mod:setLeftovers(pickup, leftoversAfterImmoral)
			elseif not usedImmoralHeart then
				mod:setLeftovers(pickup, immoralToTest)
			end
		end
	end
	
	return nil, dealtSpikesDamage
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	for i = 1, #redHeartsToLeftovers do
		local leftovers = redHeartsToLeftovers[i]
		if leftovers.Pickup and (leftovers.Pickup:GetSprite():IsPlaying("Collect") or 
		                         leftovers.Pickup:GetSprite():IsFinished("Collect") or
		                         (leftovers.Pickup:IsShopItem() and not leftovers.Pickup:Exists()))
		then
			local amount = leftovers.Amount
			if amount == 3 then
				Isaac.Spawn(5, 10, 1, leftovers.Pickup.Position + Vector(-12,0), nilvector, nil)
				Isaac.Spawn(5, 10, 2, leftovers.Pickup.Position + Vector(12,0), nilvector, nil)
			elseif amount == 2 then
				Isaac.Spawn(5, 10, 1, leftovers.Pickup.Position, nilvector, nil)
			else
				Isaac.Spawn(5, 10, 2, leftovers.Pickup.Position, nilvector, nil)
			end
		end
	end
	
	for i = 1, #morbidHeartsToLeftovers do
		local leftovers = morbidHeartsToLeftovers[i]
		if leftovers.Pickup and (leftovers.Pickup:GetSprite():IsPlaying("Collect") or 
		                         leftovers.Pickup:GetSprite():IsFinished("Collect") or
		                         (leftovers.Pickup:IsShopItem() and not leftovers.Pickup:Exists()))
		then
			local amount = leftovers.Amount
			if amount == 2 then
				Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART, 0, leftovers.Pickup.Position, nilvector, nil)
			else
				Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART, 0, leftovers.Pickup.Position, nilvector, nil)
			end
		end
	end
	
	for i = 1, #soulHeartsToLeftovers do
		local leftovers = soulHeartsToLeftovers[i]
		if leftovers.Pickup and (leftovers.Pickup:GetSprite():IsPlaying("Collect") or 
		                         leftovers.Pickup:GetSprite():IsFinished("Collect") or
		                         (leftovers.Pickup:IsShopItem() and not leftovers.Pickup:Exists()))
		then
			local amount = leftovers.Amount
			if amount == 1 then
				Isaac.Spawn(5, 10, 8, leftovers.Pickup.Position, nilvector, nil)
			end
		end
	end
	
	for i = 1, #blackHeartsToLeftovers do
		local leftovers = blackHeartsToLeftovers[i]
		if leftovers.Pickup and (leftovers.Pickup:GetSprite():IsPlaying("Collect") or 
		                         leftovers.Pickup:GetSprite():IsFinished("Collect") or
		                         (leftovers.Pickup:IsShopItem() and not leftovers.Pickup:Exists()))
		then
			local amount = leftovers.Amount
			if amount == 1 then
				Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.HALF_BLACK_HEART, 0, leftovers.Pickup.Position, nilvector, nil)
			end
		end
	end
	
	for i = 1, #immoralHeartsToLeftovers do
		local leftovers = immoralHeartsToLeftovers[i]
		if leftovers.Pickup and (leftovers.Pickup:GetSprite():IsPlaying("Collect") or 
		                         leftovers.Pickup:GetSprite():IsFinished("Collect") or
		                         (leftovers.Pickup:IsShopItem() and not leftovers.Pickup:Exists()))
		then
			local amount = leftovers.Amount
			if amount == 1 then
				Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART, 0, leftovers.Pickup.Position, nilvector, nil)
			end
		end
	end
	
	redHeartsToLeftovers = {}
	morbidHeartsToLeftovers = {}
	soulHeartsToLeftovers = {}
	blackHeartsToLeftovers = {}
	immoralHeartsToLeftovers = {}
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	redHeartsToLeftovers = {}
	morbidHeartsToLeftovers = {}
	soulHeartsToLeftovers = {}
	blackHeartsToLeftovers = {}
	immoralHeartsToLeftovers = {}
end)
