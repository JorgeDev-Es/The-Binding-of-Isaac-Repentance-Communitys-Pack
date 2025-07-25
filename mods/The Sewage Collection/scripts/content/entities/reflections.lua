--##############################################################################--
--#################################### SETUP ###################################--
--##############################################################################--
SEWCOL.REFLECTION = {
    EID = {
        en_us = "{{SEWCOL_ColorReflect}}REFLECTED: Harms you, Pay-off doubled!#",
        ru = "{{SEWCOL_ColorReflect}}ОТРАЖЕННЫЙ: Вредит вам, удваивая выплату!#",
        spa = "{{SEWCOL_ColorReflect}}REFLECTED: Te herirá, ¡Paga duplicada!#",
        zh_cn = "{{SEWCOL_ColorReflect}}镜像：触摸幻象，但是要付出代价#",
        ko_kr = "{{SEWCOL_ColorReflect}}거울 형태:접촉 시 2배로 복사되나 피해를 받습니다.#",
    },
    SPAWN_CHANCE = 9,  -- Is actually 0.75% (9/1200)
    MIRROR_CHANCE = 30, -- Is actually 2.5% (30/1200)
    COLOR = Color(1,1,1,0.5),
    COLORIZE = {1, 1.4, 1.8, 1},

    WHITELIST = {
        [PickupVariant.PICKUP_PILL] = true,
        [PickupVariant.PICKUP_COLLECTIBLE] = true,
        [PickupVariant.PICKUP_TAROTCARD] = true,
        [PickupVariant.PICKUP_TRINKET] = true,
    
        [PickupVariant.PICKUP_HEART] = "Heart",
        [PickupVariant.PICKUP_COIN] = "Coin",
        [PickupVariant.PICKUP_KEY] = "Key",
        [PickupVariant.PICKUP_BOMB] = "Bomb",
        -- [PickupVariant.PICKUP_POOP] = "Poop",
        [PickupVariant.PICKUP_GRAB_BAG] = "Bag",
        [PickupVariant.PICKUP_LIL_BATTERY] = "Battery",
    
        [PickupVariant.PICKUP_CHEST] = "Chest",
        [PickupVariant.PICKUP_BOMBCHEST] = "Chest",
        [PickupVariant.PICKUP_SPIKEDCHEST] = "Chest",
        [PickupVariant.PICKUP_ETERNALCHEST] = "Chest",
        -- [PickupVariant.PICKUP_MIMICCHEST] = "Chest",  
        [PickupVariant.PICKUP_OLDCHEST] = "Chest",
        [PickupVariant.PICKUP_WOODENCHEST] = "Chest",
        [PickupVariant.PICKUP_MEGACHEST] = "Chest",
        [PickupVariant.PICKUP_HAUNTEDCHEST] = "Chest",
        [PickupVariant.PICKUP_LOCKEDCHEST] = "Chest",
        [PickupVariant.PICKUP_REDCHEST] = "Chest"
    }
}

if GOLCG then SEWCOL.REFLECTION.WHITELIST[3320] = "Fiche" end

local json = require("json")
local gameHasLoaded = false

SEWCOL.REFLECTION.COLOR:SetColorize(table.unpack(SEWCOL.REFLECTION.COLORIZE))

local function applyReflectionColor(pickup)
    local color = pickup:GetColor()
    color = Color(color.R, color.G, color.B, color.A, color.RO, color.GO, color.BO)

    if color.R == 1 and color.G == 1 and color.B == 1 then
        pickup:SetColor(SEWCOL.REFLECTION.COLOR, -1, 99, false, true)
    else
        color.A = SEWCOL.REFLECTION.COLOR.A
        color.B = SEWCOL.REFLECTION.COLOR.B
        pickup:SetColor(color, -1, 99, false, true)
    end
end
--##############################################################################--
--################################# EID LOGIC ##################################--
--##############################################################################--
local function getName(item)
    local name = SEWCOL.REFLECTION.WHITELIST[item]
    if not name then return "pickup" end
    return name
end

