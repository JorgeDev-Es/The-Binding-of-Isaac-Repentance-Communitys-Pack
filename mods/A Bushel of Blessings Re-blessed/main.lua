--Mod registered
BlessingsBushelReblessed = RegisterMod("A Bushel of Blessings Re-Blessed", 1)
local mod = BlessingsBushelReblessed

local json = require("json")


include("scripts/CollectibleTypes")
include("scripts/EID")
include("scripts/modConfig")
local blessings = require("scripts/blessingEffects")
local revenge = require("scripts/revengeEffects")
local persistent

	local isaacBlessingId = Isaac.GetItemIdByName("Isaac's Blessing")
	local maggyBlessingId = Isaac.GetItemIdByName("Maggy's Blessing")
	local cainBlessingId = Isaac.GetItemIdByName("Cain's Blessing")
	local judasBlessingId = Isaac.GetItemIdByName("Judas' Blessing")
	local blueBabyBlessingId = Isaac.GetItemIdByName("???'s Blessing")
	local eveBlessingId = Isaac.GetItemIdByName("Eve's Blessing")
	local samsonBlessingId = Isaac.GetItemIdByName("Samson's Blessing")
	local azazelBlessingId = Isaac.GetItemIdByName("Azazel's Blessing")
	local lazarusBlessingId = Isaac.GetItemIdByName("Lazarus' Blessing")
	local lostBlessingId = Isaac.GetItemIdByName("The Lost's Blessing")
	local lilithBlessingId = Isaac.GetItemIdByName("Lilith's Blessing")
	local keeperBlessingId = Isaac.GetItemIdByName("Keeper's Blessing")
	local apollyonBlessingId = Isaac.GetItemIdByName("Apollyon's Blessing")
	local forgottenBlessingId = Isaac.GetItemIdByName("The Forgotten's Blessing")
	local bethanyBlessingId = Isaac.GetItemIdByName("Bethany's Blessing")
	local jacobEsauBlessingId = Isaac.GetItemIdByName("Jacob and Esau's Blessing")

local revengeChances = {
	isaac = 0.01,
	maggy = 0.01,
	cain = 0.01,
	judas = 0.01,
	bluebaby = 0.01,
	eve = 0.01,
	samson = 0.01,
	azazel = 0.01,
	lazarus = 0.01,
	lost = 0.01,
	lilith = 0.01,
	keeper = 0.01,
	apollyon = 0.01,
	forgotten = 0.01,
	bethany = 0.01,
	jacobesau = 0.01,
}




if mod:HasData() then
	persistent = json.decode(mod:LoadData())
else
persistent = {	
	blessing_queue = {}, 
	
	isaac_blessing = false,
	isaac_blessing_mini = false,
	maggy_blessing = 0,
	cain_blessing = false,
	cain_blessing_secondary = false,  
	judas_blessing = false, 
	judas_blessing_secondary = false,
	bluebaby_blessing = false,
	bluebaby_blessing_secondary = false,
	eve_blessing = false,
	eve_blessing_secondary = false,
	azazel_blessing = false, 
	azazel_blessing_secondary = false,
	lost_blessing = false,
	lost_blessing_secondary = false,
	keepers_blessing = false,
	keepers_blessing_secondary = false,
	apollyon_blessing = false,
	apollyon_blessing_secondary = false,
	forgotten_blessing = false,
	forgotten_blessing_secondary = false,
	bethany_blessing = false,
	bethany_blessing_secondary = false,

	judasBlessingTriggeredThisFrame = false,

	-- Revenge flags for all characters
	isaac_revenge = false,
	maggy_revenge = false,
	cain_revenge = false,
	judas_revenge = false,
	bluebaby_revenge = false,
	eve_revenge = false,
	samson_revenge = false,
	azazel_revenge = false,
	lazarus_revenge = false,
	lost_revenge = false,
	lilith_revenge = false,
	keeper_revenge = false,
	apollyon_revenge = false,
	forgotten_revenge = false,
	bethany_revenge = false,
	jacobesau_revenge = false,
}

end

-- Export persistent so other scripts can use it
_G.persistent = persistent


-- Sourced from the Isaac Lua Documentation: https://wofsauge.github.io/IsaacDocs/rep/Isaac.html?h=getplayer#getplayer

