local game = Game()
local sfx = SFXManager()
local mod = LastJudgement
local basepath = "gfx/enemies/"

mod.MortisSkins = {
    [EntityType.ENTITY_GAPER.." 3"] = { --Rotten Gaper
        {{0}, basepath.."bodies_mortis.png"},
        {{1}, basepath.."reskins/rottengaper_mortis.png"},
    },
    [EntityType.ENTITY_GUSHER.." 0"] = { --Gusher
        {{0}, basepath.."bodies02_mortis.png"},
        {{1}, basepath.."bloodgush_mortis.png", true},
    },
    [EntityType.ENTITY_GUSHER.." 1"] = { --Pacer
        {{0}, basepath.."bodies02_mortis.png"},
    },
    [EntityType.ENTITY_MEMBRAIN.." 2"] = { --Dead Meat
        {{0,1}, basepath.."reskins/deadmeat_mortis.png"},
    },
    [EntityType.ENTITY_BLASTOCYST_BIG.." 0"] = { --Blastocyst (Big)
        {{0,1,2}, basepath.."reskins/boss_063_blastocyst_mortis.png"},
        {{4}, basepath.."reskins/boss_063_blastocyst_back_mortis.png"},
    },
    [EntityType.ENTITY_BLASTOCYST_MEDIUM.." 0"] = { --Blastocyst (Medium)
        {{0,1,2}, basepath.."reskins/boss_063_blastocyst_mortis.png"},
        {{4}, basepath.."reskins/boss_063_blastocyst_back_mortis.png"},
    },
    [EntityType.ENTITY_BLASTOCYST_SMALL.." 0"] = { --Blastocyst (Small)
        {{0,1,2}, basepath.."reskins/boss_063_blastocyst_mortis.png"},
        {{4}, basepath.."reskins/boss_063_blastocyst_back_mortis.png"},
    },
    [EntityType.ENTITY_EMBRYO.." 0"] = { --Embryo
        {{0}, basepath.."reskins/monster_154_embryo_mortis.png"},
    },
    [EntityType.ENTITY_GEMINI.." 0"] = { --Gemini 
        {{0}, basepath.."reskins/gemini_body_mortis.png"},
        {{1}, basepath.."reskins/gemini_mortis.png"},
    },
    [EntityType.ENTITY_GEMINI.." 10"] = { --Gemini Baby
        {{0}, basepath.."reskins/gemini_mortis.png"},
    },
    [EntityType.ENTITY_GEMINI.." 20"] = { --Gemini Cord
        {{0}, basepath.."reskins/gemini_mortis.png"},
    },
    [EntityType.ENTITY_LEPER.." 0"] = { --Leper
        {{0}, basepath.."reskins/leper_body_mortis.png"},
        {{1}, basepath.."reskins/leper_mortis.png"},
    },
    [EntityType.ENTITY_LEPER.." 1"] = { --Leper Flesh
        {{0}, basepath.."reskins/leper_flesh_mortis.anm2", true, true},
    },
    [mod.ENT.Coil.ID.." "..mod.ENT.Coil.Var] = { --Coil
        {{0}, basepath.."coil/monster_coil_mortis.png"},
    },
    [EntityType.ENTITY_GAPER_L2.." 0"] = { --Level 2 Gaper
        {{0,1}, basepath.."reskins/lv2_gaper_mortis.png"},
    },
    [EntityType.ENTITY_GAPER_L2.." 1"] = { --Level 2 Horf
        {{0}, basepath.."reskins/lv2_gaper_mortis.png"},
        {{1}, basepath.."blooddrip_mortis.png", true},
    },
    [EntityType.ENTITY_GAPER_L2.." 2"] = { --Level 2 Gusher
        {{0}, basepath.."reskins/lv2_gaper_mortis.png"},
        {{1}, basepath.."bloodgush_mortis.png", true},
    },
    [EntityType.ENTITY_SPIKEBALL.." 0"] = { --Spikeball
        {{0}, basepath.."reskins/spikeball_mortis.png"},
    },
    [EntityType.ENTITY_CYST.." 0"] = { --Cyst
        {{0}, basepath.."reskins/cyst_mortis.png"},
    },
    [EntityType.ENTITY_EVIS.." 0"] = { --Evis
        {{0,1}, basepath.."reskins/evis_mortis.png"},
    },
    [EntityType.ENTITY_EVIS.." 10 0"] = { --Evis Guts
        {{0,1}, basepath.."reskins/evis_guts_mortis.png"},
    },
    [EntityType.ENTITY_MOTHER.." 0"] = { --Mother
        {{0,1}, basepath.."reskins/mother/witness_head_mortis.png"},
        {{2,3}, basepath.."reskins/mother/witness_arm_mortis.png"},
    },
    [EntityType.ENTITY_MOTHER.." 10"] = { --Mother 2
        {{0,1}, basepath.."reskins/mother/witness_head2_mortis.png"},
    },
    [EntityType.ENTITY_MOTHER.." 20"] = { --Dead Isaac
        {{0}, basepath.."reskins/mother/dead_isaac_mortis.png"},
        {{1}, basepath.."reskins/mother/dead_isaac_body_mortis.png"},
    },
    [EntityType.ENTITY_MOTHER.." 100"] = { --Mother Fistula Ball
        {{0}, basepath.."reskins/mother/912.100_witness ball_mortis.anm2", true, true},
    },
}

