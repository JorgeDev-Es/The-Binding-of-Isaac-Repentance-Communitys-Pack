--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Premature detonation"),
    EFFECTS = Isaac.GetEntityVariantByName("QUACOL status effects"),

    DEATH_CHANCE = 20,
    DEATH_RATE = 20,
    BOMB_LIST = {
        ['819.0'] = true, -- Bomb fly
        ['819.1'] = true, -- Eternal bomb fly
        ['16.1'] = true, -- Mulligoon
        ['16.2'] = true, -- Mulliboom
        ['821.0'] = true, -- Blaster
        ['25.0'] = true, -- Boom fly
        ['25.2'] = true, -- Drowned boom fly
        ['25.6'] = true, -- Tainted boom fly
        ['55.1'] = true, -- Kamikaze leech
        ['55.2'] = true, -- Holy leech
        ['250.0'] = true, -- Ticking spider
        ['869.0'] = true, -- Migraine
        ['225.0'] = true, -- Black maw
        ['277.0'] = true, -- Black bony

    },
    IPECAC_LIST = {
        ['25.5'] = true, -- Sick boom fly
        ['874.0'] = true, -- Gas dwarf
        ['238'] = true, -- Splasher
        ['61.1'] = true, -- Spit
        ['30.1'] = true, -- Gut
        ['88.1'] = true, -- Walking gut
        ['301.0'] = true, -- Poison mind
        ['875.0'] = true, -- Poot mine
    },

    KEY="PRDE",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BOMB_BUM,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Premature Detonation", DESC = "{{ArrowUp}} +5 Bombs#Explosive enemies die on their own#Explosive enemies have less health" },
	    { LANG = "ru",    NAME = "Преждевременная детонация", DESC = "{{ArrowUp}} +5 бомб#Взрывоопасные враги умирают сами по себе" },
        { LANG = "spa",   NAME = "Detonación anticipada", DESC = "{{ArrowUp}} +5 bombas#Enemigos de bombas mueren solos" },
        { LANG = "zh_cn", NAME = "过早爆震", DESC = "{{ArrowUp}} +5 炸弹#爆炸怪有概率自爆#毒属性怪物死亡时留下毒屁#炸弹棉花怪自爆时产生妈妈炸弹的效果" },
        { LANG = "ko_kr", NAME = "조기 폭발", DESC = "{{ArrowUp}} {{Bomb}}폭탄 +5#모든 폭발성 적들이 일정 확률로 자폭합니다.#폭발성 적들이 중독 상태에서 사망 시 주변에 독가스를 뿌립니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Enemies that would either explode when they die or drops bombs when they die will randomly die on their own."},
            {str = "If an enemy is poison/ipecac themed then it will leave a fart when it's killed."},
            {str = 'Bomb gaggers will trigger the "Mama mega!" effect when they are killed by this item'},
        }
    }
}

local function addModdedEnemy(enemy, list) item[list or "BOMB_LIST"][Isaac.GetEntityTypeByName(enemy)..'.'..Isaac.GetEntityVariantByName(enemy)] = true end

local cachedEnemies = {}
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnSpawn(NPC)
    if not NPC:GetData().PRDE_SPAWNED then
        NPC:GetData().PRDE_SPAWNED = true
        local key = NPC.Type..'.'..NPC.Variant
        if item.BOMB_LIST[key] or item.IPECAC_LIST[key] or NPC.Type == 844 or NPC:GetChampionColorIdx() == ChampionColor.BLACK then
            if not cachedEnemies[NPC.InitSeed] then
                NPC.HitPoints = math.floor(NPC.HitPoints * 0.5)
                NPC:SetColor(Color(1,0.5,0.5,0.8), 0, 99, false, true)

                local eff = Isaac.Spawn(1000, item.EFFECTS, 0, NPC.Position, Vector(0,0), NPC):ToEffect()
                local sprite = eff:GetSprite()
        
                sprite.Offset = Vector(0, -(NPC.Size * 2) - 10)
                sprite:Play('Volatile', true)
                eff:FollowParent(NPC)
                eff.DepthOffset = NPC.Position.Y + 10
            end
        
            cachedEnemies[NPC.InitSeed] = NPC
        end
    end
end

function item:OnUpdate()
    for key, enemy in pairs(cachedEnemies) do
        if enemy.FrameCount > 80 and enemy.FrameCount % item.DEATH_RATE == 0 and enemy:GetDropRNG():RandomInt(100)+1 <= item.DEATH_CHANCE then
            if not enemy:IsDead() then
                enemy:TakeDamage(enemy.MaxHitPoints*2, (DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IGNORE_ARMOR), EntityRef(Isaac.GetPlayer()), 0)

                if item.IPECAC_LIST[enemy.Type..'.'..enemy.Variant] then
                    QUACOL.GAME:Fart(enemy.Position, 85, nil, enemy.Mass > 8 and 1.5 or 1)
                elseif enemy.Type == 844 then
                    QUACOL.GAME:GetRoom():MamaMegaExplosion(enemy.Position)
                end
            end

            cachedEnemies[key] = nil

            return
        end
    end
end

local function OnEff(_, effect)
    if not effect.Parent or effect.Parent:IsDead() or not cachedEnemies[effect.Parent.InitSeed] then
        effect:Remove()
    end
end

--##############################################################################--
--############################# MOD COMPATIBILITY ##############################--
--##############################################################################--
function item:PostLoad()
    if deliveranceContent then
        addModdedEnemy("Explosimaw")
        addModdedEnemy("Joker")
    end

    if FiendFolio then
        addModdedEnemy("Powderkeg")
        addModdedEnemy("Litling")
        addModdedEnemy("Mullikaboom")
        addModdedEnemy("Stomy", "IPECAC_LIST")
        addModdedEnemy("Cordify", "IPECAC_LIST")
        addModdedEnemy("Connipshit", "IPECAC_LIST")
        addModdedEnemy("Load", "IPECAC_LIST")
        addModdedEnemy("Dr. Shambles")
        addModdedEnemy("Warty")
        addModdedEnemy("Grazer")
        addModdedEnemy("Rufus")
        addModdedEnemy("Bombmuncher")
        addModdedEnemy("Flinty")
        addModdedEnemy("Blasted")
        addModdedEnemy("Grimoire")
        addModdedEnemy("Hangman")
        addModdedEnemy("Splodum")
        addModdedEnemy("Boiler")
        addModdedEnemy("Psleech")
        addModdedEnemy("Ticking Fly")
        addModdedEnemy("Anti Golem")
        addModdedEnemy("Quack")
        addModdedEnemy("Unpawtunate")
        addModdedEnemy("Phoenix")
    end

    if REVEL then
        addModdedEnemy("Ice Hazard Troll Bomb")
        addModdedEnemy("Demobip")
        addModdedEnemy("Cannonbip")
        addModdedEnemy("Bomb Sack")
        addModdedEnemy("Chicken")
        addModdedEnemy("Shy Fly")
    end

    if CiiruleanItems then
        addModdedEnemy("Kaboom Fly")
        addModdedEnemy("Bloated Fly")
        addModdedEnemy("Full Spit", "IPECAC_LIST")
    end

    QUACOL:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)
end

QUACOL:AddCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    QUACOL:AddCallback(ModCallbacks.MC_NPC_UPDATE,    item.OnSpawn )
    QUACOL:AddCallback(ModCallbacks.MC_POST_UPDATE,   item.OnUpdate)
    QUACOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnEff, item.EFFECTS)
end

function item:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_NPC_UPDATE,  item.OnSpawn )
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_UPDATE, item.OnUpdate)
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnEff, item.EFFECTS)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item