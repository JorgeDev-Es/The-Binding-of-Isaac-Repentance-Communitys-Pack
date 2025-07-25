--Fiend folio copper bomb thing... yeah

local Mod = CustomBombHUDIcons

function CustomBombHUDIcons:HandleCopperBombs()
    if not FiendFolio then
        return false
    end

    local copperBomb = false
    
    Mod:ForEachPlayer(function(player)
        local copperCount = player:GetData().ffsavedata and player:GetData().ffsavedata.FFCopperBombsStored
        if copperCount and copperCount > 0 or player:ToPlayer():HasTrinket(FiendFolio.ITEM.TRINKET.DUDS_FLOWER) then
			copperBomb = true
		end
    end)
    

    return copperBomb
end

local appliedFFthingy = false
function CustomBombHUDIcons.HandleCopperBombsReimplementation()
    if not FiendFolio or appliedFFthingy then
        return
    end

    appliedFFthingy = true
    local copperBombCostume = Sprite()
    copperBombCostume:Load('gfx/ui/bombSpritesCopper.anm2', true)
    copperBombCostume:SetFrame('Bombs', 0)

    --Reimplement copper bomb rendering
    HudHelper.RegisterHUDElement({
        Name = "Copper Bomb Reimplementation",
        Priority = 0,
        Condition = function(player, playerHUDIndex)
            if CustomBombHUDIcons:CheckIfShouldHaveCustomSprite() then
                return false
            end

            local renderE = true

            for _, preventFunction in ipairs(CustomBombHUDIcons.PreventRenderFunctions) do
                if preventFunction.Condition(player, playerHUDIndex) then
                    renderE = false
                    break
                end
            end

            if not renderE then
                return false
            end

            local render = false

            CustomBombHUDIcons:ForEachPlayer(function(player)
                local copperCount = player:GetData().ffsavedata and player:GetData().ffsavedata.FFCopperBombsStored
                if copperCount and copperCount > 0 or player:ToPlayer():HasTrinket(FiendFolio.ITEM.TRINKET.DUDS_FLOWER) then
                	render = true
                    return
                end
            end)

            return render
        end,
        OnRender = function(_, _, _, pos)
            local offset = HudHelper.GetResourcesOffset("Bombs")
            pos = offset + Vector(pos.X + 0, pos.Y + 44)

            if not REPENTOGON then
                local pauseDark = StageAPI.Lerp(1, 1 - StageAPI.PAUSE_DARK_BG_COLOR, StageAPI.GetPauseMenuDarkPct())
                local tint = Color(pauseDark, pauseDark, pauseDark, 1, 0, 0, 0)
                copperBombCostume.Color = tint
            end

            copperBombCostume:Render(pos)
        end,
        BypassGhostBaby = true,
    }, HudHelper.HUDType.BASE)
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, CustomBombHUDIcons.HandleCopperBombsReimplementation)