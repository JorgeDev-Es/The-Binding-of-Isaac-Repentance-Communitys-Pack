local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function fFetusIsInFront(npc, target, data)
    local room = game:GetRoom()
    local dirToAng = {
        [0] = "right",
        [1] = "down",
        [2] = "left",
        [3] = "up",
        [4] = "right",
    }
    if room:CheckLine(npc.Position, target.Position, 0, 0, false, false) and (math.abs(npc.Position.X-target.Position.X) < 40 or math.abs(npc.Position.Y-target.Position.Y) < 40) and not mod:isScareOrConfuse(npc) then
		local angle = math.floor((mod:GetAngleDegreesButGood(target.Position-npc.Position)+45)/90)
		data.lastDir = dirToAng[angle]
        return true
    else
        return false
    end
end

function mod:forgottenFetusAI(npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local target = npc:GetPlayerTarget()
    local targetpos = mod:randomConfuse(npc, target.Position)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.init then
        data.siblings = data.siblings or {}
        data.enraged = false
        if (npc.SubType >> 3 & 1) == 0 then
            local baby = Isaac.Spawn(mod.FF.LilAl.ID, mod.FF.LilAl.Var, 0, npc.Position + Vector(0,10):Rotated(math.random(360)), Vector.Zero, npc):ToNPC()
            table.insert(data.siblings, baby)
            baby.Parent = npc
            npc.Child = baby

            local bData = baby:GetData()
            bData.siblingOverride = true
            bData.cordLength = ((npc.SubType & 7)+1)*40
        end
        data.lastDir = "down"
        data.state = "Idle"
        data.movement = rng:RandomInt(5)+5
        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    for i, baby in pairs(data.siblings) do
		if not mod:superExists(baby) then
			table.remove(data.siblings, i)
        elseif baby:GetData().enraged then
            table.remove(data.siblings, i)
        end
	end
    if not data.enraged and #data.siblings == 0 and npc.FrameCount > 2 then
        data.enraged = true
        sfx:Play(SoundEffect.SOUND_MULTI_SCREAM, 0.7, 0, false, 0.85)
    end

    if data.state == "Idle" then
        --fuck it I'm just going to reuse peepisser movement
        if data.enraged then
            if mod:isScare(npc) then
                if npc.Velocity.X > -0.3 then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                end
                local targetvel = (targetpos - npc.Position):Resized(-7)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
            elseif game:GetRoom():CheckLine(npc.Position, targetpos, 0, 1, false, false) then
                local targetDir = (targetpos-npc.Position):Resized(5.5)
                npc.Velocity = mod:Lerp(npc.Velocity, targetDir, 0.3)
            else
                npc.Pathfinder:FindGridPath(targetpos, 0.7, 999, true)
            end

            if npc.Velocity:Length() > 0.3 then
                mod:spritePlay(sprite, "Walk " .. data.lastDir)
            else
                mod:spritePlay(sprite, "Idle down")
            end
        else
            if mod:isScare(npc) then
                if npc.Velocity.X > -0.3 then
                    sprite.FlipX = false
                else
                    sprite.FlipX = true
                end
                mod:spritePlay(sprite, "Walk " .. data.lastDir)
                local targetvel = (targetpos - npc.Position):Resized(-5)
                npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
            elseif data.movement > 0 then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
                mod:spritePlay(sprite, "Idle " .. data.lastDir)
                data.movement = data.movement-1
            elseif not data.goHere then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
                if npc.Pathfinder:HasPathToPos(target.Position) then
                    data.goHere = mod:FindClosestValidPosition(npc, target, nil, 200, 0)
                else
                    data.goHere = mod:FindRandomValidPathPosition(npc, 3, 60, 120)
                end
                data.movement = math.floor(-(npc.Position:Distance(data.goHere)*2))
            elseif data.movement < 0 then
                mod:spritePlay(sprite, "Walk " .. data.lastDir)
                data.movement = data.movement+1
                if npc.Position:Distance(data.goHere) < 25 then
                    data.movement = 10+rng:RandomInt(10)
                    data.goHere = nil
                elseif room:CheckLine(npc.Position, data.goHere, 0, 1, false, false) then
                    local targetvel = (data.goHere - npc.Position):Resized(4)
                    npc.Velocity = mod:Lerp(npc.Velocity, targetvel, 0.3)
                else
                    npc.Pathfinder:FindGridPath(data.goHere, 0.6, 900, true)
                end
            else
                data.movement = 10
                data.goHere = nil
            end
        end

        if sprite:IsEventTriggered("Step") then
            sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 0.6, 0, false, math.random(170,230)/100)
        end

        if npc.Velocity:Length() > 0.3 then
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                if npc.Velocity.X > 0 then
                    data.lastDir = "right"
                else
                    data.lastDir = "left"
                end
            else
                if npc.Velocity.Y > 0 then
                    data.lastDir = "down"
                else
                    data.lastDir = "up"
                end
            end
        end

        if npc.StateFrame > 40 and fFetusIsInFront(npc, target, data) and npc.Position:Distance(target.Position) > 100 then
            data.state = "Shoot"
        elseif npc.StateFrame > 70 and fFetusIsInFront(npc, target, data) then
            data.state = "Shoot"
        end
    elseif data.state == "Shoot" then
        if sprite:IsFinished("Spit " .. data.lastDir) then
            data.state = "Idle"
            npc.StateFrame = 0
            data.movement = 10
            data.goHere = nil
        elseif sprite:IsEventTriggered("Shoot") then
            local dirOffset = Vector.Zero
            if data.lastDir == "up" then
                dirOffset = Vector.Zero
            elseif data.lastDir == "down" then
                dirOffset = Vector(0, 10)
            elseif data.lastDir == "right" then
                dirOffset = Vector(35, 0)
            elseif data.lastDir == "left" then
                dirOffset = Vector(-35, 0)
            end


            sfx:Play(SoundEffect.SOUND_LITTLE_SPIT, 1, 0, false, 0.8)
            local params = ProjectileParams()
            params.Scale = 2
            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position+dirOffset, (target.Position-npc.Position):Resized(8), 0, params)
            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                if data.enraged then
                    proj:GetData().enragedEffect = true
                end
                proj:GetData().projType = "customProjectileBehavior"
				proj:GetData().customProjectileBehavior = {death = function()
                    local creep = Isaac.Spawn(1000, 22, 0, proj.Position, Vector.Zero, proj):ToEffect()
                    creep.SpriteScale = Vector(3,3)
                    creep.Scale = 0.7
                    creep:Update()

                    if proj:GetData().enragedEffect then
                        for i=0,4 do
                            local proj2 = Isaac.Spawn(9, 0, 0, proj.Position, (target.Position-proj.Position):Resized(mod:getRoll(14,21,rng)/2):Rotated(mod:getRoll(-20,20,rng)), proj):ToProjectile()
                            proj2.FallingAccel = (mod:getRoll(5,10,rng))/7
                            proj2.FallingSpeed = -mod:getRoll(8,18,rng)
                            proj.Scale = mod:getRoll(10,22,rng)/16
                            if proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
                                proj2.ProjectileFlags = proj2.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER
                            end
                            if proj:HasProjectileFlags(ProjectileFlags.HIT_ENEMIES) then
                                proj2.ProjectileFlags = proj2.ProjectileFlags | ProjectileFlags.HIT_ENEMIES
                            end
                            proj2.ProjectileFlags = proj2.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
                            proj2:GetData().customProjectileBehavior = {customFunc = function()
                                if proj2.FrameCount > 1 then
                                    proj2:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
                                    proj2:GetData().customProjectileBehavior = nil
                                end
                            end}
                        end
                        local fAccel = mod:getRoll(8,14,rng)/8
                        local fSpeed = -mod:getRoll(20,25,rng)
                        for i=1,8 do
                            local proj2 = Isaac.Spawn(9, 0, 0, proj.Position, Vector(0,3):Rotated(i*45), proj):ToProjectile()
                            proj2.FallingAccel = fAccel
                            proj2.FallingSpeed = fSpeed
                            if proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
                                proj2.ProjectileFlags = proj2.ProjectileFlags | ProjectileFlags.CANT_HIT_PLAYER
                            end
                            if proj:HasProjectileFlags(ProjectileFlags.HIT_ENEMIES) then
                                proj2.ProjectileFlags = proj2.ProjectileFlags | ProjectileFlags.HIT_ENEMIES
                            end
                            proj2.ProjectileFlags = proj2.ProjectileFlags | ProjectileFlags.NO_WALL_COLLIDE
                        end
                    end
                end, customFunc = function()
                    local creep = Isaac.Spawn(1000, 22, 0, proj.Position, Vector.Zero, proj):ToEffect()
                    --creep.Scale = 0.5
                    creep.Timeout = 100
                    creep:Update()

                    if proj:GetData().enragedEffect then
                        if proj.FrameCount % 3 == 0 and proj.FrameCount > 2 then
                            local trail = Isaac.Spawn(1000, 111, 0, proj.Position, RandomVector()*2, proj):ToEffect()
                            local scaler = 1.5*math.random(75,90)/100
                            trail.SpriteScale = Vector(scaler, scaler)
                            trail.SpriteOffset = Vector(0, proj.Height+12)
                            trail.DepthOffset = -80
                            trail:Update()
                        end
                    end
                end}
			end

            local poof = Isaac.Spawn(1000, 2, 160, npc.Position+Vector(0,-30)+dirOffset, Vector.Zero, npc):ToEffect()
            poof.Color = Color(1, 1, 1, 0.4, 0.6, 0.1, 0.1)
            poof.SpriteScale = Vector(1.3, 1.3)
            if data.lastDir ~= "up" then
                poof.DepthOffset = 50
            end
        else
            mod:spritePlay(sprite, "Spit " .. data.lastDir)
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    end
end

