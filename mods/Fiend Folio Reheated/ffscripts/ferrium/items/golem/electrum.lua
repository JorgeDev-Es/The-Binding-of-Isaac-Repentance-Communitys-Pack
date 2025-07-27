local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local eColor = Color(0.88,0.95,0,1,0.62,0.93,0.14)
eColor:SetColorize(0.65,0.73,0.4,0.55)

local eExponent = 2

mod.electrumSynergies = {
	[CollectibleType.COLLECTIBLE_BIBLE] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			local beam = Isaac.Spawn(1000, 19, 0, enemy.Position, Vector.Zero, p):ToEffect()
			beam.Parent = p
			beam.CollisionDamage = p.Damage*mult
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			local d = p:GetData().ffsavedata.RunEffects
			d.electrumBelial = (d.electrumBelial or 0)+mult
			p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			p:EvaluateItems()
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_NECRONOMICON] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				Isaac.Spawn(3, 234, 0, enemy.Position, RandomVector(), p)
				sfx:Play(SoundEffect.SOUND_BONE_HEART, 0.5, 0, false, math.random(100,130)/100)
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_POOP] = function(player, mult, rng, itemConfig)
		local d = player:GetData()
		d.electrumPoop = d.electrumPoop or {}
		table.insert(d.electrumPoop, {index = game:GetRoom():GetGridIndex(player.Position), state = 0, mult = mult, rng = rng, itemConfig = itemConfig})
	end,
	[CollectibleType.COLLECTIBLE_MR_BOOM] = function(player, mult, rng, itemConfig)
		for _,bomb in ipairs(Isaac.FindByType(4, 1, -1, false ,false)) do
			if bomb.Position:Distance(player.Position) < 5 and bomb.FrameCount == 0 and bomb.SpawnerEntity:ToPlayer() then
				bomb:GetData().electrumBomb = {player = player, damage = player.Damage, mult = mult, targets = 3}
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_TAMMYS_HEAD] = function(player, mult, rng)
		local rangle = rng:RandomInt(360)
		for i=1,10 do
			local laser = EntityLaser.ShootAngle(2, player.Position, rangle+36*i, 1, Vector.Zero, player)
			laser.Color = eColor
			laser.CollisionDamage = player.Damage*mult+25
		end
	end,
	[CollectibleType.COLLECTIBLE_MOMS_BRA] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().refreezePetrify = 60
			enemy:GetData().electrumPlayer = p
			enemy:GetData().electrumRender = true
		end
		local color = Color(1,1,1,1,0.2,0,0)
		color:SetColorize(0.95,0.4,0.4,1)
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf, color)
	end,
	[CollectibleType.COLLECTIBLE_KAMIKAZE] = function(player, mult)
		local laser = player:FireTechXLaser(player.Position, player.Velocity, 80, player, mult)
		laser.Timeout = 10
		laser.Color = eColor
	end,
	[CollectibleType.COLLECTIBLE_MOMS_PAD] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().refear = 60
			enemy:GetData().electrumPlayer = p
			enemy:GetData().electrumRender = true
		end
		local color = Color(1,0,1,1,0.3,0,0.3)
		color:SetColorize(0.6,0.32,0.74,1)
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf, color)
	end,
	[CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD] = function()
		--These are kept blank so you can't spam the item and shoot lasers constantly, effects are determined elsewhere
	end,
	[CollectibleType.COLLECTIBLE_TELEPORT] = function(player, mult, rng, itemConfig)
		player:GetData().electrumTeleport = 0
	end,
	[CollectibleType.COLLECTIBLE_YUM_HEART] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(4) == 0 then
					Isaac.Spawn(5, 10, 2, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_DOCTORS_REMOTE] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			for _,target in ipairs(Isaac.FindByType(1000, 30, -1, false, false)) do
				target:GetData().electrumRemote = {player = player, rng = rng, damage = player.Damage*mult+2^eExponent}
			end
		end, 0)
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP] = function(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_LEMON_MISHAP] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			local puddle = Isaac.Spawn(1000, 32, 0, enemy.Position, Vector.Zero, p):ToEffect()
			puddle:Update()
			puddle.Size = puddle.Size*0.3
			puddle.Scale = puddle.Scale*0.3
			puddle.CollisionDamage = puddle.CollisionDamage/3
			puddle:Update()
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS] = function(player, mult, rng, itemConfig)
		local c = player:GetColor()
		player:GetData().electrumShadows = Color(c.R, c.G, c.B, c.A, c.RO, c.GO, c.BO)
		player.Color = Color(2,2,1,1,0,0,0)
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK] = function(player, mult, rng, itemConfig)
		player:GetData().electrumAnarchist = true
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_HOURGLASS] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:AddSlowing(EntityRef(player), 300, 0.2, Color(1,1,1,1,0.25,0.25,0.25))
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN] = function(player, mult, rng, itemConfig)
		player:GetData().electrumUnicorn = 0
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			local subt = r:RandomInt(5)+1
			local fly = Isaac.Spawn(3, 43, subt, p.Position, Vector.Zero, p):ToFamiliar()
			fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_THE_NAIL] = function(player, mult, rng, itemConfig) --REUSES BELIAL
		local hf = function(enemy, p, m, r)
			local d = p:GetData().ffsavedata.RunEffects
			d.electrumBelial = (d.electrumBelial or 0)+mult
			p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			p:EvaluateItems()
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(15) == 0 then
					Isaac.Spawn(5, 300, Card.RUNE_EHWAZ, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_DECK_OF_CARDS] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(10) == 0 then
					Isaac.Spawn(5, 300, 0, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_MONSTROS_TOOTH] = function(player, mult, rng, itemConfig)
		for _,monstro in ipairs(Isaac.FindByType(1000, 28, -1, false, false)) do
			monstro:GetData().electrumMonstro = {player = player, rng = rng, damage = player.Damage*mult+3^eExponent}
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_GAMEKID] = function(player, mult, rng, itemConfig)
		player:GetData().electrumUnicorn = true
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_BOOK_OF_SIN] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(4) == 0 then
					Isaac.Spawn(5, 0, 4, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_MOMS_BOTTLE_OF_PILLS] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if p:HasCollectible(CollectibleType.COLLECTIBLE_PHD) then
					local num = mod.positivePills[r:RandomInt(#mod.positivePills)+1]
                	p:GetData().queuedSpecificPills = p:GetData().queuedSpecificPills or {}
                	table.insert(p:GetData().queuedSpecificPills, num)
				else
					FiendFolio.QueuePills(p, 1)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_D6] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(6) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D6, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_PINKING_SHEARS] = function(player, mult, rng, itemConfig)
		for _,body in ipairs(Isaac.FindByType(3, 48, -1, false, false)) do
			body:GetData().electrumShears = {player = player, rng = rng, damage = player.Damage*mult+6^eExponent}
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_BEAN] = function(player, mult, rng, itemConfig)
		local hitFunc = function(enemy, p, m, r, laser)
			enemy:AddPoison(EntityRef(p), 70, player.Damage*mult+1)
		end
		local color = Color(0,0.95,0,1,0.3,0.93,0.14)
		color:SetColorize(0.2,1,0.4,0.55)
		mod:electrumShock(player, mult, rng, itemConfig, nil, hitFunc, color)
	end,

	[CollectibleType.COLLECTIBLE_MONSTER_MANUAL] = function(player, mult, rng, itemConfig)
		local hitFunc = function(enemy, p, m, r, laser)
			enemy:GetData().electrumDeath = function()
				local bobby = Isaac.Spawn(3, mod.ITEM.FAMILIAR.FRAGILE_BOBBY, 0, enemy.Position, Vector.Zero, p)
				--bobby:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				sfx:Play(SoundEffect.SOUND_DERP, 1, 0, false, math.random(140,160)/100)
				bobby:Update()
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hitFunc)
	end,

	--CollectibleType.COLLECTIBLE_DEADSEASCROLLS
	--okay I don't really want to bother finding out which effect dead sea scrolls activates

	[CollectibleType.COLLECTIBLE_RAZOR_BLADE] = function(player, mult, rng, itemConfig)
		local color = Color(1,1,1,1,0,0,0)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+1.5*player:GetHearts(), player.Position, 3, color)
	end,

	--CollectibleType.COLLECTIBLE_FORGET_ME_NOW

	[CollectibleType.COLLECTIBLE_PONY] = function(player, mult, rng, itemConfig)
		player:GetData().electrumPony = true
		mod:electrumShock(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_GUPPYS_PAW] = function(player, mult, rng, itemConfig)
		local hitFunc = function(enemy, p, m, r, laser)
			enemy:GetData().electrumDeath = function()
				Isaac.Spawn(5, 10, 8, enemy.Position, RandomVector(), p)
			end
		end
		local color = Color(0, 0, 1, 1, 0.45, 0.45, 0.8)
		color:SetColorize(0, 0, 1, 1)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+9, player.Position, 2, color, hitFunc)
	end,
	[CollectibleType.COLLECTIBLE_IV_BAG] = function(player, mult, rng, itemConfig)
		local color = Color(1,1,1,1,0,0,0)
		local hitFunc = function(enemy, p, m, r, laser)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(3) == 0 then
					Isaac.Spawn(5, 20, 1, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:alternateElectrumShock(player, rng, player.Damage*mult+3, player.Position, 3, color, hitFunc)
	end,
	[CollectibleType.COLLECTIBLE_BEST_FRIEND] = function(player, mult, rng, itemConfig)
		for _,bomb in ipairs(Isaac.FindByType(4, 2, -1, false, false)) do
			bomb:GetData().electrumBestFriend = {player = player, damage = player.Damage*mult, mult = mult, rng = rng}
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_REMOTE_DETONATOR] = function(player, mult, rng, itemConfig)
		for _,bomb in ipairs(Isaac.FindByType(4, -1, -1, false, false)) do
			bomb:GetData().electrumBomb = {player = player, damage = player.Damage*mult+2^eExponent, targets = 1, mult = mult, rng = rng}
		end
	end,
	[CollectibleType.COLLECTIBLE_GUPPYS_HEAD] = function(player, mult, rng, itemConfig)
		local hitFunc = function(enemy, p, m, r, laser)
			for _,fly in ipairs(Isaac.FindByType(3, 43, -1, false, false)) do
				fly.Target = enemy
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hitFunc)
	end,
	[CollectibleType.COLLECTIBLE_PRAYER_CARD] = function(player, mult, rng, itemConfig)
		local hitFunc = function(enemy, p, m, r, laser)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(4) == 0 then
					if p:GetEternalHearts() == 1 then
						p:AddEternalHearts(1)
					end
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hitFunc)
	end,
	[CollectibleType.COLLECTIBLE_NOTCHED_AXE] = function()
	end,
	[CollectibleType.COLLECTIBLE_CRYSTAL_BALL] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(10) == 0 then
					if r:RandomInt(2) == 0 then
						Isaac.Spawn(5, 300, 0, enemy.Position, RandomVector(), p)
					else
						Isaac.Spawn(5, 10, 3, enemy.Position, RandomVector(), p)
					end
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_CRACK_THE_SKY] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			local beam = Isaac.Spawn(1000, 19, 0, enemy.Position, Vector.Zero, p):ToEffect()
			beam.Parent = p
			beam.CollisionDamage = p.Damage*mult
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_CANDLE] = function()
	end,
	[CollectibleType.COLLECTIBLE_D20] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(5) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D20, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_SPIDER_BUTT] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			local spider = Isaac.Spawn(3, 73, 0, p.Position, Vector.Zero, p):ToFamiliar()
			spider.Player = p
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_DADS_KEY] = function(player, mult, rng, itemConfig)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+25*(player:GetNumKeys()/99), player.Position, 2)
	end,
	[CollectibleType.COLLECTIBLE_PORTABLE_SLOT] = function(player, mult, rng, itemConfig)
		if player:GetNumCoins() > 0 then
			mod:alternateElectrumShock(player, rng, player.Damage*mult+player.Damage*(mod:getRoll(-10,20,rng)/10), player.Position, rng:RandomInt(5))
		end
	end,
	[CollectibleType.COLLECTIBLE_WHITE_PONY] = function(player, mult, rng, itemConfig)
		player:GetData().electrumWhitePony = true
		mod:electrumShock(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_BLOOD_RIGHTS] = function(player, mult, rng, itemConfig)
		local hitFunc = function(enemy, p, m, r, laser)
			enemy:GetData().electrumDeath = function()
				for i=1,6 do
					local tear = p:FireTear(enemy.Position, Vector(mod:getRoll(3,28,r)/3, 0):Rotated(r:RandomInt(360)), false, true, false, p, 1)
					tear.FallingSpeed = -mod:getRoll(10,20,r)
					tear.FallingAcceleration = 1.1
					tear:ChangeVariant(1)
					tear.Scale = mod:getRoll(60,120,r)/100
					tear:Update()
				end
			end
		end
		mod:alternateElectrumShock(player, rng, player.Damage*mult+3, player.Position, 2, nil, hitFunc)
	end,
	[CollectibleType.COLLECTIBLE_TELEPATHY_BOOK] = function(player, mult, rng, itemConfig)
		local color = Color(1, 0, 1, 1, 0.5, 0.3, 0.8)
		color:SetColorize(0.6, 0, 0.6, 1)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+2^eExponent, player.Position, 2, color, nil, nil, nil, 400)
	end,
	[CollectibleType.COLLECTIBLE_CLEAR_RUNE] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				p:UseCard(Card.RUNE_SHARD, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			end
		end
		local slot = mod:findActiveSlot(CollectibleType.COLLECTIBLE_CLEAR_RUNE, player)
		local charge = player:GetActiveCharge(slot)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+charge^eExponent, player.Position, charge, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_HOW_TO_JUMP] = function(player, mult, rng, itemConfig)
		player:GetData().electrumJump = true
	end,
	[CollectibleType.COLLECTIBLE_D100] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(6) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D100, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_D4] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(6) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D4, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_D10] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			if rng:RandomInt(3) == 0 then
				Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D10, enemy.Position, RandomVector(), p)
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_BLANK_CARD] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(10) == 0 then
					Isaac.Spawn(5, 300, 0, enemy.Position, RandomVector(), p)
				end
			end
		end

		local slot = mod:findActiveSlot(CollectibleType.COLLECTIBLE_BLANK_CARD, player)
		local charge = player:GetActiveCharge(slot)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+charge^eExponent, player.Position, charge, nil, hf)
	end,

	--[[[CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS] = function(player, mult, rng, itemConfig)
	end,]]

	[CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			local spider = Isaac.Spawn(3, 73, 0, p.Position, Vector.Zero, p):ToFamiliar()
			spider.Player = p
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_RED_CANDLE] = function()
	end,
	[CollectibleType.COLLECTIBLE_THE_JAR] = function(player, mult, rng, itemConfig)
		local heartCount = 0
		for _,heart in ipairs(Isaac.FindByType(5, 10, -1, false, false)) do
			if heart.FrameCount == 0 and heart.SpawnerEntity and heart.SpawnerEntity.InitSeed == player.InitSeed then
				if heart.SubType == 1 then
					heartCount = heartCount+2
					heart:Remove()
				elseif heart.SubType == 2 then
					heartCount = heartCount+1
					heart:Remove()
				end
			end
		end
		if heartCount > 0 then
			local hitFunc = function(enemy, p, m, r)
				enemy:GetData().electrumDeath = function()
					p:AddHearts(1)
					sfx:Play(SoundEffect.SOUND_VAMP_GULP)
					local poof = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, player):ToEffect()
					poof.SpriteOffset = Vector(0,-45)
					poof:FollowParent(player)
					poof:Update()
				end
			end
			mod:alternateElectrumShock(player, rng, (player.Damage+heartCount)*mult+5*heartCount, player.Position, heartCount, Color(1,1,1,1,0,0,0), hitFunc)
		end
	end,
	[CollectibleType.COLLECTIBLE_SATANIC_BIBLE] = function(player, mult, rng, itemConfig)
		local dealMult = (1+game:GetRoom():GetDevilRoomChance())
		mod:alternateElectrumShock(player, rng, player.Damage*mult*dealMult+6^eExponent, player.Position, 6, Color(0,0,0,1,0,0,0))
	end,
	[CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS] = function(player, mult, rng, itemConfig)
		local enemies = {}
		for _, enemy in ipairs(Isaac.FindInRadius(player.Position, 200, EntityPartition.ENEMY)) do
			if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
				table.insert(enemies, enemy)
			end
		end
		if #enemies > 0 then
			if #enemies > 3 then
				local chosen = mod:getSeveralDifferentNumbers(3, #enemies, rng)
				local placeHolder = {}
				for i=1,#chosen do
					table.insert(placeHolder, enemies[chosen[i]])
				end
				enemies = placeHolder
			end
			for _, enemy in ipairs(enemies) do
				local angle = (enemy.Position-player.Position):GetAngleDegrees()
				local laser = EntityLaser.ShootAngle(2, player.Position, angle, 40, Vector.Zero, player)
				laser.CollisionDamage = player.Damage/2
				laser.MaxDistance = enemy.Position:Distance(player.Position)
				--laser.DisableFollowParent = true
				laser.Color = eColor
			end
		end
	end,
	[CollectibleType.COLLECTIBLE_BUTTER_BEAN] = function(player, mult, rng, itemConfig)
		mod:electrumShock(player, mult, rng, itemConfig, true)

		local enemies = {}
		for _, proj in ipairs(Isaac.FindInRadius(player.Position, 300, EntityPartition.BULLET)) do
			if proj:ToProjectile().ProjectileFlags ~= proj:ToProjectile().ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER then
				table.insert(enemies, proj)
			end
		end
		if #enemies > 0 then
			if #enemies > 2 then
				local chosen = mod:getSeveralDifferentNumbers(2, #enemies, rng)
				local placeHolder = {}
				for i=1,#chosen do
					table.insert(placeHolder, enemies[chosen[i]])
				end
				enemies = placeHolder
			end
			for _, enemy in ipairs(enemies) do
				local angle = (enemy.Position-player.Position):GetAngleDegrees()
				local laser = EntityLaser.ShootAngle(2, player.Position, angle, 1, Vector.Zero, player)
				laser.CollisionDamage = player.Damage/2
				laser.MaxDistance = enemy.Position:Distance(player.Position)
				--laser.DisableFollowParent = true
				laser.Color = eColor
				enemy:Die()
			end
		end
	end,
	[CollectibleType.COLLECTIBLE_MAGIC_FINGERS] = function(player, mult, rng, itemConfig)
		if player:GetNumCoins() > 0 then
			local hitFunc = function(enemy, p, m, r, laser)
				enemy:GetData().electrumDeath = function()
					if r:RandomInt(5) == 0 then
						Isaac.Spawn(5, 20, 1, enemy.Position, RandomVector(), p)
					end
				end
			end
			mod:electrumShock(player, mult, rng, itemConfig, true, hitFunc)
		end
	end,
	[CollectibleType.COLLECTIBLE_CONVERTER] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r, laser)
			enemy:GetData().electrumDeath = function()
				Isaac.Spawn(5, 10, 1, enemy.Position, RandomVector(), p)
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_BLUE_BOX
	
	[CollectibleType.COLLECTIBLE_UNICORN_STUMP] = function(player, mult, rng, itemConfig)
		local c = player:GetColor()
		player:GetData().electrumShadows = Color(c.R, c.G, c.B, c.A, c.RO, c.GO, c.BO)
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_ISAACS_TEARS] = function(player, mult, rng, itemConfig)
		for i=1,8 do
			local laser = EntityLaser.ShootAngle(2, player.Position, 45*i, 1, Vector.Zero, player)
			laser.Color = eColor
			laser.CollisionDamage = player.Damage*mult+5
		end
	end,

	--CollectibleType.COLLECTIBLE_UNDEFINED

	[CollectibleType.COLLECTIBLE_SCISSORS] = function(player, mult, rng, itemConfig)
		for _,head in ipairs(Isaac.FindByType(3, FamiliarVariant.SCISSORS, -1, false, false)) do
			head:GetData().electrumScissors = {player = player, damage = player.Damage*mult, mult = mult, rng = rng}
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_BREATH_OF_LIFE] = function(player, mult, rng, itemConfig)
		mod:electrumShock(player, mult, rng, itemConfig, true)

		--player:GetData().electrumBreath = true
	end,
	[CollectibleType.COLLECTIBLE_BOOMERANG] = function(player, mult, rng, itemConfig)
	end,

	--CollectibleType.COLLECTIBLE_DIPLOPIA

	[CollectibleType.COLLECTIBLE_PLACEBO] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if p:HasCollectible(CollectibleType.COLLECTIBLE_PHD) then
					local num = mod.positivePills[r:RandomInt(#mod.positivePills)+1]
                	p:GetData().queuedSpecificPills = p:GetData().queuedSpecificPills or {}
                	table.insert(p:GetData().queuedSpecificPills, num)
				else
					FiendFolio.QueuePills(p, 1)
				end
			end
		end

		local slot = mod:findActiveSlot(CollectibleType.COLLECTIBLE_PLACEBO, player)
		local charge = player:GetActiveCharge(slot)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+charge^eExponent, player.Position, charge, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_WOODEN_NICKEL] = function(player, mult, rng, itemConfig)
		if rng:RandomInt(2) == 0 then
			local hitFunc = function(enemy, p, m, r, laser)
				enemy:GetData().electrumDeath = function()
					Isaac.Spawn(5, 20, 1, enemy.Position, RandomVector(), p)
				end
			end
			mod:alternateElectrumShock(player, rng, player.Damage*mult*2+10, player.Position, 1, nil, hitFunc)
		end
	end,
	[CollectibleType.COLLECTIBLE_MEGA_BEAN] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			game:Fart(enemy.Position, 70, player, 1)
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_GLASS_CANNON] = function(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS] = function(player, mult, rng, itemConfig)
		for _,fam in ipairs(Isaac.FindByType(3, -1, -1)) do
			if fam.Variant == 43 or fam.Variant == 73 then
			else
				mod:alternateElectrumShock(player, rng, player.Damage*mult+4^eExponent, fam.Position, 1)
			end
		end
		mod:alternateElectrumShock(player, rng, player.Damage*mult+4^eExponent, player.Position, 1)
	end,
	[CollectibleType.COLLECTIBLE_FRIEND_BALL] = function()
	end,
	[CollectibleType.COLLECTIBLE_TEAR_DETONATOR] = function(player, mult, rng)
		for _,tear in ipairs(Isaac.FindByType(2, -1, -1)) do
			if tear.FrameCount > 0 then
				mod:alternateElectrumShock(player, rng, player.Damage*mult, tear.Position, 1)
			end
		end
	end,
	[CollectibleType.COLLECTIBLE_D12] = function(player, mult, rng, itemConfig)
		--[[for _,grid in ipairs(mod.GetGridEntities()) do
			if grid.Position:Distance(player.Position) < 200 then
				mod:alternateElectrumShock(player, rng, player.Damage*mult+3^eExponent, grid.Position, 1)
			end
		end]]
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(3) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D12, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR] = function(player, mult, rng, itemConfig)
		for _,port in ipairs(Isaac.FindByType(1000, EffectVariant.WOMB_TELEPORT, -1)) do
			port:GetData().electrumVentricle = {player = player, damage = player.Damage*mult, rng}
		end
	end,
	[CollectibleType.COLLECTIBLE_D8] = function(player, mult, rng, itemConfig)
		--mod:alternateElectrumShock(player, rng, player.Damage*mult+player.Damage*(rng:RandomInt(10)/9), player.Position, 4)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(4) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D8, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_TELEPORT_2] = function(player, mult, rng, itemConfig)
		player:GetData().electrumTeleport = 1
	end,
	[CollectibleType.COLLECTIBLE_KIDNEY_BEAN] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:AddCharmed(EntityRef(player), 120)
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = function(player, mult, rng, itemConfig) --I figure the only time you'll see the effect is when it's unpowered
		local hf = function(enemy, p, m, r)
			enemy:AddSlowing(EntityRef(player), 300, 0.2, Color(1,1,1,1,0.25,0.25,0.25))
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_MINE_CRAFTER] = function(player, mult, rng, itemConfig)
		for _,barr in ipairs(Isaac.FindByType(292, 1, -1)) do
			if barr:ToNPC().State ~= 16 then
				barr:GetData().electrumMineCrafter = {player = player, damage = player.Damage*mult, rng}
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	[CollectibleType.COLLECTIBLE_JAR_OF_FLIES] = function(player, mult, rng, itemConfig)
		local flyCount = 0
		for _,fly in ipairs(Isaac.FindByType(3, 43, -1, false, false)) do
			if fly.FrameCount == 0 and fly.SpawnerEntity.InitSeed == player.InitSeed then
				fly:Remove()
				flyCount = flyCount+1
			end
		end
		local damage = player.Damage*2*mult
		if player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
			damage = damage*2
		end
		local flyHits = 0
		local hf = function()
			flyHits = flyHits+1
		end
		mod:alternateElectrumShock(player, rng, damage, player.Position, flyCount, nil, hf)
		for i=1,(flyCount-flyHits) do
			local fly = Isaac.Spawn(3, 43, 0, player.Position, Vector.Zero, player):ToFamiliar()
			fly.Player = player
		end
	end,

	--CollectibleType.COLLECTIBLE_D7

	[CollectibleType.COLLECTIBLE_MOMS_BOX] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(8) == 0 then
					Isaac.Spawn(5, 350, 0, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_MEGA_BLAST
	--CollectibleType.COLLECTIBLE_BROKEN_GLASS_CANNON
	--CollectibleType.COLLECTIBLE_PLAN_C
	--CollectibleType.COLLECTIBLE_D1

	[CollectibleType.COLLECTIBLE_VOID] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			if rng:RandomInt(5) == 0 then
				enemy:GetData().electrumDeath = function()
					local portal = Isaac.Spawn(306, 0, 0, enemy.Position, Vector.Zero, player):ToNPC()
					portal:AddCharmed(EntityRef(player), -1)
					--portal.HitPoints = portal.HitPoints*2
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_PAUSE] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:AddFreeze(EntityRef(player), 120)
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_SMELTER] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(13) == 0 then
					Isaac.Spawn(5, 350, 0, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_COMPOST] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			if rng:RandomInt(2) == 0 then
				local spider = Isaac.Spawn(3, 73, 0, p.Position, Vector.Zero, p):ToFamiliar()
				spider.Player = player
			else
				local fly = Isaac.Spawn(3, 43, 0, player.Position, Vector.Zero, player):ToFamiliar()
				fly.Player = player
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_DATAMINER
	--CollectibleType.COLLECTIBLE_CLICKER
	--CollectibleType.COLLECTIBLE_MAMA_MEGA

	[CollectibleType.COLLECTIBLE_WAIT_WHAT] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			game:ButterBeanFart(enemy.Position, 70, player, true, false)
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_CROOKED_PENNY] = function(player, mult, rng, itemConfig)
		local heal = false
		if rng:RandomInt(2) == 0 then
			heal = true
		end
		local hf = function(enemy, p, m, r, laser)
			if not enemy:IsBoss() then
				if heal then
					laser.CollisionDamage = 0
					enemy.HitPoints = enemy.MaxHitPoints
					local poof = Isaac.Spawn(1000, 49, 0, enemy.Position, Vector.Zero, enemy):ToEffect()
					poof.SpriteOffset = Vector(0, -30 + enemy.Size * -1.0)
					poof:FollowParent(enemy)
					poof:Update()
				else
					laser.CollisionDamage = enemy.MaxHitPoints
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_DULL_RAZOR

	[CollectibleType.COLLECTIBLE_POTATO_PEELER] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			local cubes = 0
			for _,cube in ipairs(Isaac.FindByType(3, 44, -1)) do
				cubes = cubes+1
			end
			for _,cube in ipairs(Isaac.FindByType(3, 45, -1)) do
				cubes = cubes+2
			end
			for _,cube in ipairs(Isaac.FindByType(3, 46, -1)) do
				cubes = cubes+3
			end
			for _,cube in ipairs(Isaac.FindByType(3, 47, -1)) do
				cubes = cubes+4
			end
			mod:alternateElectrumShock(player, rng, (player.Damage*mult+15)*cubes, player.Position, cubes)
		end, 0)
	end,

	--CollectibleType.COLLECTIBLE_METRONOME

	[CollectibleType.COLLECTIBLE_D_INFINITY] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(4) == 0 then
					local num = mod.pocketDiceSelection[rng:RandomInt(#mod.pocketDiceSelection)+1]
					Isaac.Spawn(5, 300, num, enemy.Position, RandomVector(), p)
				end
			end
		end

		local slot = mod:findActiveSlot(CollectibleType.COLLECTIBLE_D_INFINITY, player)
		local charge = player:GetActiveCharge(slot)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+charge^eExponent, player.Position, charge, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_EDENS_SOUL

	[CollectibleType.COLLECTIBLE_BROWN_NUGGET] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			for _,fly in ipairs(Isaac.FindByType(3, 115, -1, false, false)) do
				if fly.FrameCount == 1 and fly.SpawnerEntity.InitSeed == player.InitSeed then
					fly:GetData().electrumNugget = {player = player, damage = player.Damage*mult}
				end
			end
		end, 0)
	end,
	[CollectibleType.COLLECTIBLE_SHARP_STRAW] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			if rng:RandomInt(6) == 0 then
				player:AddHearts(1)
				local poof = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, player):ToEffect()
				poof.SpriteOffset = Vector(0,-45)
				poof:FollowParent(player)
				poof:Update()
			end
		end

		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_DELIRIOUS

	[CollectibleType.COLLECTIBLE_BLACK_HOLE] = function()
	end,
	[CollectibleType.COLLECTIBLE_MYSTERY_GIFT] = function(player, mult, rng, itemConfig) --this takes them out of the item pool but I DONT CARE ITS A TRINKET SYNERGY WITH A SPECIFIC ITEM THAT CAN ONLY BE FOUND AS A CERTAIN CHARACTER
		for _,pedestal in ipairs(Isaac.FindByType(5, 100, -1)) do
			if pedestal.FrameCount < 2 and not pedestal:GetData().electrumGift then
				pedestal:GetData().electrumGift = true
				pedestal:ToPickup():Morph(5, 100, mod.GetItemFromCustomItemPool(mod.CustomPool.TECHNOLOGY_ITEMS, rng))
			end
		end
	end,
	[CollectibleType.COLLECTIBLE_SPRINKLER] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			for _,sprink in ipairs(Isaac.FindByType(3, 120, -1, false, false)) do
				if sprink.FrameCount < 2 then
					sprink:GetData().electrumSprinkler = {player = player, damage = player.Damage*mult, rng = rng}
				end
			end
		end, 0)

		mod:electrumShock(player, mult, rng, itemConfig, nil)
	end,
	
	--CollectibleType.COLLECTIBLE_COUPON

	[CollectibleType.COLLECTIBLE_TELEKINESIS] = function(player, mult, rng)
		local enemies = {}
		for _, proj in ipairs(Isaac.FindInRadius(player.Position, 300, EntityPartition.BULLET)) do
			if proj:ToProjectile().ProjectileFlags ~= proj:ToProjectile().ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER then
				table.insert(enemies, proj)
			end
		end
		if #enemies > 0 then
			if #enemies > 2 then
				local chosen = mod:getSeveralDifferentNumbers(2, #enemies, rng)
				local placeHolder = {}
				for i=1,#chosen do
					table.insert(placeHolder, enemies[chosen[i]])
				end
				enemies = placeHolder
			end
			for _, enemy in ipairs(enemies) do
				local angle = (enemy.Position-player.Position):GetAngleDegrees()
				local laser = EntityLaser.ShootAngle(2, player.Position, angle, 1, Vector.Zero, player)
				laser.CollisionDamage = player.Damage/2
				laser.MaxDistance = enemy.Position:Distance(player.Position)
				--laser.DisableFollowParent = true
				laser.Color = eColor
				enemy:Die()
			end
		end
	end,
	[CollectibleType.COLLECTIBLE_MOVING_BOX] = function(player, mult, rng, itemConfig)
		local d = player:GetData().ffsavedata.RunEffects
		if d.electrumMovingBox then
			for _,orig in ipairs(d.electrumMovingBox) do
				local enemy = Isaac.Spawn(orig.Type, orig.Variant, orig.SubType, player.Position, Vector.Zero, player):ToNPC()
				enemy:AddCharmed(EntityRef(player), -1)
				enemy:Update()
			end
		end
		d.electrumMovingBox = {}
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if not enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and not enemy:IsBoss() then
					table.insert(d.electrumMovingBox, enemy)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_MR_ME

	[CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR] = function(player, mult, rng, itemConfig)	
		mod.scheduleForUpdate(function()
			local slot = mod:findActiveSlot(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, player)
			if slot == nil then
				local hf = function(enemy, p, m, r)
					local d = p:GetData().ffsavedata.RunEffects
					d.electrumSacrificial = (d.electrumSacrificial or 0)+mult
					p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					p:EvaluateItems()
				end
				mod:alternateElectrumShock(player, rng, player.Damage*mult+40, player.Position, 3, Color(1,1,1,1,0,0,0), hf)
			end
		end, 0)
	end,
	[CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				local boneboy = Isaac.Spawn(227, 0, 0, enemy.Position, RandomVector(), p)
				boneboy:AddCharmed(EntityRef(player), -1)
				sfx:Play(SoundEffect.SOUND_BONE_HEART, 0.5, 0, false, math.random(100,130)/100)
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_1] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			Isaac.Spawn(1000, 29, 0, enemy.Position, Vector.Zero, player)
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_MOMS_SHOVEL

	[CollectibleType.COLLECTIBLE_GOLDEN_RAZOR] = function(player, mult, rng, itemConfig)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+25*(player:GetNumCoins()/99), player.Position, 2)
	end,
	[CollectibleType.COLLECTIBLE_SULFUR] = function(player, mult, rng, itemConfig)
		local enemies = {}
		for _, enemy in ipairs(Isaac.FindInRadius(player.Position, 200, EntityPartition.ENEMY)) do
			if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
				table.insert(enemies, enemy)
			end
		end
		if #enemies > 0 then
			if #enemies > 3 then
				local chosen = mod:getSeveralDifferentNumbers(3, #enemies, rng)
				local placeHolder = {}
				for i=1,#chosen do
					table.insert(placeHolder, enemies[chosen[i]])
				end
				enemies = placeHolder
			end
			for _, enemy in ipairs(enemies) do
				local angle = (enemy.Position-player.Position):GetAngleDegrees()
				local laser = EntityLaser.ShootAngle(1, player.Position, angle, 10, Vector.Zero, player)
				laser.CollisionDamage = player.Damage/2*mult
				laser.MaxDistance = enemy.Position:Distance(player.Position)
				--laser.DisableFollowParent = true
				laser.Color = eColor
			end
		end
	end,
	[CollectibleType.COLLECTIBLE_FORTUNE_COOKIE] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			mod.scheduleForUpdate(function()
				mod:ShowFortune(false, true)
			end, rng:RandomInt(100))
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_DAMOCLES] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r, laser)
			if not enemy:IsBoss() then
				laser.CollisionDamage = enemy.MaxHitPoints
				local rangle = math.random(360)
				for i=-6,6,2 do
					Isaac.Spawn(1000, 5, 0, enemy.Position, Vector(i+math.random(-1,1),0):Rotated(rangle), player)
				end
				for i=1,3 do
					Isaac.Spawn(1000, 5, 0, enemy.Position, RandomVector()*math.random(1,3), player)
				end
				local poof = Isaac.Spawn(1000, 2, 160, enemy.Position, Vector.Zero, player):ToEffect()
				poof:FollowParent(enemy)
				SFXManager():Play(SoundEffect.SOUND_KNIFE_PULL, 0.6, 0, false, math.random(100,120)/100)
			end
		end
		mod:alternateElectrumShock(player, rng, player.Damage*10*mult+50, player.Position, 4, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_FREE_LEMONADE] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			local puddle = Isaac.Spawn(1000, 32, 0, enemy.Position, Vector.Zero, p):ToEffect()
			puddle:Update()
			puddle.Size = puddle.Size
			puddle.Scale = puddle.Scale
			puddle.CollisionDamage = puddle.CollisionDamage/3
			puddle:Update()
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_RED_KEY] = function(player, mult, rng, itemConfig)
		local room = game:GetRoom()
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					Isaac.Spawn(5, 300, Card.CARD_CRACKED_KEY, enemy.Position, RandomVector(), p)
				end
			end
		end
		for _,door in ipairs(mod.availableDoors[room:GetRoomShape()]) do
			mod:alternateElectrumShock(player, rng, player.Damage*mult+4^eExponent, room:GetDoorSlotPosition(door), 3, Color(1,1,1,1,0,0,0), hf)
		end
	end,
	[CollectibleType.COLLECTIBLE_WAVY_CAP] = function(player, mult, rng, itemConfig)
		local tempEffs = player:GetEffects()
		local wavy = tempEffs:GetNullEffect(71)
		local base = 0
		if wavy then
			base = wavy.Count
		end
		local data = player:GetData()
		data.electrumWavy = (data.electrumWavy or 0)+1
		local dam = base+data.electrumWavy
		mod:alternateElectrumShock(player, rng, (player.Damage*mult+3)*dam, player.Position, math.ceil(dam/2))
	end,
	[CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(4) == 0 then
					Isaac.Spawn(3, 206, 0, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_ALABASTER_BOX

	[CollectibleType.COLLECTIBLE_MOMS_BRACELET] = function()
		--uhhhh the setup I made won't work and I'm too lazy to work it out again
	end,
	[CollectibleType.COLLECTIBLE_SCOOPER] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			for _,eye in ipairs(Isaac.FindByType(3, FamiliarVariant.PEEPER_2, -1, false, false)) do
				if eye.FrameCount < 2 then
					eye:GetData().electrumScooper = {player = player, damage = player.Damage*mult+3^eExponent}
				end
			end
		end, 0)
	end,
	[CollectibleType.COLLECTIBLE_ETERNAL_D6] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(6) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D6, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_LARYNX
	--CollectibleType.COLLECTIBLE_GENESIS

	[CollectibleType.COLLECTIBLE_SHARP_KEY] = function(player, mult, rng, itemConfig)
	end,

	--CollectibleType.COLLECTIBLE_MEGA_MUSH
	--CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE
	--CollectibleType.COLLECTIBLE_MEAT_CLEAVER I would make it split them again, but can't really make it target specific enemies easily

	[CollectibleType.COLLECTIBLE_STITCHES] = function(player, mult, rng, itemConfig)
		for _,st in ipairs(Isaac.FindByType(3, FamiliarVariant.STITCHES, -1, false, false)) do
			if st:ToFamiliar().Player.InitSeed == player.InitSeed then
				mod:alternateElectrumShock(player, rng, player.Damage*mult+5, st.Position, 1)
			end
		end
		mod:alternateElectrumShock(player, rng, player.Damage*mult+5, player.Position, 1)
	end,

	--CollectibleType.COLLECTIBLE_R_KEY

	[CollectibleType.COLLECTIBLE_ERASER] = function()
	end,
	[CollectibleType.COLLECTIBLE_YUCK_HEART] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(4) == 0 then
					Isaac.Spawn(5, 10, 12, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_URN_OF_SOULS] = function(player, mult, rng, itemConfig)--im lazy eat it
	end,
	[CollectibleType.COLLECTIBLE_MAGIC_SKIN] = function(player, mult, rng, itemConfig)
		local hearts = player:GetBrokenHearts()
		mod:alternateElectrumShock(player, rng, player.Damage*mult+6^eExponent+hearts*10, player.Position, 6)
	end,
	[CollectibleType.COLLECTIBLE_PLUM_FLUTE] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			for _,plumepepklmelum in ipairs(Isaac.FindByType(3, FamiliarVariant.BABY_PLUM, -1, false, false)) do
				if plumepepklmelum:ToFamiliar().Player.InitSeed == player.InitSeed and plumepepklmelum.FrameCount < 20 then
					plumepepklmelum:GetData().electrumPlum = {player = player, damage = player.Damage*mult, rng = rng}
				end
			end
		end, 20)
		mod:electrumShock(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_VADE_RETRO] = function(player, mult, rng, itemConfig)
		for _,ghos in ipairs(Isaac.FindByType(1000, EffectVariant.ENEMY_GHOST, 0, false, false)) do
			mod:alternateElectrumShock(player, rng, player.Damage*mult+6, ghos.Position, 2, Color(1,1,1,1,0,0,0))
		end
	end,
	[CollectibleType.COLLECTIBLE_SPIN_TO_WIN] = function(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_JAR_OF_WISPS] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(4) == 0 then
					Isaac.Spawn(3, 206, 0, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[CollectibleType.COLLECTIBLE_FRIEND_FINDER] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			for _, enemy in ipairs(Isaac.FindInRadius(player.Position, 200, EntityPartition.ENEMY)) do
				if mod:isFriend(enemy) and enemy.FrameCount < 2 then
					for k = 0, 120, 5 do
						mod.scheduleForUpdate(function()
							if enemy and enemy:Exists() then
								local laser = EntityLaser.ShootAngle(2, enemy.Position, rng:RandomInt(360), 2, Vector(0, -10), Isaac.GetPlayer())
								laser.Parent = enemy
								laser.CollisionDamage = player.Damage*mult+4^eExponent
								laser.MaxDistance = enemy.Size + mod:getRoll(50, 100, rng)
								laser.Color = eColor
								laser:Update()
							end
						end, k)
					end
				end
			end
		end, 0)
		
		mod:electrumShock(player, mult, rng, itemConfig)
	end,

	--CollectibleType.COLLECTIBLE_ESAU_JR
	--CollectibleType.COLLECTIBLE_BERSERK
	--[CollectibleType.COLLECTIBLE_DARK_ARTS] you know, I was going to make it zap on each knife hit but I think that would just ruin combos

	[CollectibleType.COLLECTIBLE_ABYSS] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			for _,loc in ipairs(Isaac.FindByType(3, FamiliarVariant.ABYSS_LOCUST, -1, false, false)) do
				if loc:ToFamiliar().Player.InitSeed == player.InitSeed then
					loc:GetData().electrumAbyss = {player = player, damage = player.Damage*mult, rng = rng}
				end
			end
		end, 0)
		mod:electrumShock(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_SUPLEX] = function(player, mult, rng, itemConfig)
		player:GetData().electrumSuplex = true
	end,
	--[CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING] okay I'm sorry but I just want to be done with this item and this seems complex
	--if another coder wants to finish, the concept was that it zaps on crafting or collecting an item, damage scales with the quality of the item/pickup

	--CollectibleType.COLLECTIBLE_FLIP

	[CollectibleType.COLLECTIBLE_LEMEGETON] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMEGETON, UseFlag.USE_NOANIM, -1, 0)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--CollectibleType.COLLECTIBLE_SUMPTORIUM

	--[CollectibleType.COLLECTIBLE_RECALL] --ehh, this works how I thought it would so that's fine
	[CollectibleType.COLLECTIBLE_HOLD] = function(player, mult, rng)
		mod:alternateElectrumShock(player, rng, player.Damage*mult, player.Position, 2)
	end,

	--CollectibleType.COLLECTIBLE_KEEPERS_BOX

	[CollectibleType.COLLECTIBLE_EVERYTHING_JAR] = function(player, mult, rng)
		local slot = mod:findActiveSlot(CollectibleType.COLLECTIBLE_EVERYTHING_JAR, player)
		local charge = player:GetActiveCharge(slot)
		mod:alternateElectrumShock(player, rng, player.Damage*mult+charge^eExponent, player.Position, charge)
	end,
	[CollectibleType.COLLECTIBLE_ANIMA_SOLA] = function(player, mult, rng, itemConfig)
		local donot = {}
		for _,chain in ipairs(Isaac.FindByType(1000, EffectVariant.ANIMA_CHAIN, -1, false, false)) do
			if chain.Target then
				table.insert(donot, chain.Target)
			end
		end

		local hf = function(enemy, p, m, r)
			local chain = Isaac.Spawn(1000, EffectVariant.ANIMA_CHAIN, 0, enemy.Position, Vector.Zero, player):ToEffect()
			chain.Target = enemy
		end

		mod:alternateElectrumShock(player, rng, player.Damage*mult, player.Position, 2, nil, hf, mult, donot)
	end,

	--CollectibleType.COLLECTIBLE_SPINDOWN_DICE

	[CollectibleType.COLLECTIBLE_GELLO] = function(player, mult, rng, itemConfig)
	end,
	[CollectibleType.COLLECTIBLE_DECAP_ATTACK] = function()
	end,
	
	--mod.ITEM.COLLECTIBLE.FIEND_FOLIO No I am not adding special technology attacks to every boss
	
	[mod.ITEM.COLLECTIBLE.D2] = function()
	end,

	--mod.ITEM.COLLECTIBLE.STORE_WHISTLE
	--mod.ITEM.COLLECTIBLE.RISKS_REWARD
	--mod.ITEM.COLLECTIBLE.ALPHA_COIN I'm sorry erfly I can't spend more time on this item doing 8 billion synergies I'm disappointed too
	--mod.ITEM.COLLECTIBLE.MARIAS_IPAD

	[mod.ITEM.COLLECTIBLE.GRAPPLING_HOOK] = function() --effect done in grappling hook code
	end,

	--mod.ITEM.COLLECTIBLE.GOLEMS_ROCK

	[mod.ITEM.COLLECTIBLE.FROG_HEAD] = function() --effect done in frog head code
	end,
	[mod.ITEM.COLLECTIBLE.SANGUINE_HOOK] = function() --most of these will be done in other code
	end,
	[mod.ITEM.COLLECTIBLE.FIDDLE_CUBE] = function()
	end,
	[mod.ITEM.COLLECTIBLE.AVGM] = function()
	end,
	--mod.ITEM.COLLECTIBLE.MALICE, letting the auto handle it.

	--mod.ITEM.COLLLECTIBLE.MALICE_REFORM
	[mod.ITEM.COLLECTIBLE.CONTRABAND] = function(player, mult, rng, itemConfig) --it's not a custom effect, but I thought it should have damage
		mod:alternateElectrumShock(player, rng, player.Damage*mult*5+30, player.Position, 5)
	end,

	[mod.ITEM.COLLECTIBLE.BEDTIME_STORY] = function(player, mult, rng, itemConfig)
		local hf = function(enemy)
			mod.scheduleForUpdate(function()
				local data = enemy:GetData()
				if data.FFSleepDuration then
					data.FFDrowsyDuration = 0
				end
				if data.FFSleepDuration then
					data.FFSleepDuration = data.FFSleepDuration*2
				end
			end, 2)
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.ETERNAL_D12] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(3) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D12, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.ETERNAL_D12_ALT] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(3) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D12, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PURPLE_PUTTY] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(7) == 0 then
					Isaac.Spawn(5, 1024, 0, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.FIEND_MIX] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				local egg = Isaac.Spawn(1000, EffectVariant.PICKUP_FIEND_MINION, 1, enemy.Position, Vector.Zero, player)
				egg:GetData().canreroll = false
				egg.EntityCollisionClass = 4
				egg.Parent = player
				egg:GetData().hollow = true

				local poof = Isaac.Spawn(1000, 15, 0, egg.Position, Vector.Zero, nil)
				poof.SpriteScale = poof.SpriteScale * 0.5
				poof.Color = Color(0.3,0.3,0.3,1,10 / 255,0,10 / 255)

				egg:Update()
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.WHITE_PEPPER] = function(player, mult, rng, itemConfig)
		local hf = function(enemy)
			enemy:GetData().electrumDeath = function()
				local fire = Isaac.Spawn(1000, 10, 0, enemy.Position, Vector.Zero, player):ToEffect()
				fire.Parent = player
				fire.Color = mod.ColorNormal
				fire.CollisionDamage = player.Damage*mult
				fire.Timeout = 300
				fire:Update()
			end
		end
		mod:alternateElectrumShock(player, rng, player.Damage*mult+2^eExponent, player.Position, 5, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_1] = function(player, mult, rng, itemConfig) --oh my god
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					local pickupType = FiendFolio.GetRandomObject(rng)
					Isaac.Spawn(5, 300, pickupType, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_2] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					local pickupType = FiendFolio.GetRandomObject(rng)
					Isaac.Spawn(5, 300, pickupType, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_3] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					local pickupType = FiendFolio.GetRandomObject(rng)
					Isaac.Spawn(5, 300, pickupType, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_4] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					local pickupType = FiendFolio.GetRandomObject(rng)
					Isaac.Spawn(5, 300, pickupType, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_5] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					local pickupType = FiendFolio.GetRandomObject(rng)
					Isaac.Spawn(5, 300, pickupType, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_6] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					local pickupType = FiendFolio.GetRandomObject(rng)
					Isaac.Spawn(5, 300, pickupType, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_8] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					local pickupType = FiendFolio.GetRandomObject(rng)
					Isaac.Spawn(5, 300, pickupType, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.PERFECTLY_GENERIC_OBJECT_12] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if rng:RandomInt(6) == 0 then
					local pickupType = FiendFolio.GetRandomObject(rng)
					Isaac.Spawn(5, 300, pickupType, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--mod.ITEM.COLLECTIBLE.WRONG_WARP

	[mod.ITEM.COLLECTIBLE.GOLDEN_PLUM_FLUTE] = function(player, mult, rng, itemConfig)
		mod.scheduleForUpdate(function()
			for _,plumepepklmelum in ipairs(Isaac.FindByType(3, FamiliarVariant.BABY_PLUM, -1, false, false)) do
				if plumepepklmelum:ToFamiliar().Player.InitSeed == player.InitSeed and plumepepklmelum.FrameCount < 20 then
					plumepepklmelum:GetData().electrumPlum = {player = player, damage = player.Damage*mult, rng = rng}
				end
			end
		end, 20)
		mod:electrumShock(player, mult, rng, itemConfig)
	end,

	--mod.ITEM.COLLECTIBLE.DOGBOARD

	[mod.ITEM.COLLECTIBLE.ETERNAL_D10] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(3) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D10, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.TOY_CAMERA] = function()--back to code in other files
	end,

	--mod.ITEM.COLLECTIBLE.THE_BROWN_HORN
	--mod.ITEM.COLLECTIBLE.ETERNAL_CLICKER

	[mod.ITEM.COLLECTIBLE.SNOW_GLOBE] = function(player, mult, rng, itemConfig)
		local gblack = {
			[15] = true, [16] = true, [21] = true, [24] = true
		}
		for _,grid in ipairs(mod.GetGridEntities()) do
			if grid.CollisionClass > 1 and not gblack[grid:GetType()] and grid.Position:Distance(player.Position) < 200 then
				mod:alternateElectrumShock(player, rng, player.Damage*mult+1, grid.Position, 1)
			end
		end
	end,
	[mod.ITEM.COLLECTIBLE.CHERRY_BOMB] = function()--ok if it's blank, it'll be in another file. no more notes
	end,
	[mod.ITEM.COLLECTIBLE.ASTROPULVIS] = function()
	end,
	[mod.ITEM.COLLECTIBLE.AZURITE_SPINDOWN] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(5) == 0 then
					Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_AZURITE_SPINDOWN, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.KING_WORM] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r, laser)
			local worm = {TearFlags.TEAR_WIGGLE, TearFlags.TEAR_SQUARE, TearFlags.TEAR_BIG_SPIRAL}
			laser:AddTearFlags(worm[rng:RandomInt(#worm)+1])
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,
	[mod.ITEM.COLLECTIBLE.DAZZLING_SLOT] = function(player, mult, rng, itemConfig)
	end,
	[mod.ITEM.COLLECTIBLE.KALUS_HEAD] = function()
	end,

	--mod.ITEM.COLLECTIBLE.RAT_POISON
	[mod.ITEM.COLLECTIBLE.ANGELIC_LYRE_B] = function() --these have no effect, just so you can't spam temporarily
	end,
	[mod.ITEM.COLLECTIBLE.ANGELIC_LYRE_R] = function()
	end,
	[mod.ITEM.COLLECTIBLE.ANGELIC_LYRE_Y] = function()
	end,

	[mod.ITEM.COLLECTIBLE.HORSE_PASTE] = function(player, mult, rng, itemConfig)
		local hearts = player:GetBrokenHearts()
		mod:alternateElectrumShock(player, rng, player.Damage*mult+6^eExponent+hearts*10, player.Position, 6)
	end,
	[mod.ITEM.COLLECTIBLE.LEMON_MISHUH] = function()
	end,

	--mod.ITEM.COLLECTIBLE.NIL_PASTA
	--mod.ITEM.COLLECTIBLE.EMPTY_BOOK
	--mod.ITEM.COLLECTIBLE.MY_STORY_2
	--mod.ITEM.COLLECTIBLE.MY_STORY_4
	--mod.ITEM.COLLECTIBLE.MY_STORY_6

	[mod.ITEM.COLLECTIBLE.YICK_HEART] = function(player, mult, rng, itemConfig)
		local hf = function(enemy, p, m, r)
			enemy:GetData().electrumDeath = function()
				if r:RandomInt(13) == 0 then
					Isaac.Spawn(5, 1028, 0, enemy.Position, RandomVector(), p)
				end
			end
		end
		mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
	end,

	--mod.ITEM.COLLECTIBLE.GAMMA_GLOVES
	--mod.ITEM.COLLECTIBLE.SHREDDER
	--mod.ITEM.COLLECTIBLE.LOADED_D6
	--mod.ITEM.COLLECTIBLE.TORTURE_COOKIE
	--mod.ITEM.COLLECTIBLE.MOONBEAM
	--mod.ITEM.COLLECTIBLE.DUSTY_D10
	--mod.ITEM.COLLECTIBLE.HEDONISTS_COOKBOOK
	--mod.ITEM.COLLECTIBLE.ERRORS_CRAZY_SLOTS
	--mod.ITEM.COLLECTIBLE.SCULPTED_PEPPER
}

function mod:electrumUseActive(item, rng, player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ELECTRUM) then
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ELECTRUM)
		local itemConfig = Isaac:GetItemConfig():GetCollectible(item)
		if mod.electrumSynergies[item] then
			mod.electrumSynergies[item](player, mult, rng, itemConfig)
		else
			mod:electrumShock(player, mult, rng, itemConfig)
		end
	end
end

function mod:electrumShock(player, mult, rng, itemConfig, bypass, hitFunc, color)
	local charges = itemConfig.MaxCharges
	local color2 = color or eColor
	if charges > 0 or bypass then
		local special = false
		if itemConfig.ChargeType > 0 then
			special = true
		end
		
		local enemies = {}
		for _, enemy in ipairs(Isaac.FindInRadius(player.Position, 200, EntityPartition.ENEMY)) do
			if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
				table.insert(enemies, enemy)
			end
		end
		if #enemies > 0 then
			if bypass then
				charges = 1
			end
			if #enemies > charges then
				local chosen = mod:getSeveralDifferentNumbers(charges, #enemies, rng)
				local placeHolder = {}
				for i=1,#chosen do
					table.insert(placeHolder, enemies[chosen[i]])
				end
				enemies = placeHolder
			end
			for _, enemy in ipairs(enemies) do
				local angle = (enemy.Position-player.Position):GetAngleDegrees()
				local laser = EntityLaser.ShootAngle(2, player.Position, angle, 1, Vector.Zero, player)
				if special or bypass then
					laser.CollisionDamage = player.Damage*mult
				else
					laser.CollisionDamage = player.Damage*mult+charges^eExponent
				end
				laser.MaxDistance = enemy.Position:Distance(player.Position)
				laser.DisableFollowParent = true
				laser.Color = color2

				if hitFunc then
					hitFunc(enemy, player, mult, rng, laser)
				end
			end
		end
	end
end

function mod:alternateElectrumShock(ent, rng, damage, pos, targets, color, hitFunc, mult, ignoreTargets, range) --eh this is messy but again who cares
	range = range or 200
	local enemies = {}
	for _, enemy in ipairs(Isaac.FindInRadius(pos, range, EntityPartition.ENEMY)) do
		if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
			local dont = false
			if ignoreTargets then
				for _,check in ipairs(ignoreTargets) do
					if check.InitSeed == enemy.InitSeed then
						dont = true
					end
				end
			end
			if dont then
			else
				table.insert(enemies, enemy)
			end
		end
	end
	if #enemies > 0 then
		if #enemies > targets then
			local chosen = mod:getSeveralDifferentNumbers(targets, #enemies, rng)
			local placeHolder = {}
			for i=1,#chosen do
				table.insert(placeHolder, enemies[chosen[i]])
			end
			enemies = placeHolder
		end
		for _, enemy in ipairs(enemies) do
			local angle = (enemy.Position-pos):GetAngleDegrees()
			local laser = EntityLaser.ShootAngle(2, pos, angle, 1, Vector.Zero, ent)
			laser.CollisionDamage = damage
			laser.MaxDistance = enemy.Position:Distance(pos)
			laser.DisableFollowParent = true
			laser.Color = color or eColor

			if hitFunc then
				hitFunc(enemy, ent, mult, rng, laser)
			end
		end
	end
end

function mod:electrumNewRoom(player, data)
	local sdata = data.ffsavedata.RunEffects
	local updateFlags = nil
	if sdata.electrumBelial then
		sdata.electrumBelial = nil
		updateFlags = true
	end
	data.electrumWavy = nil
	data.electrumPoop = nil

	if updateFlags then
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
end

function mod:electrumUpdate(player, data)
	local sdata = data.ffsavedata.RunEffects
	local room = game:GetRoom()
	if data.electrumPoop then
		for _,entry in ipairs(data.electrumPoop) do
			local gridEnt = room:GetGridEntity(entry.index)
			if gridEnt and gridEnt:ToPoop() then
				if gridEnt.State > entry.state then
					local enemies = {}
					for _, enemy in ipairs(Isaac.FindInRadius(gridEnt.Position, 200, EntityPartition.ENEMY)) do
						if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
							table.insert(enemies, enemy)
						end
					end
					if #enemies > 0 then
						if #enemies > 2 then
							local chosen = mod:getSeveralDifferentNumbers(2, #enemies, entry.rng)
							local placeHolder = {}
							for i=1,#chosen do
								table.insert(placeHolder, enemies[chosen[i]])
							end
							enemies = placeHolder
						end
						for _, enemy in ipairs(enemies) do
							local angle = (enemy.Position-gridEnt.Position):GetAngleDegrees()
							local laser = EntityLaser.ShootAngle(2, gridEnt.Position, angle, 1, Vector.Zero, player)
							laser.CollisionDamage = player.Damage*entry.mult
							laser.MaxDistance = enemy.Position:Distance(gridEnt.Position)
							laser.DisableFollowParent = true
							laser.Color = eColor
						end
					end
					entry.state = gridEnt.State
				end
			end
		end
	end

	if data.electrumShadows then
		local tempEffs = player:GetEffects()
		if tempEffs:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS) or tempEffs:HasCollectibleEffect(CollectibleType.COLLECTIBLE_UNICORN_STUMP) then
			--hi :)
		else
			player.Color = data.electrumShadows
			data.electrumShadows = nil
		end

		if not data.electrumShadowsTimer then
			data.electrumShadowsTimer = 0
		elseif data.electrumShadowsTimer > 0 then
			data.electrumShadowsTimer = data.electrumShadowsTimer-1
		end
	end

	if data.electrumUnicorn then
		local tempEffs = player:GetEffects()
		if tempEffs:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN) or tempEffs:HasCollectibleEffect(CollectibleType.COLLECTIBLE_GAMEKID) then
		else
			data.electrumUnicorn = nil
		end
	end

	if data.electrumAnarchist then
		data.electrumAnarchistTimer = (data.electrumAnarchistTimer or 0)+1
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ELECTRUM)
		for _, bomb in ipairs(Isaac.FindByType(4, 3, 0)) do
			if bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() and bomb.SpawnerEntity:GetData().electrumAnarchist then
				if bomb.FrameCount == 0 and data.electrumAnarchistTimer % 5 == 0 then
					bomb:GetData().electrumBomb = {player = player, damage = player.Damage*mult+3^eExponent, targets = 1, mult = mult}
					data.electrumLastAnarchistTimer = data.electrumAnarchistTimer
				end
			end
		end
		if data.electrumLastAnarchistTimer and data.electrumAnarchistTimer % 5 == 0 then
			if data.electrumLastAnarchistTimer < data.electrumAnarchistTimer and data.electrumLastAnarchistTimer + 5 ~= data.electrumAnarchistTimer then
				data.electrumAnarchist = nil
				data.electrumAnarchistTimer = nil
				data.electrumLastAnarchistTimer = nil
			end
		end
	end

	if player:HasTrinket(FiendFolio.ITEM.ROCK.ELECTRUM) then --thrown actives and actives that only work while held
		local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ELECTRUM)
		if data.justThrewActive and player.FrameCount-data.justThrewActiveFrames == 0 then
			local itemConfig = Isaac:GetItemConfig():GetCollectible(data.justThrewActive)
			local rng = player:GetCollectibleRNG(data.justThrewActive)
			if data.justThrewActive == CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD then
				mod:electrumShock(player, mult, rng, itemConfig)

				for _,head in ipairs(Isaac.FindByType(2, 4, -1, false, false)) do
					if head.Position:Distance(player.Position) < 20 and head.FrameCount < 2 then
						head:GetData().electrumBob = {player = player, mult = mult, rng = rng, damage = player.Damage*mult+2^eExponent}
					end
				end
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP then
				mod:electrumShock(player, mult, rng, itemConfig)

				for _,laser in ipairs(Isaac.FindByType(7, 3, -1, false, false)) do
					laser.Color = eColor
					laser.CollisionDamage = laser.CollisionDamage+player.Damage
				end
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_CANDLE then
				local hitFunc = function(enemy, p, m, r, laser)
					enemy:GetData().electrumDeath = function()
						local fire = Isaac.Spawn(1000, 10, 0, enemy.Position, Vector.Zero, player):ToEffect()
						fire.CollisionDamage = laser.CollisionDamage*2
						fire:SetTimeout(60)
					end
				end
				mod:electrumShock(player, mult, rng, itemConfig, true, hitFunc)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_RED_CANDLE then
				local hitFunc = function(enemy, p, m, r, laser)
					enemy:GetData().electrumDeath = function()
						local fire = Isaac.Spawn(1000, 52, 0, enemy.Position, Vector.Zero, player):ToEffect()
						fire.CollisionDamage = laser.CollisionDamage*2
						fire:SetTimeout(300)
					end
				end
				mod:electrumShock(player, mult, rng, itemConfig, true, hitFunc)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_BOOMERANG then
				for _,boomerang in ipairs(Isaac.FindByType(1000, 60, -1, false, false)) do
					if boomerang.FrameCount < 2 then
						boomerang:GetData().electrumBoomerang = {player = player, damage = player.Damage*mult, rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOOMERANG)}
					end
				end
				mod:electrumShock(player, mult, rng, itemConfig, true)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_GLASS_CANNON then
				mod:alternateElectrumShock(player, rng, player.Damage*3+10, player.Position, 2)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_FRIEND_BALL then
				for _,ball in ipairs(Isaac.FindByType(1000, 81, -1, false, false)) do
					if ball.FrameCount < 2 then
						ball:GetData().electrumBall = {player = player, damage = player.Damage*mult, rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_FRIEND_BALL)}
					end
				end
				mod:electrumShock(player, mult, rng, itemConfig)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_BLACK_HOLE then
				for _,hole in ipairs(Isaac.FindByType(1000, 107)) do
					if hole.FrameCount < 2 then
						hole:GetData().electrumHole = {player = player, damage = player.Damage*mult, rng = rng}
					end
				end
				mod:electrumShock(player, mult, rng, itemConfig)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_SHARP_KEY then
				local hf = function(enemy, p, m, r)
					enemy:GetData().electrumDeath = function()
						if r:RandomInt(6) == 0 then
							Isaac.Spawn(5, 30, 1, enemy.Position, RandomVector(), p)
						end
					end
				end
				mod:alternateElectrumShock(player, rng, player.Damage*mult*2+20, player.Position, 2, nil, hf)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_ERASER then
				local hf = function(enemy, p, m, r)
					local tear = Isaac.Spawn(2, 45, 0,enemy.Position, Vector.Zero, player):ToTear()
                    tear.Visible = false
                    tear:Update()
                    sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
                    mod.scheduleForUpdate(function()
                        sfx:Stop(SoundEffect.SOUND_PLOP)
                    end, 1)
				end
				mod:alternateElectrumShock(player, rng, player.Damage*mult+20, player.Position, 1, nil, hf)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_GELLO then
				mod.scheduleForUpdate(function()
					for _,BABY in ipairs(Isaac.FindByType(3, FamiliarVariant.UMBILICAL_BABY, -1, false, false)) do
						if BABY.FrameCount < 2 then
							BABY:GetData().electrumGello = player.Damage*mult+2^eExponent
						end
					end
				end, 0)
				mod:electrumShock(player, mult, rng, itemConfig)
			elseif data.justThrewActive == CollectibleType.COLLECTIBLE_DECAP_ATTACK then
				for _,head in ipairs(Isaac.FindByType(3, FamiliarVariant.DECAP_ATTACK, -1, false, false)) do
					if head.FrameCount < 2 then
						head:GetData().electrumDecap = {player = player, damage = player.Damage*mult, rng = rng}
					end
				end
				mod:electrumShock(player, mult, rng, itemConfig)
			elseif data.justThrewActive == mod.ITEM.COLLECTIBLE.D2 then
				local hf = function(enemy, p, m, r)
					enemy:GetData().electrumDeath = function()
						if r:RandomInt(3) == 0 then
							Isaac.Spawn(5, 300, mod.ITEM.CARD.GLASS_D2, enemy.Position, RandomVector(), p)
						end
					end
				end

				mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
			else
				mod:electrumShock(player, mult, rng, itemConfig)
			end
		end

		if data.overheadActiveItemID == CollectibleType.COLLECTIBLE_NOTCHED_AXE then
			local slot = mod:findActiveSlot(CollectibleType.COLLECTIBLE_NOTCHED_AXE, player)
			if not data.electrumMikuAxe then
				data.electrumMikuAxe = player:GetActiveCharge(slot)
			end
			if player:GetActiveCharge(slot) < data.electrumMikuAxe then
				local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NOTCHED_AXE)
				data.electrumMikuAxe = player:GetActiveCharge(slot)
				mod:alternateElectrumShock(player, rng, player.Damage*mult, player.Position, 1)
			end
		end

		if data.electrumTeleport then
			local sprite = player:GetSprite()
			if sprite:IsFinished("TeleportDown") then
				local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ELECTRUM)
				local itemConfig = Isaac:GetItemConfig():GetCollectible(data.electrumTeleport == 1 and CollectibleType.COLLECTIBLE_TELEPORT_2 or CollectibleType.COLLECTIBLE_TELEPORT)
				local hitFunc = function(enemy, p, m, r, laser)
					--laser:AddTearFlags(TearFlags.TEAR_TELEPORT) it can't just be simple, can it
					local tear = Isaac.Spawn(2, 40, 0, enemy.Position, Vector.Zero, p):ToTear()
					tear.CollisionDamage = laser.CollisionDamage
					tear.Color = Color(1,1,1,0,0,0,0)
					tear:AddTearFlags(TearFlags.TEAR_TELEPORT)
					tear:Update()
				end
				mod:electrumShock(player, mult, rng, itemConfig, nil, hitFunc)
				data.electrumTeleport = nil
			end
		elseif data.electrumPony then
			local tempEffs = player:GetEffects()
			if tempEffs:HasCollectibleEffect(CollectibleType.COLLECTIBLE_PONY) then
			else
				data.electrumPony = nil
				local itemConfig = Isaac:GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_PONY)
				local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PONY)
				mod:electrumShock(player, mult, rng, itemConfig)
			end
		elseif data.electrumWhitePony then
			local tempEffs = player:GetEffects()
			if tempEffs:HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHITE_PONY) then
			else
				data.electrumWhitePony = nil
				local itemConfig = Isaac:GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_WHITE_PONY)
				local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_WHITE_PONY)
				local hf = function(enemy, p, m, r)
					local beam = Isaac.Spawn(1000, 19, 0, enemy.Position, Vector.Zero, p):ToEffect()
					beam.Parent = p
					beam.CollisionDamage = p.Damage*mult
				end
				mod:electrumShock(player, mult, rng, itemConfig, nil, hf)
			end
		elseif data.electrumJump then
			local sprite = player:GetSprite()
			if not sprite:IsPlaying("Jump") then
				local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HOW_TO_JUMP)
				mod:alternateElectrumShock(player, rng, player.Damage*mult, player.Position, 1)
				data.electrumJump = nil
			end
		elseif data.electrumSuplex then
			local sprite = player:GetSprite()
			if sprite:IsPlaying("LeapDown") then
				if sprite:IsEventTriggered("Poof") then
					data.electrumSuplex = nil
					mod:alternateElectrumShock(player, player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SUPLEX), player.Damage*mult+10, player.Position, 3)
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, explosion)
	if explosion.SpawnerEntity and explosion.SpawnerEntity:GetData().electrumBomb then
		local bomb = explosion.SpawnerEntity
		local data = bomb:GetData()
		local rng = bomb:GetDropRNG()

		if not data.electrumBomb.player or not data.electrumBomb.player:Exists() then
			data.electrumBomb.player = bomb
		end

		local enemies = {}
		for _, enemy in ipairs(Isaac.FindInRadius(explosion.Position, 200, EntityPartition.ENEMY)) do
			if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
				table.insert(enemies, enemy)
			end
		end
		if #enemies > 0 then
			if #enemies > data.electrumBomb.targets then
				local chosen = mod:getSeveralDifferentNumbers(data.electrumBomb.targets, #enemies, rng)
				local placeHolder = {}
				for i=1,#chosen do
					table.insert(placeHolder, enemies[chosen[i]])
				end
				enemies = placeHolder
			end
			for _, enemy in ipairs(enemies) do
				local angle = (enemy.Position-explosion.Position):GetAngleDegrees()
				local laser = EntityLaser.ShootAngle(2, explosion.Position, angle, 1, Vector.Zero, data.electrumBomb.player)
				laser.CollisionDamage = data.electrumBomb.damage*data.electrumBomb.mult+2^eExponent
				laser.MaxDistance = enemy.Position:Distance(explosion.Position)
				laser.DisableFollowParent = true
				laser.Color = eColor
			end
		end
	end
end, EffectVariant.BOMB_EXPLOSION)

