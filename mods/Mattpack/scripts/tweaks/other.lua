local mod = MattPack

Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_BLACK_BEAN).Description = "I think we know my answer."

mod.updateRainbow(1)

function mod:godheadRainbow(tear)
    if tear:HasTearFlags(TearFlags.TEAR_GLOW) then
        local player = tear.SpawnerEntity and (tear.SpawnerEntity:ToPlayer() or (tear.SpawnerEntity.SpawnerEntity and tear.SpawnerEntity.SpawnerEntity:ToPlayer()))
        if player and player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) and mod.isNormalRender() then
            mod.UpdateRainbow = true
            local haloSprite = tear:GetTearHaloSprite()
            haloSprite.Color.A = 1/3
            haloSprite.Color:SetColorize(mod.rainbowColor.R, mod.rainbowColor.G, mod.rainbowColor.B, 1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, mod.godheadRainbow)

function mod:godheadRainbowUpdate()
    if mod.UpdateRainbow then
        mod.updateRainbow(2)
        mod.UpdateRainbow = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.godheadRainbowUpdate)


mod.doubleSizeItems = { -- renderOffset, holdOffset, EIDOffset
    -- Items listed here must have two sprites in their folder, one that's YourCollectible_hud.png and YourCollectible.png
    -- The one ending in _hud is there for the extra hud, the other one is the one that will be actually displayed on pedestals 
    [MattPack.Items.DivineHeart] = {Vector(0, 32), Vector(5, 28)}
}


local function renderOverSprite(ent, sprite, spriteData, posOffset, scaleOffset)
    local itemLayer = sprite:GetLayer("head")
    local spritePath = itemLayer:GetSpritesheetPath()
    if spritePath:sub(-16, -1) ~= "questionmark.png" then
        local offset = spriteData[1] + sprite.Offset + (posOffset or Vector.Zero)
        local data = ent:GetData()
        local renderSprite = data.replacementSprite
        if not renderSprite then
            renderSprite = Sprite()
            renderSprite:Load("gfx/collectible_64x64.anm2", true)
            renderSprite:Play("Idle")
            renderSprite.PlaybackSpeed = sprite.PlaybackSpeed
            data.replacementSprite = renderSprite
            renderSprite:ReplaceSpritesheet(1, spritePath:sub(1, -9) .. ".png", true)
        end
        local itemFrame = sprite:GetCurrentAnimationData():GetLayer(1):GetFrame(sprite:GetFrame() - 1)
        if itemFrame then
            if sprite:GetFrame() ~= data.lastFrame then
                renderSprite:GetLayer(1):SetSize(itemFrame:GetScale() * (scaleOffset or 1))
            end
            data.lastFrame = sprite:GetFrame()
            renderSprite:Render(Isaac.WorldToScreen(ent.Position + itemFrame:GetPos() + ent:GetNullOffset("ItemOffset") + offset))
        end
        itemLayer:SetColor(Color(1,1,1,0))
    end

end

function mod:biggerItemPedestals(ent)
    local spriteData = mod.doubleSizeItems[ent.SubType]
    if spriteData then
        local sprite = ent:GetSprite()
        renderOverSprite(ent, sprite, spriteData)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, mod.biggerItemPedestals, 100)


mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function(mod, ent)
    if mod.doubleSizeItems[ent.SubType] then
        ent:GetData().lastSubType = ent.SubType
    end
end, 100)
function mod:replaceItemAnim(pickup, col)
    if pickup.SubType == 0 then
        local player = col:ToPlayer()
        if player then
            local data = pickup:GetData()
            local renderData = data.lastSubType and mod.doubleSizeItems[data.lastSubType]
            if renderData then
                if player:IsHoldingItem() then
                    local itemLayer = player:GetHeldSprite():GetLayer(1)
                    local renderSprite = Sprite()
                    renderSprite:Load("gfx/collectible_64x64.anm2", true)
                    renderSprite:Play("PlayerPickup", true)
                    renderSprite:ReplaceSpritesheet(1, itemLayer:GetSpritesheetPath():sub(1, -9) .. ".png", true)

                    player:AnimatePickup(renderSprite, false)
                end
            end
            data.lastSubType = nil
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, CallbackPriority.LATE, mod.replaceItemAnim, 100)

if EID then
    for item,data in pairs(mod.doubleSizeItems) do
        local offset = data[2] or Vector(0, 32)
        local cfg = Isaac.GetItemConfig():GetCollectible(item)
        local icon64 = Sprite()
        icon64:Load("gfx/collectible_64x64.anm2", true)
        icon64:Play("Idle")
        icon64:ReplaceSpritesheet(1, cfg.GfxFileName:sub(1, -9) .. ".png", true)
        icon64:GetLayer(1):SetSize(Vector.One * (1/2))
        EID:addIcon("64x64" .. item, "Idle", 0, 32, 32, offset.X, offset.Y, icon64)
        EID.InlineIcons["64x64" .. item][7].Scale = Vector.One * .5
        EID:addDescriptionModifier(item .. "64x64", 
        function(objectDescription)
            if objectDescription.ObjType == 5 
            and objectDescription.ObjVariant == 100 
            and objectDescription.ObjSubType == MattPack.Items.DivineHeart then
                return true
            end
        end, 
        function(descObject)
            descObject.Icon = EID.InlineIcons["64x64" .. item]
            return descObject
        end)
    end
end
