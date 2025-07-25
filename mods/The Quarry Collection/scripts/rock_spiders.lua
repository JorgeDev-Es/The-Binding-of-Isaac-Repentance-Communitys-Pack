--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
-- TODO: CLEAN/OPTIMISE THIS FILE!!! (it is doodoo poopie quality)
local json = require("json")

local familiar = {
    VARIANT = Isaac.GetEntityVariantByName("QUACOL Rock spider"),
    COAL_VARIANT = Isaac.GetEntityVariantByName("QUACOL Coal"),
}

--##############################################################################--
--############################### FAMILIAR LOGIC ###############################--
--##############################################################################--
function familiar:AI(npc)
    npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
    local sprite = npc:GetSprite()
    if not sprite:IsPlaying("Appear") or sprite:IsFinished("Appear") then
        local data = npc:GetData()
        local target = data.QUACOL_TARGET_POS or npc.Player.Position
        local lastMove = data.QUACOL_MOVE_FRAME or 0

        if lastMove+50 < npc.FrameCount then
            local entities = Isaac.FindInRadius(npc.Position, 180, EntityPartition.ENEMY)
            local enemies = {}
            for k, enemy in pairs(entities) do
                if enemy:IsVulnerableEnemy() and enemy:CanShutDoors() then
                    table.insert(enemies, enemy)
                end
            end

            if #enemies > 0 then
                target = enemies[math.random(#enemies)].Position
            else
                target = npc.Player.Position+Vector(20,20):Rotated(math.random(360))
            end

            local angle = target:Distance(npc.Position) > 90 and math.random(180)-90 or math.random(60)-30

            angle = (angle) * (math.pi/180);
            local rotatedX = math.cos(angle) * (target.X - npc.Position.X) - math.sin(angle) * (target.Y-npc.Position.Y) + npc.Position.X;
            local rotatedY = math.sin(angle) * (target.X - npc.Position.X) + math.cos(angle) * (target.Y - npc.Position.Y) + npc.Position.Y;

            target = Vector(rotatedX, rotatedY)
            
            data.QUACOL_TARGET_POS = target
            lastMove = npc.FrameCount
            data.QUACOL_MOVE_FRAME = lastMove
        end

        if lastMove+40 > npc.FrameCount and npc.Position:Distance(target) > 20 then
            npc.Velocity = (target - npc.Position):Resized(npc.SubType < 5 and 5 or 10)

            if QUACOL.GAME:GetRoom():GetGridPathFromPos(npc.Position + npc.Velocity) > 999 then
                npc.Velocity = Vector(0,0)
            end
        end

        if npc.Velocity:Distance(Vector(0,0)) > 1 then
            sprite:Play("Walk")

            if npc.SubType > 5 and npc.FrameCount % 8 == 0 then
                Isaac.Spawn(1000, EffectVariant.EMBER_PARTICLE, 0, npc.Position, npc.Velocity:Clamped(-2,-2,2,2), npc)
            end
        else
            sprite:Play("Idle")

            if npc.SubType > 5 and npc.FrameCount % 8 == 0 then
                Isaac.Spawn(1000, EffectVariant.EMBER_PARTICLE, 0, npc.Position, Vector(1,1):Rotated(math.random(360)), npc)
            end
        end
    end
end

QUACOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiar.AI, familiar.VARIANT)

function familiar:Init(npc)
    if not (npc.SubType > 2 and npc.SubType < 6) and #Isaac.FindByType(3, familiar.VARIANT, -1, true, false) > (QUACOL.SAVEDATA.ROCK_LIMIT or 25) then 
        npc:Remove()
        return
    end

    local sprite = npc:GetSprite();
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    npc.Friction = 2
    npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    npc:GetSprite():Play("Appear",true)
    npc:AddEntityFlags(EntityFlag.FLAG_APPEAR)

    if npc.SubType < 3 then
        -- Normal                
        npc:GetData().QUACOL_ROCK_SPIDER_HITS = 4
    elseif npc.SubType < 6 then
        -- Tinted
        npc:GetData().QUACOL_ROCK_SPIDER_HITS = 15
    else
        -- Coal
        npc:GetData().QUACOL_ROCK_SPIDER_HITS = 3
    end
end

QUACOL:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiar.Init, familiar.VARIANT)

