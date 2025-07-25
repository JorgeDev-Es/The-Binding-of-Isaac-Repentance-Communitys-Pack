--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local game = Game()
local item = {
	ID = Isaac.GetItemIdByName("Necrosis"),
    VARIANT = Isaac.GetEntityVariantByName("Rot Collection Necrosis"),

    KEY = "NE",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_ROTTEN_BEGGAR,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Necrosis",  DESC = "{{EmptyHeart}} +2 Heart Containers#{{RottenHeart}} +2 Rotten hearts#{{ArrowDown}} +1 Broken heart#Chance to fire clumps#Clumps leave farts on impact#Clumps kill normal enemies instantly" },
        { LANG = "ru",    NAME = "Некроз",    DESC = "{{EmptyHeart}} +2 красных сердец#{{RottenHeart}} +2 гнилых сердец#{{ArrowDown}} +1 костяное сердце#Шанс выстрелить сгустками#Сгустки оставляют пуки при попадании#Сгустки мгновенно убивают обычных врагов" },
        { LANG = "spa",   NAME = "Necrosis",  DESC = "{{EmptyHeart}} +2 contenedores de corazón#{{RottenHeart}} +2 corazones podridos#{{BrokenHeart}} +1 corazón roto#Posibilidad de lanzar un cúmulo, este suelta pedos al impactar y mata a los enemigos regulares al instante" },
        { LANG = "zh_cn", NAME = "坏疽",      DESC = "{{EmptyHeart}} +2 心之容器#{{RottenHeart}} +2 腐心#{{ArrowDown}} +1 碎心#角色攻击时有概率射出一个团块#团块会秒杀碰到的怪物并留下一团毒屁" },
        { LANG = "ko_kr", NAME = "회저",      DESC = "{{EmptyHeart}} 빈 최대 체력 +2#{{RottenHeart}} 썩은하트 +2#{{ArrowDown}} 소지 불가능 체력 +1#3.33%의 확률로 적을 즉사시키며 독방귀를 뀌는 눈물이 나갑니다.#!!! {{Luck}}행운 수치 비례: 행운 20 이상일 때 20% 확률" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Isaac has a. chance to shoot a clump instead of a tear"},
            {str = "These clumps will instantly kill normal enemies and leave a fart on impact"},
            {str = "+2 Heart containers filled with rotten hearts"},
            {str = "+1 Broken heart"},
        },
        { -- Synergies
            {str = "Synergies", fsize = 2, clr = 3, halign = 0},
            {str = "While holding mom's knife fired knifes can leave a fart on impact."},
            {str = 'While holding contagion the item will apply the contagion effect to enemies.'}
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = [[The texture of this item was based on the "Child's Heart" trinket]]},
            {str = "Necrosis in real life is the premature death of living tissue"},
            {str = "Necrosis is named after the ancient greek word for death"},
        },
        { -- Credits
            {str = "Credits", fsize = 2, clr = 3, halign = 0},
            {str = 'Credit to the "Strawpack 2 mod" which was used as an example for some of the code used for this item'},
            {str = 'Strawpack 2 mod: steamcommunity.com/sharedfiles/ filedetails/?id=1163138153'}
        }
    }
}

local types = {
    [EntityType.ENTITY_TEAR] = "tear",
    [EntityType.ENTITY_LASER] = "laser",
    [EntityType.ENTITY_KNIFE] = "knife"
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function GetPlayer(entity)
    if entity and entity.SpawnerType == EntityType.ENTITY_PLAYER and entity.SpawnerEntity then 
        return entity.SpawnerEntity:ToPlayer()
    else
        return nil
    end
end

function item:OnShot(shot)
    local player = GetPlayer(shot)

    -- Roll between luck stat and 25. If luck stat is above 20 rol between 20 and 25
    if player and TCC_API:Has(item.KEY, player) > 0 and math.random(player.Luck >= 20 and 20 or math.ceil(player.Luck), 25) > 24 then
        local type = types[shot.Type]

        if type then
            -- shot:SetColor(Color(0.278, 0.286, 0.243, 1, 0, 0, 0), 0, 1, false, false)
            shot.CollisionDamage = shot.CollisionDamage*1.75
            shot:GetData()["rotcol_necrosis"] = true

            if type == 'tear' then
                shot = shot:ToTear()
                shot:ChangeVariant(item.VARIANT)
            end

            shot:Update()
        end
    end
end

function item:OnUpdate(entity)
    if entity.SpawnerType == EntityType.ENTITY_PLAYER then
        entity = entity:ToTear()
        local data = entity:GetData()

        if entity:CollidesWithGrid() or entity.Height >= -5 then
            local small = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 0, entity.Position, Vector(0, 0), nil):ToEffect()
            small:SetColor(Color(0.114, 0.118, 0.098, 1, 0, 0, 0), 0, 1, false, false)
            for i = 1, 3 do
                local large = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, entity.Position, RandomVector() * ((math.random() * 2) + 1), nil):ToEffect()
                large:SetColor(Color(0.278, 0.286, 0.243, 1, 0, 0, 0), 0, 1, false, false)
            end

            entity:Remove()
        end
    end
end

function item:OnHit(entity, _, _, source, _) -- On hit for special necrosis tears
    local player = GetPlayer(source.Entity)

    if player 
    and TCC_API:Has(item.KEY, player) > 0
    and entity:IsVulnerableEnemy() then
        local type = types[source.Type]

        if type then
            if type == "tear" and source.Entity and source.Entity:GetData()["rotcol_necrosis"] then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTAGION) then
                    entity:AddEntityFlags(EntityFlag.FLAG_CONTAGIOUS)
                    -- Conditional fart because killing an enemy with the contagion flag already creates one
                    if not entity:IsBoss() then entity:Kill() else -- Insta kill like euthanasia
                        game:Fart(entity.Position, 101.25, player, 1.25, 1, source.Color)
                    end
                else
                    game:Fart(entity.Position, 101.25, player, 1.25, 0, source.Color)
                    if not entity:IsBoss() then entity:Kill() end -- Insta kill like euthanasia
                end
            elseif type == "laser" or type == "knife" then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTAGION) then
                    entity:AddEntityFlags(EntityFlag.FLAG_CONTAGIOUS)
                end

                if entity:IsBoss() then
                    if Game():GetFrameCount() % 4 == 0 then
                        game:Fart(source.Position, 101.25, player, 1.25, 0, source.Color)
                    end
                elseif not entity:HasEntityFlags(EntityFlag.FLAG_POISON) then
                    game:Fart(source.Position, 101.25, player, 1.25, 0, source.Color)
                end
            end
        end
    end
end

function item:OnCollect(player, _, touched) -- Apply stats on pickup if they haven't been granted
    if not touched then
        player:AddMaxHearts(4)
        player:AddBrokenHearts(1)
        player:AddRottenHearts(4)
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    ROTCG:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE,   item.OnUpdate, item.VARIANT)
    ROTCG:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,     item.OnShot                )
    ROTCG:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,    item.OnHit                 )
end

function item:Disable()
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_TEAR_UPDATE,   item.OnUpdate, item.VARIANT)
    ROTCG:RemoveCallback(ModCallbacks.MC_POST_FIRE_TEAR,     item.OnShot                )
    ROTCG:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,    item.OnHit                 )
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCollect, item.ID, false)

return item