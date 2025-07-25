--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = { 
    ID = Isaac.GetItemIdByName("Childrens fund"),

    KEY = "CHFU",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Childrens Fund", DESC = "{{Slotmachine}} Donation machines are now mom's dresser#{{Coin}} Machines drop more coins#{{Coin}} Beggars grant coins when giving an item" },
        { LANG = "ru",    NAME = "Детский фонд", DESC = "{{Slotmachine}} Машины для пожертвований теперь мамины комоды#{{Coin}} Машины сбрасывают больше монет#{{Coin}} Попрошайки дают монеты, отдавая артефакт" },
        { LANG = "spa",   NAME = "Fondo para la niñez", DESC = "{{Slotmachine}} Las máquinas de donación se convierten en tocadores de mamá#{{Coin}} Las máquinas sueltan más monetas#{{Coin}} Los méndigos dejan monedas" },
        { LANG = "zh_cn", NAME = "儿童基金", DESC = "{{Slotmachine}} 捐款机将被替换成妈妈的首饰柜#{{Coin}} 机器被摧毁时将掉落更多硬币#{{Coin}} 乞丐给予奖励时将额外掉落硬币" },
        { LANG = "ko_kr", NAME = "아이들의 펀드", DESC = "{{Slotmachine}} 기부기계가 엄마의 화장대로 바뀝니다.#이 엄마의 화장대는 8%의 확률로 폭발하지만 기부기계에 비해 더 적은 코인을 드랍합니다.#{{Coin}} 슬롯머신 파괴 시 동전을 4~8개 추가로 드랍합니다.#{{Coin}} 거지들이 아이템을 주고 떠날 시 동전을 4~8개 추가로 드랍합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = 'Slot machines now drop extra coins when broken. with a minimum of 4 and a maximum of 8 (plus an additional 2 for every "Childrens fund" item held.'},
            {str = "The same amount of coins drop when a beggar pays out an item."},
            {str = "Donation machines are replaced by mom's dresser. These dressers drop less coins than donation machines and have an 8% chance to break."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnSlot(machine)
    local multiplier = TCC_API:HasGlo(item.KEY)

    if multiplier > 0 then
        for i=1, (multiplier + math.random(3)) do
            GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, machine.Position, RandomVector() * ((math.random() * 2) + 1), machine)
            GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, machine.Position, RandomVector() * ((math.random() * 2) + 1), machine)
        end
    end
end

function item:OnMachineSpawn(type, variant, subtype, pos, vel, spawner, seed)
    if type == EntityType.ENTITY_SLOT and variant == 8 and TCC_API:HasGlo(item.KEY) > 0 then
        return { type, GOLCG.DRESSER_MACHINE, -1, seed }
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    GOLCG:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, item.OnMachineSpawn)
    TCC_API:AddTCCCallback("TCC_BEGGAR_LEAVE", item.OnSlot)
    TCC_API:AddTCCCallback("TCC_MACHINE_BREAK", item.OnSlot)

    for _, slot in pairs(Isaac.FindByType(6, 8)) do
        slot:Remove()
        GOLCG.SeedSpawn(EntityType.ENTITY_SLOT, GOLCG.DRESSER_MACHINE, -1, slot.Position, Vector(0,0), slot)
        GOLCG.GAME:SpawnParticles(slot.Position, EffectVariant.GOLD_PARTICLE, 5, 1)
        GOLCG.GAME:SpawnParticles(slot.Position, EffectVariant.CRACKED_ORB_POOF, 1, 0)
    end

    GOLCG.GAME:SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_BLOWN, false)
end

function item:Disable()
    GOLCG:RemoveCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, item.OnMachineSpawn)
    TCC_API:RemoveTCCCallback("TCC_BEGGAR_LEAVE", item.OnSlot)
    TCC_API:RemoveTCCCallback("TCC_MACHINE_BREAK", item.OnSlot)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item