local AnimItems = RegisterMod("Animated Items",1)
local game = Game()
local questionMarkSprite = Sprite()
questionMarkSprite:Load("gfx/005.100_collectible.anm2",true)
questionMarkSprite:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
questionMarkSprite:LoadGraphics()
if ModConfigMenu then
	ModConfigMenu = require("scripts.modconfig")
end
--used for saving and loading string data
json = require("json")
AnimatedItemsAPI = {}
local onColor = "COLOR_DEFAULT"
local offColor = "COLOR_HALF"

AnimItems.ANIM_EFFECT = Isaac.GetEntityVariantByName("Pedestal Animation")

animationfiles = {}
animationfiles[CollectibleType.COLLECTIBLE_MUTANT_SPIDER] = "MutantSpiderAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_TINY_PLANET] = "TinyPlanetAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_GODHEAD] = "GodheadAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SYNTHOIL] = "SYNTHOILAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE] = "LudoAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_PSY_FLY] = "PsyFlyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ANGELIC_PRISM] = "AngelicPrismAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = "MagicMushroomAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SACRED_HEART] = "SacredHeartAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_PACT] = "ThePactAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_TECH_X] = "TechXAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_GLITCHED_CROWN] = "GlitchedCrownAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ECHO_CHAMBER] = "EchoChamberAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ROCK_BOTTOM] = "RockBottomAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION] = "AstralProjectionAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_MOMS_PERFUME] = "MomsPerfumeAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_FRUITY_PLUM] = "FruityPlumAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BIG_FAN] = "BigFanAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_MULLIGAN] = "MulliganAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SKATOLE] = "SkatoleAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_FRIEND_ZONE] = "FriendZoneAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_DISTANT_ADMIRATION] = "DistantAdmirationAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_FOREVER_ALONE] = "ForeverAloneAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_HALO_OF_FLIES] = "HaloOfFliesAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BEST_BUD] = "BestBudAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SMART_FLY] = "SmartFlyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_JAR_OF_FLIES] = "JarOfFliesAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_LOST_FLY] = "LostFlyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_OBSESSED_FAN] = "ObsessedFanAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_PARASITOID] = "ParasitoidAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ANGRY_FLY] = "AngryFlyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BOT_FLY] = "BotFlyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BBF] = "BBFAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_DIRTY_MIND] = "DirtyMindAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_EPIC_FETUS] = "EpicFetusAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SAD_BOMBS] = "SadBombsAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_GLITTER_BOMBS] = "GlitterBombsAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BOBBY_BOMB] = "BobbyBombsAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_HOT_BOMBS] = "HotBombsAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_NANCY_BOMBS] = "NancyBombsAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SPOON_BENDER] = "SpoonBenderAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_KAMIKAZE] = "KamikazeAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_LACHRYPHAGY] = "LachryphagyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_POLYPHEMUS] = "PolyphemusAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_1UP] = "1UpAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_DEPRESSION] = "DepressionAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_KEY_BUM] = "KeyBumAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_DARK_BUM] = "DarkBumAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BUM_FRIEND] = "BumFriendAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_EVIL_CHARM] = "EvilCharmAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_INFESTATION] = "InfestationAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_INFESTATION_2] = "Infestation2Animated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ANTI_GRAVITY] = "AntiGravityAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SMB_SUPER_FAN] = "SMBSuperFanAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL] = "GuardianAngelAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_STOP_WATCH] = "StopwatchAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN] = "DarkPrincesCrownAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_INCUBUS] = "IncubusAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_TINYTOMA] = "TinytomaAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BATTERY_PACK] = "BatteryPackAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ROID_RAGE] = "RoidRageAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BREAKFAST] = "BreakfastAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ISAACS_HEART] = "IsaacsHeartAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_HEART] = "LessThan3Animated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_GOAT_HEAD] = "GoatheadAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_20_20] = "2020Animated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_DESSERT] = "DessertAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BROKEN_MODEM] = "BrokenModemAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SPEED_BALL] = "SpeedballAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ADRENALINE] = "AdrenalineAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT] = "ExperimentalTreatmentAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_GROWTH_HORMONES] = "GrowthHormonesAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BIRDS_EYE] = "BirdsEyeAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_LIL_PORTAL] = "LilPortalAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_WORM_FRIEND] = "WormFriendAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SUPLEX] = "SuplexAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_VIRUS] = "TheVirusAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_RAINBOW_BABY] = "RainbowBabyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_MR_MEGA] = "MrMegaAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_METRONOME] = "MetronomeAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = "GlowingHourglassAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SPIN_TO_WIN] = "SpinToWinAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_VENGEFUL_SPIRIT] = "VengefulSpiritAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_ROTTEN_TOMATO] = "RottenTomatoAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_GUPPYS_EYE] = "GuppysEyeAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_LIL_DUMPY] = "LilDumpyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_EVERYTHING_JAR] = "EverythingJarAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_VASCULITIS] = "VasculitisAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SQUEEZY] = "SqueezyAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_SUPPER] = "SupperAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_STAPLER] = "StaplerAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_BOOSTER_PACK] = "BoosterpackAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_RED_STEW] = "RedStewAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_MOMS_BRACELET] = "MomsbraceletAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_IBS] = "IBSAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_MEAT_CLEAVER] = "MeatcleaverAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_LEMEGETON] = "LemegetonAnimated.anm2"
animationfiles[CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS] = "KnockoutdropsAnimated.anm2"
local previewSprite = Sprite()
local animationEnabledTable = {}

