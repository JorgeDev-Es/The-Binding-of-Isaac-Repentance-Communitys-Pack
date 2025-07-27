local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    if mod:GetRealTrinketId(pickup.SubType) == FiendFolio.ITEM.ROCK.LOST_ARTIFACT then
		local speedMult = 1.3817
		local d = pickup:GetData()
		d.danceSpeed = d.danceSpeed or 0.1
		d.danceSpeed = d.danceSpeed * speedMult
		if d.danceSpeed > 10 then
			d.danceSpeed = 0.1
			d.stepCount = d.stepCount or 0
			d.stepCount = d.stepCount + 1
			d.stepCount = d.stepCount % 16
			if d.stepCount % 4 == 0 then
				if d.dist == 75 then
					d.dist = 50
				else
					d.dist = 75
				end
			end
		end
		d.danceAng = d.danceAng or math.random(360)
		d.danceAng = d.danceAng + d.danceSpeed
		d.danceAng = d.danceAng % 360

		if pickup.FrameCount % 2 == 0 then
			d.danceSpeed2 = d.danceSpeed2 or 0.1
			d.danceSpeed2 = d.danceSpeed2 * speedMult
			if d.danceSpeed2 > 10 then
				d.danceSpeed2 = 0.1
			end
			d.danceAng2 = d.danceAng2 or math.random(360)
			d.danceAng2 = d.danceAng2 + d.danceSpeed2
			d.danceAng2 = d.danceAng2 % 360
		end
		if pickup.FrameCount % 4 == 0 then
			d.danceSpeed3 = d.danceSpeed3 or 0.1
			d.danceSpeed3 = d.danceSpeed3 * speedMult
			if d.danceSpeed3 > 10 then
				d.danceSpeed3 = 0.1
			end
			d.danceAng3 = d.danceAng3 or math.random(360)
			d.danceAng3 = d.danceAng3 + d.danceSpeed3
			d.danceAng3 = d.danceAng3 % 360
		end
	end
end, 350)

local function getNearestArtifact(position, radius)
	if mod.IsActiveRoom() then return end
	radius = radius ^ 2
	local target
	for _, ent in ipairs(Isaac.FindByType(5, 350, FiendFolio.ITEM.ROCK.LOST_ARTIFACT)) do
		local distance = position:DistanceSquared(ent.Position)
		if distance < radius then
			radius = distance
			target = ent
		end
	end
	return target
end

local function determineDanceTargetPos(fam, d, td)
	local count = 0
	local numBefore = 0
	for _, ent in ipairs(Isaac.FindByType(3, fam.Variant)) do
		if fam.Variant == mod.ITEM.FAMILIAR.FAIRY_FLY_1 then
			if ent.InitSeed % 2 == fam.InitSeed % 2 and ent:GetData().target and ent:GetData().target.InitSeed == d.target.InitSeed then
				count = count + 1
				if ent.InitSeed < fam.InitSeed then
					numBefore = numBefore + 1
				end
			end
		else
			if ent:GetData().target and ent:GetData().target.InitSeed == d.target.InitSeed then
				count = count + 1
				if ent.InitSeed < fam.InitSeed then
					numBefore = numBefore + 1
				end
			end
		end
	end
	local angChange = (360 / math.max(count, 1)) * numBefore
	local dist = td.dist or 50
	local rockAng = (td.danceAng or 0) + angChange
	if fam.Variant == mod.ITEM.FAMILIAR.FAIRY_FLY_1 then	
		if fam.InitSeed % 2 == 0 then
			if dist == 75 then
				dist = 50
			else
				dist = 75
			end
			rockAng = rockAng * -1
		end
	elseif fam.Variant == mod.ITEM.FAMILIAR.FAIRY_FLY_2 then
		rockAng = (td.danceAng2 or 0) + angChange
		dist = 100
		if td.stepCount then
			if (td.stepCount % 2 == 0 and numBefore % 2 == 0) or (td.stepCount % 2 == 1 and numBefore % 2 == 1) then
				fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, Vector(0, -10), 0.3)
			else
				fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, nilvector, 0.3)
			end
		end
	elseif fam.Variant == mod.ITEM.FAMILIAR.FAIRY_FLY_3 then
		rockAng = (td.danceAng3 or 0) + angChange
		dist = 130
		rockAng = rockAng * -1
		if td.stepCount then
			if (td.stepCount % 4 <= 1 and numBefore % 2 == 0) or (td.stepCount % 4 >= 2 and numBefore % 2 == 1) then
				fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, Vector(0, -7), 0.3)
			else
				fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, nilvector, 0.3)
			end
		end
	end
	return d.target.Position + Vector(0, dist):Rotated(rockAng)
end

local function fairyOutsideRoomControl(fam, d)
	if not d.WalledIn then
		local room = game:GetRoom()
		if room:IsPositionInRoom(fam.Position, 10) then
			d.WalledIn = true
			fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		end
	else
		fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
end

function mod:spawnFairyClearRoom(player, variant, fairyCount)
	player = player or Isaac.GetPlayer()
	variant = variant or mod.ITEM.FAMILIAR.FAIRY_FLY_1
	fairyCount = fairyCount or 1
	for i = 1, fairyCount do
		local pos
		if variant == mod.ITEM.FAMILIAR.FAIRY_FLY_3 then
			pos = player.Position + RandomVector() * 50
		else
			local room = Game():GetRoom()
			local yRange = (room:GetGridHeight() * 40)
			local xRange = (room:GetGridWidth() * 40)
			local topLeft = room:GetTopLeftPos() + Vector(-40, 0)
			if math.random(2) == 1 then
				local YPos = topLeft.Y - 80 + math.random(yRange + 160)
				if math.random(2) == 1 then
					pos = Vector(topLeft.X - 80, YPos)
				else
					pos = Vector(topLeft.X + xRange + 80, YPos)
				end
			else
				local XPos = topLeft.X - 80 + math.random(xRange + 160)
				if math.random(2) == 1 then
					pos = Vector(XPos, topLeft.Y - 80)
				else
					pos = Vector(XPos, topLeft.Y + yRange + 80)
				end
			end
		end
		local fairy = Isaac.Spawn(3, variant, 0, pos, nilvector, player)
		fairy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		fairy:Update()
	end
end

function mod:fairyFlyRoomClear(spawnPos, dropRNG)
	--Slowly move fairy flies to kamikaze
    for _, fam in pairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.FAIRY_FLY_1, -1, false, false)) do
		local d = fam:GetData()
		if not d.kamikaze then
			local r = fam:GetDropRNG()
			fam = fam:ToFamiliar()
			fam.Coins = fam.Coins + 1
			local KamikazeChance = fam.Coins / 5
			local rand = r:RandomFloat()
			if KamikazeChance > rand then
				d.kamikaze = true
				fam.CollisionDamage = fam.Player.Damage * 2
			end
		end
	end
    for _, fam in pairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.FAIRY_FLY_2, -1, false, false)) do
		local d = fam:GetData()
		d.SwollenNess = math.min(d.SwoleCap, d.SwollenNess + 30)
	end
    for _, fam in pairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.FAIRY_FLY_3, -1, false, false)) do
		fam = fam:ToFamiliar()
		fam.Coins = fam.Coins + 1
	end
	--Lost artifact fairy spawning
	local trinketMult = 0
	local spawnerPlayer
	mod.AnyPlayerDo(function(player)
		if player:HasTrinket(FiendFolio.ITEM.ROCK.LOST_ARTIFACT) then
			spawnerPlayer = spawnerPlayer or player
			local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.LOST_ARTIFACT)
			trinketMult = trinketMult + trinketPower
		end
	end)
	trinketMult = trinketMult * 10
	if trinketMult > 0 then
		spawnerPlayer = spawnerPlayer or Isaac.GetPlayer()
		--Luck calculation
		local luckval = (spawnerPlayer.Luck * 2.5)
		luckval = math.max(math.min(luckval, 70), -10)
		local rollbase = 20 + luckval

		--Variant determination
		local fairyVar = mod.ITEM.FAMILIAR.FAIRY_FLY_1
		--Rare chance for a large lad in regeular rooms
		local bigLadChance = 3000
		local roomType = Game():GetRoom():GetType()
		--Boss / miniboss rooms help
		if roomType == RoomType.ROOM_BOSS then
			bigLadChance = 50
		elseif roomType == RoomType.ROOM_MINIBOSS then
			bigLadChance = 100
		end
		local rand = dropRNG:RandomFloat() * bigLadChance
		if rand < rollbase then
			fairyVar = mod.ITEM.FAMILIAR.FAIRY_FLY_3
		--Otherwise ~1/4 of the time flies will be round ones
		elseif (dropRNG:RandomFloat() * 100) > 75 then
			fairyVar = mod.ITEM.FAMILIAR.FAIRY_FLY_2
		end

		--Number of spawns determination
		local fairyCount = 1
		local repeatTries = math.ceil(trinketMult / 5)
		--More attempts for babs
		if fairyVar == mod.ITEM.FAMILIAR.FAIRY_FLY_1 then
			repeatTries = repeatTries + 2
		end
		--Big ones only ever 1
		if fairyVar ~= mod.ITEM.FAMILIAR.FAIRY_FLY_3 then
			for i = 1, repeatTries do
				if (dropRNG:RandomFloat() * 100) < rollbase then
					fairyCount = fairyCount + 1
				end
			end
		end
		mod:spawnFairyClearRoom(spawnerPlayer, fairyVar, fairyCount)
	end
end

local cSectionItemFlags = {
	{Item = CollectibleType.COLLECTIBLE_DR_FETUS, 		Flags = TearFlags.TEAR_FETUS_BOMBER},
	{Item = CollectibleType.COLLECTIBLE_SPIRIT_SWORD, 	Flags = TearFlags.TEAR_FETUS_SWORD},
	{Item = CollectibleType.COLLECTIBLE_MOMS_KNIFE, 	Flags = TearFlags.TEAR_FETUS_KNIFE},
	{Item = CollectibleType.COLLECTIBLE_TECH_X, 		Flags = TearFlags.TEAR_FETUS_TECHX},
	{Item = CollectibleType.COLLECTIBLE_TECHNOLOGY, 	Flags = TearFlags.TEAR_FETUS_TECH}
}

local brimStoners = {
	[PlayerType.PLAYER_AZAZEL] = true,
	[PlayerType.PLAYER_AZAZEL_B] = true,
}

function mod:FairyFlyFire(fam, vec, mult, brimOffset)
	if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) and not (fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or brimStoners[fam.Player:GetPlayerType()]) then
		local tear = fam.Player:FireTear(fam.Position, vec:Resized(fam.Player.ShotSpeed * 10), false, true, false, player,mult)
		tear:AddTearFlags(TearFlags.TEAR_FETUS | TearFlags.TEAR_RAINBOW)
		tear:ChangeVariant(TearVariant.FETUS)
		for i = 1, #cSectionItemFlags do
			if fam.Player:HasCollectible(cSectionItemFlags[i].Item) then
				tear:AddTearFlags(cSectionItemFlags[i].Flags)
			end
		end
		--TearFlags.TEAR_FETUS_BONE
		tear:Update()
	--[[elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
		local sword = player:FireKnife(fam, 0, false, 4, 10)
	elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then]]
		
	elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) or fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
		local bomb = fam.Player:FireBomb(fam.Position, vec:Resized(fam.Player.ShotSpeed * 10), fam)
		bomb.ExplosionDamage = bomb.ExplosionDamage * mult
		bomb.RadiusMultiplier = bomb.RadiusMultiplier * mult
		bomb:Update()
		if mult < 1 then
			bomb.SpriteScale = bomb.SpriteScale * 0.75
		end
	elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
		local ring = fam.Player:FireTechXLaser(fam.Position, vec:Resized(fam.Player.ShotSpeed * 10), 40, fam, mult)
		ring:Update()
	elseif (fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or brimStoners[fam.Player:GetPlayerType()]) then
		local brim = fam.Player:FireBrimstone(vec, fam, mult)
		brim:AddTearFlags(TearFlags.TEAR_RAINBOW)
		brim.Parent = fam
		brim.PositionOffset = Vector(0,-25)
		brim:Update()
	elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
		local laser = fam.Player:FireTechLaser(fam.Position, LaserOffset.LASER_BRIMSTONE_OFFSET, vec, false, true, fam, mult)
		laser:AddTearFlags(TearFlags.TEAR_RAINBOW)
		laser:Update()
	else
		fam.Player:FireTear(fam.Position, vec:Resized(fam.Player.ShotSpeed * 10), false, true, false, player,mult)
	end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(fam.Player)
	local isSirenCharmed = mod:isSirenCharmed(fam)
	local r = fam:GetDropRNG()
	d.StateFrame = d.StateFrame or 0
	fairyOutsideRoomControl(fam, d)
	local BFFAccounting = false

	if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
		if not fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			fam.SpriteScale = Vector.One
		end
		if not d.HiveMinded then
			fam:SetSize(18, Vector.One, 12)
			d.HiveMinded = true
		end
	elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		BFFAccounting = true
		fam.SpriteScale = Vector(0.8,0.8)
		if d.HiveMinded then
			fam:SetSize(13, Vector.One, 12)
			d.HiveMinded = nil
		end
	else
		fam.SpriteScale = Vector.One
		if d.HiveMinded then
			fam:SetSize(13, Vector.One, 12)
			d.HiveMinded = nil
		end
	end
	d.UniqueSize = d.UniqueSize or 0.9 + math.random()/5
	fam.SpriteScale = fam.SpriteScale * d.UniqueSize

	if not d.init then
		d.init = true
		d.state = "idle"
	else
		d.StateFrame = d.StateFrame + 1
	end
	d.UniqueCol = d.UniqueCol or {math.random()/3,math.random()/3,math.random()/3}
	fam.Color = Color(0.84 + d.UniqueCol[1], 0.84 + d.UniqueCol[2], 0.84 + d.UniqueCol[3], math.min(1, fam.FrameCount/10), 0, 0, 0)

	if isSirenCharmed then
		d.target = mod:getClosestPlayer(fam.Position, 900)
	else
		local nearbyEnemy = mod:getClosestEnemyFlyingMinion(fam.Position, 200)
		if nearbyEnemy then
			d.target = nearbyEnemy
		else
			d.target = getNearestArtifact(fam.Position, 900)
		end
	end
	if (not d.target) or (d.target and not d.target:Exists()) then
		d.target = fam.Player
	end

	if d.state == "idle" then
		d.stopMoving = nil
		mod:spritePlay(sprite, "Fly")
		if fam.Position:Distance(d.target.Position) < 100 and d.target.Type ~= 1 and d.target.Type ~= 5 then
			if not d.kamikaze then
				if d.StateFrame > 60 and math.random(30) == 1 then
					if Game():GetRoom():CheckLine(fam.Position, d.target.Position, 3) then
						d.state = "shoot"
						d.stopMoving = true
					end
				end
			end
		end
	elseif d.state == "shoot" then
		if sprite:IsFinished("Attack") then
			d.state = "idle"
			d.StateFrame = 0
		elseif sprite:IsEventTriggered("Shoot") then
			sfx:Play(SoundEffect.SOUND_SPEWER,0.4,0,false,1.7 + (math.random()*0.7))
			local mult = 0.5
			if d.HiveMinded then
				mult = mult * 2
			end
			local shotCount = 1 + (1 * fam.Player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)) + (1 * fam.Player:GetCollectibleNum(CollectibleType.COLLECTIBLE_THE_WIZ)) + (2 * fam.Player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE)) + (3 * fam.Player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER))
			shotCount = math.min(shotCount, 10)
			local vec = (d.target.Position - fam.Position)
			for i = 1, shotCount do
				mod:FairyFlyFire(fam, vec:Rotated(mod.rapidFireOpalOffsets[shotCount][1] + (mod.rapidFireOpalOffsets[shotCount][2] * (i-1))), mult, brimOffset)
			end
		elseif sprite:IsEventTriggered("Continue") then
			d.stopMoving = nil
			fam.Coins = fam.Coins + 1
			local KamikazeChance = fam.Coins / 5
			local rand = r:RandomFloat()
			if KamikazeChance > rand then
				d.kamikaze = true
				fam.CollisionDamage = fam.Player.Damage * 2
			end
		else
			mod:spritePlay(sprite, "Attack")
		end
	end

	if d.stopMoving then
		fam.Velocity = fam.Velocity * 0.05
	elseif d.target.Type == 5 then
		local td = d.target:GetData()
		--[[local vec = (fam.Position - d.target.Position):Resized(dist)
		local speed = td.danceSpeed or 1
		if fam.InitSeed % 2 == 0 then
			speed = speed * -1
		end
		vec = vec:Rotated(speed)
		local targetPos = d.target.Position + vec]]
		local targetPos = determineDanceTargetPos(fam, d, td)
		local targVec = (targetPos - fam.Position)
		if targVec:Length() > 12 then
			targVec = targVec:Resized(12)
		end
		fam.Velocity = mod:Lerp(fam.Velocity, targVec, 0.3)
	else
		d.TargetAngle = d.TargetAngle or mod:RandomAngle()
		d.TargetOffset = d.TargetOffset or mod:RandomInt(0,40)
		if mod:RandomInt(1,5) == 1 then
			d.TargetAngle = d.TargetAngle + mod:RandomInt(-45,45)
			d.TargetOffset = mod:RandomInt(0,80)
		end
		local targetPos = d.target.Position + Vector.One:Resized(d.TargetOffset):Rotated(d.TargetAngle)
		local targetvec = nilvector
		if d.kamikaze and d.target.Type ~= 1 and fam.Position:Distance(d.target.Position) < 100 then
			targetvec = (d.target.Position - fam.Position):Rotated(mod:RandomInt(-20,20))
		elseif fam.Position:Distance(targetPos) > 10 then
			targetvec = (targetPos - fam.Position):Rotated(mod:RandomInt(-20,20))
		end
		if targetvec:Length() > 12 then
			targetvec = targetvec:Resized(12)
		end
		fam.Velocity = mod:Lerp(fam.Velocity, targetvec, 0.05)
	end

	if not fam.Child then
		if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
			local sword = Isaac.Spawn(1000, mod.FF.FairyWeapon.Var, mod.FF.FairyWeapon.Sub, fam.Position, nilvector, fam)
			sword.Parent = fam
			fam.Child = sword
			local ss = sword:GetSprite()
			if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
				ss:Load("gfx/008.011_tech sword.anm2", true)
			else
				ss:Load("gfx/008.010_spirit sword.anm2", true)
			end
			ss:Play("IdleDown")
			sword:Update()
		elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
			local knife = Isaac.Spawn(1000, mod.FF.FairyWeapon.Var, mod.FF.FairyWeapon.Sub, fam.Position, nilvector, fam)
			knife.Parent = fam
			fam.Child = knife
			knife:Update()
		end
	end
	if fam.Child then
		local club = fam.Child
		local distance = 10
		local targetPos = fam.Position + Vector(0,distance)
		if d.target.Type ~= 1 then
			targetPos = fam.Position + ((d.target.Position - fam.Position):Resized(distance))
			club.SpriteRotation = (d.target.Position - fam.Position):GetAngleDegrees() - 90
		else
			club.SpriteRotation = (club.Position - fam.Position):GetAngleDegrees() - 90
		end
		club.Velocity = mod:Lerp(club.Velocity, (targetPos - club.Position), 0.1)

		if d.HiveMinded then
			club.SpriteScale = Vector(0.75, 0.75)
		else
			club.SpriteScale = Vector(0.6,0.6)
		end
		--[[club:SetSize(13, Vector.One, 8)
		club.CollisionDamage = 5
		club.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES]]
	end

	if d.kamikaze then
		fam.CollisionDamage = fam.Player.Damage * 2
	else
		if fam.Child then
			fam.CollisionDamage = fam.Player.Damage * 0.5
		else
			fam.CollisionDamage = fam.Player.Damage * 0.1
		end
	end
	if BFFAccounting then
		fam.CollisionDamage = fam.CollisionDamage / 2
	end

