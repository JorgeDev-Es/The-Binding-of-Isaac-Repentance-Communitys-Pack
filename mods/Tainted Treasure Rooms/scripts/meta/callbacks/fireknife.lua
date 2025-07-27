local mod = TaintedTreasure
local game = Game()

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife) -- Mom's Knife
	if knife.Variant ~= 0 and knife.Variant ~= 5 then
		return
	end

	local player = mod:getPlayerFromKnife(knife)
	if player == nil then return end

	local data = knife:GetData()
    if knife:IsFlying() then
		if not data.TTWasFlying then
            mod:RunCustomCallback("FIRE_KNIFE", {knife, player})
		end
	end
	data.TTWasFlying = knife:IsFlying()
end)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function(_, knife) --Club-type weapons
	if knife.SubType == 4 then
		local player = mod:getPlayerFromKnife(knife)
		if player == nil then return end
		mod:RunCustomCallback("FIRE_KNIFE", {knife, player})
	end
end)