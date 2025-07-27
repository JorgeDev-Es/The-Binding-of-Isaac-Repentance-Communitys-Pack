local mod = TaintedTreasure
local game = Game()

function mod:PoisonedDartPlayerLogic(player, data) 
	if player:HasCollectible(TaintedCollectibles.POISONED_DART) then
        for _, enemy in pairs(Isaac.FindInRadius(player.Position+player.Velocity:Resized(20), 30, EntityPartition.ENEMY)) do
            if enemy:IsEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and not enemy:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) and not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                enemy:SetColor(mod.ColorWeakness, player:GetCollectibleNum(TaintedCollectibles.POISONED_DART)*180, 1, false, false)
                enemy:GetData().WeaknessDebuffed = player:GetCollectibleNum(TaintedCollectibles.POISONED_DART)*180
				enemy:TakeDamage(2, 0, EntityRef(player), 8)
				enemy.Velocity = enemy.Velocity + (enemy.Position - player.Position):Resized(15)
                enemy:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
				local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, enemy.Position, Vector.Zero, player):ToEffect()
				blood:SetColor(mod.ColorWeakness, -1, 1)
				blood.Size = 2
				
				local swipe = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.SWIPE, 0, player.Position+player.Velocity:Resized(20), Vector.Zero, player):ToEffect()
				swipe:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_bagofcrafting.png")
				swipe:GetSprite():LoadGraphics()
				swipe:GetSprite().PlaybackSpeed = 2
				swipe.SpriteRotation = (player.Position - enemy.Position):GetAngleDegrees() + 90
				swipe:SetColor(mod.ColorWeakness, -1, 1)
				
				SFXManager():Play(SoundEffect.SOUND_WHIP_HIT, 1, 2, false, 1.2)
            end
        end
    end
end

