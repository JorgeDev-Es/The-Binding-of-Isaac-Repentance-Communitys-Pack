local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:FFChestOpening(pickup, collider)
	if collider.Type == 1 then
		collider = collider:ToPlayer()
		if (not pickup:GetData().Opened) and (pickup:GetSprite():WasEventTriggered("DropSound") or pickup:GetSprite():IsPlaying("Idle") or pickup:GetSprite():IsPlaying("IdleP2P")) then
			if (pickup:GetData().payToPlayMode and collider:GetNumCoins() > 0)
			or ((not pickup:GetData().payToPlayMode) and (collider:HasTrinket(TrinketType.TRINKET_PAPER_CLIP) or collider:TryUseKey())) then
				if pickup:GetData().payToPlayMode then
					collider:AddCoins(-1)
				end
				if pickup:GetData().payToPlayMode and pickup.Variant == 711 then
					pickup:GetSprite():Play("OpenP2P")
				else
					pickup:GetSprite():Play("Open")
				end
				pickup.SubType = mod.shopChestStates.Opening
				pickup:GetData().Opened = true
				sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 0, false, 1)
				sfx:Play(SoundEffect.SOUND_UNLOCK00, 1, 0, false, 1)

				if pickup.Variant == 713 then
					mod:openGlassChest(pickup)
				end

				if pickup.OptionsPickupIndex ~= 0 then
					local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
					for _, entity in ipairs(pickups) do
						if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
						   (entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
						then
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, nilvector, nil)
							entity:Remove()
						end
					end

					pickup.OptionsPickupIndex = 0
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.FFChestOpening, 710)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.FFChestOpening, 711)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.FFChestOpening, 713)