local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	familiar.IsFollower = true
end, FamiliarVariant.DICE_BAG)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
    data.chances = data.chances or {
        Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6, Card.GLASS_D6,
        Card.GLASS_D4, Card.GLASS_D4, Card.GLASS_D4,
        Card.GLASS_D8, Card.GLASS_D8, Card.GLASS_D8, Card.GLASS_D8,
        Card.GLASS_D100,
        Card.GLASS_D10, Card.GLASS_D10, Card.GLASS_D10, Card.GLASS_D10,
        Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20, Card.GLASS_D20,
        Card.GLASS_D12, Card.GLASS_D12, Card.GLASS_D12, Card.GLASS_D12,
        Card.GLASS_SPINDOWN,
        Card.GLASS_AZURITE_SPINDOWN,Card.GLASS_AZURITE_SPINDOWN,
        mod.ITEM.CARD.GLASS_D2, mod.ITEM.CARD.GLASS_D2, mod.ITEM.CARD.GLASS_D2,
    }
	local payoutNum = 8
	if Sewn_API then
		if Sewn_API:IsUltra(data) then
			payoutNum = 4
		elseif Sewn_API:IsSuper(data) then
			payoutNum = 6
		end
	end
	if familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		payoutNum = math.ceil(payoutNum / 2)
	end
	if familiar.Coins >= payoutNum then
		sprite:Play("Spawn", false)
		familiar.Coins = 0
	end
	if sprite:IsFinished("Spawn") then
		sprite:Play("FloatDown", false)
		local die = Isaac.Spawn(5, 300, data.chances[familiar.Player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_DICE_BAG):RandomInt(#data.chances) + 1], familiar.Position, nilvector, familiar)
	end
	familiar:FollowParent()
end, FamiliarVariant.DICE_BAG)

function mod:diceBagRoomClear()
	for _, d in pairs(Isaac.FindByType(3, FamiliarVariant.DICE_BAG, -1, false, false)) do
		familiar = d:ToFamiliar()
		familiar.Coins = familiar.Coins + 1
	end
end