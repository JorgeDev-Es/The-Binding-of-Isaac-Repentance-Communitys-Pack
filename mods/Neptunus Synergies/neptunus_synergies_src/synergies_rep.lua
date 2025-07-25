local mod = RoarysNeptunusSynergies
local sfx = SFXManager()

local nepPower = 0.442329615175	-- weird power for Neptunus charge decrease

local function changeSprite(entity, file)
	local sprite = entity:GetSprite()
	local anim = sprite:GetAnimation()
	file = file or sprite:GetFilename():sub(1, -6).."_neptunus.anm2"
	sprite:Load(file, true)
	sprite:Play(anim, true)
end

local WeaponModifier = {
	CHOCOLATE_MILK = 1 << 0,
	CURSED_EYE = 1 << 1,
	BRIMSTONE = 1 << 2,
	MONSTROS_LUNG = 1 << 3,
	LUDOVICO_TECHNIQUE = 1 << 4,
	ANTI_GRAVITY = 1 << 5,
	TRACTOR_BEAM = 1 << 6,
	SOY_MILK = 1 << 7,
	ALMOND_MILK = 1 << 7,
	NEPTUNUS = 1 << 8,
	AZAZELS_SNEEZE =  1 << 9,
	C_SECTION = 1 << 10,
	FAMILIAR = 1 << 30,
	BONE = 1 << 31
}

mod.affectedLaserVariants = {
	[LaserVariant.THIN_RED] = true,
	[LaserVariant.THICK_RED] = true,
	[LaserVariant.BRIM_TECH] = true,
	[LaserVariant.THICKER_RED] = true,
	[LaserVariant.THICKER_BRIM_TECH] = true,
	[LaserVariant.GIANT_RED] = true,
	[LaserVariant.GIANT_BRIM_TECH] = true
}
mod.brimVariants = {
	[LaserVariant.THICK_RED] = true,
	[LaserVariant.BRIM_TECH] = true,
	[LaserVariant.THICKER_RED] = true,
	[LaserVariant.THICKER_BRIM_TECH] = true,
	[LaserVariant.GIANT_RED] = true,
	[LaserVariant.GIANT_BRIM_TECH] = true
}

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

mod.swordSubTypeToAnmFile = {
	[10] = {
		[0] = "gfx/008.010.0_spirit sword_neptunus.anm2",
		[4] = "gfx/008.010.4_spirit sword_neptunus.anm2"
	},
	[11] = {
		[0] = "gfx/008.011.0_tech sword_neptunus.anm2",
		[4] = "gfx/008.011.4_tech sword_neptunus.anm2"
	},
}

mod.fetusFrameToAngle = {
	[0] = 90,
	[1] = 112.5,
	[2] = 135,
	[3] = 157.5,
	[4] = 180,
	[5] = 202.5,
	[6] = -123.75,
	[7] = -90,
	[8] = -33.75,
	[9] = -22.5,
	[10] = 0,
	[11] = 22.5,
	[12] = 45,
	[13] = 67.5
}

mod.playerAnimations = {	-- used to determine if player's shoot input is blocked because of anim
	Pickup = true,
	Hit = true,
	Sad = true, 
	Happy = true,
	Jump = true,
	LiftItem = true,
	HideItem = true,
	UseItem = true,
	FallIn = true,
	JumpOut = true,
	PickupWalkDown = true,
	PickupWalkLeft = true,
	PickupWalkUp = true,
	PickupWalkRight = true
}

local function playerInAnim(player)	-- original from Samael by Ghostbroster Connor, a little tweaked by me
	local curAnim = player:GetSprite():GetAnimation()
	if player:IsHoldingItem() then return true end
	if mod.playerAnimations[curAnim] then return true end
	return false
end


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


mod.playerLikeFamiliar = {
	[FamiliarVariant.CAINS_OTHER_EYE] = true,
	[FamiliarVariant.SCISSORS] = true,
	[FamiliarVariant.INCUBUS] = true,	-- only incubus shows his charge
	[FamiliarVariant.FATES_REWARD] = true,
	--[FamiliarVariant.MINISAAC] = true,	-- just for the lols
	[FamiliarVariant.TWISTED_BABY] = true,
	[FamiliarVariant.BLOOD_BABY] = true,	-- blood clots
	[FamiliarVariant.UMBILICAL_BABY] = true,
	[FamiliarVariant.DECAP_ATTACK] = true
}	-- Found Soul is player actually lmfao


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
		if owner.Type == EntityType.ENTITY_FAMILIAR then
			if not mod.playerLikeFamiliar[entity.Variant] then
				return false
			end
		end
		return owner
	end
	return false
end


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
	local randSize = {"0","0","1"}
	if player:GetTearHitParams(7, 1, 1, player).TearScale >= 2 then
		randSize = {"1","1","2"}
	end
	for i=1, BombsAmount do
		local vel = Velocity * (0.666 + math.random(334)/1000)
		vel = vel:Rotated(math.random(-150, 150)/10)
		local bomb = player:FireBomb(Position, vel, Source)
		bomb:SetExplosionCountdown(math.random(21,31))
		bomb.ExplosionDamage = bomb.ExplosionDamage * DamageMultiplier
		bomb.RadiusMultiplier = 0.667
		bomb:Update()
		local sprite = bomb:GetSprite()
		sprite:Load(sprite:GetFilename():sub(1, -7)..randSize[math.random(#randSize)]..".anm2")
		sprite:Play("Pulse")
		bomb:GetData().rnsLungBomb = true
	end
end


local function shootMonstrosLung(player, owner, improvisedWeaponCharge, neptunusCharge, vectorDirection, isBone)
	-- Max tears amount per single burst
	local attack = fireTearBurst
	local dmgMult = 1
	local numWizs = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_THE_WIZ)
	local maxTearsAmount = 1 + 5*player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) + numWizs
	local additionalTears = 0
	local tearsAmount = 0
	
	local pType = player:GetPlayerType()
	if pType == PlayerType.PLAYER_KEEPER then
		additionalTears = 1
	elseif pType == PlayerType.PLAYER_KEEPER_B then
		additionalTears = 2
	end
	
	additionalTears = additionalTears
		+ player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE)
		+ 2*player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
	
	if additionalTears > 0 then
		maxTearsAmount = maxTearsAmount + 1 + additionalTears + math.max(player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)-1, 0)
	else
		maxTearsAmount = maxTearsAmount + additionalTears + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)
	end
	if player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) and math.random(4) == 1 then
		maxTearsAmount = 2 * maxTearsAmount
	end
	
	-- Bomb attack
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) and not isBone then
		attack = fireBombBurst
		local maxFireDelay = player.MaxFireDelay
		if maxFireDelay > 0 then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
				maxFireDelay = maxFireDelay*2.5
			end
			if improvisedWeaponCharge < maxFireDelay then
				tearsAmount = math.floor(maxTearsAmount * (improvisedWeaponCharge/maxFireDelay) + 0.2)
			end
		end
	-- Tear attack
	else
		maxTearsAmount = math.min(math.floor(2.4*maxTearsAmount+0.5), 50)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
			maxTearsAmount = math.floor(maxTearsAmount*4/7+0.5)
		end
		-- Chocolate milk damage mult
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
			local chocCharge = 2 * (improvisedWeaponCharge-1) / math.ceil(player.MaxFireDelay*5/2)
			local part1 = 0
			local part2 = 0
			if chocCharge >= 1 then
				part1 = 1
				part2 = chocCharge - 1
			else
				part1 = chocCharge
			end
			dmgMult = dmgMult * (0.1 + 0.9*part1 + part2)
		else	-- Add extra tears in case normal attack wasn't fully charged
			local maxFireDelay = player.MaxFireDelay
			if maxFireDelay > 0 then
				if isBone then
					maxFireDelay = maxFireDelay * 2
				end
				if improvisedWeaponCharge < maxFireDelay then
					tearsAmount = math.floor(maxTearsAmount * (improvisedWeaponCharge/maxFireDelay) + 0.2)
				end
			end
		end
	end
	
	tearsAmount = tearsAmount + math.floor(maxTearsAmount * (neptunusCharge)+0.2)
	
	-- Main shoot process
	local pureVelocity = vectorDirection*10*player.ShotSpeed
	pureVelocity = pureVelocity + player:GetTearMovementInheritance(pureVelocity)
	
	if numWizs > 0 then
		local multiEyeAngle = 45
		if numWizs > 1 then
			multiEyeAngle = 55
		end
		for i=0, numWizs do
			local vel = pureVelocity:Rotated(multiEyeAngle * (2*i/numWizs - 1))
			attack(player, owner.Position, vel, tearsAmount, owner, dmgMult)
		end
	else
		attack(player, owner.Position, pureVelocity, tearsAmount, owner, dmgMult)
	end
	
	if not isBone then
		-- Additional shoot processes: Loki Horns, Mom's Eye, Eye Sore
		local fireLoki = false
		local fireMomsEye = false
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE) then
			if math.random(100) + 10*player.Luck > 50 then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) then
					fireLoki = true
				else
					fireMomsEye = true
				end
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) then
			if math.random(100) + 5*player.Luck > 75 then
				fireLoki = true
			end
		end
		
		if fireLoki then
			attack(player, owner.Position, pureVelocity:Rotated(-90), tearsAmount, owner, dmgMult)
			attack(player, owner.Position, pureVelocity:Rotated(90), tearsAmount, owner, dmgMult)
			attack(player, owner.Position, pureVelocity:Rotated(180), tearsAmount, owner, dmgMult)
		elseif fireMomsEye then
			attack(player, owner.Position, pureVelocity:Rotated(180), tearsAmount, owner, dmgMult)
		end
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE) then
			for i=1, math.random(0, 3) do
				attack(player, owner.Position, pureVelocity:Rotated(math.random(0, 359)), tearsAmount, owner, dmgMult)
			end
		end
	end