local function GetPlayers()
	local game = Game()
	local numPlayers = game:GetNumPlayers()
  
	local players = {}
	for i = 0, numPlayers - 1 do
	  local player = Isaac.GetPlayer(i)
	  table.insert(players, player)
	end
  
	return players
end

function table.find(tbl, val)
	for i, v in ipairs(tbl) do
		if v == val then return i end
	end
	return nil
end



local function GetItems(player,getKeyItems)
	local getKeyItems = getKeyItems or false
	local blacklist = {CollectibleType.COLLECTIBLE_POLAROID, CollectibleType.COLLECTIBLE_NEGATIVE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2, CollectibleType.COLLECTIBLE_KEY_PIECE_1, CollectibleType.COLLECTIBLE_KEY_PIECE_2, CollectibleType.COLLECTIBLE_DADS_NOTE, CollectibleType.COLLECTIBLE_EDENS_BLESSING}
	local list = {}
	local startpoint = Isaac.GetItemIdByName("Isaac's Blessing")
	for i=startpoint,Isaac.GetItemIdByName("Jacob and Esau's Blessing")+1,1 do
		table.insert(blacklist,i)
	end

	for i=1,Isaac.GetItemIdByName("Jacob and Esau's Blessing"),1 do
		if getKeyItems then
			for _,b_item in ipairs(blacklist) do
				if i == b_item then goto next end
			end
		end
		
		if player:HasCollectible(i,true) then
			table.insert(list,i)
		end

		::next::
	end

	local s = ""
	for _,v in ipairs(list) do
		s = s .. v .. ", "
	end

	--print(s)

	return list
end

local queues = {}

-- Ensure settings table exists
local settings = settings or {}

-- Blessing Character List
local blessingsList = {"Isaac", "Maggy", "Cain", "Judas", "BlueBaby", "Eve", "Samson", "Azazel", "Lazarus", "TheLost", "Lilith", "Keeper", "Apollyon", "TheForgotten", "Bethany", "JacobAndEsau"}

local function modConfigInit()
  if ModConfigMenu then
    local modName = "A Bushel of Blessings Re Blessed"
    ModConfigMenu.UpdateCategory(modName, {
      Info = {"Blessing Settings",}
    })

    -- Title
    ModConfigMenu.AddText(modName, "Settings", function() return "A Bushel of Blessings Re Blessed" end)
    ModConfigMenu.AddSpace(modName, "Settings")

	-- Set default values for each blessing key	
	for _, character in ipairs(blessingsList) do
		local settingKey = character .. " Blessing Enabled"
		if settings[settingKey] == nil then
	  		settings[settingKey] = true
		end
  	end


    for _, character in ipairs(blessingsList) do
      local settingKey = character .. " Blessing Enabled"

      ModConfigMenu.AddSetting(modName, "Settings", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
          return settings[settingKey]
        end,
        Display = function()
          return character .. " Blessing: " .. (settings[settingKey] and "On" or "Off")
        end,
        OnChange = function(currentBool)
          settings[settingKey] = currentBool
          _G["is" .. character .. "blessingenabled"] = currentBool
        end,
        Info = {"Enable or disable " .. character .. " Blessing item."}
      })
    end
  end
end

local function RemoveDisabledBlessingsFromPool()
	local itemPool = Game():GetItemPool()
  
	-- Remove disabled blessings
	  if not _G.isIsaacblessingenabled then
	    itemPool:RemoveCollectible(isaacBlessingId)
	  end
	  if not _G.isMaggyblessingenabled then
	    itemPool:RemoveCollectible(maggyBlessingId)
	  end
	  if not _G.isCainblessingenabled then
		itemPool:RemoveCollectible(cainBlessingId)
	  end
	  if not _G.isJudasblessingenabled then
		itemPool:RemoveCollectible(judasBlessingId)
	  end
	  if not _G.isBlueBabyblessingenabled then
		itemPool:RemoveCollectible(blueBabyBlessingId)
	  end
	  if not _G.isEveblessingenabled then
		itemPool:RemoveCollectible(eveBlessingId)
	  end
	  if not _G.isSamsonblessingenabled then
		itemPool:RemoveCollectible(samsonBlessingId)
	  end
	  if not _G.isAzazelblessingenabled then
		itemPool:RemoveCollectible(azazelBlessingId)
	  end
	  if not _G.isLazarusblessingenabled then
		itemPool:RemoveCollectible(lazarusBlessingId)
	  end
	  if not _G.isTheLostblessingenabled then
		itemPool:RemoveCollectible(lostBlessingId)
	  end
	  if not _G.isLilithblessingenabled then
		itemPool:RemoveCollectible(lilithBlessingId)
	  end
	  if not _G.isKeeperblessingenabled then
		itemPool:RemoveCollectible(keeperBlessingId)
	  end
	  if not _G.isApollyonblessingenabled then
		itemPool:RemoveCollectible(apollyonBlessingId)
	  end
	  if not _G.isTheForgottenblessingenabled then
		itemPool:RemoveCollectible(forgottenBlessingId)
	  end
	  if not _G.isBethanyblessingenabled then
		itemPool:RemoveCollectible(bethanyBlessingId)
	  end
	  if not _G.isJacobAndEsaublessingenabled then
		itemPool:RemoveCollectible(jacobEsauBlessingId)
	  end
  
  end
  

