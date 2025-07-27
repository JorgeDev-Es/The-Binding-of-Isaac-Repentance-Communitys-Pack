local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

FiendFolio.D10OverridesBaseGame = {
    [EntityType.ENTITY_GAPER .. ".1.0"] = function(entity)
        return {mod.FF.Morsel1.ID, mod.FF.Morsel1.Var, mod.FF.Morsel1.Sub}
    end,
    [EntityType.ENTITY_HORF .. ".0.0"] = function(entity)
        return {mod.FF.Buoy.ID, mod.FF.Buoy.Var, 1}
    end,
    [EntityType.ENTITY_HOST .. ".0.0"] = function(entity)
        return {mod.FF.Hostlet.ID, mod.FF.Hostlet.Var, mod.FF.Hostlet.Sub}
    end,
    [EntityType.ENTITY_HOST .. ".1.0"] = function(entity) --Red host
        return {mod.FF.RedHostlet.ID, mod.FF.RedHostlet.Var, mod.FF.RedHostlet.Sub}
    end,
    [EntityType.ENTITY_SPIDER .. ".0.0"] = function(entity)
        return {mod.FF.BabySpider.ID, mod.FF.BabySpider.Var}
    end,
    [EntityType.ENTITY_BUTTLICKER .. ".0.0"] = function(entity)
        return {mod.FF.Buoy.ID, mod.FF.Buoy.Var, 1}
    end,
    [EntityType.ENTITY_TUMOR .. ".0.0"] = function(entity)
        return {mod.FF.Benign.ID, mod.FF.Benign.Var}
    end,
    [EntityType.ENTITY_TUMOR .. ".1.0"] = function(entity) --Planetoid
        return {mod.FF.Minimoon.ID, mod.FF.Minimoon.Var}
    end,
    [EntityType.ENTITY_MUSHROOM .. ".0.0"] = function(entity)
        return {mod.FF.Shiitake.ID, mod.FF.Shiitake.Var}
    end,
    [EntityType.ENTITY_FLOATING_HOST .. ".0.0"] = function(entity)
        return {mod.FF.Tittle.ID, mod.FF.Tittle.Var}
    end,
    [EntityType.ENTITY_SWARM_SPIDER .. ".0.0"] = function(entity)
        return {mod.FF.BabySpider.ID, mod.FF.BabySpider.Var}
    end,
}

FiendFolio.D10Overrides = {
    [mod.FF.SoftServe.ID .. "." .. mod.FF.SoftServe.Var] = function(entity)
        local d = entity:GetData()
        if d.scoopnumber == 3 then
            return {mod.FF.Sundae.ID, mod.FF.Sundae.Var}
        elseif d.scoopnumber == 2 then
            return {mod.FF.Scoop.ID, mod.FF.Scoop.Var}
        else
            return {EntityType.ENTITY_DIP, 2}
        end
    end,
    [mod.FF.Curdle.ID .. "." .. mod.FF.Curdle.Var] = function(entity)
        local d = entity:GetData()
        if d.skin then
            return {mod.FF.PaleBleedy.ID, mod.FF.PaleBleedy.Var}
        end
    end,
    [mod.FF.Prick.ID .. "." .. mod.FF.Prick.Var] = function(entity)
        if not entity.Child then
            if entity.Parent then
                entity:Kill()
                return true
            else
                return {mod.FF.Unshornz.ID, mod.FF.Unshornz.Var}
            end
        else
            return true
        end
    end,
    [mod.FF.BubbleBaby.ID .. "." .. mod.FF.BubbleBaby.Var] = function(entity)
        if entity.SubType > 0 then
            return {mod.FF.BubbleWaterySmall.ID, mod.FF.BubbleWaterySmall.Var, mod.FF.BubbleWaterySmall.Sub}
        else
            return {mod.FF.BubbleBaby.ID, mod.FF.BubbleBaby.Var, math.random(2)}
        end
    end,
    [FiendFolio.FFID.Weaver] = function(entity)
        if entity:ToNPC().Parent then
            entity:Remove()
            return true
        end
    end,
    [mod.FF.Trashbagger.ID .. "." .. mod.FF.Trashbagger.Var] = function(entity)
        Isaac.Spawn(1000, 15, 0, entity.Position, nilvector, nil)
    end,
    [mod.FF.Bola.ID .. "." .. mod.FF.Bola.Var] = function(entity)
        if entity.SubType == 1 then
            entity:Remove()
            return true
        end
    end,
    [mod.FF.RotspinMoon.ID .. "." .. mod.FF.RotspinMoon.Var] = function(entity)
        entity:Remove()
        return true
    end,
    [mod.FF.Centipede.ID .. "." .. mod.FF.Centipede.Var] = function(entity)
        if entity.Parent then
            return {mod.FF.CongaSkuzz.ID, mod.FF.CongaSkuzz.Var, 0}
        else
            return {mod.FF.CongaSkuzz.ID, mod.FF.CongaSkuzz.Var, 1}
        end
        return true
    end,
}

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_DEVOLVE, function(_, entity)
    local spawn
    if FiendFolio.D10Overrides[entity.Type] then
        spawn = FiendFolio.D10Overrides[entity.Type](entity)
    elseif FiendFolio.D10Overrides[entity.Type .. "." .. entity.Variant] then
        spawn = FiendFolio.D10Overrides[entity.Type .. "." .. entity.Variant](entity)
    elseif FiendFolio.D10OverridesBaseGame[entity.Type .. "." .. entity.Variant .. "." .. entity.SubType] then
        spawn = FiendFolio.D10OverridesBaseGame[entity.Type .. "." .. entity.Variant .. "." .. entity.SubType](entity)
    end
    if spawn ~= nil then
        --print(spawn, type(spawn))
        if type(spawn) == "boolean" then
            return true
        else
            local devolved = Isaac.Spawn(spawn[1] or 10, spawn[2] or 0, spawn[3] or 0, entity.Position, nilvector, entity)
            if devolved:ToNPC() then
                devolved.HitPoints = devolved.MaxHitPoints * (entity.HitPoints/entity.MaxHitPoints)
                devolved:ToNPC():Morph(devolved.Type, devolved.Variant, devolved.SubType, entity:ToNPC():GetChampionColorIdx())
            end
            devolved:Update()
            entity:Remove()
            --[[if not sfx:IsPlaying(SoundEffect.SOUND_SUMMON_POOF) then
                sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 1, 0, false, 1)
            end]]
            return true
        end
    end
end)