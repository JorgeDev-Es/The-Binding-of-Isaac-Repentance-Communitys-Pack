local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ObjectFromEntries = ____lualib.__TS__ObjectFromEntries
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____isValidId = require("util.validation.isValidId")
local isValidId = ____isValidId.isValidId
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____APISettingValidator = require("validators.api.APISettingValidator")
local APISettingValidator = ____APISettingValidator.APISettingValidator
local ____APIConditionValidator = require("validators.api.APIConditionValidator")
local APIConditionValidator = ____APIConditionValidator.APIConditionValidator
local ____APIProviderStateValidator = require("validators.api.APIProviderStateValidator")
local APIProviderStateValidator = ____APIProviderStateValidator.APIProviderStateValidator
____exports.APIProviderValidator = __TS__Class()
local APIProviderValidator = ____exports.APIProviderValidator
APIProviderValidator.name = "APIProviderValidator"
function APIProviderValidator.prototype.____constructor(self, apiSettingValidator, apiConditionValidator, apiProviderStateValidator)
    self.apiSettingValidator = apiSettingValidator
    self.apiConditionValidator = apiConditionValidator
    self.apiProviderStateValidator = apiProviderStateValidator
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, APISettingValidator)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, APIConditionValidator)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, APIProviderStateValidator)
        )
    },
    APIProviderValidator
)
function APIProviderValidator.prototype.validate(self, provider)
    return {
        id = self:validateId(provider and provider.id),
        name = self:validateName(provider and provider.name),
        description = self:validateDescription(provider and provider.description),
        targets = self:validateTargets(provider and provider.targets),
        display = self:validateDisplay(provider and provider.display),
        color = self:validateColor(provider and provider.color),
        computables = self:validateComputables(provider and provider.computables),
        conditions = self:validateConditions(provider and provider.conditions),
        settings = self:validateSettings(provider and provider.settings),
        state = self.apiProviderStateValidator:validateState(provider and provider.state),
        mount = self:validateMount(provider and provider.mount)
    }
end
function APIProviderValidator.prototype.validateId(self, id)
    if type(id) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider id (`.id`) to be a string.",
                {
                    id = id,
                    idType = __TS__TypeOf(id)
                }
            ),
            0
        )
    end
    if #id == 0 then
        error(
            __TS__New(Error, "Expected provider id (`.id`) to not be empty."),
            0
        )
    end
    if not isValidId(nil, id) then
        error(
            __TS__New(ErrorWithContext, "Expected provider id (`.id`) to contain only lowercase letters, digits and hyphen-minus signs.", {id = id}),
            0
        )
    end
    return id
end
function APIProviderValidator.prototype.validateName(self, name)
    if type(name) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider name (`.name`) to be a string.",
                {
                    name = name,
                    nameType = __TS__TypeOf(name)
                }
            ),
            0
        )
    end
    if #name == 0 then
        error(
            __TS__New(Error, "Expected provider name (`.name`) to not be empty."),
            0
        )
    end
    return name
end
function APIProviderValidator.prototype.validateDescription(self, description)
    if type(description) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider description (`.description`) to be a string.",
                {
                    description = description,
                    descriptionType = __TS__TypeOf(description)
                }
            ),
            0
        )
    end
    if #description == 0 then
        error(
            __TS__New(Error, "Expected provider description (`.description`) to not be empty."),
            0
        )
    end
    return description
end
function APIProviderValidator.prototype.validateTargets(self, targets)
    if targets == nil then
        return nil
    end
    if not __TS__ArrayIsArray(targets) then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider targets (`.targets`) to be an array.",
                {
                    targets = targets,
                    targetsType = __TS__TypeOf(targets)
                }
            ),
            0
        )
    end
    if #targets == 0 then
        error(
            __TS__New(Error, "Expected provider targets (`.targets`) to be a non-empty array." .. "Don't set this property if you intend to target all stats."),
            0
        )
    end
    return __TS__ArrayMap(
        targets,
        function(____, target) return self:validateTarget(target) end
    )
end
function APIProviderValidator.prototype.validateTarget(self, target)
    if type(target) ~= "table" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider target to be an object.",
                {
                    target = target,
                    targetType = __TS__TypeOf(target)
                }
            ),
            0
        )
    end
    if type(target.addon) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider target addon to be a string.",
                {
                    addon = target.addon,
                    addonType = __TS__TypeOf(target.addon)
                }
            ),
            0
        )
    end
    if type(target.id) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider target id to be a string.",
                {
                    id = target.id,
                    idType = __TS__TypeOf(target.id)
                }
            ),
            0
        )
    end
    return target
