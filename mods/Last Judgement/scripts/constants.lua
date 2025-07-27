local mod = LastJudgement
local game = Game()

function mod:GetEnt(name, sub)
	return {ID = Isaac.GetEntityTypeByName(name), Var = Isaac.GetEntityVariantByName(name), Sub = Isaac.GetEntitySubTypeByName(name)}
end

mod.ENT = {
    ---ENEMIES---
    --Mines
    Canary = mod:GetEnt("Canary (LJ)"),
    Foreigner = mod:GetEnt("Foreigner (LJ)"),

    --Depths
    CageVis = mod:GetEnt("Cage Vis"),

    --Mausoleum
    Exorcist = mod:GetEnt("Exorcist (LJ)"),
    Remnant = mod:GetEnt("Remnant"),
	
	--Gehenna
    BrimstoneHost = mod:GetEnt("Brimstone Host"),

    --Utero
    Embolism = mod:GetEnt("Embolism"),

    --Corpse
    Coil = mod:GetEnt("Coil (LJ)"),

    --Mortis
    Phage = mod:GetEnt("Phage"),
    Pheege = mod:GetEnt("Pheege"),
    Phooge = mod:GetEnt("Phooge"),
    StressBall = mod:GetEnt("Stress Ball"),
    Topsy = mod:GetEnt("Topsy"),
    StrainBaby = mod:GetEnt("Strain Baby"),
    Donor = mod:GetEnt("Donor"),
    SlinkingGuts = mod:GetEnt("Slinking Guts"),
    HulkingGuts = mod:GetEnt("Hulking Guts"),
    PatheticGuts = mod:GetEnt("Pathetic Guts"),
    TerrorCell = mod:GetEnt("Terror Cell"),
    Popper = mod:GetEnt("Popper"),
    Lobodious = mod:GetEnt("Lobodious"),
    Heap = mod:GetEnt("Heap"),
    Gash = mod:GetEnt("Gash"),
    Cyabin = mod:GetEnt("Cyabin"),
    CyabinGoo = mod:GetEnt("Cyabin Goo"),
    DOC = mod:GetEnt("D.O.C."),
    MinistroII = mod:GetEnt("Ministro II"),
    MinistroIIOrb = mod:GetEnt("Ministro II Orb"),
    Vax = mod:GetEnt("Vax"),
    VaxPustule = mod:GetEnt("Vax Pustule"),
    Jibble = mod:GetEnt("Jibble"),
    Skinburster = mod:GetEnt("Skinburster"),
    Aids = mod:GetEnt("AIDS"),
    AidsHelper = mod:GetEnt("AIDS Helper"),
    Carnis = mod:GetEnt("Carnis"),
    Patho = mod:GetEnt("Patho"),
    PathoTentacle = mod:GetEnt("Patho Tentacle"),

    Cadavra = mod:GetEnt("Cadavra (LJ)"),
    CadavraChubs = mod:GetEnt("Chubs (LJ)"),
    CadavraNibs = mod:GetEnt("Nibs (LJ)"),
    CadavraGut = mod:GetEnt("Cadavra Gut"),
    Pinky = mod:GetEnt("Pinky"),
    Haemotoxia = mod:GetEnt("Haemotoxia"),
    
    --Ascent
    TaintedMrMaw = mod:GetEnt("Tainted Mr. Maw"),
    TaintedMaw = mod:GetEnt("Tainted Maw"),

    ---Obstacles---
    ScalpelTimed = mod:GetEnt("Scalpel (Timed)"),
    ScalpelKills = mod:GetEnt("Scalpel (Kills)"),
    ScalpelEventTriggered = mod:GetEnt("Scalpel (Event-Triggered)"),

    ---Projectiles---
    AntibodyProjectile = mod:GetEnt("Antibody Projectile"),
    PillProjectile = mod:GetEnt("Pill Projectile"),
    BrainProjectile = mod:GetEnt("Brain Projectile"),
    MinistroIIProjectile = mod:GetEnt("Ministro II Projectile"),
    SulfuricNeedle = mod:GetEnt("Sulfuric Needle Projectile"),
    AidsNeedleProjectile = mod:GetEnt("AIDS Needle Projectile"),

    ---Effects---
    TaintedMawNeck = mod:GetEnt("Tainted Maw Neck"),
    TopsyGut = mod:GetEnt("Topsy Gut"),
    TopsyChunk = mod:GetEnt("Topsy Chunk"),
    DonorCord = mod:GetEnt("Donor Cord"),
    CordAnchorPoint = mod:GetEnt("LJ Cord Anchor Point"),
    MortisDetails = mod:GetEnt("Mortis Details"),
    MortisSplat = mod:GetEnt("Mortis Splat"),
    ScalpelLine = mod:GetEnt("Scalpel Line"),
    GashWound = mod:GetEnt("Gash Wound"),
    CustomTracer = mod:GetEnt("LJ Custom Tracer"),
    SulfuricNeedlePoof = mod:GetEnt("Sulfuric Needle Poof"),
    SkinbursterDirt = mod:GetEnt("Skinburster Dirt"),
    AidsNeedlePoof = mod:GetEnt("AIDS Needle Poof"),
    AidsCreepNeedle = mod:GetEnt("AIDS Creep Syringe"),
    PathoGround = mod:GetEnt("Patho Ground"),
    FerroCreep = mod:GetEnt("Ferro Creep"),
    FerroCreepSpikes = mod:GetEnt("Ferro Creep Spikes"),
    HaemoClot = mod:GetEnt("Haemotoxia Clot"),
}

