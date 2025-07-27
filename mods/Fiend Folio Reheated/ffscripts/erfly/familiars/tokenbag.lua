local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar.IsFollower = true
end, mod.ITEM.FAMILIAR.TOKEN_BAG)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()

	local payoutNum = 10
	if Sewn_API then
		if Sewn_API:IsUltra(data) then
			payoutNum = 8
		elseif Sewn_API:IsSuper(data) then
			payoutNum = 9
		end
	end
	if familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		payoutNum = payoutNum - 2
	end
	if familiar.Coins >= payoutNum then
		sprite:Play("Spawn", false)
		familiar.Coins = 0
	end
	if sprite:IsFinished("Spawn") then
		sprite:Play("FloatDown", false)
		local die = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.TOKEN, 0, familiar.Position, nilvector, familiar)
	end
	familiar:FollowParent()
end, mod.ITEM.FAMILIAR.TOKEN_BAG)

function mod:tokenBagRoomClear()
	for _, d in pairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.TOKEN_BAG, -1, false, false)) do
		familiar = d:ToFamiliar()
		familiar.Coins = familiar.Coins + 1
	end
end