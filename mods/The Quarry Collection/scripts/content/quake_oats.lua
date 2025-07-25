--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Quake oats"),

    TRIGGER_RATE = 28,
    SHOT_AMOUNT = 25,

    KEY="QUMU",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Quake Oats", DESC = "#Rains rocks from the sky#While held, Rains rocks in combat#Rocks have your tear effects" },
	    { LANG = "ru",    NAME = "Квакер Оутс", DESC = "#Дождь из камней с неба#Пока он держится, дождь из камней идёт в бою.#Камни имеют ваши эффекты слезы" },
        { LANG = "spa",   NAME = "Avena sísmica", DESC = "Empezarán a caer rocas#Mientras se conserve, caerán rocas ocasionalmente en combate#Las rocas tendrán tus efectos de lágrimas" },
        { LANG = "zh_cn", NAME = "地震燕麦片", DESC = "使用后在房间内生成大量岩石雨#持有时在战斗中持续生成少量岩石雨#岩石雨拥有角色的眼泪特效" },
        { LANG = "ko_kr", NAME = "지진 시리얼", DESC = "#!!! 소지 시 적이 있는 방에서 하늘에서 돌덩이가 떨어집니다.#사용 시 하늘에서 돌 무더기를 떨어뜨립니다.#떨어지는 돌의 효과는 플레이어의 눈물 효과의 영향을 받습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When used summons a bunch (25) of rocks that fall from the sky."},
            {str = "While held it also passively rains rocks while in combat."},
            {str = "All rocks have the players tear effects."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnUpdate(player)
    if QUACOL.GAME:GetFrameCount() % item.TRIGGER_RATE == 0 and player:HasCollectible(item.ID) then
        local room = QUACOL.GAME:GetRoom()
        
        if room:GetAliveEnemiesCount() > 0 then
            local shot = player:FireTear(room:GetRandomPosition(30), Vector(0,0), true, true, false, player, 2)
            shot:SetColor (Color(1,1,1,0), 5, 101, false, false)
            shot.Height = -(math.random(200)+600)
            shot.FallingSpeed = 10
            shot.FallingAcceleration = 1.5
            shot.Scale = 1

            shot:ChangeVariant(TearVariant.ROCK)
            shot:AddTearFlags(TearFlags.TEAR_ROCK)
        end
    end
end

function item:OnUse(_, RNG, player)
    local room = QUACOL.GAME:GetRoom()

    for i=1, item.SHOT_AMOUNT do
        local shot = player:FireTear(room:GetRandomPosition(30), Vector(0,0), true, true, false, player, 2.5)
        shot.Height = -(math.random(1000)+600)
        shot.FallingSpeed = 10
        shot.FallingAcceleration = 1.5
        shot.Scale = 1

        shot:ChangeVariant(TearVariant.ROCK)
        shot:AddTearFlags(TearFlags.TEAR_ROCK)
    end

    -- local discharge = RNG:RandomInt(100)+1 <= item.DISCHARGE_CHANCE and true or false

    -- if not discharge then
    --     QUACOL.SFX:Play(SoundEffect.SOUND_ITEMRECHARGE)
    --     local batEff = Isaac.Spawn(1000, EffectVariant.BATTERY, 0, player.Position-Vector(0, 60), player.Velocity, player)
    --     batEff.DepthOffset = player.Position.Y + 10
    -- end

    QUACOL.GAME:ShakeScreen(25)
    QUACOL.SFX:Play(SoundEffect.SOUND_GROUND_TREMOR)

    return {
        ['Discharge'] = true, --discharge,
        ['Remove'] = false,
        ['ShowAnim'] = true
    }
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
QUACOL:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)

function item:Enable()
    QUACOL:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, item.OnUpdate)
end

function item:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, item.OnUpdate)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item