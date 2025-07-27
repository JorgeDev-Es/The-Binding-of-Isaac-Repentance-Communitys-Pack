local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:GoldenFlyBombAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()

    if not data.Init then
        if npc.SubType == 1 then
            sprite:ReplaceSpritesheet(0, "gfx/enemies/goldenflybomb/monster_rosegoldflybomb.png")
            sprite:LoadGraphics()
        end
        data.SpawnPosition = npc.Position
        data.Init = true
    elseif not data.DontMakeSpawnpoint then
        local spawnpoint = {}
        spawnpoint.Position = data.SpawnPosition or npc.Position
        spawnpoint.SubType = npc.SubType
        spawnpoint.Ent = npc
        table.insert(mod.GoldenFlyBombSpawnpoints, spawnpoint)
        data.DontMakeSpawnpoint = true
    end

    if npc.FrameCount % 5 == 1 then
        local sparkle = Isaac.Spawn(1000, 7003, 0, npc.Position, Vector.Zero, npc):ToEffect()
        sparkle.RenderZOffset = -5
        sparkle.SpriteOffset = Vector(-10 + mod:RandomInt(0,20,rng), -30 + mod:RandomInt(0,20,rng))
        if npc.SubType == 1 then
            sparkle.Color = mod.ColorRoseGold
        end
        sparkle:Update()
    end

    if room:IsClear() then
        npc:TakeDamage(npc.MaxHitPoints, 0, EntityRef(nil), 0)
    end
end

function mod:GoldenFlyBombRespawning(spawnpoint)
    local room = game:GetRoom()
    spawnpoint.IsBomb = spawnpoint.IsBomb or false
    spawnpoint.Tries = spawnpoint.Tries or 10

    if spawnpoint.IsBomb then
        if not room:IsClear() then
            if not spawnpoint.Ent:Exists() then
                local flybomb = Isaac.Spawn(mod.FF.GoldenFlyBomb.ID, mod.FF.GoldenFlyBomb.Var, spawnpoint.SubType, spawnpoint.Ent.Position, Vector.Zero, spawnpoint.Ent)
                flybomb:GetData().DontMakeSpawnpoint = true
                flybomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                flybomb:Update()
                spawnpoint.Tries = 10
                spawnpoint.Ent = flybomb
                spawnpoint.IsBomb = false
            end
        end
    elseif spawnpoint.RespawnTimer then
        if not room:IsClear() then
            spawnpoint.RespawnTimer = spawnpoint.RespawnTimer - 1
            if spawnpoint.RespawnTimer % 2 == 0 then
                local vec = RandomVector() * 40
                local sparkle = Isaac.Spawn(1000, 7003, 0, spawnpoint.Position + vec, vec / -9, nil):ToEffect()
                if spawnpoint.SubType == 1 then
                    sparkle.Color = mod.ColorRoseGold
                end
                sparkle:Update()
            end

            if spawnpoint.RespawnTimer <= 0 then
                local flybomb = Isaac.Spawn(mod.FF.GoldenFlyBomb.ID, mod.FF.GoldenFlyBomb.Var, spawnpoint.SubType, spawnpoint.Position, Vector.Zero, nil)
                flybomb:GetData().DontMakeSpawnpoint = true
                flybomb:Update()
                spawnpoint.Tries = 10
                spawnpoint.Ent = flybomb
                spawnpoint.IsBomb = false
                spawnpoint.RespawnTimer = nil
                sfx:Play(SoundEffect.SOUND_SUMMONSOUND)
            end
        end
    elseif mod:IsReallyDead(spawnpoint.Ent) then
        spawnpoint.Tries = spawnpoint.Tries - 1
        if spawnpoint.Tries <= 0 then
            spawnpoint.RespawnTimer = 60
        end
    end
end

function mod:GoldenFlyBombInitCheck(bomb)
    for _, flybomb in pairs(Isaac.FindByType(mod.FF.GoldenFlyBomb.ID, mod.FF.GoldenFlyBomb.Var)) do
        if flybomb:IsDead() and flybomb.Position:Distance(bomb.Position) <= 1 then
            if flybomb.SubType == 1 then
                bomb:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/goldenflybomb/monster_rosegoldflybomb.png")
                bomb:GetSprite():LoadGraphics()
                bomb:ToBomb():SetExplosionCountdown(90)
                bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                bomb:GetData().playerGrab = true

                local arrow = Isaac.Spawn(1000, mod.FF.AwesomePointingArrow.Var, mod.FF.AwesomePointingArrow.Sub, bomb.Position, Vector.Zero, bomb)
                arrow:ToEffect():FollowParent(bomb)
                arrow:GetSprite():Play("Idle")
                arrow.Color = mod.ColorRoseGold2
                arrow:GetData().NoRotation = true
                arrow.SpriteRotation = 0
                arrow:Update()

                bomb:GetData().FunnyArrow = arrow
            else
                bomb:GetSprite():ReplaceSpritesheet(0, "gfx/enemies/goldenflybomb/monster_goldenflybomb.png")
                bomb:GetSprite():LoadGraphics()
            end
            for _, spawnpoint in pairs(mod.GoldenFlyBombSpawnpoints) do
                if flybomb.InitSeed == spawnpoint.Ent.InitSeed then
                    spawnpoint.Ent = bomb
                    spawnpoint.IsBomb = true
                end
            end
        end
    end
end