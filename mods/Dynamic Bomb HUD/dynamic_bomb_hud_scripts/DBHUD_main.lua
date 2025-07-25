local Mod = CustomBombHUDIcons
local game = Game()

include("dynamic_bomb_hud_scripts/bombs_data")
include("dynamic_bomb_hud_scripts/prevent_render_functions_data")

local BSprType = CustomBombHUDIcons.spriteType

--Render bombs lolz
local bombCostumesHUD = Sprite()

function Mod:AddBombHUDElementHUDHelper()
    HudHelper.RegisterHUDElement({
    	Name = "[DBHUD] Custom Bomb Icons",
    	Priority = HudHelper.Priority.HIGH,
    	Condition = function(player, playerHUDIndex)
            local render = true

            for _, preventFunction in ipairs(CustomBombHUDIcons.PreventRenderFunctions) do
                if preventFunction.Condition(player, playerHUDIndex) then
                    render = false
                    break
                end
            end

    		return render
    	end,
    	OnRender = function(_, _, _, pos)
    		local offset = HudHelper.GetResourcesOffset("Bombs")
    		pos = offset + Vector(pos.X + 0, pos.Y + 44)

            local dataToSelectFrom = {}
            local selectedData = nil
            local endingData = nil

            local breakLater = false

            local cycle = CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "Cycle", false)
            local tLazCheck = CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "CountTLazHologram", false)

            for _, bombData in ipairs(CustomBombHUDIcons.RenderBombsData) do
                Mod:ForEachPlayer(function(player)
                    if bombData.Condition(player) and not (CustomBombHUDIcons:IsTRLazBRGhost(player) and not tLazCheck) then
                        --Add modifier to list
                        dataToSelectFrom[#dataToSelectFrom + 1] = bombData

                        --No need to continue with the "for" if only one gets used.
                        if not cycle then
                            breakLater = true
                        end

                        return
                    end
                end)
                if breakLater then
                    break
                end
            end

            if #dataToSelectFrom > 0 then
                if cycle then
                    local frames = game:GetFrameCount() or 0
                    local framesPerCycle = CustomBombHUDIcons:GetOption(CustomBombHUDIcons.saveManager.GetSettingsSave(), "FramesPerCycle", 30)
                    local posInTable = (math.floor(frames / framesPerCycle) % #dataToSelectFrom) + 1
                    selectedData = dataToSelectFrom[posInTable]
                else
                    selectedData = dataToSelectFrom[1]
                end
            end

            if selectedData then
                --Check for golden bombs
                local typeSprite = BSprType.NORMAL
                Mod:ForEachPlayer(function(playerG)
                    if playerG:HasGoldenBomb() then
                        typeSprite = BSprType.GOLD
                        return
                    end
                end)

                --FIEND FOLIO COMPATIBILITY!!!

                local copperBomb = CustomBombHUDIcons:HandleCopperBombs()

                if copperBomb then
                    typeSprite = BSprType.COPPER
                end

                --Get resulting Anm2

                local resultingANM2

                if typeSprite == BSprType.NORMAL then
                    resultingANM2 = selectedData.Anm2
                elseif typeSprite == BSprType.GOLD then
                    resultingANM2 = selectedData.GoldAnm2
                elseif typeSprite == BSprType.COPPER then
                    resultingANM2 = selectedData.CopperAnm2
                end

                resultingANM2 = resultingANM2 or selectedData.Anm2

                --Set the rendering data
                endingData = {
                    Anm2 = resultingANM2,
                    FrameName = selectedData.FrameName,
                    Frame = selectedData.Frame
                }
            end

            if endingData then
                bombCostumesHUD:Load(endingData.Anm2, true)
                bombCostumesHUD:SetFrame(endingData.FrameName, endingData.Frame)

                --I am not recreating the color thing, sorry. If a popular mod already does it I might also just use it too if it's on.
                if StageAPI and not REPENTOGON then
                    local pauseDark = StageAPI.Lerp(1, 1 - StageAPI.PAUSE_DARK_BG_COLOR, StageAPI.GetPauseMenuDarkPct())	            local tint = Color(pauseDark, pauseDark, pauseDark, 1, 0, 0, 0)	            bombCostumesHUD.Color = tint
                end

    	        bombCostumesHUD:Render(pos)
            end
    	end,
    	BypassGhostBaby = true,
    }, HudHelper.HUDType.BASE)
end

if REPENTOGON then
	Mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, Mod.AddBombHUDElementHUDHelper)
else
	function Mod:AddBombHUDElement(iscontinued)
		if iscontinued then return end

		Mod:AddBombHUDElementHUDHelper()
	end

	Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.AddBombHUDElement)
end

function CustomBombHUDIcons:CheckIfShouldHaveCustomSprite()
    local hasItTho = false
    Mod:ForEachPlayer(function(player)
        for _, bombData in ipairs(CustomBombHUDIcons.RenderBombsData) do
            if bombData.Condition(player) then
                hasItTho = true
                return
            end
        end
    end)
    return hasItTho
end