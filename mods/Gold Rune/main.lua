local mod = RegisterMod("Gold rune", 1)
local goldrune = Isaac.GetCardIdByName("goldrune")
local function log(text)
  Isaac.DebugString(("[gold rune] " .. text))
  return nil
end
local function concat(seq1, seq2)
  for _, elem in ipairs(seq2) do
    table.insert(seq1, elem)
  end
  return seq1
end
local game = Game()
local sfx = SFXManager()
local goldrune_effect_radius = 100
local magicchalk_mult = 1.6
local goldrune_spawn_rate = 0.333
local GridPoopVariantGold = 3
local GridPoopVariantRed = 1
if EID then
  EID:addCard(goldrune, "{{Blank}} Turns things around Isaac to {{ColorYellow}}gold{{CR}}\n     # Works with {{Heart}}, {{Coin}}, {{Key}}, {{Bomb}}, {{Pill}},\n       {{Battery}}, {{Trinket}}, chests, and troll bombs\n     # Also rocks and poops\n     # {{Collectible44}}, {{Collectible126}}, {{Collectible249}},\n       {{Collectible670}}, {{Collectible521}} and {{Collectible201}} become {{ColorYellow}}gold{{CR}}\n     # Enemies get {{Collectible202}}", "Gold Rune", "en_us")
  EID:addCard(goldrune, "{{Blank}} Transforme les objets autour d'Isaac en {{ColorYellow}}or{{CR}}\n     # Fonctionne avec {{Heart}}, {{Coin}}, {{Key}}, {{Bomb}}, {{Pill}},\n       {{Battery}}, {{Trinket}}, coffres, et bombes troll\n     # Aussi avec les pierres et cacas\n     # {{Collectible44}}, {{Collectible126}}, {{Collectible249}},\n       {{Collectible670}}, {{Collectible521}} and {{Collectible201}} deviennent leur version en {{ColorYellow}}or{{CR}}\n     # Paralyse les monstres avec {{Collectible202}}", "Rune d'or", "fr")
  EID:addCard(goldrune, "{{Blank}} Cambia cose prossima di Isaac in {{ColorYellow}}oro{{CR}}\n     # Funziona con {{Heart}}, {{Coin}}, {{Key}}, {{Bomb}}, {{Pill}},\n       {{Battery}}, {{Trinket}}, casse, e bomba troll\n     # Anche con pietre e cacca\n     # {{Collectible44}}, {{Collectible126}}, {{Collectible249}},\n       {{Collectible670}}, {{Collectible521}} and {{Collectible201}} diventano d'{{ColorYellow}}oro{{CR}}\n     # Paralizza mostri con {{Collectible202}} effeto", "Runa d'oro", "it")
end
if MinimapAPI then
  local goldrune_sprite = Sprite()
  goldrune_sprite:Load("gfx/ui/goldrune-minimap.anm2", true)
  MinimapAPI:AddPickup("goldrune", {anim = "IconGoldRune", sprite = goldrune_sprite}, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, goldrune, MinimapAPI.PickupNotCollected, "cards", 14000)
end
local function magicchalk_3f(player)
  local magicchalk = Isaac.GetItemIdByName("Magic Chalk")
  return player:HasCollectible(magicchalk)
end
local function chalk_mul(player)
  if magicchalk_3f(player) then
    return magicchalk_mult
  else
    return 1
  end
end
local function card_spawn_overwrite(_, rng, card, playing_cards_3f, runes_3f, just_runes_3f)
  if ((card == goldrune) and (rng:RandomFloat() > goldrune_spawn_rate)) then
    local pool = game:GetItemPool()
    return pool:GetCard(rng:Next(), playing_cards_3f, runes_3f, just_runes_3f)
  end
