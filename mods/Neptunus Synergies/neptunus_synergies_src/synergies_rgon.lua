local mod = RoarysNeptunusSynergies
local sfx = SFXManager()

local nepPower = 0.442329615175	-- weird power for Neptunus charge decrease
-- this is NOT vanilla formula, but one close enough for me to stop. 
-- chargeDecreaseFormula = (math.max(player.MaxFireDelay,0)+1)^((rnsNepNCharge)^nepPower)
-- newCharge = oldCharge - chargeDecreaseFormula

local function changeSprite(entity, file)
	local sprite = entity:GetSprite()
	local anim = sprite:GetAnimation()
	file = file or sprite:GetFilename():sub(1, -6).."_neptunus.anm2"
	sprite:Load(file, true)
	sprite:Play(anim, true)
end

local nonBloodTearVars = {
	[TearVariant.BLOOD] = TearVariant.BLUE,
	[TearVariant.CUPID_BLOOD] = TearVariant.CUPID_BLUE,
	[TearVariant.PUPULA_BLOOD] = TearVariant.PUPULA,
	[TearVariant.GODS_FLESH_BLOOD] = TearVariant.GODS_FLESH,
	[TearVariant.NAIL_BLOOD] = TearVariant.NAIL,
	[TearVariant.GLAUCOMA_BLOOD] = TearVariant.GLAUCOMA,
	[TearVariant.EYE_BLOOD] = TearVariant.EYE,
	[TearVariant.KEY_BLOOD] = TearVariant.KEY
}


local function getAxisAlignedVector(vector)
	if math.abs(vector.Y) >= math.abs(vector.X) then
		return Vector(0, vector.Y):Normalized()
	else
		return Vector(vector.X, 0):Normalized()
	end
end


local function getFamiliarDMGMult(entity)
	if entity == nil then return 1 end
	local fam = entity:ToFamiliar()
	if not fam then return 1 end
	
	local ownerMult = 0.75
	local BFFSMult = 1
	if fam.Player then
		local pType = fam.Player:GetPlayerType()
		if pType == PlayerType.PLAYER_LILITH or pType == PlayerType.PLAYER_LILITH_B then
			ownerMult = 1
		end
		if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			BFFSMult = 2
		end
	end
	
	if fam.Variant == FamiliarVariant.CAINS_OTHER_EYE
	or fam.Variant == FamiliarVariant.INCUBUS
	or fam.Variant == FamiliarVariant.UMBILICAL_BABY
	then
		return 1 * ownerMult * BFFSMult
	elseif fam.Variant == FamiliarVariant.TWISTED_BABY then
		return 0.5 * ownerMult * BFFSMult
	elseif fam.Variant == FamiliarVariant.BLOOD_BABY then -- blood clots
		if fam.SubType == 2 then	-- from black hearts
			return 0.4375 * BFFSMult
		elseif fam.SubType == 3 then	-- from eternal half-heart
			return 0.525 * BFFSMult
		else	-- all the rest
			return 0.35 * BFFSMult
		end
	else
		return 1
	end
end


local function findOwner(entity)
	if not entity then return end
	local owner = entity:ToPlayer() or entity:ToFamiliar()
	local ownerRelatedType = {
		[EntityType.ENTITY_PLAYER] = true,
		[EntityType.ENTITY_TEAR] = true,
		[EntityType.ENTITY_FAMILIAR] = true,
		[EntityType.ENTITY_BOMB] = true,
		[EntityType.ENTITY_LASER] = true,
		[EntityType.ENTITY_KNIFE] = true,
		[EntityType.ENTITY_EFFECT] = true
	}
	while not owner do
		entity = entity.Parent or entity.SpawnerEntity
		if not entity then break end
		if not ownerRelatedType[entity.Type] then break end
		owner = entity:ToPlayer() or entity:ToFamiliar()
	end
	if owner then
		if owner:GetWeapon(1) then	--filter non-player-like familiars
			return owner
		end
	end
	return false
end

-- Player's target can be found by Player:GetActiveWeaponEntity() but it's no use for familiars,
-- Only owner's "main" target has .SubType = 0
-- Additional targets from Eye Sore, Loki Horns e.t.c., have different subtype
local function findTarget(owner)
	local ownerHash = GetPtrHash(owner)
	local ownersTarget = nil
	for i,target in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT,EffectVariant.TARGET,0,true)) do
		if target.SpawnerEntity then
			if ownerHash == GetPtrHash(target.SpawnerEntity) then
				ownersTarget = target
				break
			end
		end
	end
	return ownersTarget
end



local function fireTearBurst(player, Position, Velocity, TearsAmount, Source, DamageMultiplier)
	for i=1, TearsAmount do
		local vel = Velocity * (1 + math.random(-500,333)/1000)
		vel = vel:Rotated(math.random(-150, 150)/10)
		local tear = player:FireTear(Position, vel, true, false, true, Source, DamageMultiplier)
		if math.random(0,1) == 1 then
			tear.Scale = tear.Scale * (1.3 + math.random(0, 5)/100)
		else
			tear.Scale = tear.Scale * (0.9 + math.random(0, 5)/100)
		end
		local rand = math.random(-2000,9000)/1000
		tear.Height = tear.Height - rand
		tear.FallingSpeed = tear.FallingSpeed - rand
		tear.FallingAcceleration = tear.FallingAcceleration + 0.5
	end
end


local function fireBombBurst(player, Position, Velocity, BombsAmount, Source, DamageMultiplier)
	local tearScale = player:GetTearHitParams(WeaponType.WEAPON_BOMBS, 1, 1, Source).TearScale
	local defaultScale = math.min((tearScale/6)^0.5, 0.5)
	for i=1, BombsAmount do
		local scale = defaultScale + math.random(300)/1000
		local vel = Velocity * (0.666 + math.random(334)/1000)
		vel = vel:Rotated(math.random(-150, 150)/10)
		local bomb = player:FireBomb(Position, vel, Source)
		bomb:SetExplosionCountdown(math.random(20,30))
		bomb:SetHeight(-math.random(8000)/1000)
		if bomb.Variant == BombVariant.BOMB_ROCKET then
			bomb:SetFallingSpeed(0.1)
		else
			bomb:SetFallingSpeed(0.8)
		end
		bomb.ExplosionDamage = bomb.ExplosionDamage * DamageMultiplier
		bomb.RadiusMultiplier = bomb.RadiusMultiplier * scale
		bomb:SetScale(scale)
		bomb:SetLoadCostumes()
	end
end


local function shootMonstrosLung(player, owner, weapon, neptunusCharge, vectorDirection, isBone)
	-- Max tears amount per single burst
	local attack = fireTearBurst
	local maxTearsAmount = 5 + player:GetMultiShotParams(WeaponType.WEAPON_MONSTROS_LUNGS):GetNumTears()
	local dmgMult = 1
	local tearsAmount = 0
	
	-- Bomb attack
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) and not isBone then
		attack = fireBombBurst
	-- Tear attack
	else
		maxTearsAmount = math.min(math.floor(2.4*maxTearsAmount+0.5), 50)
		-- Haemolacria (familiars are affected)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
			maxTearsAmount = math.floor(maxTearsAmount*4/7+0.5)
		end
		-- Chocolate milk damage mult
		if weapon:GetModifiers() & WeaponModifier.CHOCOLATE_MILK ~= 0 then
			local maxFireDelay = weapon:GetMaxFireDelay()
			local chocCharge = neptunusCharge
			if weapon:GetModifiers() & WeaponModifier.SOY_MILK ~= 0 or maxFireDelay <= 0 then
				chocCharge = 1	--(weapon:GetCharge()-1) / math.ceil(maxFireDelay*2.5)
			end
			-- yes it's lazy way to achieve known values of dmg mult:
			-- 0.1x at first frame, 1x at 50%, and 2x at full charge;
			-- but for sake of my sanity I'll just keep it like this
			chocCharge = 2 * chocCharge
			local part1 = 0
			local part2 = 0
			if chocCharge >= 1 then
				part1 = 1
				part2 = chocCharge - 1
			else
				part1 = chocCharge
			end
			dmgMult = dmgMult * (0.1 + 0.9*part1 + part2)
		elseif isBone then	-- Add extra tears in case normal attack wasn't fully charged
			local maxFireDelay = weapon:GetMaxFireDelay() * 2
			if maxFireDelay > 0 then
				local weaponCharge = weapon:GetCharge()
				if weaponCharge < maxFireDelay then
					tearsAmount = math.floor(maxTearsAmount * (weaponCharge/maxFireDelay) + 0.2)
				end
			end
		end
	end
	
	if isBone then
		tearsAmount = tearsAmount + math.floor(maxTearsAmount * (neptunusCharge) + 0.2)
	else
		tearsAmount = maxTearsAmount
	end
	
	-- Main shoot process
	local multiShotParams = player:GetMultiShotParams(WeaponType.WEAPON_MONSTROS_LUNGS)
	for i=0, multiShotParams:GetNumEyesActive()-1 do
		local posvel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_LASER, vectorDirection, player.ShotSpeed*10, multiShotParams)
		pos = owner.Position + posvel.Position
		vel = posvel.Velocity + player:GetTearMovementInheritance(posvel.Velocity)
		attack(player, owner.Position, vel, tearsAmount, owner, dmgMult)
	end
	
	if not isBone then
		-- Additional shoot processes: Loki's Horns, Mom's Eye, Eye Sore
		local pureVelocity = vectorDirection*10*player.ShotSpeed
		pureVelocity = pureVelocity + player:GetTearMovementInheritance(pureVelocity)
		
		if multiShotParams:IsShootingSideways() then
			attack(player, owner.Position, pureVelocity:Rotated(-90), tearsAmount, owner, dmgMult)
			attack(player, owner.Position, pureVelocity:Rotated(90), tearsAmount, owner, dmgMult)
		end
		if multiShotParams:IsShootingBackwards() then
			attack(player, owner.Position, pureVelocity:Rotated(180), tearsAmount, owner, dmgMult)
		end
		for i=1, multiShotParams:GetNumRandomDirTears() do
			attack(player, owner.Position, pureVelocity:Rotated(math.random(0, 359)), tearsAmount, owner, dmgMult)
		end
	end
