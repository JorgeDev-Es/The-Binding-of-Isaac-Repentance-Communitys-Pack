local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

function mod:MakeTearSpectral(tear, noColor)
    local color = tear.Color
    tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    if noColor then
        tear.Color = color
    end
end

function mod:ArrowheadOnFireTear(player, tear)
    mod:MakeTearSpectral(tear, true)
	local color = tear.Color
    tear:SetColor(Color(color.R,color.G,color.B,0,color.RO,color.GO,color.BO),4,1,true,false)
    if tear.ContinueVelocity:Length() > 0 then --Anti-Gravity
        tear.Position = tear.Position + Vector(80,0):Rotated(mod:GetAimDirectionGood(player):GetAngleDegrees())
        tear.ContinueVelocity = tear.ContinueVelocity * -1
    else
        tear.Position = tear.Position + Vector(80,0):Rotated(tear.Velocity:GetAngleDegrees())
        tear.Velocity = tear.Velocity * -1
    end
    tear:GetData().TaintedArrowhead = true
end

function mod:ArrowheadTearUpdate(tear, data)
    if tear:HasTearFlags(TearFlags.TEAR_ORBIT_ADVANCED) and not data.ImmaculateFix then --Idfk why i have to do this
        local color = tear.Color
        tear.Color = Color(color.R,color.G,color.B,1,color.RO,color.GO,color.BO)
        tear:SetColor(Color(color.R,color.G,color.B,0,color.RO,color.GO,color.BO),4,1,true,false)
        data.ImmaculateFix = true
    end
    if tear.SpawnerEntity and not data.ArrowheadBuffed then
        if tear.SpawnerEntity.Position:Distance(tear.Position) < tear.Size + tear.SpawnerEntity.Size then
            mod:CheckTearVariant(tear, TearVariant.CUPID_BLOOD)
            tear:AddTearFlags(TearFlags.TEAR_PIERCING)
            tear.Velocity = tear.Velocity * 1.2
            tear.CollisionDamage = tear.CollisionDamage * 1.5
            tear.Scale = tear.Scale + 0.2
            data.ArrowheadBuffed = true
            for i = 1, mod:RandomInt(1,2) do
                Isaac.Spawn(1000,5,0,tear.SpawnerEntity.Position,tear.Velocity:Rotated(mod:RandomInt(-45,45)) * 0.8,tear)
            end
            sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.5, 0, false, 1.5)
        end
    end
end

function mod:ArrowheadOnFireBomb(bomb, data)
    bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    bomb.Position = bomb.Position + Vector(80,0):Rotated(bomb.Velocity:GetAngleDegrees())
    bomb.Velocity = bomb.Velocity * -1
    local color = bomb.Color
    bomb:SetColor(Color(color.R,color.G,color.B,0,color.RO,color.GO,color.BO),4,1,true,false)
    data.TaintedArrowhead = true
end

function mod:ArrowheadBombUpdate(bomb, data)
    bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    if bomb.SpawnerEntity and not data.ArrowheadBuffed then
        if bomb.SpawnerEntity.Position:Distance(bomb.Position) < bomb.Size + bomb.SpawnerEntity.Size then
            bomb.Velocity = bomb.Velocity * 1.2
            bomb.ExplosionDamage = bomb.ExplosionDamage * 1.5
            data.ArrowheadBuffed = true
            for i = 1, mod:RandomInt(1,2) do
                Isaac.Spawn(1000,5,0,bomb.SpawnerEntity.Position,bomb.Velocity:Rotated(mod:RandomInt(-45,45)) * 0.8,bomb)
            end
            sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.5, 0, false, 1.5)
        end
        return true
    end
end