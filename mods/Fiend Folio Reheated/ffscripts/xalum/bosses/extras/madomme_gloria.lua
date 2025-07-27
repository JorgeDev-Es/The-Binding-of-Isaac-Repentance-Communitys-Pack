local mod = FiendFolio
local sfx = SFXManager()

local GimpState = {
	IDLE	= 1,
	LAUNCH	= 2,
}

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, projectile)
	if projectile:IsDead() and projectile.SpawnerEntity and projectile.SpawnerType == mod.FF.Gloria.ID and projectile.SpawnerVariant == mod.FF.Gloria.Var and not projectile:GetData().notActuallyGloria then
		local rng = projectile:GetDropRNG()

		for i = 1, 15 do
			local proj = Isaac.Spawn(9, 0, 0, projectile.Position, RandomVector() * 6, projectile.SpawnerEntity):ToProjectile()
			proj.FallingSpeed = -10 -rng:RandomInt(15)
			proj.FallingAccel = 2

			proj:GetData().notActuallyGloria = true
		end

		for _, entity in pairs(Isaac.FindByType(mod.FF.Gimp.ID, mod.FF.Gimp.Var)) do
			if entity.Position:Distance(projectile.Position) < 60 then
				local data = entity:GetData()
				
				data.state = GimpState.LAUNCH
				data.launchSpeed = -10
				data.launchAccel = 0.5

				entity.SpriteOffset = Vector(0, -5)
				entity.EntityCollisionClass = 0
				entity.Velocity = (entity.Position - projectile.Position):Resized(5)
				entity:GetSprite():Play("Launched" .. math.random(2))
			end
		end
	end
end)

return {
	Init = function(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		
		local data = npc:GetData()
		data.delay = 60
		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 35)

		data.params = ProjectileParams()
		data.params.FallingSpeedModifier = -50
		data.params.FallingAccelModifier = 3
		data.params.HeightModifier = -70
		data.params.BulletFlags = ProjectileFlags.ACID_RED
		data.params.Scale = 2

		data.scatterParams = ProjectileParams()
	end,

	AI = function(npc)
		local sprite = npc:GetSprite()
		local data = npc:GetData()
		local rng = data.rng

		if sprite:IsFinished("Appear") or sprite:IsFinished("Shoot") then
			sprite:Play("Idle")
		end

		if sprite:IsPlaying("Idle") then
			if data.delay < npc.FrameCount and npc.FrameCount % 5 == 0 and (data.rng:RandomFloat() < 0.1 or data.delay + 210 < npc.FrameCount) then
				sprite:Play("Shoot")
				sfx:Play(SoundEffect.SOUND_SINK_DRAIN_GURGLE)
			end
		end

		if sprite:IsEventTriggered("Shoot") then
			local target = npc:GetPlayerTarget()
			local targetPosition = target.Position + target.Velocity * 15
			local targetVelocity = targetPosition - npc.Position
			npc:FireProjectiles(npc.Position, targetVelocity / 25, 0, data.params)
			data.delay = npc.FrameCount + 90
			sfx:Play(SoundEffect.SOUND_BLOBBY_WIGGLE)
			sfx:Play(SoundEffect.SOUND_LITTLE_SPIT, 1, 0, false, 0.85)
		end
	end,
}