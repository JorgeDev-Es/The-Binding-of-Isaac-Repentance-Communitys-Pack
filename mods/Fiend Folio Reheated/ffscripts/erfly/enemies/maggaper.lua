local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:magnifierInit(npc,sub)
	local mode = FiendFolio.GetBits(sub, 0, 1)
	local delay = FiendFolio.GetBits(sub, 1, 8)
	if delay == 0 and mode == 0 then
		mod.MagnifierActiveInRoom = true
	end
end

local magCreatures = {
	[mod.FF.PaleGaper.Var] = true,
	[mod.FF.PaleHorf.Var] = true,
	[mod.FF.PaleClotty.Var] = true,
}

function mod:zapMagThings(npc)
	local erfEnemies = Isaac.FindByType(160)
	for _, ent in pairs(erfEnemies) do
		if magCreatures[ent.Variant] then
			local vec = (ent.Position - npc.Position)
			local laser = EntityLaser.ShootAngle(10, npc.Position, vec:GetAngleDegrees(), 7, Vector(0, -35), Isaac.GetPlayer())
			laser:SetMaxDistance(vec:Length())
			laser.CollisionDamage = 0
			laser.OneHit = true
			laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			laser.Mass = 0
			laser.Color = Color(1,1,1,0,1,1,1)
			laser:SetColor(Color(1,1,1,0.5,1,1,1), 7, 7, true, true)
		end
	end
end

