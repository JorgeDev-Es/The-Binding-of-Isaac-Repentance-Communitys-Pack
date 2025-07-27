--MOD DEFINITIONS--
LastJudgement = RegisterMod("Last Judgement", 1)

local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

mod.ModVersion = "1.0.2"

if not REPENTOGON then
	error("Last Judgement v"..mod.ModVersion.." requries the latest version of REPENTOGON to be installed! Read how to at https://repentogon.com/install.html")
else

StageAPI.UnregisterCallbacks("Last Judgement")

--LOAD SCRIPTS--
mod.Scripts = {
    "constants",
    "library",
    "savedata",
    "dssmenucore",
    "commands",

    "mortis",
    "stageskins",

    "enemies.canary",
    "enemies.phage",
    "enemies.taintedmrmaw",
    "enemies.stressball",
    "enemies.embolism",
    "enemies.topsy",
    "enemies.strainbaby",
    "enemies.donor",
    "enemies.terrorcell",
    "enemies.popper",
    "enemies.lobodious",
    "enemies.heap",
    "enemies.exorcist",
    "enemies.gash",
    "enemies.cyabin",
    "enemies.doc",
    "enemies.ministro2",
    "enemies.vax",
    "enemies.coil",
    "enemies.jibble",
    "enemies.skinburster",
    "enemies.aids",
	"enemies.brimstonehost",
    "enemies.carnis",
    "enemies.patho",

    "bosses.cadavra",
    "bosses.pinky",
    "bosses.haemotoxia",

    "reworks.widow",
    "reworks.gish",
    "reworks.gate",
    "reworks.cage",

    "tweaks.misc",
}
for _, s in ipairs(mod.Scripts) do
    include("scripts."..s)
end

--NPC CALLBACKS--

--Leeches
--Must be subtype or else they will explode on death
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == mod.ENT.Vax.Var and npc.SubType == mod.ENT.Vax.Sub then
        mod:VaxAI(npc)
    end
end, EntityType.ENTITY_LEECH)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    if mod:IsScalpel(npc) then
        npc.Visible = false
    end
end, 743)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.Canary.Var or npc.Variant == mod.ENT.Foreigner.Var then
        mod:CanaryAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.TaintedMrMaw.Var then
        mod:TaintedMrMawAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.TaintedMaw.Var then
        mod:TaintedMawAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Phage.Var or npc.Variant == mod.ENT.Pheege.Var or npc.Variant == mod.ENT.Phooge.Var then
        mod:PhageAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.StressBall.Var then
        mod:StressBallAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Topsy.Var then
        mod:TopsyAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.TopsyGut.Var then
        mod:TopsyGutAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.StrainBaby.Var then
        mod:StrainBabyAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Donor.Var then
        mod:DonorAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.SlinkingGuts.Var then
        mod:SlinkingGutsAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.HulkingGuts.Var then
        mod:HulkingGutsAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.PatheticGuts.Var then
        mod:PatheticGutsAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.TerrorCell.Var then
        mod:TerrorCellAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Popper.Var then
        mod:PopperAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Lobodious.Var then
        mod:LobodiousAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Heap.Var then
        mod:HeapAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Exorcist.Var then
        mod:ExorcistAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Remnant.Var then
        mod:RemnantAI(npc, sprite, data)
    elseif mod:IsScalpel(npc) then
        mod:ScalpelAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Gash.Var then
        mod:GashAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Cyabin.Var then
        mod:CyabinAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.CyabinGoo.Var then
        mod:CyabinGooAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.DOC.Var then
        mod:DocAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.MinistroIIOrb.Var then
        mod:MinistroIIOrbAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Coil.Var then
        mod:CoilAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Jibble.Var then
        mod:JibbleAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Skinburster.Var then
        mod:SkinbursterAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.BrimstoneHost.Var then
		mod:BrimstoneHostAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Patho.Var then
		mod:PathoAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.PathoTentacle.Var then
        mod:PathoTentacleAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Carnis.Var then
		mod:CarnisAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Cadavra.Var then
        mod:CadavraAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.CadavraChubs.Var then
        mod:CadavraChubsAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.CadavraNibs.Var then
        mod:CadavraNibsAI(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Pinky.Var then
        mod:PinkyAI(npc, sprite, data)
	elseif npc.Variant == mod.ENT.Haemotoxia.Var then
        mod:HaemotoxiaAI(npc, sprite, data)
	end
end, 743)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.TopsyGut.Var then
        mod:TopsyGutRender(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Heap.Var then
        mod:HeapRender(npc, sprite, data)
    elseif npc.Variant == mod.ENT.CyabinGoo.Var then
        mod:CyabinGooRender(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Jibble.Var then
        mod:JibbleRender(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Pinky.Var then
        mod:PinkyRender(npc, sprite, data)
    elseif npc.Variant == mod.ENT.Haemotoxia.Var then
        mod:HaemotoxiaRender(npc, sprite, data)
    end
end, 743)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, amount, damageFlags, source, cooldown)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.TopsyGut.Var then
        return mod:TopsyGutHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.Remnant.Var then
        return mod:RemnantHurt(npc, sprite, data, amount, damageFlags, source)
    elseif mod:IsScalpel(npc) then
        return false
    elseif npc.Variant == mod.ENT.Cyabin.Var then
        return mod:CyabinHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.DOC.Var then
        return mod:DocHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.Coil.Var then
        return false
    elseif npc.Variant == mod.ENT.Cadavra.Var then
        return mod:CadavraHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.CadavraChubs.Var then
        return mod:CadavraChubsHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.CadavraNibs.Var then
        return mod:CadavraNibsHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.Pinky.Var then
        return mod:PinkyHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.BrimstoneHost.Var then
		return mod:BrimstoneHostHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.Patho.Var or npc.Variant == mod.ENT.PathoTentacle.Var then
		return false
	elseif npc.Variant == mod.ENT.Haemotoxia.Var then
        return mod:HaemotoxiaHurt(npc, amount, damageFlags, source)
    end
end, 743)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, npc, amount, damageFlags, source, cooldown)
    npc = npc:ToNPC()
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.HulkingGuts.Var then
        mod:HulkingGutsHurt(npc, sprite, data, amount, damageFlags, source)
    elseif npc.Variant == mod.ENT.Heap.Var then
        mod:HeapHurt(npc, sprite, data, amount, damageFlags, source)
    end
