local mod = FiendFolio
local game = Game()

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, function(_, entity, amount, flags)
	for _, champ in pairs(Isaac.FindByType(mod.FF.Champ.ID, mod.FF.Champ.Var)) do
		if champ:GetSprite():IsPlaying("Idle") then
			champ:GetSprite():Play("Sneer")
		end
	end
end, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	for _, champ in pairs(Isaac.FindByType(mod.FF.Champ.ID, mod.FF.Champ.Var)) do
		champ:Remove()
		Isaac.Spawn(mod.FF.Dominated.ID, mod.FF.Dominated.Var, 0, champ.Position, Vector.Zero, nil)
		mod.QuickSetEntityGridPath(champ, 0, true)

		for i = 1, 3 do
			Isaac.Spawn(1000, 193, 0, champ.Position, RandomVector(), champ)
		end
	end
end, CollectibleType.COLLECTIBLE_DADS_KEY)

return {
	Init = function(npc)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
		npc.GridCollisionClass = 0

		local sprite = npc:GetSprite()
		sprite:Play("Idle")

		local room = game:GetRoom()
		local centre = room:GetCenterPos()
		sprite.FlipX = npc.Position.X > centre.X
	end,

	AI = function(npc)
		local data = npc:GetData()
		local sprite = npc:GetSprite()

		mod.NegateKnockoutDrops(npc)
		if npc:Exists() and not npc:IsDead() then mod.QuickSetEntityGridPath(npc, 1900) end

		if sprite:IsFinished("Sneer") or sprite:IsFinished("Shock") then
			sprite:Play("Idle")
		elseif sprite:IsFinished("CryStart") then
			sprite:Play("CryLoop")
		end
	end,

	Death = function(npc)
		for _, marker in pairs(Isaac.FindByType(1000, 1965)) do
			if marker.SubType & ~ 3 == 0 then
				local data = marker:GetData()
				data.activateFrame = marker.FrameCount + 30
				marker.Visible = true
			end
		end

		mod.QuickSetEntityGridPath(npc, 0, true)
	end,
}