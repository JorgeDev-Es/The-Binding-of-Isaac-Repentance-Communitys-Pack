--oh thank you Connor, this was very helpful
local mod = FiendFolio
local game = Game()

local spellSprite = Sprite()
spellSprite:Load("gfx/ui/spellSlots.anm2", false)
spellSprite:LoadGraphics()

local flashColor = Color(0.3,0.3,0.3,1)
flashColor:SetColorize(1,1,1,1)

local function GetChargebarOffset(slot)
	if slot == ActiveSlot.SLOT_SECONDARY then
		return Vector(-2, 17)
	else
		return Vector(34, 17)
	end
end

local function shouldDisplaySpellSlots(player, slot)
	local activeInfo = mod:GetActiveItemInfo(player, slot)
    local man = activeInfo ~= nil and mod.SPELL[activeInfo.ID] ~= nil
	return man
end

--Spell slots decided per item
--This will mess up with multiple copies of the same spell, however
local function updateSpellSlotsUnderlay(player, slot, data)
    local item = player:GetActiveItem(slot)
    local baseInfo = mod.SPELL[item]
    local origData = player:GetData().ffsavedata
    if not origData.SpellSlots then
        origData.SpellSlots = {}
    end
    local savedata = origData.SpellSlots

    if not savedata[item] then
        savedata[item] = mod:makeCopiedTable(baseInfo)
        savedata[item].LastChanged = 0
    end

    data.Sprite:SetFrame(savedata[item].MaxSlots .. " Empty", 0)
	data.Offset = GetChargebarOffset(slot)
end

local function updateAvailableSpellSlots(player, slot, data)
    local item = player:GetActiveItem(slot)
    local baseInfo = mod.SPELL[item]
    local origData = player:GetData().ffsavedata
    if not origData.SpellSlots then
        origData.SpellSlots = {}
    end
    local savedata = origData.SpellSlots

    if savedata[item] == nil then
        savedata[item] = mod:makeCopiedTable(baseInfo)
        savedata[item].LastChanged = 0
	end
    

	data.Sprite:SetFrame(savedata[item].MaxSlots .. " Full", 0)
	
	if not game:IsPaused() and game:GetFrameCount() - savedata[item].LastChanged < 10 and math.ceil(Isaac.GetFrameCount() * 0.5) % 4 == 0 then
		data.Color = flashColor
	else
		data.Color = Color(1,1,1,1,0,0,0)
	end
	
	data.Offset = GetChargebarOffset(slot)

    data.BottomRightClamp = Vector(0, 5)

    if savedata[item].CurrentSlots and savedata[item].CurrentSlots > 0 then
		local percent = savedata[item].CurrentSlots / savedata[item].MaxSlots
		local x = (29-6) * percent
		data.TopLeftClamp = Vector(0, math.max(25.5 - x, 0))
	else
		data.TopLeftClamp = Vector(0, 30)
	end
end

--Base Pips of the Spell Slots
mod:addActiveRender({
	Sprite = spellSprite,
	Condition = shouldDisplaySpellSlots,
	Update = function(player, slot, data)
		updateSpellSlotsUnderlay(player, slot, data)
	end,
})

--Colored in Slots
mod:addActiveRender({
	Sprite = spellSprite,
	Condition = shouldDisplaySpellSlots,
	Update = function(player, slot, data)
		updateAvailableSpellSlots(player, slot, data)
	end,
})