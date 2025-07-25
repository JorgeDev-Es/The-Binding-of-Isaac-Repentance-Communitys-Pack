local Mod = RepMMod
local game = Game()
local hiddenItemManager = Mod.hiddenItemManager
local SaveManager = Mod.saveManager

local function CanDropOtherTrinket(t1, t2, isMatchStick)
	return t1 == Mod.RepmTypes.TRINKET_FROZEN_POLAROID
	and (t2 == TrinketType.TRINKET_TICK and isMatchStick or t2 ~= TrinketType.TRINKET_TICK)
	or t2 == Mod.RepmTypes.TRINKET_FROZEN_POLAROID
	and (t1 == TrinketType.TRINKET_TICK and isMatchStick or t1 ~= TrinketType.TRINKET_TICK)
end

local function stickyTrinket(_, pickup, collider, low)
	if not collider:ToPlayer() or not collider:ToPlayer():HasTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID) then
		return nil
	end
	local player = collider:ToPlayer()
	---@cast player EntityPlayer
	if
		player:GetTrinket(0) ~= Mod.RepmTypes.TRINKET_FROZEN_POLAROID
		and player:GetTrinket(1) ~= Mod.RepmTypes.TRINKET_FROZEN_POLAROID
	then
		return nil
	end

	if player:GetMaxTrinkets() > 1 then
		local t1 = player:GetTrinket(0)
		local t2 = player:GetTrinket(1)
		if t1 ~= 0 and t2 ~= 0 and CanDropOtherTrinket(t1, t2, pickup.SubType == TrinketType.TRINKET_MATCH_STICK)  then
			player:TryRemoveTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID)
			player:DropTrinket(player.Position, true)
			player:AddTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID, false)
			return nil
		else
			return pickup:IsShopItem()
		end
	else
		return pickup:IsShopItem()
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, stickyTrinket, PickupVariant.PICKUP_TRINKET)

local function tryOpenDoor_Fro_Polaroid(_, player)
	--and player:CollidesWithGrid()
	if
		(
			game:GetLevel():GetStage() == LevelStage.STAGE3_2
			or (game:GetLevel():GetStage() == LevelStage.STAGE3_1 and Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0)
		)
		and game:GetLevel():GetStageType() <= StageType.STAGETYPE_AFTERBIRTH
		and player.Position.Y < 151
		and player.Position:Distance(Vector(320, 150)) <= 26
		and game:GetLevel():GetCurrentRoomIndex() == 84
		and player:HasTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID)
	then
		local door = game:GetRoom():GetDoor(1)
		if not door:IsOpen() then
			door:TryUnlock(player, true)
			player:TryRemoveTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID)
			Mod:RunSave().repM_FrostyUnlock = true
		end
	end
	if
		player:GetLastActionTriggers() & ActionTriggers.ACTIONTRIGGER_ITEMSDROPPED
		== ActionTriggers.ACTIONTRIGGER_ITEMSDROPPED
	then
		local trinkets = Isaac.FindByType(5, 350, Mod.RepmTypes.TRINKET_FROZEN_POLAROID)
		local respawnPolaroid = false
		for i, trinket in ipairs(trinkets) do
			if trinket.FrameCount == 0 then
				trinket:Remove()
				respawnPolaroid = true
				break
			end
		end -- not a great solution but let's see
		if respawnPolaroid then
			player:AddTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID)
		end
	end
    local pdata = Mod:GetData(player)
    if pdata.HoldingFrozenPolaroid ~= player:HasTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID) then
		if player:HasTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID) then
			hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_MORE_OPTIONS)
			hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_STEAM_SALE)
			local optionsConfig = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS)
			local steamConfig = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_STEAM_SALE)
			player:RemoveCostume(optionsConfig)
			player:RemoveCostume(steamConfig)
		elseif
			pdata.HoldingFrozenPolaroid == nil and player:HasTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID) == false
		then
			pdata.HoldingFrozenPolaroid = false -- redundant, i know
		else
			hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_MORE_OPTIONS, hiddenItemManager.kDefaultGroup)
			hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_STEAM_SALE, hiddenItemManager.kDefaultGroup)
		end
		pdata.HoldingFrozenPolaroid = player:HasTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, tryOpenDoor_Fro_Polaroid)
