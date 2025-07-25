local mt_gfx = RegisterMod("mt_gfx", 1);
local TEAR_STATIC = Isaac.GetEntityVariantByName("Static Tear")
local TEAR_FACING = Isaac.GetEntityVariantByName("Facing Tear")
local TEAR_CUPID = Isaac.GetEntityVariantByName("Cupid Tear (Custom)")
local TEAR_BOOMERANG = Isaac.GetEntityVariantByName("Boomerang Tear")

local TEAR_STATIC_MULTID = Isaac.GetEntityVariantByName("Static Tear (Multidimensional)")
local TEAR_FACING_MULTID = Isaac.GetEntityVariantByName("Facing Tear (Multidimensional)")
local TEAR_CUPID_MULTID = Isaac.GetEntityVariantByName("Cupid Tear (Multidimensional)")
local TEAR_BOOMERANG_MULTID = Isaac.GetEntityVariantByName("Boomerang Tear (Multidimensional)")

local TEAR_POOF_A_LARGE = Isaac.GetEntityVariantByName("Tear PoofA large")
local TEAR_POOF_B_LARGE= Isaac.GetEntityVariantByName("Tear PoofB large")

local TEAR_VARIANT = nil
--local TEAR_SPR_FILENAME = nil
local TEAR_POS = nil
local TEAR_HEIGHT = nil
local TEAR_FLAGS = nil
local TEAR_POINTER = nil
--local TEAR_ROTATION = nil
--local TEAR_SPR_ROTATION = nil
local TEAR_COLOR = nil
--local TEAR_SPR_COLOR = nil
local TEAR_SCALE = nil
--local TEAR_BASE_SCALE = nil
--local TEAR_SIZE_MULTI = nil
--local TEAR_SPR_SCALE = nil
local TEAR_ANM_NAME = nil

local bloodModifierActive

local VARIANT_BLUE = TearVariant.BLUE
local VARIANT_BLOOD = TearVariant.BLOOD
--local VARIANT_TOOTH = TearVariant.TOOTH
local VARIANT_METALLIC = TearVariant.METALLIC
local VARIANT_FIRE = TearVariant.FIRE_MIND
local VARIANT_DARK = TearVariant.DARK_MATTER
local VARIANT_MYSTERIOUS = TearVariant.MYSTERIOUS
--local VARIANT_SCHYTHE = TearVariant.SCHYTHE
local VARIANT_LOST_CONTACT = TearVariant.LOST_CONTACT
local VARIANT_CUPID = TearVariant.CUPID_BLUE
local VARIANT_CUPID_BLOOD = TearVariant.CUPID_BLOOD
local VARIANT_NAIL = TearVariant.NAIL
local VARIANT_NAIL_BLOOD = TearVariant.NAIL_BLOOD
local VARIANT_PUPULA = TearVariant.PUPULA
local VARIANT_PUPULA_BLOOD = TearVariant.PUPULA_BLOOD
local VARIANT_GODS_FLESH = TearVariant.GODS_FLESH
local VARIANT_GODS_FLESH_BLOOD = TearVariant.GODS_FLESH_BLOOD
local VARIANT_DIAMOND = TearVariant.DIAMOND
local VARIANT_EXPLOSIVO = TearVariant.EXPLOSIVO
local VARIANT_COIN = TearVariant.COIN
local VARIANT_MULTIDIMENSIONAL = TearVariant.MULTIDIMENSIONAL
--STONE
local VARIANT_GLAUCOMA = TearVariant.GLAUCOMA
local VARIANT_GLAUCOMA_BLOOD = TearVariant.GLAUCOMA_BLOOD
--BOOGER
--EGG
--RAZOR
--BONE
--BLACK_TOOTH
--NEEDLE
--local VARIANT_BELIAL = TearVariant.BELIAL
local VARIANT_EYE = TearVariant.EYE
local VARIANT_EYE_BLOOD = TearVariant.EYE_BLOOD
--BALLOON
--HUNGRY
--BALLOON_BRIMSTONE
--BALLOON_BOMB

local FLAG_BOOMERANG
local FLAG_BURN
local FLAG_FEAR
local FLAG_MLIQ
local FLAG_GODS_F
local FLAG_EXPLOSIVO
local FLAG_PIERCING
local FLAG_SPECTRAL

if REPENTANCE then	
	FLAG_BOOMERANG = 1<<8
	FLAG_BURN = 1<<22
	FLAG_FEAR = 1<<20
	FLAG_MLIQ = 1<<33
	FLAG_GODS_F = 1<<43
	FLAG_EXPLOSIVO = 1<<37
	FLAG_PIERCING = 1<<1
	FLAG_SPECTRAL = 1<<0
else
	FLAG_BOOMERANG = TearFlags.TEAR_BOMBERANG
	FLAG_BURN = TearFlags.TEAR_BURN
	FLAG_FEAR = TearFlags.TEAR_FEAR
	FLAG_MLIQ = TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP
	FLAG_GODS_F = TearFlags.TEAR_GODS_FLESH 
	FLAG_EXPLOSIVO = TearFlags.TEAR_STICKY
	FLAG_PIERCING = TearFlags.TEAR_PIERCING
	FLAG_SPECTRAL = TearFlags.TEAR_SPECTRAL
end

local overridenBy = {}
--Regular
overridenBy[1] = {VARIANT_BLUE, VARIANT_BLOOD, VARIANT_METALLIC, VARIANT_FIRE, VARIANT_DARK, VARIANT_MYSTERIOUS, VARIANT_LOST_CONTACT, VARIANT_GODS_FLESH, VARIANT_GODS_FLESH_BLOOD, VARIANT_EXPLOSIVO,
                  VARIANT_MULTIDIMENSIONAL}
--Cupid
overridenBy[2] = {VARIANT_BLUE, VARIANT_BLOOD, VARIANT_METALLIC, VARIANT_FIRE, VARIANT_DARK, VARIANT_MYSTERIOUS, VARIANT_LOST_CONTACT, VARIANT_CUPID, VARIANT_CUPID_BLOOD, VARIANT_GODS_FLESH,
                  VARIANT_GODS_FLESH_BLOOD, VARIANT_DIAMOND, VARIANT_EXPLOSIVO, VARIANT_MULTIDIMENSIONAL}
                  --VARIANT_GODS_FLESH_BLOOD, VARIANT_DIAMOND, VARIANT_EXPLOSIVO, VARIANT_MULTIDIMENSIONAL, VARIANT_GLAUCOMA, VARIANT_GLAUCOMA_BLOOD}
--Boomerang
overridenBy[3] = {VARIANT_BLUE, VARIANT_BLOOD, VARIANT_METALLIC, VARIANT_FIRE, VARIANT_DARK, VARIANT_MYSTERIOUS, VARIANT_LOST_CONTACT, VARIANT_CUPID, VARIANT_CUPID_BLOOD, VARIANT_PUPULA,
                  VARIANT_PUPULA_BLOOD, VARIANT_GODS_FLESH, VARIANT_GODS_FLESH_BLOOD, VARIANT_EXPLOSIVO, VARIANT_MULTIDIMENSIONAL} --, VARIANT_GLAUCOMA, VARIANT_GLAUCOMA_BLOOD}