local firstLoad = true

function mod:onUpdate()
  	if firstLoad then
		modConfigInit()
		firstLoad = false
	end
	
	persistent.judasBlessingTriggeredThisFrame = false

	for i, player in ipairs(GetPlayers()) do
		local currentQueuedItem = player.QueuedItem and player.QueuedItem.Item
	
		-- If there's no queued item now but we had one stored last frame
		if queues[i] and not currentQueuedItem then
			local pickedItemID = queues[i].ID
	
			-- Only process blessing items
			local baseID = Isaac.GetItemIdByName("Isaac's Blessing")
			local maxID = baseID + 15 -- Jacob & Esau is the 16th (index 15) in the range
	
			if pickedItemID >= baseID and pickedItemID <= maxID then
				local index = pickedItemID - baseID
				local blessName = blessingsList[index + 1]:lower()
	
				-- Only apply if it hasn't been already (avoid duplicates)
				if not table.find(persistent.blessing_queue, blessName) then
					table.insert(persistent.blessing_queue, blessName)
	
					-- Apply effects based on item
					if blessName == "isaac" then
						persistent.isaac_blessing = true
	
					elseif blessName == "maggy" then
						persistent.maggy_blessing = persistent.maggy_blessing + 3
						player:AddMaxHearts(4)
						player:AddHearts(4)
	
					elseif blessName == "cain" then
						persistent.cain_blessing = true
	
					elseif blessName == "judas" then
						persistent.judas_blessing = true
						blessings.tryJudasBlessingEffect()
	
					elseif blessName == "bluebaby" then
						persistent.bluebaby_blessing = true
	
					elseif blessName == "eve" then
						persistent.eve_blessing = true
						blessings.tryEveBlessingEffect()
	
					elseif blessName == "samson" then
						player:AddCollectible(CollectibleType.COLLECTIBLE_BLOODY_LUST)
	
					elseif blessName == "azazel" then
						persistent.azazel_blessing = true
	
					elseif blessName == "lazarus" then
						blessings.tryLazarusTrinketGive()
						blessings.tryLazarusTrinketGive()
	
					elseif blessName == "thelost" then
						persistent.lost_blessing = true
	
					elseif blessName == "lilith" then
						blessings.tryLilithBlessingEffect()
	
					elseif blessName == "keeper" then
						persistent.keepers_blessing = true
	
					elseif blessName == "apollyon" then
						persistent.apollyon_blessing = true
						blessings.tryApollyonBlessingEffect()
	
					elseif blessName == "theforgotten" then
						persistent.forgotten_blessing = true
						blessings.tryForgottenBlessingEffect()
					elseif blessName == "bethany" then
						persistent.bethany_blessing = true
						blessings.tryBethanyBlessingEffect()
					elseif blessName == "jacobandesau" then
						-- Add a random passive from owned items
						local item_list = GetItems(player, true)
						local passive_items = {}
	
						for _, id in ipairs(item_list) do
							local config = Isaac.GetItemConfig():GetCollectible(id)
							if config and config.Type == ItemType.ITEM_PASSIVE then
								table.insert(passive_items, id)
							end
						end
	
						if #passive_items > 0 then
							local selection = passive_items[math.random(#passive_items)]
							player:AddCollectible(selection)
							player:AddCollectible(selection)
							table.insert(persistent.blessing_queue, "jacobandesau" .. selection)
						end
					end
	
					player:AddCacheFlags(CacheFlag.CACHE_ALL)
					player:EvaluateItems()
					mod:SaveData(json.encode(persistent))
				end
			end
		end
	
		-- Update stored queue status for next frame
		queues[i] = currentQueuedItem
	end
end	

function mod:onGameStart(isCont)
	if isCont then return end
	persistent.blessing_queue = persistent.blessing_queue or {}
	persistent.azazel_blessing = false
	persistent.lost_blessing = false
	persistent.isaac_blessing = false
	persistent.bluebaby_blessing = false
	persistent.cain_blessing = false
	persistent.keepers_blessing = false
	persistent.judas_blessing = false
	persistent.apollyon_blessing = false
	persistent.forgotten_blessing = false
	persistent.bethany_blessing = false
	-- Ensure persistent.maggy_blessing is a valid number (defaults to 0 if nil or invalid)
	if type(persistent.maggy_blessing) ~= "number" then
    	persistent.maggy_blessing = 0
	end
	if persistent.maggy_blessing > 0  then
	blessings.handleMaggyBlessingOnRunStart()
	end
	blessings.tryJudasBlessingEffect()
	blessings.tryEveBlessingEffect()
	blessings.tryApollyonBlessingEffect()
	if persistent.azazel_blessing_secondary then persistent.azazel_blessing_secondary = false end
	if persistent.isaac_blessing_mini then persistent.isaac_blessing_mini = false end
	if persistent.bluebaby_blessing_secondary then persistent.bluebaby_blessing_secondary = false end
	if persistent.cain_blessing_secondary then persistent.cain_blessing_secondary = false end
	if persistent.lost_blessing_secondary then persistent.lost_blessing_secondary = false end
	if persistent.keepers_blessing_secondary then persistent.keepers_blessing_secondary = false end
	if persistent.forgotten_blessing_secondary then persistent.forgotten_blessing_secondary = false end
	if persistent.bethany_blessing_secondary then persistent.bethany_blessing_secondary = false end
	

	local temp = {}

if persistent.blessing_queue and #persistent.blessing_queue > 0 then
	for _,v in ipairs(persistent.blessing_queue) do
		if v == "isaac" then
			persistent.isaac_blessing_mini = true
		elseif v == "maggy" then
			persistent.maggy_blessing = persistent.maggy_blessing
		elseif v == "cain" then
			persistent.cain_blessing_secondary = true
		elseif v == "judas" then
			-- persistent.judas_blessing_secondary = true
		elseif v == "bluebaby" then
			persistent.bluebaby_blessing_secondary = true
		elseif v == "eve" then
			-- persistent.eve_blessing_secondary = true
		elseif v == "samson" then
			Isaac.GetPlayer():AddCollectible(Isaac.GetItemIdByName("Bloody Lust"))
		elseif v == "azazel" then
			persistent.azazel_blessing_secondary = true
		elseif v == "lazarus" then
			blessings.tryLazarusTrinketGive()
			blessings.tryLazarusTrinketGive()
		elseif v == "lost" then
			persistent.lost_blessing_secondary = true
		elseif v == "lilith" then
			blessings.tryLilithBlessingEffect()
		elseif v == "keeper" then
			persistent.keepers_blessing_secondary = true
		elseif v == "apollyon" then
			
		elseif v == "theforgotten" then
			persistent.forgotten_blessing_secondary = true
		elseif v == "bethany" then
			persistent.bethany_blessing_secondary = true
		elseif string.sub(v,1,12) == "jacobandesau" then
			if (tonumber(string.sub(v,13)) ~= nil) then
				Isaac.GetPlayer():AddCollectible(tonumber(string.sub(v,13)))
				Isaac.GetPlayer():AddCollectible(tonumber(string.sub(v,13)))
			end
		end
	end
end
	
	persistent.blessing_queue = temp
	mod:SaveData(json.encode(persistent))
end

function mod:CheckBlessingRevenge(player)
    local blessings = {
        { id = isaacBlessingId,     key = "isaac",     valueType = "bool", extraKeys = { "isaac_blessing_mini" } },
        { id = maggyBlessingId,     key = "maggy",     valueType = "int" },
        { id = cainBlessingId,      key = "cain",      valueType = "bool", extraKeys = { "cain_blessing_secondary" } },
        { id = judasBlessingId,     key = "judas",     valueType = "bool", extraKeys = { "judas_blessing_secondary" } },
        { id = blueBabyBlessingId,  key = "bluebaby",  valueType = "bool", extraKeys = { "bluebaby_blessing_secondary" } },
        { id = eveBlessingId,       key = "eve",       valueType = "bool", extraKeys = { "eve_blessing_secondary" } },
        { id = samsonBlessingId,    key = "samson",    valueType = "bool" },
        { id = azazelBlessingId,    key = "azazel",    valueType = "bool", extraKeys = { "azazel_blessing_secondary" } },
        { id = lazarusBlessingId,   key = "lazarus",   valueType = "bool" },
        { id = lostBlessingId,      key = "lost",      valueType = "bool", extraKeys = { "lost_blessing_secondary" } },
        { id = lilithBlessingId,    key = "lilith",    valueType = "bool" },
        { id = keeperBlessingId,    key = "keeper",    valueType = "bool", extraKeys = { "keepers_blessing_secondary" } },
        { id = apollyonBlessingId,  key = "apollyon",  valueType = "bool", extraKeys = { "apollyon_blessing_secondary" } },
        { id = forgottenBlessingId, key = "forgotten", valueType = "bool", extraKeys = { "forgotten_blessing_secondary" } },
        { id = bethanyBlessingId,   key = "bethany",   valueType = "bool", extraKeys = { "bethany_blessing_secondary" } },
        { id = jacobEsauBlessingId, key = "jacobesau", valueType = "bool" },
    }

    for _, blessing in ipairs(blessings) do
        if player:HasCollectible(blessing.id) then
            local chance = revengeChances[blessing.key]
            if math.random() < chance then
                -- Trigger revenge
                persistent[blessing.key .. "_revenge"] = true

                -- Reset main blessing
                if blessing.key == "maggy" then
                    persistent.maggy_blessing = 0
                else
                    local blessKey = blessing.key .. "_blessing"
                    if persistent[blessKey] ~= nil then
                        persistent[blessKey] = false
                    end
                end

                -- Reset extras if they exist
                if blessing.extraKeys then
                    for _, extra in ipairs(blessing.extraKeys) do
                        if persistent[extra] ~= nil then
                            persistent[extra] = false
                        end
                    end
                end

				mod:SaveData(json.encode(persistent))

                -- Play curse-related sound effect
                -- Example: using the Curse sound or a similar ominous sound
                -- Adjust volume or pitch if desired
                SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 2.0, 0, false, 1.0)

                -- Spawn a visual effect on player (e.g. curse clouds or dark effect)
                -- For example, spawn a "curse" effect entity on the player position
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, player.Position, Vector.Zero, player)
                effect.Parent = player

                -- Reset revenge chance
                revengeChances[blessing.key] = 0.01
            else
                -- Double the chance (up to 100%)
                revengeChances[blessing.key] = math.min(chance * 2, 1.0)
            end
        end
    end
