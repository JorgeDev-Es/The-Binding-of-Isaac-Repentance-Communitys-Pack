local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local chinaShard = mod.ITEM.TRINKET.SHARD_OF_CHINA
local chinaHeart = mod.ITEM.COLLECTIBLE.HEART_OF_CHINA
local golemShard = mod.ITEM.ROCK.SHARD_OF_GOLEM

local chinaSprite = Sprite()
chinaSprite:Load("gfx/ui/shardofchina.anm2", true)

local function GetChinaHeartMeterLength(player)
	if player:HasCollectible(chinaHeart) then
		return math.max(6, player:GetEffectiveMaxHearts())
	elseif mod.IsPlayerHoldingTrinket(player, mod.ITEM.ROCK.SHARD_OF_GOLEM) then
		return 8
	else
	    return 6
	end
end

local function GetPlayerHudSkin(player)
	local playerType = player:GetPlayerType()
	if playerType == PlayerType.PLAYER_THEFORGOTTEN then
		return "Bone"
	elseif playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B then
		return "Lost"
	else
		return "Red"
	end
end

local function CanPlayerShowChinaHud(player)
	return player:HasCollectible(chinaHeart) or mod.IsPlayerHoldingTrinket(player, chinaShard) or mod.IsPlayerHoldingTrinket(player, golemShard)
end

local function PickupIsRedHeart(pickup)
	return pickup.Variant == PickupVariant.PICKUP_HEART and 
	(
		pickup.SubType == HeartSubType.HEART_FULL or
		pickup.SubType == HeartSubType.HEART_HALF or
		pickup.SubType == HeartSubType.HEART_DOUBLEPACK or
		pickup.SubType == HeartSubType.HEART_SCARED
	)
end

local RedHeartValue = {
	[HeartSubType.HEART_FULL] = 2,
	[HeartSubType.HEART_HALF] = 1,
	[HeartSubType.HEART_DOUBLEPACK] = 4,
	[HeartSubType.HEART_SCARED] = 2,
}

local function GetHeartOverhealAndCollect(pickup, player)
	local redIsDoubled = player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW)
	local hasOddlySmoothStone = player:HasTrinket(FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE)

	local hp
	if PickupIsRedHeart(pickup) then
		hp = RedHeartValue[pickup.SubType]
	else
		-- blended
		hp = 2
	end
	
	if redIsDoubled then
		hp = hp * 2
	end
	if hasOddlySmoothStone then
	    hp = hp + math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE))
	end
	
	local spentHP = CustomHealthAPI.Library.GetRedHPToBeSpent(player, hp)
	
	if (pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_BLENDED) or
	   pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART or
	   pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART
	then
		local soulHP = hp - spentHP
		if hasOddlySmoothStone then
			soulHP = math.max(0, soulHP - math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE)))
		end
		if redIsDoubled then
			soulHP = math.floor(soulHP / 2)
		end
		
		if soulHP > 0 then
			local spentSoulHP = 0
			if pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_BLENDED then
				spentSoulHP = CustomHealthAPI.Library.GetSoulHPToBeSpent(player, soulHP, "SOUL_HEART")
			elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART then
				spentSoulHP = CustomHealthAPI.Library.GetSoulHPToBeSpent(player, soulHP, "BLACK_HEART")
			elseif pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART then
				spentSoulHP = CustomHealthAPI.Library.GetSoulHPToBeSpent(player, soulHP, "IMMORAL_HEART")
			end
			
			if redIsDoubled then
				spentSoulHP = spentSoulHP * 2
			end
			spentHP = spentHP + spentSoulHP
		end
	end
	
	return hp - spentHP, spentHP == 0
end

local function ShouldPlayerShowChinaHud(player)
	local heartInRange
	local data = player:GetData()

	for _, pickup in pairs(Isaac.FindByType(5)) do
		if pickup:ToPickup().Price <= player:GetNumCoins() then
			if pickup.Position:Distance(player.Position) < 80 then
				if (PickupIsRedHeart(pickup) or
				   (pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_BLENDED) or
				   pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART or
				   pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART) and
				   GetHeartOverhealAndCollect(pickup, player) > 0 
				then
					heartInRange = true
					break
				end
			end
		end
	end

	return CanPlayerShowChinaHud(player) and (
		Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) or
		data.lastUsedYumHeart + 60 >= player.FrameCount or
		heartInRange
	)