end






function mod:evaluateCache(player)
	if mod.config.changeSprites then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then
			player.LaserColor = player:GetTearHitParams(WeaponType.WEAPON_TEARS).TearColor
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, mod.evaluateCache, CacheFlag.CACHE_TEARCOLOR)


function mod:postPEffectUpdate(player)
	local data = player:GetData()
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then
		data.rnsDataSet = nil
		return
	end
	
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
			rnsSavedNCharge = data.rnsSavedNCharge,
			rnsPrevCharge = data.rnsPrevCharge,
			rnsPrevNCharge = data.rnsPrevNCharge,
			rnsState = data.rnsState,
			rnsShortenedDelay = data.rnsShortenedDelay,
			rnsLastFireInput = data.rnsLastFireInput,
			rnsSafeFireInput = data.rnsSafeFireInput,
			rnsFireDur = data.rnsFireDur,
			rnsWasShooting = data.rnsWasShooting,
			rnsSavedWeapon = data.rnsSavedWeapon
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
	
	local weaponType = -1
	for i=1, WeaponType.NUM_WEAPON_TYPES-1 do
		if player:HasWeaponType(i) then
			weaponType = i
			break
		end
	end
	
	if not data.rnsDataSet then 
		data.rnsNepCharge = 0
		data.rnsNepNCharge = 0
		data.rnsDisplayedCharge = 0
		data.rnsPrevNCharge = 0	-- for Ludo and Lasers
		data.rnsSavedNCharge = 0
		data.rnsShortenedDelay = 0	-- for Technology and Dr. Fetus, equals to decreased FireDelay; used to check whether delay was already shortened
		data.rnsState = 0	-- for charged attacks
			-- states work differently, depeding on weapon, but generally:
			-- state = 0 -> (Charging Neptunus): charge Neptunus;
			-- state = 1 -> (Charging charged attack): Do NOTHING - charge stopped and no reset;
			-- state = 2 -> (Charged attack cancelled): if no input then reset charge and return to state 0;
			-- state = 3 -> (Charged attack fired): charge reset, which is needed on frame after attack, so all entities gain bonus.
		data.rnsLastFireInput = Vector.Zero
		data.rnsSafeFireInput = Vector.Zero	-- Last non-zero fire input
		data.rnsFireDur = 0
		data.rnsWasShooting = false
		data.rnsSavedWeapon = weaponType
		data.rnsDataSet = true
	end
	
	if playerInAnim(player) then
		data.rnsPlayerInAnim = true
		return
	end
	data.rnsPlayerInAnim = false
	
	if data.rnsShortenedDelay >= player.MaxFireDelay then
		data.rnsShortenedDelay = player.MaxFireDelay - 1
	end
	
	local isShooting = (player:GetLastActionTriggers() & ActionTriggers.ACTIONTRIGGER_SHOOTING ~= 0)
	local fireDir = player:GetShootingInput()
	local curFireDelay = player.FireDelay
	local maxFireDelay = player.MaxFireDelay
	local maxNepCharge = math.max(11 + 12*maxFireDelay,2)
	
	data.rnsHasWeaponMod = {
		[WeaponModifier.CHOCOLATE_MILK] = player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK),
		[WeaponModifier.CURSED_EYE] = player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE),
		[WeaponModifier.BRIMSTONE] = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE),
		[WeaponModifier.MONSTROS_LUNG] = player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG),
		[WeaponModifier.LUDOVICO_TECHNIQUE] = player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE),
		[WeaponModifier.ANTI_GRAVITY] = player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY),
		[WeaponModifier.TRACTOR_BEAM] =  player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM),
		[WeaponModifier.SOY_MILK] = player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
									or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK),
		[WeaponModifier.NEPTUNUS] = true, -- it won't get here if it was false
		[WeaponModifier.AZAZELS_SNEEZE] = pType == PlayerType.PLAYER_AZAZEL_B,
		[WeaponModifier.C_SECTION] = player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION),
		--[WeaponModifier.FAMILIAR] = weaponModifiers & WeaponModifier.FAMILIAR == WeaponModifier.FAMILIAR,	-- dunno what it is
		[WeaponModifier.BONE] = pType == PlayerType.PLAYER_THEFORGOTTEN or pType == PlayerType.PLAYER_THEFORGOTTEN_B
								or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK)
	}
	
	-- reset upon new weapon, like vanilla (modifiers don't cause charge reset)
	if weaponType ~= data.rnsSavedWeapon then
		data.rnsNepCharge = 0
		data.rnsNepNCharge = 0
		data.rnsState = 0
		data.rnsShortenedDelay = 0
		-- data.rnsWasShooting = false
		data.rnsSavedWeapon = weaponType
	end
	
	data.rnsPrevNCharge = data.rnsNepNCharge
	
	local isReallyAxisAligned = not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
	local doAttacks = player:CanShoot() and pType ~= PlayerType.PLAYER_LILITH_B
	--== The Start of weapon B******t ==--
	-- T.Lilith
	if pType == PlayerType.PLAYER_LILITH_B
	and weaponType ~= WeaponType.WEAPON_NOTCHED_AXE
	and weaponType ~= WeaponType.WEAPON_URN_OF_SOULS
	then
		if player:GetActiveWeaponEntity() then
			local baby = player:GetActiveWeaponEntity():ToFamiliar()
			if baby and not data.rnsBabySynchronized then
				local bData = baby:GetData()
				bData.rnsDataSet = true
				bData.rnsNepCharge = data.rnsNepCharge
				bData.rnsNepNCharge = data.rnsNepNCharge
				bData.rnsPrevNCharge = data.rnsPrevNCharge
				bData.rnsSavedNCharge = 0
				bData.rnsState = 0
				bData.rnsShortenedDelay = 0
				bData.rnsLastFireInput = data.rnsLastFireInput
				bData.rnsSafeFireInput = data.rnsSafeFireInput
				bData.rnsWasShooting = data.rnsWasShooting
				bData.rnsSavedWeapon = weaponType
				
				bData.rnsIsDaBaby = player
				data.rnsBabySynchronized = true
			end
		else
			data.rnsBabySynchronized = false
			data.rnsNepCharge = data.rnsNepCharge + 1.5
		end
	-- C Section
	elseif weaponType == WeaponType.WEAPON_FETUS then
		-- Buffed passively
		data.rnsNepCharge = maxNepCharge*0.4
	
	-- Bone
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
				if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) and not isShooting then
					data.rnsState = 0
				else
					data.rnsState = 1
				end
			-- Swing attack (states 2 & 4)
			else
				-- shoot lung burst
				if doAttacks then
					if data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
						shootMonstrosLung(player, player, data.rnsFireDur, data.rnsNepNCharge, data.rnsSafeFireInput, true)
					end
				end
				-- lower charge
				local mult2 = 1.5 - math.max(math.min(maxFireDelay/20, 1.2), 0)
				local mult = 4
				if data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
					mult = 7
				elseif data.rnsHasWeaponMod[WeaponModifier.BRIMSTONE] then
					if data.rnsFireDur >= maxFireDelay * 2 then
						mult = 7
					end
				elseif data.rnsHasWeaponMod[WeaponModifier.C_SECTION] then
					if data.rnsFireDur >= maxFireDelay * 2 then
						mult = 5
					end
				end
				if data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 0 then
					mult = mult/4
				end
				data.rnsNepCharge = data.rnsNepCharge - mult*(math.max(maxFireDelay,0)+1)^((mult2*data.rnsNepNCharge)^nepPower)
				if data.rnsState == 4 then	-- and not isShooting
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
			data.rnsNepCharge = data.rnsNepCharge + 2
		end
	
	-- Epic Fetus
	elseif weaponType == WeaponType.WEAPON_ROCKETS then
		isReallyAxisAligned = false
		local target = findTarget(player)
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
	
	-- Knife
	elseif weaponType == WeaponType.WEAPON_KNIFE then
		isReallyAxisAligned = false
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 1.5
			end
		else
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
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
				end
				if isShooting then
					data.rnsState = 1
				end
			end
		end
	
	-- Dr. Fetus
	elseif weaponType == WeaponType.WEAPON_BOMBS then
		if isShooting then
			if data.rnsShortenedDelay < player.FireDelay then
				player.FireDelay = player.FireDelay*(1-0.95*(data.rnsNepNCharge^0.5))
				data.rnsShortenedDelay = math.min(player.FireDelay, player.MaxFireDelay-2)
			end
			data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
		else
			data.rnsNepCharge = data.rnsNepCharge + 2
		end
	
	-- Tech X
	elseif weaponType == WeaponType.WEAPON_TECH_X then
		if data.rnsState ~= 1 then
			if data.rnsState == 0 then
				data.rnsNepCharge = data.rnsNepCharge + 1.5
			elseif data.rnsState == 3 then
				data.rnsNepCharge = data.rnsNepCharge - 3*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
				data.rnsState = 0
			end
			if isShooting then
				data.rnsState = 2
			elseif data.rnsState == 2 then
				data.rnsState = 3
			end
		end
	
	-- Brim
	elseif weaponType == WeaponType.WEAPON_BRIMSTONE then
		-- Ludo
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			isReallyAxisAligned = false
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 1.5
			end
		-- Autoshoot (soy-brim)
		elseif data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 1 then
			if isShooting and player:GetActiveWeaponEntity() then
				data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 2
			end
		-- Normal Brim
		else
			if not isShooting then
				if data.rnsState == 3 then
					if player:GetActiveWeaponEntity()
					or (not player:CanShoot() and not isShooting and data.rnsNepNCharge > 0.03)	-- handle for very modded chars, e.g. Samael
					then
						data.rnsNepCharge = data.rnsNepCharge - 0.75*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
					else
						data.rnsState = 0
					end
				elseif data.rnsWasShooting then
					if data.rnsFireDur >= maxFireDelay
					or data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
					then
						--apply boost during frame
						data.rnsState = 3
					else
						data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
					end
				else
					data.rnsNepCharge = data.rnsNepCharge + 2
				end
			end
		end
	
	-- Tech
	elseif weaponType == WeaponType.WEAPON_LASER then
		-- Ludo
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			isReallyAxisAligned = false
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 1.5
			end
			data.rnsState = 3
		-- Tech-Lung
		elseif data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
			if not isShooting then
				if data.rnsWasShooting then
					data.rnsNepCharge = data.rnsNepCharge - 6*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
					data.rnsSavedNCharge = data.rnsNepNCharge
				else
					data.rnsNepCharge = data.rnsNepCharge + 1
				end
			elseif not data.rnsWasShooting then
				data.rnsSavedNCharge = data.rnsNepNCharge
			end
		-- Other chargable Tech
		elseif data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
		or data.rnsHasWeaponMod[WeaponModifier.CURSED_EYE]
		then
			if data.rnsState == 3 then
				data.rnsNepCharge = 0
				data.rnsState = 0
			elseif data.rnsState == 2 then
				data.rnsState = 3
			elseif data.rnsState == 1 then
				if not isShooting then
					data.rnsState = 2
				end
			elseif data.rnsState == 0 then
				if isShooting then
					data.rnsState = 1
				else
					data.rnsNepCharge = data.rnsNepCharge + 2
				end
			end
		-- Normal Tech
		else
			if isShooting then
				if data.rnsShortenedDelay < player.FireDelay then
					player.FireDelay = player.FireDelay*(1-0.95*(data.rnsNepNCharge^0.5))
					data.rnsShortenedDelay = math.min(player.FireDelay, player.MaxFireDelay-2)
				end
				data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 2
			end
		end
	
	-- Ludo
	elseif weaponType == WeaponType.WEAPON_LUDOVICO_TECHNIQUE then
		isReallyAxisAligned = false
		if isShooting then
			data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
		else
			data.rnsNepCharge = data.rnsNepCharge + 1.5
		end
	
	-- Monstro's Lung
	elseif weaponType == WeaponType.WEAPON_MONSTROS_LUNGS then
		if not isShooting then
			if data.rnsWasShooting then
				if doAttacks then
					shootMonstrosLung(player, player, data.rnsFireDur, data.rnsNepNCharge, data.rnsLastFireInput, false)
				end
				data.rnsNepCharge = 0
			else
				data.rnsNepCharge = data.rnsNepCharge + 3
			end
		end
	
	-- Tears
	elseif weaponType == WeaponType.WEAPON_TEARS then
		-- Maybe will try to add Cursed Eye synergy, don't know what to do tho
	end
	--== The End of weapon B******t ==--
	
	
	if isShooting then
		data.rnsFireDur = data.rnsFireDur + 1
	else
		data.rnsFireDur = 0
	end
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
	local tLilithShowCharge = pType ~= PlayerType.PLAYER_LILITH_B
	or not player:GetActiveWeaponEntity()	-- set to false if umbilical baby is out
	or weaponType == WeaponType.WEAPON_NOTCHED_AXE
	or weaponType == WeaponType.WEAPON_URN_OF_SOULS
	
	if weaponType ~= WeaponType.WEAPON_FETUS and tLilithShowCharge and player:CanShoot() then
		data.rnsDisplayedCharge = math.floor(data.rnsNepNCharge*100 + 0.5)
	else
		data.rnsDisplayedCharge = 0
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.postPEffectUpdate)








