local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

--Originally devised by Connor for FF (discs)

-- Savedata for which discs are currently active.
local function GetDiscData(player)
	local data = mod.GetPersistentPlayerData(player)
	if not data.DiscData then
		data.DiscData = {}
	end
	return data.DiscData
end

-- Savedata which stores the InitSeeds of item wisps spawned from discs are expected to still exist.
-- Helps take advantage of the fact that item wisps maintain their InitSeed after quit+continue.
local function GetDiscWispRefs()
	if not mod.savedata.DiscWisps then
		mod.savedata.DiscWisps = {}
	end
	return mod.savedata.DiscWisps
end

local function GetExpectedItemData(player)
	local data = mod.GetPersistentPlayerData(player)
	if not data.ExpectedItemData then
		data.ExpectedItemData = {}
	end
	return data.ExpectedItemData
end

local function InitializeDiscItemWisp(wisp)
	wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	wisp.Visible = false
	wisp:RemoveFromOrbit()
	wisp:GetData().TaintedWispItem = true
end

function mod:CheckItemWisps(player, itemID, amount)
	amount = amount or 1
	local wispRefs = GetDiscWispRefs()
    local data1 = GetDiscData(player)
	local data2 = GetExpectedItemData(player)
	if not data2[""..itemID] then
		data2[""..itemID] = 0
	end
	local items = data2[""..itemID]

	if items < amount then
		--print(amount - items)
		mod:AddWispItem(player, itemID, amount - items)
		data2[""..itemID] = amount
	elseif items > amount then
		--print(items - amount)
		mod:RemoveWispItem(player, itemID, items - amount)
		data2[""..itemID] = amount
	end
end

function mod:AddWispItem(player, itemID, amount)
	amount = amount or 1
	local wispRefs = GetDiscWispRefs()
    local data = GetDiscData(player)
	
	if amount < 0 then
		mod:RemoveWispItem(player, itemID, -amount)
	else
		-- Add the hidden item wisp.
		for i = 1, amount do
			local wisp = player:AddItemWisp(itemID, player.Position)
			InitializeDiscItemWisp(wisp)
			wispRefs[""..wisp.InitSeed] = true
			mod:discItemWispUpdate(wisp)
			data[""..wisp.InitSeed] = itemID
		end
	end
end

function mod:RemoveWispItem(player, itemID, amount)
	amount = amount or 1
	local wispRefs = GetDiscWispRefs()
	local data = GetDiscData(player)
	
	for i, wisp in pairs(data) do
        if wisp == itemID then
            wispRefs[i] = nil
            data[i] = nil
			amount = amount - 1
			if amount <= 0 then
            	return
			end
        end	
	end
end

---------- Item wisp handling ----------

local suppressWispDeathEffects = false

-- Suppresses the effects of a disc wisp dying.
function mod:discEffectInit(eff)
	if suppressWispDeathEffects then
		eff:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.discEffectInit, EffectVariant.TEAR_POOF_A)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.discEffectInit, EffectVariant.POOF01)

function mod:discItemWispInit(wisp)
	if not wisp:GetData().TaintedWispItem and GetDiscWispRefs()[""..wisp.InitSeed] then
		-- This wisp isn't marked as a disc wisp, but there's supposed to be a disc wisp with this InitSeed.
		-- Most likely, we've quit and continued a run. Re-initialize this as a disc wisp and hide it.
		InitializeDiscItemWisp(wisp)
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.discItemWispInit, FamiliarVariant.ITEM_WISP)

function mod:discItemWispUpdate(wisp)
	local data = wisp:GetData()
	
	if not data.TaintedWispItem then return end
	wisp.Position = Vector(-100, -50)
	wisp.Velocity = Vector.Zero
	if not GetDiscWispRefs()[""..wisp.InitSeed] then
		-- This disc wisp should no longer exist.
		suppressWispDeathEffects = true
		wisp:Kill()
		suppressWispDeathEffects = false
		sfx:Stop(SoundEffect.SOUND_STEAM_HALFSEC)
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.discItemWispUpdate, FamiliarVariant.ITEM_WISP)

-- Disables collisions for disc wisps.
function mod:discItemWispCollision(wisp)
	if wisp:GetData().TaintedWispItem then
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.discItemWispCollision, FamiliarVariant.ITEM_WISP)

-- Prevents disc wisps from taking damage (or dealing damage).
function mod:discItemWispDamage(entity, damage, damageFlags, damageSourceRef, damageCountdown)
	if entity and entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.ITEM_WISP and entity:GetData().TaintedWispItem then
		return false
	end
	
	if damageSourceRef.Type == EntityType.ENTITY_FAMILIAR and damageSourceRef.Variant == FamiliarVariant.ITEM_WISP
			and damageSourceRef.Entity and damageSourceRef.Entity:GetData().TaintedWispItem then
		return false
	end
end

-- Prevents disc wisps from firing tears with book of virtues.
function mod:discItemWispTears(tear)
	if tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR
	and tear.SpawnerEntity.Variant == FamiliarVariant.ITEM_WISP
	and tear.SpawnerEntity:GetData().TaintedWispItem then
		tear:Remove()
	end
end

--Sacrifical Altar Fix (written by Dead for Fiend Folio)
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, -1, false, false)) do
        if wisp:GetData().TaintedWispItem then
            local fam = wisp:ToFamiliar()
            wisp:GetData().TaintedWispItemPlayer = fam.Player
            fam.Player = nil
        end
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, -1, false, false)) do
        if wisp:GetData().TaintedWispItem then
            local player = wisp:GetData().TaintedWispItemPlayer
            if player then
                wisp:ToFamiliar().Player = player
            end

            wisp:GetData().TaintedWispItemPlayer = nil
        end
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)