local mod = FiendFolio

function mod.customProjectileBehavior(v, d)
    if d.projType == "customProjectileBehavior" and d.customProjectileBehavior then
        local tab = d.customProjectileBehavior
        if tab.customFunc then
            tab.customFunc(v, tab)
        end
    end
end

function mod.customProjectileRemove(v, d)
    if d.projType == "customProjectileBehavior" and d.customProjectileBehavior and d.customProjectileBehavior.death then
        local tab = d.customProjectileBehavior
        tab.death(v, tab)
    end
end

function mod.customTearBehavior(v, d)
    if d.customTearBehavior then
        local tab = d.customTearBehavior
        if tab.customFunc then
            tab.customFunc(v, tab)
        end
    end
end

function mod.customTearRemove(v, d)
    if d.customTearBehavior and d.customTearBehavior.death then
        local tab = d.customTearBehavior
        tab.death(v, tab)
    end
end