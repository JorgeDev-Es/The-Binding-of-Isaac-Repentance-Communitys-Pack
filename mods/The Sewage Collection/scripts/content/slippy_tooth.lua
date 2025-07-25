--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local next = next

local item = {
    ID = Isaac.GetItemIdByName("Slippy tooth"),
    EFFECTS = Isaac.GetEntityVariantByName("SEWCOL status effects"),

    TRIGGER_CHANCE = 14,
    TIMEOUT = 120,
    RATE = 11,
    MAX_CREEP = 80,

    KEY = "SLTO",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Slippy Tooth", DESC = "Sometimes shoot slippy tears#Enemies leave friendly poop creep when hit with them" },
        { LANG = "ru",    NAME = "Скользкий зуб", DESC = "Шанс выстрелить скользкими слезами#Враги оставляют дружественных лужи какашек при попадании в них" },
        { LANG = "spa",   NAME = "Diente resbaladizo", DESC = "Podrás disparar lágrimas resbaladizas#Los enemigos soltarán creep de popó al golpearlos con ellas" },
        { LANG = "zh_cn", NAME = "湿滑的牙齿", DESC = "角色有14%的概率射出棕色眼泪#被击中的怪物移动时会在身后留下棕色水渍#角色站在水渍上会获得攻击和射速加成" },
        { LANG = "ko_kr", NAME = "미끄러운 이빨", DESC = "14%의 확률로 적에게 공격력 x1.5의 피해를 주는 갈색 장판을 뿌리는 눈물을 발사합니다." },
    },
    EID_TRANS = { "collectible", Isaac.GetItemIdByName("Slippy tooth"), 7 },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "The player has a 14% chance to shoot a slippy tear."},
            {str = "Enemies hit with a slippy tear will temporarily leave a trail of friendly poop creep."},
            {str = "Counts towards the Oh Crap! transformation."},
        }
    }
}
-- Slippery
local activeEnts = {}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnUpdate()
    if next(activeEnts) ~= nil then
        local cont = SEWCOL.GAME:GetFrameCount() % item.RATE == 0

        for key, value in pairs(activeEnts) do
            if value.ent:IsDead() or value.time < 1 then
                activeEnts[key] = nil
                goto loopend
            end

            activeEnts[key].time = value.time-1

            if not cont then goto loopend end

            if Isaac.CountEntities(nil, 1000, EffectVariant.CREEP_LIQUID_POOP) < item.MAX_CREEP then
                SEWCOL.SeedSpawn(1000, EffectVariant.CREEP_LIQUID_POOP, 0, value.ent.Position, Vector(0,0), value.ent):Update()
            end

            ::loopend::
        end
    end
end

function item:OnHit(entity, _, _, source, _)
    if source.Entity and source.Entity:GetData().SEWCOL_SLIPPY and entity:CanShutDoors() then
        if not activeEnts[entity.InitSeed] then
            entity:SetColor(Color(0.3, 0.3, 0.3, 1, 0.850, 0.6, 0.168), item.TIMEOUT, 99, true, false)
    
            local eff = Isaac.Spawn(1000, item.EFFECTS, 0, entity.Position, Vector(0,0), entity):ToEffect()
            local sprite = eff:GetSprite()
    
            sprite.Offset = Vector(0, -(entity.Size * 2) - 10)
            sprite:Play('Slippy', true)
            eff:FollowParent(entity)
            eff.DepthOffset = entity.Position.Y + 10
        end
    
        activeEnts[entity.InitSeed] = { ent = entity, time = item.TIMEOUT }

        if Isaac.CountEntities(nil, 1000, EffectVariant.CREEP_LIQUID_POOP) < item.MAX_CREEP then
            SEWCOL.SeedSpawn(1000, EffectVariant.CREEP_LIQUID_POOP, 0, entity.Position, Vector(0,0), source.Entity):Update()
        end
    end
end

function item:OnShot(shot)
    local player = SEWCOL.GetShooter(shot)

    if player and TCC_API:Has(item.KEY, player) > 0 and player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= item.TRIGGER_CHANCE then
        shot:GetData().SEWCOL_SLIPPY = true
        shot:SetColor(Color(0.8, 0.4, 0.2,1,0,0,0), 0, 99, true, true)
    end
end

local function OnEff(_, effect)
    if not effect.Parent or effect.Parent:IsDead() or not activeEnts[effect.Parent.InitSeed] then
        effect:Remove()
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    SEWCOL:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,           item.OnHit)
    SEWCOL:AddCallback(ModCallbacks.MC_POST_UPDATE,               item.OnUpdate)
    SEWCOL:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,            item.OnShot)
    SEWCOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnEff, item.EFFECTS)
end

function item:Disable()
    SEWCOL:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,           item.OnHit)
    SEWCOL:RemoveCallback(ModCallbacks.MC_POST_UPDATE,               item.OnUpdate)
    SEWCOL:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,            item.OnShot)
    SEWCOL:RemoveCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnEff, item.EFFECTS)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item