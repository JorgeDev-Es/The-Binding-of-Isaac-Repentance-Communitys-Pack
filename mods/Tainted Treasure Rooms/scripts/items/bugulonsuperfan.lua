local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local function ApplyBugulonBoneSkin(knife, player)
    local sprite = knife:GetSprite()
    if knife.Variant == 2 then
        sprite:ReplaceSpritesheet(0, "gfx/characters/costumes_forgotten/effect_boneknife_bsf.png")
    else
        sprite:ReplaceSpritesheet(0, "gfx/characters/costumes_forgotten/effect_boneclub_bsf.png")
    end
    sprite:LoadGraphics()
    knife:GetData().BugulonSkin = true
end

function mod:CheckTearVariant(tear, variant, overideCSection)
    if tear.Variant ~= variant and (tear.Variant ~= 50 or overideCSection) and tear.Variant ~= TaintedTears.SAWBLADE then --50 is C Section tear
        tear:ChangeVariant(variant)
        return true
    end
end

function mod:GetAimDirectionGood(player)
    local aim = player:GetAimDirection()
    local lockAngle
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
            lockAngle = 45
        else
            lockAngle = 90
        end
    end
    if lockAngle then
        aim = mod:SnapVector(aim, lockAngle)
    end
    aim = aim:Normalized()
    return aim
end

function mod:SnapVector(angle, snapAngle)
    local snapped = math.floor(((angle:GetAngleDegrees() + snapAngle/2) / snapAngle)) * snapAngle
    local snappedDirection = angle:Rotated(snapped - angle:GetAngleDegrees())
    return snappedDirection
end

function mod:BugulonFanOnFireTear(player, tear)
    local sprite = tear:GetSprite()
    local data = tear:GetData()
    local path = "gfx/projectiles/tear_bugulonsuperfan"
    if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
        path = path.."_forgotten"
    end
    path = path..".png"
    mod:CheckTearVariant(tear, TearVariant.BLUE)
    sprite:ReplaceSpritesheet(0, path)
    sprite:LoadGraphics()
    data.CustomSplat = path
end

function mod:BugulonSuperFanNewRoom(room, roomtype)
    local players = mod:GetPlayersHoldingCollectible(TaintedCollectibles.BUGULON_SUPER_FAN)
    if players and room:IsFirstVisit() and (roomtype == RoomType.ROOM_CHALLENGE or roomtype == RoomType.ROOM_BOSSRUSH or not room:IsClear()) then
        local rng = players[1]:GetCollectibleRNG(TaintedCollectibles.BUGULON_SUPER_FAN)
        local amount = mod:RandomInt(1,3,rng)
        if roomtype == RoomType.ROOM_BOSS or roomtype == RoomType.ROOM_CHALLENGE then
            amount = 3
        elseif roomtype == RoomType.ROOM_BOSSRUSH then
            amount = 10
        end
        for i = 1, amount * mod:GetTotalCollectibleNum(TaintedCollectibles.BUGULON_SUPER_FAN) do
            local sub = 0
            if rng:RandomFloat() <= 0.2 then --20% chance for TV
                sub = 1
            end
            local spawnpos = Isaac.GetFreeNearPosition(room:GetRandomPosition(40), 40)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, TaintedPickups.BUGULON_PROP, sub, spawnpos, Vector.Zero, nil)
        end
    else
        for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, TaintedPickups.BUGULON_PROP, -1, false, false)) do
            pickup.Visible = false
            pickup:Remove()
        end
    end
end

function mod:CheckForBugulonKnifeSkin(knife, data)
    local data = knife:GetData()
    if knife.Variant == 1 or knife.Variant == 2 then
        if not data.BugulonSkin and knife.Parent then
            if knife.Parent:ToPlayer() then
                local player = knife.Parent:ToPlayer()
                if player:Exists() and player:HasCollectible(TaintedCollectibles.BUGULON_SUPER_FAN) then
                    ApplyBugulonBoneSkin(knife, player)
                end
            elseif knife.Parent:ToKnife() then
                if knife.Parent.Parent:ToPlayer() then
                    local player = knife.Parent.Parent:ToPlayer()
                    if player:Exists() and player:HasCollectible(TaintedCollectibles.BUGULON_SUPER_FAN) then
                        ApplyBugulonBoneSkin(knife, player)
                    end
                end
            end
        end
    end
end

function mod:ThrowBugulonProp(pickup, player, velocity, height)
    height = height or 20
    pickup.Position = player.Position
    pickup.Velocity = velocity
    pickup.SpriteOffset = Vector(0, -height)
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
    pickup.Visible = true
    pickup:GetData().state = "thrown"
    pickup:GetData().TimeToThrow = nil
    player:GetData().HeldBugulonProp = nil
    sfx:Play(TaintedSounds.ATONEMENT_THROW)
end