end, mod.ITEM.FAMILIAR.FAIRY_FLY_1)

function mod:fairyWeaponAI(e)
	local sprite, d = e:GetSprite(), e:GetData()
	e.SpriteOffset = Vector(0, -15)
	if not e.Parent then
		e:Remove()
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider)
	local d = fam:GetData()
	if collider:IsVulnerableEnemy() and (not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) and (not collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
		if d.kamikaze then
			sfx:Play(SoundEffect.SOUND_PLOP,1,0,false,1.5)
			local blood = Isaac.Spawn(1000, mod.FF.FakeBloodpoof.Var, mod.FF.FakeBloodpoof.Sub, fam.Position, nilvector, npc):ToEffect()
			blood.Color = Color(239/255,138/255,232/255,0.75)
			blood.SpriteOffset = Vector(0, -20)
			blood:Update()
			blood.SpriteScale = Vector(0.6,0.6)
			fam:Die()
		end
	end
end, mod.ITEM.FAMILIAR.FAIRY_FLY_1)

local skippedRenderModes = {
	[RenderMode.RENDER_WATER_REFRACT] = true,
	[RenderMode.RENDER_WATER_REFLECT] = true,
}

local function renderFairyName(fam, zaniness, offset)
	if skippedRenderModes[game:GetRoom():GetRenderMode()] then return end

	local d = fam:GetData()
	d.name = d.name or mod:GenerateFairyName(zaniness)

	if mod.tabHeldAlphaTimer > 0.01 then
		local pos = game:GetRoom():WorldToScreenPosition(fam.Position) + Vector(mod.TempestFont:GetStringWidth(d.name) * -0.5, offset + fam.SpriteOffset.Y)
		mod.TempestFont:DrawString(d.name, pos.X, pos.Y, KColor(1,1,1,mod.tabHeldAlphaTimer/30), 0, false)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, fam)
	renderFairyName(fam, 0, -45)
end, mod.ITEM.FAMILIAR.FAIRY_FLY_1)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(fam.Player)
	local isSirenCharmed = mod:isSirenCharmed(fam)
	local r = fam:GetDropRNG()
	d.StateFrame = d.StateFrame or 0
	fairyOutsideRoomControl(fam, d)
	local BFFAccounting = false

	if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
		if not fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			fam.SpriteScale = Vector.One
		end
		if not d.HiveMinded then
			fam:SetSize(18, Vector.One, 12)
			d.HiveMinded = true
		end
	elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		BFFAccounting = true
		fam.SpriteScale = Vector(0.8,0.8)
		if d.HiveMinded then
			fam:SetSize(13, Vector.One, 12)
			d.HiveMinded = nil
		end
	else
		fam.SpriteScale = Vector.One
		if d.HiveMinded then
			fam:SetSize(13, Vector.One, 12)
			d.HiveMinded = nil
		end
	end
	d.UniqueSize = d.UniqueSize or 0.9 + math.random()/5
	fam.SpriteScale = fam.SpriteScale * d.UniqueSize

	if not d.init then
		d.init = true
		d.state = "idle"
	else
		d.StateFrame = d.StateFrame + 1
	end
	d.UniqueCol = d.UniqueCol or {math.random()/3,math.random()/3,math.random()/3}
	fam.Color = Color(0.84 + d.UniqueCol[1], 0.84 + d.UniqueCol[2], 0.84 + d.UniqueCol[3], math.min(1, fam.FrameCount/10), 0, 0, 0)

	if isSirenCharmed then
		d.target = mod:getClosestPlayer(fam.Position, 900)
	else
		local nearbyEnemy = mod:getClosestEnemyFlyingMinion(fam.Position, 150)
		if nearbyEnemy then
			d.target = nearbyEnemy
		else
			d.target = getNearestArtifact(fam.Position, 900)
		end
	end
	if (not d.target) or (d.target and not d.target:Exists()) then
		d.target = fam.Player
	end

	d.SwollenNess = d.SwollenNess or fam.Coins
	fam.Coins = math.ceil(d.SwollenNess)
	d.SwoleCap = 150
	local anim = math.min(math.ceil(d.SwollenNess / (d.SwoleCap/4)), 4)
	mod:spritePlay(sprite, "Idle0" .. anim)

	if d.target.Type == 1 and d.WalledIn then
		fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, nilvector, 0.3)
		d.DiagMult = d.DiagMult or math.random() * 2
		if mod:RandomInt(1,5) == 1 then
			d.DiagMult = math.random() * 2
		end
		fam.Velocity = mod:Lerp(fam.Velocity, mod:diagonalMoveFam(fam, 3, true, d.DiagMult), 0.1)
	elseif d.target.Type == 5 then
		local td = d.target:GetData()
		local targetPos = determineDanceTargetPos(fam, d, td)
		local targVec = (targetPos - fam.Position)
		if targVec:Length() > 12 then
			targVec = targVec:Resized(12)
		end
		fam.Velocity = mod:Lerp(fam.Velocity, targVec, 0.3)
	else
		fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, nilvector, 0.3)
		d.TargetAngle = d.TargetAngle or mod:RandomAngle()
		d.TargetOffset = d.TargetOffset or mod:RandomInt(0,20)
		if mod:RandomInt(1,5) == 1 then
			d.TargetAngle = d.TargetAngle + mod:RandomInt(-45,45)
			d.TargetOffset = mod:RandomInt(0,40)
		end
		local targetPos = d.target.Position + Vector.One:Resized(d.TargetOffset):Rotated(d.TargetAngle)
		local targetvec = nilvector
		if fam.Position:Distance(targetPos) > 10 then
			targetvec = (targetPos - fam.Position):Rotated(mod:RandomInt(-20,20))
			if targetvec:Length() > 12 then
				targetvec = targetvec:Resized(12)
			end
		end
		if fam.Position:Distance(d.target.Position) < 50 and d.target.Type ~= 1 then
			d.SwollenNess = d.SwollenNess + math.random() * 2
		end
		fam.Velocity = mod:Lerp(fam.Velocity, targetvec, 0.05)
	end

	if d.SwollenNess > d.SwoleCap then
		sfx:Play(SoundEffect.SOUND_SPEWER,1,0,false,1.5)
		local mult = 1
		if d.HiveMinded then
			mult = mult * 2
		end
		for i = 45, 360, 45 do
			mod:FairyFlyFire(fam, Vector.One:Rotated(i), mult, brimOffset)
		end
		sfx:Play(SoundEffect.SOUND_PLOP,1,0,false,1.5)
		local blood = Isaac.Spawn(1000, mod.FF.FakeBloodpoof.Var, mod.FF.FakeBloodpoof.Sub, fam.Position, nilvector, npc):ToEffect()
		blood.Color = Color(239/255,138/255,232/255,0.75)
		blood.SpriteOffset = Vector(0, -20)
		blood:Update()
		blood.SpriteScale = Vector(0.6,0.6)
		fam:Die()
	end


	fam.CollisionDamage = fam.Player.Damage * 0.25
	if BFFAccounting then
		fam.CollisionDamage = fam.CollisionDamage / 2
	end
end, mod.ITEM.FAMILIAR.FAIRY_FLY_2)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider)
	local d = fam:GetData()
	if collider:IsVulnerableEnemy() and (not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) and (not collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
		d.SwollenNess = d.SwollenNess or 0
	end
end, mod.ITEM.FAMILIAR.FAIRY_FLY_2)

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, fam)
	renderFairyName(fam, 1, -45)
end, mod.ITEM.FAMILIAR.FAIRY_FLY_2)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local d = fam:GetData()
	local sprite = fam:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(fam.Player)
	local isSirenCharmed = mod:isSirenCharmed(fam)
	local r = fam:GetDropRNG()
	d.StateFrame = d.StateFrame or 0
	fairyOutsideRoomControl(fam, d)
	local BFFAccounting = false

	if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
		if not fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			fam.SpriteScale = Vector.One
		end
		if not d.HiveMinded then
			fam:SetSize(35, Vector.One, 12)
			d.HiveMinded = true
		end
	elseif fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		BFFAccounting = true
		fam.SpriteScale = Vector(0.8,0.8)
		if d.HiveMinded then
			fam:SetSize(26, Vector.One, 12)
			d.HiveMinded = nil
		end
	else
		fam.SpriteScale = Vector.One
		if d.HiveMinded then
			fam:SetSize(26, Vector.One, 12)
			d.HiveMinded = nil
		end
	end
	d.UniqueSize = d.UniqueSize or 0.9 + math.random()/5
	fam.SpriteScale = fam.SpriteScale * d.UniqueSize

	if not d.init then
		d.init = true
		d.state = "appear"
	else
		d.StateFrame = d.StateFrame + 1
	end
	d.UniqueCol = d.UniqueCol or {math.random()/3,math.random()/3,math.random()/3}
	fam.Color = Color(0.84 + d.UniqueCol[1], 0.84 + d.UniqueCol[2], 0.84 + d.UniqueCol[3], math.min(1, fam.FrameCount/10), 0, 0, 0)

	if isSirenCharmed then
		d.target = mod:getClosestPlayer(fam.Position, 900)
	else
		local nearbyEnemy = mod:getClosestEnemyFlyingMinion(fam.Position, 120)
		if nearbyEnemy then
			d.target = nearbyEnemy
		else
			d.target = getNearestArtifact(fam.Position, 900)
		end
	end
	if (not d.target) or (d.target and not d.target:Exists()) then
		d.target = fam.Player
	end

	if d.state == "appear" then
		if sprite:IsFinished("Appear") then
			d.state = "idle"
		elseif sprite:IsEventTriggered("Damage") then
		elseif sprite:IsEventTriggered("Noise") then
		else
			mod:spritePlay(sprite, "Appear")
		end
	elseif d.state == "idle" then
		mod:spritePlay(sprite, "Idle")
		if d.target.Type == 1 then
			fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, nilvector, 0.3)
			if d.target.Position:Distance(fam.Position) > 100 then
				local targvec = (d.target.Position - fam.Position):Resized(5)
				fam.Velocity = mod:Lerp(fam.Velocity, targvec, 0.01)
			else
				if fam.Velocity:Length() == 0 then
					fam.Velocity = RandomVector() * 0.01
				end
				fam.Velocity = mod:Lerp(fam.Velocity, fam.Velocity:Resized(2), 0.01)
				fam.Velocity = fam.Velocity:Rotated(-5 + (math.random() * 10))
			end
		elseif d.target.Type == 5 then
			local td = d.target:GetData()
			local targetPos = determineDanceTargetPos(fam, d, td)
			local targVec = (targetPos - fam.Position)
			if targVec:Length() > 5 then
				targVec = targVec:Resized(5)
			end
			fam.Velocity = mod:Lerp(fam.Velocity, targVec, 0.1)
		else
			fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, nilvector, 0.3)
			local dist = d.target.Position:Distance(fam.Position)
			local room = game:GetRoom()
			d.UniqueTimeDiff = d.UniqueTimeDiff or math.random(60)
			if room:GetFrameCount() > 90 + d.UniqueTimeDiff and dist < 100 and (d.target.Position:Distance(fam.Player.Position) > 100 or fam.Coins >= 5) then
				d.setTarget = d.target
				d.setTargetLastPos = d.setTarget.Position
				d.state = "its over"
			else
				local targvec = (d.target.Position - fam.Position):Resized(5)
				fam.Velocity = mod:Lerp(fam.Velocity, targvec, 0.1)
			end
		end
	elseif d.state == "its over" then
		if d.setTarget:Exists() and not d.moving then
			d.setTargetLastPos = d.setTarget.Position
		end
		if d.moving then
			local targvec = (d.setTargetLastPos - fam.Position)
			local targvec = targvec:Resized(math.min(targvec:Length(), 10))
			fam.Velocity = mod:Lerp(fam.Velocity, targvec, 0.1)
		else
			fam.Velocity = fam.Velocity * 0.9
		end
		if sprite:IsFinished("Attack") then
			local bomb = Isaac.Spawn(4, 0, 0, fam.Position, nilvector, fam.Player):ToBomb()
			bomb:AddTearFlags(TearFlags.TEAR_GIGA_BOMB)
			bomb:SetExplosionCountdown(0)
			bomb:Update()
			sfx:Play(mod.Sounds.FartFrog4,0.5,0,false,0.7)
			--sfx:Stop(mod.Sounds.BrownedYippee)
			local mult = 1
			if d.HiveMinded then
				mult = mult * 2
			end
			for i = 18, 360, 18 do
				mod:FairyFlyFire(fam, Vector.One:Rotated(i), mult, brimOffset)
			end
			fam:Remove()
			mod:UpdatePits()
		elseif sprite:IsEventTriggered("Noise") then
			d.moving = true
			sfx:Play(mod.Sounds.ChildAngryRoarButGood,0.5,0,false,0.6 + (math.random() * 0.2))
		elseif sprite:IsEventTriggered("Hmph") then
			--sfx:Play(SoundEffect.SOUND_CHILD_HAPPY_ROAR_SHORT,0.5,0,false,0.6 + (math.random() * 0.2))
		elseif sprite:IsEventTriggered("Damage") then
			sfx:Play(mod.Sounds.BrownedYippee,0.1,0,false,1.3 + (math.random() * 0.7))
			d.moving = false
		else
			mod:spritePlay(sprite, "Attack")
		end
	end

	fam.CollisionDamage = fam.Player.Damage * 0.1
	if BFFAccounting then
		fam.CollisionDamage = fam.CollisionDamage / 2
	end
end, mod.ITEM.FAMILIAR.FAIRY_FLY_3)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, collider)

end, mod.ITEM.FAMILIAR.FAIRY_FLY_3)

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, fam)
	renderFairyName(fam, 2, -55)
end, mod.ITEM.FAMILIAR.FAIRY_FLY_3)

FiendFolio.FairyFlyTitlesBoring = {
	"Mrs.", "Ms.", "Dr.", "Prof.", "Mr.", "Sir", "Madam", "Miss", "Master", "A",
}
FiendFolio.FairyFlyTitles = {
	"El", "La", "Lo", "Le", "Das", "Der", "Die", "Un", "Adm.", "Capt.", "Cdr.",
	"Lt.", "Gen.", "Sgt.", "Col.", "Maj.", "Cpl.", "Pte.", "Ens.", "My", "His",
	"Her", "Their", "It's", "Da", "DJ", "MC", "Tainted", "Tarnished", "2D", "3D", "4D",
	"Here's", "Hi", "Hello", "The Binding of", "Into the", "Enter the", "My Little",
	"Lord", "King", "Queen", "M'Lord", "The one and only", "AI Generated", "Your",
	"Is it", "Kid named", "Fly named", "Level 100", "Ghost of", "Final", "Janitor", "Guardian",
}
FiendFolio.FairyFlyEnders = {
	".xml", ".exe", ".anm2", " 2.0", " XL", " XXL", " 2", " 3", " II", " III", " IV",
	" XXX", "Xc2", " et al.", " esq.", " PhD.", " BS", " BSc", " BA (Hons)", " MA",
	" MS", " MSc", " Jr.", " Sr.", " (he/him)", " (she/her)", " (they/them)", " (it/its)",
	" RTX", " NFT", ".txt", " XD", " LOL", "?", "!", "...", " etc.", " & Knuckles", " MOD",
	" X", ": Reheated", " DX", ".com", " Bros.", " with the paws", ": Story Mode",
	" 2: Electric Boogaloo", " FR", " on god", " no cap", "985", "2001", "2002", "2003",
	"-san", "-sama", "-kun", "-chan", "-tan", "-bo", " Senpai", " Sensei", "1998", "1999",
	" #Blessed", " B-Skin", " (not clickbait!)", " (gone wrong!)", " Andy", " CD", " 2600",
	" 5200", " 7800", " 3000", " 64", " U", "enemy", " API", "+", "... or is it?",
	" and more?", " TM", " Ltd.", " + L + Ratio", " in 3D", " in 4D", " Zone", ": Episode One",
	": Episode Two", ": Episode Three", ": Lost Coast", " #Cursed", " #Blursed", "of all time",
	", innit", " ne", ", eh?", ", or so it seems...", " or Rubbish?", " EX", " NEO", " Deluxe", " Super",
	"'s Brother", "!!!", " Zero", " King", " Queen", " is Magic", " TAS", " Crimelord", " 2006", " Forever",
	"'s Sister", "'s Sibling", "'s Mother", "'s Father", "'s Son", "'s Daughter", "'s Child", "'s Parent",

}
FiendFolio.FairyFlyConnectors = {
	"the", "with", "without", "on", "on the", "with the", "but", "&", "and the", "and", "yet",
	"with a", "without a", "of", "of the", "for", "for the", "but with", "but without", "T.",
	"Q.", "J.", "with their", "of their", "for their", "and their", "feat.", "including", "B.",
	"E.", ">", "<", "X", "VS", "+", "-", "=", "against", "against the", "against their", "by",
	"loves", "hates", "or", "and/or", "Named", "without any", "that is", "that isn't",
}