end
function APIProviderValidator.prototype.validateDisplay(self, display)
    if type(display) ~= "table" or display == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display settings (`display`) to be an object.",
                {
                    display = display,
                    displayType = __TS__TypeOf(display)
                }
            ),
            0
        )
    end
    if type(display.value) ~= "table" or display.value == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display value settings (`display.value`) to be an object.",
                {
                    displayValue = display.value,
                    displayValueType = __TS__TypeOf(display.value)
                }
            ),
            0
        )
    end
    if type(display.value.get) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display value getter (`display.value.get`) to be a function.",
                {
                    displayValueGetter = display.value.get,
                    displayValueGetterType = __TS__TypeOf(display.value.get)
                }
            ),
            0
        )
    end
    if type(display.value.format) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display value formatter (`display.value.format`) to be a function.",
                {
                    displayValueFormatter = display.value.format,
                    displayValueFormatterType = __TS__TypeOf(display.value.format)
                }
            ),
            0
        )
    end
    if display.change ~= nil and (display.change == nil or type(display.change) ~= "table") then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display change settings (`display.change`) - if set - to be an object.",
                {
                    displayChange = display.change,
                    displayChangeType = __TS__TypeOf(display.change)
                }
            ),
            0
        )
    end
    if display.change ~= nil and type(display.change) ~= "table" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display change settings (`display.change`) to be an object.",
                {
                    displayChange = display.change,
                    displayChangeType = __TS__TypeOf(display.change)
                }
            ),
            0
        )
    end
    if display.change ~= nil and type(display.change.format) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display change formatter (`display.change.format`) to be a function.",
                {
                    displayChangeFormatter = display.change.format,
                    displayChangeFormatterType = __TS__TypeOf(display.change.format)
                }
            ),
            0
        )
    end
    if display.change ~= nil and type(display.change.compute) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display change compute function (`display.change.compute`) to be a function.",
                {
                    displayChangeComputeFn = display.change.compute,
                    displayChangeComputeFnType = __TS__TypeOf(display.change.compute)
                }
            ),
            0
        )
    end
    local ____opt_22 = display.change
    if (____opt_22 and ____opt_22.isPositive) ~= nil and type(display.change.isPositive) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider display change isPositive function (`display.change.isPositive`) - if set - to be a function.",
                {
                    displayChangeIsPositiveFn = display.change.isPositive,
                    displayChangeIsPositiveFnType = __TS__TypeOf(display.change.isPositive)
                }
            ),
            0
        )
    end
    return display
end
function APIProviderValidator.prototype.validateColor(self, color)
    if color == nil then
        return nil
    end
    if not __TS__ArrayIncludes(____exports.APIProviderValidator.AVAILABLE_COLORS, color) then
        local availableColors = table.concat(
            __TS__ArrayMap(
                ____exports.APIProviderValidator.AVAILABLE_COLORS,
                function(____, color) return ("\"" .. color) .. "\"" end
            ),
            ", "
        )
        error(
            __TS__New(
                ErrorWithContext,
                ("Expected provider color (`.color`) to be one of " .. availableColors) .. ".",
                {
                    color = color,
                    colorType = __TS__TypeOf(color)
                }
            ),
            0
        )
    end
    return color
end
function APIProviderValidator.prototype.validateComputables(self, computables)
    if computables == nil then
        return nil
    end
    if type(computables) ~= "table" or computables == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider computables (`.computables`) to be an object.",
                {
                    computables = computables,
                    computablesType = __TS__TypeOf(computables)
                }
            ),
            0
        )
    end
    return __TS__ObjectFromEntries(__TS__ArrayMap(
        __TS__ObjectEntries(computables),
        function(____, ____bindingPattern0)
            local computable
            local key
            key = ____bindingPattern0[1]
            computable = ____bindingPattern0[2]
            return {
                key,
                self:validateComputable(computable)
            }
        end
    ))
end
function APIProviderValidator.prototype.validateComputable(self, computable)
    if type(computable) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected computable to be a function.",
                {
                    computable = computable,
                    computableType = __TS__TypeOf(computable)
                }
            ),
            0
        )
    end
    return computable
end
function APIProviderValidator.prototype.validateConditions(self, conditions)
    if conditions == nil then
        return nil
    end
    if type(conditions) ~= "table" or conditions == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider conditions (`.conditions`) to be an object.",
                {
                    conditions = conditions,
                    conditionsType = __TS__TypeOf(conditions)
                }
            ),
            0
        )
    end
    return __TS__ObjectFromEntries(__TS__ArrayMap(
        __TS__ObjectEntries(conditions),
        function(____, ____bindingPattern0)
            local condition
            local key
            key = ____bindingPattern0[1]
            condition = ____bindingPattern0[2]
            return {
                key,
                self.apiConditionValidator:validateCompanionCondition(condition)
            }
        end
    ))
end
function APIProviderValidator.prototype.validateSettings(self, settings)
    if settings == nil then
        return nil
    end
    if type(settings) ~= "table" or settings == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider settings (.settings) to be an object.",
                {
                    settings = settings,
                    settingsType = __TS__TypeOf(settings)
                }
            ),
            0
        )
    end
    return __TS__ObjectFromEntries(__TS__ArrayMap(
        __TS__ObjectEntries(settings),
        function(____, ____bindingPattern0)
            local setting
            local key
            key = ____bindingPattern0[1]
            setting = ____bindingPattern0[2]
            return {
                key,
                self.apiSettingValidator:validateSetting(setting)
            }
        end
    ))
end
function APIProviderValidator.prototype.validateMount(self, mount)
    if type(mount) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider mount function (`.mount`) to be a function.",
                {
                    mountFn = mount,
                    mountFnType = __TS__TypeOf(mount)
                }
            ),
            0
        )
    end
    return mount
end
APIProviderValidator.AVAILABLE_COLORS = {
    "NONE",
    "GREY",
    "RED",
    "GREEN",
    "BLUE",
    "ORANGE",
    "MAGENTA",
    "CYAN"
}
APIProviderValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIProviderValidator
)
____exports.APIProviderValidator = APIProviderValidator
return ____exports
