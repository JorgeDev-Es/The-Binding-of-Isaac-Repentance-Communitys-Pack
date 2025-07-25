local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local SPEED = {1.5, 10, 20} -- Default, minimum and maximum speed
local DAMAGE = {3.5, 1.5, 1.5} -- Default, per luck and minimum damage

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	local itemConfig = Isaac.GetItemConfig():GetCollectible(mod.Collectible.COMETA)
	local itemNum = mod.GetExpectedFamiliarNum(player, mod.Collectible.COMETA)
	local itemRNG = player:GetCollectibleRNG(mod.Collectible.COMETA)

	player:CheckFamiliar(mod.Familiar.COMETA, itemNum, itemRNG, itemConfig)
end, CacheFlag.CACHE_FAMILIARS)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	player.Luck = player.Luck + player:GetCollectibleNum(mod.Collectible.COMETA)
end, CacheFlag.CACHE_LUCK)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local famData = mod.GetEntityData(fam)
	local famOffset = fam:GetNullOffset("*pos")
	local famLayer = fam:GetSprite():GetLayer("body")
	local player = fam.Player
	
	local nearestEntity = mod.GetNearestEntity(fam, function(entity)
		return mod.IsActiveVulnerableEnemy(entity) or entity:ToPlayer()
	end)
	if nearestEntity then
		fam.TargetPosition = nearestEntity.Position
	end
	
	local famPos = game:GetRoom():GetClampedPosition(fam.Position, 0)
	local famPush = (famPos - fam.Position):Resized(SPEED[1] * 2) -- Pushes the familiar away from walls
	local famSeek = (fam.TargetPosition - fam.Position):Resized(SPEED[1]) -- Slowly moves towards the target position
	
	fam:AddVelocity(famPush + famSeek)
	
	for _, otherFam in pairs(Isaac.FindInRadius(fam.Position, fam.Size, EntityPartition.FAMILIAR)) do
		if otherFam.Variant == mod.Familiar.COMETA and GetPtrHash(fam) ~= GetPtrHash(otherFam) then
			fam:AddVelocity((fam.Position - otherFam.Position):Resized(SPEED[1] * 0.5))
		end
	end
	fam.Velocity = mod.ClampVector(fam.Velocity, SPEED[2], SPEED[3])
	famLayer:SetRotation(mod.LerpAngle(famLayer:GetRotation() + 5, fam.Velocity:GetAngleDegrees(), 0.035, true))
	fam.CollisionDamage = math.max(DAMAGE[1] + player.Luck * DAMAGE[2], DAMAGE[3])
	
	if not famData.TrailEntity or not famData.TrailEntity:Exists() then
		famData.TrailEntity = mod.AttachTrail(fam, 0.075, 3, Color(0.52, 0.64, 0.8), famOffset)
	end
	if not famData.BlingCooldown or famData.BlingCooldown <= 0 then
		local effect = Isaac.Spawn(
			EntityType.ENTITY_EFFECT, EffectVariant.ULTRA_GREED_BLING, 0, 
			fam.Position, Vector.Zero, fam):ToEffect()
		effect.Color = Color(1, 1, 1, 1, 0, 0, 0, 0.52, 0.64, 0.8, 1)
		effect.PositionOffset = famOffset + RandomVector() * mod.RandomFloatRange(10, 20)
		effect:GetSprite().PlaybackSpeed = 0.5
		
		famData.BlingCooldown = mod.RandomIntRange(3, 9)
	else
		famData.BlingCooldown = famData.BlingCooldown - 1
	end
end, mod.Familiar.COMETA)

-----------------
-- << DEBUG >> --
-----------------
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, fam, offset)
	if game:GetDebugFlags() & DebugFlag.ENTITY_POSITIONS > 0 then
		local startPos = Isaac.GetRenderPosition(fam.Position)
		local endPos = Isaac.GetRenderPosition(fam.TargetPosition)
		
		Isaac.DrawLine(startPos + offset, endPos + offset, KColor.Magenta, KColor.Magenta)
	end
end, mod.Familiar.COMETA)