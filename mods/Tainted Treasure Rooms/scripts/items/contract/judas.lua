local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

--A lot of this is stolen from FF's Sibling Syl because honk shoooo honk shoooooooo
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)
	
	if not data.state then
		familiar:AddToFollowers()
		familiar.FireCooldown = 15
		data.state = "Float"
		data.stateframe = 0
	else
		familiar.FireCooldown = familiar.FireCooldown - ((player and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2) or 1)
		familiar.FireCooldown = math.max(0, familiar.FireCooldown)
		
		data.stateframe = data.stateframe + 1
	end
	
	if not data.BBTearDamage then
		data.BBTearDamage = 3
	end
	
	if familiar:GetData().BBRoomIdx ~= game:GetLevel():GetCurrentRoomIndex() then
		mod:BelialBoyReset(familiar)
	end
	
	local direction = player:GetFireDirection()
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
		
		local velocity
		if direction == Direction.LEFT then
			velocity = Vector(-10, 0)
		elseif direction == Direction.RIGHT then
			velocity = Vector(10, 0)
		elseif direction == Direction.UP then
			velocity = Vector(0, -10)
		else
			velocity = Vector(0, 10)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY) then
			familiar:PickEnemyTarget(10000, 13)
			if familiar.Target then
				velocity = (familiar.Target.Position-familiar.Position):Resized(10)
			end
		elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
			for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET)) do
				if entity.SpawnerEntity.InitSeed == player.InitSeed then
					velocity = (entity.Position-familiar.Position):Resized(10)
				end
			end
		end
		velocity = velocity + player:GetTearMovementInheritance(velocity)
				
		if isSirenCharmed then
			local proj = Isaac.Spawn(9, 0, 0, familiar.Position, velocity, familiar):ToProjectile()
			local projcolor = Color(1.0, 1.0, 1.0, 1, 0/255, 0/255, 0/255)
			projcolor:SetColorize(0.4, 1, 0.5, 1)
			proj.Color = projcolor
		else
			local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, familiar.Position, velocity, familiar):ToTear()
			tear.Height = -23
			tear.FallingSpeed = 0.1 + (math.random() * 2 - 1) * 0.1
			tear.FallingAcceleration = 0
			tear.CollisionDamage = data.BBTearDamage
			if data.BBBigMode then
				tear:GetData().BBTear = true
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
				tear.CollisionDamage = data.BBTearDamage * 2
			end
			tear.Scale = data.BBTearDamage/5 + 0.2
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
	
	if data.state == "Float" then
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
	
	familiar:FollowParent()
end, TaintedFamiliars.BELIAL_BOY)

function mod:BelialBoyGoBigMode(familiar, damage)
	familiar:GetData().BBTearDamage = familiar:GetData().BBTearDamage + damage
	familiar:GetData().BBRoomIdx = game:GetLevel():GetCurrentRoomIndex()
	familiar:GetData().BBBigMode = true
	familiar:GetSprite():ReplaceSpritesheet(0, "gfx/familiar/familiar_belialboyactivated.png")
	familiar:GetSprite():LoadGraphics()
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position+familiar.Velocity, Vector.Zero, familiar)
	poof.Color = Color(0.2, 0.2, 0.2, 1, 0, 0, 0)
	sfx:Play(SoundEffect.SOUND_DEVIL_CARD, 1)
	
	for i = 0, 10 do
		local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, familiar.Position, Vector(mod:RandomInt(-1, 1), -2*i)+familiar.Velocity, player):ToEffect()
		smoke:GetSprite().PlaybackSpeed = 0.8
		smoke.Timeout = 80
		smoke.Color = Color(1,1,1,0)
		smoke:SetColor(Color(1, 0.2, 0.2, 0.5, 20, 0, 0), 20, 1, true, false)
	end
end

function mod:BelialBoyReset(familiar)
	familiar:GetData().BBTearDamage = 3
	familiar:GetData().BBBigMode = false
	familiar:GetSprite():ReplaceSpritesheet(0, "gfx/familiar/familiar_belialboy.png")
	familiar:GetSprite():LoadGraphics()
end