local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)
	local teardamage = player.Damage*0.50
	
	if not data.state then
		familiar.FireCooldown = 15
		data.state = "Float"
		data.stateframe = 0
	else
		familiar.FireCooldown = familiar.FireCooldown - ((player and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2) or 1)
		familiar.FireCooldown = math.max(0, familiar.FireCooldown)
		
		data.stateframe = data.stateframe + 1
	end
	
	local velocity
	familiar:PickEnemyTarget(10000, 13)
	if familiar.Target then
		velocity = (familiar.Target.Position-familiar.Position):Resized(10)
	end
	
	local direction
	if velocity then
		direction = mod:GetDirectionFromVector(velocity)
	else
		direction = Direction.NO_DIRECTION
	end
	
	data.lastdirection = (data.lastdirection ~= nil and data.lastdirection) or direction
	data.lastdirection = (direction ~= Direction.NO_DIRECTION and direction) or data.lastdirection
	if familiar.FireCooldown == 0 and direction ~= Direction.NO_DIRECTION then
		data.stateframe = 0
		data.state = "Shoot"
		familiar.FireCooldown = 15
		if Sewn_API then
			if Sewn_API:IsUltra(data) then
				familiar.FireCooldown = familiar.FireCooldown - 8
			elseif Sewn_API:IsSuper(data) then
				familiar.FireCooldown = familiar.FireCooldown - 4
			end
		end
				
		if isSirenCharmed then
			local proj = Isaac.Spawn(9, 0, 0, familiar.Position, velocity, familiar):ToProjectile()
			local projcolor = Color(1.0, 1.0, 1.0, 1, 0/255, 0/255, 0/255)
			projcolor:SetColorize(0.4, 1, 0.5, 1)
			proj.Color = projcolor
		else
			local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, familiar.Position, velocity, familiar):ToTear()
			local color = tear.Color
			tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
			tear.Color = Color(color.R, color.G, color.B, color.A*0.75, color.RO, color.GO, color.BO)
			tear.Height = -23
			tear.FallingSpeed = 0.1 + (math.random() * 2 - 1) * 0.07
			tear.FallingAcceleration = 0
			tear.CollisionDamage = teardamage
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
				tear.CollisionDamage = teardamage * 2
			end
			tear.Scale = teardamage/4 + 0.4
			if Sewn_API then
				if Sewn_API:IsUltra(data) then
					tear.CollisionDamage = tear.CollisionDamage * 1.5
					tear.Scale = tear.Scale * 1.1
				elseif Sewn_API:IsSuper(data) then
					tear.CollisionDamage = tear.CollisionDamage * 1.25
					tear.Scale = tear.Scale * 1.05
				end
			end
			tear:ResetSpriteScale()
			if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
				tear:AddTearFlags(TearFlags.TEAR_HOMING)
				local tearcolor = Color(0.4, 0.15, 0.38, 1, 55/255, 5/255, 95/255)
				tear.Color = tearcolor
			end
			if isSuperpositioned then
				local tearcolor = Color.Lerp(tear.Color, Color(1,1,1,1,0,0,0), 0)
				tearcolor.A = tearcolor.A / 4
				tear.Color = tearcolor
			end
		end
	end
	
	if data.state == "Float" and not sprite:IsPlaying("Appear") then
		if direction == Direction.LEFT and not (sprite:IsPlaying("FloatSide") and sprite.FlipX == true) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = true
		elseif direction == Direction.RIGHT and not (sprite:IsPlaying("FloatSide") and sprite.FlipX == false) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif direction == Direction.UP and not sprite:IsPlaying("FloatUp") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatUp", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif (direction == Direction.DOWN or direction == Direction.NO_DIRECTION) and not sprite:IsPlaying("FloatDown") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatDown", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		end
	elseif data.state == "Shoot" then
		if data.lastdirection == Direction.LEFT and not (sprite:IsPlaying("FloatShootSide") and sprite.FlipX == true) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = true
		elseif data.lastdirection == Direction.RIGHT and not (sprite:IsPlaying("FloatShootSide") and sprite.FlipX == false) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif data.lastdirection == Direction.UP and not sprite:IsPlaying("FloatShootUp") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootUp", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif (data.lastdirection == Direction.DOWN or data.lastdirection == Direction.NO_DIRECTION) and not sprite:IsPlaying("FloatShootDown") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootDown", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		end
		
		if (direction ~= Direction.NO_DIRECTION and data.stateframe >= 9) or data.stateframe >= 17 then
			data.state = "Float"
			data.stateframe = 0
		end
	end
	
	if familiar.Position:Distance(player.Position) > 50 then
		familiar.Velocity = mod:Lerp(familiar.Velocity, (player.Position - familiar.Position), 0.005, 0.9)
		familiar.Velocity = mod:CappedVector(familiar.Velocity, 5.5)
	else
		familiar.Velocity = familiar.Velocity*0.9
	end
	if familiar.Target then
		familiar.Velocity = familiar.Velocity + (familiar.Target.Position-familiar.Position):Resized(0.2)
	end
