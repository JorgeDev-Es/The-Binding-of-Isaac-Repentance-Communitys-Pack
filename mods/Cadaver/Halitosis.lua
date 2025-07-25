local Halitosis = {}

CollectibleType.COLLECTIBLE_HALITOSIS = Isaac.GetItemIdByName("Halitosis")
SoundEffect.HALITOSIS = Isaac.GetSoundIdByName("HalitosisVocal")

local MAX_DURATION = 30
local currentDurations = {}

function Halitosis.Use(collectibleType, RNG, player, useFlags, slot)
  if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
    currentDurations[GetPtrHash(player)] = MAX_DURATION * 2
  else
    currentDurations[GetPtrHash(player)] = MAX_DURATION
  end
  SFXManager():Play(SoundEffect.HALITOSIS, 2, 2, false, 1, 0)
  player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
  player:EvaluateItems()
end

local AIM_VECTORS = {}
AIM_VECTORS[Direction.LEFT] = Vector(-1, 0)
AIM_VECTORS[Direction.UP] = Vector(0, -1)
AIM_VECTORS[Direction.RIGHT] = Vector(1, 0)
AIM_VECTORS[Direction.DOWN] = Vector(0, 1)

function Halitosis.UpdateHalitosisEffect(player)
  if currentDurations[GetPtrHash(player)] and currentDurations[GetPtrHash(player)] > 0 then
    player.FireDelay = player.MaxFireDelay
    currentDurations[GetPtrHash(player)] = currentDurations[GetPtrHash(player)] - 1

    if (currentDurations[GetPtrHash(player)] == 0) then
      player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
      player:EvaluateItems()
    end

    -- Fire every 5th
    if currentDurations[GetPtrHash(player)] % 5 == 0 then
      local tear = player:FireTear(player.Position + (AIM_VECTORS[player:GetHeadDirection()] * 10), AIM_VECTORS[player:GetHeadDirection()] * 10, false, true, false, player, 1)
      tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_POISON | TearFlags.TEAR_FEAR)

      tear.SizeMulti = Vector(3, 3)
      tear.SpriteScale = Vector(0.3, 0.3)
      local sprite = tear:GetSprite()
      sprite:Load("gfx/halitosis_tear.anm2", true)
      
      if player:GetHeadDirection() == Direction.LEFT then
        sprite.FlipX = true
        sprite:Play("MoveHori")
      elseif player:GetHeadDirection() == Direction.UP then
        sprite.FlipY = true
        sprite:Play("MoveVert")
      elseif player:GetHeadDirection() == Direction.DOWN then
        sprite:Play("MoveVert")
      elseif player:GetHeadDirection() == Direction.RIGHT then
        sprite:Play("MoveHori")
      end
    end
  end
end

-- Need to remove the Trisagion effect temporarily for Halitosis because it doesn't play nicely with TearFlags on individual tears
function Halitosis.ModifyStats(player, cacheFlag)
  if (cacheFlag == CacheFlag.CACHE_TEARFLAG) then
    if (currentDurations[GetPtrHash(player)] and currentDurations[GetPtrHash(player)] > 0) then
      player.TearFlags = player.TearFlags & ~TearFlags.TEAR_LASERSHOT
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION)) then
      player.TearFlags = player.TearFlags | TearFlags.TEAR_LASERSHOT
    end
  end
end

return Halitosis