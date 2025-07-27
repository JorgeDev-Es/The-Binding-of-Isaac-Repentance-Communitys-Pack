local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local twinkleBoilCostume = Isaac.GetCostumeIdByPath("gfx/characters/twinkle_of_contagion2.anm2")

local function IsNpcInSight(npc, player)
	if not player then
		for i, player in pairs(mod:GetPlayersHoldingCollectible(mod.ITEM.COLLECTIBLE.TWINKLE_OF_CONTAGION)) do
			local degree = math.abs(mod:GetVectorFromDirection(player:GetHeadDirection()):GetAngleDegrees() - ((npc.Position - player.Position):GetAngleDegrees() % 360)) % 360
			if degree < 30 and game:GetRoom():CheckLine(player.Position, npc.Position, 3, 0, false, false) then
				return true
			end
		end
		return false
	else
		local degree = math.abs(mod:GetVectorFromDirection(player:GetHeadDirection()):GetAngleDegrees() - ((npc.Position - player.Position):GetAngleDegrees() % 360)) % 360
		return degree < 30 and game:GetRoom():CheckLine(player.Position, npc.Position, 3, 0, false, false)
	end
end

local function filter(_, npc)
	if not (npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) or npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:IsBoss() or IsNpcInSight(npc)) then
		return true
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
	if #mod:GetPlayersHoldingCollectible(mod.ITEM.COLLECTIBLE.TWINKLE_OF_CONTAGION) > 0 then
		if mod:RandomInt(1, 2) == 1 and not game:GetRoom():IsClear() then
			local enemy = mod:GetRandomElem(mod:GetAllEnemies(filter))
			if enemy then
				local aura = Isaac.Spawn(EntityType.ENTITY_EFFECT, 112, 0, enemy.Position, Vector.Zero, enemy):ToEffect()
				aura:GetSprite():Load("gfx/effects/effect_saltlamp.anm2")
				aura:SetColor(Color(1,1,1,0.8,0.5,0.5,0.5), 0, 0, false, false)
				aura:FollowParent(enemy)
				aura.DepthOffset = 100
				aura.SpriteOffset = Vector(0, -10)
				aura:GetData().TwinkleAura = true
				aura:GetData().TwinkleAuraEnemy = enemy
				aura.SpriteScale = aura.SpriteScale*1.25
			end
		end
		
		for i, player in pairs(mod:GetPlayersHoldingCollectible(mod.ITEM.COLLECTIBLE.TWINKLE_OF_CONTAGION)) do
			if player:GetData().HasTwinkle then
				player:GetData().HasTwinkle = false
				player:TryRemoveNullCostume(twinkleBoilCostume)
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_LUCK)
				player:EvaluateItems()
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local data = effect:GetData()
	if data.TwinkleAura then
		data.TwinkleBlink = data.TwinkleBlink or 0
		
		if effect.FrameCount % mod:RandomInt(10, 15) == 0 then
			for i = 1, mod:RandomInt(0,3) do
				local vel = RandomVector()*math.random()*4
				local sparkle = Isaac.Spawn(1000, 1727, 0, effect.Position+vel*5+Vector(0, -10), vel+effect.Velocity, effect):ToEffect()
				sparkle:SetColor(Color(1,1,1,1,0.4,0.4,0.4), 0, 0, false, false)
			end
		end
		
		if data.TwinkleAuraEnemy then
			if data.TwinkleAuraEnemy:IsDead() then
				local enemy = mod:GetRandomElem(mod:GetAllEnemies(filter))
				if enemy then
					effect.Position = enemy.Position
					effect:FollowParent(enemy)
					data.TwinkleAuraEnemy = enemy
					data.TwinkleBlink = 10
					sfx:Play(mod.Sounds.TwinklePass)
				else
					effect:Remove()
				end
			end
			for i, player in pairs(mod:GetPlayersHoldingCollectible(mod.ITEM.COLLECTIBLE.TWINKLE_OF_CONTAGION)) do
				if IsNpcInSight(data.TwinkleAuraEnemy, player) then
					effect.Position = player.Position
					effect:FollowParent(player)
					sfx:Play(mod.Sounds.TwinklePass)
					data.TwinkleAuraEnemy = nil
					data.TwinkleBlink = 10
					player:GetData().HasTwinkle = true
					player:AddNullCostume(twinkleBoilCostume)
					data.TwinkleAuraPlayer = player
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_LUCK)
					player:EvaluateItems()
				end
			end
		elseif data.TwinkleAuraPlayer then
			local player = data.TwinkleAuraPlayer
			if mod:RandomInt(1, 200) == 1 then
				local enemy = mod:GetRandomElem(mod:GetAllEnemies(filter))
				if enemy then
					effect.Position = enemy.Position
					effect:FollowParent(enemy)
					data.TwinkleAuraEnemy = enemy
					data.TwinkleBlink = 10
					player:GetData().HasTwinkle = false
					player:TryRemoveNullCostume(twinkleBoilCostume)
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_LUCK)
					player:EvaluateItems()
					sfx:Play(mod.Sounds.TwinklePass)
					data.TwinkleAuraPlayer = nil
				end
			end
		end
		
		if data.TwinkleBlink > 0 then
			data.TwinkleBlink = data.TwinkleBlink - 1
			effect.Visible = data.TwinkleBlink % 2 == 0
		else
			effect.Visible = true
		end
	end
end, 112)
