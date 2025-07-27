local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

function mod:BuzzingMagnetsOnFireTear(player, tear)
    if mod:BasicRoll(player.Luck, 6, 1, player:GetCollectibleRNG(TaintedCollectibles.BUZZING_MAGNETS)) then
        tear:GetData().TaintedRepulsion = true
        tear.Color = mod.ColorBuzzingMagnet
    end
end

function mod:InitRepulsionStatus(npc, data, didstatus, player)
    if didstatus then
        data.TaintedWallSlamCooldown = 0
        if player then
            data.TaintedRepulsionPlayer = player
        end
    end
end

function mod:BuzzingMagnetsEnemyLogic(npc, data)
    data.TaintedWallSlamCooldown = data.TaintedWallSlamCooldown - 1
    npc:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
    if not (npc:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) or npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE) then
        for i = 0, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i)
            if player.Position:Distance(npc.Position) < 120 then
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-player.Position) * 0.4, 0.25)
                if not player:GetData().SuccRing then
                    local succring = Isaac.Spawn(1000, 57, 2, player.Position, Vector.Zero, player):ToEffect()
                    succring:FollowParent(player)
                    player:GetData().SuccRing = succring
                end
                player:GetData().SuccRingTimer = 5
            end
        end
    end
    if npc:CollidesWithGrid() and data.TaintedWallSlamCooldown <= 0 then 
        local source = Isaac.GetPlayer(0)
        if data.TaintedRepulsionPlayer and data.TaintedRepulsionPlayer:Exists() then
            source = data.TaintedRepulsionPlayer
        end

        npc:TakeDamage(4, 0, EntityRef(source), 30)
        data.TaintedWallSlamCooldown = 5
        if npc:HasMortalDamage() then
            --sfx:Play(TaintedSounds.MAGNET_BUZZ, 0.5, 1, false, 1)
            npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
        end
    end
end

function mod:BuzzingMagnetsEnemyColl(npc, collider, data)
    if npc.Velocity:Length() > 8 then
        local source = Isaac.GetPlayer(0)
        if data.TaintedRepulsionPlayer and data.TaintedRepulsionPlayer:Exists() then
            source = data.TaintedRepulsionPlayer
        end

        npc:TakeDamage(5, 0, EntityRef(source), 2)
        collider:TakeDamage(5, 0, EntityRef(source), 2)
        sfx:Play(TaintedSounds.MAGNET_BUZZ, 0.5, 1, false, 1)
    end
end

function mod:BuzzingMagnetPlayerLogic(player, data)
    data.SuccRingTimer = data.SuccRingTimer - 1
    if data.SuccRingTimer <= 0 then
        data.SuccRing:Remove()
        data.SuccRing = nil
    end
end