
function TSIL.Players.GetPlayerIndex(player, differentiateSoulAndForgotten)
	if differentiateSoulAndForgotten == nil then
		differentiateSoulAndForgotten = false
	end

	local playerToUse = player
	local isSubPlayer = player:IsSubPlayer()
	if isSubPlayer then
		local playerParent = TSIL.Players.GetSubPlayerParent(player)
		if playerParent ~= nil then
			playerToUse = playerParent
		end
	end

	if differentiateSoulAndForgotten and player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
		return playerToUse:GetCollectibleRNG(3):GetSeed()
	end

	return playerToUse:GetCollectibleRNG(1):GetSeed()
end