end
local function spawn_gold_effects(player, radius)
  local position = player.Position
  local crater = game:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, position, Vector.Zero, player, 0, player.InitSeed)
  local gold_color = Color(0.9, 0.8, 0, 1, 0.8, 0.7, 0)
  local crater_sprite = crater:GetSprite()
  local particle_speed = (8 * chalk_mul(player))
  crater:SetColor(gold_color, 150, 1, false, false)
  crater_sprite.Scale = (Vector.One * 2.5 * chalk_mul(player))
  sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
  game:SpawnParticles(position, EffectVariant.COIN_PARTICLE, 40, particle_speed)
  return game:SpawnParticles(position, EffectVariant.GOLD_PARTICLE, 40, particle_speed)
end
local function transmute_grid(player)
  local get = GridEntityType
  local room = game:GetRoom()
  local p = room:GetGridIndex(player.Position)
  local width = room:GetGridWidth()
  local north = ( - width)
  local south = width
  local east = -1
  local west = 1
  local grid_positions = {(west + west + p), (west + p), p, (east + p), (east + east + p), (north + west + p), (north + p), (north + east + p), (south + west + p), (south + p), (south + east + p)}
  local extra_horn_positions
  if magicchalk_3f(player) then
    extra_horn_positions = {(west + west + west + p), (east + east + east + p), (north + west + west + p), (north + east + east + p), (north + north + p), (south + west + west + p), (south + east + east + p), (south + south + p)}
  else
    extra_horn_positions = {}
  end
  local all_positions = concat(grid_positions, extra_horn_positions)
  for _, idx in ipairs(all_positions) do
    local entity = room:GetGridEntity(idx)
    local function spawn(type, variant)
      entity:Destroy(true)
      return room:SpawnGridEntity(idx, type, variant, player.InitSeed, entity.VarData)
    end
    if (entity and (entity:GetType() == get.GRID_ROCK)) then
      spawn(get.GRID_ROCK_GOLD, 0)
    elseif (entity and (entity:GetType() == get.GRID_POOP)) then
      entity:SetVariant(GridPoopVariantRed)
      spawn(get.GRID_POOP, GridPoopVariantGold)
    end
  end
  return nil
