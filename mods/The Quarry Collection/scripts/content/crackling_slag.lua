--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Crackling slag"),
    EFFECT = Isaac.GetEntityVariantByName("QUACOL Fire jet"),

    SPREAD_RATE = 3,
    DISTANCE = 30,
    WAVE_CHANCE = 25,
    LUDO_RATE = 20,

    LASER_BLACKLIST = {
        [4] = true,
        [7] = true
    },
    WHITELIST = {
        [GridEntityType.GRID_NULL] = true,
        [GridEntityType.GRID_DECORATION] = true,
        [GridEntityType.GRID_SPIDERWEB] = true,
        [GridEntityType.GRID_STAIRS] = true,
        [GridEntityType.GRID_GRAVITY] = true,
        [GridEntityType.GRID_PRESSURE_PLATE] = true,
        [GridEntityType.GRID_TELEPORTER] = true,
        [GridEntityType.GRID_SPIKES_ONOFF] = true,
        [GridEntityType.GRID_SPIKES] = true
    },
    DIRS = {
        [0] = Vector(-1, 0),
        [1] = Vector(0, -1),
        [2] = Vector(1, 0),
        [3] = Vector(0, 1),
    },

    KEY="CRSL",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CRANE_GAME,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SECRET,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Crackling Slag", DESC = "Occasionally shoot waves of fire" },
	    { LANG = "ru",    NAME = "Потрескивающий шлак", DESC = "Время от времени стреляйте волнами огня" },
	    { LANG = "spa",   NAME = "Escoria crepitante", DESC = "Puedes lanzar rastros de fuego al disparar" },
	    { LANG = "zh_cn", NAME = "爆裂煤渣", DESC = "角色有25%的概率向眼泪发射方向发射火焰波" },
        { LANG = "ko_kr", NAME = "딱딱한 광재", DESC = "눈물 발사 시 25%의 확률로 해당 눈물이 지나가는 자리에 불꽃을 소환합니다.#!!! {{Luck}}행운 수치 비례: 행운 15 이상일 때 45% 확률" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "The player has a 25% chance to shoot a wave of fire."},
            {str = "Luck increases this chance up to 45%."},
            {str = "These waves of fire go in the same direction as the tear that it triggered on."},
        },
        { -- Synergies
            {str = "Synergies", fsize = 2, clr = 3, halign = 0},
            {str = 'If the player has tears that "lob" then tears will leave a cross of fire upon landing.'},
            {str = 'If the player shoots lasers then they will also shoot multiple fire waves on top of this.'},
            {str = 'Ludovico shoots waves of fire in random directions when colliding.'},
            {str = 'Moms knife and forgottens bone create a cross of fire when thrown.'},
        }
    }
}

local activeWaves = {}
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function startWave(source, player, direction, pos)
    local wave = {
        pos = pos or source.Position, 
        dir = direction or source.Velocity:Normalized(), 
        source = source,
        parent = player,
        frame = QUACOL.GAME:GetFrameCount()+0,
        tflags = source.TearFlags or 0,
        color = source.Color,
        scale = source.Scale or 1,
        startScale = source.Scale or 1,
        shrink = player.TearRange and (0.325 / (player.TearRange/40)) or 0.05
    }

    -- 6.5
    if source.HasTearFlags then
        wave.isHoming = source:HasTearFlags(TearFlags.TEAR_HOMING)
        wave.isSpec = source:HasTearFlags(TearFlags.TEAR_SPECTRAL)
        wave.isExp = source:HasTearFlags(TearFlags.TEAR_EXPLOSIVE)
        wave.isOcc = source:HasTearFlags(TearFlags.TEAR_OCCULT)
        wave.isCont = source:HasTearFlags(TearFlags.TEAR_CONTINUUM)
        wave.isPlan = source:HasTearFlags(TearFlags.TEAR_ORBIT)
        wave.isBoun = source:HasTearFlags(TearFlags.TEAR_BOUNCE)
        wave.isShiel = source:HasTearFlags(TearFlags.TEAR_SHIELDED)
    end

    activeWaves[QUACOL.GAME:GetFrameCount()..'.'..tablelength(activeWaves)] = wave
end

function item:OnTearUpdate(tear)
    if (tear:CollidesWithGrid() or tear.Height >= -5) then
        if not tear:GetData()['QUACOL_SLAG_EFFECT'] then            
            local player = QUACOL.GetShooter(tear)
            if tear.FallingAcceleration > 0.5 and player then
                if tablelength(activeWaves) > 8 then return end
                tear:GetData()['QUACOL_SLAG_EFFECT'] = true
                startWave(tear, player, Vector(1, 0))
                startWave(tear, player, Vector(0, 1))
                startWave(tear, player, Vector(-1, 0))
                startWave(tear, player, Vector(0, -1))
            end
        end
    elseif tear.FrameCount == 1 and tear.FallingAcceleration <= 0.5 then
        local player = QUACOL.GetShooter(tear)
        if player and TCC_API:Has(item.KEY, player) > 0
        and tear:GetDropRNG():RandomInt(100)+1 <= item.WAVE_CHANCE+(player.Luck < 0 and 0 or player.Luck > 15 and 15 or player.Luck) then
            if tablelength(activeWaves) > 8 then return end
            startWave(tear, player)
        end
    elseif tear:GetData()['QUACOL_SLAG_EFFECT'] and tear.Height <= 0 then
        tear:GetData()['QUACOL_SLAG_EFFECT'] = nil
    end
