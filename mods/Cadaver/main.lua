local Achievements = include("Achievements")
local RottenFlesh = include("RottenFlesh")
local TechDrones = include("TechDrones")
local HydrochloricAcid = include("HydrochloricAcid")
local Vestments = include("Vestments")
local ForbiddenFruit = include("ForbiddenFruit")
local Probiotics = include("Probiotics")
local RottenIsaac = include("RottenIsaac")
local Halitosis = include("Halitosis")
local TaintedCadaver = include("TaintedCadaver")
local MorgueKey = include("MorgueKey")
local CustomSouls = include("CustomSouls")  
local RottenChest = include("RottenChest")
local ItemPools = include("ItemPools")
local json = include("json")
local Cadaver = RegisterMod("Cadaver", 1)

Achievements.RegisterCallbacks(Cadaver)

CadaverRNG = RNG() -- Used for general RNG, just seeded at the start with the run seed
CadaverItemRNG = RNG() -- Used for seeded RNG, never use without setting the seed right beforehand

-- # POST GAME START #
function Cadaver:StartRun(isContinued)
  CadaverRNG:SetSeed(Game():GetSeeds():GetStartSeed(), 0)
  
  if Cadaver:HasData() then
    local table = json.decode(Cadaver:LoadData())
    ForbiddenFruit.LoadData(table.ForbiddenFruit)
    Vestments.LoadData(table.Vestments)
    Achievements.LoadData(table.CadaverAchievements)
    TaintedCadaver.LoadData(table.TaintedCadaver)
    MorgueKey.LoadData(table.MorgueKey)
  else
    Achievements.Reset()
  end
  
  Vestments.Reset(isContinued)
  ForbiddenFruit.Reset(isContinued)
  TaintedCadaver.Reset(isContinued)
  MorgueKey.Reset(isContinued)
  Probiotics.Reset(isContinued)

  Achievements.SetupItemPools()
  
  -- Evaluate stats after everything has been setup
  local player = Isaac.GetPlayer(0)
  player:AddCacheFlags(CacheFlag.CACHE_ALL)
  player:EvaluateItems()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Cadaver.StartRun)

-- # POST NORMAL CHEST CREATION #
function Cadaver:ModifyPickups(pickup)
  RottenChest.ReplaceChests(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyPickups, PickupVariant.PICKUP_CHEST)

-- # POST TAROT CARD CREATION #
function Cadaver:ModifyTarotCards(pickup)
  CustomSouls.RemoveLockedSouls(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyTarotCards, PickupVariant.PICKUP_TAROTCARD)

-- # POST HEART CREATION #
function Cadaver:ModifyHearts(pickup)
  RottenIsaac.ReplaceHearts(pickup)
  TaintedCadaver.ReplaceHearts(pickup)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Cadaver.ModifyHearts, PickupVariant.PICKUP_HEART)

-- # EFFECT UPDATES (Every frame) #
function Cadaver:EffectUpdate(player)
  Vestments.UpdateVestmentsEffect(player)
  ForbiddenFruit.UpdateForbiddenFruitEffect(player)
  Probiotics.UpdateProbioticsEffect(player)
  Halitosis.UpdateHalitosisEffect(player)
  MorgueKey.UpdateMorgueKeyEffect(player)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Cadaver.EffectUpdate)

-- # CADAVER-SPECIFIC EFFECT UPDATES #
function Cadaver:CadaverEffectUpdate(player)
  RottenIsaac.ConvertHealth(player)
  RottenIsaac.Birthright(player)
  RottenIsaac.ManageCostumes(player)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Cadaver.CadaverEffectUpdate, PlayerType.PLAYER_CADAVER)

-- # TAINTED CADAVER EFFECT UPDATES #
function Cadaver:TaintedCadaverEffectUpdate(player)
  TaintedCadaver.ConvertHealth(player)
  TaintedCadaver.ManageArmy(player)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Cadaver.TaintedCadaverEffectUpdate, PlayerType.PLAYER_TAINTED_CADAVER)

-- # TECH DRONES UPDATE #
function Cadaver:TechDroneUpdate(familiar)
  TechDrones.Update(familiar)
end
Cadaver:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Cadaver.TechDroneUpdate, FamiliarVariant.TECH_DRONES)

