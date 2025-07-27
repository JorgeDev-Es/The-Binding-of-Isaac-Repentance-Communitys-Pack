local mod = LastJudgement

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
    if cmd == "forcemortis" then
        mod.ForceMortis = not mod.ForceMortis
        print("Last Judgement forcing Mortis: ", mod.ForceMortis)
        
    elseif cmd == "stats" then
        if params == "Mortis" or (params == "" and mod.STAGE.Mortis:IsStage()) then
            Isaac.ExecuteCommand("giveitem Sad Onion")
            Isaac.ExecuteCommand("giveitem MEAT!")
            Isaac.ExecuteCommand("giveitem Pentagram")
            Isaac.ExecuteCommand("giveitem Cricket's Head")
        end
    end
end)