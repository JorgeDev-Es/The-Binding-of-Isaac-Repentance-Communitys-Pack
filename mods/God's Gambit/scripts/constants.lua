local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

if StageAPI then
    --StageAPI.AddEntities2Function(require("scripts.entities2"))
end

function mod:GetEnt(name, sub)
	return {ID = Isaac.GetEntityTypeByName(name), Var = Isaac.GetEntityVariantByName(name), Sub = Isaac.GetEntitySubTypeByName(name)}
end

mod.ENT = {
    ---ENEMIES---
    --Virtues
    Kindness = mod:GetEnt("Kindness"),
    SuperKindness = mod:GetEnt("Super Kindness"),
    Chastity = mod:GetEnt("Chastity"),
    SuperChastity = mod:GetEnt("Super Chastity"),
    Charity = mod:GetEnt("Charity"),
    SuperCharity = mod:GetEnt("Super Charity"),
    Humility = mod:GetEnt("Humility"),
    SuperHumility = mod:GetEnt("Super Humility"),
    Diligence = mod:GetEnt("Diligence"),
    SuperDiligence = mod:GetEnt("Super Diligence"),
    Temperance = mod:GetEnt("Temperance"),
    SuperTemperance = mod:GetEnt("Super Temperance"),
    Patience = mod:GetEnt("Patience"),
    SuperPatience = mod:GetEnt("Super Patience"),
    DiligentRambler = mod:GetEnt("Diligent Rambler"),
    DiligentRattler = mod:GetEnt("Diligent Rattler"),
    DiligentStickler = mod:GetEnt("Diligent Stickler"),
    DiligentSlimer = mod:GetEnt("Diligent Slimer"),

    PatienceMine = mod:GetEnt("Patience Mine"),
    SuperPatienceMine = mod:GetEnt("Super Patience Mine"),

    ---PICKUPS---
    ChastityKey = mod:GetEnt("Chastity Key"),

    ---EFFECTS---
    ChastityRag = mod:GetEnt("Chastity Rag"),
    ChastityRagPile = mod:GetEnt("Chastity Rag Pile"),
    HumilityScribble = mod:GetEnt("Super Humility Scribble"),
    HumilityPonspawn = mod:GetEnt("Humility Ponspawn"),
}

mod.Sounds = {

}

function mod:ColorFrom255(r,g,b,a,ro,go,bo)
    return Color(r/255, g/255, b/255, (a or 255)/255, (ro or 0)/255, (go or 0)/255, (bo or 0)/255)
end

mod.Colors = {}
mod.Colors.ColorKindnessYellow = Color(1,1,1,1,0.4,0.4,0.1)
    mod.Colors.ColorKindnessYellow:SetColorize(3,2,1,1)
mod.Colors.GreedGuts = Color(0.4,0.2,0.2)
mod.Colors.Tar = Color(1,1,1)
    mod.Colors.Tar:SetColorize(0.5,0.5,0.5,1)
mod.Colors.PitchBlack = Color(0,0,0)
mod.Colors.TemperanceSplat = Color(0.04,0.4,0.02,1,0.35,0.4,0.25)
mod.Colors.TemperanceProj = Color(1,1,1)
    mod.Colors.TemperanceProj:SetColorize(0.85,1,0.7,1)
mod.Colors.TemperanceCreep = Color(1,1,1)
    mod.Colors.TemperanceCreep:SetColorize(3.2,3.6,2.3,1)
mod.Colors.SuperPatienceSplat = Color(0.05,0,0,1,0.2,0.2,0.2)
mod.Colors.PurpleGuts = Color(1,1,1)
    mod.Colors.PurpleGuts:SetColorize(0.84,0.4,0.68,1)

if StageAPI then
    StageAPI.AddEntities2Function(require("scripts.entities2"))
end