local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:pinheadLocustAI(locust)
	local d = locust:GetData()
    if locust.Coins == 0 and locust.Keys == 0 then
        locust.Keys = 1
        local pal = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, locust.SubType, locust.Position, Vector.Zero, locust.Player):ToFamiliar()
        pal.Coins = 1
        pal:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        pal:Update()
    end
    if not d.init then
        d.init = true
        if locust.Coins == 1 then
            locust.Color = Color(4, 2, 2, 1, 0, 0, -1)
		else
			locust.Color = Color(680/256, 680/256, 4, 1, -100/256, 0, 0)
        end
    end
end

function mod:storeWhistleLocustDamage(player, locust, entity)
	if math.random(20) == 1 then
		mod.scheduleForUpdate(function()
			if entity then
				if entity:IsDead() or entity:HasMortalDamage() then
					local item = Isaac.Spawn(5,0,3, Game():GetRoom():FindFreePickupSpawnPosition(entity.Position, 0, false), Vector.Zero, nil):ToPickup()
					item.AutoUpdatePrice = false
					local rng = item:GetDropRNG()
					local rando = rng:RandomInt(3)
					if rando == 1 then
						item.Price = rng:RandomInt(10) + 1
					elseif rando == 2 then
						item.Price = rng:RandomInt(20) + 1
					else
						item.Price = rng:RandomInt(99) + 1
					end
					item.ShopItemId = -1
					local poof = Isaac.Spawn(1000, EffectVariant.POOF01, 15, item.Position, Vector.Zero, nil)
				end
			end
		end, 1)
	end
end

function mod:wrongWarpLocustAI(locust)
	if locust.FireCooldown == -1 then
		local randomvalue = ((math.random(100) - 50))
		locust.Velocity = locust.Velocity:Rotated(randomvalue)
	end
end

function mod:modelRocketLocustAI(locust)
	if locust.FireCooldown == -1 then
		locust.Velocity = locust.Velocity * 1.1
	end
end
function mod:maliceLocustAI(locust)
	if locust.FireCooldown == -1 then
		locust.Velocity = locust.Velocity * 1.02
		local creep = Isaac.Spawn(1000, 45, 0, locust.Position, Vector.Zero, locust):ToEffect()
		creep.Scale = 0.65
		creep:SetTimeout(15)
		creep:Update()
	end
end

function mod:siblingSylLocustInit(locust)
	if math.random(5) == 1 then
		local sprite = locust:GetSprite()
		sprite:ReplaceSpritesheet(1, "gfx/familiar/locusts/null.png")
		sprite:ReplaceSpritesheet(0, "gfx/familiar/locusts/ff/trans.png")
		sprite:LoadGraphics()
	end
end

function mod:spareRibsLocustUpdate(locust)
	if locust.State == 0 then
		locust:GetData().ShotRibs = nil
	end
end
function mod:spareRibsLocustDamage(player, locust, entity)
	if not locust:GetData().ShotRibs then
		SFXManager():Play(SoundEffect.SOUND_BONE_SNAP, 0.6, 0, false, 1.5)
		for i = 1, 3 do
			local tear = player:FireTear(locust.Position, Vector(11, 0):Rotated(i * 120), false, true, false):ToTear()
			tear.TearFlags = TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL
			tear.FallingAcceleration = 0
			tear.FallingAcceleration = 0
			tear.CollisionDamage = mod:getLocustDamage(locust, 0.1)
			tear:GetData().isrib = true
			--tear:GetSprite():Load("gfx/projectiles/boomerang rib.anm2", true)
			--tear:GetSprite():Play("friendly", true)
			mod:changeTearVariant(tear, TearVariant.BOOMERANG_RIB)
			locust:GetData().ShotRibs = true
		end
	end
end

--[[function mod:ipadLocustDamage(player, locust, entity)
	local room = Game():GetRoom()
	entity.Position = Vector(entity.Position.X, room:GetGridHeight() * 50)
end]]

