local mod = FiendFolio
local game = Game()

function mod:AddSamaelAngerBonus(amount)
	if SamaelMod and SamaelMod.IncreaseAngerBonus then
		SamaelMod.IncreaseAngerBonus(amount)
	end
end

-- Active Item Rendering

local renderActive = include("ffscripts.connor.utilities.renderActive")

mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderActive.OnRender)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, renderActive.OnUpdate)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, renderActive.ResetOnGameStart)

if REPENTOGON and ModCallbacks.MC_POST_HUD_RENDER then
	mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, function()
		renderActive:OnGetShaderParams()
	end)
else
	mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
		if shaderName == "StageAPI-RenderAboveHUD" and game:GetHUD():IsVisible() then
			renderActive:OnGetShaderParams()
		end
	end)
end

function mod:addActiveRender(tab)
	return renderActive:Add(tab)
end

-- Scripts

FiendFolio.LoadScripts({
	-- Items
	"ffscripts.connor.items.brown_horn",
	"ffscripts.connor.items.nyx",
	"ffscripts.connor.items.loaded_d6",
	"ffscripts.connor.items.isaac_dot_chr",
	"ffscripts.connor.items.dads_battery",
	-- Trinkets
	"ffscripts.connor.trinkets.broken_record",
	"ffscripts.connor.trinkets.wormhole_rock",
	-- Cards Etc
	"ffscripts.connor.cards.discs",
	"ffscripts.connor.cards.blank_letter_tile",
	-- Pickups
	"ffscripts.connor.pickups.custom_pickups",
	"ffscripts.connor.pickups.custom_batteries",
	-- Enemies
	"ffscripts.connor.enemies.beacon",
	-- Misc
	"ffscripts.connor.ff_character_pause_screen_marks",
	"ffscripts.connor.utilities.negative_charge",
	"ffscripts.ferrium.misc.renderSpells", --sorry, this wasn't working when I did it in my section -- hi ferrium
})

-- General callbacks

function mod:connorPostUpdate()
	mod:brokenRecordPostUpdate()
	mod:dadsBatteryPostUpdate()
	mod:chargeDebtPostUpdate()
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.connorPostUpdate)

function mod:connorPostRender()
	mod:discPostRender()
	mod:brokenRecordRenderSprites()
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.connorPostRender)

function mod:connorNewRoom()
	mod:spindleNewRoom()
	mod:wormholeRockNewRoom()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.connorNewRoom)

function mod:connorNewFloor()
	mod:resetBlankLetterTileData()
	mod:wormholeRockNewRoom()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.connorNewFloor)

-- Player callbacks

function mod:connorPlayerUpdate(player)
	mod:nyxKeepGemsStuck()
	mod:blankLetterTileUpdate(player)
	mod:handleChargeDebtSwap(player)
	mod:handleChargeDebt(player)
	mod:dadsBattery(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.connorPlayerUpdate)

function mod:connorPEffectUpdate(player)
	mod:nyxPlayerUpdate(player)
	mod:discPlayerUpdate(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.connorPEffectUpdate)

function mod:connorPlayerRender(player)
	mod:blankLetterTileRender(player)
	mod:isaacDotChrRender(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.connorPlayerRender)

-- Generic entity callbacks

function mod:connorPostEntityDeath(entity)
	mod:brownHornEntityDeath(entity)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.connorPostEntityDeath)

function mod:connorPostEntityRemove(entity)
	mod:brownHornEntityRemove(entity)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.connorPostEntityRemove)

function mod:connorTakeDamage(entity, damage, damageFlags, damageSourceRef, damageCountdown)
	local functions = {
		mod.brownHornDamage,
		mod.nyxDamage,
		mod.discItemWispDamage,
	}
	for _, func in pairs(functions) do
		if func(_, entity, damage, damageFlags, damageSourceRef, damageCountdown) == false then
			return false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.connorTakeDamage)

-- Misc entity callbacks

function mod:connorEnemyUpdate(entity)
	mod:brownHornEntityUpdate(entity)
	mod:nyxEnemyUpdate(entity)
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.connorEnemyUpdate)

function mod:connorFamiliarUpdate(entity)
	mod:brownHornEntityUpdate(entity)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.connorFamiliarUpdate)

function mod.connorSlotUpdate(slot)
	mod:brownHornEntityUpdate(slot)
end
mod.onEntityTick(EntityType.ENTITY_SLOT, mod.connorSlotUpdate)

function mod:connorLaserUpdate(laser)
	mod:nyxChainLightningUpdate(laser)
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.connorLaserUpdate)

function mod:connorPostTearInit(tear)
	mod:discItemWispTears(tear)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mod.connorPostTearInit)

function mod:connorPostTearUpdate(tear)
	mod:wormholeRockProjUpdate(tear)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.connorPostTearUpdate)

function mod:connorPostProjUpdate(proj)
	mod:wormholeRockProjUpdate(proj)
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, mod.connorPostProjUpdate)

function mod:connorPostBombUpdate(proj)
	mod:wormholeRockProjUpdate(proj)
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.connorPostBombUpdate)
