local Achievements = {}

PlayerType.PLAYER_CADAVER = Isaac.GetPlayerTypeByName("Cadaver")
PlayerType.PLAYER_TAINTED_CADAVER = Isaac.GetPlayerTypeByName("Cadaver", true)

CadaverAchievements = {
  Isaac = false,
  BlueBaby = false,
  Satan = false,
  Lamb = false,
  Hush = false,
  MegaSatan = false,
  Delirium = false,
  Mother = false,
  Beast = false,
  Vestments = false,
  Probiotics = false,
  SoulOfCadaver = false,
  RottenChest = false,
  RottenFlesh = false,
  ForbiddenFruit = false,
  GoldenSoul = false,
  Isaac_t = false,
  BlueBaby_t = false,
  Satan_t = false,
  Lamb_t = false,
  Hush_t = false,
  MegaSatan_t = false,
  Delirium_t = false,
  Mother_t = false,
  Beast_t = false,
  Halitosis = false,
  TechDrones = false,
  MorgueKey = false,
  HydrochloricAcid = false
}

local MAX_ACHIEVEMENT_FRAMES = 240

local achievementFrames = 0
local achievementSprite = Sprite()
achievementSprite:Load("gfx/ui/achievement/customAchievements.anm2", true)

function Achievements.LoadData(table)
  if table == nil then
    Achievements.Reset()
  else
    CadaverAchievements = table
  end
end

function Achievements.UnlockAll()
  for k, v in pairs(CadaverAchievements) do
    CadaverAchievements[k] = true
  end
end

function Achievements.ReadOut()
  local unlocks = ""
  for k, v in pairs(CadaverAchievements) do
    if CadaverAchievements[k] then
      unlocks = unlocks .. k .. " "
    end
  end
  print(unlocks)
end

function Achievements.Reset()
  for k, v in pairs(CadaverAchievements) do
    CadaverAchievements[k] = false
  end
end

function Achievements.SaveData()
  return CadaverAchievements
end

function Achievements.SetupItemPools()
  if not CadaverAchievements.Vestments then
    Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_VESTMENTS)
  end
  if not CadaverAchievements.ForbiddenFruit then
    Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_FORBIDDEN_FRUIT)
  end
  if not CadaverAchievements.RottenFlesh then
    Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_ROTTEN_FLESH)
  end
  if not CadaverAchievements.Halitosis then
    Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_HALITOSIS)
  end
  if not CadaverAchievements.TechDrones then
    Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_TECH_DRONES)
  end
  if not CadaverAchievements.MorgueKey then
    Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_MORGUE_KEY)
  end
  if not CadaverAchievements.HydrochloricAcid then
    Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_HYDROCHLORIC_ACID)
  end
  if not CadaverAchievements.Probiotics then
    Game():GetItemPool():RemoveTrinket(TrinketType.TRINKET_PROBIOTICS)
  end
end

function Achievements.DisplayAchievement()
  achievementSprite:LoadGraphics()
  achievementSprite:Play("Appear", true)
  achievementFrames = MAX_ACHIEVEMENT_FRAMES
end

function Achievements.TryUnlock()
  if CadaverAchievements.Isaac and CadaverAchievements.BlueBaby and not CadaverAchievements.Vestments then
    CadaverAchievements.Vestments = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_vestments.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Satan and CadaverAchievements.Lamb and not CadaverAchievements.Probiotics then
    CadaverAchievements.Probiotics = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_probiotics.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Hush and not CadaverAchievements.SoulOfCadaver then
    CadaverAchievements.SoulOfCadaver = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_soul_of_cadaver.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.MegaSatan and not CadaverAchievements.RottenChest then
    CadaverAchievements.RottenChest = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_rotten_chest.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Delirium and not CadaverAchievements.RottenFlesh then
    CadaverAchievements.RottenFlesh = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_rotten_flesh.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Mother and not CadaverAchievements.ForbiddenFruit then
    CadaverAchievements.ForbiddenFruit = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_forbidden_fruit.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Beast and not CadaverAchievements.GoldenSoul then
    CadaverAchievements.GoldenSoul = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_golden_soul.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Isaac_t and CadaverAchievements.BlueBaby_t and CadaverAchievements.Satan_t and CadaverAchievements.Lamb_t and CadaverAchievements.MegaSatan_t and not CadaverAchievements.MorgueKey then
    CadaverAchievements.MorgueKey = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_morgue_key.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Hush_t and CadaverAchievements.Delirium_t and not CadaverAchievements.Halitosis then
    CadaverAchievements.Halitosis = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_halitosis.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Beast_t and not CadaverAchievements.HydrochloricAcid then
    CadaverAchievements.HydrochloricAcid = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_hydrochloric_acid.png")
    Achievements.DisplayAchievement()
  elseif CadaverAchievements.Mother_t and not CadaverAchievements.TechDrones then
    CadaverAchievements.TechDrones = true
    achievementSprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_tech_drones.png")
    Achievements.DisplayAchievement()
  end
end

