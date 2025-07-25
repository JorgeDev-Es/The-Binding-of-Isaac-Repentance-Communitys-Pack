




function TSIL.Players.GetSubPlayerParent(subPlayer)
	local subPlayerPtrHash = GetPtrHash(subPlayer);
	local players = PlayerManager.GetPlayers();

	return TSIL.Utils.Tables.FindFirst(players, function(_, player)
		local thisPlayerSubPlayer = player:GetSubPlayer()
		if thisPlayerSubPlayer == nil then
			return false
		end

		local thisPlayerSubPlayerPtrHash = GetPtrHash(thisPlayerSubPlayer);
		return thisPlayerSubPlayerPtrHash == subPlayerPtrHash;
	end)
end
