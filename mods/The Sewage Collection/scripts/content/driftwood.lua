--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local familiar = {
    ID = Isaac.GetItemIdByName("Driftwood"),
    VARIANT = Isaac.GetEntityVariantByName("Driftwood familiar"),

    SHOTS = 4,
    SHOT_DAMAGE = 4,
    DAMAGE = 3.5,
    WHITELIST = {
        [GridEntityType.GRID_DECORATION] = true,
        [GridEntityType.GRID_ROCK] = true,
        [GridEntityType.GRID_ROCKB] = true,
        [GridEntityType.GRID_ROCK_BOMB] = true,
        [GridEntityType.GRID_ROCK_ALT] = true,
        [GridEntityType.GRID_PIT] = true,
        [GridEntityType.GRID_SPIKES] = true,
        [GridEntityType.GRID_SPIKES_ONOFF] = true,
        [GridEntityType.GRID_SPIDERWEB] = true,
        [GridEntityType.GRID_LOCK] = true,
        [GridEntityType.GRID_TNT] = true,
        [GridEntityType.GRID_FIREPLACE] = true,
        [GridEntityType.GRID_POOP] = true,
        [GridEntityType.GRID_STATUE] = true,
        [GridEntityType.GRID_ROCK_SS] = true,
        [GridEntityType.GRID_PILLAR] = true,
        [GridEntityType.GRID_ROCK_SPIKED] = true,
        [GridEntityType.GRID_ROCK_ALT2] = true,
        [GridEntityType.GRID_ROCK_GOLD] = true,
    },

    KEY="DR",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_WOODEN_CHEST,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Driftwood", DESC = "Attacks enemies from the ground#Shoots shots and fills gaps" },
        { LANG = "ru",    NAME = "Коряги", DESC = "Атакует врагов с земли#Стреляет выстрелами и заполняет бреши" },
        { LANG = "spa",   NAME = "Madera a la deriva", DESC = "Atacará a los enemigos desde el suelo#Disparará al salir#Rellena los huecos al irse" },
        { LANG = "zh_cn", NAME = "浮木", DESC = "获得一只小茵陈跟班#从地下攻击怪物，离开时会发射四向眼泪" },
        { LANG = "ko_kr", NAME = "드리프트우드", DESC = "땅 속에서 바닥을 뚫으며 적을 공격합니다.#적 공격 후 땅 속에 다시 들어갈 때 주변에 눈물을 뿌리며 구덩이를 채웁니다." },
    },
    SM_DESCRIPTION = {
        '{{ArrowUp}} Shot amount up',
        'Shots are now poisonous'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Appears from the ground beneath enemies."},
            {str = "When the familiar appears it destroys the ground and leaves a gap."},
            {str = "Upon dissapearing it fills this gap with a bridge. On top of this it will also fire 4 bouncing tears"},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function InitTear(driftwood, sewLevel)
    local shot = SEWCOL.SeedSpawn(EntityType.ENTITY_TEAR, 0, 0, driftwood.Position, Vector(2,2):Rotated(math.random(360)), driftwood):ToTear()
    shot.CollisionDamage = familiar.SHOT_DAMAGE*(driftwood.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2 or 1)
    shot.FallingSpeed = driftwood.Player:ToPlayer().TearHeight*0.75
    shot.FallingAcceleration = 1.2

    local tearflags = TearFlags.TEAR_HYDROBOUNCE

    if sewLevel == 2 then
        tearflags = tearflags | TearFlags.TEAR_POISON
        shot.Color = Color(0.6, 0.8, 0.4, 1, 0, 0, 0)
    end

    shot:AddTearFlags(tearflags)
end

function familiar:OnInit(driftwood)
    if Sewn_API then
        Sewn_API:HideCrown(driftwood, true)
        
        if Sewn_API:IsUltra(driftwood:GetData()) then
            local sprite = driftwood:GetSprite()
            sprite:ReplaceSpritesheet(0, "gfx/familiar/SEWCOL_driftwood_dross.png")
            sprite:LoadGraphics()
        end
    end
end

function familiar:OnUpdate(driftwood)
    driftwood.Velocity = Vector(0,0)
    local sprite = driftwood:GetSprite()
    local room = SEWCOL.GAME:GetRoom()

    if sprite:IsEventTriggered("Done") then
        local grid = room:GetGridEntityFromPos(driftwood.Position)
        if grid and grid:GetType() == GridEntityType.GRID_PIT then
            grid:ToPit():MakeBridge(nil)
            SEWCOL.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.7, 5, false, 1.1)

            for i = 1, 2 do
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, grid.Position, RandomVector() * ((math.random() * 2) + 1), nil)
            end

            local sewLevel = Sewn_API and Sewn_API:GetLevel(driftwood:GetData()) or 0

            for i=1, familiar.SHOTS*(sewLevel > 0 and 2 or 1) do
                InitTear(driftwood, sewLevel)
            end

            if Sewn_API then
                Sewn_API:HideCrown(driftwood, true)
            end
        end

        sprite:Play("Idle", true) 
    end

    if room:GetAliveEnemiesCount() >= 0 and SEWCOL.GAME:GetFrameCount() % 100 == 0 and not sprite:IsPlaying("Attack") then
        local enemies = Isaac.FindInRadius(Isaac.GetRandomPosition(), 200, EntityPartition.ENEMY)
    
        for i=1, #enemies do
            if enemies[i]:IsActiveEnemy() and enemies[i]:IsVulnerableEnemy() and enemies[i]:CanShutDoors() then
                sprite:Play("Attack", true)

                local gridIndex = room:GetGridIndex(enemies[i].Position)
                local gridPos = room:GetGridPosition(gridIndex)
                driftwood.Position = gridPos
        
                local grid = room:GetGridEntityFromPos(gridPos)
                
                if not grid then 
                    Isaac.GridSpawn(GridEntityType.GRID_PIT, 0, gridPos, true)
                elseif grid and (familiar.WHITELIST[grid:GetType()]) then
                    grid:Destroy(true) 
                    Isaac.GridSpawn(GridEntityType.GRID_PIT, 0, gridPos, true)
                end
                
                local effect = Isaac.Spawn(1000, EffectVariant.BIG_SPLASH, 0, gridPos, Vector(0,0), driftwood):ToEffect()
                effect.Scale = 0.5
                effect:Update()
        
                SEWCOL.SFX:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION, 0.5, 5, false, 1.1)
        
                for i = 1, 3 do
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, gridPos, RandomVector() * ((math.random() * 2) + 1), nil)
                end

                if Sewn_API then
                    Sewn_API:HideCrown(driftwood, false)
                end

                enemies[i]:TakeDamage(familiar.DAMAGE*(driftwood.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2 or 1), 0, EntityRef(driftwood), 80)
                return
            end
        end
    end
