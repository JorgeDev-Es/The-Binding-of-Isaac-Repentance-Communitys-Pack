local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Papyrus rags"),

    BOOKS = { 65, 34, 287, 58, 97, 35, 192, 545, 123, 712, 584 },

    TYPE = 100,
    KEY="PARA",
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Papyrus Rags", DESC = "{{Library}} Use a random book every 3rd room#{{BossRoom}} Use a random book every boss room" },
        { LANG = "ru",    NAME = "Папирусные тряпки", DESC = "{{Library}} Используйте случайную книгу в каждой 3-й комнате#{{BossRoom}} Используйте случайную книгу в каждой комнате с боссом" },
        { LANG = "spa",   NAME = "Trapos de papiro", DESC = "{{Library}} Usa un libro aleatorio cada tercer sala#{{BossRoom}} Usará un libro en la sala del jefe" },
        { LANG = "zh_cn", NAME = "莎草纸残片", DESC = "{{Library}} 每打开三个未探索房间触发一次随机书本效果#{{BossRoom}} 每层的首领房触发一次随机书本效果#(译者按：莎草纸的莎音同缩)" },
        { LANG = "ko_kr", NAME = "파피루스의 붕대", DESC = "{{Library}} 3번째 방마다 랜덤 책 효과를 발동합니다.#{{BossRoom}} 보스방 진입 시 랜덤 책 효과를 발동합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Upon entering a room for the first time the item will add 1 to it's counter. When the counter hits 3 it a random book will be used and the counter resets. Entering a boss room also triggers a random book and resets the counter regardless of how far it was."},
            {str = "Instead of selecting a random book this item instead selects a random library item. Which means that most modded books should also work."},
        },
        { -- Notes
            {str = "Notes", fsize = 2, clr = 3, halign = 0},
            {str = '"The bible" cannot trigger during Satan fights.'},
            {str = '"Satanic bible" and "Book of revelations" have a reduced chance of triggering.'},
            {str = '"How to jump" cannot trigger.'},
            {str = '"Book of the dead" will give 5 bone orbitals since it will otherwise grant nothing.'},
        }
    }
}

local count = 1
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnRoom()
    local room = CURCOL.GAME:GetRoom()

    if room:IsFirstVisit() then
        local room = CURCOL.GAME:GetRoom():GetType()
        if count == 3 or room == RoomType.ROOM_BOSS then
            local level = CURCOL.GAME:GetLevel()
            local RNG = level:GetDevilAngelRoomRNG()
            local id = TCC_API:GetRandomCollectible(RNG, "BOOK")
            
            while id > 731 and CURCOL.SAVEDATA.PAPYRUS_NO_MOD do
                id = TCC_API:GetRandomCollectible(RNG, "BOOK")
            end

            if id == CollectibleType.COLLECTIBLE_HOW_TO_JUMP
            or (id == CollectibleType.COLLECTIBLE_BIBLE and room == RoomType.ROOM_BOSS and CURCOL.GAME:GetLevel():GetStage() >= LevelStage.STAGE5)
            or (id == CollectibleType.COLLECTIBLE_SATANIC_BIBLE and RNG:RandomInt(100)+1 <= 80)
            or (id == CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS and RNG:RandomInt(100)+1 <= 80)
            or CURCOL.CONF:GetCollectible(id).Type ~= ItemType.ITEM_ACTIVE then 
                id = item.BOOKS[RNG:RandomInt(#item.BOOKS)+1]
            end

            local numPlayers = CURCOL.GAME:GetNumPlayers()
            for i=1, numPlayers do
                local player = CURCOL.GAME:GetPlayer(tostring((i-1)))
                local itemCount = TCC_API:Has(item.KEY, player)
                for i=1, itemCount do
                    player:UseActiveItem(id, UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER)

                    if id == CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD then
                        for i=1, 5 do
                            CURCOL.SeedSpawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_ORBITAL, 0, player.Position, Vector(0,0), player)
                        end
                    end
                end
            end

            CURCOL.SFX:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)

            if room == RoomType.ROOM_BOSS then
                count = 1
                return
            end
        end

        count = count >= 3 and 1 or count + 1
    end
end

--[[##########################################################################
############################### MOD CONFIG MENU ##############################
##########################################################################]]--
if ModConfigMenu then
    local json = require("json")

    ModConfigMenu.AddSetting("Cursed Collection", "Items", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return CURCOL.SAVEDATA.PAPYRUS_NO_MOD end,
        OnChange = function(currentBool) 
            CURCOL.SAVEDATA.PAPYRUS_NO_MOD = currentBool
            CURCOL:SaveData(json.encode(CURCOL.SAVEDATA))
        end,
        Info = {"Make papyrus rags not use modded books"},
        Display = function()
            local onOff = "False"
            if CURCOL.SAVEDATA.PAPYRUS_NO_MOD then onOff = "True" end
            return "Disable modded books: " .. onOff
        end
    })
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable() CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnRoom) end
function item:Disable() CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnRoom) end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item