local variantSelectionTable = {}

local customs_non_multiD = {TEAR_STATIC, TEAR_FACING, TEAR_CUPID, TEAR_BOOMERANG}
local customs_MultiD = {TEAR_STATIC_MULTID, TEAR_FACING_MULTID, TEAR_CUPID_MULTID, TEAR_BOOMERANG_MULTID}
local customsVariantRange = {TEAR_STATIC, TEAR_BOOMERANG_MULTID}      -- {593270, 593373}

local deadTears = {}
local tearColors = {}
local boomerangColor = {}
local tearTints = {}
local builtTears = {}
local wasBloodVariant = {}
local previousVariant = {}
local diamondVariant = {}
local tearAnimation = {}    --string name, bool using SetFrame/Play (true -> SetFrame(); false -> Play())
local tearsFrameDelay = {}
      tearsFrameDelay[1] = {}   --frame, alpha, flag (i: seed)
      tearsFrameDelay[2] = {}   --seed (i: table) (delete)

local clock = 0

local test = "a"
local test2 = "b"

local function hasFlag(tear, flag)
  local res
  if REPENTANCE then
    res = tear:HasTearFlags(flag)
  else
    res = (tear.TearFlags & flag) ~= 0
  end
  return res
end

-- Blood modifiers
local bloodM = {}
bloodM[1] = {CollectibleType.COLLECTIBLE_BLOOD_MARTYR, CollectibleType.COLLECTIBLE_PACT, CollectibleType.COLLECTIBLE_SMALL_ROCK, CollectibleType.COLLECTIBLE_STIGMATA,
             CollectibleType.COLLECTIBLE_TOOTH_PICKS, CollectibleType.COLLECTIBLE_SMB_SUPER_FAN, CollectibleType.COLLECTIBLE_MONSTROS_LUNG, CollectibleType.COLLECTIBLE_ABADDON, 
             CollectibleType.COLLECTIBLE_MAW_OF_VOID, CollectibleType.COLLECTIBLE_KIDNEY_STONE, CollectibleType.COLLECTIBLE_APPLE, CollectibleType.COLLECTIBLE_EYE_OF_BELIAL, 
             CollectibleType.COLLECTIBLE_HAEMOLACRIA, COLLECTIBLE_LACHRYPHAGY}
bloodM[2] = {CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, CollectibleType.COLLECTIBLE_RAZOR_BLADE}


local customs_anm = {}
customs_anm[TEAR_STATIC] = {0.001, 0.30, 0.55, 0.675, 0.80, 0.925, 1.05, 1.175, 1.425, 1.675, 1.925, 2.175, 2.55, 2.78, 3.022, 3.264, 3.710, 4.169, 4.871}
--customs_anm[TEAR_STATIC] = {}
--customs_anm[TEAR_STATIC][1] = {4.871, 4.169, 3.710, 3.264, 3.022, 2.78, 2.55, 2.175, 1.925, 1.675, 1.425, 1.175, 1.05, 0.925, 0.80, 0.675, 0.55, 0.30}
--customs_anm[TEAR_STATIC][2] = {19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2}

customs_anm[TEAR_FACING] = customs_anm[TEAR_STATIC]

customs_anm[TEAR_CUPID] = {0.001, 0.30, 0.55, 0.675, 0.80, 0.925, 1.05, 1.175, 1.425, 1.675, 1.925, 2.175, 2.55, 2.727, 2.914, 3.091, 3.465, 3.817, 4.740}
--customs_anm[TEAR_CUPID] = {}
--customs_anm[TEAR_CUPID][1] = {4.740, 3.817, 3.465, 3.091, 2.914, 2.727, 2.55, 2.175, 1.925, 1.675, 1.425, 1.175, 1.05, 0.925, 0.80, 0.675, 0.55, 0.30}
--customs_anm[TEAR_CUPID][2] = {19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2}

customs_anm[TEAR_BOOMERANG] = customs_anm[TEAR_STATIC]
customs_anm[TEAR_STATIC_MULTID] = customs_anm[TEAR_STATIC]
customs_anm[TEAR_FACING_MULTID] = customs_anm[TEAR_FACING]
customs_anm[TEAR_CUPID_MULTID] = customs_anm[TEAR_CUPID]
customs_anm[TEAR_BOOMERANG_MULTID] = customs_anm[TEAR_BOOMERANG]

local boomerangSizes = {"a", "a", "a", "a", "a", "a", "a", "b", "b", "b", "b", "c", "c", "c", "d", "d", "d", "e", "e"}

-- <[FUNCTIONS]>

function get_anm(sprite, str, n)
  if n == nil then
    n = 19
  end
  
  for i = 1, n do
    if sprite:IsPlaying(str .. tostring(i)) then
      return str .. tostring(i)
    end
  end
  return sprite:GetDefaultAnimationName()
end

function link_anm(scale, variant)
  local scales = customs_anm[variant]      -- #scales >= 2
  local anmNumber
  
  if scale > scales[#scales] then
    anmNumber = #scales
  else
    local i = 1
    local j = #scales
    local m = i
    while i+1 < j and not (scale > scales[i] and scale <= scales[i+1]) do
      m = math.floor((i+j)/2)
      if scale > scales[m] then
        i = m
      else
        j = m
      end
    end
    anmNumber = m
  end
  return anmNumber
end

function PlayCustom(sprite, anmName, frame, pointer)
  if tearAnimation[pointer][2] then
    if frame == 0 then          
      sprite:Play(anmName, true)
      tearAnimation[pointer][2] = false
    else
      sprite:SetFrame(anmName, frame)
    end
  end
end

function isVariant(variant, variants)
  for i = 1, #variants do
    if variant == variants[i] then
      return true
    end
  end
  return false  
end

function buildVariantSelectionTable(vars)
  for i=1, #vars do
    variantSelectionTable[i] = {}
    for j=1, #vars[i] do
      variantSelectionTable[i][vars[i][j]] = vars[i][j]
    end
  end
end
buildVariantSelectionTable(overridenBy)

function checkBloodModifiers(player, color)
  local res = false
  local i = 1
  res = player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_CLOT) and areSameColor(color, Color(1, 0, 0, 1, 0, 0, 0))
  while res == false and i <= #bloodM[1] do
    res = player:HasCollectible(bloodM[1][i])
    i = i+1
  end
  i = 1
  local effects = player:GetEffects()
  while res == false and i <= #bloodM[2] do
    res = effects:HasCollectibleEffect(bloodM[2][i])
    i = i+1
  end
  return res
end

