--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Ancestral assistance"),
    PICKUP_SFX = Isaac.GetMusicIdByName("TOYCOL_ANCESTRAL_ASSISTANCE_PICKUP"),
    SHOT_SFX = Isaac.GetSoundIdByName("TOYCOL_ANCESTRAL_ASSISTANCE_SHOT"),

    TRIGGER_CHANCE = 11,
    KNIFE_CHANCE = 14,
    LASER_CHANCE = 24,
    BOMB_CHANCE = 27,

    BLACKLIST = {
        [3] = true,
        [7] = true,
        [8] = true,
        [10] = true
    },

    VELOCITY_MULTIPLIER = 9,
    DAMAGE_MULTIPLIER = 1.8,
    KNOCKBACK_MULTIPLIER = 5,

    KEY="ANAS",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_ANGEL,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_ANGEL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Ancestral Assistance", DESC = "Sometimes shoot an arrow of piercing tears#Grants a one-use holy mantle" },
        { LANG = "ru",    NAME = "Помощь предков", DESC = "Иногда стреляет стрелой пронзительных слез#Дает одноразовую святую мантию" },
        { LANG = "spa",   NAME = "Asistencia ancestral", DESC = "Se dispararán una ráfaga de lágrimas en forma de flecha#{{HolyMantle}} Otorga un escudo que protege una vez" },
        { LANG = "zh_cn", NAME = "先祖庇佑", DESC = "{{Card51}} 获得一次性神圣屏障效果#角色有9%的概率射出箭头状泪阵，穿透并击退怪物，造成1.8倍角色伤害#(出自 奥日与黑暗森林)" },
        { LANG = "ko_kr", NAME = "선대의 지혜", DESC = "{{Card51}} 보호막 +1#공격 키를 누른 상태에서 9%의 확률로 적을 관통하는 '<' 모양의 눈물 더미를 발사합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "The player has a 9% chance to shoot an arrow of tears."},
            {str = "These tears will have piercing, Do 1.6x the players damage and high knockback."},
            {str = "Upon pickup this item will also grant a one-use holy mantle."}
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "Ori and the blind forest".'},
            {str = 'The item is referencing the "Double Jump" skill within the game.'},
        }
    }
}

local translatedDirections = {
    [Direction.NO_DIRECTION] = 90,
    [Direction.LEFT] = 180,
    [Direction.UP] = 270,
    [Direction.RIGHT] = 0,
    [Direction.DOWN] = 90,
}

local translatedRotations = {
    { ["Deg"] = 0, ["Mult"] = 1 },
    { ["Deg"] = -2, ["Mult"] = 15 },
    { ["Deg"] = 2 , ["Mult"] = 15 },
    { ["Deg"] = -4, ["Mult"] = 26 },
    { ["Deg"] = 4, ["Mult"] = 26 },
    { ["Deg"] = 0, ["Mult"] = 20 }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function triggerEffect(player, source, flags, type)
    if player and TCC_API:Has(item.KEY, player) > 0 and player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= (item[type]*TCC_API:Has(item.KEY, player)) then
        local direction = player:GetAimDirection()
        --TODO: Replace with head direction DEG to vector
        if not direction or direction:Distance(Vector(0,0)) <= 0 then direction = Vector.FromAngle(translatedDirections[player:GetHeadDirection()]) end
        direction = direction:Rotated(math.random(-20, 20))

        for i=1, #translatedRotations do
            local curTear = TOYCG.GAME:Spawn(
                EntityType.ENTITY_TEAR, 
                TearVariant.BLUE, 
                translatedRotations[i].Mult and player.Position-(direction*translatedRotations[i].Mult) or player.Position,
                (direction*item.VELOCITY_MULTIPLIER):Rotated(translatedRotations[i].Deg),
                player,
                0,
                source.InitSeed
            ):ToTear()

            curTear:AddTearFlags((flags | TearFlags.TEAR_PIERCING))
            curTear.CollisionDamage = source.CollisionDamage*item.DAMAGE_MULTIPLIER
            curTear:SetKnockbackMultiplier(item.KNOCKBACK_MULTIPLIER)
            curTear.CanTriggerStreakEnd = false
            curTear:SetColor(Color(1, 1, 1, 1, 0.75, 0.75, 0.75), 0, 1, false, false)
            curTear:GetData()['TOYCOL_ANC_SPAWN'] = true
        end

        TOYCG.SFX:Play(item.SHOT_SFX, 1, 0, false)
        
        -- Isaac.Spawn(EntityType.ENTITY_EFFECT, 40, 0, Vector(320, 300), Vector(0,0), player)
        --TODO: Add spawn effect
        return true
    end
end

function item:OnBomb(source)
    if source.FrameCount == 1 and source.IsFetus then
        local spawned = triggerEffect(TOYCG.GetShooter(source), source, source.Flags, "BOMB_CHANCE")
        if spawned then source:AddTearFlags(TearFlags.TEAR_SPECTRAL) end
    end
end

function item:OnKnife(source, col)
    if col:IsActiveEnemy(false) then 
        triggerEffect(TOYCG.GetShooter(source), source, source.TearFlags, "KNIFE_CHANCE")
    end
end

function item:OnLaser(source)
    if not source:GetData().TOYCOL_INIT and source.Visible then
        source:GetData().TOYCOL_INIT = true
        if not item.BLACKLIST[source.Variant] then
            triggerEffect(TOYCG.GetShooter(source), source, source.TearFlags, "LASER_CHANCE")
        end
    end
end

function item:OnFire(source)
    if not source:GetData()['TOYCOL_ANC_SPAWN'] then
        triggerEffect(TOYCG.GetShooter(source), source, source.TearFlags, "TRIGGER_CHANCE")
    end
end

function item:OnGrab() TOYCG.SharedOnGrab(item.PICKUP_SFX, 5, nil, true) end
function item:OnCollect(player, _, touched) if not touched then player:UseCard(Card.CARD_HOLY, 259) end end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    TOYCG:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,      item.OnFire )
    TOYCG:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE,   item.OnLaser)
    TOYCG:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, item.OnKnife)
    TOYCG:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE,    item.OnBomb )
end

function item:Disable()
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,      item.OnFire )
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_LASER_UPDATE,   item.OnLaser)
    TOYCG:RemoveCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, item.OnKnife)
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_BOMB_UPDATE,    item.OnBomb )
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab,    item.ID, false)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect, item.ID, false)

return item