local function LoadEID(pickup)
    local data = pickup:GetData()
    if not EID.player then EID.player = Isaac.GetPlayer() end
    local desc = EID:getDescriptionObj(pickup.Type, pickup.Variant, pickup.SubType)

    if pickup.Variant == 70 then
        local pillColor = pickup.SubType
        local pool = SEWCOL.GAME:GetItemPool()
        local identified = pool:IsPillIdentified(pillColor)
        if (identified or EID.Config["ShowUnidentifiedPillDescriptions"]) then
            desc.Description = (SEWCOL.REFLECTION.EID[EID.UserConfig.Language] or SEWCOL.REFLECTION.EID.en_us)..desc.Description
        else
            if pillColor >= 2049 then
                pillColor = pillColor - 2048
            end
            desc.Name = "{{ColorError}}"..EID:getDescriptionEntry("unidentifiedPill")
            desc.Description = (SEWCOL.REFLECTION.EID[EID.UserConfig.Language] or SEWCOL.REFLECTION.EID.en_us)
        end
    elseif pickup.Variant == 100 then
        goto skipDesc
    else
        if not desc.Name or string.sub(desc.Name,1,2) == '5.' then
            desc.Name = getName(pickup.Variant)
        end

        if not desc.Description or desc.Description == '(no description available)' then 
            desc.Description = (SEWCOL.REFLECTION.EID[EID.UserConfig.Language] or SEWCOL.REFLECTION.EID.en_us)
        else
            desc.Description = (SEWCOL.REFLECTION.EID[EID.UserConfig.Language] or SEWCOL.REFLECTION.EID.en_us)..desc.Description
        end
    end
    
    data.EID_Description = desc

    ::skipDesc::
end

if EID then
    EID:addColor("SEWCOL_ColorReflect", nil, function(_)
        local maxAnimTime = 80
        local animTime = Game():GetFrameCount() % maxAnimTime
        local c = EID.InlineColors
        local colors = {KColor(0.5, 0.8, 1, 0.75), KColor(0.75, 0.75, 0.75, 0.5)}
        local colorFractions = (maxAnimTime - 1) / #colors
        local subAnm = math.floor(animTime / (colorFractions + 1)) + 1
        local primaryColorIndex = subAnm % (#colors + 1)
        if primaryColorIndex == 0 then
            primaryColorIndex = 1
        end
        local secondaryColorIndex = (subAnm + 1) % (#colors + 1)
        if secondaryColorIndex == 0 then
            secondaryColorIndex = 1
        end
        return EID:interpolateColors(
            colors[primaryColorIndex],
            colors[secondaryColorIndex],
            (animTime % (colorFractions + 1)) / colorFractions
        )
    end)

    local function EIDCondition(descObj) return descObj.Entity and descObj.Entity.GetData and descObj.Entity:GetData().SEWCOL_MIRRORED end
    local function EIDResult(description) 
        description.Description = (SEWCOL.REFLECTION.EID[EID.UserConfig.Language] or SEWCOL.REFLECTION.EID.en_us)..description.Description
        return description 
    end
    EID:addDescriptionModifier("SEWCOL MIRRORED", EIDCondition, EIDResult)
end

--##############################################################################--
--############################ APPLY EFFECT LOGIC ##############################--
--##############################################################################--
function SEWCOL.Reflect(pickup, isLoad)
    if (SEWCOL.REFLECTION.WHITELIST[pickup.Variant] == 'Chest' or pickup.Variant == 100) and pickup.SubType == 0 then
        pickup:Remove()
        SEWCOL.SFX:Play(SoundEffect.SOUND_FREEZE_SHATTER)
        Isaac.Spawn(1000, 15, 1, pickup.Position, Vector(0,0), pickup)
        return
    end

    if EID then
        LoadEID(pickup)
    end

    pickup:GetData().SEWCOL_MIRRORED = true

    applyReflectionColor(pickup)

    if not isLoad then
        SEWCOL.SFX:Play(SoundEffect.SOUND_URN_OPEN, 1.6, 1000, false, 2)
    end

    if pickup.Variant ~= 100 then
        pickup.Wait = 30
    end

    SEWCOL.SAVEDATA.REF_CACHE[tostring(pickup.InitSeed)] = true

    SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))

    return pickup
end

