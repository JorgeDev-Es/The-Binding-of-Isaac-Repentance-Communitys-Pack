local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod.FFBookSlam = {
    StandardIssue = 100,
    Wimpy = 101,
    Stoney = 102,
    Pale = 103,
    Smore = 104,
    Septic = 105,
    Stompy = 106,
    Doomer = 107,
    Marzy = 108,
    Flinty = 109,
    Rancor = 110,
    Quaker = 111,
    Shaker = 112,
    Hoster = 113,
    Slimer = 114,
    Cracker = 115,
    Thwammy = 116,
}

local availableForVariety = {
    mod.FFBookSlam.Stoney,
    mod.FFBookSlam.Pale,
    mod.FFBookSlam.Smore,
    mod.FFBookSlam.Septic,
    mod.FFBookSlam.Stompy,
    mod.FFBookSlam.Doomer,
    mod.FFBookSlam.Marzy,
    mod.FFBookSlam.Flinty,
    mod.FFBookSlam.Rancor,
    mod.FFBookSlam.Quaker,
    mod.FFBookSlam.Shaker,
    mod.FFBookSlam.Hoster,
    mod.FFBookSlam.Slimer,
    mod.FFBookSlam.Cracker,
}

local grudgeVecs = {
	["RIGHT"] = Vector(1, 0),
	["LEFT"] = Vector(-1, 0),
	["DOWN"] = Vector(0, 1),
	["UP"] = Vector(0, -1)
}

local function spawnAshFamiliar(npc,pos)
	local ash = Isaac.Spawn(1000, 45, 7001, pos, Vector.Zero, npc):ToEffect()
	ash.Scale = 1
	ash:GetData().Spawner = npc
    ash:GetData().friendlyOnly = true
	ash.SpawnerEntity = npc
    ash:SetTimeout(50)
    ash:GetData().burntime = 45
	ash:Update()
	local s = ash:GetSprite()
	s:Load("gfx/effects/1000.092_creep (ash).anm2",true)
	local rand = math.random(6)
	s:Play("SmallBlood0" .. rand,true)
	local d = npc:GetData()
	table.insert(d.AshTable, ash)
end

