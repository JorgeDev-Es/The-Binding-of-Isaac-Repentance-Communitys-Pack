local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:ArachniteLogic(familiar)
	local player = familiar.Player
	if player:HasTrinket(FiendFolio.ITEM.ROCK.ARACHNITE) then
		familiar:Remove()
		
		local newvar
		local trinketpower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ARACHNITE)
		local chance = math.min(5 + player.Luck * 2, 10) * trinketpower
		local rand = mod:RandomInt(math.max(chance, 40), 150)
		
		if rand > 145 then
			newvar = 1
		elseif rand > 130 then
			newvar = 2
		else
			newvar = 0
		end
		
		if not (Isaac.CountEntities(player, 818) >= 64) then
			local npc = Isaac.Spawn(818, newvar, 0, familiar.Position, familiar.Velocity, player):ToNPC()
			npc:AddCharmed(EntityRef(player), -1)
			npc.CollisionDamage = npc.CollisionDamage * 0.2 * trinketpower
			npc.MaxHitPoints = npc.MaxHitPoints * 0.1
			npc.HitPoints = npc.MaxHitPoints
		end
	end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.ArachniteLogic, FamiliarVariant.BLUE_SPIDER)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.ArachniteLogic, FamiliarVariant.BLUE_SPIDER)