function mod:electrumTearRemove(tear, data)
	if data.electrumBob then
		local entry = data.electrumBob
		if not entry.player or not entry.player:Exists() then
			entry.player = tear
		end

		local hitFunc = function(enemy, player, mult, rng, laser)
			enemy:AddPoison(EntityRef(entry.player), 70, entry.damage)
		end

		local color = Color(0,0.95,0,1,0.3,0.93,0.14)
		color:SetColorize(0.2,1,0.4,0.55)
		mod:alternateElectrumShock(entry.player, entry.rng, entry.damage, tear.Position, 2, color, hitFunc)
	end
end

function mod:electrumNPCUpdate(npc)
	local data = npc:GetData()
	if data.electrumDeath ~= nil then
		if npc:IsDead() or mod:isLeavingStatusCorpse(npc) then
			data.electrumDeath(npc)
			data.electrumDeath = nil
		end

		data.electrumDeathLeniency = (data.electrumDeathLeniency or 0)+1
		if data.electrumDeathLeniency > 3 then
			data.electrumDeath = nil
			data.electrumDeathLeniency = nil
		end
	end
	
end

function mod:electrumRender(npc, data)
	if data.electrumRender then
		local stilldoingstuff = false
		if data.refreezePetrify then
			stilldoingstuff = true
			if not npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) then --okay nevermind I guess it still flickers when wearing off
				if not data.electrumPlayer or not data.electrumPlayer:Exists() then
					data.electrumPlayer = nil
				end
				npc:AddFreeze(EntityRef(data.electrumPlayer), data.refreezePetrify)
				data.refreezePetrify = nil
			end
		end
		if data.refear then
			stilldoingstuff = true
			if not npc:HasEntityFlags(EntityFlag.FLAG_FEAR) then
				if not data.electrumPlayer or not data.electrumPlayer:Exists() then
					data.electrumPlayer = nil
				end
				npc:AddFear(EntityRef(data.electrumPlayer), data.refear)
				data.refear = nil
			end
		end

		if not stilldoingstuff then
			data.electrumRender = nil
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ent) --for doctor's remote
	if ent.Variant ~= EffectVariant.ROCKET then return end

	local data = ent:GetData()
	if data.electrumRemote then
		local entry = data.electrumRemote
		if not entry.player or not entry.player:Exists() then
			entry.player = ent
		end
		mod:alternateElectrumShock(entry.player, entry.rng, entry.damage, ent.Position, 3)
	end