mod.MortisTearColors = {
    [EntityType.ENTITY_GUSHER.." 0"] = mod.Colors.MortisBloodProj, --Gusher
    [EntityType.ENTITY_BLASTOCYST_BIG.." 0"] = mod.Colors.VirusBlue, --Blastocyst (Big)
    [EntityType.ENTITY_BLASTOCYST_MEDIUM.." 0"] = mod.Colors.VirusBlue, --Blastocyst (Medium)
    [EntityType.ENTITY_BLASTOCYST_SMALL.." 0"] = mod.Colors.VirusBlue, --Blastocyst (Small)
    [EntityType.ENTITY_GEMINI.." 10"] = mod.Colors.MortisBloodProj, --Gemini Baby
    [EntityType.ENTITY_MEMBRAIN.." 2"] = mod.Colors.MortisBloodProj, --Dead Meat
    [EntityType.ENTITY_LEPER.." 1"] = mod.Colors.MortisBloodBright, --Leper Chunk
    [EntityType.ENTITY_CYST.." 0"] = mod.Colors.MortisBloodProj, --Cyst
}

mod.MortisSplatColors = {
    [EntityType.ENTITY_PROJECTILE.." "..ProjectileVariant.PROJECTILE_HEAD] = mod.Colors.BlueGuts, --Dead Isaac Projectile
    [EntityType.ENTITY_GAPER.." 3"] = mod.Colors.MortisBlood, --Rotten Gaper
    [EntityType.ENTITY_GUSHER.." 0"] = mod.Colors.MortisBlood, --Gusher
    [EntityType.ENTITY_GUSHER.." 1"] = mod.Colors.MortisBlood, --Pacer
    [EntityType.ENTITY_MEMBRAIN.." 2"] = mod.Colors.MortisBlood, --Dead Meat
    [EntityType.ENTITY_BLASTOCYST_BIG.." 0"] = mod.Colors.VirusBlue, --Blastocyst (Big)
    [EntityType.ENTITY_BLASTOCYST_MEDIUM.." 0"] = mod.Colors.VirusBlue, --Blastocyst (Medium)
    [EntityType.ENTITY_BLASTOCYST_SMALL.." 0"] = mod.Colors.VirusBlue, --Blastocyst (Small)
    [EntityType.ENTITY_EMBRYO.." 0"] = mod.Colors.MortisBlood, --Embryo
    [EntityType.ENTITY_GEMINI.." 0"] = mod.Colors.MortisBlood, --Gemini
    [EntityType.ENTITY_GEMINI.." 10"] = mod.Colors.MortisBlood, --Gemini Baby
    [EntityType.ENTITY_GEMINI.." 20"] = mod.Colors.MortisBlood, --Gemini Cord
    [EntityType.ENTITY_LEPER.." 0"] = mod.Colors.MortisBlood, --Leper 
    [EntityType.ENTITY_LEPER.." 1"] = mod.Colors.MortisBlood, --Leper Chunk
    [EntityType.ENTITY_GAPER_L2.." 0"] = mod.Colors.MortisBlood, --Level 2 Gaper 
    [EntityType.ENTITY_GAPER_L2.." 1"] = mod.Colors.MortisBlood, --Level 2 Horf
    [EntityType.ENTITY_GAPER_L2.." 2"] = mod.Colors.MortisBlood, --Level 2 Gusher
    [EntityType.ENTITY_SPIKEBALL.." 0"] = mod.Colors.OrganPurple, --Spikeball
    [EntityType.ENTITY_CYST.." 0"] = mod.Colors.MortisBlood, --Cyst
    [EntityType.ENTITY_EVIS.." 0"] = mod.Colors.MortisBlood, --Evis
    [EntityType.ENTITY_EVIS.." 10 0"] = mod.Colors.VirusBlue, --Evis Guts
    [EntityType.ENTITY_MOTHER.." 0"] = mod.Colors.BlueGuts, --Mother
    [EntityType.ENTITY_MOTHER.." 10"] = mod.Colors.BlueGuts, --Mother 2
    [EntityType.ENTITY_MOTHER.." 20"] = mod.Colors.MortisBlood, --Dead Isaac
    [EntityType.ENTITY_MOTHER.." 100"] = mod.Colors.MortisBlood, --Mother Fistula Ball
    [EntityType.ENTITY_EFFECT.." "..EffectVariant.BIG_KNIFE] = mod.Colors.BlueGuts, --Mother Knife Projectile
}

