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
################################# VARIABLES ##################################
##########################################################################]]--
if not TCC_API.ITEM_LISTS then
    local itemConfig = Isaac.GetItemConfig()

    TCC_API.ITEM_LISTS = {
        [ItemType.ITEM_FAMILIAR] = {},
        [ItemType.ITEM_ACTIVE] = {},
        [ItemType.ITEM_PASSIVE] = {},
        SUMMON = {},
        BOOK = {},
        QUEST = {},
        HIDDEN = {},
    }

    -- Gets ran by MC_INPUT_ACTION callback that removes itself afterwards so that it can recognize items from mods loaded after this one
    function TCC_API:LoadItemListVariable()
        for i=1, itemConfig:GetCollectibles().Size -1 do
            local item = itemConfig:GetCollectible(i)

            if item then
                if item.Hidden then
                    TCC_API.ITEM_LISTS.HIDDEN[#TCC_API.ITEM_LISTS.HIDDEN+1] = i
                else
                    if item:HasTags(ItemConfig.TAG_QUEST) then
                        TCC_API.ITEM_LISTS.QUEST[#TCC_API.ITEM_LISTS.QUEST+1] = i
                    else
                        TCC_API.ITEM_LISTS[item.Type][#TCC_API.ITEM_LISTS[item.Type]+1] = i
                    end
                    
                    if item:HasTags(ItemConfig.TAG_SUMMONABLE) then TCC_API.ITEM_LISTS.SUMMON[#TCC_API.ITEM_LISTS.SUMMON+1] = i end
                    if item:HasTags(ItemConfig.TAG_BOOK) then TCC_API.ITEM_LISTS.BOOK[#TCC_API.ITEM_LISTS.BOOK+1] = i end  
                end
            end
        end

        TCC_API:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, TCC_API.LoadItemListVariable)
    end
    TCC_API:AddCallback(ModCallbacks.MC_INPUT_ACTION, TCC_API.LoadItemListVariable)

    function TCC_API:GetRandomCollectible(RNG, type)
        return TCC_API.ITEM_LISTS[type or ItemType.ITEM_PASSIVE][RNG:RandomInt(#TCC_API.ITEM_LISTS[type or ItemType.ITEM_PASSIVE])+1]
    end
end

--[[##########################################################################
########################## NATURAL SPAWN CALLBACKS ###########################
##########################################################################]]--
if not TCC_API.HandleNaturalData then
    TCC_API.NATURAL_PICKUPS = {}
    TCC_API.TRIGGERED_PICKUPS = {}

    local function runSpawnEvent(pickup)
        if TCC_API.CALLBACKS.TCC_ON_SPAWN then
            for i,d in pairs(TCC_API.CALLBACKS.TCC_ON_SPAWN) do
                if (not d.arg1 or pickup.Variant == d.arg1) and (not d.arg2 or pickup.SubType == d.arg2) then
                    d.Func(self, pickup) 
                end
            end
        end
    end

    function TCC_API:HandleNaturalData(type, variant, subType, position, velocity, spawner, seed)
        if TCC_API.CALLBACKS.TCC_ON_SPAWN and type == EntityType.ENTITY_PICKUP and (variant == 0 or subType == 0) then
            TCC_API.NATURAL_PICKUPS[seed] = true
        end
    end

    TCC_API:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, TCC_API.HandleNaturalData)

    function TCC_API:HandlePickups(pickup)
        if TCC_API.NATURAL_PICKUPS[pickup.InitSeed] and not TCC_API.TRIGGERED_PICKUPS[pickup.InitSeed] then
            TCC_API.TRIGGERED_PICKUPS[pickup.InitSeed] = true
            runSpawnEvent(pickup)
        end

        TCC_API.NATURAL_PICKUPS[pickup.InitSeed] = nil
    end

    TCC_API:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, TCC_API.HandlePickups)

    TCC_API:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function() TCC_API.TRIGGERED_PICKUPS = {} end)
end

--[[##########################################################################
############################ GRID EVENT CALLBACKS ############################
##########################################################################]]--
if not TCC_API.OnGridEvent then
    TCC_API.GRID_CACHE = {}

    local function RunGridEvent(callBack, entity)
        if TCC_API.CALLBACKS[callBack] then
            for i,d in pairs(TCC_API.CALLBACKS[callBack]) do
                if not d.arg1 or entity.Data.Type == d.arg1 then
                    d.Func(self, entity) 
                end
            end
        end
    end

    function TCC_API:OnGridEvent()
        if TCC_API.ENABLED.GRID then
            for i = 1, Game():GetRoom():GetGridSize() do
                local entity = Game():GetRoom():GetGridEntity(i)
                if entity then
                    if TCC_API.GRID_CACHE[i] then
                        if TCC_API.GRID_CACHE[i].state ~= entity.Desc.State then
                            TCC_API.GRID_CACHE[i] = { state = entity.Desc.State, type = entity.Desc.Type, var = entity.Desc.Variant }
                            RunGridEvent('TCC_GRID_BREAK', entity)
                        end
                    else
                        TCC_API.GRID_CACHE[i] = { state = entity.Desc.State, type = entity.Desc.Type, var = entity.Desc.Variant }
                        RunGridEvent('TCC_GRID_SPAWN', entity)
                    end
                end
            end
        end
    end

    function TCC_API:OnGridEventEnter()
        if TCC_API.ENABLED.GRID then
            for i = 1, Game():GetRoom():GetGridSize() do
                local ent = Game():GetRoom():GetGridEntity(i)
                if ent then
                    TCC_API.GRID_CACHE[i] = { state = ent.Desc.State, type = ent.Desc.Type, var = ent.Desc.Variant }
                else
                    TCC_API.GRID_CACHE[i] = nil
                end
            end
        end
    end

    TCC_API:AddCallback(ModCallbacks.MC_POST_UPDATE,   TCC_API.OnGridEvent     )
    TCC_API:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TCC_API.OnGridEventEnter)
end

--[[##########################################################################
############################ SLOT CHANGE CALLBACKS ###########################
##########################################################################]]--
if not TCC_API.OnMachineUpdate then
    local function RunSlotEvent(callBack, machine)
        if TCC_API.CALLBACKS[callBack] then
            for i,d in pairs(TCC_API.CALLBACKS[callBack]) do
                if not d.arg1 or machine.Variant == d.arg1 then
                    d.Func(self, machine) 
                end
            end
        end
    end

    function TCC_API:OnMachineUpdate()
        if TCC_API.ENABLED.SLOT then
            for _, machine in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT, -1, -1, false, true)) do
                if TCC_API.ENABLED.TCC_SLOT_UPDATE then
                    RunSlotEvent("TCC_SLOT_UPDATE", machine)
                end

                local sprite = machine:GetSprite()
                if TCC_API.ENABLED.TCC_MACHINE_BREAK and not machine:GetData().TCC_API_MACHINE and (sprite:IsPlaying('Broken') or sprite:IsPlaying('Death')) then
                    machine:GetData().TCC_API_MACHINE = true
                    RunSlotEvent("TCC_MACHINE_BREAK", machine)
                    goto endloop
                end

                if TCC_API.ENABLED.TCC_BEGGAR_LEAVE and not machine:GetData().TCC_API_BEGGAR and sprite:IsPlaying('Teleport') then
                    machine:GetData().TCC_API_BEGGAR = true
                    RunSlotEvent("TCC_BEGGAR_LEAVE", machine)
                end

                ::endloop::
            end
        end
    end

    TCC_API:AddCallback(ModCallbacks.MC_POST_UPDATE, TCC_API.OnMachineUpdate)
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

--[[##########################################################################
########################## NATURAL CURSES MANAGER ############################
##########################################################################]]--
if not TCC_API.OnCurseEval then
    TCC_API.ACTIVE_CURSES = {}
    TCC_API.CURSES = {}

    TCC_API.CURSE_WHITELIST = {
        [1] = LevelCurse.CURSE_OF_DARKNESS,
        [2] = LevelCurse.CURSE_OF_THE_LOST,
        [3] = LevelCurse.CURSE_OF_THE_UNKNOWN,
        [4] = LevelCurse.CURSE_OF_MAZE,
        [5] = LevelCurse.CURSE_OF_BLIND
    }

    local function flag(i) return 2^(i-1) end
    local function hasCurse(curses, curse)
        local flag = flag(curse)
        return curses % (flag + flag) >= flag
    end

    local function getCurseList(curses)
        local list = {}

        for i=1, #TCC_API.CURSE_WHITELIST do
            local curse = TCC_API.CURSE_WHITELIST[i]

            if curses % (curse + curse) >= curse then
                table.insert(list, curse)
            end
        end

        for key, curse in pairs(TCC_API.CURSES) do
            if hasCurse(curses, key) then
                table.insert(list, flag(key))
            end
        end

        return list
    end
    
    local function getCurseRNG(level)
        local RNG = RNG()
        local seed = level:GetDungeonPlacementSeed()
        
        if not seed or seed == 0 then
            seed = Game():GetSeeds():GetStartSeed()
        end
        
        RNG:SetSeed(seed or 1, 0)

        return RNG
    end

    function TCC_API:ReloadCurses(curses)
        local curses = curses or Game():GetLevel():GetCurses()
        for key, curse in pairs(TCC_API.CURSES) do
            curse.Disable()

            if hasCurse(curses, key) then
                curse.Enable()
            end
        end
    end

    function TCC_API:AddRandomCurse(passedRNG, replace)
        local level = Game():GetLevel()
        local RNG = passedRNG or getCurseRNG(level)
        local shouldRefresh = false
        local curses = level:GetCurses()
        RNG:Next()

        if replace and curses > 0 then
            local list = getCurseList(curses)

            if #list > 0 then
                local selection = list[RNG:RandomInt(#list)+1]
                level:RemoveCurses(selection)
                shouldRefresh = true
            end
        end

        if RNG:RandomInt(#TCC_API.CURSE_WHITELIST+#TCC_API.ACTIVE_CURSES)+1 <= #TCC_API.CURSE_WHITELIST then
            RNG:Next()
            local selection = TCC_API.CURSE_WHITELIST[RNG:RandomInt(#TCC_API.CURSE_WHITELIST)+1]

            local tries = 0
            while curses % (selection + selection) >= selection and tries < 15 do
                RNG:Next()
                selection = TCC_API.CURSE_WHITELIST[RNG:RandomInt(#TCC_API.CURSE_WHITELIST)+1]
                tries = tries+1
            end

            level:AddCurse(selection)
        else
            RNG:Next()
            local selection = TCC_API.ACTIVE_CURSES[RNG:RandomInt(#TCC_API.ACTIVE_CURSES)+1]
            
            local tries = 0
            while hasCurse(curses, selection) and tries < 15 do
                RNG:Next()
                selection = TCC_API.ACTIVE_CURSES[RNG:RandomInt(#TCC_API.ACTIVE_CURSES)+1]
                tries = tries+1
            end

            level:AddCurse(flag(selection))
            shouldRefresh = true
        end

        if shouldRefresh then
            TCC_API.ReloadCurses()
        end
    end

    function TCC_API:AddTCCCurse(id, Enable, Disable, IsEnabled, Spr, Fr)
        TCC_API.CURSES[id] = { ["Enable"] = Enable, ["Disable"] = Disable, ["Spr"] = Spr, ["Fr"] = Fr or 0 }

        if IsEnabled then table.insert(TCC_API.ACTIVE_CURSES, id) end

        if MinimapAPI and Spr then
            MinimapAPI:AddMapFlag(
                id,
                function() return hasCurse(Game():GetLevel():GetCurses(), id) end,
                Spr,
                'Idle',
                Fr or 0
            )
        end
    end

    function TCC_API:OnCurseEval(curses)
        -- Do nothing if value is incorrect (shouldn't happen unless other mods are interfering)
        if curses <= -1 then return nil end

        local hasReplaced = false    

        for key, curse in pairs(TCC_API.CURSES) do
            curse.Disable()
        end
        
        local RNG = getCurseRNG(CURCOL.GAME:GetLevel())

        if curses ~= LevelCurse.CURSE_NONE then
            local validCurse = 0

            for i=1, #TCC_API.CURSE_WHITELIST do
                local flag = TCC_API.CURSE_WHITELIST[i]
                if curses % (flag + flag) >= flag then
                    validCurse = flag
                    break
                end
            end

            if validCurse > 0 then
                local rand = RNG:RandomInt(#TCC_API.CURSE_WHITELIST+#TCC_API.ACTIVE_CURSES)+1

                if rand > #TCC_API.CURSE_WHITELIST then
                    curses = curses  & ~validCurse
                    curses = curses | flag(TCC_API.ACTIVE_CURSES[rand-#TCC_API.CURSE_WHITELIST])
                    hasReplaced = true
                end
            end
        end

        TCC_API:ReloadCurses(curses)

        -- It seems that this callback is bugged and doesn't continue when not returning nil.
        -- So make sure to return nil if no changes were made inorder to support other mods.
        -- TODO: Add support for curse related APIs in the future to prevent this issue.
        return hasReplaced and curses or nil
    end

    function TCC_API:ToggleCurse(id, enable)
        if enable then
            for i=1, #TCC_API.ACTIVE_CURSES do
                if TCC_API.ACTIVE_CURSES[i] == id then
                    return
                end
            end

            table.insert(TCC_API.ACTIVE_CURSES, id)
        else
            for i=1, #TCC_API.ACTIVE_CURSES do
                if TCC_API.ACTIVE_CURSES[i] == id then
                    table.remove(TCC_API.ACTIVE_CURSES, i)
                    break
                end
            end
        end
    end

    if not MinimapAPI then
        print("THE COLLECTION: Be advised! Curse icons may behave wierdly without MiniMAPI installed.")

        function TCC_API:OnCurseRender()
            local curses = Game():GetLevel():GetCurses()

            if curses > 255 and not Input.IsActionPressed(ButtonAction.ACTION_MAP, 0) then
                local corner = Vector(Isaac.GetScreenWidth(), 0)
                local HUDOffset = Options.HUDOffset * Vector(-20, 12)
                local curOffset = 0
                -- Isaac.GetScreenHeight()
                -- Isaac.GetScreenWidth()

                for key, value in pairs(TCC_API.CURSES) do
                    if hasCurse(curses, key) then
                        value.Spr:SetFrame('Idle', value.Fr)
                        value.Spr:Render(corner + HUDOffset + Vector(-66, 10+(16*curOffset)), Vector.Zero, Vector.Zero)
                        curOffset = curOffset + 1
                    end
                end
            end
        end

        TCC_API:AddCallback(ModCallbacks.MC_POST_RENDER, TCC_API.OnCurseRender)    
    end

    TCC_API:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.IMPORTANT, TCC_API.OnCurseEval)
    TCC_API:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(IsContinue) if IsContinue then TCC_API:ReloadCurses() end end)
    TCC_API:AddCallback(ModCallbacks.MC_POST_UPDATE, function() if Isaac.GetFrameCount() % 300 == 0 then TCC_API:ReloadCurses() end end)
end

--[[##########################################################################
############################ CHARGEBAR MANAGER ###############################
##########################################################################]]--
if not TCC_API.AddTCCChargeBar then
    -- local next = next 
    local CHARGEBAR_DIRECTIONS = {
        [0] = Vector(-1, 0),
        [1] = Vector(0, -1),
        [2] = Vector(1, 0),
        [3] = Vector(0, 1),
    }
    TCC_API.CHARGEBARS = {}
    TCC_API.CHARGESPRITES = {}

    local function setSprite(sprite, key, player)
        sprite:Play("Disappear")
        sprite:SetLastFrame()
        sprite:LoadGraphics()
        if not TCC_API.CHARGESPRITES[key] then TCC_API.CHARGESPRITES[key] = {} end
        TCC_API.CHARGESPRITES[key][player] = sprite
        return sprite
    end

    local function getBarPos(i, x, y)
        local extra = math.ceil(i/2)-1
        x = x - (extra*14)

        if i % 2 == 0 then
            x = x - 7
            y = y + 11
        end

        return Vector(x, y)
    end

    --TODO: FIND SOURCE OF CRASHING! (it's at the end of the function?) (it seems that this callback is being called 4x per second (should be 2x since it runs 0.5 logic steps))
    -- ^ Might have been next = next... continue testing
    function TCC_API:OnChargeUpdate(player, offset)
        if next(TCC_API.CHARGEBARS) ~= nil then
            if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
            or Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)
            or Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
            or Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
                local dir = player:GetHeadDirection()
                for key, curBar in pairs(TCC_API.CHARGEBARS) do
                    if curBar.isManaged and player:HasCollectible(curBar.item) then
                        if not curBar.charges[player.InitSeed] then curBar.charges[player.InitSeed] = 0 end
                        TCC_API.CHARGEBARS[key].charges[player.InitSeed] = curBar.charges[player.InitSeed]+1
                        curBar.dir = dir > -1 and CHARGEBAR_DIRECTIONS[dir] or CHARGEBAR_DIRECTIONS[0]
                        if curBar.onCharge
                        and curBar.charges[player.InitSeed] == curBar.max then
                            curBar.onCharge(player)
                        end
                    end
                end
            else
                for key, curBar in pairs(TCC_API.CHARGEBARS) do
                    if curBar.isManaged and player:HasCollectible(curBar.item) then
                        if curBar.onRelease
                        and curBar.charges[player.InitSeed] 
                        and curBar.charges[player.InitSeed] > curBar.max then
                            curBar.onRelease(player, curBar.dir or CHARGEBAR_DIRECTIONS[0])
                        end
            
                        curBar.charges[player.InitSeed] = 0
                    end
                end
            end
        end
    end

    function TCC_API:OnChargeRender(player, offset)
        if Options.ChargeBars then
            local pos = Isaac.WorldToScreen(player.Position)
            local x = pos.X - 11 - ((player.SpriteScale.X - 1) * 12)
            local y = pos.Y - (player.Size * 3) - (player.CanFly and 9 or 5) - (player.SpriteScale.Y < 1 and 0 or ((player.SpriteScale.Y - 1) * 35))
            local renderAmount = 0

            for key, curBar in pairs(TCC_API.CHARGEBARS) do
                local chargeBar = TCC_API.CHARGESPRITES[key][player.InitSeed] or setSprite(curBar.getSprite(), key, player.InitSeed)
                local curCharge = curBar.charges[player.InitSeed] or 0

                if curCharge > 0 then
                    if chargeBar:IsFinished('Charging') then
                        chargeBar:Play('StartCharged')
                        chargeBar.PlaybackSpeed =  0.5
                    elseif chargeBar:IsFinished('StartCharged') then
                        chargeBar:Play('Charged')
                        chargeBar.PlaybackSpeed = 0.5
                    elseif curCharge <= curBar.max then
                        chargeBar:Play('Charging')
                        chargeBar.PlaybackSpeed =  100/curBar.max
                        chargeBar:SetFrame(math.floor(curCharge / curBar.max * 100))
                    end
                elseif not chargeBar:IsPlaying('Disappear') then
                    chargeBar:Play('Disappear')
                    chargeBar.PlaybackSpeed =  0.5
                end

                if not chargeBar:IsFinished('Disappear') then
                    renderAmount = renderAmount+1
                    chargeBar:Render(getBarPos(renderAmount, x, y), Vector.Zero, Vector.Zero)
                    chargeBar:Update()
                end
            end
        end
    end

    function TCC_API:AddTCCChargeBar(key, getSprite, max, isManaged, item, onCharge, onRelease)
        TCC_API.CHARGEBARS[key] = {
            charges = {},
            getSprite = getSprite,
            max = max,
            isManaged = isManaged,
            item = item,
            onCharge = onCharge,
            onRelease = onRelease
        }
        TCC_API.CHARGESPRITES[key] = {}
    end

    function TCC_API:RemoveTCCChargeBar(key)
        TCC_API.CHARGEBARS[key] = nil
        TCC_API.CHARGESPRITES[key] = nil
    end

    CURCOL:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, TCC_API.OnChargeUpdate, 0)
    CURCOL:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, TCC_API.OnChargeRender, 0)
end