function mod:familiarUpdate(fam)
	if not mod.playerLikeFamiliar[fam.Variant] then return end
	
	local player = fam.Player
	if not player then return end
	local pData = player:GetData()
	local data = fam:GetData()
	if not pData.rnsDataSet then
		data.rnsDataSet = nil
		return
	end
	
	local maxFireDelay = player.MaxFireDelay
	local weaponType = pData.rnsSavedWeapon
	local fireDir = pData.rnsLastFireInput
	local isShooting = pData.rnsWasShooting
	
	local maxNepCharge = math.max(11 + 12*maxFireDelay,2)
	
	if not data.rnsDataSet then 
		data.rnsNepCharge = 0
		data.rnsNepNCharge = 0
		data.rnsDisplayedCharge = 0
		data.rnsPrevNCharge = 0
		data.rnsSavedNCharge = 0
		data.rnsShortenedDelay = 0
		data.rnsState = 0
		data.rnsLastFireInput = Vector.Zero
		data.rnsSafeFireInput = Vector.Zero
		data.rnsFireDur = 0
		data.rnsWasShooting = false
		data.rnsSavedWeapon = weaponType
		data.rnsDataSet = true
	end
	
	data.rnsHasWeaponMod = pData.rnsHasWeaponMod
	
	if weaponType ~= data.rnsSavedWeapon then
		data.rnsNepCharge = 0
		data.rnsNepNCharge = 0
		data.rnsState = 0
		data.rnsShortenedDelay = 0
		-- data.rnsWasShooting = false
		data.rnsSavedWeapon = weaponType
	end
	
	data.rnsPrevNCharge = data.rnsNepNCharge
	
	--== The Start of weapon B******t ==--
	-- C Section
	if weaponType == WeaponType.WEAPON_FETUS then
		data.rnsNepCharge = maxNepCharge*0.4
	
	-- Bone
	elseif weaponType == WeaponType.WEAPON_BONE then
		if data.rnsState ~= 1 then
			-- Idle
			if data.rnsState == 0 then
				if isShooting and (player.FireDelay == player.MaxFireDelay
				or data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
				or data.rnsHasWeaponMod[WeaponModifier.CURSED_EYE]
				or data.rnsHasWeaponMod[WeaponModifier.BRIMSTONE]
				or data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG])
				then
					data.rnsState = 1
				else
					data.rnsNepCharge = data.rnsNepCharge + 1
				end
			-- Throw attack
			elseif data.rnsState == 3 then
				local mult = 6
				if data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 0 then
					mult = 1.5
				end
				data.rnsNepCharge = data.rnsNepCharge - mult*(math.max(maxFireDelay,0)+1)^((0.5*data.rnsNepNCharge)^nepPower)
				if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) and not isShooting then
					data.rnsState = 0
				else
					data.rnsState = 1
				end
			-- Swing attack (state 2 & 4)
			else
				-- shoot lung burst
				if doAttacks then
					if data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
						shootMonstrosLung(player, player, data.rnsFireDur, data.rnsNepNCharge, data.rnsSafeFireInput, true)
					end
				end
				-- lower charge
				local mult2 = 1.5 - math.max(math.min(maxFireDelay/20, 1.2), 0)
				local mult = 4
				if data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
					mult = 7
				elseif data.rnsHasWeaponMod[WeaponModifier.BRIMSTONE] then
					if data.rnsFireDur >= maxFireDelay * 2 then
						mult = 7
					end
				elseif data.rnsHasWeaponMod[WeaponModifier.C_SECTION] then
					if data.rnsFireDur >= maxFireDelay * 2 then
						mult = 5
					end
				end
				if data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 0 then
					mult = mult/4
				end
				data.rnsNepCharge = data.rnsNepCharge - mult*(math.max(maxFireDelay,0)+1)^((mult2*data.rnsNepNCharge)^nepPower)
				if data.rnsState == 4 then	-- and not isShooting
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
			data.rnsNepCharge = data.rnsNepCharge + 2
		end
	
	-- Epic Fetus
	elseif weaponType == WeaponType.WEAPON_ROCKETS then
		isReallyAxisAligned = false
		local target = findTarget(fam)
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
	
	-- Knife
	elseif weaponType == WeaponType.WEAPON_KNIFE then
		isReallyAxisAligned = false
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 1.5
			end
		else
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
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
				end
				if isShooting then
					data.rnsState = 1
				end
			end
		end
	
	-- Dr. Fetus
	elseif weaponType == WeaponType.WEAPON_BOMBS then
		if isShooting then
			--if data.rnsShortenedDelay < player.FireDelay then
			--	player.FireDelay = player.FireDelay*(1-0.95*(data.rnsNepNCharge^0.5))
			--	data.rnsShortenedDelay = math.min(player.FireDelay, player.MaxFireDelay-2)
			--end
			data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
		else
			data.rnsNepCharge = data.rnsNepCharge + 2
		end
	
	-- Tech X
	elseif weaponType == WeaponType.WEAPON_TECH_X then
		if data.rnsState ~= 1 then
			if data.rnsState == 0 then
				data.rnsNepCharge = data.rnsNepCharge + 1.5
			elseif data.rnsState == 3 then
				data.rnsNepCharge = data.rnsNepCharge - 3*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
				data.rnsState = 0
			end
			if isShooting then
				data.rnsState = 2
			elseif data.rnsState == 2 then
				data.rnsState = 3
			end
		end
	
	-- Brim
	elseif weaponType == WeaponType.WEAPON_BRIMSTONE then
		-- Ludo
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			isReallyAxisAligned = false
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 1.5
			end
		-- Autoshoot (soy-brim)
		elseif data.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or maxFireDelay <= 1 then
			if isShooting and player:GetActiveWeaponEntity() then
				data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 2
			end
		-- Normal Brim
		else
			if not isShooting then
				if data.rnsState == 3 then
					if player:GetActiveWeaponEntity()
					or (not player:CanShoot() and not isShooting and data.rnsNepNCharge > 0.03)	-- handle for very modded chars, e.g. Samael
					then
						data.rnsNepCharge = data.rnsNepCharge - 0.75*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
					else
						data.rnsState = 0
					end
				elseif data.rnsWasShooting then
					if data.rnsFireDur >= maxFireDelay
					or data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
					then
						--apply boost during frame
						data.rnsState = 3
					else
						data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
					end
				else
					data.rnsNepCharge = data.rnsNepCharge + 2
				end
			end
		end
	
	-- Tech
	elseif weaponType == WeaponType.WEAPON_LASER then
		-- Ludo
		if data.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] then
			isReallyAxisAligned = false
			if isShooting then
				data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 1.5
			end
			data.rnsState = 3
		-- Tech-Lung
		elseif data.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
			if not isShooting then
				if data.rnsWasShooting then
					data.rnsNepCharge = data.rnsNepCharge - 6*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
					data.rnsSavedNCharge = data.rnsNepNCharge
				else
					data.rnsNepCharge = data.rnsNepCharge + 1
				end
			elseif not data.rnsWasShooting then
				data.rnsSavedNCharge = data.rnsNepNCharge
			end
		-- Other chargable Tech
		elseif data.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
		or data.rnsHasWeaponMod[WeaponModifier.CURSED_EYE]
		then
			if data.rnsState == 4 then
				data.rnsNepCharge = 0
				data.rnsState = 0
			elseif data.rnsState == 3 then	-- MC_POST_LASER_UPDATE runs after MC_POST_PEFFECT_UPDATE; therefore it's possible to catch created lasers here
				data.rnsState = 4
			elseif data.rnsState == 2 then	-- MC_POST_LASER_INIT runs BEFORE MC_POST_PEFFECT_UPDATE; due to that need to skip a frame in any case
				data.rnsState = 3
			elseif data.rnsState == 1 then
				if not isShooting then	-- not player:GetActiveWeaponEntity() trick from brim doesn't work with tech
					data.rnsState = 2
				end
			elseif data.rnsState == 0 then
				if isShooting then
					data.rnsState = 1
				else
					data.rnsNepCharge = data.rnsNepCharge + 2
				end
			end
		-- Normal Tech
		else
			if isShooting then
				--if data.rnsShortenedDelay < player.FireDelay then
				--	player.FireDelay = player.FireDelay*(1-0.95*(data.rnsNepNCharge^0.5))
				--	data.rnsShortenedDelay = math.min(player.FireDelay, player.MaxFireDelay-2)
				--end
				data.rnsNepCharge = data.rnsNepCharge - (math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
			else
				data.rnsNepCharge = data.rnsNepCharge + 2
			end
		end
	
	-- Ludo
	elseif weaponType == WeaponType.WEAPON_LUDOVICO_TECHNIQUE then
		isReallyAxisAligned = false
		if isShooting then
			data.rnsNepCharge = data.rnsNepCharge - 0.2*(math.max(maxFireDelay,0)+1)^((data.rnsNepNCharge)^nepPower)
		else
			data.rnsNepCharge = data.rnsNepCharge + 1.5
		end
	
	-- Monstro's Lung
	elseif weaponType == WeaponType.WEAPON_MONSTROS_LUNGS then
		if not isShooting then
			if data.rnsWasShooting then
				shootMonstrosLung(player, fam, data.rnsFireDur, data.rnsNepNCharge, data.rnsLastFireInput, false)
				data.rnsNepCharge = 0
			else
				data.rnsNepCharge = data.rnsNepCharge + 3
			end
		end
	
	-- Tears
	elseif weaponType == WeaponType.WEAPON_TEARS then
		if data.rnsIsDaBaby then
			data.rnsNepCharge = 0
		end
	end
	--== The End of weapon B******t ==--
	
	if isShooting then
		data.rnsFireDur = data.rnsFireDur + 1
	else
		data.rnsFireDur = 0
	end
	data.rnsWasShooting = isShooting
	data.rnsLastFireInput = fireDir
	if data.rnsLastFireInput.X ~= 0 or data.rnsLastFireInput.Y ~= 0 then
		data.rnsSafeFireInput = data.rnsLastFireInput
	end
	
	data.rnsNepCharge = math.min(math.max(0, data.rnsNepCharge), maxNepCharge)
	data.rnsNepNCharge = data.rnsNepCharge/maxNepCharge
	if weaponType ~= WeaponType.WEAPON_FETUS then
		data.rnsDisplayedCharge = math.floor(data.rnsNepNCharge*100 + 0.5)
	else
		data.rnsDisplayedCharge = 0
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.familiarUpdate)