function newCustomVariant(TEAR_VARIANT, tear, TEAR_COLOR, player, seed)  
  local var
  local updatePreviousVar = true
  
  if TEAR_VARIANT == VARIANT_MULTIDIMENSIONAL then
    if isVariant(previousVariant[seed], customs_non_multiD) then
      var = previousVariant[seed] + 100
      updatePreviousVar = false
    elseif player:HasCollectible(48) or player:HasCollectible(306) or isVariant(TEAR_VARIANT, {VARIANT_CUPID, VARIANT_CUPID_BLOOD}) or 
           (player:HasTrinket(TrinketType.TRINKET_PUSH_PIN) and not player:HasCollectible(336) and hasFlag(tear, FLAG_PIERCING) and hasFlag(tear, FLAG_SPECTRAL)) then
      var = TEAR_CUPID_MULTID
    else
      var = TEAR_STATIC_MULTID
    end
  
  elseif hasFlag(tear, FLAG_BOOMERANG) and variantSelectionTable[3][TEAR_VARIANT] then
    var = TEAR_BOOMERANG
    
  else
    --local colorLess = areSameColor(TEAR_COLOR, Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0))
    --local colorLess = not (areSameColor(TEAR_COLOR, Color(0.39215689897537, 0.39215689897537, 0.39215689897537, 1.0, 0, 0, 0)) or areSameColor(TEAR_COLOR, Color(1, 0, 0, 1, 0, 0, 0)) or
    --                       areSameColor(TEAR_COLOR, Color(0.20000000298023, 0.090000003576279, 0.064999997615814, 1, 0, 0, 0)))     -- Abaddon, Blood Clot, Explosivo
    
    local has_Abaddon = player:HasCollectible(230) and hasFlag(tear, FLAG_FEAR)
    local has_BlodClot = player:HasCollectible(254) and areSameColor(TEAR_COLOR, Color(1, 0, 0, 1, 0, 0, 0))
    local has_EveMascara = player:HasCollectible(310) and areSameColor(TEAR_COLOR, Color(0.2, 0.2, 0.2, 1, 0, 0, 0))
    local has_Explosivo = player:HasCollectible(401) and hasFlag(tear, FLAG_EXPLOSIVO)
    local specialCases = has_Abaddon or has_BlodClot or has_EveMascara or has_Explosivo
    
    local has_cupid = (hasFlag(tear, FLAG_PIERCING) and (player:HasCollectible(48) or player:HasCollectible(306) or isVariant(TEAR_VARIANT, {VARIANT_CUPID, VARIANT_CUPID_BLOOD}))) or 
                      (player:HasTrinket(TrinketType.TRINKET_PUSH_PIN) and not player:HasCollectible(336) and hasFlag(tear, FLAG_PIERCING) and hasFlag(tear, FLAG_SPECTRAL))
    --if has_cupid and variantSelectionTable[2][TEAR_VARIANT] and not (colorLess and isVariant(TEAR_VARIANT, {VARIANT_CUPID_BLOOD, VARIANT_CUPID})) then
    if has_cupid and variantSelectionTable[2][TEAR_VARIANT] and not (not specialCases and isVariant(TEAR_VARIANT, {VARIANT_CUPID_BLOOD, VARIANT_CUPID})) then
      var = TEAR_CUPID
      
    --elseif variantSelectionTable[1][TEAR_VARIANT] and not (colorLess and isVariant(TEAR_VARIANT, {VARIANT_BLOOD, VARIANT_BLUE})) then
    elseif variantSelectionTable[1][TEAR_VARIANT] and not (not specialCases and isVariant(TEAR_VARIANT, {VARIANT_BLOOD, VARIANT_BLUE})) then
      local has_Dark_M = player:HasCollectible(259)
      if hasFlag(tear, FLAG_BURN) or hasFlag(tear, FLAG_MLIQ) or has_Dark_M or has_Abaddon then
        var = TEAR_FACING
      else
        var = TEAR_STATIC
      end
    end
    
  end
  
  if updatePreviousVar and var ~= nil then
  --if updatePreviousVar then
    previousVariant[seed] = var
  --else
  --  previousVariant[seed] = TEAR_VARIANT
  end
  return var
end

function getBloodVariant(var)
  local basic = {VARIANT_BLUE, VARIANT_CUPID, VARIANT_NAIL, VARIANT_PUPULA, VARIANT_GODS_FLESH, VARIANT_GLAUCOMA, VARIANT_EYE}
  local blood = {VARIANT_BLOOD, VARIANT_CUPID_BLOOD, VARIANT_NAIL_BLOOD, VARIANT_PUPULA_BLOOD, VARIANT_GODS_FLESH_BLOOD, VARIANT_GLAUCOMA_BLOOD, VARIANT_EYE_BLOOD}
  for i = 1, #basic do
    if var == basic[i] then
      return blood[i]    
    end
  end
end

function areSameColor (c1, c2)
  if c1.R == c2.R and c1.G == c2.G and c1.B == c2.B and c1.A == c2.A and c1.RO == c2.RO and c1.GO == c2.GO and c1.BO == c2.BO then
    return true
  else
    return false
  end
end

function colorToTable(c)
  return {c.R, c.G, c.B, c.A, math.floor(c.RO*255), math.floor(c.GO*255), math.floor(c.BO*255)}
end

function tableToColor(t)
  return Color(t[1], t[2], t[3], t[4], t[5], t[6], t[7])
end

function mixTearColors(c1, c2)
  return Color(c1.R * c2.R ,c1.G * c2.G,c1.B * c2.B, c1.A * c2.A, math.floor((c1.RO + c2.RO) * 255), math.floor((c1.GO + c2.GO) * 255), math.floor((c1.BO + c2.BO) * 255))
end

function getTearColor(pointer, tear, tColor, player)
  local colorT
  if hasFlag(tear, FLAG_EXPLOSIVO) then
    colorT = {"19", Color(0.319, 0.285, 0.234, 1.0, 0, 0, 0)}
    
  elseif player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR) then
    colorT = {"3", Color(0.632, 0.565, 0.452, 1.0, 0, 0, 0)}
    
  --elseif areSameColor(tColor, Color(0.39215689897537, 0.39215689897537, 0.39215689897537, 1, 0, 0, 0)) and hasFlag(tear, FLAG_FEAR) then     -- Abaddon tear
  elseif player:HasCollectible(230) and hasFlag(tear, FLAG_FEAR) then     -- Abaddon tear
    colorT = {"6", Color(0.173, 0.155, 0.127, 1.0, 0, 0, 0)}
    
  elseif player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER) then
    colorT = {"6", Color(0.173, 0.155, 0.127, 1.0, 0, 0, 0)} 
    
  elseif player:HasCollectible(310) and areSameColor(tColor, Color(0.2, 0.2, 0.2, 1, 0, 0, 0)) then     -- Eve's Mascara
    colorT = {"6", Color(0.173, 0.155, 0.127, 1.0, 0, 0, 0)}
    
  elseif hasFlag(tear, FLAG_BURN) then
    colorT = {"5", Color(1.5, 0.7, 0.2, 1.0, 0, 0, 0)}
    
  elseif hasFlag(tear, FLAG_MLIQ) then
    colorT = {"7", Color(0.476, 1.184, 0.298, 1.0, 0, 0, 0)}
    
  elseif wasBloodVariant[pointer] then
    colorT = {"1", Color(0.854, 0.053, 0.060, 1.0, 0, 0, 0)}
    
  else
    if bloodModifierActive == nil then
      bloodModifierActive = checkBloodModifiers(player, tColor)
    end
    if bloodModifierActive then
      colorT = {"1", Color(0.854, 0.053, 0.060, 1.0, 0, 0, 0)}
      
    else
      colorT = {"0", Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0)}
    end
  end
  
  return colorT