--Effects
mod.MortisSkinsEffects = {
    [EffectVariant.BIG_KNIFE] = { --Mother Knife Projectile
        {{0}, basepath.."reskins/mother/witness_knife_mortis.png"},
    },
}

mod.MortisEffectsToRecolor = {}

mod.MortisEffectsToDelete = {
    [EffectVariant.TINY_FLY.." "..0] = true,
    [EffectVariant.TINY_BUG.." "..0] = true,
    [EffectVariant.WALL_BUG.." "..0] = true,
    [EffectVariant.WORM.." "..0] = "CheckForSpawner",
    [EffectVariant.WORM.." "..1] = "CheckForSpawner",
    [EffectVariant.BEETLE.." "..0] = true,
}

------------------------Fiend Folio------------------------
mod.AddedFFSkinData = false

function mod:LoadFFSkins()
    mod.FFExpandLists = {
        mod.MortisSkins,
        mod.MortisTearColors,
        mod.MortisSplatColors,
    }

    local ff = FiendFolio.FF

    mod.MortisSkins["FiendFolio"] = {
        [ff.GutKnight.ID.." "..ff.GutKnight.Var] = {
            {{0}, basepath.."reskins/FF/monster_gutknightbody_mortis.png"},
            {{1}, basepath.."reskins/FF/monster_gutknight_mortis.png"},
        },
        [ff.CancerBoy.ID.." "..ff.CancerBoy.Var] = {
            {{0}, basepath.."reskins/FF/monster_bodybig_mortis.png"},
            {{1,2}, basepath.."reskins/FF/monster_cancerboy_mortis.png"},
        },
        [ff.Valvo.ID.." "..ff.Valvo.Var] = {
            {{0}, basepath.."reskins/FF/redbody_mortis.png"},
            {{1}, basepath.."reskins/FF/monster_valvo_mortis.png"},
        },
        [ff.Redema.ID.." "..ff.Redema.Var] = {
            {{0}, basepath.."reskins/FF/monster_bloodyedema_mortis.png"},
        },
        [ff.QuackMine.ID.." "..ff.QuackMine.Var] = {
            {{0}, basepath.."reskins/FF/monster_quack_mortis.png"},
        },
        [ff.Pox.ID.." "..ff.Pox.Var] = {
            {{0}, basepath.."reskins/FF/pox_mortis.png"},
        },
        [ff.Cancerlet.ID.." "..ff.Cancerlet.Var] = {
            {{0,1}, basepath.."reskins/FF/falafel_cancerboy_mortis.png"},
            {{6}, basepath.."reskins/FF/falafel_morph_cancerboy_mortis.png"},
        },
        [ff.MotorNeuron.ID.." "..ff.MotorNeuron.Var] = {
            {{0}, basepath.."bodies02_mortis.png"},
            {{1,2}, basepath.."reskins/FF/walking_nerve_mortis.png"},
        },
        [ff.Incisor.ID.." "..ff.Incisor.Var] = {
            {{1}, basepath.."reskins/FF/incisor_mortis.png"},
        },
        [ff.Foe.ID.." "..ff.Foe.Var] = {
            {{0}, basepath.."reskins/FF/monster_foe_mortis_back.png"},
            {{1,2}, basepath.."reskins/FF/monster_foe_mortis.png"},
        },
        [ff.Quack.ID.." "..ff.Quack.Var] = {
            {{0}, basepath.."reskins/FF/monster_quack_mortis_back.png"},
            {{1,2,3}, basepath.."reskins/FF/monster_quack_mortis.png"},
        },
        [ff.Weeper.ID.." "..ff.Weeper.Var] = {
            {{1,2}, basepath.."reskins/FF/monster_weeper_mortis.png"},
        },
        [ff.Vacuole.ID.." "..ff.Vacuole.Var] = {
            {{0,1,2}, basepath.."reskins/FF/monster_vacuole_mortis.png"},
        },
        [ff.Curdle.ID.." "..ff.Curdle.Var] = {
            {{0}, basepath.."reskins/FF/curdle_body_mortis.png"},
            {{1}, basepath.."reskins/FF/curdle_head_mortis.png"},
        },
        [ff.CurdleNaked.ID.." "..ff.CurdleNaked.Var] = {
            {{0}, basepath.."reskins/FF/curdle_body_mortis.png"},
            {{1}, basepath.."reskins/FF/curdle_head_mortis.png"},
        },
    }

    mod.MortisTearColors["FiendFolio"] = {
        [ff.Valvo.ID.." "..ff.Valvo.Var] = mod.Colors.MortisBloodProj,
        [ff.Redema.ID.." "..ff.Redema.Var] = mod.Colors.MortisBloodProj,
        [ff.QuackMine.ID.." "..ff.QuackMine.Var] = mod.Colors.VirusBlue,
        [ff.Pox.ID.." "..ff.Pox.Var] = mod.Colors.VirusBlue,
        [ff.Foe.ID.." "..ff.Foe.Var] = mod.Colors.VirusBlue,
        [ff.Weeper.ID.." "..ff.Weeper.Var] = mod.Colors.MortisBloodProj,
        [ff.Vacuole.ID.." "..ff.Vacuole.Var] = mod.Colors.MortisBloodProj,
        [ff.Curdle.ID.." "..ff.Curdle.Var] = mod.Colors.MortisBloodProj,
        [ff.CurdleNaked.ID.." "..ff.CurdleNaked.Var] = mod.Colors.MortisBloodProj,
    }

    mod.MortisSplatColors["FiendFolio"] = {
        [ff.CancerBoy.ID.." "..ff.CancerBoy.Var] = mod.Colors.BlueGuts,
        [ff.GutKnight.ID.." "..ff.GutKnight.Var] = mod.Colors.MortisBlood,
        [ff.Valvo.ID.." "..ff.Valvo.Var] = mod.Colors.MortisBlood,
        [ff.Redema.ID.." "..ff.Redema.Var] = mod.Colors.MortisBlood,
        [ff.QuackMine.ID.." "..ff.QuackMine.Var] = mod.Colors.VirusBlue,
        [ff.Pox.ID.." "..ff.Pox.Var] = mod.Colors.VirusBlue,
        [ff.Cancerlet.ID.." "..ff.Cancerlet.Var] = mod.Colors.BlueGuts,
        [ff.MotorNeuron.ID.." "..ff.MotorNeuron.Var] = mod.Colors.MortisBlood,
        [ff.Incisor.ID.." "..ff.Incisor.Var] = mod.Colors.MortisBlood,
        [ff.Foe.ID.." "..ff.Foe.Var] = mod.Colors.VirusBlue,
        [ff.Quack.ID.." "..ff.Quack.Var] = mod.Colors.VirusBlue,
        [ff.Weeper.ID.." "..ff.Weeper.Var] = mod.Colors.MortisBlood,
        [ff.Vacuole.ID.." "..ff.Vacuole.Var] = mod.Colors.MortisBlood,
        [ff.Curdle.ID.." "..ff.Curdle.Var] = mod.Colors.OrganBlue,
        [ff.CurdleNaked.ID.." "..ff.CurdleNaked.Var] = mod.Colors.OrganBlue,
    }

    for _, list in pairs(mod.FFExpandLists) do
        for key, entry in pairs(list["FiendFolio"]) do
            list[key] = entry
        end
    end

    mod:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, CallbackPriority.LATE, function(_, npc)
        if npc.Variant == ff.GutKnight.Var and mod.STAGE.Mortis:IsStage() then
            npc.SplatColor = mod.Colors.MortisBlood
        end
    end, ff.GutKnight.ID)

    mod.AddedFFSkinData = true