StageAPI.AddEntityPersistenceData({
    Type = mod.ENT.Coil.ID, 
    Variant = mod.ENT.Coil.Var, 
    RemoveOnRemove = true,
    RemoveOnDeath = true,
})
StageAPI.AddEntityPersistenceData({
    Type = mod.ENT.Patho.ID, 
    Variant = mod.ENT.Patho.Var, 
    RemoveOnRemove = true,
    RemoveOnDeath = true,
    UpdateSubType = true,
})

StageAPI.AddMetadataEntities({
    [743] = {
        [125] = {
            Name = "ScalpelLine",
            Tags = {"Triggerable"},
            BitValues = {
                Frame = {Offset = 0, Length = 4},
            },    
        },
    },
})

mod.Sounds = {
    HotBrimstone = Isaac.GetSoundIdByName("HotBrimstone"),
    EmbolismBreath = Isaac.GetSoundIdByName("EmbolismBreath"),
    RainLoop = Isaac.GetSoundIdByName("LJRainLoop"),
    ChubsKick = Isaac.GetSoundIdByName("ChubsKick"),
    ChubsSkrrt = Isaac.GetSoundIdByName("ChubsSkrrt"),
    ChubsBump = Isaac.GetSoundIdByName("ChubsBump"),
    MuscleGrow = Isaac.GetSoundIdByName("PinkyMuscleGrow"),
    MuscleDeflate = Isaac.GetSoundIdByName("PinkyMuscleDeflate"),
    DonorStart = Isaac.GetSoundIdByName("DonorStart"),
    DonorLoop = Isaac.GetSoundIdByName("DonorLoop"),
    DonorStop = Isaac.GetSoundIdByName("DonorStop"),
}

mod.Music = {
    Mortis = Isaac.GetMusicIdByName("LJ Mortis")
}

mod.Achievement = {
    Mortis = Isaac.GetAchievementIdByName("LJ Mortis")
}

function mod:ColorFrom255(r,g,b,a,ro,go,bo)
    return Color(r/255, g/255, b/255, (a or 255)/255, (ro or 0)/255, (go or 0)/255, (bo or 0)/255)
end

mod.Colors = {}
mod.Colors.FireyFade = Color(1,1,1,1,1,0.514,0.004)
    mod.Colors.FireyFade:SetTint(0,0,0,1.1)
mod.Colors.MortisBlood = Color(0.5,0.75,1,1,0,0,0.05)
mod.Colors.MortisBloodProj = Color(1,0.6,0.7,1,0,0)
    mod.Colors.MortisBloodProj:SetColorize(2.2, 0.924, 1.31, 1)