function mod:famSlammer(fam, player, sprite, d)
    local rng = fam:GetDropRNG()

    if not d.init then
        fam.Visible = false
        fam.Color = Color(1,1,1,0,0,0,0)

        d.slamCount = 0
        d.state = "shockTroops"
        fam.Coins = 0
        d.init = true
    else
        fam.Coins = fam.Coins+1
    end

    if d.state == "shockTroops" then
        if fam.Coins % 17 == 0 then
            d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
            local subt = 100
            if d.slamCount < 2 then
                subt = mod.FFBookSlam.Wimpy
            elseif d.slamCount < 4 then
                subt = mod.FFBookSlam.StandardIssue
            elseif d.slamCount < 7 then
                subt = availableForVariety[rng:RandomInt(#availableForVariety)+1]
            elseif d.slamCount == 9 then
                subt = mod.FFBookSlam.Thwammy
            end
            --subt = 110
            if d.slamCount < 9 and d.slamCount > 6 then
            else
                local slamFam = Isaac.Spawn(3, FamiliarVariant.FF_BOOK_HELPER, subt, d.target.Position, Vector.Zero, player):ToFamiliar()
                slamFam:GetData().target = d.target
                slamFam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                slamFam:Update()
            end
            d.slamCount = d.slamCount+1
            if d.slamCount == 10 then
                fam:Remove()
            end
        end
    end
end

local function getSlammerInfo(fam, player, d, sprite, rng)
    local sub = fam.SubType
    if sub == mod.FFBookSlam.StandardIssue then
        return {slammage = player.Damage*5, damage = player.Damage/3}
    elseif sub == mod.FFBookSlam.Wimpy then
        return {slammage = player.Damage*2, damage = player.Damage/3,
        jumpSound = function() sfx:Play(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1.4) end,
        landSound = function() sfx:Play(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1.4) end,}
    elseif sub == mod.FFBookSlam.Stoney then
        return {slammage = player.Damage, damage = 0,
        jumpSound = function() sfx:Play(SoundEffect.SOUND_SHELLGAME,1,2,false,0.7) end,
        landSound = function() sfx:Play(SoundEffect.SOUND_POT_BREAK,1,2,false,1) end,
        landFunc = function()
            game:ShakeScreen(6)
            local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, fam.Position, Vector.Zero, fam):ToEffect()
            wave.Parent = player
            wave.MaxRadius = 50
            --wave.CollisionDamage = player.Damage+5
        end,}
    elseif sub == mod.FFBookSlam.Pale then
        return {slammage = player.Damage, damage = 0,
        landFunc = function()
        local creep = Isaac.Spawn(1000, 46, 0, fam.Position, Vector.Zero, fam)
		creep.SpriteScale = creep.SpriteScale * 2
        creep.CollisionDamage = player.Damage/4
        creep:Update()
		for i = 1, 3 do
			local creep2 = Isaac.Spawn(1000, 46, 0, fam.Position + (Vector.FromAngle(i * (360 / 3)) * 22), Vector.Zero, fam)
            creep2.CollisionDamage = player.Damage/4
		end
		for i = 30, 360, 30 do
			--params.VelocityMulti = 0.65 + mod:RandomInt(0,4) * 0.2
            local rand = rng:RandomFloat()
            local tear = Isaac.Spawn(2, 1, 0, fam.Position, Vector(0,4):Rotated(i-40+rand*80), fam):ToTear()
            tear.FallingSpeed = -1 * (mod:getRoll(5, 20,rng))
            tear.FallingAcceleration = 2
            tear:GetData().dontHitImmediately = 10
            tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            tear.CollisionDamage = player.Damage
        end
        end,}
    elseif sub == mod.FFBookSlam.Smore then
        return {slammage = player.Damage*5, damage = player.Damage/3,
        initFunc = function()
            d.AshTable = {}
        end,
        landFunc = function()
            for _,ash in ipairs(d.AshTable) do
                if ash:Exists() then
                    mod.scheduleForUpdate(function()
                        ash:GetData().flaming = true
                    end, math.max(0, ash.FrameCount-7))
                end
            end
        end,
        override = "Smore",
        smoreInit = true,}
    elseif sub == mod.FFBookSlam.Septic then
        return {slammage = player.Damage*5, damage = player.Damage/3,
        smoreInit = true,
        override = "Smore"}
    elseif sub == mod.FFBookSlam.Stompy then
        return {slammage = player.Damage*7, damage = player.Damage,
        landFunc = function()
            local rangle = rng:RandomInt(360)
            local creep = Isaac.Spawn(1000, 46, 0, fam.Position, Vector.Zero, fam):ToEffect()
			creep.SpriteScale = creep.SpriteScale * 2
			creep:SetTimeout(60)
            creep.CollisionDamage = player.Damage/4
			creep:Update()
			for i = 72, 360, 72 do
                local tear = Isaac.Spawn(2, 1, 0, fam.Position, Vector(0,7):Rotated(i+rangle), fam):ToTear()
                tear:GetData().dontHitImmediately = 8
                tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                tear.CollisionDamage = player.Damage*2
                tear.FallingAcceleration = 0.2
			end
        end,}
    elseif sub == mod.FFBookSlam.Doomer then
        return {slammage = player.Damage*5, damage = player.Damage/2, laserDamage = player.Damage}
    elseif sub == mod.FFBookSlam.Marzy then
        return {slammage = player.Damage*5, damage = player.Damage/2, tearDamage = player.Damage*2,
        landFunc = function()
            for i = 1, mod:RandomInt(1,2) do
                local maggotvel = Vector(0,mod:getRoll(1,3,rng)):Rotated(rng:RandomInt(360))
                local mag = mod.ThrowMaggot(fam.Position, maggotvel, -5, mod:RandomInt(-20, -10), fam)
                mag:AddCharmed(EntityRef(player), -1)
            end
			d.WormyShoot = 3
			d.WormPoint = fam.Position
			d.WormVec = RandomVector()
			local effect = Isaac.Spawn(1000,7,0,fam.Position,Vector.Zero,fam)
			effect.Color = mod.ColorStinkyCheese
			effect = Isaac.Spawn(1000,16,3,fam.Position,Vector.Zero,fam)
			effect.Color = mod.ColorStinkyCheese
			effect.SpriteScale = effect.SpriteScale * 0.6
        end,}
    elseif sub == mod.FFBookSlam.Flinty then
        return {slammage = player.Damage*5, damage = player.Damage/2, explosionDamage = player.Damage*4+10,}
    elseif sub == mod.FFBookSlam.Rancor then
        return {slammage = player.Damage*5, damage = player.Damage*1.5, override = "Rancor",
        jumpSound = function() sfx:Play(SoundEffect.SOUND_STONE_IMPACT,0.35,2,false,0.8) end,
        initFunc = function()
            d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
            d.goHere = mod:RancorSnapToTile(room, d.target.Position)
            d.crosshair = Isaac.Spawn(1000, 7013, 3, d.goHere, Vector.Zero, fam)
            d.crosshair.Parent = fam
            fam.Position = d.goHere
            d.crosshair:Update()
            d.targetVelocity = Vector.Zero
        end,}
    elseif sub == mod.FFBookSlam.Quaker then
        return {slammage = player.Damage*6, damage = player.Damage/2, tearDamage = player.Damage*2,
        jumpSound = function() sfx:Play(SoundEffect.SOUND_SHELLGAME,1,2,false,0.7) end,
        landSound = function() sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1) end,
        landFunc = function()
            for _,grid in ipairs(mod.GetGridEntities()) do
				if grid.Position:Distance(fam.Position) < 65 then
					grid:Destroy()
				end
			end
            game:MakeShockwave(fam.Position, 0.035, 0.03, 8)
            for i=90,360,90 do
                local tear = Isaac.Spawn(2, 42, 0, fam.Position, Vector(0,8):Rotated(i), fam):ToTear()
                tear:GetData().dontHitImmediately = 8
                tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
            if not mod:superExists(d.target) then
                d.target = (mod.FindRandomEnemy(fam.Position, nil, true) or player)
            end
            local dir = (d.target.Position-fam.Position)
            for i=1,15 do
                mod.scheduleForUpdate(function()
                    local pos = fam.Position+dir:Resized(i*12)+mod:shuntedPosition(80, rng)
                    local tear = Isaac.Spawn(2, 42, 0, pos, Vector(mod:getRoll(1,10,rng)/7, 0):Rotated(rng:RandomInt(360)), fam):ToTear()
                    tear.Height = -600+mod:getRoll(-200,-10,rng)
                    tear.FallingAcceleration = 2
                    tear.FallingSpeed = 12
                    tear:GetData().dontHitAbove = true
                    tear.Scale = mod:getRoll(6,12,rng)/10
                    tear:Update()
                    sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
                end, i+rng:RandomInt(12))
            end
        end,}
    elseif sub == mod.FFBookSlam.Shaker then
        return {slammage = player.Damage*5, damage = player.Damage/2, tearDamage = player.Damage*6,
        jumpSound = function() sfx:Play(SoundEffect.SOUND_SHELLGAME,1,2,false,0.7) end,
        landSound = function() sfx:Play(SoundEffect.SOUND_FETUS_LAND,1,0,false,1.6) end,
        landFunc = function()
            local poof = Isaac.Spawn(1000, 59, 0, fam.Position, Vector.Zero, fam):ToEffect()
			poof:SetTimeout(20)
			poof.SpriteScale = Vector(0.6, 0.6)
			poof:Update()
        end,
        smoreInit = true, override = "Smore"}
    elseif sub == mod.FFBookSlam.Hoster then
        return {slammage = player.Damage*5, damage = player.Damage/2, tearDamage = player.Damage*5,
        landSound = function() sfx:Play(SoundEffect.SOUND_BONE_BOUNCE, 1, 0, false, 1) end,
        jumpSound = function() sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 0.7) end,}
    elseif sub == mod.FFBookSlam.Slimer then
        return{slammage = player.Damage*5, damage = player.Damage/2, tearDamage = player.Damage*3, override = "Slimer",
        initFunc = function()
            local near
            for _,creep in ipairs(Isaac.FindByType(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, false, false)) do
                if fam.Position:Distance(creep.Position) < creep.Size*creep.SpriteScale.X then
                    if creep:ToEffect().Timeout > 25 then
                        near = true
                    end
                end
            end
            if near then
                d.landing = true
            else
                d.landing = false
            end
            d.state = "Landing"
        end,}
    elseif sub == mod.FFBookSlam.Cracker then
        return {slammage = player.Damage*5, damage = player.Damage/2, tearDamage = player.Damage*2,
        landSound = function() sfx:Play(SoundEffect.SOUND_BONE_SNAP, 0.6, 0, false, math.random(8, 12)/10) end,
        jumpSound = function() sfx:Play(SoundEffect.SOUND_BONE_SNAP, 0.6, 0, false, 1.8) end,
        landFunc = function()
            d.state = "Waiting"
            fam.Coins = 0
            for i=90,360,90 do
                local tear = Isaac.Spawn(2, 29, 0, fam.Position, Vector(10,0):Rotated(45+i), fam):ToTear()
                tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                local td = tear:GetData()
                td.origpos = fam.Position
                tear.Parent = fam
				tear.FallingSpeed = 0
				tear.FallingAcceleration = -0.1
				td.rot = 0
                local s = tear:GetSprite()
				s:Load("gfx/projectiles/boomerang rib big.anm2",true)
				s:Play("spin",false)
                tear:AddTearFlags(TearFlags.TEAR_PIERCING)

                td.customTearBehavior = {customFunc = function()
                    if td.origpos then
                        local resize = 10
                        if td.rot == 0 then
                            resize = 12
                        end
                        local targetvel = (td.origpos - tear.Position):Resized(resize)
                        td.rot = td.rot / (1 + (tear.FrameCount * 0.001))
                        local rot = 4
                        if tear.FrameCount > 35 then
                            rot = 0
                        end
                        tear.Velocity = mod:Lerp(tear.Velocity, targetvel, 0.01 + (tear.FrameCount*0.001)):Rotated(rot)
                        if tear.Position:Distance(td.origpos) < 15 and tear.FrameCount > 5 then
                            if tear.Parent then
                                sfx:Play(SoundEffect.SOUND_BONE_DROP,1,2,false,1.3)
                                tear:Remove()
                            end
                        end
                    end
                    if tear.Parent then
                        if tear.Parent:IsDead() then
                            tear.FallingSpeed = 1
                        end
                    else
                        tear.FallingSpeed = 1
                    end
                end}
            end
        end,}
    elseif sub == mod.FFBookSlam.Thwammy then
        return {override = "Thwammy", damage = player.Damage*7.5+25}
    end
