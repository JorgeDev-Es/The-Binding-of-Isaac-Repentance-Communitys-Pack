--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Mini bombs"),

    TROLL_CHANCE = 25,

    UNFRIENDLY  = {
        [BombVariant.BOMB_TROLL] = true,
        [BombVariant.BOMB_SUPERTROLL] = true,
    },
    
    KEY="MIBO",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_BOMB_BUM,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SECRET,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Mini Bombs",  DESC = "{{ArrowUp}} +10 bombs#{{Warning}} Troll bombs may be giga bombs#Bombs have giga explosions" },
	    { LANG = "ru",    NAME = "Мини бомбы",  DESC = "{{ArrowUp}} +10 бомб#{{Warning}} Тролль-бомбы могут быть гига бомбами#Бомбы имеют гига взрывы" },
        { LANG = "spa",   NAME = "Mini-bombas", DESC = "{{ArrowUp}} +10 bombas#Las bombas explotan como si fueran giga bombas#{{Warning}} Las bombas troll pueden convertirse en giga bombas" },
	    { LANG = "zh_cn", NAME = "迷你炸弹",     DESC = "{{ArrowUp}} +10 炸弹#角色放置的炸弹获得巨型炸弹的效果#{{Warning}} 即爆炸弹可能转变为巨型即爆炸弹" },
        { LANG = "ko_kr", NAME = "초 압축 폭탄",  DESC = "{{ArrowUp}} {{Bomb}}폭탄 +10#{{Warning}} 트롤 폭탄이 폭발할 때 25%의 확률로 기가 폭발이 일어납니다.#플레이어가 설치한 모든 폭탄이 기가 폭탄으로 설치됩니다.#!!! (외형 상으로는 작은 폭탄으로 설치됨)" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Bombs spawned by the player will now have the giga bomb effect."},
            {str = "Troll bombs have a chance to be replaced with lit giga bombs."},
            {str = "Grants 10 bombs."},
        }
    }
}

--TODO: Try to fix the custom bomb visual
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnBomb(bomb)
    if bomb.FrameCount == 1 then
        if item.UNFRIENDLY[bomb.Variant] then
            if Isaac.GetPlayer():GetCollectibleRNG(item.ID):RandomInt(100)+1 <= item.TROLL_CHANCE then
                bomb:Remove()
                QUACOL.SeedSpawn(4, 17, 0, bomb.Position, bomb.Velocity, bomb):GetSprite().Scale = Vector(0.5,0.5)
            end
        elseif bomb.Variant ~= BombVariant.BOMB_THROWABLE then
            local player = QUACOL.GetShooter(bomb)
            if player and TCC_API:Has(item.KEY, player) > 0 then
                if bomb:HasTearFlags(BitSet128(0,1<<(119 - 64))) then
                    if not bomb:GetData()['isNewBomb'] then -- Repentance+ support
                        if bomb.Variant ~= BombVariant.BOMB_ROCKET and bomb.Variant ~= BombVariant.BOMB_ROCKET_GIGA then
                            local sprite = bomb:GetSprite()
                            sprite:Load("gfx/animations/QUACOL_mini_bombs.anm2", true); 
                            sprite:Play("Pulse", true);
                        else
                            bomb.SpriteScale = Vector(0.6,0.6)
                        end
                    end
                else
                    bomb:AddTearFlags(BitSet128(0,1<<(119 - 64))) -- TODO: Had to do this because bomb flags are currently broken. Make sure to change this to the correct value when the API is fixed
                    bomb:Update()
                end
            end
        end
    end
end

function item:OnEff(eff)
    if eff.FrameCount == 1 then
        local room = QUACOL.GAME:GetRoom()
        if room:GetType() == RoomType.ROOM_BOSS and room:GetAliveEnemiesCount() <= 0 then
            for i = 1, room:GetGridSize() do
                local entity = room:GetGridEntity(i)
                if entity then
                    if entity.Desc.Type == GridEntityType.GRID_PIT then
                        --TODO: Add particle effect for bridge appearing
                        entity:ToPit():MakeBridge(nil)
                    end
                end
            end
        end 

        if eff.SpawnerVariant == 31 then
            local numPlayers = QUACOL.GAME:GetNumPlayers()
            for i=1,numPlayers do
                local player = QUACOL.GAME:GetPlayer(tostring((i-1)))
                if TCC_API:Has(item.KEY, player) and player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
                    local newBomb = player:FireBomb(eff.Position, eff.Velocity, nil)
                    newBomb:AddTearFlags(BitSet128(0,1<<(119 - 64)))
                    newBomb:SetExplosionCountdown(0)
                    newBomb.Color = Color(0,0,0,0)
                    newBomb:GetData()['isNewBomb'] = true
                    eff:Remove()
                    return
                end
            end
        end
    end
end

function item:OnBossClear()
    local room = QUACOL.GAME:GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        for i = 1, room:GetGridSize() do
            local entity = room:GetGridEntity(i)
            if entity then
                if entity.Desc.Type == GridEntityType.GRID_PIT then
                    entity:ToPit():MakeBridge(nil)
                end
            end
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    QUACOL:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, item.OnBomb)
    QUACOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, item.OnEff, EffectVariant.BOMB_EXPLOSION)
    QUACOL:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, item.OnBossClear)
end

function item:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_BOMB_UPDATE, item.OnBomb)
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, item.OnEff, EffectVariant.BOMB_EXPLOSION)
    QUACOL:RemoveCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, item.OnBossClear) 
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item