local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local sprite = Sprite()
sprite:Load("gfx/ui/ui_crazyerrorslots.anm2")
sprite:Play("Idle", true)

local slotLeverSpeed = 15
local slotFadeSpeed = 30

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, itemRNG, player, useFlags, useSlot, varData)
    local data = player:GetData()
	local sdata = data.ffsavedata

    if useFlags == useFlags | UseFlag.USE_CARBATTERY then
        return false
    else
        local doRemove = false
        local showAnim = true

        if sdata.CrazyErrorSlot then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                for i = 1, 1 + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CAR_BATTERY) do --Book of Virtues gives Wisps each time a number is locked
                    player:AddWisp(mod.ITEM.COLLECTIBLE.ERRORS_CRAZY_SLOTS, player.Position, true, false)
                end
            end

            if sdata.CrazyErrorSlot == 3 then
                sdata.CrazyErrorData[sdata.CrazyErrorSlot] = sdata.CrazyErrorNum
                local itemID = (sdata.CrazyErrorData[1] * 100) + (sdata.CrazyErrorData[2] * 10) + sdata.CrazyErrorData[3]
                local item = Isaac.GetItemConfig():GetCollectible(itemID)
                if item and not item.Hidden then
                    player:AnimateCollectible(itemID, "Pickup", "PlayerPickupSparkle")
                    game:GetHUD():ShowItemText(player, item)
                    player:QueueItem(item, item.MaxCharges, false, false, 0)
                    if item.Type == ItemType.ITEM_PASSIVE then --Car Battery adds extra copies of Passive items
                        for i = 1, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CAR_BATTERY) do
                            player:AddCollectible(itemID)
                        end
                    end

                    if mod:playerIsBelialMode(player) then --Judas Birthright gives a permanent Damage up equal to the number rolled
                        sdata.CrazyErrorDamage = sdata.CrazyErrorDamage or 0
                        sdata.CrazyErrorDamage = sdata.CrazyErrorDamage + (itemID / 100)
                        sfx:Play(SoundEffect.SOUND_DEVIL_CARD)
                        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                        player:EvaluateItems()
                    end

                    sfx:Play(SoundEffect.SOUND_POWERUP1)
                    sfx:Play(mod.Sounds.PsionBubble)
                else --Send to the Error Room
                    game:StartRoomTransition(GridRooms.ROOM_ERROR_IDX, -1, RoomTransitionAnim.TELEPORT, player, -1)
                end
                sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_STOP)
                sfx:Stop(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP)
                sdata.CrazyErrorSlot = nil
                showAnim = false
                doRemove = true
            else
                sdata.CrazyErrorData[sdata.CrazyErrorSlot] = sdata.CrazyErrorNum
                sdata.CrazyErrorSlot = sdata.CrazyErrorSlot + 1
                sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_STOP)
            end
        else
            sdata.CrazyErrorData = {}
            sdata.CrazyErrorSlot = 1
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_PULL_SLOT)
            sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SLOT_SPIN_LOOP, 0.5, 0, true)
        end 

        sdata.CrazyErrorDuration = slotFadeSpeed
        sdata.CrazyErrorTimer = 0
        return {Discharge = false, Remove = doRemove, ShowAnim = showAnim}
    end
end, mod.ITEM.COLLECTIBLE.ERRORS_CRAZY_SLOTS)

function mod:CrazyErrorSlotRender(player)
    local data = player:GetData()
	local sdata = data.ffsavedata

    if mod:IsNormalRender(true) then
        if sdata.CrazyErrorSlot then
            sdata.CrazyErrorDuration = slotFadeSpeed
            sdata.CrazyErrorNum = sdata.CrazyErrorNum or 0 
            if sdata.CrazyErrorTimer then
                sdata.CrazyErrorTimer = sdata.CrazyErrorTimer + 1
                if sdata.CrazyErrorTimer > slotLeverSpeed then
                    sdata.CrazyErrorTimer = nil
                elseif sdata.CrazyErrorTimer > slotLeverSpeed - 3 then
                    sprite:SetLayerFrame(0, 1)
                else
                    sprite:SetLayerFrame(0, 2)
                end
            else
                sprite:SetLayerFrame(0, 0)
            end

            local interval = ((4 - sdata.CrazyErrorSlot) * 4) + 2
            --print(interval)
            if Isaac.GetFrameCount() % interval == 0 then
                sdata.CrazyErrorNum = sdata.CrazyErrorNum + 1
                if sdata.CrazyErrorNum > 9 then
                    sdata.CrazyErrorNum = 0
                end
            end

            for i = 1, 3 do
                if sdata.CrazyErrorData[i] then
                    sprite:SetLayerFrame(i, sdata.CrazyErrorData[i])
                else
                    sprite:SetLayerFrame(i, sdata.CrazyErrorNum)
                end
            end

            sprite.Color = Color.Default
        else
            sdata.CrazyErrorDuration = sdata.CrazyErrorDuration - 1
            sprite.Color = Color(1,1,1,(1/slotFadeSpeed)*sdata.CrazyErrorDuration)
            if sdata.CrazyErrorDuration <= 0 then
                sdata.CrazyErrorDuration = nil
            end
        end
        
        local pos = Isaac.WorldToRenderPosition(player.Position + Vector(4, -65 * player.SpriteScale.Y)) + game:GetRoom():GetRenderScrollOffset() --Taken from Crazy Jackpot
        sprite:Render(pos, nilvector, nilvector)
    end
end