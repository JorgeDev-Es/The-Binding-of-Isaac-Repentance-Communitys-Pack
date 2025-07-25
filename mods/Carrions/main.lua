local MyMod = RegisterMod("MyMod", 1)

function MyMod.NpcInit(_, npc)
    if npc.Type == 10 and npc.Variant == 3 and npc.SubType == 1 then
        local roll = math.random(1, 3)
        if roll == 2 or roll == 3 then
            local pos = npc.Position
            local vel = npc.Velocity
            npc:Remove()
            Isaac.Spawn(npc.Type, npc.Variant, roll == 2 and 6 or 7, pos, vel, npc.Parent)
        end
    elseif npc.Type == 10 and npc.Variant == 3 and npc.SubType == 2 then
        local roll = math.random(1, 4) -- 1~4 중 랜덤

        if roll ~= 1 then  -- roll == 2, 3, 4 → 바뀜
            local newSubType = ({8, 18, 19})[roll - 1] -- roll-1 → 1, 2, 3
            local pos = npc.Position
            local vel = npc.Velocity
            npc:Remove()
            Isaac.Spawn(npc.Type, npc.Variant, newSubType, pos, vel, npc.Parent)
        end
    elseif npc.Type == 10 and npc.Variant == 3 and npc.SubType == 3 then
        local roll = math.random(1, 5) -- 1~5 중 랜덤

        if roll ~= 1 then  -- roll == 2, 3, 4, 5 → 바뀜 
            local newSubType = ({9, 10, 11, 12})[roll - 1] -- roll-1 → 1, 2, 3, 4  
            local pos = npc.Position
            local vel = npc.Velocity
            npc:Remove()
            Isaac.Spawn(npc.Type, npc.Variant, newSubType, pos, vel, npc.Parent)
        end
    elseif npc.Type == 10 and npc.Variant == 3 and npc.SubType == 4 then
        local roll = math.random(1, 3)
        if roll == 2 or roll == 3 then
            local pos = npc.Position
            local vel = npc.Velocity
            npc:Remove()
            Isaac.Spawn(npc.Type, npc.Variant, roll == 2 and 13 or 14, pos, vel, npc.Parent) 
        end
    elseif npc.Type == 10 and npc.Variant == 3 and npc.SubType == 5 then
        local roll = math.random(1, 4) -- 1~4 중 랜덤

        if roll ~= 1 then  -- roll == 2, 3, 4 → 바뀜
            local newSubType = ({15, 16, 17})[roll - 1] -- roll-1 → 1, 2, 3
            local pos = npc.Position
            local vel = npc.Velocity
            npc:Remove()
            Isaac.Spawn(npc.Type, npc.Variant, newSubType, pos, vel, npc.Parent)
        end
    end

    if npc.Type == 10 and npc.Variant == 3 and npc.SubType == 3 then
        npc.MaxHitPoints = 60
        npc.HitPoints = 60
    end

end

MyMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, MyMod.NpcInit)

