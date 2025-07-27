local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local directions = {Vector(-1,0), Vector(0,-1), Vector(1,0), Vector(0, 1)}
local chargebaritems = {CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID, CollectibleType.COLLECTIBLE_REVELATION, CollectibleType.COLLECTIBLE_MONTEZUMAS_REVENGE}
local chargedweapontypes = {WeaponType.WEAPON_BRIMSTONE, WeaponType.WEAPON_KNIFE, WeaponType.WEAPON_MONSTROS_LUNGS, WeaponType.WEAPON_TECH_X, WeaponType.WEAPON_BONE, WeaponType.WEAPON_SPIRIT_SWORD, WeaponType.WEAPON_FETUS}

function mod:ReaperPlayerLogic(player, data) 
	if player:HasCollectible(TaintedCollectibles.REAPER) then
		local idx = player.ControllerIndex
		
		data.TaintedReaperTimer = data.TaintedReaperTimer or -1
		data.TaintedReaperBlast = data.TaintedReaperBlast or 0
		data.TaintedReaperBlastDir = data.TaintedReaperBlastDir or {}
		--print(data.TaintedReaperTimer)
		
        if player:GetFireDirection() ~= -1 then
			if not Input.IsActionPressed(ButtonAction.ACTION_MAP, idx) then
				if data.TaintedReaperTimer == -1 and data.TaintedReaperBlast < 5 then
					data.TaintedReaperTimer = 75
				elseif data.TaintedReaperTimer > 0 then
					data.TaintedReaperTimer = data.TaintedReaperTimer - 1
				end
			end
			
			if player:GetAimDirection():Length() > 0.1 then
				data.TaintedReaperBlastDir.X = player:GetAimDirection().X
				data.TaintedReaperBlastDir.Y = player:GetAimDirection().Y
			end
			
			if data.TaintedReaperTimer == 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
				SFXManager():Play(SoundEffect.SOUND_GHOST_ROAR, 1, 2, false, 1)
				data.TaintedReaperBlast = 10
				data.TaintedReaperTimer = -1
				data.ReaperBar:Play("Disappear")
			end
		else 
			if data.TaintedReaperTimer == 0 then
				SFXManager():Play(SoundEffect.SOUND_GHOST_ROAR, 1, 2, false, 1)
				data.TaintedReaperBlast = 10
			end
			data.TaintedReaperTimer = -1
		end
		
		if data.TaintedReaperBlast > 0 and player.FrameCount % 2 == 0 then
			data.TaintedReaperBlast = data.TaintedReaperBlast - 1
			local firestospawn = mod:RandomInt(0,2)
			
			for i = 1, firestospawn do
				local vec = Vector(data.TaintedReaperBlastDir.X, data.TaintedReaperBlastDir.Y)
				local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, player.Position, vec:Resized(mod:RandomInt(5,10))+Vector(mod:RandomInt(-3, 3), mod:RandomInt(-3, 3))+player.Velocity, player):ToEffect()
				fire.Parent = player
				fire.CollisionDamage = math.max(3.5, player.Damage) / 1.5
				fire.Timeout = mod:RandomInt(40, 60)
				--[[fire:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_white.png")
				fire:GetSprite():LoadGraphics()]]
				fire.Color = mod.ColorGreyscale
				fire:GetData().TaintedReaperFire = true
				fire:Update()
			end
		end
    end
end

function mod:ReaperBarRender(player, data)
	if player:HasCollectible(TaintedCollectibles.REAPER) and Options.ChargeBars then
		local idx = player.ControllerIndex
		local offset = Vector(18 * player.SpriteScale.X, -54 * player.SpriteScale.Y)
		local haschargebaritem = false
		local render = true
		local room = game:GetRoom()
		
		if not data.ReaperBar then
			local sprite = Sprite()
			sprite:Load("gfx/ui/ui_reaperchargebar.anm2", true)
			sprite.PlaybackSpeed = 1
			data.ReaperBar = sprite
		end
		local bar = data.ReaperBar
		
		if mod:IsNormalRender() then
			if game:GetFrameCount() % 2 == 0 then
				bar:Update()
			end
			
			if player:GetFireDirection() ~= -1 then
				if data.TaintedReaperTimer < 72 and data.TaintedReaperBlast < 5 then
					if data.TaintedReaperTimer > 0 then
						bar:Play("Charging")
						bar:SetFrame(100-math.floor(data.TaintedReaperTimer*100/75))
					else
						if data.TaintedStartCharged and data.TaintedReaperTimer == 0 then
							bar:Play("StartCharged")
							data.TaintedStartCharged = false
						elseif not bar:IsPlaying("Charged") and not bar:IsPlaying("StartCharged") and data.TaintedReaperTimer == 0 then
							bar:Play("Charged")
						end
					end
				end
			else
				if not bar:IsPlaying("Disappear") and (bar:IsPlaying("Charging") or bar:IsPlaying("Charged") or bar:IsPlaying("StartCharged"))then
					bar:Play("Disappear")
				end
				data.TaintedStartCharged = true
			end
		end
		
		for i, entry in pairs(chargebaritems) do
			if player:HasCollectible(entry) then
				haschargebaritem = true
			end
		end
		
		for i, entry in pairs(chargedweapontypes) do
			if player:HasWeaponType(entry) then
				offset = Vector(30 * player.SpriteScale.X, -37 * player.SpriteScale.Y)
			end
		end
		
		if room:HasWater() then
			if room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
				render = false
			else
				render = true
			end
		else
			render = true
		end
		if not haschargebaritem and render then
			bar:Render(Isaac.WorldToScreen(player.Position + offset))
		end
	end
end