end

function getPoofVariant(scale, height)
  if scale > 1.8625 then
    if height < -5 then
      return TEAR_POOF_A_LARGE    -- Wall impact
    else
      return TEAR_POOF_B_LARGE    -- Floor impact
    end
  elseif scale > 0.8 then
    if height < -5 then
      return EffectVariant.TEAR_POOF_A    -- Wall impact
    else
      return EffectVariant.TEAR_POOF_B    -- Floor impact
    end
  elseif scale > 0.4 then
    return EffectVariant.TEAR_POOF_SMALL
  else
    return EffectVariant.TEAR_POOF_VERYSMALL
  end
end

function getPoofScaleCons(scale)
  if scale > 1.8625 then
    return 0.4
  elseif scale > 0.8 then
    return 0.8
  end
  --less than 0.8 doesnt scale (cons = 1)
end

function getTearHeightAndSnd(height)
  if height < -5 then
    return {Vector(0, height * 0.5 - 14), SoundEffect.SOUND_TEARIMPACTS} --Wall impact - "tear block.wav"
  else 
    return {Vector(0,0), SoundEffect.SOUND_SPLATTER}  --Floor impact - "splatter 0-2.wav"
  end
end

-- splash: Color(1.103, 0.986, 0.810, 1.0, 0, 0, 0) (white);  Color(0.097, 0.087, 0.071, 1.0, 0, 0, 0) (black)
-- mLiq p: Color(0, 0, 0, 1.0, 190, 190, 190) (white);        Color(0, 0, 0, 1.0, 14, 14, 14) (black)
function multiD_Fade(frm, c1, c2, alpha)
  if frm <= 12 then
    return Color(c1[1] - c2[1]*frm, c1[2] - c2[2]*frm, c1[3] - c2[3]*frm, alpha, c1[5] - c2[5]*frm, c1[6] - c2[6]*frm, c1[7] - c2[7]*frm)
    --return Color(c1.R - c2.R*frm, c1.G - c2.G*frm, c1.R - c2.G*frm, c1.A, math.floor((c1.RO - c2.RO*frm)*255), math.floor((c1.GO - c2.GO*frm)*255), math.floor((c1.BO - c2.BO*frm)*255))
  else
    return multiD_Fade(24-frm, c1, c2, alpha)
  end
end

function getTearPlayerSpawner(parent)
  if parent ~= nil then
    if parent.Type == EntityType.ENTITY_PLAYER then
      return parent:ToPlayer()
    elseif parent.Type == EntityType.ENTITY_FAMILIAR then
      return parent:ToFamiliar().Player
    elseif parent.Type == EntityType.ENTITY_TEAR then
      return getTearPlayerSpawner(parent.Parent)
    end
  else
    return Isaac.GetPlayer(0)
  end
end

-- | ====== |
-- |  MAIN  |
-- | ====== |

