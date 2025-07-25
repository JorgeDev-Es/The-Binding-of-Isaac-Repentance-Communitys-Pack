local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Fettered heart"),
    EFFECTS = Isaac.GetEntityVariantByName("CURCOL status effects"),
    CHANCE = 10,

    DAMAGE = 0.60,

    TYPE = 100,
    KEY="FEHA",
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_DEVIL,
        ItemPoolType.POOL_ULTRA_SECRET,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_DEVIL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Fettered Heart", DESC = "Enemies may spawn fettered#Fettered enemies share damage taken with other enemies" },
        { LANG = "ru",    NAME = "Скованное сердце", DESC = "Враги могут появляться скованными#Скованные враги делят полученный урон с другими врагами" },
        { LANG = "spa",   NAME = "Corazón Encadenado", DESC = "Los enemigos podrán generarse encadenados#Los enemigos encadenados comparten el daño con los otros" },
        { LANG = "zh_cn", NAME = "铁索连环", DESC = "怪物生成时有10%的概率获得连环buff#房间内所有怪物都会遭受60%的拥有该buff的怪物受到的伤害" },
        { LANG = "ko_kr", NAME = "구속된 심장", DESC = "적들이 10%의 확률로 구속 상태에 걸립니다.#구속된 적 피격 시 방 안의 모든 적들도 60%의 피해를 받습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Enemies has a 10% chance to spawn fettered while carrying this item."},
            {str = "When a fettered enemy takes damage it will share 60% of that damage with all other enemies in the room."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function hasFlag(flags, flag)
    return flags % (flag + flag) >= flag
end

function item:OnNPCSpawn(NPC)
    if not NPC:IsBoss() and NPC:IsVulnerableEnemy() and NPC.CanShutDoors and NPC:GetDropRNG():RandomInt(100)+1 <= item.CHANCE then
        NPC:GetData().CURCOL_FETTERED = 1

        local eff = Isaac.Spawn(1000, item.EFFECTS, 0, NPC.Position, Vector(0,0), NPC):ToEffect()
        local sprite = eff:GetSprite()
    
        sprite.Offset = Vector(0, -NPC.Size - 15)
        sprite:Play('Fettered', true)
        eff:FollowParent(NPC)
        eff.DepthOffset = NPC.Position.Y + 10
    end
end

function item:OnEntityDamage(NPC, amount, flags, source)
    if NPC:GetData().CURCOL_FETTERED and not hasFlag(flags, DamageFlag.DAMAGE_CLONES) then
        local hitEnemies = false
        for key, value in pairs(Isaac.FindInRadius(NPC.Position, 640, EntityPartition.ENEMY)) do
            if not value:GetData().CURCOL_FETTERED and value:CanShutDoors() then
                hitEnemies = true
                value:TakeDamage(amount*item.DAMAGE, flags | DamageFlag.DAMAGE_CLONES, source, 0)
            end
        end

        if (NPC:GetData().CURCOL_FETTERED+15 < NPC.FrameCount or NPC.FrameCount == 1) and hitEnemies then
            CURCOL.GAME:SpawnParticles(NPC.Position, EffectVariant.CHAIN_GIB, math.random(2)+3, 2)
            CURCOL.GAME:ShakeScreen(8)
            CURCOL.GAME:GetRoom():EmitBloodFromWalls(1, 8)
            CURCOL.SFX:Play(SoundEffect.SOUND_BALL_AND_CHAIN_HIT, 0.9)
            NPC:GetData().CURCOL_FETTERED = NPC.FrameCount
        end
    end
end

local function OnEff(_, effect)
    if not effect.Parent or effect.Parent:IsDead() then
        effect:Remove()

        if effect.Parent then
            effect.Parent:GetData().CURCOL_FETTERED = nil
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    CURCOL:AddCallback(ModCallbacks.MC_POST_NPC_INIT, item.OnNPCSpawn)
    CURCOL:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnEntityDamage)
    CURCOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnEff, item.EFFECTS)
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, item.OnNPCSpawn)
    CURCOL:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnEntityDamage)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnEff, item.EFFECTS)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item