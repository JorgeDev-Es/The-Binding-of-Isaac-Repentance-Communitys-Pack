local mod = TaintedTreasure
local game = Game()
local rng = RNG()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	local data = familiar:GetData()
	
	familiar:MoveDiagonally(0.6)
	
	if not data.TaintedAura or not data.TaintedAura:Exists() then
		data.TaintedAura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, familiar.Position, Vector.Zero, familiar):ToEffect()
		data.TaintedAura.Parent = familiar
		data.TaintedAura:FollowParent(familiar)
		data.TaintedAura.Color = Color(1, 0.1, 0.1, 1, 0.5, 0, 0)
		--data.TaintedAura.SpriteScale = data.TaintedAura.SpriteScale*1.25
		data.TaintedAura.DepthOffset = 100
	end
end, TaintedFamiliars.GLUTTON_BABY)

mod:AddCustomCallback("GAIN_COLLECTIBLE", function(_, player, collectibleType)
    if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE and player:GetMaxHearts() > 24 then
		player:AddMaxHearts(-2)
	end
end, TaintedCollectibles.CONTRACT_OF_SERVITUDE)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, damage, flags, source, countdown)
	if entity.Type == EntityType.ENTITY_PLAYER then
		local isgluttonbabyclose
		for i, familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, TaintedFamiliars.GLUTTON_BABY)) do
			if not isgluttonbabyclose then
				isgluttonbabyclose = familiar.Position:Distance(entity.Position) <= 80
			end
		end
		if isgluttonbabyclose and rng:RandomFloat() <= 0.8 then
			if source.Type ~= EntityType.ENTITY_PROJECTILE then
				game:ButterBeanFart(entity.Position, 10, entity, false, true)
			end
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SIREN_RING, 0, entity.Position, Vector.Zero, entity):ToEffect()
			effect:GetSprite().PlaybackSpeed = 1.1
			effect:FollowParent(entity)
			sfx:Play(SoundEffect.SOUND_ANGEL_BEAM, 0.5)
			effect.SpriteScale = effect.SpriteScale/1.3
			entity:SetColor(Color(1,1,1,1,1,0,0), 10, 0, true)
			return false
		end
	end
end)