-- BLOOD_SPLAT
function MyMod.onNpcUpdate(_, npc)
    if npc.Type == 10 and npc.Variant == 3 and
       (npc.SubType == 1 or npc.SubType == 5 or npc.SubType == 9 or npc.SubType == 10 or
        npc.SubType == 11 or npc.SubType == 12 or npc.SubType == 13 or npc.SubType == 14 or
        npc.SubType == 15 or npc.SubType == 16 or npc.SubType == 18) then

        local data = npc:GetData()
        if data.BloodSplatCooldown == nil then
            data.BloodSplatCooldown = 0
        end
        if data.BloodExplosionCooldown == nil then
            data.BloodExplosionCooldown = 0
        end

        -- 쿨다운 감소
        if data.BloodSplatCooldown > 0 then
            data.BloodSplatCooldown = data.BloodSplatCooldown - 1
        end
        if data.BloodExplosionCooldown > 0 then
            data.BloodExplosionCooldown = data.BloodExplosionCooldown - 1
        end

        if npc.Velocity:Length() > 0.5 then
            local pos = npc.Position

            if (npc.SubType == 1 or npc.SubType == 16 or npc.SubType == 12 or npc.SubType == 14) then
                -- BLOOD_SPLAT (10프레임 쿨다운)
                if data.BloodSplatCooldown <= 0 then
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, pos, Vector.Zero, npc):ToEffect()
                    effect.Scale = 1.5
                    data.BloodSplatCooldown = 10
                end
            end

            if (npc.SubType == 13 or npc.SubType == 5 or npc.SubType == 15 or npc.SubType == 9 or npc.SubType == 10 or npc.SubType == 11 or npc.SubType == 18) then
                -- BLOOD_SPLAT (15프레임 쿨다운)
                if data.BloodSplatCooldown <= 0 then
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, pos, Vector.Zero, npc):ToEffect()
                    effect.Scale = 1.5
                    data.BloodSplatCooldown = 15
                end
            end


            if (npc.SubType == 13 or npc.SubType == 15 or npc.SubType == 16 or npc.SubType == 12 or npc.SubType == 9 or npc.SubType == 11 or npc.SubType == 14) then
                -- BLOOD_EXPLOSION (60프레임 쿨다운)
                if data.BloodExplosionCooldown <= 0 then
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, pos, Vector.Zero, npc):ToEffect()
                    effect.Scale = 1.5
                    data.BloodExplosionCooldown = 60
                end
            end
        end
    end
-- Monsters AI
    -- 구더기 소환 AI SubType 확장
    local data = npc:GetData()
    local spawnSubtypes = {
        [9] = true,
        [10] = true,
        [11] = true,
        [12] = true,
    }

    if npc.Type == 10 and npc.Variant == 3 and spawnSubtypes[npc.SubType] then

        -- 초기화
        data.SpawnedFrame = data.SpawnedFrame or Game():GetFrameCount()
        data.MaggotCooldown = data.MaggotCooldown or 0

        -- 프레임 경과 계산
        local framesSinceSpawn = Game():GetFrameCount() - data.SpawnedFrame

        -- 쿨다운 감소
        if data.MaggotCooldown > 0 then
            data.MaggotCooldown = data.MaggotCooldown - 1
        end

        -- 현재 살아있는 구더기 수 계산 (InitSeed 기반 추적)
        local alive = 0
        for _, e in ipairs(Isaac.GetRoomEntities()) do
            if e.Type == EntityType.ENTITY_SMALL_MAGGOT then
                local eData = e:GetData()
                if eData.SpawnerInitSeed == npc.InitSeed then
                    alive = alive + 1
                end
            end
        end

        -- 구더기 소환 조건: 1초 경과 후, 쿨다운 0, 6마리 미만일 때 (subtype 9는 최대 10)
        local maxMaggots = (npc.SubType == 9) and 10 or 6

        if framesSinceSpawn >= 60 and data.MaggotCooldown <= 0 and alive < maxMaggots then
            local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, npc.Position, Vector.Zero, npc)
            local maggotData = maggot:GetData()
            maggotData.SpawnerInitSeed = npc.InitSeed
            maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

            data.MaggotCooldown = 60 -- 2초 쿨다운
        end
    end