--##############################################################################--
--############################# NATURAL SPAWN LOGIC ############################--
--##############################################################################--
local function handleReflectionSpawns(_, pickup)
    if SEWCOL.SAVEDATA.CAN_SPAWN_REFLECTIONS and SEWCOL.REFLECTION.WHITELIST[pickup.Variant] and pickup.SpawnerType < 10 and (not SEWCOL.SAVEDATA.CANT_REFLECT_SHOP or not pickup:IsShopItem()) then
        local RNG = RNG()
        RNG:SetSeed(pickup:GetDropRNG():GetSeed(), 1)
        
        if RNG:RandomInt(1200)+1 <= (((SEWCOL.SAVEDATA.CAN_UP_REFLECTIONS and SEWCOL.SAVEDATA.BROKEN_MIRROR) and SEWCOL.REFLECTION.MIRROR_CHANCE or SEWCOL.REFLECTION.SPAWN_CHANCE) / ((pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == CoinSubType.COIN_PENNY) and 4 or 1)) then
            SEWCOL.Reflect(pickup)
        end
    end
end

TCC_API:AddTCCCallback("TCC_ON_SPAWN", handleReflectionSpawns)

if ModConfigMenu then
    ModConfigMenu.AddSetting("Sewage Collection", "Reflections", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return SEWCOL.SAVEDATA.CANT_REFLECT_SHOP end,
        OnChange = function(currentBool) 
            SEWCOL.SAVEDATA.CANT_REFLECT_SHOP = currentBool
            SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
        end,

        Info = {"Should reflections not be able to spawn in shops?"},
        Display = function()
            local onOff = "False"
            if SEWCOL.SAVEDATA.CANT_REFLECT_SHOP then onOff = "True" end
            return "Don't reflect shop items: " .. onOff
        end
    })
end
--##############################################################################--
--############################### COLLISION LOGIC ##############################--
--##############################################################################--
local questionMarkSprite = Sprite()
questionMarkSprite:Load("gfx/005.100_collectible.anm2",true)
questionMarkSprite:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
questionMarkSprite:LoadGraphics()

-- Stolen from EID >:)
local function IsQuestionMark(pickup)
	local entitySprite = pickup:GetSprite()
	local name = entitySprite:GetAnimation()

	questionMarkSprite:SetFrame(name,entitySprite:GetFrame())

	for i = -50,20,3 do
		local qcolor = questionMarkSprite:GetTexel(Vector(0,i),Vector(0,0),1,1)
		local ecolor = entitySprite:GetTexel(Vector(0,i),Vector(0,0),1,1)
		if qcolor.Red ~= ecolor.Red or qcolor.Green ~= ecolor.Green or qcolor.Blue ~= ecolor.Blue then
			return false
		end
	end
	
	for j = -1,1,1 do
		for i = -71,0,3 do
			local qcolor = questionMarkSprite:GetTexel(Vector(j,i),Vector(0,0),1,1)
			local ecolor = entitySprite:GetTexel(Vector(j,i),Vector(0,0),1,1)
			if qcolor.Red ~= ecolor.Red or qcolor.Green ~= ecolor.Green or qcolor.Blue ~= ecolor.Blue then
				return false
			end
		end
	end

	return true
end

local function getSubType(pickup)
    if pickup.SubType < 32768 then
        return pickup.SubType+32768
    else
        return pickup.SubType-32768
    end
end

local function isLostCursed(player)
    local playerType = player:GetPlayerType()

    if playerType == PlayerType.PLAYER_THELOST 
    or playerType == PlayerType.PLAYER_THELOST_B 
    or playerType == PlayerType.PLAYER_JACOB2_B then
        return true
    elseif player:GetHeadColor() == SkinColor.SKIN_WHITE and player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
        return true
    end

    return false
end

