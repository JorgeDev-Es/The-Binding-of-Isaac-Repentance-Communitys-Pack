local mod = RegisterMod("Transparent Stoneys", 1)
local game = Game()
local json = require("json")

local settings = {
    alpha = 5,
}
function mod:Save()
  local jsonString = json.encode(settings)
  mod:SaveData(jsonString)
end

function mod:Load()
  if not mod:HasData() then
    return
  end
  local jsonString = mod:LoadData()
  settings = json.decode(jsonString)
end

if ModConfigMenu ~= nil then
    ModConfigMenu.RemoveCategory("Transparent Stoneys")
    mod:Load()
    ModConfigMenu.UpdateCategory("Transparent Stoneys", {
        Name = "Transparent Stoneys",
        Info = "Makes Stoneys transparent",
    })
    ModConfigMenu.AddText("Transparent Stoneys", nil, "Super cool settings")
    ModConfigMenu.AddSetting("Transparent Stoneys",
    {
      Type = ModConfigMenu.OptionType.SCROLL,
      CurrentSetting = function()
        return settings.alpha
      end,
      Display = function()
        return "Transparency: $scroll" .. settings.alpha
      end,
      OnChange = function(a)
        settings.alpha = a
        mod:Save()
      end,
      Info = { "Stoneys become fully invisible at 100%" }
    }
  )
end

function mod:transparentify()
    local stoneys = Isaac.FindByType(EntityType.ENTITY_STONEY)
    for i, stoney in pairs(stoneys) do
        stoney:SetColor(Color(1,1,1,1 - (settings.alpha / 10)), 2, 1, false, false)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.transparentify)