function mod:ipadWispPostFire(fam)
	fam.Velocity = Vector(0,1):Resized(fam.Velocity:Length()) + fam.Player:GetTearMovementInheritance(fam.Player:GetAimDirection())
end

--[[function mod:mimeDegreeDamage(player,locust,entity)
	entity:TakeDamage(math.random(100)/100, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(locust), 0)
end]]

function mod:leftoverTakeoutOnLocustDamage(player, locust, entity)
	local baseFortuneOdds = 17
	local freq = math.min(math.max(math.floor(22 - baseFortuneOdds - player.Luck), 3), 25)

	if math.random(freq) == 1 then
		mod:ShowFortune(false, true)
	end
end

function mod:loadedD6LocustInit(locust, sub)
	local locusts = {}
	local includedSubTypes = {}
	for _, ent in ipairs(Isaac.FindByType(3, 231, -1, false, false)) do
		if ent.SubType ~= sub and not includedSubTypes[ent.SubType] then
			includedSubTypes[ent.SubType] = true
			table.insert(locusts, ent.SubType)
		end
	end
	if #locusts > 0 then
		Isaac.Spawn(3, 231, locusts[math.random(#locusts)], locust.Position, Vector.Zero, locust.Player)
		locust:Remove()
	end
end

function mod:nyxLocustAI(locust)
	local d, sprite = locust:GetData(), locust:GetSprite()
    --Init for spawning other two locusts
    if locust.Coins == 0 and locust.Keys == 0 then
        locust.Keys = 1
		for i = 1, 2 do
			local newLocust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, locust.SubType, locust.Position, nilvector, locust.Player):ToFamiliar()
			newLocust.Coins = i
			newLocust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			newLocust:Update()
		end
    end
    if not d.init then
        d.init = true
        if locust.Coins == 1 then
            locust.Color = Color(3, 2, 4, 1, 0, -1, 0) --Purple
        elseif locust.Coins == 2 then
			locust.Color = Color(544/256, 916/256, 420/256, 1, 0, 0, 0) --Green
		else
			locust.Color = Color(4, 2, 2, 1, 0, 0, -1) --Orange
        end
    end
end

------------------------------------------------------------

mod.ErflyLocustDict = {
	[FiendFolio.ITEM.COLLECTIBLE.STORE_WHISTLE] = {
		Damage = mod.storeWhistleLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.BABY_CRATER] = {
		Update = mod.babyCraterLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.SPARE_RIBS] = {
		Update = mod.spareRibsLocustUpdate,
		Damage = mod.spareRibsLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.DEVILS_UMBRELLA] = {
		Update = mod.devilsUmbrellaLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.BEE_SKIN] = {
		Update = mod.beeSkinlocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.MARIAS_IPAD] = {
		--Damage = mod.ipadLocustDamage
		PostFire = mod.ipadWispPostFire,
	},
	[FiendFolio.ITEM.COLLECTIBLE.PINHEAD] = {
		Update = mod.pinheadLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.SLIPPYS_GUTS] = {
		Update = mod.frogLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.SLIPPYS_HEART] = {
		Update = mod.frogLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.LEFTOVER_TAKEOUT] = {
		Damage = mod.leftoverTakeoutOnLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.MODERN_OUROBOROS] = {
		Damage = mod.modernOuroOnLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.FROG_HEAD] = {
		Update = mod.frogLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.AVGM] = {
		Update = mod.avgmLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.FIDDLE_CUBE] = {
		Update = mod.fiddleCubeLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.MALICE] = {
		Update = mod.maliceLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.MALICE_REFORM] = {
		Update = mod.maliceLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.BLACK_MOON] = {
		Update = mod.blackMoonlocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.MODEL_ROCKET] = {
		Update = mod.modelRocketLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.SIBLING_SYL] = {
		Init = mod.siblingSylLocustInit
	},
	[FiendFolio.ITEM.COLLECTIBLE.WRONG_WARP] = {
		Update = mod.wrongWarpLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.NYX] = {
		Update = mod.nyxLocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.EMOJI_GLASSES] = {
		Update = mod.beeSkinlocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.X10BATOOMKLING] = {
		Damage = mod.batoomKlingOnLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.INFINITY_VOLT] = {
		Update = mod.infinityVoltLocustAI,
	},
	[FiendFolio.ITEM.COLLECTIBLE.RAT_POISON] = {
		Damage = mod.ratPoisonOnLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.ANGELIC_LYRE_B] = {
		Update = mod.lyreLocustUpdate,
		Damage = mod.lyreLocustDamage,
		PostFire = mod.lyrePostFire,
	},
	[FiendFolio.ITEM.COLLECTIBLE.ANGELIC_LYRE_R] = {
		Update = mod.lyreLocustUpdate,
		Damage = mod.lyreLocustDamage,
		PostFire = mod.lyrePostFire,
	},
	[FiendFolio.ITEM.COLLECTIBLE.ANGELIC_LYRE_Y] = {
		Update = mod.lyreLocustUpdate,
		Damage = mod.lyreLocustDamage,
		PostFire = mod.lyrePostFire,
	},
	[FiendFolio.ITEM.COLLECTIBLE.MIME_DEGREE] = {
		Update = mod.mimeDegreeLocustAI,
		--Damage = mod.mimeDegreeDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.NIL_PASTA] = {
		Damage = mod.nilPastaOnLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF] = {
		Update = mod.timeItselfLocustAI,
		Damage = mod.timeItselfOnLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.HORNCOB] = {
		Update = mod.horncoblocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.BAG_OF_BOBBIES] = {
		Update = mod.bobbyBaglocustAI
	},
	[FiendFolio.ITEM.COLLECTIBLE.SMASH_TROPHY] = {
		Damage = mod.smashTrophyOnLocustDamage
	},
	[FiendFolio.ITEM.COLLECTIBLE.LOADED_D6] = {
		Init = mod.loadedD6LocustInit
	},
}

--fam.FireCooldown == -1 when charging
--fam.State == -1 when not orbiting

--Locusts
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local sub = fam.SubType
	if mod.ErflyLocustDict[sub] and mod.ErflyLocustDict[sub].Update then
		mod.ErflyLocustDict[sub].Update(_,fam,sub)
	end
	if mod.ErflyLocustDict[sub] and mod.ErflyLocustDict[sub].PostFire then
		local d = fam:GetData()
		if fam.FireCooldown == -1 then
			if not d.erfPostFire then
				mod.ErflyLocustDict[sub].PostFire(_,fam,sub,d)
				d.erfPostFire = true
			end
		else
			d.erfPostFire = false
		end
	end
end, FamiliarVariant.ABYSS_LOCUST)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	local sub = fam.SubType
	if mod.ErflyLocustDict[sub] and mod.ErflyLocustDict[sub].Init then
		mod.scheduleForUpdate(function()
			if fam and fam:Exists() then
				mod.ErflyLocustDict[sub].Init(_,fam,sub)
			end
		end, 0, nil, true)
	end
end, FamiliarVariant.ABYSS_LOCUST)

function mod:erflyOnLocustDamage(player, locust, entity, secondHandMultiplier, flags)
	if flags ~= flags | DamageFlag.DAMAGE_NO_MODIFIERS then
		local sub = locust.SubType
		locust = locust:ToFamiliar()
		if mod.ErflyLocustDict[sub] and mod.ErflyLocustDict[sub].Damage then
			mod.ErflyLocustDict[sub].Damage(_,player, locust, entity, secondHandMultiplier)
		end
	end
end

function mod:getLocustDamage(fam, mult)
	local player
	mult = mult or 1
	if fam.Player then
		player = fam.Player
		if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
			mult = mult * 1.25
		end
	else
		player = Isaac.GetPlayer()
	end

	return player.Damage * mult
end