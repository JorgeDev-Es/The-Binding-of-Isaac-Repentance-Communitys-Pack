local Mod = RepMMod

local function CalculateBonuses(pos, neg)
	return {
		Speed = (pos - neg) * 0.1,
		Damage = 0.85 * pos - 0.75 * neg,
		FireDelay = 0.1 * (pos - neg),
		Range = (pos - neg) * 0.62,
	}
end

local MinusShardHud = setmetatable({
	Render = function(self, pos, crop_min, crop_max)
		crop_min = crop_min or Vector.Zero
		crop_max = crop_max or Vector.Zero

		if Game():GetFrameCount() % 2 == 0 and not Game():IsPaused() then
			self.spr:Update()
		end

		if self.spr:IsFinished() then
			self.State = "Idle"
		end

		if Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
			self.spr:Render(pos, crop_min, crop_max)
		end

		if
			not self.spr:IsPlaying(self.State)
			and (self.spr:GetCurrentAnimationData():IsLoopingAnimation() or self.spr:IsFinished())
		then
			self.spr:Play(self.State, true)
		end
	end,
	Update = function(self)
		self.spr:Update()
	end,
}, {
	__call = function (self)
        local c = setmetatable({
            State = "Idle",
            spr = Sprite("gfx/MinusStatus.anm2", true),
        }, {__index = self})
		c.spr:Play("Idle", true)
        return c
    end,
})

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	Mod:AnyPlayerDo(function(player)
		local data = RepMMod:GetData(player)
		data.MinusShard = nil
	end)
end)


---@param player EntityPlayer
---@param cache CacheFlag | integer
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
	local effects = player:GetEffects()
	local MinusPosBonusNum = effects:GetNullEffectNum(Mod.RepmTypes.NULL_MINUS_SHARD_POSITIVE_BONUS)
	local MinusNegaBonusNum = effects:GetNullEffectNum(Mod.RepmTypes.NULL_MINUS_SHARD_NEGATIVE_BONUS)
	local bonus = CalculateBonuses(MinusPosBonusNum, MinusNegaBonusNum)
	if cache == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + bonus.Speed
	end
	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + bonus.Damage
	end
	if cache == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = Mod.TearsUp(player.MaxFireDelay, bonus.FireDelay, 0.1)
	end
	if cache == CacheFlag.CACHE_RANGE then
		player.TearRange = Mod.RangeUp(player.TearRange, bonus.Range)
	end
end)

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, Entity, _, DamageFlags)
	if
		DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES == DamageFlag.DAMAGE_NO_PENALTIES
		or DamageFlags & DamageFlag.DAMAGE_FAKE == DamageFlag.DAMAGE_FAKE
		or DamageFlags & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS
	then
		return
	end
	local player = Entity:ToPlayer()
	---@cast player EntityPlayer
	local pEffects = player:GetEffects()

	if pEffects:GetNullEffectNum(Mod.RepmTypes.NULL_MINUS_SHARD) <= 0 then
		return
	end

	local data = Mod:GetData(player)
	data.MinusShard = data.MinusShard or MinusShardHud()
	data.MinusShard.State = "Damaged"

	player:SetColor(Color(1, 1, 1, 1, 1, 0, 0), 15, 0, true, true)

	pEffects:RemoveNullEffect(Mod.RepmTypes.NULL_MINUS_SHARD)
	if pEffects:GetNullEffectNum(Mod.RepmTypes.NULL_MINUS_SHARD) <= 0 then
		data.MinusShard.State = "Fade"
	end
	local Effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 97, 0, player.Position, Vector(0, 0), player)
	Effect.Color = Color(0.75, 0, 0, 1)
	Effect.SpriteScale = Vector(2, 2)
	SFXManager():Play(175, 1.25, 0, false, math.random(155, 175) / 100)
end, EntityType.ENTITY_PLAYER)

Mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	---@param player EntityPlayer
	Mod:AnyPlayerDo(function(player)
		local pEffects = player:GetEffects()
		if pEffects:GetNullEffectNum(Mod.RepmTypes.NULL_MINUS_SHARD) > 0 then
			SFXManager():Play(268, 1, 0, false, 1.5)
			player:SetColor(Color(1, 1, 1, 1, 0, 1, 0), 15, 0, true, true)
			pEffects:RemoveNullEffect(Mod.RepmTypes.NULL_MINUS_SHARD)
			pEffects:AddNullEffect(Mod.RepmTypes.NULL_MINUS_SHARD_POSITIVE_BONUS)
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end)
end)

---@param player EntityPlayer
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
	local data = RepMMod:GetData(player)
	local effects = player:GetEffects()
	data.MinusShard = data.MinusShard or MinusShardHud()
	if effects:GetNullEffectNum(Mod.RepmTypes.NULL_MINUS_SHARD) > 0 or data.MinusShard.State == "Fade" then
		data.MinusShard:Render(Isaac.WorldToScreen(player.Position))
	end
	--end
end)

---@param player EntityPlayer
Mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, _, player)
	player:GetEffects():AddNullEffect(Mod.RepmTypes.NULL_MINUS_SHARD, true, 2)
	player:GetEffects():AddNullEffect(Mod.RepmTypes.NULL_MINUS_SHARD_NEGATIVE_BONUS)
	local Effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 16, 1, player.Position, Vector(0, 0), player)
	Effect.Color = Color(0.75, 0, 0, 0.5)
	for _ = 1, 12 do
		local Effect = Isaac.Spawn(
			EntityType.ENTITY_EFFECT,
			35,
			1,
			player.Position,
			Vector(0, math.random(3, 9)):Rotated(math.random(360)),
			player
		)
		Effect.Color = Color(0.75, 0, 0, 1)
		Effect.SpriteScale = Vector(0.75, 0.75)
	end
	player:SetColor(Color(1, 1, 1, 1, 1, 0, 0), 60, 0, true, true)
	SFXManager():Play(33, 1, 0, false, 1.5)
	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end, Mod.RepmTypes.CARD_MINUS_SHARD)
