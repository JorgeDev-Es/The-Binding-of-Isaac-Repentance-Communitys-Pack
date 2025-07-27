local mod = TaintedTreasure
local itemconfig = Isaac.GetItemConfig()
local rng = RNG()
local game = Game()

local function tearsUp(firedelay, val) --Copped from Fiend Folio but I've used this before I'm pretty sure
    local currentTears = 30 / (firedelay + 1)
    local newTears = currentTears + val
    return math.max((30 / newTears) - 1, -0.99)
end

local function tearsMult(firedelay, mult)
    local currentTears = 30 / (firedelay + 1)
    local newTears = currentTears * mult
    return math.max((30 / newTears) - 1, -0.99)
end

function mod:GetExpectedFamiliarNum(player, item)
	return player:GetCollectibleNum(item) + player:GetEffects():GetCollectibleEffectNum(item)
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
	local data = player:GetData()
	local savedata = mod.GetPersistentPlayerData(player)

	--Damage
	if cacheFlag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
		local mult = mod:GetPlayerDamageMult(player)
		
		if player:HasCollectible(TaintedCollectibles.YEARNING_PAGE) then
			player.Damage = player.Damage + (1.5 * player:GetCollectibleNum(TaintedCollectibles.YEARNING_PAGE) * mult)
		end

		if player:HasCollectible(TaintedCollectibles.EVANGELISM) then
			player.Damage = player.Damage + (0.5 * player:GetCollectibleNum(TaintedCollectibles.EVANGELISM) * mult)
		end
		
		mod:BadOnionDamageAdding(player, savedata)

		if savedata.DPadDamage then
			player.Damage = player.Damage + (savedata.DPadDamage * mult)
		end
		
		if savedata.NoOptionsDamage then
			player.Damage = player.Damage + (savedata.NoOptionsDamage * mult)
		end
		
		if savedata.SkeletonLockBuffs then
			savedata.SkeletonLockBuffs.Damage = savedata.SkeletonLockBuffs.Damage or 0
			player.Damage = player.Damage + (savedata.SkeletonLockBuffs.Damage * mult)
		end

		if player:HasCollectible(TaintedCollectibles.ETERNAL_CANDLE) and data.TotalUnknownHearts then
			player.Damage = player.Damage + (0.13 * (24 - data.TotalUnknownHearts) * mult * player:GetCollectibleNum(TaintedCollectibles.ETERNAL_CANDLE))
		end
		
		if player:HasCollectible(TaintedCollectibles.THE_BOTTLE) and (player:HasWeaponType(WeaponType.WEAPON_BONE) or player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD)) then
			player.Damage = player.Damage * 0.7
		end

		if data.GerminatedStacks then
			player.Damage = player.Damage + (1.5 * data.GerminatedStacks)
		end

		if player:HasCollectible(TaintedCollectibles.LEVIATHAN) then
			if savedata.LeviathanPurified then
				player.Damage = player.Damage + (1.5 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN) * mult)
			else
				player.Damage = player.Damage - (0.5 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN) * mult)
			end
		end
		
		if data.CancelStarEffect and data.PreStarDamage then
			player.Damage = data.PreStarDamage
		end
		if data.WormwoodEffect then
			player.Damage = player.Damage*0.7
		end
    
	--Tears
	elseif cacheFlag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY then
		if savedata.SkeletonLockBuffs then
			savedata.SkeletonLockBuffs.Tears = savedata.SkeletonLockBuffs.Tears or 0
			player.MaxFireDelay = tearsUp(player.MaxFireDelay, savedata.SkeletonLockBuffs.Tears)
		end
		if data.TaintedWhoreOfGalilee then
			player.MaxFireDelay = tearsUp(player.MaxFireDelay, 1.35 * player:GetCollectibleNum(TaintedCollectibles.WHORE_OF_GALILEE))
		end
		if data.GerminatedStacks then
			player.MaxFireDelay = tearsUp(player.MaxFireDelay, 1.5 * data.GerminatedStacks)
		end
		if player:HasCollectible(TaintedCollectibles.EVANGELISM) then
			player.MaxFireDelay = tearsUp(player.MaxFireDelay, -0.6 * player:GetCollectibleNum(TaintedCollectibles.EVANGELISM))
		end
		if player:HasCollectible(TaintedCollectibles.LEVIATHAN) then
			if savedata.LeviathanPurified then
				player.MaxFireDelay = tearsUp(player.MaxFireDelay, 1 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			else
				player.MaxFireDelay = tearsUp(player.MaxFireDelay, -0.5 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			end
		end

		if player:HasCollectible(TaintedCollectibles.SPIDER_FREAK) then
			player.MaxFireDelay = tearsMult(player.MaxFireDelay, 0.8)
		end
		if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
			player.MaxFireDelay = tearsMult(player.MaxFireDelay, 0.25)
		end
		if player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
			player.MaxFireDelay = tearsMult(player.MaxFireDelay, 0.4)
		end
		
		if savedata.WormwoodTearsUps then
			player.MaxFireDelay = tearsUp(player.MaxFireDelay, 0.5 * savedata.WormwoodTearsUps)
		end
		
		if data.CancelStarEffect and data.PreStarTears then
			player.MaxFireDelay = data.PreStarTears
		end
		if data.WormwoodEffect then
			player.MaxFireDelay = player.MaxFireDelay/0.7
		end
    
	--Speed
	elseif cacheFlag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
		if savedata.SkeletonLockBuffs then
			savedata.SkeletonLockBuffs.Speed = savedata.SkeletonLockBuffs.Speed or 0
			player.MoveSpeed = player.MoveSpeed + savedata.SkeletonLockBuffs.Speed
		end
        if player:HasCollectible(TaintedCollectibles.BUGULON_SUPER_FAN) then
            player.MoveSpeed = player.MoveSpeed + (0.3 * player:GetCollectibleNum(TaintedCollectibles.BUGULON_SUPER_FAN))
        end
		if data.GerminatedStacks then
			player.MoveSpeed = player.MoveSpeed + (0.15 * data.GerminatedStacks)
		end
		if player:HasCollectible(TaintedCollectibles.LEVIATHAN) then
			if savedata.LeviathanPurified then
				player.MoveSpeed = player.MoveSpeed + (0.2 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			else
				player.MoveSpeed = player.MoveSpeed - (0.1 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			end
		end
    
	--Luck
	elseif cacheFlag & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK then
		if savedata.SkeletonLockBuffs then
			savedata.SkeletonLockBuffs.Luck = savedata.SkeletonLockBuffs.Luck or 0
			player.Luck = player.Luck + savedata.SkeletonLockBuffs.Luck
		end
		if data.TaintedWhoreOfGalilee then
			player.Luck = player.Luck + (1 * player:GetCollectibleNum(TaintedCollectibles.WHORE_OF_GALILEE))
		end
		if player:HasCollectible(TaintedCollectibles.BUGULON_SUPER_FAN) then
            player.Luck = player.Luck + (1 * player:GetCollectibleNum(TaintedCollectibles.BUGULON_SUPER_FAN))
        end
		if data.GerminatedStacks then
			player.Luck = player.Luck + (3 * data.GerminatedStacks)
		end
		if player:HasCollectible(TaintedCollectibles.LEVIATHAN) then
			if savedata.LeviathanPurified then
				player.Luck = player.Luck + (3 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			else
				player.Luck = player.Luck - (10 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			end
		end
    
	--Range
	elseif cacheFlag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then
		if savedata.SkeletonLockBuffs then
			savedata.SkeletonLockBuffs.Range = savedata.SkeletonLockBuffs.Range or 0
			player.TearRange = player.TearRange + savedata.SkeletonLockBuffs.Range
		end
		if data.TaintedWhoreOfGalilee then
			player.TearRange = player.TearRange + (60 * player:GetCollectibleNum(TaintedCollectibles.WHORE_OF_GALILEE))
		end
		if player:HasCollectible(TaintedCollectibles.ARROWHEAD) then
            player.TearRange = player.TearRange + (120 * player:GetCollectibleNum(TaintedCollectibles.ARROWHEAD))
        end
		if player:HasCollectible(TaintedCollectibles.POLYCORIA) then
            player.TearRange = player.TearRange + (120 * player:GetCollectibleNum(TaintedCollectibles.POLYCORIA))
        end
		if data.GerminatedStacks then
			player.TearRange = player.TearRange + (120 * data.GerminatedStacks)
		end
		if player:HasCollectible(TaintedCollectibles.LEVIATHAN) then
			if savedata.LeviathanPurified then
				player.TearRange = player.TearRange + (60 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			else
				player.TearRange = player.TearRange - (30 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			end
		end

	--Shot Speed
	elseif cacheFlag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then
		if savedata.SkeletonLockBuffs then
			savedata.SkeletonLockBuffs.ShotSpeed = savedata.SkeletonLockBuffs.ShotSpeed or 0
			player.ShotSpeed = player.ShotSpeed + savedata.SkeletonLockBuffs.ShotSpeed
		end
		if player:HasCollectible(TaintedCollectibles.ARROWHEAD) then
            player.ShotSpeed = player.ShotSpeed + (0.3 * player:GetCollectibleNum(TaintedCollectibles.ARROWHEAD))
        end
		if player:HasCollectible(TaintedCollectibles.COLORED_CONTACTS) then
			player.ShotSpeed = player.ShotSpeed - 0.15
		end
		if data.GerminatedStacks then
			player.ShotSpeed = player.ShotSpeed + (0.15 * data.GerminatedStacks)
		end
		if player:HasCollectible(TaintedCollectibles.LEVIATHAN) then
			if savedata.LeviathanPurified then
				player.ShotSpeed = player.ShotSpeed + (0.15 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			else
				player.ShotSpeed = player.ShotSpeed - (0.15 * player:GetCollectibleNum(TaintedCollectibles.LEVIATHAN))
			end
		end
		if player:HasCollectible(TaintedCollectibles.EVANGELISM) then
            player.ShotSpeed = player.ShotSpeed - (0.3 * player:GetCollectibleNum(TaintedCollectibles.EVANGELISM))
        end

	--Familiars
	elseif cacheFlag & CacheFlag.CACHE_FAMILIARS == CacheFlag.CACHE_FAMILIARS then
		for _, entry in pairs(mod.FamiliarsToEvaluate) do
			player:CheckFamiliar(entry[1], mod:GetExpectedFamiliarNum(player, entry[2]), RNG(), itemconfig:GetCollectible(entry[2]))
		end

		if savedata.LilAbyssLocusts then
			--Locusts of Subtype 0 make a poof effect every new room, looks ugly
			--Let's use Inner Eye locusts (which are unlikely to be made unique in the future since the synergy is it spawning three normal locusts)
			player:CheckFamiliar(FamiliarVariant.ABYSS_LOCUST, savedata.LilAbyssLocusts, RNG(), nil, 2) 
		end
		
		--Contract of Servitude
		for _, entry in pairs(mod.ContractsToEvaluate) do
			if entry[2] == player:GetPlayerType() then
				player:CheckFamiliar(entry[1], mod:GetExpectedFamiliarNum(player, TaintedCollectibles.CONTRACT_OF_SERVITUDE), RNG(), itemconfig:GetCollectible(TaintedCollectibles.CONTRACT_OF_SERVITUDE))
			end
		end
		if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
			player:CheckFamiliar(FamiliarVariant.WISP, mod:GetExpectedFamiliarNum(player, TaintedCollectibles.CONTRACT_OF_SERVITUDE), RNG(), itemconfig:GetCollectible(TaintedCollectibles.CONTRACT_OF_SERVITUDE), TaintedCollectibles.CONTRACT_OF_SERVITUDE)
		end
		if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
			player:CheckFamiliar(TaintedFamiliars.SOUL_SISTER, mod:GetExpectedFamiliarNum(player, TaintedCollectibles.CONTRACT_OF_SERVITUDE), RNG(), itemconfig:GetCollectible(TaintedCollectibles.CONTRACT_OF_SERVITUDE))
			for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, TaintedFamiliars.BONE_SISTER)) do
				if GetPtrHash(entity:ToFamiliar().Player) == GetPtrHash(player) then
					entity:Remove()
				end
			end
		end
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
			player:CheckFamiliar(TaintedFamiliars.BONE_SISTER, mod:GetExpectedFamiliarNum(player, TaintedCollectibles.CONTRACT_OF_SERVITUDE), RNG(), itemconfig:GetCollectible(TaintedCollectibles.CONTRACT_OF_SERVITUDE))
			for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, TaintedFamiliars.SOUL_SISTER)) do
				if GetPtrHash(entity:ToFamiliar().Player) == GetPtrHash(player) then
					entity:Remove()
				end
			end
		end
		if player:GetPlayerType() == PlayerType.PLAYER_CAIN_B then
			savedata.ConsumedTrueSightCount = savedata.ConsumedTrueSightCount or 0
			player:CheckFamiliar(TaintedFamiliars.TRUE_SIGHT, mod:GetExpectedFamiliarNum(player, TaintedCollectibles.CONTRACT_OF_SERVITUDE) - savedata.ConsumedTrueSightCount, RNG(), itemconfig:GetCollectible(TaintedCollectibles.CONTRACT_OF_SERVITUDE))
		end
	
	--Tear Flags
	elseif cacheFlag & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG then
		if data.CancelStarEffect then
			player.TearFlags = player.TearFlags & ~TearFlags.TEAR_HOMING
		end
	end
end)

mod.FamiliarsToEvaluate = {
	{TaintedFamiliars.BASILISK, TaintedCollectibles.BASILISK},
	{TaintedFamiliars.LIL_ABYSS, TaintedCollectibles.LIL_ABYSS},
	{TaintedFamiliars.SWORDFISH, TaintedCollectibles.SWORD},
}

mod.ContractsToEvaluate = {
	{TaintedFamiliars.BLUEBABYS_BEST_FRIEND, PlayerType.PLAYER_BLUEBABY},
	{TaintedFamiliars.BELIAL_BOY, PlayerType.PLAYER_JUDAS},
	{TaintedFamiliars.BELPHEGOR, PlayerType.PLAYER_AZAZEL_B},
	{TaintedFamiliars.BYGONE, PlayerType.PLAYER_BLUEBABY_B},
	{TaintedFamiliars.ASMODEUS, PlayerType.PLAYER_LILITH},
	{TaintedFamiliars.GLUTTON_BABY, PlayerType.PLAYER_MAGDALENE},
	{TaintedFamiliars.STIMS, PlayerType.PLAYER_SAMSON},
}

function mod:AddPostCacheCallback()
	mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
		local data = player:GetData()
		local savedata = mod.GetPersistentPlayerData(player)

		if cacheFlag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
			if player:HasCollectible(TaintedCollectibles.CRICKETS_CRANIUM) then
				local craniumdamage = (0.5+player.Damage)*2
				if not savedata.craniumcap then
					savedata.craniumcap = craniumdamage
					player.Damage = savedata.craniumcap
				elseif savedata.craniumcap and craniumdamage >= savedata.craniumcap then
					player.Damage = savedata.craniumcap
				else 
					player.Damage = craniumdamage
				end
			elseif savedata.craniumcap then
				savedata.craniumcap = nil
			end
		end

		if player:HasCollectible(TaintedCollectibles.RAVENOUS) and not mod.RavenousBool then
			mod.RavenousBool = true
			player:AddCacheFlags(CacheFlag.CACHE_ALL)
			player:EvaluateItems()
			savedata.RavenousEval = true
			mod.RavenousBool = false
			--mod:RavenousStatEvaluation(player)
		end
	end)
end

function mod:GetPlayerDamageMult(player) --from Fiend Folio, modified to account for repentance and Tainted Treasures
	local mult = 1
	player = player:ToPlayer()
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) or player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) then
		mult = mult * 1.5
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA) then
		mult = mult * 2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) and player:GetEffectiveMaxHearts() <= player:GetHearts() then
		mult = mult * 2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
		mult = mult * 1.31
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ODD_MUSHROOM_RATE) then
		mult = mult * 0.9
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) then
		mult = mult * 2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then
		mult = mult * 2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART) then
		mult = mult * 2.3
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then
		mult = mult * 0.3
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then --Almond Milk overrides Soy Milk's multiplier
		mult = mult * 0.2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
		mult = mult * 0.65
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
		mult = mult * 0.75
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_IMMACULATE_HEART) then
		mult = mult * 1.2
	end
	if player:HasCollectible(TaintedCollectibles.CRICKETS_CRANIUM) then --Tainted items start here
		mult = mult * 2
	end
	
	if player:GetPlayerType() == PlayerType.PLAYER_CAIN then
		mult = mult * 1.2
	elseif player:GetPlayerType() == PlayerType.PLAYER_JUDAS then
		mult = mult * 1.35
	elseif player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY then
		mult = mult * 1.05
	elseif player:GetPlayerType() == PlayerType.PLAYER_EVE and player:GetHearts() > 2 then
		mult = mult * 0.75
	elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL then
		mult = mult * 1.5
	elseif player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2 then
		mult = mult * 1.2
	elseif player:GetPlayerType() == PlayerType.PLAYER_KEEPER then
		mult = mult * 1.2
	elseif player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		mult = mult * 1.5
	elseif player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE_B then
		mult = mult * 0.75
	elseif player:GetPlayerType() == PlayerType.PLAYER_EVE_B then
		mult = mult * 1.2
	elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then
		mult = mult * 1.5
	elseif player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
		mult = mult * 1.5
	elseif player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
		mult = mult * 1.3
	elseif player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
		mult = mult * 1.5
	end
	
	return mult
end