local function OnReflectCollision(_, pickup, collider, low)
    if collider.Type == EntityType.ENTITY_PLAYER and pickup:GetData().SEWCOL_MIRRORED and pickup.Wait <= 0 then
        -- if pickup.FrameCount > 40 or pickup.Variant == 100 then
            if (SEWCOL.REFLECTION.WHITELIST[pickup.Variant] == 'Chest' or pickup.Variant == 100) and pickup.SubType == 0 then
                pickup:Remove()
                SEWCOL.SFX:Play(SoundEffect.SOUND_FREEZE_SHATTER)
                Isaac.Spawn(1000, 15, 1, pickup.Position, Vector(0,0), pickup)
                return true
            end

            local data = pickup:GetData()
            local sprite = pickup:GetSprite()
            local player = collider:ToPlayer()
            player.Velocity = player.Velocity / 3

            player:TakeDamage(1, (DamageFlag.DAMAGE_NO_PENALTIES | (isLostCursed(player) and DamageFlag.DAMAGE_NOKILL or 0)), EntityRef(pickup), 0)
    
            local cachedPickupIndex = pickup.OptionsPickupIndex
            pickup.OptionsPickupIndex = 0

            if cachedPickupIndex ~= nil and cachedPickupIndex > 0 then
                for key, item in pairs(Isaac.FindByType(5)) do
                    if cachedPickupIndex == item:ToPickup().OptionsPickupIndex then
                        item:Remove()
                        Isaac.Spawn(1000, 15, 0, item.Position, Vector(0,0), item)
                    end
                end
            end

            -- Setup new item
            local wasHidden = IsQuestionMark(pickup)

            local vector = Isaac.GetFreeNearPosition(pickup.Position+(Vector((math.random(200)-100)/100, (math.random(200)-100)/100)*40), 0)
            if pickup.Variant == 100 or pickup:IsShopItem() then vector = SEWCOL.GAME:GetRoom():FindFreePickupSpawnPosition(vector) end

            local newPickup = SEWCOL.SeedSpawn(pickup.Type, pickup.Variant, pickup.Variant == 350 and getSubType(pickup) or pickup.SubType, vector, Vector(0,0), pickup):ToPickup()
            newPickup:GetData().SEWCOL_MIRRORED = false

            newPickup:SetColor(Color(1,1,1,1), -1, 99, false, false)

            if pickup.Price > 0 then
                newPickup.Price = math.ceil(pickup.Price/2)
            elseif pickup.Price == -4 then
                newPickup.Price = PickupPrice.PRICE_ONE_HEART
            elseif pickup.Price < 0 and pickup.Price > -3 then
                newPickup.Price = math.floor(pickup.Price/2)
            else
                newPickup.Price = pickup.Price 
            end

            if newPickup.Price ~= 0 then
                newPickup.AutoUpdatePrice = false
                newPickup.ShopItemId = -1
            end
            
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, vector, Vector(0,0), nil)

            -- Setup hidden state
            if wasHidden then
                newPickup:GetSprite():ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
                newPickup:GetSprite():LoadGraphics()

                sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
                sprite:LoadGraphics()
            end
            
            -- Morph old pickup into first split
            local pos = Isaac.GetFreeNearPosition(pickup.Position+(Vector((math.random(200)-100)/100, (math.random(200)-100)/100)*40), 0)
            
            if pickup.Variant == 100 or pickup:IsShopItem() then 
                pos = SEWCOL.GAME:GetRoom():FindFreePickupSpawnPosition(pos)
                pickup.TargetPosition = pos
            end

            pickup.Position = pos
            pickup.Velocity = Vector(0,0)
            pickup.Timeout = -1
            data.SEWCOL_MIRRORED = false
            sprite:Play("Appear", true)
            pickup:SetColor(Color(1,1,1,1),-1, 99, false, 2)

            if pickup.Price > 0 then
                local price = pickup.Price/2
                pickup.Price = price < 1 and 1 or math.floor(price)
            elseif pickup.Price == -4 then
                pickup.Price = PickupPrice.PRICE_THREE_SOULHEARTS
            elseif pickup.Price < 0 and pickup.Price > -3 then
                local price = pickup.Price/2
                pickup.Price = price > -1 and -1 or math.ceil(price)
            end
            
            if pickup.Price ~= 0 then
                pickup.AutoUpdatePrice = false
            end

            pickup.Wait = 35
            newPickup.Wait = 35

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, pickup.Position, Vector(0,0), nil)

            -- Remove EID if it existed
            if EID and data.EID_Description then
                if type(data.EID_Description) == "table" then
                    if data.EID_Description.Description then
                        local newDesc, replaced = string.gsub(data.EID_Description.Description, (SEWCOL.REFLECTION.EID[EID.UserConfig.Language] or SEWCOL.REFLECTION.EID.en_us), "")
                        data.EID_Description.Description = newDesc
                    end
                elseif type(data.EID_Description) == "string" then
                    local newDesc, replaced = string.gsub(data.EID_Description, (SEWCOL.REFLECTION.EID[EID.UserConfig.Language] or SEWCOL.REFLECTION.EID.en_us), "")
                    data.EID_Description = newDesc
                end
                
                data.EID_Description = nil
            end

            -- Play effects
            SEWCOL.SFX:Play(SoundEffect.SOUND_MIRROR_ENTER)
            SEWCOL.SFX:Play(SoundEffect.SOUND_FREEZE_SHATTER)

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, pickup.Position, Vector(0,0), nil)

            -- Save data
            SEWCOL.SAVEDATA.REF_CACHE[tostring(pickup.InitSeed)] = nil
            SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
        
        -- end
        return true
    end
