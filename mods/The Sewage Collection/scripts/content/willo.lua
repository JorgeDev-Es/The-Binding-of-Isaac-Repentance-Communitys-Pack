--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local familiar = {
    ID = Isaac.GetItemIdByName("Willo"),
    VARIANT = Isaac.GetEntityVariantByName("Willo familiar"),

    SHOT_RATE = 100,
    SHOT_CHANCE = 60,
    SHOT_DAMAGE = 3,

    ORBIT_SPEED =  0.025,
    ORBIT_DISTANCE = 85,
    MAX_SPEED = 8,
    OFFSET_MULTIPLIER = 10,
    COL_DAMAGE = 5,
    AMOUNT = 3,

    KEY="WI",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_KEY_MASTER,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Willo", DESC = "#Grants 3 followers#Orbits a random target#Shoots fire shots" },
        { LANG = "ru",    NAME = "Уилло", DESC = "#Дает 3 последователей#Вращаются вокруг случайной цели#Стреляет огненными выстрелами" },
        { LANG = "spa",   NAME = "Willo", DESC = "#Generará 3 Seguidores#Orbitarán en un enemigo aleatorio#Dispara disparos de fuego" },
        { LANG = "zh_cn", NAME = "幻舞蝇", DESC = "#获得三只幻舞蝇跟班#环绕在怪物周围向其发射火焰眼泪并对其他怪物造成接触伤害" },
        { LANG = "ko_kr", NAME = "윌로", DESC = "#!!! 3마리가 소환됩니다.#적 주변을 돌며 화상을 입히는 눈물을 발사합니다." },
    },
    EID_TRANS = { "collectible", Isaac.GetItemIdByName("Willo"), 3 },
    SM_DESCRIPTION = {
        'Gains double shot# Upgrades all 3 willo familiars',
        'Gains triple shot# Upgrades all 3 held willo familiars'
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "While carried this item will grant 3 willo followers"},
            {str = "When in combat these followers will teleport to random enemies and start orbiting them"},
            {str = "While orbiting a target they ionally shoot at it."},
            {str = "Counts towards the Beelzebub transformation."},
        }
    }
}

local target = nil

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function initShot(willo, target, deg)
    local shot = willo:FireProjectile((target.Position + target.Velocity - willo.Position):Rotated(deg or 0))
    shot.Velocity = shot.Velocity:Normalized()*20
    shot:AddTearFlags(TearFlags.TEAR_BURN | TearFlags.TEAR_SPECTRAL)
    shot.Color = Color(2, 1.4, 1, 1, 0, 0, 0)
end

function familiar:OnInit(willo) -- Initialize familiar
    willo:GetSprite():Play("Appear")
    willo:AddToOrbit(96)
    willo.OrbitDistance = Vector(familiar.ORBIT_DISTANCE, familiar.ORBIT_DISTANCE)
    willo.OrbitSpeed = familiar.ORBIT_SPEED
end

