local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

mod.SinToVirtueSubtypeMap = {
    [5] = 714,  -- Envy             --> Kindness
    [12] = 715, -- Super Envy       --> Super Kindness
    [1] = 716,  -- Lust             --> Chastity
    [8] = 717,  -- Super Lust       --> Super Chastity
    [4] = 718,  -- Greed            --> Charity
    [11] = 719, -- Super Greed      --> Super Charity
    [6] = 720,  -- Pride            --> Humility
    [13] = 721, -- Super Pride      --> Super Humility
    [0] = 722,  -- Sloth            --> Diligence
    [7] = 723,  -- Super Sloth      --> Super Diligence
    [3] = 724,  -- Gluttony         --> Temperance
    [10] = 725, -- Super Gluttony   --> Super Temperance
    [2] = 726,  -- Wrath            --> Patience
    [9] = 727,  -- Super Wrath      --> Super Patience
    [14] = 728, -- Ultra Pride      --> Ultra Diligence
}

function mod:IsAltPath()
    local level = game:GetLevel()
    if level:GetStageType() == StageType.STAGETYPE_REPENTANCE 
    or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B then
        return true
    elseif StageAPI and StageAPI.GetCurrentStage() then
        local customStage = StageAPI.GetCurrentStage()
        if customStage.LevelgenStage 
        and customStage.LevelgenStage.StageType
        and (customStage.LevelgenStage.StageType == StageType.STAGETYPE_REPENTANCE 
        or customStage.LevelgenStage.StageType == StageType.STAGETYPE_REPENTANCE_B) then
            return true
        end 
    end
    return false
end

function mod:CheckForVirtueSpawning()
    if mod:IsAltPath() then
        local level = game:GetLevel()
        for i = level:GetRooms().Size, 0, -1 do
            local roomDesc = level:GetRooms():Get(i-1)
            if roomDesc and roomDesc.Data then
                if roomDesc.Data.Type == RoomType.ROOM_MINIBOSS then
                    --print("Miniboss room found with Subtype "..roomDesc.Data.Subtype)
                    local newSub = mod.SinToVirtueSubtypeMap[roomDesc.Data.Subtype]
                    if newSub then
                        --print("Compatible virtue found, looking for room with Subtype "..newSub)
                        local layout = RoomConfigHolder.GetRandomRoom(roomDesc.SpawnSeed+1,true,StbType.SPECIAL_ROOMS,RoomType.ROOM_MINIBOSS,roomDesc.Data.Shape,nil,nil,nil,nil,roomDesc.Data.Doors,newSub)
                        if layout then
                            roomDesc.Data = layout
                            --print("Room replaced!")
                        end
                    end
                elseif roomDesc.Data.Type == RoomType.ROOM_SHOP or roomDesc.Data.Type == RoomType.ROOM_SECRET then
                    if roomDesc.Flags & RoomDescriptor.FLAG_SURPRISE_MINIBOSS == RoomDescriptor.FLAG_SURPRISE_MINIBOSS then
                        local newSub = game:GetStateFlag(GameStateFlag.STATE_GREED_SPAWNED) and 719 or 718
                        --print("Greed ambush detected, looking for room with Subtype "..newSub)
                        local layout = RoomConfigHolder.GetRandomRoom(roomDesc.SpawnSeed+1,true,StbType.SPECIAL_ROOMS,RoomType.ROOM_MINIBOSS,roomDesc.Data.Shape,nil,nil,nil,nil,roomDesc.Data.Doors,newSub)
                        if layout then
                            roomDesc.OverrideData = layout
                            --print("Ambush replaced!")
                        end
                    end
                end
            end
        end
    end
end

mod.VirtueRoomSubTypeToName = {
    [714] = "Kindness",
    [715] = "Super Kindness",
    [716] = "Chastity",
    [717] = "Super Chastity",
    [718] = "Charity",
    [719] = "Super Charity",
    [720] = "Humility",
    [721] = "Super Humility",
    [722] = "Diligence",
    [723] = "Super Diligence",
    [724] = "Temperance",
    [725] = "Super Temperance",
    [726] = "Patience",
    [727] = "Super Patience",
    [728] = "Ultra Diligence",
}