-- # ENTITY TAKES DAMAGE #
function Cadaver:TaintedCadaverArmyDamage(entity, amount, flags, source, countdownFrames)
  if not TaintedCadaver.SoldierDamage(entity, amount, flags, source, countdownFrames) then return false end
  if not TechDrones.LaserDamage(entity, amount, flags, source, countdownFrames) then return false end
  
  HydrochloricAcid.ItemDamage(entity, amount, flags, source, countdownFrames)
  return nil
end
Cadaver:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Cadaver.TaintedCadaverArmyDamage)

-- # POST LASER INIT #
function Cadaver:PostLaserInit(laser)
  TaintedCadaver:InitSoldierLasers(laser)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_LASER_INIT, Cadaver.PostLaserInit)

-- # POST PLAYER INIT #
function Cadaver:PlayerInit(player)
  if player:GetPlayerType() == PlayerType.PLAYER_CADAVER then
    RottenIsaac.AddCostume(player)
  end
  
  if player:GetPlayerType() == PlayerType.PLAYER_TAINTED_CADAVER then
    TaintedCadaver.PlayerInit(player)
  end
end
Cadaver:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Cadaver.PlayerInit)

-- # STAT UPDATES #
function Cadaver:ModifyStats(player, cacheFlag)
  Probiotics.ModifyStats(player, cacheFlag)
  ForbiddenFruit.ModifyStats(player, cacheFlag)
  RottenFlesh.ModifyStats(player, cacheFlag)
  RottenIsaac.ModifyStats(player, cacheFlag)
  TaintedCadaver.ModifyStats(player, cacheFlag)
  TechDrones.UpdateCache(player, cacheFlag)
  Halitosis.ModifyStats(player, cacheFlag)
end
Cadaver:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Cadaver.ModifyStats)

-- # ROOM ENTER #
function Cadaver:EnterRoom()
  Vestments.SwapVestmentsItem()
  RottenChest.RemoveOpenChests()
  MorgueKey.InitRoom()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Cadaver.EnterRoom)

-- # RENDER NPC #
function Cadaver:NpcRender(npc, renderOffset)
  HydrochloricAcid.Render(npc, renderOffset)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, Cadaver.NpcRender)

-- # UPDATE NPC #
function Cadaver:NpcUpdate(npc)
  HydrochloricAcid.Update(npc)
end
Cadaver:AddCallback(ModCallbacks.MC_NPC_UPDATE, Cadaver.NpcUpdate)

-- # RENDER #
function Cadaver:Render()
  Achievements.DisplaySprites()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_RENDER, Cadaver.Render)

-- # UPDATE #
function Cadaver:Update()
  Achievements.UpdateSprites()
end
Cadaver:AddCallback(ModCallbacks.MC_POST_UPDATE, Cadaver.Update)

-- # GAME EXIT #
function Cadaver:Exit(shouldSave)
  Vestments.Exit()
  TaintedCadaver.Exit()
  local saveData = {
    ForbiddenFruit = ForbiddenFruit.SaveData(),
    Vestments = Vestments.SaveData(),
    CadaverAchievements = Achievements.SaveData(),
    TaintedCadaver = TaintedCadaver.SaveData(),
    MorgueKey = MorgueKey.SaveData()
  }
  Cadaver:SaveData(json.encode(saveData))
end
Cadaver:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Cadaver.Exit)

-- # POST GAME END #
function Cadaver:PostGameEnd(isGameOver)
  MorgueKey.SaveItems(isGameOver)
end
Cadaver:AddCallback(ModCallbacks.MC_POST_GAME_END, Cadaver.PostGameEnd)

-- ###### SPECIFIC ITEMS ######

-- # GOLDEN SOUL USAGE #
function Cadaver:UseGoldenSoul(card, player, flags)
  CustomSouls.UseGoldenSoul(player)
end
Cadaver:AddCallback(ModCallbacks.MC_USE_CARD, Cadaver.UseGoldenSoul, Card.CARD_SOUL_GOLDEN)

-- # CADAVER SOUL USAGE #
function Cadaver:UseCadaverSoul(card, player, flags)
  CustomSouls.UseCadaverSoul(player)
end
Cadaver:AddCallback(ModCallbacks.MC_USE_CARD, Cadaver.UseCadaverSoul, Card.CARD_SOUL_CADAVER)

-- # FORBIDDEN FRUIT USAGE #
function Cadaver:UseForbiddenFruit()
  return ForbiddenFruit.Use()
end
Cadaver:AddCallback(ModCallbacks.MC_USE_ITEM, Cadaver.UseForbiddenFruit, CollectibleType.COLLECTIBLE_FORBIDDEN_FRUIT)