end
------------------------Fiend Folio END------------------------
mod.SpritesheetlessChamps = {
    [ChampionColor.FLICKER] = true,
    [ChampionColor.CAMO] = true,
    [ChampionColor.TINY] = true,
    [ChampionColor.GIANT] = true,
    [ChampionColor.SIZE_PULSE] = true,
    [ChampionColor.KING] = true,
}

function mod:ReplaceEnemySpritesheet(npc, filepath, layer, loadGraphics)
    filepath = filepath:sub(1,-5)
    layer = layer or 0
    if loadGraphics == nil then loadGraphics = true end
    npc = npc:ToNPC()
    local sprite = npc:GetSprite()
    if npc:IsChampion() and not mod.SpritesheetlessChamps[npc:GetChampionColorIdx()] then
        filepath = filepath.."_champion"
    end
    filepath = filepath..".png"
    sprite:ReplaceSpritesheet(layer, filepath)
    if loadGraphics then
        sprite:LoadGraphics()
    end
end

mod.RerollColors = {ChampionColor.GREEN, ChampionColor.BLACK, ChampionColor.PINK, ChampionColor.LIGHT_BLUE}
mod.StageSkinRNG = RNG()
function mod:LoadEnemySheet(npc, entry)
    mod.StageSkinRNG:SetSeed(npc.InitSeed, 35)

    if npc:IsChampion() and npc:GetChampionColorIdx() == ChampionColor.DARK_RED then --Dark Red champs break visually when regening with replaced sprite
        npc:MakeChampion(69, mod:GetRandomElem(mod.RerollColors, mod.StageSkinRNG), true) --"Solution": Reroll their color
        npc.MaxHitPoints = npc.MaxHitPoints/2
        npc.HitPoints = npc.MaxHitPoints
    end

    local sprite = npc:GetSprite()
    local data = npc:GetData()
    for _, sheet in pairs(entry) do
        for _, layer in pairs(sheet[1]) do
            local filepath = sheet[2]
            if sheet[4] then
                if npc.FrameCount <= 1 then
                    local anim = sprite:GetAnimation()
                    sprite:Load(sheet[2], true)
                    sprite:Play(anim, true)
                end
            else
                if type(sheet[2]) == "table" then
                    filepath = mod:GetRandomElem(sheet[2], mod.StageSkinRNG)
                end
                if sheet[3] then --No champion sheet
                    sprite:ReplaceSpritesheet(layer, filepath)
                else
                    mod:ReplaceEnemySpritesheet(npc, filepath, layer, false)
                end
            end
        end
    end
    sprite:LoadGraphics()
