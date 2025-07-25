local ____exports = {}
function ____exports.isExtensionRef(self, ref)
    return type(ref and ref.addon) == "string" and type(ref and ref.id) == "string"
end
return ____exports
