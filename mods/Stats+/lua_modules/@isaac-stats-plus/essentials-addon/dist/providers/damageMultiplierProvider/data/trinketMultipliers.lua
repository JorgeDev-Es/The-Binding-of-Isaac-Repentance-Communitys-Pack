local ____lualib = require("lualib_bundle")
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local TrinketType = ____isaac_2Dtypescript_2Ddefinitions.TrinketType
____exports.trinketMultipliers = __TS__New(
    Map,
    {{
        TrinketType.CRACKED_CROWN,
        function() return 1.2 end
    }}
)
return ____exports
