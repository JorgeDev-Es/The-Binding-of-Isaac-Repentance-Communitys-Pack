local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local ISAAC_DOT_CHR_GFX = Isaac.GetItemConfig():GetCollectible(mod.ITEM.COLLECTIBLE.ISAAC_DOT_CHR).GfxFileName
local ISAAC_DOT_CHR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/isaac_dot_chr.anm2")


local NO_REPLACE = {
	[CollectibleType.COLLECTIBLE_TMTRAINER] = true,
	[CollectibleType.COLLECTIBLE_MISSING_NO] = true,
	[CollectibleType.COLLECTIBLE_UNDEFINED] = true,
	[CollectibleType.COLLECTIBLE_DATAMINER] = true,
	[CollectibleType.COLLECTIBLE_GB_BUG] = true,
	[CollectibleType.COLLECTIBLE_TMTRAINER] = true,
	[CollectibleType.COLLECTIBLE_GLITCHED_CROWN] = true,
	[mod.ITEM.COLLECTIBLE.WRONG_WARP] = true,
	[mod.ITEM.COLLECTIBLE.NIL_PASTA] = true,
	[mod.ITEM.COLLECTIBLE.ISAAC_DOT_CHR] = true,
}

local GLITCH_SPRITES = {}

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	GLITCH_SPRITES = {}
end)

