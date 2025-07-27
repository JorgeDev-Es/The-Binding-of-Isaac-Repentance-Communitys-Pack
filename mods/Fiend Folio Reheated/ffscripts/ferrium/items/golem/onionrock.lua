local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

--just slightly adjusted function from I think erfly idk
local function PikminRandomVisibleEnemy(pos, radius, blacklist, closest)
	pos = pos or Game:GetRoom():GetCenterPos()
	radius = radius or 1000
    blacklist = blacklist or {}
    local dist = 9999
    local chosen
	local targets = {}
	local target = nil
    local room = game:GetRoom()
	for _, entity in pairs(Isaac.FindInRadius(pos, radius, EntityPartition.ENEMY)) do
		if entity and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) and room:CheckLine(entity.Position, pos, 0, 999, false, false) and not blacklist[entity.InitSeed] then
			local etype = entity.Type
			local evar = entity.Variant
			local esub = entity.SubType
			local badent = false
			for _, v in ipairs(mod.BadEnts) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then badent = true end
				elseif v[2] then if etype == v[1] and evar == v[2] then badent = true end
				elseif etype == v[1] then badent = true end
			end

			if entity.EntityCollisionClass > 0 and not badent and etype ~= 4 then
                if closest and pos:Distance(entity.Position) < dist then
                    closest = entity
                    dist = pos:Distance(entity.Position)
                else
                    table.insert(targets, entity)
                end
			end
		end
	end
    if closest then
        return chosen
    else
        if #targets > 0 then
            target = targets[math.random(#targets)]
        end
        return target
    end
end

function mod:onionRockFamiliar(player)
    local d = player:GetData().ffsavedata.RunEffects
    local count = {[0] = 0, [1] = 0, [2] = 0}
    if d and d.brickminData then
        if player:HasTrinket(mod.ITEM.ROCK.ONION_ROCK) then
            if d.brickminData.brickmins then
                for _,num in ipairs(d.brickminData.brickmins) do
                    count[num] = count[num]+1
                end
            else
                local rng = player:GetTrinketRNG(mod.ITEM.ROCK.ONION_ROCK)
                local num = rng:RandomInt(3)
                count[num] = 1
                d.brickminData = {brickmins = {num}, roomClear = 0}
            end
        end
    end
    for i=0,2 do
        player:CheckFamiliar(mod.ITEM.FAMILIAR.BRICKMIN, count[i], player:GetTrinketRNG(mod.ITEM.ROCK.ONION_ROCK), Isaac:GetItemConfig():GetTrinket(mod.ITEM.ROCK.ONION_ROCK), i)
    end
end

mod.AddTrinketPickupCallback(
function(player, trinket)
    local d = player:GetData().ffsavedata.RunEffects
    d.brickminData = d.brickminData or {}
end, nil, FiendFolio.ITEM.ROCK.ONION_ROCK, nil)

function mod:onionRockFire(player, isFiring)
    if not isFiring then return end
    if player:HasTrinket(mod.ITEM.ROCK.ONION_ROCK) then
        local data = player:GetData()
        local frame = player.FrameCount
        local fireFrame = data.LastOnionRockFirePress

        if not fireFrame or frame-fireFrame > 12 then
            mod:launchNearbyBrickmin(player, data, frame)
        end
	end
end

function mod:onionRockNewRoom()
    for _,brick in ipairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.BRICKMIN, -1, false, false)) do
        brick:GetData().state = "Idle"
        brick:GetData().launchedEnemyInfo = nil
        brick.SpriteOffset = Vector.Zero
        brick.PositionOffset = Vector.Zero
        brick:GetData().pikminHopped = nil
    end
end

function mod:onionRockNewLevel()
    for _,brick in ipairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.BRICKMIN, -1, false, false)) do
        brick:Remove()
    end
    for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i - 1)
		local basedata = player:GetData()
        local d = basedata.ffsavedata.RunEffects

        if d.brickminData then
            d.brickminData = {}
        end

        if player:HasTrinket(mod.ITEM.ROCK.ONION_ROCK) then
            local rng = player:GetTrinketRNG(mod.ITEM.ROCK.ONION_ROCK)
            local num = rng:RandomInt(3)
            local fam = Isaac.Spawn(3, mod.ITEM.FAMILIAR.BRICKMIN, num, player.Position, Vector.Zero, player):ToFamiliar()
            fam.Player = player
            d.brickminData = {brickmins = {num}, roomClear = 0}

            sfx:Play(mod.Sounds.PikminPluckSound, 0.6, 0, false, 1)
            sfx:Play(mod.Sounds.PikminPluckVoice, 0.6, 5, false, 1)
        end
    end