function mod:ChargebarRender(entity)	-- original from Samael by Ghostbroster Connor, a little tweaked by me
	if not Options.ChargeBars then return end
	
	local data = entity:GetData()
	if not data.rnsDataSet then return end
	if not data.rnsDisplayedCharge then return end
	
	if not data.rnsChargebar then
		data.rnsChargebar = Sprite()
		data.rnsChargebar:Load("gfx/chargebar_neptunus.anm2", true)
		data.rnsChargebar.Offset = Vector(-12, -35)
		data.rnsChargebar.PlaybackSpeed = 0.5
		data.rnsChargebar:Play("Disappear", true)
		data.rnsChargebar:SetLastFrame()
	end
	
	local sprite = data.rnsChargebar
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
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.ChargebarRender)
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, mod.ChargebarRender, FamiliarVariant.INCUBUS)
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, mod.ChargebarRender, FamiliarVariant.UMBILICAL_BABY)


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




-- Tears
function mod:postTearInit(tear)
	local data = tear:GetData()
	data.rnsOwner = findOwner(tear)
	if not data.rnsOwner then return end
	if not data.rnsOwner:GetData().rnsDataSet then return end
	
	if not mod.config.changeSprites then return end
	
	local blueVar = nonBloodTearVars[tear.Variant]
	if blueVar then
		tear:ChangeVariant(blueVar)
	elseif tear.Variant == TearVariant.BALLOON then
		data.rnsBlueHaemo = true
		tear:ChangeVariant(TearVariant.BLUE)
		data.rnsChangedSprite = true
	elseif tear.Variant == TearVariant.BALLOON_BRIMSTONE then
		local data = tear:GetData()
		data.rnsBlueHaemo = true
		data.rnsBlueBrimHaemo = true
		tear:ChangeVariant(TearVariant.BLUE)
		data.rnsChangedSprite = true
	elseif tear.Variant == TearVariant.SWORD_BEAM
	or tear.Variant == TearVariant.TECH_SWORD_BEAM
	then
		changeSprite(tear)
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_INIT, CallbackPriority.LATE, mod.postTearInit)


