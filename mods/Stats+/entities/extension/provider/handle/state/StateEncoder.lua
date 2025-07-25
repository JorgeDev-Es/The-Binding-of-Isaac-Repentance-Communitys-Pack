local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
____exports.StateEncoder = __TS__Class()
local StateEncoder = ____exports.StateEncoder
StateEncoder.name = "StateEncoder"
function StateEncoder.prototype.____constructor(self, encoder, createInitialValue)
    self.encoder = encoder
    self.createInitialValue = createInitialValue
    self.logger = Logger["for"](Logger, ____exports.StateEncoder.name)
end
function StateEncoder.prototype.encode(self, decoded)
    do
        local function ____catch(e)
            self.logger:error("Failed to encode provider state.", e)
            error(e, 0)
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            return true, self.encoder:encode(decoded)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
function StateEncoder.prototype.decode(self, encoded)
    do
        local function ____catch(e)
            self.logger:error("Failed to decode provider state, returning initial state instead.", e)
            return true, self:createInitialValue()
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            return true, self.encoder:decode(encoded)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
return ____exports
