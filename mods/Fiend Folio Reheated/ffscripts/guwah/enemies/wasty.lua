local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local function AnimWalkFrame(npc, sprite)
    if npc.Velocity:Length() < 0.5 then
        mod:spritePlay(sprite, "Idle")
    else
        npc:AnimWalkFrame("WalkHori", "WalkVert", 0)
    end
end

function mod:WastyAI(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        npc.SplatColor = mod.ColorBrowniePoop
        data.PathLerp = 0.85
        data.Init = true
    end

    local isSlippin
    for _, creep in pairs(Isaac.FindByType(1000,94)) do
        creep = creep:ToEffect()
        if creep.State == 1 and creep.Position:Distance(npc.Position) <= creep.Size + npc.Size and creep.FrameCount > 15 then
            isSlippin = true
        end
    end

    data.UseFFPlayerMap = true

    if data.Path then
        if isSlippin then
            data.PathLerp = 0.05
            if mod:isScare(npc) then
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(10), data.PathLerp)
            else
                FiendFolio.FollowPath(npc, 10.5, data.Path, true, data.PathLerp, 500, true)
            end
        else
            if data.PathLerp < 0.2 then
                data.PathLerp = data.PathLerp + 0.005
            end
            if mod:isScare(npc) then
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(4), data.PathLerp)
            else
                FiendFolio.FollowPath(npc, 4, data.Path, true, data.PathLerp, 500, true)
            end
        end
    end

    mod.QuickSetEntityGridPath(npc)
    AnimWalkFrame(npc, sprite)

    if npc.FrameCount % 8 == 4 then
        local creep = Isaac.Spawn(1000,94,0,npc.Position - npc.Velocity,Vector.Zero,npc):ToEffect()
        creep:SetTimeout(200)
        creep:Update()
    end

    if isSlippin and npc.Velocity:Length() > 4 and npc.FrameCount % 4 == 0 then
        local effect = Isaac.Spawn(1000,2,1,npc.Position,npc.Velocity * -1,npc):ToEffect()
        effect.Color = mod.ColorBrowniePoop
        sfx:Play(mod.Sounds.SplashSmall)
    end

    if npc:IsDead() then
        local creep = Isaac.Spawn(1000,94,0,npc.Position,Vector.Zero,npc):ToEffect()
        creep.SpriteScale = Vector(3,3)
        creep:SetTimeout(300)
        creep:Update()
    end
end