function mod:postTearUpdate(tear)
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
	end
	
	if data.rnsOwner == nil then
		data.rnsOwner = findOwner(tear)
	end
	if not data.rnsOwner then
	--	data.rnsDoNotAffect = true
		return
	end
	
	local owner = data.rnsOwner
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	-- graphics
	if mod.config.changeSprites then
		local blueVar = nonBloodTearVars[tear.Variant]
		if blueVar then
			tear:ChangeVariant(blueVar)
		elseif not data.rnsChangedSprite then
			if tear.Variant == TearVariant.SWORD_BEAM then
				if mod.config.overwriteUniqueSprites
				or tear:GetSprite():GetFilename() == "gfx/002.047_sword tear.anm2"
				then
					changeSprite(tear, "gfx/002.047_sword tear_neptunus.anm2")
				end
			elseif tear.Variant == TearVariant.TECH_SWORD_BEAM then
				if mod.config.overwriteUniqueSprites
				or tear:GetSprite():GetFilename() == "gfx/002.049_tech sword tear.anm2"
				then
					changeSprite(tear, "gfx/002.049_tech sword tear_neptunus.anm2")
				end
			end
			data.rnsChangedSprite = true
		end
	end
	
	-- C Section
	if tear:HasTearFlags(TearFlags.TEAR_FETUS) then
		--if oData.rnsSavedWeapon ~= WeaponType.WEAPON_FETUS then return end
		local player = owner:ToPlayer() or owner.Player
		if not data.rnsCooldown then
			data.rnsCooldown = 0
		end
		if data.rnsCooldown <= 0 then
			local sprite = tear:GetSprite()
			local vel = Vector(10*player.ShotSpeed,0):Rotated(mod.fetusFrameToAngle[sprite:GetFrame()] or 0)
			local tear = player:FireTear(tear.Position, vel, true, false, true, owner, 0.4)
			tear.FallingSpeed = math.random(-5, -1)
			tear.FallingAcceleration = 2 + math.random(-14, -6)/10
			data.rnsCooldown = 0.9*player.MaxFireDelay
		else
			data.rnsCooldown = data.rnsCooldown - 1
		end
	-- Ludo
	elseif tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
		if oData.rnsSavedWeapon ~= WeaponType.WEAPON_LUDOVICO_TECHNIQUE then return end
		-- I don't fucking know why this shit works like this, ask Edmund on his trash farm
		-- Lung
		if oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
			if not data.SizeMult then
				data.SizeMult = 1
			end
			if not data.rnsScaleSet then
				tear.Scale = tear.Scale * (1 + 1*oData.rnsNepNCharge)^(0.5)	-- shit #1 - somehow this is runned twice. IDK how, but it is
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
				tear.Scale = tear.Scale * (1.5 + oData.rnsNepNCharge)
				data.rnsScaleSet = true
			else
				tear.Scale = tear.Scale * data.SizeMult * (1.5 + oData.rnsNepNCharge) / (1.5 + oData.rnsPrevNCharge)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.postTearUpdate)




