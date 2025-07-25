--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item  = {
    ID = Isaac.GetItemIdByName("Wow factor!"),
    EFFECT = Isaac.GetEntityVariantByName("Wow pickup effect"),
    
    PICKUP_SFX = Isaac.GetSoundIdByName("TOYCOL_WOW_PICKUP"),
    SPAWN_SFX = Isaac.GetSoundIdByName("TOYCOL_WOW_SPAWN"),

    CHANCE = 5,
    KNIFE_CHANCE = 12,
    LASER_CHANCE = 9,
    BOMB_CHANCE = 10,

    BLACKLIST = {
        [3] = true,
        [7] = true,
        [8] = true,
        [10] = true,
        [12] = true
    },

    AMOUNT = 30,
    RATE = 3,

    KEY = "WOFA",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Wow Factor!", DESC = "Sometimes shoot a stream of floating poison tears" },
        { LANG = "ru",    NAME = "Вау фактор!", DESC = "Иногда стреляйте потоком плавающих ядовитых слез" },
        { LANG = "spa",   NAME = "Factor ¡WOW!", DESC = "A veces soltará una ráfaga de lágrimas venenosas flotantes" },
        { LANG = "zh_cn", NAME = "眼前一亮！", DESC = "角色移动射击时有5%的概率在身后留下一连串漂浮的剧毒眼泪#(出自 蔚蓝)" },
        { LANG = "ko_kr", NAME = "Wow Factor!", DESC = "공격 키를 누른 상태에서 5%의 확률로 제자리에 떠다니는 독성 눈물을 뿌립니다.#독성 눈물은 이동 중일 때만 뿌려집니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "While shooting grants a 5% chance to start spawning a stream of floating poisonous tears."},
            {str = "After spawning 30 tears the effect stops."},
            {str = "If the player is not moving then the stream of tears pauses."},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "Celeste".'},
            {str = 'The item is based on a collectible called the "Moon berry" that can be found in the game.'},
        }
    }
}

local cachedPlayers = nil

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function triggerEffect(player, type)
    if player and TCC_API:Has(item.KEY, player) > 0 and #Isaac.FindByType(3, TearVariant.MYSTERIOUS) < 100 then
        local identifier = player.ControllerIndex..","..player:GetPlayerType()

        if not cachedPlayers[identifier] and player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= item[type] then
            cachedPlayers[identifier] = {
                ['amount'] = item.AMOUNT,
                ['scale'] = 0.5+(TCC_API:Has(item.KEY, player)*0.4),
                ['player'] = player 
            }
        end
    end
end

function item:OnBomb(source)
    if source.FrameCount == 1 and cachedPlayers and source.IsFetus then 
        triggerEffect(TOYCG.GetShooter(source), "BOMB_CHANCE")
    end
end

function item:OnKnife(source, col)
    if cachedPlayers and col:IsActiveEnemy(false) then 
        triggerEffect(TOYCG.GetShooter(source), "KNIFE_CHANCE")
    end
end

function item:OnLaser(source)
    if cachedPlayers and not item.BLACKLIST[source.Variant] then 
        triggerEffect(TOYCG.GetShooter(source), "LASER_CHANCE")
    end
end

function item:OnFire(source)
    if cachedPlayers then
        triggerEffect(TOYCG.GetShooter(source), "CHANCE")
    end
end

function item:OnUpdate()
    if cachedPlayers ~= nil and TOYCG.GAME:GetFrameCount() % item.RATE == 0 then
        for key, value in pairs(cachedPlayers) do
            local player = value.player

            if not (player.Velocity:Distance(Vector(0,0)) <= 0.5) then
                local newTear = player:FireTear(player.Position, player.Velocity:Rotated(180):Clamped(-0.001, -0.001, 0.001, 0.001), false, false, false, player, 1)
                newTear:AddTearFlags(TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP)
                newTear:ChangeVariant(TearVariant.MYSTERIOUS)
                newTear.FallingAcceleration = -0.1 -- Makes 'em float ఠ_ఠ
                newTear.Scale = value.scale
                newTear:SetColor(Color(1, 1, 1, 1, 0.25, 0.75, 0.25), 0, 1, false, false)
                newTear:GetData().TOYCOL_WOW = true

                TOYCG.SFX:Play(item.SPAWN_SFX, 0.5)
                TOYCG.SFX:Stop(SoundEffect.SOUND_TEARS_FIRE)
            end

            if value.amount > 1 then
                cachedPlayers[key].amount = value.amount-1
            else
                cachedPlayers[key] = nil
            end
        end
    end
end

function item:OnGrab(player)
    local Effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, item.EFFECT, 1, player.Position - Vector(0, 4), Vector(0, -1.25), player)
    local Sprite = Effect:GetSprite()
    Sprite:Play('Idle')
    Sprite.Scale = Vector(1.4,1.4)
    Effect.DepthOffset = 10000
    Effect:Update()

    TOYCG.SharedOnGrab(item.PICKUP_SFX)
end

function item:OnTearUpdate(tear)
    if tear.FrameCount > 120 and tear:GetData().TOYCOL_WOW then
        tear:Kill()
    end
end

function item:OnReset() cachedPlayers = {} end
function item:OnExit() cachedPlayers = nil end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    TOYCG:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,      item.OnFire  )
    TOYCG:AddCallback(ModCallbacks.MC_POST_LASER_INIT,     item.OnLaser )
    TOYCG:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, item.OnKnife )
    TOYCG:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE,    item.OnBomb  )
    TOYCG:AddCallback(ModCallbacks.MC_POST_UPDATE,         item.OnUpdate)
    TOYCG:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE,    item.OnTearUpdate)
    TOYCG:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,       item.OnExit  )

    cachedPlayers = {}
end

function item:Disable()
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,      item.OnFire  )
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_LASER_INIT,     item.OnLaser )
    TOYCG:RemoveCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, item.OnKnife )
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_BOMB_UPDATE,    item.OnBomb  )
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_UPDATE,         item.OnUpdate)
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_TEAR_UPDATE,    item.OnTearUpdate)
    TOYCG:RemoveCallback(ModCallbacks.MC_PRE_GAME_EXIT,       item.OnExit  )

    cachedPlayers = nil
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab, item.ID, false)

return item