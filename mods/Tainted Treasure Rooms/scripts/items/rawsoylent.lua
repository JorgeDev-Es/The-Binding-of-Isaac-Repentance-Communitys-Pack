local mod = TaintedTreasure
local game = Game()

mod.Soylenting = false

local function GetRawSoylentAngles(player)
    local num = player:GetCollectibleNum(TaintedCollectibles.RAW_SOYLENT)
    local interval = 45/num
    return interval, 360 - interval
end

function mod:RawSoylentOnFireTear(player, tear)
    if not mod.Soylenting then
		mod.Soylenting = true
        local angle1, angle2 = GetRawSoylentAngles(player)
        for i = angle1, angle2, angle1 do
            local newtear = player:FireTear(tear.Position - tear.Velocity, tear.Velocity:Rotated(i), true, false, false, player, 0.2)
            newtear.Scale = newtear.Scale * 0.5
            newtear.Mass = newtear.Mass * 0.5
            if mod:IsDefaultColor(tear.Color) then
                newtear.Color = mod.ColorSoy
            end
        end
		mod.Soylenting = false
	end
end

function mod:RawSoylentOnFireBomb(player, bomb)
    if not mod.Soylenting then
		mod.Soylenting = true
        player:AddCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
        local angle1, angle2 = GetRawSoylentAngles(player)
        for i = angle1, angle2, angle1 do
            local newbomb = player:FireBomb(bomb.Position, bomb.Velocity:Rotated(i), player)
            --newbomb.ExplosionDamage = newbomb.ExplosionDamage * 0.2
            --newbomb.RadiusMultiplier = 0.5
            --newbomb.Scale = newbomb.Scale * 0.5
            if mod:IsDefaultColor(bomb.Color) then
                newbomb.Color = mod.ColorSoy
            end
            newbomb:GetData().TaintedRawSoylent = true
        end
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
		mod.Soylenting = false
	end
end

function mod:RawSoylentOnFireTechLaser(player, laser)
    if not mod.Soylenting then
		mod.Soylenting = true
        player:AddCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
        local angle1, angle2 = GetRawSoylentAngles(player)
        for i = angle1, angle2, angle1 do
            local newlaser = player:FireTechLaser(laser.Position, 4, Vector(1,0):Rotated(laser.AngleDegrees + i), false, true, player, 1)
            newlaser.ParentOffset = Vector.Zero
            newlaser:GetData().TaintedRawSoylent = true
        end
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
		mod.Soylenting = false
	end
end

function mod:RawSoylentOnFireBrimLaser(player, laser)
    if not mod.Soylenting then
		mod.Soylenting = true
        player:AddCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
        local angle1, angle2 = GetRawSoylentAngles(player)
        for i = angle1, angle2, angle1 do
            local newlaser = player:FireBrimstone(Vector(1,0):Rotated(laser.AngleDegrees + i), player, 0.2)
            newlaser:GetData().TaintedRawSoylent = true
            newlaser:GetData().ForceSpriteScale = Vector(0.35,0.35)
            newlaser.SpriteScale = Vector(0.35,0.35)
            newlaser.Visible = false
        end
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
		mod.Soylenting = false
	end
end

function mod:RawSoylentOnFireTechX(player, laser)
    if not mod.Soylenting then
		mod.Soylenting = true
        player:AddCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
        local angle1, angle2 = GetRawSoylentAngles(player)
        for i = angle1, angle2, angle1 do
            local newlaser = player:FireTechXLaser(laser.Position, laser.Velocity:Rotated(i), 1, player, 0.2)
            newlaser:GetData().TaintedRawSoylent = true
            newlaser.Radius = laser.Radius * 0.5
        end
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
		mod.Soylenting = false
	end
end

function mod:RawSoylentOnFireKnife(player, knife)
    if not mod.Soylenting then
		mod.Soylenting = true
        player:AddCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
        local angle1, angle2 = GetRawSoylentAngles(player)
        for i = angle1, angle2, angle1 do
            local newknife = player:FireKnife(knife.Parent, 0, false, 0, knife.Variant)
            newknife.Rotation = knife.Rotation + i
            newknife:GetData().TaintedRawSoylent = true
            newknife.SpriteScale = Vector(0.75,0.75)
            newknife.SizeMulti = newknife.SpriteScale
            newknife:Shoot(knife.Charge, knife.MaxDistance)
        end
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
		mod.Soylenting = false
	end
end

function mod:RawSoylentOnFireClub(player, knife)
    if not mod.Soylenting then
		mod.Soylenting = true
        local angle1, angle2 = GetRawSoylentAngles(player)
        for i = angle1, angle2, angle1 do
            local newtear = player:FireTear(knife.Position, player:GetLastDirection():Rotated(i):Resized(player.ShotSpeed*12), true, false, false, player, 0.2)
            newtear.Scale = newtear.Scale * 0.5
            newtear.Mass = newtear.Mass * 0.5
            if mod:IsDefaultColor(newtear.Color) then
                newtear.Color = mod.ColorSoy
            end
        end
		mod.Soylenting = false
	end
end