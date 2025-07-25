--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local trinket = { 
    ID = Isaac.GetTrinketIdByName("Slot reel"),

    KEY="SLRE",
    TYPE = 350,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Slot Reel", DESC = "Machines may spawn slots when broken#Beggars may spawn slots when paying out" },
        { LANG = "ru",    NAME = "Слот барабан", DESC = "Машины могут создавать другие слоты или попрошаек, когда они сломаны#Попрошайки могут создавать другие слоты или попрошаек при выплате" },
        { LANG = "spa",   NAME = "Carrete de tragaperras", DESC = "Las máquinas / mendigos pueden generar otras/os máquinas / mendigos al ser destruídos" },
        { LANG = "zh_cn", NAME = "赌博机号码盘", DESC = "当赌博机坏掉或乞丐离开时，60%的概率生成一个新的赌博机或乞丐" },
        { LANG = "ko_kr", NAME = "슬롯머신 회전부", DESC = "슬롯머신을 파괴하거나 거지가 아이템을 주고 떠날 때 일정 확률로 새로운 슬롯머신을 소환합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When a machine is broken or a beggar pays out it may spawn a new machine/beggar in the room."},
            {str = "This spawn chance is increased based on the trinket multiplier"},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function trinket:OnSlot(machine)
    local multiplier = TCC_API:HasGlo(trinket.KEY)
    local rng = RNG()
    rng:SetSeed(machine.InitSeed,35)

    if multiplier > 0 and rng:RandomInt(100)+1 <= 60+(10*(multiplier-1)) then
        local room = GOLCG.GAME:GetRoom()
        local newPosition = room:FindFreePickupSpawnPosition(room:GetRandomPosition(20), 0, true, false)

        GOLCG.GAME:SpawnParticles(newPosition, EffectVariant.GOLD_PARTICLE, 5, 1)
        GOLCG.GAME:SpawnParticles(newPosition, EffectVariant.CRACKED_ORB_POOF, 1, 0)

        GOLCG.SFX:Play(SoundEffect.SOUND_THUMBSUP, 0.8, 0, false, 0.25)
        GOLCG.SFX:Play(SoundEffect.SOUND_BIRD_FLAP, 3, 35, false, 0.75)

        GOLCG.SeedSpawn(EntityType.ENTITY_SLOT, GOLCG.machines[math.random(#GOLCG.machines)], 0, newPosition, Vector(0, 0), nil)
    end
end

--##############################################################################--
--################################### EXPORT ###################################--
--##############################################################################--

function trinket:Enable()
    TCC_API:AddTCCCallback("TCC_BEGGAR_LEAVE", trinket.OnSlot)
    TCC_API:AddTCCCallback("TCC_MACHINE_BREAK", trinket.OnSlot)
end

function trinket:Disable()
    TCC_API:RemoveTCCCallback("TCC_BEGGAR_LEAVE", trinket.OnSlot)
    TCC_API:RemoveTCCCallback("TCC_MACHINE_BREAK", trinket.OnSlot)
end

TCC_API:AddTCCInvManager(trinket.ID, trinket.TYPE, trinket.KEY, trinket.Enable, trinket.Disable)

return trinket