function familiar:Collision(npc1, npc2, mysteryBoolean)
    if npc2.Type == 33 and npc1.SubType < 3 then
        npc1:Remove()
        QUACOL.SeedSpawn(3, familiar.VARIANT, npc1.SubType+6, npc1.Position, Vector(0,0), npc1)
    elseif npc2:CanShutDoors() and not (npc2:HasMortalDamage() or npc2.HitPoints <= 0) and npc2.Type ~= 33 then
        npc1:GetData().QUACOL_ROCK_SPIDER_HITS = (npc1:GetData().QUACOL_ROCK_SPIDER_HITS or 4) -1
        npc2:TakeDamage(npc1.Player.Damage*2, npc1.SubType >= 6 and DamageFlag.DAMAGE_FIRE or 0, EntityRef(npc1), 0)

        if npc1:IsDead() or npc1:GetData().QUACOL_ROCK_SPIDER_HITS <= 0 then
            npc1.Player:ThrowBlueSpider(npc1.Position, npc1.Position)

            if npc1.SubType < 3 then
                -- Normal                
                local blood = Isaac.Spawn(1000, 7, 0, npc1.Position, Vector(0,0), npc1)
                blood.Color = Color(0,0,0,0.7,0,0,0)
            elseif npc1.SubType < 6 then
                -- Tinted
                local heart = Isaac.Spawn(5, 10, 3, npc1.Position, Vector(0,0), npc1)
                heart.Velocity = Vector(4,4):Rotated(math.random(360))
                
                local blood = Isaac.Spawn(1000, 7, 0, npc1.Position, Vector(0,0), npc1)
                blood.Color = Color(0,0,0,0.7,0.2,0.4,0.7)
            else
                -- Coal
                local coal = Isaac.Spawn(3, familiar.COAL_VARIANT, npc1.SubType-6, npc1.Position, Vector(0,0), npc1)
                coal:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_DAMAGE_BLINK)

                local blood = Isaac.Spawn(1000, 7, 0, npc1.Position, Vector(0,0), npc1)
                blood.Color = Color(0,1,1,1,0.7,0.3,0)
            end
            
            for i=1, 1+math.random(2) do
                local particle = Isaac.Spawn(1000, 35, 0, npc1.Position, Vector(2,2):Rotated(math.random(360)), npc1)
                particle.Color = Color(0.1,0.1,0.1,1,0,0,0)
            end

            Isaac.Spawn(1000, 145, 0, npc1.Position, Vector(0,0), npc1)

            QUACOL.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
            npc1:Die()
        end
    end
end

QUACOL:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.Collision, familiar.VARIANT)

function familiar:CoalAI(npc)
    if QUACOL.GAME:GetRoom():GetAliveEnemiesCount() < 1 and npc.FrameCount > 30 then
        QUACOL.SFX:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        Isaac.Spawn(1000, 145, 0, npc.Position, Vector(0,0), npc)
        local blood = Isaac.Spawn(1000, 7, 0, npc.Position, Vector(0,0), npc)
        blood.Color = Color(0,1,1,1,0.7,0.3,0)
        npc:Remove()
    end
end

QUACOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiar.CoalAI, familiar.COAL_VARIANT)

function familiar:CoalInit(npc)
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    npc:GetData().QUACOL_COAL_HITS = 3
end

QUACOL:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiar.CoalInit, familiar.COAL_VARIANT)

function familiar:CoalCollision(npc1, npc2, mysteryBoolean)
    if npc2:IsEnemy() then
        npc2:TakeDamage(npc1.Player.Damage*2, 0, EntityRef(npc1), 0)
        npc1:GetData().QUACOL_COAL_HITS = (npc1:GetData().QUACOL_COAL_HITS or 3) -1

        if npc1:IsDead() or npc1:GetData().QUACOL_COAL_HITS <= 0 then
            npc1:Die()
        end
    elseif npc2.Type == EntityType.ENTITY_PROJECTILE then
        npc2:Die()
    end
end

QUACOL:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.CoalCollision, familiar.COAL_VARIANT)

--##############################################################################--
--############################### COMPOST SYNERGY ##############################--
--##############################################################################--
function familiar:OnCompostUse(_, _, player, _, _, _)
    for _, spider in ipairs(Isaac.FindByType(3, familiar.VARIANT, -1)) do
        QUACOL.SeedSpawn(3, familiar.VARIANT, spider.SubType, spider.Position, spider.Velocity, spider:ToFamiliar().Player or player)
    end
end

QUACOL:AddCallback(ModCallbacks.MC_USE_ITEM, familiar.OnCompostUse, CollectibleType.COLLECTIBLE_COMPOST)

--##############################################################################--
--######################### SACRIFICIAL ALTAR SYNERGY ##########################--
--##############################################################################--
function familiar:OnAltarUse(_, _, player, _, _, _)
    for _, spider in ipairs(Isaac.FindByType(3, familiar.VARIANT, -1)) do
        spider:Remove()
        QUACOL.SeedSpawn(5, 20, (spider.SubType > 2 and spider.SubType < 6) and 3 or 1, spider.Position, Vector.Zero, spider:ToFamiliar().Player or player)
    end
end

QUACOL:AddCallback(ModCallbacks.MC_USE_ITEM, familiar.OnAltarUse, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

--##############################################################################--
--############################### MOD CONFIG MENU ##############################--
--##############################################################################--
if ModConfigMenu then
    ModConfigMenu.AddSetting("Quarry Collection", "Rock spiders", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return QUACOL.SAVEDATA.ROCK_LIMIT or 25 end,
        OnChange = function(value) 
            QUACOL.SAVEDATA.ROCK_LIMIT = value
            QUACOL:SaveData(json.encode(QUACOL.SAVEDATA))
        end,
        Info = {"Maximum amount of friendly rock spiders that can exist at the same time. Tinted rock spiders ignore this limtit (default: 25)"},
        Display = function()
            return "Max rock spiders: " .. (QUACOL.SAVEDATA.ROCK_LIMIT or 25)
        end,
        Minimum = 1,
        -- Maximum = 100,
        ModifyBy = 1,
    })
end