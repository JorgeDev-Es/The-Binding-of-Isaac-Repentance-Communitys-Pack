local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Blood of the abyss"),

    PICKUP_SFX = Isaac.GetMusicIdByName("TOYCOL_BLOOD_OF_THE_ABYSS_PICKUP"),
    DAMAGE_SFX = Isaac.GetSoundIdByName("TOYCOL_BLOOD_OF_THE_ABYSS_DAMAGE"),

    DAMAGE_FG_GFX = Isaac.GetEntityVariantByName("TOYCOL_BLOOD_OF_THE_ABYSS_FG"),
    DAMAGE_BG_GFX = Isaac.GetEntityVariantByName("TOYCOL_BLOOD_OF_THE_ABYSS_BG"),

    COSTUME_3 = Isaac.GetCostumeIdByPath("gfx/characters/TOYCOL_blood_abyss_3.anm2"),
    COSTUME_2 = Isaac.GetCostumeIdByPath("gfx/characters/TOYCOL_blood_abyss_2.anm2"),
    COSTUME_1 = Isaac.GetCostumeIdByPath("gfx/characters/TOYCOL_blood_abyss_1.anm2"),

    TEARS = 7,

    PLAYER_BLACKLIST = {
        [PlayerType.PLAYER_KEEPER] = true,
        [PlayerType.PLAYER_THELOST] = true,
        [PlayerType.PLAYER_KEEPER_B] = true,
        [PlayerType.PLAYER_THELOST_B] = true,
        [PlayerType.PLAYER_BETHANY] = true,
        [PlayerType.PLAYER_THEFORGOTTEN] = true,
    },

    KEY = "BLAB",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_GREED_SECRET,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Blood of the Abyss", DESC = "Ignore 3 hits every floor#{{SoulHeart}} Replaces all heart containers with soul hearts" },
        { LANG = "ru",    NAME = "Кровь Бездны", DESC = "Игнорируешь 3 попадания на каждом этаже#{{SoulHeart}} Заменяет все красные сердца на сердца душ." },
        { LANG = "spa",   NAME = "Sangre del abismo", DESC = "Ignorará el daño 3 veces por piso#{{SoulHeart}} Reemplaza los corazones con corazones de alma" },
        { LANG = "zh_cn", NAME = "深渊之血", DESC = "每层抵挡3次角色受到的伤害#{{SoulHeart}} 将所有心之容器和骨心转换成魂心#(来自 空洞骑士)" },
        { LANG = "ko_kr", NAME = "생명혈", DESC = "매 층마다 피격을 3회 무효화합니다.#{{SoulHeart}} 획득 시 모든 최대 체력을 소울 하트로 바꿉니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants the player 3 free hits every floor."},
            {str = "Removes all bone hearts and heart containers with soul hearts."},
            {str = "This replacement effect is excluded for the following characters: Keeper, Tained Keeper, Lost, Tainted Lost, Bethany and The Forgotten"},
            {str = "Carrying more than one instance of this item will increase the amount of hits that can be ignored per floor (+3 per item). However, the costume granted by this item will not show how many lives the player has beyond 3."},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "Hollow knight".'},
            {str = 'The item is referencing the "Lifeblood" mechanic within the game.'},
        }
    }
}

local loadCheck = false
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function setPlayerShields(player, add)
    local carried = player:GetCollectibleNum(item.ID)

    if carried > 0 then
        local type = player:GetPlayerType()
        if type == PlayerType.PLAYER_THESOUL then type = PlayerType.PLAYER_THEFORGOTTEN end
        local identifier = player.ControllerIndex..","..type

        if TOYCG.SAVEDATA.BLAB then
            if TOYCG.SAVEDATA.BLAB[identifier] then
                local amount = TOYCG.SAVEDATA.BLAB[identifier]

                if add then
                    amount = amount + 3
                    TOYCG.SAVEDATA.BLAB[identifier] = amount
                end

                if amount > 0 then
                    player:AddNullCostume(item["COSTUME_"..(amount > 3 and 3 or amount)])
                end
            else
                TOYCG.SAVEDATA.BLAB[identifier] = (carried > 0 and carried or 1)*3
                player:AddNullCostume(item.COSTUME_3)
            end

            TOYCG:SaveData(json.encode(TOYCG.SAVEDATA))
        end
    end
end