function mod:magnifierAI(npc, sub, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local room = Game():GetRoom()

	if not d.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
		npc.TargetPosition = npc.Position
		d.init = true
		d.mode = FiendFolio.GetBits(sub, 0, 1)
		d.delay = FiendFolio.GetBits(sub, 1, 8)
		if d.delay > 0 or d.mode == 1 or room:IsClear() or mod.areRoomPressurePlatesPressed() then
			sprite:Play("Sleep", true)
		elseif d.delay == 0 and d.mode == 0 then
			mod:spritePlay(sprite, "Idle")
			mod.MagnifierActiveInRoom = true
		else
			sprite:Play("Activate", true)
		end
	end
	--print(mod.MagnifierActiveInRoom)

	if npc.TargetPosition then 
		npc.Position = npc.TargetPosition
		npc.Velocity = nilvector
	else
		npc.TargetPosition = npc.Position
	end

	if (d.mode == 0 and room:GetFrameCount() < d.delay * 15) or d.mode == 1 or room:IsClear() or mod.areRoomPressurePlatesPressed() then
		if sprite:IsFinished("Deactivate") then
			mod.MagnifierActiveInRoom = false
			mod:spritePlay(sprite, "Sleep")
		elseif not sprite:IsPlaying("Sleep") then
			mod:spritePlay(sprite, "Deactivate")
		end
		if sprite:IsEventTriggered("ToggleState") then
			mod.MagnifierActiveInRoom = false
		end	
		if d.mode == 1 then
			local modecheck
			local magFilter = function(position, candidate)
				if (candidate:GetData().GrimoireEnchanted 
                or mod:CheckIDInTable(candidate, FiendFolio.GrimoireBlacklist) 
                or mod:CheckIDInTable(candidate, FiendFolio.BadEnts) 
                or mod:CheckIDInTable(candidate, FiendFolio.HidingUnderwaterEnts) 
				or candidate.Type == 160 and magCreatures[candidate.Variant]) then
                	return false
				else
					return true
				end
			end
			local enemy = mod:GetAnyEnemy(magFilter)
			if not enemy then
				modecheck = true
			else
				--print(enemy.Type, enemy.Variant)
			end
			if modecheck then
				d.modeCount = d.modeCount or 0
				d.modeCount = d.modeCount + 1
				if d.modeCount > 1 then
					d.mode = 0
				end
			else
				d.modeCount = 0
			end
		end
	else
		if sprite:IsPlaying("Sleep") then
			mod:spritePlay(sprite, "Activate")
		end
		if not sprite:IsPlaying("Activate") then
			mod.MagnifierActiveInRoom = true
			mod:spritePlay(sprite, "Idle")
		elseif not sprite:IsPlaying("Idle") then
			mod:spritePlay(sprite, "Activate")
		end
		if sprite:IsEventTriggered("ToggleState") then
			mod.MagnifierActiveInRoom = true
			mod:zapMagThings(npc)
		end
	end
	
	room:SetGridPath(room:GetGridIndex(npc.Position), 3999)

	if npc:IsDead() then
		mod.MagnifierActiveInRoom = false
	end
end

function mod.magnifierNewRoom()
	mod.MagnifierActiveInRoom = false
end

local function changeMagScale(npc, big)
	local healthScale = 2
	local massScale = 3
	local d = npc:GetData()
	if big then
		npc.HitPoints = npc.HitPoints * healthScale
		npc.Mass = npc.Mass * massScale
		d.small = nil
		if npc.Variant == mod.FF.PaleClotty.Var then
			npc:SetSize(20, Vector(2,1), 12)
		else
			npc:SetSize(20, Vector.One, 12)
		end
	else
		npc.HitPoints = npc.HitPoints / healthScale
		npc.Mass = npc.Mass / massScale
		d.small = true
		npc:SetSize(13, Vector.One, 12)
	end
end

function mod:magGaperAI(npc, subt, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local path = npc.Pathfinder
    local room = game:GetRoom()

	if not d.init then
		d.init = true
		if var == mod.FF.PaleGaper.Var then
			if mod.MagnifierActiveInRoom then
				changeMagScale(npc, true)
			else
				d.small = true
			end
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end

	if d.growing then
		sprite:RemoveOverlay()
		if sprite:IsFinished("Magnify") then
			d.growing = nil
			d.chargeInitializing = nil
			d.charging = nil
		else
			mod:spritePlay(sprite, "Magnify")
		end
		if npc.StateFrame == 1 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 0.9)
		elseif npc.StateFrame == 5 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1)
			changeMagScale(npc, true)
		elseif npc.StateFrame == 9 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1.1)
		end		
	elseif d.shrinking then
		sprite:RemoveOverlay()
		if sprite:IsFinished("Shrink") then
			d.shrinking = nil
		else
			mod:spritePlay(sprite, "Shrink")
		end
		if npc.StateFrame == 1 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.9)
		elseif npc.StateFrame == 5 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.8)
			changeMagScale(npc, false)
		elseif npc.StateFrame == 9 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.7)
		end		
	elseif d.small then
		local speedboost = 1
		if d.charging then
			speedboost = 1.5
		end
		local directChasing
		if mod:isScare(npc) then
			local targetvel = (targetpos - npc.Position):Resized(-6 * speedboost)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
		elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
			local targetvel = (targetpos - npc.Position):Resized(4 * speedboost)
			npc.Velocity = mod:Lerp(npc.Velocity, targetvel,0.25)
			directChasing = true
		else
			path:FindGridPath(targetpos, 0.6  * speedboost, 900, true)
		end

		if npc.FrameCount > 1 and npc.Velocity:Length() > 0.1 then
			npc:AnimWalkFrame("SmallWalkHori","SmallWalkVert",0)
		else
			sprite:SetFrame("SmallWalkVert", 0)
		end
		if mod.MagnifierActiveInRoom then
			d.growing = true
			npc.StateFrame = 0
		end

		if d.charging then
			d.chargeInitializing = nil
			if not sprite:IsOverlayPlaying("SmallHeadChargeIntro") then
				mod:spriteOverlayPlay(sprite, "SmallHeadCharge")
			end
			if npc.StateFrame > 60 then
				d.charging = nil
			end
		else
			if d.chargeInitializing then
				if sprite:IsOverlayFinished("SmallHeadChargeIntro") then
					d.charging = true
					d.chargeInitializing = nil
				elseif sprite:GetOverlayFrame() >= 3 then
					d.charging = true
					d.chargeInitializing = nil
					npc.StateFrame = 0
					npc:PlaySound(SoundEffect.SOUND_ZOMBIE_WALKER_KID, 1, 0, false, math.random(90,110)/100)
				else
					mod:spriteOverlayPlay(sprite, "SmallHeadChargeIntro")
				end
			else
				sprite:SetOverlayFrame("SmallHead",0)
				if directChasing then
					if npc.StateFrame > 30 and math.random(5) == 1 then
						d.chargeInitializing = true
					end
				end
			end
		end
	else
		d.walkCycle = d.walkCycle or 0
		local moduloVal = d.walkCycle % 20
		local LerpVal = 0.1
		if moduloVal % 10 == 0 then
			LerpVal = 0.4
		elseif moduloVal % 10 == 7 then
			npc.Velocity = npc.Velocity * 0.9
			npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS,0.3,0,false,(math.random(70,90)+(npc.Velocity:Length()*5))/100)
			local vecOff = npc.Velocity:Rotated(90):Resized(5)
			if moduloVal % 20 == 10 then
				vecOff = vecOff * -1
			end
			local footprint = Isaac.Spawn(1000, 89, 0, npc.Position + vecOff, nilvector, npc)
			footprint.SpriteScale = footprint.SpriteScale * 0.5
			footprint:Update()
		else
			npc.Velocity = npc.Velocity * 0.97
		end

		if var == mod.FF.PaleGaper.Var then
			if npc:IsDead() or npc:HasMortalDamage() then
				npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
			end
			if not mod.MagnifierActiveInRoom then
				d.shrinking = true
				npc.StateFrame = 0
			end
		end

		if npc.FrameCount > 1 and (room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScareOrConfuse(npc)) then
			local speed = mod:reverseIfFear(npc, 8)
			npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position):Resized(speed), LerpVal)
			d.walkCycle = d.walkCycle + 1
			if not mod:isScareOrConfuse(npc) then
				d.seenTimer = 60
			end
			d.walktarg = nil
			npc.StateFrame = 0
		else
			d.seenTimer = d.seenTimer or 0
			if d.seenTimer > 0 then
				d.walktarg = nil
				if not room:CheckLine(npc.Position,targetpos,3,1,false,false) then
					d.seenTimer = d.seenTimer - 1
				end
				if path:HasPathToPos(targetpos) then
					--path:FindGridPath(targetpos, 1, 900, true)
					mod:CatheryPathFinding(npc, targetpos, {
						Speed = 8,
						Accel = LerpVal,
						GiveUp = true
					})
					d.walkCycle = d.walkCycle + 1
				else
					d.walkCycle = 0
					d.seenTimer = 0
					npc.StateFrame = 0
				end
			else
				if npc.StateFrame > 160 or ((not d.walktarg) and npc.StateFrame > 30) then
					d.walktarg = mod:FindRandomValidPathPosition(npc)
					npc.StateFrame = 0
				end
				if d.walktarg and npc.Position:Distance(d.walktarg) > 30 then
					d.walkCycle = d.walkCycle + 1
					if room:CheckLine(npc.Position,d.walktarg,0,1,false,false) then
						local targetvel = (d.walktarg - npc.Position):Resized(5)
						npc.Velocity = mod:Lerp(npc.Velocity, targetvel,LerpVal)
					else
						mod:CatheryPathFinding(npc, d.walktarg, {
							Speed = 5,
							Accel = LerpVal,
							GiveUp = true
						})
					end
				else
					d.walkCycle = 0
					npc.Velocity = npc.Velocity * 0.7
					npc.StateFrame = npc.StateFrame + 2
				end
			end
		end

		local spriteDir
		if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
			spriteDir = "Vert"
		else
			spriteDir = "Hori"
			if npc.Velocity.X > 0 then
				sprite.FlipX = false
			else
				sprite.FlipX = true
			end
		end
		if npc.Velocity:Length() > 0.1 then
			sprite:SetFrame("Walk" .. spriteDir, moduloVal)
		else
			sprite:SetFrame("Walk" .. spriteDir, 0)
		end

		for k,v in ipairs(mod.GetGridEntities()) do
			if v.Position:Distance(npc.Position + npc.Velocity) < 45 then
				if v.Desc.Type ~= GridEntityType.GRID_DOOR then
					v:Destroy()
				end
			end
		end
	end