function AnimItems:SetDefaultEnabledStates(animationfiles)
	Isaac.ConsoleOutput("Creating animation enabled table...")
	local isAnimationEnabled = {}
	for i=1,CollectibleType.NUM_COLLECTIBLES do
		if animationfiles[i] ~= nil then
			isAnimationEnabled[i] = true
		end
	end
	return isAnimationEnabled
end

function AnimItems:UpdateEnabledStates(animationEnabledArray)
	Isaac.ConsoleOutput("Creating animation enabled table from saved data...")
	local isAnimationEnabled = {}
	for i, v in pairs(animationEnabledArray) do
		print(tostring(i))
		if v ~= nil then
			if i == "3" then
				print(tostring(v))
			end
			isAnimationEnabled[tonumber(i)] = v
		end
	end
	-- Doesn't account for case of future items being added to mod
	-- TODO fix load state to check against mod's list and user's saved list
	return isAnimationEnabled	
end


local function GetAnimationID(animation)
	local filename = animation:GetSprite():GetFilename()
	for k,i in pairs(animationfiles) do
		if "gfx/" .. i == filename then return k end
	end
end

local function EntityHasEffect(ent)
	local animeffs = Isaac.FindByType(EntityType.ENTITY_EFFECT, AnimItems.ANIM_EFFECT)
	for _,i in pairs(animeffs) do
		if i.SpawnerEntity and GetPtrHash(i.SpawnerEntity) == GetPtrHash(ent) then return true end
	end
	return false
end

local function IsQuestion(pickup)
	if pickup:GetData()["isquestion"] ~= nil and pickup:GetData()["isquestion delay"] > 2 then
        return pickup:GetData()["isquestion"]
    end
    if not pickup:GetData()["isquestion delay"] then pickup:GetData()["isquestion delay"] = 0 end
    pickup:GetData()["isquestion delay"] = pickup:GetData()["isquestion delay"] + 1
    --if pickup:GetData()["isquestion"] ~= nil then
    --    return pickup:GetData()["isquestion"]
    --end
    
    local entitySprite = pickup:GetSprite()
    local name = entitySprite:GetAnimation()
    
    if name ~= "Idle" and name ~= "ShopIdle" then
        -- Collectible can be ignored. its definetly not hidden
        pickup:GetData()["isquestion"] = false
        return false
    end
    
    questionMarkSprite:SetFrame(name,entitySprite:GetFrame())
    -- check some point in entitySprite
    for i = -70,0,2 do
        local qcolor = questionMarkSprite:GetTexel(Vector(0,i),Vector.Zero,1,1)
        local ecolor = entitySprite:GetTexel(Vector(0,i),Vector.Zero,1,1)
        if qcolor.Red ~= ecolor.Red or qcolor.Green ~= ecolor.Green or qcolor.Blue ~= ecolor.Blue then
            pickup:GetData()["isquestion"] = false
           -- print("Returning false")
            return false
        end
    end
    
    --this may be a question mark, however, we will check it again to ensure it
    for j = -3,3,2 do
        for i = -71,0,2 do
            local qcolor = questionMarkSprite:GetTexel(Vector(j,i),Vector.Zero,1,1)
            local ecolor = entitySprite:GetTexel(Vector(j,i),Vector.Zero,1,1)
            if qcolor.Red ~= ecolor.Red or qcolor.Green ~= ecolor.Green or qcolor.Blue ~= ecolor.Blue then
                pickup:GetData()["isquestion"] = false
               -- print("Returning false")
                return false
            end
        end
    end
    
    pickup:GetData()["isquestion"] = true
    return true
end
function AnimItems:save()
	if ModConfigMenu then
		local data = { }
		-- can't just dump array into json, the nil values screw things up when loading
		local storageTable = {}
		for k,v in pairs(animationEnabledTable) do
			storageTable[tostring(k)] = v
		end
		data["settings"] = storageTable
		local jsondata = json.encode(data)
		AnimItems:SaveData(jsondata)
	end
end

