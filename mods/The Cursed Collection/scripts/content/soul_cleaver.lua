--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Soul cleaver"),

    WISPS = 3,

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Soul Cleaver", DESC = "{{Collectible712}} splits collectibles into item wisps" },
        { LANG = "ru",    NAME = "Рассекатель душ", DESC = "{{Collectible712}} разбивает артефакты коллекционирования на огоньки артефактов" },
        { LANG = "spa",   NAME = "Cuchilla espiritual", DESC = "{{Collectible712}} Partirá los items en fuegos" },
        { LANG = "zh_cn", NAME = "碎魂魔刃", DESC = "{{Collectible712}} 使用后消耗基座上的道具生成三个道具灵火#其中两个灵火与消耗的道具相同，剩下一个灵火随机生成" },
        { LANG = "ko_kr", NAME = "영혼 도축칼", DESC = "{{Collectible712}} 가능한 경우 현재 방의 모든 아이템을 해당 아이템에 대응되는 레메게톤 불꽃 2개로 분해합니다.#{{Collectible712}} 추가로 Lemegeton 아이템을 1회 사용합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When used will replace collectibles in the room with 2 item wisps of the same type and one random item wisp. If an item is not able to turn into wisps then 1 random wisp and two enemy souls will be granted."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnUse(_, RNG, player)
    local collectibles = Isaac.FindByType(5, 100)

    local removed = false

    for i=1, #collectibles do
        local collectible = collectibles[i]:ToPickup()
        local conf = CURCOL.CONF:GetCollectible(collectible.SubType)
        local isSummon = conf and conf.Tags % (ItemConfig.TAG_SUMMONABLE+ItemConfig.TAG_SUMMONABLE) >= ItemConfig.TAG_SUMMONABLE
        collectible:Remove()

        local color =  Color(1,1,1,0.7)
        color:SetColorize(0.4, 0, 1, 1)

        for i=1, item.WISPS do
            if (i<3) then
                if isSummon then
                    player:AddItemWisp(collectible.SubType, collectible.Position, true)
                else
                    local soul = Isaac.Spawn(1000,EffectVariant.ENEMY_SOUL,0,collectible.Position,RandomVector(),collectible)
                    soul.Target = player
                end
            else
                player:UseActiveItem(712, false, false, true)
            end
        end

        local eff = Isaac.Spawn(1000,EffectVariant.CLEAVER_SLASH,0,collectible.Position,collectible.Velocity,collectible)
        eff:SetColor(color, -1, 99, false, false)
        eff:GetSprite().PlaybackSpeed = 0.6
        removed = true
    end

    if not removed then
        player:AnimateSad()
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false
        }
    else
        CURCOL.SFX:Play(SoundEffect.SOUND_FIREDEATH_HISS)
        return true
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
CURCOL:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)

return item