end

function mod:paleGaperKill(npc)
	local d = npc:GetData()
	if d.small then
		if not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isLeavingStatusCorpse(npc)) then
			local spawned = Isaac.Spawn(mod.FF.PaleGusher.ID, mod.FF.PaleGusher.Var, 0, npc.Position, npc.Velocity, npc)
			spawned:ToNPC():Morph(spawned.Type, spawned.Variant, spawned.SubType, npc:ToNPC():GetChampionColorIdx())
			spawned.HitPoints = spawned.MaxHitPoints
			spawned:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

			if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
				spawned:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end

			npc:Remove()
		end
	end
end

function mod:paleHorfUpdate(npc, sub, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local path = npc.Pathfinder
    local room = game:GetRoom()

	if not d.init then
		d.init = true
		if var == mod.FF.PaleHorf.Var then
			if mod.MagnifierActiveInRoom then
				changeMagScale(npc, true)
			else
				d.small = true
			end
		end

		if d.small then
			sprite:Play("SmallAppear", true)
		else
			sprite:Play("BigAppear", true)
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end
	npc.Velocity = npc.Velocity * 0.7

	if d.growing then
		sprite:RemoveOverlay()
		if sprite:IsFinished("Magnify") then
			d.growing = nil
		else
			mod:spritePlay(sprite, "Magnify")
		end
		if npc.StateFrame == 1 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 0.9)
		elseif npc.StateFrame == 5 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1)
			changeMagScale(npc, true)
		elseif npc.StateFrame == 9 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1.1)
		end		
	elseif d.shrinking then
		sprite:RemoveOverlay()
		if sprite:IsFinished("Shrink") then
			d.shrinking = nil
		else
			mod:spritePlay(sprite, "Shrink")
		end
		if npc.StateFrame == 1 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.9)
		elseif npc.StateFrame == 5 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.8)
			changeMagScale(npc, false)
		elseif npc.StateFrame == 9 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.7)
		end		
	elseif d.small then
		if d.state == "idle" then
			if not sprite:IsPlaying("SmallAppear") then
				mod:spritePlay(sprite, "SmallShake")
			end
			if npc.StateFrame > 10 and room:CheckLine(npc.Position,targetpos,3,1,false,false) then
				d.state = "attack"
			end
		elseif d.state == "attack" then
			if sprite:IsFinished("SmallAttack") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,2,false,math.random(90,110)/100)
				local params = ProjectileParams()
				params.Scale = 1
				local vec = (target.Position - npc.Position):Normalized()
				npc:FireProjectiles(npc.Position, vec:Resized(10), 0, params)
				local cloud = Isaac.Spawn(1000,2,5,npc.Position,nilvector,npc):ToEffect()
				cloud:FollowParent(npc)
				cloud.SpriteOffset = Vector(0, -9) * npc.SpriteScale.X
				cloud.SpriteScale = Vector(0.8,0.8) * npc.SpriteScale.X
				cloud.DepthOffset = 10
				cloud.Color = Color(1,1,1,0.8,0.1,0.1,0.1)
				cloud:Update()

			else
				mod:spritePlay(sprite, "SmallAttack")
				npc.StateFrame = 0
			end
		else
			d.state = "idle"
			mod:spritePlay(sprite, "SmallAppear")
		end
		if mod.MagnifierActiveInRoom then
			d.growing = true
			d.state = nil
			npc.StateFrame = 0
		end
	else
		if d.state == "idle" then
			if not sprite:IsPlaying("BigAppear") then
				mod:spritePlay(sprite, "Shake")
			end
			if npc.StateFrame > 7 and room:CheckLine(npc.Position,targetpos,3,1,false,false) then
				d.state = "attack"
			end
		elseif d.state == "attack" then
			if sprite:IsFinished("Attack") then
				d.state = "idle"
				npc.StateFrame = 0
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_BLOODSHOOT,1,2,false,1)
				npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR,1,2,false,math.random(60,70)/100)
				local params = ProjectileParams()
				params.Scale = 2
				local vec = (target.Position - npc.Position):Normalized()
				npc:FireProjectiles(npc.Position, vec:Resized(10), 0, params)
				local cloud = Isaac.Spawn(1000,2,5,npc.Position,nilvector,npc):ToEffect()
				cloud:FollowParent(npc)
				cloud.SpriteOffset = Vector(0, -7) * npc.SpriteScale.X
				cloud.SpriteScale = Vector(1.5,1.5) * npc.SpriteScale.X
				cloud.DepthOffset = 10
				cloud.Color = Color(1,1,1,0.8,0.1,0.1,0.1)
				cloud:Update()
				for i = 1, 10 do
					local smokeVec = Vector(0, -20):Rotated(-30 + math.random(60))
					local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position - smokeVec, smokeVec:Resized(math.random(3,7) * -1), npc)
					local alpha = math.min(0.3, npc.StateFrame / 300)
					smoke.Color = Color(1,1,1,alpha,1,0,0)
					smoke.SpriteOffset = Vector(0, -25) + npc.SpriteOffset
					smoke.SpriteScale = smoke.SpriteScale * math.random(70,100)/100
					smoke:Update()
				end
				if targetpos.X < npc.Position.X then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			else
				mod:spritePlay(sprite, "Attack")
			end
		else
			d.state = "idle"
			npc.StateFrame = 10
		end
		if var == mod.FF.PaleHorf.Var then
			if not mod.MagnifierActiveInRoom then
				d.shrinking = true
				d.state = nil
				npc.StateFrame = 0
			end
			if npc:IsDead() or npc:HasMortalDamage() then
				npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
			end
		end
	end