function AnimItems:loadData()
	if AnimItems:HasData() then
		local config = json.decode(AnimItems:LoadData())
		--print(config["settings"][3])
		animationEnabledTable = AnimItems:UpdateEnabledStates(config["settings"])
		if animationEnabledTable == nil then
			animationEnabledTable = AnimItems:SetDefaultEnabledStates(animationfiles)
		end
	else
		animationEnabledTable = AnimItems:SetDefaultEnabledStates(animationfiles)
	end
end
AnimItems:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, AnimItems.loadData)

function AnimItems:CheckIfMysteryItemShowed(pedestal)
    if animationfiles[pedestal.SubType] and not EntityHasEffect(pedestal) and not IsQuestion(pedestal) and animationEnabledTable[pedestal.SubType] then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, AnimItems.ANIM_EFFECT, 0, pedestal.Position, Vector.Zero, pedestal)
    end
end
AnimItems:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, AnimItems.CheckIfMysteryItemShowed, PickupVariant.PICKUP_COLLECTIBLE)

function AnimItems:AnimationBirth(animation)
	local spawner = animation.SpawnerEntity
	if spawner.Type == EntityType.ENTITY_PICKUP and spawner.Variant == PickupVariant.PICKUP_COLLECTIBLE and not IsQuestion(spawner:ToPickup()) then
		local pedestal = spawner:ToPickup()
		if animationEnabledTable[pedestal.SubType] then
			pedestal:GetSprite():ReplaceSpritesheet(1,"gfx/nil.png")
			pedestal:GetSprite():LoadGraphics()
			animation:FollowParent(spawner)
			animation:GetSprite():Load("gfx/" .. animationfiles[pedestal.SubType], true)
			animation:GetSprite():Play("AnimatedPedestal")
			animation.SpriteOffset = Vector(0,-4)
			if spawner:ToPickup():IsShopItem() then animation.SpriteOffset = Vector(0,10) end
			animation.DepthOffset = 1
		end
	elseif spawner.Type == EntityType.ENTITY_PLAYER then
		if animationEnabledTable[spawner:ToPlayer().QueuedItem.Item.ID] then
			animation:FollowParent(spawner)
			animation:GetSprite():Load("gfx/" .. animationfiles[spawner:ToPlayer().QueuedItem.Item.ID], true)
			animation:GetSprite():Play("AnimatedPedestal")
			animation.SpriteOffset = Vector(0,-16)
			animation.DepthOffset = 1
		end
	end
end
AnimItems:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, AnimItems.AnimationBirth, AnimItems.ANIM_EFFECT)

local function CheckTransferBeforeDeletion(animation)
	for num = 0, game:GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(num)
		if player.QueuedItem.Item and player.QueuedItem.Item.ID == GetAnimationID(animation) then -- do they already have an effect?
			if not EntityHasEffect(player) and Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND == 0 then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, AnimItems.ANIM_EFFECT, 0, player.Position, Vector.Zero, player)
			end
		end
	end
	animation:Remove()
end

function AnimItems:UpdateAnimation(animation)
	if not animation.SpawnerEntity then
		CheckTransferBeforeDeletion(animation)
		return
	end
	if animation.SpawnerEntity.Type == EntityType.ENTITY_PICKUP then
		local pedestal = animation.SpawnerEntity
		local frame = pedestal:GetSprite():GetFrame()
		
		if pedestal.SubType ~= GetAnimationID(animation) then CheckTransferBeforeDeletion(animation) end
		
		if not pedestal:ToPickup():IsShopItem() then
			local y = 3
			local scale = Vector(1,1)
			-- channel your inner yandev
			if frame <= 2 then
				y = y-6
			elseif frame <= 4 then
				y = y-7
				scale = Vector(1,1.04)
			elseif frame <= 6 then
				y = y-8
				scale = Vector(1.08,0.98)
			elseif frame <= 8 then
				y = y-9
				scale = Vector(1.08,0.98)
			elseif frame <= 11 then
				y = y-10
			elseif frame <= 13 then
				y = y-9
				scale = Vector(1,1.04)
			elseif frame <= 15 then
				y = y-8
			elseif frame <= 17 then
				y = y-7
				scale = Vector(1.08,0.98)
			else
				y = y-6
				scale = Vector(1.08,0.98)
			end
			animation.SpriteOffset = Vector(0,y)
			animation.SpriteScale = scale
		else
			animation.SpriteOffset = Vector(0,10)
			animation.SpriteScale = Vector.One
		end
	elseif animation.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
		local player = animation.SpawnerEntity:ToPlayer()
		if not player.QueuedItem.Item or player.QueuedItem.Item.ID ~= GetAnimationID(animation) then animation:Remove() end
		--animation.Position = player.Position + player.Velocity
		if animation.FrameCount <= 1 then animation.SpriteOffset = Vector(0,-25)
		elseif animation.FrameCount >= 36 then animation.SpriteOffset = Vector(0,-12)
		else animation.SpriteOffset = Vector(0,-16) end
	end