-- Lasers
function mod:postLaserImpactInit(effect)
	-- many useful laser params aren't set at the moment of MC_POST_LASER_INIT
	-- however, at moment of spawning impact (which comes before first render) these are already set
	-- making this callback way better for handling most lasers
	-- except those which don't spawn one: brim + ludo, brim + tech x (tech + ludo/tech x spawns impact, though)
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
	
	local lData = laser:GetData()
	lData.rnsOwner = findOwner(laser)
	if not lData.rnsOwner then return end
	local oData = lData.rnsOwner:GetData()
	if not oData.rnsDataSet then return end
		
	if laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR then
		-- change lasers from haemo tears
		if laser.DisableFollowParent
		and (laser.Variant == LaserVariant.THICK_RED
		or laser.Variant == LaserVariant.THIN_RED
		or laser.Variant == LaserVariant.BRIM_TECH
		or laser.Variant == LaserVariant.THICKER_RED
		or laser.Variant == LaserVariant.THICKER_BRIM_TECH)
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
		-- Tech
		if laser.Variant == LaserVariant.THIN_RED then
			if oData.rnsSavedWeapon ~= WeaponType.WEAPON_LASER then return end
			-- Tech-Lung
			if oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG] then
				if laser.MaxDistance > 0
				and laser.DisableFollowParent
				then
					local laserGen = lData.rnsTechLungGen or 0
					local charge = oData.rnsSavedNCharge or 0
					if math.random(40) + 40*charge - 10*laserGen > 50 then
						if laserGen > 0 then
							effect.Visible = false
						end
						local pos = laser.Position + Vector(laser.MaxDistance, 0):Rotated(laser.AngleDegrees)
						local newLaser = EntityLaser.ShootAngle(LaserVariant.THIN_RED, pos, laser.AngleDegrees+math.random(-30,30), laser.Timeout, Vector.Zero, laser.SpawnerEntity)
						newLaser:AddTearFlags(laser.TearFlags)
						newLaser:SetMaxDistance(math.random(30, 100 - 15*laserGen))
						newLaser:SetOneHit(laser.OneHit)
						newLaser.CollisionDamage = laser.CollisionDamage
						newLaser.Color = laser.Color
						newLaser.DisableFollowParent = laser.DisableFollowParent
						newLaser.GridHit = laser.GridHit
						newLaser.Shrink = laser.Shrink
						local nlData = newLaser:GetData()
						nlData.rnsTechLungGen = laserGen + 1
						if mod.config.changeSprites then
							changeSprite(newLaser)
							nlData.rnsChangedSprite = true
						end
					end
				end
			-- Other chargable Tech
			elseif oData.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK] or oData.rnsHasWeaponMod[WeaponModifier.CURSED_EYE] then
				local mult = (1 + oData.rnsNepNCharge)
				laser.Size = laser.Size * mult
				laser.SpriteScale = laser.SpriteScale * mult
				effect.Size = laser.Size
				effect.SpriteScale = laser.SpriteScale
				oData.rnsState = 2
				lData.rnsScaleSet = true
			end
		-- Brim
		elseif mod.brimVariants[laser.Variant] then
			if oData.rnsSavedWeapon ~= WeaponType.WEAPON_BRIMSTONE then return end
			
			local player = lData.rnsOwner:ToPlayer() or lData.rnsOwner.Player
			if player.MaxFireDelay <= 1 or oData.rnsHasWeaponMod[WeaponModifier.SOY_MILK] then
				lData.rnsSoyBrim = true
			else
				laser:SetTimeout(math.floor(laser.Timeout*(1+4*oData.rnsNepNCharge) + 0.5))
			end
		end
	end
	
	if not mod.config.changeSprites then return end
	if laser.SubType > 2 or not mod.affectedLaserVariants[laser.Variant] then return end
	
	changeSprite(laser)
	changeSprite(effect)
	lData.rnsChangedSprite = true
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, CallbackPriority.LATE, mod.postLaserImpactInit, EffectVariant.LASER_IMPACT)


function mod:postLaserInit(laser)
	if laser.SubType > 2 or not mod.affectedLaserVariants[laser.Variant] then return end
	
	local data = laser:GetData()
	data.rnsOwner = findOwner(laser)
	if not data.rnsOwner then
		data.rnsDoNotAffect = true
		return
	end
	if not data.rnsOwner:GetData().rnsDataSet then return end
	
	if mod.config.changeSprites then
		changeSprite(laser)
		data.rnsChangedSprite = true
	end
end
--mod:AddPriorityCallback(ModCallbacks.MC_POST_LASER_INIT, CallbackPriority.LATE, mod.postLaserInit)


function mod:postLaserUpdate(laser)
	if laser.SubType > 2 or not mod.affectedLaserVariants[laser.Variant] then return end
	
	local data = laser:GetData()
	if data.rnsDoNotAffect then return end
	if data.rnsOwner == nil then
		data.rnsOwner = findOwner(laser)
	end
	if not data.rnsOwner then
		data.rnsDoNotAffect = true
		return
	end
	local oData = data.rnsOwner:GetData()
	if not oData.rnsDataSet then return end
	
	-- Linear
	if laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR then
		if laser.Variant == LaserVariant.THIN_RED then
			if oData.rnsSavedWeapon == WeaponType.WEAPON_LASER
			and (oData.rnsHasWeaponMod[WeaponModifier.CHOCOLATE_MILK]
			or oData.rnsHasWeaponMod[WeaponModifier.CURSED_EYE])
			then
				if not data.rnsScaleSet then
					laser.Size = laser.Size * (1 + oData.rnsNepNCharge)
					laser.SpriteScale = laser.SpriteScale * (1 + oData.rnsNepNCharge)
					oData.rnsState = 2
				end
				data.rnsScaleSet = true
			end
		elseif mod.brimVariants[laser.Variant] then
			if oData.rnsSavedWeapon == WeaponType.WEAPON_BRIMSTONE then
				if data.rnsSoyBrim then
					if not data.rnsScaleSet then
						laser.CollisionDamage = laser.CollisionDamage * (1+0.25*oData.rnsNepNCharge)
						laser.Size = laser.Size * (1 + oData.rnsNepNCharge)
						laser.SpriteScale = laser.SpriteScale * (1 + oData.rnsNepNCharge)
						data.rnsScaleSet = true
					else
						laser.CollisionDamage = laser.CollisionDamage * (1+0.25*oData.rnsNepNCharge) / (1+0.25*oData.rnsPrevNCharge)
						laser.Size = laser.Size * (1 + oData.rnsNepNCharge) / (1 + oData.rnsPrevNCharge)
						laser.SpriteScale = laser.SpriteScale * (1 + oData.rnsNepNCharge) / (1 + oData.rnsPrevNCharge)
					end
					if not oData.rnsWasShooting then	-- abandon
						data.rnsSoyBrim = false
					end
				end
			end
		end
	-- Ludo
	elseif laser.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO then
		if oData.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE] and not oData.rnsPlayerInAnim
		and not data.LudovicoFix_Parent then	-- "Ludovico Laser Fix" compatibility
			if oData.rnsSavedWeapon == WeaponType.WEAPON_LASER then
				if not data.rnsScaleSet then
					laser.Size = laser.Size * (1+oData.rnsNepNCharge)
					laser.SpriteScale = laser.SpriteScale * (1+oData.rnsNepNCharge)
					data.rnsScaleSet = true
				else
					laser.Size = laser.Size * (1+oData.rnsNepNCharge) / (1+oData.rnsPrevNCharge)
					laser.SpriteScale = laser.SpriteScale * (1+oData.rnsNepNCharge) / (1+oData.rnsPrevNCharge)
				end
			elseif oData.rnsSavedWeapon == WeaponType.WEAPON_BRIMSTONE then
				-- brim ludo recalculates size every update (except in anim), so no need to divide
				laser.Size = laser.Size * (1 + 0.5*oData.rnsNepNCharge)
				laser.SpriteScale = laser.SpriteScale * (1 + 0.5*oData.rnsNepNCharge)
			end
		end
		if mod.config.changeSprites then	-- ludo and techx brim don't have laser impact, so their sprite needs to be changed on update
			if not data.rnsChangedSprite then
				changeSprite(laser)
				data.rnsChangedSprite = true
			end
		end
	-- Tech X
	elseif laser.SubType == LaserSubType.LASER_SUBTYPE_RING_PROJECTILE then
		if oData.rnsSavedWeapon == WeaponType.WEAPON_TECH_X then
			if not data.rnsScaleSet then
				if laser.Variant == LaserVariant.THIN_RED then
					laser.Size = laser.Size * (1 +  1.25*oData.rnsNepNCharge)
					laser.SpriteScale = laser.SpriteScale * (1 + 1.25*oData.rnsNepNCharge)
					if laser.Child and laser.Child.Type == EntityType.ENTITY_EFFECT then
						laser.Child.SpriteScale = laser.Child.SpriteScale * (1 + 1.25*oData.rnsNepNCharge)
					end
				else
					laser.Size = laser.Size * (1 + 0.75*oData.rnsNepNCharge)
					laser.SpriteScale = laser.SpriteScale * (1 + 0.75*oData.rnsNepNCharge)
				end
				laser.Velocity = laser.Velocity * (1 - 0.33*oData.rnsNepNCharge)
				data.rnsScaleSet = true
			end
			if mod.config.changeSprites then	-- ludo and techx brim don't have laser impact, so their sprite needs to be changed on update
				if not data.rnsChangedSprite then
					changeSprite(laser)
					data.rnsChangedSprite = true
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.postLaserUpdate)


