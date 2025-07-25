local ____lualib = require("lualib_bundle")
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local CollectibleType = ____isaac_2Dtypescript_2Ddefinitions.CollectibleType
____exports.collectibleMultipliers = __TS__New(
    Map,
    {
        {
            CollectibleType.MEGA_MUSH,
            function(____, player) return player:GetEffects():HasCollectibleEffect(CollectibleType.MEGA_MUSH) and 4 or nil end
        },
        {
            CollectibleType.CRICKETS_HEAD,
            function() return 1.5 end
        },
        {
            CollectibleType.MAGIC_MUSHROOM,
            function(____, player)
                local ____player_HasCollectible_result_0
                if player:HasCollectible(CollectibleType.CRICKETS_HEAD) then
                    ____player_HasCollectible_result_0 = nil
                else
                    ____player_HasCollectible_result_0 = 1.5
                end
                return ____player_HasCollectible_result_0
            end
        },
        {
            CollectibleType.BLOOD_OF_THE_MARTYR,
            function(____, player)
                if player:HasCollectible(CollectibleType.CRICKETS_HEAD) or player:GetEffects():HasCollectibleEffect(CollectibleType.MAGIC_MUSHROOM) then
                    return
                end
                return player:GetEffects():HasCollectibleEffect(CollectibleType.BOOK_OF_BELIAL) and 1.5 or nil
            end
        },
        {
            CollectibleType.POLYPHEMUS,
            function() return 2 end
        },
        {
            CollectibleType.SACRED_HEART,
            function() return 2.3 end
        },
        {
            CollectibleType.EVES_MASCARA,
            function() return 2 end
        },
        {
            CollectibleType.ALMOND_MILK,
            function() return 0.33 end
        },
        {
            CollectibleType.SOY_MILK,
            function(____, player)
                local ____player_HasCollectible_result_1
                if player:HasCollectible(CollectibleType.ALMOND_MILK) then
                    ____player_HasCollectible_result_1 = nil
                else
                    ____player_HasCollectible_result_1 = 0.2
                end
                return ____player_HasCollectible_result_1
            end
        },
        {
            CollectibleType.CROWN_OF_LIGHT,
            function(____, player) return player:GetEffects():HasCollectibleEffect(CollectibleType.CROWN_OF_LIGHT) and 2 or nil end
        },
        {
            CollectibleType.IMMACULATE_HEART,
            function() return 1.2 end
        },
        {
            CollectibleType.ODD_MUSHROOM_THIN,
            function() return 0.9 end
        },
        {
            CollectibleType.TWENTY_TWENTY,
            function() return 0.8 end
        },
        {
            CollectibleType.BRIMSTONE,
            function(____, player)
                if player:HasCollectible(CollectibleType.HAEMOLACRIA) then
                    return nil
                end
                if player:GetCollectibleNum(CollectibleType.BRIMSTONE) == 1 then
                    return player:HasCollectible(CollectibleType.TECHNOLOGY) and 1.5 or nil
                end
                return player:HasCollectible(CollectibleType.TECHNOLOGY) and player:HasCollectible(CollectibleType.TECH_X) and 1.8 or 1.2
            end
        }
    }
)
return ____exports
