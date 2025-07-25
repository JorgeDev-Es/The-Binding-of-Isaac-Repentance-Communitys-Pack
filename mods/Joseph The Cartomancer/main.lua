JosephMod = RegisterMod("Joseph", 1)
if REPENTOGON then
  require("JOSEPH_TSIL.TSIL").Init("JOSEPH_TSIL")

  include("joseph_scripts.enums")
  JosephMod.utility = include('joseph_scripts.utility.utilityFunctions')
  JosephMod.BaseCardEffects = include('joseph_scripts.card_enchants.base_card_effects')
  JosephMod.josephCharacter = include("joseph_scripts.characters.joseph")
  JosephMod.Chargebar = include("joseph_scripts.chargebar")
  include("joseph_scripts.achievements")
  include("joseph_scripts.characters.enchanting")

  include("joseph_scripts.card_enchants.chariot")
  include("joseph_scripts.card_enchants.reverse_fool")
  include("joseph_scripts.card_enchants.reverse_empress")
  include("joseph_scripts.card_enchants.reverse_chariot")
  include("joseph_scripts.card_enchants.reverse_high_priestess")
  include("joseph_scripts.card_enchants.reverse_lovers")
  include("joseph_scripts.card_enchants.reverse_stars")
  include("joseph_scripts.card_enchants.reverse_emperor")
  include("joseph_scripts.card_enchants.reverse_magician")
  include("joseph_scripts.card_enchants.reverse_death")
  include("joseph_scripts.card_enchants.reverse_hanged_man")
  include("joseph_scripts.card_enchants.reverse_devil")
  include("joseph_scripts.card_enchants.reverse_sun")
  include("joseph_scripts.card_enchants.reverse_moon")
  include("joseph_scripts.card_enchants.reverse_hermit")
  include("joseph_scripts.card_enchants.reverse_justice")
  include("joseph_scripts.card_enchants.reverse_hierophant")
  include("joseph_scripts.card_enchants.reverse_temperance")
  include("joseph_scripts.card_enchants.reverse_judgement")
  include("joseph_scripts.card_enchants.reverse_strength")
  include("joseph_scripts.card_enchants.reverse_wheel_of_fortune")
  include("joseph_scripts.card_enchants.reverse_tower")
  include("joseph_scripts.card_enchants.reverse_world")




  include("joseph_scripts.characters.slotmachines")
  --include("joseph_scripts.items.lil_slots")
  include("joseph_scripts.items.card_sleeve")
  include("joseph_scripts.items.calendar")
  include("joseph_scripts.items.scrawl")
  include("joseph_scripts.items.poker_mat")
  include("joseph_scripts.items.shredder")
  include("joseph_scripts.items.soul_of_envy")
  include("joseph_scripts.items.ace_of_hearts")
  include("joseph_scripts.items.trinkets.cuppa_joe")
  include("joseph_scripts.items.trinkets.ear_of_grain")

  include("joseph_scripts.items.pickups.the_aeon")
  

  include("joseph_scripts.compat.EID")
  include("joseph_scripts.compat.other_mods")

else
  JosephMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
      local pos = 50
      local scale = 0.5
      local warning =
          "REPENTOGON is required to use Joseph mod and is not installed! Check out repentogon.com for more information!"
      Isaac.RenderScaledText(warning, pos, pos, scale, scale, 1, 0, 0, 1)
  end)
end

-- JosephMod.Debug = true
-- --JosephMod.Render = "hi"

-- if JosephMod.Debug == true then
--   function JosephMod:Debug()
--     local enchantedCards = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "EnchantedCards", Isaac.GetPlayer())
--     Isaac.RenderText(tostring(enchantedCards[0]), 50, 40, 1, 1, 1, 1)
--     Isaac.RenderText(tostring(enchantedCards[1]), 50, 60, 1, 1, 1, 1)
--       Isaac.RenderText(tostring(enchantedCards[2]), 50, 80, 1, 1, 1, 1)
--       Isaac.RenderText(tostring(enchantedCards[3]), 50, 100, 1, 1, 1, 1)
--       Isaac.RenderText(tostring(enchantedCards[4]), 50, 120, 1, 1, 1, 1)
--       Isaac.RenderText(tostring(enchantedCards[5]), 50, 140, 1, 1, 1, 1)
--       Isaac.RenderText(tostring(enchantedCards[6]), 50, 160, 1, 1, 1, 1)

--   end
-- JosephMod:AddCallback(ModCallbacks.MC_POST_RENDER, JosephMod.Debug)

-- end
