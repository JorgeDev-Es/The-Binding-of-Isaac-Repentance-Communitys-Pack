local Mod = RegisterMod("deli_void",1)
local game = Game()
local sound = SFXManager()
local room = Game():GetRoom()
local SaveState = {}


local SaveState = {}

local StageSettings = {
	["Void"] = true,
	["VoidPlus"] = true,
	["Chest"] = false,
}

if ModConfigMenu then 
    local AccurateBosses = "Accurate Bosses"
    ModConfigMenu.UpdateCategory(AccurateBosses, {
            Info = {"Accurate Stage Bosses Settings",}
        })
    --Title
        ModConfigMenu.AddText(AccurateBosses, "Settings", function() return "Change stages parameters" end)
        ModConfigMenu.AddText(AccurateBosses, "Credits", function() return "Credits" end)
        ModConfigMenu.AddSpace(AccurateBosses, "Settings","Credits")
        -- Settings
        ModConfigMenu.AddSetting(AccurateBosses, "Settings", { --Void
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return StageSettings["Void"]
                end,
                Display = function()
                    local onOff = "False"
                    if StageSettings["Void"] then
                        onOff = "True"
                    end
                    return 'Accurate void bosses: ' .. onOff
                end,
                OnChange = function(currentBool)
                    StageSettings["Void"] = currentBool
                end,
                Info = function()
                    local Text = StageSettings["Void"] and " " or " not "
                    local TotalText = "Void bosses will" .. Text .. "be delirium forms."
    
                    return TotalText
                end
            })
        ModConfigMenu.AddSetting(AccurateBosses, "Settings", { --VoidPlus
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return StageSettings["VoidPlus"]
                end,
                Display = function()
                    local onOff = "False"
                    if StageSettings["VoidPlus"] then
                        onOff = "True"
                    end
                    return 'Non natural bosses accurate in void: ' .. onOff
                end,
                OnChange = function(currentBool)
                    StageSettings["VoidPlus"] = currentBool
                end,
                Info = function()
                    local Text = StageSettings["VoidPlus"] and " " or " not "
                    local TotalText = "Non natural Void bosses will" .. Text .. "be delirium forms."
    
                    return TotalText
                end
            })
        ModConfigMenu.AddSetting(AccurateBosses, "Settings", { --Chest
                Type = ModConfigMenu.OptionType.BOOLEAN,
                CurrentSetting = function()
                    return StageSettings["Chest"]
                end,
                Display = function()
                    local onOff = "False"
                    if StageSettings["Chest"] then
                        onOff = "True"
                    end
                    return 'God in Chest: ' .. onOff
                end,
                OnChange = function(currentBool)
                    StageSettings["Chest"] = currentBool
                end,
                Info = function()
                    local Text = StageSettings["Chest"] and " " or " not "
                    local TotalText = "God will" .. Text .. "replace Mega Satan in chest."
    
                    return TotalText
                end
            })

        
        
        end
    
    local json = require("json")
    local SaveState = {}
    function Mod:SaveGame()
        SaveState.Settings = {}
        
        for i, v in pairs(StageSettings) do
            SaveState.Settings[tostring(i)] = StageSettings[i]
        end
        Mod:SaveData(json.encode(SaveState))
    end
    Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Mod.SaveGame)
    
    function Mod:OnGameStart(isSave)
        if Mod:HasData() then	
            SaveState = json.decode(Mod:LoadData())	
            
            for i, v in pairs(SaveState.Settings) do
                StageSettings[tostring(i)] = SaveState.Settings[i]
            end
        end
    end
    Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.OnGameStart)
    



