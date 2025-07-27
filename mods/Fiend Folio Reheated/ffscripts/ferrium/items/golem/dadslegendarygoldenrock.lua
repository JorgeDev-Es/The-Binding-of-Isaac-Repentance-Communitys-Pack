local mod = FiendFolio
local game = Game()

function mod:dadsLegendaryGoldenRockSwap(player)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK) then
		for i=0,1 do
			if mod:GetRealTrinketId(player:GetTrinket(i)) == FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK and not mod:IsGoldTrinket(player:GetTrinket(i)) then
				player:TryRemoveTrinket(player:GetTrinket(i))
				player:AddTrinket(FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK + TrinketType.TRINKET_GOLDEN_FLAG)
			end
		end
	end
end

function mod:dadsLegendaryGoldenRockUpdate(trinket)
	if mod:GetRealTrinketId(trinket.SubType) == FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK then
		local sprite = trinket:GetSprite()
		if not mod:IsGoldTrinket(trinket.SubType) then
			--Isaac.Spawn(5, 350, FiendFolio.ITEM.ROCK.DADS_LEGENDARY_GOLDEN_ROCK+TrinketType.TRINKET_GOLDEN_FLAG, trinket.Position, trinket.Velocity, nil)
			--trinket:Remove()
			--trinket:Morph(trinket.Type, trinket.Variant, trinket.SubType + TrinketType.TRINKET_GOLDEN_FLAG, true, true, true)
		end
		
		if game:GetFrameCount() % 15 == 0 then
			local sparkle = Isaac.Spawn(1000, 1727, 0, trinket.Position+Vector(math.random(-10,10),math.random(-10,10)), Vector.Zero, trinket):ToEffect()
			sparkle.SpriteOffset = Vector(0,-7)
			sparkle.SpriteScale = Vector(0.8, 0.8)
			sparkle:SetColor(Color(1,1,1,1,1,1,0), 100, 1, false, false)
			sparkle:Update()
		end
	end
end