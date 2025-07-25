--[[##########################################################################
################################# INIT SETUP #################################
##########################################################################]]--
if not TCC_API or not TCC_API.AddTCCCallback then
    TCC_API = RegisterMod("The Collection Controller", 1)
    TCC_API.CALLBACKS = {}
    TCC_API.ENABLED = {}

    function TCC_API:AddTCCCallback(Type, Func, arg1, arg2, arg3)
        if TCC_API.CALLBACKS[Type] == nil then TCC_API.CALLBACKS[Type] = {} end
        table.insert(TCC_API.CALLBACKS[Type], { ["Func"] = Func, ["arg1"] = arg1, ["arg2"] = arg2, ["arg3"] = arg3 })

        if Type == "TCC_BEGGAR_LEAVE" or Type == "TCC_MACHINE_BREAK" or Type == "TCC_SLOT_UPDATE" then
            TCC_API.ENABLED.SLOT = true
        elseif Type == "TCC_GRID_SPAWN" or Type == "TCC_GRID_BREAK" then
            TCC_API.ENABLED.GRID = true
        end

        TCC_API.ENABLED[Type] = true
    end

    function TCC_API:RemoveTCCCallback(Type, Func, arg1, arg2, arg3)
        if TCC_API.CALLBACKS[Type] then
            for i=1, #TCC_API.CALLBACKS[Type] do
                local callback = TCC_API.CALLBACKS[Type][i]

                if callback and callback.Func == Func and callback.arg1 == arg1 and callback.arg2 == arg2 and callback.arg3 == arg3 then
                    TCC_API.CALLBACKS[Type][i] = nil
                end
            end

            if #TCC_API.CALLBACKS[Type] < 0 then
                if  (not TCC_API.CALLBACKS["TCC_BEGGAR_LEAVE"]  or #TCC_API.CALLBACKS["TCC_BEGGAR_LEAVE"] < 1 ) 
                and (not TCC_API.CALLBACKS["TCC_MACHINE_BREAK"] or #TCC_API.CALLBACKS["TCC_MACHINE_BREAK"] < 1) 
                and (not TCC_API.CALLBACKS["TCC_SLOT_UPDATE"]   or #TCC_API.CALLBACKS["TCC_SLOT_UPDATE"] < 1  ) then
                    TCC_API.ENABLED.SLOT = false
                elseif (not TCC_API.CALLBACKS["TCC_GRID_SPAWN"]  or #TCC_API.CALLBACKS["TCC_GRID_SPAWN"] < 1 )
                and    (not TCC_API.CALLBACKS["TCC_GRID_BREAK"]  or #TCC_API.CALLBACKS["TCC_GRID_BREAK"] < 1 ) then
                    TCC_API.ENABLED.GRID = false
                end

                TCC_API.ENABLED[Type] = false
            end
        end
    end
end

if not TCC_API.InitContent then
    function TCC_API:InitContent(data, mod, icon, iconSprite)
        if EID and icon then
            if iconSprite then
                EID:addIcon(icon, "Idle", 0, 40, 6, 2, 3, iconSprite)
            end

            EID:setModIndicatorName(mod)
            EID:setModIndicatorIcon(icon)    
        end

        for _, item in ipairs(data) do
            if EID and item.EID_DESCRIPTIONS then
                for i=1, #item.EID_DESCRIPTIONS do
                    if item.TYPE == 100 then
                        EID:addCollectible(item.ID, item.EID_DESCRIPTIONS[i].DESC, item.EID_DESCRIPTIONS[i].NAME, item.EID_DESCRIPTIONS[i].LANG)
                    elseif item.TYPE == 300 then
                        EID:addCard(item.ID, item.EID_DESCRIPTIONS[i].DESC, item.EID_DESCRIPTIONS[i].NAME, item.EID_DESCRIPTIONS[i].LANG)
                        local cardFrontSprite = Sprite()
                        cardFrontSprite:Load(item.FRONT, true)
                        EID:addIcon("Card"..item.ID, "Idle", -1, 8, 8, 0, 1, cardFrontSprite)
                    elseif item.TYPE == 70 then
                        EID:addPill(item.ID, item.EID_DESCRIPTIONS[i].DESC, item.EID_DESCRIPTIONS[i].NAME, item.EID_DESCRIPTIONS[i].LANG)
                    else
                        EID:addTrinket(item.ID, item.EID_DESCRIPTIONS[i].DESC, item.EID_DESCRIPTIONS[i].NAME, item.EID_DESCRIPTIONS[i].LANG)
                    end
                end

                if item.EID_TRANS then
                    EID:assignTransformation(table.unpack(item.EID_TRANS))
                end
            end
            
            if Encyclopedia and (item.EID_DESCRIPTIONS or item.ENC_DESCRIPTION) then
                if item.TYPE == 100 then
                    local pools = {}
                    if item.POOLS then
                        for i, pool in ipairs(item.POOLS) do table.insert(pools, (pool+1)) end    
                    end
                    Encyclopedia.AddItem({
                        Class = mod,
                        ModName = mod,
                        ID = item.ID,
                        WikiDesc = item.ENC_DESCRIPTION and item.ENC_DESCRIPTION or Encyclopedia.EIDtoWiki(item.EID_DESCRIPTIONS[1].DESC),
                        Pools = pools
                    })    
                elseif item.TYPE == 300 then
                    Encyclopedia.AddCard({
                        Class = mod,
                        ModName = mod,
                        ID = item.ID,
                        WikiDesc = item.ENC_DESCRIPTION and item.ENC_DESCRIPTION or Encyclopedia.EIDtoWiki(item.EID_DESCRIPTIONS[1].DESC),
                        Sprite = Encyclopedia.RegisterSprite(item.BACK, "Idle"),
                    })
                elseif item.TYPE == 70 then
                    Encyclopedia.AddPill({
                        Class = mod,
                        ID = item.ID,
                        WikiDesc = item.ENC_DESCRIPTION and item.ENC_DESCRIPTION or Encyclopedia.EIDtoWiki(item.EID_DESCRIPTIONS[1].DESC),
                        Color = item.COLOR,
                      })
                else
                    Encyclopedia.AddTrinket({
                        Class = mod,
                        ModName = mod,
                        ID = item.ID,
                        WikiDesc = item.ENC_DESCRIPTION and item.ENC_DESCRIPTION or Encyclopedia.EIDtoWiki(item.EID_DESCRIPTIONS[1].DESC)
                    }) 
                end
            end
        end
    end
end

--[[##########################################################################
############################ ITEM QUEUE CALLBACKS ############################
##########################################################################]]--
if not TCC_API.OnQueueEvent then
    TCC_API.QUEUE_CACHE = {}

    local function RunQueueEvent(callBack, pickupId, player, touched, isTrinket)
        if TCC_API.CALLBACKS[callBack] then
            for i,d in pairs(TCC_API.CALLBACKS[callBack]) do
                if (not d.arg1 or pickupId == d.arg1) and (not d.arg2 or isTrinket == d.arg2) then
                    d.Func(self, player, pickupId, touched, isTrinket) 
                end
            end
        end
    end

    local function QueueHasGained(player)
        if TCC_API.QUEUE_CACHE[player.InitSeed].IsTrinket then
            if TCC_API.QUEUE_CACHE[player.InitSeed].Amount < player:GetTrinketMultiplier(TCC_API.QUEUE_CACHE[player.InitSeed].ID) then
                RunQueueEvent("TCC_EXIT_QUEUE", TCC_API.QUEUE_CACHE[player.InitSeed].ID, player, TCC_API.QUEUE_CACHE[player.InitSeed].Touched, true) -- got added
            end
        else
            if TCC_API.QUEUE_CACHE[player.InitSeed].Amount < player:GetCollectibleNum(TCC_API.QUEUE_CACHE[player.InitSeed].ID, true) then
                RunQueueEvent("TCC_EXIT_QUEUE", TCC_API.QUEUE_CACHE[player.InitSeed].ID, player, TCC_API.QUEUE_CACHE[player.InitSeed].Touched, false) -- got added
            else
                RunQueueEvent("TCC_VOID_QUEUE", TCC_API.QUEUE_CACHE[player.InitSeed].ID, player, TCC_API.QUEUE_CACHE[player.InitSeed].Touched, false) -- got destroyed
            end
        end

        TCC_API.QUEUE_CACHE[player.InitSeed] = nil
    end

    function TCC_API:OnQueueEvent(player)
        local itemqueue = player.QueuedItem
        if itemqueue and itemqueue.Item then
            if TCC_API.QUEUE_CACHE[player.InitSeed] and (TCC_API.QUEUE_CACHE[player.InitSeed].ID ~= itemqueue.Item.ID) then
                QueueHasGained(player)
            end

            -- got picked up/queued
            if not TCC_API.QUEUE_CACHE[player.InitSeed] then RunQueueEvent("TCC_ENTER_QUEUE", itemqueue.Item.ID, player, itemqueue.Touched, itemqueue.Item:IsTrinket()) end

            TCC_API.QUEUE_CACHE[player.InitSeed] = { 
                ["ID"] = itemqueue.Item.ID,
                ["Amount"] = itemqueue.Item:IsTrinket() and player:GetTrinketMultiplier(itemqueue.Item.ID)-1 or player:GetCollectibleNum(itemqueue.Item.ID, true),
                ["Touched"] = itemqueue.Touched,
                ["IsTrinket"] = itemqueue.Item:IsTrinket(),
            }
        elseif TCC_API.QUEUE_CACHE[player.InitSeed] then
            QueueHasGained(player)
        end
    end

    TCC_API:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, TCC_API.OnQueueEvent)
end

--[[##########################################################################
############################# INVENTORY MANAGER ##############################
##########################################################################]]--
if not TCC_API.OnCacheTrigger then
    TCC_API.INV_STATE = { active = false, position = 1 }
    TCC_API.INV_GLO = {}
    TCC_API.INV = {}
    TCC_API.INV_SUBS = {}
    TCC_API.INV_ENABLED = {}
    TCC_API.INV_ITER_LIMIT = 4

    function TCC_API:AddTCCInvManager(id, type, key, Enable, Disable) 
        TCC_API.INV_SUBS[#TCC_API.INV_SUBS+1] = { ["KEY"] = key, ["TYPE"] = type, ["ID"] = id, ["Enable"] = Enable, ["Disable"] = Disable }
        TCC_API.INV_GLO[key] = 0
    end

    function TCC_API:Has(key, player, type) return (TCC_API.INV[player.InitSeed] and TCC_API.INV[player.InitSeed][key]) and TCC_API.INV[player.InitSeed][key][type or "Num"] or 0 end
    function TCC_API:HasGlo(key) return TCC_API.INV_GLO[key] or 0 end

    function TCC_API:OnCacheTrigger()
        if TCC_API.INV_STATE.active then
            TCC_API.INV_STATE.active = 2
        else
            TCC_API.INV_STATE = { active = 1, position = 1 }
            TCC_API:AddCallback(ModCallbacks.MC_POST_UPDATE, TCC_API.IterateSubs)
        end
    end

    function TCC_API:IterateSubs()
        if TCC_API.INV_STATE.active then
            local iter = 0
            local numPlayers = Game():GetNumPlayers()

            for i=1,numPlayers do
                if not TCC_API.INV[Game():GetPlayer(i-1).InitSeed] then TCC_API.INV[Game():GetPlayer(i-1).InitSeed] = {} end
            end

            for i=TCC_API.INV_STATE.position, #TCC_API.INV_SUBS do
                local value = TCC_API.INV_SUBS[i]

                if value.TYPE == 100 then
                    local num = 0
                    for j=1,numPlayers do
                        local player = Game():GetPlayer(j-1)
                        local colNum = player:GetCollectibleNum(value.ID)

                        TCC_API.INV[player.InitSeed][value.KEY] = {
                            ["Num"] = colNum,
                            ["Eff"] = player:GetEffects():GetCollectibleEffectNum(value.ID)
                        }

                        num = num + colNum
                    end

                    TCC_API.INV_GLO[value.KEY] = num
                else
                    local num = 0
                    for j=1,numPlayers do
                        local player = Game():GetPlayer(j-1)
                        local triNum = player:GetTrinketMultiplier(value.ID)

                        TCC_API.INV[player.InitSeed][value.KEY] = {
                            ["Num"] = triNum,
                            ["Eff"] = player:GetEffects():GetTrinketEffectNum(value.ID)
                        }

                        num = num + triNum
                    end

                    TCC_API.INV_GLO[value.KEY] = num
                end

                if TCC_API.INV_GLO[value.KEY] > 0 then
                    if not TCC_API.INV_ENABLED[value.KEY] then
                        TCC_API.INV_ENABLED[value.KEY] = true
                        value.Enable()
                    end
                else
                    if TCC_API.INV_ENABLED[value.KEY] then
                        TCC_API.INV_ENABLED[value.KEY] = nil
                        value.Disable()
                    end
                end

                iter=iter+1
                if iter >= TCC_API.INV_ITER_LIMIT then 
                    TCC_API.INV_STATE.position = TCC_API.INV_STATE.position+iter
                    return
                end
            end

            if TCC_API.INV_STATE.active == 2 then
                TCC_API.INV_STATE = { active = 1, position = 1 }
            else
                TCC_API.INV_STATE = { active = false, position = 1 }
                TCC_API:RemoveCallback(ModCallbacks.MC_POST_UPDATE, TCC_API.IterateSubs)
            end
        end
    end

    function TCC_API:DisableAllSubs()
        for key, value in pairs(TCC_API.INV_SUBS) do
            if TCC_API.INV_ENABLED[key] then
                value.Disable()
                TCC_API.INV_ENABLED[key] = nil
                TCC_API.INV_GLO[key] = 0
            end
        end

        TCC_API.INV = {}
    end

    TCC_API:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, TCC_API.OnCacheTrigger, CacheFlag.CACHE_WEAPON)
    TCC_API:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, TCC_API.DisableAllSubs)
end