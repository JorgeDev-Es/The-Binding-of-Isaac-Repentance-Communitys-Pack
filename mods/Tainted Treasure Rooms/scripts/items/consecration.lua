local mod = TaintedTreasure
local game = Game()

mod.CustomFireWaves = {}

mod.TearToBlood = {
    [TearVariant.BLUE] = TearVariant.BLOOD,
    [TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
    [TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
    [TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
    [TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
}

mod.BloodToTear = {
    [TearVariant.BLOOD] = TearVariant.BLUE,
    [TearVariant.CUPID_BLOOD] = TearVariant.CUPID_BLUE,
    [TearVariant.PUPULA_BLOOD] = TearVariant.PUPULA,
    [TearVariant.GODS_FLESH_BLOOD] = TearVariant.GODS_FLESH,
    [TearVariant.GLAUCOMA_BLOOD] = TearVariant.GLAUCOMA,
}

function mod:ConsecrationOnFireTear(player, tear)
    if mod:BasicRoll(player.Luck, 9, 0.5, player:GetCollectibleRNG(TaintedCollectibles.CONSECRATION)) then
        tear:GetData().TaintedFireWave = true
        tear.Color = mod.ColorConsecration
        mod:TryConvertToBloodTear(tear)
    end
end

function mod:TryConvertToBloodTear(tear)
    local new = mod.TearToBlood[tear.Variant]
    if new then
        tear:ChangeVariant(new)
    end
end

function mod:TryConvertToBlueTear(tear)
    local new = mod.BloodToTear[tear.Variant]
    if new then
        tear:ChangeVariant(new)
    end
end

function mod:DoConsecrationWave(player, position)
    if player and player:Exists() then
        local spawnpos = position
        if not game:GetRoom():IsPositionInRoom(spawnpos, 1) then
            spawnpos = Isaac.GetFreeNearPosition(spawnpos, 0)
        end
        for i = 90, 360, 90 do
            mod:SpawnCustomFireWave(spawnpos, i, 30, false, player.Damage * 2, player)
            --[[local firewave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIRE_WAVE, 0, spawnpos, Vector.Zero, player):ToEffect()
            firewave.Rotation = i
            firewave:SetDamageSource(EntityType.ENTITY_PLAYER)
            if player then --AGH IT DOESNT WORK
                firewave.CollisionDamage = player.Damage * 2
                firewave:GetData().TaintedFireWave = true
            end]]
        end
    end
end

function mod:SpawnCustomFireWave(position, angle, lifespan, canharmplayer, damage, source)
	local effect = TaintedEffects.PLAYER_FIRE_JET
    damage = damage or 10
	lifespan = lifespan or 30
	if not SFXManager():IsPlaying(SoundEffect.SOUND_FLAME_BURST) then
		SFXManager():Play(SoundEffect.SOUND_FLAME_BURST, 1)
	end
	if canharmplayer then
		effect = EffectVariant.FIRE_JET
	end
    table.insert(mod.CustomFireWaves, {["Position"] = position, ["Angle"] = angle, ["Lifespan"] = lifespan, ["Damage"] = damage, ["Effect"] = effect, ["Source"] = source})
end

function mod:CustomFireWaveUpdate(firewave)
    firewave.Scale = firewave.Scale or 1
    firewave.Timer = firewave.Timer or 0

    firewave.Timer = firewave.Timer + 1
	if firewave.Timer % 2 == 1 then
		local jet = Isaac.Spawn(EntityType.ENTITY_EFFECT, firewave.Effect, 0, firewave.Position, Vector.Zero, firewave.Source)
		jet.CollisionDamage = firewave.Damage
		jet.SpriteScale = Vector(firewave.Scale, firewave.Scale)
		
		firewave.Position = firewave.Position + Vector(30,0):Rotated(firewave.Angle)
		firewave.Scale = 1 - firewave.Timer/firewave.Lifespan
		if firewave.Scale <= 0.1 or game:GetRoom():GetGridCollisionAtPos(firewave.Position) >= GridCollisionClass.COLLISION_OBJECT then
			return false
		end
	end

    return true
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local data = effect:GetData()
	data.PtrBlacklist = data.PtrBlacklist or {}
	for i, entity in pairs(Isaac.FindInRadius(effect.Position, effect.Size)) do
		if entity:IsEnemy() and not data.PtrBlacklist[GetPtrHash(entity)] then
			data.PtrBlacklist[GetPtrHash(entity)] = true
			entity:TakeDamage(effect.CollisionDamage, DamageFlag.DAMAGE_FIRE, EntityRef(player) or EntityRef(effect.SpawnerEntity), 10)
		end
	end
	if effect:GetSprite():IsFinished() then
		effect:Remove()
	end
end, TaintedEffects.PLAYER_FIRE_JET)