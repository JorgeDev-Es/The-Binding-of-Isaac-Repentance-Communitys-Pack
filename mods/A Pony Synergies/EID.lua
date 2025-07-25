local APonyDescriptions = {
  [369] = "Upon hitting a wall, you warp around to the opposite wall.",
  [118] = "You shoot a brimstone out behind you.",
  [68] = "You fire out a cross of 4 technology lasers.",
  [152] = "You fire out a cross of 4 technology lasers.",
  [395] = "You fire out a cross of 4 technology lasers.",
  [374] = "Spawns holy light beams every so often.",
  [594] = "You shoot out poison tears from behind you every so often.",
  [87] = "You fire out a cross of 4 tears every so often.",
  [131] = "Drops quick exploding bomb's repeatedly.",
  [119] = "Leaves behind a constant trail of blood.",
  [138] = "Leaves behind a constant trail of blood.",
  [149] = "Makes poison explosions when you hit an enemy. These explosions can't damage you.",
  [180] = "Farts when you hit an enemy.",
  [204] = "Has a chance to spawn a pickup when hitting an enemy.",
  [151] = "Chance to spawn a blue fly when hitting an enemy.",
  [211] = "Spawns a blue spider when hitting an enemy.",
  [217] = "Spawns a blue spider when hitting an enemy.",
  [240] = "Applies either poison, burn, confusion, or slow when hitting an enemy.",
  [257] = "Chance to make a fiery explosion when hitting an enemy.",
  [259] = "Applies fear to hit enemies.",
  [276] = "Fires blood tears behind you every so often.",
  [305] = "Poisons hit enemies.",
  [317] = "Leaves behind a constant trail of damaging green creep.",
  [418] = "Applies random status effects to hit enemies.",
  [570] = "Applies random status effects to hit enemies.",
  [424] = "Sometimes spawns a sack when hitting an enemy.",
  [429] = "Sometimes spawns a coin when hitting an enemy.",
  [459] = "Puts 1-3 boogers on hit enemies.",
  [460] = "Chance to apply permanent confusion to hit enemies.",
  [553] = "Puts 1-3 spores on hit enemies.",
  [576] = "Spawns dips when hitting enemies.",
  [658] = "Minisaacs dash along side you.",
  [596] = "Freezes hit enemies, instantly killing them.",
  [606] = "Chance to make a rift when you hit an enemy.",
  [683] = "Spawns bone spurs constantly while riding.",
  [592] = "Shoots rocks out when hitting a wall.",
  [315] = "Attacts enemies towards you while riding.",
  [617] = "Attacts enemies towards you while riding.",
  [533] = "A giant trisagion blast surrounds you for the as you charge.",
  [378] = "Drops butt bomb constantly while riding.",
  [373] = "The dash deals more damage the more enemies you hit.",
  [696] = "Chance to spawn a cross of lasers when hitting an enemy.",
  [237] = "Chance to turn killed enemies into friendly bonies.",
}

local APonyTrinkets = {
  [2] = "Chance to spawn a poop upon hitting an enemy.",
  [5] = "Chance to spawn an additional pickup when killing a champion enemy.",
  [18] = "Chance to spawn a {{Collectible374}} Holy Light beam when hitting an enemy.",
  [30] = "Chance to poison hit enemies.",
}

local function APonyCondition(descObj)
  for itemID, _ in pairs(APonyDescriptions) do
	if descObj.ObjSubType == itemID and descObj.ObjType == 5 and descObj.ObjVariant == 100 then
	  for p = 0, Game():GetNumPlayers() - 1 do
		local player = Game():GetPlayer(p)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PONY) or player:HasCollectible(CollectibleType.COLLECTIBLE_WHITE_PONY) then
		  return true
		end
	  end	
	end
  end
  for trinketID, _ in pairs(APonyTrinkets) do
	if descObj.ObjSubType == trinketID and descObj.ObjType == 5 and descObj.ObjVariant == 350 then
	  for p = 0, Game():GetNumPlayers() - 1 do
		local player = Game():GetPlayer(p)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PONY) or player:HasCollectible(CollectibleType.COLLECTIBLE_WHITE_PONY) then
		  return true
		end
	  end	
	end
  end
  return false
end

local function APonyCallback(descObj)
  if descObj.ObjVariant == 100 then
	local itemID = descObj.ObjSubType
	local appendDesc = "#{{Collectible130}} "..APonyDescriptions[itemID]
	EID:appendToDescription(descObj, appendDesc)
  elseif descObj.ObjVariant == 350 then
	local trinketID = descObj.ObjSubType
	local appendDesc = "#{{Collectible130}} "..APonyTrinkets[trinketID]
	EID:appendToDescription(descObj, appendDesc)
  end

  return descObj
end

if EID then
	EID:addDescriptionModifier("A Pony", APonyCondition, APonyCallback)
end

APonySyn:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, para)
  if cmd == "pony" then
	local player = Isaac.GetPlayer()
	player:AddCollectible(CollectibleType.COLLECTIBLE_PONY)
	Isaac.ExecuteCommand("debug 8")
	for item, _ in pairs(APonyDescriptions) do
	  if not player:HasCollectible(item) then
		player:AddCollectible(item)
	  end
	end
  end
end)
