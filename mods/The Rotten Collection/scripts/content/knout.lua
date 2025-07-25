-- Thanks to the Crane Game mod for showing me how to give items to a player in a nice looking way
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2106770230

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local sfx = SFXManager()
local item = {
    ID = Isaac.GetItemIdByName("Knout"),
    EFFECT_VARIANT = Isaac.GetEntityVariantByName("Rot Collection Knout"),
    COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/rotcol_knout.anm2"),

    -- OWRP_ID = "rotcol01",
    -- OWRP_NAME = "The Scourge",
    -- OWRP_LOCK = false,
    KEY = "KN",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_ROTTEN_BEGGAR,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTION = "Chance to shoot a whip#This whip stuns enemies#This whip can pick up items",
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Knout", DESC = "Chance to shoot a whip#This whip stuns enemies#This whip can pick up items" },
        { LANG = "ru",    NAME = "Хлыст", DESC = "Дает шанс выстрелить хлыстом в направлении стрельбы#Может оглушать врагов#Может подбирать предметы" },
        { LANG = "spa",   NAME = "Knut",  DESC = "Posibilidad de lanzar un latigazo, provoca el daño de Isaac x3#Puede tomar recolectables#Puede confundir enemigos" },
        { LANG = "zh_cn", NAME = "笞刑",  DESC = "概率向眼泪发射方向甩出一条鞭子#攻击怪物，造成混乱并减速#鞭子可以将物品拽到角色身边" },
        { LANG = "ko_kr", NAME = "매질",  DESC = "눈물을 발사할 때 일정 확률로 채찍을 휘두릅니다.#{{Slow}} 채찍은 적을 영구적으로 혼란시키며 보스의 경우 일정 시간동안 둔화시킵니다.#채찍으로 픽업을 집을 수 있습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "While shooting or charging the player has a chance to shoot out a whip in the same direction"},
            {str = "This whip will permanently stun normal enemies"},
            {str = "This whip will also slow both normal enemies and bosses"},
            {str = "If the whip hits consumables, items or chests they will be dragged towards the player"}
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is inspired by "The Scourge"'},
            {str = 'The whip is a reskin of the whips shot by "Snappers"'},
            {str = 'Credit to the "Crane Game mod" which was used as an example for some of the code used for this item'},
            {str = 'Crane Game mod: steamcommunity.com/sharedfiles/ filedetails/?id=2106770230'}
        },
    }
}

local angles = {
    [0] = {["Dir"] = 180, ["Tag"] = "Left" },  -- LEFT
    [1] = {["Dir"] = 270, ["Tag"] = "Up"   },  -- UP
    [2] = {["Dir"] = 0,   ["Tag"] = "Right"},  -- RIGHT
    [3] = {["Dir"] = 90,  ["Tag"] = "Down" }   -- DOWN
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:InitKnout(player) -- Create a knout
    local angle = angles[player:GetHeadDirection()]

    if not angle then  -- BACKUP 1
        angle = angles[player:GetFireDirection()]
        if not angle then  -- BACKUP 2
            return false
        end
    end

    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, item.EFFECT_VARIANT, 0, player.Position, Vector(0,0), player):ToEffect()
    effect.DepthOffset = player:GetHeadDirection() == 1 and -1 or 10
    effect:FollowParent(player)

    local sprite = effect:GetSprite()
    sprite.Offset = Vector(0, -5)
    sprite:Play("Whip" .. angle.Tag, true)

    effect:Update()

    sfx:Play(SoundEffect.SOUND_WHIP, 0.6, 0, false, 1)

    return (player.Position + Vector(180, 0):Rotated(angle.Dir))
end

function item:OnPlayerUpdate(player) -- Handle the "spawning" of the knout on shot/charge
    if TCC_API:Has(item.KEY, player) > 0
    and Game():GetFrameCount() % 15 == 0
    and player:GetCollectibleRNG(item.ID):RandomInt(math.floor((15-(player.Luck >= 10 and 10 or (player.Luck > 0 and player.Luck or 0))))) <= 1
    and not player:IsHoldingItem()
    and (
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) or 
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) or 
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) or 
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) or
        Input.IsMouseBtnPressed(0)
    ) then
        local endpoint = item:InitKnout(player)

        if type(endpoint) == "boolean" then return end

        local hasConnected = false

        for _, ent in pairs(Isaac.FindInRadius(player.Position, 200, 24)) do
            if (endpoint:Distance(ent.Position) < 45 or ((endpoint + player.Position)/2):Distance(ent.Position) < 40) then
                if ent.Type == EntityType.ENTITY_PICKUP then
                    local pickup = ent:ToPickup()
                    if pickup and not pickup:IsShopItem() then
                        
                        if pickup.Variant == 100 then
                            if pickup.SubType > 0 then
                                pickup.TargetPosition = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
                            else
                                goto skippickup
                            end
                        else
                            pickup:PlayDropSound()
                        end
                        
                        pickup.Position = player.Position
                        
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil)
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, pickup.Position, Vector(0,0), nil)

                        pickup:Update()

                        hasConnected = true

                        ::skippickup::
                    end
                elseif ent:IsVulnerableEnemy() then
                    local enemy = ent:ToNPC()
                    enemy:TakeDamage(player.Damage*3, 0, EntityRef(player), 1)
    
                    if not enemy:IsBoss() or player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= 20 then
                        enemy:AddConfusion(EntityRef(player), 99, false)
                    end
    
                    hasConnected = true
                end
            end
        end

        if hasConnected then sfx:Play(SoundEffect.SOUND_WHIP_HIT, 0.6, 0, false, 1) end
    end
end

function item:OnUpdate(effect, offset) -- Handle the position and despawning of the knout
    if effect:GetSprite():IsEventTriggered("Finished") then effect:Remove() end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    ROTCG:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER,  item.OnUpdate, item.EFFECT_VARIANT)
    ROTCG:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,  item.OnPlayerUpdate)
end

function item:Disable()
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_EFFECT_RENDER,  item.OnUpdate, item.EFFECT_VARIANT)
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,  item.OnPlayerUpdate)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item