end




function mod:onNewRoom()
    blessings.tryIsaacsBlessingEffect()
    blessings.tryCainBlessingEffect()
	blessings.tryLostBlessingEffect()
	blessings.tryKeepersBlessingEffect()
	blessings.tryForgottenBlessingEffect()
	blessings.tryBethanyBlessingEffect()
	RemoveDisabledBlessingsFromPool()

	revenge.tryIsaacRevengeEffect()
end


function mod:evalCache(player, CacheFlag)
	
end

		

function mod:onNewFloor()
	
end

function mod:PostCurseEval()
	
end

function mod:OnTearFired(tear)
	if not (persistent.azazel_blessing or persistent.azazel_blessing_secondary) then return end
	blessings.tryAzazelBlessingEffect(tear)
end

function mod:onPickupUpdate(pickup)
    -- Only affect gold and bomb chests
    local variant = pickup.Variant
    if variant == PickupVariant.PICKUP_LOCKEDCHEST then
        local sprite = pickup:GetSprite()

        -- Check if the chest is now playing the "Open" animation and hasn't been processed yet
        if sprite:IsPlaying("Open") and not pickup:GetData().bluebaby_processed then
            pickup:GetData().bluebaby_processed = true -- Mark as handled
            blessings.tryBlueBabyChestSpawnEffect(pickup)
        end
    end
