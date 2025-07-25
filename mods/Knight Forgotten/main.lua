Knighty = RegisterMod("Knighty",1)

Knighty:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,ply)

    if ply:GetPlayerType() == 17 then
            
        ply:SetColor(Color(1, 1, 1, 1, 0.3, 0.2, 0.6), 3, 1, false, false)
        
    end
  
end)