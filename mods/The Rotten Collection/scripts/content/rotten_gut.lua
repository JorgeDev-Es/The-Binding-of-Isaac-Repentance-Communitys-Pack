--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local sfx = SFXManager()
local familiar = {
    ID = Isaac.GetItemIdByName("Rotten gut"),
    VARIANT = Isaac.GetEntityVariantByName("Rotten gut"),

    KEY = "ROGU",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_ROTTEN_BEGGAR,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Rotten Gut",      DESC = "Appears at a random position in the room#Sucks everything towards it#Damages enemies and blocks projectiles" },
        { LANG = "ru",    NAME = "Гнилой кишечник", DESC = "Появляется в случайном месте комнаты#Засасывает все к себе#Наносит контактный урон врагам и засасывает их выстрелы" },
        { LANG = "spa",   NAME = "Agalla podrida",  DESC = "Aparece en algún lugar aleatorio de una nueva habitación, succionando todo hacia sí mismo y dañando a los enemigos#Puede bloquear proyectiles" },
        { LANG = "zh_cn", NAME = "小腐脏",           DESC = "进入有怪物的未探索房间时生成一只迷你腐脏巨面#吸引怪物、子弹和基础掉落#对怪物造成接触伤害" },
        { LANG = "ko_kr", NAME = "리틀 썩은내장",    DESC = "방 진입 시 랜덤 위치에서 나타납니다.#주변의 적들과 투사체를 빨아들이며 피해를 줍니다." },
    },
    SM_DESCRIPTION = {
        'Poisons enemies#{{ArrowUp}} Sucking range up#{{ArrowUp}} Sucking power up#{{ArrowDown}} Player sucking power down',
        '{{BlackHeart}} Sucked enemies may drop black hearts#{{ArrowUp}} Sucking range up#{{ArrowUp}} Sucking power up#Will no longer suck players'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Teleports to a random position in the room"},
            {str = "While in combat starts sucking enemies, projectiles and consumables into it"},
            {str = "Can block projectiles"},
            {str = "Damages enemies touching it"},
        },
        { -- Synergies
            {str = "Synergies", fsize = 2, clr = 3, halign = 0},
            {str = "While holding BFFS! it's sucking range and strength are increased"}
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'The sucking animation for this follower was directly taken from the "Stone Grimace" variant "Gaping Maw"'}
        },
        { -- Credits
            {str = "Credits", fsize = 2, clr = 3, halign = 0},
            {str = 'Credit to the "Black hole mod" (Was added to the game in a booster pack) which was used as an example for some of the code used for this item'},
            {str = 'Black hole mod: steamcommunity.com/sharedfiles/ filedetails/?id=840640979'}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function familiar:OnInit(rottenGut)
    local sprite = rottenGut:GetSprite()
    sprite:SetOverlayRenderPriority(true)
end

function familiar:OnUpdate(rottenGut)
    rottenGut.Velocity = Vector(0,0)
    local sprite = rottenGut:GetSprite()
    local room = Game():GetRoom()

    if room:GetAliveEnemiesCount() == 0 then
        if sprite:IsPlaying('Suck') then
            sprite:RemoveOverlay()
            sprite:Play('Dissapear', false)
        end

        if sprite:IsFinished("Dissapear") or sprite:IsPlaying("Appear") then 
            sprite:Play("Hidden", false) 
            if Sewn_API then Sewn_API:HideCrown(rottenGut, true) end
        end
    else
        if sprite:IsPlaying('Hidden') then
            rottenGut.Position = room:FindFreePickupSpawnPosition(room:GetRandomPosition(0))
            sprite:Play("Appear", false) 
        elseif sprite:IsEventTriggered("Appear") then
            sprite:Play("Suck", false)
            sprite:PlayOverlay("Suction", false)
            if Sewn_API then Sewn_API:HideCrown(rottenGut, false) end
        elseif sprite:IsPlaying('Suck') then
            local velocity = 1.2
            local playerVel = 0.25
            local radius = 80

            if Sewn_API then
                local sewLevel = Sewn_API:GetLevel(rottenGut:GetData())
                if sewLevel == 1 then
                    velocity = 1.3
                    playerVel = 0.15
                    radius = 100
                elseif sewLevel == 2 then
                    velocity = 1.5
                    playerVel = 0
                    radius = 120
                end
            end
            
            if rottenGut.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                velocity = velocity+1
                radius = radius+40
            end

            local entities = Isaac.FindInRadius(rottenGut.Position, radius)

            for i = 1, #entities do
                if entities[i].Type == EntityType.ENTITY_PLAYER then 
                    entities[i]:AddVelocity((rottenGut.Position - entities[i].Position):Normalized() * playerVel)
                elseif entities[i]:IsVulnerableEnemy() or entities[i].Type == EntityType.ENTITY_PICKUP or entities[i].Type == EntityType.ENTITY_PROJECTILE then
                    if entities[i].Mass < 40 then
                        if entities[i].Type == EntityType.ENTITY_PROJECTILE then
                            local data = entities[i]:GetData()

                            if data.ROTCOL_RG_COUNT == nil then
                                data.ROTCOL_RG_COUNT = 140
                            elseif data.ROTCOL_RG_COUNT > 0 then
                                data.ROTCOL_RG_COUNT = data.ROTCOL_RG_COUNT-1
                            else
                                entities[i].Velocity = Vector(0,0)
                                data.ROTCOL_RG_COUNT = 140
                                goto skip
                            end
                        end
                        
                        if not entities[i]:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not entities[i]:IsBoss() then
                            entities[i]:AddVelocity((rottenGut.Position - entities[i].Position):Normalized() * velocity)
                        end

                        ::skip::
                    end
                end
            end
        else
            sprite:Play("Appear", false)
        end
    end
end

function familiar:OnCollision(rottenGut, entity, _)
    if entity.Type == EntityType.ENTITY_PROJECTILE then 
        entity:Remove() 
    elseif Sewn_API and entity:IsActiveEnemy() then
        local sewLevel = Sewn_API:GetLevel(rottenGut:GetData())
            
        if sewLevel == 1 then
            entity:AddPoison(EntityRef(rottenGut.Player), 20, 1)
        end
        
        if sewLevel == 2 then
            entity:AddEntityFlags(EntityFlag.FLAG_SPAWN_BLACK_HP)
        end
    end
end

function familiar:OnCacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(familiar.VARIANT, player:GetCollectibleNum(familiar.ID)+player:GetEffects():GetCollectibleEffectNum(familiar.ID), player:GetCollectibleRNG(familiar.ID))
    end
end

function familiar:OnSewUpgrade(rottenGut) Sewn_API:HideCrown(rottenGut, true) end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnInit,      familiar.VARIANT)
ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnUpdate,    familiar.VARIANT)
ROTCG:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnCollision, familiar.VARIANT)

function familiar:Enable() 
    ROTCG:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    ROTCG.checkAllFam(familiar.VARIANT, familiar.ID)
end

function familiar:Disable()
    ROTCG:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    ROTCG.checkAllFam(familiar.VARIANT, familiar.ID)
end

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(familiar.VARIANT, familiar.ID)
    Sewn_API:AddFamiliarDescription(familiar.VARIANT, familiar.SM_DESCRIPTION[1], familiar.SM_DESCRIPTION[2], { 0, 0.5, 0 })
    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, familiar.OnSewUpgrade, familiar.VARIANT)
end


TCC_API:AddTCCInvManager(familiar.ID, familiar.TYPE, familiar.KEY, familiar.Enable, familiar.Disable)

return familiar
