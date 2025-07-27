local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

--some code taken from sapphic sapphire to tie them together better :)) gaye

function mod:homoeroticRubyOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.HOMOEROTIC_RUBY) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local chance = math.min(10+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			--[[tear.TearFlags = tear.TearFlags | TearFlags.TEAR_BURN
            local color = Color(1, 1, 1, 1, 0.25, 0, 0)
		    color:SetColorize(1, 0.3, 0.1, 1)
			tear.Color = color
			tear:Update()]]

			tear:ChangeVariant(5)
			local td = tear:GetData()
			td.ApplyBurn = true
			td.ApplyBurnDuration = 60*secondHandMultiplier
			td.ApplyBurnDamage = player.Damage
			tear:Update()
		end
	end
end

function mod:homoeroticRubyOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.HOMOEROTIC_RUBY) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local chance = math.min(10+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			entity:AddBurn(EntityRef(player), 120*secondHandMultiplier, player.Damage*2)
		end
	end
end

function mod:homoeroticRubyOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.HOMOEROTIC_RUBY) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local chance = math.min(10+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			bomb.Flags = bomb.Flags | TearFlags.TEAR_BURN
			
			local color = Color(1, 1, 1, 1, 0.25, 0, 0)
		    color:SetColorize(1, 0.3, 0.1, 1)
			bomb.Color = color
		end
	end
end

function mod:homoeroticRubyOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.HOMOEROTIC_RUBY) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local chance = math.min(10+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			entity:AddBurn(EntityRef(player), 120*secondHandMultiplier, player.Damage*2)
		end
	end
end

function mod:homoeroticRubyOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.HOMOEROTIC_RUBY) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local chance = math.min(10+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			local data = creep:GetData()
			data.ApplyBurn = true
			data.ApplyBurnDuration = 120 * secondHandMultiplier
            data.ApplyBurnDamage = player.Damage*2

            local color = Color(1, 1, 1, 1, 0.25, 0, 0)
		    color:SetColorize(1, 0.3, 0.1, 1)
			data.FFAquariusColor = color
		end
	end
end

function mod:homoeroticRubyOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.HOMOEROTIC_RUBY) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local chance = math.min(10+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			local data = target:GetData()
			data.ApplyBurn = true
			data.ApplyBurnDuration = 120 * secondHandMultiplier
            data.ApplyBurnDamage = player.Damage*2

            local color = Color(1, 1, 1, 1, 0.25, 0, 0)
		    color:SetColorize(1, 0.3, 0.1, 1)
			data.FFExplosionColor = color
		end
	end
end

function mod:homoeroticRubyOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasTrinket(mod.ITEM.ROCK.HOMOEROTIC_RUBY) then
		local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local rng = player:GetTrinketRNG(mod.ITEM.ROCK.HOMOEROTIC_RUBY)
		local chance = math.min(10+player.Luck+5*mult, 50)
        if rng:RandomInt(100) < chance then
			entity:AddFear(EntityRef(player), 180 * secondHandMultiplier)
		end
	end
end

function mod:burnOnApply(entity, source, data)
	if data.ApplyBurn then
        entity:AddBurn(EntityRef(source.Entity.SpawnerEntity or source.Entity), data.ApplyBurnDuration, data.ApplyBurnDamage)
	end
end

function mod:homoeroticRubyWomen(npc)
    if not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and (mod.anyPlayerHas(mod.ITEM.ROCK.HOMOEROTIC_RUBY, true) or mod.anyPlayerHas(mod.ITEM.ROCK.GAY_GARNET, true)) then
        local d = npc:GetData()
        local rng = npc:GetDropRNG()
        if not d.homoeroticRubyTimer then
            d.homoeroticRubyTimer = rng:RandomInt(50)
        else
            d.homoeroticRubyTimer = d.homoeroticRubyTimer+1
        end

        if d.homoeroticRubyTimer % 90 == 0 and not d.FFBerserkDuration then
			for j = 1, game:GetNumPlayers() do
				local p = Isaac.GetPlayer(j - 1)
				local mult = 0
				local secondHand = p:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
				local proceed
				local chance = 5
				if p:HasTrinket(mod.ITEM.ROCK.HOMOEROTIC_RUBY) then
					mult = mod.GetGolemTrinketPower(p, mod.ITEM.ROCK.HOMOEROTIC_RUBY)
					chance = chance + 5*mult
					proceed = true
				end
				if p:HasTrinket(mod.ITEM.ROCK.GAY_GARNET) then
					mult = mult + mod.GetGolemTrinketPower(p, mod.ITEM.ROCK.GAY_GARNET)
					chance = chance + 5*mult + 10
					proceed = true
				end
				
				if proceed then
					chance = math.min(30, chance)
					if rng:RandomInt(100) < chance then
						local isWoman
						for i = 1, #mod.Nonmale do
							if mod.Nonmale[i].ID
							and (npc.Type == mod.Nonmale[i].ID[1]) 
							and ((not mod.Nonmale[i].ID[2]) or npc.Variant == mod.Nonmale[i].ID[2]) 
							and ((not mod.Nonmale[i].ID[3]) or npc.SubType == mod.Nonmale[i].ID[3]) 
							and mod.Nonmale[i].Affliction == "Woman"
							then
								isWoman = true
								break
							end
						end

						if isWoman then
							mod.AddBerserk(npc, p, 200*secondHand)

							if mod.WomanMode > 0 then
								sfx:Stop(mod.Sounds.WomanRevealer)
								sfx:Play(mod.Sounds.WomanRevealer, 4, 0, false, 1)
								mod:ShowFortune("Woman", true)
								game:GetHUD():ShowItemText("Woman", "This is a woman")
								local e = Isaac.Spawn(mod.FF.WomanIndicator.ID, mod.FF.WomanIndicator.Var, mod.FF.WomanIndicator.Sub, npc.Position, Vector.Zero, p):ToEffect()
								e.SpriteOffset = Vector(0, -30 + npc.Size * -1.0)
								e:FollowParent(npc)
								e.DepthOffset = 20
							end
							break
						end
					end
				end
            end
        end
    end
end

local function findClosestAvailableSapphire(pos)
	local holdDist = 99999
	local found
	for _,t in ipairs(Isaac.FindByType(5, 350, -1)) do
		if mod:GetRealTrinketId(t.SubType) == mod.ITEM.ROCK.SAPPHIC_SAPPHIRE then
			local dist = t.Position:Distance(pos)
			if dist < holdDist and not t:GetData().gemFusionPartner then
				found = t
				holdDist = dist
			end
		end
	end
	return found
end

function mod:homoeroticRubyTrinketUpdate(trinket)
	if mod:GetRealTrinketId(trinket.SubType) == mod.ITEM.ROCK.HOMOEROTIC_RUBY then
		local d = trinket:GetData()
		if not d.init then
			d.state = "searching"
			d.stateFrame = 0
			d.init = true
		else
			d.stateFrame = d.stateFrame+1
		end

		local sapphire = findClosestAvailableSapphire(trinket.Position)
		if sapphire and sapphire:Exists() or (d.gemFusionPartner and d.gemFusionPartner:Exists()) then
			local rng = trinket:GetDropRNG()
			d.gemFusionIncomplete = true
			d.gemFusionPartner = d.gemFusionPartner or sapphire
			local sd = d.gemFusionPartner:GetData()
			sd.gemFusionPartner = trinket
			sd.gemFusionIncomplete = true
			local vec = (d.gemFusionPartner.Position-trinket.Position)
			if d.state == "searching" then
				local dist = d.gemFusionPartner.Position:Distance(trinket.Position)
				d.gemFusionPartner.Velocity = mod:Lerp(d.gemFusionPartner.Velocity, vec:Resized(-2), 0.3)
				trinket.Velocity = mod:Lerp(trinket.Velocity, vec:Resized(2), 0.3)

				local oVal = 70/dist
				d.gemFusionPartner.Color = Color(1, 1, 1, 1, oVal, oVal, oVal)
				trinket.Color = Color(1, 1, 1, 1, oVal, oVal, oVal)

				if dist < 70 then
					sd.state = "danceiguess"
					d.state = "danceiguess"
					sfx:Play(mod.Sounds.StevenUniverseFusion, 1, 0, false, 1)
					trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
					d.gemFusionPartner.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
					d.stateFrame = 0
					d.speed = 3
					d.gemFusionPartner.Color = Color(1, 1, 1, 1, 1, 1, 1)
				trinket.Color = Color(1, 1, 1, 1, 1, 1, 1)
				end
			elseif d.state == "danceiguess" then
				--sapphire.Velocity = mod:Lerp(sapphire.Velocity, vec:Resized(-d.speed):Rotated(90), 0.3)
				--trinket.Velocity = mod:Lerp(trinket.Velocity, vec:Resized(d.speed):Rotated(90), 0.3)
				d.gemFusionPartner.Velocity = vec:Resized(-d.speed):Rotated(90)+vec:Resized(-d.speed/3)
				trinket.Velocity = vec:Resized(d.speed):Rotated(90)+vec:Resized(d.speed/3)
				d.speed = d.speed+0.8
				if trinket.FrameCount % 2 == 0 then
					for i=0,1 do
						local color = Color(0.6, 0.6, 0.6, 1, 1.3, 0, 0)
						local host = trinket
						if i == 0 then
							color = Color(0.6, 0.6, 0.6, 1, 0, 0, 1.3)
							host = d.gemFusionPartner
						end
						local sparkle = Isaac.Spawn(1000, 1727, 0, host.Position+mod:shuntedPosition(10, rng), Vector.Zero, host):ToEffect()
						sparkle.SpriteOffset = Vector(0,-7)
						local scale = mod:getRoll(6, 10, rng)/10
						sparkle.SpriteScale = Vector(scale, scale)
						sparkle:SetColor(color, 100, 1, false, false)
						sparkle:Update()
					end
				end

				if d.stateFrame > 52 then
					sd.state = "merging"
					d.state = "merging"
					for j=0,1 do
						local color = Color(0.6, 0.6, 0.6, 1, 1.3, 0, 0)
						local host = trinket
						if j == 0 then
							color = Color(0.6, 0.6, 0.6, 1, 0, 0, 1.3)
							host = d.gemFusionPartner
						end
						for i = 30, 360, 30 do
							local vec2 = Vector(0,3):Rotated(i)
							local sparkle = Isaac.Spawn(1000, 1727, 0, host.Position + vec2:Resized(20), vec2, host):ToEffect()
							sparkle:SetColor(color, 100, 1, false, false)
							sparkle.SpriteOffset = Vector(0,-27)
							sparkle:Update()
						end
					end
					d.mergeAngle = 90
				end
			elseif d.state == "merging" then
				local dist = d.gemFusionPartner.Position:Distance(trinket.Position)
				for i=0,1 do
					local color = Color(0.6, 0.6, 0.6, 1, 1.3, 0, 0)
					local afterColor = Color(1, 0.6, 0.6, 0.7, 1.7, 1, 1)
					local host = trinket
					local spritesheet = "gfx/items/trinkets/golem/trinket_homoerotic_ruby.png"
					if i == 0 then
						color = Color(0.6, 0.6, 0.6, 1, 0, 0, 1.3)
						afterColor = Color(0.6, 0.6, 1, 0.7, 1, 1, 1.7)
						host = d.gemFusionPartner
						spritesheet = "gfx/items/trinkets/golem/trinket_sapphic_sapphire.png"
					end
					local sparkle = Isaac.Spawn(1000, 1727, 0, host.Position+mod:shuntedPosition(10, rng), Vector.Zero, host):ToEffect()
					sparkle.SpriteOffset = Vector(0,-7)
					local scale = mod:getRoll(6, 10, rng)/10
					sparkle.SpriteScale = Vector(scale, scale)
					sparkle:SetColor(color, 100, 1, false, false)
					sparkle:Update()
					local sprite = host:GetSprite()
					local afterimage = Isaac.Spawn(mod.FF.GenericAfterimage.ID, mod.FF.GenericAfterimage.Var, mod.FF.GenericAfterimage.Sub, host.Position, Vector.Zero, host):ToEffect()
					afterimage:GetData().customAfterimageData = {
						timeout = 15, color = afterColor, fade = true, sprite = sprite,
						spritesheet = {{num = 0, file = spritesheet}}
					}
					afterimage.Parent = host
					afterimage:Update()
				end

				if dist > 40 then
					if d.mergeAngle > 0 then
						d.mergeAngle = d.mergeAngle-1
					end
					if d.speed > 17 then
						d.speed = d.speed-1
					end
					d.gemFusionPartner.Velocity = vec:Resized(-d.speed):Rotated(d.mergeAngle)+vec:Resized(-d.speed/2)
					trinket.Velocity = vec:Resized(d.speed):Rotated(d.mergeAngle)+vec:Resized(d.speed/2)
				else
					d.gemFusionPartner.Velocity = vec:Resized(-d.speed)
					trinket.Velocity = vec:Resized(d.speed)
				end
			end
		elseif d.gemFusionIncomplete then
			d.state = "searching"
			trinket.Color = Color(1,1,1,1,0,0,0)
			d.gemFusionPartner = nil
			trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			if sfx:IsPlaying(mod.Sounds.StevenUniverseFusion) then
				sfx:Stop(mod.Sounds.StevenUniverseFusion)
			end
		end
	end

	if mod:GetRealTrinketId(trinket.SubType) == mod.ITEM.ROCK.SAPPHIC_SAPPHIRE then
		local d = trinket:GetData()
		if d.gemFusionPartner then
			local d2 = d.gemFusionPartner:GetData()
			if not d.gemFusionPartner:Exists() or not d2.gemFusionPartner or d2.gemFusionPartner.InitSeed ~= trinket.InitSeed then
				d.state = "searching"
				trinket.Color = Color(1,1,1,1,0,0,0)
				d.gemFusionPartner = nil
				d.gemFusionIncomplete = nil
				trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				if sfx:IsPlaying(mod.Sounds.StevenUniverseFusion) then
					sfx:Stop(mod.Sounds.StevenUniverseFusion)
				end
			end
		end
	end
end

--edited from Middle Hand, ty erfly
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
    if collider.Type == 5 and collider.Variant == 350 then
        if mod:GetRealTrinketId(pickup.SubType) == mod.ITEM.ROCK.HOMOEROTIC_RUBY and mod:GetRealTrinketId(collider.SubType) == mod.ITEM.ROCK.SAPPHIC_SAPPHIRE then
			local d = pickup:GetData()
			if d.state and d.state == "merging" then
				local pos = mod:Lerp(pickup.Position, collider.Position, 0.5)
				pickup:Remove()
				collider:Remove()
				local flash = Isaac.Spawn(1000,1726, 0, pos, Vector.Zero, nil)
				flash:Update()
				local addedTrinket = mod.ITEM.ROCK.GAY_GARNET
				if mod:IsGoldTrinket(pickup.SubType) or mod:IsGoldTrinket(collider.SubType) then
					addedTrinket = addedTrinket + TrinketType.TRINKET_GOLDEN_FLAG
				end
				local gaygarnet = Isaac.Spawn(5, 350, addedTrinket, pos, Vector.Zero, nil)
				mod.scheduleForUpdate(function()
					for i = 30, 360, 30 do
						local vec = Vector(0,3):Rotated(i)
						local sparkle = Isaac.Spawn(1000, 1727, 0, gaygarnet.Position + vec:Resized(20), vec, nil):ToEffect()
						--sparkle.SpriteOffset = Vector(0,-27)
						sparkle:SetColor(Color(0.6, 0.6, 0.6, 1, 1, 0.4, 0.2), 100, 1, false, false)
						sparkle:Update()
					end
				end, 8)
			end
        end
    elseif collider.Type == 1 then
		if mod:GetRealTrinketId(pickup.SubType) == mod.ITEM.ROCK.HOMOEROTIC_RUBY or mod:GetRealTrinketId(pickup.SubType) == mod.ITEM.ROCK.SAPPHIC_SAPPHIRE then
			local d = pickup:GetData()
			if d.state and (d.state == "merging" or d.state == "danceiguess") then
				return true
			end
		end
	end
end, 350)

