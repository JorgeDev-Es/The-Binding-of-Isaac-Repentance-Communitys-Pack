local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local DEAL_CHANCE = 0.35
local ETERNAL_HEART_NUM = 1

mod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, function(_, chance)
	if PlayerManager.AnyoneHasCollectible(mod.Collectible.COVENANT) then
		return chance + DEAL_CHANCE
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	local pickupRNG = RNG(pickup.InitSeed)
	local pickupData = mod.GetEntityData(pickup)
	local pickupConfig = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
	
	if PlayerManager.AnyoneHasCollectible(mod.Collectible.COVENANT) then
		if not pickupData.IsCovenantMarked and not pickup.Touched and not pickup:IsShopItem() then
			if pickupConfig and pickupRNG:RandomFloat() <= 1 / (2 ^ pickupConfig.Quality) then
				pickupData.IsCovenantMarked = true
			end
		end
	end
end, PickupVariant.PICKUP_COLLECTIBLE)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_COLLISION, function(_, player, collider)
	if player:CanPickupItem() and not player:IsHoldingItem() then
		local pickup = collider and collider:ToPickup()
		if not pickup then return end
		local pickupData = mod.GetEntityData(pickup)
		
		if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickupData.IsCovenantMarked and pickup.Wait <= 0 then
			pickupData.IsCovenantMarked = nil
			
			player:AddEternalHearts(ETERNAL_HEART_NUM)
			player:GetEffects():AddNullEffect(NullItemID.ID_LAZARUS_BOOST) -- Little hack to add +0.5 damage
			
			sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 0) -- Not the best way to prevent those sounds but it works so idk
			sfx:Play(SoundEffect.SOUND_POWERUP1, 0)
			sfx:Play(SoundEffect.SOUND_POWERUP2, 0)
			sfx:Play(SoundEffect.SOUND_POWERUP3, 0)
			sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL, 0)
			sfx:Play(mod.Sound.COVENANT_CHOIR)
		end
	end
end)

---------------------
-- << RENDERING >> --
---------------------
local indicatorSpr = Sprite("gfx/ui/indicator_covenant.anm2")

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup, offset)
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	
	if mod.GetEntityData(pickup).IsCovenantMarked then
		local xOffset, yOffset = math.sin(pickup.FrameCount * 0.1) * 3, -40 + math.sin(pickup.FrameCount * 0.2) * 2
		
		indicatorSpr:SetFrame("Idle", pickup.FrameCount % indicatorSpr:GetAnimationData("Idle"):GetLength())
		indicatorSpr:Render(Isaac.GetRenderPosition(pickup.Position + pickup.PositionOffset) + offset + Vector(xOffset, yOffset))
	end
end)