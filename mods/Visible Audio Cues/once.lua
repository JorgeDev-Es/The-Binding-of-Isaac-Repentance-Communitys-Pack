--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
function ____exports.once(self, mod, fn)
    local ran = false
    mod:AddCallback(
        ModCallback.POST_GAME_STARTED,
        function()
            ran = false
        end
    )
    return function()
        if ran then
            return
        end
        fn(nil)
        ran = true
    end
end
return ____exports
