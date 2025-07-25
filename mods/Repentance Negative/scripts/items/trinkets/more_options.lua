local Mod = RepMMod
local spawnPos = Vector(500, 140)

local function options_Wow_Room()
	local room = Game():GetRoom()

	if room:GetType() == RoomType.ROOM_SHOP then
		if PlayerManager.AnyoneHasTrinket(Mod.RepmTypes.TRINKET_MORE_OPTIONS) and room:IsFirstVisit() then
			local Itempool = Game():GetItemPool()
			local pos = Isaac.GetFreeNearPosition(spawnPos, 40)
			local rng = RNG(Game():GetLevel():GetCurrentRoomDesc().SpawnSeed)
			local seed = Game():GetLevel():GetCurrentRoomDesc().AwardSeed
			--rng:SetSeed(seed, 35)
			local ItemId = Mod.GetByQuality(3, 4, Itempool:GetPoolForRoom(RoomType.ROOM_SHOP, seed), rng)
			if ItemId then
				local obj = Isaac.Spawn(5, 100, ItemId, pos, Vector.Zero, nil):ToPickup()
				
				obj.Price = Isaac.GetItemConfig():GetCollectible(ItemId).ShopPrice
				obj.ShopItemId = -50
				local poof = Isaac.Spawn(1000, 16, 1, pos, Vector.Zero, nil):ToEffect()
				poof:GetSprite().Scale = Vector(0.6, 0.6)
				poof.Color = Color(0.5, 0.5, 0.5, 1)
				SFXManager():Play(SoundEffect.SOUND_BLACK_POOF, 1, 2, false, 1, 0)
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, options_Wow_Room)

---@param pickup EntityPickup
---@param player EntityPlayer
---@param money integer
local function MOPurchase(_, pickup, player, money)
	if Game():GetRoom():GetType() == RoomType.ROOM_SHOP and pickup.ShopItemId ~= -50 then
		for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
			local shoppickup = entity:ToPickup()
			if shoppickup:IsShopItem() and shoppickup == -50 then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
				entity:Remove()
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, MOPurchase)
