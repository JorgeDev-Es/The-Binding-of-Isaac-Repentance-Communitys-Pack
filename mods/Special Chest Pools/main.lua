local mod = RegisterMod("Special Chest Pools", 1)
local game = Game()
local Vzero = Vector(0,0)
local localtables = {}
if not SpecialChests then
SpecialChests = {}
end


localtables.ChestPedestals = {}
localtables.ChestPedestals[PickupVariant.PICKUP_SPIKEDCHEST] = "gfx/items/spikedchest_itemaltar.png"
localtables.ChestPedestals[PickupVariant.PICKUP_HAUNTEDCHEST] = "gfx/items/hauntedchest_itemaltar.png"


------------ Save Data stuff
SpecialChests.SaveData = SpecialChests.SaveData or {}
local JSON = include("json")

function mod:LoadSaveData(save)
  if mod:HasData() and save then
    SpecialChests.SaveData = JSON.decode(mod:LoadData())
  
  elseif SpecialChests.SaveData == nil then
    SpecialChests.SaveData = {}
 end

end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,mod.LoadSaveData)


function mod:SaveDataOnExit ()
  mod:SaveData(JSON.encode(SpecialChests.SaveData))
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,mod.SaveDataOnExit)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END,mod.SaveDataOnExit)






---- Custom Chest Pools (items)

 
SpecialChests.ChestItemPools = SpecialChests.ChestItemPools or {}
SpecialChests.ChestItemPools[PickupVariant.PICKUP_SPIKEDCHEST] = SpecialChests.ChestItemPools[PickupVariant.PICKUP_SPIKEDCHEST] or {}
SpecialChests.ChestItemPools[PickupVariant.PICKUP_HAUNTEDCHEST] = SpecialChests.ChestItemPools[PickupVariant.PICKUP_HAUNTEDCHEST] or {}


localtables.ChestItemPools  = {}

localtables.ChestItemPools[PickupVariant.PICKUP_SPIKEDCHEST] = { 
    --insert your own items here. For modded items, use Isaac.GetItemIdByName("name")
		Isaac.GetItemIdByName("Blue Streak"),
		Isaac.GetItemIdByName("Bone Hurting Juice"),
		Isaac.GetItemIdByName("Divine Vengeance"),
		Isaac.GetItemIdByName("Revenge!"),
		Isaac.GetItemIdByName("Temper Tantrum"),
		Isaac.GetItemIdByName("White Robe"),
		Isaac.GetItemIdByName("Blank"),
		Isaac.GetItemIdByName("Witch Wand"),
		Isaac.GetItemIdByName("Gold Rope"),
		Isaac.GetItemIdByName("Haunted Rose"),
		Isaac.GetItemIdByName("Whirling Leech"),
		Isaac.GetItemIdByName("Reverse of the Tower"),
		Isaac.GetItemIdByName("Inner Demons"),
		Isaac.GetItemIdByName("Crystal Apple"),
		Isaac.GetItemIdByName("Voodoo Baby"),
		Isaac.GetItemIdByName("Cetus"),
		Isaac.GetItemIdByName("Crazy Jackpot"),
		Isaac.GetItemIdByName("Spare Ribs"),
		Isaac.GetItemIdByName("Lil' Lamb"),
		Isaac.GetItemIdByName("Pet Peeve"),
		Isaac.GetItemIdByName("Lawn Darts"),
		Isaac.GetItemIdByName("Pinhead"),
		Isaac.GetItemIdByName("Meat Grinder"),
		Isaac.GetItemIdByName("Axolotl"),
		Isaac.GetItemIdByName("Azazel's Horn"),
		Isaac.GetItemIdByName("Dead Lung"),
		Isaac.GetItemIdByName("Heart Shaped Balloon"),
		Isaac.GetItemIdByName("Joyful"),
		Isaac.GetItemIdByName("Milk of Baphomet"),
        40, -- Kamikaze
        83, -- The Nail
        117, -- Dead Crown
        126, -- Razor
        135, -- IV Bag
        148, -- Infestation
        156, -- Habit
        157, -- Bloody Lust
        186, -- Blood Rights
        204, -- Fanny Pack
        205, -- Sharp Plug
        214, -- Anemic
        225, -- Gimpy
        264, -- Smart Fly
        359, -- 8 Inch Nails
        371, -- Curse of the Tower 
        391, -- Betrayal
        408, -- Atheme
        412, -- Cambion Conception
        433, -- My Shadow
        448, -- Shard of Glass
        452, -- Vericous Veins
        486, -- Dull Razor
        538, -- Marbles
        539, -- Mystery Egg
        543, -- Hallowed Ground
        569, -- Blood Oath
        577, -- Damocles
        610, -- Bird Cage
        663, -- Tooth and Nail
        635, -- Stiches
        675, -- Cracked Orb
        677, -- Astral Projection
        692, -- Sanguine Bond
        702, -- Vengeful Spirit
        724 -- Hypercoagulation
}


