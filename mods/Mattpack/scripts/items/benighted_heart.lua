local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.BenightedHeart, "↓ {{Heart}} -1 Health#↓ {{Damage}} -0.4 Damage#↑ {{Tears}} x2.3 Tear multiplier#↑ {{Tears}} +1 Tears#↑ {{Shotspeed}} +0.25 Shot speed#{{EmptyHeart}} All Red health is drained#Enemies and pickups are attracted to tears")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_SACRED_HEART, 'using#{{Blank}} {{Collectible' .. CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL .. "}} {{ColorYellow}}Book of Belial{{CR}} or#{{Blank}} {{Card" .. Card.CARD_DEVIL .. "}} {{ColorYellow}}The Devil{{CR}}", true, nil, 2)
end

function mod:bhCache(player, flag)
    if player and player:HasCollectible(MattPack.Items.BenightedHeart) then
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage - .4
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            local tearDelay = ((30 / (player.MaxFireDelay + 1))) * 2.3 + 1
            player.MaxFireDelay = 30 / tearDelay - 1
        elseif flag == CacheFlag.CACHE_TEARFLAG then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_ATTRACTOR
        elseif flag == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = Color(.25,0,.25,1)
            player.LaserColor = Color(0,0,0,1, .35, 0, .35)
        elseif flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + .25
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.bhCache)

function mod:bhTears(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(MattPack.Items.BenightedHeart) then
        if math.random(1, 6) == 1 then
            local cloud = Isaac.Spawn(1000, 88, 0, tear.Position + tear.PositionOffset, tear.Velocity + RandomVector():Resized(math.random(1, 4)), tear)
            cloud.SpriteScale = (Vector.One / 3) * (tear.Size / 7)
            cloud.Color = Color(4, 4, 4, 1) * tear.Color
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_UPDATE, mod.bhTears)

function mod:bhTearsRender(tear)
    if MattPack.isNormalRender() then
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if player and player:HasCollectible(MattPack.Items.BenightedHeart) and tear.FrameCount > 1 then
            tear:ClearTearFlags(TearFlags.TEAR_ATTRACTOR)
            game:UpdateStrangeAttractor(tear.Position, 5, 250)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, mod.bhTearsRender)

function mod:bhTearsFire(laser)
    if MattPack.isNormalRender() then
        local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
        if player and player:HasCollectible(MattPack.Items.BenightedHeart) then
            laser:ClearTearFlags(TearFlags.TEAR_ATTRACTOR)
            local samplePoints = laser:GetNonOptimizedSamples()
            if samplePoints and #samplePoints > 0 then
                -- laser:GetData().asdasdaaa = true
                -- local length = samplePoints:Get(0):Distance(samplePoints:Get(#samplePoints - 1))
                for i=0, #samplePoints-1 do
                    local pos = samplePoints:Get(i)
                    local distFromCenter = math.abs(i - (#samplePoints - 1) / 2) / 24
                    game:UpdateStrangeAttractor(pos, 2 * (distFromCenter), 250)
                end        
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, mod.bhTearsFire)

function mod:bhTearDeath(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(MattPack.Items.BenightedHeart) then
        for i = 0, math.random(4, 12) do
            local cloud = Isaac.Spawn(1000, 88, 0, tear.Position + tear.PositionOffset, RandomVector():Resized(math.random(0, 4)), tear)
            cloud.SpriteScale = (Vector.One / 3) * (tear.Size / 7) * (math.random(85, 115) / 100)
            cloud.Color = Color(4, 4, 4, 1) * tear.Color
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, mod.bhTearDeath)

function mod:bhLasers(laser)
    local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(MattPack.Items.BenightedHeart) and laser.Type < 7 then
        local samples = laser:GetSamples()
        local endPoint = samples:Get(#samples - 1)
        local cloud = Isaac.Spawn(1000, 88, 0, endPoint + laser.PositionOffset, RandomVector():Resized(math.random(4, 8)), laser)
        cloud.SpriteScale = (Vector.One / 3) * (laser.Size / 7)
        cloud.Color = Color(4, 4, 4, 1) * laser.Color
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.bhLasers)


function mod:bhHearts(player, amt, type)
    if amt == 4 and player:HasCollectible(MattPack.Items.BenightedHeart) and not player:GetData().hpCalcDone then
        if player:GetSoulHearts() + player:GetHearts() == 0 then
            player:GetData().hpCalcDone = true
            if player:GetMaxHearts() == 0 then
                player:AddMaxHearts(1)
            end
            player:AddHearts(1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, mod.bhHearts)


function mod:bhTransmute()
    local sh = Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_SACRED_HEART) or {}
    for _,pedestal in ipairs(sh) do
        local ent = pedestal:ToPickup()
        if ent then
            sfx:Play(MattPack.Sounds.ThePact, 1)
            for i = 0, 12 do
                local particle = Isaac.Spawn(1000, 88, 0, pedestal.Position, RandomVector():Resized(math.random(0, 10)), pedestal):ToEffect()
                particle.Color = Color(1,0,1,1)
                particle.DepthOffset = 100
                particle.PositionOffset = Vector(0, -35)
                particle.SpriteScale = particle.SpriteScale * math.random(10, 12) / 10
            end
            game:ShowHallucination(0, BackdropType.DARKROOM)
            Isaac.Spawn(1000, 121, 0, pedestal.Position - Vector(0, 30), Vector.Zero, nil)
            ent:Morph(pedestal.Type, pedestal.Variant, MattPack.Items.BenightedHeart, true)
            game:Darken(1, 300)
            mod.constants.pool:RemoveCollectible(MattPack.Items.BenightedHeart)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.bhTransmute, Card.CARD_DEVIL)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.bhTransmute, CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL)
