--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Blank"),
    
    TRIGGER_GFX = Isaac.GetEntityVariantByName("TOYCOL_BLANK_TRIGGER"),

    TRIGGER_SFX = Isaac.GetSoundIdByName("TOYCOL_BLANK_TRIGGER"),
    PICKUP_SFX = Isaac.GetSoundIdByName("TOYCOL_BLANK_PICKUP"),

    KEY = "BL",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CRANE_GAME,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Blank", DESC = "{{SoulHeart}} +1 Soul heart#Clears bullets and slows enemies upon damage" },
        { LANG = "ru",    NAME = "Пустышка", DESC = "{{SoulHeart}} +1 сердце души#Очищает пули и замедляет врагов при получении урона" },
        { LANG = "spa",   NAME = "Fogueo", DESC = "{{SoulHeart}} +1 Corazón de alma#Elimina lágrimas y ralentiza enemigos al recibir daño" },
        { LANG = "zh_cn", NAME = "空包弹", DESC = "{{SoulHeart}} +1 魂心#角色受伤时清除房间内所有子弹并减速怪物#(出自 挺进地牢)" },
        { LANG = "ko_kr", NAME = "공포탄", DESC = "{{SoulHeart}} 소울하트 +1#피격 시 방 안의 모든 탄막을 지우며 방 안의 모든 적을 둔화시킵니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants a soul heart."},
            {str = "Upon taking damage slows all enemies in the room and clears all bullets within the room."},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "Enter the Gungeon".'},
            {str = 'The item is referencing the "Blank" pickups within the game.'},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnDamage(entity, _, flags, _, _)
    local player = entity:ToPlayer()

    if TCC_API:Has(item.KEY, player) > 0 then
        local entities = Isaac.GetRoomEntities()

        for i=1, #entities do
            local entity = entities[i]

            if entity.Type == EntityType.ENTITY_PROJECTILE or entity.Type == EntityType.ENTITY_LASER or entity.Type == EntityType.ENTITY_KNIFE then
                if entity.SpawnerType ~= EntityType.ENTITY_PLAYER then
                    entity:Kill()
                end
            elseif entity:IsEnemy() then
                entity:AddSlowing(EntityRef(player), 70, 8, Color(0.75, 0.35, 0, 1, 0, 0, 0))
            end
        end

        local effect = TOYCG.GAME:Spawn(EntityType.ENTITY_EFFECT, item.TRIGGER_GFX, player.Position + Vector(0, -20), Vector(0,0), nil, 1, 0):ToEffect()
        effect.DepthOffset = 1000
        effect:FollowParent(player)
        effect:Update()
    
        TOYCG.GAME:ShakeScreen(10)
        TOYCG.SFX:Play(item.TRIGGER_SFX, 1)
    end
end

function item:OnGrab() TOYCG.SharedOnGrab(item.PICKUP_SFX) end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    TOYCG:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
end

function item:Disable()
    TOYCG:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab, item.ID, false)

return item