(local mod (RegisterMod "Gold rune" 1))
(local goldrune (Isaac.GetCardIdByName :goldrune))

; Utility functions
; =================
(fn log [text] (Isaac.DebugString (.. "[gold rune] " text)) nil)
(fn concat [seq1 seq2]
  (each [_ elem (ipairs seq2)]
    (table.insert seq1 elem))
  seq1)

; Constants
; =========
(local game (Game))
(local sfx (SFXManager))

; Mod Constants
; =============
(local goldrune-effect-radius 100)
(local magicchalk-mult 1.6)
(local goldrune-spawn-rate 0.333)
(local GridPoopVariantGold 3)
(local GridPoopVariantRed 1)

; Other mods integration
; ======================
(when EID
  (EID:addCard goldrune
    "{{Blank}} Turns things around Isaac to {{ColorYellow}}gold{{CR}}
     # Works with {{Heart}}, {{Coin}}, {{Key}}, {{Bomb}}, {{Pill}},
       {{Battery}}, {{Trinket}}, chests, and troll bombs
     # Also rocks and poops
     # {{Collectible44}}, {{Collectible126}}, {{Collectible249}},
       {{Collectible670}}, {{Collectible521}} and {{Collectible201}} become {{ColorYellow}}gold{{CR}}
     # Enemies get {{Collectible202}}" "Gold Rune" "en_us")
  (EID:addCard goldrune
    "{{Blank}} Transforme les objets autour d'Isaac en {{ColorYellow}}or{{CR}}
     # Fonctionne avec {{Heart}}, {{Coin}}, {{Key}}, {{Bomb}}, {{Pill}},
       {{Battery}}, {{Trinket}}, coffres, et bombes troll
     # Aussi avec les pierres et cacas
     # {{Collectible44}}, {{Collectible126}}, {{Collectible249}},
       {{Collectible670}}, {{Collectible521}} and {{Collectible201}} deviennent leur version en {{ColorYellow}}or{{CR}}
     # Paralyse les monstres avec {{Collectible202}}" "Rune d'or" "fr")
  (EID:addCard goldrune
    "{{Blank}} Cambia cose prossima di Isaac in {{ColorYellow}}oro{{CR}}
     # Funziona con {{Heart}}, {{Coin}}, {{Key}}, {{Bomb}}, {{Pill}},
       {{Battery}}, {{Trinket}}, casse, e bomba troll
     # Anche con pietre e cacca
     # {{Collectible44}}, {{Collectible126}}, {{Collectible249}},
       {{Collectible670}}, {{Collectible521}} and {{Collectible201}} diventano d'{{ColorYellow}}oro{{CR}}
     # Paralizza mostri con {{Collectible202}} effeto" "Runa d'oro" "it"))
(when MinimapAPI
  (local goldrune-sprite (Sprite))
  (goldrune-sprite:Load "gfx/ui/goldrune-minimap.anm2" true)
  (MinimapAPI:AddPickup :goldrune
    { :anim "IconGoldRune" :sprite goldrune-sprite }
    EntityType.ENTITY_PICKUP
    PickupVariant.PICKUP_TAROTCARD
    goldrune
    MinimapAPI.PickupNotCollected
    :cards 14000))

; Mod functions
; =============
(fn magicchalk? [player]
  (local magicchalk (Isaac.GetItemIdByName "Magic Chalk"))
  (player:HasCollectible magicchalk))

(fn chalk-mul [player] (if (magicchalk? player) magicchalk-mult 1))

(fn card-spawn-overwrite [_ rng card playing-cards? runes? just-runes?]
  (when (and (= card goldrune) (> (rng:RandomFloat) goldrune-spawn-rate))
    (local pool (game:GetItemPool))
    (pool:GetCard (rng:Next) playing-cards? runes? just-runes?)))

(fn spawn-gold-effects [player radius]
  ; Spawn the yellow splatter and gold particles
  ; Also sound effect
  (let
    [position player.Position
     crater (game:Spawn
              EntityType.ENTITY_EFFECT
              EffectVariant.BOMB_CRATER
              position
              Vector.Zero
              player
              0
              player.InitSeed)
     gold-color     (Color 0.9 0.8 0   1   0.8 0.7 0)
     crater-sprite  (crater:GetSprite)
     particle-speed (* 8 (chalk-mul player))]
  (crater:SetColor gold-color 150 1 false false)
  (set crater-sprite.Scale (* Vector.One 2.5 (chalk-mul player)))
  (sfx:Play SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
  (game:SpawnParticles position EffectVariant.COIN_PARTICLE 40 particle-speed)
  (game:SpawnParticles position EffectVariant.GOLD_PARTICLE 40 particle-speed)))

(fn transmute-grid [player]
  ; Turns rocks and poops into their gold counterparts
  (let
    [get   GridEntityType
     room  (game:GetRoom)
     p     (room:GetGridIndex player.Position)
     width (room:GetGridWidth)
     north (- width)
     south width 
     east  -1
     west  1
     ; "Navigates" the grid entities by goind up-left-left etc.
     grid-positions
       [ (+ west west p) (+ west p) p (+ east p) (+ east east p)
         (+ north west p) (+ north p) (+ north east p)
         (+ south west p) (+ south p) (+ south east p) ]
     extra-horn-positions
       (if (magicchalk? player) 
         [ (+ west west west p) (+ east east east p)
           (+ north west west p) (+ north east east p) (+ north north p)
           (+ south west west p) (+ south east east p) (+ south south p) ]
         [])
     all-positions (concat grid-positions extra-horn-positions)]
    (each [_ idx (ipairs all-positions)]
      (local entity (room:GetGridEntity idx))
      (fn spawn [type variant]
        (entity:Destroy true)
        (room:SpawnGridEntity idx type variant player.InitSeed entity.VarData))
      (if
        (and entity (= (entity:GetType) get.GRID_ROCK))
          (spawn get.GRID_ROCK_GOLD 0)
        (and entity (= (entity:GetType) get.GRID_POOP))
          (do
            (entity:SetVariant GridPoopVariantRed) ; Prevents drops when destroying
            (spawn get.GRID_POOP GridPoopVariantGold))))))

(fn transmute [player entity]
  (let
    [transform (fn [from { :t type :v variant :s subtype}]
       (local { : Position : Velocity : SpawnerEntity : InitSeed } from)
       (local pickup (from:ToPickup))
       (from:Remove)
       (if pickup
         (pickup:Morph type variant subtype true true true)
         (game:Spawn type variant Position Velocity SpawnerEntity subtype InitSeed))
       (game:SpawnParticles Position EffectVariant.POOF01 1 0))

     { :Type t :Variant v :SubType s } entity
     pkup EntityType.ENTITY_PICKUP
     bmb  EntityType.ENTITY_BOMBDROP
     pv   PickupVariant
     ct   CollectibleType
     col  pv.PICKUP_COLLECTIBLE
     bv   BombVariant
     fam  EntityType.ENTITY_FAMILIAR
     dip  FamiliarVariant.DIP
     clot FamiliarVariant.BLOOD_BABY
     target (if
       (and (= t pkup) (= v pv.PICKUP_HEART))       { : t : v :s HeartSubType.HEART_GOLDEN }
       (and (= t pkup) (= v pv.PICKUP_COIN))        { : t : v :s CoinSubType.COIN_GOLDEN }
       (and (= t pkup) (= v pv.PICKUP_KEY))         { : t : v :s KeySubType.KEY_GOLDEN }
       (and (= t pkup) (= v pv.PICKUP_BOMB))        { : t : v :s BombSubType.BOMB_GOLDEN }
       (and (= t pkup) (= v pv.PICKUP_PILL))        { : t : v :s PillColor.PILL_GOLD }
       (and (= t pkup) (= v pv.PICKUP_LIL_BATTERY)) { : t : v :s BatterySubType.BATTERY_GOLDEN }
       (and (= t pkup) (= v pv.PICKUP_TRINKET))     { : t : v :s (bor entity.SubType TrinketType.TRINKET_GOLDEN_FLAG) }
       (and (= t pkup) (= v pv.PICKUP_CHEST))       { : t :v PickupVariant.PICKUP_LOCKEDCHEST : s }
       (and (= t pkup) (= v pv.PICKUP_BOMBCHEST))   { : t :v PickupVariant.PICKUP_LOCKEDCHEST : s }
       (and (= t pkup) (= v pv.PICKUP_WOODENCHEST)) { : t :v PickupVariant.PICKUP_LOCKEDCHEST : s }
       (and (= t pkup) (= v pv.PICKUP_REDCHEST))    { : t :v PickupVariant.PICKUP_LOCKEDCHEST : s }
       (and (= t pkup) (= v col) (= s ct.COLLECTIBLE_RAZOR_BLADE))    { : t : v :s ct.COLLECTIBLE_GOLDEN_RAZOR }
       (and (= t pkup) (= v col) (= s ct.COLLECTIBLE_TELEPORT))       { : t : v :s ct.COLLECTIBLE_TELEPORT_2 }
       (and (= t pkup) (= v col) (= s ct.COLLECTIBLE_THERES_OPTIONS)) { : t : v :s ct.COLLECTIBLE_MORE_OPTIONS }
       (and (= t pkup) (= v col) (= s ct.COLLECTIBLE_OPTIONS))        { : t : v :s ct.COLLECTIBLE_MORE_OPTIONS }
       (and (= t pkup) (= v col) (= s ct.COLLECTIBLE_COUPON))         { : t : v :s ct.COLLECTIBLE_MEMBER_CARD }
       (and (= t pkup) (= v col) (= s ct.COLLECTIBLE_IRON_BAR))       { : t : v :s ct.COLLECTIBLE_MIDAS_TOUCH }
       (and (= t bmb)  (= v bv.BOMB_TROLL))      { : t :v bv.BOMB_GOLDENTROLL : s }
       (and (= t bmb)  (= v bv.BOMB_SUPERTROLL)) { : t :v bv.BOMB_GOLDENTROLL : s }
       (and (= t fam)  (= v dip))  { : t : v :s 3 }
       (and (= t fam)  (= v clot)) { : t : v :s 4 }
       (entity:IsActiveEnemy) (do (entity:AddMidasFreeze (EntityRef player) (* 240 (chalk-mul player)) nil)))]
    (when target (transform entity target))))

(fn goldrune-effect [_ card player use-flags]
  (when (= card goldrune)
    (log "Used a Gold Rune")
    (local effect-radius (* goldrune-effect-radius (chalk-mul player)))
    (spawn-gold-effects player effect-radius)
    (transmute-grid player)
    (local affected-entities (Isaac.FindInRadius player.Position effect-radius))
    (each [_ entity (pairs affected-entities)] (transmute player entity))))

(mod:AddCallback ModCallbacks.MC_GET_CARD card-spawn-overwrite)
(mod:AddCallback ModCallbacks.MC_USE_CARD goldrune-effect)