end




local function shootTechX(player, owner, weapon, vectorDirection)
	local maxFireDelay = weapon:GetMaxFireDelay()
	local weaponCharge = weapon:GetCharge()
	local dmgMult
	if maxFireDelay > -2/3 then
		dmgMult = (3*(weaponCharge + 1)/(maxFireDelay + 1) - 1)/8
	else
		dmgMult = 1
	end
	local pos = owner.Position
	local vel = vectorDirection*player.ShotSpeed*10
	local radius = 60*dmgMult
	local multiShotParams = player:GetMultiShotParams(WeaponType.WEAPON_TECH_X)
	
	-- Main shoot process
	for i=0, multiShotParams:GetNumTears()-1 do	
		local posvel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TECH_X, vectorDirection, player.ShotSpeed*10, multiShotParams)
		pos = owner.Position + posvel.Position
		vel = posvel.Velocity + player:GetTearMovementInheritance(posvel.Velocity)
		player:FireTechXLaser(pos, vel, radius, owner, dmgMult)
	end
	
	-- Loki's Horns
	if multiShotParams:IsShootingSideways() then
		local velForward = vel + player:GetTearMovementInheritance(vel)
		local velBack = vel:Rotated(180)
		velBack = velBack + player:GetTearMovementInheritance(velBack)
		player:FireTechXLaser(pos, velForward, radius, owner, dmgMult)
		player:FireTechXLaser(pos, velBack, radius, owner, dmgMult)
	end
	-- Mom's Eye
	if multiShotParams:IsShootingBackwards() then
		local velBack = vel:Rotated(180)
		velBack = velBack + player:GetTearMovementInheritance(velBack)
		player:FireTechXLaser(pos, velBack, radius, owner, dmgMult)
	end
	
	-- Eye Sore
	local eyeSoreTears = multiShotParams:GetNumRandomDirTears()
	if eyeSoreTears > 0 then
		for i=1, eyeSoreTears do
			local velRand = vel:Rotated(math.random(-25,25))
			velRand = velRand + player:GetTearMovementInheritance(velRand)
			local randMult = (0.4+math.random(60)/100)
			player:FireTechXLaser(pos, velRand, radius*randMult, owner, dmgMult*randMult)
		end
	-- Monstro's Lung
	elseif weapon:GetModifiers() & WeaponModifier.MONSTROS_LUNG ~= 0 then
		for i=1, math.random(3)+2 do
			local velRand = vel:Rotated(math.random(-30,30))
			velRand = velRand + player:GetTearMovementInheritance(velRand)
			local randMult = (0.4+math.random(6)/10)
			player:FireTechXLaser(pos, velRand, radius*randMult, owner, dmgMult*randMult)
		end
	end
end






function mod:evaluateCache(player, flag)
	if not mod.config.changeSprites then return end
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then return end
	
	player:SetLaserColor(player:GetTearHitParams(WeaponType.WEAPON_TEARS).TearColor)
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, mod.evaluateCache, CacheFlag.CACHE_TEARCOLOR)

-- Order, in which weapon related callbacks fire:
-- MC_POST_WEAPON_FIRE
-- MC_POST_FIRE_<Entity>
-- MC_POST_TRIGGER_WEAPON_FIRED

-- MC_POST_TRIGGER_WEAPON_FIRED is called every time <frame> when player/familiar's weapon has either
-- fired new weapon-entities (tears, tech-lasers, alike)
-- updated active weapon-entities (brim, ludo)
--
-- in case with knife it will only fire upon knife being thrown
-- in case with Da bONe/Berserk it will fire upon both swing and throw
-- in case with sword it will fire upon both normal attack and spin-attack, won't fire for sword tears