function mod:lilAlAI(npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local rng = npc:GetDropRNG()

    if not data.init then
        data.state = "Idle"
        data.cordHealth = 20

        if not data.siblingOverride then
            data.cordLength = ((npc.SubType & 7)+1)*40
        end
        
        if (npc.SubType >> 3 & 1 == 0) or npc.Parent then
            local cord = Isaac.Spawn(mod.FF.ForgottenFetusCord.ID, mod.FF.ForgottenFetusCord.Var, mod.FF.ForgottenFetusCord.Sub, npc.Position, Vector.Zero, npc):ToNPC()
            cord:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		    cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

            if npc.Parent then
                cord.Target = npc
                cord.Parent = npc.Parent
            else
                local radius = 9999
                local sibling
                for _,ent in ipairs(Isaac.FindByType(mod.FF.ForgottenFetus.ID, mod.FF.ForgottenFetus.Var, -1, false, false)) do
                    if mod:isFriend(npc) and mod:isFriend(ent) then
                        if npc.Position:Distance(ent.Position) < radius then
                            sibling = ent
                            radius = npc.Position:Distance(ent.Position)
                        end
                    elseif not mod:isFriend(npc) and not mod:isFriend(ent) then
                        sibling = ent
                        radius = npc.Position:Distance(ent.Position)
                    end
                end

                if sibling then
                    cord.Target = npc
                    cord.Parent = sibling
                    npc.Parent = sibling
                    sibling.Child = npc

                    local sData = sibling:GetData()
                    sData.siblings = sData.siblings or {}
                    table.insert(sData.siblings, npc)
                else
                    data.enraged = true
                end
            end
            npc.Child = cord
            
            cord:Update()
            cord.DepthOffset = -20
            cord:GetSprite():Play("Idle", true)
		    cord:GetSprite():SetFrame(105)
            cord.SplatColor = Color(1,1,1,1,0,0,0)
        else
            data.enraged = true
        end

        data.init = true
    else
        npc.StateFrame = npc.StateFrame+1
    end

    if not data.enraged and data.cordHealth <= 0 then
        data.enraged = true
        if npc.Child then
            npc.Child:Kill()
        end
        data.state = "Switch"
    end

    if data.state == "Idle" then
        if math.abs(npc.Velocity.Y) > math.abs(npc.Velocity.X) then
            if npc.Velocity.Y > 0 then
                mod:spritePlay(sprite, "Al up drag")
            else
                mod:spritePlay(sprite, "Al down drag")
            end
        else
            if npc.Velocity.X > 0 then
                mod:spritePlay(sprite, "Al right drag")
            else
                mod:spritePlay(sprite, "Al left drag")
            end
        end

        if npc.FrameCount % 3 == 0 then
            local creepSize = math.min(0.5, 0.5+math.sin(npc.FrameCount)/3)
            local creep = Isaac.Spawn(1000, 22, 0, npc.Position, Vector.Zero, npc):ToEffect()
            --creep.SpriteScale = Vector(creepSize, creepSize)
            creep.Scale = creepSize
            creep.Timeout = 140
            creep:Update()
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)

        if npc.Parent and npc.Parent:Exists() then
            local dist = npc.Parent.Position - npc.Position
            if dist:Length() > data.cordLength then
                local distToClose = dist - dist:Resized(data.cordLength)
                npc.Velocity = npc.Velocity + distToClose*0.5
            end
        else
            data.enraged = true
            data.state = "Switch"
        end

        mod:handleFFetusCordHitboxes(npc, npc.Parent, npc.Child)
    elseif data.state == "Enraged" then
        mod:spritePlay(sprite, "Al cry loop")

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "Switch" then
        if sprite:IsFinished("Al sit up") then
            data.state = "Switch2"
        else
            mod:spritePlay(sprite, "Al sit up")
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    elseif data.state == "Switch2" then
        if sprite:IsFinished("Al cry") then
            data.state = "Enraged"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Wimper") then
            sfx:Play(SoundEffect.SOUND_SCARED_WHIMPER, 0.8, 0, false, 2)
        elseif sprite:IsEventTriggered("Cry") then
            data.crying = true
        else
            mod:spritePlay(sprite, "Al cry")
        end

        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.3)
    end

    if data.crying then
        if npc.StateFrame % 5 == 0 then
            local params = ProjectileParams()
            params.FallingSpeedModifier = -mod:getRoll(20,25,rng)
            params.FallingAccelModifier = mod:getRoll(8,14,rng)/8
            params.Scale = mod:getRoll(10,22,rng)/16
            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position + mod:shuntedPosition(5, rng), RandomVector()*3, 0, params)
            for _, proj in pairs(mod:GetGatheredProjectiles()) do
                proj:GetData().projType = "customProjectileBehavior"
				proj:GetData().customProjectileBehavior = {death = function()
                    local creep = Isaac.Spawn(1000, 22, 0, proj.Position, Vector.Zero, proj):ToEffect()
                    creep.Scale = 0.8
                    creep:Update()
                end}
			end
        end
    end
