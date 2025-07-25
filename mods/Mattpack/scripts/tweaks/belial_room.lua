local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

local function belialPuff(player)
    for i = 1, 25 do
        local startPos = player.Position + Vector(0, -math.random(50, 300) / 10)
        local startVel = Vector(0, math.random(-20, -5)) + RandomVector():Resized(math.random(0, 100) / 10)
        local dust = Isaac.Spawn(1000, 59, 0, startPos, startVel, nil):ToEffect()
        dust.State = 0
        dust.Timeout = 15
        dust.LifeSpan = 25
        dust.Rotation = math.random(0, 100) / 10
        dust.SpriteScale = dust.SpriteScale * math.random(90, 110) / 100
        -- dust.DepthOffset = -120
        dust.FlipX = math.random(0,1) == 1
        local color = Color(2,.75,.5,2.5,1)
        dust.Color = color
    end
    local puffColor = Color(.2, .2, .2, .6)
    local puffBG = Isaac.Spawn(1000, 16, 1, player.Position, Vector.Zero, nil)
    local puffFG = Isaac.Spawn(1000, 16, 2, player.Position, Vector.Zero, nil)
    puffBG.Color = puffColor
    puffFG.Color = puffColor
    local doFlip = math.random(0,1) == 1
    puffBG.FlipX = doFlip
    puffFG.FlipX = doFlip
    sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT)
end

function mod:useBelial(type, _, player)
    if type == CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL then
        local playerData = player:GetData()
        if not playerData.passiveBelial then
            local curDesc = game:GetLevel():GetCurrentRoomDesc()
            local data = curDesc and curDesc.Data
            if (data.StageID == 1 or data.StageID == 3) and data.Variant == 141 then
                sfx:Play(MattPack.Sounds.ThePact)
                belialPuff(player)
                if player:GetPlayerType() == PlayerType.PLAYER_JUDAS then
                    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, 1)
                    player:FullCharge(0)
                    return {Remove = true}
                else
                    player:GetData().passiveBelial = true
                    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE, 1)
                    Isaac.CreateTimer(function() player:FullCharge(0) end, 1, 1)
                    return {Remove = true}
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useBelial, CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL)

function mod:useBelial2(_, _, player)
    if player:GetData().passiveBelial then
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE, 1)
        end   
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.useBelial2)

local belialBGSprite = Sprite()
belialBGSprite:Load("gfx/belialbg.anm2")
belialBGSprite:Play("Idle")
function mod:displayBelial(player, slot, offset)
    if player:GetData().passiveBelial and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL then
        if slot == 0 then
            belialBGSprite.Color = Color(0,0,0,1,1,1,1)
            if player:GetActiveCharge() >= player:GetActiveMinUsableCharge() then
                for i = 0, 3 do
                    belialBGSprite:Render(offset + Vector(0,5) + Vector(0,1):Rotated(90 * i))
                end
            end
            belialBGSprite.Color = Color(1,1,1,1)
            belialBGSprite:Render(offset + Vector(0, 5))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, mod.displayBelial)