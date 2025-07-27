local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local suffixes = {"L", "U", "R", "D"}
local inputs = {ButtonAction.ACTION_SHOOTLEFT, ButtonAction.ACTION_SHOOTUP, ButtonAction.ACTION_SHOOTRIGHT, ButtonAction.ACTION_SHOOTDOWN}

function mod:DPadPlayerLogic(player, data, savedata)
    if player:HasCollectible(TaintedCollectibles.D_PAD) then
        savedata.DPadTimer = savedata.DPadTimer or 240
        if mod:IsRoomInCombat() and not data.DPadVisible then
            savedata.DPadTimer = savedata.DPadTimer - 1
            if savedata.DPadTimer <= 0 then
                data.DPadIcon:Play("Appear")
                data.DPadVisible = true
                savedata.DPadTimer = 240
            end
        end
    end

    if savedata.DPadDamage then
        savedata.DPadDamage = savedata.DPadDamage - (0.01 * player:GetCollectibleNum(TaintedCollectibles.D_PAD))
        if savedata.DPadDamage <= 0 then
            savedata.DPadDamage = nil
        end
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end

    if data.DPadIcon then
        data.DPadIcon:Update()
    end
end

function mod:DPadInputLogic(player, data, savedata)
    if data.DPadPrompt then
        local ret
        for _, action in pairs(inputs) do
            if Input.IsActionTriggered(action, player.ControllerIndex) then
                if action == data.DPadPrompt then 
                    ret = "Win"
                elseif ret ~= "Win" then
                    ret = "Fail"
                end
            end
        end
        if ret then
            if ret == "Win" then
                savedata.DPadDamage = savedata.DPadDamage or 0
                savedata.DPadDamage = savedata.DPadDamage + (3.5 * player:GetCollectibleNum(TaintedCollectibles.D_PAD))
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
                sfx:Play(TaintedSounds.DPAD_WIN, 6)
            elseif ret == "Fail" then
                sfx:Play(TaintedSounds.DPAD_FAIL, 5)
            end
            data.DPadIcon:Play(ret.."_"..data.DPadSuffix)
            data.DPadPrompt = nil
        end
    end
end

function mod:DPadIconRender(player, data)
    if not data.DPadIcon then
        local sprite = Sprite()
        sprite:Load("gfx/ui/ui_dpadprompt.anm2", true)
        data.DPadIcon = sprite
    end

    if data.DPadVisible  then
        local icon = data.DPadIcon

        if mod:IsNormalRender() then
            if icon:IsFinished("Appear") then
                data.DPadIconTimer = 240
                icon:Play("Idle")
            elseif icon:IsFinished("Warn") then
                icon:Play("Idle")
            elseif data.DPadSuffix then
                if icon:IsFinished("Reveal_"..data.DPadSuffix) then
                    data.DPadIconTimer = 40
                    icon:Play("Idle_"..data.DPadSuffix)
                elseif icon:IsFinished("Fail_"..data.DPadSuffix) or icon:IsFinished("Win_"..data.DPadSuffix) then
                    data.DPadVisible = false
                end
            end
        
            if icon:IsPlaying("Idle") or icon:IsPlaying("Warn") then
                data.DPadIconTimer = data.DPadIconTimer - 1
                if data.DPadIconTimer <= 0 then
                    local i = mod:RandomInt(1,4,player:GetCollectibleRNG(TaintedCollectibles.D_PAD))
                    data.DPadSuffix = suffixes[i]
                    data.DPadPrompt = inputs[i]
                    icon:Play("Reveal_"..data.DPadSuffix)
                    sfx:Play(TaintedSounds.DPAD_BEEP2, 2)
                elseif data.DPadIconTimer < 120 and data.DPadIconTimer % 30 == 0 then
                    icon:Play("Warn")
                    sfx:Play(TaintedSounds.DPAD_BEEP)
                end
            elseif data.DPadSuffix and icon:IsPlaying("Idle_"..data.DPadSuffix) then
                data.DPadIconTimer = data.DPadIconTimer - 1
                if data.DPadIconTimer <= 0 then
                    sfx:Play(TaintedSounds.DPAD_FAIL, 5)
                    icon:Play("Fail_"..data.DPadSuffix)
                    data.DPadPrompt = nil 
                end
            end
        end

        local offset = Vector(-18 * player.SpriteScale.X, -55 * player.SpriteScale.Y)
        icon:Render(Isaac.WorldToScreen(player.Position + offset))
    end
end

function mod:IsRoomInCombat() --Checks for room clear AND all doors being closed
    local room = game:GetRoom()
    if not room:IsClear() then
        return true
    else
        for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
            local door = room:GetDoor(i) 
            if door and door:IsOpen() then
                return false
            end
        end
        return true
    end
end