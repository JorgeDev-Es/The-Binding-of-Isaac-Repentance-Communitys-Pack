local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local __TS__ArrayReduce = ____lualib.__TS__ArrayReduce
local __TS__ArraySome = ____lualib.__TS__ArraySome
local __TS__StringSplit = ____lualib.__TS__StringSplit
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local Challenge = ____isaac_2Dtypescript_2Ddefinitions.Challenge
local Difficulty = ____isaac_2Dtypescript_2Ddefinitions.Difficulty
local PlayerType = ____isaac_2Dtypescript_2Ddefinitions.PlayerType
local ____PlayerService = require("services.PlayerService")
local PlayerService = ____PlayerService.PlayerService
local ____FontFactory = require("services.renderer.FontFactory")
local FontFactory = ____FontFactory.FontFactory
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
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
local ____GameService = require("services.GameService")
local GameService = ____GameService.GameService
____exports.RenderPositionProvider = __TS__Class()
local RenderPositionProvider = ____exports.RenderPositionProvider
RenderPositionProvider.name = "RenderPositionProvider"
function RenderPositionProvider.prototype.____constructor(self, isaac, game, playerService, configService, gameService, fontFactory)
    self.isaac = isaac
    self.game = game
    self.playerService = playerService
    self.configService = configService
    self.gameService = gameService
    self.fontFactory = fontFactory
    self.statFont = self.fontFactory:create("font/luaminioutlined.fnt")
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
            Inject(nil, PlayerService)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, ConfigService)
        ),
        __TS__DecorateParam(
            4,
            Inject(nil, GameService)
        ),
        __TS__DecorateParam(
            5,
            Inject(nil, FontFactory)
        )
    },
    RenderPositionProvider
)
function RenderPositionProvider.prototype.getPosition(self, slot, statText)
    return self:getTransformedPosition(
        slot,
        statText,
        self:getBasePositionFor(slot.stat)
    )
end
function RenderPositionProvider.prototype.getBasePositionFor(self, stat)
    local ____opt_0 = self.playerService:getMainPlayer()
    if (____opt_0 and ____opt_0.entityPlayer:GetPlayerType()) == PlayerType.JACOB then
        return self:getJacobAndEsauBasePosition(stat)
    end
    if #self.playerService:getPlayers() > 1 then
        return self:getMultiplePlayersBasePosition(stat)
    end
    return self:getSinglePlayerBasePosition(stat)
end
function RenderPositionProvider.prototype.getJacobAndEsauBasePosition(self, stat)
    if stat == speed then
        return {17, 87}
    end
    if stat == tears then
        return {17, 96}
    end
    if stat == damage then
        return {17, 110}
    end
    if stat == range then
        return {17, 124}
    end
    if stat == shotSpeed then
        return {17, 138}
    end
    if stat == luck then
        return {17, 152}
    end
    error(
        __TS__New(ErrorWithContext, "Unsupported stat.", {stat = stat}),
        0
    )
end
function RenderPositionProvider.prototype.getMultiplePlayersBasePosition(self, stat)
    if stat == speed then
        return {17, 84}
    end
    if stat == tears then
        return {17, 98}
    end
    if stat == damage then
        return {17, 112}
    end
    if stat == range then
        return {17, 126}
    end
    if stat == shotSpeed then
        return {17, 140}
    end
    if stat == luck then
        return {17, 154}
    end
    error(
        __TS__New(ErrorWithContext, "Unsupported stat.", {stat = stat}),
        0
    )
end
function RenderPositionProvider.prototype.getSinglePlayerBasePosition(self, stat)
    if stat == speed then
        return {17, 88}
    end
    if stat == tears then
        return {17, 100}
    end
    if stat == damage then
        return {17, 112}
    end
    if stat == range then
        return {17, 124}
    end
    if stat == shotSpeed then
        return {17, 136}
    end
    if stat == luck then
        return {17, 148}
    end
    error(
        __TS__New(ErrorWithContext, "Unsupported stat.", {stat = stat}),
        0
    )