function mod:postLaserEffectInit(effect)
	if not mod.config.changeSprites then return end
	
	local data = effect:GetData()
	
	data.rnsOwner = findOwner(effect)
	if not data.rnsOwner then return end
	
	local oData = data.rnsOwner:GetData()
	if not oData.rnsDataSet then return end
	
	if effect.Variant == EffectVariant.BRIMSTONE_BALL then
		data.rnsSavedCharge = oData.rnsNepNCharge
		oData.rnsState = 2
	end
	
	changeSprite(effect)
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, CallbackPriority.LATE, mod.postLaserEffectInit, EffectVariant.BRIMSTONE_SWIRL)
mod:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, CallbackPriority.LATE, mod.postLaserEffectInit, EffectVariant.BRIMSTONE_BALL)
mod:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, CallbackPriority.LATE, mod.postLaserEffectInit, EffectVariant.TECH_DOT)


function mod:postBrimBallUpdate(effect)
	local data = effect:GetData()
	
	if not data.rnsSavedCharge then return end
	
	effect.Size = effect.Size * (1+0.5*data.rnsSavedCharge)
	effect.SpriteScale = effect.SpriteScale * (1+0.5*data.rnsSavedCharge)
	
	if not data.rnsNepBuffed then
		effect:SetTimeout(math.ceil(effect.Timeout * (1 + 2*data.rnsSavedCharge)))
		effect.Velocity = effect.Velocity * (1+0.5*data.rnsSavedCharge)
		data.rnsNepBuffed = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.postBrimBallUpdate, EffectVariant.BRIMSTONE_BALL)




--Knives
function mod:postKnifeInit(knife)
	if not mod.config.changeSprites then return end
	
	local owner = findOwner(knife)
	if not owner
	or not owner:GetData().rnsDataSet
	then return end
	
	if knife.Variant == 10 or knife.Variant == 11 then
		changeSprite(knife, mod.swordSubTypeToAnmFile[knife.Variant][knife.SubType])
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_KNIFE_INIT, 50, mod.postKnifeInit)


function mod:postKnifeUpdate(knife)
	local data = knife:GetData()
	
	local owner = findOwner(knife)
	if not owner then return end
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local player = owner:ToPlayer() or owner.Player
	local sprite = knife:GetSprite()
	local anim = sprite:GetAnimation()
	local frame = sprite:GetFrame()
	
	-- Mom's Knife and T.Eve's Sumptorium
	if knife.Variant == 0 or knife.Variant == 5 then
		if oData.rnsSavedWeapon ~= WeaponType.WEAPON_KNIFE then return end
		if knife.SubType == 1 then return end
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
				if not (data.rnsWhirlpool and data.rnsWhirlpool:Exists()) then
					data.rnsWhirlpool = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MIST, 0, knife.Position, knife.Velocity, owner):ToEffect()
					data.rnsWhirlpool.SortingLayer = SortingLayer.SORTING_BACKGROUND
					data.rnsWhirlpool:SetTimeout(-1)
					local whirlSprite = data.rnsWhirlpool:GetSprite()
					whirlSprite:Load("gfx/1000.142_whirlpool_neptunus.anm2", true)
					whirlSprite:SetFrame("Start", 0)
					local whirlData = data.rnsWhirlpool:GetData()
					whirlData.rnsIsWhirlpool = true
					whirlData.rnsOwner = owner
					whirlData.rnsMotherKnife = knife
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
				data.rnsWhirlpool.Velocity = knife.Velocity
				-- other handling in mod.postMistUpdate()
			end
		-- normal
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
	
	-- Forgotten's Bone and Scythe + Donkey Jawbone (Berserk!)
	elseif knife.Variant == 1 or knife.Variant == 2 or knife.Variant == 3 then
		if oData.rnsSavedWeapon ~= WeaponType.WEAPON_BONE then return end
		-- bone throw / shoot
		if knife:IsFlying() then
			if knife:GetKnifeDistance() > knife.MaxDistance-2 and player then
				local nepCharge = oData.rnsNepNCharge
				if oData.rnsHasWeaponMod[WeaponModifier.SOY_MILK] or player.MaxFireDelay <= 0 then
					nepCharge = 1
				end
				if nepCharge >= 0.05 then
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
				oData.rnsState = 3
			end
		-- bone swing
		elseif anim:sub(1, 5) == "Swing" then
			-- bone slash
			if knife.SubType == 4 then
				-- lower charge here, in case of different effect
				if frame == 0 then
					if oData.rnsHasWeaponMod[WeaponModifier.BRIMSTONE]
					or oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG]
					then
						oData.rnsState = 2
					end
				-- fire tear
				elseif frame == 3 then
					local isParentTear = false
					if knife.Parent then
						isParentTear = knife.Parent.Type == EntityType.ENTITY_TEAR
					end
					
					if player
					and (isParentTear
					or not (oData.rnsHasWeaponMod[WeaponModifier.BRIMSTONE]
					or oData.rnsHasWeaponMod[WeaponModifier.MONSTROS_LUNG]))
					then
						if oData.rnsNepNCharge >= 0.2 or isParentTear then
							local shotspeedMult = knife.Variant == 2 and 18 or 13
							local vel = Vector(shotspeedMult*player.ShotSpeed, 0):Rotated(knife.SpriteRotation+90)
							vel = vel + player:GetTearMovementInheritance(vel)
							local dmgMult = 0.6
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
					
					if not isParentTear		-- due to C Section
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
							oData.rnsState = 4
						elseif not oData.rnsWasShooting then
							if oData.rnsHasWeaponMod[WeaponModifier.C_SECTION] then
								oData.rnsState = 0
							else
								oData.rnsState = 4
							end
						end
					end
				-- lower charge, if swing anim was cut short because of new attack
				elseif anim ~= data.rnsSwingAnim
				and player.FireDelay == player.MaxFireDelay
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
				if oData.rnsState == 1 and not oData.rnsWasShooting then
					local targetExists = false
					if player
					and player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
						targetExists = findTarget(owner) ~= nil
					end
					if not targetExists then
						oData.rnsState = 0
					end
				end
			end
		end
	
	-- Spirit Sword
	elseif knife.Variant == 10 or knife.Variant == 11 then
		if oData.rnsSavedWeapon ~= WeaponType.WEAPON_SPIRIT_SWORD then return end
		
		if anim:sub(1, 6) == "Attack" and frame <= 2 then
			if oData.rnsNepCharge >= 3*player.MaxFireDelay then
				oData.rnsState = 3
				sprite:Play("Spin"..anim:sub(7), true)
				sfx:Play(SoundEffect.SOUND_SWORD_SPIN)
				--shoot tear
				if player and knife.SubType == 0 then
					local vel = Vector(10*player.ShotSpeed,0):Rotated(knife.Rotation)
					vel = vel + player:GetTearMovementInheritance(vel)
					local tear = player:FireTear(knife.Position, vel, false, false, true, owner, 1)
					if knife.Variant == 11 then
						tear:ChangeVariant(TearVariant.TECH_SWORD_BEAM)
					else
						tear:ChangeVariant(TearVariant.SWORD_BEAM)
						if AnimatedSpiritSwords then
							AnimatedSpiritSwords.BeamReplace(_, tear)
						end
					end
				elseif knife.SubType == 4 then
					knife.Scale = knife.Scale * 2
					knife.Size = knife.Size * 2
					knife.SpriteScale = knife.SpriteScale * 1.25
				end
			end
			if oData.rnsState == 0 then
				oData.rnsState = 3
			end
			for _,projectile in pairs(Isaac.FindInRadius(owner.Position, 90, EntityPartition.BULLET)) do
				projectile.Velocity = Vector(projectile.Position.X - owner.Position.X, projectile.Position.Y - owner.Position.Y):Resized(18)
			end
		end
		
		if mod.config.overwriteUniqueSprites then
			if not data.rnsSpriteChanged then
				changeSprite(knife, mod.swordSubTypeToAnmFile[knife.Variant][knife.SubType])
				data.rnsSpriteChanged = true
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, mod.postKnifeUpdate)


