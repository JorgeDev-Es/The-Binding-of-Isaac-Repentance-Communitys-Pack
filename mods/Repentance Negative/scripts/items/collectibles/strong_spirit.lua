local Mod = RepMMod
local SaveManager = Mod.saveManager

local function UpdateStrongSpirit(player)
	local data = Mod:GetData(player)
	if data.StrongSpiritSS == nil then
		data.StrongSpiritSS = setmetatable({
			Render = function(self, pos, offset, crop_min, crop_max)
				self.spr.Offset = offset or Vector.Zero
				crop_min = crop_min or Vector.Zero
				crop_max = crop_max or Vector.Zero
				if self.spr:IsFinished("Fade") and self.Damage == true then
					return
				end
				if self.Damage == true then
					if not self.spr:IsPlaying("Fade") then
						self.spr:Play("Fade", true)
					end
				elseif not self.spr:IsPlaying("Idle") then
					self.spr:Play("Idle", true)
				end
				if Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
					self.spr:Render(pos, crop_min, crop_max)
				end
			end,
			SetDamaged = function(self, state)
				self.Damage = state
			end,
			Update = function(self)
				self.spr:Update()
			end,
		}, {
			__call = function(self)
				local c = setmetatable({
					Damage = false,
					spr = Sprite("gfx/SSStatus.anm2", true),
				}, { __index = self })
				return c
			end,
		})()
	end
	data.StrongSpiritSS:Update()
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	Mod:AnyPlayerDo(function(player)
		local pData = Mod:RunSave(player)
		pData.RepSSDamageBoost = nil
		pData.RepSSDamageD = nil
		if Mod:GetData(player).StrongSpiritSS then
			Mod:GetData(player).StrongSpiritSS:SetDamaged(false)
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_COLOR, true)
	end)
end)

Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE * 3, function(_, continue)
	if continue then
		Mod:AnyPlayerDo(function(player)
			if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_STRONG_SPIRIT) then
				local pData = Mod:RunSave(player)
				UpdateStrongSpirit(player)
				if Mod:GeData(player).StrongSpiritSS then
					Mod:GetData(player).StrongSpiritSS:SetDamaged(pData.RepSSDamageD or false)
				end
			end
		end)
	end
end)

---@param player EntityPlayer
---@param cache CacheFlag | integer
local function StrongSpiritCache(_, player, cache)
	local pdata = Mod:RunSave(player)
	if pdata.RepSSDamageBoost ~= nil and pdata.RepSSDamageBoost >= 0 then
		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + (5 / 600 * pdata.RepSSDamageBoost)
		elseif cache == CacheFlag.CACHE_COLOR then
			local col = player.Color
			col.BO = (1 / 600 * pdata.RepSSDamageBoost)
			player.Color = col
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, StrongSpiritCache)

local function StrongSpiritUpdate(_, player)
	local pdata = Mod:RunSave(player)
	if pdata.RepSSDamageBoost ~= nil and pdata.RepSSDamageBoost >= 0 then
		pdata.RepSSDamageBoost = pdata.RepSSDamageBoost - 1
		if pdata.RepSSDamageBoost == 0 then
			pdata.RepSSDamageBoost = nil
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_COLOR, true)
	end
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_STRONG_SPIRIT, true) then
		UpdateStrongSpirit(player)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, StrongSpiritUpdate)

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player, amount, DamageFlag)
	player = player:ToPlayer()
	---@cast player EntityPlayer
	if
		player:GetHearts() + player:GetBoneHearts() + player:GetSoulHearts() + player:GetRottenHearts() <= amount
		and player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_STRONG_SPIRIT, true)
	then
		local Data = Mod:RunSave(player)
		if Data.RepSSDamaged then
			return
		end
		Data.RepSSDamaged = true
		Mod:GetData(player).StrongSpiritSS:SetDamaged(true)
		Game():ShakeScreen(50)
		player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false, false, true, false, -1, 0)
		player:AddHearts(4)
		player:AddSoulHearts(2)
		Data.RepSSDamageBoost = 600
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_COLOR, true)
		--print(Data.RepSSDamageBoost)
		return false
	end
end, EntityType.ENTITY_PLAYER)

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
	local Data = Mod:GetData(player)
	if Data ~= nil and Data.StrongSpiritSS ~= nil then
		Data.StrongSpiritSS.spr.Scale = player:GetSprite().Scale * player.Size / 10
		Data.StrongSpiritSS:Render(Isaac.WorldToScreen(player.Position), Vector(0, 12))
	end
end)
