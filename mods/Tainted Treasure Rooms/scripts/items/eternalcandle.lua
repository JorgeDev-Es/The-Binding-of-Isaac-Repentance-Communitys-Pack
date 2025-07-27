local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

mod.AllCurses = {
    LevelCurse.CURSE_OF_BLIND,
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_MAZE,
    LevelCurse.CURSE_OF_LABYRINTH,
}

mod.AllCursesNoFloorGen = {
    LevelCurse.CURSE_OF_BLIND,
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_MAZE,
}

function mod:HasCurse(curse)
    return (game:GetLevel():GetCurses() & curse > 0)
end

mod:AddCustomCallback("GAIN_COLLECTIBLE", function(_, player, collectibleType)
    player:AddEternalHearts(1)
end, TaintedCollectibles.ETERNAL_CANDLE)

mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, function(_, curses)
    if curses <= 0 then
        local level = game:GetLevel()
        local players = mod:GetPlayersHoldingCollectible(TaintedCollectibles.ETERNAL_CANDLE)
        if players then
            if level:CanStageHaveCurseOfLabyrinth(level:GetStage()) then
                local curse = mod:GetRandomElem(mod.AllCurses, players[1]:GetCollectibleRNG(TaintedCollectibles.ETERNAL_CANDLE))
                return curse
            else
                local curse = mod:GetRandomElem(mod.AllCursesNoFloorGen, players[1]:GetCollectibleRNG(TaintedCollectibles.ETERNAL_CANDLE))
                return curse
            end
        end
    end
end)

function mod:EternalCandlePlayerLogic(player, data, level)
    local sacredorbs = 0
    local savedata = mod.GetPersistentPlayerData(player)

    if player:HasCollectible(TaintedCollectibles.ETERNAL_CANDLE) then
        local curses = level:GetCurses()
        local effects = player:GetEffects()
        if curses <= 0 and not mod.applyingcurseofmaze then
            local curse = mod:GetRandomElem(mod.AllCursesNoFloorGen, player:GetCollectibleRNG(TaintedCollectibles.ETERNAL_CANDLE))
            if curse == LevelCurse.CURSE_OF_DARKNESS then --Using reversed Sun card is smoother visually than applying Darkness curse directly
                player:UseCard(Card.CARD_REVERSE_SUN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            else
                level:AddCurse(curse, false)
            end
        end
        if mod:HasCurse(LevelCurse.CURSE_OF_DARKNESS) then --Darkness grants reverse Sun card effect
            if not effects:HasNullEffect(NullItemID.ID_REVERSE_SUN) then
                player:UseCard(Card.CARD_REVERSE_SUN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
        end
        if mod:HasCurse(LevelCurse.CURSE_OF_MAZE) then --Maze has a 50% chance to map each room on the floor
            mod:CheckFullMapping(level, 0.5, player:GetCollectibleRNG(TaintedCollectibles.ETERNAL_CANDLE))
        end
        if mod:HasCurse(LevelCurse.CURSE_OF_THE_UNKNOWN) then --Unknown grants a higher damage buff the less total hearts you have
            local totalhearts = player:GetHearts() + player:GetSoulHearts()
            if data.TotalUnknownHearts then
                if totalhearts ~= data.TotalUnknownHearts then
                    data.TotalUnknownHearts = totalhearts
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            else
                data.TotalUnknownHearts = totalhearts
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        elseif data.TotalUnknownHearts then
            data.TotalUnknownHearts = nil
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
        if mod:HasCurse(LevelCurse.CURSE_OF_BLIND) then --Blind grants Sacred Orb effect
            sacredorbs = 1
        end
    end

    mod:CheckItemWisps(player, CollectibleType.COLLECTIBLE_SACRED_ORB, sacredorbs)
end

function mod:CheckFullMapping(level, chance, rng)
    chance = chance or 1.0
    mod.DoneFullMapping = mod.DoneFullMapping or 0
    if mod.DoneFullMapping < chance then
        rng = rng or RNG()
        local roomsList = level:GetRooms()
        for i = 0, roomsList.Size - 1 do
            local roomDesc = level:GetRoomByIdx(roomsList:Get(i).SafeGridIndex)
            if roomDesc then
                if chance then
                    if rng:RandomFloat() <= chance then
                        roomDesc.DisplayFlags = roomDesc.DisplayFlags | 5 
                    end
                else
                    roomDesc.DisplayFlags = roomDesc.DisplayFlags | 5 
                end
            end
        end
        level:UpdateVisibility()
        mod.DoneFullMapping = chance
    end
end

function mod:EternalCandleRoomClear(rng, spawnpos)
    if rng:RandomFloat() <= 0.2 and game:GetRoom():GetType() == RoomType.ROOM_DEFAULT then --20% chance to check for portal spawn
        local portal
        spawnpos = Isaac.GetFreeNearPosition(spawnpos, 40)
        if not mod.TreasureRoomVisited then
            portal = Isaac.Spawn(1000,161,0,spawnpos,Vector.Zero,nil)
        elseif not mod.SecretRoomVisited then
            portal = Isaac.Spawn(1000,161,2,spawnpos,Vector.Zero,nil)
        elseif not mod.BossRoomVisited then
            portal = Isaac.Spawn(1000,161,1,spawnpos,Vector.Zero,nil)
        else
            return
        end
        portal:GetSprite():Play("Open Animation")
        Isaac.Spawn(1000,15,0,spawnpos,Vector.Zero,npc)
        sfx:Play(SoundEffect.SOUND_THUMBSUP)
    end
end

function mod:EternalCandleNewRoom(room, roomtype)
    local centerpos = room:GetCenterPos()
    if roomtype == RoomType.ROOM_DEVIL then --2 Black Hearts
        Isaac.Spawn(5,10,6,Isaac.GetFreeNearPosition(centerpos + Vector(-40,0), 40), Vector.Zero, nil)
        Isaac.Spawn(5,10,6,Isaac.GetFreeNearPosition(centerpos + Vector(40,0), 40), Vector.Zero, nil)
    elseif roomtype == RoomType.ROOM_ANGEL then --2 Eternal Hearts, 1 Soul Heart
        Isaac.Spawn(5,10,4,Isaac.GetFreeNearPosition(centerpos + Vector(-40,0), 40), Vector.Zero, nil)
        Isaac.Spawn(5,10,4,Isaac.GetFreeNearPosition(centerpos + Vector(40,0), 40), Vector.Zero, nil)
        Isaac.Spawn(5,10,3,Isaac.GetFreeNearPosition(centerpos + Vector(0,40), 40), Vector.Zero, nil)
    end
end