---@param bomb EntityBomb
local function IsActive(bomb)
    local isGigaBobbyBomb = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        bomb,
        "IsGigaBobbyBomb"
    ) ~= nil

    return bomb:HasTearFlags(TearFlags.TEAR_HOMING) or isGigaBobbyBomb
end


local function GetHighestHPEnemy()
    local npcs = TSIL.EntitySpecific.GetNPCs()
    local vulnerableEnemies = TSIL.Utils.Tables.Filter(npcs, function (_, npc)
        return npc:IsVulnerableEnemy() and npc:IsActiveEnemy(false) and not
        npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL | EntityFlag.FLAG_CHARM)
    end)
    table.sort(vulnerableEnemies, function (a, b)
        return a.HitPoints > b.HitPoints
    end)
    return vulnerableEnemies[1]
end


---@param bomb EntityBomb
local function OnUpdate(bomb)
    local isGigaBobbyBomb = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        bomb,
        "IsGigaBobbyBomb"
    ) ~= nil

    if not isGigaBobbyBomb then
        bomb:ClearTearFlags(TearFlags.TEAR_HOMING)
        TSIL.Entities.SetEntityData(
            GigaBombsSynergiesMod,
            bomb,
            "IsGigaBobbyBomb",
            true
        )
    end

    local sprite = bomb:GetSprite()

    if sprite:GetFilename() == "gfx/GigaBobbyBomb.anm2" then
        if sprite:IsEventTriggered("teleport") then
            SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1)
            local enemy = GetHighestHPEnemy()
            if not enemy then return end
            bomb.Position = enemy.Position
        end
    else
        if not sprite:IsPlaying("Pulse") then return end

        local currentFrame = sprite:GetFrame()
        local lastFrame = TSIL.Sprites.GetLastFrameOfAnimation(sprite)

        if currentFrame == lastFrame then
            SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1)
            local enemy = GetHighestHPEnemy()
            if not enemy then return end
            bomb.Position = enemy.Position
        end
    end
end


GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaBobbyBombs",
    IsActive,
    nil,
    OnUpdate,
    "GigaBobbyBomb"
)


---@param player EntityPlayer
local function OnRemoteDetonatorUse(_, _, _, player)
    local playerIndex = TSIL.Players.GetPlayerIndex(player)
    local gigaBombs = TSIL.EntitySpecific.GetBombs(BombVariant.BOMB_GIGA)

    local bobbyGigaBombs = TSIL.Utils.Tables.Filter(gigaBombs, function (_, bomb)
        local otherPlayer = TSIL.Players.GetPlayerFromEntity(bomb)
        if not otherPlayer then return false end

        local otherPlayerIndex = TSIL.Players.GetPlayerIndex(player)
        return IsActive(bomb) and playerIndex == otherPlayerIndex
    end)

    local enemy = GetHighestHPEnemy()
    TSIL.Utils.Tables.ForEach(bobbyGigaBombs, function (_, bomb)
        bomb.Position = enemy.Position
    end)
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    OnRemoteDetonatorUse,
    CollectibleType.COLLECTIBLE_REMOTE_DETONATOR
)