local ____lualib = require("lualib_bundle")
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__Generator = ____lualib.__TS__Generator
local ____exports = {}
____exports.mapIterator = __TS__Generator(function(self, iterator, mapper)
    for ____, element in __TS__Iterator(iterator) do
        coroutine.yield(mapper(nil, element))
    end
end)
return ____exports
