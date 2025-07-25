local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Sigil of knowledge"),
    EFFECT = Isaac.GetEntityVariantByName("Sigil text"),

    PICKUP_SFX = Isaac.GetMusicIdByName("TOYCOL_SIGIL_PICKUP"),
    TRIGGER_SFX = Isaac.GetSoundIdByName("TOYCOL_SIGIL_TRIGGER"),

    CLEAR_PERCENT = 55,

    KEY = "SIKN",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Sigil of Knowledge", DESC = "Reveals the map after enough rooms have been explored#Also triggers upon pickup" },
        { LANG = "ru",    NAME = "Печать знаний", DESC = "Открывает карту после исследования достаточного количества комнат#Также срабатывает при поднятии" },
        { LANG = "spa",   NAME = "Sigilo del saber", DESC = "Revela el mapa completo después de haber explorado suficientes habitaciones#También se activa al tomarlo" },
        { LANG = "zh_cn", NAME = "知识魔印", DESC = "探索过每层超过一半的房间时会触发以下效果：#揭示全部地图#打开隐藏房和超级隐藏房#移除迷途和致盲诅咒#拾起该道具时也会生效#(出自 死亡细胞)" },
        { LANG = "ko_kr", NAME = "지식의 인장", DESC = "!!! 스테이지 전체의 55% 분량 이상의 방을 방문 시 이하 효과 발동:#{{Collectible333}} 모든 방의 위치를 표시합니다.#{{Collectible76}} 비밀방이 자동으로 열립니다.#Blind, Lost 저주를 제거합니다.#!!! 획득 시에도 이 아이템의 효과 발동" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "After exploring 55% (or higher) of the floors room the map will be revealed and secret rooms will be opened."},
            {str = "Also removes curse of the lost and curse of the blind when triggered."},
            {str = "Also triggers this effect when picking up the item."},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "Dead cells".'},
            {str = "The item and it's effects reference the " .. '"' .. "Explorer's Rune" .. '"' .. " that can be found in the game."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function revealUltra(level)
    for i = 0, 169 do -- 13*13 is void floor size
        local room = level:GetRoomByIdx(i)
        
        if room.Data and room.Data.Type == RoomType.ROOM_ULTRASECRET then
            if room.DisplayFlags & 1 << 2 == 0 then
                room.DisplayFlags = room.DisplayFlags | 1 << 2
                return
            end
        end
    end
end

local function getVisitCount()
    local cleared = 0

    for i = 0, 169 do -- 13*13 is void floor size
        local room = TOYCG.GAME:GetLevel():GetRoomByIdx(i)
        
        if room.VisitedCount > 0 then
            cleared = cleared + 1
        end
    end

    return cleared
end

local function TriggerEffect(level)
    -- Trigger mechanical effect
    level:SetCanSeeEverything(true)
    level:RemoveCurses(LevelCurse.CURSE_OF_DARKNESS | LevelCurse.CURSE_OF_THE_LOST)

    level:ApplyBlueMapEffect()
    level:ApplyCompassEffect(true)
    level:ApplyMapEffect()

    revealUltra(level)

    level:UpdateVisibility()
    
    -- Trigger visuals
    local SigilEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, item.EFFECT, 1, Vector(320, 300), Vector(0,0), TOYCG.GAME:GetPlayer(0))
    SigilEffect:GetSprite():Play('Idle')
    SigilEffect.DepthOffset = 10000
    SigilEffect:Update()

    SigilEffect:GetSprite():Render(Vector(360, 300), Vector(0,0), Vector(0,0));

    -- Trigger SFX
    TOYCG.SFX:Play(item.TRIGGER_SFX, 1)

    -- Update state
    TOYCG.SAVEDATA.SIKN.hasTriggered = true
end

function item:OnNewFloor() TOYCG.SAVEDATA.SIKN = { clearCount = 0, hasTriggered = false } end

function item:OnEnter()
    if TOYCG.SAVEDATA.SIKN and not TOYCG.SAVEDATA.SIKN.hasTriggered and TOYCG.GAME:GetRoom():IsFirstVisit() then
        local level = TOYCG.GAME:GetLevel()

        if level:GetCurrentRoomIndex() ~= level:GetStartingRoomIndex() then
            TOYCG.SAVEDATA.SIKN.clearCount = TOYCG.SAVEDATA.SIKN.clearCount+1

            if TOYCG.SAVEDATA.SIKN.clearCount >= (level:GetRooms().Size/100*item.CLEAR_PERCENT) then
                TriggerEffect(level)
            end
            
            TOYCG:SaveData(json.encode(TOYCG.SAVEDATA))
        end
    end
end

function item:OnGrab() TOYCG.SharedOnGrab(item.PICKUP_SFX, 5, nil, true) end
function item:OnCollect() 
    TOYCG.SAVEDATA.SIKN = { clearCount = 0, hasTriggered = true }
    TriggerEffect(TOYCG.GAME:GetLevel())
    TOYCG:SaveData(json.encode(TOYCG.SAVEDATA))
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    TOYCG:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, item.OnNewFloor)
    TOYCG:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,  item.OnEnter   )
    TOYCG.SAVEDATA.SIKN = { 
        clearCount = getVisitCount(), 
        hasTriggered = TOYCG.SAVEDATA.SIKN and TOYCG.SAVEDATA.SIKN.hasTriggered or false 
    }
end

function item:Disable()
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, item.OnNewFloor)
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM,  item.OnEnter   )
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab, item.ID, false)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect, item.ID, false)

return item