local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local sweaticon = Sprite()
sweaticon:Load("gfx/ui/ff_statuseffects.anm2", true)
sweaticon:Play("Sweaty", true)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, cooldown)
	if entity:IsEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and not entity:HasMortalDamage() and source and source.Entity and (source.Entity.Parent or source.Entity:ToPlayer()) then
		local player = source.Entity:ToPlayer() or source.Entity.Parent:ToPlayer()
		
		if player and player:HasTrinket(FiendFolio.ITEM.ROCK.ATLAS_BURDEN) and not entity:GetData().IsBurdened then
			local trinketpower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ATLAS_BURDEN)
			local chance = math.min(5 + player.Luck * 2, 10) * trinketpower
			
			if mod:RandomInt(1,20 + Isaac.CountEntities(player, 1000, 1960, mod.FF.AtlasBoulder.Sub)*100) < chance then
				local effect = Isaac.Spawn(1000, 1960, mod.FF.AtlasBoulder.Sub, entity.Position, Vector.Zero, player):ToEffect()
				local effectdata = effect:GetData()
				effect:FollowParent(entity)
				effectdata.BurdenTarget = entity
				entity:GetData().IsBurdened = true
				
				if entity.Size < 13 then
					effectdata.BurdenSize = "Small"
				elseif entity.Size < 20 then
					effectdata.BurdenSize = "Medium"
				else
					effectdata.BurdenSize = "Large"
				end
				
				effect.SpriteOffset = Vector(0, entity.Size * -1.0)
				effect.DepthOffset = entity.DepthOffset - 1
				
				effect:GetSprite():Play("Drop"..effectdata.BurdenSize)
				
				if mod:RandomInt(1, 7) == 1 then
					effect:GetSprite():ReplaceSpritesheet(0, "gfx/effects/atlas_boulder_alt.png")
					effect:GetSprite():LoadGraphics()
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	if effect.SubType == mod.FF.AtlasBoulder.Sub then
		local data = effect:GetData()
		local sprite = effect:GetSprite()
		local player = effect.SpawnerEntity:ToPlayer()
		if data.BurdenTarget:IsDead() then
			if effect.SpriteOffset.Y ~= 0 then
				effect.SpriteOffset = Vector(0, 0)
				sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
				for i = 45, 360, 45 do
					local tear = player:FireTear(effect.Position, Vector.FromAngle(i):Resized(10), false, true, false, effect, 2)
					tear:ChangeVariant(TearVariant.ROCK)
				end
				for i = 25, 360, 25 do
					local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, effect.Position, Vector.FromAngle(i):Resized(5), effect):ToEffect()
					smoke.Timeout = mod:RandomInt(20, 30)
				end
				game:MakeShockwave(effect.Position, 0.05, 0.025, 20)
				game:ShakeScreen(10)
				
				FiendFolio.scheduleForUpdate(function()
					effect.Color = Color(1,1,1,0)
					effect:SetColor(Color.Default, 100, 1, true, false)
					effect.Timeout = 100
				end, 60)
			end
		else
			data.BurdenTarget.Velocity = data.BurdenTarget.Velocity - data.BurdenTarget.Velocity*0.2
			if mod:RandomInt(1, 100) == 1 and sprite:GetAnimation() == "Idle"..data.BurdenSize then
				sprite:Play("Bounce"..data.BurdenSize)
			end
		end
		if sprite:IsEventTriggered("Crash") then
			if data.BurdenTarget:IsBoss() then
				data.BurdenTarget:TakeDamage(player.Damage*4, 0, EntityRef(effect), 2)
				sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS)
				game:MakeShockwave(effect.Position, 0.01, 0.025, 15)
			else
				data.BurdenTarget:Kill()
			end
		end
		if sprite:IsEventTriggered("Impact") then
			sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS)
			game:MakeShockwave(effect.Position, 0.01, 0.025, 15)
		end
		if sprite:IsFinished("Bounce"..data.BurdenSize) or sprite:IsFinished("Drop"..data.BurdenSize) then
			sprite:Play("Idle"..data.BurdenSize)
		end
		
		sweaticon:Update()
	end
end, 1960)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
	if effect.SubType == mod.FF.AtlasBoulder.Sub then
		local data = effect:GetData()
		local sprite = effect:GetSprite()
		if not data.BurdenTarget:IsDead() then
			if sprite:GetAnimation() == "Idle"..data.BurdenSize then
				sweaticon:Render(Isaac.WorldToScreen(data.BurdenTarget.Position+Vector(20, -30 + data.BurdenTarget.Size * -1.0)))
			end
		end
	end
end, 1960)