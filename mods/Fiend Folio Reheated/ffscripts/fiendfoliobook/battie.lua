local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

function mod:famBattie(fam, player, sprite, d)
    local r = fam:GetDropRNG()
    local room = game:GetRoom()

	if not d.init then
		d.init = true
        mod:spritePlay(sprite, "Idle")
		fam.SpriteOffset = Vector(0, -25)
        d.state = "charge"
        d.slamattackcount = 0
		d.chargeattackcount = 0
        d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
        fam.Position = Vector(d.target.Position.X, -100)
        d.lerpness = 1
        fam.CollisionDamage = 10
        
	end

    if d.state == "charge" then
        --Initialise the charge, and set how many times she should charge
        if not d.chargestate then
            fam.Velocity = fam.Velocity * 0.85
            if sprite:IsFinished("ChargeStart") then
                mod:spritePlay(sprite, "Charge")
                d.chargestate = "go"
                fam:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                --Either 3 or 5 charges will occur
                d.maxcharges = 3 + r:RandomInt(3)
            else
                mod:spritePlay(sprite, "ChargeStart")
            end

        --Actually performing the charge
        elseif d.chargestate == "go" then
            mod:spritePlay(sprite, "Charge")
            
            if sprite:GetFrame() == 4 then
                sfx:Play(mod.Sounds.WingFlap,0.5,0,false,math.random(130,150)/100)
            end
            local add = Vector(0, 0)
            local homeStrength = 50
            
            d.target = d.target or (mod.FindRandomEnemy(player.Position, nil, true) or player)
            local target = d.target

            homeStrength = (fam.Position.X - target.Position.X) / 10

            d.lerpness = d.lerpness or 1
            d.lerpness = mod:Lerp(d.lerpness, 0.03, 0.05)
            fam.Velocity = mod:Lerp(fam.Velocity, Vector((homeStrength * -1) / 3, 20), d.lerpness)
            --Move her to the top of the screen if she goes down far enough
            local chargecomplete
            if fam.Position.Y > (room:GetGridHeight() * 40) + 300 then
                d.chargecount = d.chargecount or 0
                d.chargecount = d.chargecount + 1
                if d.chargecount > 3 then
                    if fam.Position.Y > (room:GetGridHeight() * 40) + 500 then
                        d.chargestate = "slam"
                        fam.Position = (mod.FindRandomEnemy(player.Position, nil, true) or player).Position
                        local batties = Isaac.FindByType(mod.FF.Battie.ID, mod.FF.Battie.Var, -1, false, false)
                        if #batties > 0 then
                            fam.Position = batties[1].Position
                        end
                        fam.Velocity = nilvector
                        mod:spritePlay(sprite, "FlyDown")
                        fam.SpriteOffset = Vector(0,-15)
                    end
                else
                    chargecomplete = true
                end
            end

            if chargecomplete then
                d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
                fam.Position = Vector(d.target.Position.X, -100)
                d.lerpness = 1
            end

            --The projectiles
            if fam.FrameCount % 2 == 0 then
                local tear = Isaac.Spawn(2, 1, 0, fam.Position, nilvector, fam):ToTear()
                tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                tear:Update()
                sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
            end
        elseif d.chargestate == "slam" then
            fam.Velocity = nilvector
            if sprite:IsFinished("FlyDown") then
                d.chargestate = "leave"
            --Called in the animation when she finally hits the ground
            elseif sprite:IsEventTriggered("SlamJam") then
                if game:GetRoom():GetType() == RoomType.ROOM_BOSS then
                    local batties = Isaac.FindByType(mod.FF.Battie.ID, mod.FF.Battie.Var, -1, false, false)
                    if #batties > 0 then
                        for _, batty in pairs(batties) do
                            if batty.Position:Distance(fam.Position) < 100 then
                                Isaac.Spawn(5, 100, mod.ITEM.COLLECTIBLE.BABY_BADGE, batty.Position, Vector.Zero, nil)
                                batty:Kill()
                                break
                            end
                        end
                    end
                end

                --Some effects to make it look cool
                game:ShakeScreen(15)
                sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.6,2,false,1.7)

                --Crackwave
                local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, fam.Position, nilvector, player):ToEffect()
                wave.Parent = player
                wave.MaxRadius = 100

                --Projectiles
                local params = ProjectileParams()
                params.BulletFlags = params.BulletFlags | ProjectileFlags.BOOMERANG | ProjectileFlags.CURVE_LEFT
                for i = 45, 360, 45 do
                    --npc:FireProjectiles(npc.Position, Vector(0,10 * speedmulti):Rotated(i), 0, params)
                end
            else
                mod:spritePlay(sprite, "FlyDown")
            end
        elseif d.chargestate == "leave" then
            fam.SpriteOffset = mod:Lerp(fam.SpriteOffset, Vector(0, -125), 0.02)
            fam.Color = Color(fam.Color.R * 0.99,fam.Color.G * 0.99,fam.Color.B * 0.99,fam.Color.A * 0.99)
            if not d.dir then
                local wall = mod:GetClosestWall(fam.Position)
                d.dir = wall - fam.Position
            end
            mod:spritePlay(sprite, "Idle")
            if sprite:GetFrame() == 10 then
				--Flapcount determines rotation on velocity, so each flap is rotated by either -30 or 30 degrees
				--this is a dumb lazy way of doing it though.
				if d.flapcount == 0 then
					d.flapcount = 60
				else
					d.flapcount = 0
				end
				--Only updates her velocity in a flap every ten frames
				fam.Velocity = (d.dir):Resized(10):Rotated(-30 + d.flapcount)
                fam.Velocity = fam.Velocity * 0.9
				sfx:Play(mod.Sounds.WingFlap,0.5 * fam.Color.A,0,false,math.random(70,90)/100)
			end
            if fam.Color.A < 0.02 then
                fam:Remove()
            end
        end
    end
end