local ____exports = {}
function ____exports.tryCatch(self, func, fallback)
    do
        local function ____catch(e)
            return true, fallback(nil, e)
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            return true, func(nil)
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
