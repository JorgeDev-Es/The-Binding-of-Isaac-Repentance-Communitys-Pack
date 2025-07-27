local mod = FiendFolio

mod.ferriumTrinketFamiliarCheck = false
mod.fuckyouthegameisendingtrinkets = false

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    mod.ferriumTrinketFamiliarCheck = false
    mod.fuckyouthegameisendingtrinkets = false
end)

function mod:trinketFamiliarGameInit(player, basedata)
    if mod.ferriumTrinketFamiliarCheck == false then
        local data = basedata.ffsavedata
        if data then
            if data.trinketFamiliarGameInit then
                for key, entry in pairs(data.trinketFamiliarGameInit) do
                    local exists = false
                    for _,fam in ipairs(Isaac.FindByType(3, entry.var, (entry.sub or 0), false, false)) do
                        if fam.InitSeed == entry.init then
                            data[entry.key] = fam
                            exists = true
                        end
                    end
                    if exists == false then
                        table.remove(data.trinketFamiliarGameInit, key)
                    end
                end
            end
            if not mod.fuckyouthegameisendingtrinkets then
                mod.ferriumTrinketFamiliarCheck = true
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_END, function()
    mod.ferriumTrinketFamiliarCheck = false
    mod.fuckyouthegameisendingtrinkets = true
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    mod.ferriumTrinketFamiliarCheck = false
    mod.fuckyouthegameisendingtrinkets = true
end)