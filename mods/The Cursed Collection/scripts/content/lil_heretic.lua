--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Lil heretic"),
    NPC = Isaac.GetEntityVariantByName("Lil heretic"),

    KEY="LIHE",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Lil Heretic", DESC = "Friendly ghost familiar#Weakens enemies#Connects a laser with the player" },
        { LANG = "ru",    NAME = "Лил Еретик", DESC = "Дружелюбный спутник призрак#Ослабляет врагов#Соединяет лазер с игроком" },
        { LANG = "spa",   NAME = "Pequeño Hereje", DESC = "Familiar fantasmagórico#Debilita enemigos#Conectará un láser con el jugador" },
        { LANG = "zh_cn", NAME = "小小异端", DESC = "获得一只异端幽灵跟班#追逐怪物造成接触伤害并虚弱周围的怪物#在自身和角色之间生成一道激光" },
        { LANG = "ko_kr", NAME = "리틀 불신자", DESC = "적을 따라다니며 접촉하는 적을 {{Weakness}}약화시킵니다.#캐릭터 사이에 레이저가 연결됩니다." },
    },
    SM_DESCRIPTION = {
        'Laser can blocks tears',
        'Weakens bosses'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Spawns a familiar that chases down enemies. Inflics weakness to enemies around it and connects a laser between it and the player."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnInit(familiar)
    local sprite = familiar:GetSprite()
    familiar:AddToFollowers()
    sprite:Play("Float")
end

function item:OnUpdate(lilHeretic)
    local sprite = lilHeretic:GetSprite()
    local room = CURCOL.GAME:GetRoom()

    if room:GetAliveEnemiesCount() == 0 then
        if not sprite:IsPlaying('Float') then
            sprite:Play('Float', false)
        end

        if lilHeretic:GetData().CURCOL_HER_LASER then
            lilHeretic:GetData().CURCOL_HER_LASER:Remove()
            lilHeretic:GetData().CURCOL_HER_LASER = nil
        end

        lilHeretic:FollowPosition(lilHeretic.Player.Position)
        lilHeretic:GetData().CURCOL_HER_COOL = nil
    else
        lilHeretic:PickEnemyTarget(120, 13, (1 | 2 | 8))
        
        if not lilHeretic.Target or lilHeretic.Target:IsDead() then
            if lilHeretic:GetData().CURCOL_HER_COOL then
                
                if lilHeretic:GetData().CURCOL_HER_COOL <= 0 then
                    if sprite:IsPlaying('FloatChase') then sprite:Play('Float', false) end
                    lilHeretic:FollowPosition(lilHeretic.Player.Position)
                else
                    lilHeretic:GetData().CURCOL_HER_COOL = lilHeretic:GetData().CURCOL_HER_COOL - 1
                end
            else
                lilHeretic:GetData().CURCOL_HER_COOL = 13
            end
        else
            lilHeretic:GetData().CURCOL_HER_COOL = nil
            lilHeretic:FollowPosition(lilHeretic.Target.Position)            
            if sprite:IsPlaying('Float') then sprite:Play('FloatChase', false) end
        end

        if lilHeretic.FrameCount % 30 == 0 then
            for key, enemy in ipairs(Isaac.FindInRadius(lilHeretic.Position, 90, EntityPartition.ENEMY)) do
                if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and (not enemy:IsBoss() or (Sewn_API and Sewn_API:GetLevel(lilHeretic:GetData()) == 2)) then
                    enemy:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
                end
            end
        end

        local distance = (lilHeretic.Position):Distance(lilHeretic.Player.Position) - (lilHeretic.Player.Size * 3)
        local data = lilHeretic:GetData()
        
        if distance > 15 then
            local angle = (lilHeretic.Player.Position - lilHeretic.Position):GetAngleDegrees()
    
            if not data.CURCOL_HER_LASER or data.CURCOL_HER_LASER:IsDead() then
                local laser = EntityLaser.ShootAngle(2, lilHeretic.Position, angle, 20, Vector(0.0, -20.0), lilHeretic)
                laser:AddTearFlags(TearFlags.TEAR_SPECTRAL | (Sewn_API and Sewn_API:GetLevel(lilHeretic:GetData()) > 0 and TearFlags.TEAR_SHIELDED or 0))
                laser:SetTimeout(-1)
                laser.Color = Color(1.0, 1.0, 1.0, 0.1, 100.0, 0.0, 255.0)
                laser.CollisionDamage = lilHeretic.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 0.5 or 0.25
                data.CURCOL_HER_LASER = laser
                CURCOL.SFX:Stop(SoundEffect.SOUND_REDLIGHTNING_ZAP)
            end
            
            data.CURCOL_HER_LASER.Angle = angle
            data.CURCOL_HER_LASER:SetMaxDistance(distance)
            data.CURCOL_HER_LASER.EndPoint = lilHeretic.Player.Position

        else
            if data.CURCOL_HER_LASER then
                data.CURCOL_HER_LASER:Remove()
                data.CURCOL_HER_LASER = nil
            end
        end
    end

    lilHeretic.Velocity = lilHeretic.Velocity:Clamped(-8,-8,8,8)
end

function item:OnCacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(item.NPC, player:GetCollectibleNum(item.ID)+player:GetEffects():GetCollectibleEffectNum(item.ID), player:GetCollectibleRNG(item.ID))
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
CURCOL:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          item.OnInit,      item.NPC)
CURCOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        item.OnUpdate,    item.NPC)

function item:Enable() 
    CURCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCacheUpdate)
    CURCOL.checkAllFam(item.NPC, item.ID)
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCacheUpdate)
    CURCOL.checkAllFam(item.NPC, item.ID)
end

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(item.NPC, item.ID)
    Sewn_API:AddFamiliarDescription(item.NPC, item.SM_DESCRIPTION[1], item.SM_DESCRIPTION[2], { 0.85, 0.2, 0 })
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item
