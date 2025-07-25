local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____MenuGeneralSection = require("services.menu.sections.MenuGeneralSection")
local MenuGeneralSection = ____MenuGeneralSection.MenuGeneralSection
local ____MenuLoadoutSection = require("services.menu.sections.MenuLoadoutSection")
local MenuLoadoutSection = ____MenuLoadoutSection.MenuLoadoutSection
local ____MenuProvidersSection = require("services.menu.sections.MenuProvidersSection")
local MenuProvidersSection = ____MenuProvidersSection.MenuProvidersSection
____exports.MenuSectionProvider = __TS__Class()
local MenuSectionProvider = ____exports.MenuSectionProvider
MenuSectionProvider.name = "MenuSectionProvider"
function MenuSectionProvider.prototype.____constructor(self, menuGeneralSection, menuLoadoutSection, menuProvidersSection)
    self.menuGeneralSection = menuGeneralSection
    self.menuLoadoutSection = menuLoadoutSection
    self.menuProvidersSection = menuProvidersSection
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, MenuGeneralSection)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, MenuLoadoutSection)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, MenuProvidersSection)
        )
    },
    MenuSectionProvider
)
function MenuSectionProvider.prototype.getMenuSections(self)
    return {self.menuGeneralSection, self.menuLoadoutSection, self.menuProvidersSection}
end
MenuSectionProvider = __TS__DecorateLegacy(
    {Singleton(nil)},
    MenuSectionProvider
)
____exports.MenuSectionProvider = MenuSectionProvider
return ____exports
