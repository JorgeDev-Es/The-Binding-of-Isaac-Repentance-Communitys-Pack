local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local function GetAvaliableLittleJohnGroup(rng, lastgroup)
    local choices = {}
    local otherchoice
    for group, status in pairs(mod.ActiveLittleJohnGroups) do
        if status == "Open" then
            if lastgroup and group == lastgroup then
                otherchoice = group
            else
                table.insert(choices, group)
            end
        end
    end
    local group = mod:GetRandomElem(choices, rng)
    if group then
        mod.ActiveLittleJohnGroups[group] = "Closed"
        return group
    else
        return otherchoice
    end
end

local function GatherJohns(group)
    return Isaac.FindByType(mod.FF.LittleJohn.ID, mod.FF.LittleJohn.Var, group)
end

function mod:PillarJohnAI(npc, sprite, data)
    local target = npc:GetPlayerTarget()
    local targetpos = mod:confusePos(npc, target.Position)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    npc.Velocity = Vector.Zero
    mod.QuickSetEntityGridPath(npc)

    if not data.Init then
        if room:IsClear() then
            data.State = "Inert"
        else
            data.State = "Awaken"
        end
        
        npc:SetSize(18, Vector(2,1), 12)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
        data.Init = true
    end

    if data.State == "Awaken" then
        if sprite:IsFinished("Appear") then
            data.State = "Idle"
            npc.StateFrame = mod:RandomInt(10,30,rng)
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MONSTER_YELL_B, npc, 0.6)
            npc.CollisionDamage = 1
        else
            mod:spritePlay(sprite, "Appear")
        end
    
    elseif data.State == "Idle" then
        mod:spritePlay(sprite, "Idle")
        npc.StateFrame = npc.StateFrame - 1

        if room:IsClear() then
            data.State = "Deactivate"
        elseif npc.StateFrame <= 0 then
            if data.SummonedJohns and room:GetGridCollisionAtPos(targetpos) ~= GridCollisionClass.COLLISION_PIT and room:IsPositionInRoom(targetpos, 0) then
                npc.TargetPosition = targetpos
                data.State = "MakeQuake"
            else
                data.PrevGroup = data.Group
                data.Group = GetAvaliableLittleJohnGroup(rng, data.PrevGroup)
                if data.Group then
                    data.State = "SummonJohns"
                end
            end
        end

    elseif data.State == "SummonJohns" then
        if sprite:IsFinished("SummonPillars") then
            data.State = "Idle"
            data.SummonedJohns = true
            npc.StateFrame = mod:RandomInt(100,180,rng)
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 0.7, 0.8)
            if data.PrevGroup then
                for _, john in pairs(GatherJohns(data.PrevGroup)) do
                    john.Parent = nil
                end
                mod.ActiveLittleJohnGroups[data.PrevGroup] = "Open"
            end
            for _, johns in pairs(mod.LittleJohnData) do
                if johns.Group == data.Group then
                    local john = Isaac.Spawn(mod.FF.LittleJohn.ID, mod.FF.LittleJohn.Var, data.Group, johns.Position, Vector.Zero, npc)
                    john.Parent = npc
                    john:Update()
                end
                mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 0.6)
            end
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_GRROOWL, npc, 0.7, 1.2)
            for _, john in pairs(GatherJohns(data.Group)) do
                if not mod:IsReallyDead(john) then
                    john:GetData().State = "Emerge"
                end
            end
        else
            mod:spritePlay(sprite, "SummonPillars")
        end
    
    elseif data.State == "MakeQuake" then
        if sprite:IsFinished("Quake") then
            data.State = "Idle"
            data.SummonedJohns = false
            npc.StateFrame = mod:RandomInt(30,90,rng)
        elseif sprite:IsEventTriggered("Sound") then
            if room:GetGridCollisionAtPos(targetpos) ~= GridCollisionClass.COLLISION_PIT and room:IsPositionInRoom(targetpos, 0) then
                npc.TargetPosition = targetpos
            end
            local quake = Isaac.Spawn(mod.FF.PillarJohnQuake.ID, mod.FF.PillarJohnQuake.Var, 0, npc.TargetPosition, Vector.Zero, npc)
            quake.Parent = npc
            quake:Update()
            data.Quake = quake
            for i = 1, 3 do
                local rubble = Isaac.Spawn(1000, 4, 0, targetpos, RandomVector()*(mod:RandomInt(1,2,rng)), npc)
                rubble:Update()
            end
            game:ShakeScreen(3)
            npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,0.7,0,false,1.7)
            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_1, npc, 0.7)
        elseif sprite:IsEventTriggered("Shoot") then
            if not mod:IsReallyDead(data.Quake) then
                data.Quake:GetData().State = "Attack"
            end
            mod:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, npc)
            game:ShakeScreen(10)
        else
            mod:spritePlay(sprite, "Quake")
        end
    
    elseif data.State == "Deactivate" then
        if sprite:IsFinished("Death") then
            data.State = "Inert"
        elseif sprite:IsEventTriggered("Sound") then
            npc:PlaySound(SoundEffect.SOUND_DEVILROOM_DEAL,1,0,false,0.6)
        elseif sprite:IsEventTriggered("Sound2") then
            npc:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,1,0,false,1.7)
        else
            mod:spritePlay(sprite, "Death")
        end
    
    elseif data.State == "Inert" then
        npc.CollisionDamage = 0
        mod:spritePlay(sprite, "Dead")
    end
end

