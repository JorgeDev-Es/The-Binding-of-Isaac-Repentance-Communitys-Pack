local mod = FiendFolio
local game = Game()
local rng = RNG()

local beggarvars = {
	4, --Beggar
	5, --Devil Beggar
	7, --Key Master
	13, --Battery Bum
	18, --Rotten Beggar
	1031, --Zodiac Beggar
}

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity)
	if #mod:GetPlayersHoldingTrinket(FiendFolio.ITEM.TRINKET.NESTING_DOLL) > 0 and mod:Contains(beggarvars, entity.Variant) and entity:GetSprite():GetAnimation() ~= "Teleport" and rng:RandomFloat() < 0.8 then
		local var = mod:GetRandomElem(beggarvars)
		if var ~= entity.Variant and entity.SpriteScale.X > 0.1 then
			local slot = Isaac.Spawn(EntityType.ENTITY_SLOT, var, 0, entity.Position, Vector.Zero, player)
			local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
			data.NestingSize = entity.SpriteScale*0.8
			slot.SpriteScale = data.NestingSize
		end
	end
end, EntityType.ENTITY_SLOT)

for i, entry in pairs(beggarvars) do
	FiendFolio.onEntityTick(EntityType.ENTITY_SLOT, function(slot)
		local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'SlotData', tostring(slot.InitSeed), {})
		if data.NestingSize then
			slot.SpriteScale = data.NestingSize
		end
	end, entry)
end