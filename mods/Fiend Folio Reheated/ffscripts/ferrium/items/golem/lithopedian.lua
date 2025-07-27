local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function LithopedianFindRandomEnemy(pos, radius, ignoreFriendly)
	pos = pos or Game:GetRoom():GetCenterPos()
	radius = radius or 1000
	local targets = {}
	local target = nil
	for _, entity in pairs(Isaac.FindInRadius(pos, radius, EntityPartition.ENEMY)) do
		if entity and not (ignoreFriendly and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) and not entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
			local etype = entity.Type
			local evar = entity.Variant
			local esub = entity.SubType
			local badent = false
			for _, v in ipairs(mod.BadEnts) do
				if v[3] then if etype == v[1] and evar == v[2] and esub == v[3] then badent = true end
				elseif v[2] then if etype == v[1] and evar == v[2] then badent = true end
				elseif etype == v[1] then badent = true end
			end

			if entity.EntityCollisionClass > 0 and not badent and entity.Type ~= 4 then
				table.insert(targets, entity)
			end

            local vars = {[3] = true, [4] = true, [8] = true}
            if entity.Type == 4 and not vars[entity.Variant] then
                if entity:GetData().checkedLithopedianBomb == nil then
                    if entity:GetDropRNG():RandomInt(10) == 1 then
                        entity:GetData().checkedLithopedianBomb = false
                    else
                        entity:GetData().checkedLithopedianBomb = true
                    end
                end
            end

            if entity.Type == 4 and not entity:GetData().checkedLithopedianBomb then
                for i=1,3 do
                    table.insert(targets, entity)
                end
            end
		end
	end
	if #targets > 0 then
		target = targets[math.random(#targets)]
	end
	return target
end

function mod:lithopedianFamiliar(player) --oh god I could've just used this thing?????
    player:CheckFamiliar(mod.ITEM.FAMILIAR.STONEY_GAPER, player:HasTrinket(mod.ITEM.ROCK.LITHOPEDIAN) and 1 or 0, player:GetTrinketRNG(mod.ITEM.ROCK.LITHOPEDIAN), Isaac:GetItemConfig():GetTrinket(mod.ITEM.ROCK.LITHOPEDIAN), 0)
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local d = fam:GetData()
    local sprite = fam:GetSprite()
    local room = game:GetRoom()
    local rng = fam:GetDropRNG()
    if not d.init then
        fam.Coins = 0
        fam.Keys = 0
        fam.Hearts = 0
        d.state = "Idle"
        d.target = (LithopedianFindRandomEnemy(fam.Position, nil, true) or fam.Player)
        d.lithopedianTargetTimer = mod:getRoll(70,150,rng)
        d.lithopedianBreathingTimer = mod:getRoll(300,500,rng)
        d.speed = 1
        d.stoneySoundTimer = 0
        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        d.init = true
    else
        fam.Coins = fam.Coins+1 --General timer for breathing
        fam.Keys = fam.Keys+1 --Timer for changing target
        d.stoneySoundTimer = (d.stoneySoundTimer or 0)+1
    end

    if not mod:superExists(fam.Player) then
        fam:Remove()
    end
    
    local mult = mod.GetGolemTrinketPower(fam.Player, FiendFolio.ITEM.ROCK.LITHOPEDIAN)
    
    if mult > 1 then
        fam.CollisionDamage = fam.Player.Damage/5*mult
    else
        fam.CollisionDamage = 0
    end
    local playerDir = (fam.Player.Position-fam.Position)

    for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, 20, EntityPartition.ENEMY)) do
        if enemy.EntityCollisionClass > EntityCollisionClass.ENTCOLL_PLAYERONLY and (not mod:isFriend(enemy)) and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
            local dir = (enemy.Position-fam.Position)
            local diff = mod:GetAngleDifferenceDead(dir, playerDir)
            local adjust = false
            if math.abs(diff) < 30 then
                adjust = true
            end
            if enemy.Position:DistanceSquared(fam.Position) <= (fam.Size + enemy.Size) ^ 2 then
                local dist = enemy.Position - fam.Position
                local len = (fam.Size + enemy.Size)
                if dist:Length() < len then
                    local distToClose = dist:Resized(len)-dist
                    if adjust then
                        distToClose = distToClose:Rotated(60)
                    end
                    if distToClose:Length() > 5 then
                        distToClose = distToClose:Resized(5)
                    end
                    enemy.Velocity = enemy.Velocity + distToClose*0.5
                end
            end
        end
    end
    for _,ent in ipairs(Isaac.FindByType(9,-1,-1,false, true)) do
		if ent.Position:DistanceSquared(fam.Position) <= (fam.Size + ent.Size) ^ 2 then
			ent:Die()
		end
	end

    if d.state == "Idle" then
        if not mod:superExists(d.target) or fam.Keys > d.lithopedianTargetTimer then
            d.target = (LithopedianFindRandomEnemy(fam.Position, nil, true) or fam.Player)
            if d.target.Type == 1 and mod:IsActiveRoom() then
                d.lithopedianTargetTimer = 20
            else
                d.lithopedianTargetTimer = mod:getRoll(70,150,rng)
            end
            fam.Keys = 0
        end
		if room:GetGridCollisionAtPos(fam.Position) > 0 then
			local freepos = room:FindFreeTilePosition(fam.Position, 999999)
			fam.Velocity = mod:Lerp(fam.Velocity, (freepos - fam.Position):Resized(d.speed), 0.3)
            if d.speed < 5.5 then
                d.speed = d.speed+0.2
            end
        elseif d.target.Type == 1 and fam.Position:Distance(d.target.Position) < 50 then
            fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.2)
            d.speed = 3
            if fam.Coins > 0 then
                fam.Coins = fam.Coins-3
            end
        else
            --Isaac.Spawn(1000, 11, 0, d.target.Position, Vector.Zero, fam)
            if fam.Position:Distance(d.target.Position) < 0 then
                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.2)
                if d.speed > 2 then
                    d.speed = d.speed-0.15
                end
            else
                local guy = mod:CatheryPathFinding(fam, d.target.Position, {
                    Speed = d.speed,
                    Accel = 0.6
                })
                if not guy then
                    fam.Hearts = fam.Hearts+1
                    if fam.Hearts > 10 then
                        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.2)
                    end
                    d.target = (LithopedianFindRandomEnemy(fam.Position, nil, true) or fam.Player)
                    if d.target.Type == 1 and mod:IsActiveRoom() then
                        d.lithopedianTargetTimer = 20
                    else
                        d.lithopedianTargetTimer = mod:getRoll(70,150,rng)
                    end
                    fam.Keys = 0
                else
                    fam.Hearts = 0
                end
            end
            if d.speed < 5.5 then
                d.speed = d.speed+0.2
            end
		end

        if fam.Velocity:Length() > 1 then
            if math.abs(fam.Velocity.X) > math.abs(fam.Velocity.Y) then
                sprite.FlipX = (fam.Velocity.X < 0)
                mod:spritePlay(sprite, "WalkHori")
            else
                mod:spritePlay(sprite, "WalkVert")
            end
        else
            mod:spritePlay(sprite, "WalkIdle")
        end
        mod:spriteOverlayPlay(sprite, "HeadIdle")

        if d.stoneySoundTimer > 160 and rng:RandomInt(30) == 0 then
            sfx:Play(SoundEffect.SOUND_STONE_WALKER, 0.5, 0, false, mod:getRoll(170,230,rng)/100)
            d.stoneySoundTimer = 0
        end

        if fam.Coins > d.lithopedianBreathingTimer and rng:RandomInt(10) == 0 then
            d.state = "Resting"
            fam.Coins = 0
            d.lithopedianBreathingTimer = mod:getRoll(300,500,rng)
            sfx:Play(SoundEffect.SOUND_STONE_WALKER, 0.5, 0, false, mod:getRoll(170,230,rng)/100)
        end
    elseif d.state == "Resting" then
        if fam.Coins > 80 then
            d.state = "Idle"
            fam.Coins = 0
            fam.Keys = 0
            d.target = (LithopedianFindRandomEnemy(fam.Position, nil, true) or player)
            d.lithopedianTargetTimer = mod:getRoll(70,150,rng)
            d.speed = 0
        end

        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.5)
        sprite:RemoveOverlay()
        mod:spritePlay(sprite, "Gaspy")
    end
end, mod.ITEM.FAMILIAR.STONEY_GAPER)

function mod.lithopedianNewRoom()
    for _,stoney in ipairs(Isaac.FindByType(3, mod.ITEM.FAMILIAR.STONEY_GAPER, -1, false, false)) do
        mod.scheduleForUpdate(function()
            if stoney and stoney:Exists() then
                stoney:GetData().target = (LithopedianFindRandomEnemy(stoney.Position, nil, true) or stoney:ToFamiliar().Player)
                stoney:GetData().lithopedianTargetTimer = 80
            end
        end, 1)
    end
end