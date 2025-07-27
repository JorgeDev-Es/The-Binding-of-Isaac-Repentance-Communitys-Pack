local mod = TaintedTreasure
local game = Game()

function mod:GetTaintedTreasureRoomThreshold()
    local stagelimit = LevelStage.STAGE4_1
    local purplestar = mod:GetPlayersHoldingTrinket(TaintedTrinkets.PURPLE_STAR)
    if purplestar or game:IsGreedMode() then
        stagelimit = LevelStage.STAGE5
    end
    return stagelimit
end