function mod:postKnifeRemove(entity)
	if entity.Variant ~= 10 and entity.Variant ~= 11 or entity.SubType ~= 0 then return end
	
	local owner = entity:GetData().rnsOwner
	if owner == nil then
		owner = findOwner(entity)
	end
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	if oData.rnsSavedWeapon ~= WeaponType.WEAPON_SPIRIT_SWORD then return end
	
	oData.rnsState = 0
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.postKnifeRemove, EntityType.ENTITY_KNIFE)


-- whirlpool (used for neptunus + knife + ludo)
function mod:postMistUpdate(effect)
	local data = effect:GetData()
	if not data.rnsIsWhirlpool then return end
	
	if not data.rnsOwner then
		effect:Remove()
		return
	end
	
	local oData = data.rnsOwner:GetData()
	if oData.rnsSavedWeapon ~= WeaponType.WEAPON_KNIFE
	or not oData.rnsHasWeaponMod[WeaponModifier.LUDOVICO_TECHNIQUE]
	then
		effect:Remove()
		return
	end
	
	if not data.rnsMotherKnife
	or not data.rnsMotherKnife:Exists()
	then
		effect:Remove()
		return
	end
	local kData = data.rnsMotherKnife:GetData()
	
	local pos = Vector.Zero
	local numKnives = 0
	for _, wpKnife in pairs(kData.rnsWhirlKnives) do
		pos = pos + wpKnife.Position
		numKnives = numKnives + 1
	end
	numKnives = math.max(numKnives, 1)
	effect.Position = pos / numKnives
	
	
	local sprite = effect:GetSprite()
	local anim = sprite:GetAnimation()
	local frame = sprite:GetFrame()
	if oData.rnsNepNCharge < 0.2 then
		if anim == "End" then
			if frame ~= 17 then
				sprite:SetFrame(frame+1)
			end
		elseif anim == "Start" then
			sprite:SetFrame("End", math.max(12-frame, 0))
		else
			sprite:SetFrame("End", 0)
		end
	else
		local kNumMult = (0.9 + 0.1*(numKnives))
		Game():UpdateStrangeAttractor(effect.Position, 7*kNumMult*oData.rnsNepNCharge, 150*kNumMult*oData.rnsNepNCharge)
		sprite.Scale = data.rnsMotherKnife.SpriteScale * kNumMult * oData.rnsNepNCharge^0.5
		if anim == "End" then
			sprite:SetFrame("Start", math.max(13-frame, 0))
		elseif anim == "Start" then
			if frame == 17 then
				sprite:SetFrame("Loop", 0)
			else
				sprite:SetFrame(frame+1)
			end
		else
			if frame == 7 then
				sprite:SetFrame(0)
			else
				sprite:SetFrame(frame+1)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.postMistUpdate, EffectVariant.MIST)




-- Bombs, explosions
function mod:postBombUpdate(bomb)	-- bomb.IsFetus isn't set on Init
	if not bomb.IsFetus then return end
	local data = bomb:GetData()
	if data.rnsRunned then return end
	
	local owner = findOwner(bomb)
	if owner then
		local oData = owner:GetData()
		if oData.rnsDataSet then
			data.rnsOwner = owner
			data.rnsPlayer = owner:ToPlayer() or owner.Player
		end
	end
	data.rnsRunned = true
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.postBombUpdate)


function mod:postRocketInit(effect)
	local owner = findOwner(effect)
	if not owner then return end
	
	local oData = owner:GetData()
	if not oData.rnsDataSet then return end
	
	local data = effect:GetData()
	--data.rnsNepNCharge = oData.rnsNepNCharge
	data.rnsOwner = owner
	data.rnsPlayer = owner:ToPlayer() or owner.Player
	data.rnsIsSmallRocket = effect.SpawnerEntity.Variant == EffectVariant.SMALL_ROCKET	-- whether it's Forgotten's Epic Fetus
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.postRocketInit, EffectVariant.ROCKET)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.postRocketInit, EffectVariant.SMALL_ROCKET)


function mod:postExplosionInit(effect)
	if not effect.SpawnerEntity then return end
	
	local sData = effect.SpawnerEntity:GetData()
	if not sData.rnsPlayer or not sData.rnsOwner then return end
	
	local oData = sData.rnsOwner:GetData()
	
	if sData.rnsIsSmallRocket ~= nil	-- if Epic Fetus
	and sData.rnsPlayer and oData.rnsNepNCharge then
		if oData.rnsNepNCharge >= 0.05 then
			local dmgMult = 0.66
			local tearsAmount = math.floor((2000 * oData.rnsNepNCharge^2.5 / math.max(sData.rnsPlayer.MaxFireDelay,1)^0.5) ^ 0.5 + 0.5)
			if sData.IsSoyMilkTarget then	-- correction for Soy synergy from "Epic Fetus Synergies" by JamesB456
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
		oData.rnsState = 3
	end
	
	
	if mod.config.waterBombs then
		changeSprite(effect, "gfx/1000.001b_water explosion.anm2")
		effect.Color = sData.rnsPlayer:GetTearHitParams(WeaponType.WEAPON_TEARS).TearColor
		--spawn creep
		if sData.rnsIsSmallRocket ~= nil	-- Epic Fetus
		and oData.rnsNepNCharge
		then
			local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, effect.Position, Vector.Zero, effect):ToEffect()
			creep.Size = creep.Size * 2 * oData.rnsNepNCharge
			creep.SpriteScale = creep.SpriteScale * 2 * oData.rnsNepNCharge
			creep.Color = sData.rnsPlayer:GetTearHitParams(WeaponType.WEAPON_TEARS).TearColor
			creep.CollisionDamage = sData.rnsPlayer.Damage * 0.33 * oData.rnsNepNCharge * getFamiliarDMGMult(sData.rnsOwner)
			creep:SetTimeout(100)
			creep:Update()
		else	-- Dr. Fetus 
			local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, effect.Position, Vector.Zero, effect):ToEffect()
			creep.Color = sData.rnsPlayer:GetTearHitParams(WeaponType.WEAPON_TEARS).TearColor
			creep.CollisionDamage = sData.rnsPlayer.Damage * 0.1 * getFamiliarDMGMult(sData.rnsOwner)
			creep:SetTimeout(100)
			creep:Update()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.postExplosionInit, EffectVariant.BOMB_EXPLOSION)