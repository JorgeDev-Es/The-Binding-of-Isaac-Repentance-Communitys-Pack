local Mod = CustomBombHUDIcons

---Executes given function for every player
---Return anything to end the loop early
---@param func fun(player: EntityPlayer, playerNum?: integer): any?
function CustomBombHUDIcons:ForEachPlayer(func)
	if REPENTOGON then
		for i, player in ipairs(PlayerManager.GetPlayers()) do
			if func(player, i) then
				return true
			end
		end
	else
		for i = 0, Game():GetNumPlayers() - 1 do
			if func(Isaac.GetPlayer(i), i) then
				return true
			end
		end
	end
end

function CustomBombHUDIcons:IsTRLazBRGhost(player)
	if REPENTOGON then
		return player:IsHologram()
	else
		return player.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE
	end
end