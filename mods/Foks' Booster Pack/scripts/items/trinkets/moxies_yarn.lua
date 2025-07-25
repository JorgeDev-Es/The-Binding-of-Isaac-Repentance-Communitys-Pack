local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local basicFlyList = {
	[EntityType.ENTITY_FLY] = 1,
	[EntityType.ENTITY_ATTACKFLY] = 1,
	[EntityType.ENTITY_MOTER] = 2,
	[EntityType.ENTITY_ETERNALFLY] = 1,
	[EntityType.ENTITY_RING_OF_FLIES] = 1,
	[EntityType.ENTITY_DART_FLY] = 1,
	[EntityType.ENTITY_SWARM] = 1,
	[EntityType.ENTITY_HUSH_FLY] = 1,
	[EntityType.ENTITY_WILLO] = 1,
	[EntityType.ENTITY_ARMYFLY] = 1,
}

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc) -- Doing it on render bcs sometimes it spawned more flies than it should have
	local player = mod.RandomTrinketOwner(mod.Trinket.MOXIES_YARN, npc.InitSeed) -- In RGON+ should be replaced with the official function
	local flyNum = basicFlyList[npc.Type]
	
	if player and flyNum and not npc:IsDead() then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc:Remove()
		player:AddBlueFlies(flyNum, npc.Position, nil)
	end
end)