local mod = FiendFolio
local sfx = SFXManager()
local game = Game()

function mod:alfilAI(npc)
    local target = npc:GetPlayerTarget()
	local rng = npc:GetDropRNG()
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local room = game:GetRoom()

    if not data.init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        data.alfilCooldown = 0
        local color = Color(1,1,1,1,0,0,0)
        color:SetColorize(0.12,0.24,0.24,1)
        npc.SplatColor = color

        data.alfilDummyEffect = mod:AddDummyEffect(npc, Vector(0,-30*npc.SpriteScale.Y))
        data.init = true
    end

    if data.alfilCooldown > 0 then
        data.alfilCooldown = data.alfilCooldown-1
    end

    if npc.Velocity:Length() > 0.3 then
        sprite.FlipX = false
        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            if npc.Velocity.X > 0 then
                mod:spritePlay(sprite, "WalkRight")
            else
                mod:spritePlay(sprite, "WalkLeft")
            end
        else
            if npc.Velocity.Y > 0 then
                mod:spritePlay(sprite, "WalkDown")
            else
                mod:spritePlay(sprite, "WalkUp")
            end
        end
    else
        mod:spritePlay(sprite, "Idle")
    end

    if npc.State == 4 then
        if npc.StateFrame > 20 and target.Position:Distance(npc.Position) < 250 and not mod:isScareOrConfuse(npc) and room:CheckLine(npc.Position, target.Position, 1) then
            local xAxis = math.abs(npc.Position.X - target.Position.X) < 30
            local yAxis = math.abs(npc.Position.Y - target.Position.Y) < 30

            if math.abs(npc.Velocity.X) < math.abs(npc.Velocity.Y) then
                if xAxis then
                    if npc.Velocity.Y < 0 and npc.Position.Y > target.Position.Y then
                        npc.State = 10
                        data.charge = Vector(0,-7)
                    elseif npc.Position.Y < target.Position.Y then
                        npc.State = 10
                        data.charge = Vector(0,7)
                    end
                end
            else
                if yAxis then
                    if npc.Velocity.X < 0 and npc.Position.X > target.Position.X then
                        npc.State = 10
                        data.charge = Vector(-7, 0)
                    elseif npc.Position.X < target.Position.X then
                        npc.State = 10
                        data.charge = Vector(7, 0)
                    end
                end
            end

            if (xAxis or yAxis) and rng:RandomInt(15) == 0 then
                npc.State = 10
                if xAxis then
                    if npc.Position.Y > target.Position.Y then
                        data.charge = Vector(0,-7)
                    else
                        data.charge = Vector(0,7)
                    end
                else
                    if npc.Position.X > target.Position.X then
                        data.charge = Vector(-7,0)
                    else
                        data.charge = Vector(7,0)
                    end
                end
            end
        end
    elseif npc.State == 10 then
        npc.Velocity = mod:Lerp(npc.Velocity, data.charge or Vector.Zero, 0.3)
        if npc:CollidesWithGrid() then
            npc.State = 4
            npc.StateFrame = 0
        end
    end
end

function mod:alfilHurt(npc, damage, flag, source)
    if damage > 0 then
        local validEnemies = {}
        for _,enemy in ipairs(Isaac.FindInRadius(npc.Position, 999, EntityPartition.ENEMY)) do
            if enemy:IsActiveEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) and not (enemy.Type == mod.FF.Alfil.ID and enemy.Variant == mod.FF.Alfil.Var)  then
                if not mod:isAlfilBlacklist(enemy) and not enemy:GetData().eternalFlickerspirited and not mod:isFriend(enemy) then
                    table.insert(validEnemies, enemy)
                end
            end
        end

        if #validEnemies > 0 then
            local rng = npc:GetDropRNG()
            local data = npc:GetData()
            local chosen = validEnemies[rng:RandomInt(#validEnemies)+1]
            data.alfilCooldown = data.alfilCooldown or 0

            if data.alfilCooldown <= 0 then
                local params = ProjectileParams()
                params.Color = FiendFolio.ColorBishopWhite
                params.FallingAccelModifier = 0
                params.FallingSpeedModifier = 0

                npc:ToNPC():FireProjectiles(chosen.Position, Vector(10, 0), 7, params)
                data.alfilCooldown = 10
            end

            local shield = Isaac.Spawn(1000, EffectVariant.BISHOP_SHIELD, 0, npc.Position, Vector.Zero, npc):ToEffect()
            shield.Target = data.alfilDummyEffect or npc
            shield.Parent = chosen
            shield.SpriteScale = Vector(1.1,1.1)
            shield.DepthOffset = 50*npc.SpriteScale.Y
            shield:Update()
            sfx:Play(SoundEffect.SOUND_BISHOP_HIT, 1, 0, false, 1)

            return false
        else
            --[[local data = npc:GetData()
            if data.alfilCooldown <= 0 then
                local params = ProjectileParams()
                params.Color = FiendFolio.ColorBishopWhite
                params.FallingAccelModifier = 0
                params.FallingSpeedModifier = 0
                npc:ToNPC():PlaySound(SoundEffect.SOUND_STONESHOOT, 1, 0, false, 1)

                npc:ToNPC():FireProjectiles(npc.Position, Vector(10, 0), 7, params)
                data.alfilCooldown = 10
            end]]
            return nil
        end
    end
end

function mod:isAlfilBlacklist(entity)
	return mod.alfilBlacklist[entity.Type] or
        mod.alfilBlacklist[entity.Type .. " " .. entity.Variant] or
        mod.alfilBlacklist[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
    if e.SpawnerEntity and e.FrameCount == 0 then
        if e.SpawnerEntity.Type == mod.FF.Alfil.ID and e.SpawnerEntity.Variant == mod.FF.Alfil.Var then
            local sprite = e:GetSprite()
            if sprite:GetAnimation() == "BloodGib01" or sprite:GetAnimation() == "BloodGib02" or sprite:GetAnimation() == "BloodGib03" then
                local color = Color(1,1,1,1,0,0,0)
                color:SetColorize(0.4,0.6,0.6,1)
                e.Color = color
            else
                local color = Color(1,1,1,1,0,0,0)
                color:SetColorize(0.8,0.8,0.8,1)
                e.Color = color
            end
        end
    end
end, EffectVariant.BLOOD_PARTICLE)