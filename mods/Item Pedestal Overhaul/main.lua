local mod = RegisterMod("IPO", 1)
local game = Game()

local pedestalItem = {
	[5] = "mortis", [10] = "womb", [11] = "utero", [12] = "scarred", [13] = "bluewomb",
	[14] = "devil", [15] = "angel", [16] = "darkroom", [17] = "treasure", [18] = "devil", 
	[19] = "library", [20] = "shop", [23] = "secret", [25] = "shop", [26] = "error",
	[27] = "bluewomb", [28] = "shop", [30] = "sacrifice", [34] = "corpse", [35] = "planetarium",
	[37] = "secret",  [39] = "corpse", [43] = "corpse", [44] = "corpse", [48] = "corpse",
	[49] = "loot", [50] = "loot", [51] = "loot", [52] = "loot", [53] = "loot",
	[54] = "loot", [60] = "loot"
}

function mod:pedestal(pickup)
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local sprite = pickup:GetSprite()
	if pickup.Variant == 100 and not pickup:IsShopItem() and sprite:GetOverlayFrame() == 0 and pickup:GetData().pedestal_check == nil then
		pickup:GetData().pedestal_check = true
		local altarType = pedestalItem[room:GetBackdropType()] or ""

		-- Mortis Support --
		if altarType == "mortis" then
			if not game:GetStateFlag(GameStateFlag.STATE_MAUSOLEUM_HEART_KILLED) then
				altarType = ""
			end
		end

		-- Extra Checks --
		if room:GetType() == RoomType.ROOM_BOSS or room:GetType() == RoomType.ROOM_MINIBOSS then
			local wombVar = {"womb", "utero", "scarred", "bluewomb", "corpse", "mortis"}
			local varCheck = false
			for _, value in ipairs(wombVar) do
				if altarType == value then
					varCheck = true
					altarType = altarType .. "boss"
					break
				end
			end
			if not varCheck then
				altarType = "boss"
			end
		elseif room:GetType() == RoomType.ROOM_TREASURE then
			altarType = "treasure"
		elseif room:GetType() == RoomType.ROOM_CHALLENGE or room:GetType() == RoomType.ROOM_BOSSRUSH then
			altarType = "ambush"
		end

		-- Pedestal Change --
		if altarType ~= "" then
			for i = 4, 5 do pickup:GetSprite():ReplaceSpritesheet(i, "gfx/items/slots/" .. altarType .. "_pedestal.png") end
			sprite:LoadGraphics()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.pedestal)