end

function mod:launchNearbyBrickmin(player, data, frame)
    if player:GetFireDirection() < 0 then return end
    local chosenBrick
    local dist = 50
    for _,brick in ipairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.BRICKMIN, -1, false, false)) do
        if brick.Position:Distance(player.Position) < dist and brick:GetData().state and brick:GetData().state == "Idle" then
            chosenBrick = brick
            dist = brick.Position:Distance(player.Position)
        end
    end

    if chosenBrick then
        chosenBrick = chosenBrick:ToFamiliar()
        local dir = mod.GetCorrectedFiringInput(player)
        local cd = chosenBrick:GetData()

        chosenBrick:GetSprite().FlipX = dir.X < 0
        cd.pikminJumpDir = dir
        cd.state = "Jump"
        data.LastOnionRockFirePress = frame
        sfx:Play(mod.Sounds.PikminLift, 1, 0, false, 1)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, npc)
	mod:flyingFuckEffect(npc)
end, mod.ITEM.FAMILIAR.BRICKMIN)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local sprite = fam:GetSprite()
    local d = fam:GetData()
    local rng = fam:GetDropRNG()
    local room = game:GetRoom()

    if not d.init then
        fam.Coins = 0
        local sheet = rng:RandomInt(3)+1
        local subNum = math.min(fam.SubType+1, 3)
        sprite:Load("gfx/familiar/brikmin/familiar_brikmin" .. subNum .. ".anm2", true)
        sprite:ReplaceSpritesheet(0, "gfx/familiar/brikmin/familiar_brikmin" .. subNum .. sheet .. ".png")
        sprite:LoadGraphics()
        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        d.state = "Idle"
        mod.scheduleForUpdate(function()
            sfx:Play(mod.Sounds.PikminPluckSound, 0.6, 0, false, 1)
            sfx:Play(mod.Sounds.PikminPluckVoice, 0.6, 5, false, 1)
        end, 1)
        d.init = true
    else
        fam.Coins = fam.Coins+1
    end

    if not fam.Player or not fam.Player:Exists() then
        fam.Player = mod:getClosestPlayer(fam.Position, 999)
    else
        if fam.SubType == 0 then --square
            if d.state == "Idle" then
                local walk
                if fam.Position:Distance(fam.Player.Position) > 50 then
                    if sprite:IsEventTriggered("Sound") then
                        sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.15, 0, false, mod:getRoll(155, 180, rng)/100)
                        fam.Hearts = 6
                        d.speed = 12
                    --elseif sprite:IsEventTriggered("Step") then
                    end
                    walk = true
                end

                sprite.FlipX = fam.Velocity.X < 0

                if fam.Hearts > 0 then
                    if room:CheckLine(fam.Position, fam.Player.Position, 0, 999, false, false) then
                        fam.Velocity = mod:Lerp(fam.Velocity, (fam.Player.Position-fam.Position):Resized(d.speed), 0.3)
                    else
                        local real = mod:CatheryPathFinding(fam, fam.Player.Position, {
                            Speed = d.speed,
                            Accel = 0.6,
                            Threshhold = 999,
                        })
                        if not real then
                            if room:GetGridCollisionAtPos(fam.Position) > GridCollisionClass.COLLISION_NONE then
                                local dest = mod:GetClosestPosThatCanReachTarget(fam.Position, fam.Player.Position)
                                if dest then
                                    d.state = "Flying"
                                    d.launchedEnemyInfo = {zVel = -5.8, pos = true, landFunc = function()
                                        fam.SpriteOffset = Vector.Zero
                                        fam.PositionOffset = Vector.Zero
                                        d.state = "Idle"
                                    end, collision = 0, vel = (dest-fam.Position)*0.05}
                                end
                            else
                                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                walk = nil
                            end
                        end
                    end
                    d.speed = d.speed*0.7
                else
                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                end

                if walk then
                    mod:spritePlay(sprite, "Walk")
                else
                    mod:spritePlay(sprite, "Idle")
                end
            elseif d.state == "Sleep" then
                local real = mod:CatheryPathFinding(fam, fam.Player.Position, {
                    Speed = 0,
                    Accel = 0.6,
                    Threshhold = 999,
                })
                if not real then
                    local noWalkery
                    if room:GetGridCollisionAtPos(fam.Position) > GridCollisionClass.COLLISION_NONE then
                        local dest = mod:GetClosestPosThatCanReachTarget(fam.Position, fam.Player.Position)
                        if dest then
                            d.state = "Flying"
                            d.launchedEnemyInfo = {zVel = -5.8, pos = true, landFunc = function()
                                fam.SpriteOffset = Vector.Zero
                                fam.PositionOffset = Vector.Zero
                                d.state = "Sleep"
                            end, collision = 0, vel = (dest-fam.Position)*0.05}
                        else
                            fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                            noWalkery = true
                        end
                    else
                        if not d.triedClosestSpot then
                            local testPath = Isaac.Spawn(mod.FF.BuriedFossilCrack.ID, mod.FF.BuriedFossilCrack.Var, 0, fam.Position, Vector.Zero, nil):ToNPC()
                            testPath.Visible = false
                            testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
                            testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                            d.closestSpot = mod:antiGolemFindSpot(fam, fam.Player.Position, testPath.Pathfinder, "Player")
                            d.triedClosestSpot = true
                            testPath:Remove()
                        else
                            if d.closestSpot then
                                if fam.Position:Distance(d.closestSpot) < 40 then
                                    local dest = mod:GetClosestPosThatCanReachTarget(fam.Position, fam.Player.Position)
                                    if dest then
                                        d.state = "Flying"
                                        d.launchedEnemyInfo = {zVel = -5.8, pos = true, landFunc = function()
                                            fam.SpriteOffset = Vector.Zero
                                            fam.PositionOffset = Vector.Zero
                                            d.state = "Sleep"
                                        end, collision = 0, vel = (dest-fam.Position)*0.05}
                                        d.closestSpot = nil
                                        d.triedClosestSpot = nil
                                    else
                                        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                        noWalkery = true
                                    end
                                else
                                    if room:CheckLine(fam.Position, d.closestSpot, 0, 999, false, false) then
                                        local targetvel = (d.closestSpot - fam.Position):Resized(d.speed)
                                        fam.Velocity = mod:Lerp(fam.Velocity, targetvel, 0.3)
                                    else
                                        local try = mod:CatheryPathFinding(fam, d.closestSpot, {
                                            Speed = d.speed,
                                            Accel = 0.6,
                                            Threshhold = 999,
                                        })
                                        if not try then
                                            fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                            noWalkery = true
                                        end
                                    end
                                end
                            else
                                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                noWalkery = true
                            end
                        end
                    end
                    if noWalkery then
                        mod:spritePlay(sprite, "Idle")
                    else
                        mod:spritePlay(sprite, "Walk")
                    end

                    if sprite:IsEventTriggered("Sound") then
                        sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.15, 0, false, mod:getRoll(155, 180, rng)/100)
                        fam.Hearts = 6
                        d.speed = 12
                    end

                    if fam.Hearts > 0 then
                        fam.Hearts = fam.Hearts-1
                        d.speed = d.speed*0.7
                    end
                else
                    if fam.Player.Position:Distance(fam.Position) < 60 and fam.Coins > 30 then
                        d.state = "WakeUp"
                    end
        
                    mod:spritePlay(sprite, "Sreeping")
                    fam.Velocity = Vector.Zero
                end
            elseif d.state == "Flying" then
                mod:spritePlay(sprite, "InAir")
            elseif d.state == "Jump" then
                if sprite:IsFinished("Jump") then
                    d.launchedEnemyInfo = {vel = d.pikminJumpDir:Resized(10), zVel = -9, collision = -30, landFunc = function()
                        d.state = "Impact"
                        d.impactFrame = rng:RandomInt(2)+1
                        fam.Coins = 0
                        fam.SpriteOffset = Vector.Zero
                        fam.PositionOffset = Vector.Zero
                        sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 0.6, 0, false, 1.6)
                        local poof = Isaac.Spawn(1000, 16, 1, fam.Position, Vector.Zero, fam):ToEffect()
                        poof.SpriteScale = Vector(0.7, 1)
        
                        for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, 60, EntityPartition.ENEMY)) do
                            if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
                                local level = game:GetLevel():GetAbsoluteStage()
                                enemy:TakeDamage((fam.Player.Damage or 5)*2+3*level, 0, EntityRef(fam), 0)
                                enemy:AddConfusion(EntityRef(fam), 80, false)
                            end
                        end
                    end, height = -10, pos = true, extraFunc = function()
                        d.launchedEnemyInfo.vel = d.launchedEnemyInfo.vel*0.97
                        if d.launchedEnemyInfo.zVel > 1 then
                            d.launchedEnemyInfo.accel = 2
                            d.launchedEnemyInfo.vel = mod:Lerp(d.launchedEnemyInfo.vel, Vector.Zero, 0.1)
                        end
        
                        sprite.FlipX = fam.Velocity.X < 0
                    end,}
                    sfx:Play(mod.Sounds.PikminThrow, 0.55, 0, false, 1)
                    sfx:Stop(mod.Sounds.PikminLift)
                    d.state = "Flying"
                    d.closestSpot = nil
                    d.triedClosestSpot = nil
                else
                    mod:spritePlay(sprite, "Jump")
                end

                fam.Velocity = Vector.Zero
            elseif d.state == "Impact" then
                if sprite:IsFinished("Impact" .. d.impactFrame) then
                    d.state = "Sleep"
                else
                    mod:spritePlay(sprite, "Impact" .. d.impactFrame)
                end
                fam.Velocity = Vector.Zero
            elseif d.state == "WakeUp" then
                if sprite:IsFinished("WAKEUP") then
                    d.state = "Idle"
                elseif sprite:IsEventTriggered("Sound") then
                    sfx:Play(mod.Sounds.PikminCall, 1, 0, false, 1)
                else
                    mod:spritePlay(sprite, "WAKEUP")
                end
                fam.Velocity = Vector.Zero
            end
        elseif fam.SubType == 1 then --sharpe
            local speed = 9
            if d.state == "Idle" then
                if fam.Position:Distance(fam.Player.Position) > 50 then
                    if room:CheckLine(fam.Position, fam.Player.Position, 0, 999, false, false) then
                        fam.Velocity = mod:Lerp(fam.Velocity, (fam.Player.Position-fam.Position):Resized(speed), 0.3)
                    else
                        local real = mod:CatheryPathFinding(fam, fam.Player.Position, {
                            Speed = speed,
                            Accel = 0.6,
                            Threshhold = 999,
                        })
                        if not real then
                            if room:GetGridCollisionAtPos(fam.Position) > GridCollisionClass.COLLISION_NONE then
                                local dest = mod:GetClosestPosThatCanReachTarget(fam.Position, fam.Player.Position)
                                if dest then
                                    d.state = "Flying"
                                    d.launchedEnemyInfo = {zVel = -5.8, pos = true, landFunc = function()
                                        fam.SpriteOffset = Vector.Zero
                                        fam.PositionOffset = Vector.Zero
                                        d.state = "Idle"
                                    end, collision = 0, vel = (dest-fam.Position)*0.05}
                                else
                                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                end
                            else
                                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                            end
                        end
                    end
                else
                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                end

                sprite.FlipX = fam.Velocity.X < 0
                if fam.Velocity:Length() > 0.5 then
                    mod:spritePlay(sprite, "Walk")
                else
                    mod:spritePlay(sprite, "Idle")
                end
            elseif d.state == "Okaeri" then
                if fam.Position:Distance(fam.Player.Position) > 60 then
                    if room:CheckLine(fam.Position, fam.Player.Position, 0, 999, false, false) then
                        fam.Velocity = mod:Lerp(fam.Velocity, (fam.Player.Position-fam.Position):Resized(speed), 0.3)
                    else
                        local real = mod:CatheryPathFinding(fam, fam.Player.Position, {
                            Speed = speed,
                            Accel = 0.6,
                            Threshhold = 999,
                        })
                        if not real then
                            if room:GetGridCollisionAtPos(fam.Position) > GridCollisionClass.COLLISION_NONE then
                                local dest = mod:GetClosestPosThatCanReachTarget(fam.Position, fam.Player.Position)
                                if dest then
                                    d.state = "Flying"
                                    d.launchedEnemyInfo = {zVel = -5.8, pos = true, landFunc = function()
                                        fam.SpriteOffset = Vector.Zero
                                        fam.PositionOffset = Vector.Zero
                                        d.state = "Okaeri"
                                    end, collision = 0, vel = (dest-fam.Position)*0.05}
                                else
                                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                end
                            else
                                if not d.triedClosestSpot then
                                    local testPath = Isaac.Spawn(mod.FF.BuriedFossilCrack.ID, mod.FF.BuriedFossilCrack.Var, 0, fam.Position, Vector.Zero, nil):ToNPC()
                                    testPath.Visible = false
                                    testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                    testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
                                    testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                                    d.closestSpot = mod:antiGolemFindSpot(fam, fam.Player.Position, testPath.Pathfinder, "Player")
                                    d.triedClosestSpot = true
                                    testPath:Remove()
                                else
                                    if d.closestSpot then
                                        if fam.Position:Distance(d.closestSpot) < 40 then
                                            local dest = mod:GetClosestPosThatCanReachTarget(fam.Position, fam.Player.Position)
                                            if dest then
                                                d.state = "Flying"
                                                d.launchedEnemyInfo = {zVel = -5.8, pos = true, landFunc = function()
                                                    fam.SpriteOffset = Vector.Zero
                                                    fam.PositionOffset = Vector.Zero
                                                    d.state = "Okaeri"
                                                end, collision = 0, vel = (dest-fam.Position)*0.05}
                                                d.closestSpot = nil
                                                d.triedClosestSpot = nil
                                            else
                                                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                            end
                                        else
                                            if room:CheckLine(fam.Position, d.closestSpot, 0, 999, false, false) then
                                                local targetvel = (d.closestSpot - fam.Position):Resized(speed)
                                                fam.Velocity = mod:Lerp(fam.Velocity, targetvel, 0.3)
                                            else
                                                local try = mod:CatheryPathFinding(fam, d.closestSpot, {
                                                    Speed = speed,
                                                    Accel = 0.6,
                                                    Threshhold = 999,
                                                })
                                                if not try then
                                                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                                end
                                            end
                                        end
                                    else
                                        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                    end
                                end
                            end
                        end
                    end
                else
                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                    d.state = "Idle"
                    sfx:Play(mod.Sounds.PikminCall, 0.35, 0, false, mod:getRoll(110,120,rng)/100)
                end

                sprite.FlipX = fam.Velocity.X < 0
                if fam.Velocity:Length() > 0.5 then
                    mod:spritePlay(sprite, "Walk")
                else
                    mod:spritePlay(sprite, "Idle")
                end
            elseif d.state == "Flying" then
                if fam.Coins > 15 and not d.launchedEnemyInfo then
                    d.launchedEnemyInfo = {zVel = 0, pos = true, landFunc = function()
                        fam.SpriteOffset = Vector.Zero
                        fam.PositionOffset = Vector.Zero
                        d.impactFrame = rng:RandomInt(2)+1
                        d.state = "Impact"
                        sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, mod:getRoll(120, 140, fam:GetDropRNG())/100)
                        d.launchedEnemyInfo = {zVel = -2, pos = true, landFunc = function()
                            fam.SpriteOffset = Vector.Zero
                            fam.PositionOffset = Vector.Zero
                        end}
                    end,}
                end
                if fam:CollidesWithGrid() then
                    d.state = "Impact"
                    d.impactFrame = rng:RandomInt(2)+1
                    d.launchedEnemyInfo = {zVel = -0.6, pos = true, vel = fam.Velocity:Resized(6), extraFunc = function()
                        d.launchedEnemyInfo.vel = d.launchedEnemyInfo.vel*0.97
                    end, landFunc = function()
                        fam.SpriteOffset = Vector.Zero
                        fam.PositionOffset = Vector.Zero
                        d.launchedEnemyInfo = {zVel = -3, pos = true, landFunc = function()
                            fam.SpriteOffset = Vector.Zero
                            fam.PositionOffset = Vector.Zero
                        end}
                        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                    end,}
                    sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, mod:getRoll(120, 140, fam:GetDropRNG())/100)
                    fam:GetSprite().FlipX = fam.Velocity.X < 0
                end

                mod:spritePlay(sprite, "InAir")
            elseif d.state == "Jump" then
                if sprite:IsFinished("Jump") then
                    fam.Coins = 0
                    d.launchedEnemyInfo = {vel = d.pikminJumpDir:Resized(12), zVel = -3, pos = true, extraFunc = function()
                        if d.launchedEnemyInfo.zVel > 0 then
                            fam.Coins = 0
                            d.yetToLandPikmin = true
                            d.launchedEnemyInfo = nil
                        end
        
                        sprite.FlipX = fam.Velocity.X < 0
                    end,}
                    sfx:Play(mod.Sounds.PikminThrow, 0.55, 0, false, 1)
                    sfx:Stop(mod.Sounds.PikminLift)
                    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
                    d.state = "Flying"
                    d.closestSpot = nil
                    d.triedClosestSpot = nil
                else
                    mod:spritePlay(sprite, "Jump")
                end

                fam.Velocity = Vector.Zero
            elseif d.state == "Impact" then
                if sprite:IsFinished("Impact" .. d.impactFrame) then
                    d.state = "Okaeri"
                    fam.Coins = 0
                else
                    mod:spritePlay(sprite, "Impact" .. d.impactFrame)
                end

                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.15)
            end
        else --sproingo
            local speed = 7.2
            if d.state == "Idle" then
                local walk = true
                if sprite:IsEventTriggered("Land") then
                    sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.25, 0, false, mod:getRoll(155, 180, rng)/100)
                    d.pikminHopped = nil
                elseif sprite:IsEventTriggered("Jump") then
                    d.pikminHopped = true
                end
                if fam.Position:Distance(fam.Player.Position) < 50 then
                    if sprite:GetAnimation() == "Idle" or (sprite:IsPlaying("Walk") and sprite:GetFrame() > 17) then
                        walk = nil
                    end
                end

                sprite.FlipX = fam.Velocity.X < 0

                if d.pikminHopped then
                    if room:CheckLine(fam.Position, fam.Player.Position, 0, 999, false, false) then
                        fam.Velocity = mod:Lerp(fam.Velocity, (fam.Player.Position-fam.Position):Resized(speed), 0.3)
                    else
                        local real = mod:CatheryPathFinding(fam, fam.Player.Position, {
                            Speed = speed,
                            Accel = 0.6,
                            Threshhold = 999,
                        })
                        if not real then
                            if room:GetGridCollisionAtPos(fam.Position) > GridCollisionClass.COLLISION_NONE then
                                local dest = mod:GetClosestPosThatCanReachTarget(fam.Position, fam.Player.Position)
                                if dest then
                                    d.state = "Flying"
                                    d.launchedEnemyInfo = {zVel = -5.8, pos = true, landFunc = function()
                                        fam.SpriteOffset = Vector.Zero
                                        fam.PositionOffset = Vector.Zero
                                        d.state = "Idle"
                                    end, collision = 0, vel = (dest-fam.Position)*0.05}
                                end
                            else
                                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                walk = nil
                            end
                        end
                    end
                else
                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                end

                if walk then
                    mod:spritePlay(sprite, "Walk")
                else
                    sprite:Play("Idle", true)
                end
            elseif d.state == "Rogue" then
                if not d.target or not mod:superExists(d.target) then
                    local target = PikminRandomVisibleEnemy(fam.Position, 999, nil, true)
                    if not target then
                        target = (mod.FindRandomEnemy(fam.Position, nil, true))
                        if not target then
                            d.state = "Idle"
                        end
                    end
                    d.target = target
                end

                local walk = true
                local JUMP
                if d.target then
                    if sprite:IsEventTriggered("Land") then
                        sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.25, 0, false, mod:getRoll(155, 180, rng)/100)
                        d.pikminHopped = nil
                    elseif sprite:IsEventTriggered("Jump") then
                        d.pikminHopped = true
                    end
                    if (fam.Position:Distance(d.target.Position) < 50 and fam.Coins > 100) or (fam.Coins > 120 and not d.pikminHopped) then
                        JUMP = true
                    end
                    if fam.Position:Distance(fam.Player.Position) < 60 then
                        d.state = "Idle"
                        sfx:Play(mod.Sounds.PikminCall, 1, 0, false, 1)
                    end

                    sprite.FlipX = fam.Velocity.X < 0

                    if d.pikminHopped then
                        if room:CheckLine(fam.Position, d.target.Position, 0, 999, false, false) then
                            fam.Velocity = mod:Lerp(fam.Velocity, (d.target.Position-fam.Position):Resized(speed), 0.3)
                        else
                            local real = mod:CatheryPathFinding(fam, fam.Player.Position, {
                                Speed = speed,
                                Accel = 0.6,
                                Threshhold = 999,
                            })
                            if not real then
                                if room:GetGridCollisionAtPos(fam.Position) > GridCollisionClass.COLLISION_NONE then
                                    local dest = mod:GetClosestPosThatCanReachTarget(fam.Position, fam.Player.Position)
                                    if dest then
                                        d.state = "Flying"
                                        d.launchedEnemyInfo = {zVel = -5.8, pos = true, landFunc = function()
                                            fam.SpriteOffset = Vector.Zero
                                            fam.PositionOffset = Vector.Zero
                                            d.state = "Idle"
                                        end, collision = 0, vel = (dest-fam.Position)*0.05}
                                    end
                                else
                                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                                    walk = nil
                                end
                            end
                        end
                    else
                        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                    end
                else
                    walk = nil
                    fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                end

                if walk and not JUMP then
                    mod:spritePlay(sprite, "Walk")
                else
                    sprite:Play("Idle", true)
                end

                if JUMP then
                    d.state = "Jump2"
                end
            elseif d.state == "Flying" then
                if fam:CollidesWithGrid() then
                    sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, mod:getRoll(120, 140, fam:GetDropRNG())/100)

                    d.state = "Impact"
                    d.impactFrame = rng:RandomInt(2)+1
                    d.pikminNextState = "Rogue"
                    d.launchedEnemyInfo = {zVel = -3, pos = true, extraFunc = function()
                        d.launchedEnemyInfo.vel = d.launchedEnemyInfo.vel*0.97
                    end, vel = (fam.Velocity):Resized(6), landFunc = function()
                        fam.SpriteOffset = Vector.Zero
                        fam.PositionOffset = Vector.Zero
                        d.launchedEnemyInfo = {zVel = -0.6, pos = true, landFunc = function()
                            fam.SpriteOffset = Vector.Zero
                            fam.PositionOffset = Vector.Zero
                        end}
                        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                    end,}
                end

                mod:spritePlay(sprite, "InAir")
            elseif d.state == "Roll" then
                if fam:CollidesWithGrid() then
                    local target = PikminRandomVisibleEnemy(fam.Position, 999, d.pikminLastHit)
                    if target then
                        d.rollDir = (target.Position-fam.Position)
                    else
                        d.rollDir = fam.Velocity
                    end
                    sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, mod:getRoll(120, 140, fam:GetDropRNG())/100)

                    if d.rollCount > 0 then
                        d.rollCount = d.rollCount-1
                    else
                        d.state = "Impact"
                        d.impactFrame = rng:RandomInt(2)+1
                        d.pikminNextState = "Rogue"
                        d.rollCount = nil
                        d.launchedEnemyInfo = {zVel = -3, pos = true, extraFunc = function()
                            d.launchedEnemyInfo.vel = d.launchedEnemyInfo.vel*0.97
                        end, vel = (fam.Velocity):Resized(6), landFunc = function()
                            fam.SpriteOffset = Vector.Zero
                            fam.PositionOffset = Vector.Zero
                            d.launchedEnemyInfo = {zVel = -0.6, pos = true, landFunc = function()
                                fam.SpriteOffset = Vector.Zero
                                fam.PositionOffset = Vector.Zero
                            end}
                            fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                        end,}
                    end
                end

                fam.Velocity = mod:Lerp(fam.Velocity, d.rollDir:Resized(12), 0.3)
                sprite.FlipX = fam.Velocity.X < 0
                mod:spritePlay(sprite, "InAir")
            elseif d.state == "Jump" then
                if sprite:IsFinished("Jump") then
                    sfx:Play(mod.Sounds.PikminThrow, 0.55, 0, false, 1)
                    sfx:Stop(mod.Sounds.PikminLift)
                    d.closestSpot = nil
                    d.triedClosestSpot = nil
                    d.state = "Roll"
                    d.rollDir = d.pikminJumpDir
                    d.pikminLastHit = {}
                    d.rollCount = 3
                else
                    mod:spritePlay(sprite, "Jump")
                end

                fam.Velocity = Vector.Zero
            elseif d.state == "Jump2" then
                if not d.target or not mod:superExists(d.target) then
                    d.target = nil
                    d.state = "Rogue"
                end

                if sprite:IsFinished("Jump") then
                    d.state = "Flying"
                    d.closestSpot = nil
                    d.triedClosestSpot = nil

                    local vel = (d.target.Position-fam.Position)*0.1
                    if vel:Length() > 15 then
                        vel = vel:Resized(15)
                    end
                    d.launchedEnemyInfo = {zVel = -3.6, pos = true, landFunc = function()
                        fam.SpriteOffset = Vector.Zero
                        fam.PositionOffset = Vector.Zero
                        d.state = "Rogue"
                    end, collision = -30, vel = vel}
                else
                    mod:spritePlay(sprite, "Jump")
                end

                fam.Velocity = Vector.Zero
            elseif d.state == "Impact" then
                if sprite:IsFinished("Impact" .. d.impactFrame) then
                    d.state = d.pikminNextState
                    d.pikminNextState = nil
                    d.pikminLastHit = nil
                    fam.Coins = 0
                else
                    mod:spritePlay(sprite, "Impact" .. d.impactFrame)
                end

                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.15)
            end
        end
    end