function mod:postWeaponFire(weapon, fireDir, isShooting, isInterpolated)
	local owner = weapon:GetOwner()
	if not owner then return end
	
	local data = owner:GetData()
	local weaponModifiers = weapon:GetModifiers()
	if weaponModifiers & WeaponModifier.NEPTUNUS ~= WeaponModifier.NEPTUNUS then 
		data.rnsDataSet = nil
		return
	end
	
	-- player handle
	local player = owner:ToPlayer()
	if player then
		-- for Forgotten, to save charge between forms;
		-- familiars don't observe PlayerType change, they just copy player's weapon state
		-- and as result, in case player_new_weapon_type ~= player_old_weapon_type,
		-- then familiar will just think that WeaponType changed, and will reset charge as normally
		-- thus I'm officialy allowed to not give a shit about familiar in that case
		-- ¯\_(ツ)_/¯
		local pType = player:GetPlayerType()
		if not data.rnsDataSet then
			data.rnsPTypeData = {}	-- for Forgotten, so Forgotten's charge stays in place
			data.rnsPTypeCurrent = player:GetPlayerType()
		elseif data.rnsPTypeCurrent ~= pType then
			-- save old form data
			data.rnsPTypeData[data.rnsPTypeCurrent] = {
				rnsNepCharge = data.rnsNepCharge,
				rnsNepNCharge = data.rnsNepNCharge,
				rnsDisplayedCharge = data.rnsDisplayedCharge,
				rnsPrevNCharge = data.rnsPrevNCharge,
				rnsSavedNCharge = data.rnsSavedNCharge,
				rnsState = data.rnsState,
				rnsChargeShortened = data.rnsChargeShortened,
				rnsLastFireInput = data.rnsLastFireInput,
				rnsSafeFireInput = data.rnsSafeFireInput,
				rnsWasShooting = data.rnsWasShooting,
				rnsPrevWeapon = data.rnsPrevWeapon
			}
			-- new form already has data, swap data
			if data.rnsPTypeData[pType] then
				for i,v in pairs(data.rnsPTypeData[pType]) do
					data[i] = v
				end
			else	-- absolutely new form, reset data
				data.rnsDataSet = false
			end
			data.rnsPTypeCurrent = pType
		end
		
		if player:GetWeapon(0) then
			-- T.Lilith handle
			if player:GetWeapon(0):GetWeaponType() == WeaponType.WEAPON_UMBILICAL_WHIP then
				-- synchronize Umbilical baby with T.Lilith
				local babyWeapon = player:GetActiveWeaponEntity()
				if babyWeapon then
					local baby = babyWeapon:ToFamiliar()
					if baby and not data.rnsBabySynchronized then
						local bData = baby:GetData()
						bData.rnsDataSet = true
						bData.rnsNepCharge = data.rnsNepCharge
						bData.rnsNepNCharge = data.rnsNepNCharge
						bData.rnsPrevNCharge = data.rnsPrevNCharge
						bData.rnsSavedNCharge = 0
						bData.rnsState = 0
						bData.rnsChargeShortened = false
						bData.rnsLastFireInput = data.rnsLastFireInput
						bData.rnsSafeFireInput = data.rnsSafeFireInput
						bData.rnsWasShooting = data.rnsWasShooting
						bData.rnsPrevWeapon = player:GetWeapon(1):GetWeaponType()
						
						bData.rnsIsDaBaby = player
						data.rnsBabySynchronized = true
					end
					data.rnsDisplayedCharge = 0
					return
				-- synchronize T.Lilith with Umbilical baby
				else
					data.rnsBabySynchronized = nil
				end
			-- Actives (Notched Axe, Urn of Souls)
			else
				return
			end
		elseif not player:CanShoot() then
			data.rnsDataSet = nil
			data.rnsDisplayedCharge = 0
			return
		end
	-- familiar handle
	elseif owner.Type == EntityType.ENTITY_FAMILIAR then
		player = owner:ToFamiliar().Player
	end
	
	local curFrame = Game():GetFrameCount()
	local weaponType = weapon:GetWeaponType()
	local weaponCharge = weapon:GetCharge()
	local curFireDelay = weapon:GetFireDelay()
	local maxFireDelay = weapon:GetMaxFireDelay()
	local maxNepCharge = math.max(11 + 12*maxFireDelay,2)
	
	
	if not data.rnsDataSet then
		--data.rnsNepChargebar = nil
		data.rnsNepCharge = 0
		data.rnsNepNCharge = 0 -- normalized charge
		data.rnsDisplayedCharge = 0
		data.rnsPrevNCharge = 0 -- normalized previous charge
		data.rnsSavedNCharge = 0
		data.rnsState = 0	-- for charged attacks
			-- states work differently, depeding on weapon, but generally:
			-- state = 0 -> (Charging Neptunus): charge Neptunus;
			-- state = 1 -> (Charging weapon): do NOTHING - Nep charge stopped and no reset;
			-- state = 2 -> (Weapon specific);
			-- state = 3 -> (Charge reset): upon being set apply bonus during frame, and reset charge and state to 0 on next one.
		data.rnsChargeShortened = false
		data.rnsLastFireInput = Vector.Zero
		data.rnsSafeFireInput = Vector.Zero	-- Last non-zero fire input
		data.rnsWasShooting = false
		data.rnsLastFrameRunned = curFrame-1	-- to ensure it's first callback in frame
		data.rnsPrevWeapon = weaponType
		data.rnsDataSet = true
	end
	
	data.rnsHasWeaponMod = {
		[WeaponModifier.CHOCOLATE_MILK] = weaponModifiers & WeaponModifier.CHOCOLATE_MILK == WeaponModifier.CHOCOLATE_MILK,
		[WeaponModifier.CURSED_EYE] = weaponModifiers & WeaponModifier.CURSED_EYE == WeaponModifier.CURSED_EYE,
		[WeaponModifier.BRIMSTONE] = weaponModifiers & WeaponModifier.BRIMSTONE == WeaponModifier.BRIMSTONE,
		[WeaponModifier.MONSTROS_LUNG] = weaponModifiers & WeaponModifier.MONSTROS_LUNG == WeaponModifier.MONSTROS_LUNG,
		[WeaponModifier.LUDOVICO_TECHNIQUE] = weaponModifiers & WeaponModifier.LUDOVICO_TECHNIQUE == WeaponModifier.LUDOVICO_TECHNIQUE,
		[WeaponModifier.ANTI_GRAVITY] = weaponModifiers & WeaponModifier.ANTI_GRAVITY == WeaponModifier.ANTI_GRAVITY,
		[WeaponModifier.TRACTOR_BEAM] = weaponModifiers & WeaponModifier.TRACTOR_BEAM == WeaponModifier.TRACTOR_BEAM,
		[WeaponModifier.SOY_MILK] = weaponModifiers & WeaponModifier.SOY_MILK == WeaponModifier.SOY_MILK,
		[WeaponModifier.NEPTUNUS] = true, -- it won't get here if it was false
		[WeaponModifier.AZAZELS_SNEEZE] =  weaponModifiers & WeaponModifier.AZAZELS_SNEEZE == WeaponModifier.AZAZELS_SNEEZE,
		[WeaponModifier.C_SECTION] = weaponModifiers & WeaponModifier.C_SECTION == WeaponModifier.C_SECTION,
		[WeaponModifier.FAMILIAR] = weaponModifiers & WeaponModifier.FAMILIAR == WeaponModifier.FAMILIAR,
		[WeaponModifier.BONE] = weaponModifiers & WeaponModifier.BONE == WeaponModifier.BONE
	}
	
	-- reset upon new weapon, like vanilla (modifiers don't cause charge reset)
	if weaponType ~= data.rnsPrevWeapon then
		data.rnsNepCharge = 0
		data.rnsNepNCharge = 0
		--data.rnsPrevNCharge = 0
		data.rnsState = 0
		data.rnsChargeShortened = false
		-- data.rnsWasShooting = false
		data.rnsPrevWeapon = weaponType
	end
	
	-- change only once in update cycle
	if not isInterpolated then
		data.rnsPrevNCharge = data.rnsNepNCharge
	end
	
	local isReallyAxisAligned = weapon:IsAxisAligned()	-- only checks for Analog Stick, ignoring weapon specifics
	--== The Start of weapon B******t ==--
	-- T. Lilith
	if weaponType == WeaponType.WEAPON_UMBILICAL_WHIP then
		data.rnsNepCharge = data.rnsNepCharge + 0.75
	
	-- C Section
	elseif weaponType == WeaponType.WEAPON_FETUS then
		if isShooting then
			if not data.rnsChargeShortened then
				weapon:SetCharge(weaponCharge + (2.85*maxFireDelay-weaponCharge)*(data.rnsNepNCharge^0.5))
				data.rnsChargeShortened = true
			end
			if data.rnsLastFrameRunned ~= curFrame and data.rnsWasShooting then
				data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((0.33*data.rnsNepNCharge)^nepPower)
			end
		else
			data.rnsNepCharge = data.rnsNepCharge + 1
			data.rnsChargeShortened = false
		end
	
	-- BONE
	elseif weaponType == WeaponType.WEAPON_BONE then
		if data.rnsState ~= 1 then
			-- Idle
			if data.rnsState == 0 then
				if isShooting and (player.FireDelay == player.MaxFireDelay
				or (data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
				or data.rnsHasWeaponMod[WeaponModifier.CURSED_EYE]
				or data.rnsHasWeaponMod[WeaponModifier.BRIMSTONE]
				or data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG])
				and player.FireDelay == 0)
				then
					data.rnsState = 1
				elseif not isShooting then
					data.rnsNepCharge = data.rnsNepCharge + 1
				end
			-- Throw attack
			elseif data.rnsState == 3 then
				local mult = 6
				if data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 0 then
					mult = 1.5
				end
				data.rnsNepCharge = data.rnsNepCharge - mult*(math.max(maxFireDelay,0)+1)^((0.5*data.rnsNepNCharge)^nepPower)
				if player and player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
					data.rnsState = 0
				else
					data.rnsState = 1
				end
			-- Swing attack (states 2 & 4)
			else
				local mult2 = 1.5 - math.max(math.min(maxFireDelay/20, 1.2), 0)
				local mult = 4
				if data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 0 then
					mult = 1
				end
				data.rnsNepCharge = data.rnsNepCharge - mult*(math.max(maxFireDelay,0)+1)^((mult2*data.rnsNepNCharge)^nepPower)
				if data.rnsState == 4 then
					data.rnsState = 0
				else
					data.rnsState = 1
				end
			end
		end
	
	-- Spirit Sword
	elseif weaponType == WeaponType.WEAPON_SPIRIT_SWORD then
		if data.rnsState == 3 then
			data.rnsNepCharge = data.rnsNepCharge - 5*(math.max(maxFireDelay,0)+1)^((0.5*data.rnsNepNCharge)^nepPower)
			data.rnsState = 1
		elseif data.rnsState == 0 then
			data.rnsNepCharge = data.rnsNepCharge + 0.75
		end
	
	-- Epic Fetus
	elseif weaponType == WeaponType.WEAPON_ROCKETS then
		isReallyAxisAligned = false
		local target = findTarget(owner)
		local mult1 = 6
		local mult2 = 0.75
		
		if target then	-- changes for Epic Fetus Synergies by JamesB456
			local tData = target:GetData()
			if tData.IsLudoTarget then
				mult1 = 7
				mult2 = 1.25
				if data.rnsState ~= 3 then
					data.rnsNepCharge = data.rnsNepCharge + 1
				end
			elseif tData.IsSoyMilkTarget then
				mult1 = 4
				mult2 = 0.75
			end
		end
		
		-- decrease charge upon each explosion
		if data.rnsState == 3 then
			data.rnsNepCharge = data.rnsNepCharge - mult1*(math.max(maxFireDelay,0)+1)^((mult2*data.rnsNepNCharge)^nepPower)
			data.rnsState = 2
		end
		
		if not target then
			if data.rnsState == 2 then
				data.rnsState = 0
			else
				data.rnsNepCharge = data.rnsNepCharge + 1
			end
		end
	
	-- Mom's Knife
	elseif weaponType == WeaponType.WEAPON_KNIFE then
		isReallyAxisAligned = false
		-- Ludo
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.1*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 0.75
			end
		-- Normal
		else
			if data.rnsHasWeaponMod[WeaponModifier.TRACTOR_BEAM] then
				isReallyAxisAligned = true
			end
			if data.rnsState ~= 1 then
				if data.rnsState == 0 then
					data.rnsNepCharge = data.rnsNepCharge + 1
				elseif data.rnsState == 2 then
					data.rnsNepCharge = 0
					data.rnsState = 1
				elseif data.rnsState == 3 then
					data.rnsNepCharge = 0
					data.rnsState = 0
				end
				if isShooting then
					data.rnsState = 1
				end
			end
		end
	
	-- Dr. Fetus
	elseif weaponType == WeaponType.WEAPON_BOMBS then
		if isShooting then
			if not data.rnsChargeShortened then
				weapon:SetFireDelay(curFireDelay*(1-0.95*(data.rnsNepNCharge^0.5)))
				data.rnsChargeShortened = true
			end
			if data.rnsLastFrameRunned ~= curFrame and data.rnsWasShooting then
				data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			end
		else
			data.rnsNepCharge = data.rnsNepCharge + 1
		end
	
	-- Tech X
	elseif weaponType == WeaponType.WEAPON_TECH_X then
		if isShooting then
			local newCharge = weaponCharge
			if player
			and maxFireDelay > 0
			and not data.rnsHasWeaponMod[WeaponModifier.SOY_MILK]	-- no natural autoshoot
			and weaponCharge >= math.max(3*maxFireDelay, 1) -- is fully charged
			and data.rnsNepNCharge >= 0.05
			then	--try imitate player fire
				local realFireInput = fireDir
				if isReallyAxisAligned then
					realFireInput = getAxisAlignedVector(fireDir)
				end
				shootTechX(player, owner, weapon, realFireInput)
				newCharge = 0
				data.rnsChargeShortened = false
			end
			if not data.rnsChargeShortened and maxFireDelay > 0 then
				weapon:SetCharge(newCharge + (2.7*maxFireDelay-newCharge)*(data.rnsNepNCharge^0.9))
				data.rnsChargeShortened = true
			end
			if data.rnsLastFrameRunned ~= curFrame and data.rnsWasShooting then
				data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((0.66*data.rnsNepNCharge)^nepPower)
			end
		else
			data.rnsNepCharge = data.rnsNepCharge + 0.75
			data.rnsChargeShortened = false
		end
	
	-- Brim
	elseif weaponType == WeaponType.WEAPON_BRIMSTONE then
		-- Ludo
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			isReallyAxisAligned = false
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.1*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 0.75
			end
			data.rnsState = 3 -- used here, so size only changes when weapon fires
		-- Autoshoot (soy-brim)
		elseif data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 1 then
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.1*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 1
			end
		-- Normal Brim (Anti-Gravity works fine without extra moves)
		else
			if not isShooting then
				if data.rnsState == 3 then
					-- charge decrease in postTriggerWeaponFired
					data.rnsState = 0
				elseif data.rnsWasShooting then
					if weaponCharge >= maxFireDelay
					or data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
					then
						--apply boost during frame
						data.rnsState = 3
					else
						data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
					end
				else
					data.rnsNepCharge = data.rnsNepCharge + 1
				end
			end
		end
	
	-- Technology
	elseif weaponType == WeaponType.WEAPON_LASER then
		-- Ludo
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			isReallyAxisAligned = false
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.1*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 0.75
			end
			data.rnsState = 3 -- used here, so size only changes when weapon fires
		-- Tech-Lung
		elseif data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
			if not isShooting then
				if data.rnsWasShooting then
					data.rnsNepCharge = data.rnsNepCharge - 6*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
					data.rnsSavedNCharge = data.rnsNepNCharge
				else
					data.rnsNepCharge = data.rnsNepCharge + 0.5
				end
			elseif not data.rnsWasShooting then
				data.rnsSavedNCharge = data.rnsNepNCharge
			end
		-- Cursed
		elseif data.rnsHasWeaponMod[WeaponModifier.CURSED_EYE] then
			if not isShooting then
				if data.rnsState == 3 then
					data.rnsNepCharge = 0
					data.rnsState = 0
				elseif data.rnsWasShooting then
					if weaponCharge >= maxFireDelay
					or data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
					then
						--apply boost during frame
						data.rnsState = 3
						data.rnsSavedNCharge = data.rnsNepNCharge
					else
						data.rnsNepCharge = 0
						data.rnsState = 0
					end
				else
					data.rnsNepCharge = data.rnsNepCharge + 1
				end
			end
		-- Chocolate Milk
		elseif data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK] then
			
			if not data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] and maxFireDelay > 0 then	-- no natural autoshoot, only allow imitated fire
				weapon:SetCharge(-1)
			end
			
			if isShooting then 
				local newFireDelay = curFireDelay
				local maxWeaponCharge = math.ceil(2.5*maxFireDelay+1.5)	-- SHOULD be game's formula
				if player and curFireDelay <= 0 then
					local realFireInput = fireDir
					if isReallyAxisAligned then
						realFireInput = getAxisAlignedVector(fireDir)
					end
					local dmgMult = (0.1 + 3.9*(data.rnsNepCharge)/(maxNepCharge))	-- not really accurate, but hey, it's close enough
					local pos = owner.Position
					local vel = realFireInput*player.ShotSpeed*10
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
						-- Tractor Beam cancels player:GetTearMovementInheritance()
						vel = vel + player:GetTearMovementInheritance(vel)/2
					end
					local multiShotParams = player:GetMultiShotParams(WeaponType.WEAPON_LASER)
					
					-- bug? MC_POST_FIRE_TECH_LASER isn't called if laser is spawned via player:FireTechLaser() or if is spawned by familiar
					if multiShotParams:IsShootingSideways() then
						for i=0, 1 do
							local laser = player:FireTechLaser(pos, LaserOffset.LASER_MOMS_EYE_OFFSET, vel:Rotated(-90+180*i), true, true, owner, dmgMult)
							if mod.config.changeSprites then
								changeSprite(laser)
								laser:GetData().rnsChangedSprite = true
							end
							-- impact handles itself
						end
					end
					
					if multiShotParams:IsShootingBackwards() then
						local laser = player:FireTechLaser(pos, LaserOffset.LASER_MOMS_EYE_OFFSET, vel:Rotated(180), true, true, owner, dmgMult)
						if mod.config.changeSprites then
							changeSprite(laser)
							laser:GetData().rnsChangedSprite = true
						end
					end
					
					for i=1, multiShotParams:GetNumRandomDirTears() do
						local laser = player:FireTechLaser(pos, LaserOffset.LASER_MOMS_EYE_OFFSET, vel:Rotated(math.random(359)), true, true, owner, dmgMult)
						if mod.config.changeSprites then
							changeSprite(laser)
							laser:GetData().rnsChangedSprite = true
						end
					end
					
					-- usual shoot process;
					if player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
						for i=0, multiShotParams:GetNumTears()-1 do
							local posvel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_LASER, realFireInput, player.ShotSpeed*10, multiShotParams)
							pos = owner.Position + posvel.Position
							local laser = player:FireTechLaser(pos, LaserOffset.LASER_TECH1_OFFSET, posvel.Velocity, true, true, owner, dmgMult)
							if mod.config.changeSprites then
								changeSprite(laser)
								laser:GetData().rnsChangedSprite = true
							end
						end
					else
						for i=0, multiShotParams:GetNumTears()-1 do
							local posvel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_LASER, realFireInput, player.ShotSpeed*10, multiShotParams)
							pos = owner.Position + posvel.Position
							vel = posvel.Velocity + player:GetTearMovementInheritance(posvel.Velocity)/2
							local laser = player:FireTechLaser(pos, LaserOffset.LASER_TECH1_OFFSET, vel, true, true, owner, dmgMult)
							if mod.config.changeSprites then
								changeSprite(laser)
								laser:GetData().rnsChangedSprite = true
							end
						end
					end
					newFireDelay = newFireDelay + maxFireDelay
					data.rnsChargeShortened = false
				end
				if not data.rnsChargeShortened then
					weapon:SetFireDelay(newFireDelay*(1-0.95*(data.rnsNepNCharge^0.5)))
					data.rnsChargeShortened = true
				end
				if data.rnsLastFrameRunned ~= curFrame and data.rnsWasShooting then
					data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
				end
			else
				data.rnsNepCharge = data.rnsNepCharge + 1
			end
		--Normal Tech
		else
			if isShooting then
				if not data.rnsChargeShortened then
					weapon:SetFireDelay(curFireDelay*(1-0.95*(data.rnsNepNCharge^0.5)))
					data.rnsChargeShortened = true
				end
				if data.rnsLastFrameRunned ~= curFrame and data.rnsWasShooting then
					data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
				end
			else
				data.rnsNepCharge = data.rnsNepCharge + 1
			end
		end
	
	-- Ludovico Technique
	elseif weaponType == WeaponType.WEAPON_LUDOVICO_TECHNIQUE then
		isReallyAxisAligned = false
		if isShooting then
			data.rnsNepCharge = data.rnsNepCharge - 0.1*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
		else
			data.rnsNepCharge = data.rnsNepCharge + 0.75
		end
	
	-- Monsro's Lungs
	elseif weaponType == WeaponType.WEAPON_MONSTROS_LUNGS then
		if not data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] and maxFireDelay > 0 then
			weapon:SetCharge(-1)
		end
		if isShooting then
			local newFireDelay = curFireDelay
			if curFireDelay <= 0 then
				if player then
					local realFireInput = fireDir
					if isReallyAxisAligned then
						realFireInput = getAxisAlignedVector(fireDir)
					end
					shootMonstrosLung(player, owner, weapon, data.rnsNepNCharge, realFireInput, false)
				end
				weapon:SetHeadLockTime(2)
				newFireDelay = newFireDelay + maxFireDelay
				data.rnsChargeShortened = false
			end
			if not data.rnsChargeShortened then
				weapon:SetFireDelay(newFireDelay*(1-0.95*(data.rnsNepNCharge^0.5)))
				data.rnsChargeShortened = true
			end
			if data.rnsLastFrameRunned ~= curFrame and data.rnsWasShooting then
				data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			end
		else
			data.rnsNepCharge = data.rnsNepCharge + 1.5
		end
	
	-- Tears (for T.Lilith's Umbilical baby)
	elseif weaponType == WeaponType.WEAPON_TEARS then
		if data.rnsIsDaBaby then
			if data.rnsNepCharge ~= 0 then
				weapon:SetCharge(data.rnsNepCharge)
				data.rnsNepCharge = 0
			else
				data.rnsTrueNepCharge = weapon:GetCharge()
			end
		end
	end
	--== The End of weapon B******t ==--
	
	data.rnsWasShooting = isShooting
	if isReallyAxisAligned then
		data.rnsLastFireInput = getAxisAlignedVector(fireDir)
	else
		data.rnsLastFireInput = fireDir
	end
	if data.rnsLastFireInput.X ~= 0 or data.rnsLastFireInput.Y ~= 0 then
		data.rnsSafeFireInput = data.rnsLastFireInput
	end
	data.rnsNepCharge = math.min(math.max(0, data.rnsNepCharge), maxNepCharge)
	data.rnsNepNCharge = data.rnsNepCharge/maxNepCharge
	data.rnsDisplayedCharge = math.floor(data.rnsNepNCharge*100 + 0.5)
	data.rnsLastFrameRunned = curFrame
end
mod:AddCallback(ModCallbacks.MC_POST_WEAPON_FIRE, mod.postWeaponFire)


function mod:postTriggerWeaponFired(fireDir, fireAmount, owner, weapon)
	local data = owner:GetData()
	if not data.rnsDataSet then return end
	
	local player = owner:ToPlayer() or owner:ToFamiliar().Player
	data.rnsChargeShortened = false
	
	local weaponType = weapon:GetWeaponType()
	if weaponType == WeaponType.WEAPON_BONE then
		data.rnsState = 1
		
		local mult = false
		local maxFireDelay = weapon:GetMaxFireDelay()
		-- Bone + Lung synergy
		if data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
			if player then
				shootMonstrosLung(player, owner, weapon, data.rnsNepNCharge, fireDir, true)
			end
			mult = 7
		elseif data.rnsHasWeaponMod[WeaponModifier.BRIMSTONE] then
			if weapon:GetCharge() >= maxFireDelay*2 then
				mult = 7
			else
				mult = 4
			end
		elseif data.rnsHasWeaponMod[WeaponModifier.C_SECTION] then
			if weapon:GetCharge() >= maxFireDelay*2 then
				mult = 5
			else
				mult = 4
			end
		end
		if mult then
			local mult2 = 1.5 - math.max(math.min(maxFireDelay/20, 1.2), 0)
			data.rnsNepCharge = data.rnsNepCharge - mult*(math.max(maxFireDelay,0)+1)^((mult2*data.rnsNepNCharge)^nepPower)
		end
	elseif weaponType == WeaponType.WEAPON_BRIMSTONE then
		local maxFireDelay = weapon:GetMaxFireDelay()
		-- Normal Brim only
		if not (data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE]
		or data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 1)
		then
			data.rnsNepCharge = data.rnsNepCharge - 1.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			data.rnsState = 3
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, mod.postTriggerWeaponFired)



