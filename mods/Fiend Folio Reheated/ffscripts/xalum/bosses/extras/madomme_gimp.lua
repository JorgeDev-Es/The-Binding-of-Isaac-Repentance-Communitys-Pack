local mod = FiendFolio
local game = Game()

local LocalState = {
	IDLE	= 1,
	LAUNCH	= 2,
}

local IDLE_WALK_SPEED = 3

return {
	Init = function(npc)
		local data = npc:GetData()
		data.rng = RNG()
		data.rng:SetSeed(npc.InitSeed, 35)
		data.state = LocalState.IDLE

		local sprite = npc:GetSprite()
		sprite:Play("Idle")
		sprite:PlayOverlay("Head")
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()
		local rng = data.rng

		if data.state == LocalState.IDLE then
			mod.XalumGenericPathfinding(npc, IDLE_WALK_SPEED)

			if npc.Velocity:Length() > 0.3 and npc.FrameCount > 1 then
				if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
					sprite:Play("WalkHori")
				else
					sprite:Play("WalkVert")
				end
			else
				sprite:Play("Idle")
			end

			sprite.FlipX = sprite:IsPlaying("WalkHori") and npc.Velocity.X < 0
			sprite:PlayOverlay(sprite.FlipX and "HeadFlipped" or "Head")
		else
			sprite:RemoveOverlay()
		end
	end,

	Render = function(npc)
		local data = npc:GetData()

		if data.state == LocalState.LAUNCH and not npc:IsDead() and not game:IsPaused() then
			npc.SpriteOffset = npc.SpriteOffset + Vector(0, data.launchSpeed)
			data.launchSpeed = data.launchSpeed + data.launchAccel

			npc.SpriteRotation = npc.SpriteRotation + 10

			if npc.SpriteOffset.Y > 0 then
				npc.SpriteOffset = Vector.Zero
				npc:BloodExplode()
				npc:Die()

				for i = 1, 25 do
					local rng = npc:GetDropRNG()
					local proj = Isaac.Spawn(9, 0, 0, npc.Position, RandomVector() * (5 + rng:RandomFloat() * 2), npc.SpawnerEntity):ToProjectile()
					proj.FallingSpeed = -10 -rng:RandomInt(15)
					proj.FallingAccel = 2

					proj:GetData().notActuallyGloria = true
				end
			end
		end
	end
}