end
function RenderPositionProvider.prototype.getTransformedPosition(self, slot, statText, basePosition)
    return __TS__ArrayReduce(
        {
            self:createPlayerIndexTransformer(slot.player.index),
            self:createTextLengthTransformer(statText),
            self:createScreenShakeOffsetTransformer(),
            self:createBethanyTransformer(),
            self:createJacobTransformer(),
            self:createIconTransformer(),
            self:createConfigSpacingTransformer()
        },
        function(____, acc, transformer) return transformer(nil, acc) end,
        basePosition
    )
end
function RenderPositionProvider.prototype.createIconTransformer(self)
    return function(____, ____bindingPattern0)
        local y
        local x
        x = ____bindingPattern0[1]
        y = ____bindingPattern0[2]
        if self.game.Difficulty == Difficulty.NORMAL and self.isaac.GetChallenge() == Challenge.NULL and self.gameService:areAchievementsEnabled() then
            return {x, y - 16}
        end
        return {x, y}
    end
end
function RenderPositionProvider.prototype.createJacobTransformer(self)
    return function(____, ____bindingPattern0)
        local y
        local x
        x = ____bindingPattern0[1]
        y = ____bindingPattern0[2]
        if self.isaac.GetPlayer(0):GetPlayerType() == PlayerType.JACOB then
            return {x, y + 16}
        end
        return {x, y}
    end
end
function RenderPositionProvider.prototype.createScreenShakeOffsetTransformer(self)
    return function(____, ____bindingPattern0)
        local y
        local x
        x = ____bindingPattern0[1]
        y = ____bindingPattern0[2]
        return {x + self.game.ScreenShakeOffset.X + Options.HUDOffset * 20, y + self.game.ScreenShakeOffset.Y + Options.HUDOffset * 12}
    end
end
function RenderPositionProvider.prototype.createBethanyTransformer(self)
    local function isBethany(self, player)
        return player.entityPlayer:GetPlayerType() == PlayerType.BETHANY or player.entityPlayer:GetPlayerType() == PlayerType.BETHANY_B
    end
    return function(____, ____bindingPattern0)
        local y
        local x
        x = ____bindingPattern0[1]
        y = ____bindingPattern0[2]
        if __TS__ArraySome(
            self.playerService:getPlayers(),
            isBethany
        ) then
            return {x, y + 9}
        end
        return {x, y}
    end
end
function RenderPositionProvider.prototype.createPlayerIndexTransformer(self, playerIndex)
    return function(____, ____bindingPattern0)
        local y
        local x
        x = ____bindingPattern0[1]
        y = ____bindingPattern0[2]
        if playerIndex > 0 then
            return {x + 4, y + 7}
        end
        return {x, y}
    end
end
function RenderPositionProvider.prototype.createTextLengthTransformer(self, text)
    return function(____, ____bindingPattern0)
        local y
        local x
        x = ____bindingPattern0[1]
        y = ____bindingPattern0[2]
        if text == nil then
            return {x, y}
        end
        local textWidth = __TS__ArrayReduce(
            __TS__StringSplit(text, ""),
            function(____, acc, char) return acc + self.statFont:GetCharacterWidth(char) end,
            0
        )
        return {x + textWidth, y}
    end
end
function RenderPositionProvider.prototype.createConfigSpacingTransformer(self)
    return function(____, ____bindingPattern0)
        local y
        local x
        x = ____bindingPattern0[1]
        y = ____bindingPattern0[2]
        return {
            x + self.configService:getConfig().appearance:getSpacing(),
            y
        }
    end
end
RenderPositionProvider = __TS__DecorateLegacy(
    {Singleton(nil)},
    RenderPositionProvider
)
____exports.RenderPositionProvider = RenderPositionProvider
return ____exports
