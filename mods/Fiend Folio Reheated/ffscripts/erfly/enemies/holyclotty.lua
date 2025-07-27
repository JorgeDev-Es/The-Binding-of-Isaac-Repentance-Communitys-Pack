local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:holyClottyUpdate(npc)
	local sprite = npc:GetSprite()
	local d = npc:GetData()
	local target = npc:GetPlayerTarget()
	local targetpos = mod:randomConfuse(npc, target.Position)
	local path = npc.Pathfinder
    local room = game:GetRoom()

    npc.StateFrame = npc.StateFrame + 1
    if not d.init then
        npc.SplatColor = FiendFolio.ColorPureWhitePale
        d.init = true
        local eternalfriend = Isaac.Spawn(mod.FF.DeadFlyOrbital.ID, mod.FF.DeadFlyOrbital.Var, 0, npc.Position, nilvector, npc):ToNPC()
		eternalfriend.Parent = npc
        eternalfriend:GetData().distance = 20
    end

    if d.state == "idle" then
        npc.Velocity = npc.Velocity * 0.9
        mod:spritePlay(sprite, "Idle")
        d.state = "move"
        npc.StateFrame = 0
        if math.random(2) == 1 then
            d.MoveVec = nil
            path:FindGridPath(targetpos, 0.1, 900, true)
        else
            d.MoveVec = RandomVector()
        end
    elseif d.state == "move" then
        if sprite:IsFinished("Hop") or (npc.StateFrame > 16 and math.random(6) == 1) then
            d.state = "attack"
        else
            mod:spritePlay(sprite, "Hop")
        end
        d.MoveVec = d.MoveVec or npc.Velocity:Rotated(-31 + math.random(61))
        npc.Velocity = mod:Lerp(npc.Velocity, d.MoveVec:Resized(5), 0.1)
        if npc.Velocity.X < 0 then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
        if npc.FrameCount % 3 == 1 then
            local splat = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
            splat.Color = FiendFolio.ColorPureWhitePale
            splat:Update()
        end
    elseif d.state == "attack" then
        npc.Velocity = npc.Velocity * 0.9
        if sprite:IsFinished("Attack") then
            d.state = "idle"
        elseif sprite:IsEventTriggered("Shoot") then
            npc:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
            local params = ProjectileParams()
            --params.Color = FiendFolio.ColorKickDrumsAndRedWine
            params.BulletFlags = ProjectileFlags.SMART
            params.HomingStrength = 0.4
            local vec = Vector(10,0)
            local closestOne
            local dist = 9999
            for i = 90, 360, 90 do
                local pos = npc.Position + vec:Rotated(i)
                local playerdist = (target.Position - pos):Length()
                if playerdist < dist then
                    dist = playerdist
                    closestOne = i
                end
            end
            for i = 90, 360, 90 do
                if closestOne == i then
                    npc:FireProjectiles(npc.Position, vec:Rotated(i) * 1.05, 0, params)
                else
                    npc:FireProjectiles(npc.Position, vec:Rotated(i) * 0.55, 0, params)
                end
            end
            local splat = Isaac.Spawn(1000, 7, 0, npc.Position, nilvector, npc)
            splat.Color = FiendFolio.ColorPureWhitePale
            splat:Update()
        else
            mod:spritePlay(sprite, "Attack")
        end
    else
        d.state = "idle"
        mod:spritePlay(sprite, "Idle")
    end

    if npc:IsDead() then
        local vec = Vector(25,0)
        for i = 0, 450, 90 do
            local usedvec = vec
            if i == 0 then
                usedvec = nilvector
            elseif i == 450 then
                usedvec = usedvec * 2
            end
            local beam = Isaac.Spawn(1000, 19, 0, npc.Position + usedvec:Rotated(i), nilvector, npc):ToEffect()
            beam.Timeout = 10
            beam:Update()
        end
    end
end