-- # HALITOSIS USAGE #
function Cadaver:UseHalitosis(collectibleType, RNG, player, useFlags, slot)
  Halitosis.Use(collectibleType, RNG, player, useFlags, slot)
  TaintedCadaver.KillArmy()
end
Cadaver:AddCallback(ModCallbacks.MC_USE_ITEM, Cadaver.UseHalitosis, CollectibleType.COLLECTIBLE_HALITOSIS)

-- # MORGUE KEY USAGE #
function Cadaver:UseMorgueKey(collectibleType, RNG, player, useFlags, slot)
  return MorgueKey.Use(collectibleType, RNG, player, useFlags, slot)
end
Cadaver:AddCallback(ModCallbacks.MC_USE_ITEM, Cadaver.UseMorgueKey, CollectibleType.COLLECTIBLE_MORGUE_KEY)

-- # ROTTEN CHEST COLLISION #
function Cadaver:RottenChestCollision(pickup, collider, low)
  RottenChest.OpenChest(pickup, collider, low)
end
Cadaver:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Cadaver.RottenChestCollision, PickupVariant.PICKUP_ROTTENCHEST)

-- # DEBUG COMMANDS #
function Cadaver:OnCommand(command, args)
  if command == "cd_reset" then
    Achievements.Reset()
  elseif command == "cd_unlockall" then
    Achievements.UnlockAll()
  elseif command == "cd_listunlock" then
    Achievements.ReadOut()
  elseif command == "cd_army" then
    TaintedCadaver.GetArmyStats()
  elseif command == "cd_entities" then
    local entities = Isaac:GetRoomEntities()
    for i, entity in ipairs(entities) do
      Isaac.DebugString("Type " .. entity.Type .. " Variant " .. entity.Variant .. " SubType " .. entity.SubType)
    end
  end
end
Cadaver:AddCallback(ModCallbacks.MC_EXECUTE_CMD, Cadaver.OnCommand)

-- EID Descriptions
if EID then
  EID:addCollectible(CollectibleType.COLLECTIBLE_FORBIDDEN_FRUIT, "!!! SINGLE USE#↑ 3x Damage up#↑ 2x Tears up#You take damage every 4 seconds#!!! This CANNOT be cured, even by resurrection, and WILL kill you!")
  EID:addCollectible(CollectibleType.COLLECTIBLE_ROTTEN_FLESH, "↑ +2 Damage up#Fixes tear rate at 1.5#All tear rate modifiers are converted into an equivalent damage multiplier")
  EID:addCollectible(CollectibleType.COLLECTIBLE_VESTMENTS, "Grants a random Angel Room item effect each room")
  EID:addCollectible(CollectibleType.COLLECTIBLE_HALITOSIS, "Fires a barrage of large breath tears that pierce and inflict Poison and Fear")
  EID:addCollectible(CollectibleType.COLLECTIBLE_MORGUE_KEY, "!!! SINGLE USE#Teleports you to the Morgue, a special room#It contains 4-5 items from the last successful run on pedestals#Only one can be taken")
  EID:addCollectible(CollectibleType.COLLECTIBLE_TECH_DRONES, "Grants two robot familiars that orbit far away from you, opposite each other#When firing tears, a Technology laser connects the two")
  EID:addCollectible(CollectibleType.COLLECTIBLE_HYDROCHLORIC_ACID, "Hitting an enemy 5 times causes them to take an additional +3 flat damage per hit")
  EID:addTrinket(TrinketType.TRINKET_PROBIOTICS, "If you have a Rotten Heart:#↑ +1 Damage up#↑ +0.5 Tears up#↑ +0.25 Speed up#↑ +1 Luck up")
  EID:addCard(Card.CARD_SOUL_CADAVER, "Spawns:#8 friendly Small Maggots#8 friendly Small Leeches#1 Bone Heart#2 Rotten Hearts")
  EID:addCard(Card.CARD_SOUL_GOLDEN, "Random soul stone effect (except Soul of Lazarus)#60% chance to spawn itself again")
  EID:addBirthright(PlayerType.PLAYER_CADAVER, "Blue flies are converted to random locusts", "Cadaver")
  EID:addBirthright(PlayerType.PLAYER_TAINTED_CADAVER, "Dead familiars respawn after 3 seconds.", "Tainted Cadaver")
end