localtables.ChestItemPools[PickupVariant.PICKUP_HAUNTEDCHEST] = { 
	Isaac.GetItemIdByName("Time Gal"),
	Isaac.GetItemIdByName("Sinister Chalk"),
	Isaac.GetItemIdByName("Cloaked Baby"),
	Isaac.GetItemIdByName("Soul Bond"),
	Isaac.GetItemIdByName("Enraged Soul"),
	Isaac.GetItemIdByName("Subconscious"),
	Isaac.GetItemIdByName("Old Urn"),
	Isaac.GetItemIdByName("Haunted Rose"),
	Isaac.GetItemIdByName("Lil Heretic"),
	Isaac.GetItemIdByName("Astropulvis"),
	Isaac.GetItemIdByName("White Pepper"),
	Isaac.GetItemIdByName("Lil' Minx"),
	Isaac.GetItemIdByName("Page of Virtues"),
	Isaac.GetItemIdByName("Clutch's Curse"),
	Isaac.GetItemIdByName("Cootie"),
	115, -- Ouija Board
	159, -- Spirit of the Night
	163, -- Ghost Baby
	277, -- Lil Haunt
	495, -- Ghost Pepper
	530, -- Death's List
	545, -- Book of the Dead
	554, -- 2Spooky
	566, -- Dream Catcher
	612, -- Lost Soul
	628, -- Death Certificate
	634, -- Purgatory
	653, -- Vade Retro
	674, -- Spirit Shackles
	677, -- Astral Projection
	684, -- Hungry Soul
	701, -- Isaac's Tomb
	702, -- Vengeful Spirit
	727 -- Ghost Bombs
}


---- Custom Chest Pools (trinkets)

SpecialChests.ChestTrinketPools = SpecialChests.ChestTrinketPools or {}
SpecialChests.ChestTrinketPools[PickupVariant.PICKUP_SPIKEDCHEST] = SpecialChests.ChestTrinketPools[PickupVariant.PICKUP_SPIKEDCHEST] or {}
SpecialChests.ChestTrinketPools[PickupVariant.PICKUP_HAUNTEDCHEST] = SpecialChests.ChestTrinketPools[PickupVariant.PICKUP_HAUNTEDCHEST] or {}


localtables.ChestTrinketPools  = {}