end, 1000)

function mod:electrumCollision(player, collider, low)
	if player:GetData().electrumShadows then
		if collider and collider:ToNPC() and not mod:isFriend(collider) and (player:GetData().electrumShadowsTimer or 0) <= 0 then
			collider:TakeDamage(player.Damage*2, 0, EntityRef(player), 0)
			sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK, 1, 0, false, math.random(120,140)/100)
			player:GetData().electrumShadowsTimer = 18
		end
	end
	if player:GetData().electrumUnicorn then
		if collider and collider:ToNPC() and not mod:isFriend(collider) then
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ELECTRUM)
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ELECTRUM)
			collider:GetData().electrumDeath = function()
				mod:alternateElectrumShock(player, rng, player.Damage*mult, player.Position, 2, nil, nil, nil, {collider})
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
	local data = e:GetData()

	if data.electrumMonstro then
		if e.FrameCount > 33 then
			local entry = data.electrumMonstro
			if not entry.player or not entry.player:Exists() then
				entry.player = e
			end
			mod:alternateElectrumShock(entry.player, entry.rng, entry.damage, e.Position, 3)
			data.electrumMonstro = nil
		end
	end
end, EffectVariant.MONSTROS_TOOTH)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, e)
	local data = e:GetData()

	if data.electrumShears then
		if e.FrameCount % 66 == 0 then
			local entry = data.electrumShears
			if not entry.player or not entry.player:Exists() then
				entry.player = e
			end
			mod:alternateElectrumShock(entry.player, entry.rng, entry.damage, e.Position, 1)
		end
	end
