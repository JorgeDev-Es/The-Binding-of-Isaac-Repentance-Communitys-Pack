local ____lualib = require("lualib_bundle")
local Map = ____lualib.Map
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____common = require("lua_modules.@isaac-stats-plus.common.dist.index")
local toFixedFormatted = ____common.toFixedFormatted
local ____essentialsAddonConstants = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.essentialsAddonConstants")
local D8_MULTIPLIER_PROVIDER_ID = ____essentialsAddonConstants.D8_MULTIPLIER_PROVIDER_ID
local ____D8Tracker = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.common.D8Tracker")
local D8Tracker = ____D8Tracker.D8Tracker
function ____exports.createD8MultiplierProvider(self, api, mod, json)
    local NEUTRAL_MULTIPLIER = 1
    local TARGETS = {api.stat.speed, api.stat.tears, api.stat.damage, api.stat.range}
    return api:provider({
        id = D8_MULTIPLIER_PROVIDER_ID,
        name = "D8 Multiplier",
        description = "Displays a multiplier applied by D8, ranging from x0.5 to x2.0 (D100 not supported).",
        targets = TARGETS,
        color = "BLUE",
        state = {
            seed = {
                initial = function() return Game():GetSeeds():GetStartSeed() end,
                persistent = true
            },
            multipliers = {
                initial = function() return {} end,
                persistent = true,
                encoder = {
                    encode = function(self, decoded)
                        return json.encode(__TS__ArrayMap(
                            decoded,
                            function(____, map) return __TS__ArrayFrom(map:entries()) end
                        ))
                    end,
                    decode = function(self, encoded)
                        return __TS__ArrayMap(
                            json.decode(encoded),
                            function(____, entries) return __TS__New(Map, entries) end
                        )
                    end
                }
            },
            multiplier = {initial = function() return NEUTRAL_MULTIPLIER end}
        },
        display = {
            value = {
                get = function(state) return state.multiplier end,
                format = function(multiplier) return "x" .. toFixedFormatted(nil, multiplier, 2) end
            },
            change = {
                compute = function(prev, next)
                    local ____temp_0
                    if next == prev then
                        ____temp_0 = nil
                    else
                        ____temp_0 = next / prev
                    end
                    return ____temp_0
                end,
                isPositive = function(multiplier) return multiplier > 1 end,
                format = function(multiplier) return "x" .. toFixedFormatted(nil, multiplier, 2) end
            }
        },
        mount = function(ctx)
            if ctx.state.seed:current() ~= Game():GetSeeds():GetStartSeed() then
                ctx.state.multipliers:reset()
                ctx.state.multiplier:reset(true)
                ctx.state.seed:set(Game():GetSeeds():GetStartSeed())
            end
            if ctx.state.multipliers:current()[ctx.playerIndex + 1] == nil then
                local players = __TS__ArrayFrom(ctx.state.multipliers:current())
                players[ctx.playerIndex + 1] = __TS__New(Map)
                ctx.state.multipliers:set(players)
            end
            local tracker
            tracker = __TS__New(
                D8Tracker,
                api,
                mod,
                json,
                ctx.player,
                ctx.stat,
                ctx.state.multipliers:current()[ctx.playerIndex + 1]:get(ctx.stat.id) or NEUTRAL_MULTIPLIER,
                function()
                    local multiplier = tracker:getMultiplier()
                    local players = __TS__ArrayFrom(ctx.state.multipliers:current())
                    local player = __TS__New(
                        Map,
                        players[ctx.playerIndex + 1] or __TS__New(Map)
                    )
                    player:set(ctx.stat.id, multiplier)
                    players[ctx.playerIndex + 1] = player
                    ctx.state.multipliers:set(players)
                    ctx.state.multiplier:set(multiplier)
                end
            )
            ctx.state.multiplier:set(
                tracker:getMultiplier(),
                true
            )
            return function() return tracker:destroy() end
        end
    })
end
return ____exports
