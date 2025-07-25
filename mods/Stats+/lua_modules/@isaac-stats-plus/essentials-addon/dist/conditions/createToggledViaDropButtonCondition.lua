local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ButtonAction = ____isaac_2Dtypescript_2Ddefinitions.ButtonAction
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____essentialsAddonConstants = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.essentialsAddonConstants")
local DROP_BUTTON_TOGGLED_CONDITION_ID = ____essentialsAddonConstants.DROP_BUTTON_TOGGLED_CONDITION_ID
function ____exports.createToggledViaDropButtonCondition(self, api, mod)
    return api:condition({
        id = DROP_BUTTON_TOGGLED_CONDITION_ID,
        name = "Toggled via the drop button",
        description = "Activates/deactivates when the drop button is pressed.",
        mount = function(ctx)
            local pressed = false
            local function listener()
                if pressed and not Input.IsActionPressed(ButtonAction.DROP, ctx.player.ControllerIndex) then
                    pressed = false
                    return
                end
                if pressed or Game():IsPaused() or not Input.IsActionPressed(ButtonAction.DROP, ctx.player.ControllerIndex) then
                    return
                end
                ctx:setActive(not ctx:isActive())
                pressed = true
            end
            mod:AddCallback(ModCallback.INPUT_ACTION, listener)
            return function() return mod:RemoveCallback(ModCallback.INPUT_ACTION, listener) end
        end
    })
end
return ____exports