function mod:RenderChargeBar(entity)	-- original from Samael by Ghostbroster Connor, a little tweaked by me
	if not Options.ChargeBars then return end
	local data = entity:GetData()
	if not data.rnsDataSet then return end
	if not data.rnsDisplayedCharge then return end
	
	if not data.rnsNepChargebar then
		data.rnsNepChargebar = Sprite()
		data.rnsNepChargebar:Load("gfx/chargebar_neptunus.anm2", true)
		data.rnsNepChargebar.Offset = Vector(-12, -35)
		data.rnsNepChargebar.PlaybackSpeed = 0.5
		data.rnsNepChargebar:Play("Disappear", true)
		data.rnsNepChargebar:SetLastFrame()
	end
	
	local sprite = data.rnsNepChargebar
	local cbAnim = sprite:GetAnimation()
	if data.rnsDisplayedCharge >= 100 then
		if cbAnim == "StartCharged" and sprite:IsFinished("StartCharged") then
			sprite:Play("Charged", true)
		elseif cbAnim == "Charging" or cbAnim == "Disappear" then
			sprite:Play("StartCharged", true)
		end
	elseif data.rnsDisplayedCharge >= 5 then
		sprite:SetFrame("Charging", data.rnsDisplayedCharge)
	elseif cbAnim ~= "Disappear" then
		sprite:Play("Disappear", true)
	end
	
	local renderMode = Game():GetRoom():GetRenderMode()
	if renderMode == RenderMode.RENDER_NORMAL or renderMode == RenderMode.RENDER_WATER_ABOVE then
		sprite:Render(Isaac.WorldToScreen(entity.Position) - Game().ScreenShakeOffset)
		if not Game():IsPaused() then
			sprite:Update()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.RenderChargeBar)
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, mod.RenderChargeBar, FamiliarVariant.INCUBUS)
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, mod.RenderChargeBar, FamiliarVariant.UMBILICAL_BABY)