function mt_gfx:main(tear)
  
  if tear.SpawnerType == 1 or (tear.SpawnerType == 0 and tear.Parent ~= nil) or tear.SpawnerType == 3 then
    
    --if tear.FrameCount == 1 then
    --  tear.Scale = 5
    --end
    --
    --tear.Scale = tear.Scale * 0.999
    
    --tear.Scale = -1
    
    local tearSpr = tear:GetSprite()
    TEAR_VARIANT = tear.Variant
    --TEAR_SPR_FILENAME = tearSpr:GetFilename()
    --TEAR_POS = tear.Position
    --TEAR_HEIGHT = tear.Height
    TEAR_FLAGS = tear.TearFlags
    TEAR_POINTER = GetPtrHash(tear)
    --TEAR_ROTATION = tear.Rotation
    --TEAR_SPR_ROTATION = tearSpr.Rotation
    TEAR_COLOR = tear:GetColor()
    --TEAR_SPR_COLOR = tearSpr.KColor
    TEAR_SCALE = tear:ToTear().Scale
    --TEAR_BASE_SCALE = tear.BaseScale
    --TEAR_SIZE_MULTI = tear.SizeMulti
    --TEAR_SPR_SCALE = tearSpr.Scale.X .. " " .. tearSpr.Scale.Y
    --TEAR_ANM_NAME = get_anm(tearSpr, "RegularTear", 19)
    if TEAR_VARIANT >= customsVariantRange[1] and TEAR_VARIANT <= customsVariantRange[2] then
      if tearAnimation[TEAR_POINTER] == nil then
        TEAR_ANM_NAME = "RegularTear" .. tostring(link_anm(TEAR_SCALE, TEAR_VARIANT))
        tearAnimation[TEAR_POINTER] = {TEAR_ANM_NAME, true}
      else
        TEAR_ANM_NAME = tearAnimation[TEAR_POINTER][1]
      end
    else
      TEAR_ANM_NAME = get_anm(tearSpr, "RegularTear", 19)
      tearAnimation[TEAR_POINTER] = {TEAR_ANM_NAME, true}
    end
    
    local player = getTearPlayerSpawner(tear.Parent)
    
    --test = tear.StickTarget
    
    -- <[VARIANT SELECTION]>
    
    local newVar
    if TEAR_VARIANT < 39 then
      newVar = newCustomVariant(TEAR_VARIANT, tear, TEAR_COLOR, player, tear.InitSeed)
    end
    if newVar ~= nil then
      tear:ChangeVariant(newVar)
      
     if isVariant(TEAR_VARIANT, {VARIANT_BLOOD, VARIANT_CUPID_BLOOD, VARIANT_PUPULA_BLOOD, VARIANT_GODS_FLESH_BLOOD}) then
       wasBloodVariant[TEAR_POINTER] = true
     end
      builtTears[TEAR_POINTER] = nil      --Ludovico reset
      boomerangColor[TEAR_POINTER] = nil  --My Reflection + MultiD
      
      TEAR_VARIANT = tear.Variant
      if isVariant(TEAR_VARIANT, {TEAR_STATIC, TEAR_BOOMERANG, TEAR_STATIC_MULTID, TEAR_BOOMERANG_MULTID})  then
        tearSpr.Rotation = 0.001
      end
      
      local seed = tear.InitSeed
      if tearsFrameDelay[1][seed] == nil then
        tearsFrameDelay[1][seed] = {nil, TEAR_COLOR.A, nil}
      end
      if isVariant(TEAR_VARIANT, customs_MultiD) then
        if tearsFrameDelay[1][seed][1] == nil then
          tearsFrameDelay[1][seed][1] = tear.FrameCount
          tearsFrameDelay[1][seed][3] = false
          table.insert(tearsFrameDelay[2], seed)
        end
        local alpha = tearsFrameDelay[1][seed][2]
        tear:SetColor(Color(1, 1, 1, alpha, 0, 0, 0), 0, 0, false, false)
        TEAR_COLOR = tear:GetColor()
      end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SMB_SUPER_FAN) and
    isVariant(TEAR_VARIANT, {VARIANT_BLUE, VARIANT_CUPID, VARIANT_NAIL, VARIANT_PUPULA, VARIANT_GODS_FLESH, VARIANT_GLAUCOMA, VARIANT_EYE}) then
      tear:ChangeVariant(getBloodVariant(TEAR_VARIANT))
    end
    
    -- <[TEAR GFX]>
    
    if TEAR_VARIANT >= customsVariantRange[1] and TEAR_VARIANT <= customsVariantRange[2] and builtTears[TEAR_POINTER] ~= 1 and not tear:IsDead() then
      builtTears[TEAR_POINTER] = 1
      
      local bodyName = "regular/"
      local sizeChar = ""
      local effectPath = ""
      
      if isVariant(TEAR_VARIANT, {TEAR_CUPID, TEAR_CUPID_MULTID}) then
        if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) then
          bodyName = "cupid/diamond_"
          effectPath = "gfx/tears/cupid/effects.png"
          diamondVariant[TEAR_POINTER] = true
        else
          bodyName = "cupid/"
          effectPath = "gfx/tears/cupid/effects.png"
        end
      elseif isVariant(TEAR_VARIANT, {TEAR_BOOMERANG, TEAR_BOOMERANG_MULTID}) then
        sizeChar = boomerangSizes[link_anm(TEAR_SCALE, TEAR_VARIANT)]
        bodyName = "boomerang/"
        effectPath = "gfx/tears/boomerang/effects.png"
      else
        effectPath = "gfx/tears/regular/effects.png"
      end
      
      local has_Lost_C = player:HasCollectible(213)
      local has_Dark_M = player:HasCollectible(259)
      --local has_Abaddon = areSameColor(TEAR_COLOR, Color(0.39215689897537, 0.39215689897537, 0.39215689897537, 1.0, 0, 0, 0)) and hasFlag(tear, FLAG_FEAR)
      local has_Abaddon = player:HasCollectible(230) and hasFlag(tear, FLAG_FEAR)
      
      
      local color
      if isVariant(TEAR_VARIANT, customs_non_multiD) then
        color = getTearColor(TEAR_POINTER, tear, TEAR_COLOR, player)
        tearSpr:ReplaceSpritesheet(0,"gfx/tears/" .. bodyName .. color[1] .. sizeChar .. ".png")
        tearColors[TEAR_POINTER] = color[2]
        if TEAR_VARIANT == TEAR_BOOMERANG then
          boomerangColor[TEAR_POINTER] = color[1]
        end
      elseif TEAR_VARIANT == TEAR_BOOMERANG_MULTID then
        tearSpr:ReplaceSpritesheet(0,"gfx/tears/boomerang/21" .. sizeChar .. ".png")
        tearSpr:ReplaceSpritesheet(3,"gfx/tears/boomerang/21" .. sizeChar .. ".png")
      else
        tearSpr:ReplaceSpritesheet(0,"gfx/tears/" .. bodyName .. "21.png")
        tearSpr:ReplaceSpritesheet(3,"gfx/tears/" .. bodyName .. "21.png")   
      end
      
      if hasFlag(tear, FLAG_BURN) or has_Dark_M or has_Abaddon then
        if has_Dark_M or has_Abaddon then
          tearSpr:ReplaceSpritesheet(7, effectPath)
        else
          tearSpr:ReplaceSpritesheet(6, effectPath)
        end
      end
      
      if has_Lost_C then
        tearSpr:ReplaceSpritesheet(5, effectPath)
      end
      
      if hasFlag(tear, FLAG_GODS_F) and not isVariant(TEAR_VARIANT, customs_MultiD) then
        tearSpr:ReplaceSpritesheet(1,"none.png")
        tearSpr:ReplaceSpritesheet(2, effectPath)
      end
      
      if hasFlag(tear, FLAG_MLIQ) then
        tearSpr:ReplaceSpritesheet(8, effectPath)
        if not (hasFlag(tear, FLAG_BURN) or has_Dark_M or has_Abaddon) then
          tearSpr:ReplaceSpritesheet(4, effectPath)
        end
      end
      
      tearSpr:LoadGraphics()
      
      if has_Abaddon and areSameColor(TEAR_COLOR, Color(0.39215689897537, 0.39215689897537, 0.39215689897537, 1.0, 0, 0, 0)) then
        tear:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0), 0, 0, false, false)
      elseif areSameColor(TEAR_COLOR, Color(0.20000000298023, 0.090000003576279, 0.064999997615814, 1, 0, 0, 0)) and hasFlag(tear, FLAG_EXPLOSIVO) then
        tear:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0), 0, 0, false, false)
      elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_CLOT) and areSameColor(TEAR_COLOR, Color(1, 0, 0, 1, 0, 0, 0)) and color[1] == "1" then
        tear:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0), 0, 0, false, false)
      elseif player:HasCollectible(310) and areSameColor(TEAR_COLOR, Color(0.2, 0.2, 0.2, 1, 0, 0, 0)) then
        tear:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0), 0, 0, false, false)
      end
      
    end
    
    -- <[TEAR SCALING]>
    
    if TEAR_VARIANT >= customsVariantRange[1] and TEAR_VARIANT <= customsVariantRange[2] then
      local currentAnm = link_anm(TEAR_SCALE, TEAR_VARIANT)
      local currentAnmName = "RegularTear" .. tostring(currentAnm)
      if currentAnmName ~= TEAR_ANM_NAME then        
        if isVariant(TEAR_VARIANT, {TEAR_BOOMERANG, TEAR_BOOMERANG_MULTID}) then
          local n = tonumber(string.sub(TEAR_ANM_NAME, 12))
          if boomerangSizes[currentAnm] ~= boomerangSizes[n] then
            local color = boomerangColor[TEAR_POINTER]
            if color == nil then
              color = "21"
            end
            if TEAR_VARIANT == TEAR_BOOMERANG_MULTID then
              tearSpr:ReplaceSpritesheet(3,"gfx/tears/boomerang/" .. color .. boomerangSizes[currentAnm] .. ".png")
            end
            tearSpr:ReplaceSpritesheet(0,"gfx/tears/boomerang/" .. color .. boomerangSizes[currentAnm] .. ".png")
            tearSpr:LoadGraphics()
          end
        end
        TEAR_ANM_NAME = currentAnmName
        tearAnimation[TEAR_POINTER] = {TEAR_ANM_NAME, true}
      end
      
      if TEAR_SCALE >= customs_anm[TEAR_VARIANT][19] or
      (TEAR_SCALE >= customs_anm[TEAR_VARIANT][12] and (hasFlag(tear, FLAG_EXPLOSIVO) or player:HasCollectible(261) or player:HasCollectible(132) or player:GetEffects():HasTrinketEffect(9))) then
        local scaleCons = customs_anm[TEAR_VARIANT][link_anm(TEAR_SCALE, TEAR_VARIANT)]
        --if TEAR_SCALE > scaleCons then
          local sizeM = scaleCons / TEAR_SCALE * 1.1660
          local sprScale = TEAR_SCALE / scaleCons * 0.85675
          tear.SizeMulti = Vector(sizeM, sizeM)
          tearSpr.Scale = Vector(sprScale, sprScale)
        --else
        --  tear.SizeMulti = Vector(1, 1)
        --  tearSpr.Scale = Vector(1, 1)
        --end
      else
        tear.SizeMulti = Vector(1, 1)
        tearSpr.Scale = Vector(1, 1)
      end
      
      
    -- <[TEAR POOF]>
    
      if tear:IsDead() then
        table.insert(deadTears, {tear, 1, TEAR_COLOR})
      --else
        --tearTints[TEAR_POINTER] = tableToColor(colorToTable(TEAR_COLOR))
      end
      
      if tearTints[TEAR_POINTER] == nil then
        tearTints[TEAR_POINTER] = tableToColor(colorToTable(TEAR_COLOR))      --Esto es una putisima mierda y me voy a pegar un tiro en la pija
      end
      
    end
    
    -- <[TEAR ANIMATION]>
    
    local frame = tear.FrameCount
    
    if TEAR_VARIANT == TEAR_STATIC then
      -- <[STATIC]>  
      --tearSpr:SetFrame(TEAR_ANM_NAME, 0)
      PlayCustom(tearSpr, TEAR_ANM_NAME, frame % 1, TEAR_POINTER)
      
    elseif isVariant(TEAR_VARIANT, {TEAR_FACING, TEAR_CUPID}) then
      -- <[FACING/CUPID]>
      PlayCustom(tearSpr, TEAR_ANM_NAME, frame % 16, TEAR_POINTER)
      --tearSpr.Rotation = tear.Velocity:GetAngleDegrees()
      if tear.StickTarget == nil then
        tearSpr.Rotation = (tear.Velocity + Vector(0, tear.FallingSpeed)):GetAngleDegrees()
      end
      
    elseif TEAR_VARIANT == TEAR_BOOMERANG then
      -- <[BOOMERNAG]>
      PlayCustom(tearSpr, TEAR_ANM_NAME, frame % 12, TEAR_POINTER)
      
      if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
        tearSpr.Rotation = 0.001
      end
      
      if hasFlag(tear, FLAG_MLIQ) and frame % 2 == 0 and math.random(1, 3) == 1 then
        TEAR_POS = tear.Position
        TEAR_HEIGHT = tear.Height
        local base = Vector.FromAngle((frame+5)%12*30)        
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, 111, 0, base:Resized(TEAR_SCALE*7):__add(TEAR_POS), base:Resized(TEAR_SCALE*0.3), nil):ToEffect()
        trail.PositionOffset = getTearHeightAndSnd(TEAR_HEIGHT)[1]
        
        local sprite = trail:GetSprite()
        local scale = 0.175 + TEAR_SCALE * 0.15
        sprite.Scale = Vector(scale, scale)
        sprite:ReplaceSpritesheet(0, "gfx/effects/tear_mysterious_trail.png")
        sprite:LoadGraphics()
        --trail:SetColor(TEAR_COLOR, 0, 0, false, false)
      end
      
    elseif isVariant(TEAR_VARIANT, customs_MultiD) then
      -- <[MULTI_Ds]>
      local seed = tear.InitSeed
      frame = tearsFrameDelay[1][seed][1]
      tearsFrameDelay[1][seed][3] = false
      PlayCustom(tearSpr, TEAR_ANM_NAME, frame % 24, TEAR_POINTER)
      if isVariant(TEAR_VARIANT, {TEAR_FACING_MULTID, TEAR_CUPID_MULTID}) then
        if tear.StickTarget == nil then
          tearSpr.Rotation = (tear.Velocity + Vector(0, tear.FallingSpeed)):GetAngleDegrees()
        end
        
      elseif TEAR_VARIANT == TEAR_BOOMERANG_MULTID then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
          tearSpr.Rotation = 0.001
        end
        if hasFlag(tear, FLAG_MLIQ) and frame % 2 == 0 and math.random(1, 3) == 1 then
          TEAR_POS = tear.Position
          TEAR_HEIGHT = tear.Height
          local base = Vector.FromAngle((frame+5)%12*30)
          local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, 111, 0, base:Resized(TEAR_SCALE*7):__add(TEAR_POS), base:Resized(TEAR_SCALE*0.3), nil):ToEffect()
          trail.PositionOffset = getTearHeightAndSnd(TEAR_HEIGHT)[1]
          
          local sprite = trail:GetSprite()
          local scale = 0.175 + TEAR_SCALE * 0.15
          sprite.Scale = Vector(scale, scale)
          sprite:ReplaceSpritesheet(0, "gfx/effects/tear_mysterious_trail.png")
          sprite:LoadGraphics()
          trail:SetColor(multiD_Fade((tear.FrameCount % 24), {0, 0, 0, 1.0, 190, 190, 190}, {0, 0, 0, 1.0, 14, 14, 14}, TEAR_COLOR.A), 0, 0, false, false)
        end
      end      
    end
  end
  
  -- <[VANILLA REGULAR/CUPID]>  
  TEAR_VARIANT = tear.Variant
  TEAR_SCALE = tear:ToTear().Scale
  local tearSpr = tear:GetSprite()
  if isVariant(TEAR_VARIANT, {VARIANT_BLUE, VARIANT_METALLIC, VARIANT_LOST_CONTACT, VARIANT_GODS_FLESH, VARIANT_EXPLOSIVO, VARIANT_MULTIDIMENSIONAL}) and TEAR_SCALE > 2.78 then
    if TEAR_VARIANT == VARIANT_MULTIDIMENSIONAL then
      tearSpr:SetFrame("RegularTear" .. tostring(link_anm(TEAR_SCALE, TEAR_STATIC)), tear.FrameCount % 24)
    else
      tearSpr:Play("RegularTear" .. tostring(link_anm(TEAR_SCALE, TEAR_STATIC)),false)
    end
  elseif isVariant(TEAR_VARIANT, {VARIANT_BLOOD, VARIANT_GODS_FLESH_BLOOD}) and TEAR_SCALE > 2.78 then
    tearSpr:Play("BloodTear" .. tostring(link_anm(TEAR_SCALE, TEAR_STATIC)),false)
  elseif TEAR_VARIANT == VARIANT_CUPID and TEAR_SCALE > 2.727 then
    tearSpr:Play("RegularTear" .. tostring(link_anm(TEAR_SCALE, TEAR_CUPID)),false)
  elseif TEAR_VARIANT == VARIANT_CUPID_BLOOD and TEAR_SCALE > 2.727 then
    tearSpr:Play("BloodTear" .. tostring(link_anm(TEAR_SCALE, TEAR_CUPID)),false)
  end
