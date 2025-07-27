local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

function mod:ApplyPoopKnockback(npc, velocity, extraDMG, source, flags)
    local data = npc:GetData()
    if npc:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) 
    or (data.ForcedKnockbackTimer and data.ForcedKnockbackTimer > 0) then --If they cant be knocked back, they take extra damage
        extraDMG = extraDMG or 3.5
        flags = flags or 0
        npc:TakeDamage(extraDMG, flags | DamageFlag.DAMAGE_CLONES, EntityRef(source), 0)
    else
        velocity = velocity or RandomVector()
        if velocity:Length() < 20 then
            velocity:Resize(20)
        end
        data.ForcedKnockbackTimer = 15
        data.ForcedKnockbackVel = velocity
        data.SaltOfMagnesiumPoopTimer = 0
        npc.Velocity = velocity
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
    end
    Isaac.Spawn(1000,43,0,npc.Position,Vector.Zero,npc)
    sfx:Play(TaintedSounds.FART_BLAST)
end

function mod:ForcedKnockbackEnemyLogic(npc, data)
    data.ImpactDamageCooldown = data.ImpactDamageCooldown or 0
    data.ImpactDamageCooldown = data.ImpactDamageCooldown - 1

    if data.ForcedKnockbackTimer and data.ForcedKnockbackTimer > 0 then
        if npc:CollidesWithGrid() or game:GetRoom():GetGridIndex(npc.Position) == -1 then --If you hit a grid or the gridindex is outside the room, end the knockback
            data.ForcedKnockbackTimer = 0
            data.SaltOfMagnesiumPoopTimer = nil
            if data.ForcedKnockbackImpactDamage then
                npc:TakeDamage(10 + (2 * game:GetLevel():GetStage()), 0, EntityRef(nil), 0) --Damage formula from Knockout Drops
                data.ForcedKnockbackImpactDamage = nil
            end
            npc:ClearEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
        else
            if data.SaltOfMagnesiumPoopTimer then
                data.SaltOfMagnesiumPoopTimer = data.SaltOfMagnesiumPoopTimer - 1
                if data.SaltOfMagnesiumPoopTimer <= 0 then
                    local poop = Isaac.GridSpawn(GridEntityType.GRID_POOP, 0, npc.Position, false)
                    if poop then --Poopage successful 
                        sfx:Play(SoundEffect.SOUND_FART)
                        data.SaltOfMagnesiumPoopTimer = 5
                    end
                end
                if npc.FrameCount % 2 == 0 then
                    Isaac.Spawn(1000, 58, 0, npc.Position, data.ForcedKnockbackVel:Rotated(mod:RandomInt(160,200)):Resized(mod:RandomInt(3,5)), npc)
                end
            end
        end
        data.ForcedKnockbackTimer = data.ForcedKnockbackTimer - 1
        npc:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK) --Gotta set the flag every update
        npc.Velocity = data.ForcedKnockbackVel
    end
end

function mod:SaltOfMagnesiumOnFireTear(player, tear)
    if mod:BasicRoll(player.Luck, 9, 0.5, player:GetCollectibleRNG(TaintedCollectibles.SALT_OF_MAGNESIUM)) then
        if not player:HasWeaponType(WeaponType.WEAPON_FETUS) then
			tear:ChangeVariant(TearVariant.ROCK)
		end
	    tear.Color = mod.ColorSaltOfMagnesium
        tear:GetData().TaintedPoopBlast = true
    end
end
