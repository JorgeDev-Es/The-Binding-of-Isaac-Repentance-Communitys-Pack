local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ButtonAction = ____isaac_2Dtypescript_2Ddefinitions.ButtonAction
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____essentialsAddonConstants = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.essentialsAddonConstants")
local MAP_BUTTON_HELD_CONDITION_ID = ____essentialsAddonConstants.MAP_BUTTON_HELD_CONDITION_ID
function ____exports.createMapButtonHeldCondition(self, api, mod)
    return api:condition({
        id = MAP_BUTTON_HELD_CONDITION_ID,
        name = "Map button is held",
        description = "Activates when the map button is held down and is inactive otherwise.",
        mount = function(ctx)
            local function listener()
                if Game():IsPaused() then
                    return
                end
                ctx:setActive(Input.IsActionPressed(ButtonAction.MAP, ctx.player.ControllerIndex))
            end
            mod:AddCallback(ModCallback.INPUT_ACTION, listener)
            return function() return mod:RemoveCallback(ModCallback.INPUT_ACTION, listener) end
        end
    })
end
return ____exports