function mod:genericAfterimageEffect(e)
	local sprite = e:GetSprite()
	local d = e:GetData()
	local entry = d.customAfterimageData
	if entry then
		if not d.init then
			sprite:Load(entry.animFile or entry.sprite:GetFilename(), true)
			if entry.spritesheet then
				for _,sheet in ipairs(entry.spritesheet) do
					sprite:ReplaceSpritesheet(sheet.num, sheet.file)
				end
				sprite:LoadGraphics()
			end
			sprite:SetFrame(entry.anim or entry.sprite:GetAnimation(), entry.animFrame or entry.sprite:GetFrame())
			if entry.overlay then
				sprite:SetOverlayFrame(entry.animOverlay or entry.sprite:GetOverlayAnimation(), entry.animOverlayFrame or entry.sprite:GetOverlayFrame())
			end
			sprite:Stop()

			entry.timeout = entry.timeout or 1
			e.Color = entry.color or Color(1, 1, 1, 1, 0, 0, 0)
			if entry.timeout > 0 then
				entry.fadeCalc = e.Color.A/entry.timeout
			end
			d.init = true
		end
		if entry.needsParent and not (e.Parent or e.Parent:Exists()) then
			e:Remove()
		end

		if entry.customFunc then
			entry.customFunc(e)
		end

		if entry.fade then
			e.Color = Color(e.Color.R, e.Color.G, e.Color.B, e.Color.A-entry.fadeCalc, e.Color.RO, e.Color.GO, e.Color.BO)
		end

		if e.FrameCount > entry.timeout then
			e:Remove()
		end
	else
		e:Remove()
	end
end