end

function mod.magHorfProj(v,d)
	if v.FrameCount < 2 then
		if (v.SpawnerType == mod.FF.PaleHorf.ID and v.SpawnerVariant == mod.FF.PaleHorf.Var)
		or (v.SpawnerType == mod.FF.MagHorf.ID and v.SpawnerVariant == mod.FF.MagHorf.Var)
		then
			if v.Scale >= 2 then
				d.projType = "reaim"
				if v.SpawnerEntity and v.SpawnerEntity:ToNPC() then
					d.target = v.SpawnerEntity:ToNPC():GetPlayerTarget()
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
	local data = proj:GetData()
	if data.projType == "reaim" then
		if proj:IsDead() or not proj:Exists() then
			local spawnSpot = proj.Position
			for i = 0, 100, 10 do
				local checkVec = proj.Velocity:Resized(-1 * i)
				local room = game:GetRoom()
				if room:GetGridCollisionAtPos(proj.Position + checkVec) <= GridCollisionClass.COLLISION_PIT then
					spawnSpot = proj.Position + checkVec
					break
				end
			end
			local vec = Vector(10,0)
			if data.target then
				vec = (data.target.Position - spawnSpot):Resized(10)
			end
			for i = 90, 360, 90 do
				local proj2 = Isaac.Spawn(9, 0, 0, spawnSpot, vec:Rotated(i), proj)
				proj2.Color = proj.Color
				proj2.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				proj2:Update()
			end
		end
	end
