local mod = ScrapEnemyAlts
local game = Game()

function mod:loadRooms(continued)
	if continued == false then
		if FiendFolio then
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.DOWNPOUR, RoomType.ROOM_DEFAULT, 8300, 0) == nil then
				RoomConfig.AddRooms(StbType.DOWNPOUR, 0, require("content.moddedrooms.downpour.downpour_ff_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.MINES, RoomType.ROOM_DEFAULT, 8300, 0) == nil then
				RoomConfig.AddRooms(StbType.MINES, 0, include("content.moddedrooms.mines.mines_ff_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.WOMB, RoomType.ROOM_DEFAULT, 8300, 0) == nil then
				RoomConfig.AddRooms(StbType.WOMB, 0, include("content.moddedrooms.womb.womb_ff_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.UTERO, RoomType.ROOM_DEFAULT, 8300, 0) == nil then
				RoomConfig.AddRooms(StbType.UTERO, 0, include("content.moddedrooms.utero.utero_ff_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SCARRED_WOMB, RoomType.ROOM_DEFAULT, 8300, 0) == nil then
				RoomConfig.AddRooms(StbType.SCARRED_WOMB, 0, include("content.moddedrooms.scarredwomb.scarred_womb_ff_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.CORPSE, RoomType.ROOM_DEFAULT, 8300, 0) == nil then
				RoomConfig.AddRooms(StbType.CORPSE, 0, include("content.moddedrooms.corpse.corpse_ff_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.ASCENT, RoomType.ROOM_DEFAULT, 8300, 0) == nil then
				RoomConfig.AddRooms(StbType.ASCENT, 0, include("content.moddedrooms.ascent.backwards_ff_doge"))
			end
		end
		if RestoredMonsterPack then
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.DOWNPOUR, RoomType.ROOM_DEFAULT, 8200, 0) == nil then
				RoomConfig.AddRooms(StbType.DOWNPOUR, 0, include("content.moddedrooms.downpour.downpour_rmp_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.MINES, RoomType.ROOM_DEFAULT, 8200, 0) == nil then
				RoomConfig.AddRooms(StbType.MINES, 0, include("content.moddedrooms.mines.mines_rmp_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.WOMB, RoomType.ROOM_DEFAULT, 8200, 0) == nil then
				RoomConfig.AddRooms(StbType.WOMB, 0, include("content.moddedrooms.womb.womb_rmp_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.UTERO, RoomType.ROOM_DEFAULT, 8200, 0) == nil then
				RoomConfig.AddRooms(StbType.UTERO, 0, include("content.moddedrooms.utero.utero_rmp_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SCARRED_WOMB, RoomType.ROOM_DEFAULT, 8200, 0) == nil then
				RoomConfig.AddRooms(StbType.SCARRED_WOMB, 0, include("content.moddedrooms.scarredwomb.scarred_womb_rmp_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.CORPSE, RoomType.ROOM_DEFAULT, 8200, 0) == nil then
				RoomConfig.AddRooms(StbType.CORPSE, 0, include("content.moddedrooms.corpse.corpse_rmp_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.ASCENT, RoomType.ROOM_DEFAULT, 8200, 0) == nil then
				RoomConfig.AddRooms(StbType.ASCENT, 0, include("content.moddedrooms.ascent.backwards_rmp_doge"))
			end
		end
		if FiendFolio and RestoredMonsterPack then
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.DOWNPOUR, RoomType.ROOM_DEFAULT, 8322, 0) == nil then
				RoomConfig.AddRooms(StbType.DOWNPOUR, 0, include("content.moddedrooms.downpour.downpour_mixed_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.MINES, RoomType.ROOM_DEFAULT, 8345, 0) == nil then
				RoomConfig.AddRooms(StbType.MINES, 0, include("content.moddedrooms.mines.mines_mixed_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.WOMB, RoomType.ROOM_DEFAULT, 8304, 0) == nil then
				RoomConfig.AddRooms(StbType.WOMB, 0, include("content.moddedrooms.womb.womb_mixed_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.UTERO, RoomType.ROOM_DEFAULT, 8322, 0) == nil then
				RoomConfig.AddRooms(StbType.UTERO, 0, include("content.moddedrooms.utero.utero_mixed_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SCARRED_WOMB, RoomType.ROOM_DEFAULT, 8345, 0) == nil then
				RoomConfig.AddRooms(StbType.SCARRED_WOMB, 0, include("content.moddedrooms.scarredwomb.scarred_womb_mixed_doge"))
			end
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.ASCENT, RoomType.ROOM_DEFAULT, 8313, 0) == nil then
				RoomConfig.AddRooms(StbType.ASCENT, 0, include("content.moddedrooms.ascent.backwards_mixed_doge"))
			end
		end
		if LastJudgement then
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.CORPSE, RoomType.ROOM_DEFAULT, 8250, 0) == nil then
				RoomConfig.AddRooms(StbType.CORPSE, 0, include("content.moddedrooms.corpse.corpse_lj_doge"))
			end
		end
		if FiendFolio and RestoredMonsterPack and LastJudgement then
			if RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.CORPSE, RoomType.ROOM_DEFAULT, 8340, 0) == nil then
				RoomConfig.AddRooms(StbType.CORPSE, 0, include("content.moddedrooms.corpse.corpse_mixed_doge"))
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.loadRooms)