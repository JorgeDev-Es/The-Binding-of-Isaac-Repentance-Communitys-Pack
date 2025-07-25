local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local FEAR_DURATION = 90 -- 3 seconds
local FEAR_CHANCE = 0.2
local FEAR_CHANCE_LUCK = 0.02
local FEAR_DAMAGE_MULT = 0.5 -- Part of a multiplier

mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, function(_, player, trinket, firstTime)
	if trinket & ~TrinketType.TRINKET_GOLDEN_FLAG == mod.Trinket.TRUMPET then
		if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
			sfx:Play(mod.Sound.TRUMPET_DOOT)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if game:GetRoom():GetFrameCount() == 0 and mod.IsActiveVulnerableEnemy(npc) then
		local player = mod.RandomTrinketOwner(mod.Trinket.TRUMPET, npc.InitSeed)
		
		if player and RNG(npc.InitSeed):RandomFloat() <= player.Luck * FEAR_CHANCE_LUCK + FEAR_CHANCE then
			npc:AddFear(EntityRef(player), FEAR_DURATION)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown)
	local trinketMult = PlayerManager.GetTotalTrinketMultiplier(mod.Trinket.TRUMPET)
	
	if trinketMult > 0 and entity and entity:IsEnemy() and entity:HasEntityFlags(EntityFlag.FLAG_FEAR) then
		return {Damage = amount * (1 + FEAR_DAMAGE_MULT * trinketMult)}
	end
end)