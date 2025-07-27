local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local function IsIncubusShooting(familiar)
	--print(familiar:GetSprite():GetAnimation(), familiar.HeadFrameDelay)
	if string.match(familiar:GetSprite():GetAnimation(), "Shoot") and (familiar.HeadFrameDelay == 0 or familiar.HeadFrameDelay == 10) then
		return true
	elseif string.match(familiar:GetSprite():GetAnimation(), "2") then
		return true
	end
end

--A lot of this is stolen from FF's Sibling Syl because honk shoooo honk shoooooooo
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local isSuperpositioned = mod:isSuperpositionedPlayer(familiar.Player)
	local isSirenCharmed = mod:isSirenCharmed(familiar)
	
	if not data.state then
		familiar:AddToFollowers()
		data.state = "Float"
		data.stateframe = 0
	else
		familiar.FireCooldown = familiar.FireCooldown - ((player and player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2) or 1)
		familiar.FireCooldown = math.max(0, familiar.FireCooldown)
		
		data.stateframe = data.stateframe + 1
	end
	
	local direction = player:GetFireDirection()
	data.lastdirection = (data.lastdirection ~= nil and data.lastdirection) or direction
	data.lastdirection = (direction ~= Direction.NO_DIRECTION and direction) or data.lastdirection
	
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
	
	if not data.OrbitingIncubus or not data.OrbitingIncubus:Exists() then
		for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.INCUBUS)) do
			if not entity:GetData().OrbitingAsmodeus then
				data.OrbitingIncubus = entity
				entity:GetData().OrbitingAsmodeus = familiar
			end
		end
	else
		if IsIncubusShooting(data.OrbitingIncubus:ToFamiliar()) then
			data.stateframe = 0
			data.state = "Shoot"
			familiar.FireCooldown = player.MaxFireDelay
			if Sewn_API then
				if Sewn_API:IsUltra(data) then
					familiar.FireCooldown = familiar.FireCooldown - 8
				elseif Sewn_API:IsSuper(data) then
					familiar.FireCooldown = familiar.FireCooldown - 4
				end
			end
			
			local velocity
			if data.lastdirection == Direction.LEFT then
				velocity = Vector(-10, 0)
			elseif data.lastdirection == Direction.RIGHT then
				velocity = Vector(10, 0)
			elseif data.lastdirection == Direction.UP then
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
				local tear = player:FireTear(familiar.Position, velocity, true, false, false, familiar, 0.25)
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					tear.CollisionDamage = tear.CollisionDamage * 2
				end
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
	
		--familiar.Position = data.OrbitingIncubus.Position + Vector(math.sin(familiar.FrameCount/10), math.cos(familiar.FrameCount/10))*30
		
		--Lifted from Fiend Folio Molar System (Thanks Guwah)
		data.Angle = data.Angle or 0
		familiar.Velocity = (data.OrbitingIncubus.Position + Vector(0,30):Rotated(data.Angle)) - familiar.Position
        data.Angle = data.Angle + 5
	end
end, TaintedFamiliars.ASMODEUS)