FiendFolio.FairyFlyNames = {
	"Jewel", "Berry", "Sprinkle", "Sour", "Dough", "Sweet", "Cake", "Sweetie", "Cheeks", "Sparklo",
	"Flicker", "Creek", "Lilac", "Hope", "Amethyst", "Cinnamon", "Dust", "Layla", "Cozy", "Sky", "Helios",
	"Pineapple", "Fluff", "Fluffy", "Happy", "Oak", "Willow", "Glitter", "Butter", "Moss", "Amy", "Rose",
	"Charmy", "Bee", "Foggy", "Fauna", "Swift", "Walnut", "Choco", "Chocolate", "Eva", "Spring", "Butt",
	"Twilight", "Sparkle", "Rainbow", "Dash", "Apple", "Jack", "Flutter", "Shy", "Pinkie", "Pie",
	"Epic", "Gamer", "Radical", "Derpy", "Awesome", "Bastard", "Divine", "Treasure", "Rolly", "Garnet",
	"Pearl", "Peri", "Peridot", "Spinel", "Pine", "Pen", "Fiend", "China", "Golem", "Moxi", "Rouge",
	"Velvet", "Sapphire", "Sapphic", "Gay", "Lard", "Under", "Tale", "Tail", "Apricot", "Lemon", "Bread",
	"Sunny", "Earth", "Bound", "Scout", "Star", "Blue", "Butta", "Nut", "Gar", "Field", "Garf", "Swishy",
	"Hair", "Future", "Wonder", "Bolt", "Twinkle", "Wish", "Magic", "Muffin", "Cupcake", "Cup", "Squash",
	"Pancake", "Vessel", "Lar", "Ry", "Pink", "Bubble", "Lean", "Poof", "Scary", "Hollow", "Hallow", "Merry",
	"Noelle", "Holiday", "Diet", "Pepsi", "Cola", "Vanilla", "Cream", "Moon", "Sun", "Spot", "Bear", "Faz",
	"Freddy", "Melon", "Roller", "Scoot", "Charity", "Kind", "Heart", "Cherry", "Jubilee", "Coco", "Pom",
	"Color", "Thorn", "Flora", "Jazz", "June", "Bug", "May", "Meadow", "Brook", "Bottom", "Peach", "Kitty",
	"Petunia", "Clover", "Leaf", "Bloom", "Shimmy", "Rake", "Shamrock", "Cider", "Song", "Bird", "Brain",
	"Meat", "Wad", "Master", "Shake", "Fry", "Lock", "Carl", "Trapeze", "Hugger", "Tree", "Zesty", "Ranch",
	"Rare", "Rarity", "Swoosh", "Discord", "Fly", "Wing", "Topaz", "Lydia", "Anna", "Belle", "Bell", "Jingle",
	"Dingle", "Clingy", "Bean", "Green", "Sprout", "Shoot", "Sylvia", "Penny", "Wise", "Soup", "Beet", "Dinner",
	"Breakfast", "Lunch", "Munch", "John", "Jon", "Egg", "Bert", "Vriska", "Serket", "Home", "Stuck", "Door",
	"Lah", "Londe", "Strider", "Folio", "Friend", "Friendly", "Crunch", "Dumb", "Silly", "Goober", "Juice", "Loose",
	"Sandwich", "Jill", "Jade", "Harley", "Dave", "Hive", "Swap", "Fell", "Big", "Light", "Orb", "Cute", "Cutie",
	"Word", "Smith", "Gummy", "Gum", "Mint", "Fresh", "Bomb", "Copy", "Holy", "Damn", "Devil", "Naughty", "Cheeky",
	"Dummy", "Tangerine", "Dream", "Tuft", "Linen", "Tech", "Tip", "Fiddle", "Worth", "Coin", "Key", "Black", "White",
	"Adversary", "Mc", "Edmund", "Trippy", "Necro", "Super", "Ultra", "Mug", "Smash", "Brash", "Tooth", "Evil", "Good",
	"Burger", "Pizza", "Pasta", "Demi", "Abro", "Pan", "Ace", "Aro", "Bold", "Baby", "Babie", "Tiny", "Teenie", "Teeny",
	"Tinky", "Winky", "Dipsy", "Po", "Lab", "Lala", "Slay", "Queen", "Princess", "Flavor", "Dear", "Damsel",
	"Fairy", "Tinker", "Top", "Spinning", "Monkey", "Sauce", "Wacky", "Zany", "Funky", "Caco", "Phobia",
	"Moist", "Grand", "Dom", "Nickel", "Dime", "Quartz", "Smokey", "Smooch", "Kissy", "Smekky", "Smorch",
	"Un", "Scrupulous", "Maw", "Violent", "Thunder", "Danger", "Attack", "Walter", "Jesse", "Lady", "Man",
	"Spaghetti", "Dog", "Cat", "Perfect", "Valuable", "Gold", "Finger", "Winged", "Mini", "Chibi", "Head",
	"Iron", "Copper", "Monster", "Magnum", "Macro", "Sausage", "Wiener", "Weenie", "Junior", "Madam", "Donk",
	"Basket", "Ball", "Net", "Foot", "Base", "First", "Firth", "Third", "Strong", "Bad", "Piggy", "Angry",
	"Sad", "Toby", "Fox", "Elizabeth", "Liz", "Luz", "Amity", "Blight", "Anne", "Sasha", "Marcy", "Dipper",
	"Mabel", "Lisa", "Homer", "Marge", "Bart", "Sponge", "Squid", "Ward", "Bob", "Lapis", "Lazuli", "Stone",
	"Brim", "Doodle", "Miku", "Hatsune", "Surge", "Sonic", "Shadow", "Ultimate", "Life", "Form", "Android",
	"Cyber", "Adult", "Rune", "Mystic", "Dumpy", "Lumpy", "Dopey", "Bashful", "Grumpy", "Sleepy", "Sneezy",
	"Doc", "Little", "Large", "Clap", "Among", "Amon", "Us", "Gus", "Sans", "Papyrus", "Paper", "Mache", "Macho",
	"Perfume", "Spray", "Bottle", "Purple", "Violet", "Indigo", "Lavender", "Magenta", "Brilliant", "Diamond",
	"Cerulean", "Carnation", "Cerise", "Blossom", "Coral", "Cyclamen", "Deep", "Space", "Snack", "Midnight",
	"Cool", "Inky", "Stinky", "Blinky", "Pokey", "Clyde", "Punk", "Rock", "Roll", "Millie", "Adriel", "Lalhs",
	"Voxel", "Rio", "Larry", "Doggo", "Alter", "Alternate", "Doll", "Balls", "Lead", "Poisoning", "Flaming",
	"Matrix", "Chuck", "Norris", "Ninja", "Rubius", "Alexelcapo", "Hutts", "Sla", "Chemi", "Gaming", "Mario",
	"Exe", "Knight", "Fazbear", "Justin", "Bieber", "Fort", "Nite", "Wizard", "Harry", "Potter", "Greg", "Mommy",
	"Daddy", "Eater", "Veggies", "Goku", "Vegeta", "Naruto", "Grizzco", "Small", "Fri", "Gabriel", "Uriel", "Shot",
	"Optimus", "Prime", "Mad", "Mew", "Mewmew", "Chill", "Pika", "Chu", "Gato", "Marki", "Plier", "Moo", "Pewdie", "Only",
	"Fans", "Solomon", "Salmon", "Pipo", "Fucker", "Boyfriend", "Girlfriend", "Husband", "Wife", "Luigi", "Link",
	"Inkling", "Octoling", "Marie", "Callie", "Marina", "Frye", "Shiver", "Harmony", "Woman", "Boy", "Girl", "Wario",
	"Waluigi", "Minion", "Infernal", "Meggy", "Jotaro", "Dio", "Zelda", "Ganon", "Daisy", "Rosalina", "Pauline", "Bowser",
	"Roy", "Lemmy", "Wendy", "Donald", "King", "Mother", "Iggy", "Pop", "Morton", "Ludwig", "Beethoven", "Jet", "Set", "Radio",
	"Love", "Bunny", "Plum", "Virus", "Troll", "Tactical", "Burrito", "Not", "Your", "Saggitarius", "Ghospe",
	"Grinch", "Santa", "Claus", "Satan", "Peter", "Griffin", "Simpson", "McMillen", "Lukii", "Moi", "Chris", "Pratt",
	"Spider", "Imp", "Frog", "Kilburn", "Kill", "Dragon", "Valentine", "Lord", "Remiem", "Wii", "Lizard", "Worm", 
	"Insect", "Rat", "Soppy", "Leonardo", "Dicaprio", "Robot", "Open", "Legendary", "Ass", "Butthead", "Chonker",
	"Chowder", "Emdes", "Doctor", "Angel", "Mage", "Hat", "Fury", "Hound", "Demon", "Thicc", "Spam", "Ton", "Brother",
	"Sister", "Uncle", "Auntie", "Xeno", "Blade", "Orange", "Rhymes", "Busta", "Cave", "Story", "Nicalis", "Sprite", "Pixie",
	"Elf", "Gnome", "Goblin", "Hob", "Fae", "Gremlin", "Nymph", "Siren", "Genie", "Mojo", "Jojo", "Buttercup", "Grim", "Reaper",
	"Fruity", "Pebbles", "Meduka", "Meguca", "Senyi", "Bayo", "Netta", "Mediocre", "Kris", "Ralsei", "Tingle", "Goofy", "Crash",
	"Rag", "Shah", "Emperor", "Empress", "Witch", "Hole", "Crevice", "Tweet", "Kit", "Nik", "Argyle", "Burnt", "Winner",
	"Cheese", "Cracker", "Horse", "Explorer", "Feather", "Filthy", "Rich", "Gizmo", "Glad", "Grub", "Hard", "Hoity", "Bub",
	"Carrot", "Mud", "Bumpkin", "Fritter", "Honey", "Candy", "Tart", "Peachy", "Delicious", "Golden", "Gustavo", "Fring",
	"Avalon", "Beauty", "Brass", "Dreams", "Peppy", "Preppy", "Lazy", "Smug", "Cranky", "Jock", "Sporty", "Normal", "Snooty",
	"Bizarre", "Strange", "Dead", "Sunil", "Comet", "Cometz", "Snake", "Block", "Maria", "Fuyucchi", "Vermin", "Titanium", "Grunt", 
	"Pseudo", "Julia", "Funk", "Engine", "Oro", "Ori", "Xalum", "Sin", "Ferrium", "Erfly", "Erf", "Creeps", "Jaydee", "Pixel",
	"Guillotine", "Taiga", "Treant", "Red", "Rachis", "Yellow", "Jerb", "Guwa", "Guwah", "Havel", "Ren", "Bud", "Budj", "Elemental",
	"Blor", "Blorenge", "Web", "Bustin", "Blotch", "Sbody", "Connor", "Teal", "Thx", "Jordy", "Infinity", "Poyo", "Peribot", "Hairy", "Resonant",
	"Moof", "Cipher", "Danial", "Dastarod", "Dasta", "Rod", "Gabe", "Honeyfox", "Barack", "Obama", "Eden", "Circus", "Lung", "Poster", "Goodposter",
	"Boi", "Gal", "Pal", "Dull", "Mern", "Corn", "Husk", "Kernel", "Maize", "Mustang", "Fend", "Frond", "Fient", "Mi", "Secret",
	"Flysaac", "Baphomet", "Yugi", "Bisexua", "Greeb", "Randy", "Rufus", "Jaina", "Barkliel", "Cheat", "Homestar", "Runner",
	"Crest", "Beam", "Clop", "Mid", "Night", "Mare", "Dark", "Drop", "Freeze", "Bush", "Shine", "Short", "Tall", "Long", "Fat",
	"Chunky", "Skinny", "Aqua", "Marine", "Aquamarine", "Spirit", "Wander", "Drunk", "Driving", "Emerald", "Glow", "Shimmer",
	"Beats", "Jersey", "Legacy", "Seed", "Onyx", "Ever", "Brisk", "Whiskers", "Uper", "Wild", "Bones", "Bony", "Basement",
	"Tide", "Flame", "Frozen", "Cold", "Icky", "Spit", "Joe", "Mama", "Jorts", "Many", "Fancy", "Child", "Son", "Daughter",
	"Sunrise", "Dusk", "Dawn", "Wriggle", "Justice", "Viridian", "Pretty", "Clearing", "Forest", "Incredible", "Hulk", "Bulk",
	"Amazing", "Wonderful", "Wonderous", "Gorgeous", "Rough", "Popular", "Teen", "Tender", "Bumbling", "Bumble", "Rocket",
	"Kira", "Sisko", "Quark", "Odo", "Julian", "Riker", "Will", "Beverly", "Troi", "Deanna", "Worf", "Data", "Paris", "Loaf",
	"Crumb", "Pecan", "Almond", "Activated", "Tain", "Hungry", "Mund", "Lot", "Pig", "Tenrec", "Fennec", "Pony", "Beetle",
	"Wiki", "Pedia", "Game", "Dump", "Truck", "Pail", "Fail", "Pog", "Pogger", "Loopy", "Zoomy", "Boop", "Beep", "Flop",
	"Zip", "Zap", "Zoop", "Scarf", "Skirt", "Shirt", "Girly", "Boyish", "Tomboy", "Trans", "Hot", "Fun", "Amazon", "Liver",
	"Bitch", "Bitchy", "Lesbian", "Queer", "Coder", "Coded", "Posh", "Poor", "Horn", "Horny", "Artist", "Powerful", "Alpha",
	"Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi",
	"Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega", "Source", "Team", "Fortress", "Brian", "Ender", "Ghast",
	"Zombie", "Plant", "Mulch", "Fish", "Dish", "Madoka", "Oka", "Electric", "Treat", "Treats", "Suck", "Let", "Peep", "Peepy",
	"Poop", "Pee", "Piss", "Shit", "Tickle", "Cortex", "Caca", "Fart", "Gurgle", "Snuggle", "Cuddle", "Snuggly", "Cuddly",
	"Pumpkin", "Sugar", "Spice", "Suga", "Universe", "Galaxy", "Steven", "Steve", "Wrinkle", "Neo", "Proof", "Splot", "Splat",
	"Fest", "Furry", "Scaly", "Bumpy", "Bouncy", "Lousy", "Stupid", "Genius", "Detective", "Detector", "Wright", "Phoenix",
	"Science", "Math", "Language", "Literate", "Wood", "Wooden", "Metal", "Sparkly", "Spark", "Sparky", "Killer", "Jeff",
	"New", "Old", "Flour", "Scotch", "Snax", "Hopper", "Bung", "Shishka", "Crispy", "Snak", "Pod", "Weeny", "Strabby", "Tick",
	"Tock", "Inch", "Wrap", "Mewo", "Pinkle", "Pickle", "Root", "Peel", "Banana", "Sando", "Pede", "Sub", "Twisty", "Wee",
	"Quetta", "Ronna", "Yotta", "Zetta", "Exa", "Peta", "Tera", "Giga", "Mega", "Kilo", "Hecto", "Deca", "Deci", "Centi",
	"Milli", "Micro", "Nano", "Pico", "Femto", "Atto", "Zepto", "Yocto", "Ronto", "Quecto", "Second", "Metre", "Gram", "Ampere",
	"Kelvin", "Mole", "Candela", "Radian", "Hertz", "Newton", "Pascal", "Joule", "Watt", "Coulomb", "Volt", "Farad", "Ohm",
	"Siemens", "Weber", "Tesla", "Henry", "Degree", "Celsius", "Fahren", "Heit", "Lumen", "Lux", "Becquerel", "Gray", "Sievert",
	"Katal", "Square", "Triangle", "Circle", "Sphere", "Cube", "Pyramid", "Cone", "Rhombus", "Lost", "Artifact", "Baja", "Roach",
	"Taco", "Crap", "Grape", "Skeeto", "Kwee", "Kawaii", "Sugoi", "Lovely", "Lover", "Antula", "Tar", "Razz", "Quiri", "Snaq",
	"Tropica", "Waff", "Stack", "Chee", "Ful", "Mite", "Maki", "Nood", "Ger", "Pale", "Toss", "Grande", "Banop", "Per", "Sherb",
	"Ie", "Y", "Barbeque", "Crystal", "Puffy", "Ribble", "Penyo", "Scor", "Spud", "Dy", "Lol", "Ino", "Buffalo", "Cust", "Er",
	"Rito", "Incher", "Loaded", "Meaty", "Supreme", "Moth", "Za", "Prey", "Pred", "Ator", "Ing", "Pepper", "Kisses", "Sodie",
	"Bop", "Sicle", "Char", "Mallow", "Marsh", "Cinna", "Snail", "Mon", "Kwoo", "Kie", "Hunna", "Nutty", "Agg", "Legs", "Cheer",
	"Chilly", "Nilly", "Willy", "Wily", "Chip", "Jam", "Insta", "Melty", "Mountain", "Scoop", "Stew", "Ler", "Celly", "Stix",
	"Chedda", "Boardle", "Chedd", "Adorable", "Adorb", "Claw", "Deviled", "Mochi", "Coffee", "Tea", "Hider", "Spag", "Tikka",
	"Masala", "Korma", "Curry", "Cappu", "Ccino", "Cirno", "Reimu", "Haku", "Rei", "Sakuya", "Marisa", "Kiri", "Same", "Flandre",
	"Scarlet", "Iza", "Yoi", "Hong", "Kong", "Mei", "Ling", "Gara", "Sakyu", "Basu", "Ouro", "Boros", "Soul", "Ghost", "Spook",
	"Rip", "Bozo", "Pack", "Watch", "Rest", "In", "Peace", "War", "Monger", "Over", "Kart", "Odie", "Nermal", "Al", "Sadly", "Just",
	"Chaos", "Order", "Nya", "Neko", "Arc", "Arctic", "Peas", "Pea", "Pix", "Face", "Book", "Twit", "Twat", "Gordon", "Barney",
	"Adrian", "Free", "Cal", "Houn", "Shep", "Herd", "Gina", "Cross", "Colette", "Rosen", "Berg", "Chell", "Gla", "Dos", "Nyam",
	"Naff", "Nip", "Nipper", "Nipple", "Ryan", "Bronze", "James", "Silver", "Boss", "Admiral", "Captain", "Commander", "Lieutenant",
	"General", "Major", "Colonel", "Sergeant", "Corporal", "Private", "Enemy", "Ally", "Dasher", "Dance", "Dancer", "Prancer",
	"Vixen", "Cupid", "Dunder", "Blixem", "Donder", "Blitzen", "Zen", "Floss", "Flossie", "Gloss", "Glossie", "Racer", "Pacer",
	"Reck", "Reckless", "Speck", "Speckless", "Fear", "Fearless", "Peer", "Pearless", "Less", "More", "Ready", "Steady",
	"Rudolph", "Ness", "Lucas", "Ninten", "Do", "Paula", "Poo", "Duster", "Kuma", "Tora", "Ana", "Teddy", "Pippi", "Lloyd",
	"Mary", "Bab", "Table", "Array", "Java", "Lua", "Squirrel", "Carpet", "Towel", "Beach", "Tastie", "Tasty", "Muncher",
	"Chair", "Freaking", "Uncanny", "Canny", "Jolly", "Holly", "Ellie", "Diddy", "Donkey", "Wrinkly", "Dixie", "Swanky", 
	"Puncher", "Lanky", "Kiddy", "Dinky", "Mouse", "Crypto", "Ape", "Gone", "Phony", "Prix", "Gobbler", "Swallower", "Guzzler",
	"Gulper", "Glizzy", "Glizz", "Lipstick", "Powder", "Lip", "Stick", "Eye", "Liner", "Eyeliner", "Primer", "High", "Low",
	"Right", "Left", "Bus", "Glossy", "Puss", "Dirt", "Mudd", "Facial", "Balm", "Mascara", "Polish", "Blush", "Napalm", "Tube",
	"Pipe", "Cigar", "Cigarette", "Ette", "Esque", "Itis", "Oval", "Medic", "Ine", "Ike", "Bike", "Like", "Town", "City", "Village",
	"Fukka", "Shidda", "Mudda", "Up", "Down", "Mine", "Craft", "Brown", "Brick", "Mercedes", "Benz", "Baa", "Ken", "Tucky", "Fried",
	"Ryu", "Kentucky", "Chicken", "Chick", "Cock", "Rooster", "Grid", "Entity", "Badage", "Smitty", "Werben", "Jager", "Jensen",
	"Croc", "Bootleg", "Shitty", "Pitiful", "Knuckles", "Cursed", "Mammon", "Icarus", "Buta", "Dawg", "Bertran", "Dante", "Charon",
	"Leon", "Sarah", "Glare", "Job", "Slippy", "Slip", "Slurp", "Slurpy", "Boring", "Larp", "Male", "Female", "Yiik", "Balgor", "Guillo",
	"Frozee", "Jones", "Enabler", "Chaser", "Dory", "Sword", "Chibis", "Jub", "Mod", "Dogma", "Drag", "On", "Frag", "Grenade",
	"Original", "Ordinary", "Quest", "Sensual", "Adventure", "Advent", "Ure", "Com", "Bat", "Combat", "Tyler", "Hess", "Reformed",
	"Ortho", "Dox", "Rab", "Bi", "Ex", "Priest", "Bill", "Clin", "Nye", "Re", "Qual", "Ity", "Quality", "Chunk", "O", "Oh", "Ah",
	"Jonathan", "Joseph", "Josuke", "Giorno", "Jolyne", "Joestar", "Athan", "Seph", "Suke", "Gi", "Orno", "Jo", "Lyne", "Stink",
	"Stank", "Prank", "Gunk", "Trunk", "Alot", "Salot", "Salad", "Bup", "Bap", "Homet", "Bark", "Liel", "Iroth", "Iroh", "Roth",
	"Grink", "Grunch", "Gronk", "Gonk", "Pad", "Freaker", "Freak", "Heat", "Blast", "Mutt", "Grey", "Matter", "Four", "Arms",
	"One", "Two", "Three", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Hundred", "Thousand", "Million",
	"Billion", "Trillion", "Goog", "Google", "Plex", "Ile", "Jaws", "Upgrade", "Grade", "Cannon", "Vine", "Ketchup", "Mustard",
	"Mayo", "Mayonnaise", "Wor", "Cester", "Spitter", "Buzz", "Shock", "Day", "Month", "Year", "Guana", "Blitz", "Wolf", "Wolfer",
	"Luck", "Ben", "Snare", "Mummy", "Franken", "Strike", "Stein", "Guy", "Way", "Ditto", "Dit", "Swamp", "Echo", "Humung", "Osaur",
	"Ray", "Storm", "Chroma", "Goop", "Goo", "Ber", "Gaa", "Gu", "Ga", "Ba", "Bo", "Be", "Alien", "Mech", "Lode", "Rath", "Fibian",
	"Armo", "Drillo", "Terra", "Spin", "Fast", "Track", "Cham", "La", "Le", "Li", "Lo", "Lu", "Clock", "Work", "Squatch", "Jury", "Rig",
	"Feed", "Back", "Blox", "Grav", "Atta", "Dope", "Vil", "Walka", "Trout", "Pesky", "Stache", "Worst", "Best", "Kick", "Tavo", "Astro",
	"Dactyl", "Bull", "Ix", "Ax", "Ox", "Ux", "Rot", "Gut", "Wham", "Pire", "Rosa", "Lina", "Parks", "Wa", "Wack", "Tato", "Mick", "Mickey",
	"Jay", "Dee", "Leno", "Gadget", "Inspector", "Mike", "Eel", "Mun", "Pai", "Wo", "Paws", "Boog", "Virtue", "Virtuous", "Virt", "Uous",
	"Reso", "Nant", "Bandi", "Coot", "Band", "Steam", "Deck", "Genshin", "Impact", "Gen", "Shin", "Im", "Club", "Penguin", "Guzz", "Brap",
	"Fork", "Guff", "Poot", "Plap", "Pap", "Knife", "Spoon", "Kirb", "Kirby", "Waddle", "Doo", "De", "Zorua", "Smeag", "Smea", "Gle",
	"Skit", "Skitty", "Bomber", "Kir", "Cereza", "Cere", "Bayonetta", "Medli", "Melody", "Simple", "Shiny", "Accel", "Acceler", "Accele",
	"Rando", "Alle", "Allegro", "Gro", "Ballad", "Bari", "Tone", "Note", "Tune", "Que", "Baro", "Cant", "Tana", "Chord", "Clef", "Coda",
	"Wuggy", "Guorf", "Guorfen", "Rico", "Hate", "Hater", "Bresh", "Pung", "Fingle", "Phat", "Sum", "Phatsum", "Finglebar", "Springboi",
	"Genestro", "Gene", "Stro", "Vore", "Quinn", "Flowey", "Firend", "Race", "Train", "Stroke", "Skele", "Lovania", "Vania", "Chan",
	"Catastro", "Cata", "Megalo", "Deer", "Dolph", "Dolphin", "Appa", "Apa", "Thy", "Opt", "Ions", "Ion", "Portal", "Leak", "Athon",
	"Empty", "Cracked", "Astral", "Jar", "Dad", "Maxer", "Maxing", "Max", "Min", "Hedgehog", "Hedge", "Hog", "Mobius", "Needle",
	"Ivo", "Olgilvie", "Olgil", "Maurice", "Vie", "Ilvie", "Ol", "Penders", "Lara", "Su", "Akio", "Sue", "Lin", "Oily", "Spoily",
	"Patch", "Octo", "Cuttle", "Darth", "Jedi", "Sith", "Maul", "Vader", "Mando", "Yoda", "Twink", "Twerk", "Butch", "Masc", "Femme",
	"Fem", "Andro", "Gyno", "Himbo", "Bimbo", "Thembo", "Thimble", "Nancy", "Biden", "Hunted", "Pope", "Oy", "Vey", "Crag", "Craig",
	"Elder", "Sea", "Nostalgia", "Critic", "Damned", "Video", "Nerd", "Fukkas", "Neva", "Lern", "Hati", "Ati", "Birth", "Birthday",
	"Christmas", "Raid", "Legend", "Legends", "Prince", "Pitbull", "Jerma", "Jeremy", "Pablo", "Cookie", "Cook", "Chef", "Chimp",
	"Gorilla", "Bonobo", "Orangutan", "Orang", "Utan", "Hotdog", "Dong", "Konkey", "Expand", "Donger", "Biker", "Ivan", "Tainted",
	"Tarnished", "Blessed", "Bacteria", "Click", "Amoeba", "Phage", "Clickbait", "Prankster", "Morshu", "Gwonam", "Gobbo", "Gob",
	"Squadala", "Squad", "Ala", "Hype", "Canker", "Sore", "Eddy", "Drip", "Fuddy", "Duddy", "Grouch", "Joy", "Mal", "Lordy",
	"Content", "Monke", "Scot", "Soldier", "Pyro", "Maniac", "Demo", "Demoman", "Heavy", "Engineer", "Engie", "Sniper", "Spy",
	"Lite", "Paul", "Pauling", "Announcer", "Civilian", "Merc", "Mercenary", "Civ", "Mann", "Redmond", "Mond", "Blu", "Blutarch",
	"Tarch", "Sax", "Saxton", "Hale", "Hail", "Forgor", "Concert", "Crescendo", "Cresc", "Endo", "Capo", "Elegy", "Etude", "Ensemble",
	"Flat", "Forte", "Fuck", "Fugue", "Gigue", "Gig", "Gue", "Grue", "Gru", "Gio", "Coso", "Gliss", "Ando", "Hymn", "Rhyme", "Tomb",
	"Womb", "Chest", "Boob", "Booby", "Tit", "Tidy", "Nation", "Into", "Land", "Jig", "Gate", "Largo", "Legato", "Mezzo", "Minuet",
	"Revolver", "Octave", "Obbli", "Octet", "Quartet", "Opus", "Ocelot", "Ture", "Par", "Tita", "Livid", "Haver", "Wanter", "Desire",
	"Mono", "Di", "Tri", "Tetra", "Penta", "Hexa", "Hepta", "Octa", "Ennea", "Deco", "Hendeca", "Dodeca", "Icosa", "Conta", "Kai",
	"Hexo", "Chilia", "Myria", "Nona", "Quadra", "Quinta", "Sexta", "Quattuor", "Quinque", "Sex", "Septen", "Novem", "Vigin", "Ti",
	"Ta", "Te", "To", "Ginti", "Vi", "Gender", "Sexual", "Sexua", "Social", "Ition", "Ual", "Bingus", "Spoingus", "Zabloing", "Zamn",
	"Bing", "Spoin", "Bloing", "Michael", "Smudge", "Floppa", "Chilling", "Duck", "Tiger", "Lion", "Mule", "Emu", "Lator", "Later",
	"Badger", "Bubsy", "Akbar", "Azim", "Molloy", "Druid", "Vampire", "Vamp", "Synopsis", "Eric", "Andre", "Flavius", "Foundation",
	"Patriot", "Laurent", "Rent", "Madeleine", "Madel", "Eine", "Magnus", "Woop", "Supper", "Jenikens", "Chronicle", "Might",
	"Essence", "Destruction", "Roaming", "Swordsman", "Nasty", "Banquote", "Boys", "Girls", "Who", "Whom", "Whomst", "Wagh", "Ough",
	"Ha", "He", "Hi", "Ho", "Hu", "Pleasant", "Comb", "Grab", "Grabber", "Clasp", "Catch", "Hold", "Acquire", "Acquirer", "Holding",
	"Holder", "Catcher", "Bugulon", "Zili", "Zirc", "Noshi", "Noppy", "Notsu", "Frap", "Frappa", "Liam", "Timo", "Mugo", "Doki",
	"Nom", "Mido", "Rina", "Yokko", "Yok", "Ko", "Iji", "Shou", "Shouko", "Remi", "Cedric", "Kayle", "Ynna", "Wollen", "Shelie",
	"Mango", "Lumo", "Amas", "Bon", "Dor", "Kur", "Ago", "Me", "Go", "Rae", "Sen", "Ven", "Stella", "Doop", "Morto", "Tula",
	"Kura", "Dormi", "Feli", "Co", "Ca", "Cia", "Pogo", "Dumple", "Tul", "Krii", "Vid", "Hin", "Sio", "Tib", "Bin", "Rick",
	"Morty", "Summer", "Autumn", "Fall", "Winter", "Solstice", "Sol", "Stice", "Mercury", "Venus", "Luna", "Mars", "Jupiter",
	"Saturn", "Uranus", "Neptune", "Ceres", "Pluto", "Orcus", "Sala", "Hau", "Mea", "Qua", "Oar", "Make", "Gong", "Eris", "Sedna",
	"Ganymede", "Gany", "Mede", "Titan", "Io", "Europa", "Eur", "Opa", "Callisto", "Call", "Isto", "Rhea", "Iapetus", "Enceladus",
	"Encel", "Adus", "Dione", "Mimas", "Meme", "Calypso", "Verse", "Galactic", "Multi", "Versus", "Inter", "Extra", "National",
	"Epi", "Hypo", "Tacular", "Suppa", "Tastic", "Fan", "Ular", "Smut", "Some", "Voyager", "Sis", "Bro", "Cis", "Hetero", "Homo",
	"Atari", "Sega", "Nintendo", "Microsoft", "Sony", "Phillips", "Jaguar", "Lynx", "Panther", "Porn", "Entertainment", "System",
	"Headmate", "Gamecube", "Switch", "Play", "Station", "Playstation", "Intel", "Intelli", "Vision", "Coleco", "Odyssey",
	"Geo", "Magna", "Vox", "Pana", "Hyper", "Amiga", "Commo", "Dore", "Vec", "Trex", "Dreamcast", "Cast", "Genesis", "Drive",
	"Famicom", "Multiplayer", "Player", "Nova", "Enby", "Non", "Binary", "Decimal", "Barb", "Arian", "Barbarian", "Bard",
	"Cleric", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wiz", "Artificer", "Hunter", "Shooter",
	"Heel", "Blood", "Milk", "Water", "Soda", "Dady", "Creamy", "Milky", "Flood", "Bloody", "Tear", "Tears", "Clone", "Hummus",
	"Falafel", "Fala", "Fel", "Fella", "Girth", "Width", "Height", "Length", "Kip", "Kis", "Him", "Her", "Kil", "Pike", "Oid",
	"Sal", "Picard", "Card", "Kirk", "Spock", "Knives", "Presto", "Piano", "Tired", "Oneshot", "Cud", "Girlboss", "Gaslight",
	"Gatekeep", "Api", "Library", "Lib", "Rary", "Afterbirth", "Repentance", "Revelations", "Rebirth", "Alphabirth", "Wrath",
	"Lamb", "Lust", "Gluttony", "Envy", "Sloth", "Dang", "Greed", "Pride", "Famine", "Pestilence", "Pollution", "Deluge",
	"Meltdown", "Propaganda", "Imperialism", "Imperial", "Gaper", "Goat", "Goatse", "Tank", "Support", "Heal", "Slut", 
	"Offense", "Defence", "Chungus", "Scrungus", "Clunka", "Chemical", "Romance", "Stardust", "Speedway", "Escape", "Zone",
	"Something", "Awful", "Size", "Apiary", "Gulp", "Gulps", "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra",
	"Scorpio", "Capricorn", "Aquarius", "Pisces", "Virgin", "Pork", "Beef", "Poultry", "Venison", "Condensed", "Limited",
	"Edition", "Sweetened", "World", "Yoshi", "Pikmin", "Glutton", "Metroid", "Lewd", "Olimar", "Louie", "President", "Alph",
	"Brittany", "Charlie", "Bulborb", "Borb", "Ship", "Sails", "Sales", "Pitch", "Yaw", "Smoker", "Blazer", "Blaze",
	"Gossamer", "Enchanted", "Whisper", "Breeze", "Mist", "Petal", "Dewdrop", "Sunbeam", "Moonbeam", "Newell", "Index",
	"Starlight", "Lily", "Bamboo", "Briar", "Stream", "Lake", "Giggle", "Snicker", "Chuckle", "Guffaw", "Belch", "Hiccup",
	"Burp", "Toot", "Snort", "Chirp", "Squawk", "Caw", "Hoot", "Meow", "Woof", "Oink", "Sunlight", "Moonlight", "Evergreen",
	"Diaper", "Nappy", "Plastic", "Plastics", "Microplastics", "Ghees", "Gheesling", "Fidget", "Dragger", "Smeg", "Geese",
	"Goose", "Bungo", "Hook", "Hand", "Screamer", "Skater", "Walker", "Driver", "Sleeper", "Kicker", "Smoocher", "Shocker",
	"Climber", "Sadder", "Licker", "Sticker", "Stinker", "Slinker", "Swinger", "Drinker", "Rayman", "Globox", "Glo", "Wug",
	"Snug", "Rug", "Hug", "Box", "Boxx", "Boxer", "Boxed", "Boxing", "Lemonade", "Limeade", "Lime", "Sus", "Suspicious",
	"Suspect", "Sussy", "Murder", "Murderous", "Modern", "Vintage", "Retro", "Medusa", "Usual", "Abnormal", "Unusual",
	"Genuine", "Prissy", "Pissy", "Haunted", "Spooky", "Collector", "Decorated", "Community", "Valve", "Software", "Hardware",
	"Typical", "Atypical", "Neural", "Neuro", "Divergent", "Fig", "Wig", "Dig", "Porg", "Tranz", "Transgender", "Supportive",
	"Valid", "Real", "Important", "Self", "Made", "Maiden", "Steward", "Foster", "Parent", "Chilled", "Epiphany", "Retribution",
	"Slave", "Deliverance", "Forgotten", "Fables", "Fabled", "Harlequin", "Harlem", "Quid", "Pro", "Professional", "Profitable",
	"Profit", "Able", "Abled", "Hamud", "Habibi", "Party", "Celebration", "Letter", "Media", "Commitment", "Distinctive",
	"Distinct", "After", "Aged", "Simulator", "Tycoon", "Binding", "Isaac", "Piece", "Planet", "Lunar", "Moony", "Moons",
	"Mooninite", "Ordinal", "Extraordinary", "Abundance", "Tinge", "Injustice", "Drably", "Air", "Debonair", "Balaclava",
	"Forever", "Operator", "Overalls", "Imaginary", "Finite", "Transfinite", "Oman", "Opal", "Indubitably", "Muskel",
	"Noble", "Hatter", "Peculiar", "Peculiarly", "Drab", "Tincture", "Hell", "Heaven", "Bitter", "Taste", "Defeat",
	"Gentleman", "Business", "Pants", "Trousers", "Shart", "Shirts", "Sport", "Coins", "Sports", "Balling", "Rustic", "Olde",
	"Value", "Teamwork", "Waterlogged", "Logged", "Labs", "Coat", "Vest", "Crass", "Drift", "Drifter", "Float", "Floater",
	"Stutter", "Fluttering", "Glide", "Glider", "Pilot", "Wings", "Sailor", "Swoop", "Swooper", "Swooping", "Shooting",
	"Stars", "Starstruck", "Struck", "Whiz", "Whizzer", "Beano", "Dandy", "Beezer", "Topper", "Chips", "Fries", "Borglar",
	"Burgler", "Burgers", "Pizzas", "Pizzazz", "Insected", "Aphid", "Insectoid", "Butterfly", "Mothra", "Roached", "Dragonfly",
	"Flea", "Fruit", "Fruitful", "Fruiting", "Gnat", "Midge", "Lovebug", "Ladybug", "Ladybird", "Mile", "Pest", "Ticked", "Yard",
	"Arth", "Arthro", "Arach", "Nid", "Arachnid", "Cootie", "Hornet", "Louse", "Longlegs", "Logs", "Praying", "Mantis", "Yeller",
	"Jacket", "Belly", "Stomach", "Throat", "Shoulder", "Gall", "Bladder", "Kidney", "Muscle", "Buff", "Eyeball", "Nose", "Bile",
	"Organ", "Devilled", "Harvester", "Harvest", "Gaping", "Glory", "Morning", "Noon", "Enter", "Afternoon", "Evening", "Midas",
	"Infer", "Infra", "Intra", "Dimensional", "Cosmological", "Logical", "Cosmo", "Dimension", "Power", "Colossal", "Considerable",
	"Enormous", "Gigantic", "Full", "Hefty", "Huge", "Immense", "Massive", "Sizable", "Substantial", "Tremendous", "Vast",
	"Ample", "Bulky", "Burly", "Capacious", "Copious", "Extensive", "Hulking", "Husky", "Jumbo", "Mondo", "Monsta", "Ponderous",
	"Strapping", "Stuffed", "Voluminous", "Walloping", "Whopper", "Whopping", "Meager", "Miniature", "Minuscule", "Modest",
	"Paltry", "Slight", "Bantam", "Diminutive", "Petite", "Petty", "Scanty", "Shrimp", "Trifling", "Toy", "Bitty", "Piddling",
	"Pitboss", "Pint", "Puny", "Runt", "Runty", "Scrubby", "Stunted", "Teensy", "Stunt", "Trivial", "Dank", "Peanut", "Snub",
	"Shoe", "Shoestring", "String", "Boot", "Memes", "Memer", "Casual", "Formal", "Dainty", "Elfin", "Minikin", "Kin",
	"Smallish", "Delicate", "Elegant", "Ether", "Ethereal", "Exquisite", "Grace", "Graceful", "Lacy", "Neat", "Tasting",
	"Tasteful", "Choice", "Darling", "Delicacy", "Fair", "Frail", "Loved", "Pleasing", "Tinder", "Trim", "Bonny", "Nudist",
	"Charming", "Charm", "Charmer", "Comely", "Delectable", "Delight", "Delightful", "Feeble", "Palatable", "Precious",
	"Rarest", "Rarer", "Raring", "Refined", "Reclaimed", "Scrap", "Select", "Soft", "Subtle", "Comfy", "Comfortable",
	"Cotton", "Easy", "Elastic", "Cottony", "Mushy", "Mush", "Silky", "Silk", "Spongy", "Supple", "Velvety", "Cushion",
	"Pillow", "Cushiony", "Pillowy", "Cushy", "Slutty", "Downy", "Ductile", "Fleece", "Feathery", "Flabby", "Flab", "Fine",
	"Fleecy", "Flimsy", "Furrier", "Pappy", "Pithy", "Pulpy", "Quaggy", "Satin", "Satiny", "Pulp", "Silken", "Squashy",
	"Named", "Name", "Half", "Quarter", "Swan", "Swanson", "Ripper", "Donut", "Nutting", "Victoria", "Ice", "Icing",
	"Frosting", "Frosted", "Flakes", "Mulcher", "Merchant", "Nuclear", "Nuke", "Accursed", "Blursed", "Throne",
	"Sacrifice", "Sacrificial", "Laser", "Shotgun", "Pistol", "Computer", "Rifle", "Assault", "Battery", "Salt",
	"Salty", "Salted", "Sugary", "Sugared", "Peppa", "Peppery", "Peppered", "Pickled", "Hidden", "Camera", "Secrete",
	"Secretly", "Wash", "Awash", "Shower", "Odor", "Deodorant", "Odorant", "Curtain", "Bong", "Fellowship", "Tap",
	"Unicorn", "Keebler", "Crackle", "Snap", "Reap", "Faucet", "Issue", "Warm", "Pave", "Ment", "Pavement", "Okay",
	"Okie", "Dokie", "Deagle", "Snipper", "Personal", "Weapon", "Clip", "Clipper", "Bra", "Direct", "Apply", "Roid",
	"Marble", "Labyrinth", "Final", "Bridge", "Jungle", "Ground", "Gimmick", "Scrambled", "Aquatic", "Casino", "Oil",
	"Ocean", "Metro", "Metropolis", "Polis", "Chase", "Palm", "Palmtree", "Panic", "Collision", "Tidal", "Tempest",
	"Quadrant", "Workbench", "Bench", "Metallic", "Madness", "Turquoise", "Gigalopolis", "Gigalo", "Mecha", "Sleeping",
	"Lava", "Powerhouse", "Machine", "Showdown", "Island", "Hydro", "Hydrocity", "Garden", "Carnival", "Launch", "Mushroom",
	"Flying", "Sandopolis", "Reef", "Palace", "Sanctuary", "Doomsday", "Sunset", "Meta", "Junglira", "Robotnik", "Atomic",
	"Destroyer", "Isolated", "Botanic", "Slider", "Speed", "Arena", "Techno", "Tower", "Entrance", "Rail", "Canyon", "Ruin",
	"Castle", "Poloy", "Volcanic", "Tunnel", "Polly", "Rocky", "Cavern", "Caron", "Battle", "Flicky", "Cucky", "Pecky",
	"Picky", "Pocky", "Ricky", "Grove", "Rusty", "Stadium", "Valley", "Puppet", "Resort", "Regal", "Centrist", "Leftist",
	"Reactive", "Radiant", "Coast", "Windy", "Casinopolis", "Highway", "Shelter", "Carrier", "North", "South", "West",
	"East", "Relix", "Aero", "Aerobase", "Last", "Chaotic", "Prison", "Lane", "Harbor", "Mission", "Steret", "Route",
	"Eternal", "Meteor", "Dry", "Lagoon", "Quarters", "Colony", "Weapons", "Bed", "Security", "Hall", "Core", "Chao",
	"Music", "Paradise", "Area", "Depot", "Summit", "Emerl", "Gemerl", "Seaside", "Bingo", "Bullet", "Hang", "Mansion",
	"Fleet", "Snow", "Sleet", "Altar", "Aggression", "Aggressive", "Wave", "Exception", "Mirage", "Altitude", "Crisis",
	"Line", "Unknown", "Known", "Westopolis", "Digital", "Glyphic", "Lethal", "Cryptic", "Central", "Doom", "Troops",
	"Ark", "Gun", "Haunt", "Finder", "Found", "Find", "Splash", "Desert", "Babylon", "Guardian", "Dual", "Theater",
	"Illusion", "Dusty", "Acropolis", "Acro", "Tropical", "Kingdom", "Serf", "Smurf", "Prologue", "Oasis", "Dinosaur",
	"Foundry", "Levitated", "Pirate", "Skeleton", "Dome", "Blizzard", "Swell", "Wisp", "Whisk", "Aquarium", "Asteroid",
	"Coaster", "Terminal", "Velocity", "Rooftop", "Apotos", "Windmill", "Mill", "Spagonia", "Mazuri", "Savannah", "Nah",
	"Citadel", "Holoska", "Edge", "Chun", "Nan", "Shamar", "Arid", "Skyscraper", "Scamper", "Adabat", "Joyride", "Eggman",
	"Silent", "Studio", "Studiopolis", "Press", "Saloon", "Titanic", "Monarch", "Reverie", "Boiled", "Dino", "Saur",
	"Kronos", "Ares", "Ouranos", "Sylvania", "Cobbler", "Gib", "Giblet", "Johnson", "Pecker", "Shaft", "Tool", "Beaver",
	"Muff", "Snatch", "Canoe", "Clar", "Minister", "Satanic", "Catholic", "Cath", "Cuteness", "Bloomer", "Bloomers",
	"Undies", "Undyne", "Toriel", "Metta", "Mettaton", "Spamton", "Mess", "Messy", "Mesi", "Merge", "Leela", "Leet",
	"Request", "Insurance", "Deal", "Dealer", "Deals", "Cheap", "Silt", "Birdy", "Pub", "Babby", "Salacious", "Decent",
	"Indecent", "Obscene", "Prunient", "Prude", "Prudent", "Bawdy", "Carnal", "Lusty", "Raunchy", "Ero", "Sense",
	"Steamy", "Wanton", "Hedonist", "Hedon", "Miles", "Tails", "Prower", "Echidna", "Fang", "Chaotix", "Dynamite",
	"Polar", "Vector", "Crocodile", "Espio", "Chameleon", "Mighty", "Armadillo", "Omo", "Owo", "Tikal", "Gerald",
	"Rabbit", "Nega", "Tive", "Posi", "Positive", "Negative", "Hawk", "Swallow", "Albatross", "Or", "Cu", "Sally",
	"Sticks", "Tangle", "Lemur", "Tumble", "Skunk", "Raccoon", "Benedict", "Ashe", "Carrottia", "Owl", "Froggy",
	"Kitsunami", "Nami", "Tsunami", "Zavok", "Zazz", "Zeena", "Zomom", "Zor", "Capybara", "Cart", "Magician",
	"Shinobi", "Rider", "Hey", "Hocke", "Wulf", "Ash", "Burning", "Flooded", "Scarred", "Cellar", "Caves",
	"Catacombs", "Depths", "Necropolis", "Mancer", "Necromancer", "Utero", "Sheol", "Cathedral", "Room", "Void",
	"Downpour", "Dross", "Septic", "Mines", "Ashpit", "Mausoleum", "Gehenna", "Maus", "Corpse", "Mortis",
	"Front", "Ascent", "Descent", "Fester", "Bulba", "Ivy", "Ander", "Eleon", "Meleon", "Izard", "Squirt", "Tle",
	"Wart", "Tortle", "Toise", "Oise", "Blas", "Cater", "Dle", "Kak", "Una", "Kuna", "Ka", "Drill", "Driller",
	"Pid", "Gey", "Geotto", "Otto", "Geot", "Ge", "Pidge", "Ot", "Tata", "Icate", "Spear", "Ow", "Ek", "Ans",
	"Ar", "Bok", "Rai", "Shrew", "Slash", "Nido", "Ran", "Rino", "Fable", "Cle", "Vul", "Tales",  "Jiggly",
	"Wiggly", "Iggly", "Puff", "Gol", "Odd", "Ish", "Gloom", "Gloomy", "Vile", "Plume", "Paras", "Sect",
	"Para", "Veno", "Nat", "Lett", "Trio", "Dug", "Th", "Duo", "Bio", "Mank", "Grow", "Lithe", "Arca",
	"Arcane", "Poli", "Poly", "Cule", "Whirl", "Swirl", "Abra", "Kad", "Kazam", "Ma", "Chop", "Choke",
	"Champ", "Weepin", "Vic", "Victree", "Tenta", "Cruel", "Dude", "Gravel", "Rapi", "Rapid", "Slow", "Poke",
	"Magne", "Magnem", "Ite", "Far", "Fetch", "Dod", "Seel", "Dew", "Grime", "Muk", "Shell", "Der",
	"Cloy", "Ster", "Gast", "Ly", "Geng", "Drow", "Zee", "Hyp", "Hypno", "Krab", "Elect", "Rode",
	"Exegg", "Utor", "Maro", "Wak", "Hitmon", "Lee", "Licki", "Tunt", "Koff", "Weez", "Rhy", "Don",
	"Chans", "Sey", "Tangel", "Kangas", "Khan", "Hors", "Ea", "Hor", "Dra", "Een", "Yu", "Mie", "Mime",
	"Scythe", "Jynx", "Electa", "Mag", "Mar", "Magma", "Pins", "Pin", "Taur", "Os", "Karp", "Gyara", "Lapra",
	"Ee", "Vee", "Vapor", "Eon", "Jolt", "Flar", "Pory", "Gon", "Yte", "Oma", "Kabu", "Tops", "Snor", "Lax",
	"Uno", "Mol", "Tres", "Drat", "Ini", "Onair", "Chik", "Chiko", "Rita", "Bay", "Leef", "Megan", "Ium", "Cynda",
	"Quil", "Ava", "Typh", "Losion", "Toto", "Dile", "Croco", "Naw", "Feral", "Gator", "Sent", "Ret", "Fur", "Furr",
	"Noct", "Ledy", "Led", "Ian", "Arak", "Aria", "Cro", "Chin", "Chou", "Lan", "Turn", "Fa", "Fo", "Fi", "Fe", "Tog",
	"Etic", "Toge", "Natu", "Xat", "U", "A", "E", "I", "Eep", "Fla", "Affy", "Amph", "Aros", "Ossom", "Ill", "Azu", "Azumar",
	"Sudo", "Toed", "Pip", "Loom", "Jump", "Luff", "Ai", "Sunk", "Ern", "Yan", "Mo","Quag", "Sire", "Esp", "Umb", "Umbra",
	"Sombra", "Som", "Somb", "Murk", "Row", "Mis", "Dreavus", "Wob", "Buffet", "Giraf", "Arig", "Forret", "Ress", "Dun",
	"Sparce", "Gli", "Steel", "Gran", "Sci", "Shuck", "Hera", "Sneas", "Snea", "Teddi", "Ursa", "Ring", "Slug", "Cargo",
	"Swin", "Swi", "Nub", "Pilo", "Swine", "Cors", "Cor", "Ola", "Sola", "Remo", "Oct", "Illery", "Deli", "Mant", "Manti",
	"Skar", "Mory", "Our", "Oom", "Phan", "Py", "Stant", "Smear","Smearg", "Tyro", "Smoo", "Chum", "Ele", "Mil", "Bilss",
	"Ey", "Ay", "Kou", "Ent", "Ei", "Sui", "Cune", "Larvi", "Pupi", "Tyran", "Tyrani", "Lug", "Cele", "Aur", "Fr", "Ua", "Oa",
	"Ue", "Ui", "Uy", "Aa", "Ae", "Ao", "Au", "Eo", "Eu", "Oe", "Oi", "Oo", "Ou", "Ia", "Ii", "Iu", "Iy", "Armored", "Beady",
	"Burrowing", "Snagret", "Snag", "Dwarf", "Bul", "Ear", "Blax", "Fiery", "Blow", "Lix", "Iridescent", "Flint", "Mamu", "Uta",
	"Mam", "Pearly", "Clam", "Clamp", "Pellet", "Posy", "Stool", "Puffed", "Smoky", "Progg", "Spotty", "Snitch", "Wolly", "Anode",
	"Dweevil", "Antenna", "Larva", "Careening", "Dirigi", "Caustic", "Cloaking", "Burrow", "Nit", "Creeping", "Chrysanthemum",
	"Chrys", "Anthe", "Gatling", "Groink", "Spotted", "Greater", "Lesser", "Hermit", "Craw", "Glint", "Jelly", "Munge", "Pileated",
	"Ranging", "Bloy", "Ravenous", "Whisker", "Pillar", "Segmented", "Crawb", "Skitter", "Toady", "Uja", "Dani", "Unmarked", "Spectra",
	"Lid", "Lids", "Volatile", "Wither", "Withered", "Withering", "Node", "Baldy", "Bald", "Mald", "Malding", "Balding", "Beared",
	"Prat", "Am", "Em", "Om", "Um", "At", "Et", "It", "Ut", "Blat", "Crush", "Desiccated", "Flighty", "Joust", "Medusal", "Slurk",
	"Slurker", "Nectar", "Nectarous", "Dandel", "Peckish", "Aristo", "Crat", "Phos", "Plasm", "Pucker", "Puckering", "Puckered",
	"Pyroclasmic", "Clasmic", "Quaggled", "Mire", "Clops", "Belching", "Meer", "Scorn", "Maestro", "Shag", "Shaggy", "Skeeter",
	"Skate", "Skutter", "Sputtle", "Vehemoth", "Pus", "Pussy", "Whip", "Gwen", "Plow", "Dungeon", "Wishing", "Oomox", "Mox",
	"Tuti", "Fruti", "Chewy", "Plummy", "Plumb", "Tooty", "Frooty", "Human", "Vulcan", "Romulan", "Klingon", "Ferengi", "Cardassian",
	"Bolian", "Andorian", "Tellarite", "Bajoran", "Tholian", "Gorn", "Gory", "Gore", "Denobulan", "Betazoid", "Borg", "Breen",
	"Changeling", "Hirogen", "Horta", "Jem", "Hadar", "Kazon", "Kzinti", "Orion", "Pakled", "Reman", "Talaxian", "Tribble", "Trill",
	"Vorta", "Vidiian", "Xindi", "Arboreal", "Avian", "Reptillian", "Aenar", "Benzite", "David", "Bowie", "Ziggy", "Cko", "Vyle",
	"Scep", "Tile", "Scept", "Tor", "Chic", "Torch", "Combusk", "Combus", "Blazi", "Tomp", "Ert", "Pert", "Pooch", "Yena", "Poochy",
	"Ena", "Zig", "Zag", "Zigag", "Goon", "Gooner", "Gooning", "Lino", "Oone", "Wurm", "Ple", "Silc", "Beauti", "Casc", "Cas",
	"Sil", "Dus", "Tox", "Lom", "Ludi", "Bre", "Colo", "Silcoon", "Cascoon", "Nuz", "Shift", "Swel", "Win", "Pelip", "Ralt", "Kirl",
	"Garde", "Voir", "Surs", "Sur", "Masque", "Shroom", "Slak", "Oth", "Eth", "Ath", "Uth", "Ith", "Vigor", "Nin", "Compoop", "Cada",
	"Jask", "Shed", "Inja", "Whis", "Mur", "Loud", "Exp", "Maku", "Hita", "Hari", "Yama", "Rill", "Pass", "Del", "Catty", "Sable",
	"Mawile", "Aron", "Lair", "An", "En", "Ron", "Rin", "Run", "Medi", "Tite", "Elec", "Trike", "Mane", "Plus", "Volb", "Vol", "Beat",
	"Eat", "Illum", "Ise", "Ase", "Ose", "Ese", "Use", "Lia", "Loa", "Lea", "Swal", "Carv", "Anha", "Sharp", "Edo", "Ado", "Ido", "Udo",
	"Minus", "Wail", "Mer", "Num", "Came", "Erupt", "Cam", "Rupt", "Tork", "Oal", "Koal", "Coal", "Grum", "Grump", "Spinda", "Tra",
	"Pinch", "Vib", "Rava", "Cac", "Nea", "Turne", "Swab", "Swa", "Alt", "Zan", "Se", "Sa", "Si", "So", "Viper", "Bar", "Oach", "Cash",
	"Corp", "Hish", "Daunt", "Bal", "Clay", "Lil", "Crad", "Dily", "Cra", "Ano", "Rith", "Arm", "Aldo", "Fee", "Bas", "Milo", "Rainy",
	"Snowy", "Kec", "Shup", "Pet", "Ban", "Kull", "Trop", "Ius", "Chime", "Cho", "Ab", "Eb", "Ib", "Ob", "Ub", "Wy", "Naut", "Sno",
	"Lie", "Lio", "Liu", "Seal", "Wal", "Rein", "Hunt", "Hun", "Ail", "Byss", "Relic", "Reli", "Canth", "Luv", "Disc", "Disk", "Bag",
	"Shel", "Mence", "Dum", "Met", "Ang", "Agross", "Gross", "Regi", "Latias", "Latios", "Lat", "Ias", "Ies", "Ios", "Kyo", "Gre",
	"Groud", "Grou", "Quaza", "Jir", "Achi", "Jira", "Deoxy", "Ribo", "Nucleic", "Pill", "Pilled", "Pilling", "Piller", "Corrosive",
	"Mosquito", "Morbius", "Cheeto", "Cheetos", "Asthley", "Loser", "Failure", "Download", "Evans", "Sto", "Klasa", "Bau", "Mack",
	"Mac", "Aulay", "Cul", "Attention", "Turt", "Grot", "Tort", "Chim", "Ferno", "Infern", "Lup", "Prin", "Plup", "Emp", "Oleon",
	"Empo", "Avia", "Aptor", "Raptor", "Bid", "Oof", "Bib", "Arel", "Kricket", "Tot", "Kricke", "Aw", "Ew", "Iw", "Rade", "Crani",
	"Bastio", "Bur", "My", "Na", "Ne", "No", "Sandy", "Trash", "Cloak", "Vespi", "Quen", "Pachi", "Risu", "Bui", "Zel", "Cheru",
	"Cherri", "Overcast", "Sunshine", "Lollipop", "Gastro", "Ambi", "Drif", "Loon", "Blim", "Eary", "Lop", "Unny", "Magius", "Honch",
	"Krow", "Glam", "Pur", "Ugly", "Ching", "Stunk", "Skun", "Bron", "Zong", "Ong", "Bronz", "Sly", "Happi", "Hap", "Piny", "Chat",
	"Gab", "Garch", "Chomp", "Bite", "Luca", "Hippo", "Potas", "Skoru", "Drap", "Croa", "Toxi", "Croak", "Toxic", "Carni", "Finn",
	"Lumin", "Tyke", "Ver", "Abomna", "Wea", "Lick", "Licky", "Perior", "Tang", "Tan", "Growth", "Vire", "Mortar", "Kiss", "Glis",
	"Mamo", "Ade", "Probo", "Noir", "Fros", "Lass", "Frost", "Mow", "Sprit", "Az", "Ez", "Oz", "Iz", "Uz", "Dial", "Gy", "Kia", "Gigas",
	"Gira", "Tina", "Altered", "Origin", "Cress", "Elia", "Phio", "Mana", "Phy", "Shay", "Pik", "Eus", "Vac", "Tini", "Sniv", "Sni", "Ser",
	"Tu", "Ty", "Ignite", "Boar", "Osha", "Wott", "Ott", "Samur", "Samu", "Pat", "Chog", "Wat", "Lilli", "Stout", "Purr", "Loin", "Pard",
	"Simi", "Sage", "Sear", "Pour", "Arna", "Dove", "Tran", "Quill", "Fezant", "Zeb", "Strika", "Roggen", "Rola","Ore", "Lith", "Woo", "Swoo",
	"Dril", "Exca", "Aud", "Tim", "Tum", "Tom", "Tem", "Tam", "Burr", "Gir", "Gor", "Gur", "Conkel", "Durr", "Tym", "Pole", "Palpi", "Seismi",
	"Throw", "Sock", "Stallion", "Bruta", "Nana", "Dilewski", "Popo", "Samus", "Swad", "Vanny", "Veni", "Whirli", "Scoli", "Whimsi", "Cott",
	"Peti", "Gant", "Bascu", "Kroko", "Rok", "Krook", "Daru", "Maka", "Darma", "Nitan", "Actus", "Dweb", "Ble", "Crust", "Scrag", "Crafty",
	"Sigi", "Lyph", "Sigil", "Glyph", "Ya", "Mask", "Ye", "Yi", "Yo", "Cof", "Agrigus", "Agri", "Tirt", "Ouga", "Carra", "Costa", "Hen", "Eops",
	"Trub", "Bish", "Rubbish", "Garba", "Zoru", "Zoro", "Cin", "Goth", "Ita", "Orita", "Itelle", "Gothi", "Gothic", "Solo", "Sion", "Reuni",
	"Clus", "Vanil", "Luxe", "Saws", "Saw", "Buck", "Emol", "Karra", "Esca", "Valier", "Foon", "Amoon", "Guss", "Frill", "Jelli", "Alomo", "Mola",
	"Galvan", "Galva", "Ferro", "Klink", "Klang", "Lang", "Namo", "Ektrik", "Ektross", "Elg", "Yem", "Behee", "Pent", "Chande", "Lure", "Frax",
	"Haxo", "Rus", "Cub", "Choo", "Cryo", "Gonal", "Stun", "Fisk", "Mien", "Foo", "Shao", "Drudd", "Igon", "Ett", "Lurk", "Pawn", "Iard", "Buoff",
	"Alant", "Ruff", "Brav", "Laby", "Mandi", "Dura", "Dein", "Zwei", "Hydrei", "Larv", "Esta", "Volca", "Rona", "Coba", "Kion", "Viri", "Zion",
	"Torna", "Thun", "Durus", "Thundur", "Reshi", "Ram", "Zek", "Rom", "Lando", "Kyur", "Kyu", "Rem", "Kel", "Deo", "Resolute", "Incarnate",
	"Therian", "Melo", "Etta", "Pirouette", "Moruki", "Stormcaller", "Trata", "Kathlano", "Hazel", "Zoey", "Jennael", "Kiirmion", "Fiana", "Poppydew",
	"Els", "Harvett", "Luxury", "Finnae", "Gizzle", "Quickhands", "Xeni", "Syden", "Fiendbound", "Ruby", "Ficklequill", "Fickle", "Poppy", "Olaf",
	"Hooty", "Point", "Shooty", "Elmer", "Fudd", "Cashew", "Macadamia", "Pistachio", "Butternut", "Saba", "Parasite", "Pili", "Baru", "Mongongo",
	"Chestnut", "Coconut", "Hazelnut", "Kola", "Marcona", "Acorn", "Ginkgo", "Candle", "Twin", "Crab", "Balance", "Scorpion", "Archer", "Bearer",
	"Janeway", "Jean", "Luc", "Kathryn", "Benjamin", "Chaff", "Vermillion", "Persimmon", "Amber", "Chartreuse", "Aubergine", "Crimson", "Dim",
	"Ophiuchus", "Serpent", "Cetus", "Whale", "Pisky", "Pixy", "Pixi", "Pizkie", "Piskie", "Pigsie", "Puggsy", "Fay", "Fey", "Faerie", "Folk",
	"Adhene", "Alp", "Luachra", "Anjana", "Arkan", "Sonney", "Asrai", "Baobhan", "Banshee", "Barghest", "Nighe", "Billy", "Blind", "Birog",
	"Bluecap", "Minch", "Bodach", "Boggart", "Bogle", "Boobrie", "Brag", "Brownie", "Bucca", "Buggane", "Bugbear", "Bugul", "Noz", "Caoi",
	"Neag", "Ceffyl", "Cluri", "Chaun", "Cobyl", "Nau", "Colt", "Cyhr", "Aeth", "Drude", "Duende", "Duergar", "Dullahan", "Each", "Uisge",
	"Elegast", "Huldu", "Svartal", "Fachan", "Dearg", "Gorta", "Feno", "Dyree", "Fuath", "Gan", "Canagh", "Ghillie", "Dhu", "Glastig", "Glashtn",
	"Groach", "Grindy", "Grindylow", "Annwn", "Gwyllion", "Gwyn", "Nudd", "Habe", "Trot", "Hag", "Haltija", "Hedley", "Kow", "Heinzei", "Mannchen",
	"Hinzel", "Hobbi", "Hodekin", "Iannic", "Ann", "Od", "Lantern", "Bowl", "Jenny", "Teeth", "Joint", "Kelpie", "Kilmoulis", "Knocker", "Knucker",
	"Kobold", "Klab", "Klabauter", "Korrigan", "Laurence", "Leanan", "Sidhe", "Lepre", "Lubber", "Lutin", "Erg", "Meg", "Mullach", "Melusine", "Merrow",
	"Mooinjer", "Veggey", "Morgen", "Morvar", "Nain", "Nelly", "Longarms", "Nicnevin", "Nisse", "Nixie", "Nuckelavee", "Nuckel", "Avee", "Nuggle", "Peg",
	"Powler", "Puca", "Puck", "Ra", "Bergsra", "Hulder", "Radande", "Sjora", "Skog", "Sra", "Redcap", "Selkie", "Seon", "Aidh", "Shelly", "Sluagh", "Spriggan",
	"Sylph", "Tomte", "Trow", "Tylwyth", "Teg", "Undine", "Wicked", "Wight", "Wirry", "Xana", "Bogey", "Incubus", "Succubus", "Merfolk", "Abatwa", "Asan", "Bosam",
	"Aziza", "Bult", "Ungin", "Eloko", "Jengu", "Kishi", "Mami", "Wata", "Oba", "Yifo", "Rompo", "Tikol", "Oshe", "Yumboes", "Alux", "Anchi", "Mayen", "Belled",
	"Buzzard", "Cano", "Tila", "Chaneque", "Curu", "Pira", "Encan", "Tado", "Ishi", "Gaq", "Jogah", "Muki", "Nimer", "Igar", "Nunne", "Pombero", "Puk", "Wudgie",
	"Saci", "Trauco", "Yunwi", "Tsundi", "Diwata", "Dokkaebi", "Huli", "Jing", "Huxian", "Inari", "Okami", "Kitsune", "Kumiho", "Hyang", "Irshi", "Jinn", "Kijmuna",
	"Korpokkur", "Mazzikin", "Mogwai", "Mrenh", "Kongveal", "Bunian", "Preta", "Tennin", "Yaksha", "Yakshini", "Yokai", "Mononoke", "Yosei", "Bunyip", "Manaia",
	"Menehune", "Mimis", "Muldjewangk", "Nawao", "Patu", "Paiarehe", "Taniwha", "Tipua", "Wandjina", "Yara", "Yha", "Aitvaras", "Gabija", "Lauma", "Basajaun", "Lamina",
	"Mairu", "Badb", "Pictish", "Morrigan", "Tuatha", "Danann", "Cercopes", "Circe", "Faun", "Hecate", "Satyr", "Ajatar", "Hiisi", "Mennin", "Kainen", "Alberich",
	"Perchta", "Vittra", "Witte", "Wieven", "Frauen", "Capcaun", "Dames", "Blanches", "Donas", "Fuera", "Iele", "Mouro", "Moura", "Sanziana", "Spiridus", "Squasc",
	"Valva", "Vantoase", "Zana", "Bannik", "Berehynia", "Domovoi", "Karzelek", "Kikimora", "Leshy", "Likho", "Polevik", "Psotnik", "Rusalka", "Vila", "Vodyanoy",
	"Fates", "Kalli", "Kantzaros", "Salamander", "Sandman", "Liderc", "Ursitory", "Vadleany", "Andromeda", "Antlia", "Apus", "Aquila", "Ara", "Auriga", "Bootes",
	"Caelum", "Camelo", "Pardalis", "Canes", "Venatici", "Canis", "Minor", "Carina", "Cassiopeia", "Centaur", "Cepheus", "Chamae", "Circinus", "Columba", "Coma",
	"Berenices", "Corona", "Australis", "Borealis", "Corvus", "Crater", "Crux", "Cygnus", "Delphin", "Dorado", "Draco", "Equuleus", "Eridanus", "Fornax", "Grus",
	"Hercules", "Horo", "Logium", "Hydra", "Hydrus", "Indus", "Lacerta", "Lepus", "Lupus", "Lyra", "Mensa", "Scopium", "Ceros", "Musca", "Norma", "Octans", "Pavo",
	"Pegasus", "Perseus", "Pictor", "Piscis", "Austrinus", "Puppis", "Pyxis", "Reticulum", "Sagitta", "Sculptor", "Scutum", "Serpens", "Sextans", "Tele", "Triangulum",
	"Australe", "Tucana", "Vela", "Volans", "Vulpecula", "Quadrans", "Muralis", "Caput", "Cauda", "Gin", "Vodka", "Whiskey", "Tequila", "Rum", "Brandy", "Amaretto",
	"Kahlua", "Campari", "Bailey", "Vermouth", "Sherry", "Marsala", "Liquor", "Liqueur", "Wine", "Beer", "Tanqueray", "Martini", "Collins", "Tito", "Skyy", "Absolut",
	"Bourbon", "Rye", "Maker", "Woodford", "Jameson", "Royal", "Daniels", "Skrewball", "Mezcal", "Agave", "Blanco", "Reposado", "Bacardi", "Capitan", "Morgan", "Gosling",
	"Malibu", "Stacy", "Mojito", "Daiquiri", "Cognac", "Armagnac", "Calvados", "Pisco", "Martin", "Remy", "Sidecar", "Absinthe", "Amaro", "Aperol", "Spritz", "Ale", "Lager",
	"Cocktail", "Mead", "Porter", "Pilsner", "Tonic", "Madeira", "Port", "Cappell", "Chambord", "Creme", "Drambuie", "Meister", "Galliano", "Limon", "Cello", "Maras", "Chino",
	"Midori", "Curacao", "Pastis", "Pernod", "Pimm", "Schnapps", "Sloe", "Germain", "Suze", "Chad", "Sake", "Vla", "Lexicon", "True", "False", "Domo", "Voy", "Dessert",
	"Tickler", "Columbo", "Soflan", "Backscratch", "Charge", "Notes", "Pennies", "Abolisher", "Bloodlines", "Bloodline", "Defile", "Defiler", "Flesh", "Reality", "Smasher",
	"Phyrexian", "Plague", "Plaguelord", "Impatient", "Bananas", "Defeated", "Victorious", "Lasagne", "Lasagna", "Penne", "Bucatini", "Buca", "Cavatappi", "Cava", "Tappi",
	"Manicotti", "Mani", "Cotti", "Torte", "Lloni", "Tortelloni", "Mostaccioli", "Tagliatelle", "Telle", "Taglia", "Ditalini", "Dita", "Lini", "Fettuccine", "Fettu", "Fusilli",
	"Gemelli", "Gnocchi", "Linguine", "Guine", "Macaroni", "Maca", "Roni", "Oni", "Orecchiette", "Orecchi", "Orzo", "Ravioli", "Rigatoni", "Riga", "Toni", "Rotelle", "Rotini",
	"Llini", "Tortellini", "Vermicelli", "Vermi", "Celli", "Ziti", "Marinara", "Mari", "Alfredo", "Fredo", "Bolognese", "Bolog", "Nese", "Pomodoro", "Pomo", "Doro", "Pesto",
	"Carbonara", "Carbo", "Nara", "Bechamel", "Becha", "Mel", "Arrabiata", "Arra", "Biata", "Amatriciana", "Ama", "Ciana", "Truffle", "Cacio", "Pepe", "Whole", "Wheat", "Multigrain",
	"Sourdough", "Pumpernickel", "Pumper", "Baguette", "Bagu", "Boule", "Ciabatta", "Batta", "Batter", "Challah", "Brioche", "Flatbread", "Bagel", "Bialy", "Babka", "Batik", "Battenberg",
	"Blondie", "Bundt", "Dundee", "Pear", "Citrus", "Grapefruit", "Mandarin", "Nectarine", "Exotic", "Strawberry", "Raspberry", "Blueberry", "Kiwi", "Passion", "Passionfruit", "Watermelon",
	"Rockmelon", "Honeydew", "Tomato", "Avocado", "Lettuce", "Spinach", "Silverbeet", "Cabbage", "Cruciferous", "Cauliflower", "Brussel", "Broccoli", "Marrow", "Cucumber", "Zucchini", "Potato",
	"Yam", "Celery", "Asparagus", "Onion", "Garlic", "Shallot", "Tofu", "Soybean", "Soy", "Legume", "Chickpea", "Lentil", "Beans", "Haricot", "Broad", "Kale", "Omori", "Aubrey", "Hero", "Basil",
	"Berly", "Van", "Sweetheart", "Bangs", "Brows", "Jash", "Mikal", "Neb", "Sharleen", "Shawn", "Stranger", "Thing", "Things", "Andy", "Blookie", "Brooke", "Canopy", "Chow", "Cowblin", "Dango",
	"Darville", "Frank", "Fred", "Gasper", "Gaster", "Gibs", "Goosey", "Guano", "Diggity", "Jerko", "Leafie", "Mooncake", "Mott", "Outback", "Parrot", "Obaaa", "Dressed", "Spelling", "Tater",
	"Whatever", "Whizzy", "Whitney", "Aliana", "Chelle", "Crow", "Ferris", "Spaceboy", "Gascon", "Gumbo", "Laramie", "Pessi", "Treble", "Zarf", "Batzy", "Molio", "Loam", "Guava", "Mikhael",
	"American", "Karen", "Sean", "Clumsy", "Principal", "Kim", "Charlene", "Forehead", "Fashionable", "Gino", "Vance", "Maverick", "Eggs", "Baking", "Caster", "Extract", "Grease", "Glaze",
	"Glazed", "Glazing", "Baked", "Dendrite", "Plate", "Column", "Sectored", "Saturated", "Lungy", "Jesus", "Magdalene", "Maggy", "Cain", "Judas", "Eve", "Samson", "Azazel", "Lazarus",
	"Risen", "Lilith", "Keeper", "Apollyon", "Bethany", "Jacob", "Esau", "Broken", "Dauntless", "Hoarder", "Deceiver", "Soiled", "Curdled", "Savage", "Benighted", "Enigma", "Capricious",
	"Baleful", "Harlot", "Miser", "Fettered", "Zealot", "Deserter", "Fortune", "Slot", "Goatest", "Harkinian", "Daphne", "Gibdo", "Wizz", "Hek", "Heck", "Omfak", "Grimbo", "Glimbo",
	"Harbanno", "Alma", "Lika", "Kiro", "Lubonga", "Cravendish", "Myra", "Yokan", "Onkled", "Impa", "Special", "Week", "Silence", "Suzuka", "Tokai", "Teio", "Groove", "Condor", "Pasa",
	"Oguri", "Cap", "Symboli", "Rudolf", "Taiki", "Shuttle", "Daiwa", "Opera", "Narita","Hishi", "Fuji", "Kiseki", "Maru", "Zensky", "Mejiro", "McQueen", "Seiun", "Yukino", "Bijin",
	"Winning", "Ticket", "Tamamo", "Seeking", "Manhattan", "Cafe", "Tosen", "Jordan", "Haru", "Urara", "Kawakami", "Myran", "Mati", "Kane", "Fuku", "Kitaru", "Motion", "Smart", "Falcon",
	"Taishin", "Shakur", "Nishino", "Flower", "Biko", "Akebono", "Memory", "Marvelous", "Mihono", "Sweep", "Tosho", "Ines", "Fujin", "Biwa", "Hayahide", "Sakura", "Bakushin", "Shinko",
	"Agnes", "Tachyon", "Zenno", "Rob", "Meisho", "Doto", "Rice", "Admire", "Vega", "Curren", "Eishin", "Flash", "Nakayama", "Festa", "Mayano", "Dober", "Nice", "Nature", "Halo", "Matikane",
	"Tannhauser", "Ikuno", "Dictus", "Daitaku", "Turbo", "Darley", "Arabian", "Godolphin", "Byerley", "Turk", "Katsuragi", "Pocket", "Miracle", "Satono", "Crown", "Cheval", "Ramonu", "Daiichi",
	"Daring", "Tact", "Hokko", "Tarumae", "Copano", "Rickey", "Tanino", "Gimlet", "Fusion", "Fake", "Educated", "Pain","Aura", "Wear", "Chrono", "Cluster", "Level", "Commercial", "Eldritch",
	"Blank", "Handle", "Carton", "Cartoon", "Ancient", "Fungus", "Glass", "Anatomy", "Anatomical", "Time", "Nexus", "Plasma", "Morph", "Myth", "Industrial", "Fantasy", "Subspace", "Slender",
	"Fossil", "Stereo", "Element", "Null", "Proto", "Ritual", "Neutral", "Error", "Death", "Curse", "Material", "Spell", "Anti", "Pure", "Nether", "Oblivion", "Sunseed", "Combustion",
	"Disguised", "Condo", "Lump", "Spiny", "Anxious", "Hourglass", "Twins", "Timber", "Hearth", "Brittle", "Giant", "Bramble", "Attle", "Interloper", "Loper", "Quantum", "Orbital",
	"Hearthian", "Nugget", "Succulent", "Series", "Vegetable", "Toadstool", "Replica", "Xenoflora", "Project", "Pilgrim", "Bulb", "Frippery", "Conifer", "Spire", "Corpulent",
	"Champion", "Hideous", "Victual", "Gourmet", "Satchel", "Sensation", "Threat", "Compelling", "Impenetrable", "Bait", "Imperative", "Comfort", "Mattress", "Sweets", "Enamel",
	"Buster", "Doomer", "Goodness", "Dreamer", "Confection", "Hoop", "Pastry", "Wheel", "Paleontology", "Paleon", "Tology", "Possessed", "Fossilized", "Ursidae", "Leviathan", "Fortified",
	"Scrumptious", "Memorial", "Mysterious", "Remains", "Secrets", "Gyroid", "Bust", "Merit", "Lustrous", "Mirrored", "Vorpal", "Platter", "Arsenal", "Tub", "Cooking", "God", "Merciless",
	"Extractor", "Utter", "Tortured", "Decorative", "Instrument", "Manual", "Honer", "Implement", "Toil", "Duty", "Magnetizer", "Harmonic", "Synthesizer", "Whistle", "Director", "Destiny",
	"Amenities", "Amenity", "Sud", "Generator", "Tomorrow", "Lightning", "Impediment", "Scourge", "Raft", "Slicer", "Capsule", "Service", "Stage", "Behemoth", "Jaw", "Frigid", "Receptacle",
	"Fleeting", "Art", "Spouse", "Alert", "Innocence", "Essential", "Furnishing", "Icon", "Progress", "Technology", "Temporal", "Mechanism", "Mystical", "Vacuum", "Processor", "Indomitable",
	"Network", "Mainbrain", "Receiver", "Sulking", "Nouveau", "Flywheel", "Flogger", "Superstrong", "Stabilizer", "Repair", "Juggernaut", "Adamantine", "Girdle", "Massage", "Superstick",
	"Textile", "Exhausted", "Furious", "Adhesive", "Petrified", "Unspeakable", "Rage", "Despair", "Menace", "Joyless", "Frosty", "Bauble", "Gemstar", "Univeral", "Crystallized", "Emotion",
	"Omniscient", "Telepathy", "Telekinesis", "Mirth", "Clairvoyance", "Maternal", "Paternal", "Sculpture", "Extreme", "Perspirator", "Rubber", "Paradoxical", "Paradox", "Silenced", "Silencer",
	"Wiggle", "Noggin", "Coiled", "Launcher", "Magical", "Boom", "Tiller", "Apparatus", "Spinner", "Stupendous", "Lens", "Brake", "Worthless", "Priceless", "Statue", "Wafer", "Talisman", "Strife",
	"Monolith", "Chance", "Totem", "Past", "Architect", "Glee", "Cosmic", "Archive", "Remembered", "Buddy", "Fond", "Gyro", "Memorable", "Favorite", "Treasured", "Proton", "Durable", "Energy",
	"Cell", "Tron", "Courage", "Reactor", "Yell", "Fuel", "Reservoir", "Revised", "Dynamo", "Alternative", "Container", "Knowledge", "Bounty", "Drone", "Supplies", "Supply", "Patience", "Tester",
	"Endless", "Repository", "Guard", "Nutrient", "Silo", "Stringent", "Survival", "Closed", "Architecture", "Permanent", "Plentiful", "Surviving", "Ointment", "Healing", "Cask", "Estimated",
	"Object", "Coiny", "Memories", "Understood", "Person", "Symbol", "Saucer", "Universally", "Inviting", "Idea", "Assistant", "Seat", "Enlightenment", "Cradle", "Anywhere", "Abstract",
	"Masterpiece", "Optical", "Illustration", "Thirst", "Activator", "Ad", "Tyrant", "Saliva", "Trix", "Gherkin", "Billboard", "Activity", "Arouser", "Hypnotic",  "Logo", "Happiness", "Pondering",
	"Emblem", "Quenching", "Drought", "Creative", "Inspiration", "Spherical", "Atlas", "Geographic", "Projection", "Graphic", "Prototype", "Napsack", "Brute", "Repugnant", "Appendage", "Stellar",
	"Forged", "Alloy", "Amplified", "Amplifier", "Noisemaker", "Therapist", "Comedy", "Pump", "Bugs", "Loop", "Beginnings", "Expedition", "Pendulum", "Sewer", "Consolation", "Prize", "Blues",
	"Eradicator", "Confusion", "Sealed", "Missile", "Unassuming", "Lighthouse", "Traveler", "Constitution", "Attractive", "Stopped", "Smile", "Defect", "Defective", "Independence", "Forth",
	"Road", "Flashy", "Preservation", "Cherrystone", "Revenge", "Foaming", "Berserker", "Brush", "Attitude", "Adjuster", "Rift", "Serene", "Unstrung", "Racket", "Imbalancer", "Evidence",
	"Pulverizer", "Glowing", "Handy", "Shallow", "Pick", "Conformity", "Enhancer", "Conform", "Conforming", "Unexamined", "Examined", "Strung", "Everyday", "Treacherous", "Current",
	"Currents", "Rodent", "Grown", "Getting", "Vault", "Numerical", "Gigaton", "Manifested", "Springpetal", "Dutiful", "Watchdog", "Inevitable", "Tragedy", "Subterranean", "Suite", "Gauge",
	"Lonely", "Damaging", "Javelin", "Lefty", "Loosey", "Lance", "Lopsided", "Barbell", "Metamorphosis", "Cistern", "Lifeform", "Almighty", "Ruiner", "Bond", "Impressor", "Breaker", "Relaxant",
	"Distinguished", "Speaker", "Signal", "Quo", "Drenchnozzle", "Den", "Missed", "Connection", "Zappy", "Safe", "Sloshy", "Concentrated", "Ominous", "Fragrant", "Slimmerized", "Probable",
	"Teapot", "Sanctum", "Shield", "Thicket", "Nostalgic", "Buckler", "Menacing", "Crusher", "Fallen", "Altitudinal", "Limiter", "Unlimiter", "Ceremony", "Abandoned", "Troop", "Primitive",
	"Museum", "Gale", "Force", "Glen", "Mood", "Vacated", "Buggy", "Scorched", "Deluxe", "Other", "Withdrawn", "Loneliness", "Instant", "Planetarium", "Darkness", "Unbelievable", "Believable",
	"Wand", "Terror", "Trench", "Reflection", "Extended", "Friendship", "Smacker", "Enduring", "Partnership", "Barrier", "Creativity", "Stimulator", "Shimmering", "Scoreless", "Dartboard",
	"Sizzling", "Precipice", "Blazing", "Projector", "Freezing", "Waste", "Wasteland", "Below", "Humor", "Implant", "Herbivore", "Molar", "Wintry", "Zoo", "Hazard", "Unremarkable", "Remarkable",
	"Beneficial", "Intelligence", "Routine", "Screen", "Ordeal", "Automatic", "Wheeler", "Flauntulent", "Beaten", "Parting", "Thoroughbred", "Tandem", "Compass", "Authoritative", "Tempting",
	"Obelisk", "Madcap", "Paste", "Windows", "Bog", "Training", "Distortion", "Chamber", "Single", "Seesaw", "Starship", "Apotheosis", "Ornamental", "Ornament", "Cycle", "Spellbound", "Oversized",
	"Suspenders", "Unsung", "Memento", "Incomprehensible", "Comprehensible", "Fashion", "Fearsome", "Gaudy", "Pencil", "Pusher", "Barrel", "Laughs", "Insensitive", "Lout", "Fanged", "Marshmallow",
	"Seated", "Strummer", "Uncomfortable", "Comforting", "Comforted", "Uniformed", "Swaddler", "Crew", "Apron", "Rosy", "Outlooked", "Trotter", "Trigger", "Furball", "Solemnity", "Solemn", "Chairman",
	"Unblinking", "Guilt", "Dreary", "Inadequacy", "Wellspring", "Embarassment", "Target", "Painted", "Hairdo", "Squirting", "Devious", "Drencher", "Arrow", "Uplifting", "Sparkling", "Ingenue",
	"Cucumbress", "Pit", "Depth", "Debauchery", "Snob", "Artichoke", "Turnip", "Maple", "Slice", "Dumpling", "Macaroon", "Checkerboard", "Syrup", "Baumkuchen", "Primate", "Ammonite", "Ammo", "Conch",
	"Scallop", "Lobster", "Haniwa", "Yen", "Pudding", "Can", "Juicer", "Ladle", "Crushed", "Pastel", "Crayon", "Sharpener", "Horseshoe", "Castanet", "Mild", "Matches", "Popsicle", "Corgi", "Compact",
	"Maxillary", "Denture", "Present", "Stocking", "Preceding", "Rotary", "Phone", "Lugnut", "Brooch", "Earring", "Mounted", "Wobbling", "Bobble", "Rusted", "Firework", "Bobber", "Bobby", "Boober",
	"Geigoma", "Magnifying", "Badminton", "Birdie", "Chess", "Spades", "Clubs", "Diamonds", "Hearts", "Swords", "Pentacles", "Cups", "Wands", "Circles", "Mahjong", "Die", "Duracell", "Sardine",
	"Herring", "Underwood", "Spread", "Clabber", "Skippy", "Shellfish", "Meidi", "Corned", "Breitsamer", "Haribo", "Chapstick", "Carmex", "Ohayo", "Kyodo", "Chichiyasu", "Kyusyu", "Rakuren",
	"Kajihara", "Koiwai", "Kuriomoto", "Kyoshin", "Sagotani", "Daisen", "Hiruzen", "Kitaama", "Mainichi", "Snapple", "Ragu", "French", "Dannon", "Vlasic", "Wilson", "Vitamalz", "Yoo", "Hoo",
	"Fristi", "Pschitt", "Tizer", "Sinalco", "Globe", "Glove", "Fist", "Eraser", "Megaphone", "Crookes", "Camping", "Stove", "Poison", "Spigot", "Pressure", "Awakening", "Bulblax", "Spiders",
	"Emergence", "Frontier", "Kitchen", "Holes", "Beasts", "Heroes", "Perplexing", "Submerged", "Merged", "Merging", "Minge", "Mingebag", "Complex", "Repose", "Wistful", "Positron", "Whimsical",
	"Geiger", "Counter", "Radiation", "Absorber", "Ionium", "Dioxin", "Filter", "Gravity", "Jumper", "Analog", "Satellite", "Gluon", "Zirconium", "Rotor", "Interstellar", "Bowsprit", "Chronos",
	"Blaster", "Lamp", "Bandaid", "Cockroach", "Severed", "Serrated", "Syringe", "Condom", "Tampon", "Steak", "Wrinkler", "Dapper", "Blob", "Dreamdrop", "Pustule", "Pustules", "Heroine", "Pocked",
	"Airhead", "Banquet", "Bouquet", "Mock", "Blonde", "Imposter", "Searing", "Acidshock", "Firebreathing", "Feast", "Zest", "Extrusion", "Custard", "Wayward", "Astringent", "Clump", "Slapstick",
	"Crescent", "Juicy", "Gaggle", "Glaggle", "Glaggleland", "Crunchy", "Sniffer", "Formidable", "Distant", "Thirsty", "Shaded", "Festivity", "Rustyard", "Beastly", "Clockwork", "Stalk", "Button",
	"Orca", "Kisser", "Shorten", "Snout", "Gobster", "Handibles", "Tennae", "Pincer", "Mangler", "Slag", "Jawed", "Barra", "Toucan", "Muzzle", "Skexy", "Sauro", "Clod", "Gnarly", "Simper", "Worry",
	"Swill", "Haunch", "Shout", "Lobby", "District", "Vacation", "Slum", "Staff", "Gutter", "Scape", "Bloodsauce", "Oregano", "Wasteyard", "Food", "Vigilante", "Cove", "Golf", "Noise", "Peppibot",
	"Freezerator", "Pizzascare", "Sound", "Crumbling", "Peppino", "Snotty", "Ravine", "Pizzaland", "Noisette", "Clean", "Slime", "Swedish", "Pepperoni", "Pencer", "Anchovy", "Kenny", "Bandito",
	"Gabaghoul", "Peasanto", "Pineacool", "Pizzard", "Olive", "Greaseball", "Noisey", "Hamkuff", "Thug", "Stamper", "Grabbie", "Snowman", "Pizzice", "Clownmato", "Patroller", "Toppin", "Pirane",
	"Cardboard", "Camembert", "Squire", "Meatball", "Boulder", "Smoked", "Mort", "Snick", "Boots", "Dougie", "Granny", "Blacksmith", "Jester", "Peddito", "Doise", "Peshino", "Bacon",
	"Aradia", "Megido,", "Tavros", "Nitram", "Sollux", "Captor", "Karkat", "Vantas", "Nepeta", "Leijon", "Kanaya", "Maryam", "Terezi", "Pyrope", "Equius", "Zahhak", "Gamzee", "Makara", 
	"Eridan", "Ampora", "Feferi", "Peixes", "Betty", "Crocker", "Hussie", "Crump", "Lenny", "Kappy", "Generic", "Superficial", "Guarded", "Octaroon", "Irradiated", "Devourer", "Cornmunity",
	"Roleplay", "Ralph", "Bluetawn", "Dennis", "Bogan", "Johnny", "Zestful", "Skinner", "Aurora", "Zillyhoo", "Slammer", "Saucy", "Gerome", "Morbus", "Surreal", "Stanky", "Duke", "Nukem", "Dukey",
	"Nukey", "Anarchist", "Cookbook", "Rights", "Rotten", "Shadows", "Breath", "Converter", "Crack", "Scrolls", "Cards", "Remote", "Flush", "Forget", "Now", "Guppy", "Paw", "Krampus", "How", "Kamikaze",
	"Mishap", "Fingers", "Pills", "Monstro", "Notched", "Pandora", "Prayer", "Razor", "Detonator", "Bible", "Scissors", "Shoop", "Whoop", "Tammy", "Dummies", "Teleport", "Belial", "Boomerang", "Gamekid",
	"Necronomicon", "Pinking", "Shears", "Stump", "We", "Need", "Deeper", "Yum", "Friends", "Diplopia", "Crafter", "Placebo", "Ventricle", "Shovel", "Clicker", "Compost", "Coupon", "Crooked", "Dataminer",
	"Delirious", "Metronome", "Moving", "Gift", "Pause", "Plan", "Peeler", "Straw", "Smelter", "Sprinkler", "Wait", "What", "Abyss", "Alabaster", "Anima", "Crafting", "Berserk", "Virtues", "Damocles",
	"Arts", "Certificate", "Decap", "Everything", "Flip", "Gello", "Wisps", "Larynx", "Lemegeton", "Skin", "Cleaver", "Bracelet", "Flute", "Recall", "Spindown", "Dice", "Stitches", "Sulfur", "Sumptorium",
	"Suplex", "Scooper", "Urn", "Souls", "Vade", "Wavy", "Yuck", "Dollar","Abaddon", "Abel", "Anemic", "Ankh", "Bandage", "Bandages", "Lotus", "Clot", "Martyr", "Superstitious", "Bogo", "Bucket", "Bombs",
	"Caffeine", "Celtic", "Ceremonial", "Robes", "Belt", "Peeled", "Contract", "Body", "Cricket", "Touch", "Admiration", "Fetus", "Coli", "Experimental", "Treatment", "Fanny", "Fate", "Alone", "Gimpy",
	"Gnawed", "Godhead", "Hormones", "Hormone", "Collar", "Hairball", "Habit", "Headless", "Mind", "Grail", "Mantle", "Humble", "Humbling", "Bundle", "Infamy", "Infestation", "Ipecac", "Latch", "Rags",
	"Leech", "Brimstone", "Baggy", "Chubby", "Gish", "Loki", "Horns", "Contact", "Bow", "Baller", "Scab", "Magneto", "Match", "Missing", "Page", "Mitre", "Contacts", "Eyeshadow", "Heels", "Purse", "Underwear",
	"Mongo", "Mutant", "Pageant", "Pentagram", "Philosophy", "Bank", "Placenta", "Polyphemus", "Phemus", "Proptosis", "Tosis", "Punching", "Pyromaniac", "Raw", "Robo", "Ribbit", "Rosary", "Cement", "Sacred",
	"Dagger", "Safety", "Chains", "Scapular", "Screw", "Sissy", "Skatole", "Spelunker", "Bender", "Squeezy", "Starter", "Sale", "Stem", "Cells", "Stigmata", "Attractor", "Synthoil", "Common", "Inner", "Ladder",
	"Ludovico", "Technique", "Mark", "Mulligan", "Pact", "Peeper", "Polaroid", "Options", "Thighs", "Toothpicks", "Toothpick", "Photo", "Torn", "Tough", "Transcendence", "Map", "Trinity", "Whore", "Wire", "Hanger",
	"Nails", "Outer", "Wilds", "Athame", "Betrayal", "Binky", "Bumbo", "Bursting", "Cambion", "Conception", "Censer", "Charged", "Protection", "Continuum", "Jacks", "Pockets", "Blessing", "Epiphora", "Explosivo",
	"Farting", "Reward", "Host", "Immaculate", "Gurdy", "Maid", "Pearls", "Dolly", "Multidimensional", "Number", "Obsessed", "Papa", "Pay", "Pajama", "Pajamas", "Purity", "Pupula", "Duplex", "Restock", "Sack",
	"Scatter", "Seraphim", "Sticky", "Sworn", "Protector", "Tractor", "Zodiac", "Seals", "Acid", "Adrenaline", "Angelic", "Prism", "Backstabber", "Blanket", "Bloodshot", "Modem", "Camo", "Compound", "Contagion",
	"List", "Depression", "Divorce", "Papers", "Duality", "Eucharist", "Euthanasia", "Patient", "Glaucoma", "Gullet", "Nympho", "Haemo", "Haemolacria", "Lacria", "Hallowed", "Hushy", "Cables", "Lachry", "Phagy",
	"Zit", "Leprosy", "Delirium", "Spewer", "Linger", "Marbles","Mystery", "Parasitoid", "Pointy", "Dactyly", "Sacks", "Shade", "School", "Schoolbag", "Shard", "Sinus", "Infection", "Slipped", "Sulfuric", "Tarot",
	"Cloth", "Trisagion", "Varicose", "Veins", "Listen", "Pound", "Act", "Contrition", "Akeldama", "Binge", "Birthright", "Oath", "Puppy", "Gust", "Spurs", "Booster", "Bot", "Section", "Reading", "Dirty",
	"Intervention", "Drops", "Occult", "Glitched", "Glitchy", "Glitch", "Heartbreak", "Heartbroken", "Hemoptysis", "Hangry", "Horngry", "Hurts", "Hurt", "Hurting", "Kinning", "Knockout", "Facepunch",
	"Lodestone", "Member", "Phallus", "Putz", "Schlong", "Pundit", "Monstrance", "Montezuma", "Mucor", "Mycosis", "Ocular", "Orphan", "Socks", "Paschal", "Playdough", "Purgatory", "Quints", "Redemption",
	"Revelation", "Salvation", "Sanguine", "Locket", "Shackles", "Stapler", "Bethlehem", "Stye", "Intruder", "Stairway", "Swarm", "Trainer", "Mide", "Twisted", "Pair", "Vanishing", "Vasculitis", "Vengeful",
	"Voodoo", "Tonsil", "Tract", "Callus", "Cartridge", "Counterfeit", "Curved", "Daemon", "Hoof", "Liberty", "Faith", "Toenail", "Pulse", "Push", "Credit", "Swallowed", "Swallows", "Umbilical", "Cord",
	"Blasting", "Blister", "Leash", "Nameless", "Faded", "Karma", "Locker", "Poker", "Stud", "Store", "Duct", "Equality", "Extension", "Filigree", "Fragmented", "Hairpin", "Cork", "Meconium", "Ouroboros",
	"Used", "Vibrant", "Lighter", "Adoption", "Sodom", "Glasses", "Padlock", "Chewed", "Expansion", "Lullaby", "Necklace", "Gigante", "Gilded", "Jawbreaker", "Bargain", "Drawing", "Modeling", "Myosotis",
	"Nuh", "Capacitor", "Perfection", "Perfected", "Polished", "Fuse", "Teardrop", "Telescope", "Temporary", "Tattoo", "Girthy", "Unwieldy", "Gargantuan", "Prodigious", "Elephantine", "Cumbersome",
	"Thumping", "Awkward", "Biggish", "Cumbrous", "Poky", "Eensy", "Ickle", "Tiddly", "Titchy", "Weensy", "Pintsized", "Skimpy", "Toylike", "Great", "Own", "Different", "Next", "Early", "Young", "Few",
	"Public", "Available", "Basic", "Various", "Difficult", "Several", "United", "Historical", "Useful", "Mental", "Scared", "Additional", "Emotional", "Political", "Similar", "Healthy", "Financial",
	"Medical", "Traditional", "Federal", "Entire", "Actual", "Significant", "Successful", "Electrical", "Expensive", "Pregnant", "Intelligent", "Interesting", "Responsible", "Helpful", "Recent",
	"Willing", "Serious", "Impossible", "Technical", "Competitive", "Critical", "Immediate", "Aware", "Educational", "Environmental", "Global", "Legal", "Relevant", "Accurate", "Capable", "Dangerous",
	"Dramatic", "Efficient", "Foreign", "Practical", "Psychological", "Severe", "Suitable", "Numerous", "Sufficient", "Consistent", "Cultural", "Existing", "Famous", "Afraid", "Obvious", "Careful",
	"Latter", "Unhappy", "Acceptable", "Eastern", "Reasonable", "Strict", "Administrative", "Civil", "Former", "Southern", "Unfair", "Visible", "Alive", "Desperate", "Exciting", "Realistic", "Sorry",
	"Unlikely", "Comprehensive", "Curious", "Impressive", "Informal", "Sudden", "Terrible", "Unable", "Weak", "Asleep", "Confident", "Conscious", "Guilty", "Nervous", "All", "Most", "Such", "Any",
	"Much", "Another", "Still", "Both", "Sure", "Better", "Specific", "Enough", "Certain", "Possible", "Particular", "Least", "Natural", "Physical", "Individual", "Main", "Potential", "According",
	"Working", "Clear", "Primary", "Necessary", "Close", "Late", "Fit", "Proper", "Due", "Effective", "Regular", "Wide", "Complete", "Active", "Superpowered", "Superintelligent", "Superintendent",
	"Invincible", "Enchanting", "Vigorous", "Diligent", "Overwhelming", "Passionate", "Terrifying", "Zote", "Risk", "Grappling", "Malice", "Contraband", "Case", "Bedtime", "Putty", "Mix", "Perfectly",
	"Wrong", "Warp", "Pulvis", "Azurite", "Dazzling", "Lyre", "Mishuh", "Nil", "Yick", "Shredder", "Gloves", "Torture", "Crazy", "Slots", "Sculpted", "Pyromancy", "Pyromancer", "Spooter", "Sunglasses",
	"Spare", "Ribs", "Umbrella", "Pinhead", "Wallet", "Beginner", "Dichromatic", "Guts", "Achievement", "Chirumiru", "Leftover", "Leftovers", "Takeout", "Creep", "Gorgon", "Crucifix", "Minx", "Fetal",
	"Stash", "Fraudulent", "Peppermint", "Lawn", "Darts", "Model", "Sibling", "Syl", "Familiar", "Monas", "Hieroglyphica", "Deadly", "Dose", "Postiche", "Excelsior", "Griddle", "Griddled", "Chaldean",
	"Wimpy", "Emoji", "Abacus", "Jackpot", "Clutch", "Peeve", "Stockings", "Itself", "Toast", "Bobbies", "Kinda", "Dip", "Trophy", "Eulogy", "Figure", "Goldshi", "Reheated", "Dogboard", "Board",
	"Insignia", "Batoom", "Kling", "Badge", "Commissioned", "Dripping", "Spatula", "Bifurcated", "Fool", "Chili", "Molten", "Sandpaper", "Ribbon", "Jigsaw", "Puzzle", "Autopsy", "Jevil", "Dealmaker",
	"Vow", "Faic", "Shackle", "Gel", "Hatred", "Wackey", "Heartache", "Middle", "Faulty", "Conjoined", "Searcher", "Record", "Fuzzy", "Fushigi", "Nesting", "Dud", "Token", "The", "Lob", "Irk", "Try",
	"Wet", "Cod", "For", "Ebb", "Elk", "Ilk", "Get", "Sat", "Sit", "Wow", "See", "Jib", "Dub", "Nob", "Sag", "Vat", "Hub", "Dag", "Cot", "Wok", "Biz", "Was", "Won", "Awl", "Pug", "Con", "Err", "Mop",
	"Sbu", "Jut", "Lam", "Sod", "Too", "You", "Hut", "Rue", "Sup", "Fez", "Tad", "Log", "Tis", "Vex", "Fix", "Yon", "Fad", "Huh", "Sty", "Tug", "Sap", "Asp", "Jorb"
	}

