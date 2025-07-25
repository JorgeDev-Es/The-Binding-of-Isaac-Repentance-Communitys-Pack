local ReverseDeath = {}

local utility = JosephMod.utility
local enums = JosephMod.enums


local BONE_SPAWN_CHANCE = 0.4
local BONE_ORBITAL_CHANCE = 0.3
local BONEY_CHANCE = 0.1

local BONY = {227, 0}
local BIG_BONY = {830, 0}
local HOLY_BONY = {227, 1}
local BLACK_BONY = {277, 0}
local REVENANT = {841, 0}
local QUAD_REVENANT = {841, 1}
local NECRO = {828, 0} --Little floating psychic guys
local CLICKETY_CLACK = {889, 0}
local BONE_FLY = {25, 4}
local CARRION_PRINCESS = {23, 3}
local MOMS_DEAD_HAND = {287, 0}
local KINETI = {816, 1}
local PASTY = {881, 1} --Bone needle




local enemyBoneVariants = {
    [10] = { --Gapers
        [0] = BONY,
        [1] = BONY,
        [2] = BONY,
        [3] = BONY,
    },
    [87] = { --Gurle, Crackle
        [0] = BONY,
        [1] = CLICKETY_CLACK
    },
    [252] = { --Nulls
        [0] = BLACK_BONY
    },
    [284] = { --Cyclopia
        [0] = BONY
    },
    [297] = { --Blue Gaper
        [0] = BONY
    },
    [299] = { --Greed Gaper
        [0] = BONY
    },
    [807] = { --Wraith
        [0] = BONY
    },
    [811] = { --Deep Gaper
        [0] = BONY
    },
    [813] = { --Blurb
        [0] = BONY
    },
    [850] = { --Level 2 Gaper, Level 2 Horf
        [0] = BONY,
        [1] = NECRO
    },
    [912] = { --Dead Isaac
        [20] = BONY
    },
    [832] = { --Exorcist, Fanatic
        [0] = NECRO,
        [1] = NECRO
    },
    [248] = { --Psychic Horf
        [0] = NECRO
    },
    [828] = { --Necro
        [0] = NECRO
    },
    [820] = { --Danny, Coal Boy
        [0] = BLACK_BONY,
        [1] = BLACK_BONY
    },
    [21] = { --Maggot
        [0] = CARRION_PRINCESS
    },
    [23] = { --Charger, Drowned, Dank, Carrior Princess
        [0] = CARRION_PRINCESS,
        [1] = CARRION_PRINCESS,
        [2] = CARRION_PRINCESS,
        [3] = CARRION_PRINCESS,
    },
    -- [889] = { --Clickey Clack
    --     [0] = CLICKETY_CLACK
    -- },
    [25] = { --Boom Fly
        [0] = BONE_FLY,
        [1] = BONE_FLY,
        [2] = BONE_FLY,
        [3] = BONE_FLY,
        [4] = BONE_FLY,
        [5] = BONE_FLY,
        [6] = BONE_FLY,
    },
    [26] = { --Psychic Maw
        [2] = NECRO
    },
    [834] = { --Whipper, Snapper, Flagellant
        [0] = REVENANT,
        [1] = REVENANT,
        [2] = QUAD_REVENANT,
    },
    [53] = { --Evil Twin
        [1] = QUAD_REVENANT
    },
    [90] = { --Hanger
        [0] = BONY
    },
    [208] = { --Fatty, pale, flaming
        [0] = BIG_BONY,
        [1] = BIG_BONY,
        [2] = BIG_BONY,
    },
    [209] = { --Fat Sack
        [0] = BIG_BONY
    },
    [257] = { --Conjoined, Blue conjoined fatty
        [0] = BIG_BONY,
        [1] = BIG_BONY,
        
    },
    [806] = { --Bubbles
        [0] = BIG_BONY
    },
    [823] = { --Quakey
        [0] = BIG_BONY
    },
    [830] = { --Big Bony
        [0] = BIG_BONY
    },
    [831] = { --Gutted Fatty
        [0] = BIG_BONY
    },
    [835] = { --Peeping Fatty
        [0] = BIG_BONY
    },
    [879] = { --Bloaty
        [0] = BIG_BONY
    },
    [886] = { --Vis Fatty
        [0] = BIG_BONY
    },
    [888] = { --Shady
        [0] = BIG_BONY
    },
    [213] = { --Mom's Hand
        [0] = MOMS_DEAD_HAND
    },
    [226] = { --Skinny, Rotty, Crispy
        [0] = BONY,
        [1] = BONY,
        [2] = BONY
    },
    [227] = { --Bony... Holy bony
        [0] = BONY,
        [1] = HOLY_BONY
    },
    [277] = { --Black Bony
        [0] = BLACK_BONY
    },
    [841] = { --Revenant, quad
        [0] = REVENANT,
        [1] = QUAD_REVENANT
    },
    [890] = { --Maze Roamer
        [0] = BONY
    },
    [228] = { --Homunculus
        [0] = BONY
    },
    [251] = { --Begotten
        [0] = REVENANT
    },
    [885] = { --Cultist, blood cultiust
        [0] = REVENANT,
        [1] = REVENANT
    },
    [816] = { --Polty
        [0] = KINETI,
        [1] = KINETI,
    },
    [881] = { --Needle, Pasty
        [0] = PASTY,
        [1] = PASTY
    },
}
---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseDeath:initReverseDeath(player, card)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseDeath.initReverseDeath, Card.CARD_REVERSE_DEATH)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseDeath:removeReverseDeath(player, card, slot)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseDeath.removeReverseDeath, Card.CARD_REVERSE_DEATH)


