local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local sadonion = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SAD_ONION)

function mod:SorrowfulShallotPlayerLogic(player, data, savedata)
    if player:HasCollectible(TaintedCollectibles.SORROWFUL_SHALLOT) then
        if not data.SorrowfulShallotCooldown then
            player:AddCostume(sadonion, false)
            data.SorrowfulShallotCooldown = player.MaxFireDelay
        end

        savedata.SorrowfulKills = savedata.SorrowfulKills or 1
        if savedata.SorrowfulKills > 1 then
            savedata.SorrowfulKills = savedata.SorrowfulKills - 0.025
        else
            savedata.SorrowfulKills = 1
        end

        data.SorrowfulShallotCooldown = data.SorrowfulShallotCooldown - savedata.SorrowfulKills
        if data.SorrowfulShallotCooldown <= 0 then
            local tear = player:FireTear(player.Position, RandomVector()*10, false, false, false, player, 1.66)
            tear.FallingAcceleration = 1.5
            tear.FallingSpeed = -10
            data.SorrowfulShallotCooldown = player.MaxFireDelay
            sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
            sfx:Play(SoundEffect.SOUND_TEARS_FIRE, 0.5)
        end
    elseif data.SorrowfulShallotCooldown then
        player:RemoveCostume(sadonion)
        data.SorrowfulShallotCooldown = nil
    end
end

function mod:SorrowfulShallotOnKill(player, savedata)
    savedata.SorrowfulKills = savedata.SorrowfulKills + 1
end