end

function familiar:OnCacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(familiar.VARIANT, player:GetCollectibleNum(familiar.ID)+player:GetEffects():GetCollectibleEffectNum(familiar.ID), player:GetCollectibleRNG(familiar.ID))
    end
end

function familiar:OnSMUpgrade(driftwood)
    driftwood:GetSprite():ReplaceSpritesheet(0, 'gfx/familiar/SEWCOL_driftwood_dross.png')
    driftwood:GetSprite():LoadGraphics()
end

function familiar:OnSMDowngrade(driftwood)
    driftwood:GetSprite():ReplaceSpritesheet(0, 'gfx/familiar/SEWCOL_driftwood.png')
    driftwood:GetSprite():LoadGraphics()
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
SEWCOL:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnInit,       familiar.VARIANT)
SEWCOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnUpdate,     familiar.VARIANT)

function familiar:Enable() 
    SEWCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    SEWCOL.checkAllFam(familiar.VARIANT, familiar.ID)
end

function familiar:Disable()
    SEWCOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    SEWCOL.checkAllFam(familiar.VARIANT, familiar.ID)
end

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(familiar.VARIANT, familiar.ID)
    Sewn_API:AddFamiliarDescription(familiar.VARIANT, familiar.SM_DESCRIPTION[1], familiar.SM_DESCRIPTION[2], { 0, 0.1, 0.3 })
    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, familiar.OnSMUpgrade, familiar.VARIANT, Sewn_API.Enums.FamiliarLevelFlag.FLAG_ULTRA)
    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_LOSE_UPGRADE, familiar.OnSMDowngrade, familiar.VARIANT)
end

TCC_API:AddTCCInvManager(familiar.ID, familiar.TYPE, familiar.KEY, familiar.Enable, familiar.Disable)

return familiar