function item:OnDamage(entity, _, flags, _, _)
    if TCC_API:Has(item.KEY, entity:ToPlayer()) > 0
    and (flags & DamageFlag.DAMAGE_INVINCIBLE) == 0
    and (flags & DamageFlag.DAMAGE_FAKE) == 0 then
        local player = entity:ToPlayer()
        local type = player:GetPlayerType()
        if type == PlayerType.PLAYER_THESOUL then type = PlayerType.PLAYER_THEFORGOTTEN end
        local identifier = player.ControllerIndex..","..type

        if TOYCG.SAVEDATA.BLAB and TOYCG.SAVEDATA.BLAB[identifier] and TOYCG.SAVEDATA.BLAB[identifier] > 0 then
            -- Ignore sacrifices
            if  TOYCG.GAME:GetRoom():GetType() == RoomType.ROOM_SACRIFICE and (flags & DamageFlag.DAMAGE_SPIKES) ~= 0 then
                return nil
            end

            -- Update "lives"
            local oldHealth = (TOYCG.SAVEDATA.BLAB[identifier] and TOYCG.SAVEDATA.BLAB[identifier] or 3)
            local newHealth = oldHealth - 1
        
            TOYCG.SAVEDATA.BLAB[identifier] = newHealth

            -- Play "take damage" sfx
            -- TOYCG.SFX:Play(item.DAMAGE_SFX, 0.8, 0, false, 0.75)
            TOYCG.SFX:Play(item.DAMAGE_SFX, 1, 0, false, 1, 0)
            TOYCG.SFX:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)

            -- Shake screen
            TOYCG.GAME:ShakeScreen(10)

            -- Spawn effects
            Isaac.Spawn(EntityType.ENTITY_EFFECT, item.DAMAGE_FG_GFX, 1, player.Position, Vector(0, 0), player).DepthOffset = player.DepthOffset + 10
            Isaac.Spawn(EntityType.ENTITY_EFFECT, item.DAMAGE_BG_GFX, 1, player.Position, Vector(0, 0), player).DepthOffset = player.DepthOffset - 10

            -- Spawn tears
            local tearColor = Color(1, 1, 1, 1, 0, 0, 0)
            tearColor:SetColorize(0, 0.75, 6, 1)

            for i=1, item.TEARS do
                local randomVelocity = Vector(math.random(3,5)*(math.random(2) == 1 and -1 or 1), math.random(3,5)*(math.random(2) == 1 and -1 or 1))
                local newTear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, player.Position - Vector(0, 4), randomVelocity, player):ToTear()
                newTear.FallingSpeed = -math.random(7, 12)
                newTear.FallingAcceleration = math.random(10, 13)/10
                newTear.Scale = math.random(70, 120)/100
                newTear.Color = tearColor
            end

            -- Fake damage for invis frames
            player:TakeDamage(1, (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_INVINCIBLE), EntityRef(player), 0)

            -- Remove old costume
            player:TryRemoveNullCostume(item["COSTUME_" .. tostring(oldHealth > 3 and 3 or oldHealth)])

            -- Add new costume if they still have "lives" left
            if newHealth and newHealth > 0 then
                player:AddNullCostume(item["COSTUME_" .. tostring(newHealth > 3 and 3 or newHealth)])
            end

            TOYCG:SaveData(json.encode(TOYCG.SAVEDATA))
    
            -- Cancel damage
            return false
        end
    end
end

function item:OnNewFloor()
    if loadCheck then
        TOYCG.SAVEDATA.BLAB = {}

        for i=1,TOYCG.GAME:GetNumPlayers() do
            setPlayerShields(TOYCG.GAME:GetPlayer(i-1))
        end
    end

    loadCheck = true
end

function item:OnGrab() TOYCG.SharedOnGrab(item.PICKUP_SFX, 1, 0, true) end

function item:OnCollect(player)
    local hearts = player:GetEffectiveMaxHearts()
    if hearts > 0 and not item.PLAYER_BLACKLIST[player:GetPlayerType()] then
        local slot1 = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
        local slot2 = player:GetActiveCharge(ActiveSlot.SLOT_SECONDARY)
        local slot3 = player:GetActiveCharge(ActiveSlot.SLOT_POCKET)

        -- Temp fullcharge all actives in case of the player carrying alabaster box and such
        player:FullCharge(ActiveSlot.SLOT_PRIMARY, true)
        player:FullCharge(ActiveSlot.SLOT_SECONDARY, true)
        player:FullCharge(ActiveSlot.SLOT_POCKET, true)

        player:AddMaxHearts(-hearts, true)
        player:AddBoneHearts(-hearts, true)
        player:AddSoulHearts(hearts)

        player:SetActiveCharge(slot1, ActiveSlot.SLOT_PRIMARY)
        player:SetActiveCharge(slot2, ActiveSlot.SLOT_SECONDARY)
        player:SetActiveCharge(slot3, ActiveSlot.SLOT_POCKET)

        TOYCG.SFX:Stop(SoundEffect.SOUND_BATTERYCHARGE)
    end

    if not TOYCG.SAVEDATA.BLAB then TOYCG.SAVEDATA.BLAB = {} end
    setPlayerShields(player, true)
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    TOYCG:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,    item.OnDamage, EntityType.ENTITY_PLAYER)
    TOYCG:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,     item.OnNewFloor                        )
    loadCheck = true

    for i=1,TOYCG.GAME:GetNumPlayers() do
        setPlayerShields(TOYCG.GAME:GetPlayer(i-1))
    end
end

function item:Disable()
    TOYCG:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,    item.OnDamage, EntityType.ENTITY_PLAYER)
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL,     item.OnNewFloor                        )
    loadCheck = false
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab,    item.ID, false)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect, item.ID, false)

return item