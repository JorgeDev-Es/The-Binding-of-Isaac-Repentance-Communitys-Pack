local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero

function mod:ang360(val)
	if val < 0 then
		val = val + 360
	end
	return val
end

--saggingsuckerai
function mod:saggerAI(npc)
	local sprite = npc:GetSprite();
	local d = npc:GetData();
	local target = npc:GetPlayerTarget()
	local r = npc:GetDropRNG()
	local isSpit = (npc.Variant == mod.FF.SaggingSpit.Var)

	--local ang = mod:ang360((target.Position - npc.Position):GetAngleDegrees())
	--Isaac.ConsoleOutput(ang  .. "\n")

	if not d.init then
		d.state = "idle"
		d.init = true
		d.speed = 4
		if isSpit then
			npc.SplatColor = mod.ColorGurgleGibs
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
		npc.CollisionDamage = 0
	end

	if d.state == "idle" then
		mod:spritePlay(sprite, "Idle")

		if target.Position.X > npc.Position.X then
			sprite.FlipX = true
		else
			sprite.FlipX = false
		end

		local targpos = mod:confusePos(npc, target.Position + (target.Velocity * 10))
		local targvel = mod:reverseIfFear(npc, (targpos - npc.Position):Resized(d.speed))
		npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.25)

		if d.speed < 8 then
			d.speed = d.speed + 0.03
		end

		if npc.StateFrame > 6 and not mod:isScareOrConfuse(npc) and not mod.anyPlayerHas(CollectibleType.COLLECTIBLE_SKATOLE) then
			if npc.Position:Distance(target.Position) < 80 then
				d.state = "chargestart"
				d.follow = true
				if sprite.FlipX then
					d.dirX = -1
				else
					d.dirX = 1
				end
				if npc.Position.Y > target.Position.Y then
					d.dirY = 1
					if sprite.FlipX then
						sprite.FlipX = false
					else
						sprite.FlipX = true
					end
				else
					d.dirY = -1
				end
			end
		end

	elseif d.state == "chargestart" then
		mod:spritePlay(sprite, "Shoot")
		if d.follow then
			local targpos = target.Position + (Vector(d.dirX, d.dirY) * 80)
			local targvel = (targpos - npc.Position):Resized(8)
			npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.25)
		else
			npc.Velocity = npc.Velocity * 0.7
		end
		if sprite:IsEventTriggered("shoot") then
			d.state = "charge"
			d.movevec = Vector(d.dirX * d.dirY * -1, -1):Resized(10)
			npc.Velocity = d.movevec
			npc:PlaySound(mod.Sounds.ShotgunBlast,1,0,false,math.random(7,9)/10)
			if isSpit then
				d.gasspeed = 20
			end
			npc:Update()
		end
	elseif d.state == "charge" then
		npc.Velocity = mod:Lerp(npc.Velocity, d.movevec, 0.3)
		local params = ProjectileParams()
		local shootvec = Vector(d.dirX * d.dirY, 1):Resized(10)
		if isSpit then
			if npc.FrameCount % 2 == 0 then
				local cloud = Isaac.Spawn(1000, EffectVariant.SMOKE_CLOUD, 0, npc.Position, shootvec:Resized(d.gasspeed), npc):ToEffect()
				cloud.SpriteScale = Vector(0.7,0.7)
				cloud:SetTimeout(240)
				d.gasspeed = d.gasspeed - 2
			end
			if npc.FrameCount % 3 == 0 then
				params.Color = mod.ColorIpecacProper
				params.Scale = 0.5
				params.FallingSpeedModifier = -2
				params.FallingAccelModifier = 1
				mod:SetGatheredProjectiles()
				npc:FireProjectiles(npc.Position, shootvec:Rotated(mod:RandomInt(-20,20)), 0, params)
				for _, proj in pairs(mod:GetGatheredProjectiles()) do
					proj:GetData().projType = "miniExplosion"
				end
			end
		else
			for i = 1, math.random(3) do
				npc:FireProjectiles(npc.Position, shootvec:Rotated(-20 + math.random(40)), 0, params)
			end
		end


		if sprite:IsEventTriggered("shootend") then
			d.state = "chargeend"
			npc.StateFrame = 0
		end

	elseif d.state == "chargeend" then
		if sprite:IsFinished("Shoot") then
			mod:spritePlay(sprite, "Idle")
		end
		if isSpit then
			npc.Velocity = npc.Velocity * 0.85
		else
			npc.Velocity = npc.Velocity * 0.95
		end

		if npc.StateFrame > 10 then
			d.state = "idle"
			npc.StateFrame = 0
			d.speed = 4
		end

	end
	npc.SpriteOffset = Vector(0,-20)
end

function mod:MiniExplodeProjDeath(projectile, data)
	game:BombExplosionEffects(projectile.Position, 0.5, 0, projectile.Color, projectile.SpawnerEntity, projectile.Scale, true, true, DamageFlag.DAMAGE_EXPLOSION)
end