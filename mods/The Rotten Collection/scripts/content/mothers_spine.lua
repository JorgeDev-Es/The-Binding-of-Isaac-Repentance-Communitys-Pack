--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local familiar = { 
    ID = Isaac.GetItemIdByName("Mother's spine"),
    VARIANT = Isaac.GetEntityVariantByName("Mother's spine"),

    KEY = "MOSP",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_ROTTEN_BEGGAR,
        ItemPoolType.POOL_MOMS_CHEST,
        ItemPoolType.POOL_OLD_CHEST,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Mother's Spine",     DESC = "Orbits around the player#Poisons, damages and pushes enemies in line with it" },
        { LANG = "ru",    NAME = "Мамин позвоночник",  DESC = "Летает вокруг игрока#При касании к врагам отравляет их и наносит контактный урон" },
        { LANG = "spa",   NAME = "La espina de Madre", DESC = "Familair del tipo orbital#Puede envenenar, empujar y dañar a los enemigos que sean apuntados por el familiar" },
        { LANG = "zh_cn", NAME = "妈妈的脊柱",          DESC = "获得一个脊柱环绕物#推开脊柱指向的怪物，造成伤害并施加中毒" },
        { LANG = "ko_kr", NAME = "어머니의 등뼈",       DESC = "플레이어 주변을 돌며 #{{Poison}} 가리킨 방향에 있는 적을 중독시키며 공격력의 5%의 지속 피해를 입힙니다." },
    },
    SM_DESCRIPTION = {
        '{{ArrowUp}} Damage up#Occasionally shoots a poison laser',
        '{{ArrowUp}} Laser shot chance up#Lasers shot are homing'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants a follower that orbits the player"},
            {str = 'Enemies that are being "pointed at" by the familiar will be poisoned, damaged and pushed'},
        },
        { -- Synergies
            {str = "Synergies", fsize = 2, clr = 3, halign = 0},
            {str = 'While holding BFFS! enemies "pointed at" will take more damage'}
        }
    }
}

local lasers = {}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function familiar:OnInit(mothersSpine) -- Initialize familiar
    mothersSpine:AddToOrbit(90)
	mothersSpine.OrbitDistance = Vector(50, 50) 
	mothersSpine.OrbitSpeed = 0.006
    mothersSpine.SpriteRotation = (mothersSpine.Player.Position - mothersSpine.Position):GetAngleDegrees()

    if Sewn_API then
        local sewLevel = Sewn_API:GetLevel(mothersSpine:GetData())
        
        if sewLevel == 2 then
            mothersSpine.Size = 1.15
        elseif sewLevel == 1 then
            mothersSpine.Size = 1.3
        end
    end
end

function familiar:OnUpdate(mothersSpine) -- Create a laser for the familiar if one doesn't exist. Otherwise change it's rotation to match it's familiar 
    local player = mothersSpine.Player
    local angle = (player.Position - mothersSpine.Position):GetAngleDegrees()

    if lasers[mothersSpine.Index] and lasers[mothersSpine.Index]:Exists() then
        lasers[mothersSpine.Index].Angle = angle-180
    else
        local laser = EntityLaser.ShootAngle(2, player.Position, angle-180, 0, Vector(0,0), mothersSpine)
        laser.CollisionDamage = player.Damage*(player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 0.12 or 0.05)
        laser.TearFlags = TearFlags.TEAR_POISON
        laser.Visible = false
        lasers[mothersSpine.Index] = laser
    end

    mothersSpine.SpriteRotation = angle
	mothersSpine.OrbitDistance = Vector(50, 50)
    mothersSpine.Velocity = mothersSpine:GetOrbitPosition(player.Position + player.Velocity) - mothersSpine.Position
	
    if Sewn_API then
        local data = mothersSpine:GetData()
        local sewLevel = Sewn_API:GetLevel(mothersSpine:GetData())

        if sewLevel > 0 and Game():GetFrameCount() % 120 == 0 and math.random(sewLevel == 2 and 10 or 6) > 3 then
            local laz = EntityLaser.ShootAngle(2, player.Position, (player.Position - (mothersSpine.Position + mothersSpine.Velocity)):GetAngleDegrees()-190, 5, Vector(0,0), player)
            laz.TearFlags = TearFlags.TEAR_POISON
            laz.CollisionDamage = player.Damage*4

            if sewLevel == 2 then 
                laz:AddTearFlags(TearFlags.TEAR_HOMING)
                laz:SetColor(Color(0, 0.8, 0, 1, 0, 0.1, 0), -1, 20, false, false)
            else
                laz:SetColor(Color(0, 1, 0, 1, 0, 0.3, 0), -1, 20, false, false)
            end
        end

        mothersSpine.OrbitSpeed = sewLevel == 2 and 0.03 or sewLevel == 1 and 0.02 or 0.01
    else
        mothersSpine.OrbitSpeed = 0.01
    end
end

function familiar:OnCacheTrigger(player, flag) -- Reset familiar(s) and remove lasers on change 
    if flag == CacheFlag.CACHE_FAMILIARS then
        for i in pairs(lasers) do lasers[i]:Remove() end
        player:CheckFamiliar(familiar.VARIANT, player:GetCollectibleNum(familiar.ID)+player:GetEffects():GetCollectibleEffectNum(familiar.ID), player:GetCollectibleRNG(familiar.ID))
    end
end

function familiar:ResetLasers() lasers = {} end -- Remove lasers from state when room is changed

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,      familiar.OnInit,        familiar.VARIANT)
ROTCG:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,    familiar.OnUpdate,      familiar.VARIANT)

function familiar:Enable()
    ROTCG:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,      familiar.ResetLasers   )
    ROTCG:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,     familiar.OnCacheTrigger)
    ROTCG.checkAllFam(familiar.VARIANT, familiar.ID)
end

function familiar:Disable()
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,      familiar.ResetLasers   )
    ROTCG:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,     familiar.OnCacheTrigger)
    ROTCG.checkAllFam(familiar.VARIANT, familiar.ID)

    lasers = {}
end

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(familiar.VARIANT, familiar.ID)
    Sewn_API:AddFamiliarDescription(familiar.VARIANT, familiar.SM_DESCRIPTION[1], familiar.SM_DESCRIPTION[2], { 0, 0.5, 0 })
end

TCC_API:AddTCCInvManager(familiar.ID, familiar.TYPE, familiar.KEY, familiar.Enable, familiar.Disable)

return familiar