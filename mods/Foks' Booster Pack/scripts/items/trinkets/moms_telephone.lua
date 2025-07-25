local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local THRESHOLD = 540 -- 18 seconds
local DELAY = 30 -- 1 second

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	local trinketMult = PlayerManager.GetTotalTrinketMultiplier(mod.Trinket.MOMS_TELEPHONE)
	local player = PlayerManager.FirstTrinketOwner(mod.Trinket.MOMS_TELEPHONE)
	local room = game:GetRoom()
	
	if player and trinketMult > 0 and room:GetAliveEnemiesCount() > 0 and room:GetFrameCount() == THRESHOLD // trinketMult then
		Isaac.CreateTimer(function() player:UseCard(Card.CARD_EMERGENCY_CONTACT, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER) end, DELAY)
		sfx:Play(mod.Sound.MOM_PHONE)
	end
end)