end

function mt_gfx:collision(tear, collider, low)
  TEAR_VARIANT = tear.Variant
  if TEAR_VARIANT >= customsVariantRange[1] and TEAR_VARIANT <= customsVariantRange[2] and tear.StickTarget == nil then
    TEAR_COLOR = tear:GetColor()
    TEAR_POINTER = GetPtrHash(tear)
    table.insert(deadTears, {tear, 1, TEAR_COLOR})      
    if tearTints[TEAR_POINTER] == nil then
      tearTints[TEAR_POINTER] = tableToColor(colorToTable(TEAR_COLOR))      --Esto es una putisima mierda y me voy a pegar un tiro en la pija
    end
  end
end

function mt_gfx:tearsDeath()
  bloodModifierActive = nil
  
  clock = clock + 1
  if clock > 600 then
    clock = 0
  end
  
  local i = 1
  while (i <= #deadTears) do
    if deadTears[i][2] == 1 then
      deadTears[i][2] = 2
    elseif deadTears[i][2] == 2 then
      local tear = deadTears[i][1]
      if tear:IsDead() then
        
        TEAR_SCALE = tear:ToTear().Scale
        TEAR_HEIGHT = tear.Height
        TEAR_POS = tear.Position
        TEAR_VARIANT = tear.Variant
        TEAR_POINTER = GetPtrHash(tear)
        TEAR_COLOR = tearTints[TEAR_POINTER]
        
        local poofSize = getPoofVariant(TEAR_SCALE, TEAR_HEIGHT)
        local poofHeightSnd = getTearHeightAndSnd(TEAR_HEIGHT)
        --local scaleCons = getPoofScaleCons(TEAR_SCALE)
        
        local poof
        if diamondVariant[TEAR_POINTER] then
          -- <[DIAMOND POOF]>
          poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, TEAR_POS, Vector(0,0), nil):ToEffect()
          local poofScale = TEAR_SCALE * 0.8
          poof:GetSprite().Scale = Vector(poofScale, poofScale)
          SFXManager():Play(SoundEffect.SOUND_POT_BREAK, 0.25, 0, false, 2.5)
          
          -- <[DIAMOND PARTICLES]>
          for i = 1, math.random(2,3) do
            local vel = RandomVector() * math.random(0, 10)*0.5
            vel = Vector(vel.X, vel.Y * 0.5)
            local particle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIAMOND_PARTICLE, 0, TEAR_POS, vel, nil):ToEffect()
            particle:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_085_diamondgibs_custom.png")
            particle:GetSprite():LoadGraphics()
            
            if TEAR_VARIANT == TEAR_CUPID_MULTID then
              particle:SetColor(multiD_Fade((tearsFrameDelay[1][tear.InitSeed][1]), {1.103, 0.986, 0.810, 1.0, 0, 0, 0}, {0.0838, 0.0749, 0.0616, 1.0, 0, 0, 0}, TEAR_COLOR.A), 0, 0, false, false)
            else
              local C = tearColors[TEAR_POINTER]
              if C == nil then
                C = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0)
                --SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 1)    --crap
              end
              particle:SetColor(mixTearColors(TEAR_COLOR, C), 0, 0, false, false)
            end            
          end  
          
        else          
          -- <[REGULAR POOF]>
          poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, poofSize, 0, TEAR_POS, Vector(0,0), nil):ToEffect()
          if TEAR_SCALE >= 0.8 then
            local poofScale = TEAR_SCALE * getPoofScaleCons(TEAR_SCALE)
            poof:GetSprite().Scale = Vector(poofScale, poofScale)
          end
          SFXManager():Play(poofHeightSnd[2], 1, 0, false, 1)          
        end
        
        -- <[POOF TINT]>        
        if isVariant(TEAR_VARIANT, customs_MultiD) then          
          poof:SetColor(multiD_Fade((tearsFrameDelay[1][tear.InitSeed][1]), {1.103, 0.986, 0.810, 1.0, 0, 0, 0}, {0.0838, 0.0749, 0.0616, 1.0, 0, 0, 0}, TEAR_COLOR.A), 0, 0, false, false)
        else          
          local C = tearColors[TEAR_POINTER]
          if C == nil then
            C = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0)
            --SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 1)    --crap
          end          
          if diamondVariant[TEAR_POINTER] and areSameColor(C, Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0)) then
            poof:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_impact_custom.png")
            poof:GetSprite():LoadGraphics()
          end
          poof:SetColor(mixTearColors(TEAR_COLOR, C), 0, 0, false, false)
        end
        
        poof.PositionOffset = poofHeightSnd[1]
        
        if isVariant(poofSize, {TEAR_POOF_A_LARGE, TEAR_POOF_B_LARGE}) then
          poof:GetSprite().Rotation = math.random(4) * 90
        end
        
      --else
        --SFXManager():Play(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1)
        -- flat stone bounce
      end
      table.remove(deadTears, i)
      i = i-1
    end
    i = i+1
  end
  
  i = 1
  while (i <= #tearsFrameDelay[2]) do
    local seed = tearsFrameDelay[2][i]
    if tearsFrameDelay[1][seed][3] then
      table.remove(tearsFrameDelay[2], i)
      tearsFrameDelay[1][seed] = nil
      i = i-1
    else
      tearsFrameDelay[1][seed][1] = (tearsFrameDelay[1][seed][1] + 1) % 24
      tearsFrameDelay[1][seed][3] = true
    end
    i = i+1
  end
end

function mt_gfx.clearLists()
  clock = 0
  
  deadTears = {}
  tearColors = {}  
  boomerangColor = {}
  tearTints = {}
  builtTears = {}
  wasBloodVariant = {}
  previousVariant = {}  
  diamondVariant = {}
  tearAnimation = {}
  tearsFrameDelay[1] = {}
  tearsFrameDelay[2] = {}
end

function mt_gfx:clearTear(tear)
  TEAR_POINTER = GetPtrHash(tear)
  deadTears[TEAR_POINTER] = nil
  tearColors[TEAR_POINTER] = nil
  boomerangColor[TEAR_POINTER] = nil
  tearTints[TEAR_POINTER] = nil
  builtTears[TEAR_POINTER] = nil
  wasBloodVariant[TEAR_POINTER] = nil
  --previousVariant[tear.InitSeed] = nil
  diamondVariant[TEAR_POINTER] = nil
  tearAnimation[TEAR_POINTER] = nil
  
  local seed = tear.InitSeed
  TEAR_VARIANT = tear.Variant
  TEAR_COLOR = tear:GetColor()
  if TEAR_VARIANT >= customsVariantRange[1] and TEAR_VARIANT <= customsVariantRange[2] then
    if tearsFrameDelay[1][seed] == nil then
      tearsFrameDelay[1][seed] = {nil, TEAR_COLOR.A, nil}
    end
    if isVariant(TEAR_VARIANT, customs_MultiD) then
      if tearsFrameDelay[1][seed][1] == nil then
        tearsFrameDelay[1][seed][1] = tear.FrameCount
        tearsFrameDelay[1][seed][3] = false
        table.insert(tearsFrameDelay[2], seed)
      end
      local alpha = tearsFrameDelay[1][seed][2]
      tear:SetColor(Color(1, 1, 1, alpha, 0, 0, 0), 0, 0, false, false)
      TEAR_COLOR = tear:GetColor()
    end
  end
end

function mt_gfx:poof(poof)
  local size = poof:GetSprite().Scale.X
  if isVariant(poof.Variant, {EffectVariant.BULLET_POOF, EffectVariant.TEAR_POOF_A, EffectVariant.TEAR_POOF_B}) and size > 1.49 and poof.State == 0 then    --(1.49 = 1.8625 * 0.8)
    poof.State = 1
    local sprite = poof:GetSprite()
    if isVariant(poof.Variant, {EffectVariant.BULLET_POOF, EffectVariant.TEAR_POOF_A}) then
      sprite:Load("gfx/1000.xxx_tear poofa_large.anm2",false)
    else
      sprite:Load("gfx/1000.xxx_tear poofb_large.anm2",false)
    end    
    sprite:Play("Poof", true)
    sprite:LoadGraphics()
    poof:GetSprite().Scale = Vector(size * 0.5, size * 0.5)
    
    if poof.Variant == EffectVariant.BULLET_POOF then
      local C = Color(0.854, 0.053, 0.060, 1.0, 0, 0, 0)
      local POOF_COLOR = poof:GetColor()
      poof:SetColor(mixTearColors(POOF_COLOR, C), 0, 0, false, false)
    end
  end
  
  if poof.Variant == EffectVariant.BULLET_POOF and poof.FrameCount == 0 then
    poof.Rotation = math.random(4) * 90
  end
  
  --test = poof:GetSprite().Scale.X
  --test = poof.Color.R .. " " .. poof.Color.G .. " " .. poof.Color.B .. " " .. poof.Color.A .. " " .. poof.Color.RO .. " " .. poof.Color.GO .. " " .. poof.Color.BO
end

function mt_gfx:projectiles(projectile)
  if projectile.SpawnerType == EntityType.ENTITY_FIREPLACE then
    if projectile.FrameCount == 1 then
      local sprite = projectile:GetSprite()
      local anm = get_anm(sprite, "RegularTear", 19)
      sprite:Load("gfx/009.xxx_fire projectile.anm2", false)
      sprite:Play(anm, true)
      sprite:LoadGraphics()
    end
    projectile.SpriteRotation = (projectile.Velocity + Vector(0, projectile.FallingSpeed)):GetAngleDegrees()
  end
end

function mt_gfx:multiBB(fam)
  if fam.Variant == FamiliarVariant.MULTIDIMENSIONAL_BABY then
    fam.Velocity = Vector(0,0)
  end
end

local function ShowText()
  
  local entities = Isaac.GetRoomEntities()
  
	for i=1,#entities do
    if entities[i].Type == EntityType.ENTITY_TEAR then
      TEAR_COLOR = entities[i]:GetColor()
    end
  end
  Isaac.RenderText("Test2: " ..           tostring(test2),  45, 30, 255, 255, 255, 255)  
  Isaac.RenderText("Test:  " ..           tostring(test),  45, 40, 255, 255, 255, 255)
  
  Isaac.RenderText("Variant: " ..         tostring(TEAR_VARIANT),       45, 60, 255, 255, 255, 255)
  --Isaac.RenderText("Filename: " ..        tostring(TEAR_SPR_FILENAME),  45, 70, 255, 255, 255, 255)
  if TEAR_POS ~= nil then
    Isaac.RenderText("Position.X: " ..    tostring(TEAR_POS.X),         45, 90, 255, 255, 255, 255)
    Isaac.RenderText("Position.Y: " ..    tostring(TEAR_POS.Y),         45, 100, 255, 255, 255, 255)
  end
  
  Isaac.RenderText("Height: " ..          tostring(TEAR_HEIGHT),        45, 120, 255, 255, 255, 255)
  Isaac.RenderText("Flags: " ..           tostring(TEAR_FLAGS),         45, 130, 255, 255, 255, 255)
  Isaac.RenderText("Pointer: " ..         tostring(TEAR_POINTER),         45, 140, 255, 255, 255, 255)
  
  --Isaac.RenderText("Rotation: " ..        tostring(TEAR_ROTATION),      45, 160, 255, 255, 255, 255)
  --Isaac.RenderText("SpriteRotation: " ..  tostring(TEAR_SPR_ROTATION),  45, 170, 255, 255, 255, 255)
  
  Isaac.RenderText("EntityColor:",                                        45, 190, 255, 255, 255, 255)
  if TEAR_COLOR ~= nil then
    Isaac.RenderText("[\019]",  122, 190, TEAR_COLOR.R, TEAR_COLOR.G, TEAR_COLOR.B, TEAR_COLOR.A)
    Isaac.RenderText("(R: " .. TEAR_COLOR.R .. "; G: " .. TEAR_COLOR.G .. "; B: " .. TEAR_COLOR.B .. ")" , 55, 200, 255, 255, 255, 255)
    Isaac.RenderText("(A: " .. TEAR_COLOR.A .. "; RO: " .. TEAR_COLOR.RO .. "; GO: " .. TEAR_COLOR.GO .. "; BO: " .. TEAR_COLOR.BO .. ")" , 55, 210, 255, 255, 255, 255)
  end
  --Isaac.RenderText("SpriteColor: " ..       tostring(TEAR_SPR_COLOR),  45, 210, 255, 255, 255, 255)
  
  --Isaac.RenderText("Scale: " ..           tostring(TEAR_SCALE),  45, 230, 255, 255, 255, 255)
  Isaac.RenderText("TearSize: " ..        tostring(TEAR_SCALE),  45, 230, 255, 255, 255, 255)
  --Isaac.RenderText("BaseScale: " ..       tostring(TEAR_BASE_SCALE),  45, 240, 255, 255, 255, 255)
  --if TEAR_SIZE_MULTI ~= nil then    
  --  Isaac.RenderText("SizeMulti: " ..     tostring(TEAR_SIZE_MULTI.X) .. " " .. tostring(TEAR_SIZE_MULTI.Y),  45, 250, 255, 255, 255, 255)
  --end
  --Isaac.RenderText("SpriteScale: " ..     tostring(TEAR_SPR_SCALE),  205, 260, 255, 255, 255, 255)
  Isaac.RenderText("AnmSize: " ..         tostring(TEAR_ANM_NAME),  45, 260, 255, 255, 255, 255)
end


mt_gfx:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mt_gfx.clearLists)
mt_gfx:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mt_gfx.clearTear)
mt_gfx:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mt_gfx.main)
mt_gfx:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mt_gfx.collision)
mt_gfx:AddCallback(ModCallbacks.MC_POST_UPDATE, mt_gfx.tearsDeath)
mt_gfx:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mt_gfx.poof)
mt_gfx:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, mt_gfx.projectiles)
--mt_gfx:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mt_gfx.multiBB)
--mt_gfx:AddCallback(ModCallbacks.MC_POST_RENDER, ShowText);