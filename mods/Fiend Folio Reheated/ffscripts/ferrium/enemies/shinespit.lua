local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:shineSpitAI(npc)
    local target = npc:GetPlayerTarget()
    local rng = npc:GetDropRNG()
    local d = npc:GetData()

    if not d.init then
        if npc.SubType == 1 then
            d.shineSpitSparkle = 3
        else
            d.shineSpitSparkle = 10
        end
        npc.SplatColor = mod.ColorGolden
        d.init = true
    end

    if npc.FrameCount % d.shineSpitSparkle == 0 then
		local sparkle = Isaac.Spawn(1000, 7003, 0, npc.Position, Vector.Zero, npc):ToEffect()
		sparkle.RenderZOffset = -5
		sparkle.SpriteOffset = Vector(-10 + rng:RandomInt(20), -30 + rng:RandomInt(20))
		--sparkle.SpriteScale = Vector(0.3,0.3)
	end

    if npc:IsDead() then
        local cDirection = (target.Position - npc.Position)*0.035
        if cDirection:Length() < 4 then
            cDirection = cDirection:Resized(4)
        end
        local params = ProjectileParams()
		params.FallingSpeedModifier = -40
		params.FallingAccelModifier = 1
		params.BulletFlags = params.BulletFlags | ProjectileFlags.EXPLODE
        --params.Variant = 7
        params.Color = mod.ColorGolden
        params.Scale = 1.5
        local params2 = ProjectileParams()
        params2.FallingAccelModifier = 1.5
		params2.BulletFlags = params.BulletFlags | ProjectileFlags.EXPLODE
        --params.Variant = 7
        params2.Color = mod.ColorGolden

        if npc.SubType == 1 then
            local room = game:GetRoom()
            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position, cDirection, 0, params)
            for _,proj in pairs(mod:GetGatheredProjectiles()) do
                local pData = proj:GetData()
                pData.projType = "customProjectileBehavior"
				pData.customProjectileBehavior = {death = function()
                    for i=1,5 do
                        Isaac.Spawn(1000, EffectVariant.COIN_PARTICLE, 0, proj.Position, Vector(rng:RandomInt(3)+0.5, 0):Rotated(rng:RandomInt(360)), proj)
                    end
                    for i = 1, 7 do
                        Isaac.Spawn(5, 20, 0, proj.Position, Vector(mod:getRoll(5,25,rng), 0):Rotated(rng:RandomInt(360)), proj)
                    end
                    for _, entity in pairs(Isaac.FindInRadius(proj.Position, 999, EntityPartition.ENEMY)) do
                        if entity and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) and not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                            entity:AddMidasFreeze(EntityRef(npc), 1200)
                        end
                    end
                    game:ShakeScreen(20)
                    sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 0, false, 1)
                    local flash = Isaac.Spawn(1000, 7004, 0, room:GetCenterPos(), Vector.Zero, npc):ToEffect()
                    flash.RenderZOffset = 1000000
                    room:TurnGold()
                end, customFunc = function()
                    if proj.FrameCount % 3 == 0 and proj.FrameCount > 2 then
                        local dir = Vector(rng:RandomInt(5)/3.5, 0):Rotated(rng:RandomInt(360))
                        params2.HeightModifier = proj.Height+10
                        params2.Scale = 0.7
                        params2.FallingSpeedModifier = mod:getRoll(-5,20,rng)+proj.FallingSpeed
                        params2.Variant = mod.FF.BetterCoinProjectile.Var
                        mod:SetGatheredProjectiles()
                        npc:FireProjectiles(proj.Position, dir, 0, params2)
                        for _,proj3 in pairs(mod:GetGatheredProjectiles()) do
                            local pData2 = proj3:GetData()
                            pData2.projType = "customProjectileBehavior"
				            pData2.customProjectileBehavior = {death = function()
                                Isaac.Spawn(5, 20, 0, proj3.Position, Vector(mod:getRoll(1,5,rng), 0):Rotated(rng:RandomInt(360)), proj3)
                            end}
                        end
                    end

                    if proj.FrameCount % 3 == 0 then
                        local sparkle = Isaac.Spawn(1000, 7003, 0, proj.Position, Vector.Zero, npc):ToEffect()
                        sparkle.RenderZOffset = -5
                        sparkle.SpriteOffset = Vector(-10 + rng:RandomInt(20), 40+rng:RandomInt(20))+Vector(0, proj.Height)
                        --sparkle.SpriteScale = Vector(0.3,0.3)
                    end
                end}
            end
        else
            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position, cDirection, 0, params)
            for _,proj in pairs(mod:GetGatheredProjectiles()) do
                local pData = proj:GetData()
                pData.projType = "customProjectileBehavior"
				pData.customProjectileBehavior = {death = function()
                    for i=1,5 do
                        Isaac.Spawn(1000, EffectVariant.COIN_PARTICLE, 0, proj.Position, Vector(rng:RandomInt(3)+0.5, 0):Rotated(rng:RandomInt(360)), proj)
                    end
                    sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 0.3, 0, false, 1.6)
                end, customFunc = function()
                    if proj.FrameCount % 4 == 0 and proj.FrameCount > 4 then
                        local dir = Vector(rng:RandomInt(5)/3.5, 0):Rotated(rng:RandomInt(360))
                        --[[local proj2 = Isaac.Spawn(9, 0, 0, proj.Position, dir, npc):ToProjectile()
                        if proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
                            proj2.ProjectileFlags = proj2.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER
                        end
                        proj2.Height = proj.Height
                        proj2.Color = mod.ColorGolden
                        proj2.FallingAccel = 2]]
                        params2.HeightModifier = proj.Height+10
                        params2.Scale = mod:getRoll(10,80,rng)/100
                        params2.FallingSpeedModifier = mod:getRoll(-5,20,rng)+proj.FallingSpeed
                        npc:FireProjectiles(proj.Position, dir, 0, params2)
                    end
                end}
            end
        end
	end
end