mod.Colors.MortisBloodBright = Color(0.8,1,1,1,0.2,0,0.1)
mod.Colors.MortisWater = Color(1,0.75,-0.5,1,0.1,0.1)
mod.Colors.MorgueisWater = Color(1,0.3,0.65,1,0.1)
mod.Colors.MoistisWater = Color(0.5,1,1)
mod.Colors.VirusBlue = Color(0.5,0.75,1,1)
    mod.Colors.VirusBlue:SetColorize(1.15,1.5,3,1.25)
mod.Colors.OrganBlue = Color(0.5,1,1,1)
    mod.Colors.OrganBlue:SetColorize(2,3,3,1.25)
mod.Colors.OrganYellow = Color(1,1,0.25,1)
    mod.Colors.OrganYellow:SetColorize(5,4,1,1.25)
mod.Colors.OrganPurple = Color(0.35,0.35,1,1)
    mod.Colors.OrganPurple:SetColorize(2.25,1.75,3,1.25)
mod.Colors.WhiteBlood = Color(1,1,0.5,1)
    mod.Colors.WhiteBlood:SetColorize(5,3.5,3,1.25)
mod.Colors.PsyPurple = Color(0.75,0.25,1,1)
    mod.Colors.PsyPurple:SetColorize(4,1,5,1.25)
mod.Colors.DankBlack = Color(0.5,0.5,0.5,1)
    mod.Colors.DankBlack:SetColorize(1,1,1,1)
mod.Colors.CageProj = Color(1,1,1)
    mod.Colors.CageProj:SetColorize(0.8,1,0.85,1)
mod.Colors.CageCreep = Color(1,1,1)
    mod.Colors.CageCreep:SetColorize(2.75,3,2.25,1)
mod.Colors.CageSplat = Color(0.04,0.3,0.04,1,0.4,0.4,0.3)
mod.Colors.CyanBlue = Color(0.5,1,1)
    mod.Colors.CyanBlue:SetColorize(1.15,2,3,2)
mod.Colors.CorpseBlood = Color(1,1,1)
    mod.Colors.CorpseBlood:SetColorize(1,1,1,0.65)
mod.Colors.ElectricGreen = mod:ColorFrom255(240,249,215,nil,160,160,120)
    mod.Colors.ElectricGreen:SetColorize(1,1,1,1)
mod.Colors.ElectricBlue = mod:ColorFrom255(215,248,240,nil,120,160,160)
    mod.Colors.ElectricBlue:SetColorize(1,1,1,1)
mod.Colors.RoidRage = Color(1,1,1,1)
    mod.Colors.RoidRage:SetColorize(0.33,1,0.33,1)
mod.Colors.RoidRageProj = Color(1,1,1,1)
    mod.Colors.RoidRageProj:SetColorize(1.5,3,1.5,1)
mod.Colors.SpeedBall = Color(1.5,1.5,1.5,1)
    mod.Colors.SpeedBall:SetColorize(1,1,1,1)
mod.Colors.SpeedBallProj = Color(1,1,1,1)
    mod.Colors.SpeedBallProj:SetColorize(3,3,3,1)
mod.Colors.Euthanasia = Color(0.85,0.85,0.85,1,-0.2,-0.2,-0.2)
    mod.Colors.Euthanasia:SetColorize(1,1,1,1)
mod.Colors.ExperimentalTreatment = Color(1,1,0.25,1)
    mod.Colors.ExperimentalTreatment:SetColorize(5,4,2,1.25)
mod.Colors.GrowthHormones = Color(1,1,1,1)
    mod.Colors.GrowthHormones:SetColorize(1,0.33,0.85,1)
mod.Colors.GrowthHormonesProj = Color(1,1,1,1)
    mod.Colors.GrowthHormonesProj:SetColorize(3,1,2.5,1)
mod.Colors.IpecacProj = Color(1,1,1,1)
    mod.Colors.IpecacProj:SetColorize(0.4,2,0.5,1)
mod.Colors.BlueGuts = Color(1,1,1)
    mod.Colors.BlueGuts:SetColorize(0.5,0.6,0.84,1)
