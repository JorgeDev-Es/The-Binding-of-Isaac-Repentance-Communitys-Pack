--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.doesSomePlayerHaveItem(self, collectibleType)
    do
        local i = 0
        while i < Game():GetNumPlayers() do
            if Isaac.GetPlayer(i):HasCollectible(collectibleType) then
                return true
            end
            i = i + 1
        end
    end
    return false
end
return ____exports