end, 743)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, npc, collider)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.TaintedMaw.Var then
        return mod:TaintedMawColl(npc, sprite, data, collider)
    end
end, 743)

mod:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, function(_, npc, collider)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.Phage.Var or npc.Variant == mod.ENT.Pheege.Var then
        mod:PhageColl(npc, sprite, data, collider)
    elseif npc.Variant == mod.ENT.MinistroIIOrb.Var then
        mod:MinistroIIOrbColl(npc, sprite, data, collider)
    elseif npc.Variant == mod.ENT.Pinky.Var then
        mod:PinkyColl(npc, sprite, data, collider)
    end
end, 743)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_DEVOLVE, function(_, npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    if npc.Variant == mod.ENT.Phage.Var then
        return mod:PhageDevolve(npc)
    elseif npc.Variant == mod.ENT.CyabinGoo.Var then
        return mod:CyabinGooDevolve(npc)
    end
end, 743)

function mod:ferriumNPCUpdate(npc)
    if npc.Variant == mod.ENT.Embolism.Var then
        mod:EmbolismAI(npc)
    elseif npc.Variant == mod.ENT.VaxPustule.Var then
        mod:VaxPustuleAI(npc)
    elseif npc.Variant == mod.ENT.Aids.Var then
        mod:AIDSAI(npc)
    elseif npc.Variant == mod.ENT.AidsHelper.Var then
        mod:AidsHelper(npc)
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.ferriumNPCUpdate, 744)

function mod:ferriumNPCHurt(ent, damage, flag, source, countdown)
    local npc = ent:ToNPC()
    if npc.Variant == mod.ENT.Embolism.Var then
        mod:EmbolismHurt(npc)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.ferriumNPCHurt, 744)

--PROJECTILE CALLBACKS--
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    local data = proj:GetData()
    mod:CustomProjectileBehavior(proj, data)
    mod:AidsProjectileUpdate(proj, data)
    mod:HaemotoxiaProjectileUpdate(proj, data)
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ent)
    local proj = ent:ToProjectile()
	local data = ent:GetData()

	mod:CustomProjectileRemove(proj, data)
end, 9)

--GENERAL CALLBACKS--
function mod:ResetRoomTables()
    mod.HotRocks = {}
    mod.CurrentVirusEnemies = {}
end
mod:ResetRoomTables()

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
	mod:ResetRoomTables()
    mod:CheckMortisUnlock()
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	mod:HotRocksUpdate()
    mod:MortisVisualEffectsUpdate()
    mod:TerrorCellPhageSpawning()
    mod:CheckAltPathDoor()

    if mod.DoMortisDarkness and mod.STAGE.Mortis:IsStage() then
        game:Darken(1, 30)
        for _, player in pairs(mod:GetAllPlayers()) do
            if player.Position:Distance(game:GetRoom():GetCenterPos()) > 20 then
                mod.DoMortisDarkness = false --End darkness effect when a player moves
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if not mod.InitLoading then
        mod:LoadMortisRooms()
        if FiendFolio then
            mod:LoadFFSkins()
        end
        mod.InitLoading = true
    end

    if mod.CheckForMotherVsScreen and RoomTransition.IsRenderingBossIntro() then
        mod:LoadMotherVsScreen()
        mod.CheckForMotherVsScreen = false
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    mod:SetColorCorrection(false)
    mod.TriedSelectStage = false
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	mod:ResetRoomTables()
    mod:SpawnScalpelLines()
    mod:SetColorCorrection(true)
    mod:CheckForMortisChoiceItemRoom()
    mod:CheckAltPathDoor2()
    mod:CheckForMotherRoom()
    mod.TriedSelectStage = false
    mod.CheckedForAltDoor = false
end)

--Enemy death animation
--Adapted from the Fiend Folio one
function mod:EnemyDeathAnim(ent)
    local npc = ent:ToNPC()
    if not npc or (npc and not mod:WouldEnemyHaveDeathEffect(npc)) then
        return
    end

    local d = npc:GetData()
    if not (d.LJIsDeathAnimation or d.SkulltistVictim or d.FFIsDeathAnimation) then
		for key,entry in pairs(mod.DeathAnims) do
			if npc.Type == entry.ID and (not entry.Var or npc.Variant == entry.Var) and (not entry.Sub or npc.SubType == entry.Sub) then
				entry.CustomFunc(npc)
			end
		end

		if d.LJPreventDeathDrops then
			npc:Remove()
		end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.EnemyDeathAnim)

--Table needs to be made after all the functions are declared
mod.DeathAnims = {
    {ID = mod.ENT.Embolism.ID, Var = mod.ENT.Embolism.Var, CustomFunc = mod.EmbolismDeathAnim}
}

local loadString = "Last Judgement v"..mod.ModVersion.." Loaded!"
print(loadString)
Isaac.DebugString(loadString)	

end