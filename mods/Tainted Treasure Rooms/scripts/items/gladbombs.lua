local mod = TaintedTreasure
local game = Game()

function mod:GetBombFuseTimer(player, timer)
    timer = timer or 45
    if player:HasTrinket(TrinketType.TRINKET_FIRECRACKER) then
        timer = timer * 0.44
    end
    return math.floor(timer)
end

function mod:GladBombUpdate(bomb, player, data, sprite)
    if not data.GladBombInit then
        local anim = sprite:GetAnimation()
        sprite:Load("gfx/items/pick ups/bomb_gladbombs.anm2", true)
        sprite:Play(anim, true)
        bomb:SetExplosionCountdown(mod:GetBombFuseTimer(player, 90))
        data.GladBombInit = true
    end
    if math.floor(bomb.FrameCount / (player.MaxFireDelay/2)) ~= math.floor((bomb.FrameCount - 1) / (player.MaxFireDelay/2)) then
        local closestenemy = nil
        local dist = 9999
        for _, entity in pairs(Isaac.FindInRadius(bomb.Position, 1000)) do
            if entity:IsEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
                if bomb.Position:Distance(entity.Position) < dist then
                    closestenemy = entity
                    dist = bomb.Position:Distance(entity.Position)
                end
            end
        end
        if closestenemy then
            local tear = player:FireTear(bomb.Position+Vector(3, 8), (closestenemy.Position-bomb.Position):Normalized()*player.ShotSpeed*10+Vector(mod:RandomInt(-1, 1), mod:RandomInt(-1, 1)), true, true, false, player, 1.5)
            tear:GetData().TaintedIsGladBombTear = true
            tear.Mass = 0.001
        end
    end
end