mod.VirtueGameFlagToSet = {
    [714] = GameStateFlag.STATE_ENVY_SPAWNED,
    [716] = GameStateFlag.STATE_LUST_SPAWNED,
    [718] = GameStateFlag.STATE_GREED_SPAWNED,
    [719] = GameStateFlag.STATE_SUPERGREED_SPAWNED,
    [720] = GameStateFlag.STATE_PRIDE_SPAWNED,
    [722] = GameStateFlag.STATE_SLOTH_SPAWNED,
    [724] = GameStateFlag.STATE_GLUTTONY_SPAWNED,
    [726] = GameStateFlag.STATE_WRATH_SPAWNED,
    [728] = GameStateFlag.STATE_ULTRAPRIDE_SPAWNED,
}

function mod:IsVirtueMinibossRoom(roomDesc)
    roomDesc = roomDesc or game:GetLevel():GetCurrentRoomDesc()
    if roomDesc and roomDesc.Data then
        return (roomDesc.Data.Type == RoomType.ROOM_MINIBOSS and mod.VirtueRoomSubTypeToName[roomDesc.Data.Subtype])
        or (roomDesc.OverrideData and roomDesc.OverrideData.Type == RoomType.ROOM_MINIBOSS and mod.VirtueRoomSubTypeToName[roomDesc.OverrideData.Subtype])
    end
    return false
end

function mod:CheckForVirtueRoomEntry()
    if not game:GetRoom():IsClear() then
        local roomDesc = game:GetLevel():GetCurrentRoomDesc()
        if roomDesc then
            local roomSub 
            if roomDesc.Data and roomDesc.Data.Type == RoomType.ROOM_MINIBOSS then
                roomSub = roomDesc.Data.Subtype
            elseif roomDesc.OverrideData and roomDesc.OverrideData.Type == RoomType.ROOM_MINIBOSS then
                roomSub = roomDesc.OverrideData.Subtype
            end

            if roomSub then
                local flag = mod.VirtueGameFlagToSet[roomSub]
                if flag then
                    game:SetStateFlag(flag, true)
                end

                local name = mod.VirtueRoomSubTypeToName[roomSub]
                if name then
                    game:GetHUD():ShowItemText(Isaac.GetPlayer():GetName().." vs "..name, "", false)
                end
            end
        end
    end
end

mod.VirtueDropData = {
    [mod.ENT.Kindness.Var] = {
        Pickup = {PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN},
        Item = CollectibleType.COLLECTIBLE_HALO,
    },
    [mod.ENT.SuperKindness.Var] = {
        Pickup = {PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN},
        Item = CollectibleType.COLLECTIBLE_OBSESSED_FAN,
        DoBigSplat = true,
    },
    [mod.ENT.Chastity.Var] = {
        Pickup = {PickupVariant.PICKUP_PILL, 0},
        Item = CollectibleType.COLLECTIBLE_VIRUS,
    },
    [mod.ENT.SuperChastity.Var] = {
        Pickup = {PickupVariant.PICKUP_PILL, 0},
        Item = CollectibleType.COLLECTIBLE_YUM_HEART,
        DoBigSplat = true,
    },
    [mod.ENT.Charity.Var] = {
        Pickup = {PickupVariant.PICKUP_LOCKEDCHEST, 0},
        Item = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,
    },
    [mod.ENT.SuperCharity.Var] = {
        Pickup = {PickupVariant.PICKUP_MEGACHEST, 0},
        Item = CollectibleType.COLLECTIBLE_SACK_OF_SACKS,
        DoBigSplat = true,
    },
    [mod.ENT.Humility.Var] = {
        Pickup = {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE},
        Item = CollectibleType.COLLECTIBLE_TORN_PHOTO,
    },
    [mod.ENT.SuperHumility.Var] = {
        Pickup = {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE},
        Item = CollectibleType.COLLECTIBLE_EMPTY_VESSEL,
    },
    [mod.ENT.Diligence.Var] = {
        Pickup = {PickupVariant.PICKUP_KEY, KeySubType.KEY_CHARGED},
        Item = CollectibleType.COLLECTIBLE_CAFFEINE_PILL,
    },
    [mod.ENT.SuperDiligence.Var] = {
        Pickup = {PickupVariant.PICKUP_KEY,  KeySubType.KEY_CHARGED},
        Item = CollectibleType.COLLECTIBLE_SQUEEZY,
        DoBigSplat = true,
    },
    [mod.ENT.Temperance.Var] = {
        Pickup = {PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN},
        Item = CollectibleType.COLLECTIBLE_ROTTEN_MEAT,
    },
    [mod.ENT.SuperTemperance.Var] = {
        Pickup = {PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN},
        Item = CollectibleType.COLLECTIBLE_LEECH,
        DoBigSplat = true,
    },
    [mod.ENT.Patience.Var] = {
        Pickup = {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, {3,5}},
        Item = CollectibleType.COLLECTIBLE_FAST_BOMBS,
    },
    [mod.ENT.SuperPatience.Var] = {
        Pickup = {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, {3,5}},
        Item = CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS,
        DoBigSplat = true,
    },
    [mod.ENT.DiligentRambler.Var] = {
        Pickup = {PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED, {2,3}},
        Item = CollectibleType.COLLECTIBLE_MYSTERY_SACK,
    },
    [mod.ENT.DiligentRattler.Var] = {
        Pickup = {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, {1,2}},
        Item = CollectibleType.COLLECTIBLE_MARROW,
    },
    [mod.ENT.DiligentStickler.Var] = {
        Pickup = {PickupVariant.PICKUP_TAROTCARD, Card.CARD_JUDGEMENT, {1,2}},
        Item = CollectibleType.COLLECTIBLE_DEATHS_LIST,
    },
    [mod.ENT.DiligentSlimer.Var] = {
        Pickup = {PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_BLACK}, --Black Sack
        Item = CollectibleType.COLLECTIBLE_BALL_OF_TAR,
    },
}

