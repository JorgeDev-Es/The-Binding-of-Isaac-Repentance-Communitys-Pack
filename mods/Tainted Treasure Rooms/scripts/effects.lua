local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local sprite = effect:GetSprite()
	local player = effect.SpawnerEntity
	
	if player then
		effect.Position = player.Position + player.Velocity
	end
	mod:spritePlay(sprite, "flash")
	if effect.SubType == 0 then
		effect.DepthOffset = 1000
	end
	if sprite:IsFinished("flash") then
		effect:Remove()
	end
	game:ShakeScreen(1)
	if sprite:IsEventTriggered("Teleport") then
		Isaac.ExecuteCommand("stage 13")
		mod:scheduleForUpdate(function()
			local crackedkey = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, player.Position, Vector.Zero, player)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, game:GetItemPool():GetCollectible(mod:RandomInt(ItemPoolType.POOL_TREASURE, ItemPoolType.POOL_KEY_MASTER), true), Isaac.GetFreeNearPosition(player.Position, 50), Vector.Zero, player)
			for i = 0, 20 do
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 2, Isaac.GetFreeNearPosition(player.Position, 10), Vector.Zero, player)
			end
			crackedkey.Position = Vector(440, 150)
		end, 10)
	end
end, TaintedEffects.FADE_IN)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local sprite = effect:GetSprite()
	local player = effect.SpawnerEntity
	
	mod:spritePlay(sprite, "Swing")
	
	if sprite:IsFinished("Swing") then
		effect:Remove()
	end
end, TaintedEffects.SWIPE)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local sprite = effect:GetSprite()
	local player = effect.SpawnerEntity
	local data = effect:GetData()
	
	if not data.TaintedIsFalling then
		if not sprite:IsPlaying() then
			local ran = mod:RandomInt(1, 3)
			if ran > 1 then
				mod:spritePlay(sprite, "Idle"..ran)
			else
				mod:spritePlay(sprite, "Idle")
			end
		end
	end
	
	if data.TaintedTargetEnemy and data.TaintedTargetEnemyHP then
		local enemy = data.TaintedTargetEnemy
		effect.Velocity = effect.Velocity+(enemy.Position-effect.Position)
		if enemy.HitPoints < data.TaintedTargetEnemyHP then
			mod:spritePlay(sprite, "Fall")
			data.TaintedIsFalling = true
		end
		if sprite:IsEventTriggered("Hit") then
			if enemy:IsBoss() then
				local source = effect
				if player:Exists() then 
					source = player 
				end
	
				enemy:TakeDamage(80, 0, EntityRef(source), 1)
				effect:Remove()
			else
				enemy:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
				enemy:Kill()
				if enemy:Exists() then
					enemy:Remove()
				end
			end
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
		end
	end
end, TaintedEffects.DIONYSIUS)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
	local data = effect:GetData()
	if data.TaintedTargetEnemy and data.TaintedTargetEnemyHP then
		local enemy = data.TaintedTargetEnemy
		effect.Position = enemy.Position
	end
end, TaintedEffects.DIONYSIUS)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	local sprite = effect:GetSprite()
	local player = effect.SpawnerEntity
	local data = effect:GetData()
	
	local closestenemy = false
	for i, entity in pairs(Isaac.FindInRadius(effect.Position, 1000)) do
		if not closestenemy and entity:IsEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and not entity:IsInvincible() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			closestenemy = entity
		elseif closestenemy and entity:IsEnemy() and entity.Position:Distance(effect.Position) < closestenemy.Position:Distance(effect.Position) and entity.Type ~= EntityType.ENTITY_FIREPLACE and not entity:IsInvincible() then
			closestenemy = entity
		end
	end
	if closestenemy then 
		data.TaintedTargetEnemy = closestenemy
		data.TaintedTargetEnemyHP = closestenemy.HitPoints
		data.TaintedIsFalling = false
		effect.Position = closestenemy.Position
	else
		effect:Remove()
	end
end, TaintedEffects.DIONYSIUS)

--Originally used for Polycoria
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local room = game:GetRoom()
	local data = effect:GetData()
	local dotearsexist = false
    if data.corpseClusters then
        if room:GetGridCollisionAtPos(effect.Position) >= GridCollisionClass.COLLISION_SOLID then
            for _, tear in pairs(data.corpseClusters) do
                tear.Velocity = effect.Velocity:Rotated(180 + mod:RandomInt(-60,60))*1.5
            end
            SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
            effect:Remove()
        end
    end
	for _, tear in pairs(data.corpseClusters) do
        if tear:Exists() then
			dotearsexist = true
		end
    end
	if not dotearsexist then
		effect:Remove()
	end
end, TaintedEffects.DUMMY)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	local sprite = effect:GetSprite()
	
	mod:spritePlay(sprite, "flash"..mod:RandomInt(1,3))
	
end, TaintedEffects.SPARKLE)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local sprite = effect:GetSprite()
	
	if sprite:IsFinished() then
		effect:Remove()
	end
end, TaintedEffects.SPARKLE)

--[[mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local sprite = effect:GetSprite()
	
	if sprite:IsFinished() then
		effect:Remove()
	end
end, TaintedEffects.EFFECT_CIRCLE_FLASH)]]

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local sprite = effect:GetSprite()
	local data = effect:GetData()
	
	if effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer() then
		local player = effect.SpawnerEntity:ToPlayer()
		
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
			if player:GetFireDirection() ~= -1 then
				effect.Velocity = player:GetAimDirection():Resized(10)
			else
				effect.Velocity = effect.Velocity/2
			end
			if Options.MouseControl and Input.IsMouseBtnPressed(0) then
				local pos = Input.GetMousePosition(true)
				if effect.Position:Distance(pos) > 20 then
					effect.Velocity = (pos - effect.Position):Resized(15)
				else
					effect.Velocity = pos - effect.Position
					effect.Position = mod:Lerp(effect.Position, pos, 0.1)
				end
			end
		else
			for i, entity in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET)) do
				if entity.SpawnerEntity.InitSeed == player.InitSeed then
					if entity.Position:Distance(effect.Position) > 20 then
						effect.Velocity = (entity.Position - effect.Position):Resized(15)
					else
						effect.Velocity = entity.Position - effect.Position
						effect.Position = mod:Lerp(effect.Position, entity.Position, 0.1)
						effect.DepthOffset = 10
					end
				end
			end
		end
		
		if not sprite:IsPlaying("Rocket") then
			mod:spritePlay(sprite, "Blink")
			sprite.PlaybackSpeed = effect.FrameCount/100
		end
		
		if effect.FrameCount >= 100 then
			effect.Color = Color.Default
			mod:spritePlay(sprite, "Rocket")
		end
		
		if sprite:IsEventTriggered("Explode") then
			local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, 0, effect.Position, Vector.Zero, player):ToBomb()
			local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, effect.Position, Vector.Zero, player):ToEffect()
			local color = bomb.Color
			bomb:SetColor(Color(color.R,color.G,color.B,0,color.RO,color.GO,color.BO),-1,1,true,false)
			bomb:SetExplosionCountdown(0)
			bomb.Flags = player:GetBombFlags()
			if data.TaintedGigaATG then
				bomb:AddTearFlags(TearFlags.TEAR_GIGA_BOMB)
			end
			bomb.ExplosionDamage = data.TaintedATGDamage 
			bomb.RadiusMultiplier = data.TaintedATGRadius
			effect:Remove()
		end
	end
end, TaintedEffects.ATG_TARGET)