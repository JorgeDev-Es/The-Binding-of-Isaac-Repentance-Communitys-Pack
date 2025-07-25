local fireEffect = Isaac.GetEntityVariantByName("QUACOL Fire jet")

local function OnEff(_, effect)
    if effect.FrameCount == 1 then
        local data = effect:GetData()
        for key, enemy in ipairs(Isaac.FindInRadius(effect.Position, data.QUACOL_RANGE or 30, EntityPartition.ENEMY)) do
            if enemy:IsVulnerableEnemy() and enemy:CanShutDoors() then
                local damage = data.QUACOL_DAMAGE or effect.SpawnerEntity and effect.SpawnerEntity.Damage or 3.5
                enemy:AddBurn(EntityRef(effect), 43, damage)
                enemy:AddEntityFlags(data.QUACOL_EFLAGS or 0)
                enemy:TakeDamage(damage, (DamageFlag.DAMAGE_FIRE | DamageFlag.DAMAGE_POISON_BURN), EntityRef(data.QUACOL_SOURCE or effect), 0)
            end
        end

        if data.QUACOL_BLOCK then
            for key, projectile in ipairs(Isaac.FindInRadius(effect.Position, data.QUACOL_RANGE or 30, EntityPartition.BULLET)) do
                projectile:Remove()
            end
        end
    elseif effect.FrameCount > 20 then
        effect:Remove()
    end
end

QUACOL:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnEff, fireEffect)