function FiendFolio:CheckFairyDuplicates(...)
	local checks = {}
	local dupes = {}
	if ... then
		local args = {...}
		for j = 1, #args do
			for i = 1, #FiendFolio.FairyFlyNames do
				if FiendFolio.FairyFlyNames[i] == args[j] then
					table.insert(dupes, FiendFolio.FairyFlyNames[i])
				end
			end
		end
	else
		for i = 1, #FiendFolio.FairyFlyNames do
			local found
			if #checks > 0 then
				for j = 1, #checks do
					if FiendFolio.FairyFlyNames[i] == checks[j] then
						found = true
						break
					end
				end
			end
			if found then
				table.insert(dupes, FiendFolio.FairyFlyNames[i])
			end
			table.insert(checks, FiendFolio.FairyFlyNames[i])
		end
	end
	print(#dupes)
	if #dupes > 0 then
		for i = 1, #dupes do
			print(dupes[i])
		end
	end
end

function mod:GenerateFairyName(nameZaniness, basename)
	nameZaniness = nameZaniness or 0
	local name = basename or FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)]
	local thePossible = true
	local singularName = true
	if math.random() > 0.3 - (0.1*nameZaniness) then
		if nameZaniness >= 1 and math.random() > 0.3 then
			thePossible = false
			if math.random() > 0.9 then
				name = FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)] .. "-" .. name
			else
				name = FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)] .. string.lower(name)
			end
		end
		if nameZaniness >= 1 and math.random() > 0.6 then
			thePossible = false
			name = name .. " " .. FiendFolio.FairyFlyConnectors[math.random(#FiendFolio.FairyFlyConnectors)] .. " " .. FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)]
		else
			name = name .. " " .. FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)]
		end
		singularName = false
	end
	if math.random() > 0.5 then
		local rand = math.random()
		if nameZaniness >= 1 and math.random() > 0.7 then
			name = name .. " " .. FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)]
		end
		if rand > 0.9 then
			name = name .. "-" .. FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)]
		else
			name = name .. string.lower(FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)])
		end
		thePossible = false
		singularName = false
	end
	if (thePossible and math.random() > 0.5) or nameZaniness >= 2 then
		--Titles
		--local randVal = 8
		--randVal = math.max(randVal - (nameZaniness * 2), 3)
		local rand = math.random(3)
		if rand == 1 then
			local rand = math.random(2)
			if rand == 1 then
				name = FiendFolio.FairyFlyTitlesBoring[math.random(#FiendFolio.FairyFlyTitlesBoring)] .. " " .. name
			else
				name = FiendFolio.FairyFlyTitles[math.random(#FiendFolio.FairyFlyTitles)] .. " " .. name
			end
		elseif rand == 2 then
			name = name .. FiendFolio.FairyFlyEnders[math.random(#FiendFolio.FairyFlyEnders)]
		else
			name = "The " .. name
		end
	end
	if (singularName and math.random() > 0.7) or (nameZaniness >= 1 and math.random() > 0.9) or nameZaniness >= 2 then
		name = name .. " " .. FiendFolio.FairyFlyConnectors[math.random(#FiendFolio.FairyFlyConnectors)] .. " " .. FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)]
		if (math.random() > 0.9) or (nameZaniness >= 2 and math.random() > 0.6) then
			name = name .. " " .. FiendFolio.FairyFlyNames[math.random(#FiendFolio.FairyFlyNames)]
		end
		if nameZaniness >= 1 and math.random() > 0.8 then
			name = name .. FiendFolio.FairyFlyEnders[math.random(#FiendFolio.FairyFlyEnders)]
		end
	end
	if nameZaniness >= 2 and math.random() > 0.999 then
		name = name .. " Featuring Dante from the Devil May Cry Series"
	end
	return name
end