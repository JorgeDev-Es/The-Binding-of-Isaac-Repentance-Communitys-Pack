local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

mod.EnlightenedEnemies = {}
function mod:InitEnlightenedStatus(npc, data, didstatus, player)
	if didstatus then
    	table.insert(mod.EnlightenedEnemies, {npc, player})
	end
end

function mod:EnlightenedStatusLogic()
	if game:GetRoom():GetFrameCount() % 135 == 0 then
		local StillEnlightened = {}
		for i, entry in pairs(mod.EnlightenedEnemies) do
			local npc = entry[1]
			local data = npc:GetData()
			if npc:Exists() and data.TaintedStatus == "Enlightened" then
				table.insert(StillEnlightened, entry)
			end
		end
		for i, entry in pairs(StillEnlightened) do
			local npc = entry[1]
			local player = entry[2]
			local data = npc:GetData()
			data.TaintedStatusDuration = 0
			if player then
				npc:TakeDamage(math.max(3.5, player.Damage)*#StillEnlightened*1.3, 0, EntityRef(player), 10)
			else
				npc:TakeDamage(4.5*#StillEnlightened, 0, EntityRef(nil), 10)
			end
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, npc):ToEffect()
			effect:GetSprite():Load("gfx/293.000_ultragreedcoins.anm2")
			effect:GetSprite():Play("CrumbleNoDebris")
			effect:GetSprite():SetFrame(1)
			effect.SpriteScale = Vector(npc.Size/30,npc.Size/30)
			
		end
		if #StillEnlightened > 0 then
			sfx:Play(SoundEffect.SOUND_ANGEL_BEAM, 1)
		end
		mod.EnlightenedEnemies = {}
	end
end

function mod:BlueCanaryPlayerLogic(player, data)
	if player:HasCollectible(TaintedCollectibles.BLUE_CANARY) then
		if not data.TaintedCanaryLight or not data.TaintedCanaryLight:Exists() then
			data.TaintedCanaryLight = Isaac.Spawn(EntityType.ENTITY_EFFECT, TaintedEffects.CANARY_LIGHT, 0, player.Position, Vector.Zero, player):ToEffect()
			data.TaintedCanaryLight.DepthOffset = -1
		end
		local effect = data.TaintedCanaryLight
		local sprite = effect:GetSprite()
		effect:GetData().Player = effect:GetData().Player or player
		
		if not sprite:IsPlaying("Appear") then
			sprite:Play("Idle")
		end
		if sprite:IsPlaying("Idle") then
			sprite.PlaybackSpeed = (game:GetRoom():GetFrameCount() % 135)*0.01
		end
		
		for i, entity in pairs(Isaac.FindInRadius(player.Position, 140)) do
			local degree = math.abs(effect.SpriteRotation + 90 - ((entity.Position - player.Position):GetAngleDegrees() % 360)) % 360
			if entity:IsEnemy() and entity:GetData().TaintedStatus ~= "Enlightened" and degree < 30 then
				mod:ApplyCustomStatus(entity, "Enlightened", 500, player)
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
	local player = effect:GetData().Player
	if player then
		effect.Velocity = player.Position+player.Velocity*2 - effect.Position
		if player:GetMovementVector():Length() > 0 then
			effect.SpriteRotation = effect.SpriteRotation % 360
			effect.SpriteRotation = mod:LerpAngleDegrees(effect.SpriteRotation, player:GetMovementVector():GetAngleDegrees() - 90, 0.3)
		end
	end
end, TaintedEffects.CANARY_LIGHT)