local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Container = require("app.ioc.Container")
local Container = ____Container.Container
____exports.APPLICATION_CONTAINER = __TS__New(Container)
return ____exports