end, TaintedFamiliars.SOUL_SISTER)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)
	local teardamage = player.Damage*2
	
	local skeleton
	for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.FORGOTTEN_BODY)) do
		if GetPtrHash(entity:ToFamiliar().Player) == GetPtrHash(player) then
			skeleton = entity:ToFamiliar()
		end
	end
	
	if not data.state then
		familiar.FireCooldown = 20
		data.state = "Float"
		data.stateframe = 0
	else
		familiar.FireCooldown = familiar.FireCooldown - ((player and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2) or 1)
		familiar.FireCooldown = math.max(0, familiar.FireCooldown)
		
		data.stateframe = data.stateframe + 1
	end
	
	local velocity
	familiar:PickEnemyTarget(10000, 13)
	if familiar.Target then
		velocity = (familiar.Target.Position-familiar.Position):Resized(10)
	end
	
	local direction
	if velocity then
		direction = mod:GetDirectionFromVector(velocity)
	else
		direction = Direction.NO_DIRECTION
	end
	
	data.lastdirection = (data.lastdirection ~= nil and data.lastdirection) or direction
	data.lastdirection = (direction ~= Direction.NO_DIRECTION and direction) or data.lastdirection
	if familiar.FireCooldown == 0 and direction ~= Direction.NO_DIRECTION then
		data.stateframe = 0
		data.state = "Shoot"
		familiar.FireCooldown = 20
		if Sewn_API then
			if Sewn_API:IsUltra(data) then
				familiar.FireCooldown = familiar.FireCooldown - 8
			elseif Sewn_API:IsSuper(data) then
				familiar.FireCooldown = familiar.FireCooldown - 4
			end
		end
				
		if not isSirenCharmed then
			local swipe = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.SWIPE, 0, familiar.Position, Vector.Zero, familiar):ToEffect()
			swipe:GetSprite():Load("gfx/008.001_bone club.anm2", true)
			swipe:GetSprite():Play("Swing")
			swipe.SpriteScale = swipe.SpriteScale*0.9
			swipe.SpriteRotation = velocity:GetAngleDegrees() - 90
			swipe.SpriteOffset = Vector(0, -5)
			swipe:FollowParent(familiar)
			
			local hashit = false
			for i, enemy in pairs(Isaac.FindInRadius(familiar.Position+familiar.Velocity:Resized(10), 30, EntityPartition.ENEMY)) do
				if enemy:IsEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					enemy:TakeDamage(teardamage, 0, EntityRef(familiar), 8)
					enemy.Velocity = enemy.Velocity + (enemy.Position - player.Position):Resized(80/enemy.Mass)
					hashit = true
				end
			end
			
			sfx:Play(SoundEffect.SOUND_SHELLGAME, 0.7)
			if hashit then
				sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 2, false, 1.5)
			end
		end
	end
	
	if data.state == "Float" and not sprite:IsPlaying("Appear") then
		if direction == Direction.LEFT and not (sprite:IsPlaying("FloatSide") and sprite.FlipX == true) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = true
		elseif direction == Direction.RIGHT and not (sprite:IsPlaying("FloatSide") and sprite.FlipX == false) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif direction == Direction.UP and not sprite:IsPlaying("FloatUp") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatUp", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif (direction == Direction.DOWN or direction == Direction.NO_DIRECTION) and not sprite:IsPlaying("FloatDown") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatDown", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		end
	elseif data.state == "Shoot" then
		if data.lastdirection == Direction.LEFT and not (sprite:IsPlaying("FloatShootSide") and sprite.FlipX == true) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = true
		elseif data.lastdirection == Direction.RIGHT and not (sprite:IsPlaying("FloatShootSide") and sprite.FlipX == false) then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootSide", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif data.lastdirection == Direction.UP and not sprite:IsPlaying("FloatShootUp") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootUp", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		elseif (data.lastdirection == Direction.DOWN or data.lastdirection == Direction.NO_DIRECTION) and not sprite:IsPlaying("FloatShootDown") then
			local frame = sprite:GetFrame()
			sprite:Play("FloatShootDown", true)
			sprite:SetFrame(frame)
			sprite.FlipX = false
		end
		
		if (direction ~= Direction.NO_DIRECTION and data.stateframe >= 9) or data.stateframe >= 17 then
			data.state = "Float"
			data.stateframe = 0
		end
	end
	
	if skeleton then
		if familiar.Position:Distance(skeleton.Position) > 50 then
			familiar.Velocity = mod:Lerp(familiar.Velocity, (skeleton.Position - familiar.Position), 0.005, 0.9)
			familiar.Velocity = mod:CappedVector(familiar.Velocity, 5.5)
		else
			familiar.Velocity = familiar.Velocity*0.9
		end
		if familiar.Target then
			familiar.Velocity = familiar.Velocity + (familiar.Target.Position-familiar.Position):Resized(0.3)
		end
	end
end, TaintedFamiliars.BONE_SISTER)

function mod:GetDirectionFromVector(vector)
	local angleDegrees = vector:GetAngleDegrees()
	if math.abs(angleDegrees) < 45 then
		return Direction.RIGHT
	elseif math.abs(angleDegrees) > 135 then
		return Direction.LEFT
	elseif angleDegrees > 0 then
		return Direction.DOWN
	elseif angleDegrees < 0 then
		return Direction.UP
	end
end