local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local Set = ____lualib.Set
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____common = require("lua_modules.@isaac-stats-plus.common.dist.index")
local toFixedFormatted = ____common.toFixedFormatted
local ____MetricValue = require("entities.metric.MetricValue")
local MetricValue = ____MetricValue.MetricValue
local ____StatSlot = require("entities.stat.StatSlot")
local StatSlot = ____StatSlot.StatSlot
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____PlayerService = require("services.PlayerService")
local PlayerService = ____PlayerService.PlayerService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____CORE_STAT_EXTENSIONS = require("data.stat.CORE_STAT_EXTENSIONS")
local CORE_STAT_EXTENSIONS = ____CORE_STAT_EXTENSIONS.CORE_STAT_EXTENSIONS
local ____HashMap = require("structures.HashMap")
local HashMap = ____HashMap.HashMap
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
local ____MetricChange = require("entities.metric.MetricChange")
local MetricChange = ____MetricChange.MetricChange
local ____TimeProvider = require("services.renderer.TimeProvider")
local TimeProvider = ____TimeProvider.TimeProvider
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____speed = require("core.stats.speed")
local speed = ____speed.speed
local ____tears = require("core.stats.tears")
local tears = ____tears.tears
local ____damage = require("core.stats.damage")
local damage = ____damage.damage
local ____range = require("core.stats.range")
local range = ____range.range
local ____shotSpeed = require("core.stats.shotSpeed")
local shotSpeed = ____shotSpeed.shotSpeed
local ____luck = require("core.stats.luck")
local luck = ____luck.luck
____exports.StatValueWatcher = __TS__Class()
local StatValueWatcher = ____exports.StatValueWatcher
StatValueWatcher.name = "StatValueWatcher"
function StatValueWatcher.prototype.____constructor(self, modCallbackService, timeProvider, playerService)
    self.modCallbackService = modCallbackService
    self.timeProvider = timeProvider
    self.playerService = playerService
    self.values = __TS__New(HashMap)
    self.onCacheEvaluationCallback = __TS__FunctionBind(self.onCacheEvaluation, self)
    self.onPostUpdateCallback = __TS__FunctionBind(self.onPostUpdate, self)
    self.playersToUpdate = __TS__New(Set)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ModCallbackService)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, TimeProvider)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, PlayerService)
        )
    },
    StatValueWatcher
)
function StatValueWatcher.getNumericStatValue(self, entityPlayer, stat)
    if stat == speed then
        return math.min(2, entityPlayer.MoveSpeed)
    end
    if stat == tears then
        return 30 / (entityPlayer.MaxFireDelay + 1)
    end
    if stat == damage then
        return entityPlayer.Damage
    end
    if stat == range then
        return entityPlayer.TearRange / 40
    end
    if stat == shotSpeed then
        return entityPlayer.ShotSpeed
    end
    if stat == luck then
        return entityPlayer.Luck
    end
    error(
        __TS__New(ErrorWithContext, "Unsupported stat.", {stat = stat}),
        0
    )
end
function StatValueWatcher.prototype.reload(self)
    self.values:clear()
    self.playersToUpdate = __TS__New(
        Set,
        self.playerService:getPlayers()
    )
    self.modCallbackService:removeCallback(ModCallback.EVALUATE_CACHE, self.onCacheEvaluationCallback)
    self.modCallbackService:removeCallback(ModCallback.POST_UPDATE, self.onPostUpdateCallback)
    self.modCallbackService:addCallback(ModCallback.POST_UPDATE, self.onPostUpdateCallback)
    self.modCallbackService:addCallback(ModCallback.EVALUATE_CACHE, self.onCacheEvaluationCallback)
end
function StatValueWatcher.prototype.getStatValue(self, slot)
    return self.values:get(slot)
end
function StatValueWatcher.prototype.onCacheEvaluation(self, entityPlayer)
    local player = self.playerService:getPlayerByEntity(entityPlayer)
    if player == nil then
        return
    end
    self.playersToUpdate:add(player)
end
function StatValueWatcher.prototype.onPostUpdate(self)
    self.playersToUpdate:forEach(function(____, player)
        self:updatePlayer(player)
    end)
    self.playersToUpdate:clear()
end
function StatValueWatcher.prototype.updatePlayer(self, player)
    __TS__ArrayForEach(
        CORE_STAT_EXTENSIONS,
        function(____, statType)
            local slot = __TS__New(StatSlot, statType, player)
            local currentValue = self:getStatValue(slot)
            local currentNumericValue = ____exports.StatValueWatcher:getNumericStatValue(player.entityPlayer, statType)
            if currentValue == nil then
                local statValue = __TS__New(
                    MetricValue,
                    {
                        initial = currentNumericValue,
                        computeChange = function(____, prev, next)
                            local value = next - prev
                            if value == 0 then
                                return MetricChange:empty(self.timeProvider:getLastRenderTime())
                            end
                            return __TS__New(
                                MetricChange,
                                value,
                                toFixedFormatted(nil, value, 2),
                                value > 0,
                                self.timeProvider:getLastRenderTime()
                            )
                        end,
                        formatValue = function(____, value) return toFixedFormatted(nil, value, 2) end,
                        formatChange = function(____, value) return toFixedFormatted(nil, value, 2) end
                    }
                )
                self.values:set(slot, statValue)
                return
            end
            if currentNumericValue ~= currentValue:getValue() then
                currentValue:setValue(
                    currentNumericValue,
                    self.timeProvider:getLastRenderTime()
                )
            end
        end
    )
end
StatValueWatcher = __TS__DecorateLegacy(
    {Singleton(nil)},
    StatValueWatcher
)
____exports.StatValueWatcher = StatValueWatcher
return ____exports
