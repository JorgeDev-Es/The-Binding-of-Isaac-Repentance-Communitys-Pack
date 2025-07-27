local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:psychicGaperAI(npc)
    local target = npc:GetPlayerTarget()

	npc.Color = Color(1,0,1,1)
	
    local targvel = (target.Position - npc.Position)
    local dist = targvel:Length()
    if dist < 1000 then
        npc.Velocity = mod:Lerp(npc.Velocity, targvel, 0.05)
    end
end

function mod:wallGaperAI(npc)
    local alignment = mod:GetClosestWall(npc.Position, true)
    local targetDirection = alignment[2]
    local d = npc:GetData()
    d.Direction = d.Direction or Vector(1, 0)
    d.Direction = mod:Lerp(d.Direction, Vector(1,0):Rotated(targetDirection * 90), 0.1)
    local rot = d.Direction:GetAngleDegrees()
    --print(npc:GetSprite().FlipX)
    if npc:GetSprite().FlipX then
        rot = d.Direction:GetAngleDegrees() * -1
    end
    npc.SpriteRotation = rot
end