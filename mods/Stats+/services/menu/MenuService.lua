local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____ModConfigMenuService = require("services.menu.ModConfigMenuService")
local ModConfigMenuService = ____ModConfigMenuService.ModConfigMenuService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
____exports.MenuService = __TS__Class()
local MenuService = ____exports.MenuService
MenuService.name = "MenuService"
function MenuService.prototype.____constructor(self, modConfigMenuService)
    self.modConfigMenuService = modConfigMenuService
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, ModConfigMenuService)
    )},
    MenuService
)
function MenuService.prototype.reload(self)
    self.modConfigMenuService:reload()
end
MenuService = __TS__DecorateLegacy(
    {Singleton(nil)},
    MenuService
)
____exports.MenuService = MenuService
return ____exports
