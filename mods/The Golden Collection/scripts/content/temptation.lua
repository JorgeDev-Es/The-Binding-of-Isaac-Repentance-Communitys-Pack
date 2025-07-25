--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = { 
    ID = Isaac.GetItemIdByName("Temptation"),

    DAMAGE_VALUES = {
        [GOLCG.FICHES.SUB.PENNY] =      2.5,
        [GOLCG.FICHES.SUB.PENNY_NEG] =  2.5,
        [GOLCG.FICHES.SUB.NICKEL] =     5,
        [GOLCG.FICHES.SUB.NICKEL_NEG] = 5,
        [GOLCG.FICHES.SUB.DIME] =       8,
        [GOLCG.FICHES.SUB.DIME_NEG] =   8
    },

    KEY="TE",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BEGGAR,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Temptation", DESC = "Some enemies drop fiches#enemies are damaged by fiches" },
        { LANG = "ru",    NAME = "Искушение", DESC = "Некоторые враги сбрасывают фишки#враги получают урон от фишек" },
        { LANG = "spa",   NAME = "Tentación", DESC = "Algunos enemigos soltarán fichas#Los enemigos pueden ser dañados por las fichas" },
        { LANG = "zh_cn", NAME = "诱惑", DESC = "怪物死亡时概率掉落筹码 (特殊的硬币)#筹码会对其他怪物造成接触伤害，伤害数值依据筹码面额" },
        { LANG = "ko_kr", NAME = "유혹", DESC = "적 처치 시 일정 확률로 특수 코인을 드랍합니다.#특수 코인에 닿은 적들은 피해를 받습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Enemies may drop fiches (special coins) upon death."},
            {str = "These fiches will damage enemies that touch them. The amount of damage increases for higher value fiches."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function HandleNpcDamage(_, pickup)
    if pickup.SubType > 3319 and pickup.SubType < 3326 then
        local entities = Isaac.FindInRadius(pickup.Position, 10, 8)
        if entities then
            local damageResult = item.DAMAGE_VALUES[pickup.SubType] or 2
            
            for i, entity in pairs(entities) do
                if entity:IsActiveEnemy() then
                    entity:TakeDamage(damageResult, DamageFlag.DAMAGE_SPIKES, EntityRef(pickup), 0)
                end
            end
        end
    end
end

local function OnDeath(_, npc)
    local rng = npc:GetDropRNG()

    if rng:RandomInt(6) <= 1 and not GOLCG.GAME:GetRoom():IsClear() then
        local subType = GOLCG.CursedCoinPicker(rng)
        local pickup = GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, GOLCG.FICHES.VARIANT, (subType), GOLCG.GAME:GetRoom():FindFreePickupSpawnPosition(npc.Position, 0, false), Vector(0, 0), nil):ToPickup()

        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    GOLCG:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, HandleNpcDamage, GOLCG.FICHES.VARIANT)
    GOLCG:AddCallback(ModCallbacks.MC_POST_NPC_DEATH,     OnDeath                              )
end

function item:Disable()
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, HandleNpcDamage, GOLCG.FICHES.VARIANT)
    GOLCG:RemoveCallback(ModCallbacks.MC_POST_NPC_DEATH,     OnDeath                              )
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item