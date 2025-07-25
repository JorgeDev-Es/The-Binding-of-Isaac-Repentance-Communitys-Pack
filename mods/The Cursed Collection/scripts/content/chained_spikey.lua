--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local familiar = {
    ID = Isaac.GetItemIdByName("Chained spikey"),
    VARIANT = Isaac.GetEntityVariantByName("Chained spikey"),
    NAIL = Isaac.GetEntityVariantByName("CURCOL chained spikey nail"),

    DEG_SPEED = 3,
    HIT_RATE = 5,
    HIT_RADIUS = 30,
    DAMAGE = 15,
    BFF_DAMAGE = 30,

    GRID_WHITELIST = {
        [GridEntityType.GRID_ROCK] = true,
        [GridEntityType.GRID_ROCKB] = true,
        [GridEntityType.GRID_ROCK_BOMB] = true,
        [GridEntityType.GRID_ROCK_ALT] = true,
        [GridEntityType.GRID_ROCK_SS] = true,
        [GridEntityType.GRID_ROCK_SPIKED] = true,
        [GridEntityType.GRID_ROCK_ALT2] = true,
        [GridEntityType.GRID_ROCK_GOLD] = true,
    },

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Chained Spikey", DESC = "Familiar which hurts enemies and breaks rocks" },
        { LANG = "ru",    NAME = "Прикованный шип", DESC = "Спутник, который ранит врагов и разбивает камни" },
        { LANG = "spa",   NAME = "Spikey Encadenado", DESC = "Rota alrededor#Hiere a los enemigos#Puede romper rocas" },
        { LANG = "zh_cn", NAME = "流星锤", DESC = "进入有怪物的未探索房间时生成一个友方小流星锤" },
        { LANG = "ko_kr", NAME = "묶인 뾰족이", DESC = "방 진입 시 랜덤 장애물을 중심으로 돌아가는 가시공을 소환합니다.#가시공은 장애물을 부술 수 있으며 적에게 접촉 시 15의 피해를 줍니다." },
    },
    SM_DESCRIPTION = {
        '{{ArrowUp}}+1 Spike ball',
        '{{ArrowUp}}Spins faster'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Teleports to a random rock in the room when in combat."},
            {str = "The rock chosen by the familiar will be broken and replaced by a temporary metal block."},
            {str = "After this the familiar will rotate around this metal block and both damage enemies and break rocks when colliding with them."}
        },
        { -- Synergies
            {str = "Synergies", fsize = 2, clr = 3, halign = 0},
            {str = "While holding BFFS! the familiars damage is increased from 15 to 30 (x2)."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function familiar:OnInit(chainedSpikey)
    if Sewn_API then 
        Sewn_API:HideCrown(chainedSpikey, true)
    end
end

function familiar:OnUpdate(chainedSpikey)
    local sprite = chainedSpikey:GetSprite()
    local room = CURCOL.GAME:GetRoom()
    local data = chainedSpikey:GetData()

    if room:GetAliveEnemiesCount() > 0 then
        if data.CURCOL_CS_POS then
            local level = (Sewn_API and Sewn_API:GetLevel(chainedSpikey:GetData()) or 0)
            if not sprite:IsFinished('Idle') then
                chainedSpikey.Position = data.CURCOL_CS_POS
                chainedSpikey.SpriteRotation = chainedSpikey.SpriteRotation+(familiar.DEG_SPEED*(level == 2 and 2 or 1))

                if chainedSpikey.FrameCount % familiar.HIT_RATE == 0 then
                    local hasBFF = chainedSpikey.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
                    local endPoint = (chainedSpikey.Position + Vector(hasBFF and 81.25 or 65, 0):Rotated(chainedSpikey.SpriteRotation-90))

                    for k, enemy in pairs(Isaac.FindInRadius(endPoint, familiar.HIT_RADIUS, EntityPartition.ENEMY)) do
                        enemy:TakeDamage(familiar[hasBFF and 'BFF_DAMAGE' or 'DAMAGE'], (DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_SPIKES), EntityRef(chainedSpikey), 0)
                    end

                    local grid = room:GetGridEntityFromPos(endPoint)

                    if grid then grid:Destroy(true) end

                    if level > 0 then
                        endPoint = (chainedSpikey.Position + Vector(hasBFF and 81.25 or 65, 0):Rotated(chainedSpikey.SpriteRotation-270))
                        for k, enemy in pairs(Isaac.FindInRadius(endPoint, familiar.HIT_RADIUS, EntityPartition.ENEMY)) do
                            enemy:TakeDamage(familiar[hasBFF and 'BFF_DAMAGE' or 'DAMAGE'], (DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_SPIKES), EntityRef(chainedSpikey), 0)
                        end
    
                        local grid = room:GetGridEntityFromPos(endPoint)
    
                        if grid then grid:Destroy(true) end
                    end
                end

                local block = room:GetGridEntityFromPos(chainedSpikey.Position)

                if not block or block.Desc.State == 2 then
                    Isaac.GridSpawn(GridEntityType.GRID_ROCKB, 0, chainedSpikey.Position, true)
                end
            else
                chainedSpikey.Position = data.CURCOL_CS_POS
                chainedSpikey.SpriteRotation = chainedSpikey.SpriteRotation+familiar.DEG_SPEED
                sprite:Play("Rolling"..(level > 0 and "1" or ""), false)
            end
        elseif chainedSpikey.FrameCount % 300 == 0 or room:GetFrameCount() == 1 then
            local gridEnts = {}

            for i = 1, room:GetGridSize() do
                local entity = room:GetGridEntity(i)
                
                if entity then
                    if entity.Desc.State < 2 and familiar.GRID_WHITELIST[entity.Desc.Type] then -- State 2 means it's broken
                        table.insert(gridEnts, entity)
                    end
                end
            end

            if #gridEnts > 0 then
                chainedSpikey.SpriteRotation = math.random(360)

                local gridEnt = gridEnts[math.random(#gridEnts)]
                gridEnt:Destroy(true)
                local newEnt = Isaac.GridSpawn(GridEntityType.GRID_ROCKB, 0, gridEnt.Position, true)
                
                data.CURCOL_CS_POS = gridEnt.Position-Vector(0,5)
                
                local nailEff = Isaac.Spawn(1000, familiar.NAIL, 0, gridEnt.Position-Vector(0,5), Vector(0,0), chainedSpikey)
                chainedSpikey.Child = nailEff

                if Sewn_API then 
                    Sewn_API:HideCrown(chainedSpikey, false)
                end
            end
        end
    elseif not sprite:IsFinished('Idle') then
        sprite:RemoveOverlay()
        sprite:Play('Idle', true)
        
        if data.CURCOL_CS_POS then
            local gridEnt = room:GetGridEntityFromPos(data.CURCOL_CS_POS)
            if gridEnt then
                room:RemoveGridEntity(gridEnt:GetGridIndex(), 0, true)
                room:Update()

                local endPoint = (chainedSpikey.Position + Vector(chainedSpikey.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 81.25 or 65, 0):Rotated(chainedSpikey.SpriteRotation-90))
                CURCOL.GAME:SpawnParticles(chainedSpikey.Position, EffectVariant.NAIL_PARTICLE, 2, 2)
                CURCOL.GAME:SpawnParticles(endPoint, EffectVariant.CHAIN_GIB, 3, 2)
                CURCOL.SFX:Play(SoundEffect.SOUND_CHAIN_BREAK)
            end

            data.CURCOL_CS_POS = nil
        end
        
        if chainedSpikey.Child then
            chainedSpikey.Child:Remove()
        end

        if Sewn_API then 
            Sewn_API:HideCrown(chainedSpikey, true)
        end
    end
end

function familiar:OnCacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(familiar.VARIANT, player:GetCollectibleNum(familiar.ID), player:GetCollectibleRNG(familiar.ID))
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
CURCOL:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnInit,      familiar.VARIANT)
CURCOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnUpdate,    familiar.VARIANT)
CURCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,         familiar.OnCacheUpdate                )

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(familiar.VARIANT, familiar.ID)
    Sewn_API:AddFamiliarDescription(familiar.VARIANT, familiar.SM_DESCRIPTION[1], familiar.SM_DESCRIPTION[2], { 0.85, 0.2, 0 })
end

return familiar
