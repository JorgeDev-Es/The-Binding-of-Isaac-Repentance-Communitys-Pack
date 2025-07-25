--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Shining clicker"),
 
    OPTIONS = {
        [PlayerType.PLAYER_ISAAC] = { ["Red"] = 6 },
        [PlayerType.PLAYER_MAGDALENA] = { ["Red"] = 8 },
        [PlayerType.PLAYER_CAIN] = { ["Red"] = 4 },
        [PlayerType.PLAYER_JUDAS] = { ["Red"] = 2 },
        [PlayerType.PLAYER_BLUEBABY] = { ["Soul"] = 6 },
        [PlayerType.PLAYER_EVE] = { ["Red"] = 4 },
        [PlayerType.PLAYER_SAMSON] = { ["Red"] = 6 },
        [PlayerType.PLAYER_AZAZEL] = { ["Black"] = 6 },
        [PlayerType.PLAYER_LAZARUS] = { ["Red"] = 6 },
        [PlayerType.PLAYER_EDEN] = { ["Red"] = 6 },
        [PlayerType.PLAYER_THELOST] = {},
        [PlayerType.PLAYER_LAZARUS2] = { ["Red"] = 2 },
        [PlayerType.PLAYER_BLACKJUDAS] = { ["Black"] = 4 },
        [PlayerType.PLAYER_LILITH] = { ["Red"] = 2, ["Black"] = 4 },
        [PlayerType.PLAYER_KEEPER] = { ["Red"] = 6 },
        [PlayerType.PLAYER_APOLLYON] = { ["Red"] = 4 },
        [PlayerType.PLAYER_THEFORGOTTEN] = { ["Bone"] = 2, ["Soul"] = 2  },
        [PlayerType.PLAYER_THESOUL] = { ["Bone"] = 2  },
        [PlayerType.PLAYER_BETHANY] = { ["Red"] = 6 },
        [PlayerType.PLAYER_JACOB] = { ["Red"] = 6, ["Twin"] = { ["Red"] = 2, ["Soul"] = 2 } },
        [PlayerType.PLAYER_ESAU] = { ["Red"] = 2, ["Soul"] = 2, ["Twin"] = { ["Red"] = 6 } },

        [PlayerType.PLAYER_ISAAC_B] = { ["Red"] = 6 },
        [PlayerType.PLAYER_MAGDALENE_B] = { ["Red"] = 8 },
        [PlayerType.PLAYER_CAIN_B] = { ["Red"] = 4 },
        [PlayerType.PLAYER_JUDAS_B] = { ["Black"] = 4 },
        [PlayerType.PLAYER_BLUEBABY_B] = { ["Blue"] = 6 },
        [PlayerType.PLAYER_EVE_B] = { ["Blue"] = 4 },	
        [PlayerType.PLAYER_SAMSON_B] = { ["Red"] = 6 },
        [PlayerType.PLAYER_AZAZEL_B] = { ["Black"] = 6 },
        [PlayerType.PLAYER_LAZARUS_B] = { ["Red"] = 6 },
        [PlayerType.PLAYER_EDEN_B] = { ["Random"] = true },
        [PlayerType.PLAYER_THELOST_B] = {},
        [PlayerType.PLAYER_LILITH_B] = { ["Red"] = 2, ["Black"] = 4 },
        [PlayerType.PLAYER_KEEPER_B] = { ["Red"] = 4 },
        [PlayerType.PLAYER_APOLLYON_B] = { ["Red"] = 4 },
        [PlayerType.PLAYER_THEFORGOTTEN_B] = { ["Soul"] = 6 },
        [PlayerType.PLAYER_BETHANY_B] = { ["Soul"] = 6 },	
        [PlayerType.PLAYER_JACOB_B] = { ["Red"] = 6 },
        [PlayerType.PLAYER_LAZARUS2_B] = { ["Soul"] = 4 },
        [PlayerType.PLAYER_JACOB2_B] = {},
        [PlayerType.PLAYER_THESOUL_B] = { ["Soul"] = 6 },
    },

    KEY="SHCL",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SECRET,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Shining Clicker", DESC = "Respawn as a random character on death" },
        { LANG = "ru",    NAME = "Сияющий кликер", DESC = "Возрождение случайным персонажем после смерти" },
        { LANG = "spa",   NAME = "Control remoto brillante", DESC = "Reapareces como un personaje aleatorio al morir" },
        { LANG = "zh_cn", NAME = "闪亮的遥控器", DESC = "角色死亡时在当前房间随机重生为其他人物#重生时获得对应人物的初始生命值" },
        { LANG = "ko_kr", NAME = "빛나는 클리커", DESC = "사망 시 현재 방에서 랜덤 캐릭터로 부활합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Respawns the player as a different character while staying in the same room upon death."},
            {str = "When revived the player will have the same health as when spawning as the selected character."},
            {str = 'Tained characters will turn into other tainted characters just like "The clicker"'}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function setPlayerHealth(player, selection)
    player:AddMaxHearts(-player:GetMaxHearts()) -- Remove all health first
    player:AddBoneHearts(-player:GetBoneHearts())
    player:AddSoulHearts(-player:GetSoulHearts())
    player:AddBlackHearts(-player:GetSoulHearts())

    -- Apply new health
    player:AddMaxHearts(selection.Red or 0)
    player:AddSoulHearts(selection.Soul or 0)
    player:AddBlackHearts(selection.Black or 0)
    player:AddBoneHearts(selection.Bone or 0)
    player:SetFullHearts()