end

SEWCOL:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, OnReflectCollision)

--##############################################################################--
--############################# PERSISTENCE LOGIC ##############################--
--##############################################################################--
local function OnPickupLoad(_, pickup)
    if SEWCOL.SAVEDATA.REF_CACHE[tostring(pickup.InitSeed)] then
        SEWCOL.Reflect(pickup, true)
    end
end

local function resetData(doMirror)
    SEWCOL.SAVEDATA.REF_CACHE = {}
    if doMirror then
        SEWCOL.SAVEDATA.BROKEN_MIRROR = false
    end
    SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
end

SEWCOL:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, OnPickupLoad)
SEWCOL:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() gameHasLoaded = false end)
SEWCOL:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, IsContinue)
    gameHasLoaded = true
    if not IsContinue then resetData(true) end
end)
SEWCOL:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function() 
    if gameHasLoaded then resetData(false) end
end)

--##############################################################################--
--######################### REFLECTIONS SHINE LOGIC ############################--
--##############################################################################--
local function onPickupRender(_, pickup)
	if pickup.FrameCount % 120 == 0 and pickup:GetData().SEWCOL_MIRRORED then
        if SEWCOL.SAVEDATA.DO_REFLECTION_SHINE then            
            local eff = Isaac.Spawn(1000, EffectVariant.RIPPLE_POOF, 0, pickup.Position+(pickup.SubType == 100 and Vector(0,0) or Vector(0, 8)), pickup.Velocity, pickup)
            eff:GetSprite().Scale = pickup.Variant == 100 and Vector(1.2, 1.2) or Vector(0.75, 0.75)
            
        end

        applyReflectionColor(pickup)
        -- local data = pickup:GetData()
        -- if not data.SEWCOL_MIR_COOL then
        --     data.SEWCOL_MIR_COOL = pickup.FrameCount
        -- elseif data.SEWCOL_MIR_COOL+30 < pickup.FrameCount then
        --     data.SEWCOL_MIR_COOL = nil
        -- end
    end
end

SEWCOL:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupRender)

if ModConfigMenu then
    ModConfigMenu.AddSetting("Sewage Collection", "Reflections", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return SEWCOL.SAVEDATA.DO_REFLECTION_SHINE end,
        OnChange = function(currentBool) 
            SEWCOL.SAVEDATA.DO_REFLECTION_SHINE = currentBool
            SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
        end,

        Info = {"Should reflections occasionally splash to help identify them?"},
        Display = function()
            local onOff = "False"
            if SEWCOL.SAVEDATA.DO_REFLECTION_SHINE then onOff = "True" end
            return "Splash reflections: " .. onOff
        end
    })
end

--##############################################################################--
--############################ MIRROR BREAK LOGIC ##############################--
--##############################################################################--
local function onUpdate()
	if not SEWCOL.SAVEDATA.BROKEN_MIRROR then
        local level = Game():GetLevel()
        if level:GetStage() == LevelStage.STAGE1_2 and (level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B) then
            local room = Game():GetRoom()
            for k,v in pairs({60, 74}) do
                if room:GetGridEntity(v) and room:GetGridEntity(v):GetType() == GridEntityType.GRID_DOOR and room:GetGridEntity(v):ToDoor().TargetRoomIndex == -100 then
                    if room:GetGridEntity(v).Desc.Variant == 8 then
                        SEWCOL.SAVEDATA.BROKEN_MIRROR = true
                        SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
                    end
                end
            end
        end
    end
end

SEWCOL:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

if ModConfigMenu then
    ModConfigMenu.AddSetting("Sewage Collection", "Reflections", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return SEWCOL.SAVEDATA.CAN_UP_REFLECTIONS end,
        OnChange = function(currentBool) 
            SEWCOL.SAVEDATA.CAN_UP_REFLECTIONS = currentBool
            SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
        end,

        Info = {"Should breaking the mirror in downpour/dross increase reflection chances?"},
        Display = function()
            local onOff = "False"
            if SEWCOL.SAVEDATA.CAN_UP_REFLECTIONS then onOff = "True" end
            return "Increase reflection chance: " .. onOff
        end
    })
end