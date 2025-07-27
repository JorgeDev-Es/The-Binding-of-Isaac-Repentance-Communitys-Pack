local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ShouldActivateWhoreOfGalilee(player) --Check if all heart containers/bone hearts are filled, and that the player has atleast 1 red heart
    return player:GetHearts() > 0 and player:GetHearts() >= (player:GetMaxHearts() + (player:GetBoneHearts() * 2)) 
end

function mod:WhoreOfGalileePlayerLogic(player, data)
    if player:HasCollectible(TaintedCollectibles.WHORE_OF_GALILEE) then
        if data.TaintedWhoreOfGalilee then
            if not mod:ShouldActivateWhoreOfGalilee(player) then
                player:TryRemoveNullCostume(TaintedCostumes.WhoreOfGalilee)
                player:TryRemoveNullCostume(TaintedCostumes.WhoreOfGalileeHair)
                data.TaintedWhoreOfGalilee = false
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_LUCK)
                player:EvaluateItems()
            end
        else
            if mod:ShouldActivateWhoreOfGalilee(player) then
                local tempeffects = player:GetEffects()
                local hasMaggyBuff = tempeffects:HasNullEffect(NullItemID.ID_REVERSE_EMPRESS) --If the card effect is already active, don't bother messing with it
                if not hasMaggyBuff then --Use card to show the pop-up message, then remove its effects
                    player:UseCard(Card.CARD_REVERSE_EMPRESS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                    tempeffects:RemoveNullEffect(NullItemID.ID_REVERSE_EMPRESS)
                end
                player:AddNullCostume(TaintedCostumes.WhoreOfGalilee)
                player:AddNullCostume(TaintedCostumes.WhoreOfGalileeHair)
                data.TaintedWhoreOfGalilee = true
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_LUCK)
                player:EvaluateItems()
                --sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 1, 0, false, 1)
            end
        end
    elseif data.TaintedWhoreOfGalilee then
        mod:RemoveWhoreOfGalilee(player, data)
    end
end

function mod:RemoveWhoreOfGalilee(player, data)
    player:TryRemoveNullCostume(TaintedCostumes.WhoreOfGalilee)
    player:TryRemoveNullCostume(TaintedCostumes.WhoreOfGalileeHair)
    data.TaintedWhoreOfGalilee = false
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_LUCK)
    player:EvaluateItems()
end