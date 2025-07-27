local mod = TaintedTreasure
local game = Game()
local rng = RNG()

function mod:AtlasFloorLogic()
	local level = game:GetLevel()
	if level:GetStage() ~= LevelStage.STAGE8 then --Home
		local generate = 3
		local currentroomidx = level:GetCurrentRoomIndex()
		
		for i, player in pairs(mod:GetPlayersHoldingCollectible(TaintedCollectibles.ATLAS)) do
			generate = generate + player:GetCollectibleNum(TaintedCollectibles.ATLAS)
		end
		
		for i = generate, 1, -1 do
			mod:GenerateExtraRoom()
		end
	end
end