local ____lualib = require("lualib_bundle")
local Map = ____lualib.Map
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local Set = ____lualib.Set
local __TS__New = ____lualib.__TS__New
local __TS__ArrayReduce = ____lualib.__TS__ArrayReduce
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____common = require("lua_modules.@isaac-stats-plus.common.dist.index")
local toFixedFormatted = ____common.toFixedFormatted
local ____characterMultipliers = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.providers.damageMultiplierProvider.data.characterMultipliers")
local characterMultipliers = ____characterMultipliers.characterMultipliers
local ____collectibleMultipliers = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.providers.damageMultiplierProvider.data.collectibleMultipliers")
local collectibleMultipliers = ____collectibleMultipliers.collectibleMultipliers
local ____trinketMultipliers = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.providers.damageMultiplierProvider.data.trinketMultipliers")
local trinketMultipliers = ____trinketMultipliers.trinketMultipliers
local ____essentialsAddonConstants = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.essentialsAddonConstants")
local DAMAGE_MULTIPLIER_PROVIDER_ID = ____essentialsAddonConstants.DAMAGE_MULTIPLIER_PROVIDER_ID
local ____D8Tracker = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.common.D8Tracker")
local D8Tracker = ____D8Tracker.D8Tracker
function ____exports.createDamageMultiplierProvider(self, api, mod, json)
    local NEUTRAL_MULTIPLIER = 1
    return api:provider({
        id = DAMAGE_MULTIPLIER_PROVIDER_ID,
        name = "Damage Multiplier",
        description = "Displays a damage multiplier based on the character, items and trinkets.",
        targets = {api.stat.damage},
        color = "RED",
        state = {
            multiplier = {initial = function() return NEUTRAL_MULTIPLIER end},
            seed = {
                initial = function() return Game():GetSeeds():GetStartSeed() end,
                persistent = true
            },
            d8Multipliers = {
                initial = function() return {} end,
                persistent = true
            }
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
        conditions = {isMultiplierNeutral = {id = "neutral-multiplier", name = "Damage multiplier is x1.00", description = "Activates when the damage multiplier is x1.00."}, isMultiplierAltered = {id = "altered-multiplier", name = "Damage multiplier is altered", description = "Activates when the damage multiplier is affected by some item or trinket."}},
        settings = {trackD8 = api.settings:toggle({
            name = "D8 support",
            description = "If enabled, the D8 damage multiplier will be considered when calculating the damage multiplier.",
            initial = function() return true end
        })},
        computables = {
            getCharacterMultiplier = function(self, entityPlayer)
                local ____opt_1 = characterMultipliers:get(entityPlayer:GetPlayerType())
                return ____opt_1 and ____opt_1(nil, entityPlayer) or NEUTRAL_MULTIPLIER
            end,
            getAffectedCollectibles = function(self)
                return __TS__ArrayFrom(collectibleMultipliers:keys())
            end,
            getCollectibleMultiplier = function(self, collectible, entityPlayer)
                local ____opt_3 = collectibleMultipliers:get(collectible)
                return ____opt_3 and ____opt_3(nil, entityPlayer) or NEUTRAL_MULTIPLIER
            end,
            getTotalCollectibleMultiplier = function(self, entityPlayer)
                local affectedCollectibles = __TS__ArrayFrom(__TS__New(
                    Set,
                    self:getAffectedCollectibles()
                ))
                return __TS__ArrayReduce(
                    affectedCollectibles,
                    function(____, acc, collectible) return (entityPlayer:HasCollectible(collectible) or entityPlayer:GetEffects():HasCollectibleEffect(collectible)) and acc * self:getCollectibleMultiplier(collectible, entityPlayer) or acc * NEUTRAL_MULTIPLIER end,
                    NEUTRAL_MULTIPLIER
                )
            end,
            getAffectedTrinkets = function(self)
                return __TS__ArrayFrom(trinketMultipliers:keys())
            end,
            getTrinketMultiplier = function(self, trinket, entityPlayer)
                local ____opt_5 = trinketMultipliers:get(trinket)
                return ____opt_5 and ____opt_5(nil, entityPlayer) or NEUTRAL_MULTIPLIER
            end,
            getTotalTrinketMultiplier = function(self, entityPlayer)
                local affectedTrinkets = __TS__ArrayFrom(__TS__New(
                    Set,
                    self:getAffectedTrinkets()
                ))
                return __TS__ArrayReduce(
                    affectedTrinkets,
                    function(____, acc, trinket)
                        if not entityPlayer:HasTrinket(trinket) then
                            return acc * NEUTRAL_MULTIPLIER
                        end
                        return acc * self:getTrinketMultiplier(trinket, entityPlayer)
                    end,
                    NEUTRAL_MULTIPLIER
                )
            end,
            getTotalMultiplier = function(self, multipliers)
                return __TS__ArrayReduce(
                    multipliers,
                    function(____, acc, multiplier) return acc * multiplier end,
                    NEUTRAL_MULTIPLIER
                )
            end
        },
        mount = function(ctx)
            if ctx.state.seed:current() ~= Game():GetSeeds():GetStartSeed() then
                ctx.state.d8Multipliers:reset()
                ctx.state.seed:set(Game():GetSeeds():GetStartSeed())
            end
            local function recomputeMultiplier(self, silent)
                if silent == nil then
                    silent = false
                end
                do
                    local function ____catch(e)
                        Isaac.DebugString("Error during damage multiplier recomputation: " .. json.encode(e))
                    end
                    local ____try, ____hasReturned = pcall(function()
                        local characterMultiplier = ctx.computables:getCharacterMultiplier(ctx.player)
                        local collectibleMultiplier = ctx.computables:getTotalCollectibleMultiplier(ctx.player)
                        local trinketMultiplier = ctx.computables:getTotalTrinketMultiplier(ctx.player)
                        local totalMultiplier = ctx.computables:getTotalMultiplier({
                            characterMultiplier,
                            collectibleMultiplier,
                            trinketMultiplier,
                            ctx.settings.custom.trackD8 and (ctx.state.d8Multipliers:current()[ctx.playerIndex + 1] or NEUTRAL_MULTIPLIER) or NEUTRAL_MULTIPLIER
                        })
                        ctx.state.multiplier:set(totalMultiplier, silent)
                        ctx.conditions.isMultiplierNeutral:setActive(totalMultiplier == NEUTRAL_MULTIPLIER)
                        ctx.conditions.isMultiplierAltered:setActive(totalMultiplier ~= characterMultiplier)
                    end)
                    if not ____try then
                        ____catch(____hasReturned)
                    end
                end
            end
            local function listener(____, entityPlayer)
                if entityPlayer.Index == ctx.player.Index then
                    recomputeMultiplier(nil)
                end
            end
            local d8Tracker
            d8Tracker = __TS__New(
                D8Tracker,
                api,
                mod,
                json,
                ctx.player,
                api.stat.damage,
                ctx.state.d8Multipliers:current()[ctx.playerIndex + 1] or NEUTRAL_MULTIPLIER,
                function()
                    if not ctx.settings.custom.trackD8 then
                        return
                    end
                    local d8Multipliers = ctx.state.d8Multipliers:current()
                    d8Multipliers[ctx.playerIndex + 1] = d8Tracker:getMultiplier()
                    ctx.state.d8Multipliers:set(d8Multipliers)
                    recomputeMultiplier(nil)
                end
            )
            recomputeMultiplier(nil, true)
            mod:AddCallback(ModCallback.EVALUATE_CACHE, listener)
            return function() return mod:RemoveCallback(ModCallback.EVALUATE_CACHE, listener) end
        end
    })
end
return ____exports