end

function mod.GetActiveShardOfChinaDamage(player)
	local damage = 0

	if mod.IsPlayerHoldingTrinket(player, golemShard) then
		local data = mod.GetPersistentPlayerData(player)
		local heartCap = math.floor(GetChinaHeartMeterLength(player) / 2)
		local fillLevel = math.floor((data.shardOfChinaHearts or 0) / 2)

		damage = damage + 1.8 * (fillLevel / heartCap)
	end

	if mod.IsPlayerHoldingTrinket(player, chinaShard) then
		local data = mod.GetPersistentPlayerData(player)
		local heartCap = math.floor(GetChinaHeartMeterLength(player) / 2)
		local fillLevel = math.floor((data.shardOfChinaHearts or 0) / 2)

		damage = damage + 1.5 * (fillLevel / heartCap)
	end

	return damage * (mod.GetHeldTrinketMultiplier(player, chinaShard) + mod.GetHeldTrinketMultiplier(player, golemShard))
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if player:HasTrinket(chinaShard) or player:HasCollectible(chinaHeart) or player:HasTrinket(golemShard) then
		local persistentData = mod.GetPersistentPlayerData(player)
		local data = player:GetData()

		persistentData.shardOfChinaDamage = persistentData.shardOfChinaDamage or 0
		persistentData.heartShardOfChinaDamage = persistentData.heartShardOfChinaDamage or 0
		persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts or 0
		data.lastUsedYumHeart = data.lastUsedYumHeart or -999

		if data.showShardOfChina then
			data.shardOfChinaFrame = data.shardOfChinaFrame + 1
		end

		data.didWantToShowShardOfChina = data.wantsToShowShardOfChina
		data.wantsToShowShardOfChina = ShouldPlayerShowChinaHud(player)
		data.lastShowedShardOfChina = data.wantsToShowShardOfChina and player.FrameCount or data.lastShowedShardOfChina or -15
		data.showShardOfChina = data.lastShowedShardOfChina + 5 >= player.FrameCount

		data.shardOfChinaFrame = data.shardOfChinaFrame or 0
		if (data.didWantToShowShardOfChina and not data.wantsToShowShardOfChina) or not data.showShardOfChina then
			data.shardOfChinaFrame = 0
		end

		local heartCap = GetChinaHeartMeterLength(player)

		if persistentData.shardOfChinaHearts >= heartCap then
			persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts - heartCap

			if player:HasCollectible(chinaHeart) then
				if mod.PlayerHasSmeltedTrinket(player, golemShard) then
					persistentData.heartShardOfChinaDamage = persistentData.heartShardOfChinaDamage + 0.18
				elseif mod.PlayerHasSmeltedTrinket(player, chinaShard) then
					persistentData.heartShardOfChinaDamage = persistentData.heartShardOfChinaDamage + 0.15
				end

				player:AnimateCollectible(chinaHeart, "UseItem")
				player:AddMaxHearts(2)
			end

			local trinketSlot = mod.IsPlayerHoldingTrinket(player, chinaShard)
			if trinketSlot then
				mod.SmeltHeldTrinket(player, trinketSlot)
				player:AnimateTrinket(chinaShard, "UseItem")
			end

			if mod.IsPlayerHoldingTrinket(player, golemShard) then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER)
				player:AnimateTrinket(golemShard, "UseItem")
			end

			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
			sfx:Play(SoundEffect.SOUND_THUMBSUP)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
	if CanPlayerShowChinaHud(player) then
		local data = player:GetData()
		if data.showShardOfChina then
			local anim = GetPlayerHudSkin(player)
			if not data.wantsToShowShardOfChina then
				anim = anim .. "Out"
			end

			local persistentData = mod.GetPersistentPlayerData(player)
			local playerPosition = Isaac.WorldToScreen(player.Position)
			local cap = GetChinaHeartMeterLength(player) / 2
			local fill = persistentData.shardOfChinaHearts

			for i = 1, cap do
				chinaSprite:SetFrame(anim .. math.min(fill, 2), data.shardOfChinaFrame)
				chinaSprite:Render(playerPosition + Vector((i - cap / 2) * 8 - 3.5, -40), Vector.Zero, Vector.Zero)
				fill = math.max(0, fill - 2)
			end
		end
	end
end)

