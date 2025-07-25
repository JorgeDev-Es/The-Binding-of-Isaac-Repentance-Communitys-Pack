local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____PlayerService = require("services.PlayerService")
local PlayerService = ____PlayerService.PlayerService
local ____ConditionFactory = require("services.extension.condition.ConditionFactory")
local ConditionFactory = ____ConditionFactory.ConditionFactory
local ____ProviderFactory = require("services.extension.provider.ProviderFactory")
local ProviderFactory = ____ProviderFactory.ProviderFactory
local ____StatSlot = require("entities.stat.StatSlot")
local StatSlot = ____StatSlot.StatSlot
local ____LoadoutEntry = require("entities.loadout.LoadoutEntry")
local LoadoutEntry = ____LoadoutEntry.LoadoutEntry
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____CORE_STAT_EXTENSIONS = require("data.stat.CORE_STAT_EXTENSIONS")
local CORE_STAT_EXTENSIONS = ____CORE_STAT_EXTENSIONS.CORE_STAT_EXTENSIONS
local ____HashMap = require("structures.HashMap")
local HashMap = ____HashMap.HashMap
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____LoadoutConfigEntry = require("entities.config.loadout.LoadoutConfigEntry")
local LoadoutConfigEntry = ____LoadoutConfigEntry.LoadoutConfigEntry
____exports.LoadoutService = __TS__Class()
local LoadoutService = ____exports.LoadoutService
LoadoutService.name = "LoadoutService"
function LoadoutService.prototype.____constructor(self, configService, playerService, conditionFactory, providerFactory)
    self.configService = configService
    self.playerService = playerService
    self.conditionFactory = conditionFactory
    self.providerFactory = providerFactory
    self.entries = __TS__New(HashMap)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ConfigService)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, PlayerService)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, ConditionFactory)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, ProviderFactory)
        )
    },
    LoadoutService
)
function LoadoutService.prototype.getEntry(self, slot)
    return self.entries:get(slot)
end
function LoadoutService.prototype.reload(self)
    self:unregister()
    local slots = __TS__ArrayFlatMap(
        self.playerService:getPlayers(),
        function(____, player) return self:getSlotsForPlayer(player) end
    )
    __TS__ArrayForEach(
        slots,
        function(____, slot)
            do
                local function ____catch(e)
                    error(
                        __TS__New(ErrorWithContext, "Error during loadout entry creation.", {playerIndex = slot.player.index, stat = slot.stat}, e),
                        0
                    )
                end
                local ____try, ____hasReturned = pcall(function()
                    self.entries:set(
                        slot,
                        self:createEntryFromSlot(slot)
                    )
                end)
                if not ____try then
                    ____catch(____hasReturned)
                end
            end
        end
    )
end
function LoadoutService.prototype.unregister(self)
    __TS__ArrayForEach(
        __TS__ArrayFrom(self.entries:values()),
        function(____, entry) return entry:unregister() end
    )
    self.entries:clear()
end
function LoadoutService.prototype.getSlotsForPlayer(self, player)
    return __TS__ArrayMap(
        CORE_STAT_EXTENSIONS,
        function(____, statType) return __TS__New(StatSlot, statType, player) end
    )
end
function LoadoutService.prototype.createEntryFromSlot(self, slot)
    local loadout = self.configService:getConfig().loadout
    local primaryProviderInstance = self.providerFactory:createProvider(
        loadout:getPrimaryProvider(slot.stat),
        slot.stat,
        slot.player
    )
    local secondaryProviderInstance = self.providerFactory:createProvider(
        loadout:getSecondaryProvider(slot.stat),
        slot.stat,
        slot.player
    )
    local condition = self.conditionFactory:createCondition(
        __TS__New(
            LoadoutConfigEntry,
            {
                stat = slot.stat,
                condition = loadout:getCondition(slot.stat),
                primaryProvider = primaryProviderInstance:getProvider():getExtension(),
                secondaryProvider = secondaryProviderInstance:getProvider():getExtension()
            }
        ),
        slot.player,
        slot.stat,
        primaryProviderInstance,
        secondaryProviderInstance
    )
    return __TS__New(
        LoadoutEntry,
        slot,
        condition,
        primaryProviderInstance,
        secondaryProviderInstance
    )
end
LoadoutService = __TS__DecorateLegacy(
    {Singleton(nil)},
    LoadoutService
)
____exports.LoadoutService = LoadoutService
return ____exports
