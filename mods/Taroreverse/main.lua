local mod = RegisterMod("TaroReverse", 1)

local COLLECTIBLE_TARO_REVERSE = Isaac.GetItemIdByName("Taro Reverse")

if EID then 
    EID:addCollectible(COLLECTIBLE_TARO_REVERSE, "Turns over the tarot card in hand", "Taro Reverse")
    EID:addCollectible(COLLECTIBLE_TARO_REVERSE, "Переворачивает карту таро в руке", "Обратное Таро", "ru")
end

function mod:activate_taroreverse(_, _, player)

--[[local cards = {
[1] = 56, [56] = 1,
[2] = 57, [57] = 2,
[3] = 58, [58] = 3,
[4] = 59, [59] = 4,
[5] = 60, [60] = 5,
[6] = 61, [61] = 6,
[7] = 62, [62] = 7,
[8] = 63, [63] = 8,
[9] = 64, [64] = 9,
[10] = 65, [65] = 10,
[11] = 66, [66] = 11,
[12] = 67, [67] = 12,
[13] = 68, [68] = 13,
[14] = 69, [69] = 14,
[15] = 70, [70] = 15,
[16] = 71, [71] = 16,
[17] = 72, [72] = 17,
[18] = 73, [73] = 18,
[19] = 74, [74] = 19,
[20] = 75, [75] = 20,
[21] = 76, [76] = 21,
[22] = 77, [77] = 22
}]]--

local cardid = player:GetCard(0)

    --[[if cards[cardid] then
	    player:SetCard(0, cards[cardid])
		if cardid <23 then
		SFXManager():Play(SoundEffect.SOUND_MENU_FLIP_DARK)
		else
		SFXManager():Play(SoundEffect.SOUND_MENU_FLIP_LIGHT)
		end
    end]]--
	
	if cardid >0 and cardid <23 then
	    player:SetCard(0, cardid + 55)
		SFXManager():Play(SoundEffect.SOUND_MENU_FLIP_DARK)
	elseif cardid >55 and cardid <78 then
	    player:SetCard(0, cardid - 55)
        SFXManager():Play(SoundEffect.SOUND_MENU_FLIP_LIGHT)
    end

return true

end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.activate_taroreverse, COLLECTIBLE_TARO_REVERSE)