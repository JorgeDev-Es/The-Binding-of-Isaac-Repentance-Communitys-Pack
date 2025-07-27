local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

function mod:ResetMaelstroms() --Debugging / reseting
    for _, effect in pairs(Isaac.FindByType(1000, TaintedEffects.MAELSTROM_INDIACTOR)) do
        effect:Remove()
    end
    local player = Isaac.GetPlayer(0)

    player:GetData().MaelstromIndicators = {}
end

local function UpdateMaelstromVals(player, data, savedata)
    data.MaelstromIndicators = data.MaelstromIndicators or {}
    savedata.ExpectedMaelstroms = savedata.ExpectedMaelstroms or 0
    data.MaelstromAngle = data.MaelstromAngle or 0

    data.MaelstromAngle = data.MaelstromAngle + 4
    savedata.ExpectedMaelstroms = math.min(3, savedata.ExpectedMaelstroms)
end

local function AddMaelstromCharge(player, data, savedata)
    local effect = Isaac.Spawn(1000, TaintedEffects.MAELSTROM_INDIACTOR, 0, player.Position, Vector.Zero, player)
    table.insert(data.MaelstromIndicators, effect)
end

local function RemoveMaelstromCharge(player, data, savedata)
    data.MaelstromIndicators[#data.MaelstromIndicators]:Remove()
    data.MaelstromIndicators[#data.MaelstromIndicators] = nil

    savedata.ExpectedMaelstroms = savedata.ExpectedMaelstroms - 1
end

local function UpdateMaelstromOrbitals(player, data, orbitals)
    for i, orbital in pairs(data.MaelstromIndicators) do
        if orbital:Exists() then
            local angle = ((360 / #data.MaelstromIndicators) * i) + data.MaelstromAngle
            local pos = player.Position + Vector(player.Size + 20, 0):Rotated(angle)
            local vel = pos - orbital.Position
            orbital.Velocity = vel:Resized(math.min(vel:Length(), 20))

            mod:spritePlay(orbital:GetSprite(), "Move")
        else
            data.MaelstromIndicators[i] = nil
        end
    end
end

local function DoBladeMaelstrom(player)
    player:GetData().MaelstromBlades = 90
end

function mod:MaelstromPlayerLogic(player, data, savedata)
    UpdateMaelstromVals(player, data, savedata)

    UpdateMaelstromOrbitals(player, data)

    while #data.MaelstromIndicators < savedata.ExpectedMaelstroms do
        AddMaelstromCharge(player, data, savedata)
    end

    if data.MaelstromBlades and data.MaelstromBlades > 0 then
        data.MaelstromBlades = data.MaelstromBlades - 5
        if data.MaelstromBlades % 10 == 0 then
            for i = 90, 360, 90 do
                local saw = mod:FireSawblade(player, Vector(10,0):Rotated(i + data.MaelstromBlades), nil, 0.2)
                saw.Scale = saw.Scale - 0.2

                if data.MaelstromBlades % 30 == 0 then
                    saw:AddTearFlags(TearFlags.TEAR_ATTRACTOR)
                end
            end
        end
    else --Only activate the ability while it isnt already active
        if #data.MaelstromIndicators > 0 then
            if data.TaintedDoubleTapped then
                DoBladeMaelstrom(player)
                RemoveMaelstromCharge(player, data, savedata)
            end
        end
    end
end