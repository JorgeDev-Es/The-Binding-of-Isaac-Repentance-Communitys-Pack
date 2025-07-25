local Mod = RepMMod

local PixelatedCubeBabiesList = {}
local config = Isaac.GetItemConfig()

local function PixelatedCubeUse(_, itemID, rng, player)
	-- pixelated cube
	if #PixelatedCubeBabiesList == 0 then
		for id = 1, config:GetCollectibles().Size do
			local item = config:GetCollectible(id)
			if item and item:HasTags(ItemConfig.TAG_MONSTER_MANUAL) then
				PixelatedCubeBabiesList[#PixelatedCubeBabiesList + 1] = id
			end
		end
	end
	local BabyNumber = PixelatedCubeBabiesList[rng:RandomInt(1, 30)]
	player:GetEffects():AddCollectibleEffect(BabyNumber, false)
	local BabyNumber = PixelatedCubeBabiesList[rng:RandomInt(1, 30)]
	player:GetEffects():AddCollectibleEffect(BabyNumber, false)
	local BabyNumber = PixelatedCubeBabiesList[rng:RandomInt(1, 30)]
	player:GetEffects():AddCollectibleEffect(BabyNumber, false)
	return {
		Discharge = true,
		Remove = false,
		ShowAnim = true,
	}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, PixelatedCubeUse, Mod.RepmTypes.COLLECTIBLE_PIXELATED_CUBE)