end, FamiliarVariant.ISAACS_BODY)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
	local data = bomb:GetData()
	if data.electrumBestFriend then
		if bomb.FrameCount % 27 == 5 then
			local entry = data.electrumBestFriend

			if not entry.player or not entry.player:Exists() then
				entry.player = bomb
			end
			mod:alternateElectrumShock(entry.player, entry.rng, entry.damage, bomb.Position, 2)
		end
	end
end, 2)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, e)
	local data = e:GetData()

	if data.electrumScissors then
		if e.FrameCount % 66 == 0 then
			local entry = data.electrumScissors
			if not entry.player or not entry.player:Exists() then
				entry.player = e
			end
			mod:alternateElectrumShock(entry.player, entry.rng, entry.damage, e.Position, 4)
		end
	end
end, FamiliarVariant.SCISSORS)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, e)
	if e.Variant == 60 then --Boomerang
		local data = e:GetData()
		if data.electrumBoomerang then
			local entry = data.electrumBoomerang
			if not entry.player or not entry.player:Exists() then
				entry.player = e
			end
			mod:alternateElectrumShock(entry.player, entry.rng, entry.damage, e.Position, 1)
		end
	elseif e.Variant == 81 then --Friendly Ball
		local data = e:GetData()
		if data.electrumBall then
			mod.scheduleForUpdate(function()
				for _,ent1 in ipairs(Isaac.FindInRadius(e.Position, 40, EntityPartition.ENEMY)) do
					local ent = ent1:ToNPC()
					if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY_BALL) then
						if ent.FrameCount < 2 then
							local damg = data.electrumBall.damage
							for k = 0, 120, 5 do
								mod.scheduleForUpdate(function()
									if ent and ent:Exists() then
										local laser = EntityLaser.ShootAngle(2, ent.Position, data.electrumBall.rng:RandomInt(360), 2, Vector(0, -10), Isaac.GetPlayer())
										laser.Parent = ent
										laser.CollisionDamage = damg
										laser.MaxDistance = ent.Size + mod:getRoll(50, 100, data.electrumBall.rng)
										laser.Color = eColor
										laser:Update()
									end
								end, k)
							end
						end
					end
				end
			end, 1)
		end
	end
