local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--The name sweetpuss sucks btw

FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
    local sprite, d, rng = slot:GetSprite(), slot:GetData(), slot:GetDropRNG()
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})

    if not d.init then
        if slot.SubType == 10 then
            slot:Remove()
            return
        else
            d.state = "idle"
        end

        d.init = true
    end

    if d.state == "idle" then
        if not sprite:IsPlaying("IdleRandom") then
            mod:spritePlay(sprite, "Idle")
            if rng:RandomInt(120) == 1 then
                sprite:Play("IdleRandom", true)
            end
        end
    elseif d.state == "PayoutFossil" then
        if sprite:IsFinished("Pay_Fossil") then
            d.state = "TeleportAway"
        elseif sprite:IsEventTriggered("Pickup") then
            sfx:Play(mod.Sounds.SweetpussPickup, 1, 0, false, math.random(80,120)/100)
        elseif sprite:IsEventTriggered("Crush") then
            sfx:Play(mod.Sounds.SweetpussFossilmagicBuildup, 1, 0, false, 1)
        elseif sprite:IsEventTriggered("Reward") then
            sfx:Stop(mod.Sounds.SweetpussFossilmagicBuildup)
            sfx:Play(mod.Sounds.SweetpussFossilmagicPayout, 1, 0, false, 1)
            local crushedTrinky = data.CrushingTrinket
            for i = 1, 3 do
                mod.scheduleForUpdate(function()
                    FiendFolio.CrushRockTrinket(data.CrushingPlayer or Isaac.GetPlayer(), crushedTrinky, slot)
                end, i * 3)
            end
            
        else
            mod:spritePlay(sprite, "Pay_Fossil")
        end
    elseif d.state == "PayoutTrinket" then
        if sprite:IsFinished("Pay_Normal") then
            d.state = "TeleportAway"
        elseif sprite:IsEventTriggered("Pickup") then
            sfx:Play(mod.Sounds.SweetpussPickup, 1, 0, false, math.random(80,120)/100)
        elseif sprite:IsEventTriggered("Rummage") then
            sfx:Play(mod.Sounds.SweetpussRummage, 1, 0, false, math.random(80,120)/100)
        elseif sprite:IsEventTriggered("Reward") then
            sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0, false, 1)
            local trinky = Isaac.Spawn(5, 350, FiendFolio.GetGolemTrinket(nil, "Fossil", true), slot.Position + Vector(25, 0), nilvector, slot)
            for i = 1, 8 do
                trinky:Update()
            end
            
        else
            mod:spritePlay(sprite, "Pay_Normal")
        end
    elseif d.state == "TeleportAway" then
        if sprite:IsFinished("Teleport") then
            slot:Remove()
        elseif sprite:IsEventTriggered("Teleport") then
            sfx:Play(SoundEffect.SOUND_HELL_PORTAL1, 1, 0, false, 1)
        else
            mod:spritePlay(sprite, "Teleport")
        end
    end
    FiendFolio.OverrideExplosionHack(slot)
end, mod.FF.Sweetpuss.Var)

FiendFolio.onMachineTouch(mod.FF.Sweetpuss.Var, function(player, slot)
    local sprite, d = slot:GetSprite(), slot:GetData()
    local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
    
    if d.state == "idle" then
        local trinket = FiendFolio.GetMostRecentRockTrinket(player, true)
        if trinket > 0 then
            slot.SubType = 10
            data.CrushingTrinket = trinket
            data.CrushingPlayer = player
            player:TryRemoveTrinket(trinket)

            sfx:Play(SoundEffect.SOUND_SCAMPER, 1, 0, false, 1)

            sprite:ReplaceSpritesheet(5, Isaac.GetItemConfig():GetTrinket(trinket).GfxFileName)
            sprite:LoadGraphics()
            if FiendFolio.IsFossil(trinket) then
                d.state = "PayoutFossil"
            else
                d.state = "PayoutTrinket"
            end
        end
    end
end)