local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

--0 - black, 1 = red, 2 = yellow, 3 = green

function mod:pocketRocketOnFireTear(player, tear, isLudo, ignore)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.POCKET_ROCKIT) then
        local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 10, 0.15)*100

        if rng:RandomInt(100) < chance and not ignore then
            local dir = nil
			if isLudo and not game:GetRoom():IsClear() then
				dir = tear.Position - player.Position
			elseif not isLudo and tear.CanTriggerStreakEnd then
				dir = tear.Velocity
			end
			if dir ~= nil then mod:firePocketRocketTear(player, tear, dir, isLudo) end
        end
	end
end

function mod:firePocketRocketTear(player, tear, dir, isLudo, spawnNew)
    local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
    sfx:Play(SoundEffect.SOUND_ROCKET_LAUNCH_SHORT, 0.7, 0, false, 1.6)
	if spawnNew then
		local newTear = player:FireTear(player.Position, dir:Resized(6.6*player.ShotSpeed), false, true, false, player, 1)
		newTear:ChangeVariant(mod.FF.PocketRockitTear.Var)
        local data = newTear:GetData()
        local sprite = newTear:GetSprite()
        data.originalColor = newTear.Color
        newTear.Color = Color(1,1,1,1,0,0,0)
        newTear.Scale = 1
        data.pocketRocket = rng:RandomInt(4)
        sprite:ReplaceSpritesheet(0, "gfx/projectiles/projectile_rockit" .. data.pocketRocket .. ".png")
        sprite:LoadGraphics()
	else
		if isLudo then
			tear = player:FireTear(player.Position, dir:Resized(6.6*player.ShotSpeed), false, true, false, player, 1)
        else
            tear.Velocity = tear.Velocity*0.66
        end
		tear:ChangeVariant(mod.FF.PocketRockitTear.Var)
        local data = tear:GetData()
        local sprite = tear:GetSprite()
        data.originalColor = tear.Color
        tear.Color = Color(1,1,1,1,0,0,0)
        tear.Scale = 1
        data.pocketRocket = rng:RandomInt(4)
        sprite:ReplaceSpritesheet(0, "gfx/projectiles/projectile_rockit" .. data.pocketRocket .. ".png")
        sprite:LoadGraphics()
	end
end

function mod:pocketRocketUpdate(player, data)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.POCKET_ROCKIT) then
        data.thisIsDUMBPocketRocket = {}
        for _, enemy in ipairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
            if enemy:ToNPC() and not (enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
                table.insert(data.thisIsDUMBPocketRocket, enemy)
            end
        end
    end
end

--Danial effectively asked for this
FiendFolio.AddItemPickupCallback(function(player, added)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.POCKET_ROCKIT) then
        if Options.Filter then
            Options.Filter = false
        end
    end
end, nil, CollectibleType.COLLECTIBLE_20_20)