end

--stolen from kings & pawns ty taiga
function mod:forgottenFetusHitboxAI(npc)
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	npc.Visible = false
	npc.Velocity = Vector.Zero
	npc:GetSprite().Color = Color(1,1,1,0,0,0,0)
	
	if not npc.Parent or
	   not npc.Parent:Exists() or
	   npc.Parent:IsDead() or
	   mod:isStatusCorpse(npc.Parent) or
	   npc.Parent.Type ~= mod.FF.LilAl.ID or
	   npc.Parent.Variant ~= mod.FF.LilAl.Var or
       npc.Parent:GetData().cordHealth <= 0 or
       npc.Parent:GetData().enraged == true
	then
		npc:Kill()
    end
end

function mod:handleFFetusCordHitboxes(pawn, king, cord)
	if not (not pawn or 
	        not pawn:Exists() or 
	        pawn:IsDead() or 
	        mod:isStatusCorpse(pawn) or
	        not king or 
	        not king:Exists() or 
	        king:IsDead() or 
	        mod:isStatusCorpse(king) or
	        not cord or 
	        not cord:Exists() or 
	        cord:IsDead() or 
	        mod:isStatusCorpse(cord))
	then
		local pawndata = pawn:GetData()
		
		pawndata.Hitboxes = pawndata.Hitboxes or {}
		local dist = (pawn.Position - king.Position):Length() - 30
		
		local i = 1
		while dist >= 0 do
			local hitbox = pawndata.Hitboxes[i]
			if not hitbox or not hitbox:Exists() then
				hitbox = Isaac.Spawn(mod.FF.ForgottenFetusHitbox.ID, mod.FF.ForgottenFetusHitbox.Var, 0, Vector.Zero, Vector.Zero, nil)
				pawndata.Hitboxes[i] = hitbox
				hitbox.Parent = pawn
				hitbox.Child = cord
				
				hitbox:Update()
			end
			
			hitbox.Position = (pawn.Position - king.Position):Resized(dist) + king.Position
			dist = dist - 30
			i = i + 1
		end
		
		for j = #pawndata.Hitboxes, i, -1 do
			pawndata.Hitboxes[j]:Remove()
			pawndata.Hitboxes[j] = nil
		end
	end
end

function mod:forgottenFetusHitboxHurt(entity, damage, flags, source, countdown)
	if entity.Child and damage > 0.0 then
        local data = entity.Child:GetData()
        local data2 = entity.Parent:GetData()
		data2.cordHealth = (data2.cordHealth or 20)-damage
		data.LastDamageFrame = entity.Child.FrameCount
		return false
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, cord)
	if cord.Variant == mod.FF.ForgottenFetusCord.Var and cord.SubType == mod.FF.ForgottenFetusCord.Sub then
		local data = cord:GetData()
		local sprite = cord:GetSprite()
        
		local frame = sprite:GetFrame()
		if data.LastDamageFrame == nil or cord.FrameCount - data.LastDamageFrame > 2 then
			sprite:SetFrame("Idle", frame)
		else
			sprite:SetFrame("DamageFlash", frame)
		end
	end
end, EntityType.ENTITY_EVIS)

function mod:forgottenFetusColl(npc, coll, bool)
    if coll.Type == mod.FF.LilAl.ID and coll.Variant == mod.FF.LilAl.Var then
        return true
    end
end