function mod:BugulonPropDestroy(pickup, isTV)
    for i = 1, 3 do
        local gib = Isaac.Spawn(1000, 163, 0, pickup.Position, RandomVector() * mod:RandomInt(1,5), pickup)
        local sprite = gib:GetSprite()
        sprite:ReplaceSpritesheet(0, "gfx/effects/effect_props_gibs.png")
        sprite:LoadGraphics()
    end
    if isTV then
        local player = pickup.Parent:ToPlayer()
        local bomb = player:FireBomb(pickup.Position,Vector.Zero,player)
        bomb.IsFetus = false
        bomb.ExplosionDamage = 40
        bomb.Visible = false
        bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        sfx:Play(TaintedSounds.BOTTLE_BREAK2)
        --sfx:Play(SoundEffect.SOUND_MIRROR_BREAK, 0.35, 0, false, 2)
        bomb:SetExplosionCountdown(0)
    end
    sfx:Play(SoundEffect.SOUND_POT_BREAK)
    pickup:Remove()
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    local data = pickup:GetData()
    local sprite = pickup:GetSprite()
    local rng = pickup:GetDropRNG()
    local isTV = (pickup.SubType == 1)

    if not data.Init then
        if isTV then
            data.Anim1 = "Television"
            data.Health = 1
        else
            data.Anim1 = "Chair"
            data.Health = 2
        end
        sprite.FlipX = (rng:RandomFloat() <= 0.5)
        data.Anim2 = "01"
        data.state = "idle"
        data.Init = true
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    end

    if data.state == "idle" then
        if game:GetRoom():GetGridCollisionAtPos(pickup.Position) == GridCollisionClass.COLLISION_PIT then
            Isaac.Spawn(1000,15,0,pickup.Position,Vector.Zero,pickup)
            pickup:Remove()
        end
    elseif data.state == "held" then --Referred to Sanguine Hook from FF for this
        local player = pickup.Parent:ToPlayer()
        local aim = mod:GetAimDirectionGood(player)

		if aim:Length() > 0.2 then
            data.TimeToThrow = 3
            data.ThrownVel = (aim * 25) + (2 * player:GetTearMovementInheritance(aim))
            player:AnimatePickup(pickup:GetSprite(), false, "HideItem")
        end
        pickup.Velocity = ((player.Velocity * player.MoveSpeed) + player.Position) - pickup.Position
        if data.TimeToThrow then
            data.TimeToThrow = data.TimeToThrow - 1
            if data.TimeToThrow <= 0 then
                mod:ThrowBugulonProp(pickup, player, data.ThrownVel)
            end
        end

    elseif data.state == "thrown" then
        if pickup:CollidesWithGrid() then
            if isTV or data.PrevVel >= 12 then
                sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.8, 0, false, 1.3)
                data.Health = data.Health - 1
                if data.Health <= 0 then
                    mod:BugulonPropDestroy(pickup, isTV)
                elseif not isTV then
                    data.Anim2 = "02"
                end
            end
        end
        if pickup.SpriteOffset.Y >= 0 or pickup.Velocity:Length() < 7.5 then
            data.state = "idle"
            pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
            pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        else
            local enemies = Isaac.FindInRadius(pickup.Position, 100, EntityPartition.ENEMY)
            for _, enemy in pairs(enemies) do
                if enemy:IsEnemy() and enemy.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_PLAYEROBJECTS and enemy.Position:Distance(pickup.Position) < pickup.Size + enemy.Size then
                    local player = pickup.Parent:ToPlayer()
                    local damage = 3.5
                    local source = pickup
                    if player:Exists() then
                        damage = math.max(3.5, player.Damage)
                        source = player
                    end

                    enemy:TakeDamage(damage * math.max(4.5, pickup.Velocity:Length() / 5), 0, EntityRef(source), 0)
                    enemy.Velocity = enemy.Velocity + Vector(pickup.Velocity:Length() / 1.5, 0):Rotated((enemy.Position - (pickup.Position - pickup.Velocity)):GetAngleDegrees())
                    sfx:Play(TaintedSounds.ATONEMENT_IMPACT)
                    data.Health = data.Health - 1
                    if data.Health <= 0 then
                        mod:BugulonPropDestroy(pickup, isTV)
                    else
                        pickup.Velocity = Vector(pickup.Velocity:Length() / 3, 0):Rotated(((pickup.Position - pickup.Velocity) - enemy.Position):GetAngleDegrees())
                        if not isTV then
                            data.Anim2 = "02"
                        end
                        data.state = "idle" 
                        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                    end
                    return
                end
            end
        end
    end

    mod:spritePlay(sprite, data.Anim1..data.Anim2)
    data.PrevVel = pickup.Velocity:Length()

end, TaintedPickups.BUGULON_PROP)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
    if mod:IsNormalRender() then
        local data = pickup:GetData()
        data.DownAccel = data.DownAccel or 0.035
        if pickup.SpriteOffset.Y < 0 then
            pickup.SpriteOffset = Vector(pickup.SpriteOffset.X, pickup.SpriteOffset.Y + data.DownAccel)
            data.DownAccel = data.DownAccel + 0.035
        else
            data.DownAccel = 0.035
            pickup.SpriteOffset = Vector(pickup.SpriteOffset.X, 0)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
    local data = pickup:GetData()
    local sprite = pickup:GetSprite()
    local isTV = (pickup.SubType == 1)
    local player = collider:ToPlayer()
    if data.state == "idle" and player and player:IsExtraAnimationFinished() then
        data.state = "held"
        if pickup.SubType == 1 then
            data.Anim2 = "02"
            sprite:Play("Television02") --Calling this here so it plays that anim when held
        end
        player:AnimatePickup(sprite, false, "LiftItem")
        pickup.Parent = player
        player:GetData().HeldBugulonProp = pickup
        pickup.Visible = false
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        sfx:Play(SoundEffect.SOUND_SHELLGAME, 0.75, 0, false, 1.2)
    end
end, TaintedPickups.BUGULON_PROP)