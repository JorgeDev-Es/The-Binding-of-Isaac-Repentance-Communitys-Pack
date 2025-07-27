local mod = FiendFolio
local game = Game()

function mod:warmGeodeUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.WARM_GEODE) then
		local level = game:GetLevel()
		local fireNearby = false
        for _, fire in ipairs(Isaac.FindByType(33, -1, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 and fire.HitPoints > 1 then
				fireNearby = true
			end
        end
		for _,fire in ipairs(Isaac.FindByType(1000, EffectVariant.HOT_BOMB_FIRE, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 then
				fireNearby = true
			end
		end
		for _,fire in ipairs(Isaac.FindByType(1000, EffectVariant.BLUE_FLAME, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 then
				fireNearby = true
			end
		end
		for _,fire in ipairs(Isaac.FindByType(1000, EffectVariant.RED_CANDLE_FLAME, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 then
				fireNearby = true
			end
		end
		for _,fire in ipairs(Isaac.FindByType(1000, EffectVariant.FIRE_JET, -1, false, false)) do
			if fire.Position:Distance(player.Position) <= 80 then
				fireNearby = true
			end
		end
		local stage = level:GetStage()
		local stageType = level:GetStageType()
		if fireNearby == true then
			if mod.HasTwoGeodes(player) then
				data.warmGeodeBonus = 2
				data.warmGeodeDamage = 5
			else
				data.warmGeodeBonus = 1
				data.warmGeodeDamage = 3
			end
		elseif ((stage == LevelStage.STAGE1_1 or stage == LevelStage.STAGE1_2) and stageType == StageType.STAGETYPE_AFTERBIRTH) or ((stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B) and (stage == LevelStage.STAGE2_1 or stage == LevelStage.STAGE2_2)) then
			data.warmGeodeBonus = 1
			data.warmGeodeDamage = 1.5
		else		
			data.warmGeodeBonus = nil
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:EvaluateItems()
	end
end

function mod:warmGeodeOnFireTear(player, tear, secondHand)
	if player:GetData().warmGeodeBonus == 2 then
		--[[tear:AddTearFlags(TearFlags.TEAR_BURN)
		local color = Color(1, 1, 1, 1, 0.25, 0.1, 0)
		color:SetColorize(1, 0.75, 0.2, 1)
		tear.Color = color
		tear:Update()]]
		tear:ChangeVariant(5)
		local td = tear:GetData()
		td.ApplyBurn = true
		td.ApplyBurnDuration = 60*secondHand
		td.ApplyBurnDamage = player.Damage
		tear:Update()
	end
end

function mod:warmGeodeOnFireBomb(player, bomb)
	if player:GetData().warmGeodeBonus == 2 then
		bomb.Flags = bomb.Flags | TearFlags.TEAR_BURN

		local color = Color(1, 1, 1, 1, 0.25, 0.1, 0)
		color:SetColorize(1, 0.75, 0.2, 1)
		bomb.Color = color
	end
end

function mod:warmGeodeOnFireRocket(player, target, secondHandMultiplier)
	if player:GetData().warmGeodeBonus == 2 then
		local data = target:GetData()
		data.ApplyBurn = true
		data.ApplyBurnDuration = 60 * secondHandMultiplier
        data.ApplyBurnDamage = player.Damage

        local color = Color(1, 1, 1, 1, 0.25, 0.1, 0)
		color:SetColorize(1, 0.75, 0.2, 1)
		data.FFExplosionColor = color
	end
end

function mod:warmGeodeKnife(player, ent, secondHand)
	if player:GetData().warmGeodeBonus == 2 then
		ent:AddBurn(EntityRef(player), 60*secondHand, player.Damage)
	end
end

function mod:warmGeodeLaser(player, ent, secondHand)
	if player:GetData().warmGeodeBonus == 2 then
		ent:AddBurn(EntityRef(player), 60*secondHand, player.Damage)
	end
end

function mod:warmGeodeDarkArts(player, ent, secondHand)
	if player:GetData().warmGeodeBonus == 2 then
		ent:AddBurn(EntityRef(player), 60*secondHand, player.Damage)
	end
end

function mod:warmGeodeAquarius(player, creep, secondHand)
	if player:GetData().warmGeodeBonus == 2 then
		local data = creep:GetData()
		data.ApplyBurn = true
		data.ApplyBurnDuration = 60 * secondHand
        data.ApplyBurnDamage = player.Damage

        local color = Color(0.5, 0.5, 0.2, 1, 0.7, 0.3, 0)
		color:SetColorize(1, 0.75, 0, 1)
		data.FFAquariusColor = color
	end
end