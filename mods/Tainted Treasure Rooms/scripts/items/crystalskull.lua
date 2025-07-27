local mod = TaintedTreasure
local game = Game()

function mod:CrystalSkullPlayerLogic(player, data)
	if player:HasCollectible(TaintedCollectibles.CRYSTAL_SKULL) then
		if not player:WillPlayerRevive() and not data.CrystalSkullRevive then
			player:GetEffects():AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
		end
		if mod:IsPlayerDying(player) then
			if player:GetEffects():HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE) and not data.CrystalSkullRevive then
				data.CrystalSkullRevive = true
			end
		elseif data.CrystalSkullRevive then
			player:RemoveCollectible(TaintedCollectibles.CRYSTAL_SKULL)
			if player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B and player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL then
				player:ChangePlayerType(PlayerType.PLAYER_THEFORGOTTEN)
			end
			if player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B then
				player:AddSoulHearts(-100)
				player:AddHearts(-100)
				player:AddBoneHearts(1-player:GetBoneHearts())
				player:GetSubPlayer():AddSoulHearts(1-player:GetSoulHearts())
			end
			data.CrystalSkullRevive = false
			game:StartRoomTransition(game:GetLevel():GetLastRoomDesc().SafeGridIndex, -1, 0, player)
			mod:scheduleForUpdate(function()
				player:AnimateCollectible(TaintedCollectibles.CRYSTAL_SKULL)
			end, 3)
		end
	end
end