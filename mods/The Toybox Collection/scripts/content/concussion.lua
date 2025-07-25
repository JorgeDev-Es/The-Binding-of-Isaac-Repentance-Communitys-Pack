--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Concussion"),
    
    PICKUP_SFX = Isaac.GetSoundIdByName("TOYCOL_CONCUSSION_PICKUP"),
    HIT_SFX = Isaac.GetSoundIdByName("TOYCOL_CONCUSSION_HIT"),
    SWIPE_SFX = SoundEffect.SOUND_SWORD_SPIN,

    SWIPE_GFX = Isaac.GetEntityVariantByName("TOYCOL_CONCUSSION_SWIPE"),
    HIT_STAR_GFX = Isaac.GetEntityVariantByName("TOYCOL_CONCUSSION_HIT_STAR"),
    HIT_LINE_GFX = Isaac.GetEntityVariantByName("TOYCOL_CONCUSSION_HIT_LINE"),

    RADIUS = 100,
    BOSS_CHANCE = 30,
    DAMAGE_MULTIPLIER = 2.5,

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_DEVIL,
        ItemPoolType.POOL_RED_CHEST,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_DEVIL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Concussion", DESC = "Pushes, confuses and damages enemies#Enters your pocket upon pickup if possible" },
        { LANG = "ru",    NAME = "Сотрясение", DESC = "Отталкивает, ошеломляет и наносит урон врагам#Помещается в карман при получении, если это возможно" },
        { LANG = "spa",   NAME = "Conmoción Cerebral", DESC = "Empuja, confunde y daña enemigos#Entrará en tu objeto de bolsillo y es posible" },
        { LANG = "zh_cn", NAME = "震荡", DESC = "如果可以，将优先放置在角色的次要主动栏#使用时击退并混乱角色周围的怪物，造成2.5倍角色伤害#(出自 灾厄逆刃)" },
        { LANG = "ko_kr", NAME = "진동 스매시", DESC = "캐릭터 주변의 적에게 공격력 x2.5의 피해를 주며 혼란시킵니다.#캐릭터 주변의 탄환을 반사시킵니다.#!!! 가능한 경우 이 아이템은 픽업 슬롯에 배치됩니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Upon use pushes, confuses and damages (2.5x the players damage) enemies that are closeby."},
            {str = "If the player has an empty pocket then the item will enter their pocket instead of their active slot."},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "ScourgeBringer".'},
            {str = 'The item is referencing the "Concussion" skill that can be unlocked in the game.'},
        }
    }
}

local swipeDirections = {
    [Direction.NO_DIRECTION] = 270,
    [Direction.LEFT] = 0,
    [Direction.UP] = 90,
    [Direction.RIGHT] = 180,
    [Direction.DOWN] = 270,
}

local frostColor = Color(1,1,1,1)
frostColor:SetColorize(1,1.4,2,1)

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function renderSwipe(ent, source, isFrozen)
    local starGfx = TOYCG.GAME:Spawn(EntityType.ENTITY_EFFECT, item.HIT_STAR_GFX, ent.Position, Vector(0,0), nil, 1, 0):ToEffect()
    starGfx:GetSprite().Rotation = math.random(360)
    starGfx.DepthOffset = ent.DepthOffset + 100
    starGfx:Update()

    local lineGfx = TOYCG.GAME:Spawn(EntityType.ENTITY_EFFECT, item.HIT_LINE_GFX, ent.Position, Vector(0,0), nil, 1, 0):ToEffect()
    lineGfx:GetSprite().Rotation = (source.Position - ent.Position):GetAngleDegrees()
    lineGfx.DepthOffset = starGfx.DepthOffset + 100
    lineGfx:Update()

    if isFrozen then
        ent:SetColor(Color(1, 1, 1, 1, 0.40, 0.10, 0.99), 15, 99, true, false)
        starGfx:SetColor(frostColor, -1, 99, false, true)
        lineGfx:SetColor(frostColor, -1, 99, false, true)
    else
        ent:SetColor(Color(1, 1, 1, 1, 0.99, 0.10, 0.40), 15, 99, true, false)
    end
end

local function containsCubeBaby(ents)
    for i=1, #ents do
        if ents[i].Type == EntityType.ENTITY_FAMILIAR and ents[i].Variant == FamiliarVariant.CUBE_BABY then
            return true
        end
    end

    return false
end

function item:OnUse(_, RNG, player, _, _, _)
    local entities = Isaac.FindInRadius(player.Position, item.RADIUS, 26)
    local hasHit = false
    local isFrozen = containsCubeBaby(entities)

    for i=1, #entities do
        local ent = entities[i]

        if ent.Type == EntityType.ENTITY_PROJECTILE then
            ent:Remove()
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, ent.Position, ent.Velocity:Rotated(180), player):ToTear()
            if isFrozen then
                tear:AddTearFlags(TearFlags.TEAR_ICE)
                tear:ChangeVariant(TearVariant.ICE)
            end
        elseif (ent.Type == EntityType.ENTITY_PICKUP or ent.Type == EntityType.ENTITY_BOMBDROP) then
            ent:AddVelocity((ent.Position - player.Position):Normalized()*10)
        elseif (ent.Type == EntityType.ENTITY_FAMILIAR and ent.Variant == FamiliarVariant.CUBE_BABY) then
            ent:AddVelocity((ent.Position - player.Position):Normalized()*35)
            renderSwipe(ent, player, isFrozen)

            hasHit = true
        elseif ent.Type ~= EntityType.ENTITY_PLAYER and ent:CanShutDoors() then
            ent:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK | EntityFlag.FLAG_APPLY_IMPACT_DAMAGE | EntityFlag.FLAG_AMBUSH |((isFrozen and (ent.HitPoints - player.Damage*item.DAMAGE_MULTIPLIER <= 0)) and EntityFlag.FLAG_ICE or 0))
            ent:AddVelocity((ent.Position - player.Position):Normalized()*45)
            ent:TakeDamage(player.Damage*item.DAMAGE_MULTIPLIER, (DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_CRUSH), EntityRef(player), 0)
        
            if not ent:IsBoss() or RNG:RandomInt(100)+1 <= item.BOSS_CHANCE then
                ent:AddConfusion(EntityRef(player), 90, true)
            end

            renderSwipe(ent, player, isFrozen)

            hasHit = true
        end
    end

    local swipe = TOYCG.GAME:Spawn(EntityType.ENTITY_EFFECT, item.SWIPE_GFX, player.Position + Vector(0, -20), Vector(0,0), nil, 1, 0):ToEffect()
    swipe.DepthOffset = player.DepthOffset + 100
    swipe:GetSprite().Rotation = swipeDirections[player:GetHeadDirection()]
    swipe:FollowParent(player)

    if isFrozen then
        swipe:SetColor(frostColor, -1, 99, false, true)
    end

    swipe:Update()

    TOYCG.SFX:Play(item.SWIPE_SFX, 1, 0)

    if hasHit then
        TOYCG.GAME:ShakeScreen(16)
        TOYCG.SFX:Play(item.HIT_SFX, 1)
    end
end

function item:OnGrab() TOYCG.SharedOnGrab(item.PICKUP_SFX) end

function item:OnCollect(player)
    if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == 0 then
        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == item.ID or player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == item.ID then
            player:RemoveCollectible(item.ID)
            player:SetPocketActiveItem(item.ID, ActiveSlot.SLOT_POCKET, false)
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
TOYCG:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)

TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab,    item.ID, false)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect, item.ID, false)

return item