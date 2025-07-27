local mod = FiendFolio
local game = Game()

function mod.TriggerEvent(id)
	local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, false, false)
	local tile = room:GetGridIndex(pos)

	room:SpawnGridEntity(tile, 20, 10 + id, 0, 0)
	local button = room:GetGridEntity(tile)

	local sprite = button:GetSprite()
	sprite:ReplaceSpritesheet(0, "")
	sprite:LoadGraphics()

	button:ToPressurePlate():Reward()
	room:RemoveGridEntity(tile, 0, false)
end

mod.EnemyTriggerHostBlacklist = {}

local function isEntityDead(entity)
	return (
		entity:IsDead() or
		mod:isStatusCorpse(entity) or
		not entity:Exists()
	)
end

local function createEntitiesCache()
	mod.RoomEntitiesCache = Isaac.GetRoomEntities()
	return mod.RoomEntitiesCache
end

local function getRoomEntitiesCache()
	return mod.RoomEntitiesCache or createEntitiesCache()
end

local function canEntityBeTargeted(entity)
	return (
		entity:IsEnemy() and
		not isEntityDead(entity) and
		not entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) and
		not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
	)
end

local function getClosestEnemy(postion, excludeFiresAndTNT)
	local closest
	local distance = 9e9

	for _, entity in pairs(getRoomEntitiesCache()) do
		if canEntityBeTargeted(entity) and (not excludeFiresAndTNT or (entity.Type ~= 33 and entity.Type ~= 292)) then
			if postion:Distance(entity.Position) < distance then
				closest = entity
				distance = postion:Distance(entity.Position)
			end
		end
	end

	return closest
end

mod.CustomTriggers = {
	[0] = function(effect)
		local data = effect:GetData()

		if data.targets then
			local anyTargetAlive = false

			for _, entity in pairs(data.targets) do
				if not isEntityDead(entity) then
					anyTargetAlive = true
					--print("any target alive")
				end
			end

			if not anyTargetAlive then
				mod.TriggerEvent(effect.SubType)
				effect:Remove()
			end
		else
			data.targets = {getClosestEnemy(effect.Position)}

			for _, other in pairs(Isaac.FindByType(effect.Type, effect.Variant, effect.SubType)) do
				if GetPtrHash(other) ~= GetPtrHash(effect) then
					table.insert(data.targets, getClosestEnemy(other.Position))
					other:Remove()
				end
			end
		end
	end,

	[10] = function(effect)
		if not getClosestEnemy(effect.Position, true) then
			--print("hm?")
			mod.TriggerEvent(effect.SubType - 10)
			effect:Remove()
		end
	end,
}

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect:Exists() then
		--print("trigger", effect.SubType)

		if effect.SubType < 10 then
			mod.CustomTriggers[0](effect)
		elseif effect.SubType < 20 then
			mod.CustomTriggers[10](effect)
		end
	end
end, mod.FF.CustomEventTrigger.Var)