function Achievements:IsaacAchievement(npc)
  local player = Isaac.GetPlayer(0)
  local stage = Game():GetLevel():GetStage()
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER then
    -- Isaac, only in the Cathedral
    if npc.Variant == 0 and stage == LevelStage.STAGE5 and not CadaverAchievements.Isaac then
      CadaverAchievements.Isaac = true
      Achievements.TryUnlock()
    end
    
    -- Blue Baby, only in the Chest
    if npc.Variant == 1 and stage == LevelStage.STAGE6 and not CadaverAchievements.BlueBaby then
      CadaverAchievements.BlueBaby = true
      Achievements.TryUnlock()
    end
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER then
    if npc.Variant == 0 and stage == LevelStage.STAGE5 and not CadaverAchievements.Isaac_t then
      CadaverAchievements.Isaac_t = true
      Achievements.TryUnlock()
    end
    
    if npc.Variant == 1 and stage == LevelStage.STAGE6 and not CadaverAchievements.BlueBaby_t then
      CadaverAchievements.BlueBaby_t = true
      Achievements.TryUnlock()
    end
  end
end

function Achievements:SatanAchievement(npc)
  local stage = Game():GetLevel():GetStage()
  local player = Isaac.GetPlayer(0)
  -- Satan, only in Sheol
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER and stage == LevelStage.STAGE5 and not CadaverAchievements.Satan then
    CadaverAchievements.Satan = true
    Achievements.TryUnlock()
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER and stage == LevelStage.STAGE5 and not CadaverAchievements.Satan_t then
    CadaverAchievements.Satan_t = true
    Achievements.TryUnlock()
  end
end

function Achievements:LambAchievement(npc)
  local stage = Game():GetLevel():GetStage()
  local player = Isaac.GetPlayer(0)
  -- Lamb, only in Dark Room
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER and stage == LevelStage.STAGE6 and not CadaverAchievements.Lamb then
    CadaverAchievements.Lamb = true
    Achievements.TryUnlock()
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER and stage == LevelStage.STAGE6 and not CadaverAchievements.Lamb_t then
    CadaverAchievements.Lamb_t = true
    Achievements.TryUnlock()
  end
end

function Achievements:HushAchievement(npc)
  local player = Isaac.GetPlayer(0)
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER and not CadaverAchievements.Hush then
    CadaverAchievements.Hush = true
    Achievements.TryUnlock()
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER and not CadaverAchievements.Hush_t then
    CadaverAchievements.Hush_t = true
    Achievements.TryUnlock()
  end
end

function Achievements:MegaSatanAchievement(npc)
  local player = Isaac.GetPlayer(0)
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER and not CadaverAchievements.MegaSatan then
    CadaverAchievements.MegaSatan = true
    Achievements.TryUnlock()
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER and not CadaverAchievements.MegaSatan_t then
    CadaverAchievements.MegaSatan_t = true
    Achievements.TryUnlock()
  end
end

function Achievements:DeliriumAchievement(npc)
  local player = Isaac.GetPlayer(0)
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER and not CadaverAchievements.Delirium  then
    CadaverAchievements.Delirium = true
    Achievements.TryUnlock()
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER and not CadaverAchievements.Delirium_t then
    CadaverAchievements.Delirium_t = true
    Achievements.TryUnlock()
  end
end

function Achievements:MotherAchievement(npc)
  local player = Isaac.GetPlayer(0)
  -- Mother's body is Variant 10
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER and npc.Variant == 10 and not CadaverAchievements.Mother then
    CadaverAchievements.Mother = true
    Achievements.TryUnlock()
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER and npc.Variant == 10 and not CadaverAchievements.Mother_t then
    CadaverAchievements.Mother_t = true
    Achievements.TryUnlock()
  end
end

function Achievements:BeastAchievement(npc)
  local player = Isaac.GetPlayer(0)
  -- The Beast's final form is Variant 0
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER and npc.Variant == 0 and not CadaverAchievements.Beast then
    CadaverAchievements.Beast = true
    Achievements.TryUnlock()
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER and npc.Variant == 0 and not CadaverAchievements.Beast_t then
    CadaverAchievements.Beast_t = true
    Achievements.TryUnlock()
  end
end

function Achievements.RegisterCallbacks(mod)
  mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.IsaacAchievement, EntityType.ENTITY_ISAAC)
  mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.SatanAchievement, EntityType.ENTITY_SATAN)
  mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.LambAchievement, EntityType.ENTITY_THE_LAMB)
  mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.HushAchievement, EntityType.ENTITY_HUSH)
  mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.MotherAchievement, EntityType.ENTITY_MOTHER)
  mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.BeastAchievement, EntityType.ENTITY_BEAST)
  mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.DeliriumAchievement, EntityType.ENTITY_DELIRIUM)
  mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Achievements.MegaSatanAchievement, EntityType.ENTITY_MEGA_SATAN_2)
end

function Achievements.DisplaySprites()
  if achievementFrames > 0 or achievementSprite:IsPlaying("Disappear") then
    achievementSprite:Render(Isaac.WorldToRenderPosition(Vector(320, 300)))
    achievementFrames = achievementFrames - 1
    if achievementFrames == 0 then
      achievementSprite:Play("Disappear")
    end
  end
end

function Achievements.UpdateSprites()
  achievementSprite:Update()
end

return Achievements