end

local function isPlayerDying(player)
    -- and by 'dying' I (unfortunately) mean 'playing death animation'    
    local sprite = player:GetSprite()
    return (sprite:IsPlaying("Death") and sprite:GetFrame() > 50) or (sprite:IsPlaying("LostDeath") and sprite:GetFrame() > 30)
end

function item:handleRevive(player) --Callback function
    if player:GetExtraLives() == 0 and isPlayerDying(player) and TCC_API:Has(item.KEY, player) > 0 then --If the player is dead and no extra lives
        local rng = player:GetCollectibleRNG(item.ID)
        local selection = item.OPTIONS[1]
        player = player:GetMainTwin()

        player:Revive()
        if player:GetOtherTwin() then
            player:GetOtherTwin():Revive() 
        end

        player:UseActiveItem(CollectibleType.COLLECTIBLE_CLICKER, false, true, false, false)

        if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
            player:ChangePlayerType(PlayerType.PLAYER_THELOST_B)
        end

        selection = item.OPTIONS[player:GetPlayerType()] or item.OPTIONS[PlayerType.PLAYER_ISAAC]

        setPlayerHealth(player, selection)

        -- If random apply random share of red and soul (tainted eden)
        if selection.Random then
            local max = rng:RandomInt(4)

            max = ((max < 2) and 2 or max)

            local red = rng:RandomInt((2+1))
            local soul = (max-red)

            player:AddSoulHearts(soul*2)
            player:AddMaxHearts(red*2)
            player:AddHearts(red*2)
        end

        -- if twin then also heal Esau (not nessecary for forgotten because soul hearts applied automatically go to the soul)
        if selection.Twin then
            local twin = player:GetOtherTwin()
            setPlayerHealth(twin, selection.Twin)
        end

        GOLCG.SFX:Play(SoundEffect.SOUND_ISAACDIES, 1)
        GOLCG.SFX:Play(SoundEffect.SOUND_MIRROR_EXIT, 3)
        GOLCG.SFX:Play(SoundEffect.SOUND_DOGMA_TV_BREAK, 4, 30)

        GOLCG.GAME:SpawnParticles(player.Position, EffectVariant.GOLD_PARTICLE, 5, 1)
        GOLCG.GAME:SpawnParticles(player.Position, EffectVariant.CRACKED_ORB_POOF, 1, 1)
        GOLCG.GAME:SpawnParticles(player.Position, EffectVariant.GROUND_GLOW, 1, 1)
        GOLCG.GAME:SpawnParticles(player.Position, EffectVariant.HALLOWED_GROUND, 1, 1)

        player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        player:RemoveCollectible(item.ID)
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()  GOLCG:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,    item.handleRevive) end
function item:Disable() GOLCG:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, item.handleRevive) end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

if DetailedRespawnGlobalAPI then
	DetailedRespawnGlobalAPI:AddCustomRespawn({ name = "Shining clicker", itemId = item.ID, hasAltSprite = true }, DetailedRespawnGlobalAPI.RespawnPosition.Last)
end

return item