end

function mod:OnPlayerTakeDamage(entity, amount, flags, source, countdown)
	if entity.Type == EntityType.ENTITY_PLAYER then
		local player = entity:ToPlayer()
		mod:CheckBlessingRevenge(player)
	end
end

function mod:OnPlayerWin(playerWon)
	if not playerWon then return end -- Only reset if player WON

	-- Reset all revenge flags
	local revengeKeys = {
		"isaac", "maggy", "cain", "judas", "bluebaby", "eve", "samson",
		"azazel", "lazarus", "lost", "lilith", "keeper", "apollyon",
		"forgotten", "bethany", "jacobesau"
	}

	for _, key in ipairs(revengeKeys) do
		local revengeFlag = key .. "_revenge"
		if persistent[revengeFlag] ~= nil then
			persistent[revengeFlag] = false
		end
	end
end


function mod:onGameEnd(isGameOver)
    -- isGameOver == true means player lost (game over)
    -- isGameOver == false means player won (ending)
    
    if not isGameOver then
        -- Player won: reset all revenge flags
        mod:OnPlayerWin(true) 
    end

    -- Reset mini and secondary flags regardless
    local boolFlagsToReset = {
        "isaac_blessing_mini",
        "bluebaby_blessing_secondary",
        "cain_blessing_secondary",
        "azazel_blessing_secondary",
        "lost_blessing_secondary",
        "forgotten_blessing_secondary",
        "bethany_blessing_secondary"
    }

    for _, flag in ipairs(boolFlagsToReset) do
        if persistent[flag] then
            persistent[flag] = false
        end
    end

    -- Clamp maggy blessing to max 10
    if persistent.maggy_blessing > 10 then
        persistent.maggy_blessing = 10
    end

    mod:SaveData(json.encode(persistent))