-- synchronize T.Lilith with Umbilical baby
function mod:postFamiliarRemove(entity)
	local data = entity:GetData()
	if not data.rnsIsDaBaby then return end
	local pData = data.rnsIsDaBaby:GetData()
	
	pData.rnsNepCharge = data.rnsTrueNepCharge or data.rnsNepCharge
	--pData.rnsPrevNCharge = data.rnsPrevNCharge
	--pData.rnsSavedNCharge = data.rnsSavedNCharge
	--pData.rnsLastFireInput = data.rnsLastFireInput
	--pData.rnsSafeFireInput = data.rnsSafeFireInput
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.postFamiliarRemove, EntityType.ENTITY_FAMILIAR)


--tears
function mod:postFireTear(tear)
	-- MC_POST_FIRE_TEAR isn't called for Ludo
	
	if not mod.config.changeSprites then return end
	local owner = findOwner(tear)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local blueVar = nonBloodTearVars[tear.Variant]
	if blueVar then
		tear:ChangeVariant(blueVar)
	elseif tear.Variant == TearVariant.BALLOON then
		local data = tear:GetData()
		data.rnsBlueHaemo = true
		tear:ChangeVariant(TearVariant.BLUE)
		data.rnsChangedSprite = true
	elseif tear.Variant == TearVariant.BALLOON_BRIMSTONE then
		local data = tear:GetData()
		data.rnsBlueHaemo = true
		data.rnsBlueBrimHaemo = true
		tear:ChangeVariant(TearVariant.BLUE)
		data.rnsChangedSprite = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.postFireTear)

function mod:postTearUpdate(tear)	-- handle Ludo and change some graphics
	local data = tear:GetData()
	
	-- pseudo-knives
	if data.rnsHideTrisag then
		local sprite = tear:GetSprite()
		local angle = tear.Velocity:GetAngleDegrees()
		local file = "gfx/002.011_water_knife_neptunus.anm2"
		if angle > 90 or angle < -90 then
			file = "gfx/002.011_water_knife_neptunus_flipped.anm2"
		end
		if sprite:GetFilename() ~= file then
			changeSprite(tear, file)
		end
		tear.Visible = true
	end
	
	-- blue haemolacria
	if data.rnsBlueHaemo then
		local sprite = tear:GetSprite()
		local file = "gfx/002.000_balloon tear_neptunus.anm2"
		if data.rnsBlueBrimHaemo then
			file = "gfx/002.000_brimstone balloon tear_neptunus.anm2"
		end
		if sprite:GetFilename() ~= file then
			changeSprite(tear, file)
		end
		-- trail
		local vel = 0.333 * tear.Velocity:Rotated(math.random(9,27)*10)
		local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, tear.Position, vel, tear):ToEffect()
		trail.PositionOffset = Vector(0, tear.Height)
		trail.m_Height = tear.Height
		trail.FallingSpeed = -tear.FallingSpeed
		trail.FallingAcceleration = -tear.FallingAcceleration
		trail.Color = tear.Color
		local trailSprite = trail:GetSprite()
		trailSprite:Load("gfx/1000.111_haemo trail_neptunus.anm2", true)
		trailSprite.Scale = tear.SpriteScale * tear.Scale * 0.333
		trailSprite.Offset = tear.SpriteOffset
		trailSprite:Play("Poof")
		if data.rnsBlueBrimHaemo and tear:HasTearFlags(TearFlags.TEAR_HYDROBOUNCE) then
			-- maybe
		end
	end
	
	local owner = findOwner(tear)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	-- other graphics
	if mod.config.changeSprites then
		local blueVar = nonBloodTearVars[tear.Variant]
		if blueVar then
			tear:ChangeVariant(blueVar)
		elseif tear.Variant == TearVariant.SWORD_BEAM then
			if not data.rnsChangedSprite then
				local sprite = tear:GetSprite()
				if mod.config.overwriteUniqueSprites
				or sprite:GetFilename() == "gfx/002.047_sword tear.anm2"
				and sprite:GetLayer(0):GetSpritesheetPath() == "effects/spirit_sword.png"
				then
					changeSprite(tear, "gfx/002.047_sword tear_neptunus.anm2")
				end
				data.rnsChangedSprite = true
			end
		elseif tear.Variant == TearVariant.TECH_SWORD_BEAM then
			if not data.rnsChangedSprite then
				local sprite = tear:GetSprite()
				if mod.config.overwriteUniqueSprites
				or sprite:GetFilename() == "gfx/002.049_tech sword tear.anm2"
				and sprite:GetLayer(0):GetSpritesheetPath() == "effects/tech_sword.png"
				then
					changeSprite(tear, "gfx/002.049_tech sword tear_neptunus.anm2")
				end
				data.rnsChangedSprite = true
			end
		end
	end
	
	-- Ludo
	if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
		if owner:GetWeapon(1):GetWeaponType() ~= WeaponType.WEAPON_LUDOVICO_TECHNIQUE then return end
		-- I don't fucking know why this shit works like this, ask Edmund on his trash farm
		-- Repentogon makes it even worse
		-- Lung
		if oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
			if not data.SizeMult then
				data.SizeMult = 1
			end
			if not data.rnsScaleSet then
				tear.Scale = tear.Scale * (1 + 1*oData.rnsNepNCharge)^(0.2)	-- shit #1 (Repentogon boosted) - somehow this is runned multiple times.
										-- In vanilla only runs twice. Not like it should run even TWICE but, hey, at least it isn't around 5 times.
				data.rnsScaleSet = true
			else
				tear.Scale = tear.Scale * (1 + 1*oData.rnsNepNCharge) / (1 + 1*oData.rnsPrevNCharge)
			end
		-- Normal
		else
			if not data.SizeMult then
				if owner.Type == EntityType.ENTITY_PLAYER then
					data.SizeMult = 1
				else	-- shit #2 - familiar's ludo tears need 4/3 mult to remain SAME size. But in case, tear was spawned when you had Lung this isn't needed!
					data.SizeMult = 4/3
				end
			end
			if not data.rnsScaleSet then
				tear.Scale = tear.Scale * (1.5 + oData.rnsNepNCharge)^(0.5)	-- shit #3 (Repentogon special) - this is runned twice. IDK how
				data.rnsScaleSet = true
			else
				tear.Scale = tear.Scale * data.SizeMult * (1.5 + oData.rnsNepNCharge) / (1.5 + oData.rnsPrevNCharge)
			end
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_UPDATE, CallbackPriority.LATE, mod.postTearUpdate)



--lasers
function mod:postFireBrim(laser)	-- Brim
	-- MC_POST_FIRE_BRIMSTONE isn't called for Ludo as well
	local owner = findOwner(laser)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local data = laser:GetData()
	local weapon = owner:GetWeapon(1)
	
	if weapon:GetWeaponType() == WeaponType.WEAPON_BRIMSTONE then
		--autoshoot
		if oData.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or weapon:GetMaxFireDelay() <= 1 then
			data.rnsUpdateData = {OwnerData = oData, IsSoyBrim = true, FirstUpdate = true}
		--normal
		elseif oData.rnsState == 3 then
			laser:SetTimeout(math.floor(laser.Timeout*(1+4*oData.rnsNepNCharge) + 0.5))
		end
	end
	if mod.config.changeSprites then
		changeSprite(laser)
		--runs before impact is spawned
		data.rnsChangedSprite = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, mod.postFireBrim)


function mod:postFireTech(laser)	-- Tech
	-- bug?	MC_POST_FIRE_TECH_LASER isn't called if fired by familiar that copies player (incubus, e.t.c) (MC_POST_FIRE_BRIMSTONE is called for them)
	-- MC_POST_FIRE_TECH_LASER isn't called for Ludo
	-- is called for Technology 2
	local owner = findOwner(laser)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local player = owner:ToPlayer()
	if not player then
		local fam = owner:ToFamiliar()
		if fam then
			player = fam.Player
		end
	end
	if player then
		local dir = Vector(1,0):Rotated(laser.StartAngleDegrees)
		--idk why, but :GetLaserOffset(LaserOffset.LASER_TECH2_OFFSET, dir) generates wrong offset for right direction, unless you hold technology 2
		if laser.StartAngleDegrees > -45 and laser.StartAngleDegrees < 45
		and not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)
		then
			if player:GetLaserOffset(LaserOffset.LASER_TECH5_OFFSET, dir).X == laser.ParentOffset.X
			then return end
		else
			if player:GetLaserOffset(LaserOffset.LASER_TECH2_OFFSET, dir).X == laser.ParentOffset.X
			or player:GetLaserOffset(LaserOffset.LASER_TECH5_OFFSET, dir).X == laser.ParentOffset.X
			then return end
		end
	end
	
	local data = laser:GetData()
	local weapon = owner:GetWeapon(1)
	if weapon:GetWeaponType() == WeaponType.WEAPON_LASER then
		--charged
		if oData.rnsHasWeaponMod[WeaponModifier.CURSED_EYE] then
			data.rnsUpdateData = {Charge = oData.rnsSavedNCharge, IsCursedTech = true}
		end
	end
	if mod.config.changeSprites then
		changeSprite(laser)
		data.rnsChangedSprite = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, mod.postFireTech)


