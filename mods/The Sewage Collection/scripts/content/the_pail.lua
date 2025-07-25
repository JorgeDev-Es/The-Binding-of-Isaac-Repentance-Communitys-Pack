--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("The pail"),
    
    MIN_POOPS = 3,
    MAX_POOPS = 12,
    BIG_CHANCE = 9, -- This is always lower because the spawn mechanism i'm using may fail.
    
    GRID_OPTIONS = { 
        3, -- Gold
        4, -- Rainbow
        5, -- Black
        6, -- Holy
        11, -- Smile
    },
    ENT_OPTIONS = {
        11, -- Rock
        12, -- Corn
        13, -- Fire
        14, -- Poison
    },
    
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "The Pail", DESC = "Clears all obstacles#Fills all gaps#Spawns random poops" },
        { LANG = "ru",    NAME = "Ведро", DESC = "Убирает все препятствия# Заполняет все пробелы# Создает случайные какашки" },
        { LANG = "spa",   NAME = "La cubeta", DESC = "Clarifica los obstáculos#Rellenará todos los agujeros#Generará popó aleatori" },
        { LANG = "zh_cn", NAME = "便桶", DESC = "清除房间内所有障碍物#填平所有沟壑#生成一些大便" },
        { LANG = "ko_kr", NAME = "똥 양동이", DESC = "사용 시 모든 장애물을 제거하며 구덩이를 채웁니다.#랜덤 똥을 3~12개 소환합니다." },
    },
    EID_TRANS = {"collectible", Isaac.GetItemIdByName("The pail"), 7 },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When used the pail will try to destroy everything in the room. On top of this it will also try to fill all gaps."},
            {str = "After this it will spawn a selection of random poops (both grid and entities) between 3 and 12."},
            {str = "It also has a 9% chance to spawn a giant poop."},
            {str = "Counts towards the Oh Crap! transformation."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnUse(_, RNG, player, _, _, _)
    local room = SEWCOL.GAME:GetRoom()
    
    for i = 1, room:GetGridSize() do
        local entity = room:GetGridEntity(i)
        
        if entity then
            if entity.Desc.Type == GridEntityType.GRID_PIT then
                entity:ToPit():MakeBridge(nil)

                for i = 1, 3 do 
                    local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, entity.Position, RandomVector() * ((math.random() * 2) + 1), nil)
                    eff:SetColor(Color(0,0,0,0), 1, 99, false, false)
                end
            else
                entity:Destroy(true)
            end
        end
    end

    for i = 1, item.MIN_POOPS+RNG:RandomInt(item.MAX_POOPS - item.MIN_POOPS)+1 do
        local pos = room:FindFreePickupSpawnPosition(Isaac.GetRandomPosition(), 0, true, false)

        local selection = RNG:RandomInt(16)+1
            
        if selection <= 8 then
            Isaac.GridSpawn(GridEntityType.GRID_POOP, 0, pos, true)
        elseif selection <= 12 then
            Isaac.GridSpawn(GridEntityType.GRID_POOP, item.GRID_OPTIONS[math.random(#item.GRID_OPTIONS)], pos, true)
        else
            local ent = SEWCOL.SeedSpawn(EntityType.ENTITY_POOP, item.ENT_OPTIONS[math.random(#item.ENT_OPTIONS)], 0, pos, Vector(0,0), player)
            ent.TargetPosition = ent.Position -- Lock it into place
            ent.Mass = 999
        end
    end

    if RNG:RandomInt(100)+1 <= item.BIG_CHANCE then
        --TODO: This causes bugged grid entities when used multiple times in the same room. Find a fix or a better way of spawning the big poops?
        Isaac.ExecuteCommand("gridspawn 1499")
    end

    SEWCOL.GAME:Fart(player.Position, 90, player, 2, 0)

    SEWCOL.SFX:Play(SoundEffect.SOUND_FART_MEGA)

    -- if not player:IsHoldingItem() then
    --     player:TryHoldEntity(Isaac.Spawn(EntityType.ENTITY_POOP, item.ENT_OPTIONS[math.random(#item.ENT_OPTIONS)], 0, player.Position, Vector(0,0), player))
    --     SEWCOL.SFX:Play(SoundEffect.SOUND_POOPITEM_HOLD)
    -- end
end

function item:OnCollect(player, id, touched, isTrinket)
    if not touched then
        local room = SEWCOL.GAME:GetRoom()

        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_FLUSH, false, false, true, false, -1)
        SEWCOL.SFX:Stop(SoundEffect.SOUND_FLUSH)
        SEWCOL.SFX:Play(SoundEffect.SOUND_FART, 1.5, 0, false, 0.7)
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
SEWCOL:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)

TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCollect, item.ID, false)

return item