end

function item:OnLaserInit(laser)
    if not laser:GetData().QUACOL_INIT and laser.Visible then
        laser:GetData().QUACOL_INIT = true
        local player = QUACOL.GetShooter(laser)
        if player and TCC_API:Has(item.KEY, player) > 0 and not item.LASER_BLACKLIST[laser.Variant] and not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
            if tablelength(activeWaves) > 8 then return end

            local deg = Vector.Zero

            if laser.SubType == LaserSubType.LASER_SUBTYPE_RING_PROJECTILE then
                deg = player:GetShootingInput()
            else
                if laser.RotationDegrees ~= 0 then
                    deg = Vector.FromAngle(laser.RotationDegrees)
                elseif laser.AngleDegrees ~= 0 then
                    deg = Vector.FromAngle(laser.AngleDegrees) 
                elseif laser.EndPoint then
                    deg = (laser.EndPoint - laser.Position):Normalized()
                else
                    deg = item.DIRS[player:GetHeadDirection()]
                end
            end

            if deg.X == 0 and deg.Y == 0 then deg = item.DIRS[player:GetHeadDirection()] or item.DIRS[0] end

            -- local deg = item.DIRS[player:GetHeadDirection()] or item.DIRS[0]
            -- if deg.X == 0 and deg.Y == 0 then 
            --     deg = player:GetShootingInput() 
                
            --     if deg.X == 0 and deg.Y == 0 then 
            --         deg = Vector.FromAngle(laser.RotationDegrees) 
            --         if deg.X == 0 and deg.Y == 0 then deg = Vector.FromAngle(laser.AngleDegrees) end
            --     end
            -- end
            
            if laser.Variant == 10 then
                QUACOL.SFX:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 1, 2, false, 1.5)
        
                local color = Color(0,0.8,1,1,0,0.1,0.2)

                for i=1, math.random(3)+4 do   
                    local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, laser.EndPoint, Vector(4,4):Rotated(math.random(360)), nil)
                    eff:SetColor(color, 0, 99, 0, false)
                end
            
                local effect = Isaac.Spawn(1000, item.EFFECT, 0, laser.EndPoint, Vector(0,0), laser)
                effect:SetColor(color, 0, 99, 0, false)
                local data = effect:GetData()

                data.QUACOL_TFLAGS = laser.TearFlags    
                data.QUACOL_SOURCE = laser
                data.QUACOL_BLOCK = laser:HasTearFlags(TearFlags.TEAR_SHIELDED)
            else
                startWave(laser, player, deg)
                
                -- For some reason this code won't accept rotations below 22deg??????
                if laser.Variant ~= 2 then
                    startWave(laser, player, deg:Rotated(22))
                    startWave(laser, player, deg:Rotated(-22))
                end
            end
        end
    end
end

function item:OnKnifeUpdate(knife)
	local player = QUACOL.GetShooter(knife)
	if not player or TCC_API:Has(item.KEY, player) == 0 then return end
    local distance = knife:GetKnifeDistance()
    if not knife:GetData()['QUACOL_SLAG_EFFECT'] and distance >= knife.MaxDistance then
        knife:GetData()['QUACOL_SLAG_EFFECT'] = true
        if tablelength(activeWaves) > 8 then return end
        startWave(knife, player, Vector.FromAngle(knife.Rotation))
        startWave(knife, player, Vector.FromAngle(knife.Rotation+90))
        startWave(knife, player, Vector.FromAngle(knife.Rotation+180))
        startWave(knife, player, Vector.FromAngle(knife.Rotation+270))
    elseif distance == 0 then
        knife:GetData()['QUACOL_SLAG_EFFECT'] = nil
    end
end

function item:OnLudo(tear)
    if tear.FrameCount % item.LUDO_RATE == 0 then
        local player = QUACOL.GetShooter(tear)
    
        if player and TCC_API:Has(item.KEY, player) > 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
            startWave(tear, player, Vector.FromAngle(math.random(360)))
        end
    end
end