function Mod:onRender()

    local level = game:GetLevel()
    if  level:GetStage() == 12 then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:GetData()["accurate"] == nil then
                entity:GetData()["accurate"] = true
            
            local sprite = entity:GetSprite()
            --print(sprite:GetFilename())
            if sprite:GetFilename() == "gfx/079.012_The Blighted Ovum Baby.anm2" then
                sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_024_blightedovum.png")
                sprite:LoadGraphics()
            elseif sprite:GetFilename() == "gfx/404.000_Littlehorn.anm2" then
                sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/littlehorn.png")
                sprite:LoadGraphics()
            end
            
            if entity:IsBoss() and entity.Type~=412 then
                --print(sprite:GetFilename())
                if StageSettings["Void"] then
                    if sprite:GetFilename() == "gfx/261.000_Dingle.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/boss_085_dingle.png")
                        sprite:LoadGraphics()                    
                    elseif sprite:GetFilename() == "gfx/908.000_baby plum.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/repentance/babyplum.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/261.001_Dangle.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/boss_085_dangle.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/237.000_Gurgling.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/monster_237_gurgling hands.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/rebirth/monster_237_gurgling.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/404.000_Littlehorn.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/littlehorn.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/237.002_Turdling.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/monster_237_gurgling hands.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/afterbirth/boss_turdling.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/405.000_Ragman.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/ragman.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/afterbirth/ragman_body.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/405.001_ragman_rolling_head" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/ragman_rollinghead.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/063.000_Famine.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_014_famine.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_014_famine.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_014_famine.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/079.000_Gemini.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_000_bodies02.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_010_gemini.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/079.010_Gemini Baby.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_010_gemini.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/079.001_Steven.anm2" then
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_013_steven.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/079.011_Steven Baby.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_013_steven.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/079.002_The Blighted Ovum.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_000_bodies02.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_024_blightedovum.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/067.000_The Duke of Flies.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_007_dukeofflies.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_007_dukeofflies.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/classic/boss_007_dukeofflies.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/407.000_Hush.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/boss_hush.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/afterbirth/boss_hush.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/afterbirth/boss_hush.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/afterbirth/boss_hush.png")
                        sprite:ReplaceSpritesheet(4,"gfx/deliriumforms/afterbirth/boss_hush.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/102.002_ (alt).anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/boss_078_bluebaby_hush.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/019.000_Larry Jr..anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_001_larryjr.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/067.001_The Husk.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_038_husk.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/classic/boss_038_husk.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/019.001_The Hollow.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_041_thehollow.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/260.000_Haunt.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/boss_083_haunt.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/403.000_TheForsaken.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/theforsaken.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/100.000_Widow.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_016_widow.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_016_widow.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/classic/boss_016_widow.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/100.001_The Wretched.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_047_thewretched.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_047_thewretched.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/classic/boss_047_thewretched.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/062.000_Pin.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_019_pin.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/062.002_TheFrail.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/boss_thefrail.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/020.000_Monstro.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_004_monstro.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/043.000_Monstro II.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_049_monstroii.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/043.001_Gish.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_051_gish.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/071.000_Fistula Big.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_025_fistula.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/072.000_Fistula Medium.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_025_fistula.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/073.000_Fistula Small.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_025_fistula.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/071.001_Teratoma Big.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_068_teratoma.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/072.001_Teratoma Medium.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_068_teratoma.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/073.001_Teratoma Small.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_068_teratoma.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/099.000_Gurdy Jr..anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_021_gurdyjr.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_021_gurdyjr.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/409.000_RagMega.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirthplus/boss_ragmega.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/036.000_Gurdy.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_030_gurdy.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_030_gurdy.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_030_gurdy.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/classic/boss_030_gurdy.png")
                        sprite:ReplaceSpritesheet(4,"gfx/deliriumforms/classic/boss_030_gurdy.png")
                        sprite:ReplaceSpritesheet(5,"gfx/deliriumforms/classic/boss_030_gurdy.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/411.000_BigHorn.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirthplus/boss_bighorn.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/064.000_Pestilence.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_036_pestilence.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_036_pestilence.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_036_pestilence.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/269.000_Polycephalus.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/polycephalus.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/401.000_TheStain.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/thestain.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/afterbirth/thestain.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/afterbirth/thestain.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/028.000_Chub.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_032_chub.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/028.001_C.H.A.D..anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_035_chad.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/028.002_The Carrion Queen.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_045_carrionqueen.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/264.000_Mega Fatty.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/boss_089_fatty.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/rebirth/boss_089_fatty.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/265.000_Mega Fatty 2.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/boss_090_fatty2.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/267.000_Dark One.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/092_darkone.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/268.000_Dark One 2.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/093_darkone2.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/068.001_The Bloat.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_060_bloat.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/262.000_MegaMaw.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/088_megamaw.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/263.000_MegaMaw2.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/boss_088_megamaw2.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/402.000_Brownie.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/brownie.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/afterbirth/brownie.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/afterbirth/brownie.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/afterbirth/brownie.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/097.000_Mask of Infamy.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_057_maskofinfamy.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/098.000_Heart of Infamy.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_057_maskofinfamy.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/265.001_SistersVis.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirthplus/boss_sistersvis.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/afterbirthplus/boss_sistersvis.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/afterbirthplus/boss_sistersvis.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/afterbirthplus/boss_sistersvis.png")
                        sprite:ReplaceSpritesheet(5,"gfx/deliriumforms/afterbirthplus/boss_sistersvis.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/069.000_Loki.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_048_loki.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/069.001_Lokii.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_071_lokii.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/074.000_Blastocyst Big.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(4,"gfx/deliriumforms/classic/boss_063_blastocyst_back.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/075.000_Blastocyst Medium.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(4,"gfx/deliriumforms/classic/boss_063_blastocyst_back.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/076.000_Blastocyst Small.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_063_blastocyst.png")
                        sprite:ReplaceSpritesheet(4,"gfx/deliriumforms/classic/boss_063_blastocyst_back.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/062.001_Scolex.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_062_scolex.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_062_scolex.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_062_scolex.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/066.000_Death.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_064_death.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_064_death.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_064_death.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/066.020_Death Horse.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_064_death.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/101.000_Daddy Long Legs.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_059_daddylonglegs.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_059_daddylonglegs.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/101.001_Triachnid.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_067_triachnid.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_067_triachnid.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/270.000_MegaFred.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/megafred.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/rebirth/megafred.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/266.000_Mega Gurdy.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/91_megagurdy.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/413.000_Matriarch.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirthplus/boss_matriarch.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/081.000_The Fallen.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_072_thefallen.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_072_thefallen.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_072_thefallen.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/classic/boss_072_thefallen.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/082.000_Headless Horseman.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_081_headlesshorseman.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/083.000_Headless Horsemans Head.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_081_headlesshorseman.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/081.001_Krampus.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_082_krampus.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_082_krampus.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_082_krampus.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/271.000_angel.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/angel.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/rebirth/angel.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/rebirth/angel.png")
                        sprite:ReplaceSpritesheet(4,"gfx/deliriumforms/rebirth/angel.png")
                        sprite:ReplaceSpritesheet(5,"gfx/deliriumforms/rebirth/angel.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/272.000_angel2.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/angel2.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/rebirth/angel2.png")
                        sprite:ReplaceSpritesheet(3,"gfx/deliriumforms/rebirth/angel2.png")
                        sprite:ReplaceSpritesheet(4,"gfx/deliriumforms/rebirth/angel2.png")
                        sprite:ReplaceSpritesheet(5,"gfx/deliriumforms/rebirth/angel2.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/045.010_Mom Stomp.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_054_mom.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/045.000_Mom.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_054_mom.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/078.000_Moms Heart.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_069_momsheart.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_069_momsheart.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_78_moms guts.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/078.001_It Lives.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_070_itlives.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/084.000_Satan.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_074_satanii.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_74_satanwings.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/084.010_Satan Stomp.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_074_satan_leg.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/102.000_Isaac (final boss).anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_075_isaac.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/102.001_ (final boss).anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_078_bluebaby.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/273.000_TheLamb.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/thelamb.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/273.001_TheLamb.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/thelamb.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/274.000_MegaSatanHead.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/megasatan.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/rebirth/megasatan_effects.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/274.001_MegaSatanHand.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/rebirth/megasatan.png")
                        sprite:LoadGraphics()
                    
                    end
                    
                end
                if StageSettings["VoidPlus"] then 
                    
                    if sprite:GetFilename() == "gfx/921.000_clutch.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/repentance/clutch.png")
                        --sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/repentance/clutch_trail.png") Couldnt make it work sadly
                        sprite:LoadGraphics()eet(2,"gfx/deliriumforms/repentance/siren.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/908.000_baby plum.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/repentance/babyplum.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/904.000_siren.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/repentance/siren.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/repentance/siren.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/repentance/siren.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/916.000_bumbino.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/repentance/bumbino.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/repentance/bumbino.png")
                        sprite:LoadGraphics()
                    elseif sprite:GetFilename() == "gfx/902.000_rainmaker.anm2" then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/repentance/rainmaker.png")
                        sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/repentance/rainmaker.png")
                        sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/repentance/rainmaker.png")
                        sprite:LoadGraphics()
                   end
                end
            end
        end
        end        
    end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN,Mod.onRender)


