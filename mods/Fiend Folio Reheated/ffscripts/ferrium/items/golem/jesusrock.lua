local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:playerCurrentlyDying(player, sprite)
    local str = sprite:GetAnimation()
    if str:sub(-5) == "Death" then -- and player:GetHearts() <= 0 then
        return true
    end
end

local function GETMEUP(player, data)
    local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.JESUS_ROCK)
    local hearts = player:GetMaxHearts()
    if hearts > 0 then
        player:AddHearts(-1)
    else
        player:AddSoulHearts(-1)
    end

    if mult > 2 then --okay these thresholds are arbitrary but idc, stuff like henge rock goes weird otherwise
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM, -1)
    end
    if mult > 1.5 then
        player:AddHearts(99)
        player:AddSoulHearts(99)
    elseif mult > 0.8 or data.pleasegivemethisonechanceitwasunfairdamage then
        if hearts > 0 then
            player:AddHearts(12)
            if 12-hearts > 0 then
                player:AddSoulHearts(12-hearts)
            end
        else
            player:AddSoulHearts(12)
        end
    else
        if hearts > 0 then
            player:AddHearts(4)
            if 4-hearts > 0 then
                player:AddSoulHearts(4-hearts)
            end
        else
            player:AddSoulHearts(4)
        end
    end
    sfx:Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1)

    if mult > 1 then
        for i=1,mult do
            player:TryRemoveTrinket(mod.ITEM.ROCK.JESUS_ROCK)
        end
    else
        player:TryRemoveTrinket(mod.ITEM.ROCK.JESUS_ROCK)
    end
    data.pleasegivemethisonechanceitwasunfairdamage = nil
end

--ok thank you connor for isaac.chr

function mod:jesusRockSuperUpdate(player, data) --oh I guess this doesn't run when the player is dead during PEFFECT update
    local savedata = data.ffsavedata
    local isPlayingDeathAnimation = player:GetSprite():GetAnimation():sub(-#"Death") == "Death"
    local effs = player:GetEffects()
    local framesSinceLastPeffectUpdate = game:GetFrameCount() - (data.LastPeffectUpdate or 0)

    if isPlayingDeathAnimation and framesSinceLastPeffectUpdate > 0 and player:WillPlayerRevive()
			and savedata.JesusRockAddedLazEffect and not data.JesusRockRevive
		    and effs:HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE) then
        data.jesusRockRevive = true
    end
end

function mod:jesusRockUpdate(player, data)
    local effs = player:GetEffects()
    local mult = mod.GetGolemTrinketPower(player, mod.ITEM.ROCK.JESUS_ROCK)
    local savedata = data.ffsavedata
	local playerHoldingSoulOfLazarus = player:GetCard(0) == Card.CARD_SOUL_LAZARUS or player:GetCard(1) == Card.CARD_SOUL_LAZARUS

    --data.LastPeffectUpdate = game:GetFrameCount()
    --commented out cause isaac.chr does it, but putting this here in case

    if not (player:HasTrinket(mod.ITEM.ROCK.JESUS_ROCK) or data.pleasegivemethisonechanceitwasunfairdamage) then
		if savedata.JesusRockAddedLazEffect then
			effs:RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
			savedata.JesusRockAddedLazEffect = nil
		end
		return
	end

    if data.jesusRockRevive then
		data.jesusRockRevive = nil
		savedata.JesusRockAddedLazEffect = nil
		
		-- Trigger the actual revival effects.
		GETMEUP(player, data)
		
		local holdSprite = Sprite()
		holdSprite:Load("gfx/005.350_trinket.anm2", true)
        holdSprite:ReplaceSpritesheet(0, "gfx/items/trinkets/golem/trinket_jesusrock.png")
        holdSprite:LoadGraphics()
		holdSprite:Play("Idle", true)
		player:AnimatePickup(holdSprite, true)
	elseif not playerHoldingSoulOfLazarus and not effs:HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE) then
		effs:AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
		savedata.JesusRockAddedLazEffect = true
	elseif savedata.JesusRockAddedLazEffect and (effs:GetNullEffectNum(NullItemID.ID_LAZARUS_SOUL_REVIVE) > 1 or playerHoldingSoulOfLazarus) then
		effs:RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
		savedata.JesusRockAddedLazEffect = nil
	end
end