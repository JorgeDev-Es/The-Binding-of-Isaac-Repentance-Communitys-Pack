local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____StructuralComparator = require("services.StructuralComparator")
local StructuralComparator = ____StructuralComparator.StructuralComparator
____exports.CompanionConditionDefinition = __TS__Class()
local CompanionConditionDefinition = ____exports.CompanionConditionDefinition
CompanionConditionDefinition.name = "CompanionConditionDefinition"
function CompanionConditionDefinition.prototype.____constructor(self, extension, condition, modCallbackService)
    self.extension = extension
    self.condition = condition
    self.modCallbackService = modCallbackService
    self.structuralComparator = __TS__New(StructuralComparator)
end
function CompanionConditionDefinition.prototype.getId(self)
    return self.condition.id
end
function CompanionConditionDefinition.prototype.getName(self)
    return self.condition.name
end
function CompanionConditionDefinition.prototype.getDescription(self)
    return self.condition.description
end
function CompanionConditionDefinition.prototype.getExtension(self)
    return self.extension
end
function CompanionConditionDefinition.prototype.mount(self, providerInstances, context)
    local providerHandle = __TS__ArrayFind(
        providerInstances,
        function(____, providerInstance) return self.structuralComparator:compare(
            providerInstance:getProvider():getExtension(),
            self.extension.providerExtension
        ) end
    )
    if providerHandle == nil then
        error(
            __TS__New(Error, "No matching provider instance handle found for the given companion condition."),
            0
        )
    end
    local listener = __TS__FunctionBind(self.onPostUpdate, self, providerHandle, context)
    self.modCallbackService:addCallback(ModCallback.POST_UPDATE, listener)
    return function() return self.modCallbackService:removeCallback(ModCallback.POST_UPDATE, listener) end
end
function CompanionConditionDefinition.prototype.onPostUpdate(self, providerHandle, context)
    context:setActive(providerHandle:isCompanionConditionActive(self.condition.id))
end
return ____exports
