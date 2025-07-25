local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetTrinketIdByName("Sewn bond"),

    DAMAGE = 2,
    FAM_BLACKLIST = {
        [FamiliarVariant.INCUBUS] = true,
        [FamiliarVariant.UMBILICAL_BABY] = true,
    },
    FAM_TEARS = {
        [FamiliarVariant.BOT_FLY] = TearFlags.TEAR_SHIELDED,
    },

    TYPE = 350,
    KEY="SEBO",
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Sewn bond", DESC = "Familiars share their tear effects with the player" },
        { LANG = "ru",    NAME = "Сшитая связь", DESC = "Спутники делятся с игроком своими эффектами слёз" },
        { LANG = "spa",   NAME = "Enmendadura", DESC = "Los familiares copiarán el efecto de lágrimas del jugador" },
        { LANG = "zh_cn", NAME = "缝制腰带", DESC = "跟班获得角色的攻击特效" },
        { LANG = "ko_kr", NAME = "바느질 인연", DESC = "패밀리어의 눈물이 캐릭터의 눈물 효과를 가진 눈물을 발사합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "While held familiars attacks will have the same tear effects as their player."},
            {str = "If the familiar shoots tears then they will also copy the players range, tear height, etc..."},
            {str = "At a trinket stack of two familiars will gain 50% of Isaac's damage. And at three or more they will gain 100% of Isaac's damage."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function calcDamage(famDamage, plDamage, carried)
    if carried >= 3 then
        return math.max(famDamage, plDamage)
    elseif carried == 2 then
        return math.max(famDamage, plDamage/2)
    else
        return famDamage
    end
end

function item:OnShot(shot)
    if shot.SpawnerEntity and shot.SpawnerEntity.Type == 3 and not item.FAM_BLACKLIST[shot.SpawnerEntity.Variant] then
        if shot.SpawnerEntity:ToFamiliar().Player then
            local carried = TCC_API:Has(item.KEY, shot.SpawnerEntity:ToFamiliar().Player)
            if carried > 0 then
                local player = shot.SpawnerEntity:ToFamiliar().Player
                if shot.Type == EntityType.ENTITY_TEAR then
                    local newShot = player:FireTear(shot.Position, shot.Velocity, true, false, true, player)
                    newShot:AddTearFlags(shot.TearFlags | (item.FAM_TEARS[shot.SpawnerEntity.Variant] or 0))
                    newShot.CollisionDamage = calcDamage(shot.CollisionDamage, newShot.CollisionDamage, carried)
                    newShot.Scale = shot.Scale
                    newShot.Rotation = shot.Rotation
                    newShot.Height = shot.Height
                    shot:Remove()
                else
                    local newShot = player:FireTear(shot.Position, shot.Velocity, true, false, true, player)
                    shot:AddTearFlags((player.TearFlags | newShot.TearFlags | (item.FAM_TEARS[shot.SpawnerEntity.Variant] or 0)) & ~TearFlags.TEAR_LUDOVICO)
                    shot.CollisionDamage = calcDamage(shot.CollisionDamage, newShot.CollisionDamage, carried)
                    shot.Color = player.LaserColor
                    shot.SplatColor = player.LaserColor
                    newShot:Remove()
                end
            end
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    CURCOL:AddCallback(ModCallbacks.MC_POST_TEAR_INIT,  item.OnShot)
    CURCOL:AddCallback(ModCallbacks.MC_POST_LASER_INIT,  item.OnShot)
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_TEAR_INIT,  item.OnShot)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_LASER_INIT,  item.OnShot)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item