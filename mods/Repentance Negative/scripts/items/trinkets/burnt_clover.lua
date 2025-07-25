local Mod = RepMMod
local config = Isaac.GetItemConfig()

local function IsBurntColver(trinket)
    return trinket == Mod.RepmTypes.TRINKET_BURNT_CLOVER or trinket == Mod.RepmTypes.TRINKET_BURNT_CLOVER | TrinketType.TRINKET_GOLDEN_FLAG
end

local function RemoveClover(trinket)
    if trinket > TrinketType.TRINKET_GOLDEN_FLAG then
        trinket = trinket & ~TrinketType.TRINKET_GOLDEN_FLAG
    else
        trinket = 0
    end
    return trinket
end

local function Burn(player)
    local destroyed = false
    ---@cast player EntityPlayer
    local t1 = player:GetTrinket(0)
    local t2 = player:GetTrinket(1)

    if t1 > 0 then
        player:TryRemoveTrinket(t1)
    end
    if t2 > 0 then
        player:TryRemoveTrinket(t2)
    end

    if IsBurntColver(t1) then
        t1 = RemoveClover(t1)
        destroyed = true
    elseif IsBurntColver(t2) then
        t2 = RemoveClover(t2)
        destroyed = true
    end

    if t1 > 0 then
        player:AddTrinket(t1, false)
    end
    if t2 > 0 then
        player:AddTrinket(t2, false)
    end

    if not destroyed then
        local clover = player:GetSmeltedTrinkets()[Mod.RepmTypes.TRINKET_BURNT_CLOVER]
        if clover.goldenTrinketAmount > 0 then
            player:TryRemoveSmeltedTrinket(Mod.RepmTypes.TRINKET_BURNT_CLOVER | TrinketType.TRINKET_GOLDEN_FLAG)
            player:AddSmeltedTrinket(Mod.RepmTypes.TRINKET_BURNT_CLOVER, false)
        else
            player:TryRemoveSmeltedTrinket(Mod.RepmTypes.TRINKET_BURNT_CLOVER)
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local room = Game():GetRoom()
    local tinketPlayers = Mod.Filter(PlayerManager.GetPlayers(), function(_, player) return player:HasTrinket(Mod.RepmTypes.TRINKET_BURNT_CLOVER) end)
	if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_TREASURE and #tinketPlayers > 0 then
		
        for _, item in ipairs(Isaac.FindByType(5, 100, -1)) do
            if item and item.SubType > 0 and PlayerManager.AnyoneHasTrinket(Mod.RepmTypes.TRINKET_BURNT_CLOVER) then
                local data = config:GetCollectible(item.SubType)
                if data.Quality and data.Quality ~= 4 then
                    local result = Mod.GetByQuality(4, 4, ItemPoolType.POOL_TREASURE, item.DropSeed)
                    if result then
                        item:ToPickup():Morph(5, 100, result, true, true)
                        Burn(tinketPlayers[math.random(1, #tinketPlayers)])
                    end
                end
            end
        end
    end
end)
