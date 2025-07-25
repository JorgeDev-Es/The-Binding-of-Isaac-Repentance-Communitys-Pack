--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Secretion"),
    COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/CURCOL_secretion_charged.anm2"),

    SPREAD_RATE = 2,
    DISTANCE = 30,
    WAVE_CHANCE = 100,
    CHARGE_TIME = 100,
    
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

    KEY="SECN",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_ULTRA_SECRET,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Secretion", DESC = "While firing, charge up a stream of blood creep and tears" },
        { LANG = "ru",    NAME = "Секреция", DESC = "Во время стрельбы зарядите струю крови и слез" },
        { LANG = "spa",   NAME = "Secreción", DESC = "Al disparar, se recargará un ataque de creep sangriento y lágrimas" },
        { LANG = "zh_cn", NAME = "分泌物", DESC = "蓄力后向眼泪发射方向喷射出血泪和血渍" },
        { LANG = "ko_kr", NAME = "분비 작용", DESC = "공격키를 1.5 초 이상 누르면 충전되며 공격키를 떼면 공격 방향으로 핏방울을 뿌리며 빨간 장판이 뿌려집니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "After firing for ~1.5 seconds, releasing the fire button will trigger a steam of blood tears. On top of this a trail of red creep will be created in the direction it was fired. When this trail hits an obstace both it and the stream of tears will stop."},
            {str = "This item shows a chargebar if the player has them enabled in their settings."},
        },
        { -- Interacions
            {str = "Interacions", fsize = 2, clr = 3, halign = 0},
            {str = "Loki's horns makes the player fire 4 steams of blood."},
        }
    }
}

local lastTear = {}
local activeWaves = {}

--TODO: Add synergies!
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function genSprite()
    local sprite = Sprite()
    sprite:Load("gfx/animations/CURCOL_chargebar_secretion.anm2", false)
    return sprite
end

local function addCostume(player)
    player:AddNullCostume(item.COSTUME)
    player:Update()
end

local function createShot(parent, direction)
    local rotation = math.random(15)*(math.random(2) > 1 and 1 or -1)
    local newTear = parent:FireTear(parent.Position, (direction*(math.random(10)+5)):Rotated(rotation), true, false, false)
    if newTear.Variant ~= TearVariant.BLOOD then newTear:ChangeVariant(TearVariant.BLOOD) end
    newTear.FallingSpeed = -math.random(7, 12)
    newTear.FallingAcceleration = math.random(10, 13)/10
end

local function startWave(player, direction, rotation)
    local dir = direction:Rotated(rotation or 0)

    for i=1, 3 do createShot(player, dir) end

    activeWaves[tostring(rotation or 0)..player.FrameCount..player.InitSeed] = { 
        pos = player.Position, 
        dir = dir, 
        parent = player, 
        frame = CURCOL.GAME:GetFrameCount(),
    }
end

local function OnCharge(player, dir)
    player:TryRemoveNullCostume(item.COSTUME)

    CURCOL.SFX:Play(SoundEffect.SOUND_PESTILENCE_MAGGOT_SHOOT)
    
    startWave(player, dir)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) then
        startWave(player, dir, 90)
        startWave(player, dir, 180)
        startWave(player, dir, 270)
    end
end

function item:OnUpdate()
    for key, value in pairs(activeWaves) do
        if CURCOL.GAME:GetFrameCount() >= value.frame+item.SPREAD_RATE then
            local newPos = value.pos+(value.dir*item.DISTANCE)
            local isFree = CURCOL.GAME:GetRoom():GetGridEntityFromPos(newPos)

            if (not isFree or item.WHITELIST[isFree:GetType()] or isFree.CollisionClass == GridCollisionClass.COLLISION_NONE)
            and CURCOL.GAME:GetRoom():GetClampedPosition(newPos, 0):Distance(newPos) < 5 
            and value.dir:Distance(Vector(0,0)) >= 1  then
                local effect = CURCOL.SeedSpawn(1000, EffectVariant.PLAYER_CREEP_RED, 0, newPos, Vector(0,0), value.parent):ToEffect()
                effect.CollisionDamage = math.max(value.parent.Damage * 0.04, 0.25)
                effect:GetSprite():LoadGraphics()
                
                createShot(value.parent, value.dir)

                activeWaves[key].pos = newPos
                activeWaves[key].frame = CURCOL.GAME:GetFrameCount()
            else
                activeWaves[key] = nil
            end
        end
    end
end

function item:OnNewRoom() activeWaves = {} end
--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    CURCOL:AddCallback(ModCallbacks.MC_POST_UPDATE,        item.OnUpdate  )
    CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,      item.OnNewRoom )
    TCC_API:AddTCCChargeBar(item.KEY, genSprite, item.CHARGE_TIME, true, item.ID, addCostume, OnCharge)
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_UPDATE,        item.OnUpdate  )
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,      item.OnNewRoom )
    TCC_API:RemoveTCCChargeBar(item.KEY)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item