function mod:postFireTechX(laser)	-- Tech X
	local owner = findOwner(laser)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local data = laser:GetData()
	--local weapon = owner:GetWeapon(1)
	--if weapon:GetWeaponType() == WeaponType.WEAPON_TECH_X then
		--
	--end
	if mod.config.changeSprites then
		changeSprite(laser)
		data.rnsChangedSprite = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, mod.postFireTechX)


function mod:postLaserImpactInit(effect)
	-- many useful laser params aren't set at the moment of MC_POST_LASER_INIT
	-- however, at moment of spawning impact (which comes before first render) these are already set
	-- making this callback way better for handling lasers
	
	if not effect.SpawnerEntity then return end
	local laser = effect.SpawnerEntity:ToLaser()
	if not laser then return end
	
	-- pseudo-knives (hide trisag)
	if laser.Variant == LaserVariant.SHOOP
	and laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR
	and laser.MaxDistance > 0
	then
		if laser.Parent
		and laser.Parent:GetData().rnsHideTrisag
		then
			effect.Visible = false
			laser.Visible = false
			return
		end
	end
	
	if laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR
	and laser:GetDisableFollowParent()
	and laser.SpawnerEntity
	and laser.SpawnerEntity:GetData().rnsDataSet
	then
		-- tech-lung
		if laser.Variant == LaserVariant.THIN_RED and laser.MaxDistance > 0 then
			local owner = laser.SpawnerEntity:ToPlayer() or laser.SpawnerEntity:ToFamiliar()
			if owner then
				local weapon = owner:GetWeapon(1)
				local oData = owner:GetData()
				if weapon:GetWeaponType() == WeaponType.WEAPON_LASER and oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
					local lData = laser:GetData()
					local laserGen = lData.rnsTechLungGen or 0
					if math.random(40) + 40*oData.rnsSavedNCharge - 10*laserGen > 50 then
						if laserGen > 0 then
							effect.Visible = false
						end
						local pos = laser.Position + Vector(laser.MaxDistance, 0):Rotated(laser.AngleDegrees)
						local newLaser = EntityLaser.ShootAngle(LaserVariant.THIN_RED, pos, laser.AngleDegrees+math.random(-30,30), laser.Timeout, Vector.Zero, laser.SpawnerEntity)
						newLaser:AddTearFlags(laser.TearFlags)
						newLaser:SetDisableFollowParent(laser:GetDisableFollowParent())
						newLaser:SetHomingType(laser.HomingType)
						newLaser:SetMaxDistance(math.random(30, 100 - 15*laserGen))
						newLaser:SetOneHit(laser:GetOneHit())
						newLaser:SetScale(laser:GetScale())
						newLaser:SetShrink(laser:GetShrink())
						newLaser.CollisionDamage = laser.CollisionDamage
						newLaser.Color = laser.Color
						newLaser.GridHit = laser.GridHit
						local nlData = newLaser:GetData()
						nlData.rnsTechLungGen = laserGen + 1
						if mod.config.changeSprites then
							changeSprite(newLaser)
							nlData.rnsChangedSprite = true
						end
					end
					if mod.config.changeSprites then
						changeSprite(effect)
						changeSprite(laser)
						lData.rnsChangedSprite = true
					end
					return
				end
			end
		-- handle sprites of lasers from Haemolacria
		elseif laser.Variant == LaserVariant.THICK_RED
		or laser.Variant == LaserVariant.THIN_RED
		or laser.Variant == LaserVariant.BRIM_TECH
		or laser.Variant == LaserVariant.THICKER_RED
		or laser.Variant == LaserVariant.THICKER_BRIM_TECH
		then
			local tear = Isaac.FindInRadius(laser.Position, 0, EntityPartition.TEAR)[1]
			if tear then
				tear = tear:ToTear()
				if tear and tear:GetData().rnsBlueBrimHaemo then
					changeSprite(effect)
					changeSprite(laser)
					laser:GetData().rnsChangedSprite = true
				end
			end
		end
	end
	
	-- general laser sprite change
	if not mod.config.changeSprites then return end
	
	local lData = laser:GetData()
	if lData.rnsChangedSprite then
		changeSprite(effect)
	else
		local shouldChangeSprite = false
		if laser.SpawnerEntity then
			if laser.SpawnerEntity:GetData().rnsChangedSprite then
				shouldChangeSprite = true
			end
		end
		if laser.Parent then
			if laser.Parent:GetData().rnsChangedSprite then
				shouldChangeSprite = true
			end
		end
		if shouldChangeSprite then
			changeSprite(effect)
			changeSprite(laser)
			lData.rnsChangedSprite = true
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, CallbackPriority.LATE, mod.postLaserImpactInit, EffectVariant.LASER_IMPACT)


function mod:postLaserInit(laser)	-- for ludo only
	if laser.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO then
		local owner = findOwner(laser)
		if not owner then return end
		
		local oData = owner:GetData()
		if not oData.rnsDataSet then return end
		if not oData.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then return end
		
		local data = laser:GetData()
		data.rnsUpdateData = {OwnerData = oData, IsLudo = true, FirstUpdate = true}
		
		if mod.config.changeSprites then
			changeSprite(laser)
			data.rnsChangedSprite = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.postLaserInit)


function mod:postLaserUpdate(laser)
	local data = laser:GetData()
	if not data.rnsUpdateData then return end
	
	if data.rnsUpdateData.IsLudo then
		local oData = data.rnsUpdateData.OwnerData
		if not oData then return end
		if oData.rnsState ~= 3 then return end	-- shows that WEAPON_FIRE was called, player is not in anim
		
		if laser.Variant == LaserVariant.THIN_RED then	-- tech ludo
			if data.rnsUpdateData.FirstUpdate then
				laser.Size = laser.Size * (1+oData.rnsNepNCharge)
				laser.SpriteScale = laser.SpriteScale * (1+oData.rnsNepNCharge)
			else
				laser.Size = laser.Size * (1+oData.rnsNepNCharge) / (1+oData.rnsPrevNCharge)
				laser.SpriteScale = laser.SpriteScale * (1+oData.rnsNepNCharge) / (1+oData.rnsPrevNCharge)
			end
		else	-- BRIM ludo recalculates size every update, no need to divide
			laser.Size = laser.Size * (1+0.5*oData.rnsNepNCharge)
			laser.SpriteScale = laser.SpriteScale * (1+0.5*oData.rnsNepNCharge)
		end
		data.rnsUpdateData.FirstUpdate = false
		oData.rnsState = 0
	
	elseif data.rnsUpdateData.IsSoyBrim then
		local oData = data.rnsUpdateData.OwnerData
		if not oData then return end
		if data.rnsUpdateData.FirstUpdate then
			laser.CollisionDamage = laser.CollisionDamage * (1+0.25*oData.rnsNepNCharge)
			laser.Size = laser.Size * (1+oData.rnsNepNCharge)
			laser.SpriteScale = laser.SpriteScale * (1+oData.rnsNepNCharge)
			data.rnsUpdateData.FirstUpdate = false
		elseif not oData.rnsWasShooting then	-- abandon
			data.rnsUpdateData = nil
		else
			laser.CollisionDamage = laser.CollisionDamage * (1+0.75*oData.rnsNepNCharge) / (1+0.75*oData.rnsPrevNCharge)
			laser.Size = laser.Size * (1+oData.rnsNepNCharge) / (1+oData.rnsPrevNCharge)
			laser.SpriteScale = laser.SpriteScale * (1+oData.rnsNepNCharge) / (1+oData.rnsPrevNCharge)
		end
	
	elseif data.rnsUpdateData.IsCursedTech then
		laser.Size = laser.Size * (1+data.rnsUpdateData.Charge)
		laser.SpriteScale = laser.SpriteScale * (1+data.rnsUpdateData.Charge)
		data.rnsUpdateData = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.postLaserUpdate)


function mod:postLaserEffectInit(effect)
	if not mod.config.changeSprites then return end
	
	local owner = findOwner(effect)
	if not (owner and ownerGetData().rnsDataSet) then return end
	
	changeSprite(effect)
	effect:GetData().rnsChangedSprite = true
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, CallbackPriority.LATE, mod.postLaserEffectInit, EffectVariant.BRIMSTONE_SWIRL)
mod:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, CallbackPriority.LATE, mod.postLaserEffectInit, EffectVariant.TECH_DOT)


function mod:preRenderEffectLighting(entity)
	if not mod.config.changeSprites then return end
	
	if entity.Variant == EffectVariant.LASER_IMPACT
	or entity.Variant == EffectVariant.BRIMSTONE_SWIRL
	or entity.Variant == EffectVariant.TECH_DOT
	or entity.Variant == EffectVariant.BRIMSTONE_BALL
	then
		if entity:GetData().rnsChangedSprite
		or entity.SpawnerEntity and entity.SpawnerEntity:GetData().rnsChangedSprite
		then
			return false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_RENDER_ENTITY_LIGHTING, mod.preRenderEffectLighting, EntityType.ENTITY_EFFECT)	-- optional arg fixed


function mod:postFireBrimBall(effect)
	local owner = findOwner(effect)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local data = effect:GetData()
	
	effect.Size = effect.Size * (1+0.5*oData.rnsNepNCharge)
	effect.SpriteScale = effect.SpriteScale * (1+0.5*oData.rnsNepNCharge)
	effect.Velocity = effect.Velocity * (1+0.5*oData.rnsNepNCharge)
	effect:SetTimeout(math.ceil(effect.Timeout * (1 + 2*oData.rnsNepNCharge)))
	oData.rnsState = 2
	
	if mod.config.changeSprites then
		changeSprite(effect)
		data.rnsChangedSprite = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, mod.postFireBrimBall)