end
local function transmute(player, entity)
  local transform
  local function _9_(from, _7_)
    local _arg_8_ = _7_
    local subtype = _arg_8_["s"]
    local type = _arg_8_["t"]
    local variant = _arg_8_["v"]
    local _local_10_ = from
    local InitSeed = _local_10_["InitSeed"]
    local Position = _local_10_["Position"]
    local SpawnerEntity = _local_10_["SpawnerEntity"]
    local Velocity = _local_10_["Velocity"]
    local pickup = from:ToPickup()
    from:Remove()
    if pickup then
      pickup:Morph(type, variant, subtype, true, true, true)
    else
      game:Spawn(type, variant, Position, Velocity, SpawnerEntity, subtype, InitSeed)
    end
    return game:SpawnParticles(Position, EffectVariant.POOF01, 1, 0)
  end
  transform = _9_
  local _let_12_ = entity
  local s = _let_12_["SubType"]
  local t = _let_12_["Type"]
  local v = _let_12_["Variant"]
  local pkup = EntityType.ENTITY_PICKUP
  local bmb = EntityType.ENTITY_BOMBDROP
  local pv = PickupVariant
  local ct = CollectibleType
  local col = pv.PICKUP_COLLECTIBLE
  local bv = BombVariant
  local fam = EntityType.ENTITY_FAMILIAR
  local dip = FamiliarVariant.DIP
  local clot = FamiliarVariant.BLOOD_BABY
  local target
  if ((t == pkup) and (v == pv.PICKUP_HEART)) then
    target = {s = HeartSubType.HEART_GOLDEN, t = t, v = v}
  elseif ((t == pkup) and (v == pv.PICKUP_COIN)) then
    target = {s = CoinSubType.COIN_GOLDEN, t = t, v = v}
  elseif ((t == pkup) and (v == pv.PICKUP_KEY)) then
    target = {s = KeySubType.KEY_GOLDEN, t = t, v = v}
  elseif ((t == pkup) and (v == pv.PICKUP_BOMB)) then
    target = {s = BombSubType.BOMB_GOLDEN, t = t, v = v}
  elseif ((t == pkup) and (v == pv.PICKUP_PILL)) then
    target = {s = PillColor.PILL_GOLD, t = t, v = v}
  elseif ((t == pkup) and (v == pv.PICKUP_LIL_BATTERY)) then
    target = {s = BatterySubType.BATTERY_GOLDEN, t = t, v = v}
  elseif ((t == pkup) and (v == pv.PICKUP_TRINKET)) then
    target = {s = (entity.SubType | TrinketType.TRINKET_GOLDEN_FLAG), t = t, v = v}
  elseif ((t == pkup) and (v == pv.PICKUP_CHEST)) then
    target = {s = s, t = t, v = PickupVariant.PICKUP_LOCKEDCHEST}
  elseif ((t == pkup) and (v == pv.PICKUP_BOMBCHEST)) then
    target = {s = s, t = t, v = PickupVariant.PICKUP_LOCKEDCHEST}
  elseif ((t == pkup) and (v == pv.PICKUP_WOODENCHEST)) then
    target = {s = s, t = t, v = PickupVariant.PICKUP_LOCKEDCHEST}
  elseif ((t == pkup) and (v == pv.PICKUP_REDCHEST)) then
    target = {s = s, t = t, v = PickupVariant.PICKUP_LOCKEDCHEST}
  elseif ((t == pkup) and (v == col) and (s == ct.COLLECTIBLE_RAZOR_BLADE)) then
    target = {s = ct.COLLECTIBLE_GOLDEN_RAZOR, t = t, v = v}
  elseif ((t == pkup) and (v == col) and (s == ct.COLLECTIBLE_TELEPORT)) then
    target = {s = ct.COLLECTIBLE_TELEPORT_2, t = t, v = v}
  elseif ((t == pkup) and (v == col) and (s == ct.COLLECTIBLE_THERES_OPTIONS)) then
    target = {s = ct.COLLECTIBLE_MORE_OPTIONS, t = t, v = v}
  elseif ((t == pkup) and (v == col) and (s == ct.COLLECTIBLE_OPTIONS)) then
    target = {s = ct.COLLECTIBLE_MORE_OPTIONS, t = t, v = v}
  elseif ((t == pkup) and (v == col) and (s == ct.COLLECTIBLE_COUPON)) then
    target = {s = ct.COLLECTIBLE_MEMBER_CARD, t = t, v = v}
  elseif ((t == pkup) and (v == col) and (s == ct.COLLECTIBLE_IRON_BAR)) then
    target = {s = ct.COLLECTIBLE_MIDAS_TOUCH, t = t, v = v}
  elseif ((t == bmb) and (v == bv.BOMB_TROLL)) then
    target = {s = s, t = t, v = bv.BOMB_GOLDENTROLL}
  elseif ((t == bmb) and (v == bv.BOMB_SUPERTROLL)) then
    target = {s = s, t = t, v = bv.BOMB_GOLDENTROLL}
  elseif ((t == fam) and (v == dip)) then
    target = {s = 3, t = t, v = v}
  elseif ((t == fam) and (v == clot)) then
    target = {s = 4, t = t, v = v}
  elseif entity:IsActiveEnemy() then
    target = entity:AddMidasFreeze(EntityRef(player), (240 * chalk_mul(player)), nil)
  else
  target = nil
  end
  if target then
    return transform(entity, target)
  end
end
local function goldrune_effect(_, card, player, use_flags)
  if (card == goldrune) then
    log("Used a Gold Rune")
    local effect_radius = (goldrune_effect_radius * chalk_mul(player))
    spawn_gold_effects(player, effect_radius)
    transmute_grid(player)
    local affected_entities = Isaac.FindInRadius(player.Position, effect_radius)
    for _0, entity in pairs(affected_entities) do
      transmute(player, entity)
    end
    return nil
  end
end
mod:AddCallback(ModCallbacks.MC_GET_CARD, card_spawn_overwrite)
return mod:AddCallback(ModCallbacks.MC_USE_CARD, goldrune_effect)