function mod:LittleJohnAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.State = "Tell"
        data.Suffix = mod:RandomInt(1,3,rng)
        sprite.FlipX = (rng:RandomFloat() <= 0.5)
        data.Init = true
    end

    npc.Velocity = Vector.Zero
    if npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ALL then
        mod.QuickSetEntityGridPath(npc, 3999)
    end

    if data.State == "Tell" then
        mod:spritePlay(sprite, "Tell")
        if mod:IsReallyDead(npc.Parent) or room:IsClear() then
            npc:Remove()
        end
    
    elseif data.State == "Emerge" then
        if not data.EmergeInit then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            --mod:DamageInRadius(npc.Position, npc.Size, 1, npc.SpawnerEntity, DamageFlag.DAMAGE_CRUSH, false)
            sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
            for i = 1, 2 do
                local rubble = Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector()*(mod:RandomInt(1,2,rng)), npc)
                rubble:Update()
            end
            data.EmergeInit = true
        end
        
        if sprite:IsFinished("Appear"..data.Suffix) then
            data.State = "Idle"
        else
            mod:spritePlay(sprite, "Appear"..data.Suffix)
        end

    elseif data.State == "Idle" then
        mod:spritePlay(sprite, "Idle"..data.Suffix)
        if mod:IsReallyDead(npc.Parent) or room:IsClear() then
            data.State = "Leave"
        end

    elseif data.State == "Leave" then
        if sprite:IsFinished("Leave"..data.Suffix) then
            npc:Remove()
        else
            mod:spritePlay(sprite, "Leave"..data.Suffix)
        end

    elseif data.State == "Death" then
        if sprite:IsFinished("Death"..data.Suffix) then
            npc:Remove()
        elseif sprite:IsEventTriggered("Shoot") then
            npc:BloodExplode()
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            local params = ProjectileParams()
			params.Variant = 9
			params.Scale = 0.9
            for i = 90, 360, 90 do
			    npc:FireProjectiles(npc.Position, Vector(4,0):Rotated(i), 0, params)
            end
        else
            mod:spritePlay(sprite, "Death"..data.Suffix)
        end
    end
end

function mod:LittleJohnHurt(npc, amount, damageFlags, source)
    local data = npc:GetData()
    if mod:HasDamageFlag(DamageFlag.DAMAGE_EXPLOSION, damageFlags) or mod:HasDamageFlag(DamageFlag.DAMAGE_CRUSH, damageFlags) then
        if npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ALL and data.Sate ~= "Death" then
            npc:BloodExplode()
            data.State = "Death"
        end
    end
    return false
end

function mod:PillarJohnQuake(npc, sprite, data)
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc.SortingLayer = SortingLayer.SORTING_BACKGROUND
        data.State = "Tell"
        data.Init = true
    end

    npc.Velocity = Vector.Zero

    if data.State == "Tell" then
        mod:spritePlay(sprite, "Tell")
        if mod:IsReallyDead(npc.Parent) or room:IsClear() then
            npc:Remove()
        end

    elseif data.State == "Attack" then
        if sprite:IsFinished("Attack") then
            npc:Remove()
        elseif sprite:IsEventTriggered("Shoot") then
            mod:DamageInRadius(npc.Position, npc.Size, 1, npc.SpawnerEntity, DamageFlag.DAMAGE_CRUSH, false, true, 10)
            mod:DestroyNearbyGrid(npc, npc.Size)
            sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
            npc.SortingLayer = SortingLayer.SORTING_NORMAL
            for i = 1, 3 do
                local rubble = Isaac.Spawn(1000, 4, 0, npc.Position, RandomVector()*(mod:RandomInt(1,2,rng)), npc)
                rubble:Update()
            end
        else
            mod:spritePlay(sprite, "Attack")
        end
    end
end

function mod:LittleJohnPointSetup(npc, sprite, data)
    npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    local johndata = {}
    johndata.Position = npc.Position
    johndata.Group = npc.SubType
    table.insert(mod.LittleJohnData, johndata)

    mod.ActiveLittleJohnGroups[johndata.Group] = "Open"

    npc:Remove()
end

function mod:DamageInRadius(pos, radius, damage, source, flags, ignoreFlying, doFriendlyFire, enemyDamage, enemyDmgInterval)
    local hurtPlayers = true
    local hurtEnemies = false
    local checkSelf = false
    local did = false
    if source and source:Exists() and source:ToNPC() then
        hurtPlayers = not mod:isFriend(source) 
        hurtEnemies = mod:isCharm(source)
        checkSelf = true
    end

    if doFriendlyFire then
        hurtEnemies = true
    end

    damage = damage or 1
    flags = flags or 0
    enemyDamage = enemyDamage or damage
    enemyDmgInterval = enemyDmgInterval or 1

    if hurtPlayers then
        for i = 0, game:GetNumPlayers() do
            local player = game:GetPlayer(i)
            if player:Exists() and player.Position:Distance(pos) <= player.Size + radius and not (ignoreFlying and player:IsFlying()) then
                if player:GetDamageCooldown() == 0 then
                    did = true
                end
                player:TakeDamage(damage, flags, EntityRef(source), 0)
            end
        end
    end

    if game:GetFrameCount() % enemyDmgInterval == 0 then
        for _, enemy in pairs(Isaac.FindInRadius(pos, radius * 2, EntityPartition.ENEMY)) do
            if enemy.Position:Distance(pos) <= enemy.Size + radius and not ((ignoreFlying and enemy:IsFlying()) or (checkSelf and source.InitSeed == enemy.InitSeed)) then
                if hurtEnemies and not mod:isFriend(enemy) then
                    enemy:TakeDamage(enemyDamage, flags, EntityRef(source), 0)
                    did = true
                elseif hurtPlayer and mod:isFriend(enemy) then
                    enemy:TakeDamage(enemyDamage, flags, EntityRef(source), 0)
                    did = true
                end
            end
        end
    end

    return did
end