local function AddGlitchItems(player)
	local itemConfig = Isaac.GetItemConfig()
	local itemPool = game:GetItemPool()
	local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.ISAAC_DOT_CHR)
	
	-- Get all the player's current items.
	local inventory = {}
	
	for itemID=1, itemConfig:GetCollectibles().Size-1 do
		local item = itemConfig:GetCollectible(itemID)
		if not NO_REPLACE[itemID] and item and item.Type ~= ItemType.ITEM_ACTIVE and not item:HasTags(ItemConfig.TAG_QUEST) and player:HasCollectible(itemID, true) then
			for i=1, player:GetCollectibleNum(itemID, true) do
				table.insert(inventory, itemID)
			end
		end
	end
	
	-- Generate TMTRAINER items to add.
	local numGlitchItemsToGenerate = math.max(math.ceil(#inventory / 5), 1)
	local attempts = 0
	local generatedGlitchItems = {}
	local glitchActive = nil
	
	player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
	while #generatedGlitchItems < numGlitchItemsToGenerate and attempts < 50 do
		local glitchItemID = itemPool:GetCollectible(0)
		local glitchItem = itemConfig:GetCollectible(glitchItemID)
		if glitchItem then
			if glitchItem.Type ~= ItemType.ITEM_ACTIVE then
				table.insert(generatedGlitchItems, glitchItemID)
			elseif not glitchActive then
				glitchActive = glitchItemID
			end
		end
		attempts = attempts + 1
	end
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
	
	-- Replace the player's active item if we happened to generate one (likely).
	if glitchActive and not NO_REPLACE[player:GetActiveItem()] then
		player:AddCollectible(glitchActive)
	end
	
	if #inventory == 0 and #generatedGlitchItems > 0 then
		-- Just add a glitch item if the player has nothing to replace.
		player:AddCollectible(generatedGlitchItems[1])
	else
		-- Replace random items with the TMTRAINER items.
		for _, glitchItemID in pairs(generatedGlitchItems) do
			if #inventory < 1 then break end
			local itemToReplace = table.remove(inventory, rng:RandomInt(#inventory)+1)
			player:RemoveCollectible(itemToReplace)
			player:AddCollectible(glitchItemID)
		end
	end
end

local function TriggerIsaacDotChrRevive(player)
	sfx:Play(SoundEffect.SOUND_EDEN_GLITCH)
	sfx:Play(SoundEffect.SOUND_ISAACDIES)
	mod.scheduleForUpdate(function()
		sfx:Play(SoundEffect.SOUND_ISAACDIES)
	end, 10)
	
	mod:playBrokenRecordVisualEffect(player, mod.ITEM.COLLECTIBLE.ISAAC_DOT_CHR, false, true)
	
	-- Add TMTRAINER items.
	AddGlitchItems(player)
	-- Reroll stats, because why not.
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D8, UseFlag.USE_NOANIM)

	--Add da costume
	player:AddNullCostume(ISAAC_DOT_CHR_COSTUME)
	
	-- Add some random health
	local rng = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.ISAAC_DOT_CHR)
	player:AddBlackHearts(rng:RandomInt(4))
	player:AddSoulHearts(rng:RandomInt(4))
	player:AddGoldenHearts(rng:RandomInt(2))
	player:AddBoneHearts(rng:RandomInt(2))
	player:AddHearts(rng:RandomInt(6))
	player:AddRottenHearts(rng:RandomInt(3))
	mod:AddImmoralHearts(player, rng:RandomInt(4))
	mod:AddMorbidHearts(player, rng:RandomInt(6))
	
	-- Remove or add heart containers, though never remove ALL heart containers.
	-- I think this can add half a heart container, but that's fine, extra glitchy.
	local maxToRemove = math.min(math.max(player:GetMaxHearts() - 2, 0), 4)
	player:AddMaxHearts(rng:RandomInt(maxToRemove + 4) - maxToRemove)
	
	-- Queue up the glitchy player "clone" visuals.
	table.insert(GLITCH_SPRITES, {
		Anim = "Death",
		Pos = player.Position,
	})
	table.insert(GLITCH_SPRITES, {
		Pos = player.Position + RandomVector() * (50 + (Random() % 100)),
		Rot = Random() % 360,
	})
	table.insert(GLITCH_SPRITES, {
		Pos = player.Position + RandomVector() * (200 + (Random() % 200)),
		Rot = Random() % 360,
	})
end

-- Renders glitchy copies of the player as visual flair post-revival.
function mod:isaacDotChrRender(player)
	if #GLITCH_SPRITES == 0 then return end
	
	local sprite = player:GetSprite()
	local data = player:GetData()
	
	-- Track what the player's animation state currently is.
	local anim = sprite:GetAnimation()
	local frame = sprite:GetFrame()
	local isPlaying = sprite:IsPlaying(anim)
	
	-- Try to account for non-1.0 PlaybackSpeed (well enough)
	data.isaacDotChrSubFrame = (data.isaacDotChrSubFrame or 0) + sprite.PlaybackSpeed
	if frame == data.isaacDotChrLastFrame and data.isaacDotChrSubFrame > 2 then
		frame = frame + 1
		data.isaacDotChrSubFrame = 0
	elseif frame ~= data.isaacDotChrLastFrame then
		data.isaacDotChrSubFrame = 0
	end
	data.isaacDotChrLastFrame = frame
	
	local overlay = sprite:GetOverlayAnimation()
	local overlayFrame = sprite:GetOverlayFrame()
	local overlayIsPlaying = sprite:IsOverlayPlaying(overlay)
	
	local rot = sprite.Rotation
	
	-- Use the player's sprite to render the glitch sprites.
	-- If only I could get the spritesheet from the player's Sprite, I'd use a seperate Sprite object instead of this mess.
	sprite:RemoveOverlay()
	for _, tab in pairs(GLITCH_SPRITES) do
		if not tab.Anim then
			sprite:PlayRandom()
			tab.Anim = sprite:GetAnimation()
		end
		if not tab.LastFrame then
			sprite:Play(tab.Anim, true)
			sprite:SetLastFrame()
			tab.LastFrame = sprite:GetFrame()
		end
		if not tab.N then
			tab.N = (Random() % 100) / 100
		end
		if not tab.Offset then
			tab.Offset = RandomVector() * 10
		end
		
		sprite:SetFrame(tab.Anim, math.ceil(tab.Frame or 0))
		sprite.Rotation = tab.Rot or 0
		local pos = Isaac.WorldToScreen(tab.Pos)
		sprite:Render(pos, Vector(0, mod:Lerp(20, 50, tab.N)), Vector(0, 0))
		sprite:Render(pos + tab.Offset, Vector(0, 0), Vector(0, mod:Lerp(35, 15, tab.N)))
		
		if not game:IsPaused() then
			tab.Frame = ((tab.Frame or 0) + 0.5) % tab.LastFrame
		end
	end
	
	-- Put the player's sprite back where it should be. MOSTLY seamless. Close enough for this niche case, at least.
	sprite:Play(anim, true)
	sprite:SetFrame(frame)
	if not isPlaying then
		sprite:Stop()
	end
	if overlay and overlay ~= "" then
		if overlayIsPlaying then
			sprite:PlayOverlay(overlay)
			sprite:SetOverlayFrame(overlayFrame)
		else
			sprite:SetOverlayFrame(overlay, overlayFrame)
		end
	end
	sprite.Rotation = rot
end


----------------------------------------------------------------------------------------------------
---- REVIVAL DETECTION / HANDLING ------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- MC_POST_PLAYER_UPDATE runs the entire time the player is "dying".
-- MC_POST_PEFFECT_UPDATE doesn't, but if the player revives, it will only run ONCE while the death animation is still playing, at the end before revival.
-- Detecting death/revival via the death animation still playing on that single PEFFECT frame could potentially be inconsistent.
-- So the method implemented here is described as follows:
--
-- On MC_POST_PEFFECT_UPDATE, if the player has our item and won't currently revive, we add the "Soul of Lazarus" effect, and keep track of the fact WE added it.
-- The "Soul of Lazarus" effect persists on quit and continue, so keeping track of the fact WE added it should be done in persistent player savedata.
-- We'll also remove our "Soul of Lazarus" effect if the player loses the item without dying, or if they get more than one "Soul of Lazarus" stack.
-- 
-- On MC_POST_PLAYER_UPDATE, we detect if the player is playing their death animation, will revive, AND that WE previously added the "Soul of Lazarus" effect.
-- If so, we're fairly confident that we're responsible for the revival, so we populate a GetData boolean (this doesn't need to be savedata).
--
-- On the next MC_POST_PEFFECT_UPDATE (which will only trigger post-revive) we'll see that we set that boolean, and trigger any post-revival effects (like removing our item).
--
-- The "Soul of Lazarus" null effect seems to take priority over other forms of revival.
--
-- This logic was originally based on "Crystal Skull" from Tainted Treasures, so thanks JD for that and for helping figure out how to solve compatability issues with this method.

-- On MC_POST_PLAYER_UPDATE, detect that the player is dying and will revive.
-- (See top of this section for more detail.)
function mod:isaacDotChrPlayerUpdate(player)
	local data = player:GetData()
	local savedata = data.ffsavedata
	
	local isPlayingDeathAnimation = player:GetSprite():GetAnimation():sub(-#"Death") == "Death"  -- Does their current animation end with "Death"?
	local framesSinceLastPeffectUpdate = game:GetFrameCount() - (data.LastPeffectUpdate or 0)  -- PEFFECT doesn't run while dying.
	
	if isPlayingDeathAnimation and framesSinceLastPeffectUpdate > 0 and player:WillPlayerRevive()
			and savedata.IsaacDotChrAddedLazEffect and not data.IsaacDotChrRevive
			and player:GetEffects():HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE) then
		-- Pretty sure the player is reviving using OUR Soul of Lazarus effect.
		-- Trigger the revival effects on the next PEFFECT update.
		data.IsaacDotChrRevive = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.isaacDotChrPlayerUpdate)

-- On MC_POST_PEFFECT_UPDATE, handle adding/removing the Soul of Lazarus effect and any post-revival effects (after detecting death+revival above).
-- (See top of this section for more detail.)
function mod:isaacDotChrPeffectUpdate(player)
	local peffects = player:GetEffects()
	local data = player:GetData()
	local savedata = data.ffsavedata
	local playerHoldingSoulOfLazarus = player:GetCard(0) == Card.CARD_SOUL_LAZARUS or player:GetCard(1) == Card.CARD_SOUL_LAZARUS
	
	-- PEFFECT doesn't run while dying, so we can refer to this to more accurately detect death.
	data.LastPeffectUpdate = game:GetFrameCount()
	
	if not player:HasCollectible(mod.ITEM.COLLECTIBLE.ISAAC_DOT_CHR) then
		if savedata.IsaacDotChrAddedLazEffect then
			-- The player HAD this item and we added the Soul of Lazarus effect.
			-- But they lost the item without reviving using it, so remove a stack.
			peffects:RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
			savedata.IsaacDotChrAddedLazEffect = nil
		end
		return
	end
	
	if data.IsaacDotChrRevive then
		-- We detected the player dying in MC_POST_PLAYER_UPDATE, and we assumed it was our revive because WE added a Soul of Lazarus effect.
		-- Remove our revive item and its associated booleans.
		data.IsaacDotChrRevive = nil
		savedata.IsaacDotChrAddedLazEffect = nil
		player:RemoveCollectible(mod.ITEM.COLLECTIBLE.ISAAC_DOT_CHR)
		
		-- Trigger the actual revival effects.
		TriggerIsaacDotChrRevive(player)
		
		-- Playing a different animation isn't necessary, but will stop other code from detecting the player's finished death animation this frame.
		player:AnimateAppear()
		player:GetSprite():Play("Glitch", true)
	elseif not playerHoldingSoulOfLazarus and not peffects:HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE) then
		-- If the player doesn't already have a stack of the Lazarus effect, add it and keep track of the fact we did so in player savedata.
		peffects:AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
		savedata.IsaacDotChrAddedLazEffect = true
	elseif savedata.IsaacDotChrAddedLazEffect and (peffects:GetNullEffectNum(NullItemID.ID_LAZARUS_SOUL_REVIVE) > 1 or playerHoldingSoulOfLazarus) then
		-- We previously added a "Soul of Lazarus" stack, but now there's more than one (or they have the actual Soul Stone).
		-- To be safe, remove ours. The player can revive using the other one.
		peffects:RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
		savedata.IsaacDotChrAddedLazEffect = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.isaacDotChrPeffectUpdate)
