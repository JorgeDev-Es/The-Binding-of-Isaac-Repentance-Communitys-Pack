local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

local radCircle = Sprite()
radCircle:Load("gfx/radcircle.anm2", true)
radCircle:Play("Idle", true)

local arrowSprite = Sprite()
arrowSprite:Load("gfx/radcircle.anm2", true)
arrowSprite:Play("Idle2", true)

local arrowAmount, arrowTable, knifePieceEasterEggRoll
function mod:resetKnifeEasterEgg()
    knifePieceEasterEggRoll = (math.random(1, 15) == 1)
    arrowAmount = math.random(10, 16)
    arrowTable = {}
    for i = 1, arrowAmount do
        arrowTable[i] = {
            Rotation = math.random(0, 360),
            RotationSpeed = math.random(8, 16),
            RotationFlipped = ((math.random(1, 2) == 1) and 1) or -1
        }
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.resetKnifeEasterEgg)
mod.resetKnifeEasterEgg(false)

function mod:knifePieceRender(pickup, offset)
    if pickup.SubType == CollectibleType.COLLECTIBLE_KNIFE_PIECE_1 and knifePieceEasterEggRoll then
        local frameCount = 20
        local sineBounce = math.sin((pickup:GetSprite():GetFrame() / frameCount) * math.pi)
        local positionOffset = Vector(0, 36 + (sineBounce * 2.5))
        local sineBounce2 = math.sin(radCircle.Rotation * (math.pi / 32))
        if MattPack.isNormalRender(true) then
            radCircle.Scale = Vector.One + (Vector.One * sineBounce2 * 0.1)
            radCircle:Render(Isaac.WorldToRenderPosition(pickup.Position - positionOffset) + offset)
            local differenceScale = 1 / 2
            for i = 1, arrowAmount do
                arrowSprite.Rotation = arrowTable[i].Rotation
                local sineBounce3 = math.sin(arrowTable[i].Rotation * (math.pi / 32))
                arrowSprite.Scale = Vector.One + (Vector(1 - (sineBounce3 * differenceScale), 1 + (sineBounce3 * (1 / differenceScale))) * 0.025)
                arrowSprite.Offset = (Vector.FromAngle(arrowSprite.Rotation - 90) * (50 + sineBounce3 * 8))
                arrowSprite:Render(Isaac.WorldToRenderPosition(pickup.Position - positionOffset) + offset)
            end
        end
        if not game:IsPaused() then
            radCircle.Rotation = radCircle.Rotation + .5
            for i = 1, arrowAmount do
                arrowTable[i].Rotation = arrowTable[i].Rotation + (.05 * (arrowTable[i].RotationSpeed / 2)) * arrowTable[i].RotationFlipped
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, mod.knifePieceRender, PickupVariant.PICKUP_COLLECTIBLE)

function mod:knifePieceReroll(pickup, previousType, previousVariant, subType)
    if knifePieceEasterEggRoll and (previousVariant == 100 and subType == CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) then
        sfx:Play(MattPack.Sounds.KnifeBoo, 1.5)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_MORPH, mod.knifePieceReroll)