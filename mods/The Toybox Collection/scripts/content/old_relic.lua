--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Old relic"),
    PICKUP_SFX = Isaac.GetSoundIdByName("TOYCOL_OLD_RELIC_PICKUP"),
    STEP_SFX = Isaac.GetSoundIdByName("TOYCOL_OLD_RELIC_STEP"),

    RADIUS = 120,
    DAMAGE_MULTIPLIER = 3,
    VELOCITY_MULTIPLIER = 15,
    TRIGGER_FRAMES = 120,
    
    KEY = "OLRE",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Old Relic", DESC = "While walking create stomps#Stomps fill gaps#Stomps damage enemies" },
        { LANG = "ru",    NAME = "Старая реликвия", DESC = "Во время ходьбы создаваёт топат#Топаты заполняют пробелы#Топат наносит урон врагам" },
        { LANG = "spa",   NAME = "Reliquia antigua", DESC = "Al caminar darás pisotones#Los pisotones llenarán huecos#Los pisotones dañarán enemigos" },
        { LANG = "zh_cn", NAME = "古老遗物", DESC = "角色移动时会产生冲击波#冲击波可以填平沟壑并对怪物造成3倍角色伤害#(出自 Undermine)" },
        { LANG = "ko_kr", NAME = "오래된 유물", DESC = "이동 중 일정 확률로 주변 적에게 공격력 x3의 피해를 주며 주변의 구덩이를 채웁니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "While walking the player creates a stomp periodically."},
            {str = "These stomps will fill gaps around the player."},
            {str = "They will also damage (3x the players damage) and push enemies."},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = 'This item is a reference to the game "Undermine".'},
            {str = "The item is referencing the " .. '"' .. "Wayland's" .. '"' ..  " Boots relic that can be found in the game."},
        }
    }
}

local cachedTriggers = {}

--TODO: add stomp sound

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function createBridge(grid)
    grid:ToPit():MakeBridge(nil)
    for i = 1, 3 do 
        local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, grid.Position, RandomVector() * ((math.random() * 2) + 1), nil)
        eff:SetColor(Color(0,0,0,0), 1, 99, false, false)
    end
end

function item:OnPlayerUpdate(player)
    if TCC_API:Has(item.KEY, player) > 0 then
        local room = TOYCG.GAME:GetRoom()

        local grid1 = room:GetGridEntityFromPos(player.Position+((player.Velocity*10):Rotated(-15)))
        local grid2 = room:GetGridEntityFromPos(player.Position+((player.Velocity*10):Rotated(15)))

        if grid1 and grid1.Desc.Type == GridEntityType.GRID_PIT and grid1.Desc.State == 0 then createBridge(grid1) end
        if grid2 and grid2.Desc.Type == GridEntityType.GRID_PIT and grid2.Desc.State == 0 then createBridge(grid2) end

        if room:GetAliveEnemiesCount() > 0 and TOYCG.GAME:GetFrameCount() % (item.TRIGGER_FRAMES - math.ceil((player.MoveSpeed / 2.5)*100)) == 0 and not (player.Velocity:Distance(Vector(0,0)) <= 0.5) then
            if not cachedTriggers[player.InitSeed] then
                cachedTriggers[player.InitSeed] = true

                -- Fill gaps
                for i = 1, room:GetGridSize() do
                    local entity = room:GetGridEntity(i)
                    
                    if entity then
                        if entity.Desc.Type == GridEntityType.GRID_PIT and entity.Desc.State == 0 and room:GetGridPosition(i):Distance(player.Position) < (item.RADIUS+20) then
                            createBridge(entity)
                        end
                    end
                end

                -- Push enemies
                local entities = Isaac.FindInRadius(player.Position, item.RADIUS, 8)

                for i=1, #entities do
                    local entity = entities[i]

                    if entity:CanShutDoors() then
                        entity:TakeDamage(player.Damage*item.DAMAGE_MULTIPLIER, DamageFlag.DAMAGE_CRUSH, EntityRef(player), 5)
                    end
                    
                    if entity.Type ~= EntityType.ENTITY_BOMBDROP and entity.Type ~= EntityType.ENTITY_TEAR then
                        entity:AddVelocity((entity.Position - player.Position):Normalized()*item.VELOCITY_MULTIPLIER)
                    end
                end

                TOYCG.GAME:ShakeScreen(3)

                -- BG
                local effect = TOYCG.GAME:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, player.Position, Vector(0,0), nil, 1, 0):GetSprite()
                effect.Scale = Vector(0.75, 0.75)
                effect:Update()

                -- FG
                effect = TOYCG.GAME:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, player.Position, Vector(0,0), nil, 2, 0):GetSprite()
                effect.Scale = Vector(0.75, 0.75)
                effect:Update()

                TOYCG.SFX:Play(item.STEP_SFX, 1)
            else
                cachedTriggers[player.InitSeed] = nil
            end
        end
    end
end

function item:OnGrab() TOYCG.SharedOnGrab(item.PICKUP_SFX) end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    TOYCG:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, item.OnPlayerUpdate)
end

function item:Disable()
    TOYCG:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, item.OnPlayerUpdate)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)
TCC_API:AddTCCCallback("TCC_ENTER_QUEUE", item.OnGrab, item.ID, false)

return item