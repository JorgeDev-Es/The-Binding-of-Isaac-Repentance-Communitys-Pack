local mod = RegisterMod("Brimstone Buffer?", 1)
local buffedLasers = {}
local buffedLaserTypes = {"gfx/007.001_Thick Red Laser.anm2", "gfx/007.011_Thicker Red Laser.anm2", "gfx/007.009_Brimtech.anm2"}
local newValues = {
    ["Brimstone"] = 14,
    ["ShoopDaWhoop"] = 14,
    ["LilBrimstone"] = 7,
    ["Revelation"] = 30,
    ["Azazel"] = 14,
    ["TAzazel"] = 14
    } -- default

local theuhhfunnymemelaser = "gfx/007.003_Shoop Laser.anm2"
local ANGELBRIM = "gfx/007.005_LightBeam.anm2"
local WHYISBROSHITTINONME = "gfx/007.012_Thick Brown Laser.anm2"


    function mod:getFiringPlayer(laser)
        if laser.SpawnerType == EntityType.ENTITY_PLAYER then
            return laser.SpawnerEntity:ToPlayer()
        elseif laser.SpawnerType == EntityType.ENTITY_FAMILIAR then
            if laser.SpawnerEntity ~= nil then
                if laser.SpawnerEntity.Variant == 80 or laser.SpawnerEntity.Variant == 240 or laser.SpawnerEntity.Variant == 61 or laser.SpawnerEntity.Variant == 235 or laser.SpawnerEntity.Variant == 238 then return laser.SpawnerEntity:ToFamiliar().Player end--lil brimstone 61, incubus 80, twisted pair 235 gello 240 clots 238
            end
        end
        return nil
    end
    
    function mod:ACutiePootieLilBrimstonePet(laser)
        if laser.SpawnerType == EntityType.ENTITY_FAMILIAR then
            return laser.SpawnerEntity.Variant == 61
        end
        return false
    end

    function mod:OnEveryFrame()
        local lasers = Isaac.FindByType(EntityType.ENTITY_LASER, -1, -1, 0, 0)
        for _, i in pairs(lasers) do
            if i.SpawnerType ~= nil then
                local plr = mod:getFiringPlayer(i)
                if plr ~= nil then
                    local buff = true
                    for _, l in pairs(buffedLasers) do
                        if i.InitSeed == l.InitSeed then buff = false break end
                    end
                    if buff then
                        local notdefaultbrim = false
                        local newTime
                        local laserSprite = i:GetSprite():GetFilename()
                        newTime = math.floor(i:ToLaser().Timeout * Isaac.GetPlayer().ShotSpeed + .5)
                        notdefaultbrim = true
                        if notdefaultbrim then
                            table.insert(buffedLasers, i)
                            i:ToLaser().Timeout = newTime
                        end
                    end
                end
            end
        end
        if Game():GetFrameCount() % 30 == 0 then
            local newBuffedLasers = {}
            for _, i in pairs(buffedLasers) do
                if i:Exists() then
                    table.insert(newBuffedLasers, i)
                end
            end
            buffedLasers = newBuffedLasers
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.OnEveryFrame)