--MOD DEFINITIONS--
GodsGambit = RegisterMod("God's Gambit", 1)

local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

--LOAD SCRIPTS--
mod.Scripts = {
    "constants",
    "library",

    "virtues.virtues",
    "virtues.kindness",
    "virtues.chastity",
    "virtues.charity",
    "virtues.humility",
    "virtues.diligence",
    "virtues.temperance",
    "virtues.patience",
    "virtues.ultradiligence",
}
for _, s in ipairs(mod.Scripts) do
    include("scripts."..s)
end

--NPC CALLBACKS--
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.Kindness.Var or npc.Variant == mod.ENT.SuperKindness.Var then
        mod:KindnessAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Chastity.Var or npc.Variant == mod.ENT.SuperChastity.Var then
        mod:ChastityAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Charity.Var or npc.Variant == mod.ENT.SuperCharity.Var then
        mod:CharityAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Humility.Var or npc.Variant == mod.ENT.SuperHumility.Var then
        mod:HumilityAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Diligence.Var or npc.Variant == mod.ENT.SuperDiligence.Var then
        mod:DiligenceAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Temperance.Var or npc.Variant == mod.ENT.SuperTemperance.Var then
        mod:TemperanceAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Patience.Var or npc.Variant == mod.ENT.SuperPatience.Var then
        mod:PatienceAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.PatienceMine.Var or npc.Variant == mod.ENT.SuperPatienceMine.Var then
        mod:PatienceMineAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.DiligentRambler.Var then
        mod:DiligentRamblerAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.DiligentRattler.Var then
        mod:DiligentRattlerAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.DiligentStickler.Var then
        mod:DiligentSticklerAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.DiligentSlimer.Var then
        mod:DiligentSlimerAI(npc, sprite, data)
    end
end, 714)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.Kindness.Var or npc.Variant == mod.ENT.SuperKindness.Var then
        mod:KindnessRender(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Patience.Var or npc.Variant == mod.ENT.SuperPatience.Var then
        mod:PatienceRender(npc, sprite, data)
    elseif npc.Variant == mod.ENT.PatienceMine.Var or npc.Variant == mod.ENT.SuperPatienceMine.Var then
        mod:PatienceMineRender(npc, sprite, data)
    end
end, 714)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, amount, flags, source)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.Chastity.Var or npc.Variant == mod.ENT.SuperChastity.Var then
        return mod:ChastityHurt(npc, sprite, data, amount, flags, source)
    elseif npc.Variant == mod.ENT.Humility.Var or npc.Variant == mod.ENT.SuperHumility.Var then
        return mod:HumilityHurt(npc, sprite, data, amount, flags, source)
    elseif npc.Variant == mod.ENT.Patience.Var or npc.Variant == mod.ENT.SuperPatience.Var then
        return mod:PatienceHurt(npc, sprite, data, amount, flags, source)
    elseif npc.Variant == mod.ENT.PatienceMine.Var or npc.Variant == mod.ENT.SuperPatienceMine.Var then
        return mod:PatienceMineHurt(npc, sprite, data, amount, flags, source)
    end
end, 714)

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
    mod:CheckVirtueDeath(npc)
end, 714)

--PROJECTILE CALLBACKS--
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    local data = proj:GetData()
    
    if data.projType then
        if data.projType == "CharityOrb" then
            mod:CharityOrbProjectile(proj, data)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, function(_, proj)
    local data = proj:GetData()
    
    if data.projType then
        if data.projType == "CharityCoin" then
            mod:CharityCoinProjectileDeath(proj, data)
        elseif data.projType == "CharityOrb" then
            mod:CharityOrbProjectileDeath(proj, data)
        elseif data.projType == "Temperance" then
            mod:TemperanceProjectiledeath(proj, data)
        end
    end
end)

--GENERAL CALLBACKS--
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    mod:CheckForVirtueRoomEntry()
    mod:ChastityKeyCleanup()
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    mod:CheckForVirtueSpawning()
end)