local mod = MattPack
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.WarpedLegion, "When an enemy dies, spawns a small tear-copying familiar that orbits around Isaac for the rest of the floor#Tears fired by these familiars deal 1/12 Isaac's damage#Enemies spawned by other enemies will not spawn familiars")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_TWISTED_PAIR, 'using {{Card' ..Card.RUNE_JERA .. "}}" .. "{{ColorYellow}} Jera {{CR}}", true)
end

local mincubus_null = Isaac.GetNullItemIdByName("wl_mincubus")
local mincubus_config = Isaac.GetItemConfig():GetNullItem (mincubus_null)

function mod.GetMincubusTargetPos(ent, data)
    if not data then
        data = ent:GetData()
    end
    local player = ent.Player or Isaac.GetPlayer()
    local rng = data.RNG
    if not rng then
        rng = RNG()
        data.RNG = rng
    end
    rng:SetSeed(ent.InitSeed)
    
    local orbitSpeedMulti = rng:RandomFloat() * ((rng:RandomInt(2) == 0 and -1) or 1)
    local orbitOffset = 10 + rng:RandomFloat() * 35
    return (player.Position + player.Velocity) + Vector.FromAngle(((rng:RandomFloat() * 360) + ent.FrameCount) * (3.5 * orbitSpeedMulti)):Resized(orbitOffset)
end

local wlMulti = 1/12

function mod.GetMincubusDmgMulti(familiar)
    local multi = wlMulti
    familiar = familiar and familiar:ToFamiliar()
    if familiar then
        local playerType = familiar.Player and familiar.Player:GetPlayerType()
        if not (playerType and (playerType == PlayerType.PLAYER_LILITH or playerType == PlayerType.PLAYER_LILITH_B)) then
            multi = ((1 / .75)) * wlMulti
        end
    end
    multi = multi
    return multi
end

function mod.IsMincubus(ent)
    if ent and ent.Type == 3 and ent.Variant == 80 and ent.SubType == 1530 then
        return true
    end
end

function mod.CheckMincubi(player)
    local effects = player:GetEffects()
    local count = effects:GetNullEffectNum(mincubus_null)
    count = math.min(64, count * (1 + effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)))

    local rng = RNG()
    local seed = math.max(1, Random())
    rng:SetSeed(seed, 35)

    local familiars = player:CheckFamiliarEx(80, count, rng, mincubus_config, 1530)
    for _, mincubus in ipairs(familiars) do
        if mod.wlLastKilledEnemyPos then
            mincubus.Position = mod.wlLastKilledEnemyPos
            mod.wlLastKilledEnemyPos = nil
            sfx:Play(SoundEffect.SOUND_BEAST_GHOST_DASH, .33, nil, nil, 1.5)
            sfx:Play(SoundEffect.SOUND_SIREN_MINION_SMOKE, 1)
            for i = 1, 6 do
                local particle = Isaac.Spawn(1000, 88, 0, mincubus.Position + Vector(0, -20), RandomVector():Resized(3), mincubus):ToEffect()
                particle.SpriteScale = particle.SpriteScale * math.random(10, 12) / 20
            end
        else
            mincubus.Position = mod.GetMincubusTargetPos(mincubus)
            mincubus:GetData().skipDelay = true
        end
    end
    if #familiars == 0 and count == 64 then
        sfx:Play(SoundEffect.SOUND_SIREN_MINION_SMOKE, 1)
        for i = 1, 6 do
            local particle = Isaac.Spawn(1000, 88, 0, ent.Position + Vector(0, -20), RandomVector():Resized(3), ent):ToEffect()
            particle.SpriteScale = particle.SpriteScale * math.random(10, 12) / 20
        end
    end
end

function mod:wlSpawnFamiliar(ent)
    local playersToCheck = {}
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(mod.Items.WarpedLegion) then
            table.insert(playersToCheck, player)
        end
    end
    if #playersToCheck > 0 then
        if not (ent.SpawnerEntity and ent.SpawnerEntity:ToNPC()) then
            local player = playersToCheck[math.random(1, #playersToCheck)]
            player:AddNullItemEffect(mincubus_null, false)
            
            mod.wlLastKilledEnemyPos = ent.Position
            mod.CheckMincubi(player)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.wlSpawnFamiliar)

function mod:wlEvalCache(player)
    mod.CheckMincubi(player)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.wlEvalCache, CacheFlag.CACHE_FAMILIARS)

