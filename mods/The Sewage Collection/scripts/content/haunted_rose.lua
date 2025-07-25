--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Haunted rose"),

    BOMB_CHANCE = 35,
    GHOULS = 4,

    -- Used to be 1 in lieu of missing data. but BetterBombs crashes if you modify some tearFlags on bombs on frame 1...
    FRAME = 2,

    KEY = "HARO",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_GREED_SECRET,
        ItemPoolType.POOL_CURSE,
        ItemPoolType.POOL_GREED_CURSE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Haunted Rose", DESC = "Taking damage may spawn souls#Bombs may be ghost bombs#{{EthernalHeart}} Spawn in pairs of two" },
        { LANG = "ru",    NAME = "Призрачная роза", DESC = "При получении урона могут появиться души#Бомбы могут быть бомбами-призраками#{{EthernalHeart}} Появляются в парах по два" },
        { LANG = "spa",   NAME = "Rosa Encantada", DESC = "Recibir daño podrá generar 'almas'#Las bombas podrán ser Bombas Fantasma#{{EthernalHeart}} se generarán en pares" },
        { LANG = "zh_cn", NAME = "闹鬼的玫瑰", DESC = "角色受到伤害会生成5只小幽灵#角色放置的炸弹有35%的概率转变为幽灵炸弹#{{EthernalHeart}} 每当自然生成半颗永恒之心，会同时生成另外半颗" },
        { LANG = "ko_kr", NAME = "유령 장미", DESC = "{{Collectible727}} 피격 시 35%의 확률로 유령 2~6마리가 소환됩니다.#{{Collectible727}} 폭탄 설치 시 35%의 확률로 유령 폭탄이 설치됩니다.#{{EthernalHeart}} 고정 드랍이 아닌 이터널하트가 1+1로 드랍됩니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When being hit up to 5 (friendly) souls may be spawned."},
            {str = "Bombs placed by the player have a 35% chance to be a ghost bomb."},
            {str = "When a natural eternal heart spawns it will be accompanied by a second half."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnDamage(entity, _, flags, source)
    local player = entity:ToPlayer()
    if TCC_API:Has(item.KEY, player) > 0 and source.Type ~= 6 and (flags & DamageFlag.DAMAGE_CURSED_DOOR) == 0 then

        for i=1, player:GetCollectibleRNG(item.ID):RandomInt(item.GHOULS)+2 do
            local rand = math.random(6)+9
            SEWCOL.SeedSpawn(1000, 186, 1, player.Position, Vector(rand,rand):Rotated(math.random(360)), player)
        end

        SEWCOL.SFX:Play(44, 1, 2, false, 2.1)
    end
end

function item:OnBomb(bomb)
    if not bomb:GetData().SEWCOL_HAUNTED and bomb.FrameCount > item.FRAME then
        bomb:GetData().SEWCOL_HAUNTED = true
        local player = SEWCOL.GetShooter(bomb)
        if player and TCC_API:Has(item.KEY, player) > 0 and player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= item.BOMB_CHANCE then
            -- bomb:AddTearFlags(BitSet128(0,1<<(78 - 64))) -- TODO: Had to do this because bomb flags are currently broken. Make sure to change this to the correct value when the API is fixed
            bomb:AddTearFlags(TearFlags.TEAR_GHOST_BOMB)
        end
    end
end

function item:OnSpawn(pickup)
    local vel = pickup.Velocity:Distance(Vector(0,0)) > 0 and pickup.Velocity:Rotated(180) or Vector(1,1):Rotated(math.random(360))
    SEWCOL.SeedSpawn(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, pickup.Position, vel, pickup)
end


--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    SEWCOL:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,  item.OnDamage, EntityType.ENTITY_PLAYER)
    SEWCOL:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, item.OnBomb)
    TCC_API:AddTCCCallback("TCC_ON_SPAWN", item.OnSpawn, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL)
end

function item:Disable()
    SEWCOL:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,     item.OnDamage, EntityType.ENTITY_PLAYER)
    SEWCOL:RemoveCallback(ModCallbacks.MC_POST_BOMB_UPDATE, item.OnBomb)
    TCC_API:RemoveTCCCallback("TCC_ON_SPAWN", item.OnSpawn, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item