function Mod:onRenderUpdate()
    local level = game:GetLevel()
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        local sprite = entity:GetSprite()
        if sprite:GetFilename()~= "gfx/ui/hudpickups2.anm2" then
            if sprite:GetFilename()~= "gfx/001.000_Player.anm2"  then
                --print(sprite:GetFilename())
            end
        end
    end
    if  level:GetStage() == 12 then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity.Type~=412 then
                local sprite = entity:GetSprite()
                --print(sprite:GetFilename())
                if sprite:GetFilename() == "gfx/068.000_Peep.anm2" then
                    if entity.HitPoints >= 2*entity.MaxHitPoints/3 then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_027_peep.png")
                        sprite:LoadGraphics()
                    elseif entity.HitPoints >= entity.MaxHitPoints/3 then
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_027_peep_b.png")
                        sprite:LoadGraphics()
                    else 
                        sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_027_peep_c.png")
                        sprite:LoadGraphics()
                    end
                elseif sprite:GetFilename() == "gfx/078.010_Moms Guts.anm2" then
                    sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_78_moms guts.png")
                    sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_78_moms guts.png")
                    sprite:LoadGraphics()
                elseif sprite:GetFilename() == "gfx/065.000_War.anm2" then
                    sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_052_war.png")
                    sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_052_war.png")
                    sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_052_war.png")
                    sprite:LoadGraphics()
                elseif sprite:GetFilename() == "gfx/065.010_War without horse.anm2" then
                    sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_000_bodies02.png")
                    sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_052_war.png")
                    sprite:LoadGraphics()                
                elseif sprite:GetFilename() == "gfx/066.030_Death without horse.anm2" then
                    sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_064_death.png")
                    sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_064_death.png")
                    sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_064_death.png")
                    sprite:LoadGraphics()
                elseif sprite:GetFilename() == "gfx/065.001_Conquest.anm2" then
                    sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_066_conquest.png")
                    sprite:ReplaceSpritesheet(1,"gfx/deliriumforms/classic/boss_066_conquest.png")
                    sprite:ReplaceSpritesheet(2,"gfx/deliriumforms/classic/boss_066_conquest.png")
                    sprite:LoadGraphics()
                elseif sprite:GetFilename() == "gfx/261.001_Dangle.anm2" then
                    sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/afterbirth/boss_085_dangle.png")
                    sprite:LoadGraphics()
                elseif sprite:GetFilename() == "gfx/028.000_Chub.anm2" then
                    sprite:ReplaceSpritesheet(0,"gfx/deliriumforms/classic/boss_032_chub.png")
                    sprite:LoadGraphics() 
                end
            end
        end
    end
    

    if  level:GetStage() == 11 then
        --print(room:GetBackdropType())
        --print(game:GetRoom())
        if level:GetStageType() == 1 then
            for _, entity in pairs(Isaac.GetRoomEntities()) do
                local sprite = entity:GetSprite()
                --if entity:GetData()["accurate"] == nil then
                --    entity:GetData()["accurate"] = true
                --end
                --print(sprite:GetFilename()) 
                if sprite:GetFilename() == "gfx/275.000_MegaSatan2Head" then
                    --print("megasatan2") 
                end         
                if entity.Type~=412 then --entity:IsBoss() and 
                    if StageSettings["Chest"] then
                        if sprite:GetFilename() == "gfx/274.000_MegaSatanHead.anm2" then
                            sprite:ReplaceSpritesheet(0,"gfx/godboss/godboss.png")
                            sprite:ReplaceSpritesheet(1,"gfx/godboss/godboss.png")
                            sprite:ReplaceSpritesheet(4,"gfx/godboss/godboss.png")
                            sprite:ReplaceSpritesheet(2,"gfx/godboss/godboss_effects.png")
                            sprite:ReplaceSpritesheet(3,"gfx/godboss/godboss_effects.png")
                            sprite:LoadGraphics()   
                        elseif sprite:GetFilename() == "gfx/274.001_MegaSatanHand.anm2" then
                            sprite:ReplaceSpritesheet(0,"gfx/godboss/godboss.png")
                            sprite:LoadGraphics()
                        elseif sprite:GetFilename() == "gfx/275.000_megasatan2head" then
                            sprite:ReplaceSpritesheet(0,"gfx/godboss/godboss.png")
                            sprite:ReplaceSpritesheet(1,"gfx/godboss/godboss.png")
                            sprite:ReplaceSpritesheet(2,"gfx/godboss/godboss.png")
                            sprite:ReplaceSpritesheet(3,"gfx/godboss/godboss.png")
                            sprite:ReplaceSpritesheet(4,"gfx/godboss/godboss.png")
                            sprite:ReplaceSpritesheet(5,"gfx/godboss/godboss.png")
                            --print("satan2")
                            sprite:LoadGraphics()
                        elseif sprite:GetFilename() == "gfx/275.001_MegaSatan2hand.anm2" then
                            sprite:ReplaceSpritesheet(0,"gfx/godboss/godboss.png")
                            sprite:LoadGraphics()   
                        end 
                        if entity.Type==275 then
                            sprite:ReplaceSpritesheet(0,"gfx/godboss/godboss2.png")
                            sprite:ReplaceSpritesheet(1,"gfx/godboss/godboss2.png")
                            sprite:ReplaceSpritesheet(2,"gfx/godboss/godboss2.png")
                            sprite:ReplaceSpritesheet(3,"gfx/godboss/godboss2.png")
                            sprite:ReplaceSpritesheet(4,"gfx/godboss/godboss2.png")
                            sprite:ReplaceSpritesheet(5,"gfx/godboss/godboss2.png")
                            --print("satan2")
                            sprite:LoadGraphics()
                        end    
                       
                    end  
                   
                end
                if room:GetBackdropType() == 18 then
                    --print("gold baby!!")
                    --Game():GetRoom():SetFloorColor(Color(1,1,1,1,255,215,0))
                    --room:TurnGold()
                end
            end
        end
    end 
    