function mod:IsLastBoss(npc)
    for _, ent in pairs(Isaac.FindByType(npc.Type)) do
        if ent and ent.InitSeed ~= npc.InitSeed and ent:IsBoss() then
            return false
        end
    end
    return true
end

local itemPool = game:GetItemPool()
function mod:CheckVirtueDeath(npc)
    local dropData = mod.VirtueDropData[npc.Variant]
    if dropData and mod:IsLastBoss(npc) then
        if dropData.DoBigSplat then
            local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc)
            splat.Color = npc.SplatColor
            splat:Update()
            sfx:Play(SoundEffect.SOUND_ROCKET_BLAST_DEATH)
        end

        local failedPatienceGame = ((npc.Variant == mod.ENT.Patience.Var or npc.Variant == mod.ENT.SuperPatience.Var) and npc.I1 <= 0)
        local rng = npc:GetDropRNG()
        local spawnPos = (npc.Variant == mod.ENT.SuperHumility.Var and game:GetRoom():GetCenterPos() or npc.Position)
        if rng:RandomFloat() <= 0.33 and itemPool:HasCollectible(dropData.Item) and not failedPatienceGame then
            local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, dropData.Item, Isaac.GetFreeNearPosition(spawnPos, 0), Vector.Zero, npc):ToPickup()
            if npc.Variant == mod.ENT.Charity.Var then
                item:SetAlternatePedestal(PedestalType.GOLDEN_CHEST)
                sfx:Play(SoundEffect.SOUND_CHEST_DROP)
            elseif npc.Variant == mod.ENT.SuperCharity.Var then
                item:SetAlternatePedestal(PedestalType.MEGA_CHEST)
                sfx:Play(SoundEffect.SOUND_CHEST_DROP)
            end
        
        else
            if dropData.Pickup[3] and not failedPatienceGame then
                for i = 1, mod:RandomInt(dropData.Pickup[3],rng) do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, dropData.Pickup[1], dropData.Pickup[2], spawnPos, rng:RandomVector() * mod:RandomInt(3,7,rng), npc)
                end
            else
                Isaac.Spawn(EntityType.ENTITY_PICKUP, dropData.Pickup[1], dropData.Pickup[2], Isaac.GetFreeNearPosition(spawnPos, 0), Vector.Zero, npc)
            end
        end

        if mod:IsVirtueMinibossRoom() and not game:GetRoom():IsClear() then
            mod:PlayMinibossClearJingle()
        end
    end
end

function mod:PlayMinibossClearJingle()
    local music = MusicManager()
    music:PlayJingle(Music.MUSIC_JINGLE_CHALLENGE_OUTRO)
    music:Play(Music.MUSIC_BOSS_OVER, Options.MusicVolume)
end