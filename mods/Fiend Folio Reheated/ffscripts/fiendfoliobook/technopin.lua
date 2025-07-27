local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

function mod:famTechnopin(fam, player, sprite, d)
    local room = game:GetRoom()
    if not d.init then
        d.attackCount = 0
        d.state = "attack"
        sprite:ReplaceSpritesheet(2, "gfx/bosses/champions/pin/boss_pin_techno_dirt.png")
        sprite:LoadGraphics()
        fam.Position = mod:FindRandomFreePos(fam)
        fam.TargetPosition = fam.Position
        d.init = true
    end

    if d.state == "attack" then
        if sprite:IsFinished("AttackFast") then
            mod:spritePlay(sprite, "HoleClose")
            d.state = "wait"
        elseif sprite:IsEventTriggered("Chargesound") then
            sfx:Play(mod.Sounds.EpicTwinkle,2,0,false,1.8)
        elseif sprite:IsEventTriggered("Attack") then
            local target = mod.FindClosestEnemy(fam.Position, 1250, true) or player
            local ang
            ang = (target.Position - Vector(8,-67) - fam.Position):GetAngleDegrees()
            local laser = EntityLaser.ShootAngle(2, fam.Position, ang, 10, nilvector, player)
            laser.DepthOffset = 500
            laser.Parent = fam
            laser.Position = fam.Position + Vector(8,-67)
            laser.DisableFollowParent = true
            laser.CollisionDamage = 25
            --laser:SetMaxDistance(500)
            laser:AddTearFlags(TearFlags.TEAR_BOUNCE)
            laser.OneHit = true
            laser:Update()
            d.attackCount = d.attackCount + 1
        else
            mod:spritePlay(sprite, "AttackFast")
        end
    elseif d.state == "wait" then
        if sprite:IsFinished("HoleClose") then
            fam.Visible = false
            if d.attackCount >= 4 or room:IsClear() then
                fam:Remove()
            else
                d.count = d.count or 0
                d.count = d.count + 1
                if math.random(5) == 1 then
                    fam.Visible = true
                    fam.Position = mod:FindRandomFreePos(fam)
                    fam.TargetPosition = fam.Position
                    d.state = "attack"
                    d.count = 0
                end
            end
        end
    end

    fam.Velocity = fam.TargetPosition - fam.Position
end