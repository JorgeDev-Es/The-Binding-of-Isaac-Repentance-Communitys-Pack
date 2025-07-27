local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local SwordfishBlood = Sprite()
SwordfishBlood:Load("gfx/familiar/familiar_swordfish_blood.anm2")

local function SwordfishTear(familiar, data, angle)
    local tear = familiar:FireProjectile(Vector(1.2,0):Rotated(angle + mod:RandomInt(-10,10))) 
    tear.CollisionDamage = tear.CollisionDamage / 3
    tear.Scale = mod:RandomInt(4,8) * 0.1
    tear.Mass = tear.Mass * 0.5
    sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.7)
    data.Distance = data.Distance - (data.SkewerDistance * 0.05)
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    local data = familiar:GetData()
    local savedata = mod.GetPersistentPlayerData(familiar.Player)
    local sprite = familiar:GetSprite()
	local player = familiar.Player

    if not data.Init then
        familiar:SetSize(10, Vector(2.5,1), 12)
        familiar.SpriteOffset = Vector(0,-12)
        data.Distance = 30
        data.SkewerCooldown = 0
        data.State = "Idle"
        data.Init = true
    end

    if player then
        if data.State == "Idle" then
            if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                data.SkewerCooldown = data.SkewerCooldown - 0.010
            else
                data.SkewerCooldown = data.SkewerCooldown - 0.005
            end
            
            data.Distance = mod:Lerp(data.Distance, mod:Sway(30, 120, 90, 2, 2, familiar.FrameCount), 0.25)
            mod:spritePlay(sprite, "Idle")
        elseif data.State == "Skewer" then
            if data.SkewerTarget and data.SkewerTarget:Exists() then
                data.Distance = mod:Lerp(data.Distance, data.SkewerDistance, 0.25)
                data.SkewerTarget.Velocity = (familiar.TargetPosition + Vector(30,0):Rotated(sprite.Rotation)) - data.SkewerTarget.Position

                data.SkewerTime = data.SkewerTime - 1
                if data.SkewerTime <= 0 then
                    data.State = "Launch"
                end
            else
                data.State = "Idle"
            end

            if not sprite:IsPlaying("StabSmall") then
                mod:spritePlay(sprite, "Idle")
            end
        elseif data.State == "Launch" then
            if sprite:IsFinished("LaunchSmall") then
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Shoot") then
                local vel = Vector(25,0):Rotated(sprite.Rotation)
            
                local edata = data.SkewerTarget:GetData()
                data.SkewerTarget.Velocity = vel
                data.SkewerTarget:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
                edata.ForcedKnockbackTimer = 20
                edata.ForcedKnockbackVel = vel
                edata.ForcedKnockbackImpactDamage = true
                edata.SwordfishKebab = false

                sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
                data.SkewerTarget = nil
            else
                mod:spritePlay(sprite, "LaunchSmall")
            end

            if sprite:WasEventTriggered("Shoot") then
                if not sprite:WasEventTriggered("Stop") then
                    SwordfishTear(familiar, data, sprite.Rotation)
                end
            else
                if data.SkewerTarget and data.SkewerTarget:Exists() then
                    data.Distance = mod:Lerp(data.Distance, data.SkewerDistance, 0.25)
                    data.SkewerTarget.Velocity = (familiar.TargetPosition + Vector(30,0):Rotated(sprite.Rotation)) - data.SkewerTarget.Position
                end
            end
        end
        familiar.TargetPosition = player.Position + Vector(data.Distance,0):Rotated(sprite.Rotation)
        familiar.Velocity = familiar.TargetPosition - familiar.Position
    end
end, TaintedFamiliars.SWORDFISH)

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, familiar)
    local data = familiar:GetData()
    local sprite = familiar:GetSprite()
	local player = familiar.Player

    if data.Init then
        if data.SkewerCooldown > 0 then
            SwordfishBlood:SetFrame(sprite:GetAnimation(), sprite:GetFrame())
            local color = Color.Lerp(familiar.SplatColor, Color.Default, 0) --If I try calling SetTint() on familiar.SplatColor directly it wont work bc idk lol???
            color:SetTint(1,1,1,data.SkewerCooldown)
            SwordfishBlood.Color = color
            SwordfishBlood.Scale = sprite.Scale
            SwordfishBlood.Rotation = sprite.Rotation
            SwordfishBlood.Offset = familiar.SpriteOffset
            SwordfishBlood:Render(Isaac.WorldToScreen(familiar.Position))
        end

        if mod:IsNormalRender() then
            if not (data.State == "Launch" and sprite:WasEventTriggered("Shoot") and not sprite:WasEventTriggered("Stop")) then
                sprite.Rotation = mod:LerpAngleDegrees(sprite.Rotation, mod:GetHeadDirection(player), 0.1)
            end
        end
    end           
end, TaintedFamiliars.SWORDFISH)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, collider)
    local data = familiar:GetData()
    if data.State == "Idle" and data.SkewerCooldown <= 0 then
        if collider:ToNPC() 
        and collider.FrameCount > 10 
        and not (collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) 
        or collider:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) 
        or collider:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		or collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            data.SkewerTarget = collider
            data.SkewerTime = 20
            data.SkewerDistance = collider.Size + 45
            data.SkewerCooldown = 1
            data.State = "Skewer"
            familiar.SplatColor = collider.SplatColor
            familiar:GetSprite():Play("StabSmall")
            collider:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            collider:GetData().SwordfishKebab = true
            sfx:Play(SoundEffect.SOUND_KNIFE_PULL)
            sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
        end
    end
end, TaintedFamiliars.SWORDFISH)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, npc)
    if npc:GetData().SwordfishKebab then
        return true
    end
end)