end, mod.ITEM.FAMILIAR.BRICKMIN)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, coll, low)
    if coll:ToNPC() and not mod:isFriend(coll) then
        coll = coll:ToNPC()
        local d = fam:GetData()
        local rng = fam:GetDropRNG()
        local level = game:GetLevel():GetAbsoluteStage()
        if fam.SubType == 1 and d.state == "Flying" then
            if coll:IsActiveEnemy() and coll:IsVulnerableEnemy() then
                local num = 200*(fam.Player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND)+1)
                mod.AddBruise(coll, fam.Player, num, 1, 1)
                coll:TakeDamage((fam.Player.Damage or 5)*3+3*level, 0, EntityRef(fam.Player), 0)
                d.state = "Impact"
                d.impactFrame = rng:RandomInt(2)+1
                fam.Velocity = (fam.Position-coll.Position):Resized(6)
                d.launchedEnemyInfo = {zVel = -3, pos = true, extraFunc = function()
                    d.launchedEnemyInfo.vel = d.launchedEnemyInfo.vel*0.97
                end, vel = (fam.Position-coll.Position):Resized(6), landFunc = function()
                    fam.SpriteOffset = Vector.Zero
                    fam.PositionOffset = Vector.Zero
                    d.launchedEnemyInfo = {zVel = -0.6, pos = true, landFunc = function()
                        fam.SpriteOffset = Vector.Zero
                        fam.PositionOffset = Vector.Zero
                    end}
                    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                end,}
                sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, mod:getRoll(120, 140, rng)/100)
                fam:GetSprite().FlipX = fam.Velocity.X < 0
            end
        elseif fam.SubType > 1 then
            if d.pikminLastHit and d.pikminLastHit[coll.InitSeed] then
                return true
            elseif d.state == "Roll" then
                d.pikminLastHit[coll.InitSeed] = true
                local target = PikminRandomVisibleEnemy(fam.Position, 999, d.pikminLastHit)
                if target then
                    d.rollDir = (target.Position-fam.Position)
                else
                    d.rollDir = Vector(0,1):Rotated(rng:RandomInt(360))
                end
                sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, mod:getRoll(120, 140, fam:GetDropRNG())/100)
                coll:TakeDamage((fam.Player.Damage or 5)+3*level, 0, EntityRef(fam.Player), 0)

                if d.rollCount > 0 then
                    d.rollCount = d.rollCount-1
                else
                    d.state = "Impact"
                    d.pikminNextState = "Rogue"
                    d.impactFrame = rng:RandomInt(2)+1
                    d.rollCount = nil
                    d.launchedEnemyInfo = {zVel = -3, pos = true, extraFunc = function()
                        d.launchedEnemyInfo.vel = d.launchedEnemyInfo.vel*0.97
                    end, vel = (fam.Position-coll.Position):Resized(6), landFunc = function()
                        fam.SpriteOffset = Vector.Zero
                        fam.PositionOffset = Vector.Zero
                        d.launchedEnemyInfo = {zVel = -0.6, pos = true, landFunc = function()
                            fam.SpriteOffset = Vector.Zero
                            fam.PositionOffset = Vector.Zero
                        end}
                        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                    end,}
                end
            elseif d.state == "Flying" then
                sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, mod:getRoll(120, 140, fam:GetDropRNG())/100)
                coll:TakeDamage((fam.Player.Damage or 5)+3*level, 0, EntityRef(fam.Player), 0)

                d.state = "Impact"
                d.pikminNextState = "Rogue"
                d.impactFrame = rng:RandomInt(2)+1
                d.launchedEnemyInfo = {zVel = -3, pos = true, extraFunc = function()
                    d.launchedEnemyInfo.vel = d.launchedEnemyInfo.vel*0.97
                end, vel = (fam.Position-coll.Position):Resized(6), landFunc = function()
                    fam.SpriteOffset = Vector.Zero
                    fam.PositionOffset = Vector.Zero
                    d.launchedEnemyInfo = {zVel = -0.6, pos = true, landFunc = function()
                        fam.SpriteOffset = Vector.Zero
                        fam.PositionOffset = Vector.Zero
                    end}
                    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                end,}
            end
        end
    end
end, mod.ITEM.FAMILIAR.BRICKMIN)

function mod:GetClosestPosThatCanReachTarget(position, targetPos)
    local room = game:GetRoom()
    if room:GetGridCollisionAtPos(targetPos) > GridCollisionClass.COLLISION_NONE then return end
	local size = room:GetGridSize()
    local dist = 9999
    local chosen
    for i=0,size do
        local pos = room:GetGridPosition(i)
        local coll = room:GetGridCollision(i)
        if coll == GridCollisionClass.COLLISION_NONE and pos:Distance(position) < dist then
            local testPath = Isaac.Spawn(mod.FF.BuriedFossilCrack.ID, mod.FF.BuriedFossilCrack.Var, 0, pos, Vector.Zero, nil):ToNPC()
			testPath.Visible = false
			testPath:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			testPath:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
			testPath.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            if testPath.Pathfinder:HasPathToPos(targetPos, false) then
                chosen = pos
                dist = pos:Distance(position)
            end
            testPath:Remove()
        end
    end
    return chosen
end