end

function mod:ShouldReplaceSkin(npc)
    npc = npc:ToNPC()
    if npc.Type == EntityType.ENTITY_GEMINI or (npc:IsBoss() and not (npc.Type == EntityType.ENTITY_MOTHER)) then
        if npc.SubType > 0 or npc.FrameCount <= 0 then
            return false
        elseif npc.Parent and npc.Parent:Exists() and npc.Parent.SubType > 0 and npc.Parent:ToNPC() and npc.Parent:ToNPC():IsBoss() then
            return false
        end
    end
    return true
end

function mod:CheckForStageSkin(npc)
    local data = npc:GetData()
    local key = npc.Type.." "..npc.Variant
    if not mod.MortisSkins[key] then
        key = npc.Type.." "..npc.Variant.." "..npc.SubType
    end
    if mod:ShouldReplaceSkin(npc) then
        if mod.MortisSkins[key] then
            mod:LoadEnemySheet(npc, mod.MortisSkins[key])
            data.MortisSkin = true
        end
    end
    return key
end

function mod:checkStageSkins(npc)
    if mod.STAGE.Mortis:IsStage() then
        local key = mod:CheckForStageSkin(npc)
        if mod.MortisSplatColors[key] then
            npc.SplatColor = mod.MortisSplatColors[key]
        end
        for i = 1, 3 do
            mod:ScheduleForUpdate(function() 
                local key = mod:CheckForStageSkin(npc)
                if mod.MortisSplatColors[key] then
                    npc.SplatColor = mod.MortisSplatColors[key]
                end
            end, i)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.checkStageSkins)
mod:AddCallback(ModCallbacks.MC_POST_NPC_MORPH, mod.checkStageSkins)

mod.PhageSpawnCap = 10

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.FrameCount <= 0 and mod.STAGE.Mortis:IsStage() then
        if mod:CountPhages() < mod.PhageSpawnCap then
            npc.PositionOffset = Vector.Zero
            npc:Morph(mod.ENT.Phage.ID, mod.ENT.Phage.Var, 0, npc:GetChampionColorIdx())

            if mod:IsMotherBossRoom() and npc.State == 16 then
                for _, mother in pairs(Isaac.FindByType(EntityType.ENTITY_MOTHER, 0)) do
                    if mother:ToNPC().State == 9 then
                        npc.I1 = 2
                        npc.Velocity = npc.Velocity:Resized(8)
                        break
                    end
                end
            end
        else
            sfx:Stop(SoundEffect.SOUND_BLOODSHOOT)
            mod:ScheduleForUpdate(function() sfx:Stop(SoundEffect.SOUND_BLOODSHOOT) end, 0)
            npc.Visible = false
            npc:Remove()
        end
    end
end, EntityType.ENTITY_SMALL_MAGGOT)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc:GetData().MortisSkin then
        if npc.Variant == 3 and npc.SubType == 3 then
            if npc.FrameCount % 3 == 0 then
                npc.I2 = npc.I2 - 1
            end
        end
    end
