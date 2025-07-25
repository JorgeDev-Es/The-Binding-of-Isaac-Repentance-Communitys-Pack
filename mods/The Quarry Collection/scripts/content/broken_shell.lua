--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local familiar = {
    ID = Isaac.GetItemIdByName("Broken shell"),
    NPC = Isaac.GetEntityVariantByName("Broken shell"),

    KEY="STSL",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_BOMB_BUM,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Broken Shell", DESC = "{{EmptyBoneHeart}} +1 bone heart#{{ArrowUp}} +3 giga bombs#Targets enemies#Familiar that spawns a bomb when colliding" },
	    { LANG = "ru",    NAME = "Разбитая оболочка", DESC = "{{EmptyBoneHeart}} +1 костяное сердце#{{ArrowUp}} +3 гига бомбы#Самонаводится на врагов#Спутник, создающий бомбу при столкновении" },
	    { LANG = "spa",   NAME = "Caparazón roto", DESC = "{{EmptyBoneHeart}} +1 corazón de hueso#{{ArrowUp}} +3 giga bombas#Familiar que apunta a enemigos y genera bombas al chocar" },
	    { LANG = "zh_cn",   NAME = "破碎的外壳", DESC = "{{EmptyBoneHeart}} +1 骨心#{{ArrowUp}} +3 巨型炸弹#获得一只炸弹苍蝇跟班#追踪怪物造成接触伤害并留下一个会爆炸的小炸弹" },
        { LANG = "ko_kr", NAME = "부서진 껍질", DESC = "{{EmptyBoneHeart}} 뼈하트 +1#{{ArrowUp}} 기가폭탄 +3#적을 향해 이동하며 적과 접촉 시 잠시 후 폭발합니다." },
    },
    SM_DESCRIPTION = {
        '{{ArrowUp}} Respawn time down',
        'Drops 3 bombs upon death'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grant's a bomb fly familiar that attacks enemies."},
            {str = "When the familiar hits an enemy it will die and spawn a bomb."},
            {str = "After being dead for a while the familiar will respawn at the players position."},
            {str = "Upon pickup the item will grant a bone heart and 3 giga bombs."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function familiar:OnInit(brokenShell)
    local sprite = brokenShell:GetSprite()
    sprite:Play("Appear")

    if Sewn_API and Sewn_API:IsUltra(brokenShell:GetData()) then
        sprite:ReplaceSpritesheet(0, 'gfx/familiar/QUACOL_broken_shell_ultra.png')
        sprite:LoadGraphics()
    end
end

function familiar:OnUpdate(brokenShell)
    local room = QUACOL.GAME:GetRoom()
    local sprite = brokenShell:GetSprite()

    if sprite:IsFinished("Appear") then
        sprite:Play("Idle")
    elseif sprite:IsPlaying("Hidden") 
    and brokenShell.FrameCount % ((Sewn_API and Sewn_API:GetLevel(brokenShell:GetData()) or 0) > 0 and 200 or 400) == 0 then
        Isaac.Spawn(1000, 15, 0, brokenShell.Position, Vector(0,0), brokenShell)
        if Sewn_API then Sewn_API:HideCrown(brokenShell, false) end
        sprite:Play("Appear")
        QUACOL.SFX:Play(SoundEffect.SOUND_FETUS_JUMP)
    end
    
    if room:GetAliveEnemiesCount() > 0 and not sprite:IsPlaying("Hidden") then
        if not brokenShell.Target or brokenShell.Target:IsDead() or brokenShell.Target.Type == EntityType.ENTITY_PLAYER then
            brokenShell:PickEnemyTarget(2000, 13, (1 | 2), Vector.Zero, 360)
            
            if not brokenShell.Target or brokenShell.Target:IsDead() then
                brokenShell.Target = brokenShell.Player
            end
        end
        
        if sprite:IsPlaying("Idle") and brokenShell.Target.Type ~= EntityType.ENTITY_PLAYER then sprite:Play("Angry") end

        if brokenShell.Target and brokenShell.Target.Position then
            brokenShell.Velocity = (brokenShell.Velocity + (brokenShell.Target.Position - brokenShell.Position):Normalized()):Clamped(-6,-6,6,6)
        end
    else
        if sprite:IsPlaying("Angry") then sprite:Play("Idle") end
        brokenShell:FollowPosition(brokenShell.Player.Position)
    end
end

function familiar:OnCollision(brokenShell, entity, _)
    if entity:IsVulnerableEnemy() and brokenShell:GetSprite():IsPlaying("Angry") then
        local sewLevel = Sewn_API and Sewn_API:GetLevel(brokenShell:GetData()) or 0

        brokenShell:GetSprite():Play("Hidden")
        brokenShell.Target = brokenShell.Player
        QUACOL.SFX:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
        if sewLevel > 0 then Sewn_API:HideCrown(brokenShell, true) end

        Isaac.Spawn(1000, EffectVariant.FLY_EXPLOSION, 0, brokenShell.Position, Vector(0,0), brokenShell)
        QUACOL.SeedSpawn(4, BombVariant.BOMB_SMALL, 0, brokenShell.Position, Vector(0,0), brokenShell)

        if sewLevel == 2 then
            QUACOL.SeedSpawn(4, BombVariant.BOMB_SMALL, 0, brokenShell.Position, Vector(0,0), brokenShell)
            QUACOL.SeedSpawn(4, BombVariant.BOMB_SMALL, 0, brokenShell.Position, Vector(0,0), brokenShell)
        end
    end
end

function familiar:OnCacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(familiar.NPC, player:GetCollectibleNum(familiar.ID)+player:GetEffects():GetCollectibleEffectNum(familiar.ID), player:GetCollectibleRNG(familiar.ID))
    end
end

function familiar:OnSMUpgrade(brokenShell)
    brokenShell:GetSprite():ReplaceSpritesheet(0, 'gfx/familiar/QUACOL_broken_shell_ultra.png')
    brokenShell:GetSprite():LoadGraphics()
end

function familiar:OnSMDowngrade(brokenShell)
    brokenShell:GetSprite():ReplaceSpritesheet(0, 'gfx/familiar/QUACOL_broken_shell.png')
    brokenShell:GetSprite():LoadGraphics()
end

function familiar:OnCollect(player, _, touched)
    if not touched then
        player:AddBoneHearts(1)
        player:AddBombs(3)
        player:AddGigaBombs(3)
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
QUACOL:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnInit,      familiar.NPC)
QUACOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnUpdate,    familiar.NPC)
QUACOL:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnCollision, familiar.NPC)

function familiar:Enable() 
    QUACOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    QUACOL.checkAllFam(familiar.NPC, familiar.ID)
end

function familiar:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    QUACOL.checkAllFam(familiar.NPC, familiar.ID)
end

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(familiar.NPC, familiar.ID)
    Sewn_API:AddFamiliarDescription(familiar.NPC, familiar.SM_DESCRIPTION[1], familiar.SM_DESCRIPTION[2], { 0.5, 0.2, 0 })
    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, familiar.OnSMUpgrade, familiar.NPC, Sewn_API.Enums.FamiliarLevelFlag.FLAG_ULTRA)
    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_LOSE_UPGRADE, familiar.OnSMDowngrade, familiar.NPC)
end

TCC_API:AddTCCInvManager(familiar.ID, familiar.TYPE, familiar.KEY, familiar.Enable, familiar.Disable)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", familiar.OnCollect, familiar.ID)

return familiar