end, 1000)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
	local data = e:GetData()
	if data.electrumVentricle then
		local entry = data.electrumVentricle
		if not entry.player or not entry.player:Exists() then
			entry.player = e
		end
		if e.State == 4 then
			if not data.electrumVentricleZapped then
				mod:alternateElectrumShock(data.electrumVentricle.player, entry.rng, entry.damage, e.Position, 2)
				data.electrumVentricleZapped = true
			end
		elseif data.electrumVentricleZapped then
			data.electrumVentricleZapped = nil
		end
	end
end, EffectVariant.WOMB_TELEPORT)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local data = fam:GetData()
	if data.electrumNugget then
		local sprite = fam:GetSprite()
		local entry = data.electrumNugget
		if sprite:IsPlaying("Attack") and not data.electrumNuggetFired then
			data.electrumNuggetFired = true
			for _,shot in ipairs(Isaac.FindByType(2, -1, -1, false, false)) do
				if shot.SpawnerEntity and shot.SpawnerEntity.InitSeed == fam.InitSeed then
					shot:Remove()
					local hf = function(enemy, p, m, r, laser)
						laser.PositionOffset = Vector(0,-20)
					end
					mod:alternateElectrumShock(fam, fam:GetDropRNG(), entry.damage, fam.Position, 1, nil, hf)
					--[[local ang = (fam.TargetPosition-fam.Position):GetAngleDegrees()
					local laser = EntityLaser.ShootAngle(2, fam.Position, ang, 1, Vector(0, -10), fam.Player)
					laser.Parent = fam
					laser.CollisionDamage = entry.damage
					laser.MaxDistance = (fam.TargetPosition):Distance(fam.Position)
					laser.Color = eColor
					laser:Update()]]
				end
			end
		elseif not sprite:IsPlaying("Attack") then
			data.electrumNuggetFired = nil
		end
	end