localtables.ChestTrinketPools[PickupVariant.PICKUP_SPIKEDCHEST] = { 
    --insert your own items here. For modded items, use Isaac.GetItemIdByName("name")
	Isaac.GetTrinketIdByName("Apple Core"),
	Isaac.GetTrinketIdByName("Krampus Horn"),
	Isaac.GetTrinketIdByName("Uncertainty"),
	Isaac.GetTrinketIdByName("Judas' Kiss"),
	Isaac.GetTrinketIdByName("Key Knife"),
	Isaac.GetTrinketIdByName("Child's Soul"),
	Isaac.GetTrinketIdByName("Life Savings"),
	Isaac.GetTrinketIdByName("Swallowed M90"),
	Isaac.GetTrinketIdByName("Autopsy Kit"),
	Isaac.GetTrinketIdByName("Sharp Penny"),
	Isaac.GetTrinketIdByName("Frog Puppet"),
	Isaac.GetTrinketIdByName("Cursed Urn"),
	Isaac.GetTrinketIdByName("Rose Thorns"),
	Isaac.GetTrinketIdByName("Thick Skin"),
	Isaac.GetTrinketIdByName("Girl Pill"),
	Isaac.GetTrinketIdByName("Occam's Razor"),
    TrinketType.TRINKET_BLIND_RAGE,
	TrinketType.TRINKET_PANIC_BUTTON,
	TrinketType.TRINKET_TORN_CARD,
	TrinketType.TRINKET_TORN_POCKET,
	TrinketType.TRINKET_SWALLOWED_M80,
	TrinketType.TRINKET_SWALLOWED_PENNY,
	TrinketType.TRINKET_CARTRIDGE,
	TrinketType.TRINKET_MONKEY_PAW,
	TrinketType.TRINKET_BROKEN_ANKH,
	TrinketType.TRINKET_FISH_HEAD,
	TrinketType.TRINKET_UMBILICAL_CORD,
	TrinketType.TRINKET_RED_PATCH,
	TrinketType.TRINKET_CURSED_SKULL,
	TrinketType.TRINKET_MISSING_PAGE,
	TrinketType.TRINKET_CRACKED_DICE,
	TrinketType.TRINKET_TONSIL,
	TrinketType.TRINKET_WISH_BONE,
	TrinketType.TRINKET_BAG_LUNCH,
	TrinketType.TRINKET_CROW_HEART,
	TrinketType.TRINKET_WALNUT,
	TrinketType.TRINKET_FINGER_BONE
}

localtables.ChestTrinketPools[PickupVariant.PICKUP_HAUNTEDCHEST] = { 
    --insert your own items here. For modded items, use Isaac.GetItemIdByName("name")
	Isaac.GetTrinketIdByName("Bishop's Cloth"),
	Isaac.GetTrinketIdByName("Dreamcatcher"),
	Isaac.GetTrinketIdByName("Child's Soul"),
	Isaac.GetTrinketIdByName("Shattered Soul"),
	Isaac.GetTrinketIdByName("The Right Hand"),
	Isaac.GetTrinketIdByName("White Candle"),
    TrinketType.TRINKET_MISSING_PAGE,
	TrinketType.TRINKET_YOUR_SOUL,
	TrinketType.TRINKET_FOUND_SOUL,
	--TrinketType.TRINKET_ISAACS_HEAD,
	TrinketType.TRINKET_SOUL,
	TrinketType.TRINKET_BAT_WING,
	TrinketType.TRINKET_WOODEN_CROSS,
	TrinketType.TRINKET_KARMA
}


----

function SpecialChests.AddItemToPool (tabl,item,weight)
  SpecialChests.ChestItemPools = SpecialChests.ChestItemPools or {}
  weight = weight or 1
  if SpecialChests.ChestItemPools[tabl] then
    for i = 1,weight do
      table.insert(SpecialChests.ChestItemPools[tabl],item)
    end
  end
end

function SpecialChests.AddTrinketToPool (tabl,item,weight)
  SpecialChests.ChestItemPools = SpecialChests.ChestItemPools or {}
  weight = weight or 1
  if SpecialChests.ChestItemPools[tabl] then
    for i = 1,weight do
      table.insert(SpecialChests.ChestTrinketPools[tabl],item)
    end
  end
end

if not SpecialChests.hasLoaded then
  SpecialChests.hasloaded = true
  for i,v in pairs(localtables.ChestItemPools) do
    if type(v) =="table" then
      for i2,v2 in pairs(v) do
        if v2 ~= -1 then
          SpecialChests.AddItemToPool(i,v2,1)
        end
      end
    end
  end



  for i,v in pairs(localtables.ChestTrinketPools) do
    if type(v) =="table" then
      for i2,v2 in pairs(v) do
        if v2 ~= -1 then
          SpecialChests.AddTrinketToPool(i,v2,1)
        end
      end
    end
  end
