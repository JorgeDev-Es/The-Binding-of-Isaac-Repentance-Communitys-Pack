local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local rng = RNG()

local function ShootNails(npc, data)
    if not data.ShotMyNails then
        mod:PlaySound(mod.Sounds.PiperAttack,npc)
        for i = 45, 360, 45 do
            local nail = Isaac.Spawn(mod.FF.NailheadNail.ID, mod.FF.NailheadNail.Var, mod.FF.NailheadNail.Sub, npc.Position, Vector(5,0):Rotated(i), npc)
        end
        data.ShotMyNails = true
    end
end

function mod:NailheadAI(npc, sprite, data)
    local room = game:GetRoom()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    mod.QuickSetEntityGridPath(npc)

    if not data.Init then
        data.Speed = 4
        data.Suffix = ""
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        npc:AnimWalkFrame("WalkHori"..data.Suffix, "WalkVert"..data.Suffix, 0.1)

        if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(data.Speed)), 0.25)
        else
            npc.Pathfinder:FindGridPath(targetpos, (data.Speed * 0.1) + 0.2, 900, true)
        end
        
        if data.Suffix == "02" then
            if npc.FrameCount % 5 == 1 then
                local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
                creep.SpriteScale = Vector(0.3,0.3)
                creep:SetTimeout(10)
                creep:Update()
            end
        else
            if npc.HitPoints <= npc.MaxHitPoints * 0.66 or (npc.FrameCount > 90 and room:CheckLine(npc.Position,targetpos,0,1,false,false) and npc.Position:Distance(targetpos) <= 40) then
                data.State = "Shoot"
            end
        end
    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.7
        if sprite:IsFinished("Shoot") then
            data.Speed = 6
            data.Suffix = "02"
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            ShootNails(npc, data)
        elseif sprite:IsEventTriggered("Burst") then
            npc:BloodExplode()
            mod:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE,npc)
        else
            mod:spritePlay(sprite, "Shoot")
        end
    end

    if npc:IsDead() then
        ShootNails(npc, data)
    end
end

function mod:NailheadNail(effect, sprite, data)
    if not data.Init then
        sprite:Play("InAir")
        data.Init = true
    end

    if sprite:IsFinished("Land") then
        sprite:Play("Idle")
    end

    if data.Landed then
        effect.Velocity = effect.Velocity * 0.5
        mod:DamagePlayersInRadius(effect.Position, 8, 1, effect.SpawnerEntity, DamageFlag.DAMAGE_SPIKES, true)

        if game:GetRoom():IsClear() or effect.FrameCount > 600 then
            mod:NailheadNailBreak(effect)
        end
    end
end

function mod:NailheadNailRender(effect, sprite, data, isPaused, isReflected)
    if not (isPaused or isReflected) then
        if not data.Landed then
            data.StateFrame = data.StateFrame or 2
            mod:FlipSprite(sprite,  effect.Position, effect.Position + effect.Velocity)
            local curve = math.sin(math.rad(9 * data.StateFrame))
            local height = 0 - curve * 40
            sprite.Offset = Vector(0, height)
            if height >= 0 then
                if game:GetRoom():GetGridCollisionAtPos(effect.Position) > GridCollisionClass.COLLISION_NONE then
                    mod:NailheadNailBreak(effect)
                else
                    sprite.FlipX = (rng:RandomFloat() <= 0.5)
                    sprite.Offset = Vector.Zero
                    data.Landed = true
                    sfx:Play(SoundEffect.SOUND_SCAMPER)
                    sprite:Play("Land")
                end
            else
                data.StateFrame = data.StateFrame + 0.5
            end
        end
    end
end

function mod:NailheadNailBreak(effect)
    sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.5, 0, false, 3)
	local poof = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, effect.Position, Vector.Zero, effect)
    poof.SpriteScale = Vector(0.8,0.8)
	for i = 1, 5 do
		local gib = Isaac.Spawn(1000, EffectVariant.NAIL_PARTICLE, 0, effect.Position, RandomVector()*2, effect):ToEffect()
		gib.State = 2
	end
    effect.Visible = false
    effect:Remove()
end