end



-- Register the familiar update callback (called every frame)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    if familiar.Variant == FamiliarVariant.BONE_SPUR then
        local player = familiar.Player
        local orbitCenter = player.Position
        
        -- Fixed values for orbit distance
        local orbitDistance = 50  -- Set the orbit distance to a constant value (adjustable)
        
        -- Randomly assign a speed between 0.08 and 0.12, and direction (clockwise or counter-clockwise)
        if not familiar:GetData().orbitSpeed then
            familiar:GetData().orbitSpeed = math.random() * 0.04 + 0.08  -- Random speed between 0.08 and 0.12
            familiar:GetData().orbitDirection = (math.random(0, 1) == 0) and 1 or -1  -- Random direction (1 for counter-clockwise, -1 for clockwise)
        end
        
        local orbitSpeed = familiar:GetData().orbitSpeed * familiar:GetData().orbitDirection

        -- Calculate the difference in X and Y between the familiar and the player
        local dx = familiar.Position.X - orbitCenter.X
        local dy = familiar.Position.Y - orbitCenter.Y
        
        -- Calculate the angle using math.atan, handling both X and Y components manually
        local angle = math.atan(dy / dx)
        
        -- Adjust angle based on quadrant
        if dx < 0 then
            angle = angle + math.pi
        elseif dx > 0 and dy < 0 then
            angle = angle + 2 * math.pi
        end
        
        -- Increment the angle based on the orbit speed and direction
        angle = angle + orbitSpeed
        
        -- Calculate the new position in the orbit using sine/cosine to maintain the orbit shape
        local newX = orbitCenter.X + math.cos(angle) * orbitDistance
        local newY = orbitCenter.Y + math.sin(angle) * orbitDistance
        
        -- Set the familiar's position to the new orbit position
        familiar.Position = Vector(newX, newY)
    end
end)



mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
    if tear:GetData().isInvisible then
        tear:SetColor(Color(0, 0, 0, 0, 0, 0, 0), 0, 0, false, false)  -- Makes the tear invisible
    end
end)





function mod:OnGameExit()
	if mod:HasData() then
	 -- mod:SaveData(json.encode(settings))
	end
  end





mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.OnPlayerTakeDamage, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.OnGameExit)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.onPickupUpdate)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.onGameEnd, mod)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onGameStart)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.evalCache)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloor)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.OnTearFired)
mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, mod.PostCurseEval)




  






