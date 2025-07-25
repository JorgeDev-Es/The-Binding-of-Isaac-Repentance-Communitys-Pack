GOLCG.DRESSER_MACHINE = Isaac.GetEntityVariantByName("GOLCOL Dresser Machine")

if EID then
    EID:addEntity(6, 3320, 0, "Mom's Dresser", "Drops between 2 and 5 {{Coin}} when bombed#Small chance to break when bombed", "en_us")
    EID:addEntity(6, 3320, 0, "Комод мамы", "Выпадает от 2 до 5 {{Coin}} при взрыве#Небольшой шанс сломаться при взрыве", "ru")
    EID:addEntity(6, 3320, 0, "Tocador de mamá", "Suelta de 2 a 5 {{Coin}} al explotarlo#Pequeña posibilidad de romperlo al explotarlo", "spa")
    EID:addEntity(6, 3320, 0, "妈妈的首饰柜", "代替捐款机，只有小概率会被炸毁", "zh_cn")
    EID:addEntity(6, 3320, 0, "엄마의 화장대", "폭탄으로 터트릴 시 {{Coin}}동전을 2~5개 드랍합니다.#낮은 확률로 기계가 폭발합니다.", "ko_kr")
end

function GOLCG:OnDresserUpdate(machine)
    if not (machine.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND) or machine:GetData().GOLCOL_DR_BROKEN then return end -- If not broken then return

    -- Remove rewards
    for _, reward in ipairs(Isaac.FindByType(5, -1, -1)) do
        if reward.FrameCount <= 1 and reward.SpawnerType == 0
        and reward.Position:DistanceSquared(machine.Position) <= 400 then
            reward:Remove()
        end
    end
    
    -- Remove troll bombs
    for _, bomb in ipairs(Isaac.FindByType(4, -1, -1)) do
        if (bomb.Variant == 3 or bomb.Variant == 4)
        and bomb.FrameCount <= 1 and bomb.SpawnerType == 0
        and bomb.Position:DistanceSquared(machine.Position) <= 400 then
            bomb:Remove()
        end
    end

    local wasHit = false

    -- for _, exp in ipairs(Isaac.FindByType(1000, EffectVariant.BOMB_EXPLOSION, -1)) do
    --     if (exp.SpawnerType == 1 or exp.SpawnerType == 4)
    --     and (machine.Position - exp.Position):LengthSquared() <= ((100*exp:ToEffect().Scale) + machine.Size)^2 then
    --         wasHit = true
    --     end
    -- end

    local RNG = machine:GetDropRNG()

    if RNG:RandomInt(100)+1 <= 7 then
        -- BREAK LOGIC
        wasHit = true
        machine:GetSprite():ReplaceSpritesheet(0, 'gfx/items/slots/slot_dresser_broken.png')
        machine:GetSprite():LoadGraphics()
        machine:GetData().GOLCOL_DR_BROKEN = true
    else
        -- Replace broken machine with new one
        local room = GOLCG.GAME:GetRoom()
        local pos = room:GetGridPosition(room:GetGridIndex(machine.Position))
        machine:Remove()
        machine = GOLCG.SeedSpawn(EntityType.ENTITY_SLOT, GOLCG.DRESSER_MACHINE, 0, pos, Vector(0,0), machine)
    end

    RNG:Next()

    -- Spawn reward for bombing the machine
    for i=1, ((wasHit and 8 or 2) + RNG:RandomInt(4)) do
        GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, machine.Position + Vector(0, 25), RandomVector() * ((math.random() * 2) + 1), machine)
    end
end

TCC_API:AddTCCCallback("TCC_SLOT_UPDATE", GOLCG.OnDresserUpdate, GOLCG.DRESSER_MACHINE)

if MinimapAPI then
    MinimapAPI:AddPickup("GOLCOL Mom dresser", "GOLCOL Mom dresser", 6, 3320, 0, nil, "slots", 1100)
end