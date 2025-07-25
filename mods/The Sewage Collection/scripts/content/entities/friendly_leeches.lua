--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local json = require("json")

local familiar = {
    VARIANT = Isaac.GetEntityVariantByName("SEWCOL friendly leech"),

    MV_DIRECTIONS ={
        [0] = "SwimRight",
        [90] = "SwimDown",
        [180] = "SwimLeft",
        [270] = "SwimUp",
    },

    HP_DIRECTIONS ={
        [0] = "HopRight",
        [90] = "HopDown",
        [180] = "HopLeft",
        [270] = "HopUp",
    },
}

--##############################################################################--
--############################### FAMILIAR LOGIC ###############################--
--##############################################################################--
local function closestDegreeFinder(deg, cat)
    local index = 0
    local closestDistance = nil
    local cachedDistance = nil
  
    for key, value in pairs(familiar[cat]) do
      local distance = math.abs(key - deg)
  
      if distance > 180 then
        distance = math.abs(distance - 360)
      end

      if not closestDistance or distance < closestDistance then
        closestDistance = distance
        index = key
      elseif distance > closestDistance then

      end
    end

    return familiar[cat][index]
end

function familiar:AI(leech)
    local sprite = leech:GetSprite()
    local data = leech:GetData()
    local room = SEWCOL.GAME:GetRoom()

    leech:PickEnemyTarget(120, 13, 1 | 2)

    if leech.Target and leech.Target:IsDead() then leech.Target = nil end

    if room:HasWater() then
        leech.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
        leech.Friction = 1

        local targetPos = (leech.Target or leech.Player).Position
        local dir = (targetPos - leech.Position)
        -- Generic velocity to target and sprite changes
        leech.Velocity = (leech.Velocity + dir:Clamped(-1, -1, 1, 1):Rotated(30-math.random(60))):Clamped(-7,-7,7,7)
        sprite:Play(closestDegreeFinder(dir:GetAngleDegrees(), "MV_DIRECTIONS"))
    else
        leech.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        leech.Friction = 0.8

        if sprite:GetFrame() >= 14 then
            -- Check direction and start new jump
            local targetPos = leech.Target and leech.Target.Position or leech.Player.Position + Vector(20,20):Rotated(math.random(360))
            local dir = (targetPos - leech.Position)

            leech.Velocity = dir:Clamped(-1, -1, 1, 1)*5
            sprite:Play(closestDegreeFinder(dir:GetAngleDegrees(), "HP_DIRECTIONS"))
            sprite:SetFrame(0)
        end
    end
end

SEWCOL:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiar.AI, familiar.VARIANT)

function familiar:Init(npc)
    if #Isaac.FindByType(3, familiar.VARIANT, 0) > (SEWCOL.SAVEDATA.LEECH_LIMIT or 25) then 
        npc:Remove()
        return
    end

    if not npc.Player then npc.Player = Isaac.GetPlayer() end
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    npc.Friction = 0.8
end

SEWCOL:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiar.Init, familiar.VARIANT)

function familiar:Collision(npc1, npc2)
    if npc2:IsVulnerableEnemy() and
    not (npc2:HasMortalDamage() or npc2.HitPoints <= 0)
    and (not npc1:GetData().SEWCOL_LAST_COL or Isaac.GetFrameCount() - npc1:GetData().SEWCOL_LAST_COL >= 30) then
        npc1.HitPoints = npc1.HitPoints - 1
        npc1:GetData().SEWCOL_LAST_COL = Isaac.GetFrameCount()
        npc2:TakeDamage(npc1.Player.Damage*(npc1.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 3.5 or 2.5), 0, EntityRef(npc1), 0)

        if npc1:IsDead() or npc1.HitPoints <= 0 then
            local blood = Isaac.Spawn(1000, 7, 0, npc1.Position, Vector(0,0), npc1)
            blood.Color = Color(0,0,0,0.7,0,0,0)

            SEWCOL.SeedSpawn(1000, 131, 0, npc1.Position, Vector(0,0), npc1)

            SEWCOL.SFX:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
            npc1:Die()
        end
    end
end

SEWCOL:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiar.Collision, familiar.VARIANT)

function familiar:Damage(leech)
    if leech.Variant == familiar.VARIANT then
        return false
    end
end

SEWCOL:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, familiar.Damage, 3)

--##############################################################################--
--############################### COMPOST SYNERGY ##############################--
--##############################################################################--
function familiar:OnCompostUse(_, _, player, _, _, _)
    for _, leech in ipairs(Isaac.FindByType(3, familiar.VARIANT, 0)) do
        SEWCOL.SeedSpawn(3, familiar.VARIANT, 0, leech.Position, leech.Velocity, leech:ToFamiliar().Player or player)
    end
end

SEWCOL:AddCallback(ModCallbacks.MC_USE_ITEM, familiar.OnCompostUse, CollectibleType.COLLECTIBLE_COMPOST)

--##############################################################################--
--######################### SACRIFICIAL ALTAR SYNERGY ##########################--
--##############################################################################--
function familiar:OnAltarUse(_, _, player, _, _, _)
    for _, leech in ipairs(Isaac.FindByType(3, familiar.VARIANT, 0)) do
        leech:Remove()
        SEWCOL.SeedSpawn(5, 20, 1, leech.Position, Vector.Zero, leech:ToFamiliar().Player or player)
    end
end

SEWCOL:AddCallback(ModCallbacks.MC_USE_ITEM, familiar.OnAltarUse, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

--##############################################################################--
--############################### MOD CONFIG MENU ##############################--
--##############################################################################--
if ModConfigMenu then
    ModConfigMenu.AddSetting("Sewage Collection", "Leeches", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return SEWCOL.SAVEDATA.LEECH_LIMIT or 25 end,
        OnChange = function(value) 
            SEWCOL.SAVEDATA.LEECH_LIMIT = value
            SEWCOL:SaveData(json.encode(SEWCOL.SAVEDATA))
        end,
        Info = {"Maximum amount of friendly leeches that can exist at the same time (default: 25)"},
        Display = function()
            return "Max leeches: " .. (SEWCOL.SAVEDATA.LEECH_LIMIT or 25)
        end,
        Minimum = 1,
        -- Maximum = 100,
        ModifyBy = 1,
    })
end