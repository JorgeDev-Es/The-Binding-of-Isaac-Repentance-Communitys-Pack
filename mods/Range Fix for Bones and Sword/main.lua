local mod = RegisterMod("Range fix for Bones & Sword", 1)
RangeFixForBonesAndSword = mod;
mod.WhitelistVariants = {
    [1] = true,
    [2] = true,
    [3] = true,
    [9] = true,
    [10] = true,
    [11] = true,
}
mod.VersionString = "1.1.0";

local json = require("json")
local dataTable;
local function saveDataTable(tbl)
    local string = json.encode(tbl);
    mod:SaveData(string);
end

local function loadDataTable()
    if (mod:HasData()) then
        local string = mod:LoadData();
        return json.decode(string);
    end
    return {};
end

local function GetData(key, default)
    dataTable = dataTable or loadDataTable();
    if (dataTable[key] == nil) then
        return default;
    end
    return dataTable[key];
end
local function SetData(key, value)
    dataTable = dataTable or loadDataTable();
    dataTable[key] = value;
    saveDataTable(dataTable);
end

function mod:IsEnabled() return GetData("Enabled", true); end
function mod:SetEnabled(value) SetData("Enabled", value) end

function mod:GetRangeFactor() return GetData("RangeFactor", 5); end
function mod:SetRangeFactor(value) SetData("RangeFactor", value); end

function mod:IsEnabledBOC() return GetData("EnabledBOC", true); end
function mod:SetEnabledBOC(value) SetData("EnabledBOC", value) end

function mod:GetRangeFactorBOC() return GetData("RangeFactorBOC", 0); end
function mod:SetRangeFactorBOC(value) SetData("RangeFactorBOC", value); end

local function FixKnife(knife, enabled, factor)
    if (not enabled) then
        return;
    end
    local targetPosition = knife.TargetPosition;
    local multiplier = factor / 450;
    local scale = targetPosition.X * multiplier + 1;
    knife.TargetPosition = Vector(4,0);
    knife.Scale = knife.Scale * scale;
    knife.SpriteScale = knife.SpriteScale * scale;

    local parent = nil;
    if (not parent) then
        for _, ent in ipairs(Isaac.FindByType(8,knife.Variant,0)) do
            if (GetPtrHash(ent.SpawnerEntity) == GetPtrHash(knife.SpawnerEntity)) then
                parent = ent;
                break;
            end
        end
    end
    if (parent) then
        knife.Position = parent.Position + Vector.FromAngle(knife.Rotation) * 8;
        knife.Velocity = Vector.Zero;
    end
end

local function PostKnifeUpdate(_, knife)
    if (knife.FrameCount > 0) then
        return;
    end
    if (not mod.WhitelistVariants[knife.Variant]) then
        return;
    end
    FixKnife(knife, mod:IsEnabled(), mod:GetRangeFactor());
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, PostKnifeUpdate, 4)


local function PostBOCUpdate(_, knife)
    if (knife.FrameCount > 0) then
        return;
    end
    if (knife.Variant ~= 4) then
        return;
    end
    FixKnife(knife, mod:IsEnabledBOC(), mod:GetRangeFactorBOC());
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, PostBOCUpdate, 4)


if (ModConfigMenu) then
    require("mod_config_menu");
end