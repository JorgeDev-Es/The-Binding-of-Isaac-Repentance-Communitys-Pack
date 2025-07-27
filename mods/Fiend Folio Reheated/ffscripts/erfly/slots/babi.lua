local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local babiSpawnOffsets = {
    {0}, {0}, {0},
    {-25, 25}, {25, -25},
    {-50, 0, 50},
}

local function findBabisTrinkets(slot)
    local trinkets = {}
    for _, trinket in pairs(Isaac.FindByType(5, 350)) do
        trinket = trinket:ToPickup()
        if trinket and trinket.OptionsPickupIndex ~= 0 and trinket.OptionsPickupIndex == slot.SubType % 1048576 then
            table.insert(trinkets, trinket)
        elseif trinket.OptionsPickupIndex == 0 and game:GetRoom():GetFrameCount() <= 1 then
            --Horrid check because of luarooms
            for i = -50, 50, 25 do
                if trinket.Position:Distance(slot.Position+Vector(i,25)) < 1 then
                    trinket.OptionsPickupIndex = slot.SubType % 1048576
                    table.insert(trinkets, trinket)
                end
            end
        end
    end
    if #trinkets > 0 then
        return trinkets
    else
        return false
    end
end

local function determineBabiTrinketPrice(trinket)
    if mod.anyPlayerHas(mod.ITEM.TRINKET.DEALMAKERS, true) then
        if trinket.AutoUpdatePrice and trinket.Price >= 0 then
            trinket.Price = -1
            trinket.AutoUpdatePrice = false
            trinket.ShopItemId = -1
        end
        return
    end

    trinket.AutoUpdatePrice = false
    trinket.ShopItemId = -1
    if mod.anyPlayerHas(TrinketType.TRINKET_YOUR_SOUL, true) then
        trinket.Price = -6
    elseif mod:anyPlayerIsEitherKeeper()
    or mod.anyPlayerHas(CollectibleType.COLLECTIBLE_POUND_OF_FLESH)
    or mod.anyPlayerHas(TrinketType.TRINKET_KEEPERS_BARGAIN, true) and math.floor(trinket.OptionsPickupIndex + trinket.Position.X) % 3 == 1 then --Don't even ask
        local defaultPrice = 10
        if FiendFolio.RockTrinkets[trinket.SubType] and FiendFolio.RockTrinkets[mod:GetRealTrinketId(trinket.SubType)] >= 2 then
            defaultPrice = 15
        end
        local steamSaleNum = 1
        mod.AnyPlayerDo(function(player)
            steamSaleNum = steamSaleNum + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_STEAM_SALE)
        end)
        trinket.Price = math.floor(defaultPrice / steamSaleNum)
    elseif mod.isAnyoneCharacter(PlayerType.PLAYER_BLUEBABY) then
        if FiendFolio.RockTrinkets[trinket.SubType] and FiendFolio.RockTrinkets[mod:GetRealTrinketId(trinket.SubType)] >= 2 then
            trinket.Price = -8
        else
            trinket.Price = -7
        end
    else
        local anyContainers
        mod.AnyPlayerDo(function(player)
            if player:GetMaxHearts() > 0 then
                anyContainers = true
            end
        end)
        if not anyContainers then
            trinket.Price = -3
        else
            --Default behaviour
            trinket.Price = -1
        end
    end
end

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, d, rng = slot:GetSprite(), slot:GetData(), slot:GetDropRNG()

    if not d.init then
        if slot.SubType >= 1048576 then
            slot:Remove()
            return
        end
        d.state = "idle"
        if not findBabisTrinkets(slot, true) and slot.SubType < 1048576 then
            slot.SubType = slot.InitSeed % 1048576
            local spawnsets = rng:RandomInt(#babiSpawnOffsets) + 1
            for i = 1, #babiSpawnOffsets[spawnsets] do
                local rocksub
                if i == 2 or #babiSpawnOffsets[spawnsets] == 1 then
                    rocksub = FiendFolio.GetGolemTrinket({2, 3})
                else
                    rocksub = FiendFolio.GetGolemTrinket({1, 2, 3})
                end
                local trinket = Isaac.Spawn(5, 350, rocksub, slot.Position + Vector(babiSpawnOffsets[spawnsets][i], 25), nilvector, slot):ToPickup()
                trinket.OptionsPickupIndex = slot.InitSeed % 1048576
                determineBabiTrinketPrice(trinket)
                trinket:Update()
            end
        end
        d.NoDestroy = true
        d.Anims = { 
            "Idle",
            "Sell",
        }
        d.init = true
    end

    d.Position = d.Position or slot.Position
    slot.Velocity = nilvector
    slot.Position = d.Position

    if d.state == "idle" then
        trinkets = findBabisTrinkets(slot)
        if not trinkets then
            d.state = "sell"
            sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL, 1, 0, false, 1)
        else
            for _, trinket in pairs(trinkets) do
                determineBabiTrinketPrice(trinket)
            end
        end
    elseif d.state == "sell" then
        if slot.SubType < 1048576 then
            slot.SubType = slot.SubType + 1048576
        end
        if sprite:IsFinished("Sell") then
            slot:Remove()
        elseif sprite:IsEventTriggered("Twink") then
            sfx:Play(mod.Sounds.DrShambleHeal, 1, 0, false, 0.7)
        elseif sprite:IsEventTriggered("Swish") then
            sfx:Play(mod.Sounds.WingFlap, 0.4, 0, false, 0.6)
        elseif sprite:IsEventTriggered("Grab") then
            --sfx:Play(SoundEffect.SOUND_KISS_LIPS1, 0.3, 0, false, 0.7)
        elseif sprite:IsEventTriggered("Snap") then
            sfx:Play(mod.Sounds.FingerSnapCool, 1, 0, false, 1)
        elseif sprite:IsEventTriggered("Leave") then
            sfx:Play(SoundEffect.SOUND_HELL_PORTAL1, 1, 0, false, 1)
            game:MakeShockwave(slot.Position, 0.035, 0.025, 10)
        else
            mod:spritePlay(sprite, "Sell")
        end
    else
        d.state = "idle"
    end
    
    FiendFolio.StopExplosionHack(slot)
end, mod.FF.Babi.Var)

--[[FiendFolio.onMachineTouch(mod.FF.Babi.Var, function(player, slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'BabiData', tostring(slot.InitSeed), {})
    
    if d.state == "idle" then

    end
end)]]