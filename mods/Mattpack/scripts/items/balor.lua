local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.Balor, "↑ {{Damage}} +6 Damage#↑ {{Damage}} x3 Damage multiplier#↓ {{Tears}} -0.42 Fire rate#↓ {{Tears}} x0.125 Fire rate multiplier#Tears will pierce enemies up to 5 times, reducing in damage 20% and cycling to a new Harbinger effect each time#{{1}} Famine - Slowing#{{2}} Pestilence - Poison#{{3}} War - Fire explosion#{{4}} Death - 2x base damage#{{5}} Conquest - Holy Light")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_POLYPHEMUS, 'using {{Card' .. Card.CARD_HUGE_GROWTH .. "}}" .. "{{ColorYellow}} Huge Growth {{CR}}", true)
end

function mod:damageCache(player, flag)
    local balorMulti = player:GetCollectibleNum(mod.Items.Balor)
    if flag == CacheFlag.CACHE_DAMAGE then
        if balorMulti > 0 then
            player.Damage = (player.Damage + (6 * player:GetCollectibleNum(mod.Items.Balor))) * 3
        end
    elseif flag == CacheFlag.CACHE_FIREDELAY then
        if balorMulti > 0 then
            player.MaxFireDelay = (player.MaxFireDelay + (2 * balorMulti)) * 8
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.damageCache, CacheFlag.CACHE_DAMAGE)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.damageCache, CacheFlag.CACHE_FIREDELAY)

function mod:tearFire(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player then
        if player:HasCollectible(MattPack.Items.Balor) then
            local stackedAmt = player:GetCollectibleNum(mod.Items.Balor)
            if tear:ToTear() then
                tear.Scale = tear.Scale * (1.5 + (.25 * (stackedAmt - 1)))
            elseif tear:ToLaser() then
                tear:SetScale(tear:GetScale() * (2.5 + (.25 * (stackedAmt - 1))))
                sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER)
            end
            if math.random(1, 3) == 1 then
                tear:AddTearFlags(TearFlags.TEAR_ACID)
            end
            sfx:Play(SoundEffect.SOUND_EXPLOSION_WEAK)
            sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 2)
            local tearData = tear:GetData()
            tearData.balorPierces = 0
            tearData.wasPiercing = tear:HasTearFlags(TearFlags.TEAR_PIERCING) or (stackedAmt > 1)
            tearData.balorOrigDmg = tear.CollisionDamage
            tearData.balorOrigHeight = tear.Height
            tear:AddTearFlags(TearFlags.TEAR_PIERCING)
            tear:AddTearFlags(TearFlags.TEAR_PERSISTENT)
            if tear.Position:Distance(player.Position) <= tear.Velocity:Length() + (tear.ParentOffset or Vector.Zero):Length() + 20 then
                player.Velocity = player.Velocity + -(tear.Velocity / 2 * stackedAmt)
            end
            local shakeIntensityConfig = MattPack.Config.balorScreenshakeIntensity
            if shakeIntensityConfig > 1 then
                local shakeStrength = math.min(15, math.floor(12 * (tear.CollisionDamage / 28.5)))
                if shakeIntensityConfig == 2 then
                    shakeStrength = shakeStrength / 1.5
                end
                game:ShakeScreen(math.ceil(shakeStrength))
            end
            tear.DepthOffset = 15
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.tearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, mod.tearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, mod.tearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, mod.tearFire)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, mod.tearFire)

