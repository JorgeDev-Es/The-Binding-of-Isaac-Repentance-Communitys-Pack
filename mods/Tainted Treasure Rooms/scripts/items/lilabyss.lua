local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local function LilAbyssTear(familiar, target)
    local tear = familiar:FireProjectile((target.Position - familiar.Position):Resized(1):Rotated(mod:RandomInt(-10,10))) 
    mod:MakeTearSpectral(tear, true)
    tear:ChangeVariant(TearVariant.BLOOD)
    tear.Scale = mod:RandomInt(6,10) * 0.1
    tear.Color = mod.ColorShadyRed
    tear.CollisionDamage = (tear.CollisionDamage * (familiar.Player.Damage / 3.5)) * 0.66
    tear.Mass = tear.Mass * 0.5
    tear:GetData().LilAbyssTear = true
    sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 0.7)
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    local data = familiar:GetData()
    local savedata = mod.GetPersistentPlayerData(familiar.Player)
    local sprite = familiar:GetSprite()
	local player = familiar.Player

    data.Sucked = data.Sucked or 0
    data.SuckAnimTimer = data.SuckAnimTimer or 0
    data.State = data.State or "Idle"
    data.Suffix = math.floor(data.Sucked / 3)
    savedata.LilAbyssTrinkets = savedata.LilAbyssTrinkets or 0
    savedata.LilAbyssLocusts = savedata.LilAbyssLocusts or 0
    familiar.CollisionDamage = 2 + (2 * data.Suffix)

    if data.State == "Idle" then
        local sucked
        local bulletss = {Isaac.FindByType(2), Isaac.FindByType(9)}
        for _, bullets in pairs(bulletss) do
            for _, bullet in pairs(bullets) do
                if bullet.Position:Distance(familiar.Position) <= 80 and not bullet:GetData().LilAbyssTear then
                    data.SuckAnimTimer = 15
                    bullet.Velocity = mod:Lerp(bullet.Velocity, (familiar.Position - bullet.Position):Resized(15), 0.1)
                    if bullet.Position:Distance(familiar.Position) <= 15 then
                        bullet:Remove()
                        local poof = Isaac.Spawn(1000,15,1,bullet.Position,Vector.Zero,familiar)
                        poof.Color = mod.ColorShadyRed
                        data.Sucked = data.Sucked + 1
                        if data.Sucked >= 12 then
                            data.Sucked = 0
                            data.SuckAnimTimer = 0
                            data.State = "Shoot"
                        end
                    end
                end
            end
        end

        for _, trinket in pairs(Isaac.FindByType(5, PickupVariant.PICKUP_TRINKET)) do
            if trinket.Position:Distance(familiar.Position) <= 120 then
                data.SuckAnimTimer = 15
                trinket.Velocity = mod:Lerp(trinket.Velocity, (familiar.Position - trinket.Position):Resized(5), 0.1)
                if trinket.Position:Distance(familiar.Position) <= 15 then
                    trinket:Remove()
                    local poof = Isaac.Spawn(1000,15,1,trinket.Position,Vector.Zero,familiar)
                    poof.Color = mod.ColorShadyRed
                    savedata.LilAbyssTrinkets = savedata.LilAbyssTrinkets + 1
                    if savedata.LilAbyssTrinkets >= 2 then
                        savedata.LilAbyssTrinkets = 0
                        data.SuckAnimTimer = 0
                        data.State = "Payout"
                    end
                end
            end
        end

        if data.SuckAnimTimer > 0 then
            data.SuckAnimTimer = data.SuckAnimTimer - 1
            mod:spritePlay(sprite, "Charge"..data.Suffix)
        else
            mod:spritePlay(sprite, "Idle"..data.Suffix)
        end
    
        familiar:MoveDiagonally(0.7)
    elseif data.State == "Shoot" then
        if sprite:IsFinished("Shoot") then
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            data.Shooting = true
        elseif sprite:IsEventTriggered("Stop") then
            data.Shooting = false
        else
            mod:spritePlay(sprite, "Shoot")
        end

        if data.Shooting then
            local target = mod:GetFamiliarTarget(familiar.Position)
            if target then
                LilAbyssTear(familiar, target)
                if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                    LilAbyssTear(familiar, target)
                end
            end
        end

        familiar.Velocity = familiar.Velocity * 0.7
    elseif data.State == "Payout" then
        if sprite:IsFinished("Spawn"..data.Suffix) then
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            local bug = Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 2, familiar.Position, Vector.Zero, familiar):ToFamiliar()
            bug.Player = player
            savedata.LilAbyssLocusts = savedata.LilAbyssLocusts + 1
            sfx:Play(SoundEffect.SOUND_THUMBSUP)
        else
            mod:spritePlay(sprite, "Spawn"..data.Suffix)
        end
    
        familiar.Velocity = familiar.Velocity * 0.7
    end
end, TaintedFamiliars.LIL_ABYSS)
