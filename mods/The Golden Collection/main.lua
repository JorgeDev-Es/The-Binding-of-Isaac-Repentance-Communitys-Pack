GOLCG = RegisterMod("The Golden Collection", 1)

local json = require("json")

--[[##########################################################################
######################## MOD CONTENT IMPORT AND SETUP ########################
##########################################################################]]--

GOLCG.SAVEDATA = {
    CAN_SPAWN_FICHES = true,
    HOURGLASS = { IsActive = false, Rooms = {} },
    BLACK_CARD = { ["Debt"] = 0, ["IgnoreUpdates"] = 0, ['PickupFilter'] = nil }
}

GOLCG.SFX = SFXManager()
GOLCG.GAME = Game()

function GOLCG.getPrice(_, price, IsPickup, hasPoundOfFlesh, steamSaleMultiplier)
    if hasPoundOfFlesh then
        if IsPickup then
            return PickupPrice.PRICE_SPIKES
        else
            if type(price) == "number" and price < 25 then
                return PickupPrice.PRICE_ONE_HEART
            else --[[if price < 50 then]]
                return PickupPrice.PRICE_TWO_HEARTS
            -- else
                -- price = PickupPrice.PRICE_TWO_HEARTS -- PickupPrice.PRICE_THREE_SOULHEARTS
                -- Why is there no 3 red hearts price enum?
            end
        end
    elseif price == PickupPrice.PRICE_ONE_HEART then
        price = 25
    elseif price == PickupPrice.PRICE_TWO_HEARTS then
        price = 50
    elseif type(price) == "number" then
        if price >= 0 then
            if type(steamSaleMultiplier) == "number" and steamSaleMultiplier > 0 then
                price = math.ceil(price / (steamSaleMultiplier+1))
            end

            if price > 99 then return 99 end
            if price <= 0 then return PickupPrice.PRICE_FREE end
        end
    end

    return math.ceil(price)
end

function GOLCG.SeedSpawn(entType, variant, subtype, pos, vel, spawner, seed)
    local seed = seed or Random()

    if seed == 0 then seed = 1 end

    local ent = Game():Spawn(entType, variant or 0, pos, vel, spawner or nil, subtype or 0, seed or 1)

    return ent
end

function GOLCG.GetShooter(ent)
    if ent then
        if ent.SpawnerEntity and ent.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and ent.SpawnerEntity.Variant == FamiliarVariant.INCUBUS then
            if ent.SpawnerEntity:ToFamiliar().Player ~= nil then
                return ent.SpawnerEntity:ToFamiliar().Player:ToPlayer()
            end
        elseif ent.SpawnerType == EntityType.ENTITY_PLAYER then
            if ent.SpawnerEntity ~= nil then
                return ent.SpawnerEntity:ToPlayer()
            elseif ent.Parent ~= nil then
                return ent.Parent:ToPlayer()
            end
        end
    end

    return nil
end

function GOLCG.checkAllFam(var, id, amount)
    local numPlayers = GOLCG.GAME:GetNumPlayers()
    for i=1,numPlayers do
        local player = GOLCG.GAME:GetPlayer(tostring((i-1)))
        player:CheckFamiliar(var, (player:GetCollectibleNum(id)+player:GetEffects():GetCollectibleEffectNum(id))*(amount or 1), player:GetCollectibleRNG(id))
    end
end

function GOLCG.checkFlags(key, flags)
    local numPlayers = GOLCG.GAME:GetNumPlayers()
    for i=1,numPlayers do
        local player = GOLCG.GAME:GetPlayer(tostring((i-1)))
        if TCC_API:Has(key, player) then
            player:AddCacheFlags(flags)
            player:EvaluateItems()
        end
    end
end

-- Define content and path
local path = 'scripts.content.'
local content = {
    'molten_dime',    'ancient_hourglass',       'flakes_of_gold',  'spinning_cent',
    'childrens_fund', 'gold_rope',               'shining_clicker', 'quality_stamp', 
    'temptation',     'abundance',               'stolen_placard',  'nugget',
    'black_card',     'slot_machine_handle',     'cracked_penny',   'red_penny',
    'slot_reel',      'silver_lacquered_chisel', 'golden_god',      'fancy_brooch'
}

require('scripts.golcol_callbacks') -- Import custom/shared callbacks
require('scripts.golcol_data_manager') -- Import savedata manager
require('scripts.content.entities.cursed_coins') -- Import pickups
require('scripts.content.entities.dressing_machine') -- Import slot machine

-- Global slots table
GOLCG.machines = {
    [1] = 1, -- slot
    [2] = 2, -- blood donation
    [3] = 3, -- fortune
    [4] = 4, -- beggar
    [5] = 5, -- devil beggar
    [6] = 6, -- shell game
    [7] = 7, -- key begggar
    --[0] = 8, -- donation machine
    [8] = 9, -- bomb begggar
    --[0] = 10, -- reroll machine
    --[0] = 11, -- greed machine
    --[0] = 12, -- dressing mirror
    [9] = 13, -- charge bum
    --[0] = 14, -- tainted character?
    [10] = 15, -- hell game
    [11] = 16, -- crane game
    [12] = 17, -- confessional
    [13] = 18, -- rotten bum
    [14] = GOLCG.DRESSER_MACHINE -- custom slot machine
}

-- MiniMAPI icons
if MinimapAPI then
    local icons = Sprite()
    icons:Load("gfx/ui/GOLCOL_minimapi_icons.anm2", true)
    MinimapAPI:AddIcon("GOLCOL Poker penny", icons, "GolcolPokerPenny", 0)
    MinimapAPI:AddIcon("GOLCOL Poker nickel", icons, "GolcolPokerNickel", 0)
    MinimapAPI:AddIcon("GOLCOL Poker dime", icons, "GolcolPokerDime", 0)
    MinimapAPI:AddIcon("GOLCOL Mom dresser", icons, "GolcolSlotMomDresser", 0)
end

-- Import content
local contentImports = {}
for _, title in pairs(content) do table.insert(contentImports, require(path .. title)) end

local ModIcon = Sprite()
ModIcon:Load("gfx/ui/GOLCOL_mod_icon.anm2", true)
contentImports = TCC_API:InitContent(contentImports, "Golden Collection", "GolcolMod", ModIcon)

--[[##########################################################################
########################## MOD CONFIG MENU SETTINGS ##########################
##########################################################################]]--

if ModConfigMenu then
	local ModName = "Golden Collection"

	ModConfigMenu.UpdateCategory(ModName, { Info = {"Settings for enabling and disabling natural poker fiches spawning."} })

	ModConfigMenu.AddSetting(ModName, "Fiche spawn settings.", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return GOLCG.SAVEDATA.CAN_SPAWN_FICHES end,
        OnChange = function(currentBool) 
            GOLCG.SAVEDATA.CAN_SPAWN_FICHES = currentBool
            GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))
        end,
        Info = {"Fiches can spawn naturally?"},
        Display = function()
            local onOff = "False"
            if GOLCG.SAVEDATA.CAN_SPAWN_FICHES then onOff = "True" end
            return "Can spawn naturally: " .. onOff
        end
    })
end

--[[ ### DEV CODE ### --
local function loadItems()
    if Game():GetFrameCount() == 0 then
        local offset = 0
        local offsetY = 0
        for _, item in ipairs(contentImports) do
            if item.SHOW_DEV or true then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, item.TYPE, item.ID, Vector(320+offset, 300-offsetY), Vector(0, 0), nil)

                if item.TYPE == 350 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, item.TYPE, item.ID+32768, Vector(320+offset, 300-offsetY), Vector(0, 0), nil)
                end

                if offset == -200 then
                    offset = 0
                    offsetY = offsetY+50
                elseif offset == 0 then
                    offset = 50
                elseif offset > 0 then
                    offset = offset - (offset*2)
                else
                    offset = -1*offset+50
                end
            end
        end
    end
end

GOLCG:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, loadItems);
-- ### END DEV CODE ### ]]--