function mod:tearCol(tear, col)
    local data = tear:GetData()
    if (tear:ToKnife() and tear:ToKnife():IsFlying() == false) then
        data.balorPierces = nil
        data.piercedList = nil
    end
    local pierces = data.balorPierces
    local isTear = tear:ToTear() ~= nil
    local isValid = pierces ~= nil
    if not isValid then
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if player and player:HasCollectible(MattPack.Items.Balor) and not tear:ToBomb() then
            isValid = true
        end
    end
    if isValid and (col and col:ToNPC() and col:ToNPC():IsVulnerableEnemy()) then
        if (not pierces) then
            pierces = 0
        end
        if not data.piercedList then
            data.piercedList = {GetPtrHash(col)}
        else
            Isaac.CreateTimer(function()
                if data then
                    data.piercedList = nil
                end
            end, 60, 1, false)
            for _,hash in ipairs(data.piercedList) do
                if GetPtrHash(col) == hash then
                    return
                end
            end
            table.insert(data.piercedList, GetPtrHash(col))
        end 
        data.balorPierces = (pierces or 0) + 1

        local player = (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()) or Isaac.GetPlayer():ToPlayer()

        local origColor = tear.Color
        local setVariant = nil
        tear:ClearTearFlags(TearFlags.TEAR_SLOW)
        tear:ClearTearFlags(TearFlags.TEAR_POISON)
        tear:ClearTearFlags(TearFlags.TEAR_BURN)
        sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, .75)
        if pierces == 0 then
            setVariant = (TearVariant.GLAUCOMA_BLOOD)
            if not isTear then
                origColor = Color(.54, .25, .1, 1, .54, .25, .1)
            end
        elseif pierces == 1 then
            -- famine
            tear:AddTearFlags(TearFlags.TEAR_SLOW)
            sfx:Play(SoundEffect.SOUND_BIRD_FLAP)

            if isTear then
                origColor.RO = 0
                origColor.GO = .15
                origColor.BO = 0
            else
                origColor = Color(.25, 1, .25, 1, .25, 1, .25)
            end
            setVariant = (TearVariant.BOOGER)
        elseif pierces == 2 then
            -- pestilence
            tear:AddTearFlags(TearFlags.TEAR_POISON)
            sfx:Play(SoundEffect.SOUND_POISON_HURT)

            setVariant = (TearVariant.FIRE_MIND)
            if isTear then
                origColor.RO = .15
                origColor.GO = 0
                origColor.BO = 0
            else
                origColor = Color(.8, .3, 0, 1, .8, .3, 0, 1)
            end
        elseif pierces == 3 then
            -- war
            col:AddBurn(EntityRef(col), 63, tear.CollisionDamage / 2)
            sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING)
            game:BombExplosionEffects(col.Position, tear.CollisionDamage / 2, (tear.TearFlags or 0) | TearFlags.TEAR_BURN, tear.Color, tear, .5)

            setVariant = (TearVariant.SCHYTHE)
            if isTear then
                origColor.RO = 0
                origColor.GO = 0
                origColor.BO = 0
            else
                origColor = Color(1, 1, 1, 1, .25,.25,.25,1)
            end
        elseif pierces == 4 then
            -- death
            tear.CollisionDamage = math.max(data.balorOrigDmg or 0, tear.CollisionDamage) * 2
            sfx:Play(SoundEffect.SOUND_KNIFE_PULL)
            
            if isTear then
                origColor.RO = .75
                origColor.GO = .9
                origColor.BO = 1
            else
                origColor = Color(1, 1, 1, 1, .75, .9, 1)
            end
            setVariant = (TearVariant.BLUE)
        elseif pierces >= 5 then
            -- conquest
            if tear:IsDead() == false then
                Isaac.Spawn(1000, EffectVariant.CRACK_THE_SKY, 1, col.Position, Vector.Zero, player)
                sfx:Play(SoundEffect.SOUND_ANGEL_BEAM)
            end
            if not tear:GetData().wasPiercing then
                if isTear then
                    tear:Die()
                end
            else
                setVariant = 0
            end
            data.balorPierces = 0
            origColor = Color(1,1,1,1)
        end
        local setScale = (tear.Scale or 1) / 1.25
        if setVariant == 8 then
            setScale = setScale / 1.4
        end
        if setVariant then
            if not isTear then
                tear.Color = origColor
            else
                Isaac.CreateTimer(function()
                    if tear then
                        tear:ChangeVariant(setVariant)
                        tear.Scale = setScale
                        origColor.R = math.max(origColor.R, origColor.RO)
                        origColor.G = math.max(origColor.G, origColor.GO)
                        origColor.B = math.max(origColor.B, origColor.BO) 
                        tear.Color = origColor
                    end
                end, 1, 1, false)
            end
        end
        if isTear then
            if not tear:GetData().wasPiercing then
                tear.Scale = setScale
                tear.CollisionDamage = tear.CollisionDamage * .8
            end
            if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
                tear.Height = math.max(tear.Height - 1, data.balorOrigHeight or 0)
            end
        end
        if tear:ToBomb() then
            local currentVel = tear.Velocity
            Isaac.CreateTimer(function()
                tear.Velocity = currentVel
            end, 1, 1, false)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.tearCol)
mod:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, mod.tearCol)
mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, mod.tearCol)
mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, mod.tearCol)
mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, mod.tearCol)



function mod:balorUnlockCond()
    local bl = Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_POLYPHEMUS) or {}
    for _,pedestal in ipairs(bl) do
        local data = pedestal:GetData()
        data.q5TargetScale = .35
        data.q5TargetOffset = Vector(0, .05)
        local pos = pedestal.Position + Vector(0, -25)
        local targetFunc = function()
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1.5)
            sfx:Play(SoundEffect.SOUND_JELLY_BOUNCE, 1.5)
            local color = Color(1,1,1,.5,1,1,1)
            color:SetColorize(1, 1, 1, 1)
            local splat = Isaac.Spawn(1000, 2, 4, pos, Vector.Zero, nil)
            splat.Color = color
            splat.DepthOffset = 80
            for i = 0, math.random(18, 24) do
                local particle = Isaac.Spawn(1000, 5, 5, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
                particle.Color = color
            end
        end
        mod.switchItem(pedestal, MattPack.Items.Balor, function()
            sfx:Play(128, 2, nil, nil, .3)
            sfx:Play(SoundEffect.SOUND_INFLATE, 1, nil, nil, .45) 
        end, targetFunc)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.balorUnlockCond, Card.CARD_HUGE_GROWTH)