function mod:wlBabyUpdate(ent)
    if ent.SubType == 1530 then
        local sizeMulti = 1/3 * ((ent:GetMultiplier() + 4) / 5)
        ent.SpriteScale = (Vector.One * sizeMulti)
        ent.PositionOffset = Vector(0, -12.5)
        local player = ent.Player
        if player then
            local data = ent:GetData()

            ent:SetShadowSize(.075)
            local timeToFullSpeed = 30
            local targetPos = mod.GetMincubusTargetPos(ent)
            local trail = data.trail
            
            if (ent.FrameCount <= timeToFullSpeed and ent.Position:Distance(targetPos) > 10) and (not data.skipDelay) then
                if ent.FrameCount > 0 and not (trail and trail:Exists()) then
                    trail = Isaac.Spawn(1000, 166, 0, ent.Position + ent.PositionOffset, Vector.Zero, ent):ToEffect()
                    trail:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.NORMAL)
                    trail:FollowParent(ent)
                    trail:Update()
                    trail.Color = Color(0,0,0,.5)
                    trail.MinRadius = .1
                    trail.MaxRadius = .1
                    trail.SpriteScale = Vector.One
                    trail.ParentOffset = Vector(0, -20)
                    data.trail = trail
                end
            else
                if trail then
                    trail.MinRadius = trail.MinRadius + .1
                    trail.MaxRadius = trail.MaxRadius + .1

                    if trail.MinRadius >= 1 then
                        trail:Remove()
                        data.trail = nil
                    end
                end
            end
            if ent.FrameCount < 15 and (not data.skipDelay) then
                ent.Velocity = Vector.Zero
            else
                if not data.randomDirSet then
                    data.randomDirSet = ent.Velocity
                    ent.Velocity = RandomVector():Resized(15)
                end
                local speedMulti = (math.min(ent.FrameCount, timeToFullSpeed) / timeToFullSpeed)
                if data.skipDelay then
                    speedMulti = 1
                end
                local targetVel = Lerp(ent.Velocity, targetPos - ent.Position, .5 * speedMulti)
                ent.Velocity = targetVel:Resized(math.min(25, targetVel:Length()))
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.wlBabyUpdate, 80)

function mod:wlBabyInit(ent)
    if ent.SubType == 1530 then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.wlBabyInit, 80)

function mod:wlTearFire(ent)
    local spawner = ent.SpawnerEntity
    if spawner and spawner.Type == 3 and spawner.Variant == 80 and spawner.SubType == 1530 then
        if ent.Type == 8 then
            ent.SpriteScale = Vector.One / 3
        else
            local data = ent:GetData()
            if not data.wlTearInit then
                local multi = mod.GetMincubusDmgMulti(spawner)
                data.wlTearInit = true
                if ent.Type == 2 then
                    ent.CollisionDamage = (ent.CollisionDamage * multi)
                    ent.Scale = math.sqrt(ent.CollisionDamage) / 2
                    ent.KnockbackMultiplier = ent.KnockbackMultiplier * (multi / 4)
                elseif ent.Type == 7 then
                    ent:SetScale(ent:GetScale() * multi * 3)
                    ent.Radius = ent.Radius * multi * 3
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, mod.wlTearFire)
mod:AddCallback(ModCallbacks.MC_PRE_LASER_UPDATE, mod.wlTearFire)
mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_RENDER, mod.wlTearFire)

function mod:wlOtherWeaponFire(ent)
    local posToSearch = ent.Position
    for _,mincubus in ipairs(Isaac.FindInRadius(posToSearch, 0, EntityPartition.FAMILIAR)) do
        if mincubus.Type == 3 and mincubus.Variant == 80 and mincubus.SubType == 1530 then
            if mincubus.Position:DistanceSquared(posToSearch) <= 0.01 then
                if ent.Type == 4 then
                    local multi = mod.GetMincubusDmgMulti(mincubus)
                    ent.ExplosionDamage = ((ent.ExplosionDamage) * multi)
                    ent.RadiusMultiplier = ((ent.RadiusMultiplier) * (multi * 6))
                    ent:SetScale(ent:GetScale() * multi)
                end
                break
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, mod.wlOtherWeaponFire)