function mod.pocketRocketTear(v, d)
    --if v.Variant ~= mod.FF.PocketRockitTear.Var then return end

    if d.pocketRocket then
        local room = game:GetRoom()
        local sprite = v:GetSprite()
        sprite.Rotation = v.Velocity:GetAngleDegrees()
        v.FallingAcceleration = 0
        v.FallingSpeed = 0
        d.Height = v.Height
        d.tearFlags = v.TearFlags

        if v.SpawnerEntity and v.SpawnerEntity:ToPlayer() then
            local d2 = v.SpawnerEntity:GetData()
            local enemyList = d2.thisIsDUMBPocketRocket or Isaac.FindInRadius(v.Position, 500, EntityPartition.ENEMY)
            local dist = 500
            local foundTarget = false
            local shoot = false

            for _,enemy in ipairs(enemyList) do
                if enemy.Position:Distance(v.Position) < dist and room:CheckLine(enemy.Position, v.Position, 3, 0, false, false) then
                    d.pocketRocketTarget = enemy
                    foundTarget = true
                    dist = enemy.Position:Distance(v.Position)
                    if dist < 200 then
                        shoot = true
                    end
                end
            end
            if foundTarget == false then
                d.pocketRocketTarget = nil
            end

            if d.pocketRocketTarget then
                local tVel = (d.pocketRocketTarget.Position-v.Position)
                local difference = mod:GetAngleDifference(v.Velocity, tVel)
                if difference < 120 then
                    v.Velocity = v.Velocity:Rotated(-4)
                elseif difference > 240 then
                    v.Velocity = v.Velocity:Rotated(4)
                end

                if shoot and v.FrameCount % 8 == 0 then
                    local tear = Isaac.Spawn(2, 0, 0, v.Position, (d.pocketRocketTarget.Position-v.Position):Resized(10), v):ToTear()
                    tear.Scale = 0.2
                    tear.CollisionDamage = v.CollisionDamage*0.35
                    if d.tearFlags then tear.TearFlags = d.tearFlags end
                    tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                    tear.Color = d.originalColor or Color(1,1,1,1,0,0,0)
                end
            end
        end

        if v.FrameCount % 6 == 0 then
            local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, v.Position, -v.Velocity:Resized(1)+RandomVector()*math.random(1,2)/2, v)
            smoke:GetData().longonly = true
            smoke.SpriteScale = Vector(0.3, 0.3)
            smoke.Color = Color(0.6, 0.6, 0.6, 0.6, 0, 0, 0)
            smoke.SpriteOffset = Vector(0, v.Height*0.8)
            smoke:Update()
        elseif v.FrameCount % 9 == 0 then
            local ember = Isaac.Spawn(1000, 66, 0, v.Position, -v.Velocity:Resized(1)+RandomVector()*math.random(1,2)/2, v)
            ember.SpriteOffset = Vector(0, v.Height*0.8)
            ember:Update()
        end
    elseif d.tearType == "pocketRocketBlack" then
        local targetpos = d.originalPos+d.originalDir:Rotated(v.FrameCount*6*(d.pocketRocketOrient or 1)):Resized(d.originalDir:Length()*(math.min(16, v.FrameCount)))
		v.Velocity = targetpos-v.Position

		if v.FrameCount < 100 then
			v.FallingAcceleration = 0
            v.FallingSpeed = 0
		end
    elseif d.tearType == "pocketRocketRed" then
        v.Velocity = v.Velocity*0.75

        if v.FrameCount < 100 then
			v.FallingAcceleration = 0
            v.FallingSpeed = 0
		end
    elseif d.tearType == "pocketRocketGreen" then
        v.Velocity = v.Velocity:Rotated(11*(d.pocketRocketOrient or 1))

        if v.FrameCount < 70 then
			v.FallingAcceleration = 0
            v.FallingSpeed = 0
		end
    end
end

