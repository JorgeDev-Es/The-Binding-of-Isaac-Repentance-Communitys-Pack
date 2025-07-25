local ____lualib = require("lualib_bundle")
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local CollectibleType = ____isaac_2Dtypescript_2Ddefinitions.CollectibleType
local PlayerType = ____isaac_2Dtypescript_2Ddefinitions.PlayerType
____exports.characterMultipliers = __TS__New(
    Map,
    {
        {
            PlayerType.CAIN,
            function() return 1.2 end
        },
        {
            PlayerType.JUDAS,
            function() return 1.35 end
        },
        {
            PlayerType.BLUE_BABY,
            function() return 1.05 end
        },
        {
            PlayerType.EVE,
            function(____, player)
                local ____player_GetEffects_result_HasCollectibleEffect_result_0
                if player:GetEffects():HasCollectibleEffect(CollectibleType.WHORE_OF_BABYLON) then
                    ____player_GetEffects_result_HasCollectibleEffect_result_0 = nil
                else
                    ____player_GetEffects_result_HasCollectibleEffect_result_0 = 0.75
                end
                return ____player_GetEffects_result_HasCollectibleEffect_result_0
            end
        },
        {
            PlayerType.AZAZEL,
            function() return 1.5 end
        },
        {
            PlayerType.LAZARUS_2,
            function() return 1.4 end
        },
        {
            PlayerType.DARK_JUDAS,
            function() return 2 end
        },
        {
            PlayerType.KEEPER,
            function() return 1.2 end
        },
        {
            PlayerType.FORGOTTEN,
            function() return 1.5 end
        },
        {
            PlayerType.MAGDALENE_B,
            function() return 0.75 end
        },
        {
            PlayerType.EVE_B,
            function() return 1.2 end
        },
        {
            PlayerType.AZAZEL_B,
            function() return 1.5 end
        },
        {
            PlayerType.LOST_B,
            function() return 1.3 end
        },
        {
            PlayerType.FORGOTTEN_B,
            function() return 1.5 end
        },
        {
            PlayerType.LAZARUS_2_B,
            function() return 1.5 end
        },
        {
            PlayerType.CAIN_B,
            function() return 1.2 end
        }
    }
)
return ____exports
