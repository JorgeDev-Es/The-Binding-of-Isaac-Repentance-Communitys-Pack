local mod = FiendFolio
local game = Game()
local rng = RNG()
local itemconfig = Isaac.GetItemConfig()

mod.LoadScripts({
    "ffscripts.jd.custompoopapi.main",
	"ffscripts.jd.ffpoops",
	
	"ffscripts.jd.items.gammagloves",
	"ffscripts.jd.items.twinkleofcontagion",
	"ffscripts.jd.items.sculptedpepper",
	"ffscripts.jd.items.toomanyoptions",
	
	"ffscripts.jd.trinkets.fushigi",
	"ffscripts.jd.trinkets.nestingdoll",
	"ffscripts.jd.trinkets.eggpenny",
	
	"ffscripts.jd.trinkets.rocks.atlasburden",
	"ffscripts.jd.trinkets.rocks.arachnite",
	
	"ffscripts.jd.enemies.volt",
	
	"ffscripts.jd.bosses.vanillachampions",
})

function mod:JDOnFireTear(player, tear, secondHandMultiplier, isLudo, ignorePlayerEffects)
	mod:FushigiOnFireTear(player, tear)
end

function mod:JDOnFireLaser(player, laser)
	mod:RollForFushigiTear(player, 10)
end

function mod:JDOnFireKnife(player, knife)
	if knife.Variant ~= 0 and knife.Variant ~= 5 then --Club-type weapons
		mod:RollForFushigiTear(player, 30)
	else
		mod:RollForFushigiTear(player, 10)
	end
end

function mod:JDOnFireBomb(player, bomb, secondHandMultiplier)
	mod:FushigiOnFireBomb(player, bomb)
end

function mod:JDOnFireRocket(player, target, secondHandMultiplier)

end

function mod:JDOnFireAquarius(player, creep, secondHandMultiplier)

end


function mod:GetAllPlayers()
	local players = {}
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i)
		if player:Exists() then
			table.insert(players, player)
		end
	end
	return players
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	local sprite = npc:GetSprite()
	local npcdata = npc:GetData()
	
	if npc.Variant == mod.FF.Volt.Var then
		mod:VoltAI(npc, sprite, npcdata)
	end
	
	if npc.Variant == mod.FF.PepperStatue.Var then
		mod:PepperAI(npc, sprite, npcdata)
	end
end, FiendFolio.FFID.JD)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, npc, amount, damageFlags, source) 
	if npc.Variant == mod.FF.Volt.Var then
		return mod:VoltHurt(npc, amount)
	end
	if npc.Variant == mod.FF.PepperStatue.Var then
		return mod:PepperHurt(npc, amount)
	end
end, FiendFolio.FFID.JD)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup) --Pica Golem
	if mod.PicaGolem and mod.GolemExists() and not itemconfig:GetCollectible(pickup.SubType):HasTags(ItemConfig.TAG_QUEST) then
		pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, mod.GetGolemTrinket(), true)
	end
end, PickupVariant.PICKUP_COLLECTIBLE)

function mod:GetPlayersHoldingTrinket(trinket)
	local players = {}
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:HasTrinket(trinket) then
			table.insert(players, player)
		end
	end
	return players
end

function mod:GetPlayersHoldingCollectible(item)
	local players = {}
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:HasCollectible(item) then
			table.insert(players, player)
		end
	end
	return players
end

function mod:IsPlayerWithCollectible(item)
	return #mod:GetPlayersHoldingCollectible(item) > 0
end

function mod:GetPlayersOfType(typ)
	local players = {}
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:GetPlayerType() == typ then
			table.insert(players, player)
		end
	end
	return players
end

function mod:IsPlayerOfType(typ)
	return #mod:GetPlayersOfType(typ) > 0
end

function mod:GetPlayersHoldingCollectibleOfType(item, typ)
	local players = {}
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:HasCollectible(item) and player:GetPlayerType() == typ then
			table.insert(players, player)
		end
	end
	return players
end

function mod:IsPlayerWithCollectibleOfType(item, typ)
	return #mod:GetPlayersHoldingCollectibleOfType(item, typ) > 0
end

function mod:GetPlayersHoldingTrinket(trinket)
	local players = {}
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:HasTrinket(trinket) then
			table.insert(players, player)
		end
	end
	return players
end

function mod:IsPlayerWithTrinket(trinket)
	return #mod:GetPlayersHoldingTrinket(trinket) > 0
end

function mod:GetTotalCollectibleNum(item)
	local num = 0
	for _, player in pairs(mod:GetAllPlayers()) do
		num = num + player:GetCollectibleNum(item)
	end
	return num
end

function mod:BasicRoll(scalar, cap, cappercent, customRNG)
	cappercent = cappercent or 1
	cap = cap + 1
	scalar = math.max(0, scalar)
	local rand = customRNG or rng

	local chance = math.min(cappercent, (cappercent / cap) * (cap + ((scalar + 1) - cap)))
	return (rng:RandomFloat() <=  chance)
end

local directions = {[0] = Vector(-1,0), [1] = Vector(0,-1), [2] = Vector(1,0), [3] = Vector(0, 1)}
function mod:GetVectorFromDirection(direction)
	return directions[direction]
end

function mod:GetClosest(pos, entities)
	local closestDist = nil
	local closest = nil

	for i, entity in pairs(entities) do
		if not closest or (entity.Position - pos):Length() < closestDist then
			closestDist = (entity.Position - pos):Length()
			closest = entity
		end
	end

	return closest
end

function mod:CheckIDInTableFromValues(table, id, var, sub)
    for _, entry in pairs(table) do
        if mod:CheckIDFromValues(entry, id, var, sub) then
            return true, entry[4]
        end
    end
    return false
end

function mod:CheckIDFromValues(entry, id, var, sub)
    if id == entry[1] then
        if entry[2] then
            if entry[2] == -1 or var == entry[2] then
                if entry[3] then
                    if entry[3] == -1 or sub == entry[3] then
                        return true
                    end
                else
                    return true
                end
            end
        else
            return true
        end
    end
end