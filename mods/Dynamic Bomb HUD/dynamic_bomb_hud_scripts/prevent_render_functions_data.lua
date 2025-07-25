---Name: Name of the function
---Condition: true = don't render
CustomBombHUDIcons.PreventRenderFunctions =
{
    {
        --prevent from rendering for p2, p3, p4, etc...

        Name = 'Non-P1',

        Condition = function(_, playerHUDIndex)
            return playerHUDIndex ~= 1
        end
    },
    {
        --different hud icon, yeah

        Name = 'Giga Bomb',

        Condition = function(_)
            local gigaBombPresent = false
            CustomBombHUDIcons:ForEachPlayer(function(player)
                if player:GetNumGigaBombs() > 0 then
                    gigaBombPresent = true
                    return
                end
            end)

            
            return gigaBombPresent
        end
    },
    {
        --different hud icon, yeah

        Name = 'Tainted ??? Only',

        Condition = function(_)
            local isOnlyTBBPresent = true
            CustomBombHUDIcons:ForEachPlayer(function(player)
                if player:GetPlayerType() ~= PlayerType.PLAYER_BLUEBABY_B then
                    isOnlyTBBPresent = false
                    return
                end
            end)

            
            return isOnlyTBBPresent
        end
    }
}