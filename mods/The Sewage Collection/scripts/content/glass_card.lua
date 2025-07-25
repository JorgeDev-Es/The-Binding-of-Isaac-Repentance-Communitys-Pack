--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local card = {
    ID = Isaac.GetCardIdByName("glassCard"),
    TAG = "glassCard",
    
    BACK = "gfx/SEWCOL_glass_card.anm2",
    FRONT = "gfx/animations/SEWCOL_glass_card_front.anm2",

    TYPE = 300,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Glass Card", DESC = "#{{SEWCOL_ColorReflect}}reflects{{ColorReset}} all items in the room" },
        { LANG = "ru",    NAME = "Стеклянная карта", DESC = "#{{SEWCOL_ColorReflect}}отражает{{ColorReset}} все предметы в комнате" },
        { LANG = "spa",   NAME = "Carta de cristal", DESC = "#{{SEWCOL_ColorReflect}}Reflejará{{ColorReset}} todos los objetos en la sala" },
        { LANG = "zh_cn", NAME = "玻璃卡", DESC = "#{{SEWCOL_ColorReflect}}镜像{{ColorReset}}房间内所有物品#镜像另一张玻璃卡会摧毁彼此" },
        { LANG = "ko_kr", NAME = "유리 카드", DESC = "#방 안의 모든 아이템을 {{SEWCOL_ColorReflect}}거울 형태{{ColorReset}}로 만듭니다.#거울 형태의 픽업은 습득 시 2배로 복사되나 피해를 받습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When used this card will apply the reflected modifier to all pickups in the room."},
            {str = "This includes pedestal items, normal pickups and even chests!"},
            {str = "Using the card to try and reflect another glass card will instead break it."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
-- if EID then
--     EID:addCard(card.ID, card.EID_DESCRIPTIONS[1].DESC)
--     local cardFrontSprite = Sprite()
--     cardFrontSprite:Load("gfx/animations/SEWCOL_glass_card_front.anm2", true)
--     EID:addIcon("Card"..card.ID, "Idle", -1, 8, 8, 0, 1, cardFrontSprite)
-- end

function card:OnUse()
    for key, pickup in pairs(Isaac.FindByType(5)) do
        if SEWCOL.REFLECTION.WHITELIST[pickup.Variant] and not pickup:GetData().SEWCOL_MIRRORED then
            if pickup.Variant == 300 and pickup.SubType == card.ID then
                pickup:Remove()
                SEWCOL.SFX:Play(SoundEffect.SOUND_FREEZE_SHATTER)
                Isaac.Spawn(1000, 15, 1, pickup.Position, Vector(0,0), pickup)
            else
                SEWCOL.Reflect(pickup:ToPickup(), true)
            end
        end
    end

    SEWCOL.SFX:Play(572)
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
SEWCOL:AddCallback(ModCallbacks.MC_USE_CARD, card.OnUse, card.ID)

return card

