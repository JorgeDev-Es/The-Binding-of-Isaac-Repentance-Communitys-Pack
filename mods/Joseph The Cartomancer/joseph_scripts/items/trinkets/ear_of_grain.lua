local EarGrain = {}

local enums = JosephMod.enums
local util = JosephMod.utility
local earOfGrain = enums.Trinkets.EAR_OF_GRAIN



TSIL.SaveManager.AddPersistentVariable(
    JosephMod,
    "FaminesKilledPerFloor",
    0,
    TSIL.Enums.VariablePersistenceMode.RESET_LEVEL,
    false
)


local famineReady = false
function EarGrain:EnterBossRoom()
    local room = Game():GetRoom()
    if room:GetType() ~= RoomType.ROOM_BOSS then return end
    if util:IsFinalBossRoom() then return end
    if room:IsClear() then return end

    local faminesKilled = TSIL.SaveManager.GetPersistentVariable(JosephMod, "FaminesKilledPerFloor")
    if faminesKilled == {} then faminesKilled = 0 end
    if faminesKilled >= PlayerManager.GetTotalTrinketMultiplier(earOfGrain) then return end

    if PlayerManager.AnyoneHasTrinket(earOfGrain) then
        famineReady = true
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EarGrain.EnterBossRoom)


function EarGrain:CheckBossScreenEnded()
    if not famineReady then return end
    if Game():GetRoom():GetFrameCount() == 20 then
        local grainCount = PlayerManager.GetTotalTrinketMultiplier(earOfGrain)
        for i = 0, grainCount - 1, 1 do
            EarGrain:SummonFamine()
        end
        famineReady = false
    end

end
JosephMod:AddCallback(ModCallbacks.MC_POST_UPDATE, EarGrain.CheckBossScreenEnded)


function EarGrain:SummonFamine()
    local famine = Isaac.Spawn(63, 0, 0, Vector(1000, 450), Vector(0, 0), nil):ToNPC()
    if not famine then return end
    famine.Visible = false
    famine.MaxHitPoints = 80 + 35*Game():GetLevel():GetStage()
    famine.HitPoints = 80 + 35*Game():GetLevel():GetStage()
    local data = util:GetData(famine, "EarOfGrain")
    data.ShouldDropCube = true

    Isaac.CreateTimer(function ()
        famine.Visible = true
    end, 1, 1, false)

    Isaac.CreateTimer(function ()
        famine.Velocity = famine.Velocity + Vector(23, 0)
    end, 3, 1, false)
    famine.State = 8
    famine:GetSprite():Play("AttackDashStart")
    SFXManager():Play(SoundEffect.SOUND_MONSTER_YELL_A)

end


function EarGrain:FamineDie(famine)
    local data = util:GetData(famine, "EarOfGrain")
    if not (data and data.ShouldDropCube == true) then return end

    local faminesKilled = TSIL.SaveManager.GetPersistentVariable(JosephMod, "FaminesKilledPerFloor")
    if faminesKilled == {} then faminesKilled = 0 end
    faminesKilled = faminesKilled + 1
    TSIL.SaveManager.SetPersistentVariable(JosephMod, "FaminesKilledPerFloor", faminesKilled)

    if faminesKilled > PlayerManager.GetTotalTrinketMultiplier(earOfGrain) then return end

    local rng = famine:GetDropRNG()
    local item = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT
    if rng:RandomFloat() > 0.5 then
        item = CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES
    end
    Isaac.Spawn(5, 100, item, famine.Position, Vector.Zero, famine)

end
JosephMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, EarGrain.FamineDie, 63)