-- Where are the knives.
function mod:postKnifeUpdate(knife)
	local owner = findOwner(knife)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local data = knife:GetData()
	local weapon = owner:GetWeapon(1)
	local player = owner:ToPlayer() or owner.Player
	local sprite = knife:GetSprite()
	local anim = sprite:GetAnimation()
	local frame = sprite:GetFrame()
	
	-- Knife
	if knife.Variant == KnifeVariant.MOMS_KNIFE
	or knife.Variant == KnifeVariant.SUMPTORIUM
	then
		if weapon:GetWeaponType() ~= WeaponType.WEAPON_KNIFE then return end
		if knife.SubType == KnifeSubType.PROJECTILE then return end
		-- Ludo
		if oData.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			-- additional knives
			if knife.Parent.Type == EntityType.ENTITY_KNIFE then
				local pData = knife.Parent:GetData()
				if pData.rnsWhirlKnives then
					pData.rnsWhirlKnives[knife.Index] = {Position = knife.Position, Ptr = knife}
				end
			-- main knife
			else
				if not data.rnsWhirlpool then
					data.rnsWhirlpool = Sprite()
					data.rnsWhirlpool:Load("gfx/1000.142_whirlpool_neptunus.anm2", true)
					data.rnsWhirlpool:SetFrame("Start", 0)
				end
				if not data.rnsWhirlKnives then
					data.rnsWhirlKnives = {[knife.Index] = {Position = knife.Position, Ptr = knife}}
				else
					data.rnsWhirlKnives[knife.Index] = {Position = knife.Position, Ptr = knife}
				end
				for i, wpKnife in pairs(data.rnsWhirlKnives) do
					if not wpKnife.Ptr:Exists()
					or wpKnife.Ptr.Index ~= i then
						data.rnsWhirlKnives[i] = nil
					end
				end
				if player then
					data.rnsWhirlpool.Color = player:GetTearHitParams(WeaponType.WEAPON_TEARS).TearColor
				end
				local wpAnim = data.rnsWhirlpool:GetAnimation()
				local wpFrame = data.rnsWhirlpool:GetFrame()
				
				if oData.rnsNepNCharge < 0.2 then
					if wpAnim == "End" then
						if wpFrame ~= 17 then
							data.rnsWhirlpool:SetFrame(wpFrame+1)
						end
					elseif wpAnim == "Start" then
						data.rnsWhirlpool:SetFrame("End", math.max(12-wpFrame, 0))
					else
						data.rnsWhirlpool:SetFrame("End", 0)
					end
				else
					local pos = Vector.Zero
					local numKnives = 0
					for _, wpKnife in pairs(data.rnsWhirlKnives) do
						pos = pos + wpKnife.Position
						numKnives = numKnives + 1
					end
					numKnives = math.max(numKnives, 1)
					pos = pos / numKnives
					local kNumMult = (0.9 + 0.1*numKnives)
					Game():UpdateStrangeAttractor(pos, 7*kNumMult*oData.rnsNepNCharge, 150*kNumMult*oData.rnsNepNCharge)
					data.rnsWhirlpool.Scale = sprite.Scale * kNumMult * oData.rnsNepNCharge^0.5
					if wpAnim == "End" then
						data.rnsWhirlpool:SetFrame("Start", math.max(13-wpFrame, 0))
					elseif wpAnim == "Start" then
						if wpFrame == 17 then
							data.rnsWhirlpool:SetFrame("Loop", 0)
						else
							data.rnsWhirlpool:SetFrame(wpFrame+1)
						end
					else
						if wpFrame == 7 then
							data.rnsWhirlpool:SetFrame(0)
						else
							data.rnsWhirlpool:SetFrame(wpFrame+1)
						end
					end
				end
			end
		-- normal Mom's Knife
		else
			local numTears = math.floor(3*oData.rnsNepNCharge+0.3)
			if not data.rnsNumTearsFired then
				data.rnsNumTearsFired = 0
			end
			if knife:GetKnifeDistance() > (knife.MaxDistance - 2)*(data.rnsNumTearsFired+1)/(math.max(numTears,0.01)) and player then
				local rot = knife.Rotation + knife.RotationOffset
				local pos = owner.Position + Vector(30, 0):Rotated(rot)
				local vel = Vector(13*player.ShotSpeed*(2 + knife.Charge)/3,0):Rotated(rot)
				local tear = player:FireTear(pos, vel, false, true, false, owner, knife.CollisionDamage/player.Damage)
				tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING | TearFlags.TEAR_LASERSHOT)
				tear:ChangeVariant(TearVariant.CUPID_BLUE)
				tear.Height = tear.Height * (1.5 + 2.5*knife.Charge) / 4
				tear.FallingSpeed = 1.8 - 1*knife.Charge
				tear.FallingAcceleration = 0
				tear.Scale = 1
				if rot > 90 or rot < -90 then
					changeSprite(tear, "gfx/002.011_water_knife_neptunus_flipped.anm2")
				else
					changeSprite(tear, "gfx/002.011_water_knife_neptunus.anm2")
				end
				tear.Visible = true
				tear:GetData().rnsHideTrisag = true
				data.rnsNumTearsFired = data.rnsNumTearsFired + 1
				if data.rnsNumTearsFired == numTears then
					oData.rnsState = 2
				end
			end
			if not knife:IsFlying() then
				data.rnsNumTearsFired = 0
				if oData.rnsState ~= 0 and not oData.rnsWasShooting then
					oData.rnsState = 0
				end
			end
		end
	
	-- Bones
	elseif knife.Variant == KnifeVariant.BONE_CLUB
	or knife.Variant == KnifeVariant.BONE_SCYTHE
	or knife.Variant == KnifeVariant.DONKEY_JAWBONE
	then
		if weapon:GetWeaponType() ~= WeaponType.WEAPON_BONE then return end
		-- bone throw / shoot
		if knife:IsFlying() then
			if knife:GetKnifeDistance() > knife.MaxDistance-2 then
				local nepCharge = oData.rnsNepNCharge
				if oData.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or weapon:GetMaxFireDelay() <= 0 then
					nepCharge = 1
				end
				if nepCharge >= 0.05 and player then
					local dmgMult = 0.15 + 3.35*nepCharge
					local tear = player:FireTear(knife.Position, Vector.Zero, false, true, false, owner, dmgMult)
					tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING | TearFlags.TEAR_KNOCKBACK)
					tear:ClearTearFlags(TearFlags.TEAR_HOMING | TearFlags.TEAR_SPLIT | TearFlags.TEAR_GROW | TearFlags.TEAR_BOOMERANG
										| TearFlags.TEAR_PERSISTENT | TearFlags.TEAR_EXPLOSIVE | TearFlags.TEAR_ORBIT | TearFlags.TEAR_QUADSPLIT
										| TearFlags.TEAR_BOUNCE | TearFlags.TEAR_SHRINK | TearFlags.TEAR_PULSE | TearFlags.TEAR_FLAT
										| TearFlags.TEAR_GLOW | TearFlags.TEAR_SHIELDED | TearFlags.TEAR_BOOGER | TearFlags.TEAR_EGG
										| TearFlags.TEAR_BONE | TearFlags.TEAR_BELIAL | TearFlags.TEAR_LASER | TearFlags.TEAR_ABSORB
										| TearFlags.TEAR_LASERSHOT | TearFlags.TEAR_HYDROBOUNCE | TearFlags.TEAR_BURSTSPLIT | TearFlags.TEAR_OCCULT | TearFlags.TEAR_TURN_HORIZONTAL)
					tear.Scale = 3 + 9*nepCharge
					tear.Height = -2000
					tear.FallingSpeed = 400
					tear.FallingAcceleration = 0
					tear.Visible = false
					
					local splash = Isaac.Spawn(1000, 132, 0, knife.Position, Vector.Zero, knife)
					splash.SpriteScale = splash.SpriteScale * (0.3+nepCharge) * getFamiliarDMGMult(owner)
					changeSprite(splash)
					splash.Color = tear.Color
					sfx:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION, 0.3+nepCharge, 0, false, 2.2-1.3*nepCharge, 0)
				end
				oData.rnsState = 4
			end
		elseif anim:sub(1, 5) == "Swing" then
			-- bone slash
			if knife.SubType == KnifeSubType.CLUB_HITBOX then
				-- fire tear
				if frame == 3 then
					local isParentTear = false
					if knife.Parent then
						isParentTear = knife.Parent.Type == EntityType.ENTITY_TEAR
					end
					
					if player and not oData.rnsHasWeaponMod[WeaponModifier.BRIMSTONE]
					and not oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG]	then
						if oData.rnsNepNCharge >= 0.2 or isParentTear then
							local shotspeedMult = knife.Variant == KnifeVariant.BONE_SCYTHE and 18 or 13
							local vel = Vector(shotspeedMult*player.ShotSpeed, 0):Rotated(knife.SpriteRotation+90)
							vel = vel + player:GetTearMovementInheritance(vel)
							local dmgMult = 1
							if not isParentTear then
								dmgMult = 0.3 + 2.2*oData.rnsNepNCharge^1.3
								if oData.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK] then
									dmgMult = dmgMult * (1 + (knife.SpriteScale:LengthSquared()/2)^0.5)
								end
							end
							local tear = player:FireTear(knife.Position, vel, true, false, true, owner, dmgMult)
							tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_KNOCKBACK)
							tear:ChangeVariant(TearVariant.PUPULA)
							tear.FallingSpeed = 1.3
							tear.FallingAcceleration = 0
							tear.Scale = tear.Scale*0.15*knife.Size
						end
					end
					
					-- lower charge, in case attack is autoreleased
					local nullDelay, hasEpicFetus = false, false
					if player then 
						nullDelay = player.MaxFireDelay <= 0
						hasEpicFetus = player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
					end
					
					if not isParentTear		--due to C Section
					and not (oData.rnsHasWeaponMod[WeaponModifier.BRIMSTONE]
					or oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG]
					or hasEpicFetus)
					and (oData.rnsHasWeaponMod[WeaponModifier.C_SECTION]
					or oData.rnsHasWeaponMod[WeaponModifier.SOY_MILK]
					or oData.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
					or oData.rnsHasWeaponMod[WeaponModifier.CURSED_EYE]
					or nullDelay)
					then
						oData.rnsState = 2
					end
				end
				-- idle 2 (swing end), in case it IS charged swing
				if oData.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
				or oData.rnsHasWeaponMod[WeaponModifier.CURSED_EYE]
				or oData.rnsHasWeaponMod[WeaponModifier.BRIMSTONE]
				or oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG]
				then
					-- this utilises load/update order, as slashes from Cursed Eye, that started earlier,
					-- will get their input undone by later ones
					if sprite:IsFinished() then
						oData.rnsState = 0
					elseif oData.rnsState == 0 then
						oData.rnsState = 1
					end
				end
			-- bone club
			elseif knife.SubType == 0 then
				-- idle 2 (swing end), in case it's NOT charged swing
				if sprite:IsFinished() then
					data.rnsSwingEnded = true
					if oData.rnsState == 1
					and not (oData.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
					or oData.rnsHasWeaponMod[WeaponModifier.CURSED_EYE]
					or oData.rnsHasWeaponMod[WeaponModifier.BRIMSTONE]
					or oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG])
					then
						if player and player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
							oData.rnsState = 3
						elseif weapon:GetCharge() <= 0 and not oData.rnsWasShooting then
							if oData.rnsHasWeaponMod[WeaponModifier.C_SECTION] then
								oData.rnsState = 0
							elseif findTarget(owner) == nil then
								oData.rnsState = 3
							end
						end
					end
				-- lower charge, if swing anim was cut short because of new attack
				elseif anim ~= data.rnsSwingAnim
				and weapon:GetFireDelay() == weapon:GetMaxFireDelay()
				and not data.rnsSwingEnded
				then
					oData.rnsState = 2
				end
				data.rnsSwingAnim = anim
			end
		-- idle
		elseif anim == "Idle" then
			if knife.SubType == 0 then
				data.rnsSwingAnim = "Swing2"
				data.rnsSwingEnded = true
				if oData.rnsState == 1 and weapon:GetCharge() <= 0 and not oData.rnsWasShooting then
					oData.rnsState = 0
				end
			end
		end
	
	-- Swords
	elseif knife.Variant == KnifeVariant.SPIRIT_SWORD
	or knife.Variant == KnifeVariant.TECH_SWORD then
		if weapon:GetWeaponType() ~= WeaponType.WEAPON_SPIRIT_SWORD then return end
		
		if knife:GetIsSwinging() and not knife:GetIsSpinAttack() then
			if oData.rnsNepCharge >= 3*weapon:GetMaxFireDelay() then
				sprite:Play("Spin"..anim:sub(7), true)
				sfx:Play(SoundEffect.SOUND_SWORD_SPIN)
				--shoot tear
				if player and knife.SubType == 0 then
					local vel = Vector(10*player.ShotSpeed,0):Rotated(knife.Rotation)
					vel = vel + player:GetTearMovementInheritance(vel)
					local tear = player:FireTear(knife.Position, vel, false, false, true, owner, 1)
					if knife.Variant == KnifeVariant.TECH_SWORD then
						tear:ChangeVariant(TearVariant.TECH_SWORD_BEAM)
					else
						tear:ChangeVariant(TearVariant.SWORD_BEAM)
						if AnimatedSpiritSwords then
							AnimatedSpiritSwords.BeamReplace(_, tear)
						end
					end
				end
				knife:SetIsSpinAttack(true)
			end
			if oData.rnsState == 0 then
				oData.rnsState = 3
			end
		end
		
		if mod.config.changeSprites then
			if not data.rnsChangedSprite then
				local file = "gfx/008.010_spirit sword.anm2"
				local newFile = "gfx/008.010_spirit sword_neptunus.anm2"
				local spritesheet = "gfx/effects/spirit_sword.png"
				if knife.Variant == KnifeVariant.TECH_SWORD then
					file = "gfx/008.011_tech sword.anm2"
					newFile = "gfx/008.011_tech sword_neptunus.anm2"
					spritesheet = "gfx/effects/tech_sword.png"
				end
				if mod.config.overwriteUniqueSprites
				or string.lower(sprite:GetFilename()) == file and sprite:GetLayer(0):GetSpritesheetPath() == spritesheet
				then
					changeSprite(knife, newFile)
					if knife.SubType == KnifeSubType.CLUB_HITBOX then
						sprite:GetLayer(0):SetVisible(false)
					elseif knife.SubType == 0 then
						sprite:GetLayer(1):SetVisible(false)
						sprite:GetLayer(2):SetVisible(false)
					end
					sprite:LoadGraphics()
				end
				data.rnsChangedSprite = true
			end
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, CallbackPriority.LATE, mod.postKnifeUpdate)


