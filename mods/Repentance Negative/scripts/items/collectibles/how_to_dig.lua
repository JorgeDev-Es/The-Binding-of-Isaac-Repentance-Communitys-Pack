local Mod = RepMMod
local game = Mod.Game
local sfx = SFXManager()
local hiddenItemManager = Mod.hiddenItemManager

---@param player EntityPlayer
---@param button ButtonAction
---@return boolean
local function DontRegisterInput(player, button)
	if
		button == ButtonAction.ACTION_ITEM
			and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= Mod.RepmTypes.COLLECTIBLE_HOW_TO_DIG
		or button == ButtonAction.ACTION_BOMB
		or button == ButtonAction.ACTION_DROP
	then
		return true
	end
	if button == ButtonAction.ACTION_PILLCARD then
		local pItem = player:GetPocketItem(PillCardSlot.PRIMARY)
		if pItem then
			if pItem:GetType() ~= PocketItemType.ACTIVE_ITEM then
				return true
			elseif
				pItem:GetType() == PocketItemType.ACTIVE_ITEM
				and player:GetActiveItem(pItem:GetSlot() - 1) ~= Mod.RepmTypes.COLLECTIBLE_HOW_TO_DIG
			then
				return true
			end
		end
	end
	return false
end

---@param ent Entity
---@param hook InputHook
---@param button ButtonAction
local function useDigInput(_, ent, hook, button)
	if ent and ent:ToPlayer() then
		local player = ent:ToPlayer()
		local effs = player:GetEffects()
		if effs:HasNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG) then
			if DontRegisterInput(player, button) then
				return false
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, useDigInput)

---@param col CollectibleType | integer
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag | integer
---@param slot ActiveSlot | integer
---@param vardata integer
---@return table | boolean?
local function useDig(_, col, rng, player, flags, slot, vardata)
	local effs = player:GetEffects()
	if player:IsExtraAnimationFinished() then
		if not effs:HasNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG) then
			player:PlayExtraAnimation("Trapdoor")
			Isaac.CreateTimer(function()
				effs:AddNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG)
				player:DischargeActiveItem(slot)
				sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, Options.SFXVolume * 2)
				Isaac.Spawn(
					EntityType.ENTITY_EFFECT,
					EffectVariant.ROCK_EXPLOSION,
					0,
					player.Position,
					Vector.Zero,
					nil
				)
				for i = 1, 3 do
					Isaac.Spawn(
						EntityType.ENTITY_EFFECT,
						EffectVariant.ROCK_PARTICLE,
						0,
						game:GetRoom():GetGridPosition(game:GetRoom():GetGridIndex(player.Position)),
						RandomVector() * math.random() * 5,
						player
					)
				end
			end, player:GetSprite():GetAnimationData("Trapdoor"):GetLength() - 1, 1, false)
		else
			effs:RemoveNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG, -1)
		end
	end
	return {
		Discharge = false,
		Remove = false,
		ShowAnim = false,
	}
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, useDig, Mod.RepmTypes.COLLECTIBLE_HOW_TO_DIG)

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, function(_, slot, player, curMinCharge)
	if player:GetEffects():HasNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG) then
		return 0
	end
end, Mod.RepmTypes.COLLECTIBLE_HOW_TO_DIG)

---@param player EntityPlayer
---@param conf ItemConfigItem
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, function(_, player, conf)
	if conf:IsNull() and conf.ID == Mod.RepmTypes.NULL_HOW_TO_DIG and not player:IsDead() then
		player:PlayExtraAnimation("Jump")
		for i = 1, 3 do
			Isaac.Spawn(
				EntityType.ENTITY_EFFECT,
				EffectVariant.ROCK_PARTICLE,
				0,
				game:GetRoom():GetGridPosition(game:GetRoom():GetGridIndex(player.Position)),
				RandomVector() * math.random() * 5,
				player
			)
		end
		sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, Options.SFXVolume * 2)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, 0, player.Position, Vector.Zero, nil)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
			--table.insert(points, { point = player, dmg = player.Damage })
			for _, dir in pairs({ 0, 90, 180, 270 }) do
				CustomShockwaveAPI:SpawnCustomCrackwave(player.Position, player, 40, dir, 4, -1, player.Damage * 7)
			end
		end
	end
end)

---@param player EntityPlayer
---@param cacheFlag CacheFlag | integer
local function digCache(_, player, cacheFlag)
	if player:GetEffects():HasNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed * 0.5
		end
		if cacheFlag == CacheFlag.CACHE_FLYING then
			player.CanFly = false
		end
		if cacheFlag == CacheFlag.CACHE_COLOR then
			local color = player.Color
			color.A = 0
			player.Color = color
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, digCache)

---@param player EntityPlayer
local function DigPlayerUpdate(_, player)
	local effs = player:GetEffects()
	if effs:HasNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG) then
		player.FireDelay = math.max(2, player.FireDelay)
		if game:GetFrameCount() % 4 == 0 then
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, Options.SFXVolume / 3)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, 0, player.Position, Vector.Zero, player)
				:ToEffect()
			Game():BombDamage(player.Position, player.Damage / 5, 20, false, player)
		end
		local activeMain = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		local activeSecond = player:GetActiveItem(ActiveSlot.SLOT_SECONDARY)
		local activePocket = player:GetActiveItem(ActiveSlot.SLOT_POCKET)
		if activeMain > 0 and activeSecond > 0 and activeMain ~= Mod.RepmTypes.COLLECTIBLE_HOW_TO_DIG then
			player:SwapActiveItems()
		end
	end
	hiddenItemManager:CheckStack(
		player,
		CollectibleType.COLLECTIBLE_LEO,
		effs:GetNullEffectNum(Mod.RepmTypes.NULL_HOW_TO_DIG),
		"Repm_HowToDig"
	)
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DigPlayerUpdate)

local function OnPlayerCollide_Dig(_, player, collider)
	if player:GetEffects():HasNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG) then
		return true
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, OnPlayerCollide_Dig)

local function OnPlayerDamage_Dig(_, entity, amount, damageflags, source, countdownframes)
	local player = entity:ToPlayer()
	if player == nil then
		return
	end

	if player:GetEffects():HasNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG) then
		return false
	end
end
Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnPlayerDamage_Dig, EntityType.ENTITY_PLAYER)

local function DoorUpdateDig(_, door)
	local entities = Isaac.FindInRadius(door.Position, 30)
	if not door:IsOpen() and door:CanBlowOpen() then
		for i, entity in ipairs(entities) do
			if
				entity
				and entity:ToPlayer() ~= nil
				and entity:ToPlayer():GetEffects():HasNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG)
			then
				door:TryBlowOpen(false, entity:ToPlayer())
				sfx:Play(SoundEffect.SOUND_WOOD_PLANK_BREAK)
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, DoorUpdateDig)

---@param player EntityPlayer
---@param idx integer
---@param grid GridEntity
---@return boolean?
local function PitCollisionInDig(_, player, idx, grid)
	if player:GetEffects():GetNullEffect(Mod.RepmTypes.NULL_HOW_TO_DIG) and grid then
		if grid:GetType() == GridEntityType.GRID_PIT then
			return nil
		end
		return true
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, PitCollisionInDig, PlayerVariant.PLAYER)