function FiendFolio.HandleChinaShardHeartCollision(pickup, player, alreadyDealtSpikesDamage)
	local dealtSpikesDamage = false
	
	if not (PickupIsRedHeart(pickup) or
	       (pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_BLENDED) or
	       pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART or
	       pickup.Variant == FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART)
	then
		return nil, dealtSpikesDamage
	end
	
	if player and CanPlayerShowChinaHud(player) then
		if pickup.Price > player:GetNumCoins() then
			return nil, dealtSpikesDamage
		elseif pickup.Price == PickupPrice.PRICE_SPIKES and not alreadyDealtSpikesDamage then
			local tookDamage = player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
			dealtSpikesDamage = true
			
			if not tookDamage then
				return nil, dealtSpikesDamage
			end
		end
		
		local recalculate
		local overheal, collect = GetHeartOverhealAndCollect(pickup, player)

		local unspentOverheal = 0
		if overheal > 0 then
			local persistentData = mod.GetPersistentPlayerData(player)
			if player:HasCollectible(mod.ITEM.COLLECTIBLE.HEART_OF_CHINA) then
				persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts + overheal
				unspentOverheal = 0
			elseif mod.IsPlayerHoldingTrinket(player, mod.ITEM.ROCK.SHARD_OF_GOLEM) then
				local overhealToUse = math.min(overheal, 8 - persistentData.shardOfChinaHearts)
				persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts + overhealToUse
				unspentOverheal = overheal - overhealToUse
			elseif mod.IsPlayerHoldingTwoTrinkets(player, mod.ITEM.TRINKET.SHARD_OF_CHINA) then
				local overhealToUse = math.min(overheal, 12 - persistentData.shardOfChinaHearts)
				persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts + overhealToUse
				unspentOverheal = overheal - overhealToUse
			elseif mod.IsPlayerHoldingTrinket(player, mod.ITEM.TRINKET.SHARD_OF_CHINA) then
				local overhealToUse = math.min(overheal, 6 - persistentData.shardOfChinaHearts)
				persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts + overhealToUse
				unspentOverheal = overheal - overhealToUse
			end
			recalculate = true
		end

		if recalculate and (mod.IsPlayerHoldingTrinket(player, chinaShard) or mod.IsPlayerHoldingTrinket(player, golemShard)) then
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end

		if collect then
			if pickup.OptionsPickupIndex ~= 0 then
				local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
				for _, entity in ipairs(pickups) do
					if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
					   (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
					then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
						entity:Remove()
					end
				end
			end

			if pickup:IsShopItem() then
				if pickup.Price > 0 then
					player:AddCoins(-1 * pickup.Price)
				end
				
				CustomHealthAPI.Library.TriggerRestock(pickup)
				CustomHealthAPI.Helper.TryRemoveStoreCredit(player)
			end
			
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
			pickup.EntityCollisionClass = 0
			pickup:GetSprite():Play("Collect")
			pickup:Die()
			
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
		
			if unspentOverheal > 0 and player:HasTrinket(FiendFolio.ITEM.TRINKET.LEFTOVERS) then
				if player:HasTrinket(FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE) then
					unspentOverheal = math.max(0, unspentOverheal - math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE)))
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
					unspentOverheal = math.floor(unspentOverheal / 2)
				end
				mod:setLeftovers(pickup, unspentOverheal)
			end
			
			return true, dealtSpikesDamage
		else
			local spentOverheal = overheal - unspentOverheal
			if player:HasTrinket(FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE) then
				spentOverheal = math.max(0, spentOverheal - math.ceil(mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ODDLY_SMOOTH_STONE)))
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
				spentOverheal = math.floor(spentOverheal / 2)
			end
			pickup:GetData().FFOverhealSpentByChinaShardForLeftovers = spentOverheal
		end
	end
	
	return nil, dealtSpikesDamage
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, item, rng, player)
	if CanPlayerShowChinaHud(player) then
		local amount = player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE_B and 4 or 2
		local overheal = amount - CustomHealthAPI.Library.GetRedHPToBeSpent(player, amount)

		if overheal > 0 then
			local persistentData = mod.GetPersistentPlayerData(player)
			persistentData.shardOfChinaHearts = persistentData.shardOfChinaHearts + overheal
			
			player:GetData().lastUsedYumHeart = player.FrameCount

			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	end
end, CollectibleType.COLLECTIBLE_YUM_HEART)