end, EntityType.ENTITY_GAPER)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc:GetData().MortisSkin then
        if npc.Variant == 1 then
            if npc:GetSprite():IsFinished("Shoot") then
                npc.ProjectileCooldown = math.floor(npc.ProjectileCooldown * 1.75)
            end
            if npc.State == 4 and mod:CountPhages() >= mod.PhageSpawnCap then
                npc.ProjectileCooldown = npc.ProjectileCooldown + 1
            end
        elseif npc.Variant == 2 then
            if npc.ProjectileCooldown <= 0 then
                mod:ScheduleForUpdate(function() npc.ProjectileCooldown = math.floor(npc.ProjectileCooldown * 1.75) end, 2)
            end
        end
    end
end, EntityType.ENTITY_GAPER_L2)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 10 and npc.SubType == 0 and mod.STAGE.Mortis:IsStage() then
        npc.SplatColor = mod.MortisSplatColors[npc.Type.." "..npc.Variant.." "..npc.SubType]
    end
end, EntityType.ENTITY_EVIS)

function mod:checkEffectStageSkins(effect)
    if effect.FrameCount <= 1 then
        if mod.STAGE.Mortis:IsStage() then
            local data = effect:GetData()
            local sprite = effect:GetSprite()

            if mod.MortisEffectsToDelete[effect.Variant.." "..effect.SubType] then
                if mod.MortisEffectsToDelete[effect.Variant.." "..effect.SubType] == "CheckForSpawner" then
                    if not effect.SpawnerEntity then
                        effect.Visible = false
                        effect:Remove()
                    end
                else
                    effect.Visible = false
                    effect:Remove()
                end
            else
                if mod.MortisSkinsEffects[effect.Variant] then
                    local entry = mod.MortisSkinsEffects[effect.Variant]
                    for _, sheet in pairs(entry) do
                        if sheet[3] then
                            sprite:Load(sheet[2], false)
                        else
                            for _, layer in pairs(sheet[1]) do
                                sprite:ReplaceSpritesheet(layer, sheet[2])
                            end
                        end
                    end
                    data.MortisSkin = true
                    sprite:LoadGraphics()
                end
            
                if mod.MortisEffectsToRecolor[effect.Variant.." "..effect.SubType] then
                    effect.Color = mod.MortisEffectsToRecolor[effect.Variant.." "..effect.SubType]
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.checkEffectStageSkins)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.checkEffectStageSkins)

function mod:CheckMortisEffectColor(effect)
    if effect.FrameCount <= 1 and mod.STAGE.Mortis:IsStage() then
        if effect.SpawnerEntity then
            if mod.MortisSplatColors[effect.SpawnerEntity.Type.." "..effect.SpawnerEntity.Variant] then
                effect.Color = mod.MortisSplatColors[effect.SpawnerEntity.Type.." "..effect.SpawnerEntity.Variant]
                effect.SplatColor = mod.MortisSplatColors[effect.SpawnerEntity.Type.." "..effect.SpawnerEntity.Variant]
            elseif effect.SpawnerType == EntityType.ENTITY_PROJECTILE then
                if (effect.Variant == EffectVariant.BLOOD_SPLAT or effect.Variant == EffectVariant.BLOOD_EXPLOSION) and mod:IsMotherBossRoom(game:GetLevel():GetCurrentRoomDesc()) then
                    effect.Color = mod.Colors.BlueGuts
                end
            end
        else
            if mod:IsMotherBossRoom(game:GetLevel():GetCurrentRoomDesc()) and not effect:GetData().DontRecolorMother then
                if effect.Variant == EffectVariant.ROCK_PARTICLE then
                    if effect.SubType == 0 or effect.SubType == 131072 then
                        local _, blueRocks = mod:GetMortisRocks()
                        effect:GetSprite():ReplaceSpritesheet(0, blueRocks, true)
                    end
                elseif effect.Variant == EffectVariant.BLOOD_PARTICLE or effect.Variant == EffectVariant.BLOOD_EXPLOSION then
                    local colorize = effect.Color:GetColorize()
                    if ((colorize.R >= 0.625 and colorize.R <= 0.635) and (colorize.G >= 0.845 and colorize.G <= 0.855)) or colorize.G == 5 or (colorize.B == 0 and effect.Color.BO == 0) then
                        effect.SplatColor = mod.Colors.BlueGuts
                        effect.Color = mod.Colors.BlueGuts
                        mod:ScheduleForUpdate(function()
                            if not effect:GetData().DontRecolorMother then
                                effect.SplatColor = mod.Colors.BlueGuts
                                effect.Color = mod.Colors.BlueGuts
                            end
                        end, 1)
                        --print("recolored!")
                    else
                        --print(effect.Color, colorize.R, colorize.G)
                        --print("not recolored!")
                    end
                else
                    effect.Color = mod.Colors.BlueGuts
                end
            end

            if effect.Variant == EffectVariant.BLOOD_EXPLOSION then
                for _, gemini in pairs(Isaac.FindByType(EntityType.ENTITY_GEMINI, 10)) do
                    if gemini.SubType ~= 2 and gemini.Position:Distance(effect.Position) <= 10 and gemini:GetSprite():GetFrame() == 19 then
                        effect.Color = mod.MortisSplatColors[gemini.Type.." "..gemini.Variant]
                        break
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.CheckMortisEffectColor, EffectVariant.BLOOD_SPLAT)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.CheckMortisEffectColor, EffectVariant.BLOOD_EXPLOSION)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.CheckMortisEffectColor, EffectVariant.BLOOD_PARTICLE)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.CheckMortisEffectColor, EffectVariant.BLOOD_PARTICLE)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.CheckMortisEffectColor, EffectVariant.POOF02)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.CheckMortisEffectColor, EffectVariant.ROCK_PARTICLE)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if mod.STAGE.Mortis:IsStage() and not mod.SpawningMortisBlood then
        local guy = mod:GetNearestThing(effect.Position, EntityType.ENTITY_GAPER_L2)
        if guy and guy.Position:Distance(effect.Position) <= 5 then
            mod.SpawningMortisBlood = true
            local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, effect.Position, Vector.Zero, nil)
            local scale = mod:RandomInt(25,100) * 0.01
            splat.SpriteScale = Vector(scale,scale)
            splat.Color = mod.Colors.MortisBlood
            effect.Visible = false
            effect:Remove()
            mod.SpawningMortisBlood = false
        end
    end
