local mod = FiendFolio
local game = Game()

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, opp)
	if opp:ToPlayer() and not pickup.Touched then
		local player = opp:ToPlayer()
		local canPickup = false
		if player:GetMaxHearts() == 0 then
			canPickup = true
		elseif player:CanPickRedHearts() then
			canPickup = true
		end

        if canPickup then
            if player:GetData().ffsavedata.SpellSlots then
                local spells = player:GetData().ffsavedata.SpellSlots
                for _,tab in pairs(spells) do
                    tab.CurrentSlots = tab.MaxSlots
                end
            end
        end
	end
end, 380)

function mod:spellsNewLevel(player, data)
    if data.ffsavedata.SpellSlots then
        local spells = data.ffsavedata.SpellSlots
        for _,tab in pairs(spells) do
            tab.CurrentSlots = tab.MaxSlots
        end
    end
end