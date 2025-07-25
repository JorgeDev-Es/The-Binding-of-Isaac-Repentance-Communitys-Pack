local Mod = RepMMod

Mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, _, player, flags)
	local CRI = game:GetLevel():GetCurrentRoomIndex()
	local Dirt = player:GetMovementDirection()
	local NewDirt
	if Dirt == 0 then
		NewDirt = CRI - 2
		if game:GetLevel():GetRoomByIdx(NewDirt, -1).Data == nil then
			NewDirt = CRI - 1
		end
	elseif Dirt == 1 then
		NewDirt = CRI - 26
		if game:GetLevel():GetRoomByIdx(NewDirt, -1).Data == nil then
			NewDirt = CRI - 13
		end
	elseif Dirt == 2 then
		NewDirt = CRI + 2
		if game:GetLevel():GetRoomByIdx(NewDirt, -1).Data == nil then
			NewDirt = CRI + 1
		end
	elseif Dirt == 3 then
		NewDirt = CRI + 26
		if game:GetLevel():GetRoomByIdx(NewDirt, -1).Data == nil then
			NewDirt = CRI + 13
		end
	end
	if Dirt == -1 then
		player:AddCard(Mod.RepmTypes.CARD_HAMMER_CARD)
	else
		print(Dirt)
		if game:GetLevel():GetRoomByIdx(NewDirt, -1).Data ~= nil then
			game:StartRoomTransition(NewDirt, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, -1)
			if player:HasCollectible(451) then
				if math.random(1, 10) <= 2 then
					player:AddCard(Mod.RepmTypes.CARD_HAMMER_CARD)
				end
			else
				if math.random(1, 10) == 1 then
					player:AddCard(Mod.RepmTypes.CARD_HAMMER_CARD)
				end
			end
		else
			player:AddCard(Mod.RepmTypes.CARD_HAMMER_CARD)
		end
	end
end, Mod.RepmTypes.CARD_HAMMER_CARD)