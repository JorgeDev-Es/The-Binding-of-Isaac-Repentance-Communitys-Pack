--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Golden god!"),
    EFFECT = Isaac.GetEntityVariantByName("Golden god shine"),

    PICKUPS = {
        [10] = HeartSubType.HEART_GOLDEN, -- Heart
        [20] = CoinSubType.COIN_GOLDEN, --Coin
        [30] = KeySubType.KEY_GOLDEN, -- Key
        [70] = PillColor.PILL_GOLD, -- Pill ?
        [90] = BatterySubType.BATTERY_GOLDEN, -- Battery
    },
    CONSUMABLES = {
        [CollectibleType.COLLECTIBLE_IRON_BAR] = CollectibleType.COLLECTIBLE_MIDAS_TOUCH,
        [CollectibleType.COLLECTIBLE_WOODEN_NICKEL] = CollectibleType.COLLECTIBLE_QUARTER,
        [CollectibleType.COLLECTIBLE_SPEAR_OF_DESTINY] = CollectibleType.COLLECTIBLE_SPIRIT_SWORD,
        [CollectibleType.COLLECTIBLE_BLANK_CARD] = CollectibleType.COLLECTIBLE_MEMBER_CARD,

        [CollectibleType.COLLECTIBLE_TELEPORT] = CollectibleType.COLLECTIBLE_TELEPORT_2,
        [CollectibleType.COLLECTIBLE_DOCTORS_REMOTE] = CollectibleType.COLLECTIBLE_TELEPORT_2,
        [CollectibleType.COLLECTIBLE_PAUSE] = CollectibleType.COLLECTIBLE_TELEPORT_2,

        [CollectibleType.COLLECTIBLE_THERES_OPTIONS] = CollectibleType.COLLECTIBLE_MORE_OPTIONS,
        [CollectibleType.COLLECTIBLE_OPTIONS] = CollectibleType.COLLECTIBLE_MORE_OPTIONS,

        [CollectibleType.COLLECTIBLE_SINUS_INFECTION] = CollectibleType.COLLECTIBLE_NUMBER_ONE,
        [CollectibleType.COLLECTIBLE_ANEMIC] = CollectibleType.COLLECTIBLE_NUMBER_ONE,
        [CollectibleType.COLLECTIBLE_ANTI_GRAVITY] = CollectibleType.COLLECTIBLE_NUMBER_ONE,
        [CollectibleType.COLLECTIBLE_BLOODY_LUST] = CollectibleType.COLLECTIBLE_NUMBER_ONE,

        [CollectibleType.COLLECTIBLE_CAINS_OTHER_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_EYE_SORE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_EYE_OF_BELIAL] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_CURSED_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_MOMS_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_INNER_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_GUPPYS_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_BIRDS_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_BLOODSHOT_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_EVIL_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_DEAD_EYE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_MOMS_CONTACTS] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_PROPTOSIS] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_POLYPHEMUS] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_PEEPER] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_PUPULA_DUPLEX] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_GLAUCOMA] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_POP] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        [CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO] = CollectibleType.COLLECTIBLE_EYE_OF_GREED,

        [CollectibleType.COLLECTIBLE_KEEPERS_SACK] = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,
        [CollectibleType.COLLECTIBLE_SACK_OF_SACKS] = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,
        [CollectibleType.COLLECTIBLE_SACK_HEAD] = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,
        [CollectibleType.COLLECTIBLE_MYSTERY_SACK] = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,
        [CollectibleType.COLLECTIBLE_BLACK_POWDER] = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,

        [CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN] = CollectibleType.COLLECTIBLE_GLITCHED_CROWN,
        [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = CollectibleType.COLLECTIBLE_GLITCHED_CROWN,

        [CollectibleType.COLLECTIBLE_HOST_HAT] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_DECAP_ATTACK] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_ABEL] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_FATES_REWARD] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_CRICKETS_HEAD] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_VOODOO_HEAD] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_CONE_HEAD] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_GOAT_HEAD] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_GUPPYS_HEAD] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_TAMMYS_HEAD] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        [CollectibleType.COLLECTIBLE_MEGA_BLAST] = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER,
        
        [CollectibleType.COLLECTIBLE_KNIFE_PIECE_1] = CollectibleType.COLLECTIBLE_KEY_PIECE_1,
        [CollectibleType.COLLECTIBLE_KNIFE_PIECE_2] = CollectibleType.COLLECTIBLE_KEY_PIECE_2,

        [CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_1] = CollectibleType.COLLECTIBLE_KEY_PIECE_1,
        [CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_2] = CollectibleType.COLLECTIBLE_KEY_PIECE_2,

        [CollectibleType.COLLECTIBLE_MR_DOLLY] = CollectibleType.COLLECTIBLE_STRAW_MAN,
        [CollectibleType.COLLECTIBLE_STITCHES] = CollectibleType.COLLECTIBLE_STRAW_MAN,

        [CollectibleType.COLLECTIBLE_RAZOR_BLADE] = CollectibleType.COLLECTIBLE_GOLDEN_RAZOR,
        [CollectibleType.COLLECTIBLE_MOMS_RAZOR] = CollectibleType.COLLECTIBLE_GOLDEN_RAZOR,
        [CollectibleType.COLLECTIBLE_DULL_RAZOR] = CollectibleType.COLLECTIBLE_GOLDEN_RAZOR,
        [CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR] = CollectibleType.COLLECTIBLE_GOLDEN_RAZOR,

        [CollectibleType.COLLECTIBLE_SKELETON_KEY] = CollectibleType.COLLECTIBLE_MOMS_KEY,
        [CollectibleType.COLLECTIBLE_SHARP_KEY] = CollectibleType.COLLECTIBLE_MOMS_KEY,
        [CollectibleType.COLLECTIBLE_RED_KEY] = CollectibleType.COLLECTIBLE_MOMS_KEY,
        [CollectibleType.COLLECTIBLE_LATCH_KEY] = CollectibleType.COLLECTIBLE_MOMS_KEY,
        [CollectibleType.COLLECTIBLE_DADS_KEY] = CollectibleType.COLLECTIBLE_MOMS_KEY,

        [CollectibleType.COLLECTIBLE_CLICKER] = Isaac.GetItemIdByName("Shining clicker"),

        [CollectibleType.COLLECTIBLE_TRANSCENDENCE] = Isaac.GetItemIdByName("Gold rope"),

        [CollectibleType.COLLECTIBLE_HOURGLASS] = Isaac.GetItemIdByName("Ancient hourglass"),
        [CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = Isaac.GetItemIdByName("Ancient hourglass"),

        [CollectibleType.COLLECTIBLE_IPECAC] = Isaac.GetItemIdByName("Flakes of gold"),
        [CollectibleType.COLLECTIBLE_RUBBER_CEMENT] = Isaac.GetItemIdByName("Flakes of gold"),

        [CollectibleType.COLLECTIBLE_SMALL_ROCK] = Isaac.GetItemIdByName("Nugget"),
        [CollectibleType.COLLECTIBLE_ROCK_BOTTOM] = Isaac.GetItemIdByName("Nugget"),
        [CollectibleType.COLLECTIBLE_LODESTONE] = Isaac.GetItemIdByName("Nugget"),
        [CollectibleType.COLLECTIBLE_FLAT_STONE] = Isaac.GetItemIdByName("Nugget"),
        [CollectibleType.COLLECTIBLE_KIDNEY_STONE] = Isaac.GetItemIdByName("Nugget"),
        [CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL] = Isaac.GetItemIdByName("Nugget"),
        [CollectibleType.COLLECTIBLE_BROWN_NUGGET] = Isaac.GetItemIdByName("Nugget"),
    },
    CHESTS = {
        [PickupVariant.PICKUP_CHEST] = true,
        [PickupVariant.PICKUP_BOMBCHEST] = true,
        [PickupVariant.PICKUP_SPIKEDCHEST] = true,
        [PickupVariant.PICKUP_ETERNALCHEST] = true,
        [PickupVariant.PICKUP_MIMICCHEST] = true,
        [PickupVariant.PICKUP_OLDCHEST] = true,
        [PickupVariant.PICKUP_WOODENCHEST] = true,
        [PickupVariant.PICKUP_HAUNTEDCHEST] = true,
        [PickupVariant.PICKUP_LOCKEDCHEST] = true,
        [PickupVariant.PICKUP_REDCHEST] = true,
        [PickupVariant.PICKUP_MOMSCHEST] = true,
    },

    ENEMY_CHANCE = 20,      -- Midas (80%), Crown (20%)
    GRID_CHANCE = 40,       -- Fools gold (40%)
    PICKUP_CHANCE = 25,     -- Pickup transform (25%)
    MEGA_CHEST_CHANCE = 10, -- Mega chest (10%)

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_GREED_SECRET,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Golden God!", DESC = "Turns the room {{ColorYellow}}Gold#Chance to affect: enemies, rocks, pickups, collectibles, trinkets and chests" },
        { LANG = "ru",    NAME = "Золотой Бог!", DESC = "Превращает комнату в {{ColorYellow}}золото#Эффекты: враги, камни, подбираемые предметы, предметы коллекционирования, безделушки и сундуки." },
        { LANG = "spa",   NAME = "El dios del oro", DESC = "La habitación es convertida en {{ColorYellow}}Oro #Puede tanto congelar como fortalcer a los enemigos", "El dios del oro" },
        { LANG = "zh_cn", NAME = "金向箔！", DESC = "{{ColorYellow}}超级点石成金！#使用后，把整个房间都变成金的：#40%的概率将岩石变成愚人金、便便变成金便便#25%的概率将基础掉落和饰品变成金基础掉落和金饰品#25%的概率将宝箱变成金宝箱、10%的概率变成超级宝箱#80%的概率点金怪物，20%的概率加强怪物#40%的概率将道具变成类似的金色道具#打开所有门" },
        { LANG = "ko_kr", NAME = "Golden God!", DESC = "현재 방을 {{ColorGold}}황금색으로 바꿉니다.#현재 방의 모든 적들을 석화시키거나 왕관 챔피언으로 강화시킵니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Turn the room gold when used."},
            {str = "Replaces some rocks, poops, chests and pickups with their gold variant."},
            {str = "May turn trinkets gold."},
            {str = "Opens all doors."},
            {str = 'Either turns enemies into a crown champion or midas freezes them.'},
            {str = 'May turn gold chests into mega chests.'},
            {str = 'May turn some collectibles into their gold/money/greed themed variants (I.E: razor to gold razor)'},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--

