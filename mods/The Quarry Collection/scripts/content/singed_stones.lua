--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Singed stones"),
    EFFECT = Isaac.GetEntityVariantByName("QUACOL Fire jet"),
    
    TRIGGER_RATE = 50,
    TRIGGER_CHANCE = 60,
    RADIUS = 135,
    DAMAGE_MULTIPLIER = 2.5,
    SPEED = 0.2,

    VAR_DATA = {
        [1] = { ["Color"] = Color(1, 1, 1, 1, 0.8, 0, 0) },
        [2] = { ["Color"] = Color(0, 1, 1, 1, 0.3, 0.3, 0.8) },
        [3] = { ["Color"] = Color(1.5, 1, 2, 1, 0.4, 0, 0.8) },
        [4] = { ["Color"] = Color(1, 1, 1, 1, 1, 1, 1) },
    },

    KEY="SISO",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Singed Stones", DESC = "{{ArrowUp}} +0.2 speed#Fires flare up and hurt enemies" },
	    { LANG = "ru",    NAME = "Опаленные камни", DESC = "{{ArrowUp}} +0.2 скорости#Огонь вспыхивает и ранит врагов" },
        { LANG = "spa",   NAME = "Piedras al rojo vivo", DESC = "{{ArrowUp}} +0.2 de velocidad#Las fogatas lanzarán llamaradas y dañaran enemigos" },
        { LANG = "zh_cn", NAME = "烧焦的石头", DESC = "{{ArrowUp}} +0.2 移速#角色在战斗中时，房间内的火堆会不时爆燃一下#爆燃会对火堆周围的怪物造成2.5倍角色伤害" },
        { LANG = "ko_kr", NAME = "신즈의 돌덩이", DESC = "{{ArrowUp}} {{Speed}}이동속도 +0.2#일정 확률로 모닥불 주변의 적에게 캐릭터의 공격력 x2의 피해를 줍니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Fires ocationally flare up while the player is in combat."},
            {str = "When a fire flares up it will damage enemies in a radius of 135 units (~4.5 tiles)."},
            {str = "Fires do twice the players damage."},
            {str = "The item also grants a 0.2 speed up."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function triggerFires(fires, player, isFirePlace)
    for i=1, #fires do
        if (isFirePlace and fires[i].HitPoints <= 1.0) or player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= item.TRIGGER_CHANCE then goto skipfire end

        local selection = fires[i]
        
        local effect1 = QUACOL.SeedSpawn(EntityType.ENTITY_EFFECT, item.EFFECT, 0, selection.Position, Vector(0,0), selection)
        effect1:GetData().QUACOL_RANGE = item.RADIUS
        effect1:GetData().QUACOL_DAMAGE = player.Damage*item.DAMAGE_MULTIPLIER
        
        if isFirePlace then            
            local specials = item.VAR_DATA[selection.Variant] or {}
            if specials.Color then
                effect1:SetColor(specials.Color, 0, 99, 0, false)
            end
        elseif selection.Variant == EffectVariant.BLUE_FLAME then
            effect1:SetColor(Color(0, 1, 1, 1, 0.3, 0.3, 0.8), 0, 99, 0, false)
        else
            effect1:SetColor(selection.Color, 0, 99, 0, false)
        end

        ::skipfire::
    end
end

function item:OnUpdate()
    if QUACOL.GAME:GetFrameCount() % item.TRIGGER_RATE == 0 and QUACOL.GAME:GetRoom():GetAliveEnemiesCount() > 0 then
        local player = Isaac.GetPlayer()
        -- local fires = Isaac.FindByType(EntityType.ENTITY_FIREPLACE)  

        triggerFires(Isaac.FindByType(EntityType.ENTITY_FIREPLACE), player, true)
        triggerFires(Isaac.FindByType(1000, EffectVariant.HOT_BOMB_FIRE), player)
        triggerFires(Isaac.FindByType(1000, EffectVariant.RED_CANDLE_FLAME), player)
        triggerFires(Isaac.FindByType(1000, EffectVariant.BLUE_FLAME), player)
    end
end

function item:OnCache(player, flag)
    if TCC_API:Has(item.KEY, player) then
        local amount = (item.SPEED*TCC_API:Has(item.KEY, player))
        player.MoveSpeed = (player.MoveSpeed + amount) > 2 and 2 or (player.MoveSpeed + amount)
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()  
    QUACOL:AddCallback(ModCallbacks.MC_POST_UPDATE, item.OnUpdate)
    QUACOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCache, CacheFlag.CACHE_SPEED)
    QUACOL.checkFlags(item.KEY, CacheFlag.CACHE_SPEED)
end

function item:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_UPDATE, item.OnUpdate)
    QUACOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCache, CacheFlag.CACHE_SPEED)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item