end, FamiliarVariant.BROWN_NUGGET_POOTER)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
	local data = e:GetData()
	if data.electrumHole then
		if e.State == 1 then
			data.electrumHoleCount = (data.electrumHoleCount or 0)+1
			if data.electrumHoleCount % 7 == 0 then
				local laser = EntityLaser.ShootAngle(2, e.Position, data.electrumHole.rng:RandomInt(360), 2, Vector(0, -10), Isaac.GetPlayer())
				laser.Parent = e
				laser.CollisionDamage = data.electrumHole.damage
				laser.MaxDistance = mod:getRoll(50, 100, data.electrumHole.rng)
				laser.Color = eColor
				laser:Update()
			end
		end
	end
end, EffectVariant.BLACK_HOLE)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, sp)
	local data = sp:GetData()
	if data.electrumSprinkler then
		if sp.FrameCount % 20 == 0 then
			mod:alternateElectrumShock(sp, sp:GetDropRNG(), data.electrumSprinkler.damage, sp.Position, 1)
		end
	end
end, FamiliarVariant.SPRINKLER)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if npc.Variant ~= 1 then return end
	local data = npc:GetData()
	if data.electrumMineCrafter then
		if npc.State == 16 then
			local entry = data.electrumMineCrafter
			if not entry.player or not entry.player:Exists() then
				entry.player = npc
			end
			mod:alternateElectrumShock(entry.player, entry.rng, entry.damage, npc.Position, 2)
			data.electrumMineCrafter = nil
		end
	end