end

SpecialChests.SaveData.TempChestItemPools = SpecialChests.SaveData.TempChestItemPools or  SpecialChests.ChestItemPools
SpecialChests.SaveData.TempChestTrinketPools = SpecialChests.SaveData.TempChestTrinketPools or SpecialChests.ChestTrinketPools

local function removefromtable (table,index)
  index = index or #table
  local newtable = {}
  local indextype = type(index) == "number"
  for i,v in pairs(table) do
    if indextype and ( type(i)=="number" and i > index ) then
      newtable[i-1] = v
    elseif i ~= index then
      newtable[i] = v
    end
  end
    return newtable
  
end


function SpecialChests.PickItemFromPool(rng,pooltype,poolvariant,subtract)
  rng = rng or RNG()
  pooltype = pooltype or 0
  poolvariant = poolvariant or PickupVariant.PICKUP_SPIKEDCHEST
  local pool1 = SpecialChests.SaveData.TempChestItemPools
  local pool2
  local poolpath = "TempChestItemPools"
  if pooltype == 1 then
    pool1 = SpecialChests.SaveData.TempChestTrinketPools
    poolpath = "TempChestTrinketPools"
  end
  if pool1[poolvariant] then
    pool2 = pool1[poolvariant]
  else
    return 0
  end
  local poolsize = #pool2
  if poolsize > 0 then
    local resulti = rng:RandomInt(poolsize) + 1
    local result = pool2[resulti]
    if subtract then
      
      SpecialChests.SaveData[poolpath][poolvariant] = removefromtable(pool2,i)
    end
    
    return result
  end
  return 0
  
  
end

local function copytable (t1)
  local result = {}
  for i,v in pairs(t1) do
    result[i] = v
  end
  return result
end

function SpecialChests.HasChaos()
  for i = 0,game:GetNumPlayers()-1 do
    local player = Isaac.GetPlayer(i)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHAOS) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CHAOS) then
      return true
    end
  end
  
end

-----

function mod:ResetPoolsOnNewRun (save)
  if not save then
    SpecialChests.SaveData.TempChestItemPools = copytable(SpecialChests.ChestItemPools)
    SpecialChests.SaveData.TempChestTrinketPools = copytable(SpecialChests.ChestTrinketPools)
  end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,mod.ResetPoolsOnNewRun)

function mod:OnChestOpen (pickup)
    if pickup:GetSprite():IsPlaying("Open") and pickup:GetSprite():GetFrame() == 1 then
        local rng = RNG()
        if pickup and pickup.DropSeed then
          rng:SetSeed(pickup.DropSeed,69)
        end
        local outcome = rng:RandomInt(100)
        if outcome <= 15 then -- replace number with the percentage chance for the item dropping.
          --local poolsize = #SpecialChests.ChestItemPools[pickup.Variant]
          local item = 0
          if not SpecialChests.HasChaos() then
            item = SpecialChests.PickItemFromPool(rng,0,pickup.Variant,true)
          end
          local pedestal = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,item, pickup.Position,Vzero, pickup)
          pedestal:GetSprite():ReplaceSpritesheet(5,tostring(localtables.ChestPedestals[pickup.Variant])) 
          pedestal:GetSprite():LoadGraphics()
          pickup:Remove()
        elseif outcome < 30 then
          local poolsize = #SpecialChests.ChestTrinketPools[pickup.Variant]
          local item = SpecialChests.PickItemFromPool(rng,1,pickup.Variant,true)
          local trinket = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,item,pickup.Position,RandomVector() * 5,pickup)
          --local newchest = Isaac.Spawn(pickup.Type,pickup.Variant,2,pickup.Position,pickup.Velocity,pickup.SpawnerEntity)
          --pickup:Remove()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.OnChestOpen, PickupVariant.PICKUP_SPIKEDCHEST)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.OnChestOpen, PickupVariant.PICKUP_HAUNTEDCHEST)