end, EffectVariant.BLOOD_SPLAT)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if mod.STAGE.Mortis:IsStage() then
        if effect.SpawnerEntity and effect.SpawnerEntity:Exists() then
            if FiendFolio and effect.SpawnerType == EntityType.ENTITY_PROJECTILE and effect.SpawnerEntity:GetData().special == "curdled" then
                effect.Color = mod.Colors.MortisBlood
            end
        else
            local flesh = mod:GetNearestThing(effect.Position, EntityType.ENTITY_LEPER, 1)
            if flesh and flesh.Position:Distance(effect.Position) <= 5 then
                effect.Color = mod.Colors.MortisBlood
            end
        end
    end
end, EffectVariant.HAEMO_TRAIL)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if effect.SubType == 1 and mod.STAGE.Mortis:IsStage() then
        if effect.SpawnerEntity and effect.SpawnerEntity:Exists() then
            if FiendFolio and effect.SpawnerType == EntityType.ENTITY_PROJECTILE and effect.SpawnerEntity:GetData().special == "curdled" then
                effect.Color = mod.Colors.MortisBlood
            end
        end
    end
end, EffectVariant.RIPPLE_POOF)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if mod.STAGE.Mortis:IsStage() then
        if effect.SpawnerType == EntityType.ENTITY_LEPER then
            effect.Color = mod.Colors.MortisBlood
        elseif FiendFolio then
            if effect.SpawnerType == FiendFolio.FF.Pox.ID and effect.SpawnerVariant == FiendFolio.FF.Pox.Var then
                effect.Color = mod.Colors.VirusBlue
            elseif effect.SpawnerType == FiendFolio.FF.Curdle.ID and (effect.SpawnerVariant == FiendFolio.FF.Curdle.Var or effect.SpawnerVariant == FiendFolio.FF.CurdleNaked.Var) then
                effect.Color = mod.Colors.MortisBlood
            end
        end
    end
end, EffectVariant.CREEP_RED)

function mod:colorMortisProjectiles(projectile)
    if mod.STAGE.Mortis:IsStage() then
        local color = mod.MortisTearColors[projectile.SpawnerType.." "..projectile.SpawnerVariant]
        if color then
            projectile.Color = color
            for i = 1, 2 do
                mod:ScheduleForUpdate(function()
                    if not projectile:HasProjectileFlags(ProjectileFlags.SMART) then
                        projectile.Color = color
                    end
                end, i)
            end
        elseif FiendFolio then
            if projectile.SpawnerType == FiendFolio.FF.GutKnight.ID and projectile.SpawnerVariant == FiendFolio.FF.GutKnight.Var then
                local rand = mod:RandomInt(0,12) * 0.1
                local color = Color(1,0.6,0.7)
                color:SetColorize(1 + rand,0.924,1.31,1)
                projectile.Color = color
                for i = 1, 2 do
                    mod:ScheduleForUpdate(function()
                        projectile.Color = color
                    end, i)
                end
            elseif projectile.SpawnerType == EntityType.ENTITY_PROJECTILE and projectile.SpawnerEntity:GetData().special == "curdled" then
                projectile.Color = mod.Colors.MortisBloodProj
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, mod.colorMortisProjectiles)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    local cyst = mod:GetNearestThing(effect.Position, EntityType.ENTITY_CYST)
    if cyst then
        if cyst.Position:Distance(effect.Position) <= 5 and cyst:ToNPC().ProjectileCooldown >= 55 then
            effect.Color = mod.Colors.MortisBloodProj
        end
    end
