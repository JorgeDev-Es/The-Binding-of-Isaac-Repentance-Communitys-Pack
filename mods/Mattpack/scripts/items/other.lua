local mod = MattPack
-- local game = mod.constants.game
local sfx = mod.constants.sfx

function mod:q5Switch(ent)
    if MattPack.isNormalRender() then
        local data = ent:GetData()
        if data.q5Fade and data.q5TargetId then
            ent.Wait = 1
            local targetColor = data.targetColor
            if not targetColor then
                targetColor = ent.Color
                targetColor.RO = 1
                targetColor.GO = 1
                targetColor.BO = 1
            end
            data.q5Fade = data.q5Fade + .0003
            ent.Color = Color.Lerp(ent.Color, targetColor, data.q5Fade)
            if data.q5Fade >= .05 then 
                ent.Color = Color(1,1,1,1)
                if data.q5TargetFunc then
                    data.q5TargetFunc(ent)
                    data.q5TargetFunc = nil
                end
                ent:Morph(ent.Type, ent.Variant, data.q5TargetId, true)
                mod.constants.pool:RemoveCollectible(data.q5TargetId)
                ent:RemoveCollectibleCycle ()
                data.q5TargetId = nil
                data.q5Fade = nil
                if Epic then
                    Epic.OnRoomUpdate()
                end
                sfx:Stop(128)
                sfx:Stop(129) 
            end
            local percent = ((data.q5Fade or 0) / .05)
            if data.q5RenderFunc then
                data.q5RenderFunc(ent, percent)
            end
            local itemLayer = ent:GetSprite():GetLayer(1)
            if data.q5TargetScale then
                itemLayer:SetSize(Vector.One * ((percent * data.q5TargetScale) + 1))
            end
            if data.q5TargetOffset then
                itemLayer:SetPos(itemLayer:GetPos() + data.q5TargetOffset)
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, CallbackPriority.LATE, mod.q5Switch, 100)

function mod:useFKey(type, _, player)
    if type == Isaac.GetItemIdByName("F Key") then
        Options.Fullscreen = not Options.Fullscreen
        player:AnimateCollectible(Isaac.GetItemIdByName("F Key"))
        return {Remove = true}
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useFKey, Isaac.GetItemIdByName("F Key"))

function mod:playSound(ent, col)
    local sfxFunc = mod.pickupSounds[ent.SubType]
    if sfxFunc and ent.Wait <= 0 then
        local player = col:ToPlayer()
        if player and player:CanPickupItem() and not player:IsHoldingItem() then
            sfxFunc()
            sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 0)
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, mod.playSound, 100)