end

function mod:famSlammerToo(fam, player, sprite, d)
    local rng = fam:GetDropRNG()
    local room = game:GetRoom()
    if not d.init then
        d.info = getSlammerInfo(fam, player, d, sprite, rng)
        d.state = "Fall"
        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        d.override = d.info.override
        if d.info.initFunc then
            d.info.initFunc()
        end
        if d.info.smoreInit then
            local vec = Vector(0,40):Rotated(rng:RandomInt(360))
            local goForth = 0
            local going = true
            while going do
                goForth = goForth+1
                if goForth > 12 or not room:IsPositionInRoom(fam.Position+vec*goForth, 0) then
                    going = false
                end
            end
            fam.Position = fam.Position+vec*goForth
            d.state = "Wait"
            sprite:SetFrame("Jump", 19)
            d.target = (mod.FindRandomEnemy(player.Position, nil, true) or player)
            d.goHere = d.target.Position
            fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        end
        d.init = true
    else
        fam.Coins = fam.Coins+1
    end

    if d.info.override then
        if d.info.override == "Thwammy" then
            if d.state == "Fall" then
                if sprite:IsFinished("SlamDown") then
                    d.state = "Idle"
                    fam.Coins = 0
                elseif sprite:IsEventTriggered("Slam") then
                    sfx:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, 1, 0, false, 1)
                    fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                    fam.CollisionDamage = 0
                    game:ShakeScreen(10)
                    for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, 100, EntityPartition.ENEMY)) do
                        if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
                            if enemy.Position:DistanceSquared(fam.Position) <= (fam.Size + enemy.Size) ^ 2 then
                                enemy:TakeDamage(d.info.damage or 50, 0, EntityRef(player or fam), 0)
                            end
                        end
                    end
                    for _,grid in ipairs(mod.GetGridEntities()) do
                        if grid.Position:Distance(fam.Position) < 80 then
                            grid:Destroy()
                        end
                    end
                else
                    mod:spritePlay(sprite, "SlamDown")
                end
            elseif d.state == "Idle" then
                if fam.Coins > 6 then
                    d.state = "Rise"
                end

                mod:spritePlay(sprite, "IdleSlammed")
            elseif d.state == "Rise" then
                if sprite:IsFinished("Leave") then
                    fam:Remove()
                elseif sprite:IsEventTriggered("Leave") then
                    fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                else
                    mod:spritePlay(sprite, "Leave")
                end
            end

            fam.Velocity = Vector.Zero
        elseif d.info.override == "Slimer" then
            if d.state == "Landing" then
                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                if d.landing == true then
                    if sprite:IsFinished("JumpDownTar") then
                        d.state = "Hidden"
                        fam.Coins = 0
                        fam.Visible = false
                    elseif sprite:IsEventTriggered("Land") then
                        sfx:Play(SoundEffect.SOUND_BOSS2_DIVE, 0.35, 0, false, 3)
                        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                        local creep = Isaac.Spawn(1000, 45, 0, fam.Position, Vector.Zero, fam):ToEffect()
                        creep:SetTimeout(200)
                        creep:Update()
                        local poof = Isaac.Spawn(1000, 2, 160, fam.Position, Vector.Zero, fam):ToEffect()
                        poof.Color = Color(0,0,0,1,0,0,0)
                        poof.SpriteScale = Vector(0.5,0.5)
                        fam.CollisionDamage = d.info.damage or 2
                        for _, enemy in ipairs(Isaac.FindInRadius((fam.Position), fam.Size, EntityPartition.ENEMY)) do
                            if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
                                local damage = d.info.slammage or 10
                                enemy:TakeDamage(damage, 0, EntityRef(fam), 0)
                            end
                        end
                        
                        local rangle = rng:RandomInt(360)
                        for i=60,360,60 do
                            local tear = Isaac.Spawn(2, 1, 0, fam.Position, Vector(4.5, 0):Rotated(i+rangle), fam):ToTear()
                            local tdata = tear:GetData()
                            tdata.dontHitImmediately = 10
                            tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                            tear.CollisionDamage = d.info.tearDamage or 5
                            tear.Color = mod.ColorDankBlackReal
                            tear.FallingSpeed = -15
                            tear.FallingAcceleration = 1.2
                        end
                        local poof = Isaac.Spawn(1000, 16, 4, fam.Position, Vector.Zero, fam):ToEffect()
                        poof.Color = mod.ColorDankBlackReal
                        poof.SpriteScale = Vector(0.6,0.6)
        
                        for i=120,360,120 do
                            local tear = Isaac.Spawn(2, 1, 0, fam.Position, Vector(7, 0):Rotated(i+rangle), fam):ToTear()
                            local tdata = tear:GetData()
                            tdata.dontHitImmediately = 10
                            tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                            tear.CollisionDamage = d.info.tearDamage or 5
                            tear.Color = mod.ColorDankBlackReal
                            tear.FallingSpeed = -20
                            tear.FallingAcceleration = 1.35
                            tear.Scale = 1.7
                            tdata.customTearBehavior = {death = function()
                                local egg = Isaac.Spawn(mod.FF.TarBubble.ID, mod.FF.TarBubble.Var, 0, tear.Position, Vector.Zero, fam)
                                egg:AddCharmed(EntityRef(player or fam), -1)
                            end}
                        end
                    elseif sprite:IsEventTriggered("Hide") then
                        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    else
                        mod:spritePlay(sprite, "JumpDownTar")
                    end
                else
                    if sprite:IsFinished("JumpDownGround") then
                        d.state = "Idle"
                        d.info.override = nil
                        fam.Coins = 0
                    elseif sprite:IsEventTriggered("Land") then
                        sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
                        fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                        fam.CollisionDamage = d.info.damage or 2
                        for _, enemy in ipairs(Isaac.FindInRadius((fam.Position), fam.Size, EntityPartition.ENEMY)) do
                            if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
                                local damage = d.info.slammage or 10
                                enemy:TakeDamage(damage, 0, EntityRef(fam), 0)
                            end
                        end
                        
                        local creep = Isaac.Spawn(1000, 45, 0, fam.Position, Vector.Zero, fam):ToEffect()
                        creep.SpriteScale = Vector(2.3,2.3)
                        creep:SetTimeout(425)
                        creep:Update()
                        local rangle = rng:RandomInt(360)
                        
                        for i=120,360,120 do
                            local tear = Isaac.Spawn(2, 1, 0, fam.Position, Vector(4.5, 0):Rotated(i+rangle), fam):ToTear()
                            local tdata = tear:GetData()
                            tdata.dontHitImmediately = 10
                            tdata.customTearBehavior = {death = function()
                                local creep = Isaac.Spawn(1000, 45, 0, tear.Position, Vector.Zero, tear):ToEffect()
                                creep.SpriteScale = Vector(1.5,1.5)
                                creep:SetTimeout(425)
                                creep:Update()
                            end}
                            tear.Color = mod.ColorDankBlackReal
                            tear.FallingAcceleration = 1.2
                            tear.FallingSpeed = -18
                        end
                    else
                        mod:spritePlay(sprite, "JumpDownGround")
                    end
                end
            elseif d.state == "Hidden" then
                if fam.Coins > 5 then
                    local validPoses = {}
                    
                    for _,creep in ipairs(Isaac.FindByType(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, false, false)) do
                        if room:GetGridCollisionAtPos(creep.Position) == GridCollisionClass.COLLISION_NONE then
                            table.insert(validPoses, creep.Position)
                        end
                    end
                    
                    if #validPoses > 0 then
                        fam.Position = validPoses[rng:RandomInt(#validPoses)+1]
                    else
                        fam.Position = mod:FindRandomFreePos(fam, 0, nil, true)
                        local creep = Isaac.Spawn(1000, 45, 0, fam.Position, Vector.Zero, fam):ToEffect()
                        creep.SpriteScale = Vector(1.5,1.5)
                        creep:Update()
                        local poof = Isaac.Spawn(1000, 2, 160, fam.Position, Vector.Zero, fam):ToEffect()
                        poof.Color = Color(0,0,0,1,0,0,0)
                        poof.SpriteScale = Vector(0.5,0.5)
                    end
                    d.state = "Emerge"
                    fam.Visible = true
                end
            elseif d.state == "Emerge" then
                if sprite:IsFinished("Emerge") then
                    d.state = "Idle"
                    d.info.override = nil
                elseif sprite:IsEventTriggered("Emerge") then
                    fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                    sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
                    local creep = Isaac.Spawn(1000, 45, 0, fam.Position, Vector.Zero, fam):ToEffect()
                    creep.SpriteScale = Vector(1.5,1.5)
                    creep:Update()
                    
                    local poof = Isaac.Spawn(1000, 2, 160, fam.Position, Vector.Zero, fam):ToEffect()
                    poof.Color = Color(0,0,0,1,0,0,0)
                    poof.SpriteScale = Vector(0.5,0.5)
                else
                    mod:spritePlay(sprite, "Emerge")
                end
                
                if fam.FrameCount % 40 == 0 then
                    local creep = Isaac.Spawn(1000, 45, 0, fam.Position, Vector.Zero, fam):ToEffect()
                    creep:SetTimeout(60)
                    creep:Update()
                end
                
                fam.Velocity = Vector.Zero
            end
        elseif d.info.override == "Rancor" then
            if not mod:superExists(d.target) then
                d.target = (mod.FindRandomEnemy(fam.Position, nil, true) or player)
            end
            if d.state == "Fall" then
                if sprite:IsFinished("Fall") then
                    d.state = "Idle"
                    fam.Coins = 0
                elseif sprite:IsEventTriggered("Land") then
                    game:ShakeScreen(8)
			        sfx:Play(SoundEffect.SOUND_STONE_IMPACT,1,2,false,1)

                    if d.crosshair then
                        d.crosshair:Remove()
                        d.crosshair = nil
                    end

                    for i = 1, 10 do -- spawn smoke
                        local Vec = RandomVector()
                        local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, fam.Position + Vec:Resized(math.random(5,25)), Vec:Resized(math.random(2,7)), fam):ToEffect()
                        smoke.SpriteScale = smoke.SpriteScale * (math.random(8,18)/10)
                        smoke.SpriteOffset = Vector(0, 0 - math.random(5,25))
                        smoke.Color = Color(1.8, 2, 1.8, 0.4)
                        smoke:Update()
                    end

                    fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                    fam.CollisionDamage = d.info.damage or 2
                    for _, enemy in ipairs(Isaac.FindInRadius((fam.Position), fam.Size, EntityPartition.ENEMY)) do
                        if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
                            local damage = d.info.slammage or 10
                            enemy:TakeDamage(damage, 0, EntityRef(fam), 0)
                        end
                    end
                else
                    mod:spritePlay(sprite, "Fall")
                end
                fam.Velocity = (d.goHere-fam.Position)
            elseif d.state == "Idle" then
                mod:spritePlay(sprite, "IdleD")

                local col = mod:CheckLineCollision(room, fam.Position, d.target.Position)
                if col == GridCollisionClass.COLLISION_NONE then
                    if math.abs(fam.Position.Y - d.target.Position.Y) < 20 then
                        local check = fam.Position.X < d.target.Position.X
                        d.grudgeDir = check and "LEFT" or "RIGHT"

                        d.state = "grudgestart"
                    end
                    if math.abs(fam.Position.X - d.target.Position.X) < 20 then
                        local check = fam.Position.Y < d.target.Position.Y
                        d.grudgeDir = check and "UP" or "DOWN"

                        d.state = "grudgestart"
                    end
                end
                if fam.Coins > 12 then
                    d.state = "grudgestart"
                    local dirs = {"UP", "LEFT", "DOWN", "RIGHT"}
                    d.grudgeDir = dirs[rng:RandomInt(#dirs)+1]
                    d.state = "grudgestart"
                end

                d.targetVelocity = Vector.Zero
            elseif d.state == "grudge" then
                mod:RancorLook("Attack", fam, d.target)

                -- move
                local vec = grudgeVecs[d.grudgeDir]
                local speed = 16

                d.targetVelocity = -vec:Resized(speed)

                -- spawn smoke
                local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, fam.Position, fam.Velocity:Resized(3), fam)
                smoke.SpriteScale = smoke.SpriteScale * 1.2
                smoke.SpriteOffset = Vector(0, -5)
                smoke.SpriteRotation = math.random(360)
                smoke.Color = Color(1.8, 2, 1.8, 0.4)
                smoke:Update()

                -- on collide
                if fam:CollidesWithGrid() then
                    game:ShakeScreen(6)

                    if d.grudgeDir == "LEFT" or d.grudgeDir == "RIGHT" then
                        mod:spritePlay(sprite, "HitHori")
                    else
                        mod:spritePlay(sprite, "HitVert")
                    end

                    sfx:Play(SoundEffect.SOUND_STONE_IMPACT,1,2,false,1)

                    d.targetVelocity = Vector.Zero
                    d.state = "grudgeend"
                end
            elseif d.state == "grudgestart" then
                if sprite:IsFinished() then
                    sfx:Play(SoundEffect.SOUND_STONE_IMPACT,0.32,2,false,0.8)
                    d.state = "grudge"
                end

                mod:RancorLook("AttackStart", fam, d.target)
            elseif d.state == "grudgeend" then
                if sprite:IsFinished() then
                    d.state = "Jump"
                    d.info.override = nil
                end
            end

            local lerpAmount = 0.6
            if d.state == "grudge" then
                lerpAmount = 0.2
            end
            fam.Velocity = mod:Lerp(fam.Velocity, d.targetVelocity, lerpAmount)
        elseif d.info.override == "Smore" then
            if fam.SubType == mod.FFBookSlam.Smore then
                if d.ashPos then
                    if d.ashPos:Distance(fam.Position) > 10 and room:IsPositionInRoom(fam.Position, 0) then
                        spawnAshFamiliar(fam, fam.Position)
                        d.ashPos = fam.Position
                    end
                elseif room:IsPositionInRoom(fam.Position, 0) then
                    spawnAshFamiliar(fam, fam.Position)
                    d.ashPos = fam.Position
                end
            elseif fam.SubType == mod.FFBookSlam.Septic then
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, fam.Position, Vector.Zero, fam):ToEffect();
				creep.Timeout = 20
                creep.CollisionDamage = player.Damage/2 or 2
				creep:Update()
            elseif fam.SubType == mod.FFBookSlam.Shaker then
                if room:GetGridCollisionAtPos(fam.Position) == GridCollisionClass.COLLISION_NONE then
                    local salt = Isaac.Spawn(1000, 92, 115, fam.Position+RandomVector()*5, Vector.Zero, fam):ToEffect()
                    salt.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5)
                    salt:SetTimeout(15)
                    salt.SpriteScale = Vector(0.4, 0.4)
                    salt:Update()
                end

                local proj = Isaac.Spawn(2, 42, 0, fam.Position, RandomVector()*(rng:RandomInt(100,500)/100), fam):ToTear()
                proj:GetData().shakerSalt = true
                proj.Height = -350
                proj.FallingAcceleration = 0.2+rng:RandomInt(20)/100
                proj.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
                proj:GetData().customTearBehavior = {death = function()
                    if proj.Height > -5 then
                        local salt = Isaac.Spawn(1000, 92, 115, proj.Position, Vector.Zero, proj):ToEffect()
                        salt.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5)
                        salt:SetTimeout(20)
                        salt.SpriteScale = Vector(0.8, 0.8)
                        salt:Update()
                    end
                    local poof = Isaac.Spawn(1000, 59, 0, proj.Position, Vector.Zero, proj):ToEffect()
                    poof:SetTimeout(10)
                    poof.SpriteScale = Vector(0.2, 0.2)
                    poof.SpriteOffset = Vector(0, proj.Height)
                    poof:Update()
                    sfx:Play(SoundEffect.SOUND_SUMMON_POOF, 0.3, 0, false, math.random(90,140)/100)
                end, customFunc = function() proj.Velocity = proj.Velocity*0.98 end}
                --proj.Acceleration = 0.98
                proj.Scale = 0.6
                local pSprite = proj:GetSprite()
                pSprite:Load("gfx/009.009_Rock Projectile.anm2", true)
                pSprite:ReplaceSpritesheet(0, "gfx/projectiles/salt_projectile.png")
                pSprite:Play("Rotate1", true)
                pSprite:LoadGraphics()
                proj:Update()
            end

            --[[if mod:superExists(d.target) then
                d.goHere = d.target.Position
            end]]
            local dist = d.goHere:Distance(fam.Position)
            if dist < 20 or fam.Coins > 50 then
                d.state = "Fall"
                d.info.override = nil
                fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
                sprite:Play("Idle")
                sprite:Play("Fall")
            elseif dist < 40 then
                fam.Velocity = mod:Lerp(fam.Velocity, (d.goHere-fam.Position):Resized(5), 0.3)
            else
                fam.Velocity = mod:Lerp(fam.Velocity, fam.Velocity+(d.goHere-fam.Position):Resized(dist/10), 0.3)
                if fam.Velocity:Length() >= 24 then
                    fam.Velocity = fam.Velocity:Resized(24)
                end
            end
        end
    elseif d.state == "Fall" then
        if sprite:IsFinished("Fall") or (fam.SubType == mod.FFBookSlam.Hoster and sprite:IsFinished("Land")) then
            if fam.SubType == mod.FFBookSlam.Doomer then
                d.state = "IdleDoomer"
            elseif fam.SubType == mod.FFBookSlam.Hoster then
                d.state = "IdleHoster"
            else
                d.state = "Idle"
            end
            fam.Coins = 0
        elseif sprite:IsEventTriggered("Land") then
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            fam.CollisionDamage = d.info.damage or 2
            if d.info.landSound then
                d.info.landSound()
            else
                sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
            end

            if d.info.landFunc then
                d.info.landFunc()
            end

            for _, enemy in ipairs(Isaac.FindInRadius((fam.Position), fam.Size, EntityPartition.ENEMY)) do
                if enemy:IsActiveEnemy() and (not mod:isFriend(enemy)) and enemy:IsVulnerableEnemy() then
                    local damage = d.info.slammage or 10
                    enemy:TakeDamage(damage, 0, EntityRef(fam), 0)
                end
            end
            d.landed = true
        elseif sprite:IsEventTriggered("Sound") and fam.SubType == mod.FFBookSlam.Hoster then
            sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
        elseif sprite:IsEventTriggered("Shoot") and fam.SubType == mod.FFBookSlam.Hoster then
            if not mod:superExists(d.target) then
                d.target = (mod.FindRandomEnemy(fam.Position, nil, true) or player)
            end

            local poof = Isaac.Spawn(1000, 16, 0, fam.Position, Vector.Zero, fam):ToEffect()
			poof.SpriteScale = Vector(0.5,0.6)
			poof.SpriteOffset = Vector(0,-10)
			poof.DepthOffset = 30
			sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 0, false, 1)
			for i=-21,21,21 do
				local tear = Isaac.Spawn(2, 1, 0, fam.Position, (d.target.Position-fam.Position):Resized(9.5):Rotated(i), fam):ToTear()
                tear.CollisionDamage = d.info.tearDamage or 5
			end
        else
            if fam.SubType == mod.FFBookSlam.Hoster then
                mod:spritePlay(sprite, "Land")
            else
                mod:spritePlay(sprite, "Fall")
            end
        end

        if fam.SubType == mod.FFBookSlam.Flinty and sprite:GetFrame() < 25 then
            local smoke = Isaac.Spawn(1000, 59, 0, fam.Position+RandomVector()*15, Vector(0,-5), fam):ToEffect()
            smoke:SetTimeout(10)
            smoke:SetColor(Color(0,0,0,0.5,0,0,0), 0, 0, false, false)
            smoke.Scale = 1000
            local offsetY = sprite:GetFrame()
            if offsetY > 6 then offsetY = 6 end
            smoke.PositionOffset = Vector(0, -220+(offsetY*33.3))
        end

        if d.target and mod:superExists(d.target) and not d.landed then
            local dir = (d.target.Position-fam.Position):Resized(5)
            fam.Velocity = mod:Lerp(fam.Velocity, dir, 0.3)
        else
            fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
        end
    elseif d.state == "Idle" then
        if fam.Coins > 6 then
            d.state = "Jump"
        else
            mod:spritePlay(sprite, "Idle")
        end

        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
    elseif d.state == "Jump" then
        if sprite:IsFinished("Jump") then
        elseif (sprite:IsEventTriggered("Jump") and fam.SubType == mod.FFBookSlam.Slimer) then
            if d.info.jumpSound then
                d.info.jumpSound()
            else
                sfx:Play(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1)
            end

            fam.CollisionDamage = 0
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            d.famSpriteScale = 1
            fam.Coins = 0
            d.jumper = true
        elseif sprite:IsEventTriggered("Sound") then
            if d.info.jumpSound then
                d.info.jumpSound()
            else
                sfx:Play(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,1)
            end

            if fam.SubType == mod.FFBookSlam.Flinty then
                local smoke = Isaac.Spawn(1000, 59, 0, fam.Position+RandomVector()*10, Vector(0,-5), fam):ToEffect()
                smoke:SetTimeout(20)
                smoke.Scale = 1000
                local offsetY = sprite:GetFrame()-30
                smoke.PositionOffset = Vector(0, -50*offsetY)
                Isaac.Explode(fam.Position, player or fam, d.info.explosionDamage)
            end
        elseif sprite:IsEventTriggered("GetPlayer") or sprite:IsEventTriggered("Jump") then
            fam.CollisionDamage = 0
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            d.famSpriteScale = 1
            fam.Coins = 0
            d.jumper = true
        else
            if fam.SubType == mod.FFBookSlam.Slimer then
                mod:spritePlay(sprite, "JumpUp")
            else
                mod:spritePlay(sprite, "Jump")
            end
        end

        if d.jumper then
            if d.famSpriteScale < 0.1 then
                fam:Remove()
            else
                fam.SpriteScale = Vector(d.famSpriteScale, d.famSpriteScale)
                d.famSpriteScale = mod:Lerp(d.famSpriteScale, 0, 0.2)
            end
        end

        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
    elseif d.state == "Waiting" then
        if fam.Coins < 46 then
            mod:spritePlay(sprite, "Ribless")
        else
            if sprite:IsFinished("Recover") then
                d.state = "Idle"
                fam.Coins = 0
            else
                mod:spritePlay(sprite, "Recover")
            end
        end
        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
    elseif d.state == "IdleDoomer" then
        if not d.brimState then
			if sprite:IsFinished("BrimstoneStart") then
				d.brimState = "firing"
			elseif sprite:IsEventTriggered("rrerr") then
				for i = 90, 360, 90 do
					local tracer = Isaac.Spawn(1000, 198, 0, fam.Position + Vector(10, 0):Rotated(i), Vector(0.001,0), fam):ToEffect()
					tracer.Timeout = 20
					tracer.TargetPosition = Vector(1,0):Rotated(i)
					tracer.LifeSpan = 15
					tracer:FollowParent(fam)
					tracer.Color = Color(1,0.2,0,0.3,0,0,0)
					tracer:Update()
				end
			elseif sprite:IsEventTriggered("Shoot") then
				local laserVar = 1
				for i = 90, 360, 90 do
					local laser = EntityLaser.ShootAngle(laserVar, fam.Position, i, 20, Vector(0, -10), fam)
					if i == 90 then
						laser.DepthOffset = -500
					end
					laser.Parent = fam
                    laser.CollisionDamage = d.info.laserDamage or 3
					laser:Update()
				end
				fam.Coins = 0
			else
				mod:spritePlay(sprite, "BrimstoneStart")
			end
		elseif d.brimState == "firing" then
			mod:spritePlay(sprite, "BrimstoneLoop")
			if fam.Coins > 20 then
				d.brimState = "end"
			end
		elseif d.brimState == "end" then
			if sprite:IsFinished("BrimstoneEnd") then
				d.state = "Idle"
			else
				mod:spritePlay(sprite, "BrimstoneEnd")
			end
		end

        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
    elseif d.state == "IdleHoster" then
        if sprite:IsFinished("Hide") then
            d.state = "Jump"
        elseif sprite:IsEventTriggered("Sound") then
            sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "Hide")
        end

        fam.Velocity = mod:Lerp(fam.Velocity, Vector.Zero, 0.3)
    end

    if d.WormyShoot and d.WormyShoot >= 0 then
        d.WormyShoot = d.WormyShoot-1
        for i=0,240,120 do
            local shootvec = d.WormVec:Rotated(i):Resized(8)
            local tear = Isaac.Spawn(2, 1, 0, d.WormPoint + shootvec:Resized(d.WormyShoot * 2), shootvec, fam):ToTear()
            local td = tear:GetData()
            td.dontHitImmediately = 8
            tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            tear.CollisionDamage = d.info.tearDamage
            tear.FallingAcceleration = -0.15
            tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
            tear.Color = mod.ColorWigglyMaggot
            tear.Scale = 0.6
            td.customTearBehavior = {
                customFunc = function()
                    td.WiggleCurve = td.WiggleCurve or 4
                    td.WiggleAngle = td.WiggleAngle or 12
                    tear.Velocity = tear.Velocity:Rotated(td.WiggleAngle)
                    td.WiggleAngle = td.WiggleAngle + td.WiggleCurve
                    if math.abs(td.WiggleAngle) > 12 then
                        td.WiggleCurve = -td.WiggleCurve
                    end
                end
            }
        end
    end
end