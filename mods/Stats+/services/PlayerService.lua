local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local Set = ____lualib.Set
local __TS__New = ____lualib.__TS__New
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local BabySubType = ____isaac_2Dtypescript_2Ddefinitions.BabySubType
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local PlayerType = ____isaac_2Dtypescript_2Ddefinitions.PlayerType
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____LifecycleService = require("services.LifecycleService")
local LifecycleService = ____LifecycleService.LifecycleService
local ____Player = require("entities.player.Player")
local Player = ____Player.Player
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
____exports.PlayerService = __TS__Class()
local PlayerService = ____exports.PlayerService
PlayerService.name = "PlayerService"
function PlayerService.prototype.____constructor(self, isaac, game, modCallbackService, lifecycleService)
    self.isaac = isaac
    self.game = game
    self.modCallbackService = modCallbackService
    self.lifecycleService = lifecycleService
    self.onPostPlayerInitCallback = __TS__FunctionBind(self.onPostPlayerInit, self)
    self.onPostUpdateCallback = __TS__FunctionBind(self.onPostUpdate, self)
    self.logger = Logger["for"](Logger, ____exports.PlayerService.name)
    self.players = {}
    self.recomputePlayersOnNextTick = false
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, InjectionToken.IsaacAPI)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, InjectionToken.GameAPI)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, ModCallbackService)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, LifecycleService)
        )
    },
    PlayerService
)
function PlayerService.prototype.getMainPlayer(self)
    return __TS__ArrayFind(
        self:getPlayers(),
        function(____, player) return player:isMainPlayer() end
    )
end
function PlayerService.prototype.getPlayerByEntity(self, entityPlayer)
    return __TS__ArrayFind(
        self:getPlayers(),
        function(____, player) return entityPlayer.Index == player.entityPlayer.Index and entityPlayer:GetPlayerType() == player.entityPlayer:GetPlayerType() end
    )
end
function PlayerService.prototype.getPlayers(self)
    return __TS__ArraySlice(self.players)
end
function PlayerService.prototype.reload(self)
    self.modCallbackService:removeCallback(ModCallback.POST_UPDATE, self.onPostUpdateCallback)
    self.modCallbackService:removeCallback(ModCallback.POST_PLAYER_INIT, self.onPostPlayerInitCallback)
    self.modCallbackService:addCallback(ModCallback.POST_PLAYER_INIT, self.onPostPlayerInitCallback)
    self.modCallbackService:addCallback(ModCallback.POST_UPDATE, self.onPostUpdateCallback)
    self.players = self:findActivePlayers()
    self.logger:debug("Recomputed current players.", {playerCount = #self.players})
end
function PlayerService.prototype.findActivePlayers(self)
    local allEntityPlayers = self:getAllEntityPlayers()
    local activeEntityPlayers = {}
    local controllerIndices = __TS__New(Set)
    __TS__ArrayForEach(
        allEntityPlayers,
        function(____, entityPlayer)
            if entityPlayer:GetBabySkin() ~= BabySubType.UNASSIGNED or entityPlayer:GetPlayerType() == PlayerType.SOUL_B then
                return
            end
            local previousPlayer = activeEntityPlayers[#activeEntityPlayers]
            if controllerIndices:has(entityPlayer.ControllerIndex) and (entityPlayer:GetPlayerType() ~= PlayerType.ESAU or (previousPlayer and previousPlayer:GetPlayerType()) ~= PlayerType.JACOB) then
                return
            end
            controllerIndices:add(entityPlayer.ControllerIndex)
            activeEntityPlayers[#activeEntityPlayers + 1] = entityPlayer
        end
    )
    return __TS__ArrayMap(
        activeEntityPlayers,
        function(____, entityPlayer, idx) return __TS__New(Player, entityPlayer, idx) end
    )
end
function PlayerService.prototype.getAllEntityPlayers(self)
    local entityPlayers = {}
    do
        local i = 0
        while i < self.game:GetNumPlayers() do
            local entityPlayer = self.isaac.GetPlayer(i)
            if entityPlayer ~= nil then
                entityPlayers[#entityPlayers + 1] = entityPlayer
            end
            i = i + 1
        end
    end
    return entityPlayers
end
function PlayerService.prototype.onPostPlayerInit(self)
    self.recomputePlayersOnNextTick = true
end
function PlayerService.prototype.onPostUpdate(self)
    if not self.recomputePlayersOnNextTick then
        return
    end
    self.recomputePlayersOnNextTick = false
    self.logger:info("Requesting a full reload due to the change of active players.")
    self.lifecycleService:reloadAll()
end
PlayerService = __TS__DecorateLegacy(
    {Singleton(nil)},
    PlayerService
)
____exports.PlayerService = PlayerService
return ____exports
