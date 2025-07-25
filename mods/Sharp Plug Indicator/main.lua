-- Prerequisites and initializing the only variable
local plug_indicator = RegisterMod("plug_indicator", 1)
local json = require("json")

local font = Font()
font:Load("font/luaminioutlined.fnt")

-- Initialize the sprite
local spr_plug = Sprite()
spr_plug:Load("gfx/ui/sharpplug.anm2", true)
spr_plug:Play("SharpPlug", true)

-- Do the render loop
function plug_indicator:render()
	if Game():IsPaused() == true and Game():GetRoom():GetAliveBossesCount() > 0 then return else 
	    if Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_SHARP_PLUG, false) and Isaac.GetPlayer(0):GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0 and Isaac.GetItemConfig():GetCollectible(Isaac.GetPlayer(0):GetActiveItem(ActiveSlot.SLOT_PRIMARY)).MaxCharges > 0 then
	        spr_plug.FlipX = false
	        spr_plug:Render(Vector(39+2*Options.HUDOffset*10, 1.2*Options.HUDOffset*10))
	        hearts_taken = math.min(math.min(math.max(Isaac.GetItemConfig():GetCollectible(Isaac.GetPlayer(0):GetActiveItem(ActiveSlot.SLOT_PRIMARY)).MaxCharges - Isaac.GetPlayer(0):GetEffectiveBloodCharge() - Isaac.GetPlayer(0):GetEffectiveSoulCharge() - Isaac.GetPlayer(0):GetActiveCharge(ActiveSlot.SLOT_PRIMARY), 0), Isaac.GetPlayer(0):GetHearts() + Isaac.GetPlayer(0):GetSoulHearts() - 0.5), Isaac.GetItemConfig():GetCollectible(Isaac.GetPlayer(0):GetActiveItem(ActiveSlot.SLOT_PRIMARY)).MaxCharges)
	       --[[ font:DrawString("Max Charges: " .. Isaac.GetItemConfig():GetCollectible(Isaac.GetPlayer(0):GetActiveItem(ActiveSlot.SLOT_PRIMARY)).MaxCharges, 40, 60, KColor(1,1,0,1), 0, false)
	        font:DrawString("Blood Charge: " .. Isaac.GetPlayer(0):GetEffectiveBloodCharge(), 40, 70, KColor(1,1,0,1), 0, false)
	        font:DrawString("Soul Charges: " .. Isaac.GetPlayer(0):GetEffectiveSoulCharge(), 40, 80, KColor(1,1,0,1), 0, false)
	        font:DrawString("CurrentCharge: " .. Isaac.GetPlayer(0):GetActiveCharge(ActiveSlot.SLOT_PRIMARY), 40, 90, KColor(1,1,0,1), 0, false)
	        font:DrawString("Current RedHP: " .. Isaac.GetPlayer(0):GetHearts(), 40, 100, KColor(1,1,0,1), 0, false)
	        font:DrawString("Current SoulHP: " .. Isaac.GetPlayer(0):GetSoulHearts(), 40, 110, KColor(1,1,0,1), 0, false)
	        font:DrawString("Current TotHP: " .. Isaac.GetPlayer(0):GetSoulHearts(), 40, 120, KColor(1,1,0,1), 0, false)]]
	        if hearts_taken > 0 then
	            font:DrawString(hearts_taken, 50+2*Options.HUDOffset*10, 1.2*Options.HUDOffset*10 - 6, KColor(1,1,1,1), 0, false)
	        end
	    end
	    if Game():GetNumPlayers() > 1 and Isaac.GetPlayer(1):HasCollectible(CollectibleType.COLLECTIBLE_SHARP_PLUG, false) and Isaac.GetPlayer(1):GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0 and Isaac.GetItemConfig():GetCollectible(Isaac.GetPlayer(1):GetActiveItem(ActiveSlot.SLOT_PRIMARY)).MaxCharges > 0 then
	        local windowsize = (Isaac.WorldToScreen(Vector(320, 280)) - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset) * 2
	        local windowY = windowsize.Y
	        local windowX = windowsize.X
	        spr_plug.FlipX = true
	        spr_plug:Render(Vector(windowX-39-1.6*Options.HUDOffset*10, windowY-39-0.6*Options.HUDOffset*10))
	        hearts_taken = math.min(math.min(math.max(Isaac.GetItemConfig():GetCollectible(Isaac.GetPlayer(1):GetActiveItem(ActiveSlot.SLOT_PRIMARY)).MaxCharges - Isaac.GetPlayer(1):GetEffectiveBloodCharge() - Isaac.GetPlayer(1):GetEffectiveSoulCharge() - Isaac.GetPlayer(1):GetActiveCharge(ActiveSlot.SLOT_PRIMARY), 0)*0.5, Isaac.GetPlayer(1):GetHearts() + Isaac.GetPlayer(1):GetSoulHearts() - 0.5), Isaac.GetItemConfig():GetCollectible(Isaac.GetPlayer(1):GetActiveItem(ActiveSlot.SLOT_PRIMARY)).MaxCharges)
	        if hearts_taken > 0 then
	            font:DrawString(hearts_taken, windowX-66-1.6*Options.HUDOffset*10, windowY-45-0.6*Options.HUDOffset*10, KColor(1,1,1,1), 0, false)
	        end
	    end
    end
end
plug_indicator:AddCallback(ModCallbacks.MC_POST_RENDER, plug_indicator.render)