function mod:pocketRocketTearRemove(v, d)
    if v.Variant ~= mod.FF.PocketRockitTear.Var then return end

    if d.pocketRocket then
        local rng = v:GetDropRNG()
        sfx:Stop(SoundEffect.SOUND_TEARIMPACTS)
        sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.5, 0, false, 3)
        local impact = Isaac.Spawn(1000, 97, 0, v.Position, Vector.Zero, v)
        impact.SpriteScale = Vector(0.7, 0.7)
        impact.SpriteOffset = Vector(0, d.Height or 0)

        for i=1,2 do
            local part = Isaac.Spawn(1000, 98, 0, v.Position, RandomVector()*math.random(3), v)
            local color = Color(0.6, 0.6, 1, 1, 0, 0, 0)
            color:SetColorize(1, 1, 1, 1)
            part.Color = color
        end

        local dam = v.CollisionDamage*0.35

        if d.pocketRocket == 0 then
            local randOrient = rng:RandomInt(360)
            local orient = 1-rng:RandomInt(2)*2
            for i=1,6 do
                local tear = Isaac.Spawn(2, 0, 0, v.Position, Vector(0,6):Rotated(i*60+randOrient), v):ToTear()
                local d2 = tear:GetData()
                d2.originalPos = v.Position
                d2.originalDir = Vector(0,6):Rotated(i*60+randOrient)
                d2.tearType = "pocketRocketBlack"
                if d.tearFlags then tear.TearFlags = d.tearFlags end
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                tear.Scale = 0.65+0.35*(i%2)
                tear.CollisionDamage = dam
                d2.pocketRocketOrient = orient
                tear.Color = d.originalColor or Color(1,1,1,1,0,0,0)
            end
        elseif d.pocketRocket == 1 then
            local vel = 4
            for i=-30,30,30 do
                local ang = 30
                local newVel = vel
                if i ~= 0 then
                    newVel = vel/math.cos(math.rad(ang))
                end
                local tear = Isaac.Spawn(2, 0, 0, v.Position, v.Velocity:Rotated(-180+i):Resized(newVel), v):ToTear()
                local d2 = tear:GetData()
                d2.tearType = "pocketRocketRed"
                if d.tearFlags then tear.TearFlags = d.tearFlags end
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                tear.Scale = 0.7
                tear.CollisionDamage = dam
                tear.Color = d.originalColor or Color(1,1,1,1,0,0,0)
            end
            for i=-15,15,30 do
                local ang = 15
                local newVel = vel*0.75
                if i ~= 0 then
                    newVel = vel*0.75/math.cos(math.rad(ang))
                end
                local tear = Isaac.Spawn(2, 0, 0, v.Position, v.Velocity:Rotated(i):Resized(newVel), v):ToTear()
                local d2 = tear:GetData()
                d2.tearType = "pocketRocketRed"
                if d.tearFlags then tear.TearFlags = d.tearFlags end
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                tear.Scale = 0.6
                tear.CollisionDamage = dam
                tear.Color = d.originalColor or Color(1,1,1,1,0,0,0)
            end
            for i=-30,30,60 do
                local ang = 30
                local newVel = vel+2
                newVel = (vel+2)/math.cos(math.rad(ang))
                local tear = Isaac.Spawn(2, 0, 0, v.Position, v.Velocity:Rotated(-180+i):Resized(newVel), v):ToTear()
                local d2 = tear:GetData()
                d2.tearType = "pocketRocketRed"
                if d.tearFlags then tear.TearFlags = d.tearFlags end
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                tear.Scale = 0.6
                tear.CollisionDamage = dam
                tear.Color = d.originalColor or Color(1,1,1,1,0,0,0)
            end
            for i=0,1 do
                local tear = Isaac.Spawn(2, 0, 0, v.Position, v.Velocity:Rotated(i):Resized(vel+3+5*i), v):ToTear()
                local d2 = tear:GetData()
                d2.tearType = "pocketRocketRed"
                if d.tearFlags then tear.TearFlags = d.tearFlags end
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                tear.Scale = 0.7-0.3*i
                tear.CollisionDamage = dam
                tear.Color = d.originalColor or Color(1,1,1,1,0,0,0)
            end
        elseif d.pocketRocket == 2 then
            for i=1,9 do
                local tear = Isaac.Spawn(2, 0, 0, v.Position, Vector(0,1+rng:RandomInt(15)/3):Rotated(rng:RandomInt(360)), v):ToTear()
                tear.Scale = 0.3+rng:RandomInt(40)/100
                tear.CollisionDamage = dam
                tear.FallingSpeed = -8 - rng:RandomInt(20)
				tear.FallingAcceleration = 1.1
				tear.Height = -10
                if d.tearFlags then tear.TearFlags = d.tearFlags end
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                tear.Color = d.originalColor or Color(1,1,1,1,0,0,0)
            end
        elseif d.pocketRocket == 3 then
            local rand = 5+rng:RandomInt(4)
            local rangle = rng:RandomInt(360)
            local orient = 1-rng:RandomInt(2)*2
            for i=1,rand do
                local rangle2 = 360/rand
                local tear = Isaac.Spawn(2, 0, 0, v.Position, Vector(0,7):Rotated(i*rangle2+rangle), v):ToTear()
                local d2 = tear:GetData()
                d2.tearType = "pocketRocketGreen"
                if d.tearFlags then tear.TearFlags = d.tearFlags end
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
                tear.Scale = 0.75
                tear.CollisionDamage = dam
                d2.pocketRocketOrient = orient
                tear.Color = d.originalColor or Color(1,1,1,1,0,0,0)
            end
        end
    end
end


function mod:pocketRocketOnFireLaser(player, laser)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.POCKET_ROCKIT) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 10, 0.15)*100

		if rng:RandomInt(100) < chance then
			FiendFolio.scheduleForUpdate(function()
				local vec = Vector(10, 0)
				if laser.Velocity:Length() > 0 then
					vec = laser.Velocity:Resized(10)
				end

				mod:firePocketRocketTear(player, nil, vec:Rotated(laser.AngleDegrees), nil, true)
			end, 1)
		end
	end
end

function mod:pocketRocketOnFireKnife(player, knife)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.POCKET_ROCKIT) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 10, 0.15)*100

		if rng:RandomInt(100) < chance then
			mod:firePocketRocketTear(player, nil, Vector(1,0):Rotated(knife.Rotation), nil, true)
		end
	end
end

function mod:pocketRocketOnFireBomb(player, bomb)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.POCKET_ROCKIT) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.POCKET_ROCKIT)
        local chance = 10*mult+mod.XalumLuckBonus(player.Luck, 10, 0.15)*100

		if rng:RandomInt(100) < chance then
			mod:firePocketRocketTear(player, nil, bomb.Velocity, nil, true)
		end
	end
end