function ReverseDeath:onEntityDie(entity, amount, flags, source)

    if not (entity:IsEnemy() and entity:HasMortalDamage() and entity:IsActiveEnemy() and source.Entity) then return end

    local player = TSIL.Players.GetPlayerFromEntity(source.Entity)
    if not (player and utility:HasEnchantment(player, Card.CARD_REVERSE_DEATH)) then return end

    local rng = player:GetCardRNG(Card.CARD_REVERSE_DEATH)
    if rng:RandomFloat() > BONE_SPAWN_CHANCE then return end

    local boneEnemy

    local randomChance = rng:RandomFloat()

    if enemyBoneVariants[entity.Type] and enemyBoneVariants[entity.Type][entity.Variant] then
        boneEnemy = Isaac.Spawn(enemyBoneVariants[entity.Type][entity.Variant][1], enemyBoneVariants[entity.Type][entity.Variant][2], 0, entity.Position, Vector.Zero, entity)
        boneEnemy:AddCharmed(EntityRef(player), -1)
        if boneEnemy.Type == 830 and boneEnemy.Variant == 0 then
            boneEnemy.HitPoints = boneEnemy.HitPoints/2 --Nerf big bonys lol
        end
        SFXManager():Play(316)
        local poof = Isaac.Spawn(1000, 15, 0, boneEnemy.Position, Vector.Zero, nil)

    else
        if randomChance < BONE_ORBITAL_CHANCE then
            boneEnemy = Isaac.Spawn(3, FamiliarVariant.BONE_ORBITAL, 0, entity.Position, Vector.Zero, player)
            SFXManager():Play(SoundEffect.SOUND_BONE_SNAP)

        elseif randomChance < BONEY_CHANCE + BONE_ORBITAL_CHANCE 
            and entity.MaxHitPoints >= 8 + Game():GetLevel():GetStage()*2 then
            boneEnemy = Isaac.Spawn(227, 0, 0, entity.Position, Vector.Zero, entity)
            SFXManager():Play(316)

        else
            boneEnemy = Isaac.Spawn(3, FamiliarVariant.BONE_SPUR, 0, entity.Position, RandomVector()*5, player)
            SFXManager():Play(SoundEffect.SOUND_BONE_SNAP)

        end
    end
    if boneEnemy then
        utility:GetData(boneEnemy, "Invincible").isInvincible = true
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ReverseDeath.onEntityDie)


local function preventHit(_, entity)
    local data = utility:GetData(entity, "Invincible")
    if not (data.isInvincible == true) then return end
    if entity.FrameCount < 30 then return false
    else
        data.isInvincible = false
    end
    
end
JosephMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, preventHit)


-- JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_LEVEL_REORDERED, function ()
--     if gameContinued then 
--         gameContinued = false
--         return
--     end
--     JosephMod.Schedule(1, function ()
--         JosephMod.BaseCardEffects:ReapplyCardEffects()
--     end,{})
-- end)