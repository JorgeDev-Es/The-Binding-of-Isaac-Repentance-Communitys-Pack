local mod = FiendFolio
local game = Game()

--THE COMBINATION time to copy and paste weeeeeeee

function mod:gayGarnetOnFireTear(player, tear, isLudo, ignorePlayerEffects)
	if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
		local chance = math.min(15+player.Luck+5*mult, 50)
        --[[if rng:RandomInt(100) < chance then
            tear:ChangeVariant(5)
            local td = tear:GetData()
            td.ApplyBurn = true
            td.ApplyBurnDuration = 60*secondHandMultiplier
            td.ApplyBurnDamage = player.Damage
            tear:Update()
		end

        chance = math.min(12 + player.Luck * 2, 30) * mult
        if rng:RandomInt(60) < chance then
            tear.Color = Color(0.7, 0.7, 1, 1, -0.1, -0.1, 0.1)
            tear.TearFlags = tear.TearFlags | TearFlags.TEAR_ICE | TearFlags.TEAR_SLOW
        end]]

        if rng:RandomInt(100) < chance and not ignorePlayerEffects and (not isLudo or not game:GetRoom():IsClear()) then
            local pos = tear.Position
            local vel = tear.Velocity:Resized(10) + player:GetTearMovementInheritance(player:GetAimDirection())
            if isLudo then
                pos = player.Position
                vel = (tear.Position - player.Position):Resized(10)
            end

            mod:firePeppermint(player, pos, vel, true)
        end
	end
end

--[[function mod:gayGarnetOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
		local chance = math.min(15+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			entity:AddBurn(EntityRef(player), 120*secondHandMultiplier, player.Damage*2)
		end

        chance = math.min(12 + player.Luck * 2, 30) * mult
        if rng:RandomInt(60) < chance then
            entity:AddSlowing(EntityRef(player), 60, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
			entity:AddEntityFlags(EntityFlag.FLAG_ICE)
			entity:GetData().PeppermintSlowed = true
        end
	end
end]]

function mod:gayGarnetOnFireKnife(player, knife)
    if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
		local chance = math.min(15+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
            mod:firePeppermint(player, knife.Position, Vector(10, 0):Rotated(knife.Rotation) + player:GetTearMovementInheritance(player:GetAimDirection()), true)
        end
    end
end

function mod:gayGarnetOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
		local chance = math.min(15+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
            mod:firePeppermint(player, bomb.Position, bomb.Velocity:Resized(10) + player:GetTearMovementInheritance(player:GetAimDirection()), true)
        end
			--[[bomb.Flags = bomb.Flags | TearFlags.TEAR_BURN
			
			local color = Color(1, 1, 1, 1, 0.25, 0, 0)
		    color:SetColorize(1, 0.3, 0.1, 1)
			bomb.Color = color
		end

        chance = math.min(12 + player.Luck * 2, 30) * mult
        if rng:RandomInt(60) < chance then
            bomb.Color = Color(0.7, 0.7, 1, 1, -0.1, -0.1, 0.1)
            bomb.Flags = bomb.Flags | TearFlags.TEAR_ICE | TearFlags.TEAR_SLOW
        end]]
	end
end

function mod:gayGarnetOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
		local chance = math.min(15+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			entity:AddBurn(EntityRef(player), 120*secondHandMultiplier, player.Damage*2)
		end

        chance = math.min(12 + player.Luck * 2, 30) * mult
        if rng:RandomInt(60) < chance then
            entity:AddSlowing(EntityRef(player), 60, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
			entity:AddEntityFlags(EntityFlag.FLAG_ICE)
			entity:GetData().PeppermintSlowed = true
        end
	end
end

function mod:gayGarnetOnFireLaser(player, laser)
    if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
        local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
        local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
        local chance = math.min(15+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
            FiendFolio.scheduleForUpdate(function()
                local vec = Vector(10, 0)
                if laser.Velocity:Length() > 0 then
                    vec = laser.Velocity:Resized(10)
                end
    
                mod:firePeppermint(player, laser.Position, vec:Rotated(laser.AngleDegrees) + player:GetTearMovementInheritance(player:GetAimDirection()), true)
            end, 1)
        end
    end
end

function mod:gayGarnetOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
		local chance = math.min(15+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			local data = creep:GetData()
			data.ApplyBurn = true
			data.ApplyBurnDuration = 120 * secondHandMultiplier
            data.ApplyBurnDamage = player.Damage*2

            local color = Color(1, 1, 1, 1, 0.25, 0, 0)
		    color:SetColorize(1, 0.3, 0.1, 1)
			data.FFAquariusColor = color
		end

        chance = math.min(12 + player.Luck * 2, 30) * mult
        if rng:RandomInt(60) < chance then
			local data = creep:GetData()

			data.ApplySapphicSapphireFreeze = true

			local color = Color(0.3, 0.7, 1, 1, -0.2, -0.1, 0.3)
			data.FFAquariusColor = color
        end
	end
end

function mod:gayGarnetOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
		local chance = math.min(15+player.Luck+5*mult, 50)
        --[[if rng:RandomInt(100) < chance then
			local data = target:GetData()
			data.ApplyBurn = true
			data.ApplyBurnDuration = 120 * secondHandMultiplier
            data.ApplyBurnDamage = player.Damage*2

            local color = Color(1, 1, 1, 1, 0.25, 0, 0)
		    color:SetColorize(1, 0.3, 0.1, 1)
			data.FFExplosionColor = color
		end

        chance = math.min(12 + player.Luck * 2, 30) * mult
        if rng:RandomInt(60) < chance then
			local data = target:GetData()

			data.ApplySapphicSapphireFreeze = true
        end]]

        if target.FrameCount == 1 and not target:GetData().firedGayGarnet then
            target:GetData().firedGayGarnet = true
            if rng:RandomInt(100) < chance then
                mod:firePeppermint(player, player.Position, (target.Position-player.Position):Resized(10) + player:GetTearMovementInheritance(player:GetAimDirection()), true)
            end
        end
	end
end

function mod:gayGarnetOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.GAY_GARNET)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.GAY_GARNET)
		local chance = math.min(15+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			entity:AddFear(EntityRef(player), 180 * secondHandMultiplier)
		end

        chance = math.min(12 + player.Luck * 2, 30) * mult
        if rng:RandomInt(60) < chance then
            entity:AddSlowing(EntityRef(player), 60, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
			entity:AddEntityFlags(EntityFlag.FLAG_ICE)
			entity:GetData().PeppermintSlowed = true
        end
	end
end