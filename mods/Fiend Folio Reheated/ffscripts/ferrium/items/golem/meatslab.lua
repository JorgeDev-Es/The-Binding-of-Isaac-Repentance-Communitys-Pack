local mod = FiendFolio

function mod:meatSlabUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.MEAT_SLAB) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.MEAT_SLAB)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.MEAT_SLAB)
		local heartNum = player:GetMaxHearts()/math.max(1,(player:GetHearts()+player:GetRottenHearts()))
		local frames = math.floor(15-math.min(12, heartNum*2))
		if player.FrameCount % frames == 0 then
			for i=0,1 do
				local newtear = Isaac.Spawn(2, 0, 0, player.Position, Vector(0,1+rng:RandomInt(15)/3):Rotated(rng:RandomInt(360)), player):ToTear()
				newtear.FallingSpeed = -8 - rng:RandomInt(20)
				newtear.FallingAcceleration = 1.1
				newtear.Height = -10
				newtear.CanTriggerStreakEnd = false
				newtear.CollisionDamage = player.Damage*mult
				newtear.Scale = math.min(1.5, player.Damage*mult/5.5)*mod:getRoll(90,110,rng)/100
				newtear:GetData().dontCollideBombs = true
				newtear:Update()
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, coll)
	if coll.Type == 4 and tear:GetData().dontCollideBombs then
		return true
	end
end)