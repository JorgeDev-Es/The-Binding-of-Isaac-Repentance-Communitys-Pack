local AnimItems = RegisterMod("Animated Items",1)
local level = Game():GetLevel()
local curses = {LevelCurse.CURSE_OF_BLIND}
local questionMarkSprite = Sprite()
local game = Game()
local nullVector = Vector(0,0)
questionMarkSprite:Load("gfx/005.100_collectible.anm2",true)
questionMarkSprite:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
questionMarkSprite:LoadGraphics()

AnimatedItemsAPI = {}

AnimItems.ANIM_EFFECT = Isaac.GetEntityVariantByName("Pedestal Animation")

local animationfiles = {}
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
animationfiles[CollectibleType.COLLECTIBLE_MONTEZUMAS_REVENGE] = "MontezumasRevengeAnimated.anm2"


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

function AnimItems:CheckIfMysteryItemShowed(pedestal)
    if animationfiles[pedestal.SubType] and not EntityHasEffect(pedestal) and not AnimItems:IsQuestion(pedestal) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, AnimItems.ANIM_EFFECT, 0, pedestal.Position, Vector.Zero, pedestal)
    end
end

function AnimItems:AnimationBirth(animation)
	local spawner = animation.SpawnerEntity
	if spawner.Type == 5 and spawner.Variant == 100 and not AnimItems:IsQuestion(spawner:ToPickup()) then
		local pedestal = spawner:ToPickup()
		pedestal:GetSprite():ReplaceSpritesheet(1,"gfx/nil.png")
		pedestal:GetSprite():LoadGraphics()
		
		animation:GetSprite():Load("gfx/" .. animationfiles[pedestal.SubType], true)
		animation:GetSprite():Play("AnimatedPedestal")
		animation.SpriteOffset = Vector(0,-4)
		animation.DepthOffset = 1
	elseif spawner.Type == 1 then
		animation:GetSprite():Load("gfx/" .. animationfiles[spawner:ToPlayer().QueuedItem.Item.ID], true)
		animation:GetSprite():Play("AnimatedPedestal")
		animation.SpriteOffset = Vector(0,-16)
		animation.DepthOffset = 10
	end
end

function AnimItems:UpdateAnimation(animation)
	if not animation.SpawnerEntity then animation:Remove() return end
	if animation.SpawnerEntity.Type == 5 then
		local pedestal = animation.SpawnerEntity
		local frame = pedestal:GetSprite():GetFrame()
		
		if pedestal.SubType ~= GetAnimationID(animation) then
			for num = 0, Game():GetNumPlayers()-1 do
				local player = Isaac.GetPlayer(num)
				if player.QueuedItem.Item and player.QueuedItem.Item.ID == GetAnimationID(animation) then -- do they already have an effect?
					Isaac.Spawn(EntityType.ENTITY_EFFECT, AnimItems.ANIM_EFFECT, 0, pedestal.Position, Vector.Zero, player)
				end
			end
			animation:Remove()
		else
			animation.Position = pedestal.Position -- in case it's being bumped into or whatevs
		end
		
		if pedestal:ToPickup().Price == 0 then
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
	elseif animation.SpawnerEntity.Type == 1 then
		local player = animation.SpawnerEntity:ToPlayer()
		if not player.QueuedItem.Item or player.QueuedItem.Item.ID ~= GetAnimationID(animation) then animation:Remove() end
		animation.Position = player.Position + player.Velocity
		if animation.FrameCount <= 1 then animation.SpriteOffset = Vector(0,-25)
		elseif animation.FrameCount >= 36 then animation.SpriteOffset = Vector(0,-12)
		else animation.SpriteOffset = Vector(0,-16) end
	end
end



function AnimItems:IsQuestion(pickup)
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

-- Allows modders to add compatibility with their idems.
-- Parameters :
--   collectibleId [number] : The ID of the item. To find the ID of the itemn use : Isaac.GetItemIdByName("Your Item Name")
--   animation     [string] : The anm2 file in resources/gfx/
function AnimatedItemsAPI:SetAnimationForCollectibe(collectibleId, animation)
    if collectibleId == nil or animation == nil then return end
    animationfiles[collectibleId] = animation
end

AnimItems:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, AnimItems.CheckIfMysteryItemShowed, PickupVariant.PICKUP_COLLECTIBLE)
AnimItems:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, AnimItems.AnimationBirth, AnimItems.ANIM_EFFECT)
AnimItems:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, AnimItems.UpdateAnimation, AnimItems.ANIM_EFFECT)