end


Mod:AddCallback(ModCallbacks.MC_POST_RENDER,Mod.onRenderUpdate)

function Mod:OnRoomUpdate()
    local getLevel = game:GetLevel()

    --Delirium door locking function

    if getLevel:GetStage() == LevelStage.STAGE7 then
        local getRoom = game:GetRoom()

        for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
            local door = getRoom:GetDoor(i)

            --If the door exists
            if door ~= nil then
                --Getting the index of the room, its description data, and its configuration data
                local doorSprite = door:GetSprite()
                local doorRoomIndex = door.TargetRoomIndex
                local roomDescriptor = getLevel:GetRoomByIdx(doorRoomIndex)
                local roomConfigData = roomDescriptor.Data  
                
                --Code is based on Delirium Door mod, credits to OceanMan
                if (roomConfigData.Shape == RoomShape.ROOMSHAPE_2x2 and roomConfigData.Type == RoomType.ROOM_BOSS) or (getRoom:GetType() == RoomType.ROOM_BOSS and getRoom:GetRoomShape() == RoomShape.ROOMSHAPE_2x2) and not door:IsOpen() then
                    doorSprite:Load("gfx/grid/deliriumdoor.anm2", false)
                    --Play the close door animation since changing the sprite messes up the animation that plays
                    doorSprite:Play("Close", false)
                    doorSprite:LoadGraphics()
                end
            end
        end
    end
end
-- Work in Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.OnRoomUpdate)