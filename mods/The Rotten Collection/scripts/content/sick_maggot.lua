--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local trinket = { 
    ID = Isaac.GetTrinketIdByName("Sick maggot"),
    KEY = "SIMA",
    TYPE = 350,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Sick Maggot",     DESC = "{{HalfHeart}} Rotten hearts turn into half red hearts when lost#{{RottenHeart}} Red hearts turn into rotten hearts while at full health" },
        { LANG = "ru",    NAME = "Больная личинка", DESC = "{{HalfHeart}} Гнилые сердца превращаются в половину красных сердец, когда теряются#{{RottenHeart}} Красные сердца превращаются в гнилые сердца при полном здоровье" },
        { LANG = "spa",   NAME = "Gusano enfermo",  DESC = "{{HalfHeart}} Los corazones podridos se convierten en medios corazones al 'perderlos'#{{Heart}}Los corazones rojos se convertirán en corazones podridos si tu salud está completa" },
        { LANG = "zh_cn", NAME = "病蛆",            DESC = "{{HalfHeart}} 失去腐心时会生成半颗红心#{{RottenHeart}} 满血时拾取红心会变成腐心" },
        { LANG = "ko_kr", NAME = "아픈 구더기",      DESC = "{{HalfHeart}} 썩은하트를 잃을 경우 빨간하트 반칸을 회복합니다.#{{RottenHeart}} 체력이 꽉 찬 상태에서 빨간하트와 접촉 시 썩은하트가 채워집니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When losing a rotten heart the heart gets replaced by red heart(s)"},
            {str = "The amount of red health changes based on the trinket multiplier"},
            {str = "Default: Half a heart, Gold/Mom's Box: a full heart, Both: 1,5 hearts, etc..."},
            {str = "When at full health red hearts picked up will be transformed into rotten hearts if the player can hold them"},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local rottenHearts = {}

function trinket:OnLoad(_) rottenHearts = {} end

function trinket:HandleHealth(player) -- Grant red health when a rotten heart is lost
    local identifier = player.ControllerIndex..","..player:GetPlayerType()
    if rottenHearts[identifier] == nil or rottenHearts[identifier] < player:GetRottenHearts() then
        rottenHearts[identifier] = player:GetRottenHearts()
    elseif rottenHearts[identifier] > player:GetRottenHearts() then
        local diff = rottenHearts[identifier] - player:GetRottenHearts()
        
        player:AddHearts(TCC_API:Has(trinket.KEY, player))
        player:AddRottenHearts(diff-1)
        
        if player:IsDead() then
            player:Revive()
            player:GetSprite():Play("Hit")
        end

        -- player:AddBlueFlies(5, player.Position, nil) -- Possible extra feature
        rottenHearts[identifier] = player:GetRottenHearts()
    end
end

function trinket:HandleHeal(pickup, collider, low) -- Give the player rotten health when colliding with red hearts when possible
    if collider.Type == EntityType.ENTITY_PLAYER
    and (pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF or pickup.SubType == HeartSubType.HEART_DOUBLEPACK)
    and not pickup:ToPickup():IsShopItem()
    and not collider:ToPlayer():CanPickRedHearts()
    and collider:ToPlayer():CanPickRottenHearts() 
    then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LEECH_EXPLOSION, 0, pickup.Position, RandomVector() * ((math.random() * 2) + 1), nil)
        for i = 1, 4 do   
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, pickup.Position, RandomVector() * ((math.random() * 2) + 1), nil)
        end
    
        SFXManager():Play(SoundEffect.SOUND_ROTTEN_HEART, 1, 0, false, 1)
        collider:ToPlayer():AddRottenHearts((pickup.SubType == HeartSubType.HEART_DOUBLEPACK and 4 or 2))
        pickup:Remove()

        return true
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function trinket:Enable()
    ROTCG:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,   trinket.HandleHealth                            )
    ROTCG:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,    trinket.OnLoad                                  )
    ROTCG:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, trinket.HandleHeal,   PickupVariant.PICKUP_HEART)
end

function trinket:Disable()
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,   trinket.HandleHealth                            )
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,    trinket.OnLoad                                  )
    ROTCG:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, trinket.HandleHeal,   PickupVariant.PICKUP_HEART)
end

TCC_API:AddTCCInvManager(trinket.ID, trinket.TYPE, trinket.KEY, trinket.Enable, trinket.Disable)

return trinket