local function goldifyRoom(RNG, player)
    local room = GOLCG.GAME:GetRoom()

    GOLCG.GAME:GetRoom():TurnGold()

    -- Spawn some particles
    for i = 1, 5 do
        GOLCG.GAME:SpawnParticles(Isaac.GetRandomPosition(), EffectVariant.GOLD_PARTICLE, 5, 1)
    end

    -- Open doors
    for i = 0, DoorSlot.NUM_DOOR_SLOTS-1 do
        local door = room:GetDoor(i)
        if door ~= nil then
            local doorSuccess = door:CanBlowOpen()
            if doorSuccess then
                door:Open()
            end 
        end
    end

    -- Replace rock and poops 
    for i = 1, room:GetGridSize() do
        local entity = room:GetGridEntity(i)

        if entity and RNG:RandomInt(100)+1 <= item.GRID_CHANCE then
            local type = entity.Desc.Type
            if type then
                if (type == GridEntityType.GRID_ROCK or type == GridEntityType.GRID_ROCK_SPIKED) then -- Fuck spiked rocks (｀∀´)Ψ
                    entity:Destroy(true) -- Using SetType won't update the rocks texture so i'm replacing it instead (drops loot of broken rocks but whatever)
                    room:SpawnGridEntity(i, GridEntityType.GRID_ROCK_GOLD, 0, entity:GetRNG():GetSeed(), entity.VarData)
                elseif type == GridEntityType.GRID_POOP and entity.Desc.Variant ~= 3 then -- Don't replace gold poops
                    entity:Destroy(true)
                    room:SpawnGridEntity(i, GridEntityType.GRID_POOP, 3, entity:GetRNG():GetSeed(), entity.VarData)
                end
            end
        end
    end

    local goldenColor =  Color(1,1,1,1)
    goldenColor:SetColorize(2.5,2.25,0,1)

    -- Replace pickups and enemies
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            entity = entity:ToNPC()
            if entity:IsBoss() then
                entity:TakeDamage(entity.MaxHitPoints/10, DamageFlag.DAMAGE_SPAWN_COIN, EntityRef(player), 0)
                entity:SetColor(goldenColor, 0, 3320, false, false)
            else
                if not entity:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) then                    
                    if RNG:RandomInt(100)+1 <= item.ENEMY_CHANCE then
                        entity:MakeChampion(entity:GetDropRNG():GetSeed(), ChampionColor.KING)
                    else
                        entity:Morph(entity.Type, entity.Variant, entity.SubType, -1)
                        entity:AddEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE | EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
                        entity:TakeDamage(entity.HitPoints-1, DamageFlag.DAMAGE_NOKILL, EntityRef(player), 0)
                        entity:AddMidasFreeze(EntityRef(player), 150)
                        entity:AddSlowing(EntityRef(player), 150, 0, goldenColor)
                        entity:SetColor(goldenColor, 0, 3320, false, false)
                        entity.CanShutDoors = false -- If they are frozen while being invincible you could get stuck
                    end
                end
            end

            entity:Update()
        elseif entity.Type == EntityType.ENTITY_PICKUP then
            entity = entity:ToPickup()

            if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and not entity:IsShopItem() and entity:GetSprite():GetOverlayFrame() == 0 then
                entity:GetSprite():ReplaceSpritesheet(3,"gfx/items/GOLCOL_levelitem_001_itemaltar.png")
                entity:GetSprite():ReplaceSpritesheet(4,"gfx/items/GOLCOL_levelitem_001_itemaltar.png")
                entity:GetSprite():ReplaceSpritesheet(5,"gfx/items/GOLCOL_levelitem_001_itemaltar.png")
                entity:GetSprite():LoadGraphics()
            end

            if RNG:RandomInt(100)+1 <= item.PICKUP_CHANCE then
                local isShop = false
                local price = 0
                local shopId = 0

                if entity:IsShopItem() then
                    isShop = true
                    price = entity.Price
                    shopId = entity.ShopItemId
                end

                local hasChanged = false
                if entity.Variant == GOLCG.FICHES.VARIANT then -- Handle custom pickup spawns
                    entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, true, true)
                elseif entity.Variant == PickupVariant.PICKUP_BOMB then -- Replace bombs/troll bombs
                    entity:Morph(entity.Type, entity.Variant, ((entity.SubType == 3 or entity.SubType == 5) and BombSubType.BOMB_GOLDENTROLL or BombSubType.BOMB_GOLDEN), true, true)
                    hasChanged = true
                elseif entity.Variant == PickupVariant.PICKUP_TRINKET and entity.SubType < 32768 then -- goldify trinkets
                    hasChanged = true
                    entity:Morph(entity.Type, entity.Variant, entity.SubType + 32768, true, true)
                elseif entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and item.CONSUMABLES[entity.SubType] then
                    hasChanged = true
                    entity:Morph(entity.Type, entity.Variant, item.CONSUMABLES[entity.SubType], true, true)
                elseif item.PICKUPS[entity.Variant] then
                    hasChanged = true
                    entity:Morph(entity.Type, entity.Variant, item.PICKUPS[entity.Variant], true, true)
                elseif item.CHESTS[entity.Variant] then
                    hasChanged = true
                    entity:Morph(entity.Type, ((RNG:RandomInt(100)+1 <= item.MEGA_CHEST_CHANCE or entity.Variant == PickupVariant.PICKUP_MOMSCHEST) and PickupVariant.PICKUP_MEGACHEST or PickupVariant.PICKUP_LOCKEDCHEST), 0, true, true)
                end

                if hasChanged then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ULTRA_GREED_BLING, 0, entity.Position, RandomVector() * ((math.random() * 2) + 1), nil)
                end

                if isShop then
                    entity.ShopItemId = shopId
                    entity.Price = price
                end

                entity:Update()
            end
        elseif entity.Type == 4 then
            entity:Remove()
            GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB,  BombSubType.BOMB_GOLDENTROLL, entity.Position, entity.Velocity, entity)
        elseif entity.Type ~= EntityType.ENTITY_PLAYER then
            entity:SetColor(goldenColor, 0, 3320, false, false)
        end
    end
