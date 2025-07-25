local mod = RangeFixForBonesAndSword;
local MCM = ModConfigMenu;
local ModName = mod.Name;
local Version = mod.VersionString;

if (MCM) then
    MCM.SetCategoryInfo(ModName, "A mod that fixed bones and spirit sword's range compatibility.")
    MCM.AddSpace(ModName, "Info");
    MCM.AddText(ModName, "Info", ModName)
    MCM.AddSpace(ModName, "Info")
    MCM.AddText(ModName, "Info", function() return "Version " .. Version end)
    MCM.AddSpace(ModName, "Info")
    MCM.AddText(ModName, "Info", "By Cuerzor")

    do  -- Enabled.
        local boolean = MCM.AddBooleanSetting(
            ModName, 
            "Settings", --category
            "Enabled", --attribute in table
            mod:IsEnabled(), --default value
            "Enabled", --display text
            { --value display text
                [true] = "On",
                [false] = "Off"
            },
            "Enable or disable the fix effect for melee weapons."
        );
        local setEnabled = mod.SetEnabled;
        mod.SetEnabled = function(self, value)
            setEnabled(self, value);
            MCM.Config[ModName]["Enabled"] = value;
        end

        local onChange = boolean.OnChange;
        boolean.OnChange = function(currentValue) 
            onChange(currentValue);
            mod:SetEnabled(currentValue);
        end
    end

    do  -- Range Factor.
        local scroll = MCM.AddScrollSetting(
            ModName, 
            "Settings", --category,
            "RangeFactor", --attribute in table
            mod:GetRangeFactor(), --default value
            "Range Factor", --display text, 
            "How much will the range affect the size of weapons.")
        local setRangeFactor = mod.SetRangeFactor;
        mod.SetRangeFactor = function(self, value)
            setRangeFactor(self, value);
            MCM.Config[ModName]["RangeFactor"] = value;
        end

        local onChange = scroll.OnChange;
        scroll.OnChange = function(currentValue) 
            onChange(currentValue);
            mod:SetRangeFactor(currentValue);
        end
    end
    
    do  -- Affect Bag of Crafting.
        local boolean = MCM.AddBooleanSetting(
            ModName, 
            "Settings", --category
            "EnabledBOC", --attribute in table
            mod:IsEnabledBOC(), --default value
            "Enabled for BOC", --display text
            { --value display text
                [true] = "On",
                [false] = "Off"
            },
            "Enable or disable the fix effect for Bag of Crafting."
        );
        local setEnabledBOC = mod.SetEnabledBOC;
        mod.SetEnabledBOC = function(self, value)
            setEnabledBOC(self, value);
            MCM.Config[ModName]["EnabledBOC"] = value;
        end

        local onChange = boolean.OnChange;
        boolean.OnChange = function(currentValue) 
            onChange(currentValue);
            mod:SetEnabledBOC(currentValue);
        end
    end

    do  -- BOC Range Factor.
        local scroll = MCM.AddScrollSetting(
            ModName, 
            "Settings", --category,
            "RangeFactorBOC", --attribute in table
            mod:GetRangeFactorBOC(), --default value
            "Range Factor for BOC", --display text, 
            "How much will the range affect the size of Bag of Crafting.")
        local setRangeFactorBOC = mod.SetRangeFactorBOC;
        mod.SetRangeFactorBOC = function(self, value)
            setRangeFactorBOC(self, value);
            MCM.Config[ModName]["RangeFactorBOC"] = value;
        end

        local onChange = scroll.OnChange;
        scroll.OnChange = function(currentValue) 
            onChange(currentValue);
            mod:SetRangeFactorBOC(currentValue);
        end
    end

    if MCM.i18n == "Chinese" then
        MCM.SetCategoryNameTranslate(ModName, "骨&剑射程修复")
        MCM.SetSubcategoryNameTranslate(ModName, "Info","信息")
        MCM.SetSubcategoryNameTranslate(ModName, "Settings","设置")
        
        MCM.SetCategoryInfoTranslate(ModName, "一个修复了骨头、英灵剑等近战攻击方式和射程兼容问题的MOD。")
        MCM.TranslateOptionsDisplayTextWithTable(ModName, "Info", {
            [ModName] = "骨&剑射程修复",
            ["By Cuerzor"] = "Cuerzor制作"
        })
        MCM.TranslateOptionsDisplayWithTable(ModName, "Info", {
            {"Version", "版本"}
        })
        MCM.TranslateOptionsDisplayWithTable(ModName, "Settings", {
            { "Enabled for BOC", "合成宝袋启用"},
            { "Range Factor for BOC", "合成宝袋射程倍率"},
            { "Enabled", "启用"},
            { "Range Factor", "射程倍率"},
            { "On", "开"},
            { "Off", "关"},
        })
        MCM.TranslateOptionsInfoTextWithTable(ModName, "Settings",{
            ["Enable or disable the fix effect for melee weapons."] = 
            "启用或禁用近战武器的修复效果。",
            ["How much will the range affect the size of weapons."] = 
            "修改射程影响武器尺寸的程度。",
            ["Enable or disable the fix effect for Bag of Crafting."] = 
            "启用或禁用合成宝袋的修复效果。",
            ["How much will the range affect the size of Bag of Crafting."] = 
            "修改射程影响合成宝袋的程度。",
        });
    end
end