function familiar:OnUpdate(willo)
    local sprite = willo:GetSprite()
    local room = SEWCOL.GAME:GetRoom()

    if sprite:IsEventTriggered("Finished") then sprite:Play("Fly", true) end

    if room:GetAliveEnemiesCount() > 0 then

        if not target or target:IsDead() then
            target = nil

            local entities = Isaac.GetRoomEntities()
            local enemies = {}
            for k, enemy in pairs(entities) do
                if enemy:IsVulnerableEnemy() and enemy:CanShutDoors() then
                    table.insert(enemies, enemy)
                end
            end

            if #enemies > 0 then 
                target = enemies[math.random(#enemies)] 
                return
            else
                target = false
            end
        end

        if target ~= willo:GetData().SEWCOL_OLD_TARGET or (sprite:IsPlaying("Fly") and target.Position:Distance(willo.Position) > 100) then
            for key, value in pairs(Isaac.FindByType(3, familiar.VARIANT, 0)) do
                value:GetData().SEWCOL_OLD_TARGET = target
                value:GetSprite():Play("Hide", true)
                SEWCOL.SFX:Play(SoundEffect.SOUND_FLAMETHROWER_END, 1, 2, false, 1.6)
                value.Velocity = Vector(0,0)
            end
        elseif target then
            if sprite:IsFinished("Hide") then 
                SEWCOL.SFX:Play(SoundEffect.SOUND_CANDLE_LIGHT)
                sprite:Play("Appear") 
            end

            if not sprite:IsPlaying("Hide") then
                willo.OrbitDistance = Vector(familiar.ORBIT_DISTANCE, familiar.ORBIT_DISTANCE)
                willo.OrbitSpeed = familiar.ORBIT_SPEED
                willo.Velocity = willo:GetOrbitPosition(target.Position + target.Velocity) - willo.Position

                if sprite:IsPlaying("Fly") and SEWCOL.GAME:GetFrameCount() % familiar.SHOT_RATE == 0 and math.random(100) > familiar.SHOT_CHANCE then
                    sprite:Play("Attack", true)
                    SEWCOL.SFX:Play(SoundEffect.SOUND_CANDLE_LIGHT)
                end
    
                if sprite:IsEventTriggered("Shoot") then
                    if Sewn_API then
                        if Sewn_API:IsSuper(willo:GetData()) then
                            initShot(willo, target, 4)
                            initShot(willo, target, -4)
                        elseif Sewn_API:IsUltra(willo:GetData()) then
                            initShot(willo, target)
                            initShot(willo, target, 7)
                            initShot(willo, target, -7)
                        else
                            initShot(willo, target)
                        end
                    else
                        initShot(willo, target)
                    end
                end
            end
        end
    else
        if target ~= nil or target ~= willo:GetData().SEWCOL_OLD_TARGET then
            sprite:Play("Hide", true)
            target = nil
            willo:GetData().SEWCOL_OLD_TARGET = nil
            willo.Velocity = Vector(0,0)
        else
            if sprite:IsFinished("Hide") then
                sprite:Play("Appear", true)
            elseif not sprite:IsPlaying("Hide") then
                willo.OrbitDistance = Vector(familiar.ORBIT_DISTANCE, familiar.ORBIT_DISTANCE)
                willo.OrbitSpeed = familiar.ORBIT_SPEED
                willo.Velocity = willo:GetOrbitPosition(willo.Player.Position + willo.Player.Velocity) - willo.Position
            end
        end
    end
end

function familiar:OnCollision(fam, entity, _)
    if not fam:GetSprite():IsPlaying("Hide") then
        if entity.Type == EntityType.ENTITY_PROJECTILE then entity:Remove()
        elseif entity:IsActiveEnemy() then entity:TakeDamage(familiar.COL_DAMAGE, 0, EntityRef(fam), 2) end
    end
end

function familiar:OnCacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(familiar.VARIANT, (player:GetCollectibleNum(familiar.ID)+player:GetEffects():GetCollectibleEffectNum(familiar.ID))*familiar.AMOUNT, player:GetCollectibleRNG(familiar.ID))
    end
end

function familiar:OnUpgrade(willo, isPerm)
    if isPerm then
        local data = willo:GetData()
        local loop = 1

        if Sewn_API:IsUltra(data) then
            for key, item in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, familiar.VARIANT, -1)) do
                item = item:ToFamiliar()
                if Sewn_API:GetLevel(item:GetData()) == 1 and willo.Player.Index == item.Player.Index and willo.InitSeed ~= item.InitSeed then
                    item:GetData().Sewn_upgradeLevel = 2
                    loop = loop+1
                    if loop >= 3 then return end
                end
            end
        elseif Sewn_API:IsSuper(data) then
            for key, item in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, familiar.VARIANT, -1)) do
                item = item:ToFamiliar()
                if Sewn_API:GetLevel(item:GetData()) == 0 and willo.Player.Index == item.Player.Index and willo.InitSeed ~= item.InitSeed then
                    item:GetData().Sewn_upgradeLevel = 1
                    loop = loop+1
                    if loop >= 3 then return end
                end
            end
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
SEWCOL:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,          familiar.OnInit,       familiar.VARIANT)
SEWCOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,        familiar.OnUpdate,     familiar.VARIANT)
SEWCOL:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.OnCollision,  familiar.VARIANT)

function familiar:Enable() 
    SEWCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    SEWCOL.checkAllFam(familiar.VARIANT, familiar.ID, familiar.AMOUNT)
end

function familiar:Disable()
    SEWCOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, familiar.OnCacheUpdate)
    SEWCOL.checkAllFam(familiar.VARIANT, familiar.ID, familiar.AMOUNT)
end

if Sewn_API then
    Sewn_API:MakeFamiliarAvailable(familiar.VARIANT, familiar.ID)
    Sewn_API:AddFamiliarDescription(familiar.VARIANT, familiar.SM_DESCRIPTION[1], familiar.SM_DESCRIPTION[2], { 0, 0.1, 0.3 })
    Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, familiar.OnUpgrade, familiar.VARIANT)
end

TCC_API:AddTCCInvManager(familiar.ID, familiar.TYPE, familiar.KEY, familiar.Enable, familiar.Disable)

return familiar