end

function item:OnUse(_, RNG, player, _, _, _)

    -- Room effects
    GOLCG.GAME:ShakeScreen(35)
    local shineEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, item.EFFECT, 0, player.Position, Vector(0,0), player)
    shineEffect:GetData()['GOLCOL_GG_RNG'] = RNG
    shineEffect:GetSprite():Play('Idle')
    shineEffect.DepthOffset = 10000
    shineEffect:Update()

    -- Sound effects
    GOLCG.SFX:Play(SoundEffect.SOUND_ULTRA_GREED_TURN_GOLD_1, 1, 0)
    GOLCG.SFX:Play(SoundEffect.SOUND_GOLD_HEART, 1, 0)
    GOLCG.SFX:Play(SoundEffect.SOUND_FLASHBACK, 1, 0)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then 
        -- player:TriggerBookOfVirtues(CollectibleType.COLLECTIBLE_GOLDEN_RAZOR)
        player:AddWisp(CollectibleType.COLLECTIBLE_GOLDEN_RAZOR, player.Position)
    end
end

function item:OnEffectUpdate(effect)
    if effect:GetSprite():IsEventTriggered("IsFinished") then
        goldifyRoom((effect:GetData()['GOLCOL_GG_RNG'] or RNG()), effect.SpawnerEntity:ToPlayer() or Isaac.GetPlayer())
    elseif effect:GetSprite():IsEventTriggered("IsDead") then
        effect:Remove()
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
GOLCG:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, item.OnEffectUpdate, item.EFFECT)
GOLCG:AddCallback(ModCallbacks.MC_USE_ITEM,           item.OnUse,          item.ID    )

return item