function mod:preKnifeRender(knife, offset)
	local data = knife:GetData()
	if not data.rnsWhirlpool then return end
	
	local pos = Vector.Zero
	if #data.rnsWhirlKnives == 0 then
		pos = knife.Position
	else
		for i, wpKnife in pairs(data.rnsWhirlKnives) do
			pos = pos + wpKnife.Position
		end
		pos = pos / (#data.rnsWhirlKnives)
	end
	data.rnsWhirlpool:Render(Isaac.WorldToScreen(pos) - Game():GetRoom():GetRenderScrollOffset() + offset - Game().ScreenShakeOffset)
end
mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_RENDER, mod.preKnifeRender)


function mod:postKnifeRemove(entity)
	if entity.Variant ~= KnifeVariant.SPIRIT_SWORD and entity.Variant ~= KnifeVariant.TECH_SWORD or entity.SubType ~= 0 then return end
	local data = entity:GetData()
	
	local owner = findOwner(entity)
	if not owner then return end
	
	if owner:GetWeapon(1):GetWeaponType() ~= WeaponType.WEAPON_SPIRIT_SWORD then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	oData.rnsState = 0
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.postKnifeRemove, EntityType.ENTITY_KNIFE)


-- bombs, explosions, water nukes
function mod:postFireBomb(bomb)	-- Dr. Fetus
	local owner = findOwner(bomb)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	if mod.config.waterBombs then
		local data = bomb:GetData()
		data.rnsWaterExplosion = true
		data.rnsPlayer = owner:ToPlayer() or owner.Player
		data.rnsOwner = owner
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, mod.postFireBomb)

function mod:postRocketInit(effect)	-- Epic Fetus
	local owner = findOwner(effect)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local data = effect:GetData()
	data.rnsPlayer = owner:ToPlayer() or owner.Player
	data.rnsOwner = owner
	data.rnsIsSmallRocket = effect.Variant == EffectVariant.SMALL_ROCKET	-- Forgotten's Epic Fetus
	
	if mod.config.waterBombs then
		data.rnsWaterExplosion = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.postRocketInit, EffectVariant.ROCKET)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.postRocketInit, EffectVariant.SMALL_ROCKET)	-- used by Forgotten + Epic Fetus


function mod:postExplosionInit(effect)	-- general handle
	if not effect.SpawnerEntity then return end
	local sData = effect.SpawnerEntity:GetData()
	if not sData.rnsOwner then return end
	
	local oData = sData.rnsOwner:GetData()
	local NepNormalizedCharge = oData.rnsNepNCharge
	
	if sData.rnsIsSmallRocket ~= nil	-- if Epic Fetus
	and sData.rnsPlayer and oData.rnsNepNCharge then
		oData.rnsState = 3
		if oData.rnsNepNCharge >= 0.05 then
			local dmgMult = 0.66
			local tearsAmount = math.floor((2000 * oData.rnsNepNCharge^2.5 / math.max(sData.rnsPlayer.MaxFireDelay,1)^0.5) ^ 0.5 + 0.5)
			if sData.IsSoyMilkTarget then	-- correction for Epic Fetus Synergies by JamesB456
				tearsAmount = math.floor(tearsAmount/3 + 0.5)
				dmgMult = dmgMult * 2
			end
			for i=1, tearsAmount do
				local tear = sData.rnsPlayer:FireTear(effect.Position, RandomVector()*(math.random(0,35)/10), false, true, false, sData.rnsPlayer, dmgMult)
				tear.Height = -20
				tear.FallingSpeed = math.random(-65, -50)
				tear.FallingAcceleration = 2.5 + math.random(-5, 8)/10
				tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
				tear:ClearTearFlags(TearFlags.TEAR_BURSTSPLIT)
			end
		end
	end
	
	if sData.rnsWaterExplosion then	-- not directly so only Epic Fetus explosions are affected
		changeSprite(effect, "gfx/1000.001b_water explosion.anm2")
		if sData.rnsPlayer then
			effect.Color = sData.rnsPlayer:GetTearHitParams(WeaponType.WEAPON_TEARS).TearColor
			--spawn creep
			local creep = sData.rnsPlayer:SpawnAquariusCreep()
			creep.Position = effect.Position
			if sData.rnsIsSmallRocket ~= nil	-- Epic Fetus
			and oData.rnsNepNCharge
			then
				creep.Size = creep.Size * 2 * oData.rnsNepNCharge
				creep.SpriteScale = creep.SpriteScale * 2 * oData.rnsNepNCharge
				creep.CollisionDamage = creep.CollisionDamage * 0.33 * oData.rnsNepNCharge * getFamiliarDMGMult(sData.rnsOwner)
			else	-- Dr. Fetus 
				creep.CollisionDamage = creep.CollisionDamage*0.1*getFamiliarDMGMult(sData.rnsOwner)
			end
			creep:Update()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.postExplosionInit, EffectVariant.BOMB_EXPLOSION)


function mod:postCraterInit(effect)	-- maybe will try to not let craters spawn
	if not effect.SpawnerEntity then return end
	local sData = effect.SpawnerEntity:GetData()
	if not sData.rnsWaterExplosion then return end
	-- morph somehow idk
end
--mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.postExplosionInit, EffectVariant.BOMB_CRATER)