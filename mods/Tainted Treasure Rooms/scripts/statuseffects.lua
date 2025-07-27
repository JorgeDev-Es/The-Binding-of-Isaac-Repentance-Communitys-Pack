local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local filepath = "gfx/ui/ui_statusicons.anm2"

local iconRepulsion = Sprite()
iconRepulsion:Load(filepath, true)
iconRepulsion:Play("Repulsion", true)

local iconGerminated = Sprite()
iconGerminated:Load(filepath, true)
iconGerminated:Play("Germinated", true)

local iconEnlightened = Sprite()
iconEnlightened:Load(filepath, true)
iconEnlightened:Play("Enlightened", true)

TaintedStatus = {
    Repulsion = {
        Icon = iconRepulsion,
        Color = mod.ColorBuzzingMagnet,
        Update = mod.BuzzingMagnetsEnemyLogic,
        Init = mod.InitRepulsionStatus,
    },
    Germinated = {
        Icon = iconGerminated,
        Color = mod.ColorGerminated,
        Update = mod.GerminatedEnemyUpdate,
        Init = mod.InitGerminatedStatus,
    },
	Enlightened = {
		Icon = iconEnlightened,
        Color = mod.ColorEnlightened,
        Init = mod.InitEnlightenedStatus,
	}
}

function mod:InitCustomStatus(npc, data)
    data.TaintedStatusTimer = data.TaintedStatusTimer or 0
    data.TaintedStatusDuration = data.TaintedStatusDuration or 0
end

function mod:CustomStatusUpdate(npc, data)
    if data.TaintedStatus then
        local status = TaintedStatus[data.TaintedStatus]
		if status.Update then
			status.Update(_, npc, data)
		end
        if status.Color then
            npc:SetColor(status.Color, 2, 1)
        end
        data.TaintedStatusDuration = data.TaintedStatusDuration - 1
        if data.TaintedStatusDuration <= 0 then
            data.TaintedStatus = nil
        end
    end
	if data.TaintedStatusTimer and data.TaintedStatusTimer > 0 then
		data.TaintedStatusTimer = data.TaintedStatusTimer - 1
	end
end

function mod:StatusIconRendering(npc, data)
    if data.TaintedStatus then
        local status = TaintedStatus[data.TaintedStatus]
        if status.Icon then
            status.Icon.Offset = Vector(0, -30 + npc.Size * -1.0)
            status.Icon:Render(Isaac.WorldToScreen(npc.Position))
        end
    end
end

function mod:UpdateCustomStatusIcons()
    for _, status in pairs(TaintedStatus) do
        if status.Icon then
            status.Icon:Update()
        end
    end
end

function mod:ApplyCustomStatus(npc, status, duration, player)
	local data = npc:GetData()
    local didstatus
	mod:InitCustomStatus(npc, data)


	if data.TaintedStatusTimer <= 0 and not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then 
		duration = duration or 90
		if player then
			duration = duration * (1 + player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND))
		end

        didstatus = true
	end

    local statussy = TaintedStatus[status]
    if statussy.Init then
        statussy.Init(_, npc, data, didstatus, player)
    end

    if didstatus then
        data.TaintedStatus = status
        data.TaintedStatusDuration = duration
        if npc:IsBoss() then
            data.TaintedStatusTimer = 240
        end
    end
end