--5 350 195
function Mod:DebugText()
	local player = Isaac.GetPlayer(0) --this one is OK
	local coords = (player.Position):Distance(Vector(320, 150))
	--local coords = player.Position
	local debug_str = tostring(player.Position)
	--26
	Isaac.RenderText(debug_str, 100, 60, 1, 1, 1, 255)
end
--Mod:AddCallback(ModCallbacks.MC_POST_RENDER, Mod.DebugText)

local BasegameSegmentedEnemies = {
	[35 .. " " .. 0] = true, -- Mr. Maw (body)
	[35 .. " " .. 1] = true, -- Mr. Maw (head)
	[35 .. " " .. 2] = true, -- Mr. Red Maw (body)
	[35 .. " " .. 3] = true, -- Mr. Red Maw (head)
	[89] = true, -- Buttlicker
	[216 .. " " .. 0] = true, -- Swinger (body)
	[216 .. " " .. 1] = true, -- Swinger (head)
	[239] = true, -- Grub
	[244 .. " " .. 2] = true, -- Tainted Round Worm

	[19 .. " " .. 0] = true, -- Larry Jr.
	[19 .. " " .. 1] = true, -- The Hollow
	[19 .. " " .. 2] = true, -- Tuff Twins
	[19 .. " " .. 3] = true, -- The Shell
	[28 .. " " .. 0] = true, -- Chub
	[28 .. " " .. 1] = true, -- C.H.A.D.
	[28 .. " " .. 2] = true, -- The Carrion Queen
	[62 .. " " .. 0] = true, -- Pin
	[62 .. " " .. 1] = true, -- Scolex
	[62 .. " " .. 2] = true, -- The Frail
	[62 .. " " .. 3] = true, -- Wormwood
	[79 .. " " .. 0] = true, -- Gemini
	[79 .. " " .. 1] = true, -- Steven
	[79 .. " " .. 10] = true, -- Gemini (baby)
	[79 .. " " .. 11] = true, -- Steven (baby)
	[92 .. " " .. 0] = true, -- Heart
	[92 .. " " .. 1] = true, -- 1/2 Heart
	[93 .. " " .. 0] = true, -- Mask
	[93 .. " " .. 1] = true, -- Mask II
	[97] = true, -- Mask of Infamy
	[98] = true, -- Heart of Infamy
	[266] = true, -- Mama Gurdy
	[912 .. " " .. 0 .. " " .. 0] = true, -- Mother (phase one)
	[912 .. " " .. 0 .. " " .. 2] = true, -- Mother (left arm)
	[912 .. " " .. 0 .. " " .. 3] = true, -- Mother (right arm)
	[918 .. " " .. 0] = true, -- Turdlet
}

function Mod:isBasegameSegmented(entity)
	return BasegameSegmentedEnemies[entity.Type]
		or BasegameSegmentedEnemies[entity.Type .. " " .. entity.Variant]
		or BasegameSegmentedEnemies[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

local function checkEntityForChampionizing(entity)
	return not entity:IsChampion()
		and not entity:IsBoss()
		and Mod.RNG:RandomInt(8) == 1
		and not Mod:isBasegameSegmented(entity)
		and entity.Type ~= EntityType.ENTITY_FIREPLACE
end

local function OnEntitySpawn_Polar(_, npc)
	if PlayerManager.AnyoneHasTrinket ~= Mod.RepmTypes.TRINKET_FROZEN_POLAROID then
		if checkEntityForChampionizing(npc) == true then
			npc:MakeChampion(Mod.RNG:GetSeed())
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, OnEntitySpawn_Polar)

local function OnTakeHit_Polar(_, entity, amount, damageflags, source, countdownframes)
	local player = entity:ToPlayer()
	if player == nil then
		return
	end
	local data = Mod:RunSave(player)
	if amount == 1 and player:HasTrinket(Mod.RepmTypes.TRINKET_FROZEN_POLAROID) and not data.inPolaroidDamage then
		data.inPolaroidDamage = true
		return { Damage = amount + 1, DamageFlags = damageflags, DamageCountdown = countdownframes }
	end
	data.inPolaroidDamage = nil
end
Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnTakeHit_Polar, EntityType.ENTITY_PLAYER)