end
AnimItems:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, AnimItems.UpdateAnimation, AnimItems.ANIM_EFFECT)


-- Allows modders to add compatibility with their idems.
-- Parameters :
--   collectibleId [number] : The ID of the item. To find the ID of the itemn use : Isaac.GetItemIdByName("Your Item Name")
--   animation     [string] : The anm2 file in resources/gfx/
function AnimatedItemsAPI:SetAnimationForCollectible(collectibleId, animation)
    if collectibleId == nil or animation == nil then return end
    animationfiles[collectibleId] = animation
end

-- Legacy compatibility for original typo'd function
function AnimatedItemsAPI:SetAnimationForCollectibe(collectibleId, animation)
	AnimatedItemsAPI:SetAnimationForCollectible(collectibleId, animation)
end

-- ModMenu for Animated Items
function AnimItems:RenderPreviewAnimation()
	if not ModConfigMenu then return end
	if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, 0) or Input.IsButtonTriggered(ModConfigMenu.Config["Mod Config Menu"].OpenMenuKeyboard, 0) or Input.IsButtonTriggered(ModConfigMenu.Config["Mod Config Menu"].OpenMenuController, 0) or Input.IsButtonTriggered(Keyboard.KEY_F10, 0)then
		previewSprite.Scale = Vector(0,0)
	end
	if ModConfigMenu.IsVisible then 
		previewSprite:Render(Vector(Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight() - 10), Vector(0,0), Vector(0,0))
	end
end

local function getDisplayValue(value)
	if value then return "On" else return "Off" end
end
local function getPrettyName(itemName)
	-- Isaac doesn't give item names in a nice format, we have to split strings and slice things to make it decently readable
	-- format is "#(item name in underscores and allcaps)_NAME"
	local finalName = ""
	simplifiedName = string.sub(itemName, 2, string.len(itemName) - 4) -- we keep the last underscore for simplicity sake
	local spliteratedName = { }
	for w in simplifiedName:gmatch("(.-)_") do table.insert(spliteratedName, w) end
	for i, v in ipairs(spliteratedName) do
		if v == "BBF" or v == "SMB" then -- All caps in certain names
			finalName = finalName .. v
		elseif v == "2020" then -- 20/20 gets named as 2020
			finalName = finalName .. "20/20"
		elseif v == "MOMS" or v == "???S" or v == "ISAACS" or v == "GUPPYS" then --item names with possessive adjectives
			finalName = finalName .. string.sub(v,1,1) .. string.sub(string.lower(v),2,string.len(v) - 1) .. "'s"
		else
			finalName = finalName .. string.sub(v,1,1) .. string.sub(string.lower(v),2,string.len(v))
		end
		if i < #spliteratedName then
			finalName = finalName .. " "
		end
	end
	return finalName
end

function AnimItems:CreateModMenu(animationfiles)
	AnimItems:loadData()
	if ModConfigMenu then
		ModConfigMenu.UpdateCategory("Animated Items", {
		  Info = {"Toggle settings for Animated Items mod",}
		})
		local category = "Animated Items"
		ModConfigMenu.AddText(category, "Settings", function() return "Animated Items Toggle" end)
		ModConfigMenu.AddSpace(category, "Settings")
		for k,v in pairs(animationEnabledTable) do
			ModConfigMenu.AddSetting(category, "Settings", {

			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return tostring(animationEnabledTable[k])
			end,
			Display = function()
				local display = ""
				display = getPrettyName(Isaac.GetItemConfig():GetCollectible(k).Name) .. ": " .. getDisplayValue(animationEnabledTable[k])
				return display
			end,
            OnChange = function(newValue)
                animationEnabledTable[k] = not animationEnabledTable[k]
                AnimItems:save()
            end,
            Info = function()
                local info = {"",""}
				if ModConfigMenu.IsVisible then
					previewSprite:Load("gfx/" .. tostring(animationfiles[k]), true)
					if animationEnabledTable[k] then
						previewSprite.Color = Color(previewSprite.Color.R, previewSprite.Color.G, previewSprite.Color.B, 1, 0,0,0)
					else
						previewSprite.Color = Color(previewSprite.Color.R, previewSprite.Color.G, previewSprite.Color.B, 0.3, 0,0,0)
					end
					previewSprite.Scale = Vector(1, 1)
					previewSprite:SetFrame("AnimatedPedestal",1)
				end
				return info
            end
		})
		end
	end
end
--- the only way I could find to hide our preview sprite is to create a custom callback for ModConfigMenu.  if things break for your mod, it might be this

AnimItems:AddCallback(ModCallbacks.MC_POST_RENDER, AnimItems.RenderPreviewAnimation)
AnimItems:CreateModMenu(animationfiles)