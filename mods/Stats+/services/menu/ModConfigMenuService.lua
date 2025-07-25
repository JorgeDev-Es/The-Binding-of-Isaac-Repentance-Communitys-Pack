local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ModConfigMenu = require("entities.menu.mcm.ModConfigMenu")
local ModConfigMenu = ____ModConfigMenu.ModConfigMenu
local ____MenuSectionProvider = require("services.menu.MenuSectionProvider")
local MenuSectionProvider = ____MenuSectionProvider.MenuSectionProvider
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
____exports.ModConfigMenuService = __TS__Class()
local ModConfigMenuService = ____exports.ModConfigMenuService
ModConfigMenuService.name = "ModConfigMenuService"
function ModConfigMenuService.prototype.____constructor(self, modConfigMenu, menuSectionProvider)
    self.modConfigMenu = modConfigMenu
    self.menuSectionProvider = menuSectionProvider
    self.logger = Logger["for"](Logger, ____exports.ModConfigMenuService.name)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, InjectionToken.ModConfigMenu)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, MenuSectionProvider)
        )
    },
    ModConfigMenuService
)
function ModConfigMenuService.prototype.reload(self)
    self.logger:info("Waiting for the ModConfigMenuProviderService...")
    self.modConfigMenu:get(function(____, modConfigMenu)
        if modConfigMenu == nil then
            self.logger:info("No Mod Config Menu is present, skipping the registration of ModConfigMenuService.")
            return
        end
        self.logger:info("Registering Mod Config Menu.", {modConfigMenuVersion = modConfigMenu.Version})
        self:registerModConfigMenu(modConfigMenu)
    end)
end
function ModConfigMenuService.prototype.registerModConfigMenu(self, modConfigMenu)
    modConfigMenu.RemoveCategory(____exports.ModConfigMenuService.CATEGORY_NAME)
    modConfigMenu.UpdateCategory(____exports.ModConfigMenuService.CATEGORY_NAME, {Name = ____exports.ModConfigMenuService.CATEGORY_NAME, Info = ____exports.ModConfigMenuService.CATEGORY_DESCRIPTION, IsOld = false})
    __TS__ArrayForEach(
        self.menuSectionProvider:getMenuSections(),
        function(____, section)
            local menu = __TS__New(
                ModConfigMenu,
                {
                    modConfigMenu = modConfigMenu,
                    category = ____exports.ModConfigMenuService.CATEGORY_NAME,
                    subcategory = section:getIdentifier()
                }
            )
            section:register(menu)
        end
    )
end
ModConfigMenuService.CATEGORY_NAME = "Stats+"
ModConfigMenuService.CATEGORY_DESCRIPTION = "Choose what, how, and when to display Stats+ data."
ModConfigMenuService = __TS__DecorateLegacy(
    {Singleton(nil)},
    ModConfigMenuService
)
____exports.ModConfigMenuService = ModConfigMenuService
return ____exports