local function createFireWave(value, key, newPos, isFirst)
    if isFirst then
        QUACOL.SFX:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 1, 2, false, 1.5)

        local effPos =  Vector(value.source.Position.X,value.source.Position.Y+(value.source.Height or 0))
        local effVel = value.dir*4

        for i = 1, math.random(3)+4 do   
            local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, effPos, effVel:Rotated(math.random(40)-20), nil)
            eff:SetColor(value.color, 0, 99, 0, false)
        end
    end

    local effect = Isaac.Spawn(1000, item.EFFECT, 0, newPos, Vector(0,0), value.parent or Isaac.GetPlayer())
    local data = effect:GetData()
    effect:GetSprite().Scale = Vector(value.scale,value.scale)
    data.QUACOL_TFLAGS = value.tflags

    if value.color then
        effect:SetColor(value.color, 0, 99, 0, false)
    end

    data.QUACOL_SOURCE = value.source
    data.QUACOL_BLOCK = value.isShiel

    effect:GetSprite():LoadGraphics()

    activeWaves[key].pos = newPos
    activeWaves[key].frame = QUACOL.GAME:GetFrameCount()
    activeWaves[key].scale = value.scale-value.shrink
end

function item:OnUpdate()
    for key, value in pairs(activeWaves) do
        local isFirst = value.scale == value.startScale
        if isFirst or QUACOL.GAME:GetFrameCount() >= value.frame+item.SPREAD_RATE then
            local newPos = isFirst and value.pos or value.pos+(value.dir*item.DISTANCE)

            if value.isHoming == true then
                local closest = nil
                local closestValue = 100
                
                local enemies = Isaac.FindInRadius(newPos, 90, EntityPartition.ENEMY)

                for i=1, #enemies do
                    if enemies[i]:CanShutDoors() and enemies[i].Position:Distance(newPos) < closestValue then
                        closest = enemies[i]
                        closestValue = enemies[i].Position:Distance(newPos)
                    end
                end

                if closest then
                    local angle = (closest.Position-newPos):GetAngleDegrees() - value.dir:GetAngleDegrees()
                    if angle < -20 then angle = -20 elseif angle > 20 then angle = 20 end

                    local rotatedDir = value.dir:Rotated(angle)
                    value.dir = rotatedDir
                    activeWaves[key].dir = rotatedDir
                    
                    newPos = value.pos+(value.dir*item.DISTANCE)
                end
            end

            if value.isOcc == true then
                local newDir = (value.dir+value.parent:GetLastDirection()) / 2
                value.dir = newDir
                activeWaves[key].dir = newDir
            end

            if value.isPlan == true then
                local newDir = value.dir:Rotated(30)
                value.dir = newDir
                activeWaves[key].dir = newDir
            end


            if value.scale > 0
            and value.dir:Distance(Vector(0,0)) >= 0.1  then
                local hasGrid = QUACOL.GAME:GetRoom():GetGridEntityFromPos(newPos)
                if (value.isSpec or not hasGrid or item.WHITELIST[hasGrid:GetType()] or hasGrid.CollisionClass == GridCollisionClass.COLLISION_NONE) then
                    local wallDist = QUACOL.GAME:GetRoom():GetClampedPosition(newPos, 0):Distance(newPos)
                    if wallDist < (value.isCont and 60 or 5) then
                        createFireWave(value, key, newPos, isFirst)

                        goto skip
                    elseif value.isCont then
                        local shape = QUACOL.GAME:GetRoom():GetRoomShape()
                        local height = shape > 7 and 1200 or 600 --QUACOL.GAME:GetRoom():GetGridWidth()*30
                        local width = shape > 7 and 1280 or 640 --QUACOL.GAME:GetRoom():GetGridHeight()*30

                        local X = newPos.X >= width and 0 or newPos.X <= 0 and width or newPos.X
                        local Y = newPos.Y >= height and 0 or newPos.Y <= 0 and height or newPos.Y

                        createFireWave(value, key, Vector(X, Y), isFirst)

                        goto skip
                    end
                elseif value.isBoun then
                    local newDir = value.dir:Rotated(180)

                    createFireWave(value, key, value.pos+(newDir*item.DISTANCE), isFirst)

                    activeWaves[key].dir = newDir

                    goto skip
                end
            end

            activeWaves[key] = nil

            if value.isExp then
                QUACOL.GAME:BombExplosionEffects(newPos, 10, value.tflags or TearFlags.TEAR_NORMAL, value.color or Color.Default, value.parent, 1, true, value.parent, DamageFlag.DAMAGE_EXPLOSION)
            end

            ::skip::
        end
    end
end

function item:OnNewRoom() activeWaves = {} end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    QUACOL:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE,   item.OnTearUpdate )
    QUACOL:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE,  item.OnLaserInit  )
    QUACOL:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, item.OnLudo       )
    QUACOL:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE,  item.OnLudo       )
    QUACOL:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE,  item.OnKnifeUpdate)
    QUACOL:AddCallback(ModCallbacks.MC_POST_UPDATE,        item.OnUpdate     )
    QUACOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,      item.OnNewRoom    )
end

function item:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_TEAR_UPDATE,   item.OnTearUpdate )
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_LASER_UPDATE,  item.OnLaserInit  )
    QUACOL:RemoveCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, item.OnLudo       )
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_LASER_UPDATE,  item.OnLudo       )
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_KNIFE_UPDATE,  item.OnKnifeUpdate)
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_UPDATE,        item.OnUpdate     )
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,      item.OnNewRoom    )
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item