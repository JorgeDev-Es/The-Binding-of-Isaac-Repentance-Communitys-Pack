local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()
local rng = RNG()


--Polycoria originally used a dummy effect to track the position of the cluster, but this was changed since a lot of items modify tear trajectory mid flight
function mod:PolycoriaOnFireTear(player, tear)
	if not player:GetData().TaintedArePolycoriaTearsSpawning then
		--local dummyeffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.DUMMY, 0, tear.Position, tear.Velocity, player)
		local tearstospawn = mod:RandomInt(5,8)
		player:GetData().TaintedArePolycoriaTearsSpawning = true
		tear:GetData().TaintedCorpseClusters = {}
		--table.insert(dummyeffect:GetData().corpseClusters, tear)
		--tear.Parent = dummyeffect
		tear:GetData().TaintedClusterParent = true
		for i = 1, tearstospawn do
			local newtear = player:FireTear(tear.Position, tear.Velocity, true, true, false, player, 1):ToTear()
			table.insert(tear:GetData().TaintedCorpseClusters, newtear)
			newtear.Parent = tear
			if tear.Parent and tear.Parent.Type ~= EntityType.ENTITY_PLAYER then
				newtear.Parent = tear.Parent
			end
			newtear:GetData().TaintedCluster = true
			newtear.CollisionDamage = (tear.CollisionDamage + mod:RandomInt(-3, 3)*rng:RandomFloat())*0.8
			if newtear.CollisionDamage < 0.1 then
				newtear.CollisionDamage = 0.1
			end
			newtear.Scale = newtear.Scale + (rng:RandomFloat()/2)*mod:RandomInt(-1, 1)
			newtear.Position = tear.Position + Vector(mod:RandomInt(-15, 15), mod:RandomInt(-15, 15))
			newtear.Color = tear.Color
			newtear.Height = tear.Height
			newtear:ClearTearFlags(TearFlags.TEAR_ORBIT, TearFlags.TEAR_OCCULT)
			
			if tear:GetData().TaintedArrowhead then
				newtear.Height = newtear.Height*2
				newtear.Velocity = newtear.Velocity*-1
			end
		end
		
		tear.Velocity = tear.Velocity * 1.2
		player:GetData().TaintedArePolycoriaTearsSpawning = false
	end
end

function mod:PolycoriaTearUpdate(tear, data)
    data.Angle = mod:RandomInt(0, 360)
	if tear.Parent then
		local parent = tear.Parent
		local room = game:GetRoom()
		local data = tear:GetData()
		
		if room:GetGridEntityFromPos(parent.Position+parent.Velocity) and not data.TaintedParentCollidedGrid and parent.Type == EntityType.ENTITY_TEAR and not parent:ToTear():HasTearFlags(TearFlags.TEAR_SPECTRAL) then
			data.TaintedParentCollidedGrid = true
		end
		
		if parent:Exists() then
			tear.TargetPosition = parent.Position + Vector.One:Resized(mod:RandomInt(30,40)):Rotated(data.Angle)
			local vec = tear.TargetPosition - tear.Position
			vec = vec:Resized(math.min(40, vec:Length()))
			if parent.Type == EntityType.ENTITY_TEAR then
				tear.Velocity = mod:Lerp(tear.Velocity, vec, 0.02)
			else
				tear.Velocity = mod:Lerp(tear.Velocity, vec, 0.04)
			end
		elseif not data.TaintedParentCollidedEnemy and data.TaintedParentCollidedGrid then
			tear.Velocity = parent.Velocity:Rotated(180 + mod:RandomInt(-60,60))*1.3
			sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
		end
	end
end

function mod:FireCluster(player, velocity, color, dmgmult, heightmult, position, parent)
	player:GetData().TaintedArePolycoriaTearsSpawning = true
    dmgmult = dmgmult or 1
	heightmult = heightmult or 1
    position = position or player.Position
    local tear = player:FireTear(position, velocity, false, false, false, player, mult)
    tear.Color = color or tear.Color
	tear.Height = tear.Height*heightmult
	tear.Scale = tear.Scale*dmgmult
	if parent then
		tear.Parent = parent
		tear:GetData().TaintedCluster = true
	end
	player:GetData().TaintedArePolycoriaTearsSpawning = false
	mod:PolycoriaOnFireTear(player, tear)
    return tear
end
