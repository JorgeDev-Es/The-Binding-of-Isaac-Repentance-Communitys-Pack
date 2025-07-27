local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:DumptruckAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc.SplatColor = mod.ColorDankBlackReal
        npc.StateFrame = 0
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        if mod:WanderAbout(npc, data, 2.5, 0.02) then
            mod:spritePlay(sprite, "Walk")
            mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
        else
            mod:spritePlay(sprite, "Idle")
        end
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= -30 and npc.Position:Distance(targetpos) <= 100 then
            data.State = "Shit"
            data.ShitPos = targetpos
            mod:FlipSprite(sprite, data.ShitPos, npc.Position)
        end

    elseif data.State == "Shit" then
        if sprite:IsFinished("Shit") then
            npc.StateFrame = mod:RandomInt(60,90,rng)
            data.WalkPos = nil
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            local vec = data.ShitPos - npc.Position
            local index = room:GetGridIndex(npc.Position)
            --[[local grid = room:GetGridEntity(index)
            if grid and room:GetGridCollision(index) <= GridCollisionClass.COLLISION_NONE then
                room:RemoveGridEntity(index, 0, false)
            end]]
            local trashbag = FiendFolio.TrashbagGrid:Spawn(index, true, true, {["NoReward"] = true})

            local effect = Isaac.Spawn(1000,16,4,trashbag.Position,Vector.Zero,npc)
            effect.Color = mod.ColorDankBlackReal
            effect.SpriteScale = Vector(0.8,0.8)
            effect:Update()

            local creep = Isaac.Spawn(1000,26,0,trashbag.Position,Vector.Zero,npc)
            creep.SpriteScale = Vector(1.5,1.5)
            creep:Update()

            local params = ProjectileParams()
            params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
            params.FallingAccelModifier = 0.6
            for i = 1, mod:RandomInt(5,8,rng) do
                if rng:RandomFloat() <= 0.6 then
                    params.Color = Color.Default
                    params.Variant = mod:GetRandomElem(mod.TrashbaggerTable,rng)
                else
                    params.Color = mod.ColorDankBlackReal
                    params.Variant = 0
                end
                params.FallingSpeedModifier = mod:RandomInt(-8,-5,rng)
                npc:FireProjectiles(npc.Position, vec:Resized(mod:RandomInt(5,12,rng)):Rotated(mod:RandomInt(-20,20,rng)), 0, params)			
            end
            
            npc.Velocity = vec:Resized(-20)
            game:ButterBeanFart(npc.Position, 80, npc, false, false)
            sfx:Play(SoundEffect.SOUND_FART)
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
        else
            mod:spritePlay(sprite, "Shit")
        end
        npc.Velocity = npc.Velocity * 0.7
    end

    mod.QuickSetEntityGridPath(npc)

    if npc.FrameCount % 12 == 4 then
        local creep = Isaac.Spawn(1000,26,0,npc.Position,Vector.Zero,npc)
        creep:Update()
    end
end

function mod:DumptruckHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    if npc.StateFrame <= 0 and data.State == "Idle" then
        data.State = "Shit"
        data.ShitPos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
        mod:FlipSprite(npc:GetSprite(), data.ShitPos, npc.Position)
    end
end