end, 9)

function mod:paleClottyUpdate(npc, sub, var)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local path = npc.Pathfinder
    local room = game:GetRoom()

	if not d.init then
		d.init = true
		if var == mod.FF.PaleClotty.Var then
			npc.SplatColor = FiendFolio.ColorKickDrumsAndRedWine
			if mod.MagnifierActiveInRoom then
				changeMagScale(npc, true)
			else
				d.small = true
			end
		end

		if d.small then
			sprite:Play("SmallAppear", true)
		else
			sprite:Play("BigAppear", true)
		end
	else
		npc.StateFrame = npc.StateFrame + 1
	end


	if d.growing then
		sprite:RemoveOverlay()
		if sprite:IsFinished("Magnify") then
			d.growing = nil
		else
			mod:spritePlay(sprite, "Magnify")
		end
		if npc.StateFrame == 1 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 0.9)
		elseif npc.StateFrame == 5 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1)
			changeMagScale(npc, true)
		elseif npc.StateFrame == 9 then
			npc:PlaySound(SoundEffect.SOUND_THUMBSUP, 1, 0, false, 1.1)
		end		
	elseif d.shrinking then
		sprite:RemoveOverlay()
		if sprite:IsFinished("Shrink") then
			d.shrinking = nil
		else
			mod:spritePlay(sprite, "Shrink")
		end
		if npc.StateFrame == 1 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.9)
		elseif npc.StateFrame == 5 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.8)
			changeMagScale(npc, false)
		elseif npc.StateFrame == 9 then
			npc:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, 1, 0, false, 0.7)
		end		
	elseif d.small then
		if d.state == "idle" then
			npc.Velocity = npc.Velocity * 0.9
			mod:spritePlay(sprite, "SmallIdle")
			d.state = "move"
			npc.StateFrame = 0
			if math.random(2) == 1 then
				d.MoveVec = nil
				path:FindGridPath(targetpos, 0.1, 900, true)
			else
				d.MoveVec = RandomVector()
			end
		elseif d.state == "move" then
			if sprite:IsFinished("SmallHop") or (npc.StateFrame > 10 and math.random(5) == 1) then
				d.state = "attack"
			else
				mod:spritePlay(sprite, "SmallHop")
			end
			d.MoveVec = d.MoveVec or npc.Velocity:Rotated(-31 + math.random(61))
			npc.Velocity = mod:Lerp(npc.Velocity, d.MoveVec:Resized(5), 0.1)
			if npc.Velocity.X < 0 then
				sprite.FlipX = true
			else
				sprite.FlipX = false
			end
			if npc.FrameCount % 3 == 1 then
				local splat = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
				if var == mod.FF.PaleClotty.Var then
					splat.Color = FiendFolio.ColorKickDrumsAndRedWine
				end
				splat:Update()
			end
		elseif d.state == "attack" then
			npc.Velocity = npc.Velocity * 0.9
			if sprite:IsFinished("SmallAttack") then
				d.state = "idle"
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
				local params = ProjectileParams()
				params.Color = FiendFolio.ColorKickDrumsAndRedWine
				params.BulletFlags = ProjectileFlags.WIGGLE
				local vec = Vector(10,0)
				for i = 90, 360, 90 do
					npc:FireProjectiles(npc.Position, vec:Rotated(i), 0, params)
				end
				local splat = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
				if var == mod.FF.PaleClotty.Var then
					splat.Color = FiendFolio.ColorKickDrumsAndRedWine
				end
				splat:Update()
			else
				mod:spritePlay(sprite, "SmallAttack")
			end
		elseif not sprite:IsPlaying("SmallAppear") then
			d.state = "idle"
			mod:spritePlay(sprite, "SmallIdle")
		end
		if mod.MagnifierActiveInRoom then
			d.growing = true
			npc.StateFrame = 0
		end
	else
		if d.state == "idle" then
			mod:spritePlay(sprite, "Idle")
			npc.Velocity = npc.Velocity * 0.9
			if sprite:IsEventTriggered("Move") then
				d.Moved = true
				if math.random(3) == 1 then
					npc.Velocity = RandomVector():Resized(9)
				else
					mod:CatheryPathFinding(npc, targetpos, {
						Speed = 9,
						Accel = 1,
						GiveUp = true
					})
					npc.Velocity = npc.Velocity:Rotated(-31 + math.random(61))
				end
				if npc.Velocity.X < 0 then
					sprite.FlipX = true
				else
					sprite.FlipX = false
				end
			end
			if d.Moved and math.random(5) == 1 then
				d.state = "attack"
				d.Moved = false
			end
			
			if npc.FrameCount % 3 == 1 then
				for i = -15, 15, 30 do
					local splat = Isaac.Spawn(1000, 7, 0, npc.Position + Vector(i, 0), nilvector, npc):ToEffect()
					if var == mod.FF.PaleClotty.Var then
						splat.Color = FiendFolio.ColorKickDrumsAndRedWine
						splat:Update()
					end
				end
			end
		elseif d.state == "attack" then
			npc.Velocity = npc.Velocity * 0.9
			if sprite:IsFinished("Attack") then
				d.state = "idle"
			elseif sprite:IsEventTriggered("Shoot") then
				npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 0.6)
				npc:PlaySound(SoundEffect.SOUND_HEARTOUT, 0.5, 0, false, math.random(60,80)/100)
				npc:PlaySound(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.5, 0, false, math.random(65,75)/100)
				local params = ProjectileParams()
				if var == mod.FF.PaleClotty.Var then
					params.Color = FiendFolio.ColorKickDrumsAndRedWine
				end
				--params.BulletFlags = ProjectileFlags.SMART
				--I pout this in as a joke
				local vec = Vector(1,0)
				for j = 90, 360, 90 do
					for i = 1, 4 do
						params.Scale = 1 + (i/4)
						npc:FireProjectiles(npc.Position, vec:Rotated(j):Resized(4 * (5 - i)), 0, params)
					end
				end
				if var == mod.FF.PaleClotty.Var then
					for i = -15, 15, 30 do
						local splat = Isaac.Spawn(1000, 7, 0, npc.Position + Vector(i, 0), nilvector, npc):ToEffect()
						splat.Color = FiendFolio.ColorKickDrumsAndRedWine
						splat:Update()
					end
				end
			else
				mod:spritePlay(sprite, "Attack")
			end
		else
			d.state = "idle"
			mod:spritePlay(sprite, "Idle")
		end
		if var == mod.FF.PaleClotty.Var then
			if npc:IsDead() or npc:HasMortalDamage() then
				npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
			end
			if not mod.MagnifierActiveInRoom then
				d.shrinking = true
				d.state = nil
				npc.StateFrame = 0
			end
		end
	end
end