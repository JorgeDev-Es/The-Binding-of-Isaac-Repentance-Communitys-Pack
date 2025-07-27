local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local player = familiar.Player
	local sprite = familiar:GetSprite()
	local data = familiar:GetData()
	
	data.SneezeDelay = data.SneezeDelay or 0
	if data.SneezeDelay > 0 then
		data.SneezeDelay = data.SneezeDelay - 1
	end
	
	if mod:RandomInt(1, 10) == 1 then
		familiar:PickEnemyTarget(999999, 13, 1 << 2)
	end
	
    if player:GetAimDirection():Length() > 0 then
		familiar.TargetPosition = -player:GetAimDirection():Resized(40)
	end
	
	if not string.match(sprite:GetAnimation(), "Shoot") or sprite:IsFinished() then
		if not familiar.Target then
			if player:GetFireDirection() == Direction.LEFT then
				sprite:Play("FloatSide")
				familiar.FlipX = false
			elseif player:GetFireDirection() == Direction.UP then
				sprite:Play("FloatDown")
			elseif player:GetFireDirection() == Direction.RIGHT then
				sprite:Play("FloatSide")
				familiar.FlipX = true
			elseif player:GetFireDirection() == Direction.DOWN then
				sprite:Play("FloatUp")
			elseif sprite:IsFinished() then
				sprite:Play("FloatSide")
			end
		else
			sprite:Play("FloatSide")
			familiar.FlipX = false
		end
	end
	
	local triggersneeze = false
	for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 1)) do
		if entity.SpawnerEntity and GetPtrHash(entity.SpawnerEntity) == GetPtrHash(player) then
			triggersneeze = true
		end
	end
	
	if triggersneeze and data.SneezeDelay < 1 and not string.match(sprite:GetAnimation(), "Shoot") then
		data.SneezeDelay = 20
		sfx:Play(SoundEffect.SOUND_BABY_BRIM)
		if player:GetFireDirection() == Direction.LEFT then
			sprite:Play("ShootSide")
			familiar.FlipX = false
		elseif player:GetFireDirection() == Direction.UP then
			sprite:Play("ShootDown")
		elseif player:GetFireDirection() == Direction.RIGHT then
			sprite:Play("ShootSide")
			familiar.FlipX = true
		elseif player:GetFireDirection() == Direction.DOWN then
			sprite:Play("ShootUp")
		end
		
		local vector = player:GetAimDirection()
		if familiar.Target then
			sprite:Play("ShootSide")
			familiar.FlipX = false
			vector = Vector(-1, 0)
		end
		
		
		local bloodtospawn = mod:RandomInt(5,15)
		for i = 1, bloodtospawn do
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 1, familiar.Position-vector:Resized(10), -vector:Resized(5) + RandomVector():Resized(5) + familiar.Velocity:Resized(2), familiar):ToEffect()
			effect.Color = mod.ColorElectricRed
			effect.PositionOffset = Vector(0, mod:RandomInt(-5,-10))
			effect.SpriteScale = effect.SpriteScale*rng:RandomFloat()*1.5
		end
		
		for i, entity in pairs(Isaac.FindInRadius(familiar.Position-vector:Resized(20), 40, EntityPartition.ENEMY)) do
			if entity:IsEnemy() and not entity:IsInvincible() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
				local knockbackvector = (entity.Position - player.Position)*2/entity.Mass
				if knockbackvector:Length() > 30 then
					knockbackvector = knockbackvector:Resized(30)
				end
				entity:TakeDamage(5, 0, EntityRef(familiar), 10)
				if not familiar.Target then
					entity.Velocity = entity.Velocity + knockbackvector
				end
				entity:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
				entity:GetData().BrimCurseDebuffed = 180
				entity:SetColor(Color(1,1,1,1,0.1,0,0), 180, 1, false, false)
			end
		end
		for i, entity in pairs(Isaac.FindInRadius(familiar.Position-vector:Resized(20), 40, EntityPartition.BULLET)) do
			local projectile = entity:ToProjectile()
			if projectile then
				projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
				projectile.Velocity = (projectile.Position - familiar.Position)*2/projectile.Mass
			end
		end
	end
	
	if not familiar.Target then
		familiar.Velocity = mod:Lerp(familiar.Velocity, (player.Position + familiar.TargetPosition - familiar.Position), 0.25, 0.9)
	else
		familiar.Velocity = mod:Lerp(familiar.Velocity, (familiar.Target.Position + Vector(-40, 0) - familiar.Position), 0.25, 0.9)
	end
end, TaintedFamiliars.BELPHEGOR)