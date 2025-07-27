local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local checkingForFortunes
local successfulFortuneChange

function mod:erflyCommandShit(cmd, params)
    cmd = string.lower(cmd)
    if checkingForFortunes then
        successfulFortuneChange = true
        checkingForFortunes = checkingForFortunes .. "\n" .. cmd .. " " .. params
    elseif cmd == "fortune" or cmd == "f" or cmd == "fortue" then
        mod:fortuneCommand(params)
        checkingForFortunes = params
        mod.scheduleForUpdate(function()
            if not successfulFortuneChange then
                checkingForFortunes = nil
            end            
        end, 1, ModCallbacks.MC_POST_RENDER, true)
        mod.scheduleForUpdate(function()
            if successfulFortuneChange then
                mod:fortuneCommand(checkingForFortunes or 0)
                checkingForFortunes = nil
                successfulFortuneChange = nil
            end
        end, 1, nil, true)
    elseif cmd == "rule" then
        mod:ShowRule()
    elseif cmd == "tortune" or cmd == "insult" or cmd == "fuck" then
        mod:ShowTortune()
    elseif cmd == "fortunecount" then
        mod:BuildFortuneTable(false, true)
    elseif cmd == "championall" then
        for _,entity in ipairs(Isaac.GetRoomEntities()) do
            local enemy = entity:ToNPC()
            if enemy then
                enemy:Morph(enemy.Type, enemy.Variant, enemy.SubType, math.random(10))
            end
        end
    elseif cmd == "gimmeall" then
        Isaac.GetPlayer():GetData().giveAllItems = true
        --[[local player = Isaac.GetPlayer()
        local itempool = game:GetItemPool()
        for i = 1, 1000 do
            local itemChoice = itempool:GetCollectible(math.random(ItemPoolType.NUM_ITEMPOOLS) - 1, true)
            player:AddCollectible(itemChoice)
        end]]
    elseif cmd == "taintme" then
        local player = Isaac.GetPlayer()
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/fiends_horn_tainted.anm2"))
        local sprite = player:GetSprite()
        sprite:ReplaceSpritesheet(1, "gfx/characters/costumes/player_tainted_fiend.png")
        sprite:ReplaceSpritesheet(4, "gfx/characters/costumes/player_tainted_fiend.png")
        sprite:ReplaceSpritesheet(12, "gfx/characters/costumes/player_tainted_fiend.png")
        sprite:LoadGraphics()
        player:SetPocketActiveItem(FiendFolio.ITEM.COLLECTIBLE.HORNCOB, ActiveSlot.SLOT_POCKET)
        player:GetData().TheRealTaintedFiend = true
    elseif cmd == "setallstatsto" then
        if tonumber(params) then
            local player = Isaac.GetPlayer()
            player.MoveSpeed = params
            player.MaxFireDelay = (30/params - 1)
            player.Damage = params
            player.TearRange = params * 40
            player.ShotSpeed = params
            player.Luck = params
        end
    elseif cmd == "forceprice" then
        for _, pickup in ipairs(Isaac.FindByType(5, -1, -1, false, false)) do
            pickup = pickup:ToPickup()
            pickup.AutoUpdatePrice = false
            pickup.ShopItemId = -1
            pickup.Price = params
        end
    end
end

function mod:erflyCustomCommandsPlayerUpdate(player, data)
    if data.giveAllItems then
        if player.FrameCount % 1 == 0 then
            local itempool = game:GetItemPool()
            local itemChoice = itempool:GetCollectible(math.random(ItemPoolType.NUM_ITEMPOOLS) - 1, true)
            player:AddCollectible(itemChoice)
        end
    end
end