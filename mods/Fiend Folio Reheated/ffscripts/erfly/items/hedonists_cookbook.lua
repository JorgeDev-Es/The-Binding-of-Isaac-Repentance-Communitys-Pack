local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.hedonistPos = mod.hedonistPos or {}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, useflags, activeslot)
    local LowestHealthEnemies = {}
    local LowestHealth = 99999999
    local npcs = Isaac.FindInRadius(player.Position, 500, EntityPartition.ENEMY)
    for _, npc in ipairs(npcs) do
        npc = npc:ToNPC()
        if npc and npc:IsVulnerableEnemy() then
            if npc.MaxHitPoints <= LowestHealth then
                if not mod:CheckIDInTable(npc, FiendFolio.BadEnts)
                and not npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)
                and not npc:IsBoss()
                then
                    if npc.MaxHitPoints < LowestHealth then
                        LowestHealthEnemies = {}
                        LowestHealth = npc.MaxHitPoints
                    end
                    table.insert(LowestHealthEnemies, npc)
                end
            end
        end
    end
    if #LowestHealthEnemies > 0 then
        sfx:Play(mod.Sounds.Plorp, 1, 0, false, 1)
        for _, ent in pairs(LowestHealthEnemies) do
            local creep = Isaac.Spawn(1000, 25, 0, ent.Position, Vector.Zero, ent):ToEffect()
            creep.Timeout = 120
            Isaac.Spawn(1000, 132, 0, ent.Position, Vector.Zero, ent).Color = mod.ColorWebWhite
            ent:Kill()
            for i = 0, 120, 5 do
                mod.hedonistPos[ent.InitSeed] = ent.Position
                mod.scheduleForUpdate(function()
                    --sfx:Play(mod.Sounds.Plorp, 0.9, 0, false, math.random(130,150)/100)
                    local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.HEDONISTS_COOKBOOK)
                    local newtear = Isaac.Spawn(2, 0, 0, mod.hedonistPos[ent.InitSeed], Vector(0,1+rng:RandomInt(15)/3):Rotated(rng:RandomInt(360)), player):ToTear()
                    newtear.FallingSpeed = -18 - rng:RandomInt(20)
                    newtear.FallingAcceleration = 1.1
                    newtear.Height = -10
                    newtear.CanTriggerStreakEnd = false
                    newtear.CollisionDamage = player.Damage / 5.5
                    newtear.Scale = math.min(1, player.Damage/5.5)
                    newtear.SpawnerEntity = player
                    newtear.Color = mod.ColorWebWhite
                    newtear:GetData().dontCollideBombs = true
                    newtear:Update()
                end, i)
            end
        end

        sfx:Play(mod.Sounds.HedonistChant, 1, 0, false, 1)
        for i = 1, 100 do
            local vecX = math.random(50,100)
            if math.random(2) == 1 then
                vecX = vecX * -1
            end
    
            local side = -400 + math.random(room:GetGridWidth()*40 + 650)
    
            local eff = Isaac.Spawn(1000, 138, 961, Vector(side, 30 + math.random(room:GetGridHeight() * 40 + 120)), Vector(vecX, 0), nil):ToEffect()
            eff.Color = Color(1,1,1,0.3,1,1,1)
            eff:GetData().opacity = 0.1
            eff:GetSprite():Stop()
            eff:GetSprite():SetFrame(math.random(4)-1)
            eff.Timeout = 50
            eff:Update()
        end
    else
        sfx:Play(mod.Sounds.HedonistMmm, 0.6, 0, false, math.random(90,150)/100)
    end
    return true
end, mod.ITEM.COLLECTIBLE.HEDONISTS_COOKBOOK)