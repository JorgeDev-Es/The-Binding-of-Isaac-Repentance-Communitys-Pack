local RepentogonTest = RegisterMod("RepentogonTest", 1)
local IsRepPlus=(FontRenderSettings~=nil)	--detect rep+

local renderFont = Font()
renderFont:Load("font/teamMeatFont16Bold.fnt")

local hud = Game():GetHUD()

local function drawString(text, x, y)
    renderFont:DrawString(text, x, y, KColor(1, 0, 0, 1), 1, true)
end    

local function displayWarning()
    RepentogonTest:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        hud:SetVisible(false)
        local height = Isaac.GetScreenHeight() / 2
        local width = Isaac.GetScreenWidth() / 2
		if not IsRepPlus then
			drawString("REPENTOGON isn't fully installed!", width, height - 60)
			drawString("Head to repentogon.com/install", width, height - 30)
			drawString("for installation instructions.", width, height)
		else
			drawString("REPENTOGON is incompatible with Repentance+", width, height - 60)
			drawString("at the moment. If you still want to", width, height - 30)
			drawString("get access to REPENTOGON, consider",width,height)
			drawString("downgrading to Repentance.", width, height+30)
		end
    end)
end

local function main()
    if not REPENTOGON then
        displayWarning()
    end
end


main()
