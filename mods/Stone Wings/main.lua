StoneWings = RegisterMod("Stone Wings", 1)
local mod = StoneWings

local stoneWingsItem = Isaac.GetItemIdByName("Stone Wings")

-- Lágrima de piedra
function mod:OnTearFired(tear)
	local player = Isaac.GetPlayer()
	if player:HasCollectible(stoneWingsItem) then
		tear:ChangeVariant(TearVariant.ROCK)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.OnTearFired)

-- Lógica del objeto
function mod:stoneWingsLogic(player, cacheFlag)
	if player:HasCollectible(stoneWingsItem) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.2
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay * 0.61
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed * 1
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			player.CanFly = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.stoneWingsLogic)

-- Para hacer que el item se muestre en español al tomarlo
local itemsSPA = {
	{stoneWingsItem, "Alas de piedra", "El peso del destino"}, -- Spa
}
local Language = Options.Language
local queueLastFrame
local queueNow
function mod.onUpdate(_, player)
	queueNow = player.QueuedItem.Item
	if (queueNow ~= nil) then	
		if Language == "es" then
			for i,item in ipairs(itemsSPA) do
				if (queueNow.ID == item[1] and queueNow:IsCollectible() and queueLastFrame == nil) then
					Game():GetHUD():ShowItemText(item[2], item[3])
				end
			end
		end
	end
	queueLastFrame = queueNow
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.onUpdate)

-- Soporte con EID
if EID then
	EID:addCollectible(stoneWingsItem, "Flight#{{ArrowDown}} {{Speed}} -0.2 Speed down#{{ArrowUp}} {{Tears}} +1.5 Tears up#Your tears will become stone tears, however, you can't break rocks", "Stone wings", "en_us")
	EID:addCollectible(stoneWingsItem, "Recibes vuelo#{{ArrowDown}} {{Speed}} Velocidad -0.2#{{ArrowUp}} {{Tears}} Lágrimas +1.5#Tus lágrimas se volverán de piedra, sin embargo, no puedes romper rocas", "Alas de piedra", "spa")
end

