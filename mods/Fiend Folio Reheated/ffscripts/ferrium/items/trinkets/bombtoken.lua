local mod = FiendFolio
local sfx = SFXManager()

function mod:bombTokenEntDamage(npc, entry, flags, source)
    if flags == flags | DamageFlag.DAMAGE_EXPLOSION and (source and source.Type == 4) then
        local ent = source.Entity
        if ent:GetData().bombTokenDamage then
            entry.newDamage = entry.newDamage+ent:GetData().bombTokenDamage
            entry.sendNewDamage = true
            if ent:GetData().bombTokenDamage > 90 then
                sfx:Play(mod.Sounds.BombToken, 1, 0, false, 1)
            else
                sfx:Play(mod.Sounds.BombToken, 0.5, 0, false, 1)
            end
        end
    end
end

function mod:bombTokenPostFireBomb(player, bomb) --rockets are not bombs
    if player:HasTrinket(FiendFolio.ITEM.TRINKET.BOMB_TOKEN) then
        local mult = player:GetTrinketMultiplier(mod.ITEM.TRINKET.BOMB_TOKEN)
        if bomb.IsFetus then
            bomb:GetData().bombTokenDamage = bomb.ExplosionDamage*(mult-0.5)
        else
	    	bomb:GetData().bombTokenDamage = 100*mult
        end
	end
end

function mod:bombTokenUpdate(player, data)
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.BOMB_TOKEN) then
		local queuedItem = player.QueuedItem
		if queuedItem.Item ~= nil and queuedItem.Item:IsTrinket() and queuedItem.Item.ID == FiendFolio.ITEM.TRINKET.BOMB_TOKEN then
			if not data.bombTokenHeld then
				sfx:Play(mod.Sounds.Tada, 1, 0, false, 1)
				data.bombTokenHeld = true
			end
		else
			data.bombTokenHeld = nil
		end
    end
end