mod.Colors.MotherBlueProj1 = Color(1,1,1)
    mod.Colors.MotherBlueProj1:SetColorize(1,1.5,2,1)
mod.Colors.MotherBlueProj2 = Color(1,1,1)
    mod.Colors.MotherBlueProj2:SetColorize(2,2.7,3,1)
mod.Colors.BrimstoneProj = Color(1,1,1,1,0.425)
    mod.Colors.BrimstoneProj :SetColorize(0.425,0,0,1)
mod.Colors.AidsPuddle = Color(1,0.7,0.8,1,0.35,0,0.08,1,0.4,0.55,1)
mod.Colors.CarnisSplat = Color(0,0,0,1,0.45,0.3,0.35)
mod.Colors.HaemotoxiaCreep = Color(0.75,0.75,0.8,1,0,0.02,0)

mod.STAGE = {}

mod.Rooms = {
    Mortis = {
		include("resources.luarooms.mortis.mortis_guwah"),
        include("resources.luarooms.mortis.mortis_pk"),
        include("resources.luarooms.mortis.mortis_al"),
        include("resources.luarooms.mortis.mortis_hippo"),
        include("resources.luarooms.mortis.mortis_ferrium"),
        include("resources.luarooms.mortis.mortis_oily"),
        include("resources.luarooms.mortis.mortis_snake"),
        include("resources.luarooms.mortis.mortis_absolutely_important_room"),
    },
    MortisFF = {
		include("resources.luarooms.mortis.ff.mortis_guwah_ff"),
        include("resources.luarooms.mortis.ff.mortis_pk_ff"),
        include("resources.luarooms.mortis.ff.mortis_al_ff"),
        include("resources.luarooms.mortis.ff.mortis_oily_ff"),
    },
    MortisChallenge = {include("resources.luarooms.mortis.mortis_challenge")},
    MortisBossChallenge = {include("resources.luarooms.mortis.mortis_boss_challenge")},
}

mod.MortisBosses = {
    "LastJudgement Cadavra",
    "LastJudgement Pinky",
    "LastJudgement Haemotoxia",
}

mod.StageAPIBosses = {
    Cadavra = StageAPI.AddBossData("LastJudgement Cadavra", {
        Name = "Cadavra",
        Portrait = "gfx/bosses/LastJudgement/portrait_cadavra.png",
        Bossname = "gfx/bosses/LastJudgement/bossname_cadavra.png",
        Offset = Vector(0,-15),
        Weight = 1,
        Rooms = StageAPI.RoomsList("LastJudgement Cadavra Rooms", require("resources.luarooms.mortis.bosses.mortis_boss_cadavra")),
        Entity = {Type = mod.ENT.Cadavra.ID, Variant = mod.ENT.Cadavra.Var},
    }),
    Pinky = StageAPI.AddBossData("LastJudgement Pinky", {
        Name = "Pinky",
        Portrait = "gfx/bosses/LastJudgement/portrait_pinky.png",
        Bossname = "gfx/bosses/LastJudgement/bossname_pinky.png",
        Offset = Vector(0,-15),
        Weight = 1,
        Rooms = StageAPI.RoomsList("LastJudgement Pinky Rooms", require("resources.luarooms.mortis.bosses.mortis_boss_pinky")),
        Entity = {Type = mod.ENT.Pinky.ID, Variant = mod.ENT.Pinky.Var},
    }),
    Haemotoxia = StageAPI.AddBossData("LastJudgement Haemotoxia", {
        Name = "Haemotoxia",
        Portrait = "gfx/bosses/LastJudgement/portrait_haemotoxia.png",
        Bossname = "gfx/bosses/LastJudgement/bossname_maemotoxia.png",
        Offset = Vector(0,-15),
        Weight = 1,
        Rooms = StageAPI.RoomsList("LastJudgement Haemotoxia Rooms", require("resources.luarooms.mortis.bosses.mortis_boss_haemotoxia")),
        Entity = {Type = mod.ENT.Haemotoxia.ID, Variant = mod.ENT.Haemotoxia.Var},
    }),
}