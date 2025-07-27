local mod = LastJudgement
local game = Game()

local bal = {
    wanderRange = {40,100},
    moveSpeed = 4,
    numSlides = {2,4},
    whipForce = 20,
    idleDelay = {0,5},
}

local function GetWanderPos(npc)
    local wanderpos = mod:FindRandomValidPathPosition(npc, 0, bal.wanderRange[1], bal.wanderRange[2])
    if wanderpos:Distance(npc.Position) < 20 then
        wanderpos = npc.Position + (RandomVector() * 40)
    end
    return wanderpos
end

local function ApplyWhipForce(npc, collider, doSound)
    collider.Velocity = (collider.Position - npc.Position):Resized(bal.whipForce)
    if doSound then
        mod:PlaySound(SoundEffect.SOUND_WHIP_HIT, npc)
    end
end

function mod:CarnisAI(npc, sprite, data)
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc.SplatColor = mod.Colors.CarnisSplat
        npc.TargetPosition = GetWanderPos(npc)
        npc.StateFrame = mod:RandomInt(bal.numSlides)
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Hop")

        if sprite:WasEventTriggered("Shoot") then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.TargetPosition - npc.Position):Resized(bal.moveSpeed), 0.2)
        else
            npc.Velocity = npc.Velocity * 0.7
        end

        if sprite:IsEventTriggered("Shoot") then
            mod:FlipSprite(sprite, npc.Position, npc.TargetPosition)
        elseif sprite:IsEventTriggered("Stop") then
            npc.TargetPosition = GetWanderPos(npc)
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 and not mod:AreOthersInState(npc, "Attack") then
                npc.StateFrame = mod:RandomInt(bal.idleDelay, rng)
                data.State = "Attack"
            end
        end

    elseif data.State == "Attack" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Attack") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                npc.StateFrame = mod:RandomInt(bal.numSlides)
                data.State = "Idle"
            end
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_WHIP, npc)
            mod:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, npc, 0.8, 1.2)
        elseif sprite:IsEventTriggered("Swing") then
            mod:PlaySound(SoundEffect.SOUND_WHIP, npc, 0.8, 0.5)
            mod:PlaySound(SoundEffect.SOUND_SWORD_SPIN, npc, 1.2)
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 0.8, 0.5)
        else
            mod:SpritePlay(sprite, "Attack")
        end

        for i = 1, 2 do
            for _, ent in pairs(Isaac.FindInCapsule(npc:GetNullCapsule("Hitbox"..i)), EntityPartition.PLAYER | EntityPartition.ENEMY) do
                if not mod:isFriend(ent) then
                    if ent:ToPlayer() then
                        ent = ent:ToPlayer()
                        if ent:GetDamageCooldown() <= 0 and ent:TakeDamage(npc.CollisionDamage, 0, EntityRef(npc), 0) then
                            ApplyWhipForce(npc, ent, true)
                        end
                    elseif ent:ToBomb() then
                        ApplyWhipForce(npc, ent)
                    end
                end
                if ent:ToNPC() then
                    if mod:isFriend(npc) ~= mod:isFriend(ent) or mod:isCharm(npc) then
                        if ent:TakeDamage(15, 0, EntityRef(npc), 0) then
                            ApplyWhipForce(npc, ent, true)
                        end
                    end
                end
            end
        end
    end

    if npc.FrameCount > 0 and rng:RandomFloat() <= 0.1 then
        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc)
        splat.Color = npc.SplatColor
        splat:Update()
    end
end