function mod:wlKnifeDmg(ent, amt, flags, source)
    local src = source and source.Entity
    if src then
        if src.Type == 2 then -- Pre-init tears
            local spawner = src.SpawnerEntity
            if mod.IsMincubus(spawner) and not src:GetData().wlTearInit then
                return {Damage = amt * mod.GetMincubusDmgMulti(spawner)}
            end
        elseif src.Type == 8 then -- Knives
            local parent = src.Parent
            if mod.IsMincubus(parent) then
                return {Damage = amt * mod.GetMincubusDmgMulti(parent)}
            end
        elseif mod.IsMincubus(src) then -- All damage sourced from mincubus
            if flags & DamageFlag.DAMAGE_LASER ~= 0 then -- Laser damage
                return {Damage = amt * mod.GetMincubusDmgMulti(src)}
            end
        else -- Non-tear damage from sources spawned by mincubus
            local spawner = src.SpawnerEntity
            if mod.IsMincubus(spawner) then
                return {Damage = amt * mod.GetMincubusDmgMulti(spawner)}
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.wlKnifeDmg)

function mod:wlClearIncubi()
    for _,player in ipairs(PlayerManager.GetPlayers()) do
        local effect = player:GetEffects()
        effect:RemoveNullEffect(mincubus_null, -1)
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.wlClearIncubi)

function mod:wlEpicFetusMarker(ent)
    local spawner = ent.SpawnerEntity
    if spawner and spawner.Type == 3 and spawner.Variant == 80 and spawner.SubType == 1530 then
        ent.SpriteScale = Vector.One * (mod.GetMincubusDmgMulti(spawner) * 3)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, mod.wlEpicFetusMarker, 30)


function mod:warpedLegionUnlockCond()
    local bl = Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_TWISTED_PAIR) or {}
    for _,pedestal in ipairs(bl) do
        local data = pedestal:GetData()
        data.q5TargetScale = .35
        data.q5TargetOffset = Vector(0, .05)
        data.targetColor = Color(0,0,0,1)
        local pos = pedestal.Position + Vector(2.5, -35)
        local targetFunc = function()
            sfx:Play(SoundEffect.SOUND_DEMON_HIT, 1.5)
            sfx:Play(SoundEffect.SOUND_MENU_FLIP_DARK, 1.5)
            local splat = Isaac.Spawn(1000, 2, 4, pos, Vector.Zero, nil)
            splat.DepthOffset = 80
            for i = 0, math.random(18, 24) do
                local particle = Isaac.Spawn(1000, 66, 0, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
                particle.Color = Color(0,0,0,1)
                particle.SpriteOffset = Vector(-2, -2)
                local trail = Isaac.Spawn(1000, 166, 0, particle.Position + particle.PositionOffset, Vector.Zero, particle):ToEffect()
                trail:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.NORMAL)
                trail:FollowParent(particle)
                trail:Update()
                trail.Color = Color(0,0,0,.5)
                trail.MinRadius = .1
                trail.MaxRadius = .1
                trail.SpriteScale = Vector.One
            end
            local poof = Isaac.Spawn(1000, 88, 0, pos + RandomVector():Resized(15, 30), Vector.Zero, nil)
            poof.SpriteScale = Vector.One * math.random(5, 10) / 5
            poof.Color = pedestal.Color
            poof.DepthOffset = 80
        end
        local updateFunc = function(pedestal, percent)
            if MattPack.isNormalRender() and math.random(1, 7) == 1 then
                if math.random(1, 4) == 1 then
                    local particle = Isaac.Spawn(1000, 66, 0, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
                    particle.Color = Color(0,0,0,1)
                    particle.SpriteOffset = Vector(-2, -2)
                    local trail = Isaac.Spawn(1000, 166, 0, particle.Position + particle.PositionOffset, Vector.Zero, particle):ToEffect()
                    trail:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.NORMAL)
                    trail:FollowParent(particle)
                    trail:Update()
                    trail.Color = Color(0,0,0,.5)
                    trail.MinRadius = .1
                    trail.MaxRadius = .1
                    trail.SpriteScale = Vector.One
                end
                local poof = Isaac.Spawn(1000, 88, 0, pos + RandomVector():Resized(15, 30), Vector.Zero, nil)
                poof.SpriteScale = Vector.One * math.random(5, 10) / 10 * ((data.q5TargetScale * percent) + 1)
                poof.Color = pedestal.Color
                poof.DepthOffset = 80
                sfx:Play(SoundEffect.SOUND_BEAST_GHOST_DASH, .33, nil, nil, 1.5)
                sfx:Play(SoundEffect.SOUND_SIREN_MINION_SMOKE, 1)
            end
        end
        mod.switchItem(pedestal, MattPack.Items.WarpedLegion, function()
            sfx:Play(128, 1, nil, nil, .3)
        end, targetFunc, updateFunc)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.warpedLegionUnlockCond, Card.RUNE_JERA)