-- subtype 9번의 ai

    local data = npc:GetData()

    -- 가속 돌진 상태 초기화
    if data.dashState == nil then
        data.dashState = "idle"  -- idle, charging, dashing
        data.dashSpeed = 0
        data.dashMaxSpeed = 20
        data.dashDuration = 60 -- 60프레임 (1초)
        data.dashTimer = 0
        data.dashDir = Vector(0,0)
    end

    if npc.Type == 10 and npc.Variant == 3 and (npc.SubType == 15 or npc.SubType == 16 or npc.SubType == 17) then
        local data = npc:GetData()

        -- 여기서 강제 초기화
        data.dashCooldown = data.dashCooldown or 0

        if data.dashState == nil then
            data.dashState = "idle"
            data.dashSpeed = 0
            data.dashMaxSpeed = 20
            data.dashDuration = 60
            data.dashTimer = 0
            data.dashDir = Vector(0, 0)
        end

        -- 쿨다운 감소
        if data.dashCooldown > 0 then
            data.dashCooldown = data.dashCooldown - 1
        end

        local player = Isaac.GetPlayer(0)
        local toPlayer = player.Position - npc.Position
        local distance = toPlayer:Length()
        local room = Game():GetRoom()

        if data.dashState == "idle" then
            -- 플레이어가 200 이내 거리이면서 시야에 있을 경우만 돌진
            if data.dashCooldown <= 0 and distance < 200 and room:CheckLine(npc.Position, player.Position, 0, 1, false, false) then
                data.dashState = "charging"
                data.dashSpeed = 0
                data.dashTimer = 0
                data.dashDir = toPlayer:Normalized()

            end

        elseif data.dashState == "charging" then
            data.dashSpeed = math.min(data.dashSpeed + 1, data.dashMaxSpeed)
            npc.Velocity = data.dashDir * data.dashSpeed
            data.dashTimer = data.dashTimer + 1

            -- 벽에 닿았으면 멈추기
            if npc:CollidesWithGrid() then
                local speed = data.dashSpeed
                local room = Game():GetRoom()
                local gridIndex = room:GetGridIndex(npc.Position)
                local gridEntity = room:GetGridEntity(gridIndex)

                data.dashState = "idle"
                data.dashSpeed = 0
                npc.Velocity = Vector(0, 0)
                data.dashCooldown = 7 -- 벽에 부딪힌 경우 쿨다운 설정

                if speed >= 15 then

                    -- 격자가 파괴 가능 상태인지 체크 후 파괴
                    if gridEntity ~= nil and gridEntity:GetType() ~= GridEntityType.GRID_NULL and not gridEntity:ToRock():IsDestroyed() then
                       gridEntity:Destroy()
                    end

                    -- 벽에 닿았을 때 BLOOD_PARTICLE 생성
                    for i = 1, 10 do
                        local particleSubtype = math.random(7) - 1
                        local particleSpeed = RandomVector() * math.random() * 3
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, particleSubtype, npc.Position, particleSpeed, npc)
                    end

                    -- 벽에 닿았을 때 BLOOD_EXPLOSION
                    local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc)

                    -- 피 장판 생성 (예: EffectVariant.BRIMSTONE_PIT, 또는 커스텀 Variant 생성)
                    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, Vector.Zero, npc):ToEffect()
                    creep:SetTimeout(90)  -- 3초 지속
                    creep.Scale = 1.0      -- 원하는 크기로 조절
                    creep:Update()
    
                    local bloodData = creep:GetData()
                    bloodData.Damage = 1 -- 밟을 시 1 데미지
                    bloodData.Owner = npc

                    -- 사운드
                    SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS, 1.0, 0, false, 1.0)
                    SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1.0, 0, false, 1.0)
                end
            end

            if data.dashTimer >= data.dashDuration then
                data.dashState = "idle"
                data.dashSpeed = 0
                npc.Velocity = Vector(0, 0)
            end
        end
    end
end

MyMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, MyMod.onNpcUpdate)

function MyMod:onEntityDamage(entity, amount, flags, sourceRef, countdownFrames)
    if entity:ToNPC() ~= nil then
        local npc = entity:ToNPC()
        -- Type 10, Variant 3, SubType 1~19 인 적 체크
        if npc.Type == 10 and npc.Variant == 3 and npc.SubType >= 1 and npc.SubType <= 19 then
            
            -- 피격 시 Blood Particle 이펙트 10개 생성
            for i = 1, 10 do
                local particleSubtype = math.random(7) - 1
                local particleSpeed = RandomVector() * math.random() * 3
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, particleSubtype, npc.Position, particleSpeed, npc)
            end
            
            
        end
    end
end

MyMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, MyMod.onEntityDamage)