end, EffectVariant.BULLET_POOF)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if mod.STAGE.Mortis:IsStage() then
        local sprite = effect:GetSprite()
        if mod.UsingMorgueisBackdrop then
            sprite:ReplaceSpritesheet(0, "gfx/effects/rockwave_morgueis.png", true)
        else
            sprite:ReplaceSpritesheet(0, "gfx/effects/rockwave_mortis.png", true)
        end
        sprite:Play("WombBreak"..mod:RandomInt(1,3), true)
    end
end, EffectVariant.ROCK_EXPLOSION)

local haemoColor = Color(0,0,0,0.87,100/255,220/255,230/255)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect.FrameCount <= 0 and mod.STAGE.Mortis:IsStage() then
        if effect.SpawnerType == EntityType.ENTITY_MOTHER and effect.SpawnerVariant == 100 then
            effect.Color = haemoColor
        end
    end
end, EffectVariant.HAEMO_TRAIL)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect.FrameCount <= 0 and mod.STAGE.Mortis:IsStage() then
        if mod:IsMotherBossRoom(game:GetLevel():GetCurrentRoomDesc()) then
            effect.Color = Color(0.3,0.5,0.6,0.1)
        end
    end
end, EffectVariant.BIG_ATTRACT)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if mod.STAGE.Mortis:IsStage() then
        local sprite = effect:GetSprite()
        for i = 0, 1 do
            sprite:ReplaceSpritesheet(i, basepath.."reskins/mother/mother_tracer_mortis.png")
        end
        sprite:ReplaceSpritesheet(2, basepath.."reskins/mother/chubberworm_mortis.png")
        sprite:LoadGraphics()
    end
end, EffectVariant.MOTHER_TRACER)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    if proj.FrameCount <= 1 and mod.STAGE.Mortis:IsStage() then
        if proj.SpawnerType == EntityType.ENTITY_MOTHER and not proj:GetData().MortisMotherColored then
            local colorize = proj.Color:GetColorize()
            --print(proj.Color, proj.Variant)
            if colorize.G >= 0.845 and colorize.G <= 0.855 then
                local rand = mod:RandomInt(1,3)
                if rand == 1 then
                    proj.Color = mod.Colors.OrganPurple
                elseif rand == 2 then
                    proj.Color = mod.Colors.OrganYellow
                elseif rand == 3 then
                    proj.Color = mod.Colors.OrganBlue
                end
            elseif proj.Color.R == 1 and proj.Color.G == 1 and proj.Color.B == 1 and colorize.G <= 0 then
                proj.Color = mod.Colors.MortisBloodProj
            elseif colorize.R == 4 or colorize.R == 3.5 then
                proj.Color = mod.Colors.VirusBlue
            elseif colorize.G == 2 then
                proj.Color = mod.Colors.MotherBlueProj1
            elseif colorize.G == 3 then
                proj.Color = mod.Colors.MotherBlueProj2
            end
            proj:GetData().MortisMotherColored = true
        end
    end
end, ProjectileVariant.PROJECTILE_NORMAL)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, proj)
    if mod.STAGE.Mortis:IsStage() then
        proj.SplatColor = mod.Colors.MortisBlood
        proj:GetSprite():ReplaceSpritesheet(0, basepath.."reskins/mother/dead_isaac_mortis.png", true)
    end
end, ProjectileVariant.PROJECTILE_HEAD)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
    if proj.Variant == ProjectileVariant.PROJECTILE_HEAD and mod.STAGE.Mortis:IsStage() then
        for _, var in pairs({EffectVariant.BLOOD_PARTICLE, EffectVariant.BLOOD_EXPLOSION}) do
            for _, eff in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, var)) do
                if eff.FrameCount <= 0 and eff.Position:Distance(proj.Position) <= 10 then
                    eff.Color = mod.Colors.MortisBlood
                    eff.SplatColor = mod.Colors.MortisBlood
                    eff:GetData().DontRecolorMother = true
                end
            end
        end
    end
end, EntityType.ENTITY_PROJECTILE)

mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, function(_, laser)
    if mod.STAGE.Mortis:IsStage() then
        if laser.SpawnerType == EntityType.ENTITY_MOTHER then
            laser.Color = mod.Colors.MortisBloodProj
            mod:ScheduleForUpdate(function()
                laser.Color = mod.Colors.MortisBloodProj
            end, 1)
        end
    end
end, LaserVariant.GIANT_RED)