end, EntityType.ENTITY_MOVABLE_TNT)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local data = fam:GetData()
	if data.electrumScooper and fam.FrameCount % 40 == 0 then
		local entry = data.electrumScooper
		if not entry.player or not entry.player:Exists() then
			entry.player = fam.Player or fam
		end
		local laser = EntityLaser.ShootAngle(2, fam.Position, (entry.player.Position-fam.Position):GetAngleDegrees(), 1, Vector(0, -30), Isaac.GetPlayer())
		laser.Parent = fam
		laser.CollisionDamage = data.electrumScooper.damage
		laser.MaxDistance = fam.Position:Distance(entry.player.Position)
		laser.Color = eColor
		laser.DisableFollowParent = true
		laser:Update()
	end
end, FamiliarVariant.PEEPER_2)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
	if tear.SpawnerEntity then
		if tear.SpawnerEntity.Type == 3 and tear.SpawnerEntity.Variant == FamiliarVariant.BABY_PLUM and tear.SpawnerEntity:GetData().electrumPlum then
			local entry = tear.SpawnerEntity:GetData().electrumPlum

			local pos = tear.Position+tear.Velocity:Resized(6)
			local laser = EntityLaser.ShootAngle(2, tear.SpawnerEntity.Position, (pos-tear.SpawnerEntity.Position):GetAngleDegrees(), 1, Vector(0, -20), Isaac.GetPlayer())
			laser.Parent = tear.SpawnerEntity
			laser.CollisionDamage = entry.damage
			laser.Color = eColor
			laser.DisableFollowParent = true
			laser:Update()
			tear:Remove()
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	if fam.Player and fam.Player:ToPlayer():HasTrinket(FiendFolio.ITEM.ROCK.ELECTRUM) then
		local mult = mod.GetGolemTrinketPower(fam.Player:ToPlayer(), FiendFolio.ITEM.ROCK.ELECTRUM)
		local sprite = fam:GetSprite()
		if sprite:GetAnimation() == "Spin" then
			if fam.FrameCount % 10 == 0 then
				mod:alternateElectrumShock(fam.Player, fam:GetDropRNG(), fam.Player:ToPlayer().Damage*mult, fam.Position, 2, nil, nil, nil, nil, 120)
			end
		end
	end
end, FamiliarVariant.SPIN_TO_WIN)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local data = fam:GetData()
	if data.electrumAbyss then
		if fam.EntityCollisionClass == 4 then
			data.electrumAbyssPrimed = true
		elseif data.electrumAbyssPrimed then
			local entry = data.electrumAbyss
			data.electrumAbyssPrimed = nil
			mod:alternateElectrumShock(fam.Player, fam:GetDropRNG(), entry.damage, fam.Position, 2)
		end
	end
end, FamiliarVariant.ABYSS_LOCUST)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local data = fam:GetData()
	if data.electrumGello and fam.FrameCount % 40 == 0 then
		mod:alternateElectrumShock(fam.Player, fam:GetDropRNG(), data.electrumGello, fam.Position, 2)
	end
end, FamiliarVariant.UMBILICAL_BABY)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local data = fam:GetData()
	if data.electrumDecap then
		if fam.State > 0 then
			mod:alternateElectrumShock(fam.Player, fam:GetDropRNG(), data.electrumDecap.damage, fam.Position, 2)
			data.electrumDecap = nil
		end
	end
end, FamiliarVariant.DECAP_ATTACK)